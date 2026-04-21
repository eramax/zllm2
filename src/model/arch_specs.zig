const std = @import("std");
const Io = std.Io;
const arch_table = @import("arch_table.zig");

pub const Registry = struct {
    arches: []arch_table.Arch,
    transform_slices: [][]TransformRule,
    optional_layer_rule_slices: [][]LayerOptionalRule,
    layer_u32_rule_slices: [][]LayerU32Rule,
    meta_scalar_rule_slices: [][]MetaScalarRule,
    meta_array_rule_slices: [][]MetaArrayRule,
    meta_slices: [][]arch_table.MetaEntry,
    tensor_slices: [][]arch_table.TensorPattern,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Registry) void {
        for (self.arches, 0..) |arch, idx| {
            self.allocator.free(arch.hf_class);
            self.allocator.free(arch.gguf_arch);
            self.allocator.free(arch.config_prefix);
            if (arch.tokenizer_pre) |tokenizer_pre| self.allocator.free(tokenizer_pre);

            for (self.meta_slices[idx]) |entry| {
                self.allocator.free(entry.gguf_key);
                self.allocator.free(entry.config_path);
                if (entry.default) |default| self.allocator.free(default);
            }
            self.allocator.free(self.meta_slices[idx]);

            for (self.transform_slices[idx]) |rule| {
                self.allocator.free(rule.kind);
                self.allocator.free(rule.match);
                if (rule.output_a) |value| self.allocator.free(value);
                if (rule.output_b) |value| self.allocator.free(value);
            }
            self.allocator.free(self.transform_slices[idx]);

            for (self.optional_layer_rule_slices[idx]) |rule| {
                self.allocator.free(rule.config_path);
                self.allocator.free(rule.value);
                for (rule.tensors) |tensor| self.allocator.free(tensor);
                self.allocator.free(rule.tensors);
            }
            self.allocator.free(self.optional_layer_rule_slices[idx]);

            for (self.layer_u32_rule_slices[idx]) |rule| {
                self.allocator.free(rule.config_path);
                self.allocator.free(rule.target_key);
                self.allocator.free(rule.match_value);
                if (rule.value_from_config_path) |value| self.allocator.free(value);
            }
            self.allocator.free(self.layer_u32_rule_slices[idx]);

            for (self.meta_scalar_rule_slices[idx]) |rule| {
                self.allocator.free(rule.target_key);
                self.allocator.free(rule.kind);
                if (rule.primary_path) |value| self.allocator.free(value);
                if (rule.fallback_path) |value| self.allocator.free(value);
                if (rule.secondary_path) |value| self.allocator.free(value);
                if (rule.condition_path) |value| self.allocator.free(value);
                if (rule.multiplier_path) |value| self.allocator.free(value);
                if (rule.multiple_of_path) |value| self.allocator.free(value);
            }
            self.allocator.free(self.meta_scalar_rule_slices[idx]);

            for (self.meta_array_rule_slices[idx]) |rule| {
                self.allocator.free(rule.target_key);
                self.allocator.free(rule.kind);
                self.allocator.free(rule.source_path);
                if (rule.match_value) |value| self.allocator.free(value);
            }
            self.allocator.free(self.meta_array_rule_slices[idx]);

            for (self.tensor_slices[idx]) |pattern| {
                self.allocator.free(pattern.hf);
                self.allocator.free(pattern.gguf);
                self.allocator.free(pattern.shape_transform);
            }
            self.allocator.free(self.tensor_slices[idx]);
        }

        self.allocator.free(self.transform_slices);
        self.allocator.free(self.optional_layer_rule_slices);
        self.allocator.free(self.layer_u32_rule_slices);
        self.allocator.free(self.meta_scalar_rule_slices);
        self.allocator.free(self.meta_array_rule_slices);
        self.allocator.free(self.meta_slices);
        self.allocator.free(self.tensor_slices);
        self.allocator.free(self.arches);
    }

    pub fn findArchByHfClass(self: *const Registry, hf_class: []const u8) ?*const arch_table.Arch {
        for (self.arches) |*arch| {
            if (std.mem.eql(u8, arch.hf_class, hf_class)) return arch;
        }
        return null;
    }

    pub fn transformsForArch(self: *const Registry, arch: *const arch_table.Arch) []const TransformRule {
        for (self.arches, 0..) |*candidate, idx| {
            if (candidate == arch) return self.transform_slices[idx];
        }
        return &.{};
    }

    pub fn optionalLayerRulesForArch(self: *const Registry, arch: *const arch_table.Arch) []const LayerOptionalRule {
        for (self.arches, 0..) |*candidate, idx| {
            if (candidate == arch) return self.optional_layer_rule_slices[idx];
        }
        return &.{};
    }

    pub fn layerU32RulesForArch(self: *const Registry, arch: *const arch_table.Arch) []const LayerU32Rule {
        for (self.arches, 0..) |*candidate, idx| {
            if (candidate == arch) return self.layer_u32_rule_slices[idx];
        }
        return &.{};
    }

    pub fn metaScalarRulesForArch(self: *const Registry, arch: *const arch_table.Arch) []const MetaScalarRule {
        for (self.arches, 0..) |*candidate, idx| {
            if (candidate == arch) return self.meta_scalar_rule_slices[idx];
        }
        return &.{};
    }

    pub fn metaArrayRulesForArch(self: *const Registry, arch: *const arch_table.Arch) []const MetaArrayRule {
        for (self.arches, 0..) |*candidate, idx| {
            if (candidate == arch) return self.meta_array_rule_slices[idx];
        }
        return &.{};
    }
};

pub const TransformRule = struct {
    kind: []const u8,
    match: []const u8,
    output_a: ?[]const u8 = null,
    output_b: ?[]const u8 = null,
};

pub const LayerOptionalRule = struct {
    config_path: []const u8,
    value: []const u8,
    tensors: [][]const u8,
};

pub const LayerU32Rule = struct {
    config_path: []const u8,
    target_key: []const u8,
    match_value: []const u8,
    set_value: ?u32 = null,
    value_from_config_path: ?[]const u8 = null,
};

pub const MetaScalarRule = struct {
    target_key: []const u8,
    kind: []const u8,
    primary_path: ?[]const u8 = null,
    fallback_path: ?[]const u8 = null,
    secondary_path: ?[]const u8 = null,
    condition_path: ?[]const u8 = null,
    multiplier_path: ?[]const u8 = null,
    multiple_of_path: ?[]const u8 = null,
    set_u32: ?u32 = null,
};

pub const MetaArrayRule = struct {
    target_key: []const u8,
    kind: []const u8,
    source_path: []const u8,
    match_value: ?[]const u8 = null,
    pad_to_length: ?usize = null,
    pad_value_i32: i32 = 0,
};

pub const default_registry_path = "architectures/registry.json";

pub fn loadFromFile(io: Io, allocator: std.mem.Allocator, path: []const u8) !Registry {
    const text = try Io.Dir.cwd().readFileAlloc(io, path, allocator, .limited(4 * 1024 * 1024));
    defer allocator.free(text);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, text, .{});
    defer parsed.deinit();

    const root = parsed.value;
    if (root != .object) return error.InvalidArchRegistry;

    const arches_val = root.object.get("architectures") orelse return error.InvalidArchRegistry;
    if (arches_val != .array) return error.InvalidArchRegistry;

    const arch_count = arches_val.array.items.len;
    var arches = try allocator.alloc(arch_table.Arch, arch_count);
    errdefer allocator.free(arches);

    var meta_slices = try allocator.alloc([]arch_table.MetaEntry, arch_count);
    errdefer allocator.free(meta_slices);

    var transform_slices = try allocator.alloc([]TransformRule, arch_count);
    errdefer allocator.free(transform_slices);

    var optional_layer_rule_slices = try allocator.alloc([]LayerOptionalRule, arch_count);
    errdefer allocator.free(optional_layer_rule_slices);

    var layer_u32_rule_slices = try allocator.alloc([]LayerU32Rule, arch_count);
    errdefer allocator.free(layer_u32_rule_slices);

    var meta_scalar_rule_slices = try allocator.alloc([]MetaScalarRule, arch_count);
    errdefer allocator.free(meta_scalar_rule_slices);

    var meta_array_rule_slices = try allocator.alloc([]MetaArrayRule, arch_count);
    errdefer allocator.free(meta_array_rule_slices);

    var tensor_slices = try allocator.alloc([]arch_table.TensorPattern, arch_count);
    errdefer allocator.free(tensor_slices);

    for (arches_val.array.items, 0..) |arch_val, idx| {
        if (arch_val != .object) return error.InvalidArchRegistry;
        const obj = arch_val.object;

        const hf_class = try dupRequiredString(allocator, obj, "hf_class");
        errdefer allocator.free(hf_class);
        const gguf_arch = try dupRequiredString(allocator, obj, "gguf_arch");
        errdefer allocator.free(gguf_arch);
        const config_prefix = try dupOptionalString(allocator, obj, "config_prefix") orelse try allocator.dupe(u8, "");
        errdefer allocator.free(config_prefix);
        const tokenizer_pre = try dupOptionalString(allocator, obj, "tokenizer_pre");
        errdefer if (tokenizer_pre) |value| allocator.free(value);

        const tie_embeddings = if (obj.get("tie_embeddings")) |value|
            switch (value) {
                .bool => |b| b,
                else => return error.InvalidArchRegistry,
            }
        else
            false;

        meta_slices[idx] = try parseMetaEntries(allocator, obj.get("meta") orelse return error.InvalidArchRegistry);
        errdefer freeMetaEntries(allocator, meta_slices[idx]);

        transform_slices[idx] = if (obj.get("transforms")) |transforms_value|
            try parseTransformRules(allocator, transforms_value)
        else
            try allocator.alloc(TransformRule, 0);
        errdefer freeTransformRules(allocator, transform_slices[idx]);

        optional_layer_rule_slices[idx] = if (obj.get("optional_layer_rules")) |rules_value|
            try parseLayerOptionalRules(allocator, rules_value)
        else
            try allocator.alloc(LayerOptionalRule, 0);
        errdefer freeLayerOptionalRules(allocator, optional_layer_rule_slices[idx]);

        layer_u32_rule_slices[idx] = if (obj.get("layer_u32_rules")) |rules_value|
            try parseLayerU32Rules(allocator, rules_value)
        else
            try allocator.alloc(LayerU32Rule, 0);
        errdefer freeLayerU32Rules(allocator, layer_u32_rule_slices[idx]);

        meta_scalar_rule_slices[idx] = if (obj.get("meta_scalar_rules")) |rules_value|
            try parseMetaScalarRules(allocator, rules_value)
        else
            try allocator.alloc(MetaScalarRule, 0);
        errdefer freeMetaScalarRules(allocator, meta_scalar_rule_slices[idx]);

        meta_array_rule_slices[idx] = if (obj.get("meta_array_rules")) |rules_value|
            try parseMetaArrayRules(allocator, rules_value)
        else
            try allocator.alloc(MetaArrayRule, 0);
        errdefer freeMetaArrayRules(allocator, meta_array_rule_slices[idx]);

        tensor_slices[idx] = try parseTensorPatterns(allocator, obj.get("tensors") orelse return error.InvalidArchRegistry);
        errdefer freeTensorPatterns(allocator, tensor_slices[idx]);

        arches[idx] = .{
            .hf_class = hf_class,
            .gguf_arch = gguf_arch,
            .config_prefix = config_prefix,
            .meta = meta_slices[idx],
            .tensors = tensor_slices[idx],
            .tie_embeddings = tie_embeddings,
            .tokenizer_pre = tokenizer_pre,
        };
    }

    return .{
        .arches = arches,
        .transform_slices = transform_slices,
        .optional_layer_rule_slices = optional_layer_rule_slices,
        .layer_u32_rule_slices = layer_u32_rule_slices,
        .meta_scalar_rule_slices = meta_scalar_rule_slices,
        .meta_array_rule_slices = meta_array_rule_slices,
        .meta_slices = meta_slices,
        .tensor_slices = tensor_slices,
        .allocator = allocator,
    };
}

pub fn tryLoadDefault(io: Io, allocator: std.mem.Allocator) !?*Registry {
    const registry = loadFromFile(io, allocator, default_registry_path) catch |err| switch (err) {
        error.FileNotFound => return null,
        else => return err,
    };
    const heap = try allocator.create(Registry);
    heap.* = registry;
    return heap;
}

fn dupRequiredString(allocator: std.mem.Allocator, obj: std.json.ObjectMap, key: []const u8) ![]const u8 {
    const value = obj.get(key) orelse return error.InvalidArchRegistry;
    return switch (value) {
        .string => |s| allocator.dupe(u8, s),
        else => error.InvalidArchRegistry,
    };
}

fn dupOptionalString(allocator: std.mem.Allocator, obj: std.json.ObjectMap, key: []const u8) !?[]const u8 {
    const value = obj.get(key) orelse return null;
    return switch (value) {
        .null => null,
        .string => |s| try allocator.dupe(u8, s),
        else => error.InvalidArchRegistry,
    };
}

fn parseMetaEntries(allocator: std.mem.Allocator, value: std.json.Value) ![]arch_table.MetaEntry {
    if (value != .array) return error.InvalidArchRegistry;
    const out = try allocator.alloc(arch_table.MetaEntry, value.array.items.len);
    errdefer allocator.free(out);

    for (value.array.items, 0..) |entry_val, idx| {
        if (entry_val != .object) return error.InvalidArchRegistry;
        const obj = entry_val.object;
        const kind_str = try dupRequiredString(allocator, obj, "kind");
        defer allocator.free(kind_str);

        out[idx] = .{
            .gguf_key = try dupRequiredString(allocator, obj, "gguf_key"),
            .config_path = try dupRequiredString(allocator, obj, "config_path"),
            .kind = parseMetaKind(kind_str),
            .default = try dupOptionalString(allocator, obj, "default"),
        };
    }

    return out;
}

fn parseTensorPatterns(allocator: std.mem.Allocator, value: std.json.Value) ![]arch_table.TensorPattern {
    if (value != .array) return error.InvalidArchRegistry;
    const out = try allocator.alloc(arch_table.TensorPattern, value.array.items.len);
    errdefer allocator.free(out);

    for (value.array.items, 0..) |entry_val, idx| {
        if (entry_val != .object) return error.InvalidArchRegistry;
        const obj = entry_val.object;
        out[idx] = .{
            .hf = try dupRequiredString(allocator, obj, "hf"),
            .gguf = try dupRequiredString(allocator, obj, "gguf"),
            .shape_transform = try dupOptionalString(allocator, obj, "shape_transform") orelse try allocator.dupe(u8, "reverse"),
        };
    }

    return out;
}

fn parseTransformRules(allocator: std.mem.Allocator, value: std.json.Value) ![]TransformRule {
    if (value != .array) return error.InvalidArchRegistry;
    const out = try allocator.alloc(TransformRule, value.array.items.len);
    errdefer allocator.free(out);

    for (value.array.items, 0..) |entry_val, idx| {
        if (entry_val != .object) return error.InvalidArchRegistry;
        const obj = entry_val.object;
        out[idx] = .{
            .kind = try dupRequiredString(allocator, obj, "kind"),
            .match = try dupRequiredString(allocator, obj, "match"),
            .output_a = try dupOptionalString(allocator, obj, "output_a"),
            .output_b = try dupOptionalString(allocator, obj, "output_b"),
        };
    }

    return out;
}

fn parseLayerOptionalRules(allocator: std.mem.Allocator, value: std.json.Value) ![]LayerOptionalRule {
    if (value != .array) return error.InvalidArchRegistry;
    const out = try allocator.alloc(LayerOptionalRule, value.array.items.len);
    errdefer allocator.free(out);

    for (value.array.items, 0..) |entry_val, idx| {
        if (entry_val != .object) return error.InvalidArchRegistry;
        const obj = entry_val.object;
        const tensors_val = obj.get("tensors") orelse return error.InvalidArchRegistry;
        if (tensors_val != .array) return error.InvalidArchRegistry;
        const tensors = try allocator.alloc([]const u8, tensors_val.array.items.len);
        errdefer allocator.free(tensors);
        for (tensors_val.array.items, 0..) |tensor_val, t_idx| {
            tensors[t_idx] = switch (tensor_val) {
                .string => |s| try allocator.dupe(u8, s),
                else => return error.InvalidArchRegistry,
            };
        }

        out[idx] = .{
            .config_path = try dupRequiredString(allocator, obj, "config_path"),
            .value = try dupRequiredString(allocator, obj, "value"),
            .tensors = tensors,
        };
    }

    return out;
}

fn parseLayerU32Rules(allocator: std.mem.Allocator, value: std.json.Value) ![]LayerU32Rule {
    if (value != .array) return error.InvalidArchRegistry;
    const out = try allocator.alloc(LayerU32Rule, value.array.items.len);
    errdefer allocator.free(out);

    for (value.array.items, 0..) |entry_val, idx| {
        if (entry_val != .object) return error.InvalidArchRegistry;
        const obj = entry_val.object;
        out[idx] = .{
            .config_path = try dupRequiredString(allocator, obj, "config_path"),
            .target_key = try dupRequiredString(allocator, obj, "target_key"),
            .match_value = try dupRequiredString(allocator, obj, "match_value"),
            .set_value = if (obj.get("set_value")) |set_value| switch (set_value) {
                .integer => |i| std.math.cast(u32, i) orelse return error.InvalidArchRegistry,
                else => return error.InvalidArchRegistry,
            } else null,
            .value_from_config_path = try dupOptionalString(allocator, obj, "value_from_config_path"),
        };
    }

    return out;
}

fn parseMetaScalarRules(allocator: std.mem.Allocator, value: std.json.Value) ![]MetaScalarRule {
    if (value != .array) return error.InvalidArchRegistry;
    const out = try allocator.alloc(MetaScalarRule, value.array.items.len);
    errdefer allocator.free(out);

    for (value.array.items, 0..) |entry_val, idx| {
        if (entry_val != .object) return error.InvalidArchRegistry;
        const obj = entry_val.object;
        out[idx] = .{
            .target_key = try dupRequiredString(allocator, obj, "target_key"),
            .kind = try dupRequiredString(allocator, obj, "kind"),
            .primary_path = try dupOptionalString(allocator, obj, "primary_path"),
            .fallback_path = try dupOptionalString(allocator, obj, "fallback_path"),
            .secondary_path = try dupOptionalString(allocator, obj, "secondary_path"),
            .condition_path = try dupOptionalString(allocator, obj, "condition_path"),
            .multiplier_path = try dupOptionalString(allocator, obj, "multiplier_path"),
            .multiple_of_path = try dupOptionalString(allocator, obj, "multiple_of_path"),
            .set_u32 = if (obj.get("set_u32")) |set_value| switch (set_value) {
                .integer => |i| std.math.cast(u32, i) orelse return error.InvalidArchRegistry,
                else => return error.InvalidArchRegistry,
            } else null,
        };
    }

    return out;
}

fn parseMetaArrayRules(allocator: std.mem.Allocator, value: std.json.Value) ![]MetaArrayRule {
    if (value != .array) return error.InvalidArchRegistry;
    const out = try allocator.alloc(MetaArrayRule, value.array.items.len);
    errdefer allocator.free(out);

    for (value.array.items, 0..) |entry_val, idx| {
        if (entry_val != .object) return error.InvalidArchRegistry;
        const obj = entry_val.object;
        out[idx] = .{
            .target_key = try dupRequiredString(allocator, obj, "target_key"),
            .kind = try dupRequiredString(allocator, obj, "kind"),
            .source_path = try dupRequiredString(allocator, obj, "source_path"),
            .match_value = try dupOptionalString(allocator, obj, "match_value"),
            .pad_to_length = if (obj.get("pad_to_length")) |pad_value| switch (pad_value) {
                .integer => |i| std.math.cast(usize, i) orelse return error.InvalidArchRegistry,
                else => return error.InvalidArchRegistry,
            } else null,
            .pad_value_i32 = if (obj.get("pad_value_i32")) |pad_value| switch (pad_value) {
                .integer => |i| std.math.cast(i32, i) orelse return error.InvalidArchRegistry,
                else => return error.InvalidArchRegistry,
            } else 0,
        };
    }

    return out;
}

const MetaKind = @TypeOf(arch_table.gemma4.meta[0].kind);

fn parseMetaKind(kind: []const u8) MetaKind {
    if (std.mem.eql(u8, kind, "u32")) return .u32;
    if (std.mem.eql(u8, kind, "f32")) return .f32;
    if (std.mem.eql(u8, kind, "bool")) return .bool;
    return .str;
}

fn freeMetaEntries(allocator: std.mem.Allocator, entries: []arch_table.MetaEntry) void {
    for (entries) |entry| {
        allocator.free(entry.gguf_key);
        allocator.free(entry.config_path);
        if (entry.default) |default| allocator.free(default);
    }
    allocator.free(entries);
}

fn freeTensorPatterns(allocator: std.mem.Allocator, patterns: []arch_table.TensorPattern) void {
    for (patterns) |pattern| {
        allocator.free(pattern.hf);
        allocator.free(pattern.gguf);
        allocator.free(pattern.shape_transform);
    }
    allocator.free(patterns);
}

fn freeTransformRules(allocator: std.mem.Allocator, rules: []TransformRule) void {
    for (rules) |rule| {
        allocator.free(rule.kind);
        allocator.free(rule.match);
        if (rule.output_a) |value| allocator.free(value);
        if (rule.output_b) |value| allocator.free(value);
    }
    allocator.free(rules);
}

fn freeLayerOptionalRules(allocator: std.mem.Allocator, rules: []LayerOptionalRule) void {
    for (rules) |rule| {
        allocator.free(rule.config_path);
        allocator.free(rule.value);
        for (rule.tensors) |tensor| allocator.free(tensor);
        allocator.free(rule.tensors);
    }
    allocator.free(rules);
}

fn freeLayerU32Rules(allocator: std.mem.Allocator, rules: []LayerU32Rule) void {
    for (rules) |rule| {
        allocator.free(rule.config_path);
        allocator.free(rule.target_key);
        allocator.free(rule.match_value);
        if (rule.value_from_config_path) |value| allocator.free(value);
    }
    allocator.free(rules);
}

fn freeMetaScalarRules(allocator: std.mem.Allocator, rules: []MetaScalarRule) void {
    for (rules) |rule| {
        allocator.free(rule.target_key);
        allocator.free(rule.kind);
        if (rule.primary_path) |value| allocator.free(value);
        if (rule.fallback_path) |value| allocator.free(value);
        if (rule.secondary_path) |value| allocator.free(value);
        if (rule.condition_path) |value| allocator.free(value);
        if (rule.multiplier_path) |value| allocator.free(value);
        if (rule.multiple_of_path) |value| allocator.free(value);
    }
    allocator.free(rules);
}

fn freeMetaArrayRules(allocator: std.mem.Allocator, rules: []MetaArrayRule) void {
    for (rules) |rule| {
        allocator.free(rule.target_key);
        allocator.free(rule.kind);
        allocator.free(rule.source_path);
        if (rule.match_value) |value| allocator.free(value);
    }
    allocator.free(rules);
}

test "external arch registry loads lfm2 spec" {
    const allocator = std.testing.allocator;
    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    var registry = try loadFromFile(io, allocator, "architectures/registry.json");
    defer registry.deinit();

    const arch = registry.findArchByHfClass("Lfm2ForCausalLM") orelse return error.TestExpectedEqual;
    try std.testing.expectEqualStrings("lfm2", arch.gguf_arch);
    try std.testing.expect(arch.tie_embeddings);
}

test "external arch registry resolves tensor alias" {
    const allocator = std.testing.allocator;
    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    var registry = try loadFromFile(io, allocator, "architectures/registry.json");
    defer registry.deinit();

    const arch = registry.findArchByHfClass("Lfm2ForCausalLM") orelse return error.TestExpectedEqual;
    const matched = arch_table.matchTensorName(allocator, arch, "model.layers.3.self_attn.q_proj.weight", 16) orelse return error.TestExpectedEqual;
    defer allocator.free(matched);

    try std.testing.expectEqualStrings("blk.3.attn_q.weight", matched);
    const conv_pattern = arch_table.matchTensorPattern(arch, "model.layers.3.conv.conv.weight", 16) orelse return error.TestExpectedEqual;
    try std.testing.expectEqualStrings("squeeze_unit_dims_reverse", conv_pattern.shape_transform);
}

test "external arch registry parses deepseek transforms" {
    const allocator = std.testing.allocator;
    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    var registry = try loadFromFile(io, allocator, "architectures/registry.json");
    defer registry.deinit();

    const arch = registry.findArchByHfClass("Glm4MoeLiteForCausalLM") orelse return error.TestExpectedEqual;
    const transforms = registry.transformsForArch(arch);

    try std.testing.expectEqual(@as(usize, 4), transforms.len);
    try std.testing.expectEqualStrings("expert_merge", transforms[0].kind);
    try std.testing.expectEqualStrings("model.layers.{N}.mlp.experts.{E}.gate_proj.weight", transforms[0].match);
    try std.testing.expectEqualStrings("blk.{N}.ffn_gate_exps.weight", transforms[0].output_a.?);
    try std.testing.expectEqualStrings("expert_merge", transforms[2].kind);
    try std.testing.expectEqualStrings("kv_b_split", transforms[3].kind);
    try std.testing.expectEqualStrings("blk.{N}.attn_k_b.weight", transforms[3].output_a.?);
    try std.testing.expectEqualStrings("blk.{N}.attn_v_b.weight", transforms[3].output_b.?);
}

test "external arch registry parses lfm2 optional layer rules" {
    const allocator = std.testing.allocator;
    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    var registry = try loadFromFile(io, allocator, "architectures/registry.json");
    defer registry.deinit();

    const arch = registry.findArchByHfClass("Lfm2ForCausalLM") orelse return error.TestExpectedEqual;
    const rules = registry.optionalLayerRulesForArch(arch);

    try std.testing.expectEqual(@as(usize, 2), rules.len);
    try std.testing.expectEqualStrings("layer_types", rules[0].config_path);
    try std.testing.expectEqualStrings("conv", rules[0].value);
    try std.testing.expectEqualStrings("blk.{N}.attn_q.weight", rules[0].tensors[0]);
    try std.testing.expectEqualStrings("full_attention", rules[1].value);
    try std.testing.expectEqualStrings("blk.{N}.shortconv.conv.weight", rules[1].tensors[0]);
}

test "external arch registry parses lfm2 layer u32 rules" {
    const allocator = std.testing.allocator;
    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    var registry = try loadFromFile(io, allocator, "architectures/registry.json");
    defer registry.deinit();

    const arch = registry.findArchByHfClass("Lfm2ForCausalLM") orelse return error.TestExpectedEqual;
    const rules = registry.layerU32RulesForArch(arch);
    try std.testing.expectEqual(@as(usize, 2), rules.len);
    try std.testing.expectEqualStrings("lfm2.attention.head_count_kv", rules[0].target_key);
    try std.testing.expectEqual(@as(?u32, 0), rules[0].set_value);
    try std.testing.expectEqualStrings("num_key_value_heads", rules[1].value_from_config_path.?);
}

test "external arch registry parses meta scalar rules" {
    const allocator = std.testing.allocator;
    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    var registry = try loadFromFile(io, allocator, "architectures/registry.json");
    defer registry.deinit();

    const lfm2 = registry.findArchByHfClass("Lfm2ForCausalLM") orelse return error.TestExpectedEqual;
    const lfm2_rules = registry.metaScalarRulesForArch(lfm2);
    try std.testing.expectEqual(@as(usize, 1), lfm2_rules.len);
    try std.testing.expectEqualStrings("u32_ffn_auto_adjust", lfm2_rules[0].kind);
    try std.testing.expectEqualStrings("block_ff_dim", lfm2_rules[0].primary_path.?);

    const glm = registry.findArchByHfClass("Glm4MoeLiteForCausalLM") orelse return error.TestExpectedEqual;
    const glm_rules = registry.metaScalarRulesForArch(glm);
    try std.testing.expectEqual(@as(usize, 3), glm_rules.len);
    try std.testing.expectEqualStrings("u32_constant", glm_rules[0].kind);
    try std.testing.expectEqual(@as(?u32, 1), glm_rules[0].set_u32);
    try std.testing.expectEqualStrings("u32_sum", glm_rules[1].kind);
}

test "external arch registry parses meta array rules" {
    const allocator = std.testing.allocator;
    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    var registry = try loadFromFile(io, allocator, "architectures/registry.json");
    defer registry.deinit();

    const gemma = registry.findArchByHfClass("Gemma4ForCausalLM") orelse return error.TestExpectedEqual;
    const gemma_rules = registry.metaArrayRulesForArch(gemma);
    try std.testing.expectEqual(@as(usize, 1), gemma_rules.len);
    try std.testing.expectEqualStrings("bool_match_array", gemma_rules[0].kind);
    try std.testing.expectEqualStrings("text_config.layer_types", gemma_rules[0].source_path);

    const qwen = registry.findArchByHfClass("Qwen3_5ForCausalLM") orelse return error.TestExpectedEqual;
    const qwen_rules = registry.metaArrayRulesForArch(qwen);
    try std.testing.expectEqual(@as(usize, 1), qwen_rules.len);
    try std.testing.expectEqualStrings("i32_copy_pad", qwen_rules[0].kind);
    try std.testing.expectEqual(@as(?usize, 4), qwen_rules[0].pad_to_length);
}
