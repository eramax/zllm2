#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="${ROOT_DIR}/zig-out/bin/zllm2"
MODEL_ROOT="${1:-/home/emo/Downloads/test_models/models}"
RESULTS_DIR="${ROOT_DIR}/tests/results"
CONFIGS_DIR="${ROOT_DIR}/tests/configs/model-matrix"
PROMPT="${PROMPT:-Write one clear English sentence with at least eighteen words about astronomy, numbers, and software testing.}"
GEN_TOKENS="${GEN_TOKENS:-96}"
CTX_TOKENS="${CTX_TOKENS:-1024}"
MAX_MODELS="${MAX_MODELS:-0}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-1800}"

mkdir -p "${RESULTS_DIR}"
mkdir -p "${CONFIGS_DIR}"

if [[ ! -x "${BIN}" ]]; then
  echo "binary not found: ${BIN}" >&2
  echo "build first with: rtk zig build" >&2
  exit 1
fi

if [[ ! -d "${MODEL_ROOT}" ]]; then
  echo "model root not found: ${MODEL_ROOT}" >&2
  exit 1
fi

next_run_index() {
  local max=0
  shopt -s nullglob
  for d in "${RESULTS_DIR}"/run*; do
    [[ -d "${d}" ]] || continue
    local name idx
    name="$(basename "$d")"
    idx="${name#run}"
    [[ "$idx" =~ ^[0-9]+$ ]] || continue
    if (( idx > max )); then
      max="$idx"
    fi
  done
  shopt -u nullglob
  echo $((max + 1))
}

slugify() {
  local raw="$1"
  local slug
  slug="$(printf '%s' "${raw}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
  if [[ -z "${slug}" ]]; then
    slug="model"
  fi
  printf '%s' "${slug}"
}

mapfile -t MODEL_LIST < <(
  python3 - <<'PY' "$MODEL_ROOT"
import os
import sys

root = sys.argv[1]
ggufs = set()
safetensors_dirs = set()

for dp, dns, fns in os.walk(root):
    for fn in fns:
        if fn.lower().endswith(".gguf"):
            full = os.path.join(dp, fn)
            low = full.lower()
            if "ggml-vocab-" in low:
                continue
            ggufs.add(full)
    if "config.json" in fns and ("model.safetensors" in fns or "model.safetensors.index.json" in fns):
        safetensors_dirs.add(dp)

for path in sorted(ggufs):
    print(path)
for path in sorted(safetensors_dirs):
    print(path)
PY
)

if (( ${#MODEL_LIST[@]} == 0 )); then
  echo "no models discovered under ${MODEL_ROOT}" >&2
  exit 1
fi

if (( MAX_MODELS > 0 && ${#MODEL_LIST[@]} > MAX_MODELS )); then
  MODEL_LIST=("${MODEL_LIST[@]:0:${MAX_MODELS}}")
fi

echo "Discovered ${#MODEL_LIST[@]} model targets"

PASS_COUNT=0
FAIL_COUNT=0
FAILED_LIST_FILE="$(mktemp /tmp/zllm2-failed-models-XXXXXX.txt)"
trap 'rm -f "${FAILED_LIST_FILE}"' EXIT
RUN_INDEX="$(next_run_index)"
RUN_DIR="${RESULTS_DIR}/run${RUN_INDEX}"
mkdir -p "${RUN_DIR}"

for model_spec in "${MODEL_LIST[@]}"; do
  model_path="${model_spec}"
  model_kind="safetensors"
  model_name="$(basename "${model_path}")"
  if [[ "${model_path}" == *.gguf ]]; then
    model_kind="gguf"
    model_name="${model_name%.gguf}"
  fi
  model_slug="$(slugify "${model_name}")"

  result_file="${RUN_DIR}/${model_kind}-${model_slug}.log"
  dupe_idx=2
  while [[ -f "${result_file}" ]]; do
    result_file="${RUN_DIR}/${model_kind}-${model_slug}-${dupe_idx}.log"
    dupe_idx=$((dupe_idx + 1))
  done

  cfg_file="${CONFIGS_DIR}/${model_kind}-${model_slug}.json"
  run_stamp="$(date -Is)"

  {
    echo "timestamp=${run_stamp}"
    echo "model=${model_path}"
    echo "kind=${model_kind}"
    echo "config=${cfg_file}"
    echo "prompt=${PROMPT}"
    echo "gen=${GEN_TOKENS}"
    echo "ctx=${CTX_TOKENS}"
  } >"${result_file}"

  python3 - <<'PY' "$cfg_file" "$model_path" "$PROMPT" "$GEN_TOKENS" "$CTX_TOKENS"
import json
import sys

cfg_path, model, prompt, gen, ctx = sys.argv[1:]
cfg = {
    "model": model,
    "dtype": "f16",
    "prompt": prompt,
    "gen": int(gen),
    "ctx": int(ctx),
    "temp": 0.0,
}
with open(cfg_path, "w", encoding="utf-8") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")
PY

  {
    echo "----- command -----"
    echo "timeout --signal=INT ${TIMEOUT_SECONDS} ${BIN} -c ${cfg_file} --no-tui"
    echo "----- output -----"
  } >>"${result_file}"

  set +e
  timeout --signal=INT "${TIMEOUT_SECONDS}" "${BIN}" -c "${cfg_file}" --no-tui >>"${result_file}" 2>&1
  cmd_status=$?
  set -e

  quality_status=0
  quality_note=""
  set +e
  python3 - <<'PY' "${result_file}" "${cmd_status}" >/tmp/zllm2-quality.txt
import re
import sys
import string

path = sys.argv[1]
cmd_status = int(sys.argv[2])

text = open(path, "r", encoding="utf-8", errors="replace").read()

markers = ("----- output -----",)
out = text
for m in markers:
    idx = out.find(m)
    if idx >= 0:
        out = out[idx + len(m):]

if cmd_status != 0:
    print("extracted_chars=0")
    print("quality=FAIL reason=process_exit_nonzero")
    sys.exit(2)

# keep only generation-adjacent tail before perf footer
candidate = ""
patterns = [
    r"ggml_backend_cuda_graph_compute: CUDA graph warmup complete\s*\n\n(.*?)\nllama_perf_context_print:",
    r"Model loaded\.\s*\n\n(.*?)\nllama_perf_context_print:",
]
for pat in patterns:
    m = re.search(pat, out, re.S)
    if m:
        candidate = m.group(1).strip()
        break

if not candidate:
    if "llama_perf_context_print:" in out:
        out = out.split("llama_perf_context_print:", 1)[0]
    tail_lines = out.splitlines()[-120:]

    noise_prefixes = (
        "ggml_", "load_backend:", "register_", "print_info:", "load:", "llama_",
        "~llama_", "Loading model:", "Model loaded.", "init_", "warning:",
        "offloading", "CUDA_", "Detected architecture:", "sched_reserve:",
        "graph_reserve:", "common_init_from_params:", "system_info:", "set_abort_callback:",
        "CUDA Graph id",
    )

    candidate_lines = []
    for ln in tail_lines:
        s = ln.strip()
        if not s:
            continue
        if s.startswith("-----"):
            continue
        if any(s.startswith(p) for p in noise_prefixes):
            continue
        if "[LAYER " in s and "DEBUG" in s:
            continue
        if "DEBUG]" in s:
            continue
        candidate_lines.append(s)

    candidate = "\n".join(candidate_lines).strip()
print(f"extracted_chars={len(candidate)}")

if len(candidate) < 40:
    print("quality=FAIL reason=too_short_output")
    sys.exit(3)

printable = sum(1 for ch in candidate if ch in string.printable or ch in "\n\r\t")
ratio_printable = printable / max(1, len(candidate))
letters = sum(1 for ch in candidate if ch.isalpha())
ratio_letters = letters / max(1, len(candidate))
words = re.findall(r"[A-Za-z]{2,}", candidate)
unique_chars = len(set(candidate))
ratio_unique = unique_chars / max(1, len(candidate))

if ratio_printable < 0.90:
    print(f"quality=FAIL reason=low_printable_ratio value={ratio_printable:.3f}")
    sys.exit(4)
if ratio_letters < 0.20:
    print(f"quality=FAIL reason=low_letter_ratio value={ratio_letters:.3f}")
    sys.exit(5)
if len(words) < 8:
    print(f"quality=FAIL reason=too_few_words value={len(words)}")
    sys.exit(6)
if ratio_unique < 0.04:
    print(f"quality=FAIL reason=too_repetitive value={ratio_unique:.3f}")
    sys.exit(7)

print("quality=PASS")
PY
  quality_status=$?
  set -e
  quality_note="$(cat /tmp/zllm2-quality.txt)"

  {
    echo "----- quality -----"
    echo "${quality_note}"
    echo "exit_code=${cmd_status}"
  } >>"${result_file}"

  {
    echo "----- inspect -----"
  } >>"${result_file}"
  set +e
  timeout --signal=INT 120 "${BIN}" -c "${cfg_file}" --inspect-yaml >>"${result_file}" 2>/dev/null
  set -e

  if [[ "${cmd_status}" -eq 0 && "${quality_status}" -eq 0 ]]; then
    echo "PASS ${model_path} -> ${result_file}"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "FAIL ${model_path} -> ${result_file}"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    echo "${model_kind}-${model_slug}::${model_path}::$(basename "${result_file}")" >>"${FAILED_LIST_FILE}"
  fi
done

summary_file="${RUN_DIR}/summary.log"
{
  echo "run=run${RUN_INDEX}"
  echo "model_root=${MODEL_ROOT}"
  echo "runs=${#MODEL_LIST[@]}"
  echo "pass=${PASS_COUNT}"
  echo "fail=${FAIL_COUNT}"
  echo "results_dir=${RUN_DIR}"
  failed_count="$(wc -l < "${FAILED_LIST_FILE}" | tr -d ' ')"
  echo "failed_models_count=${failed_count}"
  if (( failed_count == 0 )); then
    echo "failed_models=none"
  else
    while IFS= read -r item; do
      echo "failed_model=${item}"
    done < "${FAILED_LIST_FILE}"
  fi
} >"${summary_file}"

echo "Summary: pass=${PASS_COUNT} fail=${FAIL_COUNT} (details in ${RUN_DIR}, summary in ${summary_file})"

if (( FAIL_COUNT > 0 )); then
  exit 1
fi
