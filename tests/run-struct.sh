#!/usr/bin/env bash
# struct smoke: lit/field/padding/packed/arena + boundary inline + while_if
#
# Honesty: soft auto-make + soft bootstrap-link + soft host-cc/-E+cc fallback +
# soft SKIP while_if_nested_let (false authority) retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard
# die (refuse soft SKIP→OK / soft auto-make / prefer-c / soft bootstrap-link).
# Former `xlang check` padding arm → product -o NEG (hard). Report:
# run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_STRUCT_PREFIX:-xlang: [STRUCT]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "struct FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

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
  if [ -n "${XLANG_BSTRICT_USE_ASM2:-}" ] && dod_native_exe ./compiler/xlang_asm2; then
    echo "$(pwd)/compiler/xlang_asm2"
    return 0
  fi
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

run_exit() {
  local tag="$1" src="$2" want="$3"
  local exe="/tmp/xlang_struct_${tag}_$$"
  local log="/tmp/xlang_struct_${tag}_$$.log"
  local o_ec r_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$exe" "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build -L . "$src" -o "$exe" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$tag product -o timeout"
  elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    die "$tag product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
  fi
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe" >/dev/null 2>&1
  r_ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$r_ec" -eq 124 ]; then
    die "$tag run timeout"
  elif [ "$r_ec" -ne "$want" ]; then
    die "$tag expected exit $want, got $r_ec"
  fi
  RUN_OK=$((RUN_OK + 1))
}

run_neg() {
  local tag="$1" src="$2" needle="$3"
  local exe="/tmp/xlang_struct_${tag}_$$"
  local log="/tmp/xlang_struct_${tag}_$$.log"
  local o_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$exe" "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build -L . "$src" -o "$exe" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$tag timeout"
  elif [ "$o_ec" -eq 0 ]; then
    die "$tag expected compile fail, got success"
  fi
  grep -q "$needle" "$log" \
    || die "$tag expected '$needle'; $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
  rm -f "$exe" "$log"
  RUN_OK=$((RUN_OK + 1))
}

echo "=== struct gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

run_exit simple tests/struct/simple.x 1
run_exit padding_allow tests/struct/padding_allow.x 2
run_neg padding_no_allow tests/struct/padding_no_allow.x "implicit padding"
run_exit packed_struct tests/memory-contract/packed_struct.x 0
run_exit arena_align tests/memory-contract/arena_align.x 0
run_exit struct_add_pair_inline tests/boundary/struct_add_pair_inline.x 12
run_exit struct_get_field_inline tests/boundary/struct_get_field_inline.x 10
run_exit struct_mk_field_inline tests/boundary/struct_mk_field_inline.x 10
run_exit struct_mk_pair_sum_inline tests/boundary/struct_mk_pair_sum_inline.x 20
run_exit struct_mk_let_inline tests/boundary/struct_mk_let_inline.x 10
run_exit struct_mk_while_let_inline tests/boundary/struct_mk_while_let_inline.x 9
# Former soft-skip (parse hole) — product path now hard-green exit 10.
run_exit while_if_nested_let tests/boundary/while_if_nested_let.x 10

ok_report
echo "struct test OK"
