#!/usr/bin/env bash
# PERF-011：超越 Zig 战略看板 manifest 门禁
#
# 用法：./tests/run-perf-zig-strategy-dashboard-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_PERF_ZIG_STRATEGY_DOC:-analysis/perf-zig-strategy-dashboard-v1.md}"
MANIFEST="${SHUX_PERF_ZIG_STRATEGY_TSV:-tests/baseline/perf-zig-strategy-dashboard.tsv}"
CASES="${SHUX_ZIG_STRATEGY_CASES:-tests/baseline/zig-strategy-cases.tsv}"
HISTORY="${SHUX_ZIG_STRATEGY_HISTORY:-tests/baseline/zig-strategy-history.tsv}"
LIB="tests/lib/zig-strategy-dashboard.sh"
RUNNER="tests/run-perf-zig-strategy-dashboard.sh"
ZIG_GATE="tests/run-zig-baseline-gate.sh"
MIN_CASES=6
MIN_MONTHS=2
PREFIX="shux: [SHUX_ZIG_STRATEGY]"

# shellcheck source=tests/lib/zig-strategy-dashboard.sh
. tests/lib/zig-strategy-dashboard.sh

echo "=== PERF-011: Zig strategy dashboard manifest ==="
for f in "$DOC" "$MANIFEST" "$CASES" "$HISTORY" "$LIB" "$RUNNER" "$ZIG_GATE"; do
  if [ ! -f "$f" ]; then
    echo "perf-zig-strategy gate FAIL: missing $f" >&2
    exit 1
  fi
done

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
  echo "perf-zig-strategy gate FAIL: history months=${HIST_MONTHS} < min ${MIN_MONTHS}" >&2
  exit 1
fi

if [ "$CASES_N" -lt "$MIN_CASES" ]; then
  echo "perf-zig-strategy gate FAIL: cases=${CASES_N} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "perf-zig-strategy gate FAIL: missing=${MISS}" >&2
  exit 1
fi

# 趋势图烟测：每个 case 须有非空 sparkline。
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
  exit 1
fi

for kw in Zig strategy dashboard trend sparkline monthly; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "perf-zig-strategy gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done
echo "perf-zig-strategy manifest OK (cases=${CASES_N} months=${HIST_MONTHS})"

if command -v zig >/dev/null 2>&1; then
  echo "=== PERF-011: dashboard live smoke (advisory) ==="
  chmod +x "$RUNNER"
  if SHUX_ZIG_STRATEGY_FAIL=0 ./"$RUNNER" 2>&1 | tee /tmp/perf_zig_strategy_smoke.log | tail -12; then
    if grep -qF "$PREFIX" /tmp/perf_zig_strategy_smoke.log; then
      echo "perf-zig-strategy live smoke OK"
    elif grep -q 'zig-strategy dashboard SKIP' /tmp/perf_zig_strategy_smoke.log; then
      echo "perf-zig-strategy gate SKIP live smoke (runner skipped)" >&2
    else
      echo "perf-zig-strategy gate SKIP live smoke (no SHUX_ZIG_STRATEGY lines; compile skip OK)" >&2
    fi
  else
    echo "perf-zig-strategy gate SKIP live smoke (runner non-fatal)" >&2
  fi
else
  echo "perf-zig-strategy gate SKIP live smoke (no zig)" >&2
fi

echo "perf-zig-strategy gate OK"
