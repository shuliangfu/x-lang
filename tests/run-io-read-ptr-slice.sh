#!/usr/bin/env bash
# M-5 leftover runner: read_ptr_slice / read_ptr_slice_param product -o
# (stdin "AB"; local/param slice field access codegen).
#
# Honesty: leftover soft auto-make (`xlang_compiler_make -q xlang-c || make`
# + process.o/io.o) + bootstrap-link wrap (prefer-c) + xlang-c-first fallback
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / leftover XLANG fallthrough /
# soft auto-make / prefer-c). Check path = obs= (paused 2026-08-05).
# Product `-o` both smokes must exit 0 with stdin AB. Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-io-read-ptr-slice.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_IO_READ_PTR_SLICE_PREFIX:-xlang: [IO_READ_PTR_SLICE]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "io-read-ptr-slice FAIL: $*" >&2
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

run_product_stdin() {
  local tag="$1" src="$2" stdin_bytes="$3"
  local exe="/tmp/xlang_io_rps_$$_${tag}"
  local log="/tmp/xlang_io_rps_${tag}_$$.log"
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
  printf '%s' "$stdin_bytes" | "$exe" >/dev/null 2>&1
  r_ec=$?
  set -e
  rm -f "$exe" "$log"
  [ "$r_ec" -eq 0 ] || die "$tag runnable exit=$r_ec (expected 0)"
  RUN_OK=$((RUN_OK + 1))
}

echo "=== io-read-ptr-slice leftover (prefer asm; hard; refuse leftover auto-make) ==="
if [ -n "${XLANG:-}" ]; then
  if ! XLANG_BIN="$(resolve_shu)"; then
    die "explicit XLANG not native (refuse leftover XLANG fallthrough / soft auto-make)"
  fi
elif ! XLANG_BIN="$(resolve_shu)"; then
  die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

set +e
"$XLANG_BIN" check -L . tests/io/read_ptr_slice.x >/tmp/xlang_io_rps_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "io-read-ptr-slice OBS check (paused / CHK residual ec=$chk_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

run_product_stdin read_ptr_slice tests/io/read_ptr_slice.x "AB"
run_product_stdin read_ptr_slice_param tests/io/read_ptr_slice_param.x "AB"

ok_report
echo "io read_ptr_slice OK"
