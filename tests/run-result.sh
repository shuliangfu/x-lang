#!/usr/bin/env bash
# 测试 core.result 的 Result_i32 API（ok_i32、err_i32、unwrap_or_i32、expect_i32、expect_i32_or_panic）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

# shux-c -o 在 ubuntu-22.04/ARM64 等宿主偶发 SIGSEGV；回退 C 前端 shux 完成 EXC-002 result_suite。
set +e
"$SHUX" -L . tests/result/main.sx -o /tmp/shux_result 2>&1
_compile_ec=$?
set -e
if [ "$_compile_ec" -ne 0 ]; then
  if [ "$_compile_ec" -eq 139 ] && [ -x ./compiler/shux ] && [ "$SHUX" != "./compiler/shux" ]; then
    ./compiler/shux -L . tests/result/main.sx -o /tmp/shux_result 2>&1
  else
    exit "$_compile_ec"
  fi
fi

exitcode=0; /tmp/shux_result >/dev/null 2>&1 || exitcode=$?
# 42+0+3+5=50 + map/and_then/or_else/Result_u8 extra=123 → 173
[ "$exitcode" -ne 173 ] && { echo "expected exit 173, got $exitcode"; exit 1; }

echo "result test OK"
