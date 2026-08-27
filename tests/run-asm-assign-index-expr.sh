#!/usr/bin/env bash
# asm 7.3: INDEX expr assign/read (var±lit/var, mul, nested) + add-chain; no mov x2.
#
# Honesty: soft default `./compiler/xlang` + soft auto-make (false authority)
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - hard: product -o + expected exits for all expr fixtures
#   - hard (Darwin+otool): main has no `mov x2` when forbid_x2=1
#   - skip: non-Darwin / no otool disasm N/A
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required; Darwin arm64 disasm.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_ASM_ASSIGN_INDEX_EXPR_PREFIX:-xlang: [XLANG_ASM_ASSIGN_INDEX_EXPR]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "asm-assign-index-expr FAIL: $*" >&2
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

run_case() {
  local tag="$1" src="$2" want="$3" forbid_x2="$4"
  local exe="/tmp/xlang_asm_assign_index_expr_${tag}_$$"
  local log="/tmp/xlang_asm_assign_index_expr_${tag}_$$.log"
  local o_ec r_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$exe" "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$exe" >"$log" 2>&1
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
  if [ "$r_ec" -eq 124 ]; then
    rm -f "$exe"
    die "$tag run timeout"
  elif [ "$r_ec" -ne "$want" ]; then
    rm -f "$exe"
    die "$tag expected exit $want, got $r_ec"
  fi
  RUN_OK=$((RUN_OK + 1))
  if [ "$forbid_x2" = "1" ]; then
    # PLATFORM: DARWIN — otool arm64 main disasm. Non-Darwin = skip= honesty.
    if [ "$(uname -s)" = Darwin ] && command -v otool >/dev/null 2>&1; then
      if otool -tv "$exe" 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
        rm -f "$exe"
        die "$tag main still uses mov x2"
      fi
      RUN_OK=$((RUN_OK + 1))
    else
      SKIP=$((SKIP + 1))
    fi
  fi
  rm -f "$exe"
}

echo "=== asm-assign-index-expr gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

run_case assign_index_var_plus_lit tests/asm/assign_index_var_plus_lit.x 99 1
run_case binop_index_add_chain tests/asm/binop_index_add_chain.x 30 0
run_case assign_index_var_plus_var tests/asm/assign_index_var_plus_var.x 99 1
run_case assign_index_var_plus_var_copy tests/asm/assign_index_var_plus_var_copy.x 15 1
run_case assign_index_var_minus_lit tests/asm/assign_index_var_minus_lit.x 99 1
run_case assign_index_var_minus_var tests/asm/assign_index_var_minus_var.x 99 1
run_case assign_index_var_mul_lit tests/asm/assign_index_var_mul_lit.x 99 1
run_case assign_index_lit_mul_var tests/asm/assign_index_lit_mul_var.x 88 1
run_case index_read_var_mul_lit tests/asm/index_read_var_mul_lit.x 30 1
run_case index_read_var_plus_lit tests/asm/index_read_var_plus_lit.x 10 1
run_case index_read_var_minus_lit tests/asm/index_read_var_minus_lit.x 10 1
run_case index_read_var_plus_var tests/asm/index_read_var_plus_var.x 15 1
run_case index_read_var_mul_var tests/asm/index_read_var_mul_var.x 30 1
run_case index_read_var_plus_var_plus_var tests/asm/index_read_var_plus_var_plus_var.x 40 1
run_case index_read_var_plus_var_mul_lit tests/asm/index_read_var_plus_var_mul_lit.x 30 1
run_case index_read_var_plus_paren_var_plus_var tests/asm/index_read_var_plus_paren_var_plus_var.x 40 1
run_case index_read_var_add3_mul_lit tests/asm/index_read_var_add3_mul_lit.x 30 1
run_case index_read_var_minus_var_plus_var tests/asm/index_read_var_minus_var_plus_var.x 30 1
run_case assign_index_var_minus_var_plus_var tests/asm/assign_index_var_minus_var_plus_var.x 99 1
run_case assign_read_index_var_minus_var_plus_var tests/asm/assign_read_index_var_minus_var_plus_var.x 99 1
run_case index_read_var_minus_var_minus_var tests/asm/index_read_var_minus_var_minus_var.x 30 1
run_case index_read_var_minus_add3 tests/asm/index_read_var_minus_add3.x 20 1
run_case index_read_var_minus_var_mul_lit tests/asm/index_read_var_minus_var_mul_lit.x 30 1
run_case assign_index_var_minus_var_minus_var tests/asm/assign_index_var_minus_var_minus_var.x 99 1
run_case assign_index_var_minus_add3 tests/asm/assign_index_var_minus_add3.x 99 1
run_case assign_index_var_minus_var_mul_lit tests/asm/assign_index_var_minus_var_mul_lit.x 99 1
run_case assign_read_index_var_minus_add3 tests/asm/assign_read_index_var_minus_add3.x 99 1
run_case assign_index_var_plus_paren_var_plus_var tests/asm/assign_index_var_plus_paren_var_plus_var.x 99 1
run_case assign_index_var_add3_mul_lit tests/asm/assign_index_var_add3_mul_lit.x 99 1
run_case assign_index_var_plus_var_plus_var tests/asm/assign_index_var_plus_var_plus_var.x 99 1
run_case assign_index_var_plus_var_mul_lit tests/asm/assign_index_var_plus_var_mul_lit.x 99 1
run_case assign_index_var_mul_var tests/asm/assign_index_var_mul_var.x 99 1
run_case assign_read_index_var_mul_lit tests/asm/assign_read_index_var_mul_lit.x 99 1
run_case assign_read_index_var_mul_var tests/asm/assign_read_index_var_mul_var.x 99 1
run_case assign_read_index_var_plus_var_mul_lit tests/asm/assign_read_index_var_plus_var_mul_lit.x 99 1
run_case assign_read_index_var_add3_mul_lit tests/asm/assign_read_index_var_add3_mul_lit.x 99 1
run_case index_read_var_subadd3_mul_lit tests/asm/index_read_var_subadd3_mul_lit.x 30 1
run_case assign_index_var_subadd3_mul_lit tests/asm/assign_index_var_subadd3_mul_lit.x 99 1
run_case assign_read_index_var_subadd3_mul_lit tests/asm/assign_read_index_var_subadd3_mul_lit.x 99 1
run_case index_read_var_subsub3_mul_lit tests/asm/index_read_var_subsub3_mul_lit.x 30 1
run_case assign_index_var_subsub3_mul_lit tests/asm/assign_index_var_subsub3_mul_lit.x 99 1
run_case assign_read_index_var_subsub3_mul_lit tests/asm/assign_read_index_var_subsub3_mul_lit.x 99 1
run_case index_read_var_minus_add3_mul_lit tests/asm/index_read_var_minus_add3_mul_lit.x 30 1
run_case assign_index_var_minus_add3_mul_lit tests/asm/assign_index_var_minus_add3_mul_lit.x 99 1
run_case assign_read_index_var_minus_add3_mul_lit tests/asm/assign_read_index_var_minus_add3_mul_lit.x 99 1

ok_report
echo "asm assign index expr OK"

