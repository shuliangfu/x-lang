#!/usr/bin/env bash
# 测试 debug 相关模块（合并自 run-debug.sh + run-core-assert.sh + run-std-debug.sh）：
# - core.debug (alias): assert/debug_assert/assert_eq_i32/assert_ne_i32/assert_eq_u32/assert_ne_u32/assert_eq_bool (tests/debug/main.x)
# - core.assert: assert(true)/assert_eq_i32(1,1) (tests/core-assert/main.x) — merged from run-core-assert.sh
# - std.debug: stderr print + assert 重导出 (tests/std-debug/main.x) — merged from run-std-debug.sh
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler xlang-c
XLANG=${XLANG:-./compiler/xlang-c}

# === core.debug (alias) + assert 变体 ===
$XLANG build -L . tests/debug/main.x -o /tmp/xlang_debug 2>&1
exitcode=0
/tmp/xlang_debug >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (assert(true)), got $exitcode"; exit 1; }
echo "core.debug test OK"

# === core.assert (merged from run-core-assert.sh) ===
# tests/core-assert/main.x: import core.assert; assert(true) + assert_eq_i32(1,1) → exit 0
$XLANG build -L . tests/core-assert/main.x -o /tmp/xlang_core_assert 2>&1
ec=0
/tmp/xlang_core_assert >/dev/null 2>&1 || ec=$?
[ "$ec" -ne 0 ] && { echo "core-assert: expected exit 0, got $ec"; exit 1; }
echo "core.assert test OK"

# === std.debug (merged from run-std-debug.sh) ===
$XLANG build -L . tests/std-debug/main.x -o /tmp/xlang_std_debug 2>&1
ec=0
/tmp/xlang_std_debug >/dev/null 2>/tmp/xlang_std_debug_err.log || ec=$?
[ "$ec" -ne 0 ] && { echo "std-debug: run failed ec=$ec"; exit 1; }
grep -q 'debug line' /tmp/xlang_std_debug_err.log || { echo "std-debug: missing stderr output"; exit 1; }
echo "std.debug test OK"

echo "debug test OK"
