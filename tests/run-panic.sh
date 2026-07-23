#!/usr/bin/env bash
# panic() / panic(expr)：编译通过，运行会 abort（仅验证编译与链接）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
XLANG=${XLANG:-./compiler/xlang}
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
LINK_XLANG="$RUN_XLANG"
# panic -o：bootstrap 默认 xlang-c 对 main.x 易 SIGSEGV；xlang_asm2 已绿（与 run-struct 一致）。
if [ -x ./compiler/xlang_asm2 ] && ci_native_xlang ./compiler/xlang_asm2; then
  LINK_XLANG=./compiler/xlang_asm2
fi

$LINK_XLANG build tests/panic/main.x -o /tmp/xlang_panic 2>&1
$LINK_XLANG build tests/panic/with_msg.x -o /tmp/xlang_panic_msg 2>&1
# 运行预期非 0 退出（abort）；整组命令 stderr 重定向，尽量抑制 shell 打印 "Abort trap: 6"
exitcode=0; { ( /tmp/xlang_panic 2>/dev/null ) 2>/dev/null || exitcode=$?; } 2>/dev/null
[ "$exitcode" -eq 0 ] && { echo "expected non-zero exit (panic abort)"; exit 1; }
exitcode=0; { ( /tmp/xlang_panic_msg 2>/dev/null ) 2>/dev/null || exitcode=$?; } 2>/dev/null
[ "$exitcode" -eq 0 ] && { echo "expected non-zero exit (panic(42) abort)"; exit 1; }

echo "panic test OK"
