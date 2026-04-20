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
    tokenizer_pre: ?[]const u8 = null,
};

// ── Gemma 4 ──────────────────────────────────────────────────────────────────

const gemma4_meta = &[_]MetaEntry{
    .{ .gguf_key = "gemma4.context_length", .config_path = "max_position_embeddings", .kind = .u32 },
    .{ .gguf_key = "gemma4.embedding_length", .config_path = "hidden_size", .kind = .u32 },
    .{ .gguf_key = "gemma4.block_count", .config_path = "num_hidden_layers", .kind = .u32 },
    .{ .gguf_key = "gemma4.attention.head_count", .config_path = "num_attention_heads", .kind = .u32 },
    .{ .gguf_key = "gemma4.attention.head_count_kv", .config_path = "num_key_value_heads", .kind = .u32 },
    .{ .gguf_key = "gemma4.attention.key_length", .config_path = "head_dim", .kind = .u32, .default = "256" },
    .{ .gguf_key = "gemma4.attention.sliding_window", .config_path = "sliding_window", .kind = .u32, .default = "512" },
    .{ .gguf_key = "gemma4.rope.freq_base", .config_path = "rope_theta", .kind = .f32, .default = "1000000" },
    .{ .gguf_key = "gemma4.attention.layer_norm_rms_epsilon", .config_path = "rms_norm_eps", .kind = .f32, .default = "1e-6" },
    .{ .gguf_key = "gemma4.feed_forward_length", .config_path = "intermediate_size", .kind = .u32 },
};

const gemma4_tensors = &[_]TensorPattern{
    .{ .hf = "model.language_model.embed_tokens.weight", .gguf = "token_embd.weight" },
    .{ .hf = "model.embed_tokens.weight", .gguf = "token_embd.weight" },
    .{ .hf = "model.language_model.norm.weight", .gguf = "output_norm.weight" },
    .{ .hf = "model.norm.weight", .gguf = "output_norm.weight" },
    .{ .hf = "model.language_model.layers.{N}.input_layernorm.weight", .gguf = "blk.{N}.attn_norm.weight" },
    .{ .hf = "model.layers.{N}.input_layernorm.weight", .gguf = "blk.{N}.attn_norm.weight" },
    .{ .hf = "model.language_model.layers.{N}.self_attn.q_proj.weight", .gguf = "blk.{N}.attn_q.weight" },
    .{ .hf = "model.layers.{N}.self_attn.q_proj.weight", .gguf = "blk.{N}.attn_q.weight" },
    .{ .hf = "model.language_model.layers.{N}.self_attn.k_proj.weight", .gguf = "blk.{N}.attn_k.weight" },
    .{ .hf = "model.layers.{N}.self_attn.k_proj.weight", .gguf = "blk.{N}.attn_k.weight" },
    .{ .hf = "model.language_model.layers.{N}.self_attn.v_proj.weight", .gguf = "blk.{N}.attn_v.weight" },
    .{ .hf = "model.layers.{N}.self_attn.v_proj.weight", .gguf = "blk.{N}.attn_v.weight" },
    .{ .hf = "model.language_model.layers.{N}.self_attn.o_proj.weight", .gguf = "blk.{N}.attn_output.weight" },
    .{ .hf = "model.layers.{N}.self_attn.o_proj.weight", .gguf = "blk.{N}.attn_output.weight" },
    .{ .hf = "model.language_model.layers.{N}.post_attention_layernorm.weight", .gguf = "blk.{N}.post_attention_norm.weight" },
    .{ .hf = "model.layers.{N}.post_attention_layernorm.weight", .gguf = "blk.{N}.post_attention_norm.weight" },
    .{ .hf = "model.language_model.layers.{N}.pre_feedforward_layernorm.weight", .gguf = "blk.{N}.ffn_norm.weight" },
    .{ .hf = "model.layers.{N}.pre_feedforward_layernorm.weight", .gguf = "blk.{N}.ffn_norm.weight" },
    .{ .hf = "model.language_model.layers.{N}.mlp.gate_proj.weight", .gguf = "blk.{N}.ffn_gate.weight" },
    .{ .hf = "model.layers.{N}.mlp.gate_proj.weight", .gguf = "blk.{N}.ffn_gate.weight" },
    .{ .hf = "model.language_model.layers.{N}.mlp.up_proj.weight", .gguf = "blk.{N}.ffn_up.weight" },
    .{ .hf = "model.layers.{N}.mlp.up_proj.weight", .gguf = "blk.{N}.ffn_up.weight" },
    .{ .hf = "model.language_model.layers.{N}.mlp.down_proj.weight", .gguf = "blk.{N}.ffn_down.weight" },
    .{ .hf = "model.layers.{N}.mlp.down_proj.weight", .gguf = "blk.{N}.ffn_down.weight" },
    .{ .hf = "model.language_model.layers.{N}.post_feedforward_layernorm.weight", .gguf = "blk.{N}.post_ffw_norm.weight" },
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
    .{ .gguf_key = "qwen35.attention.key_length", .config_path = "head_dim", .kind = .u32, .default = "256" },
    .{ .gguf_key = "qwen35.attention.value_length", .config_path = "head_dim", .kind = .u32, .default = "256" },
    .{ .gguf_key = "qwen35.ssm.conv_kernel", .config_path = "linear_conv_kernel_dim", .kind = .u32, .default = "4" },
    .{ .gguf_key = "qwen35.ssm.state_size", .config_path = "linear_key_head_dim", .kind = .u32, .default = "128" },
    .{ .gguf_key = "qwen35.ssm.group_count", .config_path = "linear_num_key_heads", .kind = .u32, .default = "16" },
    .{ .gguf_key = "qwen35.ssm.time_step_rank", .config_path = "linear_num_value_heads", .kind = .u32, .default = "32" },
    .{ .gguf_key = "qwen35.ssm.inner_size", .config_path = "linear_inner_size", .kind = .u32, .default = "4096" },
    .{ .gguf_key = "qwen35.full_attention_interval", .config_path = "full_attention_interval", .kind = .u32, .default = "4" },
    .{ .gguf_key = "qwen35.rope.dimension_count", .config_path = "rope_dimension_count", .kind = .u32, .default = "64" },
};

const qwen35_tensors = &[_]TensorPattern{
    // Decoder-only aliases
    .{ .hf = "model.embed_tokens.weight", .gguf = "token_embd.weight" },
    .{ .hf = "model.norm.weight", .gguf = "output_norm.weight" },
    // Multimodal checkpoints expose language model under model.language_model.*
    .{ .hf = "model.language_model.embed_tokens.weight", .gguf = "token_embd.weight" },
    .{ .hf = "model.language_model.norm.weight", .gguf = "output_norm.weight" },
    // Full-attention layers
    .{ .hf = "model.language_model.layers.{N}.input_layernorm.weight", .gguf = "blk.{N}.attn_norm.weight" },
    .{ .hf = "model.layers.{N}.input_layernorm.weight", .gguf = "blk.{N}.attn_norm.weight" },
    .{ .hf = "model.language_model.layers.{N}.self_attn.q_proj.weight", .gguf = "blk.{N}.attn_q.weight" },
    .{ .hf = "model.layers.{N}.self_attn.q_proj.weight", .gguf = "blk.{N}.attn_q.weight" },
    .{ .hf = "model.language_model.layers.{N}.self_attn.k_proj.weight", .gguf = "blk.{N}.attn_k.weight" },
    .{ .hf = "model.layers.{N}.self_attn.k_proj.weight", .gguf = "blk.{N}.attn_k.weight" },
    .{ .hf = "model.language_model.layers.{N}.self_attn.v_proj.weight", .gguf = "blk.{N}.attn_v.weight" },
    .{ .hf = "model.layers.{N}.self_attn.v_proj.weight", .gguf = "blk.{N}.attn_v.weight" },
    .{ .hf = "model.language_model.layers.{N}.self_attn.o_proj.weight", .gguf = "blk.{N}.attn_output.weight" },
    .{ .hf = "model.layers.{N}.self_attn.o_proj.weight", .gguf = "blk.{N}.attn_output.weight" },
    .{ .hf = "model.language_model.layers.{N}.self_attn.q_layernorm.weight", .gguf = "blk.{N}.attn_q_norm.weight" },
    .{ .hf = "model.language_model.layers.{N}.self_attn.k_layernorm.weight", .gguf = "blk.{N}.attn_k_norm.weight" },
    .{ .hf = "model.language_model.layers.{N}.post_attention_layernorm.weight", .gguf = "blk.{N}.post_attention_norm.weight" },
    .{ .hf = "model.layers.{N}.post_attention_layernorm.weight", .gguf = "blk.{N}.ffn_norm.weight" },
    // Linear-attention (SSM) layers in Qwen3.5 hybrid
    .{ .hf = "model.language_model.layers.{N}.linear_attn.in_proj_qkv.weight", .gguf = "blk.{N}.attn_qkv.weight" },
    .{ .hf = "model.language_model.layers.{N}.linear_attn.in_proj_z.weight", .gguf = "blk.{N}.attn_gate.weight" },
    .{ .hf = "model.language_model.layers.{N}.linear_attn.in_proj_a.weight", .gguf = "blk.{N}.ssm_alpha.weight" },
    .{ .hf = "model.language_model.layers.{N}.linear_attn.in_proj_b.weight", .gguf = "blk.{N}.ssm_beta.weight" },
    .{ .hf = "model.language_model.layers.{N}.linear_attn.conv1d.weight", .gguf = "blk.{N}.ssm_conv1d.weight" },
    .{ .hf = "model.language_model.layers.{N}.linear_attn.dt_bias", .gguf = "blk.{N}.ssm_dt.bias" },
    .{ .hf = "model.language_model.layers.{N}.linear_attn.norm.weight", .gguf = "blk.{N}.ssm_norm.weight" },
    .{ .hf = "model.language_model.layers.{N}.linear_attn.out_proj.weight", .gguf = "blk.{N}.ssm_out.weight" },
    .{ .hf = "model.language_model.layers.{N}.linear_attn.A_log", .gguf = "blk.{N}.ssm_a" },
    // FFN
    .{ .hf = "model.language_model.layers.{N}.mlp.gate_proj.weight", .gguf = "blk.{N}.ffn_gate.weight" },
    .{ .hf = "model.layers.{N}.mlp.gate_proj.weight", .gguf = "blk.{N}.ffn_gate.weight" },
    .{ .hf = "model.language_model.layers.{N}.mlp.up_proj.weight", .gguf = "blk.{N}.ffn_up.weight" },
    .{ .hf = "model.layers.{N}.mlp.up_proj.weight", .gguf = "blk.{N}.ffn_up.weight" },
    .{ .hf = "model.language_model.layers.{N}.mlp.down_proj.weight", .gguf = "blk.{N}.ffn_down.weight" },
    .{ .hf = "model.layers.{N}.mlp.down_proj.weight", .gguf = "blk.{N}.ffn_down.weight" },
};

pub const qwen35: Arch = .{
    .hf_class = "Qwen3_5ForCausalLM",
    .gguf_arch = "qwen35",
    .config_prefix = "text_config",
    .meta = qwen35_meta,
    .tensors = qwen35_tensors,
};

// ── LFM2 ────────────────────────────────────────────────────────────────────

const lfm2_meta = &[_]MetaEntry{
    .{ .gguf_key = "lfm2.context_length", .config_path = "max_position_embeddings", .kind = .u32 },
    .{ .gguf_key = "lfm2.embedding_length", .config_path = "hidden_size", .kind = .u32 },
    .{ .gguf_key = "lfm2.block_count", .config_path = "num_hidden_layers", .kind = .u32 },
    .{ .gguf_key = "lfm2.feed_forward_length", .config_path = "intermediate_size", .kind = .u32 },
    .{ .gguf_key = "lfm2.attention.head_count", .config_path = "num_attention_heads", .kind = .u32 },
    .{ .gguf_key = "lfm2.attention.head_count_kv", .config_path = "num_key_value_heads", .kind = .u32 },
    .{ .gguf_key = "lfm2.rope.freq_base", .config_path = "rope_theta", .kind = .f32, .default = "1000000" },
    .{ .gguf_key = "lfm2.attention.layer_norm_rms_epsilon", .config_path = "norm_eps", .kind = .f32, .default = "1e-5" },
    .{ .gguf_key = "lfm2.vocab_size", .config_path = "vocab_size", .kind = .u32 },
    .{ .gguf_key = "lfm2.shortconv.l_cache", .config_path = "conv_L_cache", .kind = .u32, .default = "3" },
};

const lfm2_tensors = &[_]TensorPattern{
    .{ .hf = "model.embed_tokens.weight", .gguf = "token_embd.weight" },
    .{ .hf = "model.embedding_norm.weight", .gguf = "token_embd_norm.weight" },
    .{ .hf = "model.layers.{N}.operator_norm.weight", .gguf = "blk.{N}.attn_norm.weight" },
    .{ .hf = "model.layers.{N}.ffn_norm.weight", .gguf = "blk.{N}.ffn_norm.weight" },
    .{ .hf = "model.layers.{N}.feed_forward.w1.weight", .gguf = "blk.{N}.ffn_gate.weight" },
    .{ .hf = "model.layers.{N}.feed_forward.w2.weight", .gguf = "blk.{N}.ffn_down.weight" },
    .{ .hf = "model.layers.{N}.feed_forward.w3.weight", .gguf = "blk.{N}.ffn_up.weight" },
    .{ .hf = "model.layers.{N}.conv.conv.weight", .gguf = "blk.{N}.shortconv.conv.weight" },
    .{ .hf = "model.layers.{N}.conv.in_proj.weight", .gguf = "blk.{N}.shortconv.in_proj.weight" },
    .{ .hf = "model.layers.{N}.conv.out_proj.weight", .gguf = "blk.{N}.shortconv.out_proj.weight" },
    .{ .hf = "model.layers.{N}.self_attn.q_proj.weight", .gguf = "blk.{N}.attn_q.weight" },
    .{ .hf = "model.layers.{N}.self_attn.k_proj.weight", .gguf = "blk.{N}.attn_k.weight" },
    .{ .hf = "model.layers.{N}.self_attn.v_proj.weight", .gguf = "blk.{N}.attn_v.weight" },
    .{ .hf = "model.layers.{N}.self_attn.out_proj.weight", .gguf = "blk.{N}.attn_output.weight" },
    .{ .hf = "model.layers.{N}.self_attn.q_layernorm.weight", .gguf = "blk.{N}.attn_q_norm.weight" },
    .{ .hf = "model.layers.{N}.self_attn.k_layernorm.weight", .gguf = "blk.{N}.attn_k_norm.weight" },
};

pub const lfm2: Arch = .{
    .hf_class = "Lfm2ForCausalLM",
    .gguf_arch = "lfm2",
    .config_prefix = "",
    .meta = lfm2_meta,
    .tensors = lfm2_tensors,
    .tie_embeddings = true,
};

// ── DeepSeek2 / GLM-4.7 Flash ───────────────────────────────────────────────

const deepseek2_meta = &[_]MetaEntry{
    .{ .gguf_key = "deepseek2.context_length", .config_path = "max_position_embeddings", .kind = .u32 },
    .{ .gguf_key = "deepseek2.embedding_length", .config_path = "hidden_size", .kind = .u32 },
    .{ .gguf_key = "deepseek2.block_count", .config_path = "num_hidden_layers", .kind = .u32 },
    .{ .gguf_key = "deepseek2.attention.head_count", .config_path = "num_attention_heads", .kind = .u32 },
    .{ .gguf_key = "deepseek2.attention.head_count_kv", .config_path = "n_group", .kind = .u32, .default = "1" },
    .{ .gguf_key = "deepseek2.attention.layer_norm_rms_epsilon", .config_path = "rms_norm_eps", .kind = .f32, .default = "1e-6" },
    .{ .gguf_key = "deepseek2.attention.q_lora_rank", .config_path = "q_lora_rank", .kind = .u32 },
    .{ .gguf_key = "deepseek2.attention.kv_lora_rank", .config_path = "kv_lora_rank", .kind = .u32 },
    .{ .gguf_key = "deepseek2.attention.key_length", .config_path = "qk_rope_head_dim", .kind = .u32 },
    .{ .gguf_key = "deepseek2.attention.value_length", .config_path = "kv_lora_rank", .kind = .u32 },
    .{ .gguf_key = "deepseek2.attention.key_length_mla", .config_path = "qk_head_dim", .kind = .u32 },
    .{ .gguf_key = "deepseek2.attention.value_length_mla", .config_path = "v_head_dim", .kind = .u32 },
    .{ .gguf_key = "deepseek2.rope.dimension_count", .config_path = "qk_rope_head_dim", .kind = .u32 },
    .{ .gguf_key = "deepseek2.feed_forward_length", .config_path = "intermediate_size", .kind = .u32 },
    .{ .gguf_key = "deepseek2.expert_feed_forward_length", .config_path = "moe_intermediate_size", .kind = .u32 },
    .{ .gguf_key = "deepseek2.expert_count", .config_path = "n_routed_experts", .kind = .u32 },
    .{ .gguf_key = "deepseek2.expert_used_count", .config_path = "num_experts_per_tok", .kind = .u32 },
    .{ .gguf_key = "deepseek2.expert_shared_count", .config_path = "n_shared_experts", .kind = .u32, .default = "0" },
    .{ .gguf_key = "deepseek2.leading_dense_block_count", .config_path = "first_k_dense_replace", .kind = .u32, .default = "0" },
    .{ .gguf_key = "deepseek2.expert_weights_scale", .config_path = "routed_scaling_factor", .kind = .f32, .default = "1.0" },
    .{ .gguf_key = "deepseek2.expert_weights_norm", .config_path = "norm_topk_prob", .kind = .bool },
    .{ .gguf_key = "deepseek2.vocab_size", .config_path = "vocab_size", .kind = .u32 },
};

const deepseek2_tensors = &[_]TensorPattern{
    .{ .hf = "model.embed_tokens.weight", .gguf = "token_embd.weight" },
    .{ .hf = "model.norm.weight", .gguf = "output_norm.weight" },
    .{ .hf = "lm_head.weight", .gguf = "output.weight" },
    .{ .hf = "model.layers.{N}.input_layernorm.weight", .gguf = "blk.{N}.attn_norm.weight" },
    .{ .hf = "model.layers.{N}.self_attn.q_a_proj.weight", .gguf = "blk.{N}.attn_q_a.weight" },
    .{ .hf = "model.layers.{N}.self_attn.q_b_proj.weight", .gguf = "blk.{N}.attn_q_b.weight" },
    .{ .hf = "model.layers.{N}.self_attn.q_a_layernorm.weight", .gguf = "blk.{N}.attn_q_a_norm.weight" },
    .{ .hf = "model.layers.{N}.self_attn.kv_a_proj_with_mqa.weight", .gguf = "blk.{N}.attn_kv_a_mqa.weight" },
    .{ .hf = "model.layers.{N}.self_attn.kv_a_layernorm.weight", .gguf = "blk.{N}.attn_kv_a_norm.weight" },
    .{ .hf = "model.layers.{N}.self_attn.o_proj.weight", .gguf = "blk.{N}.attn_output.weight" },
    .{ .hf = "model.layers.{N}.post_attention_layernorm.weight", .gguf = "blk.{N}.ffn_norm.weight" },
    .{ .hf = "model.layers.{N}.mlp.gate_proj.weight", .gguf = "blk.{N}.ffn_gate.weight" },
    .{ .hf = "model.layers.{N}.mlp.up_proj.weight", .gguf = "blk.{N}.ffn_up.weight" },
    .{ .hf = "model.layers.{N}.mlp.down_proj.weight", .gguf = "blk.{N}.ffn_down.weight" },
    .{ .hf = "model.layers.{N}.mlp.gate.weight", .gguf = "blk.{N}.ffn_gate_inp.weight" },
    .{ .hf = "model.layers.{N}.mlp.gate.e_score_correction_bias", .gguf = "blk.{N}.exp_probs_b.bias" },
    .{ .hf = "model.layers.{N}.mlp.shared_experts.gate_proj.weight", .gguf = "blk.{N}.ffn_gate_shexp.weight" },
    .{ .hf = "model.layers.{N}.mlp.shared_experts.up_proj.weight", .gguf = "blk.{N}.ffn_up_shexp.weight" },
    .{ .hf = "model.layers.{N}.mlp.shared_experts.down_proj.weight", .gguf = "blk.{N}.ffn_down_shexp.weight" },
    .{ .hf = "model.layers.{N}.mlp.experts.gate_proj.weight", .gguf = "blk.{N}.ffn_gate_exps.weight" },
    .{ .hf = "model.layers.{N}.mlp.experts.up_proj.weight", .gguf = "blk.{N}.ffn_up_exps.weight" },
    .{ .hf = "model.layers.{N}.mlp.experts.down_proj.weight", .gguf = "blk.{N}.ffn_down_exps.weight" },
    .{ .hf = "model.layers.{N}.self_attn.k_b_proj.weight", .gguf = "blk.{N}.attn_k_b.weight" },
    .{ .hf = "model.layers.{N}.self_attn.v_b_proj.weight", .gguf = "blk.{N}.attn_v_b.weight" },
};

pub const deepseek2_glm4_moe_lite: Arch = .{
    .hf_class = "Glm4MoeLiteForCausalLM",
    .gguf_arch = "deepseek2",
    .config_prefix = "",
    .meta = deepseek2_meta,
    .tensors = deepseek2_tensors,
    .tokenizer_pre = "glm4",
};

// ── Arch dispatch ─────────────────────────────────────────────────────────────

pub const all_archs = &[_]Arch{
    gemma4,
    llama3,
    qwen35,
    lfm2,
    deepseek2_glm4_moe_lite,
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
        const marker = "{N}";
        const idx = std.mem.indexOf(u8, pattern.hf, marker).?;
        const prefix = pattern.hf[0..idx];
        const suffix = pattern.hf[idx + marker.len ..];
        if (!std.mem.startsWith(u8, hf_name, prefix)) continue;
        if (!std.mem.endsWith(u8, hf_name, suffix)) continue;
        const middle = hf_name[prefix.len .. hf_name.len - suffix.len];
        const layer = std.fmt.parseInt(u32, middle, 10) catch continue;
        if (layer >= n_layers) continue;
        const gguf_expanded = expandPattern(allocator, pattern.gguf, layer) catch return null;
        return gguf_expanded;
    }
    return null;
}

test "matchTensorName skips tensors beyond configured block count" {
    const allocator = std.testing.allocator;
    try std.testing.expect(matchTensorName(allocator, &deepseek2_glm4_moe_lite, "model.layers.47.self_attn.q_a_proj.weight", 47) == null);
}
