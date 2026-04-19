//! ASCII block diagram renderer for model architecture inspection.

const std = @import("std");
const c = @import("../llama.zig").c;

fn metaStr(model: *const c.llama_model, key: [*:0]const u8, buf: []u8) []const u8 {
    const n = c.llama_model_meta_val_str(model, key, buf.ptr, buf.len);
    if (n >= 0 and @as(usize, @intCast(n)) < buf.len) return buf[0..@intCast(n)];
    return "";
}

/// Append a formatted string to out. Uses a 4KB temp buffer — lines longer than that are truncated.
fn fmt(out: *std.ArrayList(u8), comptime f: []const u8, args: anytype) !void {
    var tmp: [4096]u8 = undefined;
    const s = std.fmt.bufPrint(&tmp, f, args) catch return;
    try out.appendSlice(out.allocator, s);
}

pub fn render(allocator: std.mem.Allocator, model: *const c.llama_model) ![]u8 {
    var out = std.ArrayList(u8).empty;
    errdefer out.deinit(allocator);

    var tmp: [256]u8 = undefined;

    // ── Header ──
    const desc_n = c.llama_model_desc(model, &tmp, tmp.len);
    const desc = if (desc_n >= 0) tmp[0..@intCast(desc_n)] else "unknown";

    const n_params = c.llama_model_n_params(model);
    const model_size = c.llama_model_size(model);
    const arch = metaStr(model, "general.architecture", &tmp);

    const params_b = @as(f64, @floatFromInt(n_params)) / 1e9;
    const size_gb = @as(f64, @floatFromInt(model_size)) / (1024.0 * 1024.0 * 1024.0);

    try fmt(&out, "┌─ {s} ──────────────────────────────────────────┐\n", .{desc});
    try fmt(&out, "│ arch: {s} | params: {d:.1}B | size: {d:.1} GB", .{ arch, params_b, size_gb });
    try padTo(&out, 56);
    try out.appendSlice(allocator, "│\n");

    // ── Dimensions ──
    const n_embd = c.llama_model_n_embd(model);
    const n_layer = c.llama_model_n_layer(model);
    const n_head = c.llama_model_n_head(model);
    const n_head_kv = c.llama_model_n_head_kv(model);
    const n_embd_out = c.llama_model_n_embd_out(model);
    const head_dim: i32 = if (n_head > 0) n_embd / n_head else 0;
    try fmt(&out, "│ embd: {d} | layers: {d} | heads: {d} | kv: {d} | dim: {d}", .{ n_embd, n_layer, n_head, n_head_kv, head_dim });
    try padTo(&out, 56);
    try out.appendSlice(allocator, "│\n");

    // ── Read arch-specific metadata ──
    var rope_buf: [64]u8 = undefined;
    const rope_base = metaStr(model, "llama.rope.freq_base", &rope_buf);
    const rope_scale = c.llama_model_rope_freq_scale_train(model);
    var eps_buf: [64]u8 = undefined;
    const eps = metaStr(model, "llama.attention.layer_norm_rms_epsilon", &eps_buf);
    var ffn_buf: [64]u8 = undefined;
    const ffn_dim = metaStr(model, "llama.feed_forward_length", &ffn_buf);

    if (std.mem.eql(u8, arch, "gemma4")) {
        try renderGemma4(allocator, &out, n_embd, n_layer, n_head, n_head_kv, eps, rope_base, rope_scale, ffn_dim);
    } else if (std.mem.eql(u8, arch, "qwen35")) {
        try renderQwen35(allocator, &out, model, n_embd, n_layer, n_head, n_head_kv, eps, rope_base, rope_scale, ffn_dim);
    } else {
        try renderLlamaFamily(allocator, &out, model, n_embd, n_embd_out, n_layer, n_head, n_head_kv, eps, rope_base, rope_scale, ffn_dim, arch);
    }

    return out.toOwnedSlice(allocator);
}

fn renderLlamaFamily(
    allocator: std.mem.Allocator,
    out: *std.ArrayList(u8),
    model: *const c.llama_model,
    n_embd: i32,
    n_embd_out: i32,
    n_layer: i32,
    n_head: i32,
    n_head_kv: i32,
    eps: []const u8,
    rope_base: []const u8,
    rope_scale: f32,
    ffn_dim: []const u8,
    arch: []const u8,
) !void {
    _ = arch;

    try out.appendSlice(allocator, "│ ");
    if (rope_base.len > 0) {
        try fmt(out, "rope: base={s} scale={d:.1}", .{ rope_base, rope_scale });
    }
    try fmt(out, " | norm: rms(ε={s}) | act: silu", .{if (eps.len > 0) eps else "?"});
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");

    if (ffn_dim.len > 0) {
        try fmt(out, "│ ffn: {s} (SwiGLU: gate + up → silu → down)", .{ffn_dim});
    } else {
        try out.appendSlice(allocator, "│ ffn: (SwiGLU: gate + up → silu → down)");
    }
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");

    try out.appendSlice(allocator, "├────────────────────────────────────────────────────────┤\n");

    var vocab_buf: [64]u8 = undefined;
    const vocab_model = metaStr(model, "tokenizer.ggml.model", &vocab_buf);
    try fmt(out, "│ [tok_embd]  {d} × {d}", .{ n_embd, n_embd });
    if (vocab_model.len > 0) try fmt(out, "  vocab: {s}", .{vocab_model});
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");

    try out.appendSlice(allocator, "│     │                                                  │\n");

    const gqa = n_head_kv > 0 and n_head_kv < n_head;
    if (n_layer > 1) {
        try fmt(out, "│ {d:>2}..{d:>2} × ", .{ 0, n_layer - 1 });
    } else {
        try out.appendSlice(allocator, "│  0   × ");
    }
    try out.appendSlice(allocator, "[attn_norm → Q/K/V → RoPE");
    if (gqa) try fmt(out, " (GQA {d}H/{d}KV)", .{ n_head, n_head_kv });
    try out.appendSlice(allocator, " → o_proj]");
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");

    try out.appendSlice(allocator, "│           [ffn_norm → gate/up → SiLU·up → down]");
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");

    try out.appendSlice(allocator, "│     │                                                  │\n");

    try fmt(out, "│ [output_norm]  {d}", .{n_embd});
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");

    if (n_embd_out > 0 and n_embd_out != n_embd) {
        try fmt(out, "│ [output]  {d} × {d}", .{ n_embd, n_embd_out });
    } else {
        try fmt(out, "│ [output]  {d} × vocab (tied: tok_embd)", .{n_embd});
    }
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");

    try out.appendSlice(allocator, "└────────────────────────────────────────────────────────┘\n");
}

fn renderGemma4(
    allocator: std.mem.Allocator,
    out: *std.ArrayList(u8),
    n_embd: i32,
    n_layer: i32,
    n_head: i32,
    n_head_kv: i32,
    eps: []const u8,
    rope_base: []const u8,
    rope_scale: f32,
    ffn_dim: []const u8,
) !void {
    try out.appendSlice(allocator, "│ gemma4: softcap attn + per-layer embed + SWA interleaved");
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");

    try fmt(out, "│ rope: base={s} scale={d:.1} | norm: rms(ε={s})", .{ rope_base, rope_scale, if (eps.len > 0) eps else "?" });
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");

    if (ffn_dim.len > 0) {
        try fmt(out, "│ ffn: {s} (GeGLU: gate → gelu · up → down)", .{ffn_dim});
    }
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");

    try out.appendSlice(allocator, "├────────────────────────────────────────────────────────┤\n");
    try fmt(out, "│ [tok_embd]  {d} × {d}  (scaled by sqrt({d}))", .{ n_embd, n_embd, n_embd });
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");
    try out.appendSlice(allocator, "│     │                                                  │\n");

    const gqa = n_head_kv > 0 and n_head_kv < n_head;
    try fmt(out, "│ {d:>2} layers × ", .{n_layer});
    try out.appendSlice(allocator, "[attn_norm → Q/K/V → RoPE");
    if (gqa) try fmt(out, " GQA({d}/{d})", .{ n_head, n_head_kv });
    try out.appendSlice(allocator, " → o_proj + resid]");
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");

    try out.appendSlice(allocator, "│           [ffn_norm → gate → gelu·up → down + resid]");
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");
    try out.appendSlice(allocator, "│     │                                                  │\n");
    try fmt(out, "│ [output_norm]  {d}  →  [output]  {d} × vocab", .{ n_embd, n_embd });
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");
    try out.appendSlice(allocator, "└────────────────────────────────────────────────────────┘\n");
}

fn renderQwen35(
    allocator: std.mem.Allocator,
    out: *std.ArrayList(u8),
    model: *const c.llama_model,
    n_embd: i32,
    n_layer: i32,
    n_head: i32,
    n_head_kv: i32,
    eps: []const u8,
    rope_base: []const u8,
    rope_scale: f32,
    ffn_dim: []const u8,
) !void {
    var tmp: [64]u8 = undefined;
    const moe_layers = metaStr(model, "qwen35.attention.dense_layers", &tmp);

    try out.appendSlice(allocator, "│ qwen35: hybrid dense/MoE layers");
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");

    try fmt(out, "│ rope: base={s} scale={d:.1} | norm: rms(ε={s}) | act: silu", .{ rope_base, rope_scale, if (eps.len > 0) eps else "?" });
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");

    if (ffn_dim.len > 0) {
        try fmt(out, "│ ffn: {s} (SwiGLU)", .{ffn_dim});
    }
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");

    try out.appendSlice(allocator, "├────────────────────────────────────────────────────────┤\n");
    try fmt(out, "│ [tok_embd]  {d}", .{n_embd});
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");
    try out.appendSlice(allocator, "│     │                                                  │\n");

    const gqa = n_head_kv > 0 and n_head_kv < n_head;
    try fmt(out, "│ {d:>2} layers × ", .{n_layer});
    try out.appendSlice(allocator, "[attn_norm → Q/K/V → RoPE");
    if (gqa) try fmt(out, " GQA({d}/{d})", .{ n_head, n_head_kv });
    try out.appendSlice(allocator, "]");
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");

    if (moe_layers.len > 0) {
        try fmt(out, "│   dense: layers [{s}] → SwiGLU FFN", .{moe_layers});
        try padTo(out, 56);
        try out.appendSlice(allocator, "│\n");
        try out.appendSlice(allocator, "│   MoE:   other layers → routed expert FFN");
        try padTo(out, 56);
        try out.appendSlice(allocator, "│\n");
    }

    try out.appendSlice(allocator, "│     │                                                  │\n");
    try fmt(out, "│ [output_norm]  {d}  →  [output]", .{n_embd});
    try padTo(out, 56);
    try out.appendSlice(allocator, "│\n");
    try out.appendSlice(allocator, "└────────────────────────────────────────────────────────┘\n");
}

fn padTo(out: *std.ArrayList(u8), target: usize) !void {
    const visible = visibleLen(out.items);
    if (visible < target) {
        const pad = target - visible;
        var buf: [64]u8 = undefined;
        @memset(buf[0..@min(pad, buf.len)], ' ');
        var remaining = pad;
        while (remaining > 0) {
            const chunk = @min(remaining, buf.len);
            try out.appendSlice(out.allocator, buf[0..chunk]);
            remaining -= chunk;
        }
    }
}

fn visibleLen(s: []const u8) usize {
    var len: usize = 0;
    var i: usize = 0;
    while (i < s.len) {
        if (s[i] == '\x1b') {
            i += 1;
            if (i < s.len and s[i] == '[') {
                i += 1;
                while (i < s.len and s[i] != 'm' and s[i] != 'H' and s[i] != 'J' and s[i] != 'K') : (i += 1) {}
                if (i < s.len) i += 1;
            } else {
                if (i < s.len) i += 1;
            }
        } else if (s[i] == '\n') {
            len = 0;
            i += 1;
        } else {
            len += 1;
            if (s[i] < 0x80) {
                i += 1;
            } else {
                i += 1;
                while (i < s.len and s[i] & 0xC0 == 0x80) : (i += 1) {}
            }
        }
    }
    return len;
}
