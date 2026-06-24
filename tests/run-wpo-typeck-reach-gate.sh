#!/usr/bin/env bash
# S5：typeck_wpo.o WPO reach 门禁（typeck_sx_ast / check_block / check_expr 须已定义）。
# 用法：
#   ./tests/run-wpo-typeck-reach-gate.sh
#   SHUX_WPO_TYPECK_REACH_FAIL=1 ./tests/run-wpo-typeck-reach-gate.sh
set -e
cd "$(dirname "$0")/.."

TYPECK_O="${1:-compiler/build_asm/typeck_wpo.o}"
FAIL=${SHUX_WPO_TYPECK_REACH_FAIL:-1}
MIN_EXPORTS=${SHUX_WPO_TYPECK_MIN_EXPORTS:-5}

if [ ! -f "$TYPECK_O" ]; then
  echo "run-wpo-typeck-reach-gate SKIP: missing $TYPECK_O"
  exit 0
fi

if ! nm "$TYPECK_O" 2>/dev/null | grep -qE ' T (_)?typeck_sx_ast'; then
  echo "run-wpo-typeck-reach-gate FAIL: $TYPECK_O missing typeck_sx_ast export" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

MISSING=""
for sym in check_block check_expr; do
  if nm "$TYPECK_O" 2>/dev/null | grep -qE " U ${sym}$"; then
    MISSING="${MISSING} ${sym}"
  fi
done

EXPORTS=$(nm "$TYPECK_O" 2>/dev/null | awk '/ T / { c++ } END { print c+0 }')

echo "run-wpo-typeck-reach-gate: $TYPECK_O exports=${EXPORTS} (min=${MIN_EXPORTS})"

gate_fail=0
if [ -n "$MISSING" ]; then
  echo "run-wpo-typeck-reach-gate FAIL: undefined entry symbol(s):${MISSING}" >&2
  gate_fail=1
fi
if [ "$EXPORTS" -lt "$MIN_EXPORTS" ] 2>/dev/null; then
  echo "run-wpo-typeck-reach-gate FAIL: export count ${EXPORTS} < min ${MIN_EXPORTS}" >&2
  gate_fail=1
fi

if [ "$gate_fail" -ne 0 ]; then
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "run-wpo-typeck-reach-gate OK (typeck_sx_ast+check_block/check_expr defined, exports=${EXPORTS})"
