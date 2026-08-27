#!/usr/bin/env bash
# asm 7.3: block consecutive VAR binop reuse + return 4..14-var spill (x10–x15).
#
# Honesty: soft default `./compiler/xlang` + soft auto-make (false authority)
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - hard: product -o + expected exits for all block-var fixtures
#   - hard (Linux aarch64 via wpo_asm_disasm_gate_host): no #0x10 binop push;
#     ldur x1/x0 bounds; optional x10–x15 spill + no spill round-trip mov
#   - skip: Darwin / non-aarch64 (arm64 spill shape N/A on Ubuntu x86_64 gold;
#     Darwin xlang_asm frame layout does not emit x10–x15 spill patterns today)
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

PREFIX="${XLANG_ASM_BINOP_BLOCK_VAR_PREFIX:-xlang: [XLANG_ASM_BINOP_BLOCK_VAR]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "asm-binop-block-var FAIL: $*" >&2
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

# spill_kind: "" | x10 | x10or11 | x11 | x12 | x13 | x14 | x15
# noround: 0|1 — also forbid spill↔x0/x1 consecutive round-trip mov
run_case() {
  local tag="$1" src="$2" want="$3" max_b_ldur="$4" max_a_ldur="${5:-99}"
  local spill_kind="${6:-}" noround="${7:-0}"
  local exe="/tmp/xlang_asm_binop_block_var_${tag}_$$"
  local log="/tmp/xlang_asm_binop_block_var_${tag}_$$.log"
  local o_ec r_ec main_asm b_ldur a_ldur
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

  # PLATFORM: SHARED — arm64 spill/ldur shape only on Linux aarch64 hosts.
  # Darwin / Ubuntu x86_64 = skip= honesty (not soft silent OK).
  if ! wpo_asm_disasm_gate_host; then
    SKIP=$((SKIP + 1))
    rm -f "$exe"
    return 0
  fi

  main_asm=$(wpo_main_asm "$exe" 2>/dev/null || true)
  if echo "$main_asm" | grep -q 'sub.*sp, sp, #0x10'; then
    rm -f "$exe"
    die "$tag still uses stack push for binop"
  fi
  RUN_OK=$((RUN_OK + 1))

  b_ldur=$(echo "$main_asm" | grep -cE 'ldur[[:space:]]+x1,.*#-0x18' || true)
  a_ldur=$(echo "$main_asm" | grep -cE 'ldur[[:space:]]+x0,.*#-0x10' || true)
  if [ "$b_ldur" -gt "$max_b_ldur" ]; then
    rm -f "$exe"
    die "$tag ldur x1 [b] count $b_ldur > $max_b_ldur"
  fi
  if [ "$a_ldur" -gt "$max_a_ldur" ]; then
    rm -f "$exe"
    die "$tag ldur x0 [a] count $a_ldur > $max_a_ldur"
  fi
  RUN_OK=$((RUN_OK + 1))

  case "$spill_kind" in
    x10)
      if ! echo "$main_asm" | grep -qE 'mov[[:space:]]+x10, x|mov[[:space:]]+x0, x10|mov[[:space:]]+x1, x10'; then
        rm -f "$exe"
        die "$tag missing x10 spill/reload in _main"
      fi
      RUN_OK=$((RUN_OK + 1))
      ;;
    x10or11)
      if ! echo "$main_asm" | grep -qE 'mov[[:space:]]+x1[01], x|mov[[:space:]]+x0, x1[01]|mov[[:space:]]+x1, x1[01]'; then
        rm -f "$exe"
        die "$tag missing x10/x11 spill/reload in _main"
      fi
      RUN_OK=$((RUN_OK + 1))
      ;;
    x11)
      if ! echo "$main_asm" | grep -qE 'mov[[:space:]]+x11, x|mov[[:space:]]+x0, x11|mov[[:space:]]+x1, x11'; then
        rm -f "$exe"
        die "$tag missing x11 spill/reload in _main"
      fi
      RUN_OK=$((RUN_OK + 1))
      ;;
    x12)
      if ! echo "$main_asm" | grep -qE 'mov[[:space:]]+x12, x|mov[[:space:]]+x0, x12|mov[[:space:]]+x1, x12'; then
        rm -f "$exe"
        die "$tag missing x12 spill/reload in _main"
      fi
      RUN_OK=$((RUN_OK + 1))
      ;;
    x13)
      if ! echo "$main_asm" | grep -qE 'mov[[:space:]]+x13, x|mov[[:space:]]+x0, x13|mov[[:space:]]+x1, x13'; then
        rm -f "$exe"
        die "$tag missing x13 spill/reload in _main"
      fi
      RUN_OK=$((RUN_OK + 1))
      ;;
    x14)
      if ! echo "$main_asm" | grep -qE 'mov[[:space:]]+x14, x|mov[[:space:]]+x0, x14|mov[[:space:]]+x1, x14'; then
        rm -f "$exe"
        die "$tag missing x14 spill/reload in _main"
      fi
      RUN_OK=$((RUN_OK + 1))
      ;;
    x15)
      if ! echo "$main_asm" | grep -qE 'mov[[:space:]]+x15, x|mov[[:space:]]+x0, x15|mov[[:space:]]+x1, x15'; then
        rm -f "$exe"
        die "$tag missing x15 spill/reload in _main"
      fi
      RUN_OK=$((RUN_OK + 1))
      ;;
    "") ;;
    *)
      rm -f "$exe"
      die "$tag unknown spill_kind=$spill_kind"
      ;;
  esac

  if [ "$noround" = "1" ]; then
    if ! echo "$main_asm" | perl -0777 -ne 'exit 1 if /mov\s+x1[0-5],\s+x[01]\n\s*mov\s+x[01],\s+x1[0-5]/ || /mov\s+x[01],\s+x1[0-5]\n\s*mov\s+x1[0-5],\s+x[01]/'; then
      rm -f "$exe"
      die "$tag has redundant spill round-trip mov (peephole miss)"
    fi
    RUN_OK=$((RUN_OK + 1))
  fi

  rm -f "$exe"
}

echo "=== asm-binop-block-var gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# tag src want max_b max_a [spill] [noround]
run_case repeat_add tests/asm/binop_block_repeat_add.x 60 1 2
run_case repeat_mul tests/asm/binop_block_repeat_mul.x 12 1 2
run_case prune_dead_b tests/asm/binop_block_prune_dead_b.x 10 1 99
run_case shared_right tests/asm/binop_block_shared_right.x 90 3 4
run_case swap_add tests/asm/binop_block_swap_add.x 60 1 2
run_case three_var tests/asm/binop_block_three_var.x 6 99 99
run_case four_var tests/asm/binop_block_four_var.x 10 99 99
run_case five_var tests/asm/binop_block_five_var.x 231 99 99
run_case six_var tests/asm/binop_block_six_var.x 21 99 99
run_case ret_four_add tests/asm/binop_return_four_add.x 10 99 99 x10
run_case ret_four_mul tests/asm/binop_return_four_mul.x 24 99 99 x10
run_case ret_four_and tests/asm/binop_return_four_and.x 1 99 99 x10
run_case ret_four_or tests/asm/binop_return_four_or.x 15 99 99 x10
run_case ret_four_xor tests/asm/binop_return_four_xor.x 15 99 99 x10
run_case ret_five_add tests/asm/binop_return_five_add.x 15 99 99 x10or11
run_case ret_six_add tests/asm/binop_return_six_add.x 21 99 99 x11
run_case ret_seven_add tests/asm/binop_return_seven_add.x 28 99 99 x12
run_case ret_eight_add tests/asm/binop_return_eight_add.x 36 99 99 x13
run_case ret_nine_add tests/asm/binop_return_nine_add.x 45 99 99 x14 1
run_case ret_thirteen_add tests/asm/binop_return_thirteen_add.x 91 99 99 x15 1
run_case ret_fourteen_add tests/asm/binop_return_fourteen_add.x 105 99 99 x15
run_case two_phase tests/asm/binop_block_two_phase_add.x 36 99 99

ok_report
echo "asm binop block var OK"
