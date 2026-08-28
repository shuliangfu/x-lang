#!/usr/bin/env bash
# std-cache.sh — STD-087 std.cache helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_cache_symbols_ok MOD_X CACHE_X TSV
#   std_cache_host_c_obs SMOKE_C
#   std_cache_run_smoke XLANG SRC [tag]
#   std_cache_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_CACHE_PREFIX="${XLANG_STD_CACHE_PREFIX:-xlang: [XLANG_STD_CACHE]}"

# Validate manifest; echo miss count; return 0 iff miss==0.
std_cache_symbols_ok() {
  local mod_x="$1"
  local cache_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  local doc="${XLANG_STD_CACHE_DOC:-analysis/archive/std/std-cache-v1.md}"
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-cache FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/cache/cache_glue.c" ]; then path="$cache_x"; fi
        if [ "$path" = "std/cache/cache.x" ]; then path="$cache_x"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-cache FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-cache FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors)
        if [ ! -f "$anchor" ]; then
          echo "std-cache FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-cache FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Host-C archaeology: prebuilt cache.o + time.o + runtime_time_os.o only.
# Refuse soft xlang_compiler_make / soft ensure_std_c_o.
# Returns 0 C smoke linked+ran on existing objects, 1 link/run fail, 2 missing prebuilt.
# PLATFORM: SHARED — do not toggle set -e (leaks make return 1 kill the gate).
std_cache_host_c_obs() {
  local smoke_c="${1:-tests/std-cache/cache_smoke_ok.c}"
  local cache_o="std/cache/cache.o"
  local time_o="std/time/time.o"
  local rt_o="compiler/runtime_time_os.o"
  local o
  for o in "$cache_o" "$time_o" "$rt_o"; do
    if [ ! -f "$o" ]; then
      echo "std-cache OBS host-C (missing prebuilt $o; refuse soft auto-make)" >&2
      return 2
    fi
  done
  if [ ! -f "$smoke_c" ]; then
    echo "std-cache OBS host-C (missing $smoke_c)" >&2
    return 2
  fi
  local out="/tmp/xlang_cache_smoke_$$"
  local log="/tmp/xlang_cache_smoke_link_$$.err"
  if ! cc -std=c11 -O1 -o "$out" "$smoke_c" "$cache_o" "$time_o" "$rt_o" 2>"$log"; then
    echo "std-cache OBS host-C link (existing .o only; refuse soft auto-make)" >&2
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
    echo "std-cache OBS host-C run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Product -o smoke. Return 0 exit0, 1 compile/run fail.
# Do not restore set -e before return 1.
std_cache_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-cache}"
  local exe="/tmp/xlang_std_cache_${tag}_$$"
  local log="/tmp/xlang_std_cache_${tag}_build_$$.log"
  if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
    echo "std-cache FAIL: compile $src" >&2
    tail -n 12 "$log" >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-cache FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; check residual = obs).
std_cache_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_CACHE_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
