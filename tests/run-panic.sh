#!/usr/bin/env bash
# panic() / panic(expr)：编译通过，运行会 abort（仅验证编译与链接）
set -e
cd "$(dirname "$0")/.."
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi
XLANG=${XLANG:-./compiler/xlang}
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
LINK_XLANG="$RUN_XLANG"
# PLATFORM: SHARED — product bstrict/L4 uses this-SHA xlang_asm.
# Preferring leftover Stage2 xlang_asm2 is July-14 wrong-binary (stale gen2
# false green/red). Opt-in: XLANG_BSTRICT_USE_ASM2=1 (align run-all-bstrict).
if [ -n "${XLANG_BSTRICT_USE_ASM2:-}" ] && [ -x ./compiler/xlang_asm2 ] &&
    ci_native_xlang ./compiler/xlang_asm2; then
  LINK_XLANG=./compiler/xlang_asm2
elif [ -x ./compiler/xlang_asm ] && ci_native_xlang ./compiler/xlang_asm; then
  LINK_XLANG=./compiler/xlang_asm
fi

$LINK_XLANG build tests/panic/main.x -o /tmp/xlang_panic 2>&1
$LINK_XLANG build tests/panic/with_msg.x -o /tmp/xlang_panic_msg 2>&1
$LINK_XLANG build tests/panic/with_str.x -o /tmp/xlang_panic_str 2>&1
# 运行预期非 0 退出（abort）；整组命令 stderr 重定向，尽量抑制 shell 打印 "Abort trap: 6"
exitcode=0; { ( /tmp/xlang_panic 2>/dev/null ) 2>/dev/null || exitcode=$?; } 2>/dev/null
[ "$exitcode" -eq 0 ] && { echo "expected non-zero exit (panic abort)"; exit 1; }
exitcode=0; { ( /tmp/xlang_panic_msg 2>/dev/null ) 2>/dev/null || exitcode=$?; } 2>/dev/null
[ "$exitcode" -eq 0 ] && { echo "expected non-zero exit (panic(42) abort)"; exit 1; }
exitcode=0; { ( /tmp/xlang_panic_str 2>/dev/null ) 2>/dev/null || exitcode=$?; } 2>/dev/null
[ "$exitcode" -eq 0 ] && { echo "expected non-zero exit (panic(string) abort)"; exit 1; }

# wave386: cstr message must appear on stderr (host-C / C runtime_panic; Linux .s write(2)).
str_err=$(/tmp/xlang_panic_str 2>&1 >/dev/null || true)
case "$str_err" in
  *boom*) ;;
  *)
    echo "expected panic cstr 'boom' on stderr, got: [$str_err]"
    exit 1
    ;;
esac

# wave389: integer panic(42) → "panic: 42" (Linux freestanding .s itoa; host-C fprintf).
msg_err=$(/tmp/xlang_panic_msg 2>&1 >/dev/null || true)
case "$msg_err" in
  *42*) ;;
  *)
    echo "expected panic int '42' on stderr, got: [$msg_err]"
    exit 1
    ;;
esac

echo "panic test OK"
