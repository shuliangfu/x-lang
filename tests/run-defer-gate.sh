#!/usr/bin/env bash
# MEM-B0: defer static-inline smoke (LIFO / nested / multi-return).
#
# Honesty: soft default `./compiler/xlang` + soft host-cc `-backend c`
# fallback (false authority) retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die
# (refuse soft SKIP→OK / soft auto-make / prefer-c / soft host-cc).
# Optional host-cc only when caller exports XLANG_ALLOW_HOST_CC (not a
# soft silence path). Report: run=/obs=/skip=
# Usage: ./tests/run-defer-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_DEFER_PREFIX:-xlang: [DEFER]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "defer-gate FAIL: $*" >&2
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
  local exe="/tmp/xlang_defer_${tag}_$$"
  local log="/tmp/xlang_defer_${tag}_$$.log"
  local o_ec r_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$exe" "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build -L . "$src" -o "$exe" >"$log" 2>&1
  o_ec=$?
  set -e
  # Optional host-cc only when caller opts in — never soft prefer-c.
  if { [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; } && [ -n "${XLANG_ALLOW_HOST_CC:-}" ]; then
    rm -f "$exe"
    set +e
    gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build -backend c -L . "$src" -o "$exe" >"$log" 2>&1
    o_ec=$?
    set -e
  fi
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
  echo "defer-gate OK $src exit=$want"
  RUN_OK=$((RUN_OK + 1))
}

echo "=== defer gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

run_exit main tests/defer/main.x 42
run_exit order_lifo tests/defer/order_lifo.x 21
run_exit nested_if tests/defer/nested_if.x 111
run_exit multi_return tests/defer/multi_return.x 30

ok_report
echo "defer-gate OK (MEM-B0 defer smoke)"
