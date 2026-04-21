# Robust Loader + Architecture System Plan

## Goal

Finish zllm2 as a solid, low-rework system that:

- runs GGUF and HF safetensors models
- quantizes on the fly during loading without materializing the full model
- saves quantized GGUF output
- supports editable architectures and custom loading behavior
- supports DFlash and DDTree DFlash from `luce-megakernel`
- keeps interactive and non-interactive paths on the same runtime
- supports sessions, agent loop, and tools on top of one model/runtime core

This plan replaces the current direction of adding more architecture-specific compiled logic in Zig wherever possible.

## Investigation Summary

### What already exists

- `plan.md` already defines the correct product envelope, but it is outdated in one key place:
  - it says `llama.cpp C API (no source changes)`
  - that is no longer the right assumption
- zllm2 already has the beginning of the right extension seam:
  - [src/model/arch_yaml.zig](/mnt/data1/projects/llm/zllm2/src/model/arch_yaml.zig)
  - [src/model/graphs/custom.zig](/mnt/data1/projects/llm/zllm2/src/model/graphs/custom.zig)
  - [src/model/graphs/interface.zig](/mnt/data1/projects/llm/zllm2/src/model/graphs/interface.zig)
- your `llama.cpp` repo is now on branch `zllm2`, which matches the need for a maintained patch layer instead of pretending upstream APIs are enough.

### What is wrong with the current direction

- some recent fixes are architecture-specific in compiled Zig
- that is acceptable for debugging, but not as the stable architecture
- continuing this way will create:
  - repeated arch-specific branches in `arch_table.zig` and `hf_bridge.zig`
  - duplicated logic between zllm2 and llama.cpp
  - difficulty supporting future variants like DFlash / DDTree DFlash cleanly

### Key design constraint

We should not dump raw `ggml_cgraph` internals as the product format.

That format is:

- too low-level
- too tied to llama.cpp internals
- too unstable across backend/runtime refactors

Instead, we should export a stable **semantic architecture/graph IR** that zllm2 owns.

## Recommended Architecture

Use a 3-layer design.

### 1. Generic compiled runtime in zllm2

This remains compiled Zig/C++ and handles:

- unified loader entry
- safetensors shard reading
- streamed tensor load
- streamed quantization
- GGUF save
- runtime state
- TUI / CLI / server / sessions / tool loop
- graph execution dispatch
- DFlash / DDTree runtime integration

### 2. External architecture spec

This becomes the main declarative description for builtin and custom architectures.

Use YAML first because:

- zllm2 already has YAML-oriented code
- users want editable arch files
- it is easier to inspect and patch manually than JSON

This spec should describe:

- architecture id
- HF class matchers
- GGUF architecture id
- config field mappings
- tensor aliases
- optional tensors
- layer patterns
- tensor transforms
- tokenizer rules
- graph mode
- validation rules

### 3. Small llama.cpp `zllm2` patch layer

This is the minimum maintained patch set for flexibility.

It should expose:

- user-init tensor validation hooks
- graph export hooks
- graph post-build hooks
- direct save support from externally supplied tensors/metadata
- explicit optional/required tensor handling

This keeps llama.cpp as the execution backend for builtin graph semantics while letting zllm2 own the flexible loading/editing layer.

## Canonical Source of Truth

For less work and better robustness:

- llama.cpp remains the canonical source for builtin execution semantics
- zllm2 external specs become the canonical source for:
  - architecture overrides
  - custom transforms
  - custom graph selection
  - edited/custom models

This avoids reimplementing every builtin graph in Zig while still letting zllm2 own the extension system.

## Recommended External Spec Model

Unify the existing `arch_yaml` blueprint with loader metadata into one external spec family.

### `arch.yaml`

Describes the model architecture semantically.

Sections:

- `architecture`
- `match`
- `dimensions`
- `metadata`
- `tokenizer`
- `tensors`
- `layers`
- `transforms`
- `graph`
- `validation`

Example shape:

```yaml
architecture:
  id: lfm2
  gguf_arch: lfm2

match:
  hf_architectures: [Lfm2ForCausalLM]

dimensions:
  block_count: 16
  embedding_length: 1024

metadata:
  map:
    hidden_size: dimensions.embedding_length
    num_hidden_layers: dimensions.block_count

tokenizer:
  type: bpe
  added_tokens: merge_by_id

tensors:
  aliases:
    model.layers.{i}.self_attn.q_proj.weight: blk.{i}.attn_q.weight
  optional:
    - blk.{i}.attn_q_norm.weight

layers:
  pattern:
    source: config.layer_types
    values:
      full_attention:
        attention.type: full
      conv:
        block.type: conv

transforms:
  - kind: split
    when: architecture.id == deepseek2
    from: model.layers.{i}.self_attn.kv_b_proj.weight
    into:
      - blk.{i}.attn_k_b.weight
      - blk.{i}.attn_v_b.weight

graph:
  mode: llama_cpp_builtin

validation:
  require_all_required_tensors: true
  fail_on_unknown_required: true
```

### `graph.yaml`

Optional semantic graph blueprint for overrides or custom architectures.

This extends the current custom graph idea but keeps it semantic rather than raw ggml.

It should describe:

- execution phases
- layer components
- residual topology
- attention type per layer
- FFN/MoE type per layer
- custom op names

## What Must Stay Declarative vs Compiled

### Declarative

- HF architecture detection rules
- GGUF metadata mapping
- tensor aliases
- optional tensor flags
- tensor split/concat/stack/rename recipes
- tokenizer import behavior
- layer pattern rules
- graph mode selection
- graph component ordering for semantic blueprints

### Compiled in zllm2

- safetensors parser and mmap streaming
- row/chunk quantization
- backend uploads
- GGUF writer
- runtime/session/server/tool logic
- semantic-IR interpreter
- DFlash / DDTree integration
- custom op execution

### Compiled in llama.cpp `zllm2`

- builtin graph construction
- backend memory planning
- execution kernels
- graph export from builtin architectures
- user-init tensor instantiation and validation support

## Graph Export Strategy

Your idea about using llama.cpp graphs as the source is correct, but the export target should be a normalized semantic IR.

### Export source

- builtin llama.cpp graph builder
- tensor registry / metadata
- known layer schedule

### Export output

A stable semantic blueprint, not a raw `ggml_cgraph` dump.

Example categories:

- `attention.full`
- `attention.sliding`
- `attention.mla`
- `ffn.swiglu`
- `ffn.geglu`
- `ffn.moe`
- `norm.rms`
- `residual.add`
- `rope.standard`
- `rope.swa`

### Why this matters

This gives zllm2:

- a readable/editable representation
- stable tests
- compatibility across llama.cpp internal rewrites
- a clean path for custom graphs and future DDTree/DFlash modes

## Llama.cpp Patch Plan

Maintain a small explicit patch set on branch `zllm2`.

### Patch 1. Tensor contract API

Add a way to enumerate expected tensors with:

- name
- shape
- type
- required vs optional
- backend/storage hints

This prevents silent fallback allocations and makes HF loading deterministic.

### Patch 2. User-init validation

Before allocation, validate:

- all required tensors provided
- all shapes match
- all transformed tensors resolved

Fail early with exact diagnostics.

### Patch 3. Semantic graph export

Add an export hook that emits builtin graph structure into zllm2’s semantic IR.

### Patch 4. Graph override hook

Keep and formalize the existing post-build callback path so zllm2 can:

- patch builtin graphs
- install custom graph segments
- swap to custom op handlers

### Patch 5. Save-from-user-init path

Allow GGUF save directly from the externally supplied tensor set and metadata, without requiring a second full in-memory model materialization.

## Execution Plan

### Phase A. Freeze the architecture boundary

Outcome:

- stop adding more ad hoc compiled arch branches unless needed to unblock immediate validation

Tasks:

- update `plan.md` assumptions:
  - replace `no source changes` with `maintained llama.cpp zllm2 patch layer`
- document builtin-vs-external ownership
- document semantic graph IR vs raw ggml dump

### Phase B. External spec foundation

Outcome:

- one schema for architecture specs

Tasks:

- define YAML schema for:
  - architecture detection
  - metadata mapping
  - tensor aliases
  - transforms
  - graph mode
  - validation
- refactor current `arch_yaml.zig` from GGUF-dump-only toward reusable schema parsing
- add schema validation tests

### Phase C. Loader transform engine

Outcome:

- `hf_bridge.zig` becomes a generic executor of declarative transforms

Tasks:

- move alias rules out of compiled arch tables into external specs
- implement declarative transforms:
  - rename
  - split
  - concat
  - stack
  - reshape
  - pad
- make optional/required tensor rules explicit
- infer layer patterns from config/spec, not hardcoded branches

### Phase D. Quantize + save completion

Outcome:

- quantized load and quantized GGUF save are first-class and size-correct

Tasks:

- finish streamed quantized load for both quantized and non-quantized paths
- ensure allocated model size matches quantized tensor bytes, not original BF16/F32 size
- implement direct GGUF save from quantized user-init tensor set
- add save metadata validation and roundtrip tests

### Phase E. Builtin graph export/import

Outcome:

- builtin llama.cpp architectures can be exported into zllm2 semantic graph format

Tasks:

- implement semantic graph exporter in llama.cpp `zllm2`
- add importer/consumer in zllm2
- use exported graphs as the reference baseline for builtin arch specs

### Phase F. Architecture ports on top of the new system

Outcome:

- current broken/incomplete architectures get fixed in the right place

Priority order:

1. `lfm2`
2. `gemma4`
3. `deepseek2` / `glm`

Tasks:

- port current hardcoded knowledge into YAML specs
- use declarative transforms for:
  - LFM2 hybrid layer pattern
  - Gemma4 metadata/tensor mapping
  - DeepSeek2/GLM MoE merge and MLA split
- remove redundant compiled branches after parity is reached

### Phase G. DFlash / DDTree integration

Outcome:

- DFlash becomes a graph/runtime mode, not a one-off side system

Tasks:

- define graph modes:
  - `llama_cpp_builtin`
  - `zllm2_custom`
  - `dflash`
  - `ddtree_dflash`
- integrate `luce-megakernel` paths as compiled execution backends selected by external graph mode
- define which pieces must be exported declaratively vs remain backend-specific

### Phase H. Product runtime unification

Outcome:

- one model/runtime core used by:
  - TUI
  - non-interactive prompt mode
  - HTTP server
  - session management
  - agent/tool loop

Tasks:

- ensure all frontends consume the same model/session abstractions
- remove any duplicate load paths
- make lazy-load behavior consistent across TUI and CLI

## Minimum Tests Required

### Loader correctness

- GGUF load smoke test
- HF safetensors load smoke test
- exact no-quant reproduction for:
  - `/home/emo/Downloads/test_models/LFM2.5-350M-uncenssored`
- quantized load tests for:
  - `q_4km`
  - `q_3km`
- required/optional tensor validation tests

### Quantization correctness

- planned bytes vs allocated bytes
- quantized load must not allocate the original full BF16/F32 footprint
- row/chunk streaming tests to ensure bounded memory usage

### Save correctness

- `--save-on-load` GGUF file size matches quantized footprint expectations
- saved GGUF reloads successfully
- saved GGUF metadata matches the external spec / transformed tensor set

### Architecture tests

- LFM2 hybrid layer pattern
- Gemma4 SWA/global attention metadata
- DeepSeek2/GLM tensor split/merge rules
- external override spec alters architecture without rebuild

### Graph tests

- builtin graph export snapshot tests
- semantic graph import parity tests
- custom graph override tests

### Product tests

- interactive load/unload path
- non-interactive prompt path
- session save/restore
- tool loop smoke test
- server single-request smoke test

## Immediate Next Steps

These are the next steps with the best leverage and lowest rework:

1. Update `plan.md` to reflect the real architecture boundary:
   - external specs
   - semantic graph IR
   - llama.cpp `zllm2` patch layer
2. Design and implement the external architecture YAML schema
3. Refactor the current hardcoded HF arch mapping into spec-driven loading
4. Add llama.cpp tensor contract + validation hooks
5. Finish quantized load/save on top of that contract
6. Port `lfm2`, `gemma4`, and `deepseek2/glm` into the external spec format
7. Add semantic graph export/import
8. Then land DFlash / DDTree on top of the same graph-mode boundary

## Recommendation

Do not continue solving new architecture failures by adding more permanent compiled branches in `hf_bridge.zig` and `arch_table.zig`.

Use the current GLM/Gemma/LFM2 fixes only as temporary knowledge to extract into:

- external architecture specs
- generic transform executor
- small llama.cpp hook improvements

That is the shortest path that still satisfies the full requirement set.
