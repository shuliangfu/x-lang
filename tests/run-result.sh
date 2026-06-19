#!/usr/bin/env bash
# 测试 core.result 的 Result_i32 API（ok_i32、err_i32、unwrap_or_i32、expect_i32、expect_i32_or_panic）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

$SHUX -L . tests/result/main.sx -o /tmp/shux_result 2>&1
exitcode=0; /tmp/shux_result >/dev/null 2>&1 || exitcode=$?
# 42+0+3+5=50 + map/and_then/or_else/Result_u8 extra=123 → 173
[ "$exitcode" -ne 173 ] && { echo "expected exit 173, got $exitcode"; exit 1; }

echo "result test OK"
