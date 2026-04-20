const std = @import("std");
const c = @import("../../llama.zig").c;
const loader = @import("../loader.zig");
const interface = @import("interface.zig");
const arch_yaml = @import("../arch_yaml.zig");

// ── C++ bridge ───────────────────────────────────────────────────────────────
const bridge = struct {
    extern fn zllm_count_tensors(model: *const c.llama_model) c_int;
    extern fn zllm_get_tensor_name(model: *const c.llama_model, i: c_int) ?[*:0]const u8;
    extern fn zllm_get_tensor_by_name(model: *const c.llama_model, name: [*:0]const u8) ?*c.ggml_tensor;
    extern fn zllm_get_tensor_by_index(model: *const c.llama_model, i: c_int) ?*c.ggml_tensor;
    extern fn zllm_set_graph_post_build_callback(
        ctx: *c.llama_context,
        cb: ?*const fn (*c.ggml_cgraph, ?*anyopaque) callconv(.c) void,
        userdata: ?*anyopaque,
    ) void;
};

// ── Blueprint types ───────────────────────────────────────────────────────────
pub const ActivationType = enum { silu, gelu, relu, swiglu, geglu };
pub const AttentionType  = enum { full, sliding, linear };
pub const RouterType     = enum { topk, softmax, random };
pub const ComponentKind  = enum { rms_norm, linear, rope, moe_router, moe_ffn, linear_ffn, activation };

pub const Component = struct {
    name: []const u8,
    kind: ComponentKind,
    skip: bool = false,
    weight_source: ?[]const u8 = null,
    freq_base: f32 = 10000.0,
    freq_scale: f32 = 1.0,
    sliding_window: ?u32 = null,
    act: ActivationType = .swiglu,
    expert_count: u32 = 0,
    expert_used_count: u32 = 0,
    router_type: RouterType = .topk,
};

pub const LayerBlueprint = struct {
    index: u32,
    skip: bool = false,
    duplicate_of: ?u32 = null,
    residual: bool = true,
    extra_residual_from: ?u32 = null,
    execution_order: ?u32 = null,
    components: std.ArrayList(Component),
};

pub const MoeConfig = struct {
    expert_count: u32 = 0,
    expert_used_count: u32 = 0,
    shared_expert_count: u32 = 0,
    shared_expert_ffn: u32 = 0,
    router_type: RouterType = .topk,
};

pub const GlobalConfig = struct {
    embedding_length: u32 = 0,
    block_count: u32 = 0,
    head_count: u32 = 0,
    head_count_kv: u32 = 0,
    head_dim: u32 = 0,
    vocab_size: u32 = 0,
    context_length: u32 = 4096,
    rope_freq_base: f32 = 10000.0,
    rope_freq_scale: f32 = 1.0,
    rope_dim: u32 = 0,
    norm_epsilon: f32 = 1e-5,
    sliding_window: ?u32 = null,
    attn_type: AttentionType = .full,
    ffn_length: u32 = 0,
    ffn_act: ActivationType = .swiglu,
    moe: MoeConfig = .{},
};

pub const Blueprint = struct {
    global: GlobalConfig,
    layers: std.ArrayList(LayerBlueprint),
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Blueprint) void {
        for (self.layers.items) |*layer| {
            for (layer.components.items) |*comp| {
                self.allocator.free(comp.name);
                if (comp.weight_source) |ws| self.allocator.free(ws);
            }
            layer.components.deinit(self.allocator);
        }
        self.layers.deinit(self.allocator);
    }
};

// ── Blueprint parser ──────────────────────────────────────────────────────────
pub fn parseBlueprint(allocator: std.mem.Allocator, yaml_text: []const u8) !Blueprint {
    var bp = Blueprint{ .global = .{}, .layers = std.ArrayList(LayerBlueprint).empty, .allocator = allocator };
    errdefer bp.deinit();

    var overrides = try arch_yaml.parseOverrides(allocator, yaml_text);
    defer { var it = overrides.iterator(); while (it.next()) |e| allocator.free(e.key_ptr.*); overrides.deinit(); }

    if (overrides.get("dimensions.embedding_length")) |v| bp.global.embedding_length = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("dimensions.block_count"))      |v| bp.global.block_count      = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("dimensions.head_dim"))         |v| bp.global.head_dim         = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("dimensions.vocab_size"))       |v| bp.global.vocab_size       = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("dimensions.context_length"))   |v| bp.global.context_length   = std.fmt.parseInt(u32, v, 10) catch 4096;
    if (overrides.get("attention.head_count"))        |v| bp.global.head_count       = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("attention.head_count_kv"))     |v| bp.global.head_count_kv    = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("attention.layer_norm_rms_epsilon")) |v| bp.global.norm_epsilon = std.fmt.parseFloat(f32, v) catch 1e-5;
    if (overrides.get("attention.sliding_window"))    |v| {
        if (!std.mem.eql(u8, v, "null")) bp.global.sliding_window = std.fmt.parseInt(u32, v, 10) catch null;
    }
    if (overrides.get("rope.freq_base"))              |v| bp.global.rope_freq_base   = std.fmt.parseFloat(f32, v) catch 10000.0;
    if (overrides.get("rope.freq_scale"))             |v| bp.global.rope_freq_scale  = std.fmt.parseFloat(f32, v) catch 1.0;
    if (overrides.get("rope.dimension_count"))        |v| bp.global.rope_dim         = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("feed_forward.length"))         |v| bp.global.ffn_length       = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("feed_forward.activation"))     |v| bp.global.ffn_act          = parseAct(v);
    if (overrides.get("moe.expert_count"))            |v| bp.global.moe.expert_count        = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("moe.expert_used_count"))       |v| bp.global.moe.expert_used_count   = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("moe.shared_expert_count"))     |v| bp.global.moe.shared_expert_count = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("moe.shared_expert_ffn"))       |v| bp.global.moe.shared_expert_ffn   = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("moe.router_type"))             |v| bp.global.moe.router_type          = parseRouter(v);

    try parseLayerSection(allocator, yaml_text, &bp);
    return bp;
}

fn parseAct(s: []const u8) ActivationType {
    if (std.mem.eql(u8, s, "gelu"))   return .gelu;
    if (std.mem.eql(u8, s, "relu"))   return .relu;
    if (std.mem.eql(u8, s, "silu"))   return .silu;
    if (std.mem.eql(u8, s, "geglu"))  return .geglu;
    return .swiglu;
}

fn parseRouter(s: []const u8) RouterType {
    if (std.mem.eql(u8, s, "softmax")) return .softmax;
    if (std.mem.eql(u8, s, "random"))  return .random;
    return .topk;
}

fn parseLayerSection(allocator: std.mem.Allocator, yaml: []const u8, bp: *Blueprint) !void {
    var in_layers = false;
    var current_layer: ?LayerBlueprint = null;
    var current_comp: ?Component = null;
    var in_components = false;

    var lines = std.mem.splitScalar(u8, yaml, '\n');
    while (lines.next()) |raw| {
        const cp = std.mem.indexOfScalar(u8, raw, '#');
        const line = if (cp) |p| raw[0..p] else raw;
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0) continue;

        if (std.mem.eql(u8, trimmed, "layers:")) { in_layers = true; continue; }
        if (in_layers and line.len > 0 and line[0] != ' ' and line[0] != '\t' and !std.mem.startsWith(u8, trimmed, "-")) {
            if (current_comp) |co| { if (current_layer) |*la| try la.components.append(allocator, co); current_comp = null; }
            if (current_layer) |la| try bp.layers.append(allocator, la);
            current_layer = null; in_layers = false; in_components = false; continue;
        }
        if (!in_layers) continue;

        var indent: usize = 0;
        while (indent < line.len and (line[indent] == ' ' or line[indent] == '\t')) indent += 1;

        if (indent == 2 and std.mem.startsWith(u8, trimmed, "- index:")) {
            if (current_comp) |co| { if (current_layer) |*la| try la.components.append(allocator, co); current_comp = null; }
            if (current_layer) |la| try bp.layers.append(allocator, la);
            const idx = std.fmt.parseInt(u32, std.mem.trim(u8, trimmed["- index:".len..], " \t"), 10) catch 0;
            current_layer = .{ .index = idx, .components = std.ArrayList(Component).empty };
            in_components = false; continue;
        }
        if (current_layer == null) continue;

        if (indent == 4) {
            const colon = std.mem.indexOfScalar(u8, trimmed, ':') orelse continue;
            const k = std.mem.trim(u8, trimmed[0..colon], " \t");
            const v = std.mem.trim(u8, trimmed[colon+1..], " \t");
            if (std.mem.eql(u8, k, "skip"))               { current_layer.?.skip = std.mem.eql(u8, v, "true"); }
            else if (std.mem.eql(u8, k, "duplicate_of"))  { if (!std.mem.eql(u8, v, "null")) current_layer.?.duplicate_of = std.fmt.parseInt(u32, v, 10) catch null; }
            else if (std.mem.eql(u8, k, "residual"))      { current_layer.?.residual = !std.mem.eql(u8, v, "false"); }
            else if (std.mem.eql(u8, k, "extra_residual_from")) { current_layer.?.extra_residual_from = std.fmt.parseInt(u32, v, 10) catch null; }
            else if (std.mem.eql(u8, k, "execution_order")) { current_layer.?.execution_order = std.fmt.parseInt(u32, v, 10) catch null; }
            else if (std.mem.eql(u8, k, "components")) { in_components = true; }
            continue;
        }
        if (!in_components) continue;

        if (indent == 6 and std.mem.startsWith(u8, trimmed, "- name:")) {
            if (current_comp) |co| { if (current_layer) |*la| try la.components.append(allocator, co); }
            const name = std.mem.trim(u8, trimmed["- name:".len..], " \t");
            current_comp = Component{ .name = try allocator.dupe(u8, name), .kind = kindFromName(name), .act = .swiglu };
            continue;
        }
        if (indent == 8 and current_comp != null) {
            const colon = std.mem.indexOfScalar(u8, trimmed, ':') orelse continue;
            const k = std.mem.trim(u8, trimmed[0..colon], " \t");
            const v = std.mem.trim(u8, trimmed[colon+1..], " \t");
            if (std.mem.eql(u8, k, "type"))               { current_comp.?.kind = kindFromType(v); current_comp.?.act = parseAct(v); }
            else if (std.mem.eql(u8, k, "skip"))          { current_comp.?.skip = std.mem.eql(u8, v, "true"); }
            else if (std.mem.eql(u8, k, "weight_source")) { current_comp.?.weight_source = try allocator.dupe(u8, v); }
            else if (std.mem.eql(u8, k, "freq_base"))     { current_comp.?.freq_base = std.fmt.parseFloat(f32, v) catch 10000.0; }
            else if (std.mem.eql(u8, k, "freq_scale"))    { current_comp.?.freq_scale = std.fmt.parseFloat(f32, v) catch 1.0; }
            else if (std.mem.eql(u8, k, "sliding_window")) { if (!std.mem.eql(u8, v, "null")) current_comp.?.sliding_window = std.fmt.parseInt(u32, v, 10) catch null; }
            else if (std.mem.eql(u8, k, "expert_count"))      { current_comp.?.expert_count = std.fmt.parseInt(u32, v, 10) catch 0; }
            else if (std.mem.eql(u8, k, "expert_used_count")) { current_comp.?.expert_used_count = std.fmt.parseInt(u32, v, 10) catch 0; }
            else if (std.mem.eql(u8, k, "router_type"))       { current_comp.?.router_type = parseRouter(v); }
        }
    }
    if (current_comp) |co| { if (current_layer) |*la| try la.components.append(allocator, co); }
    if (current_layer) |la| try bp.layers.append(allocator, la);
}

fn kindFromName(name: []const u8) ComponentKind {
    if (std.mem.endsWith(u8, name, "_norm"))        return .rms_norm;
    if (std.mem.eql(u8, name, "rope"))              return .rope;
    if (std.mem.startsWith(u8, name, "ffn_router")) return .moe_router;
    if (std.mem.startsWith(u8, name, "ffn_experts")) return .moe_ffn;
    if (std.mem.startsWith(u8, name, "ffn_shared")) return .linear_ffn;
    if (std.mem.startsWith(u8, name, "ffn_act"))    return .activation;
    return .linear;
}

fn kindFromType(t: []const u8) ComponentKind {
    if (std.mem.eql(u8, t, "rms_norm"))   return .rms_norm;
    if (std.mem.eql(u8, t, "rope"))       return .rope;
    if (std.mem.eql(u8, t, "moe_router")) return .moe_router;
    if (std.mem.eql(u8, t, "moe_ffn"))   return .moe_ffn;
    if (std.mem.eql(u8, t, "linear_ffn")) return .linear_ffn;
    if (std.mem.eql(u8, t, "silu") or std.mem.eql(u8, t, "gelu") or
        std.mem.eql(u8, t, "relu") or std.mem.eql(u8, t, "swiglu") or
        std.mem.eql(u8, t, "geglu")) return .activation;
    return .linear;
}

// ── CustomGraph ───────────────────────────────────────────────────────────────
pub const CustomGraph = struct {
    blueprint: Blueprint,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, _model: *c.llama_model, yaml_text: []const u8) !*CustomGraph {
        _ = _model;
        var bp = try parseBlueprint(allocator, yaml_text);
        errdefer bp.deinit();

        const self = try allocator.create(CustomGraph);
        self.* = .{ .blueprint = bp, .allocator = allocator };

        for (bp.layers.items) |*layer| {
            if (layer.skip) std.debug.print("custom: layer {d} SKIPPED\n", .{layer.index});
            if (layer.duplicate_of) |src| std.debug.print("custom: layer {d} → dup of {d}\n", .{ layer.index, src });
            for (layer.components.items) |*comp| {
                if (comp.skip) std.debug.print("custom: layer {d}.{s} SKIPPED\n", .{ layer.index, comp.name });
                if (comp.weight_source) |ws| std.debug.print("custom: layer {d}.{s} weight_source={s}\n", .{ layer.index, comp.name, ws });
            }
        }
        return self;
    }

    pub fn deinit(self: *CustomGraph) void {
        self.blueprint.deinit();
        self.allocator.destroy(self);
    }

    pub fn install(self: *CustomGraph, lctx: *c.llama_context) void {
        bridge.zllm_set_graph_post_build_callback(lctx, graphCallback, self);
    }

    pub fn uninstall(_: *CustomGraph, lctx: *c.llama_context) void {
        bridge.zllm_set_graph_post_build_callback(lctx, null, null);
    }
};

// ── Graph patch callback ──────────────────────────────────────────────────────
fn graphCallback(gf: *c.ggml_cgraph, userdata: ?*anyopaque) callconv(.c) void {
    const cg: *CustomGraph = @ptrCast(@alignCast(userdata orelse return));
    applyBlueprint(gf, &cg.blueprint) catch |err| {
        std.debug.print("custom: graph patch error: {s}\n", .{@errorName(err)});
    };
}

fn applyBlueprint(gf: *c.ggml_cgraph, bp: *const Blueprint) !void {
    const nodes: [*]*c.ggml_tensor = @ptrCast(c.ggml_graph_nodes(gf));
    const n: usize = @intCast(c.ggml_graph_n_nodes(gf));

    for (bp.layers.items) |*layer| {
        if (layer.skip) skipLayer(nodes, n, layer.index);
        if (layer.duplicate_of) |src| duplicateLayer(nodes, n, layer.index, src);
        for (layer.components.items) |*comp| {
            if (comp.skip) skipComponent(nodes, n, layer.index, comp.name);
            if (comp.kind == .activation) swapActivation(nodes, n, layer.index, comp.act);
        }
    }
}

/// Replace the layer's output residual-add with a pass-through of its first src.
fn skipLayer(nodes: [*]*c.ggml_tensor, n: usize, layer_idx: u32) void {
    var buf: [64]u8 = undefined;
    const target = std.fmt.bufPrintZ(&buf, "l_out-{d}", .{layer_idx}) catch return;
    for (0..n) |i| {
        const t = nodes[i];
        const name = c.ggml_get_name(t) orelse continue;
        if (std.mem.eql(u8, std.mem.span(name), std.mem.span(target.ptr))) {
            if (t.src[0] != null) {
                t.op = c.GGML_OP_CONT;
                t.src[1] = null;
                std.debug.print("custom: skipped layer {d}\n", .{layer_idx});
            }
            break;
        }
    }
}

/// Stub — weight-level redirect requires mapping node names across layers.
fn duplicateLayer(nodes: [*]*c.ggml_tensor, n: usize, dst: u32, src: u32) void {
    _ = nodes; _ = n; _ = dst; _ = src;
    std.debug.print("custom: duplicate_of not yet implemented\n", .{});
}

/// Replace a named component node with pass-through.
fn skipComponent(nodes: [*]*c.ggml_tensor, n: usize, layer_idx: u32, comp_name: []const u8) void {
    var buf: [64]u8 = undefined;
    const prefix = std.fmt.bufPrint(&buf, "{s}-{d}", .{ comp_name, layer_idx }) catch return;
    for (0..n) |i| {
        const t = nodes[i];
        const name = c.ggml_get_name(t) orelse continue;
        if (std.mem.startsWith(u8, std.mem.span(name), prefix)) {
            if (t.src[0] != null) {
                t.op = c.GGML_OP_CONT;
                t.src[1] = null;
                std.debug.print("custom: skipped {s} at layer {d}\n", .{ comp_name, layer_idx });
            }
        }
    }
}

/// Change the GGML_OP_UNARY activation for ffn_act-{layer_idx}.
fn swapActivation(nodes: [*]*c.ggml_tensor, n: usize, layer_idx: u32, act: ActivationType) void {
    var buf: [64]u8 = undefined;
    const target = std.fmt.bufPrintZ(&buf, "ffn_act-{d}", .{layer_idx}) catch return;
    for (0..n) |i| {
        const t = nodes[i];
        const name = c.ggml_get_name(t) orelse continue;
        if (!std.mem.eql(u8, std.mem.span(name), std.mem.span(target.ptr))) continue;
        if (t.op != c.GGML_OP_UNARY) continue;
        const new_op: c_int = switch (act) {
            .silu, .swiglu => c.GGML_UNARY_OP_SILU,
            .gelu, .geglu  => c.GGML_UNARY_OP_GELU,
            .relu          => c.GGML_UNARY_OP_RELU,
        };
        @as(*c_int, @ptrCast(@alignCast(&t.op_params[0]))).* = new_op;
        std.debug.print("custom: swapped activation at layer {d} to {s}\n", .{ layer_idx, @tagName(act) });
    }
}

// ── Global state ──────────────────────────────────────────────────────────────
pub var g_custom_graph: ?*CustomGraph = null;

pub fn initCustomGraph(allocator: std.mem.Allocator, model: *c.llama_model, yaml_text: []const u8) !void {
    if (g_custom_graph) |old| old.deinit();
    g_custom_graph = try CustomGraph.init(allocator, model, yaml_text);
}

pub fn freeCustomGraph() void {
    if (g_custom_graph) |g| { g.deinit(); g_custom_graph = null; }
}

// ── GraphOps ─────────────────────────────────────────────────────────────────

fn prefill(ms: *loader.ModelState, tokens: []const c.llama_token) !void {
    if (g_custom_graph) |cg| cg.install(ms.ctx);
    const batch = c.llama_batch_get_one(@constCast(tokens.ptr), @intCast(tokens.len));
    if (c.llama_decode(ms.ctx, batch) < 0) return error.DecodeFailed;
}

fn decodeOne(ms: *loader.ModelState, token: c.llama_token) !void {
    var t = token;
    const batch = c.llama_batch_get_one(&t, 1);
    if (c.llama_decode(ms.ctx, batch) < 0) return error.DecodeFailed;
}

fn sample(ms: *loader.ModelState) c.llama_token {
    return c.llama_sampler_sample(ms.sampler, ms.ctx, -1);
}

fn accept(ms: *loader.ModelState, token: c.llama_token) void {
    c.llama_sampler_accept(ms.sampler, token);
}

pub const ops: interface.GraphOps = .{
    .prefill   = prefill,
    .decodeOne = decodeOne,
    .sample    = sample,
    .accept    = accept,
};
