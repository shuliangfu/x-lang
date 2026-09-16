#!/usr/bin/env bash
# S5: build_asm/backend_wpo.o WPO production-chain hard gate (WPO-compressed
# backend.x dogfood). Strict chain still uses full build_asm/backend.o; this
# gate only checks backend_wpo.o.
#
# Honesty: missing .o is hard die. Reach is hard (soft REACH_FAIL:-0 /
# soft SKIP→OK retired in reach gate).
#
# Usage:
#   ./tests/run-wpo-backend-o-gate.sh
#   ./tests/run-wpo-backend-o-gate.sh compiler/build_asm/backend_wpo.o
# Report: run=/obs=/skip=
# PLATFORM: SHARED
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-ab-proxy.sh
. tests/lib/wpo-ab-proxy.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

BACKEND_O="${1:-compiler/build_asm/backend_wpo.o}"
BASELINE="${XLANG_WPO_BACKEND_O_BASELINE:-tests/baseline/wpo-backend-o.tsv}"
MAX_TEXT=$(awk -F'\t' '$1=="backend_wpo_max_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MAX_TEXT=${MAX_TEXT:-4096}
MIN_SAVE=$(awk -F'\t' '$1=="backend_wpo_min_save_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_SAVE=${MIN_SAVE:-2000}
OFF_PROXY=$(awk -F'\t' '$1=="backend_dce_off_text" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
OFF_PROXY=${OFF_PROXY:-4941}
PREFIX="xlang: [XLANG_WPO_BACKEND_O]"
OBS=0

die() {
  echo "run-wpo-backend-o-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=0 obs=${OBS} skip=0 host=$(ci_host_summary)"
  exit 1
}

if [ ! -f "$BACKEND_O" ]; then
  die "missing $BACKEND_O (refuse soft SKIP→OK)"
fi

TXT=$(wpo_ab_text_bytes "$BACKEND_O") || die "cannot read .text from $BACKEND_O"

if ! nm "$BACKEND_O" 2>/dev/null | grep -q 'asm_codegen_ast'; then
  die "$BACKEND_O missing asm_codegen_ast"
fi

SAVE=$((OFF_PROXY - TXT))
echo "wpo backend_wpo.o gate: $BACKEND_O __text=${TXT}B (max=${MAX_TEXT}B, save=${SAVE}B vs proxy off=${OFF_PROXY}B)"

if [ "$TXT" -gt "$MAX_TEXT" ] 2>/dev/null; then
  die "__text ${TXT}B > cap ${MAX_TEXT}B"
fi
if [ "$SAVE" -lt "$MIN_SAVE" ] 2>/dev/null; then
  die "save ${SAVE}B < min ${MIN_SAVE}B"
fi

"$(dirname "$0")/run-wpo-backend-reach-gate.sh" "$BACKEND_O" || die "reach gate failed"

echo "wpo backend_wpo.o gate OK (__text=${TXT}B <= ${MAX_TEXT}B, save=${SAVE}B, asm_codegen_ast present, reach hard)"
echo "${PREFIX} status=ok run=1 obs=${OBS} skip=0 host=$(ci_host_summary)"
