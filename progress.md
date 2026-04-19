# zllm2 Progress Log

## 2026-04-18

- Added persistent progress log file per request.
- Completed model-matrix runner structure update:
  - Results now under `tests/results/runN/`.
  - Per-model logs named `gguf-<slug>.log` / `safetensors-<slug>.log`.
  - `summary.log` includes run metadata and failed-model entries.
- Added/updated per-model config generation under `tests/configs/model-matrix/`.
- Added `tests/results/` to `.gitignore` and cleaned old log artifacts.
- Current known blocker:
  - Native HF safetensors path crashes in tokenizer metadata path (`gguf_set_arr_str` interop).
  - Temporary nearby-GGUF fallback is in place, so matrix passes functionally but Phase 1 is not semantically complete yet.
- Next steps in progress:
  - Fix `gguf_set_arr_str` pointer typing in HF bridge.
  - Prefer HF load first, then fallback only if HF fails.
  - Verify HF path is actually used (no fallback message) for safetensors directories.

## 2026-04-18 (cont.)

- User confirmed preference for a generic solution over per-model patches.
- Kept safetensors handling generic in loader:
  - Native HF path still attempted first.
  - On HF failure, automatic nearby GGUF fallback is used generically.
  - Fallback log now includes resolved GGUF path for traceability.
- Next execution step:
  - Run matrix against `/home/emo/Downloads/test_models/models`.
  - Verify per-run logs and summary show model names and failed models explicitly.

## 2026-04-18 (phase-1 continuation)

- Stabilized generic HF path:
  - Replaced unsafe JSON integer casts in `hf_bridge.zig` with checked conversions.
  - Stopped crashing shard-header cleanup path (temporary metadata cleanup is now non-fragile).
- Fixed generic path handling bugs:
  - All GGUF load calls now pass NUL-terminated paths (`dupeZ`) before calling llama.cpp C APIs.
  - HF fallback GGUF resolver now builds a NUL-terminated resolved path and logs it.
- Verification sweeps:
  - `run4` exposed two GGUF path failures caused by non-NUL C strings.
  - `run5` is clean: `pass=17`, `fail=0` on `/home/emo/Downloads/test_models/models`.
  - Safetensors directories now pass in matrix via generic flow (native HF attempt first, then fallback when needed).
- Verification commands:
  - `rtk zig build` passed.
  - `rtk zig build test` passed.

## 2026-04-18 (phase-0/1 audit)

- Audited Phase 0 + Phase 1 against plan/tasks and ran config verification.
- Fixed remaining Phase 0 test blocker:
  - Corrected `tests/configs/smoke_gguf.json` model path to existing GGUF (`Qwen3.5-4B-Q4_K_M.gguf`).
- Verification:
  - `rtk zig build` passed.
  - `rtk zig build test` passed.
  - `rtk bash tests/run_tests.sh` passed for `smoke_gguf`, `qwen35_hf`, `gemma4_hf`.
- Attempted to complete Phase 0 `libvaxis` dependency/link item:
  - `libvaxis` currently pulls a transitive dependency (`uucode`) incompatible with current Zig 0.16 build API in this environment.
  - Kept branch stable by reverting that attempted integration.

## 2026-04-18 (zigzag investigation)

- Inspected `meszmate/zigzag` as the TUI candidate for Zig 0.16.
- Found:
  - `build.zig.zon` declares `minimum_zig_version = 0.15.0`.
  - Repo is pure Zig with no external deps, so the dependency graph is much simpler than `libvaxis`.
  - It does not build on Zig 0.16 without porting.
- First Zig 0.16 build failure points:
  - `ArrayList.writer()` API removals.
  - `std.posix.getenv` and `std.io.fixedBufferStream` API changes.
  - `std.fmt.FormatOptions` and `std.time.Timer` API changes.
- Conclusion:
  - `zigzag` is the better 0.16 path, but it needs a porting pass before it can replace the current terminal layer.

## 2026-04-19 — Phase 2 TUI (complete)

Built a full custom TUI from scratch (no TUI library) after zigzag proved impractical on Zig 0.16.

### New files
- `src/cli/terminal.zig` — raw mode (POSIX tcgetattr/tcsetattr), terminal size (ioctl TIOCGWINSZ), ANSI escape constants, double-buffered `RenderBuf` with synchronized output (DECSET 2026)
- `src/cli/markdown.zig` — ANSI markdown renderer: `**bold**`, `*italic*`, `` `code` ``, `# headers` (3 levels), fenced code blocks with box-drawing borders, `- bullets`, `> blockquotes`, `~~strikethrough~~`, numbered lists, horizontal rules, inline nesting
- `src/cli/commands.zig` — slash command parser with `CommandKind` enum and `ParsedCommand` struct
- `src/cli/tui.zig` — main TUI (~850 lines): fixed input box at bottom, two status bars (model/stats + CPU/RAM/config), scrolling chat area, generation loop, replay support, savefile logging
- `tests/replay_test.txt` — replay test script with /help, /set, two coding prompts, /model

### Key implementation details
- `RenderBuf` accumulates all output into an `ArrayList(u8)`, flushed once per frame to avoid tearing
- Chat template builds full conversation history (all prior user/assistant turns) for multi-turn context
- Tokenization flags: `add_special=false` (chat template includes BOS), `parse_special=true` (tokenizes `<|im_start|>` etc. as single tokens)
- Sampler reset (`llama_sampler_reset`) between turns to prevent stale repetition penalty state
- Input handling: loops over all bytes in read buffer for paste support; accepts multi-byte UTF-8
- Render throttle: minimum 80ms between redraws (≤12 fps) during generation to prevent flicker
- stderr redirected to `/dev/null` in TUI mode before any backend init (covers ggml loader + llama.cpp logs)
- `/load` owns the model path string to prevent dangling pointer after input line is freed
- Status bars use `BG_COLOR + \x1b[K` pattern (erase-to-EOL fills with background color) instead of manual padding — avoids byte-vs-column miscounts from multi-byte UTF-8
- Unclosed code blocks get a full `└─...─┘` bottom border

### CLI flags added to main.zig
- `--replay <file>` — feed inputs from file, one per line, `#` lines are comments
- `--savefile <path>` — log conversation as `[user]:`/`[assistant]:`/`[system]:` entries
- `--tui-smoke` — render one frame and exit (CI smoke test)

### Bugs fixed in review pass
1. **Flicker during generation**: llama.cpp logs leaked into alt-screen; fixed by dup2(stderr→/dev/null) before backend init
2. **Paste not working**: `handleKey` only processed first byte; fixed with loop over entire read buffer
3. **Wrong model answers**: Only current message sent to model (no history); fixed by building full chat history from `state.messages` and passing to `llama_chat_apply_template`. Also fixed tokenize flags.
4. **Model name wrong after /load**: `state.cfg.model = path` pointed into freed input buffer; fixed with owned `model_path_buf`
5. **Code block bottom border missing**: Unclosed block fallback only drew `└`; fixed to draw full `└─...─┘`
6. **Status bar trailing artifacts**: Manual padding broke for multi-byte chars (`│` = 3 UTF-8 bytes = 1 column); fixed with `BG_COLOR + \x1b[K` pattern
7. **Garbage behind input row**: Same status bar padding issue; clearing with `\x1b[K` before separator text

### Verification
- `zig build` — clean
- `zig-out/bin/zllm2 --tui-smoke` — exits 0, renders one clean frame with no backend logs
- `tests/run_tests.sh` — smoke_gguf, qwen35_hf, gemma4_hf all pass
- Replay test: `zig-out/bin/zllm2 -c test_cfg.json --replay tests/replay_test.txt --savefile /tmp/out.log` — multi-turn context confirmed in savefile output

- Began the in-repo `zigzag` 0.16 port.
- Ported several stdlib API removals:
  - Replaced `std.fmt.FormatOptions` with `std.fmt.Options` in key/mouse formatters.
  - Removed `std.posix.getenv` use from color detection to avoid libc dependency.
  - Replaced `std.io.fixedBufferStream` test/helpers in `terminal/ansi.zig` and several image/OSC buffer builders with `std.Io.Writer`.
  - Replaced `std.time.Timer` usage in `core/program.zig` with a monotonic clock helper.
  - Switched several result buffers from old `Managed` writer patterns toward `std.ArrayList` + `std.Io.Writer.Allocating`.
- Current blocker:
  - `zigzag` is using a much older file/IO model than Zig 0.16, so `terminal.zig`, `core/log.zig`, and several component renderers still need a broader compatibility pass.
- Next step:
  - Finish the `std.Io.File` migration in terminal/logging and clean the remaining component renderers until `rtk zig build test` passes.
