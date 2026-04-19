# Custom Graph Architecture Plan
# zllm2 — Editable Model Architecture via YAML + ggml

## Motivation

llama.cpp's `llama_decode` is a black box — it runs the full forward pass with no user control
over individual layer components. This plan adds a second execution path: a **custom ggml graph**
built at runtime from a user-edited YAML blueprint. The weights are still loaded by llama.cpp
(no reimplementing GGUF loading), but the computation graph is constructed op-by-op from ggml
primitives, with the architecture driven entirely by the YAML.

---

## Key API: `llama_get_model_tensor`

```c
struct ggml_tensor * llama_get_model_tensor(struct llama_model * model, const char * name);
```

This is the bridge. It returns a live `ggml_tensor*` pointing into llama.cpp's loaded weight
memory. Standard GGUF tensor names follow the pattern:

```
token_embd.weight
blk.{L}.attn_norm.weight
blk.{L}.attn_q.weight
blk.{L}.attn_k.weight
blk.{L}.attn_v.weight
blk.{L}.attn_output.weight
blk.{L}.ffn_norm.weight
blk.{L}.ffn_gate.weight        # dense or shared expert
blk.{L}.ffn_up.weight
blk.{L}.ffn_down.weight
blk.{L}.ffn_gate_exps.weight   # MoE experts (stacked)
blk.{L}.ffn_up_exps.weight
blk.{L}.ffn_down_exps.weight
blk.{L}.ffn_gate_shexp.weight  # shared expert
blk.{L}.ffn_up_shexp.weight
blk.{L}.ffn_down_shexp.weight
blk.{L}.ffn_gate_inp.weight    # MoE router
output_norm.weight
output.weight
```

---

## Architecture

```
User edits arch.yaml
       ↓
zllm2 --arch arch.yaml -m model.gguf
       ↓
arch_yaml.parseOverrides(yaml)    ← parse edits
       ↓
custom.GraphBuilder.init(model, blueprint)
  - for each layer: resolve weight tensors via llama_get_model_tensor
  - build ggml_cgraph with ops as specified in YAML
       ↓
ggml_backend_graph_compute(backend, graph)
       ↓
sample next token → repeat
```

### Execution backends

ggml supports CPU, CUDA, Metal. We use the same backend already initialized by llama.cpp.
The function `llama_get_model(ctx)` → `ggml_get_backend_buffer` gives us the backend.
We create our own `ggml_context` for the graph nodes (not for weight storage).

---

## YAML Blueprint Format (editable fields)

```yaml
# Top-level overrides
rope:
  freq_base: 500000.0       # change RoPE base frequency
  freq_scale: 1.0

# Per-layer overrides (if absent, use model defaults)
layers:
  - index: 0
    skip: false             # set true to remove this layer entirely
    components:
      - name: attn_norm
        type: rms_norm
        epsilon: 1e-5
      - name: attn_q
        type: linear
        weight_source: blk.0.attn_q.weight   # can point to another layer/model
      - name: ffn_act
        type: gelu           # was: silu — change activation
      - name: ffn_gate
        type: linear
        skip: true           # remove gate proj → plain FFN
  - index: 1
    duplicate_of: 0          # reuse layer 0's weights (weight sharing)

# MoE overrides
moe:
  expert_count: 256
  expert_used_count: 4       # was 8 — use fewer experts
  shared_expert: true
  router_type: softmax       # softmax | topk | random

# Attention overrides
attention:
  sliding_window: 4096       # enable SWA on all layers (null = disabled)
  sliding_window_layers: [0,2,4,6,8,10]   # or per-layer
  type: full                 # full | sliding | linear
```

---

## Implementation Plan

### Phase 1 — Baseline custom graph (dense, Llama-family)

**Goal**: Reproduce `llama_decode` output exactly using custom ggml ops.
This validates the approach before any arch edits are allowed.

Files:
- `src/model/graphs/custom.zig` — main custom graph builder
- `src/model/graphs/ops.zig` — ggml op wrappers (rms_norm, rope, attention, ffn)

Steps:
1. Create `ggml_context` for graph nodes (separate from weight memory)
2. Get backend from `llama_get_model` → `ggml_model_get_backend_buffer`
3. Implement token embedding lookup: `ggml_get_rows(token_embd, input_ids)`
4. For each layer:
   a. attn_norm: `ggml_rms_norm` + `ggml_mul` (weight)
   b. Q/K/V projections: `ggml_mul_mat`
   c. RoPE: `ggml_rope_ext`
   d. Attention scores: `ggml_mul_mat(Q, K)` → scale → `ggml_soft_max` → `ggml_mul_mat(scores, V)`
   e. KV cache: write K/V into pre-allocated cache tensors, read past positions
   f. O projection: `ggml_mul_mat`
   g. Residual: `ggml_add`
   h. ffn_norm: `ggml_rms_norm` + `ggml_mul`
   i. FFN: gate/up projections → activation → `ggml_mul` → down projection
   j. Residual: `ggml_add`
5. output_norm + output projection → logits
6. Verify: same token output as baseline for same prompt

### Phase 2 — YAML-driven arch edits (dense)

Wire `arch_yaml.parseOverrides` into `custom.GraphBuilder`:
- Per-layer `skip: true` → omit that layer's ops
- `duplicate_of: N` → reuse layer N's weight tensors for this layer
- `ffn_act: gelu/relu/silu` → swap activation op
- `rope.freq_base` override → pass to `ggml_rope_ext`
- `attention.sliding_window` → mask attention beyond window
- `weight_source: blk.X.Y.weight` → fetch tensor from different layer

### Phase 3 — MoE support

MoE forward pass:
1. Router: `ggml_mul_mat(x, ffn_gate_inp)` → softmax → topk → expert indices + weights
2. Expert dispatch: gather rows from stacked expert weight tensors (`ffn_gate_exps`, etc.)
3. Shared expert: always-active dense FFN added to expert output
4. YAML edits: `expert_used_count`, `shared_expert: false`, `router_type`

### Phase 4 — Cross-model weight transplant

Allow `weight_source: /path/to/other.gguf:blk.0.attn_q.weight`:
- Load second model's weights into a read-only ggml context
- Resolve named tensor, verify shape compatibility
- Use it as weight in the current graph

### Phase 5 — TUI integration

- `/reload --arch edited.yaml` → rebuild custom graph with new blueprint
- `/showmodel --graph` → show which ops are active in current graph
- Save modified blueprint back to file after edits

---

## KV Cache Strategy

The main complexity in Phase 1. Options:

**Option A: Own KV cache** (full control, needed for Phase 2+ edits)
- Allocate `ggml_tensor` for K and V per layer, size `[head_dim, n_kv_heads, n_ctx]`
- On each step, write new K/V at position `n_past`, read `[0..n_past+1]`
- Pros: fully controllable, can change cache size/type per layer
- Cons: ~2× VRAM overhead vs llama.cpp's fused KV cache

**Option B: Hybrid** (use llama.cpp's KV cache, custom forward)
- Call `llama_kv_cache_seq_*` APIs to manage positions
- Build graph using cached K/V tensors exposed by llama.cpp internals
- Cons: tight coupling to llama.cpp internals, may break across versions

**Decision: Option A for custom graph path, Option B for fallback.**

---

## Test Models (from matrix)

| Model | Arch | Type | Key Test |
|---|---|---|---|
| LFM2.5-350M-Q8_0 | lfm2 | Dense, small | Baseline validation, fast iteration |
| Qwen3.5-0.8B-BF16 | qwen3 | Dense, small | Baseline validation |
| Bonsai-8B | qwen3 | Dense | Layer skip, activation swap |
| Qwen3.5-4B | qwen3 | Dense | Duplicate layers, SWA |
| Qwen3.5-27B | qwen3 | Dense | RoPE override |
| Qwen3.5-35B-A3B | qwen35moe | MoE (256 exp, top-8) | Expert count edit, router |
| Qwen3.6-35B-A3B | qwen35moe | MoE | Shared expert toggle |
| Nemotron-Cascade-30B | nemotron_h_moe | MoE (128 exp) | Expert weights scale |
| Gemma-4-E4B | gemma4 | Dense+SWA interleaved | SWA window change |
| Darwin-27B | qwen3 | Dense large | Cross-layer weight transplant |

---

## Test Cases

See: `tests/arch_edit/` — each test is a directory with:
- `arch.yaml` — the edited blueprint
- `run.sh` — runs inference, compares output
- `expected_behavior.md` — what we expect to happen

### TC-01: Baseline (no edits) — validate custom graph == fallback
**Model**: LFM2.5-350M-Q8_0
**Edit**: None — run with default arch.yaml (generated by --inspect-yaml)
**Expected**: Token-for-token identical output to `--no-tui` baseline
**Pass criterion**: Exact match on greedy (temp=0) output for 32 tokens

### TC-02: RoPE frequency override
**Model**: Qwen3.5-0.8B-BF16
**Edit**: `rope.freq_base: 1000000.0` → `rope.freq_base: 10000.0`
**Expected**: Model still generates coherent text (lower quality expected), no crash
**Pass criterion**: Output is non-empty, length > 10 tokens, no OOM/crash

### TC-03: Activation function swap — silu → gelu (all layers)
**Model**: LFM2.5-350M-Q8_0
**Edit**: All layers `ffn_act.type: gelu`
**Expected**: Model still generates text, different from baseline (quality may degrade)
**Pass criterion**: Non-empty output, different from TC-01 baseline

### TC-04: Activation function swap — per-layer (layers 0-7 silu, 8-15 gelu)
**Model**: LFM2.5-350M-Q8_0
**Edit**: Layers 8-15 `ffn_act.type: gelu`, others `silu`
**Expected**: Coherent-ish output, measurably different from TC-01 and TC-03
**Pass criterion**: Non-empty output

### TC-05: Layer skip — remove last 4 layers
**Model**: LFM2.5-350M-Q8_0 (16 layers)
**Edit**: Layers 12-15 `skip: true`
**Expected**: Faster inference, degraded but non-empty output
**Pass criterion**: Non-empty output, ~25% fewer ops (measurable via timing)

### TC-06: Layer skip — remove first 2 layers
**Model**: LFM2.5-350M-Q8_0
**Edit**: Layers 0-1 `skip: true`
**Expected**: Degraded output, still non-crashing
**Pass criterion**: Non-empty output, no crash

### TC-07: Duplicate layers — repeat layer 0 twice
**Model**: Qwen3.5-0.8B-BF16 (28 layers)
**Edit**: Insert `duplicate_of: 0` for a new entry after layer 0 (29 total)
**Expected**: Slightly different output from baseline, no crash
**Pass criterion**: Non-empty output, graph has 29 layer iterations

### TC-08: Duplicate layers — repeat last 8 layers (depth extension)
**Model**: Qwen3.5-0.8B-BF16
**Edit**: Layers 28-35 → `duplicate_of: 20..27` (36 total layers)
**Expected**: Different output from baseline, possibly more repetitive
**Pass criterion**: Non-empty output, no OOM crash

### TC-09: Sliding window attention — enable on all layers
**Model**: Bonsai-8B (Qwen3 arch)
**Edit**: `attention.sliding_window: 512` globally
**Expected**: Faster attention computation for long contexts, output changes
**Pass criterion**: Non-empty output at ctx=2048, no crash

### TC-10: Sliding window attention — alternating layers (even=full, odd=SWA)
**Model**: Qwen3.5-4B
**Edit**: Odd layers get `attention.type: sliding`, `sliding_window: 1024`
**Expected**: Hybrid attention similar to Gemma4 pattern
**Pass criterion**: Non-empty output

### TC-11: MoE expert count reduction — top-8 → top-2
**Model**: Qwen3.5-35B-A3B (256 experts, top-8)
**Edit**: `moe.expert_used_count: 2`
**Expected**: ~75% less FFN compute, faster tokens/s, lower quality output
**Pass criterion**: Non-empty output, measurable speedup vs baseline

### TC-12: MoE expert count increase — top-8 → top-16
**Model**: Qwen3.5-35B-A3B
**Edit**: `moe.expert_used_count: 16`
**Expected**: More compute, potentially higher quality
**Pass criterion**: Non-empty output, no OOM

### TC-13: MoE shared expert disable
**Model**: Qwen3.5-35B-A3B (has shared expert)
**Edit**: `moe.shared_expert: false`
**Expected**: Slightly different output (shared expert contribution removed)
**Pass criterion**: Non-empty output, different from baseline

### TC-14: MoE router type change — topk → random sampling
**Model**: Qwen3.6-35B-A3B
**Edit**: `moe.router_type: random`
**Expected**: Non-deterministic output even at temp=0 (random expert selection)
**Pass criterion**: Two runs produce different outputs

### TC-15: MoE expert weights scale change
**Model**: Nemotron-Cascade-30B (expert_weights_scale: 2.5)
**Edit**: `nemotron_h_moe.expert_weights_scale: 1.0`
**Expected**: Different output distribution, possibly more uniform
**Pass criterion**: Non-empty output

### TC-16: Residual connection removal — skip residual on layers 4-8
**Model**: Qwen3.5-0.8B-BF16
**Edit**: Layers 4-8: `residual: false` on both attn and ffn
**Expected**: Significant quality degradation (residuals are critical), but no crash
**Pass criterion**: Non-empty output (even if nonsensical)

### TC-17: Cross-layer weight transplant — use layer 0 attn_q in layer 8
**Model**: Bonsai-8B
**Edit**: Layer 8 `attn_q.weight_source: blk.0.attn_q.weight`
**Expected**: Subtly different output (same shape, different semantics)
**Pass criterion**: Non-empty output, shape check passes

### TC-18: Cross-model weight transplant — borrow a layer from compatible model
**Model primary**: Bonsai-8B (Qwen3, embd=4096)
**Model donor**: Qwen3.5-4B (Qwen3, embd=2048) — incompatible shape, expect rejection
**Model donor 2**: Qwen3.5-27B (Qwen3, embd=5120) — incompatible, expect rejection
**Edit**: Layer 0 `attn_q.weight_source: /path/donor.gguf:blk.0.attn_q.weight`
**Expected**: Shape mismatch → clear error message, no crash
**Pass criterion**: Error reported gracefully, no segfault

### TC-19: Cross-model transplant — compatible architecture
**Model primary**: LFM2.5-350M-Q8_0
**Model donor**: LFM2.5-350M-Q4_K_M (same arch, same shape, different quant)
**Edit**: Layer 0's ffn weights sourced from donor model
**Expected**: Output changes (quantization difference affects values)
**Pass criterion**: Non-empty output, no crash

### TC-20: Full arch replacement — all layers duplicated and reordered
**Model**: LFM2.5-350M-Q8_0 (16 layers)
**Edit**: Blueprint reorders layers: [0,2,4,6,8,10,12,14,1,3,5,7,9,11,13,15]
**Expected**: Different output (layer order matters), no crash
**Pass criterion**: Non-empty output

### TC-21: Attention type swap — GQA → full attention (broadcast KV heads)
**Model**: Bonsai-8B (32 heads, 8 KV heads)
**Edit**: `attention.type: full` (broadcast K/V to match Q head count)
**Expected**: More memory usage (8→32 KV heads), slightly different output
**Pass criterion**: Non-empty output, no OOM on ctx=512

### TC-22: Add explicit residual connection between non-adjacent layers
**Model**: Qwen3.5-0.8B-BF16
**Edit**: Layer 10 gets an additional residual from layer 5's output
**Expected**: Different output, no crash
**Pass criterion**: Non-empty output

---

## Test Infrastructure

```
tests/arch_edit/
├── tc-01-baseline/
│   ├── arch.yaml          ← generated by --inspect-yaml, unmodified
│   ├── expected.txt       ← captured baseline output (32 tokens, temp=0)
│   └── run.sh
├── tc-02-rope-override/
│   ├── arch.yaml
│   └── run.sh
...
└── run_all.sh             ← runs all TCs, reports PASS/FAIL
```

`run.sh` template:
```bash
#!/bin/bash
set -e
MODEL="$1"   # path passed from run_all.sh
BIN="$(dirname "$0")/../../zig-out/bin/zllm2"
ARCH="$(dirname "$0")/arch.yaml"

output=$("$BIN" -m "$MODEL" --arch "$ARCH" -p "Write a sentence about astronomy." \
         --no-tui --gen 32 --temp 0.0 2>/dev/null)

if [[ -z "$output" ]]; then
    echo "FAIL: empty output"
    exit 1
fi
echo "PASS: $output"
```

---

## CLI Integration

```bash
# Generate blueprint
zllm2 -m model.gguf --inspect-out arch.yaml

# Edit arch.yaml manually

# Run with edited arch (custom graph path)
zllm2 -m model.gguf --arch arch.yaml -p "Hello"

# TUI with editable arch
zllm2 -m model.gguf --arch arch.yaml
# then: /reload --arch new_arch.yaml
```

New flags:
- `--arch <yaml>` — load custom graph from blueprint (implies custom graph path)

---

## Risk Register

| Risk | Mitigation |
|---|---|
| `llama_get_model_tensor` returns null for some tensors | Graceful error + fallback to default |
| KV cache management bugs → wrong outputs | TC-01 exact-match test catches regressions |
| Shape mismatch in cross-model transplant | Validate shapes before building graph |
| MoE expert dispatch OOM | Cap expert_used_count at expert_count |
| Quantized tensor ops (ggml_mul_mat handles Q4/Q8 natively) | No special handling needed |
| ggml_context node budget exceeded for large models | Set node limit high (n_nodes = n_layer * 64) |

---

## Implementation Order

1. **TC-01** — custom graph baseline (dense, LFM2.5-350M)
2. **TC-02, TC-09** — RoPE + SWA overrides (easy, single param)
3. **TC-03, TC-04** — activation swap (single op change)
4. **TC-05, TC-06** — layer skip (conditional in builder loop)
5. **TC-07, TC-08** — layer duplication (weight reuse)
6. **TC-11, TC-12, TC-13** — MoE expert count + shared expert
7. **TC-14** — MoE router type
8. **TC-17, TC-18, TC-19** — cross-layer/model weight transplant
9. **TC-16, TC-21, TC-22** — advanced topology edits
