#!/usr/bin/env bash
# asm 7.3：cmp 左 INDEX(rbx) + 右 binop slow emit 须 preserve rbx；10 < 15 → exit 1。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

$SHUX tests/asm/cmp_index_binop_fast.x -o /tmp/shux_asm_cmp_index_binop 2>&1
exitcode=0
/tmp/shux_asm_cmp_index_binop >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 1 ] && { echo "run-asm-cmp-index-binop FAIL: expected exit 1, got $exitcode"; exit 1; }

echo "asm cmp index binop OK"
