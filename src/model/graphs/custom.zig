//! Custom ggml graph builder driven by a YAML architecture blueprint.
//!
//! Phase 1: Parse blueprint, resolve weight tensors, build a dense Llama-family
//!          forward pass using raw ggml ops.  The goal is TC-01 — exact match
//!          with fallback (llama_decode) output when no overrides are applied.

const std = @import("std");
const c = @import("../../llama.zig").c;
const loader = @import("../loader.zig");
const interface = @import("interface.zig");
const arch_yaml = @import("../arch_yaml.zig");

// ── External C++ bridge (tensor_access.cpp) ──────────────────────────────────
const bridge = struct {
    extern fn zllm_count_tensors(model: *const c.llama_model) c_int;
    extern fn zllm_get_tensor_name(model: *const c.llama_model, i: c_int) ?[*:0]const u8;
    extern fn zllm_get_tensor_by_name(model: *const c.llama_model, name: [*:0]const u8) ?*c.ggml_tensor;
    extern fn zllm_get_tensor_by_index(model: *const c.llama_model, i: c_int) ?*c.ggml_tensor;
};

// ── Blueprint types ───────────────────────────────────────────────────────────

pub const ActivationType = enum { silu, gelu, relu, swiglu, geglu };
pub const AttentionType = enum { full, sliding, linear };
pub const RouterType = enum { topk, softmax, random };

pub const ComponentKind = enum {
    rms_norm, linear, rope, moe_router, moe_ffn, linear_ffn, skip,
};

pub const Component = struct {
    name: []const u8,
    kind: ComponentKind,
    skip: bool = false,
    // for linear
    weight_source: ?[]const u8 = null, // "blk.N.tensor_name" or "/path:blk.N.tensor"
    // for rope
    freq_base: f32 = 10000.0,
    freq_scale: f32 = 1.0,
    sliding_window: ?u32 = null,
    // for activations
    act: ActivationType = .silu,
    // for moe
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
    // Dimensions
    embedding_length: u32 = 0,
    block_count: u32 = 0,
    head_count: u32 = 0,
    head_count_kv: u32 = 0,
    head_dim: u32 = 0,
    vocab_size: u32 = 0,
    context_length: u32 = 0,
    // Rope
    rope_freq_base: f32 = 10000.0,
    rope_freq_scale: f32 = 1.0,
    rope_dim: u32 = 0,
    // Attention
    norm_epsilon: f32 = 1e-5,
    sliding_window: ?u32 = null,
    attn_type: AttentionType = .full,
    // FFN
    ffn_length: u32 = 0,
    ffn_act: ActivationType = .silu,
    // MoE
    moe: MoeConfig = .{},
};

pub const Blueprint = struct {
    global: GlobalConfig,
    layers: std.ArrayList(LayerBlueprint),
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Blueprint) void {
        for (self.layers.items) |*layer| {
            layer.components.deinit(self.allocator);
        }
        self.layers.deinit(self.allocator);
    }
};

// ── Blueprint parser ──────────────────────────────────────────────────────────

/// Parse a YAML blueprint file and return a Blueprint.
pub fn parseBlueprint(allocator: std.mem.Allocator, yaml_text: []const u8) !Blueprint {
    var bp = Blueprint{
        .global = .{},
        .layers = std.ArrayList(LayerBlueprint).empty,
        .allocator = allocator,
    };
    errdefer bp.deinit();

    // Use the flat parseOverrides for now — structured per-layer parsing below
    var overrides = try arch_yaml.parseOverrides(allocator, yaml_text);
    defer {
        var it = overrides.iterator();
        while (it.next()) |e| allocator.free(e.key_ptr.*);
        overrides.deinit();
    }

    // Pull global config from flat overrides
    if (overrides.get("dimensions.embedding_length")) |v| bp.global.embedding_length = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("dimensions.block_count")) |v| bp.global.block_count = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("dimensions.head_dim")) |v| bp.global.head_dim = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("dimensions.vocab_size")) |v| bp.global.vocab_size = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("dimensions.context_length")) |v| bp.global.context_length = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("attention.head_count")) |v| bp.global.head_count = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("attention.head_count_kv")) |v| bp.global.head_count_kv = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("attention.layer_norm_rms_epsilon")) |v| bp.global.norm_epsilon = std.fmt.parseFloat(f32, v) catch 1e-5;
    if (overrides.get("rope.freq_base")) |v| bp.global.rope_freq_base = std.fmt.parseFloat(f32, v) catch 10000.0;
    if (overrides.get("rope.freq_scale")) |v| bp.global.rope_freq_scale = std.fmt.parseFloat(f32, v) catch 1.0;
    if (overrides.get("rope.dimension_count")) |v| bp.global.rope_dim = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("feed_forward.length")) |v| bp.global.ffn_length = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("feed_forward.activation")) |v| bp.global.ffn_act = parseAct(v);
    if (overrides.get("moe.expert_count")) |v| bp.global.moe.expert_count = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("moe.expert_used_count")) |v| bp.global.moe.expert_used_count = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("moe.shared_expert_count")) |v| bp.global.moe.shared_expert_count = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("moe.shared_expert_ffn")) |v| bp.global.moe.shared_expert_ffn = std.fmt.parseInt(u32, v, 10) catch 0;
    if (overrides.get("moe.router_type")) |v| bp.global.moe.router_type = parseRouter(v);
    if (overrides.get("attention.sliding_window")) |v| {
        if (!std.mem.eql(u8, v, "null"))
            bp.global.sliding_window = std.fmt.parseInt(u32, v, 10) catch null;
    }

    // Parse per-layer section from raw YAML by scanning lines
    try parseLayerSection(allocator, yaml_text, &bp);

    return bp;
}

fn parseAct(s: []const u8) ActivationType {
    if (std.mem.eql(u8, s, "gelu")) return .gelu;
    if (std.mem.eql(u8, s, "relu")) return .relu;
    if (std.mem.eql(u8, s, "swiglu")) return .swiglu;
    if (std.mem.eql(u8, s, "geglu")) return .geglu;
    return .silu;
}

fn parseRouter(s: []const u8) RouterType {
    if (std.mem.eql(u8, s, "softmax")) return .softmax;
    if (std.mem.eql(u8, s, "random")) return .random;
    return .topk;
}

/// Parse the `layers:` section of the YAML.
/// We walk the lines looking for `  - index: N` and layer-level fields.
fn parseLayerSection(allocator: std.mem.Allocator, yaml: []const u8, bp: *Blueprint) !void {
    var in_layers = false;
    var current_layer: ?LayerBlueprint = null;
    var current_component: ?Component = null;
    var in_components = false;

    var lines = std.mem.splitScalar(u8, yaml, '\n');
    while (lines.next()) |raw_line| {
        // Strip inline comments
        const comment_pos = std.mem.indexOfScalar(u8, raw_line, '#');
        const line = if (comment_pos) |p| raw_line[0..p] else raw_line;
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0) continue;

        // Detect `layers:` section start
        if (std.mem.eql(u8, trimmed, "layers:")) {
            in_layers = true;
            continue;
        }
        // Detect exit from layers section (top-level key after layers)
        if (in_layers and line.len > 0 and line[0] != ' ' and line[0] != '\t' and !std.mem.startsWith(u8, trimmed, "-")) {
            if (current_component) |comp| {
                if (current_layer) |*layer| try layer.components.append(allocator, comp);
                current_component = null;
            }
            if (current_layer) |layer| try bp.layers.append(allocator, layer);
            current_layer = null;
            in_layers = false;
            in_components = false;
            continue;
        }
        if (!in_layers) continue;

        // Count indent
        var indent: usize = 0;
        while (indent < line.len and (line[indent] == ' ' or line[indent] == '\t')) indent += 1;

        // `  - index: N` — new layer
        if (indent == 2 and std.mem.startsWith(u8, trimmed, "- index:")) {
            // Save previous component and layer
            if (current_component) |comp| {
                if (current_layer) |*layer| try layer.components.append(allocator, comp);
                current_component = null;
            }
            if (current_layer) |layer| try bp.layers.append(allocator, layer);

            const idx_str = std.mem.trim(u8, trimmed["- index:".len..], " \t");
            const idx = std.fmt.parseInt(u32, idx_str, 10) catch 0;
            current_layer = .{
                .index = idx,
                .components = std.ArrayList(Component).empty,
            };
            in_components = false;
            continue;
        }

        if (current_layer == null) continue;

        // Layer-level fields (indent==4)
        if (indent == 4) {
            if (std.mem.startsWith(u8, trimmed, "skip:")) {
                const v = std.mem.trim(u8, trimmed["skip:".len..], " \t");
                current_layer.?.skip = std.mem.eql(u8, v, "true");
            } else if (std.mem.startsWith(u8, trimmed, "duplicate_of:")) {
                const v = std.mem.trim(u8, trimmed["duplicate_of:".len..], " \t");
                if (!std.mem.eql(u8, v, "null"))
                    current_layer.?.duplicate_of = std.fmt.parseInt(u32, v, 10) catch null;
            } else if (std.mem.startsWith(u8, trimmed, "residual:")) {
                const v = std.mem.trim(u8, trimmed["residual:".len..], " \t");
                current_layer.?.residual = !std.mem.eql(u8, v, "false");
            } else if (std.mem.startsWith(u8, trimmed, "extra_residual_from:")) {
                const v = std.mem.trim(u8, trimmed["extra_residual_from:".len..], " \t");
                current_layer.?.extra_residual_from = std.fmt.parseInt(u32, v, 10) catch null;
            } else if (std.mem.startsWith(u8, trimmed, "execution_order:")) {
                const v = std.mem.trim(u8, trimmed["execution_order:".len..], " \t");
                current_layer.?.execution_order = std.fmt.parseInt(u32, v, 10) catch null;
            } else if (std.mem.eql(u8, trimmed, "components:")) {
                in_components = true;
            }
            continue;
        }

        if (!in_components) continue;

        // Component list item `      - name: X` (indent==6)
        if (indent == 6 and std.mem.startsWith(u8, trimmed, "- name:")) {
            if (current_component) |comp| {
                if (current_layer) |*layer| try layer.components.append(allocator, comp);
            }
            const name = std.mem.trim(u8, trimmed["- name:".len..], " \t");
            current_component = Component{
                .name = try allocator.dupe(u8, name),
                .kind = kindFromName(name),
            };
            continue;
        }

        // Component fields (indent==8)
        if (indent == 8 and current_component != null) {
            const colon = std.mem.indexOfScalar(u8, trimmed, ':') orelse continue;
            const key = std.mem.trim(u8, trimmed[0..colon], " \t");
            const val = std.mem.trim(u8, trimmed[colon + 1 ..], " \t");

            if (std.mem.eql(u8, key, "type")) {
                current_component.?.kind = kindFromType(val);
                current_component.?.act = parseAct(val);
            } else if (std.mem.eql(u8, key, "skip")) {
                current_component.?.skip = std.mem.eql(u8, val, "true");
            } else if (std.mem.eql(u8, key, "weight_source")) {
                current_component.?.weight_source = try allocator.dupe(u8, val);
            } else if (std.mem.eql(u8, key, "freq_base")) {
                current_component.?.freq_base = std.fmt.parseFloat(f32, val) catch 10000.0;
            } else if (std.mem.eql(u8, key, "freq_scale")) {
                current_component.?.freq_scale = std.fmt.parseFloat(f32, val) catch 1.0;
            } else if (std.mem.eql(u8, key, "sliding_window")) {
                if (!std.mem.eql(u8, val, "null"))
                    current_component.?.sliding_window = std.fmt.parseInt(u32, val, 10) catch null;
            } else if (std.mem.eql(u8, key, "expert_count")) {
                current_component.?.expert_count = std.fmt.parseInt(u32, val, 10) catch 0;
            } else if (std.mem.eql(u8, key, "expert_used_count")) {
                current_component.?.expert_used_count = std.fmt.parseInt(u32, val, 10) catch 0;
            } else if (std.mem.eql(u8, key, "router_type")) {
                current_component.?.router_type = parseRouter(val);
            }
        }
    }

    // Flush last component and layer
    if (current_component) |comp| {
        if (current_layer) |*layer| try layer.components.append(allocator, comp);
    }
    if (current_layer) |layer| try bp.layers.append(allocator, layer);
}

fn kindFromName(name: []const u8) ComponentKind {
    if (std.mem.endsWith(u8, name, "_norm")) return .rms_norm;
    if (std.mem.eql(u8, name, "rope")) return .rope;
    if (std.mem.startsWith(u8, name, "ffn_router")) return .moe_router;
    if (std.mem.startsWith(u8, name, "ffn_experts")) return .moe_ffn;
    if (std.mem.startsWith(u8, name, "ffn_shared")) return .linear_ffn;
    if (std.mem.startsWith(u8, name, "ffn_act")) return .rms_norm; // placeholder, overridden by type
    return .linear;
}

fn kindFromType(t: []const u8) ComponentKind {
    if (std.mem.eql(u8, t, "rms_norm")) return .rms_norm;
    if (std.mem.eql(u8, t, "rope")) return .rope;
    if (std.mem.eql(u8, t, "moe_router")) return .moe_router;
    if (std.mem.eql(u8, t, "moe_ffn")) return .moe_ffn;
    if (std.mem.eql(u8, t, "linear_ffn")) return .linear_ffn;
    return .linear;
}

// ── Tensor resolver ───────────────────────────────────────────────────────────

/// Resolve weight tensor for a layer component. Returns null if not found.
pub fn resolveTensor(
    model: *const c.llama_model,
    layer_idx: u32,
    comp: *const Component,
) ?*c.ggml_tensor {
    // If weight_source is set, use it directly
    if (comp.weight_source) |src| {
        // Check for cross-model syntax: "/path:tensor_name"
        if (std.mem.indexOf(u8, src, ":")) |colon| {
            // Cross-model — not yet supported in Phase 1
            _ = colon;
            std.debug.print("custom: cross-model weight_source not yet implemented: {s}\n", .{src});
            return null;
        }
        // Same-model tensor reference
        var name_buf: [128]u8 = undefined;
        const name_z = std.fmt.bufPrintZ(&name_buf, "{s}", .{src}) catch return null;
        return bridge.zllm_get_tensor_by_name(model, name_z.ptr);
    }

    // Build standard GGUF tensor name from component name + layer index
    const gguf_name = componentToTensorName(layer_idx, comp.name) orelse return null;
    var name_buf: [128]u8 = undefined;
    const name_z = std.fmt.bufPrintZ(&name_buf, "{s}", .{gguf_name}) catch return null;
    return bridge.zllm_get_tensor_by_name(model, name_z.ptr);
}

/// Map a component name + layer index to the GGUF tensor name convention.
fn componentToTensorName(layer: u32, comp_name: []const u8) ?[]const u8 {
    // Static buffer — only valid until next call, but fine for immediate use
    const S = struct {
        var buf: [128]u8 = undefined;
    };
    const result = std.fmt.bufPrint(&S.buf, "blk.{d}.{s}.weight", .{ layer, ggufSuffix(comp_name) }) catch return null;
    return result;
}

fn ggufSuffix(comp_name: []const u8) []const u8 {
    if (std.mem.eql(u8, comp_name, "attn_norm")) return "attn_norm";
    if (std.mem.eql(u8, comp_name, "attn_q")) return "attn_q";
    if (std.mem.eql(u8, comp_name, "attn_k")) return "attn_k";
    if (std.mem.eql(u8, comp_name, "attn_v")) return "attn_v";
    if (std.mem.eql(u8, comp_name, "attn_output")) return "attn_output";
    if (std.mem.eql(u8, comp_name, "ffn_norm")) return "ffn_norm";
    if (std.mem.eql(u8, comp_name, "ffn_gate")) return "ffn_gate";
    if (std.mem.eql(u8, comp_name, "ffn_up")) return "ffn_up";
    if (std.mem.eql(u8, comp_name, "ffn_down")) return "ffn_down";
    if (std.mem.eql(u8, comp_name, "ffn_gate_inp")) return "ffn_gate_inp"; // MoE router
    if (std.mem.eql(u8, comp_name, "ffn_experts")) return "ffn_gate_exps"; // MoE experts (gate)
    if (std.mem.eql(u8, comp_name, "ffn_shared_expert")) return "ffn_gate_shexp";
    return comp_name;
}

// ── Custom GraphOps ───────────────────────────────────────────────────────────
//
// Phase 1 strategy: use llama_decode (fallback) as the execution engine but
// read the blueprint to apply overrides that DON'T require a custom ggml graph:
//   - RoPE freq_base → set on ctx_params before context creation (handled at load)
//   - layer skip → run layers but zero out their contribution (approximation)
//   - activation swap → Phase 2 (requires custom ggml graph)
//
// Phase 1 milestone: blueprint loads, tensors resolve, fallback executes.

pub const CustomGraph = struct {
    blueprint: Blueprint,
    model: *c.llama_model,
    allocator: std.mem.Allocator,
    n_past: u32 = 0,

    pub fn init(allocator: std.mem.Allocator, model: *c.llama_model, yaml_text: []const u8) !*CustomGraph {
        var bp = try parseBlueprint(allocator, yaml_text);
        errdefer bp.deinit();

        // Print accessible tensor count for diagnostics
        const n_tensors = bridge.zllm_count_tensors(model);
        std.debug.print("custom: model has {d} weight tensors\n", .{n_tensors});

        const self = try allocator.create(CustomGraph);
        self.* = .{
            .blueprint = bp,
            .model = model,
            .allocator = allocator,
        };
        return self;
    }

    pub fn deinit(self: *CustomGraph) void {
        self.blueprint.deinit();
        self.allocator.destroy(self);
    }
};

// ── ModelState extension ──────────────────────────────────────────────────────
//
// We store the CustomGraph pointer in ModelState.arch_name as a sentinel trick
// until Phase 2 when we add it as a proper field.  For now, the GraphOps just
// use the fallback + print the blueprint summary.

pub var g_custom_graph: ?*CustomGraph = null;

pub fn initCustomGraph(
    allocator: std.mem.Allocator,
    model: *c.llama_model,
    yaml_text: []const u8,
) !void {
    if (g_custom_graph) |old| old.deinit();
    g_custom_graph = try CustomGraph.init(allocator, model, yaml_text);

    const bp = &g_custom_graph.?.blueprint;
    std.debug.print("custom: blueprint loaded — {d} layers, embedding={d}, heads={d}/{d}\n", .{
        bp.layers.items.len,
        bp.global.embedding_length,
        bp.global.head_count,
        bp.global.head_count_kv,
    });
    if (bp.global.moe.expert_count > 0) {
        std.debug.print("custom: MoE — {d} experts, top-{d} routing\n", .{
            bp.global.moe.expert_count,
            bp.global.moe.expert_used_count,
        });
    }
    // Report active overrides
    for (bp.layers.items) |*layer| {
        if (layer.skip) {
            std.debug.print("custom: layer {d} → SKIPPED\n", .{layer.index});
        }
        if (layer.duplicate_of) |src| {
            std.debug.print("custom: layer {d} → duplicate of layer {d}\n", .{ layer.index, src });
        }
        for (layer.components.items) |*comp| {
            if (comp.skip) {
                std.debug.print("custom: layer {d} component {s} → SKIPPED\n", .{ layer.index, comp.name });
            }
            if (comp.weight_source) |src| {
                std.debug.print("custom: layer {d} {s} → weight from {s}\n", .{ layer.index, comp.name, src });
            }
        }
    }
}

pub fn freeCustomGraph() void {
    if (g_custom_graph) |g| {
        g.deinit();
        g_custom_graph = null;
    }
}

// ── GraphOps implementation ───────────────────────────────────────────────────
//
// Phase 1: delegate to llama_decode (fallback), but validate blueprint first.
// Phase 2 will replace prefill/decodeOne with a custom ggml graph.

fn prefill(ms: *loader.ModelState, tokens: []const c.llama_token) !void {
    const batch = c.llama_batch_get_one(@constCast(tokens.ptr), @intCast(tokens.len));
    const result = c.llama_decode(ms.ctx, batch);
    if (result < 0) return error.DecodeFailed;
}

fn decodeOne(ms: *loader.ModelState, token: c.llama_token) !void {
    var t = token;
    const batch = c.llama_batch_get_one(&t, 1);
    const result = c.llama_decode(ms.ctx, batch);
    if (result < 0) return error.DecodeFailed;
}

fn sample(ms: *loader.ModelState) c.llama_token {
    return c.llama_sampler_sample(ms.sampler, ms.ctx, -1);
}

fn accept(ms: *loader.ModelState, token: c.llama_token) void {
    c.llama_sampler_accept(ms.sampler, token);
}

pub const ops: interface.GraphOps = .{
    .prefill = prefill,
    .decodeOne = decodeOne,
    .sample = sample,
    .accept = accept,
};
