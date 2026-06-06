#!/usr/bin/env bash
# asm 7.3：VAR+VAR 向量逐 lane binop 直 ldr（无 push/pop）；基于 vec_add_check.su。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHU=${SHU:-./compiler/shu}

$SHU tests/vector/vec_add_check.su -o /tmp/shu_asm_vector_var 2>&1
exitcode=0
/tmp/shu_asm_vector_var >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "run-asm-vector-var FAIL: expected exit 0, got $exitcode"; exit 1; }

if otool -tv /tmp/shu_asm_vector_var 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'sub.*sp, sp, #0x10'; then
  echo "run-asm-vector-var FAIL: main still uses stack push for vector lane binop"
  exit 1
fi

echo "asm vector var fast OK"
