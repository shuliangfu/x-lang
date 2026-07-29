#!/usr/bin/env bash
# 阶段 6：含 import std.io 的 .x 能解析、typeck 并产出可执行文件

set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
fi
XLANG=${XLANG:-./compiler/xlang}
out=$($XLANG build -L . tests/std/main.x 2>&1)
echo "$out" | grep -q "parse OK" || { echo "expected parse OK"; echo "$out"; exit 1; }
echo "$out" | grep -q "typeck OK" || { echo "expected typeck OK"; echo "$out"; exit 1; }
$XLANG build -L . tests/std/main.x -o /tmp/xlang_std_hello 2>&1
/tmp/xlang_std_hello | grep -q "Hello World" || { echo "expected Hello World"; exit 1; }
echo "std import test OK"
