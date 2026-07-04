#!/usr/bin/env bash
# asm 7.3：FIELD_ACCESS / INDEX 赋值免 push/pop 保存左值址。
# 含 struct 字面量：-o 走 bootstrap LINK（bstrict 为 shux-c），与 run-asm-binop-field-index 一致。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
SHUX=${SHUX:-./compiler/shux}
LINK_SHUX="${SHUX_LINK_SHUX:-${RUN_SHUX:-$SHUX}}"

$LINK_SHUX tests/asm/assign_lval_fast.x -o /tmp/shux_asm_assign_var 2>&1
exitcode=0
/tmp/shux_asm_assign_var >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 52 ] && { echo "run-asm-assign-var FAIL: expected exit 52, got $exitcode"; exit 1; }

if otool -tv /tmp/shux_asm_assign_var 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'sub.*sp, sp, #0x10'; then
  echo "run-asm-assign-var FAIL: main still uses stack push for assign lvalue"
  exit 1
fi

echo "asm assign lval fast OK"
