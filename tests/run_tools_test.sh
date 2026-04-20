#!/usr/bin/env bash
# Phase 8 — Tools replay tests
# Runs TUI with replay inputs, captures savefile, validates tool execution.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="${ROOT_DIR}/zig-out/bin/zllm2"
CONFIG="${ROOT_DIR}/tests/configs/tools_replay.json"
REPLAY="${ROOT_DIR}/tests/replay_tools.txt"
SAVEFILE="/tmp/zllm2_tools_test.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

if [[ ! -x "${BIN}" ]]; then
    echo "binary not found: ${BIN}" >&2
    echo "build first with: zig build" >&2
    exit 1
fi

if [[ ! -f "${CONFIG}" ]]; then
    echo "config not found: ${CONFIG}" >&2
    exit 1
fi

pass=0
fail=0
total=0

check() {
    local name="$1"
    local pattern="$2"
    local file="$3"
    total=$((total + 1))
    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo "  ${GREEN}PASS${RESET} ${name}"
        pass=$((pass + 1))
    else
        echo "  ${RED}FAIL${RESET} ${name}"
        echo "       expected pattern: ${pattern}"
        fail=$((fail + 1))
    fi
}

# ─── Test 1: /enable command (no model needed) ────────────────────────
echo ""
echo "${BOLD}Test 1: /enable command (no model)${RESET}"
rm -f "$SAVEFILE"

cat > /tmp/zllm2_replay_enable.txt <<'EOF'
/enable bash
/enable websearch
/enable
/config
/quit
EOF

# Run TUI with no model — /enable should work
"${BIN}" --replay /tmp/zllm2_replay_enable.txt --savefile "$SAVEFILE" >/dev/null 2>&1 || true

if [[ -f "$SAVEFILE" ]]; then
    check "enable bash acknowledged"     "Enabled tool: bash"         "$SAVEFILE"
    check "enable websearch acknowledged" "Enabled tool: websearch"   "$SAVEFILE"
    check "enable list shows both"        "bash"                       "$SAVEFILE"
    check "config shows tools count"      "tools:"                     "$SAVEFILE"
else
    total=$((total + 4))
    fail=$((fail + 4))
    echo "  ${RED}FAIL${RESET} savefile not created"
fi

# ─── Test 2: Bash tool with model (ls) ────────────────────────────────
echo ""
echo "${BOLD}Test 2: Bash tool — ls command${RESET}"
rm -f "$SAVEFILE"

# Create a replay that enables bash and asks model to run ls
cat > /tmp/zllm2_replay_bash.txt <<'EOF'
/enable bash
run ls -la in the current directory using the bash tool
/quit
EOF

# This requires a model. Skip if model doesn't exist.
MODEL=$(python3 -c "import json; print(json.load(open('$CONFIG'))['model'])" 2>/dev/null || echo "")
if [[ -n "$MODEL" && -f "$MODEL" ]]; then
    "${BIN}" -c "$CONFIG" --replay /tmp/zllm2_replay_bash.txt --savefile "$SAVEFILE" >/dev/null 2>&1 || true

    if [[ -f "$SAVEFILE" ]]; then
        check "bash tool call generated"  'tool_call name="bash"'      "$SAVEFILE"
        check "bash shows command"        '"command"'                  "$SAVEFILE"
        check "bash result returned"      'tool_result'                "$SAVEFILE"
    else
        total=$((total + 3))
        fail=$((fail + 3))
        echo "  ${RED}FAIL${RESET} savefile not created (model may have errored)"
    fi
else
    total=$((total + 3))
    echo "  ${YELLOW}SKIP${RESET} model not found: ${MODEL}"
fi

# ─── Test 3: Bash tool with model (free -h) ───────────────────────────
echo ""
echo "${BOLD}Test 3: Bash tool — free -h command${RESET}"
rm -f "$SAVEFILE"

cat > /tmp/zllm2_replay_free.txt <<'EOF'
/enable bash
use the bash tool to run free -h and tell me how much RAM is available
/quit
EOF

if [[ -n "$MODEL" && -f "$MODEL" ]]; then
    "${BIN}" -c "$CONFIG" --replay /tmp/zllm2_replay_free.txt --savefile "$SAVEFILE" >/dev/null 2>&1 || true

    if [[ -f "$SAVEFILE" ]]; then
        check "bash free tool call"       'tool_call name="bash"'      "$SAVEFILE"
        check "bash free result"          'tool_result'                "$SAVEFILE"
    else
        total=$((total + 2))
        fail=$((fail + 2))
        echo "  ${RED}FAIL${RESET} savefile not created"
    fi
else
    total=$((total + 2))
    echo "  ${YELLOW}SKIP${RESET} model not found"
fi

# ─── Test 4: Websearch tool ───────────────────────────────────────────
echo ""
echo "${BOLD}Test 4: Websearch tool${RESET}"
rm -f "$SAVEFILE"

cat > /tmp/zllm2_replay_search.txt <<'EOF'
/enable websearch
search the web for "Zig programming language" using the websearch tool
/quit
EOF

if [[ -n "$MODEL" && -f "$MODEL" ]]; then
    "${BIN}" -c "$CONFIG" --replay /tmp/zllm2_replay_search.txt --savefile "$SAVEFILE" >/dev/null 2>&1 || true

    if [[ -f "$SAVEFILE" ]]; then
        check "websearch tool call"       'tool_call name="websearch"' "$SAVEFILE"
        check "websearch result"          'tool_result'                "$SAVEFILE"
    else
        total=$((total + 2))
        fail=$((fail + 2))
        echo "  ${RED}FAIL${RESET} savefile not created"
    fi
else
    total=$((total + 2))
    echo "  ${YELLOW}SKIP${RESET} model not found"
fi

# ─── Test 5: Enable all, then bash ────────────────────────────────────
echo ""
echo "${BOLD}Test 5: /enable all + bash tool${RESET}"
rm -f "$SAVEFILE"

cat > /tmp/zllm2_replay_all.txt <<'EOF'
/enable all
run uname -a with the bash tool
/quit
EOF

if [[ -n "$MODEL" && -f "$MODEL" ]]; then
    "${BIN}" -c "$CONFIG" --replay /tmp/zllm2_replay_all.txt --savefile "$SAVEFILE" >/dev/null 2>&1 || true

    if [[ -f "$SAVEFILE" ]]; then
        check "enable all works"          "Enabled all tools"          "$SAVEFILE"
        check "bash tool call generated"  'tool_call name="bash"'      "$SAVEFILE"
    else
        total=$((total + 2))
        fail=$((fail + 2))
        echo "  ${RED}FAIL${RESET} savefile not created"
    fi
else
    total=$((total + 2))
    echo "  ${YELLOW}SKIP${RESET} model not found"
fi

# ─── Test 6: Tool enable from config ──────────────────────────────────
echo ""
echo "${BOLD}Test 6: Tools enabled from config${RESET}"
rm -f "$SAVEFILE"

# The config already has tools: ["bash", "websearch"], so /enable should show them
cat > /tmp/zllm2_replay_config.txt <<'EOF'
/enable
/quit
EOF

if [[ -n "$MODEL" && -f "$MODEL" ]]; then
    "${BIN}" -c "$CONFIG" --replay /tmp/zllm2_replay_config.txt --savefile "$SAVEFILE" >/dev/null 2>&1 || true

    if [[ -f "$SAVEFILE" ]]; then
        check "config-loaded bash"        "bash"                       "$SAVEFILE"
        check "config-loaded websearch"   "websearch"                  "$SAVEFILE"
    else
        total=$((total + 2))
        fail=$((fail + 2))
        echo "  ${RED}FAIL${RESET} savefile not created"
    fi
else
    total=$((total + 2))
    echo "  ${YELLOW}SKIP${RESET} model not found"
fi

# ─── Summary ──────────────────────────────────────────────────────────
echo ""
echo "${BOLD}─────────────────────────────────────${RESET}"
echo "  Results: ${GREEN}${pass} passed${RESET}, ${RED}${fail} failed${RESET}, ${total} total"

# Clean up
rm -f "$SAVEFILE"
rm -f /tmp/zllm2_replay_*.txt

if [[ $fail -gt 0 ]]; then
    exit 1
fi
exit 0
