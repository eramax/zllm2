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

## 2026-04-18 (zigzag 0.16 port progress)

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
