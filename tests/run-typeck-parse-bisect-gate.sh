#!/usr/bin/env bash
# A-11 bisect：typeck.sx 前缀 parse 指标，定位 num_defined 首次低于预期的 function 边界。
# 用法：./tests/run-typeck-parse-bisect-gate.sh
# 环境：SHUX_TYPECK_PARSE_BISECT_FAIL=1 任一步低于期望时硬失败（默认 track-only）
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_TYPECK_PARSE_BISECT_FAIL:-0}
SHUX="${SHUX:-./compiler/shux_asm}"
TYPECK_SU="compiler/src/typeck/typeck.sx"
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"
# 探测点：defined function 序号（不含 extern）
PROBES="${SHUX_TYPECK_PARSE_BISECT_PROBES:-20 40 60 80 100 120 146}"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "typeck-parse-bisect-gate: N/A on Darwin"
  exit 0
fi

if [ ! -x "$SHUX" ]; then
  echo "typeck-parse-bisect-gate: SKIP (no $SHUX)"
  exit 0
fi

WORKDIR="/tmp/shux_typeck_bisect.$$"
mkdir -p "$WORKDIR"
trap 'rm -rf "$WORKDIR"' EXIT

# 提取文件头（首个 ^function 之前：import/extern/注释）
header_end=$(grep -n '^function ' "$TYPECK_SU" | head -1 | cut -d: -f1)
header_end=$((header_end - 1))

# 按 defined function 序号截取前缀（保留 header + 前 N 个 function 块）
make_prefix() {
  local n="$1"
  local out="$2"
  head -n "$header_end" "$TYPECK_SU" >"$out"
  awk -v n="$n" '
    /^function / { c++ }
    c > 0 && c <= n { print }
  ' "$TYPECK_SU" >>"$out"
}

parse_defined_count() {
  local su="$1"
  local log="$2"
  local out="$3"
  rm -f "$out" "$log" 2>/dev/null || true
  (
    cd compiler
    env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 \
      SHUX_DEBUG_PIPE=1 SHUX_DEBUG_PARSE=1 \
      "../$SHUX" -backend asm -o "$out" $LIBROOT "$su"
  ) >"$log" 2>&1 || true
  local ndef nf
  ndef=$(sed -n 's/.*num_defined=\([0-9][0-9]*\).*/\1/p' "$log" | tail -1)
  nf=$(sed -n 's/.*after_entry_parse num_funcs=\([0-9][0-9]*\).*/\1/p' "$log" | tail -1)
  if [ -n "$ndef" ]; then
    echo "$ndef"
  else
    echo "${nf:-0}"
  fi
}

echo "typeck-parse-bisect-gate: probes defined func indices: ${PROBES}"
prev_ok=0
for want in $PROBES; do
  prefix="$WORKDIR/typeck_prefix_${want}.sx"
  make_prefix "$want" "$prefix"
  got=$(parse_defined_count "$prefix" "$WORKDIR/log_${want}.log" "$WORKDIR/out_${want}.o")
  # 前缀含 want 个 defined，num_defined 应 ≥ want（extern 另计）
  if [ "$got" -lt "$want" ] 2>/dev/null; then
    echo "typeck-parse-bisect-gate: probe defined<=${want} got num_defined=${got} (REGRESSION)" >&2
    grep -E 'parse skip at byte|parse commit fail at byte' "$WORKDIR/log_${want}.log" 2>/dev/null | head -3 >&2 || true
    prev_ok=1
    [ "$FAIL" = "1" ] && exit 1
  else
    echo "typeck-parse-bisect-gate: probe defined<=${want} OK (num_defined=${got})"
  fi
done

if [ "$prev_ok" = "0" ]; then
  echo "typeck-parse-bisect-gate OK (all probes passed)"
else
  echo "typeck-parse-bisect-gate WARN (see REGRESSION lines; track-only unless FAIL=1)"
fi
exit 0
