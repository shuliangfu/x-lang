#!/usr/bin/env bash
# ZC-008：零拷贝指标看板 runner（每日采集 + 趋势）
#
# 用法：
#   ./tests/run-zc-dashboard.sh
#   ./tests/run-zc-dashboard.sh --record
#   SHUX_ZC_DASHBOARD_RECORD=1 ./tests/run-zc-dashboard.sh --record
set -e
cd "$(dirname "$0")/.."

METRICS="${SHUX_ZC_DASHBOARD_METRICS:-tests/baseline/zc-dashboard-metrics.tsv}"
HISTORY="${SHUX_ZC_DASHBOARD_HISTORY:-tests/baseline/zc-dashboard-history.tsv}"
RECORD=0
[ "${SHUX_ZC_DASHBOARD_RECORD:-0}" = "1" ] && RECORD=1
[ "${1:-}" = "--record" ] && RECORD=1

# shellcheck source=tests/lib/zc-dashboard.sh
. tests/lib/zc-dashboard.sh

echo "=== ZC-008: zero-copy metrics dashboard ==="
if [ ! -f "$METRICS" ]; then
  echo "zc-dashboard FAIL: missing $METRICS" >&2
  exit 1
fi

TODAY="$(zcd_current_date)"
FAILS=0
zcd_print_dashboard_header

while IFS=$'\t' read -r metric_id layer src case_id field cap rule notes; do
  [ -z "${metric_id:-}" ] && continue
  case "$metric_id" in \#*) continue ;; esac
  IFS='|' read -r value cap_out status <<< "$(zcd_collect_metric "$layer" "$src" "$case_id" "$field" "$cap" "$rule")"
  cap_disp="${cap_out:--}"
  [ "$cap_disp" = "-" ] && cap_disp="$cap"
  trend="$(zcd_sparkline "$metric_id" "$HISTORY")"
  zcd_print_dashboard_row "$metric_id" "$value" "$cap_disp" "$status" "$trend"
  zcd_report_emit "$metric_id" "$value" "$cap_disp" "$status" "$trend"
  if [ "$RECORD" -eq 1 ]; then
    zcd_append_daily "$TODAY" "$metric_id" "$value" "$status" "$notes" "$HISTORY"
  fi
  case "$status" in
    warn) FAILS=$((FAILS + 1)) ;;
    pass|green|skip) ;;
  esac
done < "$METRICS"

if [ "$RECORD" -eq 1 ]; then
  echo "zc-dashboard: recorded ${TODAY} -> ${HISTORY}" >&2
fi

if [ "$FAILS" -gt 0 ]; then
  echo "zc-dashboard FAIL: ${FAILS} metric(s) warn" >&2
  exit 1
fi
echo "zc-dashboard OK (days=$(zcd_history_days "$HISTORY"))"
