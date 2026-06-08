#!/usr/bin/env bash
# 测试 core.option 全 API：Option_i32 / Option_u8（none/some/unwrap_or/expect/is_some/is_none、or/and）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

# Alpine/Docker 等环境默认栈较小，typeck/codegen 处理 option 时可能栈溢出；提高栈限制（16MB）
ulimit -s 16384 2>/dev/null || true
SHU=${SHU:-./compiler/shu}
# shellcheck source=lib/bootstrap-link-shu.sh
. "$(dirname "$0")/lib/bootstrap-link-shu.sh"

# bootstrap / shu_asm：typeck 走 $SHU（check）；-o 链接用 shu-c（seed/shu_asm 全链路 -o 在 ubuntu 易 SIGSEGV）。
LINK_SHU="$RUN_SHU"
_option_split=0
if [ -n "${SHULANG_RUN_ALL_BOOTSTRAP_SHU:-}" ]; then
  _option_split=1
fi
case "${SHU:-}" in
  *shu_asm*) _option_split=1 ;;
esac
if [ "$_option_split" = "1" ]; then
  chk_out=$($SHU check -L . tests/option/main.su 2>&1) || chk_rc=$?
  chk_rc=${chk_rc:-0}
  if [ "$chk_rc" -ne 0 ]; then
    echo "option: check failed on $SHU (exit $chk_rc)" >&2
    echo "$chk_out"
    exit "$chk_rc"
  fi
  if [ -x ./compiler/shu-c ]; then
    LINK_SHU=./compiler/shu-c
  fi
fi

$LINK_SHU -L . tests/option/main.su -o /tmp/shu_option 2>&1
exitcode=0; /tmp/shu_option >/dev/null 2>&1 || exitcode=$?
# 10+42+7 + unwrap_or_u8(some_u8(3),0)=3 + unwrap_or_u8(none_u8(),5)=5 → 59+3+5=67
[ "$exitcode" -ne 67 ] && { echo "expected exit 67, got $exitcode"; exit 1; }

echo "option test OK"
