#!/usr/bin/env bash
# P3 asm leftover runner: struct CALL inline (try_inline_*); product -o +
# exit codes hard; Darwin otool requires _main has no user `bl` (vec div
# may `bl _xlang_panic_`). Nested under run-asm-73-gate.sh (leave that host).
#
# Honesty: leftover `ensure-compiler-seed.sh` auto-make (`bootstrap-driver-seed`
# if compiler/xlang missing) + fossil `$XLANG build` retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard
# die (refuse soft SKIP→OK / leftover XLANG fallthrough / leftover auto-make).
# Check path = obs= (check gate paused 2026-08-05; first smoke only).
# Product `-o` of 11 cases must match expected exit. Darwin otool _main
# no-user-bl is hard on Darwin; Linux/Ubuntu skips otool (N/A, not skip=).
# Report: run=/obs=/skip=
# PLATFORM: SHARED product -o / DARWIN otool CALL-inline proof.
# Usage: ./tests/run-asm-call-inline.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_ASM_CALL_INLINE_PREFIX:-xlang: [ASM_CALL_INLINE]}"
RUN_OK=0
OBS=0
SKIP=0
CHECKED=0

die() {
  echo "run-asm-call-inline FAIL: $*" >&2
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

# _main disassembly must not `bl` user functions (CALL inline).
# Allow `bl _xlang_panic_` (vec div per-lane zero check).
# PLATFORM: DARWIN — otool -tv is the CALL-inline proof; missing otool /
# missing _main is a hard fail (refuse leftover vacuous pass).
# PLATFORM: LINUX|UBUNTU — otool N/A; product -o + exit codes remain hard.
check_no_bl_in_main() {
  local out="$1"
  local tag="$2"
  local main_asm bad_bl
  if [ "$(uname -s)" != Darwin ]; then
    return 0
  fi
  if ! command -v otool >/dev/null 2>&1; then
    die "$tag Darwin otool missing (refuse leftover vacuous inline pass)"
  fi
  main_asm=$(otool -tv "$out" 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p')
  if [ -z "$main_asm" ]; then
    die "$tag Darwin otool produced no _main (refuse leftover vacuous inline pass)"
  fi
  bad_bl=$(echo "$main_asm" | grep -E '[[:space:]]bl[[:space:]]' | grep -v '_xlang_panic_' || true)
  if [ -n "$bad_bl" ]; then
    echo "$bad_bl" >&2
    die "$tag _main still has bl (expected full inline)"
  fi
}

# Refuse leftover fossil `$XLANG build` / leftover ensure-compiler-seed
# auto-make (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
run_one() {
  local src="$1"
  local out="$2"
  local want="$3"
  local tag="$4"
  local o_ec exitcode chk_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  if [ "$CHECKED" -eq 0 ]; then
    set +e
    "$XLANG_BIN" check "$src" >/tmp/xlang_asm_call_inline_check.log 2>&1
    chk_ec=$?
    set -e
    CHECKED=1
    if [ "$chk_ec" -ne 0 ]; then
      echo "asm-call-inline OBS check (paused / CHK residual ec=$chk_ec; refuse leftover auto-make)" >&2
      OBS=$((OBS + 1))
    fi
  fi
  rm -f "$out" 2>/dev/null || true
  set +e
  "$XLANG_BIN" "$src" -o "$out" >/tmp/xlang_asm_call_inline_o.log 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    tail -n 12 /tmp/xlang_asm_call_inline_o.log 2>/dev/null || true
    rm -f "$out"
    die "product -o failed for $tag (ec=$o_ec; refuse leftover auto-make / fossil XLANG build)"
  fi
  set +e
  "$out" >/dev/null 2>&1
  exitcode=$?
  set -e
  if [ "$exitcode" -ne "$want" ]; then
    rm -f "$out"
    die "$tag expected exit $want, got $exitcode"
  fi
  check_no_bl_in_main "$out" "$tag"
  rm -f "$out"
  RUN_OK=$((RUN_OK + 1))
}

echo "=== asm-call-inline leftover (prefer asm; hard; refuse leftover auto-make) ==="
if [ -n "${XLANG:-}" ]; then
  if ! XLANG_BIN="$(resolve_shu)"; then
    die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover auto-make)"
  fi
elif ! XLANG_BIN="$(resolve_shu)"; then
  die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

run_one tests/boundary/struct_add_pair_inline.x /tmp/xlang_asm_struct_add_pair 12 "add_pair loop"
run_one tests/boundary/struct_get_field_inline.x /tmp/xlang_asm_struct_get_field 10 "get_a loop"
run_one tests/boundary/struct_mk_field_inline.x /tmp/xlang_asm_struct_mk_field 10 "mk+get_a nested"
run_one tests/boundary/struct_mk_pair_sum_inline.x /tmp/xlang_asm_struct_mk_pair_sum 20 "mk+add_pair nested"
run_one tests/boundary/struct_mk_let_inline.x /tmp/xlang_asm_struct_mk_let 10 "mk let slot"
run_one tests/boundary/struct_mk_while_let_inline.x /tmp/xlang_asm_struct_mk_while_let 9 "mk while let"
run_one tests/boundary/inc_while_inline.x /tmp/xlang_asm_inc_while 15 "inc while outer i"
run_one tests/boundary/vec_add4_call_inline.x /tmp/xlang_asm_vec_add4 0 "vec_add4 call inline"
run_one tests/boundary/vec_sub4_call_inline.x /tmp/xlang_asm_vec_sub4 0 "vec_sub4 call inline"
run_one tests/boundary/vec_mul4_call_inline.x /tmp/xlang_asm_vec_mul4 0 "vec_mul4 call inline"
run_one tests/boundary/vec_div4_call_inline.x /tmp/xlang_asm_vec_div4 0 "vec_div4 call inline"

ok_report
echo "asm call inline OK (11 cases: 6 struct + inc while + vec add/sub/mul/div)"
