const std = @import("std");

pub const MetaEntry = struct {
    gguf_key: []const u8,
    config_path: []const u8,
    kind: enum { u32, f32, bool, str },
    default: ?[]const u8 = null,
};

pub const TensorPattern = struct {
    hf: []const u8,
    gguf: []const u8,
};

pub const Arch = struct {
    hf_class: []const u8,
    gguf_arch: []const u8,
    config_prefix: []const u8,
    meta: []const MetaEntry,
    tensors: []const TensorPattern,
    tie_embeddings: bool = false,
};

// ── Gemma 4 ──────────────────────────────────────────────────────────────────

const gemma4_meta = &[_]MetaEntry{
    .{ .gguf_key = "gemma4.context_length", .config_path = "text_config.max_position_embeddings", .kind = .u32 },
    .{ .gguf_key = "gemma4.embedding_length", .config_path = "text_config.hidden_size", .kind = .u32 },
    .{ .gguf_key = "gemma4.block_count", .config_path = "text_config.num_hidden_layers", .kind = .u32 },
    .{ .gguf_key = "gemma4.attention.head_count", .config_path = "text_config.num_attention_heads", .kind = .u32 },
    .{ .gguf_key = "gemma4.attention.head_count_kv", .config_path = "text_config.num_key_value_heads", .kind = .u32 },
    .{ .gguf_key = "gemma4.attention.key_length", .config_path = "text_config.head_dim", .kind = .u32, .default = "256" },
    .{ .gguf_key = "gemma4.attention.sliding_window", .config_path = "text_config.sliding_window", .kind = .u32, .default = "512" },
    .{ .gguf_key = "gemma4.rope.freq_base", .config_path = "text_config.rope_theta", .kind = .f32, .default = "1000000" },
    .{ .gguf_key = "gemma4.attention.layer_norm_rms_epsilon", .config_path = "text_config.rms_norm_eps", .kind = .f32, .default = "1e-6" },
    .{ .gguf_key = "gemma4.feed_forward_length", .config_path = "text_config.intermediate_size", .kind = .u32 },
};

const gemma4_tensors = &[_]TensorPattern{
    .{ .hf = "model.language_model.embed_tokens.weight", .gguf = "token_embd.weight" },
    .{ .hf = "model.language_model.norm.weight", .gguf = "output_norm.weight" },
    .{ .hf = "model.layers.{N}.input_layernorm.weight", .gguf = "blk.{N}.attn_norm.weight" },
    .{ .hf = "model.layers.{N}.self_attn.q_proj.weight", .gguf = "blk.{N}.attn_q.weight" },
    .{ .hf = "model.layers.{N}.self_attn.k_proj.weight", .gguf = "blk.{N}.attn_k.weight" },
    .{ .hf = "model.layers.{N}.self_attn.v_proj.weight", .gguf = "blk.{N}.attn_v.weight" },
    .{ .hf = "model.layers.{N}.self_attn.o_proj.weight", .gguf = "blk.{N}.attn_output.weight" },
    .{ .hf = "model.layers.{N}.post_attention_layernorm.weight", .gguf = "blk.{N}.post_attention_norm.weight" },
    .{ .hf = "model.layers.{N}.pre_feedforward_layernorm.weight", .gguf = "blk.{N}.ffn_norm.weight" },
    .{ .hf = "model.layers.{N}.mlp.gate_proj.weight", .gguf = "blk.{N}.ffn_gate.weight" },
    .{ .hf = "model.layers.{N}.mlp.up_proj.weight", .gguf = "blk.{N}.ffn_up.weight" },
    .{ .hf = "model.layers.{N}.mlp.down_proj.weight", .gguf = "blk.{N}.ffn_down.weight" },
    .{ .hf = "model.layers.{N}.post_feedforward_layernorm.weight", .gguf = "blk.{N}.post_ffw_norm.weight" },
};

pub const gemma4: Arch = .{
    .hf_class = "Gemma4ForCausalLM",
    .gguf_arch = "gemma4",
    .config_prefix = "text_config",
    .meta = gemma4_meta,
    .tensors = gemma4_tensors,
};

// ── Llama 3 ──────────────────────────────────────────────────────────────────

const llama3_meta = &[_]MetaEntry{
    .{ .gguf_key = "llama.context_length", .config_path = "max_position_embeddings", .kind = .u32 },
    .{ .gguf_key = "llama.embedding_length", .config_path = "hidden_size", .kind = .u32 },
    .{ .gguf_key = "llama.block_count", .config_path = "num_hidden_layers", .kind = .u32 },
    .{ .gguf_key = "llama.attention.head_count", .config_path = "num_attention_heads", .kind = .u32 },
    .{ .gguf_key = "llama.attention.head_count_kv", .config_path = "num_key_value_heads", .kind = .u32 },
    .{ .gguf_key = "llama.attention.layer_norm_rms_epsilon", .config_path = "rms_norm_eps", .kind = .f32, .default = "1e-5" },
    .{ .gguf_key = "llama.rope.freq_base", .config_path = "rope_theta", .kind = .f32, .default = "500000" },
    .{ .gguf_key = "llama.feed_forward_length", .config_path = "intermediate_size", .kind = .u32 },
};

const llama3_tensors = &[_]TensorPattern{
    .{ .hf = "model.embed_tokens.weight", .gguf = "token_embd.weight" },
    .{ .hf = "model.norm.weight", .gguf = "output_norm.weight" },
    .{ .hf = "model.layers.{N}.input_layernorm.weight", .gguf = "blk.{N}.attn_norm.weight" },
    .{ .hf = "model.layers.{N}.self_attn.q_proj.weight", .gguf = "blk.{N}.attn_q.weight" },
    .{ .hf = "model.layers.{N}.self_attn.k_proj.weight", .gguf = "blk.{N}.attn_k.weight" },
    .{ .hf = "model.layers.{N}.self_attn.v_proj.weight", .gguf = "blk.{N}.attn_v.weight" },
    .{ .hf = "model.layers.{N}.self_attn.o_proj.weight", .gguf = "blk.{N}.attn_output.weight" },
    .{ .hf = "model.layers.{N}.post_attention_layernorm.weight", .gguf = "blk.{N}.ffn_norm.weight" },
    .{ .hf = "model.layers.{N}.mlp.gate_proj.weight", .gguf = "blk.{N}.ffn_gate.weight" },
    .{ .hf = "model.layers.{N}.mlp.up_proj.weight", .gguf = "blk.{N}.ffn_up.weight" },
    .{ .hf = "model.layers.{N}.mlp.down_proj.weight", .gguf = "blk.{N}.ffn_down.weight" },
};

pub const llama3: Arch = .{
    .hf_class = "LlamaForCausalLM",
    .gguf_arch = "llama",
    .config_prefix = "",
    .meta = llama3_meta,
    .tensors = llama3_tensors,
    .tie_embeddings = true,
};

// ── Qwen 3.5 ─────────────────────────────────────────────────────────────────
// Note: Qwen3.5 has hybrid linear + full attention layers. The tensor names
// differ between full-attention and linear-attention layers. For the fallback
// path (llama_decode), we only need to map the tensors that llama.cpp knows.
// The full Qwen3.5 Level 2 graph builder comes in Phase 1b+.

const qwen35_meta = &[_]MetaEntry{
    .{ .gguf_key = "qwen35.context_length", .config_path = "max_position_embeddings", .kind = .u32 },
    .{ .gguf_key = "qwen35.embedding_length", .config_path = "hidden_size", .kind = .u32 },
    .{ .gguf_key = "qwen35.block_count", .config_path = "num_hidden_layers", .kind = .u32 },
    .{ .gguf_key = "qwen35.attention.head_count", .config_path = "num_attention_heads", .kind = .u32 },
    .{ .gguf_key = "qwen35.attention.head_count_kv", .config_path = "num_key_value_heads", .kind = .u32 },
    .{ .gguf_key = "qwen35.attention.layer_norm_rms_epsilon", .config_path = "rms_norm_eps", .kind = .f32, .default = "1e-6" },
    .{ .gguf_key = "qwen35.rope.freq_base", .config_path = "rope_theta", .kind = .f32, .default = "1000000" },
    .{ .gguf_key = "qwen35.feed_forward_length", .config_path = "intermediate_size", .kind = .u32 },
};

const qwen35_tensors = &[_]TensorPattern{
    .{ .hf = "model.embed_tokens.weight", .gguf = "token_embd.weight" },
    .{ .hf = "model.norm.weight", .gguf = "output_norm.weight" },
    .{ .hf = "model.layers.{N}.input_layernorm.weight", .gguf = "blk.{N}.attn_norm.weight" },
    .{ .hf = "model.layers.{N}.self_attn.q_proj.weight", .gguf = "blk.{N}.attn_q.weight" },
    .{ .hf = "model.layers.{N}.self_attn.k_proj.weight", .gguf = "blk.{N}.attn_k.weight" },
    .{ .hf = "model.layers.{N}.self_attn.v_proj.weight", .gguf = "blk.{N}.attn_v.weight" },
    .{ .hf = "model.layers.{N}.self_attn.o_proj.weight", .gguf = "blk.{N}.attn_output.weight" },
    .{ .hf = "model.layers.{N}.post_attention_layernorm.weight", .gguf = "blk.{N}.ffn_norm.weight" },
    .{ .hf = "model.layers.{N}.mlp.gate_proj.weight", .gguf = "blk.{N}.ffn_gate.weight" },
    .{ .hf = "model.layers.{N}.mlp.up_proj.weight", .gguf = "blk.{N}.ffn_up.weight" },
    .{ .hf = "model.layers.{N}.mlp.down_proj.weight", .gguf = "blk.{N}.ffn_down.weight" },
};

pub const qwen35: Arch = .{
    .hf_class = "Qwen3_5ForCausalLM",
    .gguf_arch = "qwen35",
    .config_prefix = "",
    .meta = qwen35_meta,
    .tensors = qwen35_tensors,
};

// ── Arch dispatch ─────────────────────────────────────────────────────────────

pub const all_archs = &[_]Arch{
    gemma4,
    llama3,
    qwen35,
};

pub fn findArchByHfClass(hf_class: []const u8) ?*const Arch {
    for (all_archs) |*arch| {
        if (std.mem.eql(u8, arch.hf_class, hf_class)) return arch;
    }
    return null;
}

/// Expand a pattern like "model.layers.{N}.self_attn.q_proj.weight"
/// by replacing {N} with the layer index string.
pub fn expandPattern(allocator: std.mem.Allocator, pattern: []const u8, layer_num: u32) ![]const u8 {
    const marker = "{N}";
    if (std.mem.indexOf(u8, pattern, marker)) |_| {
        const num_str = try std.fmt.allocPrint(allocator, "{}", .{layer_num});
        return std.mem.replaceOwned(u8, allocator, pattern, marker, num_str);
    }
    return allocator.dupe(u8, pattern);
}

/// Try to match an HF tensor name against all tensor patterns for an arch.
/// Returns the GGUF name if matched, null otherwise.
pub fn matchTensorName(allocator: std.mem.Allocator, arch: *const Arch, hf_name: []const u8, n_layers: u32) ?[]const u8 {
    // First check non-layer patterns
    for (arch.tensors) |pattern| {
        if (std.mem.indexOf(u8, pattern.hf, "{N}") != null) continue;
        if (std.mem.eql(u8, pattern.hf, hf_name)) {
            return allocator.dupe(u8, pattern.gguf) catch return null;
        }
    }
    // Then check layer patterns
    for (arch.tensors) |pattern| {
        if (std.mem.indexOf(u8, pattern.hf, "{N}") == null) continue;
        var layer: u32 = 0;
        while (layer < n_layers) : (layer += 1) {
            const expanded = expandPattern(allocator, pattern.hf, layer) catch continue;
            defer allocator.free(expanded);
            if (std.mem.eql(u8, expanded, hf_name)) {
                const gguf_expanded = expandPattern(allocator, pattern.gguf, layer) catch return null;
                return gguf_expanded;
            }
        }
    }
    return null;
}
