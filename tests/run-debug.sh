#!/usr/bin/env bash
# 测试 debug 相关模块（合并自 run-debug.sh + run-core-assert.sh）：
# - core.debug (alias): assert/debug_assert/assert_eq_i32/assert_ne_i32/assert_eq_u32/assert_ne_u32/assert_eq_bool (tests/debug/main.x)
# - core.assert: assert(true)/assert_eq_i32(1,1) (tests/core-assert/main.x) — merged from run-core-assert.sh
# 注：run-std-debug.sh 暂未合并 — 发现 std.debug.println 返回 io.write_stderr 字节数（11），
# 而 tests/std-debug/main.x 期望 a == 0；语义不匹配导致 ec=1。std.debug bug 待单独修复（超出 C7 范围）。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler shux-c
SHUX=${SHUX:-./compiler/shux-c}

# === core.debug (alias) + assert 变体 ===
$SHUX build -L . tests/debug/main.x -o /tmp/shux_debug 2>&1
exitcode=0
/tmp/shux_debug >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (assert(true)), got $exitcode"; exit 1; }
echo "core.debug test OK"

# === core.assert (merged from run-core-assert.sh) ===
# tests/core-assert/main.x: import core.assert; assert(true) + assert_eq_i32(1,1) → exit 0
$SHUX build -L . tests/core-assert/main.x -o /tmp/shux_core_assert 2>&1
ec=0
/tmp/shux_core_assert >/dev/null 2>&1 || ec=$?
[ "$ec" -ne 0 ] && { echo "core-assert: expected exit 0, got $ec"; exit 1; }
echo "core.assert test OK"

echo "debug test OK"
