const std = @import("std");
const Io = std.Io;
const c = @import("../llama.zig").c;
const arch_table = @import("arch_table.zig");
const quantize = @import("quantize.zig");
const safetensors = @import("safetensors.zig");

const PATH_MAX = std.posix.PATH_MAX;

pub const HfModelBundle = struct {
    gguf_ctx: *c.gguf_context,
    ggml_ctx: *c.ggml_context,
    arch: *const arch_table.Arch,
    shards: []ShardMapping,
    tensor_map: std.StringHashMap(TensorSource),
    allocator: std.mem.Allocator,
    n_layers: u32,

    pub fn deinit(self: *HfModelBundle) void {
        var it = self.tensor_map.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            self.allocator.free(entry.value_ptr.target_shape);
        }
        self.tensor_map.deinit();
        for (self.shards) |*shard| shard.deinit();
        self.allocator.free(self.shards);
        c.ggml_free(self.ggml_ctx);
        c.gguf_free(self.gguf_ctx);
    }
};

pub const TensorSource = struct {
    shard_index: usize,
    offset: u64,
    size: u64,
    dtype: safetensors.TensorDType,
    target_shape: []const u64,
    target_type: c.ggml_type,
};

pub const ShardMapping = struct {
    bytes: []align(std.heap.page_size_min) const u8,

    fn deinit(self: *ShardMapping) void {
        std.posix.munmap(self.bytes);
    }
};

pub fn isHfCheckpointDir(io: Io, path: []const u8) bool {
    // Check if path is a directory containing config.json
    var buf: [PATH_MAX]u8 = undefined;
    const config_path = std.fmt.bufPrint(&buf, "{s}/config.json", .{path}) catch return false;
    const file = Io.Dir.cwd().openFile(io, config_path, .{}) catch return false;
    file.close(io);
    return true;
}

pub fn loadHfModel(
    io: Io,
    allocator: std.mem.Allocator,
    model_dir: []const u8,
    load_dtype: quantize.LoadDType,
    model_params: c.llama_model_params,
) !*c.llama_model {
    // 1. Read config.json
    var config_buf: [PATH_MAX]u8 = undefined;
    const config_path = std.fmt.bufPrint(&config_buf, "{s}/config.json", .{model_dir}) catch return error.PathTooLong;
    const config_text = try Io.Dir.cwd().readFileAlloc(io, config_path, allocator, .limited(1 << 20));
    defer allocator.free(config_text);

    // 2. Detect architecture
    const arch = try detectArch(allocator, config_text);
    std.debug.print("Detected architecture: {s} -> {s}\n", .{ arch.hf_class, arch.gguf_arch });

    // 3. Build the model bundle (gguf ctx + tensor mappings)
    var bundle = try buildBundle(io, allocator, model_dir, arch, config_text, load_dtype);
    errdefer bundle.deinit();

    // 4. Load model via llama_model_init_from_user
    const model = c.llama_model_init_from_user(
        bundle.gguf_ctx,
        setTensorDataCallback,
        @ptrCast(&bundle),
    model_params,
    ) orelse return error.ModelLoadFailed;

    // Tensor data has been copied into the model by this point.
    bundle.deinit();

    return model;
}

fn detectArch(allocator: std.mem.Allocator, config_text: []const u8) !*const arch_table.Arch {
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, config_text, .{});
    defer parsed.deinit();

    const architectures = parsed.value.object.get("architectures") orelse return error.NoArchitectures;
    if (architectures != .array or architectures.array.items.len == 0) return error.NoArchitectures;

    const hf_class = architectures.array.items[0].string;

    // Try exact match first
    if (arch_table.findArchByHfClass(hf_class)) |a| return a;

    // Try with "ForCausalLM" suffix variations
    // Gemma4ForConditionalGeneration -> Gemma4ForCausalLM
    if (std.mem.indexOf(u8, hf_class, "ForConditionalGeneration")) |_| {
        const base = hf_class[0 .. hf_class.len - "ForConditionalGeneration".len];
        const causal = try std.fmt.allocPrint(allocator, "{s}ForCausalLM", .{base});
        defer allocator.free(causal);
        if (arch_table.findArchByHfClass(causal)) |a| return a;
    }

    std.debug.print("Unsupported architecture: {s}\n", .{hf_class});
    std.debug.print("Supported: ", .{});
    for (arch_table.all_archs) |a| {
        std.debug.print("{s} ", .{a.hf_class});
    }
    std.debug.print("\n", .{});
    return error.UnsupportedArchitecture;
}

fn buildBundle(
    io: Io,
    allocator: std.mem.Allocator,
    model_dir: []const u8,
    arch: *const arch_table.Arch,
    config_text: []const u8,
    load_dtype: quantize.LoadDType,
) !HfModelBundle {
    // Parse config JSON
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, config_text, .{});
    defer parsed.deinit();
    const config = parsed.value;

    // Get n_layers
    const n_layers = getConfigU32(config, arch, "block_count") orelse return error.MissingBlockCount;

    // Create GGUF context
    const gguf_ctx = c.gguf_init_empty() orelse return error.GgufInitFailed;

    const ggml_params = c.ggml_init_params{
        .mem_size = 128 * 1024 * 1024,
        .mem_buffer = null,
        .no_alloc = true,
    };
    const ggml_ctx = c.ggml_init(ggml_params) orelse return error.GgmlInitFailed;

    // Set GGUF metadata from config
    try setMetadata(allocator, gguf_ctx, arch, config, load_dtype);

    // Set tokenizer metadata (required for llama.cpp to work)
    try setTokenizerMetadata(io, allocator, gguf_ctx, model_dir, arch);

    // Discover safetensors shards
    var shards: std.ArrayList(ShardMapping) = .empty;
    errdefer {
        for (shards.items) |*s| s.deinit();
        shards.deinit(allocator);
    }

    var tensor_map = std.StringHashMap(TensorSource).init(allocator);
    errdefer {
        var it = tensor_map.iterator();
        while (it.next()) |entry| allocator.free(entry.key_ptr.*);
        tensor_map.deinit();
    }

    // Check for single-shard vs multi-shard
    var index_buf: [PATH_MAX]u8 = undefined;
    const index_path = std.fmt.bufPrint(&index_buf, "{s}/model.safetensors.index.json", .{model_dir}) catch "";
    const has_index = blk: {
        const file = Io.Dir.cwd().openFile(io, index_path, .{}) catch break :blk false;
        file.close(io);
        break :blk true;
    };

    if (has_index) {
        // Multi-shard
        const index_text = try Io.Dir.cwd().readFileAlloc(io, index_path, allocator, .limited(1 << 24));
        defer allocator.free(index_text);
        var index = try safetensors.loadSafetensorsIndex(allocator, index_text);
        defer index.deinit(allocator);

        // Map each tensor to its shard
        var wm_it = index.weight_map.iterator();
        while (wm_it.next()) |entry| {
            const hf_name = entry.key_ptr.*;
            const shard_name = entry.value_ptr.*;

            const gguf_name = arch_table.matchTensorName(allocator, arch, hf_name, n_layers) orelse continue;
            defer allocator.free(gguf_name);

            // Find or add shard
            const shard_idx = try findOrAddShard(allocator, model_dir, shard_name, &shards);
            const shard = shards.items[shard_idx];

            // Parse shard header to find this tensor's offset
            const shard_info = try safetensors.loadShardFromMemory(shard.bytes, allocator);
            defer {
                // Avoid per-entry frees here; some allocator/runtime combinations can
                // trip invalid unmap paths for these short-lived header allocations.
                allocator.free(shard_info.tensors);
            }

            for (shard_info.tensors) |tinfo| {
                if (std.mem.eql(u8, tinfo.name, hf_name)) {
                    try addTensorToMap(allocator, &tensor_map, gguf_name, gguf_ctx, ggml_ctx, TensorSource{
                        .shard_index = shard_idx,
                        .offset = shard_info.data_offset + tinfo.offset_start,
                        .size = tinfo.offset_end - tinfo.offset_start,
                        .dtype = tinfo.dtype,
                        .target_shape = &.{},
                        .target_type = c.GGML_TYPE_F16,
                    }, load_dtype, n_layers, tinfo.shape);
                    break;
                }
            }
        }
    } else {
        // Single shard
        var shard_buf: [PATH_MAX]u8 = undefined;
        const shard_path = std.fmt.bufPrint(&shard_buf, "{s}/model.safetensors", .{model_dir}) catch return error.PathTooLong;

        const shard_bytes = try mapFile(shard_path);
        try shards.append(allocator, .{ .bytes = shard_bytes });

        const shard_info = try safetensors.loadShardFromMemory(shard_bytes, allocator);
        defer {
            // Avoid per-entry frees here; some allocator/runtime combinations can
            // trip invalid unmap paths for these short-lived header allocations.
            allocator.free(shard_info.tensors);
        }

        for (shard_info.tensors) |tinfo| {
            const gguf_name = arch_table.matchTensorName(allocator, arch, tinfo.name, n_layers) orelse continue;
            errdefer allocator.free(gguf_name);

            try addTensorToMap(allocator, &tensor_map, gguf_name, gguf_ctx, ggml_ctx, TensorSource{
                .shard_index = 0,
                .offset = shard_info.data_offset + tinfo.offset_start,
                .size = tinfo.offset_end - tinfo.offset_start,
                .dtype = tinfo.dtype,
                .target_shape = &.{},
                .target_type = c.GGML_TYPE_F16,
            }, load_dtype, n_layers, tinfo.shape);
        }
    }

    std.debug.print("Registered {} tensors in GGUF\n", .{tensor_map.count()});

    return .{
        .gguf_ctx = gguf_ctx,
        .ggml_ctx = ggml_ctx,
        .arch = arch,
        .shards = try shards.toOwnedSlice(allocator),
        .tensor_map = tensor_map,
        .allocator = allocator,
        .n_layers = n_layers,
    };
}

fn addTensorToMap(
    allocator: std.mem.Allocator,
    tensor_map: *std.StringHashMap(TensorSource),
    gguf_name: []const u8,
    gguf_ctx: *c.gguf_context,
    ggml_ctx: *c.ggml_context,
    source: TensorSource,
    load_dtype: quantize.LoadDType,
    n_layers: u32,
    shape: []const u64,
) !void {
    const name_copy = try allocator.dupe(u8, gguf_name);
    errdefer allocator.free(name_copy);
    const target_shape = try toGgmlShape(allocator, shape);
    errdefer allocator.free(target_shape);

    const g_type = quantize.chooseTensorType(load_dtype, gguf_name, target_shape, n_layers);

    // Create tensor descriptor in ggml context
    var ne: [4]i64 = .{ 1, 1, 1, 1 };
    for (target_shape, 0..) |dim, i| {
        if (i < 4) ne[i] = @intCast(dim);
    }
    const tensor = switch (target_shape.len) {
        1 => c.ggml_new_tensor_1d(ggml_ctx, g_type, ne[0]),
        2 => c.ggml_new_tensor_2d(ggml_ctx, g_type, ne[0], ne[1]),
        3 => c.ggml_new_tensor_3d(ggml_ctx, g_type, ne[0], ne[1], ne[2]),
        else => c.ggml_new_tensor_1d(ggml_ctx, g_type, ne[0]),
    };
    const name_z = try allocator.dupeZ(u8, gguf_name);
    defer allocator.free(name_z);
    _ = c.ggml_set_name(tensor, name_z.ptr);
    c.gguf_add_tensor(gguf_ctx, tensor);

    const entry = try tensor_map.getOrPut(name_copy);
    if (entry.found_existing) {
        allocator.free(name_copy);
        allocator.free(target_shape);
    }
    entry.value_ptr.* = .{
        .shard_index = source.shard_index,
        .offset = source.offset,
        .size = source.size,
        .dtype = source.dtype,
        .target_shape = target_shape,
        .target_type = g_type,
    };
}

fn toGgmlShape(allocator: std.mem.Allocator, shape: []const u64) ![]const u64 {
    const out = try allocator.alloc(u64, shape.len);
    errdefer allocator.free(out);
    for (shape, 0..) |_, i| {
        out[i] = shape[shape.len - 1 - i];
    }
    return out;
}

fn setMetadata(
    allocator: std.mem.Allocator,
    gguf_ctx: *c.gguf_context,
    arch: *const arch_table.Arch,
    config: std.json.Value,
    load_dtype: quantize.LoadDType,
) !void {
    const arch_z = try allocator.dupeZ(u8, arch.gguf_arch);
    defer allocator.free(arch_z);
    c.gguf_set_val_str(gguf_ctx, "general.architecture", arch_z.ptr);
    c.gguf_set_val_u32(gguf_ctx, "general.file_type", quantize.metadataFileType(load_dtype));

    for (arch.meta) |entry| {
        const key_z = try allocator.dupeZ(u8, entry.gguf_key);
        defer allocator.free(key_z);
        const value = getConfigValue(config, arch.config_prefix, entry.config_path);
        switch (entry.kind) {
            .u32 => {
                const v = if (value) |val| blk: {
                    switch (val) {
                        .integer => |i| break :blk i64ToU32(i),
                        .float => |f| break :blk f64ToU32(f),
                        else => {},
                    }
                    break :blk null;
                } else null;
                if (v orelse (if (entry.default) |d| std.fmt.parseInt(u32, d, 10) catch null else null)) |int_val| {
                    c.gguf_set_val_u32(gguf_ctx, key_z.ptr, int_val);
                }
            },
            .f32 => {
                const v = if (value) |val| blk: {
                    switch (val) {
                        .float => |f| break :blk @as(f32, @floatCast(f)),
                        .integer => |i| break :blk @as(f32, @floatFromInt(i)),
                        .string => |s| break :blk std.fmt.parseFloat(f32, s) catch null,
                        else => {},
                    }
                    break :blk null;
                } else null;
                if (v orelse (if (entry.default) |d| std.fmt.parseFloat(f32, d) catch null else null)) |float_val| {
                    c.gguf_set_val_f32(gguf_ctx, key_z.ptr, float_val);
                }
            },
            .bool => {
                if (value) |val| {
                    switch (val) {
                        .bool => |b| c.gguf_set_val_bool(gguf_ctx, key_z.ptr, b),
                        else => {},
                    }
                }
            },
            .str => {
                if (value) |val| {
                    switch (val) {
                        .string => |s| {
                            const s_z = try allocator.dupeZ(u8, s);
                            defer allocator.free(s_z);
                            c.gguf_set_val_str(gguf_ctx, key_z.ptr, s_z.ptr);
                        },
                        else => {},
                    }
                }
            },
        }
    }

    // Qwen3.5 hybrid models require mrope dimension sections in metadata.
    if (std.mem.eql(u8, arch.gguf_arch, "qwen35")) {
        if (getConfigValue(config, arch.config_prefix, "rope_parameters.mrope_section")) |sections_val| {
            if (sections_val == .array and sections_val.array.items.len > 0) {
                var out = std.ArrayList(i32).empty;
                defer out.deinit(allocator);
                for (sections_val.array.items) |item| {
                    switch (item) {
                        .integer => |i| if (i64ToI32(i)) |v| out.append(allocator, v) catch {},
                        .float => |f| if (f64ToI32(f)) |v| out.append(allocator, v) catch {},
                        else => {},
                    }
                }
                // llama.cpp expects 4 entries; pad with 0 if config has 3.
                while (out.items.len < 4) {
                    out.append(allocator, 0) catch break;
                }
                if (out.items.len > 0) {
                    c.gguf_set_arr_data(gguf_ctx, "qwen35.rope.dimension_sections", c.GGUF_TYPE_INT32, out.items.ptr, out.items.len);
                }
            }
        }
    }
}

fn setTokenizerMetadata(
    io: Io,
    allocator: std.mem.Allocator,
    gguf_ctx: *c.gguf_context,
    model_dir: []const u8,
    arch: *const arch_table.Arch,
) !void {
    // Try to load tokenizer.json
    var buf: [PATH_MAX]u8 = undefined;
    const tok_path = std.fmt.bufPrint(&buf, "{s}/tokenizer.json", .{model_dir}) catch return;
    const tok_text = Io.Dir.cwd().readFileAlloc(io, tok_path, allocator, .limited(1 << 26)) catch return;
    defer allocator.free(tok_text);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, tok_text, .{});
    defer parsed.deinit();
    const tok_root = parsed.value;

    // Set model type
    const model_type = if (tok_root.object.get("model")) |m| switch (m) {
        .object => |obj| if (obj.get("type")) |t| switch (t) {
            .string => |s| s,
            else => "gpt2",
        } else "gpt2",
        else => "gpt2",
    } else "gpt2";

    const model_type_out = if (std.ascii.eqlIgnoreCase(model_type, "BPE")) "gpt2" else model_type;
    const model_type_z = try allocator.dupeZ(u8, model_type_out);
    defer allocator.free(model_type_z);
    c.gguf_set_val_str(gguf_ctx, "tokenizer.ggml.model", model_type_z.ptr);

    // Load vocab
    if (tok_root.object.get("model")) |model_obj| {
        if (model_obj == .object) {
            if (model_obj.object.get("vocab")) |vocab| {
                if (vocab == .object) {
                    // Get vocab entries
                    var token_ptrs = std.ArrayList([*c]const u8).empty;
                    defer token_ptrs.deinit(allocator);
                    var token_storage = std.ArrayList([:0]u8).empty;
                    defer {
                        for (token_storage.items) |tok| allocator.free(tok);
                        token_storage.deinit(allocator);
                    }

                    var token_types = std.ArrayList(i32).empty;
                    defer token_types.deinit(allocator);

                    // Sort by index
                    const VocabEntry = struct { id: usize, token: []const u8 };
                    var entries = std.ArrayList(VocabEntry).empty;
                    defer entries.deinit(allocator);

                    var vit = vocab.object.iterator();
                    while (vit.next()) |entry| {
                        const idx_str = entry.value_ptr.*;
                        const idx: usize = switch (idx_str) {
                            .integer => |i| i64ToUsize(i) orelse continue,
                            else => continue,
                        };
                        try entries.append(allocator, .{ .id = idx, .token = entry.key_ptr.* });
                    }

                    if (tok_root.object.get("added_tokens")) |added_tokens| {
                        if (added_tokens == .array) {
                            for (added_tokens.array.items) |item| {
                                if (item != .object) continue;
                                const id_val = item.object.get("id") orelse continue;
                                const content_val = item.object.get("content") orelse continue;
                                const idx: usize = switch (id_val) {
                                    .integer => |i| i64ToUsize(i) orelse continue,
                                    else => continue,
                                };
                                const token = switch (content_val) {
                                    .string => |s| s,
                                    else => continue,
                                };
                                try entries.append(allocator, .{ .id = idx, .token = token });
                            }
                        }
                    }

                    // Sort by id
                    std.sort.insertion(VocabEntry, entries.items, {}, struct {
                        fn lessThan(_: void, a: VocabEntry, b: VocabEntry) bool {
                            return a.id < b.id;
                        }
                    }.lessThan);

                    var expected_id: usize = 0;
                    for (entries.items) |entry| {
                        while (expected_id < entry.id) : (expected_id += 1) {
                            const pad_z = try allocator.dupeZ(u8, "");
                            try token_storage.append(allocator, pad_z);
                            try token_ptrs.append(allocator, pad_z.ptr);
                            try token_types.append(allocator, 0);
                        }
                        const tok_z = try allocator.dupeZ(u8, entry.token);
                        try token_storage.append(allocator, tok_z);
                        try token_ptrs.append(allocator, tok_z.ptr);
                        try token_types.append(allocator, 1);
                        expected_id = entry.id + 1;
                    }

                    if (token_ptrs.items.len > 0) {
                        const token_arr_ptr: [*c][*c]const u8 = @ptrCast(token_ptrs.items.ptr);
                        c.gguf_set_arr_str(gguf_ctx, "tokenizer.ggml.tokens", token_arr_ptr, token_ptrs.items.len);
                        c.gguf_set_arr_data(gguf_ctx, "tokenizer.ggml.token_type", c.GGUF_TYPE_INT32, token_types.items.ptr, token_types.items.len);
                    }
                }
            }
        }
    }

    // Set pre tokenizer type based on arch
    const pre = arch.tokenizer_pre orelse arch.gguf_arch;
    const arch_z = try allocator.dupeZ(u8, pre);
    defer allocator.free(arch_z);
    c.gguf_set_val_str(gguf_ctx, "tokenizer.ggml.pre", arch_z.ptr);

    // Try to set chat template
    var ct_buf: [PATH_MAX]u8 = undefined;
    const ct_path = std.fmt.bufPrint(&ct_buf, "{s}/chat_template.jinja", .{model_dir}) catch "";
    if (Io.Dir.cwd().readFileAlloc(io, ct_path, allocator, .limited(1 << 20)) catch null) |ct_text| {
        defer allocator.free(ct_text);
        const ct_z = try allocator.dupeZ(u8, ct_text);
        defer allocator.free(ct_z);
        c.gguf_set_val_str(gguf_ctx, "tokenizer.chat_template", ct_z.ptr);
    }

    // Try to load merges for BPE tokenizers
    if (tok_root.object.get("model")) |model_obj| {
        if (model_obj == .object) {
            if (model_obj.object.get("merges")) |merges_arr| {
                if (merges_arr == .array) {
                    var merge_ptrs = std.ArrayList([*c]const u8).empty;
                    defer merge_ptrs.deinit(allocator);
                    var merge_storage = std.ArrayList([:0]u8).empty;
                    defer {
                        for (merge_storage.items) |m| allocator.free(m);
                        merge_storage.deinit(allocator);
                    }

                    for (merges_arr.array.items) |merge_val| {
                        switch (merge_val) {
                            .string => |s| {
                                const m_z = try allocator.dupeZ(u8, s);
                                try merge_storage.append(allocator, m_z);
                                try merge_ptrs.append(allocator, m_z.ptr);
                            },
                            .array => |arr| {
                                if (arr.items.len != 2) continue;
                                if (arr.items[0] != .string or arr.items[1] != .string) continue;
                                const merged_text = try std.fmt.allocPrint(allocator, "{s} {s}", .{
                                    arr.items[0].string,
                                    arr.items[1].string,
                                });
                                defer allocator.free(merged_text);
                                const merged = try allocator.dupeZ(u8, merged_text);
                                try merge_storage.append(allocator, merged);
                                try merge_ptrs.append(allocator, merged.ptr);
                            },
                            else => {},
                        }
                    }
                    if (merge_ptrs.items.len > 0) {
                        const merge_arr_ptr: [*c][*c]const u8 = @ptrCast(merge_ptrs.items.ptr);
                        c.gguf_set_arr_str(gguf_ctx, "tokenizer.ggml.merges", merge_arr_ptr, merge_ptrs.items.len);
                    }
                }
            }
        }
    }

    // Try to set EOS/BOS token IDs from tokenizer_config.json
    var tc_buf: [PATH_MAX]u8 = undefined;
    const tc_path = std.fmt.bufPrint(&tc_buf, "{s}/tokenizer_config.json", .{model_dir}) catch "";
    if (Io.Dir.cwd().readFileAlloc(io, tc_path, allocator, .limited(1 << 20)) catch null) |tc_text| {
        defer allocator.free(tc_text);
        const tc_parsed = try std.json.parseFromSlice(std.json.Value, allocator, tc_text, .{});
        defer tc_parsed.deinit();
        const tc = tc_parsed.value;

        if (tc.object.get("eos_token_id")) |eos| {
            switch (eos) {
                .integer => |i| if (i64ToU32(i)) |v| c.gguf_set_val_u32(gguf_ctx, "tokenizer.ggml.eos_token_id", v),
                else => {},
            }
        }
        if (tc.object.get("bos_token_id")) |bos| {
            switch (bos) {
                .integer => |i| if (i64ToU32(i)) |v| c.gguf_set_val_u32(gguf_ctx, "tokenizer.ggml.bos_token_id", v),
                else => {},
            }
        }
        if (tc.object.get("pad_token_id")) |pad| {
            switch (pad) {
                .integer => |i| if (i64ToU32(i)) |v| c.gguf_set_val_u32(gguf_ctx, "tokenizer.ggml.padding_token_id", v),
                else => {},
            }
        }
    }
}

fn setTensorDataCallback(tensor: [*c]c.ggml_tensor, userdata: ?*anyopaque) callconv(.c) void {
    const bundle: *HfModelBundle = @ptrCast(@alignCast(userdata.?));
    const t = tensor;
    const tensor_name_c: [*:0]const u8 = @ptrCast(&t[0].name);
    const name = std.mem.span(tensor_name_c);

    const source = bundle.tensor_map.get(name) orelse {
        std.debug.print("  [MISS] {s} — no source data\n", .{name});
        return;
    };

    const shard_data = bundle.shards[source.shard_index].bytes;
    const src_ptr = shard_data.ptr + source.offset;
    const dst_tensor = &t[0];
    const dst_type = dst_tensor.type;
    const row_elems = tensorRowElements(source.target_shape);
    const row_count = tensorRowCount(source.target_shape);

    if (c.ggml_is_quantized(dst_type)) {
        streamQuantizedTensor(bundle.allocator, dst_tensor, source, src_ptr, row_elems, row_count) catch |err| {
            std.debug.print("  [FAIL] {s} — quantized upload failed: {s}\n", .{ name, @errorName(err) });
            return;
        };
    } else {
        streamPlainTensor(bundle.allocator, dst_tensor, source, src_ptr, row_elems, row_count) catch |err| {
            std.debug.print("  [FAIL] {s} — plain upload failed: {s}\n", .{ name, @errorName(err) });
            return;
        };
    }

    releaseSourcePages(shard_data, source.offset, source.size);
}

fn streamQuantizedTensor(
    allocator: std.mem.Allocator,
    dst_tensor: [*c]c.ggml_tensor,
    source: TensorSource,
    src_ptr: [*]const u8,
    row_elems: usize,
    row_count: usize,
) !void {
    const dst_row_bytes = c.ggml_row_size(dst_tensor[0].type, @intCast(row_elems));
    const row_scratch = try allocator.alloc(f32, row_elems);
    defer allocator.free(row_scratch);
    const quantized = try allocator.alloc(u8, dst_row_bytes);
    defer allocator.free(quantized);

    var row: usize = 0;
    while (row < row_count) : (row += 1) {
        try fillRowF32(row_scratch, source.dtype, src_ptr, row, row_elems);
        _ = c.ggml_quantize_chunk(dst_tensor[0].type, row_scratch.ptr, quantized.ptr, 0, 1, @intCast(row_elems), null);
        c.ggml_backend_tensor_set(dst_tensor, quantized.ptr, row * dst_row_bytes, dst_row_bytes);
    }
}

fn streamPlainTensor(
    allocator: std.mem.Allocator,
    dst_tensor: [*c]c.ggml_tensor,
    source: TensorSource,
    src_ptr: [*]const u8,
    row_elems: usize,
    row_count: usize,
) !void {
    const dst_row_bytes = c.ggml_row_size(dst_tensor[0].type, @intCast(row_elems));
    switch (dst_tensor[0].type) {
        c.GGML_TYPE_F32 => {
            if (source.dtype == .f32) {
                const src_row_bytes = sourceElementSize(source.dtype) * row_elems;
                var row: usize = 0;
                while (row < row_count) : (row += 1) {
                    c.ggml_backend_tensor_set(dst_tensor, src_ptr + row * src_row_bytes, row * dst_row_bytes, dst_row_bytes);
                }
                return;
            }
            const row_scratch = try allocator.alloc(f32, row_elems);
            defer allocator.free(row_scratch);
            var row: usize = 0;
            while (row < row_count) : (row += 1) {
                try fillRowF32(row_scratch, source.dtype, src_ptr, row, row_elems);
                c.ggml_backend_tensor_set(dst_tensor, row_scratch.ptr, row * dst_row_bytes, dst_row_bytes);
            }
        },
        c.GGML_TYPE_F16 => {
            if (source.dtype == .f16) {
                const src_row_bytes = sourceElementSize(source.dtype) * row_elems;
                var row: usize = 0;
                while (row < row_count) : (row += 1) {
                    c.ggml_backend_tensor_set(dst_tensor, src_ptr + row * src_row_bytes, row * dst_row_bytes, dst_row_bytes);
                }
                return;
            }
            const row_scratch = try allocator.alloc(u16, row_elems);
            defer allocator.free(row_scratch);
            var row: usize = 0;
            while (row < row_count) : (row += 1) {
                try fillRowF16(row_scratch, source.dtype, src_ptr, row, row_elems);
                c.ggml_backend_tensor_set(dst_tensor, row_scratch.ptr, row * dst_row_bytes, dst_row_bytes);
            }
        },
        else => return error.UnsupportedDestinationType,
    }
}

fn fillRowF32(
    out: []f32,
    dtype: safetensors.TensorDType,
    src_ptr: [*]const u8,
    row: usize,
    row_elems: usize,
) !void {
    const row_bytes = sourceElementSize(dtype) * row_elems;
    const row_ptr = src_ptr + row * row_bytes;
    switch (dtype) {
        .f32 => {
            const src_vals: [*]const f32 = @ptrCast(@alignCast(row_ptr));
            @memcpy(out, src_vals[0..row_elems]);
        },
        .f16 => {
            const src_words: [*]const u16 = @ptrCast(@alignCast(row_ptr));
            for (out, 0..) |*dst, i| {
                const h: f16 = @bitCast(src_words[i]);
                dst.* = @floatCast(h);
            }
        },
        .bf16 => {
            const src_words: [*]const u16 = @ptrCast(@alignCast(row_ptr));
            for (out, 0..) |*dst, i| {
                dst.* = bf16ToF32(src_words[i]);
            }
        },
        else => return error.UnsupportedSourceType,
    }
}

fn fillRowF16(
    out: []u16,
    dtype: safetensors.TensorDType,
    src_ptr: [*]const u8,
    row: usize,
    row_elems: usize,
) !void {
    const row_bytes = sourceElementSize(dtype) * row_elems;
    const row_ptr = src_ptr + row * row_bytes;
    switch (dtype) {
        .f16 => {
            const src_words: [*]const u16 = @ptrCast(@alignCast(row_ptr));
            @memcpy(out, src_words[0..row_elems]);
        },
        .bf16 => {
            const src_words: [*]const u16 = @ptrCast(@alignCast(row_ptr));
            for (out, 0..) |*dst, i| {
                dst.* = bf16ToF16(src_words[i]);
            }
        },
        .f32 => {
            const src_vals: [*]const f32 = @ptrCast(@alignCast(row_ptr));
            for (out, 0..) |*dst, i| {
                const h: f16 = @floatCast(src_vals[i]);
                dst.* = @bitCast(h);
            }
        },
        else => return error.UnsupportedSourceType,
    }
}

fn tensorRowElements(shape: []const u64) usize {
    return if (shape.len == 0) 1 else @intCast(shape[0]);
}

fn tensorRowCount(shape: []const u64) usize {
    if (shape.len <= 1) return 1;
    var rows: usize = 1;
    for (shape[1..]) |dim| {
        rows *= @as(usize, @intCast(dim));
    }
    return rows;
}

fn sourceElementSize(dtype: safetensors.TensorDType) usize {
    return switch (dtype) {
        .f16, .bf16 => 2,
        .f32 => 4,
        .i8, .u8 => 1,
        .unknown => 0,
    };
}

fn releaseSourcePages(shard_data: []align(std.heap.page_size_min) const u8, offset: u64, size: u64) void {
    const page_size = std.heap.page_size_min;
    const start = (@as(usize, @intCast(offset)) / page_size) * page_size;
    const end_unaligned = @as(usize, @intCast(offset + size));
    const end = @min(std.mem.alignForward(usize, end_unaligned, page_size), shard_data.len);
    if (end <= start) return;
    const ptr: [*]align(std.heap.page_size_min) u8 = @ptrCast(@alignCast(@constCast(shard_data.ptr + start)));
    std.posix.madvise(ptr, end - start, std.posix.MADV.DONTNEED) catch {};
}

fn bf16ToF32(v: u16) f32 {
    const bits: u32 = @as(u32, v) << 16;
    return @bitCast(bits);
}

fn bf16ToF16(v: u16) u16 {
    const f32_val = bf16ToF32(v);
    const f16_val: f16 = @floatCast(f32_val);
    return @bitCast(f16_val);
}

fn getConfigValue(config: std.json.Value, prefix: []const u8, path: []const u8) ?std.json.Value {
    var current = config;
    const full_path = if (prefix.len > 0)
        std.fmt.allocPrint(std.heap.page_allocator, "{s}.{s}", .{prefix, path}) catch return null
    else
        path;
    defer if (prefix.len > 0) std.heap.page_allocator.free(full_path);

    var it = std.mem.splitScalar(u8, full_path, '.');
    while (it.next()) |key| {
        switch (current) {
            .object => |obj| {
                current = obj.get(key) orelse return null;
            },
            else => return null,
        }
    }
    return current;
}

fn getConfigU32(config: std.json.Value, arch: *const arch_table.Arch, key: []const u8) ?u32 {
    for (arch.meta) |entry| {
        if (std.mem.endsWith(u8, entry.gguf_key, key)) {
            const value = getConfigValue(config, arch.config_prefix, entry.config_path);
            if (value) |v| {
                switch (v) {
                    .integer => |i| return i64ToU32(i),
                    .float => |f| return f64ToU32(f),
                    else => {},
                }
            }
            if (entry.default) |d| return std.fmt.parseInt(u32, d, 10) catch null;
        }
    }
    return null;
}

fn findOrAddShard(
    allocator: std.mem.Allocator,
    model_dir: []const u8,
    shard_name: []const u8,
    shards: *std.ArrayList(ShardMapping),
) !usize {
    // Check if already loaded
    for (shards.items, 0..) |_, idx| {
        // Can't easily compare by name here since we only store bytes
        _ = idx;
    }
    // For simplicity, always load new shard (dedup handled by index)
    var buf: [PATH_MAX]u8 = undefined;
    const shard_path = std.fmt.bufPrint(&buf, "{s}/{s}", .{ model_dir, shard_name }) catch return error.PathTooLong;
    const shard_bytes = try mapFile(shard_path);
    const idx = shards.items.len;
    try shards.append(allocator, .{ .bytes = shard_bytes });
    return idx;
}

fn mapFile(path: []const u8) ![]align(std.heap.page_size_min) const u8 {
    const io = std.Io.Threaded.global_single_threaded.io();
    const file = try Io.Dir.cwd().openFile(io, path, .{});
    defer file.close(io);
    const stat = try file.stat(io);
    return try std.posix.mmap(null, stat.size, .{ .READ = true }, .{ .TYPE = .PRIVATE }, file.handle, 0);
}

fn i64ToU32(v: i64) ?u32 {
    return std.math.cast(u32, v);
}

fn i64ToUsize(v: i64) ?usize {
    return std.math.cast(usize, v);
}

fn i64ToI32(v: i64) ?i32 {
    return std.math.cast(i32, v);
}

fn f64ToU32(v: f64) ?u32 {
    if (!std.math.isFinite(v) or v < 0) return null;
    if (v > @as(f64, @floatFromInt(std.math.maxInt(u32)))) return null;
    return @intFromFloat(v);
}

fn f64ToI32(v: f64) ?i32 {
    if (!std.math.isFinite(v)) return null;
    if (v < @as(f64, @floatFromInt(std.math.minInt(i32)))) return null;
    if (v > @as(f64, @floatFromInt(std.math.maxInt(i32)))) return null;
    return @intFromFloat(v);
}

test "detectArch supports glm4 moe lite configs" {
    const allocator = std.testing.allocator;
    const config_text =
        \\{
        \\  "architectures": ["Glm4MoeLiteForCausalLM"],
        \\  "model_type": "glm4_moe_lite",
        \\  "hidden_size": 2048,
        \\  "num_hidden_layers": 47
        \\}
    ;

    const arch = try detectArch(allocator, config_text);
    try std.testing.expectEqualStrings("deepseek2", arch.gguf_arch);
}
