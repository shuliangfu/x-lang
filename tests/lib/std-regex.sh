#!/usr/bin/env bash
# std-regex.sh — STD-051 manifest helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_regex_symbols_ok MOD_X REGEX_X TSV
#   std_regex_run_c_smoke REGEX_X   # prebuilt std/regex/regex.o only
#   std_regex_run_smoke XLANG_BIN SRC TAG
#   std_regex_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_REGEX_PREFIX="${XLANG_STD_REGEX_PREFIX:-xlang: [XLANG_STD_REGEX]}"

# Validate manifest; echo miss count; return 0 iff miss==0.
std_regex_symbols_ok() {
  local mod_x="$1"
  local regex_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-regex FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-regex FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/regex/regex.c|std/regex/regex_engine_glue.c|std/regex/regex_min.inc.c) path="$regex_x" ;;
          std/regex/regex.x) path="$regex_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-regex FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        local doc="${XLANG_STD_REGEX_DOC:-analysis/archive/std/std-regex-v1.md}"
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-regex FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-regex FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$anchor" ]; then
          echo "std-regex FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      bench)
        # Optional perf artifact; missing bench file is not a soft/hard gate residual.
        :
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Product tip -o smoke. Caller decides hard vs obs (tip UNDEF / missing main = obs leave).
# PLATFORM: SHARED archaeology — product honesty path.
std_regex_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_regex_${tag}_$$"
  local log="/tmp/xlang_std_regex_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-regex FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  # Do not restore set -e between steps: return 1 must not trip the gate's set +e window.
  # PLATFORM: SHARED archaeology.
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-regex OBS tip product -o (ec=$o_ec)" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-regex OBS tip run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Host-C archaeology: prebuilt std/regex/regex.o only.
# Refuse soft ensure_std_c_o / soft auto-make. Path is repo-root relative.
# Returns 0 green, 1 link/run fail, 2 missing prebuilt .o.
# PLATFORM: SHARED — do not toggle set -e.
std_regex_run_c_smoke() {
  local _regex_x="$1"
  local src="tests/regex/regex_min_ok.c"
  local out="/tmp/xlang_regex_min_ok_$$"
  local regex_o="std/regex/regex.o"
  if [ ! -f "$regex_o" ]; then
    echo "std-regex OBS c smoke (missing prebuilt $regex_o; refuse soft auto-make)" >&2
    return 2
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$regex_o" 2>/tmp/std_regex_c_$$.log; then
    echo "std-regex OBS c smoke link (refuse soft ensure)" >&2
    return 1
  fi
  # Do not restore set -e here: return 1 must not trip the gate's set +e window.
  # PLATFORM: SHARED — SEGV/exit≠0 is obs, not soft die.
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-regex OBS c smoke run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired c_smoke=/x=/host=).
std_regex_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_REGEX_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
