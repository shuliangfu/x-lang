#!/usr/bin/env bash
# S5：backend_wpo.o WPO reach 门禁（asm_codegen_ast / emit_expr_elf / emit_block_body_elf 须已定义）。
# 用法：
#   ./tests/run-wpo-backend-reach-gate.sh
#   SHUX_WPO_BACKEND_REACH_FAIL=1 ./tests/run-wpo-backend-reach-gate.sh
set -e
cd "$(dirname "$0")/.."

BACKEND_O="${1:-compiler/build_asm/backend_wpo.o}"
FAIL=${SHUX_WPO_BACKEND_REACH_FAIL:-1}
MIN_EXPORTS=${SHUX_WPO_BACKEND_MIN_EXPORTS:-5}

if [ ! -f "$BACKEND_O" ]; then
  echo "run-wpo-backend-reach-gate SKIP: missing $BACKEND_O"
  exit 0
fi

if ! nm "$BACKEND_O" 2>/dev/null | grep -qE ' T (_)?asm_codegen_ast$'; then
  echo "run-wpo-backend-reach-gate FAIL: $BACKEND_O missing asm_codegen_ast export" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

MISSING=""
for sym in asm_codegen_ast emit_expr_elf emit_block_body_elf; do
  if nm "$BACKEND_O" 2>/dev/null | grep -qE " U ${sym}$"; then
    MISSING="${MISSING} ${sym}"
  fi
done

EXPORTS=$(nm "$BACKEND_O" 2>/dev/null | awk '/ T / { c++ } END { print c+0 }')

echo "run-wpo-backend-reach-gate: $BACKEND_O exports=${EXPORTS} (min=${MIN_EXPORTS})"

gate_fail=0
if [ -n "$MISSING" ]; then
  echo "run-wpo-backend-reach-gate FAIL: undefined entry symbol(s):${MISSING}" >&2
  gate_fail=1
fi
if [ "$EXPORTS" -lt "$MIN_EXPORTS" ] 2>/dev/null; then
  echo "run-wpo-backend-reach-gate FAIL: export count ${EXPORTS} < min ${MIN_EXPORTS}" >&2
  gate_fail=1
fi

if [ "$gate_fail" -ne 0 ]; then
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "run-wpo-backend-reach-gate OK (asm_codegen_ast+emit_* defined, exports=${EXPORTS})"
