#!/usr/bin/env bash
# ZC-008：零拷贝指标仪表板 manifest 门禁
#
# 用法：./tests/run-zc-dashboard-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_ZC_DASHBOARD_DOC:-analysis/zc-dashboard-v1.md}"
MANIFEST="${SHUX_ZC_DASHBOARD_MANIFEST:-tests/baseline/zc-dashboard-manifest.tsv}"
METRICS="${SHUX_ZC_DASHBOARD_METRICS:-tests/baseline/zc-dashboard-metrics.tsv}"
HISTORY="${SHUX_ZC_DASHBOARD_HISTORY:-tests/baseline/zc-dashboard-history.tsv}"
LIB="tests/lib/zc-dashboard.sh"
RUNNER="tests/run-zc-dashboard.sh"
MIN_METRICS=8
MIN_DAYS=2

# shellcheck source=tests/lib/zc-dashboard.sh
. tests/lib/zc-dashboard.sh

echo "=== ZC-008: zero-copy dashboard manifest ==="
for f in "$DOC" "$MANIFEST" "$METRICS" "$HISTORY" "$LIB" "$RUNNER"; do
  if [ ! -f "$f" ]; then
    echo "zc-dashboard gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in dashboard daily runnable report sparkline SHUX_ZC_DASHBOARD; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "zc-dashboard gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_metrics) MIN_METRICS="$c2" ;;
    min_history_days) MIN_DAYS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
METRIC_N=0
LAYER_N=0
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|output_prefix) continue ;; esac
  case "$kind" in
    field)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "zc-dashboard FAIL: doc missing field $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      layer_key="${anchor%%	*}"
      if ! grep -qF "$layer_key" "$DOC" 2>/dev/null; then
        echo "zc-dashboard FAIL: doc missing layer $layer_key" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|script)
      path="$anchor"
      case "$kind" in
        script) path="tests/$anchor" ;;
      esac
      if [ ! -f "$path" ]; then
        echo "zc-dashboard FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "zc-dashboard FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "zc-dashboard FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

METRIC_N=$(awk -F'\t' '$1 !~ /^#/ && NF >= 2 { n++ } END { print n+0 }' "$METRICS")
if [ "$METRIC_N" -lt "$MIN_METRICS" ]; then
  echo "zc-dashboard gate FAIL: metrics=${METRIC_N} < min ${MIN_METRICS}" >&2
  exit 1
fi

HIST_DAYS=$(zcd_history_days "$HISTORY")
if [ "$HIST_DAYS" -lt "$MIN_DAYS" ]; then
  echo "zc-dashboard gate FAIL: history days=${HIST_DAYS} < min ${MIN_DAYS}" >&2
  exit 1
fi

if ! grep -qF 'zcd_report_emit' "$RUNNER" 2>/dev/null; then
  echo "zc-dashboard gate FAIL: $RUNNER must call zcd_report_emit" >&2
  MISS=$((MISS + 1))
fi

if [ "$MISS" -gt 0 ]; then
  echo "zc-dashboard gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "zc-dashboard manifest OK (metrics=${METRIC_N} layers=${LAYER_N} days=${HIST_DAYS})"

echo "=== ZC-008: dashboard runnable report ==="
chmod +x "$RUNNER" 2>/dev/null || true
if "$RUNNER" 2>/tmp/zc_dashboard_smoke.log; then
  grep -q 'SHUX_ZC_DASHBOARD' /tmp/zc_dashboard_smoke.log || {
    echo "zc-dashboard gate FAIL: missing report prefix" >&2
    exit 1
  }
  echo "zc-dashboard gate OK"
else
  echo "zc-dashboard gate FAIL: runner" >&2
  exit 1
fi
