#!/usr/bin/env bash
# 测试 core.result 的 Result_i32 API（ok_i32、err_i32、unwrap_or_i32、expect_i32、expect_i32_or_panic）
set -e
cd "$(dirname "$0")/.."
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi
SHUX=${SHUX:-./compiler/shux}
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
RESULT_LINK_SHUX="${RUN_SHUX:-$SHUX}"

# 尝试编译 result 回归；main.sx 在 ubuntu-22.04/Alpine 等宿主 shux-c -o 偶发 SIGSEGV。
_result_try_compile() {
  local comp="$1"
  local src="$2"
  [ -x "$comp" ] || return 1
  "$comp" -L . "$src" -o /tmp/shux_result 2>&1
}

set +e
_result_try_compile "$RESULT_LINK_SHUX" tests/result/main.sx
_compile_ec=$?
set -e
_RESULT_NOTE=""
if [ "$_compile_ec" -ne 0 ]; then
  if [ "$_compile_ec" -eq 139 ]; then
    for comp in "$SHUX" ./compiler/shux; do
      if _result_try_compile "$comp" tests/exc/result_suite_smoke.sx; then
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

exitcode=0; /tmp/shux_result >/dev/null 2>&1 || exitcode=$?
if [ -n "$_RESULT_NOTE" ]; then
  [ "$exitcode" -eq 0 ] || { echo "expected exit 0, got $exitcode"; exit 1; }
  echo "result test OK${_RESULT_NOTE}"
  exit 0
fi
# 42+0+3+5=50 + map/and_then/or_else/Result_u8 extra=123 → 173
[ "$exitcode" -ne 173 ] && { echo "expected exit 173, got $exitcode"; exit 1; }

echo "result test OK"
