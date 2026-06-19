#!/usr/bin/env bash
# std-error-map.sh — STD-020：错误码映射与 last_error manifest 辅助
#
# 用法（source 后）：
#   std_error_map_manifest_ok ERR_MOD TSV
#   std_error_map_emit_report status check_ok run_ok skip

STD_ERROR_MAP_PREFIX="${SHUX_STD_ERROR_MAP_PREFIX:-shux: [SHUX_STD_ERROR_MAP]}"

# 校验 manifest：lookup 符号、模块 src、侧车函数；echo 缺失数。
std_error_map_manifest_ok() {
  local err_mod="$1"
  local tsv="$2"
  local miss=0
  local mod_n=0
  local min_mod=8
  local item_id kind anchor mod_path src _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path src _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in
      \#*) continue ;;
      min_modules)
        if [ -n "${anchor:-}" ]; then
          min_mod="$anchor"
        fi
        continue
        ;;
    esac
    case "$kind" in
      symbol)
        if ! grep -qE "function ${anchor}\\(" "$err_mod" 2>/dev/null; then
          echo "std-error-map FAIL: missing symbol ${anchor} in $err_mod" >&2
          miss=$((miss + 1))
        fi
        ;;
      module)
        mod_n=$((mod_n + 1))
        if [ ! -f "$src" ]; then
          echo "std-error-map FAIL: missing module src $src ($anchor)" >&2
          miss=$((miss + 1))
        fi
        if [ "$mod_path" != "-" ] && ! grep -qE "function ${mod_path}\\(" "$err_mod" 2>/dev/null; then
          echo "std-error-map FAIL: missing base ${mod_path} for $anchor" >&2
          miss=$((miss + 1))
        fi
        ;;
      sidecar)
        if [ ! -f "$src" ]; then
          echo "std-error-map FAIL: missing sidecar src $src" >&2
          miss=$((miss + 1))
        elif ! grep -qE "function ${anchor}\\(" "$src" 2>/dev/null; then
          echo "std-error-map FAIL: missing sidecar ${anchor} in $src" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  if [ "$mod_n" -lt "$min_mod" ]; then
    echo "std-error-map FAIL: modules=${mod_n} < min ${min_mod}" >&2
    miss=$((miss + 1))
  fi
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_error_map_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_ERROR_MAP_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
