#!/usr/bin/env bash
# 测试 core.types（size_of_*）与 core.debug.assert
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
# core.types 符号由 base64.o 提供（co-emit skip）；须预编 .o 供 asm -o 链入。
xlang_compiler_make -q ../std/base64/base64.o 2>/dev/null || xlang_compiler_make ../std/base64/base64.o
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
LINK_XLANG="$RUN_XLANG"
ulimit -s 65532 2>/dev/null || true

$LINK_XLANG build -L . tests/core-types-size/main.x -o /tmp/xlang_core_types 2>&1
exitcode=0; /tmp/xlang_core_types >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (core.types size_of + assert), got $exitcode"; exit 1; }

echo "core-types test OK"
