#!/usr/bin/env bash
# asm 7.3: block INDEX assign chains (lit/VAR/nested/sub-mul) + addr-cache reuse.
#
# Honesty: soft default `./compiler/xlang` + soft auto-make (false authority)
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - hard: product -o + expected exits for all block fixtures
#   - hard (Darwin+otool): main has no `mov x2`; optional max `ldur w` for reuse
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

PREFIX="${XLANG_ASM_ASSIGN_INDEX_BLOCK_PREFIX:-xlang: [XLANG_ASM_ASSIGN_INDEX_BLOCK]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "asm-assign-index-block FAIL: $*" >&2
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

# Product -o + expected exit; Darwin otool forbid mov x2; optional max ldur w.
# max_ldur empty = no ldur bound; forbid_x2 always on when Darwin+otool.
run_case() {
  local tag="$1" src="$2" want="$3" max_ldur="${4:-}"
  local exe="/tmp/xlang_asm_assign_index_block_${tag}_$$"
  local log="/tmp/xlang_asm_assign_index_block_${tag}_$$.log"
  local o_ec r_ec main_asm ldur_count
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

  # PLATFORM: DARWIN — otool arm64 main disasm. Non-Darwin = skip= honesty.
  if [ "$(uname -s)" = Darwin ] && command -v otool >/dev/null 2>&1; then
    main_asm=$(otool -tv "$exe" 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' || true)
    if echo "$main_asm" | grep -q 'mov x2'; then
      rm -f "$exe"
      die "$tag main still uses mov x2"
    fi
    RUN_OK=$((RUN_OK + 1))
    if [ -n "$max_ldur" ]; then
      ldur_count=$(echo "$main_asm" | grep -cE 'ldur[[:space:]]+w' || true)
      if [ "$ldur_count" -gt "$max_ldur" ]; then
        rm -f "$exe"
        die "$tag ldur w count $ldur_count > $max_ldur (addr cache miss?)"
      fi
      RUN_OK=$((RUN_OK + 1))
    fi
  else
    SKIP=$((SKIP + 1))
  fi
  rm -f "$exe"
}

echo "=== asm-assign-index-block gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

run_case lit_sum tests/asm/assign_index_block_sum.x 6
run_case var_idx tests/asm/assign_index_block_var.x 6
run_case nested tests/asm/assign_index_block_nested.x 62
run_case sub_mul tests/asm/assign_index_block_sub_mul.x 33
run_case sub_mul_reuse tests/asm/assign_index_block_sub_mul.x 33 6
run_case seq tests/asm/assign_index_block_seq.x 45
run_case same_idx_reuse tests/asm/assign_index_block_reuse_same_index.x 22 8
run_case subadd3_mul_lit tests/asm/assign_index_block_subadd3_mul_lit.x 33 5
run_case minus_mul_lit tests/asm/assign_index_block_minus_mul_lit.x 33 6
run_case minus_mul_lit_seq tests/asm/assign_index_block_minus_mul_lit_seq.x 33 4
run_case rhs_index tests/asm/assign_index_block_rhs_index.x 20
run_case read_between tests/asm/assign_index_block_read_between.x 33 10
run_case let_read_cache tests/asm/assign_index_block_let_read_addr_cache.x 99 3
run_case read_subadd3 tests/asm/assign_index_block_read_subadd3.x 198 4
run_case read_minus_mul tests/asm/assign_index_block_read_minus_mul.x 22 5
run_case read_minus_mul_seq tests/asm/assign_index_block_read_minus_mul_seq.x 110 3

ok_report
echo "asm assign index block OK"
