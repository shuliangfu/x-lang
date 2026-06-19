#!/usr/bin/env bash
# asm 7.3：arr[i] = a + b 须先 emit 右值再 INDEX 址→rbx（arm64 x1 不被 binop clobber）。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

$SHUX tests/asm/assign_index_binop_fast.sx -o /tmp/shux_asm_assign_index_binop 2>&1
exitcode=0
/tmp/shux_asm_assign_index_binop >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 42 ] && { echo "run-asm-assign-index-binop FAIL: expected exit 42, got $exitcode"; exit 1; }

if otool -tv /tmp/shux_asm_assign_index_binop 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'sub.*sp, sp, #0x10'; then
  echo "run-asm-assign-index-binop FAIL: main still uses stack push for index assign+binop"
  exit 1
fi

echo "asm assign index binop OK"
