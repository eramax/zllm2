const std = @import("std");
const Io = std.Io;
const c = @import("../llama.zig").c;
const arch_table = @import("arch_table.zig");
const arch_specs = @import("arch_specs.zig");
const quantize = @import("quantize.zig");
const safetensors = @import("safetensors.zig");

const PATH_MAX = std.posix.PATH_MAX;

pub const HfModelBundle = struct {
    gguf_ctx: *c.gguf_context,
    ggml_ctx: *c.ggml_context,
    arch: *const arch_table.Arch,
    spec_registry: ?*arch_specs.Registry = null,
    shards: []ShardMapping,
    tensor_map: std.StringHashMap(TensorSource),
    allocator: std.mem.Allocator,
    n_layers: u32,

    pub fn deinit(self: *HfModelBundle) void {
        var it = self.tensor_map.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            self.allocator.free(entry.value_ptr.target_shape);
            if (entry.value_ptr.kind == .expert_merge) {
                self.allocator.free(entry.value_ptr.expert_parts);
            }
        }
        self.tensor_map.deinit();
        for (self.shards) |*shard| shard.deinit();
        self.allocator.free(self.shards);
        if (self.spec_registry) |registry| {
            registry.deinit();
            self.allocator.destroy(registry);
        }
        c.ggml_free(self.ggml_ctx);
        c.gguf_free(self.gguf_ctx);
    }
};

pub const DirectTensorSource = struct {
    shard_index: usize,
    offset: u64,
    size: u64,
    dtype: safetensors.TensorDType,
    row_elems: usize,
    row_count: usize,
};

pub const SplitKvKind = enum {
    k_b,
    v_b,
};

pub const TensorSource = struct {
    kind: enum {
        direct,
        expert_merge,
        kv_b_split,
    } = .direct,
    target_shape: []const u64,
    target_type: c.ggml_type,
    dtype: safetensors.TensorDType,
    direct: DirectTensorSource = undefined,
    expert_parts: []DirectTensorSource = &.{},
    split_source: DirectTensorSource = undefined,
    split_kind: SplitKvKind = .k_b,
    split_n_head: u32 = 0,
    split_kv_rank: u32 = 0,
    split_k_nope: u32 = 0,
    split_v_dim: u32 = 0,
};

const ExpertProj = enum {
    gate,
    up,
    down,
};

const TokenizerEntry = struct {
    id: usize,
    token: []const u8,
};

const TransformSpec = struct {
    expert_count: u32,
    kv_rank: u32,
    n_head: u32,
    k_nope: u32,
    v_head_dim: u32,
};

const ExpertMergeKey = struct {
    layer: u32,
    proj: ExpertProj,
};

const ExpertMergeAccumulator = struct {
    dtype: safetensors.TensorDType,
    row_elems: usize,
    row_count: usize,
    parts: []?DirectTensorSource,

    fn init(allocator: std.mem.Allocator, expert_count: usize, source: DirectTensorSource) !ExpertMergeAccumulator {
        const parts = try allocator.alloc(?DirectTensorSource, expert_count);
        for (parts) |*slot| slot.* = null;
        return .{
            .dtype = source.dtype,
            .row_elems = source.row_elems,
            .row_count = source.row_count,
            .parts = parts,
        };
    }

    fn deinit(self: *ExpertMergeAccumulator, allocator: std.mem.Allocator) void {
        allocator.free(self.parts);
    }
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
    save_path: ?[]const u8,
    model_params: c.llama_model_params,
) !*c.llama_model {
    // 1. Read config.json
    var config_buf: [PATH_MAX]u8 = undefined;
    const config_path = std.fmt.bufPrint(&config_buf, "{s}/config.json", .{model_dir}) catch return error.PathTooLong;
    const config_text = try Io.Dir.cwd().readFileAlloc(io, config_path, allocator, .limited(1 << 20));
    defer allocator.free(config_text);

    // 2. Detect architecture
    const resolved_arch = try detectArch(io, allocator, config_text);
    const arch = resolved_arch.arch;
    std.debug.print("Detected architecture: {s} -> {s}\n", .{ arch.hf_class, arch.gguf_arch });

    // 3. Build the model bundle (gguf ctx + tensor mappings)
    var bundle = try buildBundle(io, allocator, model_dir, arch, resolved_arch.spec_registry, config_text, load_dtype);
    errdefer bundle.deinit();

    if (save_path) |out_path| {
        try saveBundleAsGguf(io, allocator, &bundle, out_path);
    }

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

pub fn saveHfModelAsGguf(
    io: Io,
    allocator: std.mem.Allocator,
    model_dir: []const u8,
    load_dtype: quantize.LoadDType,
    out_path: []const u8,
) !void {
    var config_buf: [PATH_MAX]u8 = undefined;
    const config_path = std.fmt.bufPrint(&config_buf, "{s}/config.json", .{model_dir}) catch return error.PathTooLong;
    const config_text = try Io.Dir.cwd().readFileAlloc(io, config_path, allocator, .limited(1 << 20));
    defer allocator.free(config_text);

    const resolved_arch = try detectArch(io, allocator, config_text);
    const arch = resolved_arch.arch;
    std.debug.print("Detected architecture: {s} -> {s}\n", .{ arch.hf_class, arch.gguf_arch });

    var bundle = try buildBundle(io, allocator, model_dir, arch, resolved_arch.spec_registry, config_text, load_dtype);
    defer bundle.deinit();
    try saveBundleAsGguf(io, allocator, &bundle, out_path);
}

fn saveBundleAsGguf(
    io: Io,
    allocator: std.mem.Allocator,
    bundle: *HfModelBundle,
    out_path: []const u8,
) !void {
    const meta_size = c.gguf_get_meta_size(bundle.gguf_ctx);
    const data_offset = meta_size;
    const n_tensors = c.gguf_get_n_tensors(bundle.gguf_ctx);

    const meta = try allocator.alloc(u8, meta_size);
    defer allocator.free(meta);
    c.gguf_get_meta_data(bundle.gguf_ctx, meta.ptr);

    const file = try Io.Dir.cwd().createFile(io, out_path, .{ .truncate = true });
    defer file.close(io);

    var required_end: u64 = data_offset;
    var tensor_id: i64 = 0;
    while (tensor_id < n_tensors) : (tensor_id += 1) {
        const name_c = c.gguf_get_tensor_name(bundle.gguf_ctx, tensor_id);
        const name = std.mem.span(name_c);
        const source = bundle.tensor_map.get(name) orelse return error.MissingTensorSourceForSave;
        const tensor_offset = c.gguf_get_tensor_offset(bundle.gguf_ctx, tensor_id);
        const tensor_size = c.gguf_get_tensor_size(bundle.gguf_ctx, tensor_id);
        const tensor_type = c.gguf_get_tensor_type(bundle.gguf_ctx, tensor_id);
        required_end = @max(required_end, data_offset + tensor_offset + tensor_size);

        try writeTensorSource(io, allocator, bundle, source, tensor_type, tensor_size, file, data_offset + tensor_offset);
    }

    const st = try file.stat(io);
    if (st.size < required_end) {
        const zero = [_]u8{0};
        try file.writePositionalAll(io, &zero, required_end - 1);
    }

    try file.writePositionalAll(io, meta, 0);
}

const ResolvedArch = struct {
    arch: *const arch_table.Arch,
    spec_registry: ?*arch_specs.Registry = null,
};

fn detectArch(io: Io, allocator: std.mem.Allocator, config_text: []const u8) !ResolvedArch {
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, config_text, .{});
    defer parsed.deinit();

    const architectures = parsed.value.object.get("architectures") orelse return error.NoArchitectures;
    if (architectures != .array or architectures.array.items.len == 0) return error.NoArchitectures;

    const hf_class = architectures.array.items[0].string;

    if (try arch_specs.tryLoadDefault(io, allocator)) |registry| {
        if (registry.findArchByHfClass(hf_class)) |arch| {
            return .{ .arch = arch, .spec_registry = registry };
        }
        registry.deinit();
        allocator.destroy(registry);
    }

    // Try exact match first
    if (arch_table.findArchByHfClass(hf_class)) |a| return .{ .arch = a };

    // Try with "ForCausalLM" suffix variations
    // Gemma4ForConditionalGeneration -> Gemma4ForCausalLM
    if (std.mem.indexOf(u8, hf_class, "ForConditionalGeneration")) |_| {
        const base = hf_class[0 .. hf_class.len - "ForConditionalGeneration".len];
        const causal = try std.fmt.allocPrint(allocator, "{s}ForCausalLM", .{base});
        defer allocator.free(causal);
        if (try arch_specs.tryLoadDefault(io, allocator)) |registry| {
            if (registry.findArchByHfClass(causal)) |arch| {
                return .{ .arch = arch, .spec_registry = registry };
            }
            registry.deinit();
            allocator.destroy(registry);
        }
        if (arch_table.findArchByHfClass(causal)) |a| return .{ .arch = a };
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
    spec_registry: ?*arch_specs.Registry,
    config_text: []const u8,
    load_dtype: quantize.LoadDType,
) !HfModelBundle {
    // Parse config JSON
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, config_text, .{});
    defer parsed.deinit();
    const config = parsed.value;

    // Config-derived defaults; tensor name matching no longer trusts this blindly.
    const transform_rules: []const arch_specs.TransformRule = if (spec_registry) |registry| registry.transformsForArch(arch) else &.{};
    const n_layers = getConfigU32(config, arch, "block_count") orelse return error.MissingBlockCount;
    const transform_spec = try deriveTransformSpec(config, arch.config_prefix, transform_rules);

    // Create GGUF context
    const gguf_ctx = c.gguf_init_empty() orelse return error.GgufInitFailed;

    const ggml_params = c.ggml_init_params{
        .mem_size = 128 * 1024 * 1024,
        .mem_buffer = null,
        .no_alloc = true,
    };
    const ggml_ctx = c.ggml_init(ggml_params) orelse return error.GgmlInitFailed;

    // Set GGUF metadata from config
    try setMetadata(allocator, gguf_ctx, arch, spec_registry, config, load_dtype);
    try setLoaderContractMetadata(allocator, gguf_ctx, arch, spec_registry, config);

    // Set tokenizer metadata (required for llama.cpp to work)
    try setTokenizerMetadata(io, allocator, gguf_ctx, model_dir, arch, config);

    // Discover safetensors shards
    var shards: std.ArrayList(ShardMapping) = .empty;
    errdefer {
        for (shards.items) |*s| s.deinit();
        shards.deinit(allocator);
    }

    var tensor_map = std.StringHashMap(TensorSource).init(allocator);
    errdefer {
        var it = tensor_map.iterator();
        while (it.next()) |entry| {
            allocator.free(entry.key_ptr.*);
            allocator.free(entry.value_ptr.target_shape);
            if (entry.value_ptr.kind == .expert_merge) allocator.free(entry.value_ptr.expert_parts);
        }
        tensor_map.deinit();
    }

    var expert_merges = std.AutoHashMap(ExpertMergeKey, ExpertMergeAccumulator).init(allocator);
    defer {
        var it = expert_merges.iterator();
        while (it.next()) |entry| {
            entry.value_ptr.deinit(allocator);
        }
        expert_merges.deinit();
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
                    try registerSourceTensor(
                        allocator,
                        &tensor_map,
                        &expert_merges,
                        gguf_ctx,
                        ggml_ctx,
                        arch,
                        load_dtype,
                        n_layers,
                        hf_name,
                        DirectTensorSource{
                            .shard_index = shard_idx,
                            .offset = shard_info.data_offset + tinfo.offset_start,
                            .size = tinfo.offset_end - tinfo.offset_start,
                            .dtype = tinfo.dtype,
                            .row_elems = if (tinfo.shape.len == 0) 1 else @intCast(tinfo.shape[tinfo.shape.len - 1]),
                            .row_count = tensorRowCountFromHfShape(tinfo.shape),
                        },
                        tinfo.shape,
                        transform_rules,
                        transform_spec,
                    );
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
            try registerSourceTensor(
                allocator,
                &tensor_map,
                &expert_merges,
                gguf_ctx,
                ggml_ctx,
                arch,
                load_dtype,
                n_layers,
                tinfo.name,
                DirectTensorSource{
                    .shard_index = 0,
                    .offset = shard_info.data_offset + tinfo.offset_start,
                    .size = tinfo.offset_end - tinfo.offset_start,
                    .dtype = tinfo.dtype,
                    .row_elems = if (tinfo.shape.len == 0) 1 else @intCast(tinfo.shape[tinfo.shape.len - 1]),
                    .row_count = tensorRowCountFromHfShape(tinfo.shape),
                },
                tinfo.shape,
                transform_rules,
                transform_spec,
            );
        }
    }

    try finalizeExpertMerges(allocator, &tensor_map, gguf_ctx, ggml_ctx, load_dtype, n_layers, expert_merges);
    try ensureTiedOutputTensor(allocator, arch, &tensor_map, gguf_ctx, ggml_ctx, load_dtype, n_layers);

    std.debug.print("Registered {} tensors in GGUF\n", .{tensor_map.count()});
    debugPrintTensorPlan(allocator, tensor_map) catch {};

    return .{
        .gguf_ctx = gguf_ctx,
        .ggml_ctx = ggml_ctx,
        .arch = arch,
        .spec_registry = spec_registry,
        .shards = try shards.toOwnedSlice(allocator),
        .tensor_map = tensor_map,
        .allocator = allocator,
        .n_layers = n_layers,
    };
}

fn setLoaderContractMetadata(
    allocator: std.mem.Allocator,
    gguf_ctx: *c.gguf_context,
    arch: *const arch_table.Arch,
    spec_registry: ?*arch_specs.Registry,
    config: std.json.Value,
) !void {
    if (spec_registry) |registry| {
        const optional_names = try expandOptionalTensorNames(allocator, arch, registry.optionalLayerRulesForArch(arch), config);
        defer {
            for (optional_names) |name| allocator.free(name);
            allocator.free(optional_names);
        }

        if (optional_names.len > 0) {
            var optional_ptrs = std.ArrayList([*c]const u8).empty;
            defer optional_ptrs.deinit(allocator);
            var optional_storage = std.ArrayList([:0]u8).empty;
            defer {
                for (optional_storage.items) |name| allocator.free(name);
                optional_storage.deinit(allocator);
            }

            for (optional_names) |name| {
                const z = try allocator.dupeZ(u8, name);
                try optional_storage.append(allocator, z);
                try optional_ptrs.append(allocator, z.ptr);
            }

            const ptrs: [*c][*c]const u8 = @ptrCast(optional_ptrs.items.ptr);
            c.gguf_set_arr_str(gguf_ctx, "zllm.optional_tensors", ptrs, optional_ptrs.items.len);
            c.gguf_set_val_bool(gguf_ctx, "zllm.strict_user_tensor_contract", true);
        }

        try applyLayerU32MetadataRules(allocator, gguf_ctx, registry.layerU32RulesForArch(arch), config);
    }
}

fn expandOptionalTensorNames(
    allocator: std.mem.Allocator,
    arch: *const arch_table.Arch,
    rules: []const arch_specs.LayerOptionalRule,
    config: std.json.Value,
) ![][]const u8 {
    _ = arch;
    var out = std.ArrayList([]const u8).empty;
    errdefer {
        for (out.items) |name| allocator.free(name);
        out.deinit(allocator);
    }

    for (rules) |rule| {
        const value = getConfigValue(config, "", rule.config_path) orelse continue;
        if (value != .array) continue;
        for (value.array.items, 0..) |item, idx| {
            const layer_type = switch (item) {
                .string => |s| s,
                else => continue,
            };
            if (!std.mem.eql(u8, layer_type, rule.value)) continue;
            for (rule.tensors) |pattern| {
                try out.append(allocator, try arch_table.expandPattern(allocator, pattern, @intCast(idx)));
            }
        }
    }

    return out.toOwnedSlice(allocator);
}

fn applyLayerU32MetadataRules(
    allocator: std.mem.Allocator,
    gguf_ctx: *c.gguf_context,
    rules: []const arch_specs.LayerU32Rule,
    config: std.json.Value,
) !void {
    var grouped = std.StringHashMap(std.ArrayList(u32)).init(allocator);
    defer {
        var it = grouped.iterator();
        while (it.next()) |entry| {
            allocator.free(entry.key_ptr.*);
            entry.value_ptr.deinit(allocator);
        }
        grouped.deinit();
    }

    for (rules) |rule| {
        const config_value = getConfigValue(config, "", rule.config_path) orelse continue;
        if (config_value != .array) continue;

        const value_u32 = if (rule.set_value) |v|
            v
        else blk: {
            const src = getConfigValue(config, "", rule.value_from_config_path orelse break :blk null) orelse break :blk null;
            break :blk jsonValueToU32(src);
        };
        if (value_u32 == null) continue;

        const gop = try grouped.getOrPut(rule.target_key);
        if (!gop.found_existing) {
            gop.key_ptr.* = try allocator.dupe(u8, rule.target_key);
            gop.value_ptr.* = std.ArrayList(u32).empty;
            try gop.value_ptr.resize(allocator, config_value.array.items.len);
            for (gop.value_ptr.items) |*item| item.* = 0;
        }

        for (config_value.array.items, 0..) |item, idx| {
            const s = switch (item) {
                .string => |text| text,
                else => continue,
            };
            if (std.mem.eql(u8, s, rule.match_value)) {
                gop.value_ptr.items[idx] = value_u32.?;
            }
        }
    }

    var it = grouped.iterator();
    while (it.next()) |entry| {
        const key_z = try allocator.dupeZ(u8, entry.key_ptr.*);
        defer allocator.free(key_z);
        c.gguf_set_arr_data(gguf_ctx, key_z.ptr, c.GGUF_TYPE_UINT32, entry.value_ptr.items.ptr, entry.value_ptr.items.len);
    }
}

fn applyMetaScalarRules(
    allocator: std.mem.Allocator,
    gguf_ctx: *c.gguf_context,
    rules: []const arch_specs.MetaScalarRule,
    config: std.json.Value,
) !void {
    for (rules) |rule| {
        const value = try evaluateMetaScalarRule(rule, config) orelse continue;
        const key_z = try allocator.dupeZ(u8, rule.target_key);
        defer allocator.free(key_z);
        c.gguf_set_val_u32(gguf_ctx, key_z.ptr, value);
    }
}

fn evaluateMetaScalarRule(rule: arch_specs.MetaScalarRule, config: std.json.Value) !?u32 {
    if (std.mem.eql(u8, rule.kind, "u32_constant")) return rule.set_u32;

    if (std.mem.eql(u8, rule.kind, "u32_copy")) {
        const value = getConfigValue(config, "", rule.primary_path orelse return error.InvalidArchRegistryRule) orelse return null;
        return jsonValueToU32(value);
    }

    if (std.mem.eql(u8, rule.kind, "u32_sum")) {
        const lhs = getConfigValue(config, "", rule.primary_path orelse return error.InvalidArchRegistryRule) orelse return null;
        const rhs = getConfigValue(config, "", rule.secondary_path orelse return error.InvalidArchRegistryRule) orelse return null;
        const lhs_u32 = jsonValueToU32(lhs) orelse return error.InvalidConfigValue;
        const rhs_u32 = jsonValueToU32(rhs) orelse return error.InvalidConfigValue;
        return lhs_u32 + rhs_u32;
    }

    if (std.mem.eql(u8, rule.kind, "u32_ffn_auto_adjust")) {
        const base = getConfigValue(config, "", rule.primary_path orelse return error.InvalidArchRegistryRule) orelse
            (if (rule.fallback_path) |path| getConfigValue(config, "", path) else null) orelse return null;
        var ff_dim = jsonValueToU32(base) orelse return error.InvalidConfigValue;

        const should_adjust = if (rule.condition_path) |path| blk: {
            if (getConfigValue(config, "", path)) |cond_val| {
                break :blk switch (cond_val) {
                    .bool => |b| b,
                    else => false,
                };
            }
            break :blk false;
        } else false;
        if (!should_adjust) return ff_dim;

        ff_dim = @intCast((@as(u64, ff_dim) * 2) / 3);

        if (rule.multiplier_path) |path| {
            if (getConfigValue(config, "", path)) |mult_val| {
                switch (mult_val) {
                    .float => |f| ff_dim = f64ToU32(@as(f64, @floatFromInt(ff_dim)) * f) orelse return error.InvalidConfigValue,
                    .integer => |i| ff_dim = i64ToU32(@as(i64, @intCast(ff_dim)) * i) orelse return error.InvalidConfigValue,
                    else => {},
                }
            }
        }

        const multiple_of = if (rule.multiple_of_path) |path|
            if (getConfigValue(config, "", path)) |m_val|
                jsonValueToU32(m_val) orelse return error.InvalidConfigValue
            else
                1
        else
            1;
        if (multiple_of == 0) return error.InvalidConfigValue;
        return multiple_of * ((ff_dim + multiple_of - 1) / multiple_of);
    }

    return error.InvalidArchRegistryRule;
}

fn applyMetaArrayRules(
    allocator: std.mem.Allocator,
    gguf_ctx: *c.gguf_context,
    rules: []const arch_specs.MetaArrayRule,
    config: std.json.Value,
) !void {
    for (rules) |rule| {
        const key_z = try allocator.dupeZ(u8, rule.target_key);
        defer allocator.free(key_z);

        if (std.mem.eql(u8, rule.kind, "bool_match_array")) {
            const source = getConfigValue(config, "", rule.source_path) orelse continue;
            if (source != .array) continue;
            const out = try allocator.alloc(bool, source.array.items.len);
            defer allocator.free(out);
            for (source.array.items, 0..) |item, idx| {
                out[idx] = switch (item) {
                    .string => |s| std.mem.eql(u8, s, rule.match_value orelse return error.InvalidArchRegistryRule),
                    else => false,
                };
            }
            c.gguf_set_arr_data(gguf_ctx, key_z.ptr, c.GGUF_TYPE_BOOL, out.ptr, out.len);
            continue;
        }

        if (std.mem.eql(u8, rule.kind, "i32_copy_pad")) {
            const source = getConfigValue(config, "", rule.source_path) orelse continue;
            if (source != .array) continue;
            var out = std.ArrayList(i32).empty;
            defer out.deinit(allocator);
            for (source.array.items) |item| {
                switch (item) {
                    .integer => |i| if (i64ToI32(i)) |v| try out.append(allocator, v),
                    .float => |f| if (f64ToI32(f)) |v| try out.append(allocator, v),
                    else => {},
                }
            }
            if (rule.pad_to_length) |target_len| {
                while (out.items.len < target_len) {
                    try out.append(allocator, rule.pad_value_i32);
                }
            }
            if (out.items.len > 0) {
                c.gguf_set_arr_data(gguf_ctx, key_z.ptr, c.GGUF_TYPE_INT32, out.items.ptr, out.items.len);
            }
            continue;
        }

        return error.InvalidArchRegistryRule;
    }
}

fn registerSourceTensor(
    allocator: std.mem.Allocator,
    tensor_map: *std.StringHashMap(TensorSource),
    expert_merges: *std.AutoHashMap(ExpertMergeKey, ExpertMergeAccumulator),
    gguf_ctx: *c.gguf_context,
    ggml_ctx: *c.ggml_context,
    arch: *const arch_table.Arch,
    load_dtype: quantize.LoadDType,
    n_layers: u32,
    hf_name: []const u8,
    direct: DirectTensorSource,
    hf_shape: []const u64,
    transform_rules: []const arch_specs.TransformRule,
    transform_spec: ?TransformSpec,
) !void {
    if (extractModelLayerIndex(hf_name)) |layer| {
        if (layer >= n_layers) return;
    }

    if (arch_table.matchTensorPattern(arch, hf_name, n_layers)) |pattern| {
        const gguf_name = arch_table.matchTensorName(allocator, arch, hf_name, n_layers) orelse return error.InvalidTensorPattern;
        defer allocator.free(gguf_name);
        try addTensorDescriptor(
            allocator,
            tensor_map,
            gguf_name,
            gguf_ctx,
            ggml_ctx,
            TensorSource{
                .kind = .direct,
                .dtype = direct.dtype,
                .target_shape = try toTargetShape(allocator, hf_shape, pattern.shape_transform),
                .target_type = undefined,
                .direct = direct,
            },
            load_dtype,
            n_layers,
        );
    }

    if (transform_spec) |spec| {
        const handled_by_external = try applyExternalTransformRules(
            allocator,
            tensor_map,
            expert_merges,
            gguf_ctx,
            ggml_ctx,
            load_dtype,
            n_layers,
            hf_name,
            direct,
            transform_rules,
            spec,
        );
        if (handled_by_external) return;

        if (parseExpertTensorName(hf_name)) |parsed| {
            const entry = try expert_merges.getOrPut(parsed.key);
            if (!entry.found_existing) {
                entry.value_ptr.* = try ExpertMergeAccumulator.init(allocator, spec.expert_count, direct);
            }
            entry.value_ptr.parts[parsed.expert_idx] = direct;
            return;
        }

        if (parseKvBProjLayer(hf_name)) |layer| {
            const k_name = try std.fmt.allocPrint(allocator, "blk.{d}.attn_k_b.weight", .{layer});
            defer allocator.free(k_name);
            const v_name = try std.fmt.allocPrint(allocator, "blk.{d}.attn_v_b.weight", .{layer});
            defer allocator.free(v_name);

            try addTensorDescriptor(
                allocator,
                tensor_map,
                k_name,
                gguf_ctx,
                ggml_ctx,
                TensorSource{
                    .kind = .kv_b_split,
                    .dtype = direct.dtype,
                    .target_shape = try allocator.dupe(u64, &[_]u64{ spec.k_nope, spec.kv_rank, spec.n_head }),
                    .target_type = undefined,
                    .split_source = direct,
                    .split_kind = .k_b,
                    .split_n_head = spec.n_head,
                    .split_kv_rank = spec.kv_rank,
                    .split_k_nope = spec.k_nope,
                    .split_v_dim = spec.v_head_dim,
                },
                load_dtype,
                n_layers,
            );
            try addTensorDescriptor(
                allocator,
                tensor_map,
                v_name,
                gguf_ctx,
                ggml_ctx,
                TensorSource{
                    .kind = .kv_b_split,
                    .dtype = direct.dtype,
                    .target_shape = try allocator.dupe(u64, &[_]u64{ spec.kv_rank, spec.v_head_dim, spec.n_head }),
                    .target_type = undefined,
                    .split_source = direct,
                    .split_kind = .v_b,
                    .split_n_head = spec.n_head,
                    .split_kv_rank = spec.kv_rank,
                    .split_k_nope = spec.k_nope,
                    .split_v_dim = spec.v_head_dim,
                },
                load_dtype,
                n_layers,
            );
        }
    }
}

fn applyExternalTransformRules(
    allocator: std.mem.Allocator,
    tensor_map: *std.StringHashMap(TensorSource),
    expert_merges: *std.AutoHashMap(ExpertMergeKey, ExpertMergeAccumulator),
    gguf_ctx: *c.gguf_context,
    ggml_ctx: *c.ggml_context,
    load_dtype: quantize.LoadDType,
    n_layers: u32,
    hf_name: []const u8,
    direct: DirectTensorSource,
    transform_rules: []const arch_specs.TransformRule,
    spec: TransformSpec,
) !bool {
    for (transform_rules) |rule| {
        const matched = matchTransformPattern(rule.match, hf_name) orelse continue;

        if (std.mem.eql(u8, rule.kind, "expert_merge")) {
            const proj = expertProjFromOutputName(rule.output_a orelse continue) orelse continue;
            const entry = try expert_merges.getOrPut(.{
                .layer = matched.layer,
                .proj = proj,
            });
            if (!entry.found_existing) {
                entry.value_ptr.* = try ExpertMergeAccumulator.init(allocator, spec.expert_count, direct);
            }
            entry.value_ptr.parts[matched.expert_idx orelse return error.InvalidTransformRule] = direct;
            return true;
        }

        if (std.mem.eql(u8, rule.kind, "kv_b_split")) {
            const layer = matched.layer;
            const k_name = try expandTransformOutput(allocator, rule.output_a orelse return error.InvalidTransformRule, layer);
            defer allocator.free(k_name);
            const v_name = try expandTransformOutput(allocator, rule.output_b orelse return error.InvalidTransformRule, layer);
            defer allocator.free(v_name);

            try addTensorDescriptor(
                allocator,
                tensor_map,
                k_name,
                gguf_ctx,
                ggml_ctx,
                TensorSource{
                    .kind = .kv_b_split,
                    .dtype = direct.dtype,
                    .target_shape = try allocator.dupe(u64, &[_]u64{ spec.k_nope, spec.kv_rank, spec.n_head }),
                    .target_type = undefined,
                    .split_source = direct,
                    .split_kind = .k_b,
                    .split_n_head = spec.n_head,
                    .split_kv_rank = spec.kv_rank,
                    .split_k_nope = spec.k_nope,
                    .split_v_dim = spec.v_head_dim,
                },
                load_dtype,
                n_layers,
            );
            try addTensorDescriptor(
                allocator,
                tensor_map,
                v_name,
                gguf_ctx,
                ggml_ctx,
                TensorSource{
                    .kind = .kv_b_split,
                    .dtype = direct.dtype,
                    .target_shape = try allocator.dupe(u64, &[_]u64{ spec.kv_rank, spec.v_head_dim, spec.n_head }),
                    .target_type = undefined,
                    .split_source = direct,
                    .split_kind = .v_b,
                    .split_n_head = spec.n_head,
                    .split_kv_rank = spec.kv_rank,
                    .split_k_nope = spec.k_nope,
                    .split_v_dim = spec.v_head_dim,
                },
                load_dtype,
                n_layers,
            );
            return true;
        }
    }

    return false;
}

fn finalizeExpertMerges(
    allocator: std.mem.Allocator,
    tensor_map: *std.StringHashMap(TensorSource),
    gguf_ctx: *c.gguf_context,
    ggml_ctx: *c.ggml_context,
    load_dtype: quantize.LoadDType,
    n_layers: u32,
    expert_merges: std.AutoHashMap(ExpertMergeKey, ExpertMergeAccumulator),
) !void {
    var it = expert_merges.iterator();
    while (it.next()) |entry| {
        const key = entry.key_ptr.*;
        const acc = entry.value_ptr.*;
        const gguf_name = try std.fmt.allocPrint(allocator, "blk.{d}.{s}.weight", .{
            key.layer,
            switch (key.proj) {
                .gate => "ffn_gate_exps",
                .up => "ffn_up_exps",
                .down => "ffn_down_exps",
            },
        });
        defer allocator.free(gguf_name);
        const parts = try allocator.alloc(DirectTensorSource, acc.parts.len);
        errdefer allocator.free(parts);
        for (acc.parts, 0..) |maybe_part, i| {
            parts[i] = maybe_part orelse return error.MissingExpertTensor;
        }
        try addTensorDescriptor(
            allocator,
            tensor_map,
            gguf_name,
            gguf_ctx,
            ggml_ctx,
            TensorSource{
                .kind = .expert_merge,
                .dtype = acc.dtype,
                .target_shape = try allocator.dupe(u64, &[_]u64{
                    @intCast(acc.row_elems),
                    @intCast(acc.row_count),
                    @intCast(acc.parts.len),
                }),
                .target_type = undefined,
                .expert_parts = parts,
            },
            load_dtype,
            n_layers,
        );
    }
}

fn ensureTiedOutputTensor(
    allocator: std.mem.Allocator,
    arch: *const arch_table.Arch,
    tensor_map: *std.StringHashMap(TensorSource),
    gguf_ctx: *c.gguf_context,
    ggml_ctx: *c.ggml_context,
    load_dtype: quantize.LoadDType,
    n_layers: u32,
) !void {
    if (!arch.tie_embeddings) return;
    if (tensor_map.contains("output.weight")) return;

    const embd_source = tensor_map.get("token_embd.weight") orelse return;
    var cloned = embd_source;
    cloned.target_shape = try allocator.dupe(u64, embd_source.target_shape);
    if (embd_source.kind == .expert_merge) {
        cloned.expert_parts = try allocator.dupe(DirectTensorSource, embd_source.expert_parts);
    }

    try addTensorDescriptor(
        allocator,
        tensor_map,
        "output.weight",
        gguf_ctx,
        ggml_ctx,
        cloned,
        load_dtype,
        n_layers,
    );
}

fn addTensorDescriptor(
    allocator: std.mem.Allocator,
    tensor_map: *std.StringHashMap(TensorSource),
    gguf_name: []const u8,
    gguf_ctx: *c.gguf_context,
    ggml_ctx: *c.ggml_context,
    source: TensorSource,
    load_dtype: quantize.LoadDType,
    n_layers: u32,
) !void {
    const name_copy = try allocator.dupe(u8, gguf_name);
    errdefer allocator.free(name_copy);
    errdefer allocator.free(source.target_shape);

    if (tensor_map.contains(gguf_name)) {
        allocator.free(name_copy);
        allocator.free(source.target_shape);
        if (source.kind == .expert_merge) allocator.free(source.expert_parts);
        return;
    }

    var resolved = source;
    const g_type = quantize.chooseTensorType(load_dtype, gguf_name, resolved.target_shape, n_layers);
    resolved.target_type = g_type;

    // Create tensor descriptor in ggml context
    var ne: [4]i64 = .{ 1, 1, 1, 1 };
    for (resolved.target_shape, 0..) |dim, i| {
        if (i < 4) ne[i] = @intCast(dim);
    }
    const tensor = switch (resolved.target_shape.len) {
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
        allocator.free(resolved.target_shape);
        if (resolved.kind == .expert_merge) allocator.free(resolved.expert_parts);
    }
    entry.value_ptr.* = resolved;
}

fn toTargetShape(allocator: std.mem.Allocator, shape: []const u64, shape_transform: []const u8) ![]const u64 {
    if (std.mem.eql(u8, shape_transform, "reverse")) {
        const out = try allocator.alloc(u64, shape.len);
        errdefer allocator.free(out);
        for (shape, 0..) |_, i| {
            out[i] = shape[shape.len - 1 - i];
        }
        return out;
    }

    if (std.mem.eql(u8, shape_transform, "squeeze_unit_dims_reverse")) {
        var squeezed_len: usize = 0;
        for (shape) |dim| {
            if (dim != 1) squeezed_len += 1;
        }
        if (squeezed_len == 0) squeezed_len = 1;

        const out = try allocator.alloc(u64, squeezed_len);
        errdefer allocator.free(out);
        var out_idx: usize = 0;
        var rev_idx: usize = shape.len;
        while (rev_idx > 0) {
            rev_idx -= 1;
            const dim = shape[rev_idx];
            if (dim == 1 and shape.len > 1) continue;
            out[out_idx] = dim;
            out_idx += 1;
        }
        return out;
    }

    return error.InvalidShapeTransform;
}

fn tensorRowCountFromHfShape(shape: []const u64) usize {
    if (shape.len <= 1) return 1;
    var rows: usize = 1;
    for (shape[0 .. shape.len - 1]) |dim| {
        rows *= @as(usize, @intCast(dim));
    }
    return rows;
}

fn parseExpertTensorName(hf_name: []const u8) ?struct { key: ExpertMergeKey, expert_idx: usize } {
    const prefix = "model.layers.";
    if (!std.mem.startsWith(u8, hf_name, prefix)) return null;
    const after_layer = hf_name[prefix.len..];
    const layer_end = std.mem.indexOfScalar(u8, after_layer, '.') orelse return null;
    const layer = std.fmt.parseInt(u32, after_layer[0..layer_end], 10) catch return null;
    const rest = after_layer[layer_end + 1 ..];
    const expert_prefix = "mlp.experts.";
    if (!std.mem.startsWith(u8, rest, expert_prefix)) return null;
    const after_expert = rest[expert_prefix.len..];
    const expert_end = std.mem.indexOfScalar(u8, after_expert, '.') orelse return null;
    const expert_idx = std.fmt.parseInt(usize, after_expert[0..expert_end], 10) catch return null;
    const proj_name = after_expert[expert_end + 1 ..];
    const proj: ExpertProj = if (std.mem.eql(u8, proj_name, "gate_proj.weight"))
        .gate
    else if (std.mem.eql(u8, proj_name, "up_proj.weight"))
        .up
    else if (std.mem.eql(u8, proj_name, "down_proj.weight"))
        .down
    else
        return null;
    return .{
        .key = .{ .layer = layer, .proj = proj },
        .expert_idx = expert_idx,
    };
}

fn parseKvBProjLayer(hf_name: []const u8) ?u32 {
    const prefix = "model.layers.";
    const suffix = ".self_attn.kv_b_proj.weight";
    if (!std.mem.startsWith(u8, hf_name, prefix)) return null;
    if (!std.mem.endsWith(u8, hf_name, suffix)) return null;
    const middle = hf_name[prefix.len .. hf_name.len - suffix.len];
    return std.fmt.parseInt(u32, middle, 10) catch null;
}

const TransformMatch = struct {
    layer: u32,
    expert_idx: ?usize = null,
};

fn matchTransformPattern(pattern: []const u8, hf_name: []const u8) ?TransformMatch {
    var pi: usize = 0;
    var si: usize = 0;
    var out = TransformMatch{ .layer = 0, .expert_idx = null };

    while (pi < pattern.len) {
        if (std.mem.startsWith(u8, pattern[pi..], "{N}")) {
            pi += 3;
            const suffix = nextLiteralSegment(pattern, pi);
            const end = findSegmentEnd(hf_name, si, suffix) orelse return null;
            out.layer = std.fmt.parseInt(u32, hf_name[si..end], 10) catch return null;
            si = end;
            continue;
        }
        if (std.mem.startsWith(u8, pattern[pi..], "{E}")) {
            pi += 3;
            const suffix = nextLiteralSegment(pattern, pi);
            const end = findSegmentEnd(hf_name, si, suffix) orelse return null;
            out.expert_idx = std.fmt.parseInt(usize, hf_name[si..end], 10) catch return null;
            si = end;
            continue;
        }

        if (si >= hf_name.len or pattern[pi] != hf_name[si]) return null;
        pi += 1;
        si += 1;
    }

    if (si != hf_name.len) return null;
    return out;
}

fn nextLiteralSegment(pattern: []const u8, start: usize) []const u8 {
    var end = start;
    while (end < pattern.len) : (end += 1) {
        if (std.mem.startsWith(u8, pattern[end..], "{N}") or std.mem.startsWith(u8, pattern[end..], "{E}")) break;
    }
    return pattern[start..end];
}

fn findSegmentEnd(text: []const u8, start: usize, suffix: []const u8) ?usize {
    if (suffix.len == 0) return text.len;
    const idx = std.mem.indexOf(u8, text[start..], suffix) orelse return null;
    return start + idx;
}

fn expertProjFromOutputName(output_name: []const u8) ?ExpertProj {
    if (std.mem.indexOf(u8, output_name, ".ffn_gate_exps.weight") != null) return .gate;
    if (std.mem.indexOf(u8, output_name, ".ffn_up_exps.weight") != null) return .up;
    if (std.mem.indexOf(u8, output_name, ".ffn_down_exps.weight") != null) return .down;
    return null;
}

fn expandTransformOutput(allocator: std.mem.Allocator, pattern: []const u8, layer: u32) ![]const u8 {
    return arch_table.expandPattern(allocator, pattern, layer);
}

fn extractModelLayerIndex(hf_name: []const u8) ?u32 {
    const prefix = "model.layers.";
    if (!std.mem.startsWith(u8, hf_name, prefix)) return null;
    const rest = hf_name[prefix.len..];
    const dot = std.mem.indexOfScalar(u8, rest, '.') orelse return null;
    return std.fmt.parseInt(u32, rest[0..dot], 10) catch null;
}

const TensorPlanEntry = struct {
    name: []const u8,
    bytes: usize,
    ggml_type: c.ggml_type,
    shape: []const u64,
};

fn debugPrintTensorPlan(allocator: std.mem.Allocator, tensor_map: std.StringHashMap(TensorSource)) !void {
    var entries = std.ArrayList(TensorPlanEntry).empty;
    defer entries.deinit(allocator);

    var total_bytes: usize = 0;
    var it = tensor_map.iterator();
    while (it.next()) |entry| {
        const src = entry.value_ptr.*;
        const bytes = tensorBytes(src.target_type, src.target_shape);
        total_bytes += bytes;
        try entries.append(allocator, .{
            .name = entry.key_ptr.*,
            .bytes = bytes,
            .ggml_type = src.target_type,
            .shape = src.target_shape,
        });
    }

    std.sort.block(TensorPlanEntry, entries.items, {}, struct {
        fn lessThan(_: void, a: TensorPlanEntry, b: TensorPlanEntry) bool {
            return a.bytes > b.bytes;
        }
    }.lessThan);

    std.debug.print("Planned tensor bytes: {d:.2} GiB across {} tensors\n", .{
        @as(f64, @floatFromInt(total_bytes)) / (1024.0 * 1024.0 * 1024.0),
        entries.items.len,
    });

    const limit = @min(entries.items.len, 20);
    for (entries.items[0..limit]) |item| {
        std.debug.print("  {s}: {d:.2} MiB type={s} shape=", .{
            item.name,
            @as(f64, @floatFromInt(item.bytes)) / (1024.0 * 1024.0),
            std.mem.span(c.ggml_type_name(item.ggml_type)),
        });
        for (item.shape, 0..) |dim, idx| {
            if (idx != 0) std.debug.print("x", .{});
            std.debug.print("{d}", .{dim});
        }
        std.debug.print("\n", .{});
    }
}

fn tensorBytes(ggml_type: c.ggml_type, shape: []const u64) usize {
    if (shape.len == 0) return 0;
    var elem_count: u64 = 1;
    for (shape[1..]) |dim| elem_count *= dim;
    return c.ggml_row_size(ggml_type, @intCast(shape[0])) * @as(usize, @intCast(elem_count));
}

fn setMetadata(
    allocator: std.mem.Allocator,
    gguf_ctx: *c.gguf_context,
    arch: *const arch_table.Arch,
    spec_registry: ?*const arch_specs.Registry,
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

    if (spec_registry) |registry| {
        try applyMetaScalarRules(allocator, gguf_ctx, registry.metaScalarRulesForArch(arch), config);
        try applyMetaArrayRules(allocator, gguf_ctx, registry.metaArrayRulesForArch(arch), config);
    }
}

fn deriveTransformSpec(config: std.json.Value, config_prefix: []const u8, transform_rules: []const arch_specs.TransformRule) !?TransformSpec {
    var needs_expert_count = false;
    var needs_kv_split = false;
    for (transform_rules) |rule| {
        if (std.mem.eql(u8, rule.kind, "expert_merge")) needs_expert_count = true;
        if (std.mem.eql(u8, rule.kind, "kv_b_split")) needs_kv_split = true;
    }
    if (!needs_expert_count and !needs_kv_split) return null;

    var expert_count: u32 = 0;
    if (needs_expert_count) {
        const expert_count_val = getConfigValue(config, config_prefix, "n_routed_experts") orelse return error.MissingExpertCount;
        expert_count = jsonValueToU32(expert_count_val) orelse return error.MissingExpertCount;
    }

    var kv_rank_u32: u32 = 0;
    var n_head_u32: u32 = 0;
    var k_nope_u32: u32 = 0;
    var v_head_dim_u32: u32 = 0;
    if (needs_kv_split) {
        const kv_rank = getConfigValue(config, config_prefix, "kv_lora_rank") orelse return error.MissingKvRank;
        const qk_head_dim = getConfigValue(config, config_prefix, "qk_head_dim") orelse return error.MissingQkHeadDim;
        const qk_rope_head_dim = getConfigValue(config, config_prefix, "qk_rope_head_dim") orelse return error.MissingQkRopeHeadDim;
        const v_head_dim = getConfigValue(config, config_prefix, "v_head_dim") orelse return error.MissingVHeadDim;
        const n_head_val = getConfigValue(config, config_prefix, "num_attention_heads") orelse return error.MissingAttentionHeadCount;

        kv_rank_u32 = jsonValueToU32(kv_rank) orelse return error.MissingKvRank;
        const qk_head_dim_u32 = jsonValueToU32(qk_head_dim) orelse return error.MissingQkHeadDim;
        const qk_rope_head_dim_u32 = jsonValueToU32(qk_rope_head_dim) orelse return error.MissingQkRopeHeadDim;
        v_head_dim_u32 = jsonValueToU32(v_head_dim) orelse return error.MissingVHeadDim;
        n_head_u32 = jsonValueToU32(n_head_val) orelse return error.MissingAttentionHeadCount;
        if (qk_head_dim_u32 < qk_rope_head_dim_u32) return error.InvalidAttentionDimensions;
        k_nope_u32 = qk_head_dim_u32 - qk_rope_head_dim_u32;
    }

    return .{
        .expert_count = expert_count,
        .kv_rank = kv_rank_u32,
        .n_head = n_head_u32,
        .k_nope = k_nope_u32,
        .v_head_dim = v_head_dim_u32,
    };
}

test "extractModelLayerIndex parses layer numbers" {
    try std.testing.expectEqual(@as(?u32, 12), extractModelLayerIndex("model.layers.12.self_attn.q_a_proj.weight"));
    try std.testing.expect(extractModelLayerIndex("lm_head.weight") == null);
}

fn setTokenizerMetadata(
    io: Io,
    allocator: std.mem.Allocator,
    gguf_ctx: *c.gguf_context,
    model_dir: []const u8,
    arch: *const arch_table.Arch,
    config: std.json.Value,
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

                    // Merge vocab and added tokens by id, allowing added tokens to override.
                    var vocab_entries = std.ArrayList(TokenizerEntry).empty;
                    defer vocab_entries.deinit(allocator);
                    var added_entries = std.ArrayList(TokenizerEntry).empty;
                    defer added_entries.deinit(allocator);

                    var vit = vocab.object.iterator();
                    while (vit.next()) |entry| {
                        const idx_str = entry.value_ptr.*;
                        const idx: usize = switch (idx_str) {
                            .integer => |i| i64ToUsize(i) orelse continue,
                            else => continue,
                        };
                        try vocab_entries.append(allocator, .{ .id = idx, .token = entry.key_ptr.* });
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
                                try added_entries.append(allocator, .{ .id = idx, .token = token });
                            }
                        }
                    }

                    const target_vocab_size: usize = blk: {
                        const vocab_val = getConfigValue(config, arch.config_prefix, "vocab_size") orelse break :blk 0;
                        break :blk jsonValueToU32(vocab_val) orelse 0;
                    };

                    const merged_entries = try mergeTokenizerEntries(allocator, vocab_entries.items, added_entries.items, target_vocab_size);
                    defer allocator.free(merged_entries);

                    for (merged_entries) |entry| {
                        const tok_z = try allocator.dupeZ(u8, entry.token);
                        try token_storage.append(allocator, tok_z);
                        try token_ptrs.append(allocator, tok_z.ptr);
                        try token_types.append(allocator, if (entry.token.len == 0) 0 else 1);
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

fn mergeTokenizerEntries(
    allocator: std.mem.Allocator,
    vocab_entries: []const TokenizerEntry,
    added_entries: []const TokenizerEntry,
    target_vocab_size: usize,
) ![]TokenizerEntry {
    var final_len = target_vocab_size;
    for (vocab_entries) |entry| final_len = @max(final_len, entry.id + 1);
    for (added_entries) |entry| final_len = @max(final_len, entry.id + 1);

    const merged = try allocator.alloc(TokenizerEntry, final_len);
    for (merged, 0..) |*entry, idx| {
        entry.* = .{ .id = idx, .token = "" };
    }

    for (vocab_entries) |entry| {
        merged[entry.id].token = entry.token;
    }
    for (added_entries) |entry| {
        merged[entry.id].token = entry.token;
    }

    return merged;
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

    const dst_tensor = &t[0];
    const dst_type = dst_tensor.type;
    const row_elems = tensorRowElements(source.target_shape);
    const row_count = tensorRowCount(source.target_shape);

    if (c.ggml_is_quantized(dst_type)) {
        streamQuantizedTensor(bundle, dst_tensor, source, row_elems, row_count) catch |err| {
            std.debug.print("  [FAIL] {s} — quantized upload failed: {s}\n", .{ name, @errorName(err) });
            return;
        };
    } else {
        streamPlainTensor(bundle, dst_tensor, source, row_elems, row_count) catch |err| {
            std.debug.print("  [FAIL] {s} — plain upload failed: {s}\n", .{ name, @errorName(err) });
            return;
        };
    }

    releaseTensorSourcePages(bundle, source);
}

fn streamQuantizedTensor(
    bundle: *HfModelBundle,
    dst_tensor: [*c]c.ggml_tensor,
    source: TensorSource,
    row_elems: usize,
    row_count: usize,
) !void {
    const dst_row_bytes = c.ggml_row_size(dst_tensor[0].type, @intCast(row_elems));
    const row_scratch = try bundle.allocator.alloc(f32, row_elems);
    defer bundle.allocator.free(row_scratch);
    const rows_per_chunk = maxChunkRows(dst_row_bytes);
    const quantized = try bundle.allocator.alloc(u8, dst_row_bytes * rows_per_chunk);
    defer bundle.allocator.free(quantized);

    var row_base: usize = 0;
    while (row_base < row_count) : (row_base += rows_per_chunk) {
        const chunk_rows = @min(rows_per_chunk, row_count - row_base);
        var row: usize = 0;
        while (row < chunk_rows) : (row += 1) {
            try populateRowF32(bundle, source, row_base + row, row_scratch);
            const dst = quantized[row * dst_row_bytes ..][0..dst_row_bytes];
            _ = c.ggml_quantize_chunk(dst_tensor[0].type, row_scratch.ptr, dst.ptr, 0, 1, @intCast(row_elems), null);
        }
        c.ggml_backend_tensor_set(dst_tensor, quantized.ptr, row_base * dst_row_bytes, chunk_rows * dst_row_bytes);
    }
}

fn streamPlainTensor(
    bundle: *HfModelBundle,
    dst_tensor: [*c]c.ggml_tensor,
    source: TensorSource,
    row_elems: usize,
    row_count: usize,
) !void {
    const dst_row_bytes = c.ggml_row_size(dst_tensor[0].type, @intCast(row_elems));
    const rows_per_chunk = maxChunkRows(dst_row_bytes);
    switch (dst_tensor[0].type) {
        c.GGML_TYPE_F32 => {
            const chunk = try bundle.allocator.alloc(f32, row_elems * rows_per_chunk);
            defer bundle.allocator.free(chunk);
            var row_base: usize = 0;
            while (row_base < row_count) : (row_base += rows_per_chunk) {
                const chunk_rows = @min(rows_per_chunk, row_count - row_base);
                var row: usize = 0;
                while (row < chunk_rows) : (row += 1) {
                    const row_dst = chunk[row * row_elems ..][0..row_elems];
                    try populateRowF32(bundle, source, row_base + row, row_dst);
                }
                c.ggml_backend_tensor_set(dst_tensor, chunk.ptr, row_base * dst_row_bytes, chunk_rows * dst_row_bytes);
            }
        },
        c.GGML_TYPE_F16 => {
            const chunk = try bundle.allocator.alloc(u16, row_elems * rows_per_chunk);
            defer bundle.allocator.free(chunk);
            var row_base: usize = 0;
            while (row_base < row_count) : (row_base += rows_per_chunk) {
                const chunk_rows = @min(rows_per_chunk, row_count - row_base);
                var row: usize = 0;
                while (row < chunk_rows) : (row += 1) {
                    const row_dst = chunk[row * row_elems ..][0..row_elems];
                    try populateRowF16(bundle, source, row_base + row, row_dst);
                }
                c.ggml_backend_tensor_set(dst_tensor, chunk.ptr, row_base * dst_row_bytes, chunk_rows * dst_row_bytes);
            }
        },
        else => return error.UnsupportedDestinationType,
    }
}

fn writeTensorSource(
    io: Io,
    allocator: std.mem.Allocator,
    bundle: *HfModelBundle,
    source: TensorSource,
    dst_type: c.ggml_type,
    expected_bytes: usize,
    file: anytype,
    file_offset: u64,
) !void {
    const row_elems = tensorRowElements(source.target_shape);
    const row_count = tensorRowCount(source.target_shape);
    const dst_row_bytes = c.ggml_row_size(dst_type, @intCast(row_elems));
    if (expected_bytes != dst_row_bytes * row_count) return error.TensorSizeMismatch;
    var written: u64 = 0;

    if (c.ggml_is_quantized(dst_type)) {
        const row_scratch = try allocator.alloc(f32, row_elems);
        defer allocator.free(row_scratch);
        const rows_per_chunk = maxChunkRows(dst_row_bytes);
        const quantized = try allocator.alloc(u8, dst_row_bytes * rows_per_chunk);
        defer allocator.free(quantized);

        var row_base: usize = 0;
        while (row_base < row_count) : (row_base += rows_per_chunk) {
            const chunk_rows = @min(rows_per_chunk, row_count - row_base);
            var row: usize = 0;
            while (row < chunk_rows) : (row += 1) {
                try populateRowF32(bundle, source, row_base + row, row_scratch);
                const dst = quantized[row * dst_row_bytes ..][0..dst_row_bytes];
                _ = c.ggml_quantize_chunk(dst_type, row_scratch.ptr, dst.ptr, 0, 1, @intCast(row_elems), null);
            }
            const bytes = quantized[0 .. chunk_rows * dst_row_bytes];
            try file.writePositionalAll(io, bytes, file_offset + written);
            written += bytes.len;
        }
        return;
    }

    switch (dst_type) {
        c.GGML_TYPE_F32 => {
            const rows_per_chunk = maxChunkRows(dst_row_bytes);
            const chunk = try allocator.alloc(f32, row_elems * rows_per_chunk);
            defer allocator.free(chunk);
            var row_base: usize = 0;
            while (row_base < row_count) : (row_base += rows_per_chunk) {
                const chunk_rows = @min(rows_per_chunk, row_count - row_base);
                var row: usize = 0;
                while (row < chunk_rows) : (row += 1) {
                    const row_dst = chunk[row * row_elems ..][0..row_elems];
                    try populateRowF32(bundle, source, row_base + row, row_dst);
                }
                const bytes: [*]const u8 = @ptrCast(chunk.ptr);
                const slice = bytes[0 .. chunk_rows * dst_row_bytes];
                try file.writePositionalAll(io, slice, file_offset + written);
                written += slice.len;
            }
        },
        c.GGML_TYPE_F16 => {
            const rows_per_chunk = maxChunkRows(dst_row_bytes);
            const chunk = try allocator.alloc(u16, row_elems * rows_per_chunk);
            defer allocator.free(chunk);
            var row_base: usize = 0;
            while (row_base < row_count) : (row_base += rows_per_chunk) {
                const chunk_rows = @min(rows_per_chunk, row_count - row_base);
                var row: usize = 0;
                while (row < chunk_rows) : (row += 1) {
                    const row_dst = chunk[row * row_elems ..][0..row_elems];
                    try populateRowF16(bundle, source, row_base + row, row_dst);
                }
                const bytes: [*]const u8 = @ptrCast(chunk.ptr);
                const slice = bytes[0 .. chunk_rows * dst_row_bytes];
                try file.writePositionalAll(io, slice, file_offset + written);
                written += slice.len;
            }
        },
        else => return error.UnsupportedDestinationType,
    }
}

fn maxChunkRows(dst_row_bytes: usize) usize {
    const target_bytes: usize = 32 * 1024 * 1024;
    return @max(@as(usize, 1), target_bytes / @max(@as(usize, 1), dst_row_bytes));
}

fn populateRowF32(
    bundle: *HfModelBundle,
    source: TensorSource,
    row: usize,
    out: []f32,
) !void {
    switch (source.kind) {
        .direct => try fillDirectRowF32(bundle, source.direct, row, out),
        .expert_merge => {
            const rows_per_expert = source.expert_parts[0].row_count;
            const expert_idx = row / rows_per_expert;
            const expert_row = row % rows_per_expert;
            try fillDirectRowF32(bundle, source.expert_parts[expert_idx], expert_row, out);
        },
        .kv_b_split => switch (source.split_kind) {
            .v_b => {
                const rows_per_head = @as(usize, source.split_v_dim);
                const head = row / rows_per_head;
                const v_row = row % rows_per_head;
                const src_row = head * (@as(usize, source.split_k_nope) + @as(usize, source.split_v_dim)) + @as(usize, source.split_k_nope) + v_row;
                try fillDirectRowF32(bundle, source.split_source, src_row, out);
            },
            .k_b => {
                const head = row / @as(usize, source.split_kv_rank);
                const kv = row % @as(usize, source.split_kv_rank);
                var i: usize = 0;
                while (i < out.len) : (i += 1) {
                    out[i] = try readDirectElementF32(bundle, source.split_source, head * (@as(usize, source.split_k_nope) + @as(usize, source.split_v_dim)) + i, kv);
                }
            },
        },
    }
}

fn populateRowF16(
    bundle: *HfModelBundle,
    source: TensorSource,
    row: usize,
    out: []u16,
) !void {
    switch (source.kind) {
        .direct => try fillDirectRowF16(bundle, source.direct, row, out),
        .expert_merge => {
            const rows_per_expert = source.expert_parts[0].row_count;
            const expert_idx = row / rows_per_expert;
            const expert_row = row % rows_per_expert;
            try fillDirectRowF16(bundle, source.expert_parts[expert_idx], expert_row, out);
        },
        .kv_b_split => switch (source.split_kind) {
            .v_b => {
                const rows_per_head = @as(usize, source.split_v_dim);
                const head = row / rows_per_head;
                const v_row = row % rows_per_head;
                const src_row = head * (@as(usize, source.split_k_nope) + @as(usize, source.split_v_dim)) + @as(usize, source.split_k_nope) + v_row;
                try fillDirectRowF16(bundle, source.split_source, src_row, out);
            },
            .k_b => {
                const scratch = try bundle.allocator.alloc(f32, out.len);
                defer bundle.allocator.free(scratch);
                try populateRowF32(bundle, source, row, scratch);
                for (out, 0..) |*dst, i| {
                    const h: f16 = @floatCast(scratch[i]);
                    dst.* = @bitCast(h);
                }
            },
        },
    }
}

fn fillDirectRowF32(
    bundle: *HfModelBundle,
    source: DirectTensorSource,
    row: usize,
    out: []f32,
) !void {
    const src_ptr = bundle.shards[source.shard_index].bytes.ptr + source.offset;
    const row_bytes = sourceElementSize(source.dtype) * source.row_elems;
    const row_ptr = src_ptr + row * row_bytes;
    switch (source.dtype) {
        .f32 => {
            const src_vals: [*]const f32 = @ptrCast(@alignCast(row_ptr));
            @memcpy(out, src_vals[0..source.row_elems]);
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

fn fillDirectRowF16(
    bundle: *HfModelBundle,
    source: DirectTensorSource,
    row: usize,
    out: []u16,
) !void {
    const src_ptr = bundle.shards[source.shard_index].bytes.ptr + source.offset;
    const row_bytes = sourceElementSize(source.dtype) * source.row_elems;
    const row_ptr = src_ptr + row * row_bytes;
    switch (source.dtype) {
        .f16 => {
            const src_words: [*]const u16 = @ptrCast(@alignCast(row_ptr));
            @memcpy(out, src_words[0..source.row_elems]);
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

fn readDirectElementF32(bundle: *HfModelBundle, source: DirectTensorSource, row: usize, col: usize) !f32 {
    const src_ptr = bundle.shards[source.shard_index].bytes.ptr + source.offset;
    const row_bytes = sourceElementSize(source.dtype) * source.row_elems;
    const elem_ptr = src_ptr + row * row_bytes + col * sourceElementSize(source.dtype);
    return switch (source.dtype) {
        .f32 => @as(*align(4) const f32, @ptrCast(@alignCast(elem_ptr))).*,
        .f16 => blk: {
            const h: f16 = @bitCast(@as(*align(2) const u16, @ptrCast(@alignCast(elem_ptr))).*);
            break :blk @floatCast(h);
        },
        .bf16 => bf16ToF32(@as(*align(2) const u16, @ptrCast(@alignCast(elem_ptr))).*),
        else => error.UnsupportedSourceType,
    };
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

fn releaseTensorSourcePages(bundle: *HfModelBundle, source: TensorSource) void {
    switch (source.kind) {
        .direct => releaseDirectPages(bundle, source.direct),
        .expert_merge => {
            for (source.expert_parts) |part| releaseDirectPages(bundle, part);
        },
        .kv_b_split => releaseDirectPages(bundle, source.split_source),
    }
}

fn releaseDirectPages(bundle: *HfModelBundle, source: DirectTensorSource) void {
    releaseSourcePages(bundle.shards[source.shard_index].bytes, source.offset, source.size);
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

fn jsonValueToU32(value: std.json.Value) ?u32 {
    return switch (value) {
        .integer => |i| i64ToU32(i),
        .float => |f| f64ToU32(f),
        .string => |s| std.fmt.parseInt(u32, s, 10) catch null,
        else => null,
    };
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
    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();
    const config_text =
        \\{
        \\  "architectures": ["Glm4MoeLiteForCausalLM"],
        \\  "model_type": "glm4_moe_lite",
        \\  "hidden_size": 2048,
        \\  "num_hidden_layers": 47
        \\}
    ;

    const resolved = try detectArch(io, allocator, config_text);
    if (resolved.spec_registry) |registry| {
        defer {
            registry.deinit();
            allocator.destroy(registry);
        }
    }
    try std.testing.expectEqualStrings("deepseek2", resolved.arch.gguf_arch);
}

test "deriveTransformSpec skips when no transform parameters are required" {
    const allocator = std.testing.allocator;
    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();
    var registry = try arch_specs.loadFromFile(io, allocator, "architectures/registry.json");
    defer registry.deinit();

    const config_text =
        \\{
        \\  "architectures": ["Gemma4ForConditionalGeneration"],
        \\  "text_config": {
        \\    "hidden_size": 2560,
        \\    "num_hidden_layers": 42
        \\  }
        \\}
    ;

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, config_text, .{});
    defer parsed.deinit();

    const arch = registry.findArchByHfClass("Gemma4ForCausalLM") orelse return error.TestExpectedEqual;
    const spec = try deriveTransformSpec(parsed.value, arch.config_prefix, registry.transformsForArch(arch));
    try std.testing.expect(spec == null);
}

test "matchTransformPattern extracts layer and expert indices" {
    const matched = matchTransformPattern("model.layers.{N}.mlp.experts.{E}.gate_proj.weight", "model.layers.12.mlp.experts.7.gate_proj.weight") orelse return error.TestExpectedEqual;
    try std.testing.expectEqual(@as(u32, 12), matched.layer);
    try std.testing.expectEqual(@as(?usize, 7), matched.expert_idx);
}

test "expertProjFromOutputName maps external output names" {
    try std.testing.expectEqual(ExpertProj.gate, expertProjFromOutputName("blk.{N}.ffn_gate_exps.weight") orelse return error.TestExpectedEqual);
    try std.testing.expectEqual(ExpertProj.up, expertProjFromOutputName("blk.{N}.ffn_up_exps.weight") orelse return error.TestExpectedEqual);
    try std.testing.expectEqual(ExpertProj.down, expertProjFromOutputName("blk.{N}.ffn_down_exps.weight") orelse return error.TestExpectedEqual);
}

test "expandOptionalTensorNames expands lfm2 layer-type optionals" {
    const allocator = std.testing.allocator;
    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    var registry = try arch_specs.loadFromFile(io, allocator, "architectures/registry.json");
    defer registry.deinit();

    const config_text =
        \\{
        \\  "architectures": ["Lfm2ForCausalLM"],
        \\  "layer_types": ["conv", "full_attention", "conv"]
        \\}
    ;
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, config_text, .{});
    defer parsed.deinit();

    const arch = registry.findArchByHfClass("Lfm2ForCausalLM") orelse return error.TestExpectedEqual;
    const names = try expandOptionalTensorNames(allocator, arch, registry.optionalLayerRulesForArch(arch), parsed.value);
    defer {
        for (names) |name| allocator.free(name);
        allocator.free(names);
    }

    try std.testing.expectEqual(@as(usize, 15), names.len);
    try std.testing.expectEqualStrings("blk.0.attn_q.weight", names[0]);
    try std.testing.expectEqualStrings("blk.1.shortconv.conv.weight", names[6]);
    try std.testing.expectEqualStrings("blk.2.attn_q.weight", names[9]);
}

test "applyLayerU32MetadataRules builds lfm2 per-layer kv heads" {
    const allocator = std.testing.allocator;
    const config_text =
        \\{
        \\  "architectures": ["Lfm2ForCausalLM"],
        \\  "num_key_value_heads": 8,
        \\  "layer_types": ["conv", "full_attention", "conv"]
        \\}
    ;
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, config_text, .{});
    defer parsed.deinit();

    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();
    var registry = try arch_specs.loadFromFile(io, allocator, "architectures/registry.json");
    defer registry.deinit();
    const arch = registry.findArchByHfClass("Lfm2ForCausalLM") orelse return error.TestExpectedEqual;

    const gguf_ctx = c.gguf_init_empty() orelse return error.GgufInitFailed;
    defer c.gguf_free(gguf_ctx);

    try applyLayerU32MetadataRules(allocator, gguf_ctx, registry.layerU32RulesForArch(arch), parsed.value);

    const key = "lfm2.attention.head_count_kv";
    const kid = c.gguf_find_key(gguf_ctx, key);
    try std.testing.expect(kid >= 0);
    try std.testing.expectEqual(c.GGUF_TYPE_ARRAY, c.gguf_get_kv_type(gguf_ctx, kid));
    try std.testing.expectEqual(c.GGUF_TYPE_UINT32, c.gguf_get_arr_type(gguf_ctx, kid));
    try std.testing.expectEqual(@as(i64, 3), c.gguf_get_arr_n(gguf_ctx, kid));
    const arr_ptr: [*]const u32 = @ptrCast(c.gguf_get_arr_data(gguf_ctx, kid));
    try std.testing.expectEqual(@as(u32, 0), arr_ptr[0]);
    try std.testing.expectEqual(@as(u32, 8), arr_ptr[1]);
    try std.testing.expectEqual(@as(u32, 0), arr_ptr[2]);
}

test "deriveTransformSpec loads parameters from transform kinds" {
    const allocator = std.testing.allocator;
    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();
    var registry = try arch_specs.loadFromFile(io, allocator, "architectures/registry.json");
    defer registry.deinit();

    const config_text =
        \\{
        \\  "architectures": ["Glm4MoeLiteForCausalLM"],
        \\  "hidden_size": 2048,
        \\  "num_hidden_layers": 47,
        \\  "num_attention_heads": 16,
        \\  "q_lora_rank": 1536,
        \\  "kv_lora_rank": 512,
        \\  "qk_head_dim": 128,
        \\  "qk_rope_head_dim": 64,
        \\  "v_head_dim": 128,
        \\  "n_routed_experts": 16
        \\}
    ;

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, config_text, .{});
    defer parsed.deinit();

    const arch = registry.findArchByHfClass("Glm4MoeLiteForCausalLM") orelse return error.TestExpectedEqual;
    const spec = (try deriveTransformSpec(parsed.value, arch.config_prefix, registry.transformsForArch(arch))).?;
    try std.testing.expectEqual(@as(u32, 512), spec.kv_rank);
    try std.testing.expectEqual(@as(u32, 16), spec.n_head);
    try std.testing.expectEqual(@as(u32, 64), spec.k_nope);
    try std.testing.expectEqual(@as(u32, 128), spec.v_head_dim);
    try std.testing.expectEqual(@as(u32, 16), spec.expert_count);
}

test "applyMetaScalarRules derives lfm2 feed-forward length from registry" {
    const allocator = std.testing.allocator;
    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();
    var registry = try arch_specs.loadFromFile(io, allocator, "architectures/registry.json");
    defer registry.deinit();
    const arch = registry.findArchByHfClass("Lfm2ForCausalLM") orelse return error.TestExpectedEqual;

    const config_text =
        \\{
        \\  "block_auto_adjust_ff_dim": true,
        \\  "block_ff_dim": 6656,
        \\  "block_ffn_dim_multiplier": 1.0,
        \\  "block_multiple_of": 256
        \\}
    ;
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, config_text, .{});
    defer parsed.deinit();

    const gguf_ctx = c.gguf_init_empty() orelse return error.GgufInitFailed;
    defer c.gguf_free(gguf_ctx);

    try applyMetaScalarRules(allocator, gguf_ctx, registry.metaScalarRulesForArch(arch), parsed.value);

    const kid = c.gguf_find_key(gguf_ctx, "lfm2.feed_forward_length");
    try std.testing.expect(kid >= 0);
    try std.testing.expectEqual(@as(u32, 4608), c.gguf_get_val_u32(gguf_ctx, kid));
}

test "applyMetaArrayRules builds registry-driven bool and padded int arrays" {
    const allocator = std.testing.allocator;
    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();
    var registry = try arch_specs.loadFromFile(io, allocator, "architectures/registry.json");
    defer registry.deinit();

    const config_text =
        \\{
        \\  "text_config": {
        \\    "layer_types": ["sliding_attention", "full_attention", "sliding_attention"],
        \\    "rope_parameters": { "mrope_section": [16, 24, 32] }
        \\  }
        \\}
    ;
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, config_text, .{});
    defer parsed.deinit();

    const gguf_ctx = c.gguf_init_empty() orelse return error.GgufInitFailed;
    defer c.gguf_free(gguf_ctx);

    const gemma = registry.findArchByHfClass("Gemma4ForCausalLM") orelse return error.TestExpectedEqual;
    try applyMetaArrayRules(allocator, gguf_ctx, registry.metaArrayRulesForArch(gemma), parsed.value);
    const gemma_kid = c.gguf_find_key(gguf_ctx, "gemma4.attention.sliding_window_pattern");
    try std.testing.expect(gemma_kid >= 0);
    const gemma_ptr: [*]const bool = @ptrCast(c.gguf_get_arr_data(gguf_ctx, gemma_kid));
    try std.testing.expectEqual(true, gemma_ptr[0]);
    try std.testing.expectEqual(false, gemma_ptr[1]);
    try std.testing.expectEqual(true, gemma_ptr[2]);

    const qwen = registry.findArchByHfClass("Qwen3_5ForCausalLM") orelse return error.TestExpectedEqual;
    try applyMetaArrayRules(allocator, gguf_ctx, registry.metaArrayRulesForArch(qwen), parsed.value);
    const qwen_kid = c.gguf_find_key(gguf_ctx, "qwen35.rope.dimension_sections");
    try std.testing.expect(qwen_kid >= 0);
    const qwen_ptr: [*]const i32 = @ptrCast(c.gguf_get_arr_data(gguf_ctx, qwen_kid));
    try std.testing.expectEqual(@as(i32, 16), qwen_ptr[0]);
    try std.testing.expectEqual(@as(i32, 24), qwen_ptr[1]);
    try std.testing.expectEqual(@as(i32, 32), qwen_ptr[2]);
    try std.testing.expectEqual(@as(i32, 0), qwen_ptr[3]);
}

test "ensureTiedOutputTensor duplicates token embeddings for gguf save path" {
    const allocator = std.testing.allocator;
    const gguf_ctx = c.gguf_init_empty() orelse return error.GgufInitFailed;
    defer c.gguf_free(gguf_ctx);
    const ggml_ctx = c.ggml_init(.{
        .mem_size = 1024 * 1024,
        .mem_buffer = null,
        .no_alloc = true,
    }) orelse return error.GgmlInitFailed;
    defer c.ggml_free(ggml_ctx);

    var tensor_map = std.StringHashMap(TensorSource).init(allocator);
    defer {
        var it = tensor_map.iterator();
        while (it.next()) |entry| {
            allocator.free(entry.key_ptr.*);
            allocator.free(entry.value_ptr.target_shape);
        }
        tensor_map.deinit();
    }

    try addTensorDescriptor(
        allocator,
        &tensor_map,
        "token_embd.weight",
        gguf_ctx,
        ggml_ctx,
        .{
            .kind = .direct,
            .target_shape = try allocator.dupe(u64, &[_]u64{ 1024, 65536 }),
            .target_type = undefined,
            .dtype = .f16,
            .direct = .{
                .shard_index = 0,
                .offset = 0,
                .size = 0,
                .dtype = .f16,
                .row_elems = 1024,
                .row_count = 65536,
            },
        },
        .f16,
        16,
    );

    const arch = arch_table.Arch{
        .hf_class = "Dummy",
        .gguf_arch = "dummy",
        .config_prefix = "",
        .meta = &.{},
        .tensors = &.{},
        .tie_embeddings = true,
        .tokenizer_pre = null,
    };

    try ensureTiedOutputTensor(allocator, &arch, &tensor_map, gguf_ctx, ggml_ctx, .f16, 16);

    try std.testing.expect(tensor_map.contains("output.weight"));
    const out = tensor_map.get("output.weight") orelse return error.TestExpectedEqual;
    try std.testing.expectEqualSlices(u64, &[_]u64{ 1024, 65536 }, out.target_shape);
}

test "toTargetShape squeezes unit dimensions before reversing when requested" {
    const allocator = std.testing.allocator;
    const transformed = try toTargetShape(allocator, &[_]u64{ 1024, 1, 3 }, "squeeze_unit_dims_reverse");
    defer allocator.free(transformed);
    try std.testing.expectEqualSlices(u64, &[_]u64{ 3, 1024 }, transformed);
}

test "mergeTokenizerEntries prefers added tokens by id without growing vocab" {
    const allocator = std.testing.allocator;
    const vocab_entries = [_]TokenizerEntry{
        .{ .id = 0, .token = "<pad>" },
        .{ .id = 1, .token = "a" },
        .{ .id = 2, .token = "b" },
    };
    const added_entries = [_]TokenizerEntry{
        .{ .id = 0, .token = "<pad>" },
        .{ .id = 2, .token = "<bos>" },
        .{ .id = 4, .token = "<extra>" },
    };

    const merged = try mergeTokenizerEntries(allocator, &vocab_entries, &added_entries, 5);
    defer allocator.free(merged);

    try std.testing.expectEqual(@as(usize, 5), merged.len);
    try std.testing.expectEqualStrings("<pad>", merged[0].token);
    try std.testing.expectEqualStrings("a", merged[1].token);
    try std.testing.expectEqualStrings("<bos>", merged[2].token);
    try std.testing.expectEqualStrings("", merged[3].token);
    try std.testing.expectEqualStrings("<extra>", merged[4].token);
}
