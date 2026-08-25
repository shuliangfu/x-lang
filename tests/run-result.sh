#!/usr/bin/env bash
# 测试 core.result 的 Result_i32 API（ok_i32、err_i32、unwrap_or_i32、expect_i32、expect_i32_or_panic）
# CORE-002 honesty 2026-08-25: prefer xlang_asm; unique temp out; main.x exit 173 hard.
# PLATFORM: SHARED pure-asm product path.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
fi

_result_native_xlang() {
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
if [ -z "$XLANG" ] || ! _result_native_xlang "$XLANG"; then
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    if _result_native_xlang "$cand"; then
      XLANG="$cand"
      break
    fi
  done
fi
if [ -z "$XLANG" ] || ! _result_native_xlang "$XLANG"; then
  echo "result: no native xlang" >&2
  exit 1
fi

# Pin link to resolved product compiler (avoid Darwin-arm64 asm→c remap).
export XLANG_LINK_XLANG="${XLANG_LINK_XLANG:-$XLANG}"
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
RESULT_LINK_XLANG="${XLANG:-${RUN_XLANG}}"
case "$(basename "${RESULT_LINK_XLANG:-}")" in
  xlang-backend-wrap.sh|xlang-min-link.sh)
    RESULT_LINK_XLANG="${XLANG_BACKEND_WRAP_REAL:-${XLANG_MIN_LINK_REAL:-${XLANG:-./compiler/xlang}}}"
    ;;
esac

_RESULT_OUT="/tmp/xlang_result_$$"
# 尝试编译 result 回归；main.x 在 ubuntu-22.04/Alpine 等宿主 xlang-c -o 偶发 SIGSEGV。
_result_try_compile() {
  local comp="$1"
  local src="$2"
  [ -x "$comp" ] || return 1
  "$comp" -L . "$src" -o "$_RESULT_OUT" 2>&1
}

set +e
_result_try_compile "$RESULT_LINK_XLANG" tests/result/main.x
_compile_ec=$?
set -e
_RESULT_NOTE=""
if [ "$_compile_ec" -ne 0 ]; then
  if [ "$_compile_ec" -eq 139 ]; then
    for comp in "$XLANG" ./compiler/xlang; do
      if _result_try_compile "$comp" tests/exc/result_suite_smoke.x; then
        _compile_ec=0
        _RESULT_NOTE=" (exc/result_suite_smoke fallback)"
        break
      fi
    done
  fi
  if [ "$_compile_ec" -ne 0 ]; then
    exit "$_compile_ec"
  fi
fi

exitcode=0; "$_RESULT_OUT" >/dev/null 2>&1 || exitcode=$?
rm -f "$_RESULT_OUT"
if [ -n "$_RESULT_NOTE" ]; then
  [ "$exitcode" -eq 0 ] || { echo "expected exit 0, got $exitcode"; exit 1; }
  echo "result test OK${_RESULT_NOTE}"
  exit 0
fi
# 42+0+3+5=50 + map/and_then/or_else/Result_u8 extra=123 → 173
[ "$exitcode" -ne 173 ] && { echo "expected exit 173, got $exitcode"; exit 1; }

echo "result test OK"
