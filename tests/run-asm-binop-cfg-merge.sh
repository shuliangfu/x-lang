#!/usr/bin/env bash
# asm 7.3: if/while/for CFG merge live ∪; nested/mix/break/continue; ldur b gate.
#
# Honesty: soft default `./compiler/xlang` + soft auto-make + soft seed fallback
# (xlang-x / xlang_asm73_seed / ASM73_FALLBACK_SHU) retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die
# (refuse soft SKIP→OK / soft auto-make / prefer-c / soft seed green).
#   - hard: product -o + expected exits for all cfg-merge fixtures
#   - hard (Linux aarch64 via wpo_asm_disasm_gate_host): optional max ldur x1 [b];
#     fourteen-var cfg return must show #0x10 stack spill push
#   - skip: Darwin / non-aarch64 disasm N/A (report skip=, not soft silent OK)
#   - one product retry on SIGSEGV (139) only; never fall back to seed compilers
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required for product exits.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh
# shellcheck source=tests/lib/wpo-main-disasm.sh
. tests/lib/wpo-main-disasm.sh

PREFIX="${XLANG_ASM_BINOP_CFG_MERGE_PREFIX:-xlang: [XLANG_ASM_BINOP_CFG_MERGE]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-180}"
XLANG_RUN_TIMEOUT="${CFG_MERGE_RUN_TIMEOUT:-30}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "asm-binop-cfg-merge FAIL: $*" >&2
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

# Product -o only (no seed fallback). One SIGSEGV retry on the same product binary.
product_compile_o() {
  local src="$1" exe="$2" tag="$3" log="$4"
  local o_ec attempt=1
  while [ "$attempt" -le 2 ]; do
    rm -f "$exe" "$log"
    set +e
    gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$exe" >"$log" 2>&1
    o_ec=$?
    set -e
    if [ "$o_ec" -eq 0 ] && [ -x "$exe" ]; then
      return 0
    fi
    if [ "$o_ec" -eq 124 ]; then
      die "$tag product -o timeout"
    fi
    # 139 = SIGSEGV; one product retry only (refuse soft seed fallback).
    if [ "$o_ec" -eq 139 ] && [ "$attempt" -eq 1 ]; then
      echo "asm-binop-cfg-merge: warn: product SIGSEGV ($tag), retry once (no seed fallback)" >&2
      attempt=2
      continue
    fi
    die "$tag product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
  done
  die "$tag product -o failed after SIGSEGV retry"
}

# max_b_ldur empty = no ldur bound; require_spill=1 → must have #0x10 push (Linux aarch64)
run_case() {
  local tag="$1" src="$2" want="$3" max_b_ldur="${4:-}" require_spill="${5:-0}"
  local exe="/tmp/xlang_asm_binop_cfg_merge_${tag}_$$"
  local log="/tmp/xlang_asm_binop_cfg_merge_${tag}_$$.log"
  local r_ec main_asm b_ldur
  [ -f "$src" ] || die "missing $src ($tag)"
  product_compile_o "$src" "$exe" "$tag" "$log"
  set +e
  gate_run_timeout "$XLANG_RUN_TIMEOUT" "$exe" >/dev/null 2>&1
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

  # PLATFORM: SHARED — ldur/spill shape only on Linux aarch64.
  if ! wpo_asm_disasm_gate_host; then
    if [ -n "$max_b_ldur" ] || [ "$require_spill" = "1" ]; then
      SKIP=$((SKIP + 1))
    fi
    rm -f "$exe"
    return 0
  fi

  if [ -n "$max_b_ldur" ] || [ "$require_spill" = "1" ]; then
    main_asm=$(wpo_main_asm "$exe" 2>/dev/null || true)
    if [ -n "$max_b_ldur" ]; then
      b_ldur=$(echo "$main_asm" | grep -cE 'ldur[[:space:]]+x1,.*#-0x18' || true)
      if [ "$b_ldur" -gt "$max_b_ldur" ]; then
        rm -f "$exe"
        die "$tag ldur x1 [b] count $b_ldur > $max_b_ldur (selective merge?)"
      fi
      RUN_OK=$((RUN_OK + 1))
    fi
    if [ "$require_spill" = "1" ]; then
      if ! echo "$main_asm" | grep -q 'sub.*sp, sp, #0x10'; then
        rm -f "$exe"
        die "$tag missing cfg stack spill push"
      fi
      RUN_OK=$((RUN_OK + 1))
    fi
  fi
  rm -f "$exe"
}

ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || true

echo "=== asm-binop-cfg-merge gate (prefer asm; hard; no seed fallback) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make / soft seed)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# tag src want [max_b_ldur] [require_spill]
run_case if_merge tests/asm/binop_if_plus_eq_merge.x 13
run_case if_both_a tests/asm/binop_if_both_assign_a.x 13
run_case if_both_b tests/asm/binop_if_both_assign_keep_b.x 13 2
run_case if_keep_b tests/asm/binop_if_merge_keep_b.x 13 2
run_case if_after_b tests/asm/binop_if_after_use_b.x 13 2
run_case if_nested tests/asm/binop_if_nested_after_b.x 8
run_case if_nested_ldur tests/asm/binop_if_nested_after_b.x 8 2
run_case while_merge tests/asm/binop_while_plus_eq_merge.x 3
run_case while_merge_b tests/asm/binop_while_plus_eq_merge.x 3 2
run_case while_twice tests/asm/binop_while_twice_merge.x 4
run_case while_if tests/asm/binop_while_if_in_body.x 3
run_case while_if2b tests/asm/binop_while_if_twice_keep_b.x 4 2
run_case while_break tests/asm/binop_while_break_merge.x 3
run_case while_break_b tests/asm/binop_while_break_keep_b.x 3 2
run_case while_cont_br tests/asm/binop_while_continue_break.x 6
run_case while_nest_cb tests/asm/binop_while_nested_cont_br.x 5 2
run_case while_cont_b tests/asm/binop_while_continue_keep_b.x 6 2
run_case while_let tests/asm/binop_while_let_in_body.x 3
run_case if_while tests/asm/binop_if_while_in_then.x 3 2
run_case while_nested_b tests/asm/binop_while_nested_after_b.x 3 2
run_case while_nest_br tests/asm/binop_while_nested_inner_break.x 4
run_case while_nest_br_b tests/asm/binop_while_nested_inner_break.x 4 2
run_case while_after_b tests/asm/binop_while_after_use_b.x 3
run_case while_keep_b tests/asm/binop_while_keep_b.x 3 3
run_case for_merge tests/asm/binop_for_plus_eq_merge.x 3
run_case for_twice tests/asm/binop_for_twice_merge.x 4
run_case for_if tests/asm/binop_for_if_in_body.x 3
run_case if_for tests/asm/binop_if_for_in_then.x 3 2
run_case for_step tests/asm/binop_for_step_header.x 3
run_case for_keep_b tests/asm/binop_for_keep_b.x 3 3
run_case for_cont_br tests/asm/binop_for_continue_break.x 6
run_case for_carried_b tests/asm/binop_for_carried_keep_b.x 3 2
run_case if_ret_eight tests/asm/binop_if_return_eight_add.x 36
run_case if_ret_twelve tests/asm/binop_if_return_twelve_add.x 78
run_case if_ret_thirteen tests/asm/binop_if_return_thirteen_add.x 91
run_case if_ret_fourteen tests/asm/binop_if_return_fourteen_add.x 105 "" 1
run_case while_ret_fourteen tests/asm/binop_while_return_fourteen_add.x 105 "" 1
run_case for_ret_fourteen tests/asm/binop_for_return_fourteen_add.x 105 "" 1
run_case if_while_ret_fourteen tests/asm/binop_if_while_return_fourteen_add.x 105 "" 1
run_case if_phi_ret_fourteen tests/asm/binop_if_phi_return_fourteen_add.x 105
run_case while_phi_ret_fourteen tests/asm/binop_while_phi_return_fourteen_add.x 105

ok_report
echo "asm binop cfg merge OK"
