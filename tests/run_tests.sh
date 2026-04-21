#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="${ROOT_DIR}/zig-out/bin/zllm2"
CONFIG_DIR="${ROOT_DIR}/tests/configs"

if [[ ! -x "${BIN}" ]]; then
  echo "binary not found: ${BIN}" >&2
  echo "build first with: zig build" >&2
  exit 1
fi

status=0
for cfg in "${CONFIG_DIR}"/*.json; do
  echo "==> ${cfg}"
  model="$(python3 - <<'PY' "${cfg}"
import json, sys
cfg = json.load(open(sys.argv[1], "r", encoding="utf-8"))
print(cfg.get("model", ""))
PY
)"
  if [[ -z "${model}" ]]; then
    echo "SKIP: ${cfg} (no model configured)"
    continue
  fi
  if [[ ! -e "${model}" ]]; then
    echo "SKIP: ${cfg} (model not found: ${model})"
    continue
  fi
  if ! "${BIN}" -c "${cfg}" --no-tui >/tmp/zllm2-test.log 2>&1; then
    echo "FAILED: ${cfg}" >&2
    cat /tmp/zllm2-test.log >&2
    status=1
  fi
done

exit "${status}"
