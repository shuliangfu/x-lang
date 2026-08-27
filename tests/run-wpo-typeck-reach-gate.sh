#!/usr/bin/env bash
# S5: typeck_wpo.o WPO reach gate (typeck_x_ast / check_block / check_expr defined).
#
# Honesty: soft XLANG_WPO_TYPECK_REACH_FAIL:-0 retired — missing .o soft
# SKIP→OK and soft die→exit0 on undefined/under-exports were portable
# false-green. Missing artifact is hard die. Symbol / export floors hard.
# Parent o-gates must not force REACH_FAIL=0.
#
# Usage:
#   ./tests/run-wpo-typeck-reach-gate.sh
#   ./tests/run-wpo-typeck-reach-gate.sh compiler/build_asm/typeck_wpo.o
# Report: run=/exports=/skip=
# PLATFORM: SHARED — Mach-O may prefix `_`; nm matches both.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

TYPECK_O="${1:-compiler/build_asm/typeck_wpo.o}"
MIN_EXPORTS=${XLANG_WPO_TYPECK_MIN_EXPORTS:-5}
PREFIX="xlang: [XLANG_WPO_TYPECK_REACH]"

die() {
  echo "run-wpo-typeck-reach-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=0 exports=0 skip=0 host=$(ci_host_summary)"
  exit 1
}

if [ ! -f "$TYPECK_O" ]; then
  die "missing $TYPECK_O (refuse soft SKIP→OK)"
fi

if ! nm "$TYPECK_O" 2>/dev/null | grep -qE ' T (_)?typeck_x_ast'; then
  die "$TYPECK_O missing typeck_x_ast export"
fi

MISSING=""
for sym in check_block check_expr; do
  if nm "$TYPECK_O" 2>/dev/null | grep -qE " U ${sym}$"; then
    MISSING="${MISSING} ${sym}"
  fi
done

EXPORTS=$(nm "$TYPECK_O" 2>/dev/null | awk '/ T / { c++ } END { print c+0 }')

echo "run-wpo-typeck-reach-gate: $TYPECK_O exports=${EXPORTS} (min=${MIN_EXPORTS})"

if [ -n "$MISSING" ]; then
  die "undefined entry symbol(s):${MISSING}"
fi
if [ "$EXPORTS" -lt "$MIN_EXPORTS" ] 2>/dev/null; then
  die "export count ${EXPORTS} < min ${MIN_EXPORTS}"
fi

echo "run-wpo-typeck-reach-gate OK (typeck_x_ast+check_block/check_expr defined, exports=${EXPORTS})"
echo "${PREFIX} status=ok run=1 exports=${EXPORTS} skip=0 host=$(ci_host_summary)"
