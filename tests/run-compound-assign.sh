#!/usr/bin/env bash
# 复合赋值运算符：+= -= *= /= %= &= |= ^= <<= >>=
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
XLANG=${XLANG:-./compiler/xlang}
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
# Product pure-asm default (no forced -backend c). Prefer product XLANG over wrap.
# PLATFORM: SHARED pure-asm product; C/host-cc only with XLANG_ALLOW_HOST_CC /
# XLANG_FORCE_LINK_BACKEND.
LINK_XLANG="${XLANG:-${RUN_XLANG}}"
case "$(basename "${LINK_XLANG:-}")" in
  xlang-backend-wrap.sh|xlang-min-link.sh)
    LINK_XLANG="${XLANG_BACKEND_WRAP_REAL:-${XLANG_MIN_LINK_REAL:-${XLANG:-./compiler/xlang}}}"
    ;;
esac
LINK_BACKEND_ARGS=""
if [ -n "${XLANG_FORCE_LINK_BACKEND:-}" ]; then
  LINK_BACKEND_ARGS="-backend ${XLANG_FORCE_LINK_BACKEND}"
fi

set +e
# shellcheck disable=SC2086
$LINK_XLANG build $LINK_BACKEND_ARGS tests/compound-assign/main.x -o /tmp/xlang_compound_assign 2>&1
_compile_ec=$?
set -e
set +e
# Optional host-cc / seed-c fallback only when explicitly allowed.
if [ "$_compile_ec" -ne 0 ] && [ -n "${XLANG_ALLOW_HOST_CC:-}" ]; then
  ./compiler/xlang build -backend c tests/compound-assign/main.x -o /tmp/xlang_compound_assign 2>&1
  _compile_ec=$?
fi
if [ "$_compile_ec" -ne 0 ] && [ -n "${XLANG_ALLOW_HOST_CC:-}" ] && [ -x ./compiler/xlang-c ]; then
  ./compiler/xlang-c -E tests/compound-assign/main.x > /tmp/xlang_ca_fallback.c 2>&1
  ${CC:-cc} -O2 -o /tmp/xlang_compound_assign /tmp/xlang_ca_fallback.c 2>&1
  _compile_ec=$?
fi
set -e
if [ "$_compile_ec" -ne 0 ]; then
  echo "compound-assign: product pure-asm -o failed (exit $_compile_ec)" >&2
  exit "$_compile_ec"
fi

exitcode=0
/tmp/xlang_compound_assign >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 0 ]; then
  echo "compound-assign: expected exit 0, got $exitcode"
  exit 1
fi
echo "compound-assign test OK"
