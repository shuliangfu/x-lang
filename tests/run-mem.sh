#!/usr/bin/env bash
# 测试 core.mem（align_of_i32）
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

"$RUN_XLANG" -L . tests/mem/main.x -o /tmp/xlang_mem 2>&1
exitcode=0; /tmp/xlang_mem >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (align_of_i32 == 4), got $exitcode"; exit 1; }

echo "mem test OK"
