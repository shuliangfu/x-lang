#!/usr/bin/env bash
# obs-perf-regression-alert.sh — OBS-004 共享：性能回归告警 emit / 行校验
#
# 用法（source 后）：
#   obs_perf_alert_emit baseline_id metric measured cap gate_script [severity]
#   obs_perf_alert_line_valid "$line"

# 是否输出告警（默认开启）。
obs_perf_alert_enabled() {
  case "${SHUX_PERF_ALERT_EMIT:-1}" in
    0|false|FALSE|no|NO) return 1 ;;
    *) return 0 ;;
  esac
}

# 输出一条 SHUX_PERF_ALERT 行到 stderr（OBS-003 bracket 格式）。
obs_perf_alert_emit() {
  local baseline_id="$1"
  local metric="$2"
  local measured="$3"
  local cap="$4"
  local gate="$5"
  local severity="${6:-critical}"
  if ! obs_perf_alert_enabled; then
    return 0
  fi
  printf 'shux: [SHUX_PERF_ALERT] severity=%s baseline_id=%s metric=%s measured=%s cap=%s gate=%s\n' \
    "$severity" "$baseline_id" "$metric" "$measured" "$cap" "$gate" >&2
}

# 校验告警行格式。
obs_perf_alert_line_valid() {
  local line="$1"
  echo "$line" | grep -qE '^shux: \[SHUX_PERF_ALERT\] severity=(critical|warn) baseline_id=[a-z0-9_-]+ metric=[^ ]+ measured=[0-9.]+ cap=[0-9.]+ gate=[^ ]+'
}
