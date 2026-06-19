#!/usr/bin/env bash
# asm 7.3：非交换 div/shift 左 binop + 右 INDEX 须 preserve rbx；块内连续 INDEX assign 无 x2。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

$SHUX tests/asm/binop_div_index_binop.sx -o /tmp/shux_asm_div_index_binop 2>&1
exitcode=0
/tmp/shux_asm_div_index_binop >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 2 ] && { echo "run-asm-binop-div-index FAIL: div index/binop expected 2, got $exitcode"; exit 1; }

$SHUX tests/asm/binop_div_binop_index.sx -o /tmp/shux_asm_div_binop_index 2>&1
exitcode=0
/tmp/shux_asm_div_binop_index >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 10 ] && { echo "run-asm-binop-div-index FAIL: div binop/index expected 10, got $exitcode"; exit 1; }

$SHUX tests/asm/assign_index_block_seq.sx -o /tmp/shux_asm_assign_index_block 2>&1
exitcode=0
/tmp/shux_asm_assign_index_block >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 45 ] && { echo "run-asm-binop-div-index FAIL: block seq expected 45, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_block 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-binop-div-index FAIL: block seq main still uses mov x2"
  exit 1
fi

echo "asm binop div index OK"
