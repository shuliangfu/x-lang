#!/usr/bin/env bash
# S5：backend_wpo.o WPO reach 门禁（asm_codegen_ast / emit_expr_elf / emit_block_body_elf 须已定义）。
# 用法：
#   ./tests/run-wpo-backend-reach-gate.sh
#   XLANG_WPO_BACKEND_REACH_FAIL=1 ./tests/run-wpo-backend-reach-gate.sh
set -e
cd "$(dirname "$0")/.."

BACKEND_O="${1:-compiler/build_asm/backend_wpo.o}"
FAIL=${XLANG_WPO_BACKEND_REACH_FAIL:-1}
# Tip WPO-compressed backend_wpo has exactly 4 T exports (asm_codegen_ast +
# asm_codegen_ast_to_elf + emit_expr_elf + emit_block_body_elf). Old min=5
# rejected true DCE. PLATFORM: SHARED.
MIN_EXPORTS=${XLANG_WPO_BACKEND_MIN_EXPORTS:-4}

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
# PLATFORM: SHARED — Mach-O undefined symbols are `U _sym`.
for sym in asm_codegen_ast emit_expr_elf emit_block_body_elf; do
  if nm "$BACKEND_O" 2>/dev/null | grep -qE " U (_)?${sym}$"; then
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
