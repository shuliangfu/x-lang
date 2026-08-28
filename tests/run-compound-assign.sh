#!/usr/bin/env bash
# Compound assign: += -= *= /= %= &= |= ^= <<= >>=
#
# Honesty: soft default `./compiler/xlang` + soft auto-make (false authority)
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
# PLATFORM: SHARED pure-asm product; C/host-cc only with XLANG_ALLOW_HOST_CC /
# XLANG_FORCE_LINK_BACKEND. Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

XLANG="$(resolve_shu)" || { echo "compound-assign FAIL: no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)" >&2; exit 1; }
export XLANG
export XLANG_LINK_XLANG="$XLANG"
# Product pure-asm default (no forced -backend c). Prefer product XLANG over wrap.
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
