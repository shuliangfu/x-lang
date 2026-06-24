#!/usr/bin/env bash
# 测试 core.debug（alias）/ core.assert：assert(true) 通过并返回 0
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler shux-c
SHUX=${SHUX:-./compiler/shux-c}

$SHUX -L . tests/debug/main.sx -o /tmp/shux_debug 2>&1
exitcode=0
/tmp/shux_debug >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (assert(true)), got $exitcode"; exit 1; }
echo "debug test OK"
