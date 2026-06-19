#!/usr/bin/env bash
# asm 7.3：arr[lit]=value 字面量下标赋值直 lea/add→rbx，main 内无 mov x2。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

$SHUX tests/asm/assign_index_lit_fast.sx -o /tmp/shux_asm_assign_index_lit 2>&1
exitcode=0
/tmp/shux_asm_assign_index_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-lit FAIL: expected exit 99, got $exitcode"; exit 1; }

if otool -tv /tmp/shux_asm_assign_index_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-lit FAIL: main still uses x2 for literal-index assign"
  exit 1
fi

echo "asm assign index lit OK"
