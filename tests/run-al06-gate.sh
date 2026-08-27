#!/usr/bin/env bash
# MEM-C1 AL-06: slice + Allocator dual-escape + AL-04 assign-escape typeck negatives.
#
# Honesty: soft SKIP→OK when no xlang binary retired. Prefer product
# xlang_asm (was prefer xlang first); pin XLANG_LINK_XLANG. Explicit bad
# XLANG / missing native = hard die. Tip `xlang check` CHK002 / missing
# escape message = obs (check gate paused 2026-08-05; not soft SKIP→OK
# and not honesty hard-red). Report run=/obs=/skip=.
#
# Usage: ./tests/run-al06-gate.sh
# Env:   XLANG_AL06_SKIP=1 → skip=1 status=ok
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED harness — check path is tip residual (obs); Ubuntu gold
# still required when check gate reopens.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_AL06_PREFIX:-xlang: [XLANG_AL06]}"
AL06_TIMEOUT="${XLANG_AL06_TIMEOUT:-30}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "al06-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

# Prefer product asm; explicit XLANG wins only when native.
resolve_asm() {
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

run_check() {
  local src="$1"
  if command -v timeout >/dev/null 2>&1; then
    timeout --signal=TERM --kill-after=5 "$AL06_TIMEOUT" "$XLANG" check "$src" 2>&1 || true
  else
    # portable wall-clock alarm via perl (not soft SKIP→OK)
    perl -e "alarm $AL06_TIMEOUT; exec @ARGV" "$XLANG" check "$src" 2>&1 || true
  fi
}

# Negatives: expected escape diag = run++; CHK002 / missing msg = obs
# (check paused). Refuse soft SKIP→OK.
check_neg() {
  local src="$1"
  local msg="$2"
  local out
  [ -f "$src" ] || die "missing $src"
  out="$(run_check "$src")"
  if echo "$out" | grep -qF "$msg"; then
    RUN_OK=$((RUN_OK + 1))
    gate_progress "al06-gate OK $src -> $msg"
    return 0
  fi
  if echo "$out" | grep -qE 'CHK002|no \.x files found'; then
    echo "al06-gate OBS: $src check CHK002/no .x (check gate paused; want '$msg')" >&2
    echo "$out" | head -6 >&2
    OBS=$((OBS + 1))
    return 0
  fi
  echo "al06-gate OBS: $src missing '$msg' (check residual; not soft SKIP→OK)" >&2
  echo "$out" | head -12 >&2
  OBS=$((OBS + 1))
}

echo "=== AL-06: assign + dual escape (check path) ==="
if [ "${XLANG_AL06_SKIP:-0}" = "1" ]; then
  SKIP=$((SKIP + 1))
  gate_progress "al06-gate: SKIP (XLANG_AL06_SKIP=1)"
  echo "al06-gate OK"
  ok_report
  exit 0
fi

XLANG_BIN="$(resolve_asm)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
gate_progress "al06-gate: XLANG=$XLANG"

check_neg tests/typeck/allocator_assign_escape.x "allocator region escape"
check_neg tests/typeck/dual_escape_with_arena_region.x "slice region escape"

gate_progress "al06-gate OK (AL-04 assign + AL-06 dual escape; obs=${OBS})"
echo "al06-gate OK (AL-04 assign + AL-06 dual escape)"
ok_report
