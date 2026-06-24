#!/usr/bin/env bash
# std-config-yaml.sh — STD-119 manifest 与烟测辅助

STD_CONFIG_YAML_PREFIX="${SHUX_STD119_CONFIG_YAML_PREFIX:-shux: [SHUX_STD119_CONFIG_YAML]}"

std_config_yaml_symbols_ok() {
  local mod_sx="$1"
  local cfg_sx="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null || miss=$((miss + 1))
        ;;
      symbol)
        local path="$mod_path"
        local path="$mod_path"
        if [ "$path" = "std/config/config_glue.c" ]; then path="$cfg_sx"; fi
        if [ "$path" = "std/config/config.sx" ]; then path="$cfg_sx"; fi
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

std_config_yaml_run_sx_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_config_yaml_$$"
  "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1 || return 1
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
  local proc_o="$3"
  local rpav_o="${4:-$(cd compiler && pwd)/runtime_process_argv.o}"
  local out="/tmp/shux_std_config_yaml_c_$$"
  make -C compiler -q runtime_process_argv.o 2>/dev/null || make -C compiler runtime_process_argv.o 2>/dev/null || true
  cc -std=c11 -O1 -o "$out" tests/std-config/yaml_smoke_ok.c "$cfg_o" "$env_o" "$proc_o" "$rpav_o" 2>/dev/null || return 1
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

std_config_yaml_emit_report() {
  echo "${STD_CONFIG_YAML_PREFIX} status=$1 c=$2 sx=$3 skip=$4"
}
