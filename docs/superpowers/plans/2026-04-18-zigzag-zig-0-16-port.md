# ZigZag Zig 0.16 Port Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Vendor `zigzag` into `zllm2`, port the repo to Zig `0.16`, and use it as the TUI foundation without changing the inference runtime.

**Architecture:** Keep the TUI migration isolated in a vendored `third_party/zigzag` tree plus a small integration surface in `zllm2`. First make the vendored package build and test on Zig `0.16`, then add a thin `zllm2` wrapper module that depends on the vendored package. Avoid touching model-loading code unless a build break forces it.

**Tech Stack:** Zig `0.16`, vendored `zigzag`, existing `zllm2` build system, current `rtk` build/test flow.

---

### Task 1: Vendor `zigzag`

**Files:**
- Create: `third_party/zigzag/**`
- Modify: `build.zig`

- [ ] **Step 1: Copy the upstream source into the repo**

Run: `cp -R /tmp/zigzag third_party/zigzag`
Expected: upstream `zigzag` source available in-repo

- [ ] **Step 2: Add it to the repo build as a local module**

Run: update `build.zig` to import `third_party/zigzag/src/root.zig`
Expected: `zigzag` is available as a build module

- [ ] **Step 3: Build the project**

Run: `rtk zig build`
Expected: build fails only on ZigZag 0.16 API mismatches, not on missing paths

### Task 2: Port ZigZag to Zig 0.16

**Files:**
- Modify: `third_party/zigzag/src/**`
- Modify: `third_party/zigzag/tests/**`

- [ ] **Step 1: Fix stdlib API removals**

Targets include `ArrayList.writer()`, `std.posix.getenv`, `std.io.fixedBufferStream`, `std.fmt.FormatOptions`, and `std.time.Timer`.

- [ ] **Step 2: Re-run ZigZag tests after each patch batch**

Run: `rtk zig build test` in `third_party/zigzag`
Expected: all ZigZag tests pass on Zig `0.16`

### Task 3: Wire into zllm2

**Files:**
- Modify: `build.zig`
- Modify: `src/main.zig`
- Modify: `src/cli/**` or create new TUI entry points if needed

- [ ] **Step 1: Replace the current TUI dependency path with ZigZag**

Run: build the `zllm2` binary with the vendored ZigZag module
Expected: `zllm2` still compiles and `--no-tui` behavior is unchanged

- [ ] **Step 2: Add a minimal TUI smoke path**

Run: a small `zigzag` program or `zllm2` TUI entry that starts and exits cleanly
Expected: we have a proof that the TUI stack runs under Zig `0.16`

### Task 4: Verify and commit

**Files:**
- Modify: `progress.md`

- [ ] **Step 1: Run full verification**

Run: `rtk zig build && rtk zig build test && rtk bash tests/run_tests.sh`
Expected: all current runtime tests still pass

- [ ] **Step 2: Commit the port**

Run: `git add ... && git commit -m "tui: vendor zigzag and port to zig 0.16"`
Expected: clean commit with TUI migration isolated from inference/runtime changes
