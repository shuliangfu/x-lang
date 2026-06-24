#!/usr/bin/env bash
# 固定长数组 T[N]：初值 0、字面量初始化、下标
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

$SHUX tests/array/main.sx -o /tmp/shux_array_main 2>&1
exitcode=0; /tmp/shux_array_main >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected 0 (array main), got $exitcode"; exit 1; }

$SHUX tests/array/literal.sx -o /tmp/shux_array_lit 2>&1
exitcode=0; /tmp/shux_array_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 1 ] && { echo "expected 1 (array literal a[0]), got $exitcode"; exit 1; }

# 边界：下标基类型非数组/切片，应报 subscript base must be array, slice or pointer
err=$($SHUX tests/array/subscript_not_array.sx -o /tmp/shux_array_fail 2>&1) || true
echo "$err" | grep -q "subscript base must be array" || { echo "expected subscript base error, got: $err"; exit 1; }

echo "array test OK"
