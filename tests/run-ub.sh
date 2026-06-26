#!/usr/bin/env bash
# 运行 UB 收窄测试：除零、越界应 panic（exit 134 = SIGABRT），正常路径应正常返回
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
SHUX="${SHUX:-./compiler/shux}"
LINK_SHUX="${SHUX_LINK_SHUX:-${RUN_SHUX:-$SHUX}}"
# bootstrap seed shux 对 asm -o 烟测易 SIGSEGV；有 shux_asm(2) 时用于 -o 链接/运行（与 W3 gate COMPILE_SHUX 一致）。
if [ "$SHUX" = "./compiler/shux" ] || [ "$SHUX" = "compiler/shux" ]; then
  if [ -x ./compiler/shux_asm2 ]; then
    LINK_SHUX=./compiler/shux_asm2
  elif [ -x ./compiler/shux_asm ]; then
    LINK_SHUX=./compiler/shux_asm
  fi
fi
run_panic() {
    "$LINK_SHUX" "$1" -o /tmp/ub_test 2>/dev/null || exit 1
    set +e; { ( /tmp/ub_test 2>/dev/null ) 2>/dev/null; r=$?; } 2>/dev/null; set -e
    if [ "$r" -eq 134 ] || [ "$r" -ne 0 ]; then
        echo "  $1: panic/abort (expected)"
    else
        echo "  $1: unexpected exit $r"; exit 1
    fi
}
run_ok() {
    "$LINK_SHUX" "$1" -o /tmp/ub_ok 2>/dev/null || exit 1
    set +e; /tmp/ub_ok 2>/dev/null; r=$?; set -e
    echo "  $1: exit $r"
}
echo "ub: div_zero (expect panic)"
run_panic tests/ub/div_zero.sx
echo "ub: bounds_array (expect panic)"
run_panic tests/ub/bounds_array.sx
echo "ub: bounds_slice (expect panic)"
run_panic tests/ub/bounds_slice.sx
echo "ub: div_ok (expect exit 3)"
run_ok tests/ub/div_ok.sx
echo "ub: OK"
