#!/usr/bin/env bash
# 测试 core.builtin（placeholder、位运算、copy/min/max）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler shu-c
make -C compiler -q ../core/builtin/builtin.o 2>/dev/null || make -C compiler ../core/builtin/builtin.o
# shellcheck source=tests/lib/bootstrap-link-shu.sh
. "$(dirname "$0")/lib/bootstrap-link-shu.sh"

$RUN_SHU -L . tests/builtin/main.su -o /tmp/shu_builtin 2>&1
exitcode=0; /tmp/shu_builtin >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (core.builtin placeholder), got $exitcode"; exit 1; }

echo "builtin test OK"
