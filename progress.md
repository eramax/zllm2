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
