#!/usr/bin/env bash
# 阶段 6：含 import std.io 的 .x 能解析、typeck 并产出可执行文件

set -e
cd "$(dirname "$0")/.."
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi
XLANG=${XLANG:-./compiler/xlang}
out=$($XLANG build -L . tests/std/main.x 2>&1)
echo "$out" | grep -q "parse OK" || { echo "expected parse OK"; echo "$out"; exit 1; }
echo "$out" | grep -q "typeck OK" || { echo "expected typeck OK"; echo "$out"; exit 1; }
$XLANG build -L . tests/std/main.x -o /tmp/xlang_std_hello 2>&1
/tmp/xlang_std_hello | grep -q "Hello World" || { echo "expected Hello World"; exit 1; }
echo "std import test OK"
