#!/usr/bin/env bash
# 验证多函数与函数调用：add(a,b) 与 main 调用 add(1,2)，程序退出码为 3。
# 由 compiler/Makefile 的 test 目标与 tests/run-all.sh 调用。

set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi
"$RUN_SHUX" tests/multi-func/main.x -o /tmp/shux_multi_func 2>&1
exitcode=0
/tmp/shux_multi_func >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 3 ]; then
    echo "expected exit code 3 (add(1,2)), got $exitcode"
    exit 1
fi
echo "multi-func test OK"
