#!/usr/bin/env bash
# 测试 core.types（size_of_*）与 core.debug.assert
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

$SHUX -L . tests/core-types-size/main.sx -o /tmp/shux_core_types 2>&1
exitcode=0; /tmp/shux_core_types >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (core.types size_of + assert), got $exitcode"; exit 1; }

echo "core-types test OK"
