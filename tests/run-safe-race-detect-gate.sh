#!/usr/bin/env bash
# SAFE-006: race detect experimental line — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native) + prefer-c only + soft auto-make + fossil
# top-level DOC retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - manifest + ## Gate + tracks/cases = hard.
#   - product -o mutex/atomic = hard run.
#   - TSAN probe = obs (experimental toolchain).
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-safe-race-detect-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/safe-race.sh
. tests/lib/safe-race.sh

DOC="${XLANG_RACE_DOC:-analysis/archive/safe/safe-race-detect-v1.md}"
MANIFEST="${XLANG_RACE_MANIFEST:-tests/baseline/safe-race-detect.tsv}"
MIN_CASES=2

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "safe-race-detect gate FAIL: $*" >&2
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

echo "=== SAFE-006: race detect manifest (archive DOC) ==="
if [ -f analysis/safe-race-detect-v1.md ]; then
  die "top-level DOC resurrected (live = archive/safe/)"
fi
for f in "$DOC" "$MANIFEST" tests/lib/safe-race.sh tests/run-safe-race-detect.sh \
  tests/safe/race_mutex_ok.x tests/safe/race_atomic_ok.x; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi

for kw in runnable report XLANG_RACE_DETECT T1-tsan-probe; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
CASE_N=0
TRACK_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$item_id" in
    read_path|tsan|cases|report|schedule)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "safe-race FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    track_*)
      TRACK_N=$((TRACK_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "safe-race FAIL: doc missing track $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case_*)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "safe-race FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-race FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    probe)
      if [ ! -f "$src" ]; then
        echo "safe-race FAIL: missing probe $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    lib|runner|gate)
      if [ ! -f "$src" ]; then
        echo "safe-race FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-race FAIL: doc missing ref $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    workflow)
      if [ ! -f "$src" ]; then
        echo "safe-race FAIL: missing workflow $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-race FAIL: doc missing workflow $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_*)
      if [ ! -f "$anchor" ]; then
        echo "safe-race FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$CASE_N" -ge "$MIN_CASES" ] || die "cases=${CASE_N} < min ${MIN_CASES}"
[ "$TRACK_N" -ge 4 ] || die "tracks=${TRACK_N} < 4"
grep -qF 'safe_race_emit_report' tests/run-safe-race-detect.sh 2>/dev/null \
  || die "runner must emit report"
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "safe-race-detect manifest OK (cases=${CASE_N} tracks=${TRACK_N})"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== SAFE-006: product -o cases (XLANG=$XLANG_BIN) ==="

while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$kind" in
    case)
      if safe_race_run_x "$XLANG_BIN" "$src" "$item_id"; then
        RUN_OK=$((RUN_OK + 1))
        echo "safe-race-detect run OK $item_id"
      else
        die "product -o $item_id failed (refuse soft SKIP→OK)"
      fi
      ;;
  esac
done < "$MANIFEST"

# TSAN probe is experimental toolchain — observational only.
# PLATFORM: LINUX primary; Darwin often N/A.
if [ "${XLANG_RACE_PROBE:-0}" = "1" ]; then
  if safe_race_tsan_ok; then
    set +e
    safe_race_run_probe
    prc=$?
    set -e
    if [ "$prc" -eq 0 ]; then
      RUN_OK=$((RUN_OK + 1))
      echo "safe-race-detect probe OK"
    elif [ "$prc" -eq 2 ]; then
      echo "safe-race-detect SKIP probe (toolchain)" >&2
      SKIP=$((SKIP + 1))
    else
      echo "safe-race-detect OBS probe (experimental TSAN residual)" >&2
      OBS=$((OBS + 1))
    fi
  else
    echo "safe-race-detect SKIP probe (no TSAN)" >&2
    SKIP=$((SKIP + 1))
  fi
else
  echo "safe-race-detect OBS probe (opt-in XLANG_RACE_PROBE=1; refuse soft silence)" >&2
  OBS=$((OBS + 1))
fi

echo "safe-race-detect gate OK"
safe_race_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
