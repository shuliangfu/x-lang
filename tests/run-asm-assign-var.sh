#!/usr/bin/env bash
# asm 7.3：FIELD_ACCESS / INDEX 赋值免 push/pop 保存左值址。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

$SHUX tests/asm/assign_lval_fast.sx -o /tmp/shux_asm_assign_var 2>&1
exitcode=0
/tmp/shux_asm_assign_var >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 52 ] && { echo "run-asm-assign-var FAIL: expected exit 52, got $exitcode"; exit 1; }

if otool -tv /tmp/shux_asm_assign_var 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'sub.*sp, sp, #0x10'; then
  echo "run-asm-assign-var FAIL: main still uses stack push for assign lvalue"
  exit 1
fi

echo "asm assign lval fast OK"
