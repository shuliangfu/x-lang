#!/usr/bin/env bash
# PERF-011: Zig strategy dashboard manifest gate.
#
# Honesty: soft XLANG_ZIG_STRATEGY_FAIL:-0 smoke previously left microbench
# behind unchecked; soft SKIP→OK / runner-non-fatal soft green / soft
# auto-make retired. Prefer product xlang_asm. DOC authority = archive/perf.
# Live smoke behind / compile-fail = obs via runner (FAIL=1 still hard).
# Report run=/obs=/skip=.
#
# Usage: ./tests/run-perf-zig-strategy-dashboard-gate.sh
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/zig-strategy-dashboard.sh
. tests/lib/zig-strategy-dashboard.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_PERF_ZIG_STRATEGY_DOC:-analysis/archive/perf/perf-zig-strategy-dashboard-v1.md}"
MANIFEST="${XLANG_PERF_ZIG_STRATEGY_TSV:-tests/baseline/perf-zig-strategy-dashboard.tsv}"
CASES="${XLANG_ZIG_STRATEGY_CASES:-tests/baseline/zig-strategy-cases.tsv}"
HISTORY="${XLANG_ZIG_STRATEGY_HISTORY:-tests/baseline/zig-strategy-history.tsv}"
LIB="tests/lib/zig-strategy-dashboard.sh"
RUNNER="tests/run-perf-zig-strategy-dashboard.sh"
ZIG_GATE="tests/run-zig-baseline-gate.sh"
MIN_CASES=6
MIN_MONTHS=2
PREFIX="xlang: [XLANG_ZIG_STRATEGY]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "perf-zig-strategy gate FAIL: $*" >&2
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

# Refuse resurrecting top-level DOC (archive is authority).
if [ -f analysis/perf-zig-strategy-dashboard-v1.md ]; then
  die "refuse top-level analysis/perf-zig-strategy-dashboard-v1.md (use archive/perf)"
fi

echo "=== PERF-011: Zig strategy dashboard manifest ==="
for f in "$DOC" "$MANIFEST" "$CASES" "$HISTORY" "$LIB" "$RUNNER" "$ZIG_GATE"; do
  if [ ! -f "$f" ]; then
    die "missing $f"
  fi
done
if ! grep -q '^## Gate$' "$DOC" 2>/dev/null; then
  die "doc missing ## Gate ($DOC)"
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_cases) MIN_CASES="$c2" ;;
    min_history_months) MIN_MONTHS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
CASES_N=0
echo "=== PERF-011: manifest anchors ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|output_prefix) continue ;; esac
  case "$kind" in
    field)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-zig-strategy FAIL: doc missing field $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    bracket_component)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-zig-strategy FAIL: doc missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASES_N=$((CASES_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-zig-strategy FAIL: doc missing case $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if ! awk -F'\t' -v c="$anchor" '$1==c && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$CASES"; then
        echo "perf-zig-strategy FAIL: cases missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|script)
      path="$anchor"
      case "$kind" in
        script) path="tests/$anchor" ;;
      esac
      if [ ! -f "$path" ]; then
        echo "perf-zig-strategy FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-zig-strategy FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "perf-zig-strategy FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-zig-strategy FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if ! grep -qF 'zsd_report_emit' "$RUNNER" 2>/dev/null; then
  echo "perf-zig-strategy FAIL: $RUNNER must call zsd_report_emit" >&2
  MISS=$((MISS + 1))
fi

HIST_MONTHS=$(zsd_history_months "$HISTORY")
if [ "$HIST_MONTHS" -lt "$MIN_MONTHS" ]; then
  die "history months=${HIST_MONTHS} < min ${MIN_MONTHS}"
fi

if [ "$CASES_N" -lt "$MIN_CASES" ]; then
  die "cases=${CASES_N} < min ${MIN_CASES}"
fi
if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi

# Trend smoke: each case must have a non-empty sparkline.
SPARK_FAIL=0
while IFS=$'\t' read -r case_id _rest; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*) continue ;; esac
  sp=$(zsd_sparkline "$case_id" "$HISTORY")
  if [ -z "$sp" ] || [ "$sp" = "—" ]; then
    echo "perf-zig-strategy FAIL: no trend for $case_id" >&2
    SPARK_FAIL=1
  else
    echo "perf-zig-strategy trend OK: $case_id $sp"
  fi
done < "$CASES"

if [ "$SPARK_FAIL" -ne 0 ]; then
  die "sparkline missing for one or more cases"
fi

for kw in Zig strategy dashboard trend sparkline monthly; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing keyword $kw"
  fi
done
echo "perf-zig-strategy manifest OK (cases=${CASES_N} months=${HIST_MONTHS})"
RUN_OK=1

# Explicit bad XLANG still hard-dies even when live smoke is N/A.
if [ -n "${XLANG:-}" ]; then
  resolve_shu >/dev/null || die "XLANG=${XLANG} not native (refuse soft SKIP→OK)"
fi

chmod +x "$RUNNER"
if command -v zig >/dev/null 2>&1; then
  echo "=== PERF-011: dashboard live smoke ==="
  XLANG_GATE=""
  if ! XLANG_GATE="$(resolve_shu)"; then
    die "no native xlang for live smoke (refuse soft SKIP→OK)"
  fi
  set +e
  XLANG="$XLANG_GATE" XLANG_LINK_XLANG="$XLANG_GATE" XLANG_ZIG_STRATEGY_FAIL=0 \
    ./"$RUNNER" >/tmp/perf_zig_strategy_smoke.log 2>&1
  smoke_rc=$?
  set -e
  tail -20 /tmp/perf_zig_strategy_smoke.log || true
  if [ "$smoke_rc" -ne 0 ]; then
    die "zig-strategy smoke hard-fail rc=${smoke_rc}"
  fi
  grep -qF "$PREFIX" /tmp/perf_zig_strategy_smoke.log || \
    die "missing $PREFIX in runner output"
  if grep -q 'OBS:' /tmp/perf_zig_strategy_smoke.log; then
    OBS=1
    echo "perf-zig-strategy live smoke OBS (see runner log)" >&2
  fi
  echo "perf-zig-strategy live smoke OK"
else
  SKIP=1
  echo "perf-zig-strategy gate SKIP live smoke (no zig)" >&2
fi

ok_report
echo "perf-zig-strategy gate OK"
