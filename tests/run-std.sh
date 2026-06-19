#!/usr/bin/env bash
# 阶段 6：含 import std.io 的 .sx 能解析、typeck 并产出可执行文件

set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}
out=$($SHUX -L . tests/std/main.sx 2>&1)
echo "$out" | grep -q "parse OK" || { echo "expected parse OK"; echo "$out"; exit 1; }
echo "$out" | grep -q "typeck OK" || { echo "expected typeck OK"; echo "$out"; exit 1; }
$SHUX -L . tests/std/main.sx -o /tmp/shux_std_hello 2>&1
/tmp/shux_std_hello | grep -q "Hello World" || { echo "expected Hello World"; exit 1; }
echo "std import test OK"
