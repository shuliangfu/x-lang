#!/usr/bin/env bash
# std.fmt leftover runner: tests/fmt-std/*.x product -o exit 0
# (main / format_multi / print_scalar / print_any / print_u8_slc / print_i32_slc).
#
# Honesty: leftover soft auto-make (`xlang_compiler_make -q || xlang_compiler_make
# xlang-c`) + bootstrap-link wrap (prefer-c) retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / soft auto-make / leftover XLANG
# fallthrough / prefer-c). Check path = obs= (check gate paused 2026-08-05).
# Product `-o` must exit 0; print_i32_slc stdout must contain A@ JSON arrays.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-fmt-std.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_FMT_STD_PREFIX:-xlang: [FMT_STD]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "fmt-std FAIL: $*" >&2
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
  local exe="/tmp/xlang_fmt_std_$$_${tag}"
  local log="/tmp/xlang_fmt_std_${tag}_$$.log"
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

# i32[] must print JSON via schema A@ — exit0 alone hid empty/u8_slc fake-green.
run_print_i32_slc_json() {
  local src="tests/fmt-std/print_i32_slc.x"
  local exe="/tmp/xlang_fmt_std_$$_print_i32_slc"
  local log="/tmp/xlang_fmt_std_print_i32_slc_$$.log"
  local o_ec r_ec out
  [ -f "$src" ] || die "missing $src (print_i32_slc)"
  rm -f "$exe" "$log"
  set +e
  "$XLANG_BIN" -L . "$src" -o "$exe" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    tail -n 12 "$log" 2>/dev/null || true
    rm -f "$exe"
    die "print_i32_slc product -o failed (ec=$o_ec; refuse leftover auto-make)"
  fi
  set +e
  out="$("$exe")"
  r_ec=$?
  set -e
  rm -f "$exe" "$log"
  [ "$r_ec" -eq 0 ] || die "print_i32_slc runnable exit=$r_ec (expected 0)"
  echo "$out" | grep -q '\[10,20,30\]' || die "print_i32_slc missing [10,20,30] JSON (got: $out)"
  echo "$out" | grep -q '\[1,2,3\]' || die "print_i32_slc missing [1,2,3] JSON (got: $out)"
  RUN_OK=$((RUN_OK + 1))
}

echo "=== fmt-std leftover (prefer asm; hard; refuse leftover auto-make) ==="
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

# Observational check on STD-019 live smoke (paused) — never soft SKIP→OK.
set +e
"$XLANG_BIN" check -L . tests/fmt-std/format_multi.x >/tmp/xlang_fmt_std_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "fmt-std OBS check (paused / CHK residual ec=$chk_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

run_product main tests/fmt-std/main.x
run_product format_multi tests/fmt-std/format_multi.x
run_product print_scalar tests/fmt-std/print_scalar.x
run_product print_any tests/fmt-std/print_any.x
run_product print_u8_slc tests/fmt-std/print_u8_slc.x
run_print_i32_slc_json

ok_report
echo "fmt-std test OK (incl. print_any JSON + print_u8_slc + print_i32_slc A@ schema)"
