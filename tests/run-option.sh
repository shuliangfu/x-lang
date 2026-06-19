#!/usr/bin/env bash
# 测试 core.option 全 API：Option_i32 / Option_u8（none/some/unwrap_or/expect/is_some/is_none、or/and）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

# Alpine/Docker 等环境默认栈较小，typeck/codegen 处理 option 时可能栈溢出；提高栈限制（16MB）
ulimit -s 16384 2>/dev/null || true
SHUX=${SHUX:-./compiler/shux}
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"

# bootstrap / shux_asm：typeck 走 $SHUX（check）；-o 链接用 shux-c（seed/shux_asm 全链路 -o 在 ubuntu 易 SIGSEGV）。
LINK_SHUX="$RUN_SHUX"
_option_split=0
if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ]; then
  _option_split=1
fi
case "${SHUX:-}" in
  *shux_asm*) _option_split=1 ;;
esac
if [ "$_option_split" = "1" ]; then
  chk_out=$($SHUX check -L . tests/option/main.sx 2>&1) || chk_rc=$?
  chk_rc=${chk_rc:-0}
  if [ "$chk_rc" -ne 0 ]; then
    echo "option: check failed on $SHUX (exit $chk_rc)" >&2
    echo "$chk_out"
    exit "$chk_rc"
  fi
  if [ -x ./compiler/shux-c ]; then
    LINK_SHUX=./compiler/shux-c
  fi
fi

$LINK_SHUX -L . tests/option/main.sx -o /tmp/shux_option 2>&1
exitcode=0; /tmp/shux_option >/dev/null 2>&1 || exitcode=$?
# 10+42+7 + unwrap_or_u8(some_u8(3),0)=3 + unwrap_or_u8(none_u8(),5)=5 + map/and_then/generic/ptr extra=35 → 102
[ "$exitcode" -ne 102 ] && { echo "expected exit 102, got $exitcode"; exit 1; }

echo "option test OK"
