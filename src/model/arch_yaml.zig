//! Serialize GGUF model metadata to a structured, edit-friendly YAML blueprint.
//! The output is designed to be human-editable: fields the user can change are
//! at the top, raw metadata is at the bottom, and per-layer sections are compact
//! and clearly annotated with what each field controls.

const std = @import("std");
const c = @import("../llama.zig").c;

fn metaStr(model: *const c.llama_model, key: [*:0]const u8, buf: []u8) []const u8 {
    const n = c.llama_model_meta_val_str(model, key, buf.ptr, buf.len);
    if (n > 0 and @as(usize, @intCast(n)) <= buf.len) return buf[0..@intCast(n)];
    return "";
}

fn metaI64(model: *const c.llama_model, key: [*:0]const u8) ?i64 {
    var buf: [64]u8 = undefined;
    const s = metaStr(model, key, &buf);
    if (s.len == 0) return null;
    return std.fmt.parseInt(i64, s, 10) catch null;
}

fn w(out: *std.ArrayList(u8), allocator: std.mem.Allocator, comptime f: []const u8, args: anytype) !void {
    var tmp: [4096]u8 = undefined;
    if (std.fmt.bufPrint(&tmp, f, args)) |s| {
        try out.appendSlice(allocator, s);
    } else |_| {
        const heap = try std.fmt.allocPrint(allocator, f, args);
        defer allocator.free(heap);
        try out.appendSlice(allocator, heap);
    }
}

/// Serialize model metadata + per-layer blueprint to an edit-friendly YAML.
pub fn serialize(allocator: std.mem.Allocator, model: *const c.llama_model) ![]u8 {
    var out = std.ArrayList(u8).empty;
    errdefer out.deinit(allocator);

    // ── Identify architecture ──────────────────────────────────────────────
    var arch_buf: [64]u8 = undefined;
    const arch = metaStr(model, "general.architecture", &arch_buf);
    var arch_pfx_buf: [72]u8 = undefined;
    const arch_pfx: []const u8 = if (arch.len > 0)
        std.fmt.bufPrint(&arch_pfx_buf, "{s}.", .{arch}) catch arch
    else
        "llama.";

    // ── Model info ────────────────────────────────────────────────────────
    var desc_buf: [256]u8 = undefined;
    const desc_n = c.llama_model_desc(model, &desc_buf, desc_buf.len);
    const desc = if (desc_n >= 0) desc_buf[0..@intCast(desc_n)] else "unknown";
    const n_params = c.llama_model_n_params(model);
    const model_size = c.llama_model_size(model);

    const n_embd: i32 = c.llama_model_n_embd(model);
    const n_layer: i32 = c.llama_model_n_layer(model);
    const n_head: i32 = c.llama_model_n_head(model);
    const n_head_kv: i32 = c.llama_model_n_head_kv(model);
    const head_dim: i32 = if (n_head > 0) @divTrunc(n_embd, n_head) else 0;
    const kv_dim: i32 = if (n_head_kv > 0) n_head_kv * head_dim else 0;

    var pfx_key_buf: [128]u8 = undefined;
    const vocab_key = std.fmt.bufPrintZ(&pfx_key_buf, "{s}vocab_size", .{arch_pfx}) catch "llama.vocab_size";
    const vocab_size = metaI64(model, vocab_key) orelse metaI64(model, "general.vocab_size") orelse 0;
    const ctx_key = std.fmt.bufPrintZ(&pfx_key_buf, "{s}context_length", .{arch_pfx}) catch "llama.context_length";
    const ctx_len = metaI64(model, ctx_key) orelse 0;

    const rope_base_key = std.fmt.bufPrintZ(&pfx_key_buf, "{s}rope.freq_base", .{arch_pfx}) catch "llama.rope.freq_base";
    var rope_buf: [64]u8 = undefined;
    const rope_base = metaStr(model, rope_base_key, &rope_buf);
    const rope_scale = c.llama_model_rope_freq_scale_train(model);
    const rope_dim_key = std.fmt.bufPrintZ(&pfx_key_buf, "{s}rope.dimension_count", .{arch_pfx}) catch "llama.rope.dimension_count";
    const rope_dim = metaI64(model, rope_dim_key) orelse head_dim;

    const eps_key = std.fmt.bufPrintZ(&pfx_key_buf, "{s}attention.layer_norm_rms_epsilon", .{arch_pfx}) catch "llama.attention.layer_norm_rms_epsilon";
    var eps_buf: [64]u8 = undefined;
    const eps = metaStr(model, eps_key, &eps_buf);

    const ffn_key = std.fmt.bufPrintZ(&pfx_key_buf, "{s}feed_forward_length", .{arch_pfx}) catch "llama.feed_forward_length";
    var ffn_buf: [64]u8 = undefined;
    const ffn_str = metaStr(model, ffn_key, &ffn_buf);
    const ffn_dim: i64 = if (ffn_str.len > 0) std.fmt.parseInt(i64, ffn_str, 10) catch 0 else 0;

    // MoE fields
    const exp_count_key = std.fmt.bufPrintZ(&pfx_key_buf, "{s}expert_count", .{arch_pfx}) catch "";
    const exp_count = metaI64(model, exp_count_key) orelse 0;
    const exp_used_key = std.fmt.bufPrintZ(&pfx_key_buf, "{s}expert_used_count", .{arch_pfx}) catch "";
    const exp_used = metaI64(model, exp_used_key) orelse 0;
    const exp_shared_ffn_key = std.fmt.bufPrintZ(&pfx_key_buf, "{s}expert_shared_feed_forward_length", .{arch_pfx}) catch "";
    const exp_shared_ffn = metaI64(model, exp_shared_ffn_key) orelse 0;
    const exp_shared_count_key = std.fmt.bufPrintZ(&pfx_key_buf, "{s}expert_shared_count", .{arch_pfx}) catch "";
    const exp_shared_count = metaI64(model, exp_shared_count_key) orelse (if (exp_shared_ffn > 0) @as(i64, 1) else 0);
    const is_moe = exp_count > 0;

    const act: []const u8 = if (std.mem.eql(u8, arch, "gemma4")) "gelu" else "silu";
    const ffn_type: []const u8 = if (std.mem.eql(u8, arch, "gemma4")) "geglu" else "swiglu";
    const gqa = n_head_kv > 0 and n_head_kv < n_head;

    // ══════════════════════════════════════════════════════════════════════
    // HEADER
    // ══════════════════════════════════════════════════════════════════════
    try w(&out, allocator,
        \\# ╔══════════════════════════════════════════════════════════════════╗
        \\# ║  zllm2 Architecture Blueprint — edit this file, then reload     ║
        \\# ║  zllm2 -m model.gguf --arch this_file.yaml                      ║
        \\# ╚══════════════════════════════════════════════════════════════════╝
        \\#
        \\# HOW TO EDIT:
        \\#   • Change any value under [editable] sections
        \\#   • Per-layer overrides go in the `layers:` section
        \\#   • Set `skip: true` on a layer to remove it from the graph
        \\#   • Set `duplicate_of: N` to reuse another layer's weights
        \\#   • Change `ffn_act.type` to swap activation (silu/gelu/relu/swiglu/geglu)
        \\#   • Set `attention.sliding_window` to cap attention span
        \\#   • Set `weight_source: blk.N.tensor_name` to borrow a weight
        \\#   • MoE: change `expert_used_count` to use fewer/more experts
        \\
        \\
    , .{});

    // ══════════════════════════════════════════════════════════════════════
    // MODEL INFO (read-only, informational)
    // ══════════════════════════════════════════════════════════════════════
    try w(&out, allocator,
        \\# ── Model Info (read-only) ───────────────────────────────────────────
        \\model:
        \\  description: "{s}"
        \\  architecture: {s}
        \\  params: {d}       # {d:.2}B
        \\  size_bytes: {d}   # {d:.2} GB
        \\
        \\
    , .{
        desc, arch,
        n_params, @as(f64, @floatFromInt(n_params)) / 1e9,
        model_size, @as(f64, @floatFromInt(model_size)) / (1024.0 * 1024.0 * 1024.0),
    });

    // ══════════════════════════════════════════════════════════════════════
    // GLOBAL OVERRIDES [editable]
    // ══════════════════════════════════════════════════════════════════════
    try out.appendSlice(allocator,
        \\# ── Global Overrides [editable] ─────────────────────────────────────
        \\# Changes here apply to the whole model unless overridden per-layer.
        \\
        \\
    );

    // Dimensions (mostly read-only but ctx and vocab can matter)
    try w(&out, allocator,
        \\dimensions:
        \\  embedding_length: {d}   # read-only: baked into weight shapes
        \\  block_count: {d}        # number of transformer layers
        \\  head_dim: {d}           # per-head dimension
        \\  vocab_size: {d}
        \\  context_length: {d}     # max sequence length (can reduce to save KV cache)
        \\
        \\
    , .{ n_embd, n_layer, head_dim, vocab_size, ctx_len });

    // Attention
    try w(&out, allocator,
        \\attention:
        \\  head_count: {d}
        \\  head_count_kv: {d}      # GQA={s}; increase to head_count for full attention
        \\  q_dim: {d}
        \\  kv_dim: {d}
        \\  layer_norm_rms_epsilon: {s}
        \\  sliding_window: null    # set to integer (e.g. 4096) to enable SWA globally
        \\  type: full              # full | sliding | linear
        \\
        \\
    , .{ n_head, n_head_kv, if (gqa) "true" else "false", n_embd, kv_dim, if (eps.len > 0) eps else "1e-5" });

    // RoPE
    try w(&out, allocator,
        \\rope:
        \\  freq_base: {s}          # increase for longer context (e.g. 500000 → 1000000)
        \\  freq_scale: {d:.4}
        \\  dimension_count: {d}
        \\
        \\
    , .{ if (rope_base.len > 0) rope_base else "10000", rope_scale, rope_dim });

    // FFN
    try w(&out, allocator,
        \\feed_forward:
        \\  length: {d}
        \\  activation: {s}         # silu | gelu | relu | swiglu | geglu
        \\  type: {s}
        \\
        \\
    , .{ ffn_dim, act, ffn_type });

    // MoE section (only if MoE model)
    if (is_moe) {
        try w(&out, allocator,
            \\moe:
            \\  expert_count: {d}        # total number of experts (read-only: set by weights)
            \\  expert_used_count: {d}   # how many experts to route each token to (editable)
            \\  shared_expert_count: {d} # always-active experts (0 = none)
            \\  shared_expert_ffn: {d}   # shared expert FFN dimension
            \\  router_type: topk        # topk | softmax | random
            \\
            \\
        , .{ exp_count, exp_used, exp_shared_count, exp_shared_ffn });
    }

    // ══════════════════════════════════════════════════════════════════════
    // RAW METADATA (reference, not parsed by custom graph)
    // ══════════════════════════════════════════════════════════════════════
    try out.appendSlice(allocator,
        \\# ── Raw GGUF Metadata (reference only) ──────────────────────────────
        \\# These are all key-value pairs from the model file. The custom graph
        \\# reads the structured sections above, not this block directly.
        \\metadata:
        \\
    );
    const n_kv = c.llama_model_meta_count(model);
    var key_buf: [512]u8 = undefined;
    var val_buf: [512]u8 = undefined;
    var mi: i32 = 0;
    while (mi < n_kv) : (mi += 1) {
        const kn = c.llama_model_meta_key_by_index(model, mi, &key_buf, key_buf.len);
        const vn = c.llama_model_meta_val_str_by_index(model, mi, &val_buf, val_buf.len);
        if (kn <= 0 or vn < 0) continue;
        const key = key_buf[0..@intCast(kn)];
        if (std.mem.startsWith(u8, key, "tokenizer.ggml.tokens") or
            std.mem.startsWith(u8, key, "tokenizer.ggml.scores") or
            std.mem.startsWith(u8, key, "tokenizer.ggml.token_type") or
            std.mem.startsWith(u8, key, "tokenizer.ggml.merges")) continue;
        const val_len = @min(@as(usize, @intCast(vn)), val_buf.len - 1);
        const val = val_buf[0..val_len];
        const nl = std.mem.indexOfScalar(u8, val, '\n');
        if (nl != null) {
            try w(&out, allocator, "  {s}: \"{s}...(multiline)\"\n", .{ key, val[0..nl.?] });
        } else {
            const needs_quote = std.mem.indexOfAny(u8, val, ":#[]{}|>&*!,'\"") != null;
            if (needs_quote) {
                try w(&out, allocator, "  {s}: \"{s}\"\n", .{ key, val });
            } else {
                try w(&out, allocator, "  {s}: {s}\n", .{ key, val });
            }
        }
    }
    try out.appendSlice(allocator, "\n");

    // ══════════════════════════════════════════════════════════════════════
    // PER-LAYER BLUEPRINT [editable]
    // ══════════════════════════════════════════════════════════════════════
    try out.appendSlice(allocator,
        \\# ── Per-Layer Blueprint [editable] ──────────────────────────────────
        \\# Each layer lists its components in execution order.
        \\# Available per-layer overrides:
        \\#   skip: true                        → remove this layer from the graph
        \\#   duplicate_of: N                   → reuse layer N's weights here
        \\#   component.type: gelu              → swap activation function
        \\#   component.skip: true              → remove one component (e.g. gate proj)
        \\#   component.weight_source: blk.N.X  → use a different layer's weight
        \\#   attention.sliding_window: 1024    → per-layer SWA override
        \\layers:
        \\
    );

    var li: i32 = 0;
    while (li < n_layer) : (li += 1) {
        try w(&out, allocator, "  - index: {d}\n", .{li});
        try w(&out, allocator, "    # skip: false\n", .{});
        try w(&out, allocator, "    # duplicate_of: null\n", .{});
        try w(&out, allocator, "    components:\n", .{});

        // attn_norm
        try w(&out, allocator,
            \\      - name: attn_norm
            \\        type: rms_norm
            \\        epsilon: {s}
            \\        input_shape: [{d}]
            \\
        , .{ if (eps.len > 0) eps else "1e-5", n_embd });

        // Q/K/V/O projections
        try w(&out, allocator,
            \\      - name: attn_q
            \\        type: linear
            \\        shape: [{d}, {d}]
            \\        # weight_source: blk.0.attn_q.weight
            \\      - name: attn_k
            \\        type: linear
            \\        shape: [{d}, {d}]
            \\      - name: attn_v
            \\        type: linear
            \\        shape: [{d}, {d}]
            \\      - name: attn_output
            \\        type: linear
            \\        shape: [{d}, {d}]
            \\
        , .{ n_embd, n_embd, n_embd, kv_dim, n_embd, kv_dim, n_embd, n_embd });

        // RoPE
        try w(&out, allocator,
            \\      - name: rope
            \\        type: rope
            \\        freq_base: {s}
            \\        freq_scale: {d:.4}
            \\        dim: {d}
            \\        # sliding_window: null
            \\
        , .{ if (rope_base.len > 0) rope_base else "10000", rope_scale, rope_dim });

        // ffn_norm
        try w(&out, allocator,
            \\      - name: ffn_norm
            \\        type: rms_norm
            \\        epsilon: {s}
            \\        input_shape: [{d}]
            \\
        , .{ if (eps.len > 0) eps else "1e-5", n_embd });

        if (is_moe) {
            // MoE router + experts
            try w(&out, allocator,
                \\      - name: ffn_router
                \\        type: moe_router
                \\        expert_count: {d}
                \\        expert_used_count: {d}   # edit this to use fewer/more experts
                \\        router_type: topk         # topk | softmax | random
                \\      - name: ffn_experts
                \\        type: moe_ffn
                \\        activation: {s}
                \\        ffn_type: {s}
                \\        expert_count: {d}
                \\
            , .{ exp_count, exp_used, act, ffn_type, exp_count });
            if (exp_shared_count > 0) {
                try w(&out, allocator,
                    \\      - name: ffn_shared_expert
                    \\        type: linear_ffn
                    \\        activation: {s}
                    \\        ffn_dim: {d}
                    \\        skip: false   # set true to disable shared expert
                    \\
                , .{ act, exp_shared_ffn });
            }
        } else if (ffn_dim > 0) {
            // Dense FFN
            try w(&out, allocator,
                \\      - name: ffn_gate
                \\        type: linear
                \\        shape: [{d}, {d}]
                \\      - name: ffn_up
                \\        type: linear
                \\        shape: [{d}, {d}]
                \\      - name: ffn_act
                \\        type: {s}        # change to: silu | gelu | relu | swiglu | geglu
                \\        inputs: [ffn_gate, ffn_up]
                \\      - name: ffn_down
                \\        type: linear
                \\        shape: [{d}, {d}]
                \\
            , .{ n_embd, ffn_dim, n_embd, ffn_dim, ffn_type, ffn_dim, n_embd });
        }
        try out.appendSlice(allocator, "\n");
    }

    return out.toOwnedSlice(allocator);
}

/// Parse a simple dotted-key YAML text into a flat key→value map.
pub fn parseOverrides(allocator: std.mem.Allocator, text: []const u8) !std.StringHashMap([]const u8) {
    var map = std.StringHashMap([]const u8).init(allocator);
    errdefer {
        var it = map.iterator();
        while (it.next()) |e| allocator.free(e.key_ptr.*);
        map.deinit();
    }

    var current_section: []const u8 = "";
    var lines = std.mem.splitScalar(u8, text, '\n');
    while (lines.next()) |line| {
        // Strip inline comment first
        const comment_pos = std.mem.indexOfScalar(u8, line, '#');
        const no_comment = if (comment_pos) |p| line[0..p] else line;
        const trimmed = std.mem.trim(u8, no_comment, " \t\r");
        if (trimmed.len == 0) continue;

        const colon = std.mem.indexOfScalar(u8, trimmed, ':') orelse continue;
        const key = std.mem.trim(u8, trimmed[0..colon], " \t");
        const val = std.mem.trim(u8, trimmed[colon + 1 ..], " \t");
        if (key.len == 0) continue;

        // Determine indent level
        var indent: usize = 0;
        while (indent < line.len and (line[indent] == ' ' or line[indent] == '\t')) indent += 1;

        if (indent == 0) {
            // Top-level key: could be a section header (val empty) or a plain key
            current_section = key;
            if (val.len > 0) {
                const key_copy = try allocator.dupe(u8, key);
                map.put(key_copy, val) catch allocator.free(key_copy);
            }
        } else {
            // Nested key: emit as "section.key"
            const full_key = try std.fmt.allocPrint(allocator, "{s}.{s}", .{ current_section, key });
            map.put(full_key, val) catch allocator.free(full_key);
        }
    }

    return map;
}
