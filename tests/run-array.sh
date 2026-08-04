#!/usr/bin/env bash
# 固定长数组 T[N]：初值 0、字面量初始化、下标
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
fi
XLANG=${XLANG:-./compiler/xlang}
# PLATFORM: SHARED — product bstrict uses this-SHA xlang_asm; leftover xlang_asm2
# only with XLANG_BSTRICT_USE_ASM2=1 (July-14 wrong-binary ban; see run-all-bstrict.sh).
if [ -n "${XLANG_RUN_ALL_BOOTSTRAP_XLANG:-}" ]; then
  if [ -n "${XLANG_BSTRICT_USE_ASM2:-}" ] && [ -x ./compiler/xlang_asm2 ]; then
    XLANG=./compiler/xlang_asm2
  elif [ -x ./compiler/xlang_asm ]; then
    XLANG=./compiler/xlang_asm
  fi
fi

$XLANG build tests/array/main.x -o /tmp/xlang_array_main 2>&1
exitcode=0; /tmp/xlang_array_main >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected 0 (array main), got $exitcode"; exit 1; }

$XLANG build tests/array/literal.x -o /tmp/xlang_array_lit 2>&1
exitcode=0; /tmp/xlang_array_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 1 ] && { echo "expected 1 (array literal a[0]), got $exitcode"; exit 1; }

# 边界：下标基类型非数组/切片，应报 subscript base must be array, slice or pointer
err=$($XLANG build tests/array/subscript_not_array.x -o /tmp/xlang_array_fail 2>&1) || true
echo "$err" | grep -q "subscript base must be array" || { echo "expected subscript base error, got: $err"; exit 1; }

echo "array test OK"
