# zllm2 — Source of Truth

**Created**: 2026-04-18  
**Author**: Ahmed Morsi  
**Status**: Planning  
**Stack**: Zig 0.16.0-dev · llama.cpp C API (no source changes) · vendored/ported zigzag · CUDA via ggml

---

## 1. What Is zllm2

A single self-contained binary for local LLM inference that:

- Loads **any HF safetensors or GGUF model** — no conversion, no Python, no intermediate files
- **Quantizes on the fly** during loading (BF16 → F16 / Q4_K_M / Q8_0 etc.)
- Runs an **interactive TUI chat** in the terminal with markdown rendering and command palette
- Exposes an **OpenAI-compatible HTTP API** (`/v1/chat/completions`)
- Supports **DFlash speculative decoding** (3–3.5× throughput via block-diffusion draft)
- Lets users **inspect, edit, and save** model architectures as YAML + GGUF
- Runs **benchmark suites** (HumanEval, GSM8K, Math500) from config files
- Integrates **web search** and **bash** as callable tools during inference
- **Loads models in seconds** via mmap + CPU-side embeddings (same technique as dflash)
- **Lazy loading in TUI** — model is never loaded until user explicitly runs `/load`; set model path and dtype first
- **Streaming quantization** — quantizes layer by layer with one row in RAM at a time; never loads full model into system RAM
- **Live inference stats** — prefill tok/s, generate tok/s, VRAM used/total, RAM, ctx fill shown in status bar every token

Target platforms: Linux + CUDA. macOS Metal later.

---

## 2. Repository Layout

```
zllm2/
├── src/
│   ├── main.zig                   CLI entry: arg parse, dispatch to tui/serve/bench
│   ├── cli/
│   │   ├── tui.zig                zigzag event loop, chat transcript + input
│   │   ├── commands.zig           /command dispatch table + handlers
│   │   ├── markdown.zig           streaming Cell styler (bold/italic/code/headers)
│   │   ├── diagram.zig            ASCII + Kitty model architecture renderer
│   │   ├── complete.zig           tab-completion for /commands and file paths
│   │   ├── session.zig            JSONL chat history save/resume (from zaica/session.zig)
│   │   ├── terminal.zig           raw mode, scroll, spinner (from zaica/io.zig)
│   │   └── state.zig              reactive TUI state via zefx (from zaica/lib/zefx)
│   ├── model/
│   │   ├── loader.zig             unified entry: GGUF vs HF dir detection + mmap load
│   │   ├── weights.zig            ModelWeights + LayerWeights structs, tensor lookup
│   │   ├── kv_cache.zig           KV cache alloc/manage/snapshot/restore
│   │   ├── hf_bridge.zig          generic setTensorData callback + pattern matcher
│   │   ├── arch_table.zig         per-arch metadata + tensor name pattern tables
│   │   ├── quantize.zig           ggml_quantize_chunk wrappers, row-at-a-time
│   │   ├── safetensors.zig        safetensors header parser + mmap shard manager
│   │   ├── arch_yaml.zig          GGUF hparam ↔ YAML serialization + override apply
│   │   ├── moe.zig                MoE expert dispatch: routing, CPU/GPU hybrid
│   │   └── graphs/
│   │       ├── interface.zig      GraphBuilder interface + dispatch by arch
│   │       ├── llama3.zig         Llama-3 forward pass (dense: attn + SwiGLU + RMSNorm)
│   │       ├── llama4.zig         Llama-4 (interleaved MoE)
│   │       ├── qwen35.zig         Qwen3.5 hybrid (port qwen35_target_graph.cpp)
│   │       ├── qwen3moe.zig       Qwen3-MoE / Qwen3-30B-A3B
│   │       ├── deepseek2.zig      DeepSeek-V2/V3 (MLA + grouped MoE)
│   │       ├── mixtral.zig        Mixtral 8x7B/8x22B (sparse MoE)
│   │       ├── gemma4.zig         Gemma4 (SWA+global attn, per-layer embd, softcap)
│   │       └── fallback.zig       llama_decode fallback for unimplemented archs
│   ├── cuda/
│   │   ├── kernels.cu             dflash rollback, DDTree mask, hidden state ops
│   │   ├── dequant.cu             GGUF quant dequantization kernels (from ktransformers)
│   │   ├── moe_topk.cu            MoE top-k softmax expert routing (from ktransformers)
│   │   ├── gptq_marlin.cu         GPTQ INT4 fast matmul (from ktransformers)
│   │   ├── kernels.h
│   │   └── kernels.zig            extern fn declarations for all CUDA kernels
│   ├── serving/
│   │   ├── server.zig             minimal HTTP/1.1 listener (std.net, ~300 lines)
│   │   └── openai.zig             /v1/chat/completions SSE + /v1/models handlers
│   ├── dflash/
│   │   ├── draft.zig              generic draft safetensors loader (BF16 → ggml)
│   │   ├── ddtree.zig             DDTree budget-22 tree verify
│   │   └── decode.zig             block-diffusion speculative decode loop
│   ├── bench/
│   │   ├── runner.zig             benchmark harness: tok/s, AL, accuracy
│   │   └── datasets.zig           JSONL loaders for HumanEval / GSM8K / Math500
│   ├── config/
│   │   └── schema.zig             JSON config load/save, field validation
│   ├── tools/
│   │   ├── executor.zig           tool framework + permissions (from zaica/tools.zig)
│   │   ├── agent_loop.zig         LLM→tool→loop agentic logic (from zaica/node.zig)
│   │   ├── http.zig               streaming HTTP client (from zaica/client/http.zig)
│   │   ├── websearch.zig          DuckDuckGo search (uses http.zig)
│   │   └── bash.zig               confirmed shell execution (from zaica tool def)
│   └── serving/
│       ├── server.zig             minimal HTTP/1.1 listener
│       ├── openai.zig             /v1/chat/completions SSE + /v1/models
│       ├── sse.zig                SSE parser + emitter (from zaica/client/sse.zig)
│       └── message.zig            ChatMessage builder (from zaica/client/message.zig)
├── tests/
│   ├── run_tests.sh               master test runner: iterates configs/, checks exit
│   └── configs/
│       ├── smoke_gguf.json        Phase 0 smoke test (any GGUF)
│       ├── llama3_hf.json         Phase 1: Llama-3.1-8B safetensors
│       ├── qwen35_hf.json         Phase 1: Qwen3.5-9B safetensors
│       ├── gemma4_hf.json         Phase 1: Gemma-4-E4B safetensors
│       ├── quant_q4km.json        Phase 4: load BF16 → quantize Q4_K_M → save
│       ├── serve_basic.json       Phase 5: start server, POST one request
│       ├── mixtral_moe.json       Phase 5b: Mixtral 8x7B
│       ├── qwen3moe_hf.json       Phase 5b: Qwen3-30B-A3B safetensors
│       ├── deepseek_cpu_offload.json Phase 5b: DeepSeek CPU offload
│       ├── dflash_qwen35.json     Phase 6: DFlash Qwen3.5-27B
│       ├── bench_humaneval.json   Phase 7: HumanEval 10 samples
│       └── tools_websearch.json   Phase 8: websearch tool call
├── datasets/
│   ├── humaneval.jsonl            OpenAI HumanEval 164 prompts
│   ├── gsm8k.jsonl                GSM8K test split
│   └── math500.jsonl              MATH-500 problems
├── build.zig
├── build.zig.zon
└── README.md
```

---

## 3. Config File Format (JSON)

All runtime configuration lives in a single JSON file. The CLI accepts `-c <path>`.  
Any field can be omitted — defaults shown below.

### 3.1 Full Config Reference

```json
{
  "model": "/home/emo/Downloads/test_models/2/gemma-4-E4B-it",
  "dtype": "f16",
  "ctx": 4096,
  "gen": 512,
  "temp": 0.7,
  "top_p": 0.9,
  "top_k": 40,
  "repeat_penalty": 1.1,
  "flash_attn": true,
  "kv_type": "f16",
  "sliding_window": null,
  "offload": -1,
  "threads": 8,

  "moe_expert_dtype": null,
  "moe_experts_offload": false,
  "moe_experts_on_gpu": -1,

  "draft": null,
  "dflash": false,
  "dflash_budget": 22,
  "draft_dtype": "bf16",

  "serve": false,
  "serve_port": 8080,
  "system_prompt": "You are a helpful assistant.",
  "tools": [],
  "save_on_load": null,
  "arch_override": null,
  "bench": null,
  "prompt": null
}
```

### 3.2 Field Reference

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `model` | string | required | Path to GGUF file or HF safetensors directory |
| `dtype` | string | `"f16"` | Weight dtype: `"f16"`, `"f32"`, `"q4_k_m"`, `"q8_0"`, `"q5_k_m"`, `"q2_k"` |
| `ctx` | int | `4096` | Context window size in tokens |
| `gen` | int | `512` | Max tokens to generate per turn |
| `temp` | float | `0.7` | Sampling temperature. `0` = greedy |
| `top_p` | float | `0.9` | Nucleus sampling probability |
| `top_k` | int | `40` | Top-K sampling. `0` = disabled |
| `repeat_penalty` | float | `1.1` | Repetition penalty |
| `flash_attn` | bool | `true` | Enable flash attention |
| `kv_type` | string | `"f16"` | KV cache dtype: `"f16"`, `"f32"`, `"q4_0"`, `"q8_0"` |
| `sliding_window` | int\|null | `null` | Override sliding window size (null = use model default) |
| `offload` | int | `-1` | GPU layers to offload. `-1` = all, `0` = CPU only |
| `threads` | int | `8` | CPU thread count |
| `draft` | string\|null | `null` | Path to DFlash draft model (safetensors dir) |
| `dflash` | bool | `false` | Enable DFlash speculative decoding |
| `dflash_budget` | int | `22` | DDTree node budget per step |
| `draft_dtype` | string | `"bf16"` | Draft model weight dtype: `"bf16"`, `"f16"`, `"q4_k_m"`, `"q8_0"`. Same streaming quantization as target. |
| `moe_expert_dtype` | string\|null | `null` | Override dtype for MoE expert weights only (gate/up/down_exps). Null = use global `dtype`. Useful to keep experts at lower precision than attention. |
| `moe_experts_offload` | bool | `false` | Offload MoE expert weights to CPU RAM. Attention stays on GPU. Enables running 671B DeepSeek on 24GB VRAM. |
| `moe_experts_on_gpu` | int | `-1` | When `moe_experts_offload=true`: number of expert layers to keep on GPU. `-1` = auto (fit as many as possible). `0` = all experts on CPU. |
| `serve` | bool | `false` | Start OpenAI-compatible HTTP server instead of TUI |
| `serve_port` | int | `8080` | HTTP port |
| `system_prompt` | string | `"You are a helpful assistant."` | System message prepended to every chat |
| `tools` | array | `[]` | Enabled tools: `"websearch"`, `"bash"` |
| `save_on_load` | string\|null | `null` | If set, save GGUF to this path after loading |
| `arch_override` | string\|null | `null` | Path to YAML file with hparam overrides |
| `bench` | string\|null | `null` | Run benchmark: `"humaneval"`, `"gsm8k"`, `"math500"` |
| `prompt` | string\|null | `null` | Non-interactive: run this prompt and exit |

### 3.3 Example Configs

#### Chat with Gemma4 (HF safetensors, interactive TUI)
```json
{
  "model": "/home/emo/Downloads/test_models/2/gemma-4-E4B-it",
  "dtype": "f16",
  "ctx": 8192,
  "gen": 1024,
  "temp": 0.7,
  "flash_attn": true,
  "kv_type": "q4_0",
  "offload": -1
}
```
Run: `zllm2 -c gemma4.json`

#### Load BF16 safetensors, quantize Q4_K_M, save GGUF, then chat
```json
{
  "model": "/home/emo/Downloads/test_models/2/gemma-4-E4B-it",
  "dtype": "q4_k_m",
  "save_on_load": "/home/emo/Downloads/gemma4-q4km.gguf",
  "ctx": 4096,
  "flash_attn": true
}
```
Run: `zllm2 -c gemma4-quant.json`

#### Non-interactive single prompt (for scripting / CI)
```json
{
  "model": "/home/emo/Downloads/Qwen3.5-9B.Q4_K_M.gguf",
  "dtype": "f16",
  "ctx": 2048,
  "gen": 200,
  "temp": 0.0,
  "prompt": "Give me 5 Python code examples."
}
```
Run: `zllm2 -c qwen_prompt.json`  
Also works via: `zllm2 -c qwen_prompt.json -p "override prompt here"`

#### OpenAI server
```json
{
  "model": "/home/emo/Downloads/Qwen3.5-9B.Q4_K_M.gguf",
  "serve": true,
  "serve_port": 8080,
  "ctx": 4096,
  "flash_attn": true,
  "kv_type": "q4_0"
}
```
Run: `zllm2 -c serve.json`  
Test: `curl http://localhost:8080/v1/models`

#### DFlash speculative decoding (draft as BF16, ~3.5 GB)
```json
{
  "model": "/home/emo/Downloads/Qwen3.5-27B.Q4_K_M.gguf",
  "draft": "/home/emo/Downloads/test_models/Qwen3.5-27B-DFlash",
  "dflash": true,
  "dflash_budget": 22,
  "draft_dtype": "bf16",
  "ctx": 4096,
  "kv_type": "q4_0",
  "flash_attn": true
}
```

#### Mixtral 8x7B — full GPU (fits in 24 GB at Q4_K_M)
```json
{
  "model": "/home/emo/Downloads/Mixtral-8x7B.Q4_K_M.gguf",
  "dtype": "f16",
  "ctx": 32768,
  "flash_attn": true,
  "kv_type": "q4_0",
  "offload": -1
}
```

#### Qwen3-30B-A3B MoE — full GPU, experts at lower precision
```json
{
  "model": "/home/emo/Downloads/Qwen3-30B-A3B",
  "dtype": "f16",
  "moe_expert_dtype": "q4_k_m",
  "ctx": 32768,
  "flash_attn": true,
  "kv_type": "q4_0",
  "offload": -1
}
```
Note: attention weights stay F16, expert FFN weights quantized to Q4_K_M.  
Saves ~60% VRAM on expert weights while keeping attention quality.

#### DeepSeek-V3 671B — CPU/GPU hybrid (24 GB VRAM)
```json
{
  "model": "/home/emo/Downloads/DeepSeek-V3.Q4_K_M.gguf",
  "dtype": "q4_k_m",
  "moe_experts_offload": true,
  "moe_experts_on_gpu": 0,
  "threads": 32,
  "ctx": 8192,
  "flash_attn": true,
  "kv_type": "q4_0",
  "offload": -1
}
```
Note: all expert weights on CPU RAM, attention + embeddings on GPU.  
Requires ~200 GB RAM for full Q4_K_M expert weights.  
Tok/s limited by RAM bandwidth for expert dispatch (~5-15 tok/s on fast RAM).

#### DeepSeek-V3 671B — mixed: partial GPU expert offload
```json
{
  "model": "/home/emo/Downloads/DeepSeek-V3.Q4_K_M.gguf",
  "dtype": "q4_k_m",
  "moe_experts_offload": true,
  "moe_experts_on_gpu": 10,
  "threads": 32,
  "ctx": 8192,
  "flash_attn": true,
  "kv_type": "q4_0"
}
```
Note: first 10 expert layers on GPU, rest on CPU. Balance VRAM vs tok/s.

#### DFlash with quantized draft (saves ~2.6 GB VRAM vs BF16)
```json
{
  "model": "/home/emo/Downloads/Qwen3.5-27B.Q4_K_M.gguf",
  "draft": "/home/emo/Downloads/test_models/Qwen3.5-27B-DFlash",
  "dflash": true,
  "dflash_budget": 22,
  "draft_dtype": "q4_k_m",
  "ctx": 131072,
  "kv_type": "q4_0",
  "flash_attn": true
}
```
Note: quantizing the draft may reduce acceptance length slightly. Benchmark to verify.
Run: `zllm2 -c dflash.json`

#### Benchmark HumanEval
```json
{
  "model": "/home/emo/Downloads/Qwen3.5-27B.Q4_K_M.gguf",
  "bench": "humaneval",
  "temp": 0.0,
  "gen": 512,
  "ctx": 2048
}
```
Run: `zllm2 -c bench.json`

#### Chat with web search + bash tools enabled
```json
{
  "model": "/home/emo/Downloads/Qwen3.5-9B.Q4_K_M.gguf",
  "tools": ["websearch", "bash"],
  "ctx": 8192,
  "temp": 0.7
}
```

#### Architecture override (edit hparams before loading)
```json
{
  "model": "/home/emo/Downloads/Qwen3.5-9B.Q4_K_M.gguf",
  "arch_override": "/home/emo/experiments/qwen_ablation.yaml",
  "ctx": 2048,
  "prompt": "Hello"
}
```

---

## 4. Architecture Override YAML

When `arch_override` is set, zllm2 loads the base model's hparams from GGUF/config.json, then applies overrides from this YAML before constructing the ggml graph. This enables architecture ablations without retraining.

`/showmodel --yaml` dumps the *full* current architecture as a ready-to-edit YAML file. The user edits it, then runs `/reload --arch <path>` to apply. The YAML is the single source of truth — what is in the file is exactly what gets built.

### 4.1 Full Schema

The schema mirrors the complete layer tree that inspect.zig exposes. Every node has a real tensor name so the user can track what weight each component maps to.

#### Top-level structure

```yaml
# Architecture YAML — generated by /showmodel --yaml, editable by user
# Apply with: /reload --arch arch.yaml

model:
  name: Qwen3.5-9B              # display name (informational)
  architecture: qwen35          # gguf arch string — drives tensor name lookup
  dtype: q4_k_m                 # default weight dtype for load/quant

# ── Global hyperparameters ─────────────────────────────────────────────────────
hparams:
  embedding_length: 4096        # d_model / hidden_size
  block_count: 32               # number of transformer blocks
  vocab_size: 152064
  rms_norm_epsilon: 1.0e-6

  attention:
    head_count: 32              # Q heads
    head_count_kv: 8            # KV heads (GQA); set == head_count for MHA
    head_dim: 128               # per-head dimension (d_model / head_count if omitted)
    key_length: 128             # key projection output per head
    value_length: 128           # value projection output per head
    use_qkv_bias: false         # whether Q/K/V projections have bias
    use_alibi: false            # ALiBi positional bias instead of RoPE
    sliding_window: null        # null = global attn; integer = local window size

  rope:
    freq_base: 1000000.0
    dimension_count: 128        # rotary dims (usually == head_dim)
    scaling_type: null          # null | "linear" | "yarn" | "longrope"
    scaling_factor: 1.0

  mlp:
    feed_forward_length: 22016  # intermediate / up-proj size
    activation: silu            # silu | gelu | relu | geglu
    gate_proj: true             # SwiGLU: true = gate×up×down; false = up×down

  moe:
    enabled: false
    num_experts: 0
    num_experts_used: 0         # top-k
    shared_experts: 0           # DeepSeek-style always-active experts
    expert_feed_forward_length: 0
    norm_topk_prob: true

  final_norm: rms_norm          # rms_norm | layer_norm
  tie_word_embeddings: false    # lm_head shares embed weight

# ── Layer list ─────────────────────────────────────────────────────────────────
# If omitted, layers 0 .. block_count-1 are used in order.
# Explicit list enables: skip, duplicate, reorder layers.
# Each entry maps to a real blk.N in the loaded model (source: N).
# You can also override per-layer hparams here.
layers:
  - id: 0                       # logical index in the generated model
    source: 0                   # which blk.N to load weights from
    # optional per-layer overrides:
    # attention:
    #   sliding_window: 4096    # e.g. make this block use local attention
    # skip: false               # set true to drop this block from the graph

  - id: 1
    source: 1

  # ... (block_count entries total)
  # /showmodel --yaml fills all of these in for you
```

#### Per-layer full component tree

Each element in `layers:` represents one transformer block. The component tree below shows every sub-module and its corresponding **weight tensor name** as it appears in the HF safetensors / GGUF file. This is what `inspect.zig` builds as `ArchitectureNode` children:

```yaml
# Example expansion of layers[0] — shows every named component.
# /showmodel --yaml --expand emits this form for inspection/editing.
# In the compact form above, these are derived automatically from hparams.

layers:
  - id: 0
    source: 0
    components:
      # ── Pre-attention norm ────────────────────────────────────────────────
      pre_attn_norm:
        kind: rms_norm
        weight: model.layers.{N}.input_layernorm.weight   # HF name
        gguf:   blk.{N}.attn_norm.weight                  # GGUF tensor name
        shape:  [embedding_length]                         # [4096]

      # ── Multi-head self-attention ─────────────────────────────────────────
      self_attn:
        kind: self_attention
        # input:  [B, T, embedding_length]
        # output: [B, T, embedding_length]
        components:
          q_proj:
            kind: linear
            weight: model.layers.{N}.self_attn.q_proj.weight
            gguf:   blk.{N}.attn_q.weight
            shape:  [head_count * head_dim, embedding_length]   # [4096, 4096]
            bias:   model.layers.{N}.self_attn.q_proj.bias      # if use_qkv_bias

          k_proj:
            kind: linear
            weight: model.layers.{N}.self_attn.k_proj.weight
            gguf:   blk.{N}.attn_k.weight
            shape:  [head_count_kv * head_dim, embedding_length]  # [1024, 4096]

          v_proj:
            kind: linear
            weight: model.layers.{N}.self_attn.v_proj.weight
            gguf:   blk.{N}.attn_v.weight
            shape:  [head_count_kv * head_dim, embedding_length]  # [1024, 4096]

          # RoPE is a stateless op — no weights, no tensor name
          rope:
            kind: rope
            freq_base: 1000000.0   # inherited from hparams.rope unless overridden
            dimension_count: 128

          sdpa:
            kind: scaled_dot_product_attention
            # flash attention is used automatically when ctx > threshold

          o_proj:
            kind: linear
            weight: model.layers.{N}.self_attn.o_proj.weight
            gguf:   blk.{N}.attn_output.weight
            shape:  [embedding_length, head_count * head_dim]  # [4096, 4096]

      attn_residual:
        kind: residual_add      # x = x + attn_out  (no weights)

      # ── Pre-FFN norm ──────────────────────────────────────────────────────
      pre_ffn_norm:
        kind: rms_norm
        weight: model.layers.{N}.post_attention_layernorm.weight
        gguf:   blk.{N}.ffn_norm.weight
        shape:  [embedding_length]

      # ── Feed-forward (MLP / SwiGLU) ───────────────────────────────────────
      mlp:
        kind: feed_forward
        # input:  [B, T, embedding_length]
        # output: [B, T, embedding_length]
        components:
          gate_proj:
            kind: linear
            weight: model.layers.{N}.mlp.gate_proj.weight
            gguf:   blk.{N}.ffn_gate.weight
            shape:  [feed_forward_length, embedding_length]  # [22016, 4096]

          up_proj:
            kind: linear
            weight: model.layers.{N}.mlp.up_proj.weight
            gguf:   blk.{N}.ffn_up.weight
            shape:  [feed_forward_length, embedding_length]

          act_fn:
            kind: activation
            function: silu   # inherited from hparams.mlp.activation

          down_proj:
            kind: linear
            weight: model.layers.{N}.mlp.down_proj.weight
            gguf:   blk.{N}.ffn_down.weight
            shape:  [embedding_length, feed_forward_length]  # [4096, 22016]

      ffn_residual:
        kind: residual_add
```

#### MoE variant — additional components inside `mlp:`

When `hparams.moe.enabled: true`, each layer's `mlp:` is replaced by a `moe:` block:

```yaml
      moe:
        kind: mixture_of_experts
        components:
          router:
            kind: linear
            weight: model.layers.{N}.mlp.gate.weight
            gguf:   blk.{N}.ffn_gate_inp.weight
            shape:  [num_experts, embedding_length]

          # shared experts (DeepSeek-V3 style, count = moe.shared_experts)
          shared_expert_gate_proj:
            kind: linear
            weight: model.layers.{N}.mlp.shared_experts.gate_proj.weight
            gguf:   blk.{N}.ffn_gate_shexp.weight
            shape:  [shared_expert_feed_forward_length, embedding_length]

          shared_expert_up_proj:
            kind: linear
            weight: model.layers.{N}.mlp.shared_experts.up_proj.weight
            gguf:   blk.{N}.ffn_up_shexp.weight

          shared_expert_down_proj:
            kind: linear
            weight: model.layers.{N}.mlp.shared_experts.down_proj.weight
            gguf:   blk.{N}.ffn_down_shexp.weight

          # sparse experts — one entry per expert (num_experts total)
          experts:
            - id: 0
              gate_proj:
                weight: model.layers.{N}.mlp.experts.0.gate_proj.weight
                gguf:   blk.{N}.ffn_gate_exps.weight   # stacked in GGUF
              up_proj:
                weight: model.layers.{N}.mlp.experts.0.up_proj.weight
                gguf:   blk.{N}.ffn_up_exps.weight
              down_proj:
                weight: model.layers.{N}.mlp.experts.0.down_proj.weight
                gguf:   blk.{N}.ffn_down_exps.weight
            # ... num_experts entries
```

#### Embedding and output head

```yaml
# ── Token embedding (top of model) ────────────────────────────────────────────
embedding:
  weight: model.embed_tokens.weight
  gguf:   token_embd.weight
  shape:  [vocab_size, embedding_length]   # [152064, 4096]
  cpu_only: true    # never uploaded to GPU — dequantize row-at-a-time on demand

# ── Final norm ─────────────────────────────────────────────────────────────────
final_norm:
  kind: rms_norm
  weight: model.norm.weight
  gguf:   output_norm.weight
  shape:  [embedding_length]

# ── LM head / output projection ────────────────────────────────────────────────
lm_head:
  weight: lm_head.weight
  gguf:   output.weight
  shape:  [vocab_size, embedding_length]
  tied: false    # if true, shares embedding.weight (no separate tensor)
```

### 4.2 `/showmodel` Tree Output (TUI display)

When the user types `/showmodel`, zllm2 renders this tree in the terminal using box-drawing characters. The display mirrors the YAML structure:

```
Qwen3.5-9B  [32 layers · 9.4B params · q4_k_m · 4096d · 32/8 heads · ctx 131072]

model
├── embedding              token_embd.weight          [152064 × 4096]  cpu-only
│
├── block.0 ─┐
│   ├── pre_attn_norm      blk.0.attn_norm.weight     [4096]
│   ├── self_attn
│   │   ├── q_proj         blk.0.attn_q.weight        [4096 × 4096]
│   │   ├── k_proj         blk.0.attn_k.weight        [1024 × 4096]
│   │   ├── v_proj         blk.0.attn_v.weight        [1024 × 4096]
│   │   ├── rope           (stateless, base=1e6)
│   │   ├── sdpa           (flash_attn)
│   │   └── o_proj         blk.0.attn_output.weight   [4096 × 4096]
│   ├── attn_residual      (op)
│   ├── pre_ffn_norm       blk.0.ffn_norm.weight      [4096]
│   ├── mlp
│   │   ├── gate_proj      blk.0.ffn_gate.weight      [22016 × 4096]
│   │   ├── up_proj        blk.0.ffn_up.weight        [22016 × 4096]
│   │   ├── act_fn         silu
│   │   └── down_proj      blk.0.ffn_down.weight      [4096 × 22016]
│   └── ffn_residual       (op)
│
├── block.1  (source: 1)   [same structure]
│   └── ...
│
├── block.N  ...
│
├── final_norm             output_norm.weight         [4096]
└── lm_head                output.weight              [152064 × 4096]

Press [e] to export YAML   [q] to close
```

For MoE models the `mlp` subtree is replaced:

```
│   ├── moe
│   │   ├── router         blk.0.ffn_gate_inp.weight  [128 × 4096]
│   │   ├── shared_ffn
│   │   │   ├── gate_proj  blk.0.ffn_gate_shexp.weight
│   │   │   ├── up_proj    blk.0.ffn_up_shexp.weight
│   │   │   └── down_proj  blk.0.ffn_down_shexp.weight
│   │   └── experts [128]
│   │       ├── expert.0
│   │       │   ├── gate_proj  blk.0.ffn_gate_exps.weight [row 0]
│   │       │   ├── up_proj    blk.0.ffn_up_exps.weight   [row 0]
│   │       │   └── down_proj  blk.0.ffn_down_exps.weight [row 0]
│   │       └── ... (collapsed by default, [x] to expand)
```

### 4.3 Examples

#### Skip last 4 layers (speed ablation)
```yaml
hparams:
  block_count: 28
layers:
  - { id: 0, source: 0 }
  - { id: 1, source: 1 }
  # ...
  - { id: 27, source: 27 }
  # layers 28-31 simply omitted
```

#### Duplicate middle layers (depth experiment)
```yaml
hparams:
  block_count: 34
layers:
  - { id: 0,  source: 0  }
  # ... layers 1-15
  - { id: 15, source: 14 }   # duplicate 14
  - { id: 16, source: 15 }   # duplicate 15
  - { id: 17, source: 16 }
  # ...
```

#### Make blocks 16-31 use sliding window attention
```yaml
layers:
  # blocks 0-15: global attention (inherited from hparams)
  - { id: 0, source: 0 }
  # ...
  # blocks 16-31: local window
  - id: 16
    source: 16
    attention:
      sliding_window: 4096
  # ...
```

#### Change GQA ratio
```yaml
hparams:
  attention:
    head_count_kv: 4   # was 8, now more aggressive GQA
```

### 4.4 `/showmodel --yaml` Output Example

Running `/showmodel --yaml` in the TUI (or `zllm2 --showmodel --yaml` on CLI) dumps the full compact form — hparams + layer list — ready to edit and reload:

```yaml
# zllm2 arch dump — Qwen3.5-9B — 2026-04-18
# Edit and reload with: /reload --arch <path>

model:
  name: Qwen3.5-9B
  architecture: qwen35
  dtype: q4_k_m

hparams:
  embedding_length: 4096
  block_count: 32
  vocab_size: 152064
  rms_norm_epsilon: 1.0e-6
  attention:
    head_count: 32
    head_count_kv: 8
    head_dim: 128
    key_length: 128
    value_length: 128
    use_qkv_bias: false
    sliding_window: null
  rope:
    freq_base: 1000000.0
    dimension_count: 128
    scaling_type: null
  mlp:
    feed_forward_length: 22016
    activation: silu
    gate_proj: true
  moe:
    enabled: false
  final_norm: rms_norm
  tie_word_embeddings: false

embedding:
  cpu_only: true

lm_head:
  tied: false

layers:
  - { id: 0,  source: 0  }
  - { id: 1,  source: 1  }
  - { id: 2,  source: 2  }
  # ... 32 entries total
  - { id: 31, source: 31 }
```

`/showmodel --yaml --expand` emits the full component tree with all tensor names and shapes filled in (the long form shown in §4.1). That form is read-only reference — users edit the compact form.

---

## 5. TUI Commands Reference

All commands are typed in the TextInput at the bottom of the TUI. Commands start with `/`.

### 5.1 Model Loading

| Command | Description |
|---------|-------------|
| `/model <path>` | Set model path (does NOT load — just sets the path) |
| `/load` | Load the model with current settings; shows progress bar |
| `/reload` | Unload current model and load again with current settings |
| `/reload --arch path.yaml` | Reload with hparam overrides from YAML |
| `/unload` | Free model from GPU, keep config — TUI returns to idle state |
| `/save path.gguf` | Write current model (at current dtype) to GGUF file |

**Startup behaviour**: zllm2 always starts in idle state (no model loaded).  
If `-c config.json` is passed, settings are applied but `/load` must be called explicitly unless `prompt` is set (non-interactive mode auto-loads).  
If `-m model-path` is passed, `/model` is pre-filled but still requires `/load` unless `-p` is also set.

### 5.2 Generation Settings

| Command | Example | Description |
|---------|---------|-------------|
| `/set temp 0.6` | `/set temp 0` | Sampling temperature |
| `/set top_p 0.9` | | Nucleus sampling |
| `/set top_k 40` | | Top-K |
| `/set gen 256` | | Max tokens per response |
| `/set ctx 8192` | | Context size (requires `/reload`) |
| `/set dtype f16` | `/set dtype q4_k_m` | Weight dtype (requires `/reload`) |
| `/set dtype blk.5.ffn_gate.weight q8_0` | | Per-tensor dtype override |
| `/set system "You are a Zig expert."` | | Override system prompt |

### 5.3 Hardware

| Command | Example | Description |
|---------|---------|-------------|
| `/offload -1` | `/offload 20` | GPU layers (-1=all, 0=CPU) |
| `/kv-type q4_0` | `/kv-type f16` | KV cache dtype |
| `/ctx 4096` | | Shorthand for `/set ctx` |
| `/gen 512` | | Shorthand for `/set gen` |
| `/enable flash-attn` | `/disable flash-attn` | Toggle flash attention |

### 5.4 Inspection

| Command | Description |
|---------|-------------|
| `/showmodel` | Print ASCII block diagram of model architecture |
| `/showmodel --yaml` | Dump hparams as YAML to stdout / file |
| `/chat-template` | Print the model's Jinja2 chat template |
| `/config` | Show current full config as JSON |

### 5.5 Speculative Decoding

| Command | Description |
|---------|-------------|
| `/enable dflash --draft /path/to/draft` | Enable DFlash with given draft model |
| `/disable dflash` | Disable DFlash, back to autoregressive |
| `/set dflash-budget 22` | Set DDTree node budget |

### 5.6 Server

| Command | Description |
|---------|-------------|
| `/serve` | Start OpenAI server on default port 8080 |
| `/serve 9090` | Start on custom port |
| `/serve stop` | Stop server |

### 5.7 Tools

| Command | Description |
|---------|-------------|
| `/enable websearch` | Enable web search tool for model |
| `/enable bash` | Enable bash execution tool (prompts user to confirm each run) |
| `/disable websearch` | Disable tool |

### 5.8 Benchmarks

| Command | Description |
|---------|-------------|
| `/bench humaneval` | Run HumanEval (164 prompts, reports pass@1) |
| `/bench humaneval --samples 10` | Run 10 samples only |
| `/bench gsm8k` | Run GSM8K (reports accuracy + tok/s) |
| `/bench math500` | Run MATH-500 |

### 5.9 Config

| Command | Description |
|---------|-------------|
| `/config-save path.json` | Save current config to JSON |
| `/load-config path.json` | Load config (reloads model if model path changed) |

### 5.10 Session

| Command | Description |
|---------|-------------|
| `/clear` | Clear chat history |
| `/reset` | Clear history + reset KV cache |
| `/history` | Show token counts per turn |
| `/quit` | Exit zllm2 |

---

## 6. TUI Layout

### 6.1 Idle (no model loaded)

On startup zllm2 opens the TUI immediately without loading any model.  
If a config was passed with `-c`, settings are applied but the model is **not** loaded until `/load`.

```
┌──────────────────────────────────────────────────────────────────────┐
│ zllm2  [no model]  dtype:f16  ctx:4096                               │  ← status bar
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Welcome to zllm2.                                                   │
│  Set a model and load it:                                            │
│                                                                      │
│    /model /path/to/model-dir-or-file                                 │
│    /set dtype q4_k_m                                                 │
│    /load                                                             │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│ > _                                                                  │
└──────────────────────────────────────────────────────────────────────┘
```

### 6.2 Loading (progress bar)

After `/load`, the chat pane shows a live progress bar.  
For safetensors models, progress advances layer by layer as tensors are quantized and uploaded.  
For GGUF models, progress advances as tensors are mmap-copied to GPU.

```
┌──────────────────────────────────────────────────────────────────────┐
│ zllm2  Gemma-4-E4B  dtype:q4_k_m  ctx:8192  loading...              │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Loading: Gemma-4-E4B  (q4_k_m)                                     │
│                                                                      │
│  [████████████████████░░░░░░░░░░░░░░]  47%  blk.29/62               │
│                                                                      │
│  tensors loaded : 312 / 660                                          │
│  VRAM used      : 6.1 GB / 24.0 GB                                  │
│  RAM used       : 1.2 GB  (mmap, not resident)                      │
│  elapsed        : 4.2 s                                              │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│ (loading — input disabled)                                           │
└──────────────────────────────────────────────────────────────────────┘
```

Progress data comes from the `setTensorData` callback: each call increments a counter and sends a progress event to the TUI event loop via a channel.

### 6.3 Chat (model loaded, generating)

```
┌──────────────────────────────────────────────────────────────────────┐
│ zllm2  Gemma-4-E4B  q4_k_m  ctx:8192  kv:q4_0  pp:1840t/s  tg:31t/s│
│        VRAM 8.3/24GB  RAM 1.2GB  temp:0.7  ctx used: 312/8192       │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  You: give me a quicksort in Python                                  │
│                                                                      │
│  Assistant:                                                          │
│  Sure! Here's a clean quicksort:                                     │
│                                                                      │
│  ```python                                                           │
│  def quicksort(arr):                                                 │
│      if len(arr) <= 1:                                               │
│          return arr                                                  │
│      pivot = arr[len(arr) // 2]                                     │
│      left  = [x for x in arr if x < pivot]                          │
│      mid   = [x for x in arr if x == pivot]                         │
│      right = [x for x in arr if x > pivot]                          │
│      return quicksort(left) + mid + quicksort(right)                │
│  ```                                                                 │
│                                                                      │
│  This runs in **O(n log n)** average time.                           │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│ > _                                                                  │
└──────────────────────────────────────────────────────────────────────┘
```

**Status bar — two rows when model loaded:**
- Row 1: model name · dtype · ctx size · kv type · prefill tok/s (`pp`) · generate tok/s (`tg`)
- Row 2: VRAM used/total · RAM used · temp · ctx tokens used / max

Stats source:
- `pp` / `tg`: from `llama_perf_context` after each decode call
- VRAM: `ggml_backend_cuda_get_device_memory` (free/total), compute used = total − free
- RAM: `/proc/self/status` → `VmRSS` (Linux)
- ctx used: `llama_get_kv_cache_used_cells`

All stats update every token during generation.

**Keyboard shortcuts:**  
Scroll: mouse wheel or PgUp/PgDn in chat pane  
Tab: complete `/command` names and file paths  
Up/Down: history in TextInput  
Ctrl+C: interrupt current generation  
Ctrl+L: clear screen  
Ctrl+S: quick `/save` to last save path  

---

## 7. CLI Flags (non-interactive)

```
zllm2 [flags]

  -c, --config <path>     Load config JSON (required or -m)
  -m, --model  <path>     Model path (overrides config.model)
  -p, --prompt <text>     Run single prompt and exit (non-interactive)
      --dtype  <name>     Weight dtype override
      --serve             Start HTTP server (non-interactive)
      --port   <n>        HTTP port (default 8080)
      --bench  <name>     Run benchmark and exit
      --samples <n>       Benchmark sample count
      --save   <path>     Save GGUF after loading, then exit
      --no-tui            Print tokens to stdout, no TUI (for piping)
      --version           Print version
      --help              Print usage
```

Examples:
```bash
# Interactive TUI
zllm2 -c gemma4.json

# Single prompt, no TUI
zllm2 -c gemma4.json -p "explain RoPE embeddings" --no-tui

# Convert safetensors → Q4_K_M GGUF, then exit
zllm2 -m /path/to/hf-model --dtype q4_k_m --save model-q4.gguf

# Serve
zllm2 -c serve.json --serve --port 8080

# Benchmark
zllm2 -c bench.json --bench humaneval --samples 10
```

---

## 8. OpenAI API

### POST /v1/chat/completions

Request:
```json
{
  "model": "zllm2",
  "messages": [
    {"role": "system", "content": "You are helpful."},
    {"role": "user", "content": "What is 2+2?"}
  ],
  "stream": true,
  "temperature": 0.7,
  "max_tokens": 256
}
```

Response (SSE stream):
```
data: {"id":"chatcmpl-1","object":"chat.completion.chunk","model":"zllm2","choices":[{"delta":{"content":"4"},"index":0}]}

data: {"id":"chatcmpl-1","object":"chat.completion.chunk","model":"zllm2","choices":[{"delta":{"content":"."},"index":0}]}

data: [DONE]
```

### GET /v1/models

```json
{
  "object": "list",
  "data": [
    {
      "id": "zllm2",
      "object": "model",
      "owned_by": "local"
    }
  ]
}
```

---

## 9. Generic HF Loader Design

### 9.1 How It Works

When `model` path is a directory, zllm2:
1. Reads `config.json` → detects `architectures[0]` (e.g. `"Gemma4ForCausalLM"`)
2. Looks up arch entry in `arch_table.zig`
3. Builds a `gguf_context` with metadata mapped from config fields
4. Parses safetensors shards (mmap'd), maps HF tensor names → GGUF names via pattern table
5. Calls `llama_model_init_from_user(gguf_ctx, setTensorData, bundle, params)`
6. In `setTensorData`: converts BF16/F16 → target dtype and uploads to GPU
7. Token embedding stays CPU-side (mmap pointer, no GPU upload)

### 9.2 Arch Table Entry Structure

```zig
// arch_table.zig
pub const MetaEntry = struct {
    gguf_key: []const u8,        // e.g. "gemma4.embedding_length"
    config_path: []const u8,     // e.g. "text_config.hidden_size"
    kind: enum { u32, f32, bool, str },
    default: ?[]const u8 = null, // used if key missing from config.json
};

pub const TensorPattern = struct {
    hf:   []const u8,   // "model.layers.{N}.self_attn.q_proj.weight"
    gguf: []const u8,   // "blk.{N}.attn_q.weight"
    // Norms and 1D tensors always → F32. 2D weights → target dtype.
};

pub const Arch = struct {
    hf_class:    []const u8,         // "Gemma4ForCausalLM"
    gguf_arch:   []const u8,         // "gemma4"
    meta:        []const MetaEntry,
    tensors:     []const TensorPattern,
};
```

### 9.3 Example: Gemma4 Arch Entry (~50 lines of data)

```zig
const gemma4_meta = &[_]MetaEntry{
    .{ .gguf_key = "gemma4.context_length",               .config_path = "text_config.max_position_embeddings", .kind = .u32 },
    .{ .gguf_key = "gemma4.embedding_length",             .config_path = "text_config.hidden_size",              .kind = .u32 },
    .{ .gguf_key = "gemma4.block_count",                  .config_path = "text_config.num_hidden_layers",        .kind = .u32 },
    .{ .gguf_key = "gemma4.attention.head_count",         .config_path = "text_config.num_attention_heads",      .kind = .u32 },
    .{ .gguf_key = "gemma4.attention.head_count_kv",      .config_path = "text_config.num_key_value_heads",      .kind = .u32 },
    .{ .gguf_key = "gemma4.attention.key_length",         .config_path = "text_config.global_head_dim",          .kind = .u32, .default = "512" },
    .{ .gguf_key = "gemma4.attention.sliding_window",     .config_path = "text_config.sliding_window",           .kind = .u32, .default = "512" },
    .{ .gguf_key = "gemma4.rope.freq_base",               .config_path = "text_config.rope_parameters.full_attention.rope_theta", .kind = .f32, .default = "1000000" },
    .{ .gguf_key = "gemma4.rope.freq_base_swa",           .config_path = "text_config.rope_parameters.sliding_attention.rope_theta", .kind = .f32, .default = "10000" },
    .{ .gguf_key = "gemma4.final_logit_softcapping",      .config_path = "text_config.final_logit_softcapping",  .kind = .f32, .default = "30.0" },
    .{ .gguf_key = "gemma4.feed_forward_length",          .config_path = "text_config.intermediate_size",        .kind = .u32 },
    .{ .gguf_key = "gemma4.attention.layer_norm_rms_epsilon", .config_path = "text_config.rms_norm_eps",         .kind = .f32, .default = "1e-6" },
};

const gemma4_tensors = &[_]TensorPattern{
    .{ .hf = "model.language_model.embed_tokens.weight",               .gguf = "token_embd.weight" },
    .{ .hf = "model.language_model.norm.weight",                       .gguf = "output_norm.weight" },
    .{ .hf = "model.language_model.per_layer_model_projection.weight", .gguf = "per_layer_model_proj.weight" },
    .{ .hf = "model.language_model.layers.{N}.input_layernorm.weight",          .gguf = "blk.{N}.attn_norm.weight" },
    .{ .hf = "model.language_model.layers.{N}.self_attn.q_proj.weight",         .gguf = "blk.{N}.attn_q.weight" },
    .{ .hf = "model.language_model.layers.{N}.self_attn.k_proj.weight",         .gguf = "blk.{N}.attn_k.weight" },
    .{ .hf = "model.language_model.layers.{N}.self_attn.v_proj.weight",         .gguf = "blk.{N}.attn_v.weight" },
    .{ .hf = "model.language_model.layers.{N}.self_attn.o_proj.weight",         .gguf = "blk.{N}.attn_output.weight" },
    .{ .hf = "model.language_model.layers.{N}.self_attn.q_norm.weight",         .gguf = "blk.{N}.attn_q_norm.weight" },
    .{ .hf = "model.language_model.layers.{N}.self_attn.k_norm.weight",         .gguf = "blk.{N}.attn_k_norm.weight" },
    .{ .hf = "model.language_model.layers.{N}.post_attention_layernorm.weight", .gguf = "blk.{N}.post_attention_norm.weight" },
    .{ .hf = "model.language_model.layers.{N}.pre_feedforward_layernorm.weight",.gguf = "blk.{N}.ffn_norm.weight" },
    .{ .hf = "model.language_model.layers.{N}.mlp.gate_proj.weight",            .gguf = "blk.{N}.ffn_gate.weight" },
    .{ .hf = "model.language_model.layers.{N}.mlp.up_proj.weight",              .gguf = "blk.{N}.ffn_up.weight" },
    .{ .hf = "model.language_model.layers.{N}.mlp.down_proj.weight",            .gguf = "blk.{N}.ffn_down.weight" },
    .{ .hf = "model.language_model.layers.{N}.post_feedforward_layernorm.weight",.gguf = "blk.{N}.post_ffw_norm.weight" },
    .{ .hf = "model.language_model.layers.{N}.layer_scalar",                    .gguf = "blk.{N}.layer_output_scale.weight" },
};

pub const gemma4: Arch = .{
    .hf_class  = "Gemma4ForCausalLM",
    .gguf_arch = "gemma4",
    .meta      = gemma4_meta,
    .tensors   = gemma4_tensors,
};
```

Adding Llama-3.1 = ~40 lines of similar data. No new functions ever.

### 9.4 Fast Loading (mmap + CPU Embeddings)

Ported from `dflash/src/gguf_target_loader.cpp`:

```
1. mmap(model_dir/shard.safetensors, MAP_PRIVATE | O_RDONLY)
   → file appears in address space instantly, OS pages load on first access
   → a 15 GB model "loads" in ~100ms

2. token_embd.weight → kept as mmap'd byte pointer on CPU
   → never uploaded to GPU
   → during embedding lookup: dequantize row on demand (ggml_type_traits.to_float)
   → saves 500MB–2GB of VRAM + eliminates biggest upload

3. all other tensors → ggml_backend_tensor_set(tensor, mmap_ptr + offset, 0, nbytes)
   → GPU DMA from pinned mmap pages, async, fast
```

---

## 10. Dtype / Quantization

### 10.1 Supported Dtypes

| Name | Description | VRAM vs F16 | Quality |
|------|-------------|-------------|---------|
| `f32` | Full float32 | 2× | Lossless |
| `f16` | Float16 (default) | 1× | Near-lossless |
| `q8_0` | 8-bit symmetric | 0.5× | Excellent |
| `q5_k_m` | 5-bit K-quant mixed | 0.31× | Very good |
| `q4_k_m` | 4-bit K-quant mixed | 0.25× | Good |
| `q3_k_m` | 3-bit K-quant mixed | 0.19× | Acceptable |
| `q2_k` | 2-bit K-quant | 0.13× | Low |

### 10.2 Layer-by-Layer Streaming Quantization

**The problem**: a 27B BF16 safetensors model is ~54 GB on disk. Loading it entirely into RAM before quantizing is not feasible on most systems.

**The solution**: process one tensor at a time, never holding more than one tensor's worth of data in RAM simultaneously.

```
for each tensor T (in safetensors shard order):
    src_bytes  = mmap_ptr + T.offset        ← no copy, OS pages on demand
    row_buffer = alloc(T.row_bytes)         ← single row, ~tens of KB max
    for each row R in T:
        convert src_bytes[R] BF16→F32       ← into row_buffer
        ggml_quantize_chunk(target_type, row_buffer, dst_ptr, R, 1, ...)
        ← dst_ptr is already on GPU (ggml_backend_alloc_ctx_tensors ran first)
    free(row_buffer)
    madvise(src_bytes, T.size, MADV_DONTNEED)  ← tell OS to evict pages
```

This means:
- **RAM peak**: one tensor row at a time (~tens of KB, never GBs)
- **Shard file**: mmap'd → pages loaded on access, discarded after `MADV_DONTNEED`
- **VRAM**: each tensor is written to its final GPU location directly, no staging buffer
- **Progress**: each tensor completion = one progress tick in the TUI bar

For norms and 1D tensors → always `F32`, no quantization needed, direct BF16→F32 copy.  
`token_embd.weight` → stays CPU-mmap'd, never quantized (dequantized per-row at inference time).

### 10.3 Per-Tensor Dtype Override

`/set dtype blk.5.ffn_gate.weight q8_0`  
Stored in a `StringHashMap(dtype)`. At `setTensorData` time: check override map before using global dtype.  
Useful for keeping sensitive layers (e.g. first/last blocks) at higher precision.

---

## 11. Live Inference Stats

Stats are updated every token and displayed in the two-row status bar.

### 11.1 Sources

| Stat | Source | Notes |
|------|--------|-------|
| `pp` prefill tok/s | `llama_perf_context(ctx).t_p_eval_ms` | computed after each prefill |
| `tg` generate tok/s | `llama_perf_context(ctx).t_eval_ms / n_eval` | rolling average last 10 tokens |
| VRAM used | `ggml_backend_cuda_get_device_memory(&free, &total)` then `used = total - free` | per device |
| VRAM total | same call | |
| RAM (RSS) | `/proc/self/status` → `VmRSS` line (Linux) | read once per second, not per token |
| ctx tokens used | `llama_get_kv_cache_used_cells(ctx)` | |
| DFlash AL | acceptance length: committed_tokens / steps | only shown when dflash active |

### 11.2 Status Bar Format

```
│ zllm2  Gemma-4-E4B  q4_k_m  ctx:8192  kv:q4_0  pp:1840t/s  tg:31.2t/s │
│        VRAM 8.3/24.0GB  RAM 1.2GB  temp:0.70  512/8192 tokens           │
```

With DFlash active:
```
│ zllm2  Qwen3.5-27B  q4_k_m  ctx:4096  kv:q4_0  pp:312t/s  tg:128t/s 3.4×│
│        VRAM 18.1/24.0GB  RAM 0.8GB  AL:8.3  temp:0.00  256/4096 tokens   │
```

### 11.3 Load Progress Format

```
  Loading: Gemma-4-E4B  →  q4_k_m
  [████████████████████░░░░░░░░░░░░░░░░░░]  51%  blk.31/62
  tensors: 318/624    VRAM: 6.4/24.0 GB    RAM: ~0 GB (mmap)    4.8 s
```

- Progress bar width = terminal width − 4
- Tensor name shown after bar (current tensor being processed)
- VRAM updates after each `ggml_backend_tensor_set` completes
- RAM shows "~0 GB (mmap)" for safetensors since mmap pages are not resident
- On completion: bar fills, shows total time and final VRAM used

---

## 12. llama.cpp Integration Architecture

### 12.1 Design Philosophy: Level 2 First

**zllm2 owns the forward pass.** The primary inference path builds its own ggml compute graph per architecture — it does not call `llama_decode`. This is the same approach as `dflash/src/qwen35_target_graph.cpp` which proves a complete transformer forward pass in ggml is ~800 lines and runs at full llama.cpp speed.

We still use llama.cpp for what it does well:
- **Weight loading**: gguf parsing, `setTensorData`, `ggml_backend_alloc_ctx_tensors`
- **Samplers**: `llama_sampler_*` — temperature, top-p, top-k, repetition penalty
- **GGUF format**: metadata read/write (`gguf_init_*`, `gguf_set_*`, `gguf_write_to_file`)
- **Backend management**: CUDA/CPU/Metal backend init and scheduling
- **Tokenizer**: `llama_tokenize`, `llama_token_to_piece`

We own:
- **The entire forward pass**: attention, FFN, norms, RoPE, KV cache, logit projection
- **KV cache layout**: allocate and manage K/V buffers directly as ggml tensors
- **Hidden states**: accessible at any layer for DFlash, visualization, probing
- **Attention masks**: causal, sliding window, DDTree tree-structured — all explicit
- **Graph shape**: skip layers, duplicate layers, inject LoRA ops — modify graph directly

**Fallback**: architectures without a Level 2 graph builder yet fall back to `llama_decode`. This means every model works on day 1, and we progressively build graph ownership.

```
┌─────────────────────────────────────────────────────────────────────┐
│                           zllm2                                     │
├─────────────────────────────────────────────────────────────────────┤
│  What we own (Level 2 — primary path)                               │
│                                                                     │
│  model/graphs/                                                      │
│    llama3.zig      → ggml ops: norm, rope, GQA attn, SwiGLU        │
│    qwen35.zig      → ggml ops: hybrid attn+deltanet (port dflash)  │
│    gemma4.zig      → ggml ops: SWA+global attn, per-layer embd     │
│    [future archs]                                                   │
│                                                                     │
│  Each graph builder:                                                │
│    buildPrefillGraph(weights, tokens, pos, kv_cache) → ggml_cgraph │
│    buildDecodeGraph(weights, token, pos, kv_cache)   → ggml_cgraph │
│    buildDFlashGraph(weights, tree, hidden_bufs)      → ggml_cgraph │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│  What llama.cpp provides (used as a library)                        │
│                                                                     │
│  gguf_*              weight loading, metadata, file format          │
│  ggml_backend_*      CUDA/CPU/Metal device management               │
│  ggml_mul_mat        matrix multiply (CUDA kernels)                 │
│  ggml_norm_rms       RMSNorm (CUDA kernel)                          │
│  ggml_rope           RoPE (CUDA kernel)                             │
│  ggml_soft_max       softmax (CUDA kernel)                          │
│  ggml_quantize_chunk quantize rows                                  │
│  llama_sampler_*     sampling (temperature, top-p, etc.)            │
│  llama_tokenize      tokenizer                                      │
│  llama_decode        fallback for unsupported archs only            │
└─────────────────────────────────────────────────────────────────────┘
```

### 12.2 Graph Builder Interface

Every architecture implements this interface in `src/model/graphs/<arch>.zig`:

```zig
pub const GraphBuilder = struct {
    weights: *ModelWeights,   // ggml tensors for all layers
    kv:      *KvCache,        // K/V buffers, managed by us
    backend: *ggml_backend_t,

    // Standard prefill: process N tokens, fill KV cache
    pub fn buildPrefill(
        self: *GraphBuilder,
        gctx:   *ggml_context,
        tokens: []const i32,
        pos:    u32,
    ) *ggml_cgraph { ... }

    // Standard decode: one token, read from KV cache
    pub fn buildDecode(
        self: *GraphBuilder,
        gctx:   *ggml_context,
        token:  i32,
        pos:    u32,
    ) *ggml_cgraph { ... }

    // DFlash decode: tree-structured multi-token verify
    // hidden_out: preallocated buffers to capture layer outputs
    pub fn buildDFlashDecode(
        self:        *GraphBuilder,
        gctx:        *ggml_context,
        tree_tokens: []const i32,
        tree_mask:   *ggml_tensor,    // DDTree causal mask
        hidden_out:  []*ggml_tensor,  // one buffer per captured layer
    ) *ggml_cgraph { ... }
};
```

`ModelWeights` holds pointers to every named tensor already allocated on GPU:
```zig
pub const ModelWeights = struct {
    token_embd:  *ggml_tensor,   // CPU-mmap'd, not on GPU
    output_norm: *ggml_tensor,
    output:      *ggml_tensor,
    layers: []LayerWeights,      // indexed by layer number
};

pub const LayerWeights = struct {
    attn_norm:   *ggml_tensor,
    attn_q:      *ggml_tensor,
    attn_k:      *ggml_tensor,
    attn_v:      *ggml_tensor,
    attn_output: *ggml_tensor,
    ffn_norm:    *ggml_tensor,
    ffn_gate:    *ggml_tensor,
    ffn_up:      *ggml_tensor,
    ffn_down:    *ggml_tensor,
    // arch-specific extras (q_norm, k_norm, layer_scale, etc.)
    extras: std.StringHashMap(*ggml_tensor),
};
```

### 12.3 KV Cache

We manage the KV cache directly as ggml tensors, one tensor per layer per head type:

```zig
pub const KvCache = struct {
    // Shape: [head_dim, n_heads_kv, ctx_len] per layer
    k: []*ggml_tensor,   // length = n_layers
    v: []*ggml_tensor,
    dtype: ggml_type,    // matches kv_type config (f16, q4_0, q8_0, ...)
    n_used: u32,         // current fill position

    // DFlash: snapshot/restore for speculative rollback
    // Implemented via custom CUDA kernels (extern fn)
    pub fn snapshot(self: *KvCache, layer: u32) void { ... }
    pub fn restore(self: *KvCache, layer: u32) void { ... }
};
```

### 12.4 Execution Loop

```zig
// per turn (decode path)
pub fn decode(builder: *GraphBuilder, token: i32, pos: u32, sampler: *llama_sampler) !i32 {
    var gctx = ggml_init(.{ .mem_size = graph_mem, .no_alloc = true });
    defer ggml_free(gctx);

    const graph = builder.buildDecode(gctx, token, pos);
    ggml_backend_graph_compute(builder.backend, graph);

    // logits are in graph's output tensor
    const logits = ggml_get_tensor(gctx, "logits");
    // llama.cpp sampler still works — we feed it the raw logits array
    const next_token = llama_sampler_sample_with_logits(sampler, logits_ptr, vocab_size);
    return next_token;
}
```

### 12.5 Performance Parity

Building our own graph does **not** sacrifice performance because:
- All the heavy ops (`ggml_mul_mat`, `ggml_rope`, `ggml_norm_rms`, `ggml_soft_max`) call the **same CUDA kernels** as `llama_decode` internally
- `ggml_backend_graph_compute` uses the same scheduler and memory planner
- Flash attention: call `ggml_flash_attn_ext` — same kernel llama.cpp uses
- The only overhead is graph construction (CPU, microseconds, not on the hot path)

Expected: identical tok/s to `llama_decode` for standard inference. Verified by the dflash codebase which matches llama.cpp AR baseline exactly.

### 12.6 Custom CUDA Kernels

Three kernels from dflash, plus any future custom ops, live in `src/cuda/`:

```
src/cuda/
├── kernels.cu       dflash rollback, DDTree mask, hidden state copy
├── kernels.h        C header
└── kernels.zig      extern fn declarations for Zig callers
```

```zig
// src/cuda/kernels.zig
pub extern fn dflash_kv_snapshot(
    k_dst: *anyopaque, v_dst: *anyopaque,
    k_src: *anyopaque, v_src: *anyopaque,
    nbytes: usize, stream: *anyopaque,
) void;

pub extern fn dflash_kv_restore(
    k_dst: *anyopaque, v_dst: *anyopaque,
    k_src: *anyopaque, v_src: *anyopaque,
    nbytes: usize, stream: *anyopaque,
) void;

pub extern fn ddtree_build_mask(
    mask_out: *anyopaque,      // [budget, budget] bool tensor on GPU
    parent_ids: [*]const i32,
    n_nodes: i32,
    stream: *anyopaque,
) void;
```

`build.zig` compiles `kernels.cu` with `nvcc` and links the `.o` into the binary:
```zig
const cuda_obj = b.addSystemCommand(&.{
    "nvcc", "-O3", "-arch=sm_86",
    "-c", "src/cuda/kernels.cu",
    "-o", "zig-cache/kernels.o",
});
exe.addObjectFile(.{ .path = "zig-cache/kernels.o" });
```

### 12.7 What Level 2 Unlocks

Every feature becomes possible without waiting for llama.cpp:

| Feature | How |
|---------|-----|
| DFlash hidden state capture | add output node to graph at any layer |
| LoRA adapter injection | insert `ggml_add(ggml_mul_mat(lora_a, ggml_mul_mat(lora_b, x)), x)` in graph |
| Layer skip/duplicate from YAML | loop over `arch_override.layers[]` when building graph |
| Custom attention patterns | build attention mask tensor before `ggml_flash_attn_ext` |
| Mixed per-layer precision | each `LayerWeights` can have different dtypes |
| Activation steering | add `ggml_add(hidden, steering_vector)` at chosen layer |
| Probing / visualization | read any intermediate tensor after `graph_compute` |
| New speculative algorithms | build new graph shape, same ggml primitives |
| Any future llama.cpp op | available immediately via `ggml_*` calls |

---

## 13. MoE Architecture Support

### 13.1 What MoE Is

Mixture-of-Experts models have sparse FFN layers: each token routes to only `top_k` of `n_experts` expert networks, keeping compute constant while scaling parameters. Examples:

| Model | Experts | Top-K | Active params | Total params |
|-------|---------|-------|---------------|--------------|
| Mixtral 8x7B | 8 | 2 | ~13B | 47B |
| Qwen3-30B-A3B | 128 | 8 | ~3B | 30B |
| DeepSeek-V3 | 256 | 8 | ~37B | 671B |
| Llama-4-Scout | 16 | 1 | ~17B | 109B |

### 13.2 MoE in the Graph Builder

Every MoE graph builder calls the same shared `moe.zig` dispatch layer, which wraps `ggml_mul_mat_id` — the key ggml primitive for sparse expert matmul:

```
input hidden → gate_proj → softmax/sigmoid → top-k select → expert IDs
                                                                  ↓
input hidden → [ggml_mul_mat_id(up_exps,   hidden, expert_ids)]  → SiLU
             × [ggml_mul_mat_id(gate_exps, hidden, expert_ids)]
             → [ggml_mul_mat_id(down_exps, x,      expert_ids)]
             → weighted sum by gate scores
             → output hidden
```

`ggml_mul_mat_id` dispatches to the right expert sub-matrix on GPU — same kernel llama.cpp uses internally. No custom CUDA needed for standard MoE dispatch.

For **DeepSeek-V3 group expert selection** (256 experts, select top 8 from top 2 of 8 groups):
```
→ ggml_reshape_3d (organize into groups)
→ ggml_argsort_top_k (top-2 groups)
→ ggml_set_rows (mask non-selected groups to -inf)
→ standard top-k on masked probs
```
All pure ggml ops, already proven in llama.cpp's `llama-graph.cpp`.

### 13.3 CPU/GPU Hybrid Expert Offloading

For models too large to fit expert weights on GPU (DeepSeek-V3 671B = ~370 GB at Q4_K_M), expert weights live on CPU RAM. Attention, norms, embeddings stay on GPU.

**How it works in ggml:**
```
Expert tensors allocated with:  ggml_backend_alloc_ctx_tensors(ctx, cpu_backend)
Attention tensors allocated with: ggml_backend_alloc_ctx_tensors(ctx, cuda_backend)

ggml_backend_sched schedules ops to the correct backend automatically:
  ggml_mul_mat_id(expert_weights, ...) → runs on CPU
  ggml_flash_attn_ext(...)             → runs on CUDA
  Cross-device copies handled by ggml_backend_sched internally
```

This is exactly what `ggml_backend_sched` was designed for. No custom scheduling code needed from us.

**Config:**
```json
"moe_experts_offload": true,   // expert weights → CPU backend
"moe_experts_on_gpu": 10,      // first N expert layers stay on GPU
"threads": 32                  // CPU threads for expert matmul
```

**Performance profile:**

| Config | DeepSeek-V3 tok/s (est.) | VRAM needed |
|--------|--------------------------|-------------|
| All experts CPU, 32 threads | 3–8 tok/s | ~20 GB |
| 10 expert layers GPU | 8–15 tok/s | 24 GB |
| All GPU (requires 8×A100) | 30+ tok/s | 370 GB |

### 13.4 Per-Expert Dtype (`moe_expert_dtype`)

Expert FFN weights (gate/up/down projections) dominate model size. Keeping them at lower precision than attention saves VRAM with minimal quality impact:

```json
"dtype": "f16",            // attention weights: F16
"moe_expert_dtype": "q4_k_m"  // expert FFN weights: Q4_K_M
```

In `setTensorData`: check if tensor name contains `_exps` — if so, use `moe_expert_dtype` instead of global `dtype`.

**VRAM example — Qwen3-30B-A3B:**

| dtype | moe_expert_dtype | VRAM |
|-------|-----------------|------|
| f16 | f16 | ~60 GB |
| f16 | q4_k_m | ~18 GB |
| q4_k_m | q4_k_m | ~16 GB |

### 13.5 Supported MoE Architectures (graph builders)

| Arch | File | Gating | Notes |
|------|------|--------|-------|
| Mixtral 8x7B/8x22B | `mixtral.zig` | softmax top-2 | Standard sparse MoE |
| Qwen3-MoE / 30B-A3B | `qwen3moe.zig` | softmax top-8 | 128 experts |
| DeepSeek-V2 | `deepseek2.zig` | softmax + group select | MLA attention |
| DeepSeek-V3 | `deepseek2.zig` | sigmoid + group select + bias | 256 experts |
| Llama-4 | `llama4.zig` | sigmoid top-1 | interleaved dense+MoE |
| OLMoE | `fallback.zig` (llama_decode) | softmax top-8 | via fallback initially |

### 13.6 ktransformers Code Borrowed for MoE

| File | Source | Purpose |
|------|--------|---------|
| `cuda/moe_topk.cu` | `ktransformers/kt-kernel/cuda/moe/moe_topk_softmax_kernels.cu` | Fused top-k softmax on GPU — faster than ggml's argsort for large expert counts |
| `cuda/dequant.cu` | `ktransformers/kt-kernel/cuda/custom_gguf/dequant.cu` | GPU-side GGUF dequant (Q2_K→Q6_K) — use when GPU dequant faster than CPU upload |
| `cuda/gptq_marlin.cu` | `ktransformers/kt-kernel/cuda/gptq_marlin/gptq_marlin.cu` | GPTQ INT4 matmul — enables GPTQ HF models |

All three are Apache 2.0 licensed. Compile separately with nvcc, link as `extern fn`.

### 13.7 MoE Test Configs

`tests/configs/mixtral_moe.json`:
```json
{
  "model": "/home/emo/Downloads/Mixtral-8x7B-Instruct.Q4_K_M.gguf",
  "prompt": "Say exactly: TEST_PASS",
  "temp": 0.0, "gen": 20, "ctx": 512
}
```

`tests/configs/qwen3moe_hf.json`:
```json
{
  "model": "/home/emo/Downloads/Qwen3-30B-A3B",
  "dtype": "f16",
  "moe_expert_dtype": "q4_k_m",
  "prompt": "Say exactly: TEST_PASS",
  "temp": 0.0, "gen": 20, "ctx": 512
}
```

`tests/configs/deepseek_cpu_offload.json`:
```json
{
  "model": "/home/emo/Downloads/DeepSeek-V3.Q4_K_M.gguf",
  "moe_experts_offload": true,
  "moe_experts_on_gpu": 0,
  "threads": 16,
  "prompt": "Say exactly: TEST_PASS",
  "temp": 0.0, "gen": 20, "ctx": 512
}
```

---

## 14. DFlash Integration

### 13.1 What DFlash Is

Block-diffusion speculative decoding from arxiv:2502.20762.  
A small 5-layer non-causal diffusion draft model conditioned on captured target hidden states proposes 16 tokens per step. DDTree verifies up to 22 nodes in one target forward pass. Acceptance length ~8 tokens/step vs ~3 for chain EAGLE → 3.5× speedup at concurrency=1.

### 11.2 Architecture

```
Target model (e.g. Qwen3.5-27B Q4_K_M)    ← loaded normally via loader.zig
        ↕ captures last 5 hidden states
Draft model (e.g. Qwen3.5-27B-DFlash BF16) ← loaded via dflash/draft.zig
        ↓ proposes 16 tokens via diffusion
DDTree (budget=22)                          ← dflash/ddtree.zig
        ↓ one target forward verifies tree
Accept/rollback                             ← dflash/decode.zig
```

### 11.3 Draft Model Loading

The draft is a safetensors directory. `draft.zig` uses the **same streaming quantization pipeline** as the target model — controlled by `draft_dtype`:

- mmap all shards (`MAP_PRIVATE | O_RDONLY`) — instant, no RAM used
- parse tensor names + offsets from safetensors headers
- allocate ggml_context for draft weight descriptors (`no_alloc=true`)
- set tensor types according to `draft_dtype` config field
- `ggml_backend_alloc_ctx_tensors(draft_ctx, backend)` → allocate GPU memory
- for each tensor row: BF16 → `draft_dtype` via `ggml_quantize_chunk` (one row buffer, ~KB RAM peak)
- `MADV_DONTNEED` after each tensor to release mmap pages
- progress shown in TUI bar as a second phase after target load

**VRAM comparison — Qwen3.5-27B-DFlash (5 layers, 5120 hidden):**

| `draft_dtype` | Draft VRAM | Notes |
|---------------|-----------|-------|
| `bf16` | ~3.5 GB | original dflash default |
| `f16` | ~3.5 GB | same size, native ggml |
| `q8_0` | ~1.8 GB | minimal quality loss |
| `q4_k_m` | ~0.9 GB | ~2.6 GB saving; benchmark AL impact |

Draft norm weights always stay F32 regardless of `draft_dtype`.

### 11.4 Config

```json
{
  "model":   "/home/emo/Downloads/Qwen3.5-27B.Q4_K_M.gguf",
  "draft":   "/home/emo/Downloads/Qwen3.5-27B-DFlash",
  "dflash":  true,
  "dflash_budget": 22,
  "kv_type": "q4_0",
  "ctx":     131072
}
```

---

## 15. Benchmarks

### 12.1 Dataset Format (JSONL)

Each dataset is a local JSONL file. One JSON object per line.

**HumanEval** (`datasets/humaneval.jsonl`):
```json
{"task_id": "HumanEval/0", "prompt": "from typing import List\ndef has_close_elements(numbers: List[float], threshold: float) -> bool:\n    \"\"\" ...\"\"\"\n"}
```

**GSM8K** (`datasets/gsm8k.jsonl`):
```json
{"id": 0, "question": "Natalia sold clips to 48 of her friends...", "answer": "72"}
```

**MATH-500** (`datasets/math500.jsonl`):
```json
{"id": 0, "problem": "Let $f(x) = ...$", "solution": "...", "answer": "\\frac{1}{2}"}
```

### 12.2 Running

```bash
# via config
zllm2 -c bench.json

# via CLI
zllm2 -m model.gguf --bench humaneval --samples 10 --no-tui

# via TUI command
/bench humaneval --samples 10
```

### 12.3 Output

```
Benchmark: HumanEval — 10 samples — Qwen3.5-27B Q4_K_M
─────────────────────────────────────────────────────
 #    tokens   tok/s     AL
  1     146    37.7     —
  2     100    37.8     —
 ...
─────────────────────────────────────────────────────
mean           37.4 tok/s
```

With DFlash:
```
 #    tokens   tok/s     AL
  1     146   142.8    9.14
  ...
mean          130.2 tok/s   AL=8.31   3.48× speedup
```

---

## 16. Testing Strategy

### 13.1 Test Runner

`tests/run_tests.sh <phase>` iterates all configs for that phase:

```bash
#!/usr/bin/env bash
set -e
PHASE=${1:-all}
PASS=0; FAIL=0

for cfg in tests/configs/${PHASE}_*.json; do
    echo -n "  $cfg ... "
    timeout 120 ./zig-out/bin/zllm2 -c "$cfg" --no-tui 2>&1 | tee /tmp/zllm2_test.log
    if grep -q "TEST_PASS" /tmp/zllm2_test.log; then
        echo "PASS"; PASS=$((PASS+1))
    else
        echo "FAIL"; FAIL=$((FAIL+1))
    fi
done

echo "Results: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ]
```

Each config that runs non-interactively prints `TEST_PASS` on success or `TEST_FAIL: reason` on failure.

### 13.2 Test Config Examples

**Phase 0 — GGUF smoke**  
`tests/configs/smoke_gguf.json`:
```json
{
  "model": "/home/emo/Downloads/Qwen3.5-9B.Q4_K_M.gguf",
  "prompt": "Say exactly: TEST_PASS",
  "gen": 20,
  "temp": 0.0,
  "ctx": 512
}
```

**Phase 1 — HF Gemma4 loads and generates**  
`tests/configs/gemma4_hf.json`:
```json
{
  "model": "/home/emo/Downloads/test_models/2/gemma-4-E4B-it",
  "dtype": "f16",
  "prompt": "Say exactly: TEST_PASS",
  "gen": 20,
  "temp": 0.0,
  "ctx": 512,
  "flash_attn": true
}
```

**Phase 4 — Quantize + save**  
`tests/configs/quant_q4km.json`:
```json
{
  "model": "/home/emo/Downloads/test_models/2/gemma-4-E4B-it",
  "dtype": "q4_k_m",
  "save_on_load": "/tmp/zllm2_test_q4km.gguf",
  "prompt": "Say exactly: TEST_PASS",
  "gen": 20,
  "temp": 0.0
}
```

**Phase 5 — Server responds**  
`tests/configs/serve_basic.json`:
```json
{
  "model": "/home/emo/Downloads/Qwen3.5-9B.Q4_K_M.gguf",
  "serve": true,
  "serve_port": 18080,
  "_test_curl": "POST /v1/chat/completions"
}
```
(test script sends a curl request after server starts, checks response contains `content`)

**Phase 6 — DFlash baseline tok/s**  
`tests/configs/dflash_qwen35.json`:
```json
{
  "model": "/home/emo/Downloads/Qwen3.5-27B.Q4_K_M.gguf",
  "draft": "/home/emo/Downloads/Qwen3.5-27B-DFlash",
  "dflash": true,
  "bench": "humaneval",
  "temp": 0.0,
  "gen": 256,
  "ctx": 2048,
  "_test_min_toks": 80
}
```

---

## 17. Implementation Phases

### Phase 0 — Foundation (1 day)
**Goal**: build system works, GGUF loads, tokens generate.

Tasks:
- [x] Init repo at `/mnt/data1/projects/llm/zllm2/`
- [x] `build.zig`: link llama.cpp, CUDA
- [x] `build.zig`: import vendored `third_party/zigzag` module
- [x] `main.zig`: parse `-c`, `-m`, `-p`, `--no-tui` flags
- [x] `model/loader.zig`: detect GGUF vs dir; for GGUF call `llama_model_load_from_file` with mmap
- [x] `config/schema.zig`: parse JSON config, apply defaults
- [x] Print first N tokens to stdout with `--no-tui`

Deliverable: `zllm2 -m model.gguf -p "hello" --no-tui` prints tokens  
Test: `tests/configs/smoke_gguf.json`

---

### Phase 1 — Generic HF Loader + Weight System (3-4 days)
**Goal**: any safetensors model loads, weights accessible as named ggml tensors.

Tasks:
- [x] `model/safetensors.zig`: header parser, mmap shard manager
- [x] `model/arch_table.zig`: Arch struct + entries for Llama3, Qwen3.5, Gemma4
- [x] `model/hf_bridge.zig`:
  - detect `architectures[0]` from config.json
  - build gguf_ctx from arch meta table
  - pattern-match tensor names using `{N}` expansion
  - `setTensorData` callback: BF16→F16/F32, streaming row-by-row
  - token_embd stays CPU-mmap'd
- [x] `model/weights.zig`: `ModelWeights` + `LayerWeights` structs, populate from loaded tensors
- [x] `model/kv_cache.zig`: allocate K/V buffers as ggml tensors on GPU
- [x] `model/quantize.zig`: stub (f16 only for now)
- [x] `model/graphs/fallback.zig`: `llama_decode`-based fallback for any arch
- [x] Wire into `loader.zig`: after load, populate `ModelWeights`, alloc `KvCache`

Deliverable: `zllm2 -m /hf/gemma4 -p "hello" --no-tui` generates tokens via fallback graph  
Test: `gemma4_hf.json`, `qwen35_hf.json`, `llama3_hf.json`

### Phase 1b — First Level 2 Graph: Llama3 (2-3 days)
**Goal**: one full Level 2 graph working end-to-end, proving the architecture.

Tasks:
- [ ] `model/graphs/interface.zig`: `GraphBuilder` interface, arch dispatch
- [ ] `model/graphs/llama3.zig`:
  - `buildPrefill`: token embed → N×[RMSNorm → RoPE GQA attn → RMSNorm → SwiGLU] → RMSNorm → logits
  - `buildDecode`: same graph, single token, reads K/V from `KvCache`
  - all ops: `ggml_norm_rms`, `ggml_mul_mat`, `ggml_rope`, `ggml_flash_attn_ext`, `ggml_silu`, `ggml_mul`
- [ ] Integrate into execution loop, replace fallback for llama3 arch
- [ ] Verify tok/s matches fallback (parity check)

Deliverable: Llama3 runs via Level 2 graph at same speed as `llama_decode`  
Test: `llama3_hf.json` with `--bench-parity` flag: assert <1% tok/s difference vs fallback

### Phase 1c — Model Matrix Validation + Output Quality Gate (0.5-1 day)
**Goal**: verify Phase 0/1 runtime against most local models (`/home/emo/Downloads/test_models/models`) with repeatable logs.

Tasks:
- [x] Add `tests/run_model_matrix.sh`:
  - auto-discover GGUF files (exclude tokenizer vocab `.gguf`) and safetensors dirs
  - run models sequentially with `--no-tui` and fixed deterministic prompt (`temp: 0.0`)
  - enforce minimum generation quality checks (length, printable ratio, word count, repetition guard)
  - continue on failure and collect per-model status
- [x] Write one new log per model run under `tests/results/runN/` using model names (`gguf-<slug>.log` / `safetensors-<slug>.log`)
- [x] Write per-sweep summary log with pass/fail totals and failed model names
- [x] Keep `zlab_Qwen3.5-27B-DFlash` out of this sweep (reserved for Phase 6 DFlash tests)

Deliverable: full sweep logs under `tests/results/runN/` with explicit pass/fail reasons per model  
Test: run `tests/run_model_matrix.sh /home/emo/Downloads/test_models/models` and verify every discovered model got a model-named log

---

### Phase 2 — TUI with ported zigzag (2 days)
**Goal**: interactive TUI chat backed by the vendored Zig 0.16 `zigzag` port.
Implementation note: the TUI backend is the vendored/ported `zigzag` module; keep the original Phase 2 deliverables and tests, only swap the terminal stack.

Tasks:
- [x] Add vendored `zigzag` as a local module in `build.zig`
- [x] `cli/tui.zig`: zigzag event loop, chat transcript, prompt input, status line
- [x] Shared generation helper for stdout and TUI replies
- [x] `--tui-smoke`: start the TUI, draw one frame, and exit cleanly for verification
- [x] Keep `--no-tui` and existing runtime tests unchanged

Deliverable: `zllm2 -c gemma4.json` opens the zigzag TUI, accepts input, and renders chat content  
Test: `rtk zig build`, `rtk bash tests/run_tests.sh`, and `rtk zig build run -- -c tests/configs/smoke_gguf.json --tui-smoke`

---

### Phase 3 — Inspection Commands (1-2 days)
**Goal**: `/showmodel`, `/chat-template`, `/showmodel --yaml`.

Tasks:
- [ ] `cli/diagram.zig`: walk gguf hparams → ASCII block diagram
- [ ] `model/arch_yaml.zig`: serialize gguf hparams → YAML; parse YAML overrides
- [ ] Wire `/showmodel`, `/showmodel --yaml`, `/chat-template`, `/config` commands
- [ ] `/reload --arch` applies YAML overrides before `llama_model_init_from_user`

Deliverable: `/showmodel` prints correct layer diagram for Llama3 and Gemma4  
Test: assert diagram output contains expected layer count and arch name

---

### Phase 4 — Quantization + Save (1-2 days)
**Goal**: load any dtype, save GGUF.

Tasks:
- [ ] `model/quantize.zig`: implement `ggml_quantize_chunk` wrappers for Q4_K_M, Q8_0, Q5_K_M
- [ ] Wire `dtype` config field through `setTensorData`
- [ ] `/save <path>` → `gguf_write_to_file`
- [ ] `save_on_load` config field
- [ ] `/set dtype` + `/reload` cycle

Deliverable: load BF16 safetensors → `/save q4.gguf` → reload GGUF → same outputs  
Test: `quant_q4km.json`

---

### Phase 5 — OpenAI Server (1 day, zaica accelerates)
**Goal**: `POST /v1/chat/completions` streaming works.

Tasks:
- [ ] `serving/server.zig`: minimal HTTP/1.1 accept loop, parse headers (~200 lines)
- [ ] Copy + adapt `zaica/src/client/sse.zig` → `serving/sse.zig`: SSE emitter for streaming responses
- [ ] Copy + adapt `zaica/src/client/message.zig` → `serving/message.zig`: ChatMessage request/response types
- [ ] `serving/openai.zig`: parse request JSON, call `decode()`, emit SSE using `sse.zig`
- [ ] `GET /v1/models`
- [ ] `/serve [port]` command + `--serve` flag + `serve: true` config

Deliverable: `curl -X POST http://localhost:8080/v1/chat/completions` streams tokens  
Test: `serve_basic.json`

---

### Phase 5b — MoE Architecture Support (3-4 days)
**Goal**: Mixtral, Qwen3-MoE, DeepSeek-V2/V3 all work; CPU offload works.

Tasks:
- [ ] `model/moe.zig`: shared MoE dispatch — `ggml_mul_mat_id` wrapper, top-k routing, weighted combine
- [ ] Copy `moe_topk.cu` from ktransformers, add `extern fn` in `kernels.zig`
- [ ] Copy `dequant.cu` + `gptq_marlin.cu` from ktransformers for GPTQ support
- [ ] `model/graphs/mixtral.zig`: softmax top-2 sparse MoE forward pass
- [ ] `model/graphs/qwen3moe.zig`: 128-expert, top-8, shared expert variant
- [ ] `model/graphs/deepseek2.zig`: MLA attention + group expert selection (256 experts)
- [ ] `model/graphs/llama4.zig`: interleaved dense + MoE layers
- [ ] `moe_expert_dtype`: expert-specific dtype in `setTensorData`
- [ ] `moe_experts_offload`: allocate expert tensors on CPU backend via `ggml_backend_sched`
- [ ] `moe_experts_on_gpu`: partial GPU/CPU expert split

Deliverable: `zllm2 -c mixtral_moe.json` and `zllm2 -c qwen3moe_hf.json` generate tokens  
Test: `mixtral_moe.json`, `qwen3moe_hf.json`, `deepseek_cpu_offload.json`

---

### Phase 6 — DFlash (4-5 days)
**Goal**: Qwen3.5-27B + DFlash draft at >100 tok/s.

Tasks:
- [ ] `dflash/draft.zig`: safetensors loader for draft model (port `safetensors_draft.cpp`)
- [ ] `dflash/ddtree.zig`: DDTree budget-22 (port from dflash C++)
- [ ] `dflash/decode.zig`: block-diffusion decode loop (port `qwen3_dflash_graph.cpp`)
- [ ] Rollback: snapshot/restore KV cache + SSM state via CUDA kernels
- [ ] `/enable dflash --draft <path>` command
- [ ] Wire into main decode loop

Deliverable: Qwen3.5-27B + DFlash > 100 tok/s on RTX 3090  
Test: `dflash_qwen35.json` — assert tok/s > 80

---

### Phase 7 — Benchmarks (1-2 days)
**Goal**: HumanEval/GSM8K/Math500 from local JSONL.

Tasks:
- [ ] `bench/datasets.zig`: JSONL loaders, prompt formatters
- [ ] `bench/runner.zig`: run N samples, collect tok/s + AL
- [ ] Download and store datasets in `datasets/` as JSONL
- [ ] `/bench` command + `--bench` CLI flag + `bench` config field

Deliverable: `--bench humaneval --samples 10` prints results table  
Test: `bench_humaneval.json` — assert mean tok/s within 10% of known baseline

---

### Phase 8 — Tools (1 day, mostly zaica ports)
**Goal**: model can call websearch and bash from chat.

Most of this phase is adapting zaica code, not writing from scratch.

Tasks:
- [ ] Copy + adapt `zaica/src/tools.zig` → `src/tools/executor.zig` (permission system, tool defs, bash/file tools)
- [ ] Copy + adapt `zaica/src/node.zig` → `src/tools/agent_loop.zig` (replace HTTP call with local `decode()`)
- [ ] Copy + adapt `zaica/src/client/http.zig` → `src/tools/http.zig` (for websearch HTTP GET)
- [ ] `tools/websearch.zig`: DuckDuckGo JSON API using `http.zig` (~80 lines)
- [ ] Inject tool schemas into system prompt; parse tool calls from model output tokens
- [ ] `/enable websearch|bash` commands + `tools` config field
- [ ] Port zaica Zig 0.15 → 0.16 API fixes across all copied files (~2h)

Deliverable: ask model to search for something, assert tool is invoked  
Test: `tools_websearch.json`

---

## 18. Open Questions

1. **DFlash generalization**: initial target is Qwen3.5-27B only (same as existing dflash). Which other target/draft pairs do you want after that?

2. **Web search API**: DuckDuckGo Instant Answer JSON (free, no key) or SearXNG (self-hosted)? DuckDuckGo is simpler to start.

3. **Tool calling format**: use a simple `<tool_call name="websearch"><query>...</query></tool_call>` XML tag format parsed from model output, or implement full OpenAI function-calling JSON schema? The XML approach works with any model; function-calling requires model support.

4. **Arch YAML — compute graph editing**: layer duplication/reordering requires remapping tensor lookups. Hparam overrides (head counts, dims) are straightforward. Do you want full layer reordering in Phase 3, or just hparam overrides?

5. **Syntax highlighting in code blocks**: adds ~300 lines and a keyword table per language. Worth it for Phase 2 or defer?

6. **Config format**: currently JSON (zero extra deps, `std.json`). YAML is more readable but needs a ~300 line parser. Keep JSON?

---

## 19. Achievability Assessment

| Feature | Confidence | Risk | Notes |
|---------|-----------|------|-------|
| GGUF load + mmap | High | None | Proven in dflash |
| Generic HF loader | High | Low | Data tables, 3 archs validate pattern |
| On-the-fly quant | High | Low | `ggml_quantize_chunk` proven in llama.cpp |
| Save GGUF | High | None | `gguf_write_to_file` exists |
| libvaxis TUI | High | Low | Library handles all terminal complexity |
| Markdown streaming | High | Low | State machine, ~150 lines |
| /showmodel diagram | High | None | Read-only from hparams |
| Arch YAML edit | Medium | Medium | Hparam overrides easy; layer graph harder |
| OpenAI server | High | Low | Simple HTTP, ~300 lines |
| DFlash Qwen3.5-27B | High | Medium | C++→Zig port, CUDA kernel wrapping |
| DFlash generalization | Medium | High | Depends on draft model availability |
| Benchmarks | High | None | JSONL → run → print |
| Tools (websearch/bash) | Medium | Low | HTTP client + XML parsing |

**Total estimated time**: 3–4 weeks focused.  
**Biggest risk**: DFlash CUDA kernel wrapping in Zig. Mitigate by calling them as extern C functions from a thin `.cu` shim compiled separately, linked into the binary — avoids porting CUDA to Zig.

---

## 20. Dependencies

| Dep | Version | How |
|-----|---------|-----|
| Zig | 0.16.0-dev | compiler |
| llama.cpp | current main | git submodule, C API only |
| libvaxis | 0.5.1 | `build.zig.zon` |
| CUDA | 12+ | system, via ggml |
| zaica (partial) | local | copy specific files, not a dep |
| ktransformers CUDA | local | copy 3 `.cu` files, Apache 2.0 |

`build.zig.zon`:
```zig
.{
    .name = .zllm2,
    .version = "0.1.0",
    .dependencies = .{
        .vaxis = .{
            .url = "git+https://github.com/rockorager/libvaxis#v0.5.1",
            .hash = "...",
        },
    },
}
```

---

## 21. Code Borrowed from zaica

zaica (`/mnt/data1/projects/llm/zaica`) is a pure-Zig multi-provider LLM API client with agentic tooling. It is not an inference engine, but it contains ~3,000 lines of well-tested Zig that directly solve zllm2 subsystems. We copy specific files rather than taking a dependency — zaica uses Zig 0.15 and we are on 0.16, so minor API updates needed.

### 21.1 Files to Copy + Adapt

| zaica source | zllm2 destination | Adaptation needed | Saves |
|-------------|-------------------|-------------------|-------|
| `src/client/sse.zig` | `src/serving/sse.zig` | Rename types, keep SSE parser logic | ~400 lines |
| `src/client/http.zig` | `src/tools/http.zig` | Keep streaming HTTP client for websearch | ~380 lines |
| `src/client/message.zig` | `src/serving/message.zig` | ChatMessage builder for OpenAI response format | ~310 lines |
| `src/node.zig` | `src/tools/agent_loop.zig` | Adapt LLM call → tool exec loop to use local model | ~700 lines |
| `src/tools.zig` | `src/tools/executor.zig` | Keep tool framework + permission system verbatim | ~620 lines |
| `src/session.zig` | `src/cli/session.zig` | JSONL chat history save/resume | ~540 lines |
| `src/config/loader.zig` | `src/config/loader.zig` | 5-layer merge pattern, adapt field names | ~340 lines |
| `src/io.zig` | `src/cli/terminal.zig` | Raw mode, scroll regions, spinner — supplement libvaxis | ~390 lines |
| `lib/zefx/src/root.zig` | `src/cli/state.zig` | Reactive state for TUI status bar + streaming | ~1190 lines |

**Total: ~4,870 lines saved** (before adaptation, ~3,500 after Zig 0.16 updates).

### 21.2 What Each Piece Solves

**`sse.zig` → `src/serving/sse.zig`**  
Used in two places: (1) our OpenAI server sends SSE to clients, (2) the websearch tool may call external APIs that return SSE. zaica's parser handles content deltas, tool_call deltas, reasoning_content, and token usage — all already tested against OpenAI/DeepSeek/GLM formats.

**`http.zig` → `src/tools/http.zig`**  
The websearch tool needs to make HTTP GET requests and parse JSON. zaica's HTTP client does streaming reads from TCP, handles chunked transfer, and accumulates response bodies. Saves writing `std.net` boilerplate.

**`node.zig` → `src/tools/agent_loop.zig`**  
zaica's agentic loop handles: call LLM → parse tool calls from response → execute tool → feed result back → repeat. The hooks (`on_tool_calls`, `on_tool_result`, `on_cancel`) map cleanly to our TUI events. We adapt `node.zig` to call our local `decode()` instead of an HTTP API — the loop logic stays identical.

**`tools.zig` → `src/tools/executor.zig`**  
The tool permission system (safe/write/dangerous tiers, user confirmation prompt, `--yolo` auto-approve flag) is exactly what `/enable bash` needs. Tool definitions (bash, read_file, write_file, search_files) are directly usable. We add `websearch` as a new tool entry.

**`session.zig` → `src/cli/session.zig`**  
JSONL format: first line = session metadata (model, date, token counts), subsequent lines = ChatMessage objects. `/config-save` and session resume (`/load-config`) map to zaica's `--continue` flag logic. Near-verbatim copy.

**`config/loader.zig` → `src/config/loader.zig`**  
The 5-layer merge (struct defaults → `~/.config/zllm2/config.json` → `.zllm2.json` → `ZLLM2_*` env vars → CLI flags) is the pattern we want. Adapt field names to our schema, keep the merge algorithm.

**`zefx` → `src/cli/state.zig`**  
Reactive state for the TUI: a `Store<StatusBar>` updated by inference events (tok/s, VRAM, ctx fill), with an `Effect` that rerenders the status bar. Cleaner than manual state threading. The comptime type-safety catches wrong event types at compile time.

### 21.3 What NOT to Copy

- `src/repl.zig` (2153 lines) — we use libvaxis instead; zaica's raw terminal REPL is replaced by libvaxis `TextInput` + `TextView`
- `src/chain.zig` — not needed (pipeline orchestration out of scope for now)
- `src/agent.zig` — subsumed by `node.zig` adaptation
- `src/client/mod.zig` — high-level API wrapper not needed (we adapt `node.zig` directly)
- Provider presets (`config/presets.zig`) — we don't call remote providers

### 21.4 Zig 0.15 → 0.16 Changes Needed

zaica targets Zig 0.15.2. Known breakages in 0.16:
- `std.heap.GeneralPurposeAllocator` → removed, use `std.heap.DebugAllocator` or arena
- `ArrayList.init(allocator)` → `.empty` + `list.deinit(allocator)`
- `std.io.getStdIn().reader()` API changes
- `std.net.tcpConnectToHost` signature may differ

These are mechanical fixes, estimated ~2 hours total across all copied files.

---

## 22. Reference: lemonade

lemonade (`/mnt/data1/projects/llm/lemonade`) is an AMD ROCm-focused multi-engine inference server. Language: C++ (34K) + TypeScript/React (16K) + Python tests (11K). **Not reusable as code** (C++, process-orchestration model, no ggml graphs), but contains several excellent design patterns worth following.

### 22.1 Architecture

lemonade is a subprocess orchestrator — it spawns llama.cpp, whisper.cpp, stable-diffusion.cpp as child processes and proxies HTTP to them. zllm2 does not use this pattern (we call llama.cpp as a library). Ignore the orchestration layer entirely.

### 22.2 HTTP Server Patterns (from `server.cpp`, 3,853 lines)

lemonade registers every endpoint four times:
```cpp
// exact + trailing slash, both HTTP methods
server.Post("/v1/chat/completions",   handler);
server.Post("/v1/chat/completions/",  handler);
server.Get( "/v1/chat/completions",   handler);
server.Get( "/v1/chat/completions/",  handler);
```
Copy this pattern in `src/serving/routes.zig` — client SDKs send both methods and both slash variants in the wild.

**SSE flush pattern**: lemonade calls `res.set("Content-Type", "text/event-stream")`, then sends chunks as `data: {json}\n\n` with explicit `res.flush()` after each. Our `sse.zig` already does this but the explicit flush is easy to forget — add a `flushChunk()` helper.

**CORS + auth**: lemonade adds `Access-Control-Allow-Origin: *` and `Authorization: Bearer` token check on every request in a global middleware. Add both from day one; they're each 5 lines and save pain later.

**Ollama `/api/chat` compatibility**: lemonade maps Ollama format → OpenAI format in a thin adapter (~80 lines). Worth adding so tools that target Ollama (Continue.dev, Open WebUI) work out of the box.

### 22.3 Model Registry (from `model_manager.cpp`, 3,170 lines + `server_models.json`, 1,417 lines)

lemonade maintains a JSON registry of known model IDs with download URLs, quantization variants, and hardware requirements. **We don't need a model registry** (user specifies paths explicitly), but the download/resume pattern is useful:

```cpp
// Resume partial downloads with HTTP Range header
curl_easy_setopt(curl, CURLOPT_RESUME_FROM_LARGE, existing_file_size);
```

When we add HF Hub auto-download in a later phase, implement resume-from-range from the start — large models are multi-GB and connections drop.

### 22.4 System Hardware Detection (from `system_info.cpp`, 2,822 lines)

lemonade detects: CPU model/cores/cache, DRAM size/speed, GPU vendor/VRAM, NPU availability. Implementation: reads `/proc/cpuinfo`, `/sys/class/drm/`, `nvidia-smi` subprocess, `rocm-smi` subprocess, Windows WMI via COM on Windows.

For our live stats bar we need GPU VRAM (used/total). Simplest approach: parse `nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader` output — lemonade confirms this is reliable across driver versions. Use a 2-second poll interval (lemonade uses 1s; 2s is sufficient and cheaper).

### 22.5 What to Take from lemonade

| Pattern | File | Apply in zllm2 |
|---------|------|----------------|
| Quad-prefix endpoint registration | `server.cpp:L180` | `src/serving/routes.zig` |
| Explicit SSE flush per chunk | `server.cpp:L410` | `src/serving/sse.zig` |
| Global CORS + Bearer auth middleware | `server.cpp:L95` | `src/serving/routes.zig` |
| Ollama `/api/chat` adapter | `server.cpp:L620` | `src/serving/compat.zig` |
| HTTP Range resume for downloads | `model_manager.cpp:L890` | future HF downloader |
| `nvidia-smi` VRAM polling | `system_info.cpp:L1240` | `src/cli/stats.zig` |

### 22.6 What NOT to take from lemonade

- Subprocess orchestration model — we link llama.cpp directly
- C++ HTTP server (cpp-httplib) — we write ~300 lines of Zig with `std.net`
- TypeScript/React frontend — our TUI is libvaxis
- Python tests — our tests are Zig + config-driven shell scripts
- ROCm/HIP-specific code — we target CUDA

---

## 24. Repo Setup

```bash
mkdir -p /mnt/data1/projects/llm/zllm2
cd /mnt/data1/projects/llm/zllm2
git init
git checkout -b main

# llama.cpp as submodule
git submodule add /mnt/data1/projects/llm/llama.cpp deps/llama.cpp
```

This is a **separate repo** from zllm. The existing zllm stays as-is.
