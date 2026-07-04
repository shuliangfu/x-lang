#!/usr/bin/env bash
# asm 7.3：arr[lit]=arr[lit] 双字面量 INDEX 赋值，main 内无 mov x2。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

$SHUX tests/asm/assign_index_lit_to_index.x -o /tmp/shux_asm_assign_index_lit_to_index 2>&1
exitcode=0
/tmp/shux_asm_assign_index_lit_to_index >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 15 ] && { echo "run-asm-assign-index-lit-to-index FAIL: expected exit 15, got $exitcode"; exit 1; }

if otool -tv /tmp/shux_asm_assign_index_lit_to_index 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-lit-to-index FAIL: main still uses x2 for lit-to-lit index assign"
  exit 1
fi

echo "asm assign index lit to index OK"
