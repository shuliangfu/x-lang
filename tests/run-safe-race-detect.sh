#!/usr/bin/env bash
# SAFE-006: race detect experimental runner — honesty soft→硬绿.
#
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
# Usage:
#   ./tests/run-safe-race-detect.sh
#   XLANG_RACE_PROBE=1 ./tests/run-safe-race-detect.sh
# PLATFORM: SHARED product -o; LINUX TSAN probe experimental.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/safe-race.sh
. tests/lib/safe-race.sh

MANIFEST="${XLANG_RACE_MANIFEST:-tests/baseline/safe-race-detect.tsv}"
DO_PROBE=0
[ "${XLANG_RACE_PROBE:-0}" = "1" ] && DO_PROBE=1

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "safe-race-detect FAIL: $*" >&2
  safe_race_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== SAFE-006: race detect (XLANG=$XLANG_BIN) ==="

while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|track_*|probe|lib|runner|gate|workflow|cross_*) continue ;; esac
  case "$kind" in
    case)
      echo "── $item_id ($src) ──"
      if safe_race_run_x "$XLANG_BIN" "$src" "$item_id"; then
        RUN_OK=$((RUN_OK + 1))
      else
        die "case $item_id failed (refuse soft SKIP→OK)"
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$DO_PROBE" -eq 1 ]; then
  if safe_race_tsan_ok; then
    echo "── race_probe (TSAN) ──"
    set +e
    safe_race_run_probe
    prc=$?
    set -e
    if [ "$prc" -eq 0 ]; then
      RUN_OK=$((RUN_OK + 1))
    elif [ "$prc" -eq 2 ]; then
      SKIP=$((SKIP + 1))
    else
      echo "safe-race-detect OBS probe (experimental)" >&2
      OBS=$((OBS + 1))
    fi
  else
    echo "safe-race probe SKIP: no TSAN toolchain" >&2
    SKIP=$((SKIP + 1))
  fi
fi

safe_race_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "safe-race-detect OK"
