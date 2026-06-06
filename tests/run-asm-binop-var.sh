#!/usr/bin/env bash
# asm 7.3：VAR+VAR binop 直 load 栈槽（无 push/pop）；反汇编须无 sub sp 临时保存左操作数。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHU=${SHU:-./compiler/shu}

$SHU tests/asm/binop_var_fast.su -o /tmp/shu_asm_binop_var 2>&1
exitcode=0
/tmp/shu_asm_binop_var >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 143 ] && { echo "run-asm-binop-var FAIL: expected exit 143, got $exitcode"; exit 1; }

# a+b 路径不应出现 push 左操作数到栈（sub sp,#0x10; str x0,[sp] 成对出现于 binop fallback）
if otool -tv /tmp/shu_asm_binop_var 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'sub.*sp, sp, #0x10'; then
  echo "run-asm-binop-var FAIL: main still uses stack push for binop (expected direct ldr)"
  exit 1
fi

echo "asm binop var fast OK"
