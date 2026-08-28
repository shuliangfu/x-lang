#!/usr/bin/env bash
# std-url.sh — STD-076 std.url helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_url_symbols_ok MOD_X URL_X TSV [DOC]
#   std_url_host_c_obs SMOKE_C
#   std_url_run_smoke XLANG SRC [TAG]
#   std_url_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_URL_PREFIX="${XLANG_STD_URL_PREFIX:-xlang: [XLANG_STD_URL]}"

# Validate manifest api/symbol/file/smoke/script/section/vectors anchors.
# Echo miss count; return 0 when miss=0.
# Optional DOC overrides archive path for section checks (default archived RFC).
std_url_symbols_ok() {
  local mod_x="$1"
  local url_x="$2"
  local tsv="$3"
  local doc="${4:-analysis/archive/std/std-url-v1.md}"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-url FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/url/url_glue.c|std/url/url.c|std/url/url.x) path="$url_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-url FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors)
        if [ ! -f "$anchor" ]; then
          echo "std-url FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script|gate)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-url FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-url FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Host-C archaeology: prebuilt url.o only.
# Refuse soft xlang_compiler_make / soft ensure_std_c_o.
# C harness tests/std-url/url_smoke_ok.c calls url_smoke_c.
# Do not invent a second url ABI; do not rebuild missing objects;
# do not expand companions to fake a C pass (old gate intended set = url.o).
# Returns 0 C smoke linked+ran on existing objects, 1 link/run fail, 2 missing prebuilt.
# PLATFORM: SHARED — do not toggle set -e (leaks make return 1 kill the gate).
std_url_host_c_obs() {
  local smoke_c="${1:-tests/std-url/url_smoke_ok.c}"
  local url_o="std/url/url.o"
  if [ ! -f "$url_o" ]; then
    echo "std-url OBS host-C (missing prebuilt $url_o; refuse soft auto-make)" >&2
    return 2
  fi
  if [ ! -f "$smoke_c" ]; then
    echo "std-url OBS host-C (missing $smoke_c)" >&2
    return 2
  fi
  local out="/tmp/xlang_url_smoke_$$"
  local log="/tmp/xlang_url_smoke_link_$$.err"
  if ! cc -std=c11 -O1 -o "$out" "$smoke_c" "$url_o" 2>"$log"; then
    echo "std-url OBS host-C link (existing .o only; refuse soft auto-make)" >&2
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
    echo "std-url OBS host-C run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Product -o smoke. Return 0 exit0, 1 compile/run fail.
# Do not restore set -e before return 1.
std_url_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-url}"
  local exe="/tmp/xlang_std_url_${tag}_$$"
  local log="/tmp/xlang_std_url_${tag}_build_$$.log"
  if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
    echo "std-url FAIL: compile $src" >&2
    tail -n 12 "$log" >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-url FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; check residual = obs).
std_url_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_URL_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
