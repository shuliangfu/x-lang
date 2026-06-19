#!/usr/bin/env bash
# asm 7.3：字面量下标 INDEX+VAR binop 免 x2 暂存 rbx（add_imm 路径）。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

$SHUX tests/asm/binop_index_lit_fast.sx -o /tmp/shux_asm_binop_index_lit 2>&1
exitcode=0
/tmp/shux_asm_binop_index_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 75 ] && { echo "run-asm-binop-index-lit FAIL: expected exit 75, got $exitcode"; exit 1; }

if otool -tv /tmp/shux_asm_binop_index_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-binop-index-lit FAIL: main still uses x2 scratch for literal-index binop"
  exit 1
fi

echo "asm binop index lit OK"
