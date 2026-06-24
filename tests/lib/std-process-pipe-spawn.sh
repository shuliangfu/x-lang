#!/usr/bin/env bash
# std-process-pipe-spawn.sh — STD-023/024 manifest 与 typeck 辅助
#
# 用法（source 后）：
#   std_pps_symbols_ok PROC_SX TSV
#   std_pps_emit_report status pipe_ok win_ok skip

STD_PPS_PREFIX="${SHUX_STD_PROCESS_PIPE_SPAWN_PREFIX:-shux: [SHUX_STD_PROCESS_PIPE_SPAWN]}"

# 校验 manifest symbol/file；echo 缺失数，成功返回 0。
std_pps_symbols_ok() {
  local proc_sx="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$proc_sx" 2>/dev/null; then
          echo "std-process-pipe-spawn FAIL: missing '$anchor' in $proc_sx" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$anchor" ]; then
          echo "std-process-pipe-spawn FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_pps_emit_report() {
  local status="$1"
  local pipe_ok="$2"
  local win_ok="$3"
  local skip="$4"
  echo "${STD_PPS_PREFIX} status=${status} pipe=${pipe_ok} win=${win_ok} skip=${skip}"
}
