#!/usr/bin/env bash
# S5：build_asm/driver_compile.o WPO 生产链硬门禁（WPO 压缩 entry TU）。
# 用法：
#   ./tests/run-wpo-driver-o-gate.sh
#   ./tests/run-wpo-driver-o-gate.sh compiler/build_asm/driver_compile.o
#   SHU_WPO_DRIVER_O_FAIL=1 ./tests/run-wpo-driver-o-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-ab-proxy.sh
. tests/lib/wpo-ab-proxy.sh

DRIVER_O="${1:-compiler/build_asm/driver_compile.o}"
BASELINE="${SHU_WPO_DRIVER_O_BASELINE:-tests/baseline/wpo-driver-o.tsv}"
MAX_TEXT=$(awk -F'\t' '$1=="driver_o_max_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MAX_TEXT=${MAX_TEXT:-768}
FAIL=${SHU_WPO_DRIVER_O_FAIL:-1}

if [ ! -f "$DRIVER_O" ]; then
  echo "run-wpo-driver-o-gate FAIL: missing $DRIVER_O" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

TXT=$(wpo_ab_text_bytes "$DRIVER_O") || {
  echo "run-wpo-driver-o-gate FAIL: cannot read .text from $DRIVER_O" >&2
  exit 1
}

if ! nm "$DRIVER_O" 2>/dev/null | grep -qE ' T (compile_dispatch_asm_backend|run_compiler_full_su|entry)$'; then
  echo "run-wpo-driver-o-gate FAIL: $DRIVER_O missing WPO export (compile_dispatch_asm_backend/run_compiler_full_su/entry)" >&2
  exit 1
fi

echo "wpo driver.o gate: $DRIVER_O __text=${TXT}B (max=${MAX_TEXT}B)"

if [ "$TXT" -gt "$MAX_TEXT" ] 2>/dev/null; then
  echo "run-wpo-driver-o-gate WARN: __text ${TXT}B > WPO compressed cap ${MAX_TEXT}B (full emit fallback)" >&2
  [ "$FAIL" = "1" ] && exit 1
  echo "wpo driver.o gate OK (soft: entry present, __text=${TXT}B)"
  exit 0
fi

echo "wpo driver.o gate OK (__text=${TXT}B <= ${MAX_TEXT}B, WPO export present)"
