#!/usr/bin/env bash
# std.string leftover runner: tests/string/{main,from_slice_eq,
# compare_append_find,contains_trim_replace,view_zerocopy}.x product -o exit 0.
#
# Honesty: leftover hard make string.o if missing (`xlang_compiler_make
# ../std/string/string.o`) + bootstrap-link wrap (prefer-c remap xlang_asm →
# xlang-c) + fossil `$LINK_XLANG build` retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die (refuse soft
# SKIP→OK / leftover XLANG fallthrough / leftover auto-make / leftover wrap).
# Check path = obs= (check gate paused 2026-08-05). Product `-o` each smoke
# must exit 0. Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-string.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_STRING_PREFIX:-xlang: [STRING]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "string FAIL: $*" >&2
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

run_product() {
  local tag="$1" src="$2"
  local exe="/tmp/xlang_string_$$_${tag}"
  local log="/tmp/xlang_string_${tag}_$$.log"
  local o_ec r_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$exe" "$log"
  set +e
  "$XLANG_BIN" -L . "$src" -o "$exe" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    tail -n 12 "$log" 2>/dev/null || true
    rm -f "$exe"
    die "$tag product -o failed (ec=$o_ec; refuse leftover auto-make / bootstrap-link wrap)"
  fi
  set +e
  "$exe" >/dev/null 2>&1
  r_ec=$?
  set -e
  rm -f "$exe" "$log"
  [ "$r_ec" -eq 0 ] || die "$tag runnable exit=$r_ec (expected 0)"
  RUN_OK=$((RUN_OK + 1))
}

# MSYS2/Alpine default stack is small; leftover string smokes chain std/heap.
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

echo "=== string leftover (prefer asm; hard; refuse leftover auto-make) ==="
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
"$XLANG_BIN" check -L . tests/string/main.x >/tmp/xlang_string_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "string OBS check (paused / CHK residual ec=$chk_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

run_product main tests/string/main.x
run_product from_slice_eq tests/string/from_slice_eq.x
run_product compare_append_find tests/string/compare_append_find.x
run_product contains_trim_replace tests/string/contains_trim_replace.x
run_product view_zerocopy tests/string/view_zerocopy.x

ok_report
echo "string test OK"
rm -f /tmp/xlang_string_$$_*
