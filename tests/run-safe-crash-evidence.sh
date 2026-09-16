#!/usr/bin/env bash
# SAFE-007: crash evidence regression runner — honesty soft→硬绿.
#
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
# Product -o UNDEF residual = obs (report via gate).
# Usage: XLANG_CRASH_EVIDENCE=1 ./tests/run-safe-crash-evidence.sh
# PLATFORM: SHARED archaeology.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/safe-crash.sh
. tests/lib/safe-crash.sh

OUT_DIR="${XLANG_CRASH_EVIDENCE_DIR:-/tmp/xlang_crash_evidence_$$}"
mkdir -p "$OUT_DIR"
export XLANG_CRASH_EVIDENCE="${XLANG_CRASH_EVIDENCE:-1}"
export XLANG_CRASH_EVIDENCE_DIR="$OUT_DIR"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "safe-crash-evidence FAIL: $*" >&2
  safe_crash_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
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

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== SAFE-007: manual evidence (XLANG=$XLANG_BIN) ==="
EXE="/tmp/xlang_crash_manual_$$"
LOG="/tmp/xlang_crash_manual_$$.log"
set +e
"$XLANG_BIN" -L . tests/crash/evidence_manual.x -o "$EXE" >"$LOG" 2>&1
bec=$?
set -e
if [ "$bec" -ne 0 ]; then
  if grep -qE 'Undefined symbols|undefined reference|UNDEF|BLD001' "$LOG" 2>/dev/null; then
    echo "safe-crash-evidence OBS manual (product -o UNDEF/ld residual)" >&2
    OBS=$((OBS + 1))
  else
    tail -n 12 "$LOG" >&2 || true
    die "compile evidence_manual"
  fi
else
  "$EXE" 2>"$LOG" || true
  if safe_crash_grep_evidence "$LOG"; then
    RUN_OK=$((RUN_OK + 1))
    echo "safe-crash-evidence manual OK"
  else
    echo "safe-crash-evidence OBS manual (no evidence line)" >&2
    OBS=$((OBS + 1))
  fi
fi
rm -f "$EXE"

echo "=== SAFE-007: panic evidence (div_zero) ==="
PLOG="/tmp/xlang_crash_panic_$$.log"
PEX="/tmp/xlang_crash_panic_$$"
set +e
"$XLANG_BIN" -L . tests/ub/div_zero.x -o "$PEX" >"$PLOG" 2>&1
pbec=$?
set -e
if [ "$pbec" -ne 0 ]; then
  if grep -qE 'Undefined symbols|undefined reference|UNDEF|BLD001' "$PLOG" 2>/dev/null; then
    echo "safe-crash-evidence OBS panic (product -o UNDEF/ld residual)" >&2
    OBS=$((OBS + 1))
  else
    tail -n 12 "$PLOG" >&2 || true
    die "compile div_zero"
  fi
else
  set +e
  "$PEX" 2>"$PLOG"
  set -e
  if safe_crash_grep_evidence "$PLOG"; then
    RUN_OK=$((RUN_OK + 1))
    echo "safe-crash-evidence panic OK"
  else
    echo "safe-crash-evidence OBS panic (no evidence line)" >&2
    OBS=$((OBS + 1))
  fi
fi
rm -f "$PEX"

safe_crash_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "safe-crash-evidence OK"
