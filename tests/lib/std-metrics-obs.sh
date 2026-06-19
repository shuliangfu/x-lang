#!/usr/bin/env bash
# std-metrics-obs.sh — STD-117 manifest 与烟测辅助

STD_METRICS_OBS_PREFIX="${SHUX_STD117_METRICS_OBS_PREFIX:-shux: [SHUX_STD117_METRICS_OBS]}"

# 校验 manifest 中 api/file/smoke 符号。
std_metrics_obs_symbols_ok() {
  local mod_su="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null || miss=$((miss + 1))
        ;;
      file|smoke|vectors)
        [ -f "$anchor" ] || miss=$((miss + 1))
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .sx 烟测；失败时打印编译日志尾部。
std_metrics_obs_run_sx_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_metrics_obs_$$"
  local log="/tmp/shux_std_metrics_obs_compile_$$.log"
  if ! "$shux" -L . "$src" -o "$exe" >"$log" 2>&1; then
    tail -12 "$log" >&2 || true
    rm -f "$log" "$exe"
    return 1
  fi
  rm -f "$log"
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

std_metrics_obs_emit_report() {
  echo "${STD_METRICS_OBS_PREFIX} status=$1 su=$2 skip=$3"
}
