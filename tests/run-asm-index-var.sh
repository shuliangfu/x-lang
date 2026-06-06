#!/usr/bin/env bash
# asm 7.3：VAR+VAR INDEX 直 load/lea（无 push/pop）；反汇编须无 sub sp 临时保存 base。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHU=${SHU:-./compiler/shu}

$SHU tests/asm/index_var_fast.su -o /tmp/shu_asm_index_var 2>&1
exitcode=0
/tmp/shu_asm_index_var >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 10 ] && { echo "run-asm-index-var FAIL: expected exit 10, got $exitcode"; exit 1; }

if otool -tv /tmp/shu_asm_index_var 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'sub.*sp, sp, #0x10'; then
  echo "run-asm-index-var FAIL: main still uses stack push for INDEX (expected direct ldr)"
  exit 1
fi

echo "asm index var fast OK"
