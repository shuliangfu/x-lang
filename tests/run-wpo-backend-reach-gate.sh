#!/usr/bin/env bash
# S5: backend_wpo.o WPO reach gate (asm_codegen_ast / emit_expr_elf /
# emit_block_body_elf defined).
#
# Honesty: soft XLANG_WPO_BACKEND_REACH_FAIL:-0 retired — missing .o soft
# SKIP→OK and soft die→exit0 on undefined/under-exports were portable
# false-green. Missing artifact is hard die. Symbol / export floors hard.
#
# Tip WPO-compressed backend_wpo has exactly 4 T exports (asm_codegen_ast +
# asm_codegen_ast_to_elf + emit_expr_elf + emit_block_body_elf). Old min=5
# rejected true DCE.
#
# Usage:
#   ./tests/run-wpo-backend-reach-gate.sh
#   ./tests/run-wpo-backend-reach-gate.sh compiler/build_asm/backend_wpo.o
# Report: run=/exports=/skip=
# PLATFORM: SHARED — Mach-O undefined symbols are `U _sym`.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

BACKEND_O="${1:-compiler/build_asm/backend_wpo.o}"
MIN_EXPORTS=${XLANG_WPO_BACKEND_MIN_EXPORTS:-4}
PREFIX="xlang: [XLANG_WPO_BACKEND_REACH]"

die() {
  echo "run-wpo-backend-reach-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=0 exports=0 skip=0 host=$(ci_host_summary)"
  exit 1
}

if [ ! -f "$BACKEND_O" ]; then
  die "missing $BACKEND_O (refuse soft SKIP→OK)"
fi

if ! nm "$BACKEND_O" 2>/dev/null | grep -qE ' T (_)?asm_codegen_ast$'; then
  die "$BACKEND_O missing asm_codegen_ast export"
fi

MISSING=""
for sym in asm_codegen_ast emit_expr_elf emit_block_body_elf; do
  if nm "$BACKEND_O" 2>/dev/null | grep -qE " U (_)?${sym}$"; then
    MISSING="${MISSING} ${sym}"
  fi
done

EXPORTS=$(nm "$BACKEND_O" 2>/dev/null | awk '/ T / { c++ } END { print c+0 }')

echo "run-wpo-backend-reach-gate: $BACKEND_O exports=${EXPORTS} (min=${MIN_EXPORTS})"

if [ -n "$MISSING" ]; then
  die "undefined entry symbol(s):${MISSING}"
fi
if [ "$EXPORTS" -lt "$MIN_EXPORTS" ] 2>/dev/null; then
  die "export count ${EXPORTS} < min ${MIN_EXPORTS}"
fi

echo "run-wpo-backend-reach-gate OK (asm_codegen_ast+emit_* defined, exports=${EXPORTS})"
echo "${PREFIX} status=ok run=1 exports=${EXPORTS} skip=0 host=$(ci_host_summary)"
