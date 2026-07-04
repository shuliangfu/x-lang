#!/usr/bin/env bash
# S5：build_asm/typeck_wpo.o WPO 生产链硬门禁（WPO 压缩 typeck.x dogfood）。
# strict 链仍用全量 build_asm/typeck.o；本门禁仅验 typeck_wpo.o。
# 用法：
#   ./tests/run-wpo-typeck-o-gate.sh
#   ./tests/run-wpo-typeck-o-gate.sh compiler/build_asm/typeck_wpo.o
#   SHUX_WPO_TYPECK_O_FAIL=1 ./tests/run-wpo-typeck-o-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-ab-proxy.sh
. tests/lib/wpo-ab-proxy.sh

TYPECK_O="${1:-compiler/build_asm/typeck_wpo.o}"
BASELINE="${SHUX_WPO_TYPECK_O_BASELINE:-tests/baseline/wpo-typeck-o.tsv}"
MAX_TEXT=$(awk -F'\t' '$1=="typeck_wpo_max_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MAX_TEXT=${MAX_TEXT:-2048}
MIN_SAVE=$(awk -F'\t' '$1=="typeck_wpo_min_save_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_SAVE=${MIN_SAVE:-70000}
OFF_PROXY=$(awk -F'\t' '$1=="typeck_dce_off_text" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
OFF_PROXY=${OFF_PROXY:-79397}
FAIL=${SHUX_WPO_TYPECK_O_FAIL:-1}

if [ ! -f "$TYPECK_O" ]; then
  echo "run-wpo-typeck-o-gate FAIL: missing $TYPECK_O" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

TXT=$(wpo_ab_text_bytes "$TYPECK_O") || {
  echo "run-wpo-typeck-o-gate FAIL: cannot read .text from $TYPECK_O" >&2
  exit 1
}

if ! nm "$TYPECK_O" 2>/dev/null | grep -q 'typeck_x_ast'; then
  echo "run-wpo-typeck-o-gate FAIL: $TYPECK_O missing typeck_x_ast" >&2
  exit 1
fi
if ! nm "$TYPECK_O" 2>/dev/null | grep -q 'check_block'; then
  echo "run-wpo-typeck-o-gate FAIL: $TYPECK_O missing check_block" >&2
  exit 1
fi

SAVE=$((OFF_PROXY - TXT))
echo "wpo typeck_wpo.o gate: $TYPECK_O __text=${TXT}B (max=${MAX_TEXT}B, save=${SAVE}B vs proxy off=${OFF_PROXY}B)"

if [ "$TXT" -gt "$MAX_TEXT" ] 2>/dev/null; then
  echo "run-wpo-typeck-o-gate WARN: __text ${TXT}B > cap ${MAX_TEXT}B" >&2
  [ "$FAIL" = "1" ] && exit 1
fi
if [ "$SAVE" -lt "$MIN_SAVE" ] 2>/dev/null; then
  echo "run-wpo-typeck-o-gate FAIL: save ${SAVE}B < min ${MIN_SAVE}B" >&2
  [ "$FAIL" = "1" ] && exit 1
fi

if [ -x "$(dirname "$0")/run-wpo-typeck-reach-gate.sh" ]; then
  SHUX_WPO_TYPECK_REACH_FAIL="${SHUX_WPO_TYPECK_REACH_FAIL:-0}" \
    "$(dirname "$0")/run-wpo-typeck-reach-gate.sh" "$TYPECK_O" || {
    [ "$FAIL" = "1" ] && exit 1
  }
fi

echo "wpo typeck_wpo.o gate OK (__text=${TXT}B <= ${MAX_TEXT}B, save=${SAVE}B, typeck_x_ast+check_block present)"
