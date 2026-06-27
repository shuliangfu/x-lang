#!/usr/bin/env bash
# typeck-parse-count-chunk.sh — A-11 分块 parse 指标（整文件 typeck.sx 单次 parse 易 OOM）
#
# 将 typeck.sx 按 function 定义切成多段，每段带完整 header（import/extern）+ stub main，
# 用 SHUX_ASM_PARSE_METRIC_ONLY 只跑 parse，累加 num_defined（扣除每块 stub main）。
#
# 用法（仓库根）：
#   ./tests/lib/typeck-parse-count-chunk.sh <compiler> [typeck.sx]
#
# 环境：
#   SHUX_TYPECK_PARSE_CHUNK_FUNCS  每块最多 function 个数（默认 20）
#   SHUX_TYPECK_PARSE_CHUNK_LIBROOT  传给 -L（默认与 A-11 gate 一致）
#
# 成功时 stdout 打印累加后的 num_defined；失败返回 1。

set -euo pipefail
cd "$(dirname "$0")/../.."

COMP="${1:-./compiler/shux_asm}"
TYPECK_SX="${2:-compiler/src/typeck/typeck.sx}"
CHUNK_FUNCS="${SHUX_TYPECK_PARSE_CHUNK_FUNCS:-10}"
LIBROOT="${SHUX_TYPECK_PARSE_CHUNK_LIBROOT:--L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm}"
WORKDIR="/tmp/shux_typeck_chunks.$$"
OUT_BASE="/tmp/shux_typeck_chunk.$$"
CHUNK_TIMEOUT="${SHUX_TYPECK_PARSE_CHUNK_TIMEOUT:-240}"

if [ ! -x "$COMP" ] || [ ! -f "$TYPECK_SX" ]; then
  echo "typeck-parse-count-chunk: need executable compiler and typeck.sx" >&2
  exit 1
fi
COMP="$(cd "$(dirname "$COMP")" && pwd)/$(basename "$COMP")"

# shellcheck disable=SC2086
run_chunk_metric() {
  local sx="$1"
  local log="$2"
  local sx_abs out attempt rc
  sx_abs="$(cd "$(dirname "$sx")" && pwd)/$(basename "$sx")"
  out="${OUT_BASE}.${chunk_i}.o"
  for attempt in 1 2; do
    if command -v timeout >/dev/null 2>&1; then
      SHUX_CHUNK_COMP="$COMP" SHUX_CHUNK_OUT="$out" SHUX_CHUNK_SX="$sx_abs" \
        timeout "$CHUNK_TIMEOUT" bash -c '
          cd compiler || exit 1
          env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 \
            SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_PARSE_METRIC_ONLY=1 SHUX_DEBUG_PIPE=1 \
            "$SHUX_CHUNK_COMP" -backend asm -o "$SHUX_CHUNK_OUT" '"$LIBROOT"' "$SHUX_CHUNK_SX"
        ' >"$log" 2>&1 && return 0
      rc=$?
    else
      SHUX_CHUNK_COMP="$COMP" SHUX_CHUNK_OUT="$out" SHUX_CHUNK_SX="$sx_abs" \
        bash -c '
          cd compiler || exit 1
          env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 \
            SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_PARSE_METRIC_ONLY=1 SHUX_DEBUG_PIPE=1 \
            "$SHUX_CHUNK_COMP" -backend asm -o "$SHUX_CHUNK_OUT" '"$LIBROOT"' "$SHUX_CHUNK_SX"
        ' >"$log" 2>&1 && return 0
      rc=$?
    fi
    if grep -qE 'Terminated|Killed|signal 9|oom|Cannot allocate memory' "$log" 2>/dev/null && [ "$attempt" -eq 1 ]; then
      echo "typeck-parse-count-chunk: retry chunk ${chunk_i} after Terminated/OOM (attempt 2, rc=${rc})" >&2
      rm -f "$out" 2>/dev/null || true
      sleep 2
      continue
    fi
    return 1
  done
  return 1
}

parse_ndef_from_log() {
  local log="$1"
  local ndef nf
  ndef=$(sed -n 's/.*num_defined=\([0-9][0-9]*\).*/\1/p' "$log" | tail -1)
  if [ -n "$ndef" ]; then
    echo "$((ndef - 1))"
    return 0
  fi
  nf=$(sed -n 's/.*after_entry_parse num_funcs=\([0-9][0-9]*\).*/\1/p' "$log" | tail -1)
  if [ -n "$nf" ]; then
    echo "$((nf - 1))"
    return 0
  fi
  return 1
}

mkdir -p "$WORKDIR"
trap 'rm -rf "$WORKDIR" "${OUT_BASE}".*.o 2>/dev/null || true' EXIT

python3 - "$TYPECK_SX" "$WORKDIR" "$CHUNK_FUNCS" <<'PY'
import sys
from pathlib import Path

src = Path(sys.argv[1])
out_dir = Path(sys.argv[2])
chunk_sz = int(sys.argv[3])
lines = src.read_text().splitlines(keepends=True)
first_def = next(i for i, l in enumerate(lines) if l.startswith("function "))
header = "".join(lines[:first_def])
body_lines = lines[first_def:]
funcs: list[str] = []
cur: list[str] = []
for line in body_lines:
    if line.startswith("function ") and cur:
        funcs.append("".join(cur))
        cur = [line]
    else:
        cur.append(line)
if cur:
    funcs.append("".join(cur))
stub = "function main(): i32 { return 0; }\n"
idx = 0
for start in range(0, len(funcs), chunk_sz):
    part = funcs[start : start + chunk_sz]
    path = out_dir / f"chunk_{idx:03d}.sx"
    path.write_text(header + "".join(part) + stub, encoding="utf-8")
    idx += 1
print(len(funcs), file=sys.stderr)
PY

total_ndef=0
chunk_i=0
while [ -f "$WORKDIR/chunk_$(printf '%03d' "$chunk_i").sx" ]; do
  chunk_file="$WORKDIR/chunk_$(printf '%03d' "$chunk_i").sx"
  clog="$WORKDIR/chunk_${chunk_i}.log"
  if ! run_chunk_metric "$chunk_file" "$clog"; then
    echo "typeck-parse-count-chunk: FAIL chunk $chunk_i (see $clog)" >&2
    tail -n 8 "$clog" >&2 || true
    exit 1
  fi
  ndef=$(parse_ndef_from_log "$clog") || {
    echo "typeck-parse-count-chunk: no parse metric in chunk $chunk_i" >&2
    tail -n 8 "$clog" >&2 || true
    exit 1
  }
  total_ndef=$((total_ndef + ndef))
  chunk_i=$((chunk_i + 1))
  rm -f "${OUT_BASE}.$((chunk_i - 1)).o" 2>/dev/null || true
done

if [ "$chunk_i" -eq 0 ]; then
  echo "typeck-parse-count-chunk: no chunks produced" >&2
  exit 1
fi

echo "typeck-parse-count-chunk: OK chunks=${chunk_i} chunk_funcs<=${CHUNK_FUNCS} num_defined_sum=${total_ndef}" >&2
echo "$total_ndef"
