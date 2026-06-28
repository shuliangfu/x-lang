#!/usr/bin/env bash
# 测试 std.error（ok）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

$SHUX -L . tests/error/main.sx -o /tmp/shux_error 2>&1
exitcode=0; /tmp/shux_error >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (ok), got $exitcode"; exit 1; }

echo "error test OK"
