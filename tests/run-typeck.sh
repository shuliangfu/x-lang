#!/usr/bin/env bash
# Stage-3 typeck smoke: POS emit "typeck OK"; NEG emit typeck error.
#
# Honesty: soft auto-make xlang-c + soft prefer-c NEG host + soft
# xlang-x/seed fallback for diagnostics (false authority) retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make /
# prefer-c). Product build (no -o / -E) is the authority for both POS
# ("info: typeck OK") and NEG ("typeck error…") — tip product emits both.
# Report: run=/obs=/skip=
# Usage: ./tests/run-typeck.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_TYPECK_PREFIX:-xlang: [TYPECK]}"
XLANG_CASE_TIMEOUT="${XLANG_TYPECK_TIMEOUT:-${XLANG_CASE_TIMEOUT:-30}}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "typeck FAIL: $*" >&2
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

# NEG: product build must emit typeck diagnostic (stderr). Exit code is
# not authoritative on tip product (may be 0 with XT001 on stderr).
expect_neg() {
  local tag="$1" src="$2" needle="$3"
  local log="/tmp/xlang_typeck_neg_${tag}_$$.log"
  local o_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build "$src" \
    -o "/tmp/xlang_typeck_neg_${tag}_$$.o" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$tag timeout"
  fi
  grep -q "$needle" "$log" \
    || die "$tag expected '$needle'; $(tail -8 "$log" 2>/dev/null | tr '\n' ' ')"
  rm -f "$log" "/tmp/xlang_typeck_neg_${tag}_$$.o"
  echo "typeck NEG OK: $tag"
  RUN_OK=$((RUN_OK + 1))
}

# POS: product build (no -o) must emit "typeck OK". Prefer no -o over -E
# so asm/C hosts share one path; -E also works on tip but dumps codegen.
expect_pos() {
  local tag="$1" src="$2"
  local log="/tmp/xlang_typeck_pos_${tag}_$$.log"
  local o_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build "$src" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$tag timeout"
  fi
  grep -q "typeck OK" "$log" \
    || die "$tag missing typeck OK; $(tail -8 "$log" 2>/dev/null | tr '\n' ' ')"
  rm -f "$log"
  echo "typeck POS OK: $tag"
  RUN_OK=$((RUN_OK + 1))
}

# Breadcrumb NEG: return mismatch + optional subexpression note.
expect_breadcrumb() {
  local tag="$1" src="$2"
  local log="/tmp/xlang_typeck_bc_${tag}_$$.log"
  local o_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build -L . "$src" \
    -o "/tmp/xlang_typeck_bc_${tag}_$$" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$tag timeout"
  fi
  grep -qE "return expression type mismatch: expected i32, found (result\.)?Result_i32" "$log" \
    || die "$tag missing return mismatch breadcrumb; $(tail -8 "$log" 2>/dev/null | tr '\n' ' ')"
  if grep -q "return subexpression:" "$log"; then
    grep -q "return subexpression: result.ok_i32()" "$log" \
      || die "$tag missing return subexpression breadcrumb; $(tail -8 "$log" 2>/dev/null | tr '\n' ' ')"
  fi
  rm -f "$log" "/tmp/xlang_typeck_bc_${tag}_$$"
  echo "typeck NEG OK: $tag (breadcrumb)"
  RUN_OK=$((RUN_OK + 1))
}

echo "=== typeck gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# Hard NEG arms (product diagnostics).
expect_neg assign_mismatch tests/typeck/type_mismatch_assign.x \
  "assignment type mismatch: expected i32, found bool"
expect_neg if_not_bool tests/typeck/if_condition_not_bool.x "typeck error"
expect_neg undefined_name tests/typeck/undefined_name.x "typeck error"
expect_neg return_implicit tests/typeck/return_implicit.x "typeck error"
expect_neg ternary_cond tests/typeck/ternary_condition_not_bool.x "typeck error"
expect_neg ternary_branches tests/typeck/ternary_branches_mismatch.x "typeck error"
expect_neg struct_repr_fail tests/typeck/struct_repr_compatible_fail.x "typeck error"
expect_neg result_try_bad tests/typeck/result_try_bad.x "typeck error"
expect_neg import_const_bare tests/typeck/import_const_bare_fail.x "typeck error"
expect_neg return_operand tests/typeck/return_operand_type_mismatch.x "typeck error"
expect_breadcrumb return_import_call tests/typeck/return_import_call_type_mismatch.x

# Hard POS arms (product typeck OK).
for f in \
  tests/typeck/contextual_typing_p0.x \
  tests/typeck/contextual_typing_p1.x \
  tests/typeck/postfix_call_index.x \
  tests/typeck/postfix_array_slice_type.x \
  tests/typeck/ptr_arith_i32.x \
  tests/typeck/ternary_u8_context.x \
  tests/typeck/struct_field_shorthand.x \
  tests/typeck/match_guard.x \
  tests/typeck/match_struct_destructure.x \
  tests/typeck/range_for.x \
  tests/typeck/result_try.x \
  tests/typeck/result_try_catch.x \
  tests/typeck/return_struct_field_shorthand.x \
  tests/typeck/struct_repr_compatible.x \
  tests/typeck/type_alias.x \
  tests/typeck/import_const_qualified_ok.x \
  tests/typeck/u64_to_usize_needs_as.x \
  tests/typeck/u64_to_usize_needs_as_lit_lhs.x
do
  expect_pos "$(basename "$f" .x)" "$f"
done

ok_report
echo "typeck test OK"
