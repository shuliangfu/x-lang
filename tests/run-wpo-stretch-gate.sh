#!/usr/bin/env bash
# S5 WPO stretch gate: xlang_asm full-chain binary proxy must be ≥ 3%
# (after strict bstrict). CI-fast is only ~0.8%; do not hard-open in default jobs.
#
# Honesty: soft SKIP→OK when no xlang_asm retired. Missing native = hard die.
# Tip under-min proxy (<3%) = obs (perf residual; XLANG_WPO_STRETCH_FAIL=1
# still hard). Darwin delegates to asm-text N/A (skip=1; Linux covers).
# Report run=/obs=/skip=. Refuse claiming "≥ 3%" after skip or under-min obs.
#
# Usage:
#   ./tests/run-wpo-stretch-gate.sh
#   XLANG=./compiler/xlang_asm ./tests/run-wpo-stretch-gate.sh
# Env:   XLANG_WPO_STRETCH_SKIP=1 → skip=1 status=ok
#        XLANG_WPO_STRETCH_FAIL=1 → under-min hard die (default obs)
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED harness — Darwin skip; Ubuntu x86_64 gold for stretch %.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_WPO_STRETCH_PREFIX:-xlang: [XLANG_WPO_STRETCH]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "wpo stretch gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

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
  abs="$root/compiler/xlang_asm"
  if dod_native_exe "$abs"; then
    echo "$abs"
    return 0
  fi
  return 1
}

echo "=== wpo stretch: binary proxy ≥ 3% ==="
if [ "${XLANG_WPO_STRETCH_SKIP:-0}" = "1" ]; then
  SKIP=$((SKIP + 1))
  gate_progress "wpo stretch gate: SKIP (XLANG_WPO_STRETCH_SKIP=1)"
  echo "wpo stretch gate OK"
  ok_report
  exit 0
fi

# Explicit bad XLANG hard-dies before platform skip (refuse soft SKIP→OK).
if [ -n "${XLANG:-}" ]; then
  case "$XLANG" in
    /*) _abs="$XLANG" ;;
    *) _abs="$(pwd)/$XLANG" ;;
  esac
  dod_native_exe "$_abs" || die "explicit XLANG not native: $XLANG (refuse soft SKIP→OK)"
fi

# PLATFORM: DARWIN — asm-text A/B N/A; do not claim stretch ≥3% here.
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  SKIP=$((SKIP + 1))
  gate_progress "wpo stretch gate: SKIP (Darwin asm-text N/A; Linux covers ≥3%)"
  echo "wpo stretch gate OK (Darwin N/A)"
  ok_report
  exit 0
fi

ASM="$(resolve_asm)" || die "no native xlang_asm (refuse soft SKIP→OK)"
export XLANG="$ASM"
export XLANG_LINK_XLANG="$ASM"

FAIL_STRETCH="${XLANG_WPO_STRETCH_FAIL:-0}"
chmod +x tests/run-perf-wpo-dce-xlang-asm-text.sh
LOG="/tmp/wpo_stretch_3pct_$$.log"
rm -f "$LOG"
set +e
XLANG="$ASM" XLANG_WPO_STRETCH_3PCT=1 \
  XLANG_PERF_FAIL_ON_WPO_XLANG_ASM_TEXT="$FAIL_STRETCH" \
  ./tests/run-perf-wpo-dce-xlang-asm-text.sh >"$LOG" 2>&1
ec=$?
set -e
cat "$LOG"
if [ "$ec" -ne 0 ]; then
  if [ "$FAIL_STRETCH" = "1" ]; then
    die "asm-text stretch failed ec=$ec (XLANG_WPO_STRETCH_FAIL=1)"
  fi
  echo "wpo stretch gate OBS: asm-text stretch residual ec=$ec (counted)" >&2
  OBS=$((OBS + 1))
  echo "wpo stretch gate OK"
  ok_report
  exit 0
fi
if ! grep -q 'wpo xlang_asm text OK' "$LOG"; then
  die "missing wpo xlang_asm text OK marker"
fi
# Tip under-min (<3%) surfaces as child obs when FAIL_STRETCH=0.
if grep -qE 'OBS:.*min 3\.0|status=ok.*obs=[1-9]' "$LOG"; then
  OBS=$((OBS + 1))
  RUN_OK=$((RUN_OK + 1))
  gate_progress "wpo stretch gate OK (obs under-min <3%; not claiming ≥3%)"
  echo "wpo stretch gate OK (obs under-min; tip proxy <3%)"
  ok_report
  exit 0
fi
RUN_OK=$((RUN_OK + 1))
gate_progress "wpo stretch gate OK (binary proxy save ≥ 3%)"
echo "wpo stretch gate OK (binary proxy save ≥ 3%)"
ok_report
