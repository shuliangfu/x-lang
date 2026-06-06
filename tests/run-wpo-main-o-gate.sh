#!/usr/bin/env bash
# S5：build_asm/main.o WPO 生产链硬门禁（post-strict 重编后 __text 须压缩）。
# 用法：
#   ./tests/run-wpo-main-o-gate.sh
#   ./tests/run-wpo-main-o-gate.sh compiler/build_asm/main.o
#   SHU_WPO_MAIN_O_FAIL=1 ./tests/run-wpo-main-o-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-ab-proxy.sh
. tests/lib/wpo-ab-proxy.sh

MAIN_O="${1:-compiler/build_asm/main.o}"
BASELINE="${SHU_WPO_MAIN_O_BASELINE:-tests/baseline/wpo-main-o.tsv}"
MAX_TEXT=$(awk -F'\t' '$1=="main_o_max_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MAX_TEXT=${MAX_TEXT:-768}
FAIL=${SHU_WPO_MAIN_O_FAIL:-1}

if [ ! -f "$MAIN_O" ]; then
  echo "run-wpo-main-o-gate FAIL: missing $MAIN_O" >&2
  exit 1
fi

TXT=$(wpo_ab_text_bytes "$MAIN_O") || {
  echo "run-wpo-main-o-gate FAIL: cannot read .text from $MAIN_O" >&2
  exit 1
}

if ! nm "$MAIN_O" 2>/dev/null | grep -q ' entry$'; then
  echo "run-wpo-main-o-gate FAIL: $MAIN_O missing symbol entry" >&2
  exit 1
fi

echo "wpo main.o gate: $MAIN_O __text=${TXT}B (max=${MAX_TEXT}B)"

if [ "$TXT" -gt "$MAX_TEXT" ] 2>/dev/null; then
  echo "run-wpo-main-o-gate WARN: __text ${TXT}B > WPO compressed cap ${MAX_TEXT}B (full emit fallback)" >&2
  [ "$FAIL" = "1" ] && exit 1
  echo "wpo main.o gate OK (soft: entry present, __text=${TXT}B)"
  exit 0
fi

echo "wpo main.o gate OK (__text=${TXT}B <= ${MAX_TEXT}B, entry present)"
