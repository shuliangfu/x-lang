#!/usr/bin/env bash
# OBS-004：性能回归告警烟测 runner（不跑 bench，仅 emit 样例行）
#
# 用法：
#   ./tests/run-obs-perf-regression-alert.sh --smoke
set -e
cd "$(dirname "$0")/.."

MANIFEST="${SHU_OBS_PERF_ALERT_TSV:-tests/baseline/obs-perf-regression-alert.tsv}"
REG="${SHU_PERF_BASELINE_REGISTRY:-tests/baseline/perf-baseline-registry.tsv}"
MODE="${1:-}"

# shellcheck source=tests/lib/obs-perf-regression-alert.sh
. tests/lib/obs-perf-regression-alert.sh
# shellcheck source=tests/lib/perf-baseline-governance.sh
. tests/lib/perf-baseline-governance.sh

if [ "$MODE" != "--smoke" ]; then
  echo "run-obs-perf-regression-alert: use --smoke (v1)" >&2
  exit 2
fi

if [ ! -f "$MANIFEST" ]; then
  echo "run-obs-perf-regression-alert FAIL: missing $MANIFEST" >&2
  exit 1
fi

N=0
while IFS=$'\t' read -r item_id kind baseline_id fail_env gate _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$kind" in
    regression_alert)
      path=$(perf_baseline_registry_get "$baseline_id" 2) || true
      if [ -z "$path" ] || [ ! -f "$path" ]; then
        echo "run-obs-perf-regression-alert FAIL: registry missing $baseline_id" >&2
        exit 1
      fi
      obs_perf_alert_emit "$baseline_id" "smoke_metric" "9.999" "1.000" "$gate" "warn"
      N=$((N + 1))
      ;;
  esac
done < "$MANIFEST"

if [ "$N" -lt 1 ]; then
  echo "run-obs-perf-regression-alert FAIL: no alerts emitted" >&2
  exit 1
fi
echo "obs-perf-regression-alert smoke OK (alerts=${N})"
