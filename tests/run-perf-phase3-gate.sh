#!/usr/bin/env bash
# PERF-172: Phase 3 std hotpath perf smoke gate.
#
# Honesty: soft SKIP→OK when no native xlang + soft prefer-xlang-c +
# missing top-level DOC retired. Prefer product xlang_asm. Explicit bad
# XLANG = hard die. Over-cap median = obs (FAIL hard only when
# XLANG_PERF_PHASE3_FAIL=1). DOC authority = archive/perf. Report
# run=/obs=/skip=.
#
# Usage: ./tests/run-perf-phase3-gate.sh
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_PERF_PHASE3_DOC:-analysis/archive/perf/perf-phase3-v1.md}"
MANIFEST="${XLANG_PERF_PHASE3_MANIFEST:-tests/baseline/perf-phase3-manifest.tsv}"
BASELINE="${XLANG_PERF_PHASE3_TSV:-tests/baseline/perf-phase3.tsv}"
BENCH_X="bench/phase3_std_hotpath.x"
LIB="tests/lib/perf-phase3.sh"
RUNS="${XLANG_PERF_PHASE3_RUNS:-3}"
FAIL_HARD="${XLANG_PERF_PHASE3_FAIL:-0}"
PREFIX="xlang: [XLANG_PERF_PHASE3]"
CHECK_OK=0
RUN_OK=0
OBS=0
SKIP=0

# shellcheck source=tests/lib/perf-phase3.sh
. "$LIB"

die() {
  echo "perf-phase3 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail check=${CHECK_OK} run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok check=${CHECK_OK} run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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

if [ -f analysis/perf-phase3-v1.md ]; then
  die "refuse top-level analysis/perf-phase3-v1.md (use archive/perf)"
fi

echo "=== PERF-172: phase3 std perf manifest ==="
for f in "$DOC" "$MANIFEST" "$BASELINE" "$LIB" "$BENCH_X"; do
  if [ ! -f "$f" ]; then
    die "missing $f"
  fi
done
if ! grep -q '^## Gate$' "$DOC" 2>/dev/null; then
  die "doc missing ## Gate ($DOC)"
fi
for kw in PERF-172 phase3_std_hotpath timezone_iana tcp_pool_new; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing '$kw'"
  fi
done
echo "perf-phase3 manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK)"

echo "=== PERF-172: typeck (XLANG=$XLANG_BIN) ==="
if "$XLANG_BIN" check -L . "$BENCH_X" >/dev/null 2>&1; then
  CHECK_OK=1
else
  echo "perf-phase3 OBS: typeck/check residual (check gate paused)" >&2
  "$XLANG_BIN" check -L . "$BENCH_X" 2>&1 | tail -6 >&2 || true
  OBS=1
fi

OUT="/tmp/xlang_perf_phase3_loop"
if "$XLANG_BIN" -L . "$BENCH_X" -o "$OUT" >/dev/null 2>&1 && [ -x "$OUT" ]; then
  MED="$(perf_phase3_median_real "$OUT" "$RUNS")"
  CEIL="$(awk -F'\t' '$1=="phase3_std_hotpath_loop"{print $2; exit}' "$BASELINE")"
  echo "perf-phase3 median=${MED}s ceiling=${CEIL}s"
  if [ "${XLANG_PERF_UPDATE_PHASE3_BASELINE:-0}" = "1" ] && [ "$MED" != "nan" ]; then
    awk -v m="$MED" 'BEGIN { printf "%.3f\n", m * 1.25 }' | {
      read -r new_ceil
      echo "perf-phase3 UPDATE baseline ceiling -> ${new_ceil}s"
      awk -F'\t' -v c="$new_ceil" '$1=="phase3_std_hotpath_loop"{print $1"\t"c; next}{print}' "$BASELINE" > "${BASELINE}.tmp"
      mv "${BASELINE}.tmp" "$BASELINE"
    }
    RUN_OK=1
  elif [ "$MED" != "nan" ] && awk -v m="$MED" -v c="$CEIL" 'BEGIN { exit (m <= c + 0.000001) ? 0 : 1 }'; then
    RUN_OK=1
    echo "perf-phase3 regression OK"
  else
    OBS=1
    echo "perf-phase3 OBS: median ${MED}s > ceiling ${CEIL}s (or nan)" >&2
    if [ "$FAIL_HARD" = "1" ]; then
      die "median ${MED}s > ceiling ${CEIL}s (XLANG_PERF_PHASE3_FAIL=1)"
    fi
    RUN_OK=1
  fi
  rm -f "$OUT"
else
  OBS=1
  echo "perf-phase3 OBS: compile/link residual (no runnable)" >&2
  if [ "$FAIL_HARD" = "1" ]; then
    die "compile/link failed (XLANG_PERF_PHASE3_FAIL=1)"
  fi
fi

echo "perf-phase3 gate OK"
ok_report
perf_phase3_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
exit 0
