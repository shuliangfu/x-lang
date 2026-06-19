#!/usr/bin/env bash
# 测试 std.heap（alloc_size_zero）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

$SHUX -L . tests/heap/main.sx -o /tmp/shux_heap 2>&1
exitcode=0; /tmp/shux_heap >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (alloc_size_zero), got $exitcode"; exit 1; }

echo "heap test OK"
