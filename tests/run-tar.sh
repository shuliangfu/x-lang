#!/usr/bin/env bash
# std.tar leftover runner: tests/tar/main.x product -o exit 0 (UStar header
# read/write smoke). STD-038 gate already honesty-closed; this is the leftover
# observational hook (TSV hook_tar).
#
# Honesty: leftover soft auto-make (`xlang_compiler_make -q || xlang_compiler_make`
# + leftover `ensure_std_c_o ../std/tar/tar.o`) + default ./compiler/xlang +
# fossil `$XLANG build` retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# leftover XLANG fallthrough / leftover auto-make / leftover ensure).
# Check path = obs= (check gate paused 2026-08-05). Product `-o` tests/tar/main.x
# must exit 0. Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-tar.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_TAR_PREFIX:-xlang: [TAR]}"
SMOKE="tests/tar/main.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "tar test FAIL: $*" >&2
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

echo "=== tar leftover (prefer asm; hard; refuse leftover auto-make / ensure) ==="
if [ -n "${XLANG:-}" ]; then
  if ! XLANG_BIN="$(resolve_shu)"; then
    die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover auto-make / leftover ensure)"
  fi
elif ! XLANG_BIN="$(resolve_shu)"; then
  die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / leftover auto-make / leftover ensure)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_tar_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "tar test OBS check (paused / CHK residual ec=$chk_ec; refuse leftover auto-make / leftover ensure)" >&2
  OBS=$((OBS + 1))
fi

exe="/tmp/xlang_tar_$$"
rm -f "$exe" 2>/dev/null || true
set +e
# Refuse leftover wrap / leftover auto-make / leftover ensure /
# fossil `$XLANG build` (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
"$XLANG_BIN" -L . "$SMOKE" -o "$exe" >/tmp/xlang_tar_o.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_tar_o.log 2>/dev/null || true
  rm -f "$exe"
  die "product -o failed (ec=$o_ec; refuse leftover auto-make / leftover ensure / fossil XLANG build)"
fi
set +e
"$exe" >/dev/null 2>&1
run_ec=$?
set -e
rm -f "$exe"
[ "$run_ec" -eq 0 ] || die "runnable exit=$run_ec (expected 0)"
RUN_OK=$((RUN_OK + 1))

ok_report
echo "tar test OK"
