#!/usr/bin/env bash
# MEM-D3: SROA/ASP CTFE chain fold honesty gate.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make (prefer-c /
# false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - hard: product -o exit 7 on both CTFE fixtures
#   - obs: KEEP_C / folded return 7 emit missing under tip asm
# Report: run=/obs=/skip=
# Usage: ./tests/run-sroa-ctfe-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_SROA_CTFE_PREFIX:-xlang: [XLANG_SROA_CTFE]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "sroa-ctfe-gate FAIL: $*" >&2
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

# Product -o expect exit 7; KEEP_C fold markers observational.
# Return 0=ok, 1=hard fail, 2=obs (should not happen for -o fail here — hard).
check_ctfe() {
  local src="$1"
  local label
  label="$(basename "$src" .x)"
  local out="/tmp/xlang_ctfe_${label}_$$"
  local err="/tmp/xlang_ctfe_${label}_$$.log"
  local o_ec r_ec gen main_body
  [ -f "$src" ] || { echo "sroa-ctfe-gate FAIL: missing $src" >&2; return 1; }
  rm -f "$out"

  set +e
  XLANG_KEEP_C=1 gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$out" >"$err" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    echo "sroa-ctfe-gate FAIL $label: -o timeout" >&2
    return 1
  fi
  if [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    echo "sroa-ctfe-gate FAIL $label: product -o ec=$o_ec" >&2
    tail -n 8 "$err" >&2 || true
    return 1
  fi
  set +e
  gate_run_timeout 10 "$out" >/dev/null 2>&1
  r_ec=$?
  set -e
  rm -f "$out"
  if [ "$r_ec" -eq 124 ]; then
    echo "sroa-ctfe-gate FAIL $label: run timeout" >&2
    return 1
  fi
  if [ "$r_ec" -ne 7 ]; then
    echo "sroa-ctfe-gate FAIL $label: exit=$r_ec want 7" >&2
    return 1
  fi
  echo "sroa-ctfe-gate OK $label product -o (exit=7)"

  gen="$(grep 'kept generated C:' "$err" 2>/dev/null | sed 's/.*: //' | tail -1 || true)"
  if [ -z "$gen" ] || [ ! -f "$gen" ]; then
    gen="$(grep -oE '/tmp/xlang_[A-Za-z0-9]+\.c' "$err" 2>/dev/null | tail -1 || true)"
  fi
  if [ -z "$gen" ] || [ ! -f "$gen" ]; then
    echo "sroa-ctfe-gate OBS $label (missing kept C under asm; fold emit residual)" >&2
    return 2
  fi
  if grep -q 'int32_t main(void)' "$gen" 2>/dev/null; then
    main_body=$(sed -n '/int32_t main(void)/,/^}/p' "$gen")
  else
    main_body=$(sed -n '/int main/,/^}/p' "$gen")
  fi
  rm -f "$gen"
  if ! echo "$main_body" | grep -qE 'return 7;'; then
    echo "sroa-ctfe-gate OBS $label (main missing folded return 7 emit; tip residual)" >&2
    return 2
  fi
  if echo "$main_body" | grep -qE 'sum_pair\('; then
    echo "sroa-ctfe-gate OBS $label (main still has sum_pair; tip fold residual)" >&2
    return 2
  fi
  echo "sroa-ctfe-gate OK $label fold emit"
  return 0
}

echo "=== MEM-D3: SROA CTFE chain (prefer asm; hard/obs) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

for src in tests/mem/sroa_ctfe_chain.x tests/mem/sroa_ctfe_chain_alias.x; do
  prc=0
  check_ctfe "$src" || prc=$?
  if [ "$prc" -eq 1 ]; then
    die "ctfe $src"
  elif [ "$prc" -eq 2 ]; then
    # product -o already counted as hard OK inside check_ctfe before OBS return
    RUN_OK=$((RUN_OK + 1))
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 2))
  fi
done

echo "sroa-ctfe-gate OK (MEM-D3 honesty; run=${RUN_OK} obs=${OBS})"
ok_report
exit 0
