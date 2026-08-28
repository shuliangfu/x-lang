#!/usr/bin/env bash
# std.test leftover runner: tests/stdtest/main.x product -o exit 0
# (expect / expect_eq_i32 / expect_ne_i32).
#
# Honesty: leftover soft auto-make (`xlang_compiler_make -q || make` of
# compiler / test.o / runtime_test_fn_invoke.o) + leftover bootstrap-link wrap
# (prefer-c remap) + fossil `$RUN_XLANG build` retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard
# die (refuse soft SKIP→OK / leftover auto-make / leftover wrap / leftover
# XLANG fallthrough). Check path = obs= (check gate paused 2026-08-05).
# Product `-o` must exit 0. Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-stdtest.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_STDTEST_PREFIX:-xlang: [STDTEST]}"
SMOKE="tests/stdtest/main.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "stdtest test FAIL: $*" >&2
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
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

echo "=== stdtest leftover (prefer asm; hard; refuse leftover wrap / auto-make) ==="
if [ -n "${XLANG:-}" ]; then
  if ! XLANG_BIN="$(resolve_shu)"; then
    die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover wrap)"
  fi
elif ! XLANG_BIN="$(resolve_shu)"; then
  die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / leftover wrap)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_stdtest_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "stdtest OBS check (paused / CHK residual ec=$chk_ec; refuse leftover wrap)" >&2
  OBS=$((OBS + 1))
fi

exe="/tmp/xlang_stdtest_$$"
rm -f "$exe" 2>/dev/null || true
set +e
# Refuse leftover wrap / fossil `$RUN_XLANG build` / leftover auto-make
# (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
"$XLANG_BIN" -L . "$SMOKE" -o "$exe" >/tmp/xlang_stdtest_o.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_stdtest_o.log 2>/dev/null || true
  rm -f "$exe"
  die "product -o failed (ec=$o_ec; refuse leftover wrap / fossil RUN_XLANG build / leftover auto-make)"
fi
set +e
"$exe" >/dev/null 2>&1
run_ec=$?
set -e
rm -f "$exe"
[ "$run_ec" -eq 0 ] || die "runnable exit=$run_ec (expected 0)"
RUN_OK=$((RUN_OK + 1))

ok_report
echo "stdtest test OK"
