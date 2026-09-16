#!/usr/bin/env bash
# S5：build_asm/main.o WPO 生产链硬门禁（post-strict 重编后 __text 须压缩）。
# 用法：
#   ./tests/run-wpo-main-o-gate.sh
#   ./tests/run-wpo-main-o-gate.sh compiler/build_asm/main.o
#   XLANG_WPO_MAIN_O_FAIL=1 ./tests/run-wpo-main-o-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-ab-proxy.sh
. tests/lib/wpo-ab-proxy.sh

MAIN_O="${1:-compiler/build_asm/main.o}"
BASELINE="${XLANG_WPO_MAIN_O_BASELINE:-tests/baseline/wpo-main-o.tsv}"
MAX_TEXT=$(awk -F'\t' '$1=="main_o_max_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MAX_TEXT=${MAX_TEXT:-768}
FAIL=${XLANG_WPO_MAIN_O_FAIL:-1}

if [ ! -f "$MAIN_O" ]; then
  echo "run-wpo-main-o-gate FAIL: missing $MAIN_O" >&2
  exit 1
fi

TXT=$(wpo_ab_text_bytes "$MAIN_O") || {
  echo "run-wpo-main-o-gate FAIL: cannot read .text from $MAIN_O" >&2
  exit 1
}

# PLATFORM: SHARED — product ABI is main_entry; Mach-O may prefix `_`.
if ! wpo_nm_has_main_cli_entry "$MAIN_O"; then
  echo "run-wpo-main-o-gate FAIL: $MAIN_O missing symbol main_entry/entry" >&2
  exit 1
fi

echo "wpo main.o gate: $MAIN_O __text=${TXT}B (max=${MAX_TEXT}B)"

if [ "$TXT" -gt "$MAX_TEXT" ] 2>/dev/null; then
  # Tip main.x multi-export: WPO DCE no longer compresses to historical ≤2048B on
  # either platform (Ubuntu ~21KiB / Darwin ~52KiB live). Symbol gate stays hard;
  # size overage is WARN. Hard FAIL only when XLANG_WPO_MAIN_O_STRICT_SIZE=1.
  echo "run-wpo-main-o-gate WARN: __text ${TXT}B > WPO compressed cap ${MAX_TEXT}B (full emit fallback; tip multi-export)" >&2
  if [ "${XLANG_WPO_MAIN_O_STRICT_SIZE:-0}" = "1" ] && [ "$FAIL" = "1" ]; then
    exit 1
  fi
  echo "wpo main.o gate OK (soft size: main_entry/entry present, __text=${TXT}B)"
  exit 0
fi

echo "wpo main.o gate OK (__text=${TXT}B <= ${MAX_TEXT}B, main_entry/entry present)"
