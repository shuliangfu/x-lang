#!/usr/bin/env bash
# 测试 core.option 全 API：Option_i32 / Option_u8（none/some/unwrap_or/expect/is_some/is_none、or/and）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

# Alpine/Docker 等环境默认栈较小，typeck/codegen 处理 option 时可能栈溢出；提高栈限制（16MB）
ulimit -s 16384 2>/dev/null || true

# 本机可执行 xlang 探测（Docker 优先 xlang-c，避免 bind-mount Mach-O xlang SIGSEGV）
_option_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

XLANG="${XLANG:-}"
if [ -z "$XLANG" ] || ! _option_native_xlang "$XLANG"; then
  for cand in ./compiler/xlang-c ./compiler/xlang; do
    if _option_native_xlang "$cand"; then
      XLANG="$cand"
      break
    fi
  done
fi
if [ -z "$XLANG" ] || ! _option_native_xlang "$XLANG"; then
  echo "option: no native xlang" >&2
  exit 1
fi

# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

# 产品路径：必须用 $XLANG（或 RUN_XLANG）真 -o + 运行；禁止 check-only 假绿。
LINK_XLANG="${RUN_XLANG:-$XLANG}"

_option_try_compile() {
  local comp="$1"
  [ -x "$comp" ] || return 1
  "$comp" -backend c -L . tests/option/main.x -o /tmp/xlang_option 2>&1
}

set +e
_option_try_compile "$LINK_XLANG"
_compile_ec=$?
set -e
_OPTION_NOTE=""
if [ "$_compile_ec" -ne 0 ]; then
  echo "option: product -o failed on $LINK_XLANG build (exit $_compile_ec)" >&2
  exit "$_compile_ec"
fi

exitcode=0; /tmp/xlang_option >/dev/null 2>&1 || exitcode=$?
# 10+42+7 + unwrap_or_u8(some_u8(3),0)=3 + unwrap_or_u8(none_u8(),5)=5 + map/and_then/generic/ptr extra=35 → 102
[ "$exitcode" -ne 102 ] && { echo "expected exit 102, got $exitcode"; exit 1; }

echo "option test OK"
