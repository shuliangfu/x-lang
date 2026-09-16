#!/usr/bin/env bash
# S5: build_asm/typeck_wpo.o WPO production-chain hard gate (WPO-compressed
# typeck.x dogfood). Strict chain still uses full build_asm/typeck.o; this
# gate only checks typeck_wpo.o.
#
# Honesty: parent must not force XLANG_WPO_TYPECK_REACH_FAIL=0 — reach is
# hard (soft die→exit0 / soft SKIP→OK retired in reach gate). Missing .o
# is hard die (refuse soft exit0 when XLANG_WPO_TYPECK_O_FAIL=0).
#
# Usage:
#   ./tests/run-wpo-typeck-o-gate.sh
#   ./tests/run-wpo-typeck-o-gate.sh compiler/build_asm/typeck_wpo.o
# Report: run=/obs=/skip=
# PLATFORM: SHARED — Darwin arm64 typeck_wpo tip ~9–10KiB (Linux ~4.5KiB);
# override via XLANG_WPO_TYPECK_O_MAX_TEXT_OVERRIDE / XLANG_WPO_TYPECK_MAX_TEXT.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-ab-proxy.sh
. tests/lib/wpo-ab-proxy.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

TYPECK_O="${1:-compiler/build_asm/typeck_wpo.o}"
BASELINE="${XLANG_WPO_TYPECK_O_BASELINE:-tests/baseline/wpo-typeck-o.tsv}"
MAX_TEXT=$(awk -F'\t' '$1=="typeck_wpo_max_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MAX_TEXT=${MAX_TEXT:-8192}
if [ -n "${XLANG_WPO_TYPECK_O_MAX_TEXT_OVERRIDE:-}" ]; then
  MAX_TEXT="$XLANG_WPO_TYPECK_O_MAX_TEXT_OVERRIDE"
elif [ -n "${XLANG_WPO_TYPECK_MAX_TEXT:-}" ]; then
  MAX_TEXT="$XLANG_WPO_TYPECK_MAX_TEXT"
elif [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  MAX_TEXT=16384
fi
MIN_SAVE=$(awk -F'\t' '$1=="typeck_wpo_min_save_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_SAVE=${MIN_SAVE:-70000}
OFF_PROXY=$(awk -F'\t' '$1=="typeck_dce_off_text" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
OFF_PROXY=${OFF_PROXY:-79397}
PREFIX="xlang: [XLANG_WPO_TYPECK_O]"
OBS=0

die() {
  echo "run-wpo-typeck-o-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=0 obs=${OBS} skip=0 host=$(ci_host_summary)"
  exit 1
}

if [ ! -f "$TYPECK_O" ]; then
  die "missing $TYPECK_O (refuse soft SKIP→OK)"
fi

TXT=$(wpo_ab_text_bytes "$TYPECK_O") || die "cannot read .text from $TYPECK_O"

if ! nm "$TYPECK_O" 2>/dev/null | grep -q 'typeck_x_ast'; then
  die "$TYPECK_O missing typeck_x_ast"
fi
if ! nm "$TYPECK_O" 2>/dev/null | grep -q 'check_block'; then
  die "$TYPECK_O missing check_block"
fi

SAVE=$((OFF_PROXY - TXT))
echo "wpo typeck_wpo.o gate: $TYPECK_O __text=${TXT}B (max=${MAX_TEXT}B, save=${SAVE}B vs proxy off=${OFF_PROXY}B)"

if [ "$TXT" -gt "$MAX_TEXT" ] 2>/dev/null; then
  die "__text ${TXT}B > cap ${MAX_TEXT}B"
fi
if [ "$SAVE" -lt "$MIN_SAVE" ] 2>/dev/null; then
  die "save ${SAVE}B < min ${MIN_SAVE}B"
fi

"$(dirname "$0")/run-wpo-typeck-reach-gate.sh" "$TYPECK_O" || die "reach gate failed"

echo "wpo typeck_wpo.o gate OK (__text=${TXT}B <= ${MAX_TEXT}B, save=${SAVE}B, typeck_x_ast+check_block present, reach hard)"
echo "${PREFIX} status=ok run=1 obs=${OBS} skip=0 host=$(ci_host_summary)"
