#!/usr/bin/env bash
# OBS-004：性能回归自动告警 manifest 门禁
#
# 用法：./tests/run-obs-perf-regression-alert-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_OBS_PERF_ALERT_DOC:-analysis/obs-perf-regression-alert-v1.md}"
MANIFEST="${SHUX_OBS_PERF_ALERT_TSV:-tests/baseline/obs-perf-regression-alert.tsv}"
REG="${SHUX_PERF_BASELINE_REGISTRY:-tests/baseline/perf-baseline-registry.tsv}"
LIB="tests/lib/obs-perf-regression-alert.sh"
RUNNER="tests/run-obs-perf-regression-alert.sh"
DOGFOOD="tests/run-perf-compile-dogfood.sh"
MIN_ALERTS=6

# shellcheck source=tests/lib/obs-perf-regression-alert.sh
. tests/lib/obs-perf-regression-alert.sh
# shellcheck source=tests/lib/perf-baseline-governance.sh
. tests/lib/perf-baseline-governance.sh

echo "=== OBS-004: perf regression alert manifest ==="
for f in "$DOC" "$MANIFEST" "$REG" "$LIB" "$RUNNER" "$DOGFOOD"; do
  if [ ! -f "$f" ]; then
    echo "obs-perf-regression-alert gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_alerts) MIN_ALERTS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
ALERTS=0
echo "=== OBS-004: manifest anchors ==="
while IFS=$'\t' read -r item_id kind anchor notes extra; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|output_prefix) continue ;; esac
  case "$kind" in
    bracket_component)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "obs-perf-regression-alert FAIL: doc missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    output_field)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "obs-perf-regression-alert FAIL: doc missing field $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    regression_alert)
      ALERTS=$((ALERTS + 1))
      fail_env="$notes"
      gate="$extra"
      bid="$anchor"
      if [ -z "$(perf_baseline_registry_get "$bid" 1)" ]; then
        echo "obs-perf-regression-alert FAIL: registry missing $bid" >&2
        MISS=$((MISS + 1))
      fi
      if [ ! -f "tests/$gate" ]; then
        echo "obs-perf-regression-alert FAIL: missing gate tests/$gate" >&2
        MISS=$((MISS + 1))
      fi
      if ! grep -qF "$fail_env" "$DOC" 2>/dev/null; then
        echo "obs-perf-regression-alert FAIL: doc missing env $fail_env" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    emit_hook)
      if ! grep -qF 'SHUX_PERF_ALERT' "tests/$anchor" 2>/dev/null; then
        echo "obs-perf-regression-alert FAIL: $anchor missing SHUX_PERF_ALERT emit" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script|file)
      path="$anchor"
      case "$kind" in
        script) path="tests/$anchor" ;;
      esac
      if [ ! -f "$path" ]; then
        echo "obs-perf-regression-alert FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "obs-perf-regression-alert FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "obs-perf-regression-alert FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "obs-perf-regression-alert FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$ALERTS" -lt "$MIN_ALERTS" ]; then
  echo "obs-perf-regression-alert gate FAIL: alerts=${ALERTS} < min ${MIN_ALERTS}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "obs-perf-regression-alert gate FAIL: missing=${MISS}" >&2
  exit 1
fi

for kw in SHUX_PERF_ALERT 越界 severity=critical baseline_id; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "obs-perf-regression-alert gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done
echo "obs-perf-regression-alert manifest OK (alerts=${ALERTS})"

echo "=== OBS-004: alert smoke runner ==="
chmod +x "$RUNNER" "$LIB"
if ! ./"$RUNNER" --smoke 2>&1 | tee /tmp/obs_perf_alert_smoke.log; then
  echo "obs-perf-regression-alert gate FAIL: smoke runner" >&2
  exit 1
fi
COUNT=$(grep -c 'shux: \[SHUX_PERF_ALERT\]' /tmp/obs_perf_alert_smoke.log || true)
if [ "$COUNT" -lt "$MIN_ALERTS" ]; then
  echo "obs-perf-regression-alert gate FAIL: alert lines=${COUNT}" >&2
  exit 1
fi
LINE=$(grep 'shux: \[SHUX_PERF_ALERT\]' /tmp/obs_perf_alert_smoke.log | head -1)
if ! obs_perf_alert_line_valid "$LINE"; then
  echo "obs-perf-regression-alert gate FAIL: invalid line: $LINE" >&2
  exit 1
fi
echo "obs-perf-regression-alert smoke OK (lines=${COUNT})"
echo "obs-perf-regression-alert gate OK"
