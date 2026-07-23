#!/usr/bin/env bash
# 验证 bool 类型与 true/false 字面量；if 条件须为 bool。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
XLANG=${XLANG:-./compiler/xlang}

# let ok: bool = true; if ok { 42 } else { 0 } -> 42（test_c 传 XLANG=./compiler/xlang-c 时用 C 流水线）
$XLANG build tests/bool/simple.x -o /tmp/xlang_bool 2>&1
exitcode=0
/tmp/xlang_bool >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 42 ] && { echo "expected 42 (bool simple), got $exitcode"; exit 1; }

echo "bool test OK"
