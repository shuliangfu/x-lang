#!/usr/bin/env bash
# std-config.sh — STD-086 manifest 与烟测辅助

STD_CONFIG_PREFIX="${SHUX_STD_CONFIG_PREFIX:-shux: [SHUX_STD_CONFIG]}"

# 遍历 manifest 校验 symbol/file/smoke。
std_config_symbols_ok() {
  local mod_su="$1"
  local cfg_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-config FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/config/config.c" ]; then path="$cfg_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-config FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors)
        if [ ! -f "$anchor" ]; then
          echo "std-config FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .sx 烟测。
std_config_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-config}"
  local exe="/tmp/shux_std_config_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-config FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -12 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-config FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出 gate 报告行。
std_config_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_CONFIG_PREFIX} status=${status} c_smoke=${c_ok} su=${su_ok} skip=${skip}"
}
