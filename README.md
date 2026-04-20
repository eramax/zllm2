# zllm2

A self-contained LLM inference binary written in Zig. Loads any GGUF model, runs an interactive TUI chat with markdown rendering, and lets you surgically edit model architectures at inference time via YAML blueprints — without recompiling anything.

---

## Features

### Inference
- Load and run any GGUF model via llama.cpp
- Interactive TUI with real-time markdown rendering (`**bold**`, `*italic*`, `` `code` ``, headers, fenced blocks, bullets, blockquotes)
- Streaming generation with live stats: prefill tok/s, gen tok/s, VRAM, RAM, ctx fill
- GPU monitoring in status bar (util%, VRAM used/total)
- `--prompt` / `--no-tui` mode for scripting and piping

### Architecture Editing (`--arch`)
Edit model internals at inference time with a YAML blueprint — no fine-tuning, no recompilation, works on any architecture llama.cpp supports.

**What you can change:**
| Edit | YAML field | Effect |
|------|-----------|--------|
| Skip a layer entirely | `skip: true` on a layer | Layer output replaced with its input (identity) |
| Skip one component | `skip: true` on a component | That op replaced with pass-through |
| Swap activation function | `type: gelu` on `ffn_act` component | Changes GELU/SiLU/ReLU/SwiGLU/GeGLU |
| Reuse another layer's weights | `duplicate_of: N` on a layer | Layer uses blk.N weight tensors |
| Borrow one weight tensor | `weight_source: blk.N.attn_q.weight` | Single component redirected |
| Override RoPE | `freq_base` / `freq_scale` | Per-layer or global |
| Enable sliding-window attention | `sliding_window: 4096` | Global or per-layer |
| Control MoE routing | `expert_used_count`, `router_type` | Top-k count, random/softmax router |
| Reorder layer execution | `execution_order: N` | Run layers in any order |
| Change context length | `context_length` | Cap KV cache size |

**How it works:** zllm2 adds a post-build hook to llama.cpp that fires after `model.build_graph()` fills the ggml compute graph, and before the graph is computed. The hook iterates all named nodes and patches them in-place (`op`, `src[*]`) according to the blueprint. llama.cpp's own per-model graph builders handle every architecture correctly — we only patch the result.

### Tool Use (bash + websearch)

The model can call tools during inference. zllm2 runs a full agentic loop — generate → parse → execute → feed result back — until the model stops calling tools or hits the iteration limit.

Enable tools in the TUI:
```
/enable bash        # let the model run shell commands
/enable websearch   # let the model search DuckDuckGo
/enable all         # enable both
/enable             # list currently enabled tools
```

Or pre-enable in a config file:
```json
{ "tools": ["bash", "websearch"] }
```

The model uses an XML format: `<tool_call name="bash">{"command": "ls -la"}</tool_call>`. Works with any local model — no function-calling fine-tune required. Tool results are fed back as user messages so the model can reason over them.

Status bar shows `| Tools: ON` when any tool is active.

### TUI Commands
| Command | Description |
|---------|-------------|
| `/load <path>` | Load a model (GGUF or HF safetensors directory) |
| `/set gen <N>` | Set max generation tokens (-1 = infinite) |
| `/set temp <F>` | Set temperature |
| `/set top_p <F>` | Set top-p |
| `/enable <tool\|all>` | Enable a tool (bash, websearch) or list enabled tools |
| `/help` | Show all commands |
| `/model` | Show current model info |
| `/clear` | Clear chat history |
| `Ctrl-C` | Interrupt generation or quit |

### Other Modes
- `--inspect-yaml` — dump the model's architecture as an editable YAML blueprint
- `--replay <file>` — feed inputs from a text file (one per line, `#` = comment)
- `--savefile <path>` — log conversation to file as `[user]:`/`[assistant]:` entries

---

## Build

**Requirements:** Zig 0.16, a built llama.cpp at `../llama.cpp/build/bin/`

```bash
# Build llama.cpp first (one time)
cd ../llama.cpp
cmake -B build -DGGML_CUDA=ON -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)

# Build zllm2
cd zllm2
zig build
```

Binary: `zig-out/bin/zllm2`

---

## Usage

### Interactive TUI
```bash
zllm2 -m path/to/model.gguf
```

### Single prompt (no TUI)
```bash
zllm2 -m model.gguf -p "Explain quantum entanglement." --no-tui --gen 200 --temp 0.7
```

### Inspect a model's architecture
```bash
# Print diagram + full editable YAML to stdout
zllm2 -m model.gguf --inspect-yaml

# Save to file
zllm2 -m model.gguf --inspect-out arch.yaml
```

### Edit the architecture and run
```bash
# 1. Generate a blueprint
zllm2 -m model.gguf --inspect-out arch.yaml

# 2. Edit arch.yaml (see YAML reference below)

# 3. Run with the edited blueprint
zllm2 -m model.gguf --arch arch.yaml -p "Hello" --no-tui --gen 64
```

### Replay a script
```bash
# File: chat.txt
# Load model and chat
/load /path/to/model.gguf
What is the speed of light?
Summarize that in one sentence.

zllm2 --replay chat.txt --savefile output.log
```

---

## Architecture Blueprint YAML Reference

Generate a starting point with `--inspect-out`, then edit:

```yaml
# Global overrides — applied to all layers unless overridden per-layer
dimensions:
  block_count: 16         # number of transformer layers
  context_length: 4096    # max context (reducing saves KV memory)

attention:
  sliding_window: null    # set to integer (e.g. 2048) to enable SWA globally

rope:
  freq_base: 500000.0     # lower = shorter effective context
  freq_scale: 1.0

feed_forward:
  activation: silu        # silu | gelu | relu | swiglu | geglu

# Per-layer overrides
layers:
  - index: 5
    skip: true            # remove this layer from the graph entirely

  - index: 8
    duplicate_of: 0       # use layer 0's weights here instead

  - index: 10
    components:
      - name: ffn_act
        type: gelu        # swap activation for this layer only
        skip: false

      - name: attn_q
        weight_source: blk.0.attn_q.weight   # borrow weight from layer 0

  - index: 12
    residual: false       # remove residual connection
    execution_order: 0    # run this layer first (before index 0)
```

### Activation types
`silu` · `gelu` · `relu` · `swiglu` (gated silu) · `geglu` (gated gelu)

### MoE fields (Qwen MoE, Nemotron, etc.)
```yaml
moe:
  expert_used_count: 2    # how many experts to activate per token (top-k)
  router_type: topk       # topk | softmax | random
  shared_expert_count: 0  # set 0 to disable shared expert
```

---

## CLI Reference

```
zllm2 [flags]

  -m, --model  <path>      Model path (GGUF or HF safetensors dir)
  -c, --config <path>      Load config JSON
  -p, --prompt <text>      Single prompt mode (non-interactive)
      --no-tui             Print tokens to stdout instead of TUI
      --gen <N>            Max tokens to generate in prompt mode (-1 = unlimited)
  -n  <N>                  Alias for --gen
      --temp <F>           Temperature (0.0 = greedy)
      --arch <yaml>        Architecture blueprint to apply
      --inspect-yaml       Print model architecture diagram + YAML and exit
      --inspect-out <path> Save --inspect-yaml output to file
      --replay <file>      Feed inputs from file (one per line)
      --savefile <path>    Log conversation to file
      --tui-smoke          Render one TUI frame and exit (CI)
      --version            Print version
      --help               Print this help
```

---

## Test Suite

```bash
# Architecture editing (22 test cases)
bash tests/arch_edit/run_all.sh

# Tools / agentic loop (15 test cases)
bash tests/run_tools_test.sh
```

**Architecture editing** — 22 test cases across multiple model architectures:
- LFM2.5 350M (shortconv, non-standard architecture)
- Qwen3 0.8B / 4B
- Qwen3.5 35B-A3B (MoE)
- Nemotron 30B-A3B (MoE)
- Bonsai 8B (GQA)

**Tools** — 15 test cases: `/enable` command, bash (`ls`, `free -h`), websearch (DuckDuckGo), `/enable all`, config-loaded tools.

All tests pass.
