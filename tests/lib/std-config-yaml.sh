#!/usr/bin/env bash
# std-config-yaml.sh — STD-119 manifest helpers (YAML optional backend).
#
# Usage (after source):
#   std_config_yaml_symbols_ok MOD_X CFG_X TSV
#   std_config_yaml_run_c_smoke   # existing .o only; no soft rebuild
#   std_config_yaml_emit_report status run obs skip
# Honesty: run=/obs=/skip= (check/host-C = obs; prefer asm product -o hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_CONFIG_YAML_PREFIX="${XLANG_STD119_CONFIG_YAML_PREFIX:-xlang: [XLANG_STD119_CONFIG_YAML]}"

# Validate manifest api/symbol/file/smoke/vectors anchors.
# Echo miss count; return 0 when miss=0.
std_config_yaml_symbols_ok() {
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
        grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null || miss=$((miss + 1))
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/config/config_glue.c" ]; then path="$cfg_x"; fi
        if [ "$path" = "std/config/config.x" ]; then path="$cfg_x"; fi
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

# Host-C archaeology: yaml_smoke_ok.c + existing .o only.
# Refuse soft ensure_std_c_o / soft auto-make of missing .o (obs path only).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
# Same short-name fs_* + link_abi_getenv surface as STD-086; do NOT also link
# std/process/process.o + runtime_process_os_glue.o (Ubuntu GNU ld multiple def).
std_config_yaml_run_c_smoke() {
  local cfg_o="std/config/config.o"
  local env_o="std/env/env.o"
  local rpav_o="compiler/runtime_process_argv.o"
  local rio_o="compiler/src/runtime_io_abi.o"
  local getenv_o="compiler/runtime_link_abi_user_env.o"
  local renv_o="compiler/runtime_env_os.o"
  local src="tests/std-config/yaml_smoke_ok.c"
  local out="/tmp/xlang_std_config_yaml_c_$$"
  for o in "$cfg_o" "$env_o" "$rpav_o" "$rio_o" "$getenv_o" "$renv_o"; do
    [ -f "$o" ] || return 1
  done
  if ! cc -std=c11 -O1 -o "$out" "$src" \
    "$cfg_o" "$env_o" "$rpav_o" "$rio_o" "$getenv_o" "$renv_o" 2>/dev/null; then
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=).
# Hard-green signal is product -o yaml_smoke.x; check/host-C = obs.
std_config_yaml_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_CONFIG_YAML_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
