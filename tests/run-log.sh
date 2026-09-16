#!/usr/bin/env bash
# log leftover runner (bstrict catalog: run-log.sh): tests/log/main.x
# product -o exit 0.
#
# Honesty: leftover soft `ensure_std_c_o log.o` + `ensure_runtime_log_os_o` +
# unused compiler-make.sh retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die (refuse
# leftover SKIP→OK / leftover XLANG fallthrough / leftover auto-make /
# leftover ensure). Check path = obs= (check gate paused 2026-08-05).
# Product `-o` tests/log/main.x must exit 0. Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-log.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_LOG_PREFIX:-xlang: [XLANG_LOG]}"
SMOKE="tests/log/main.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "log test FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

# G.7: complete the existing per-script resolve_shu family (dod_native_exe);
# do not fork a third resolver. Explicit XLANG that is missing/non-native
# returns 1 (caller hard-dies; refuse leftover XLANG fallthrough).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

[ -f "$SMOKE" ] || die "missing $SMOKE"

echo "=== log leftover (prefer asm; hard; refuse leftover ensure) ==="
if [ -n "${XLANG:-}" ]; then
  if ! XLANG_BIN="$(resolve_shu)"; then
    die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ensure)"
  fi
elif ! XLANG_BIN="$(resolve_shu)"; then
  die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / leftover ensure)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_log_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "log test OBS check (paused / CHK residual ec=$chk_ec; refuse leftover ensure)" >&2
  OBS=$((OBS + 1))
fi

exe="/tmp/xlang_log_$$"
rm -f "$exe" 2>/dev/null || true
set +e
"$XLANG_BIN" -L . "$SMOKE" -o "$exe" >/tmp/xlang_log_compile.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_log_compile.log 2>/dev/null || true
  rm -f "$exe"
  die "product -o compile failed (ec=$o_ec; refuse leftover ensure / leftover auto-make)"
fi
set +e
"$exe" >/dev/null 2>&1
exitcode=$?
set -e
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then
  die "expected exit 0, got $exitcode"
fi
RUN_OK=1
echo "log test OK"
ok_report
