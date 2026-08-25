#!/usr/bin/env bash
# std-config.sh — STD-086 manifest 与烟测辅助

STD_CONFIG_PREFIX="${XLANG_STD_CONFIG_PREFIX:-xlang: [XLANG_STD_CONFIG]}"

# 遍历 manifest 校验 symbol/file/smoke。
std_config_symbols_ok() {
  local mod_x="$1"
  local cfg_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-config FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/config/config_glue.c" ]; then path="$cfg_x"; fi
        if [ "$path" = "std/config/config.x" ]; then path="$cfg_x"; fi
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

# 编译并运行 .x 烟测。
std_config_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-config}"
  local exe="/tmp/xlang_std_config_${tag}_$$"
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-config FAIL: compile $src" >&2
    "$xlang" -L . "$src" 2>&1 | tail -12 >&2 || true
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

# Structured report line (check observational; run hard; skip only when no binary).
# PLATFORM: SHARED archaeology — gate path no longer hard-fails on c_smoke / check.
std_config_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_CONFIG_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
