#!/usr/bin/env bash
# std-config.sh — STD-086 std.config helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_config_symbols_ok MOD_X CFG_X TSV [DOC]
#   std_config_host_c_obs SMOKE_C
#   std_config_run_smoke XLANG SRC [TAG]
#   std_config_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_CONFIG_PREFIX="${XLANG_STD_CONFIG_PREFIX:-xlang: [XLANG_STD_CONFIG]}"

# Validate manifest api/symbol/file/smoke/script/section anchors.
# Echo miss count; return 0 when miss=0.
# Optional DOC overrides archive path for section checks (default archived RFC).
std_config_symbols_ok() {
  local mod_x="$1"
  local cfg_x="$2"
  local tsv="$3"
  local doc="${4:-analysis/archive/std/std-config-v1.md}"
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
        if [ "$path" = "std/config/config_glue.c" ] || [ "$path" = "std/config/config.x" ]; then path="$cfg_x"; fi
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
      script|gate)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-config FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-config FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Host-C archaeology: prebuilt config.o + env.o + runtime companions only.
# Refuse soft xlang_compiler_make / soft ensure_std_c_o.
# config.o needs short-name fs_open_read_c/fs_posix_read_c (runtime_io_abi.o
# Track-L) + link_abi_getenv (runtime_link_abi_user_env.o). Do not invent a
# second fs_* ABI. Do NOT also link std/process/process.o +
# runtime_process_os_glue.o together: Ubuntu GNU ld hard-fails on multiple
# definition (Darwin ld was permissive).
# Returns 0 C smoke linked+ran on existing objects, 1 link/run fail, 2 missing prebuilt.
# PLATFORM: SHARED — do not toggle set -e (leaks make return 1 kill the gate).
std_config_host_c_obs() {
  local smoke_c="${1:-tests/std-config/config_smoke_ok.c}"
  local config_o="std/config/config.o"
  local env_o="std/env/env.o"
  local argv_o="compiler/runtime_process_argv.o"
  local env_rt_o="compiler/runtime_env_os.o"
  local io_o="compiler/src/runtime_io_abi.o"
  local getenv_o="compiler/runtime_link_abi_user_env.o"
  local o
  for o in "$config_o" "$env_o" "$argv_o" "$env_rt_o" "$io_o" "$getenv_o"; do
    if [ ! -f "$o" ]; then
      echo "std-config OBS host-C (missing prebuilt $o; refuse soft auto-make)" >&2
      return 2
    fi
  done
  if [ ! -f "$smoke_c" ]; then
    echo "std-config OBS host-C (missing $smoke_c)" >&2
    return 2
  fi
  local out="/tmp/xlang_config_smoke_$$"
  local log="/tmp/xlang_config_smoke_link_$$.err"
  if ! cc -std=c11 -O1 -o "$out" "$smoke_c" "$config_o" "$env_o" \
      "$argv_o" "$env_rt_o" "$io_o" "$getenv_o" 2>"$log"; then
    echo "std-config OBS host-C link (existing .o only; refuse soft auto-make)" >&2
    tail -n 10 "$log" 2>/dev/null || true
    rm -f "$out" "$log"
    return 1
  fi
  # Do not restore set -e here: return 1 must not trip the gate's set +e window.
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-config OBS host-C run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Product -o smoke. Return 0 exit0, 1 compile/run fail.
# Do not restore set -e before return 1.
std_config_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-config}"
  local exe="/tmp/xlang_std_config_${tag}_$$"
  local log="/tmp/xlang_std_config_${tag}_build_$$.log"
  if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
    echo "std-config FAIL: compile $src" >&2
    tail -n 12 "$log" >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-config FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; check residual = obs).
std_config_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_CONFIG_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
