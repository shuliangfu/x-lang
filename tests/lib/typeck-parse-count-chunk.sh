#!/usr/bin/env bash
# typeck-parse-count-chunk.sh — A-11 分块 parse 指标（整文件 typeck.x 单次 parse 易 OOM）
#
# 将 typeck.x 按 function 定义切成多段，每段带完整 header（import/extern）+ stub main，
# 用 SHUX_ASM_PARSE_METRIC_ONLY 只跑 parse，累加 num_defined（扣除每块 stub main）。
#
# 用法（仓库根）：
#   ./tests/lib/typeck-parse-count-chunk.sh <compiler> [typeck.x]
#
# 环境：
#   SHUX_TYPECK_PARSE_CHUNK_FUNCS  每块最多 function 个数（默认 20）
#   SHUX_TYPECK_PARSE_CHUNK_LIBROOT  传给 -L（默认与 A-11 gate 一致）
#
# 成功时 stdout 打印累加后的 num_defined；失败返回 1。

set -euo pipefail
cd "$(dirname "$0")/../.."

# 连续 parse 指标会反复 exec shux；默认 nofile=1024 时约 90 次后 EMFILE → timeout SIGTERM。
ulimit -n 8192 2>/dev/null || ulimit -n 4096 2>/dev/null || true

COMP="${1:-./compiler/shux_asm}"
TYPECK_X="${2:-compiler/src/typeck/typeck.x}"
CHUNK_FUNCS="${SHUX_TYPECK_PARSE_CHUNK_FUNCS:-10}"
LIBROOT="${SHUX_TYPECK_PARSE_CHUNK_LIBROOT:--L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm}"
WORKDIR="/tmp/shux_typeck_chunks.$$"
OUT_BASE="/tmp/shux_typeck_chunk.$$"
CHUNK_TIMEOUT="${SHUX_TYPECK_PARSE_CHUNK_TIMEOUT:-240}"

if [ ! -x "$COMP" ] || [ ! -f "$TYPECK_X" ]; then
  echo "typeck-parse-count-chunk: need executable compiler and typeck.x" >&2
  exit 1
fi
COMP="$(cd "$(dirname "$COMP")" && pwd)/$(basename "$COMP")"
ONE_SH="$(dirname "$0")/typeck-parse-count-chunk-one.sh"
chmod +x "$ONE_SH" 2>/dev/null || true

mkdir -p "$WORKDIR"
trap 'rm -rf "$WORKDIR" "${OUT_BASE}".*.o 2>/dev/null || true' EXIT

python3 - "$TYPECK_X" "$WORKDIR" "$CHUNK_FUNCS" <<'PY'
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
    path = out_dir / f"chunk_{idx:03d}.x"
    path.write_text(header + "".join(part) + stub, encoding="utf-8")
    idx += 1
print(len(funcs), file=sys.stderr)
PY

total_ndef=0
chunk_i=0
while [ -f "$WORKDIR/chunk_$(printf '%03d' "$chunk_i").x" ]; do
  chunk_file="$WORKDIR/chunk_$(printf '%03d' "$chunk_i").x"
  clog="$WORKDIR/chunk_${chunk_i}.log"
  out="${OUT_BASE}.${chunk_i}.o"
  ndef=""
  for attempt in 1 2; do
    if command -v timeout >/dev/null 2>&1; then
      if ndef=$(timeout "$CHUNK_TIMEOUT" "$ONE_SH" "$COMP" "$chunk_file" "$out" "$clog" 2>>"$clog"); then
        break
      fi
      rc=$?
    elif ndef=$("$ONE_SH" "$COMP" "$chunk_file" "$out" "$clog" 2>>"$clog"); then
      break
    else
      rc=$?
    fi
    if grep -qE 'Terminated|Killed|signal 9|oom|Cannot allocate memory' "$clog" 2>/dev/null && [ "$attempt" -eq 1 ]; then
      echo "typeck-parse-count-chunk: retry chunk ${chunk_i} after Terminated/OOM (attempt 2, rc=${rc:-?})" >&2
      sleep 2
      continue
    fi
    echo "typeck-parse-count-chunk: FAIL chunk $chunk_i (see $clog)" >&2
    tail -n 8 "$clog" >&2 || true
    exit 1
  done
  if [ -z "$ndef" ]; then
    echo "typeck-parse-count-chunk: FAIL chunk $chunk_i (no metric; see $clog)" >&2
    exit 1
  fi
  total_ndef=$((total_ndef + ndef))
  chunk_i=$((chunk_i + 1))
  rm -f "$out" 2>/dev/null || true
done

if [ "$chunk_i" -eq 0 ]; then
  echo "typeck-parse-count-chunk: no chunks produced" >&2
  exit 1
fi

echo "typeck-parse-count-chunk: OK chunks=${chunk_i} chunk_funcs<=${CHUNK_FUNCS} num_defined_sum=${total_ndef}" >&2
echo "$total_ndef"
