#!/usr/bin/env bash
# std-config-yaml.sh — STD-119 manifest 与烟测辅助

STD_CONFIG_YAML_PREFIX="${SHU_STD119_CONFIG_YAML_PREFIX:-shu: [SHU_STD119_CONFIG_YAML]}"

std_config_yaml_symbols_ok() {
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
        grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null || miss=$((miss + 1))
        ;;
      symbol)
        local path="$mod_path"
        [ "$path" = "std/config/config.c" ] && path="$cfg_c"
        grep -qF "$anchor" "$path" 2>/dev/null || miss=$((miss + 1))
        ;;
      file|smoke|vectors)
        [ -f "$anchor" ] || miss=$((miss + 1))
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_config_yaml_run_su_smoke() {
  local shu="$1"
  local src="$2"
  local exe="/tmp/shu_std_config_yaml_$$"
  "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1 || return 1
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

std_config_yaml_run_c_smoke() {
  local cfg_o="$1"
  local env_o="$2"
  local out="/tmp/shu_std_config_yaml_c_$$"
  cc -std=c11 -O1 -o "$out" tests/std-config/yaml_smoke_ok.c "$cfg_o" "$env_o" 2>/dev/null || return 1
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

std_config_yaml_emit_report() {
  echo "${STD_CONFIG_YAML_PREFIX} status=$1 c=$2 su=$3 skip=$4"
}
