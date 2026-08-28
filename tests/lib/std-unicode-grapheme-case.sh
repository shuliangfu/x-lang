#!/usr/bin/env bash
# std-unicode-grapheme-case.sh — STD-114 grapheme/case-fold helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_unicode_gc_symbols_ok MOD_X UNI_IMPL TSV
#   std_unicode_gc_run_c_smoke          # prebuilt unicode.o only
#   std_unicode_gc_run_smoke XLANG_BIN SRC [TAG]
#   std_unicode_gc_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_UNICODE_GC_PREFIX="${XLANG_STD114_UNICODE_GC_PREFIX:-xlang: [XLANG_STD114_UNICODE_GC]}"

# Validate manifest; echo miss count; return 0 iff miss==0.
std_unicode_gc_symbols_ok() {
  local mod_x="$1"
  local uni_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-unicode-grapheme-case FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/unicode/unicode.x) mod_path="$uni_c" ;;
          std/unicode/mod.x) mod_path="$mod_x" ;;
        esac
        if [ ! -f "$mod_path" ] || ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-unicode-grapheme-case FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        local doc="${XLANG_STD114_DOC:-analysis/archive/std/std-unicode-grapheme-case-v1.md}"
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-unicode-grapheme-case FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-unicode-grapheme-case FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-unicode-grapheme-case FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Host-C archaeology: prebuilt std/unicode/unicode.o only.
# Refuse soft xlang_compiler_make / soft ensure_std_c_o.
# Returns 0 green, 1 link/run fail, 2 missing prebuilt.
# PLATFORM: SHARED — do not toggle set -e (leaks make return 1 kill the gate).
std_unicode_gc_run_c_smoke() {
  local uni_o="std/unicode/unicode.o"
  local out="/tmp/xlang_std_unicode_gc_c_$$"
  if [ ! -f "$uni_o" ]; then
    echo "std-unicode-grapheme-case OBS c smoke (missing prebuilt $uni_o; refuse soft auto-make)" >&2
    return 2
  fi
  if ! cc -std=c11 -O1 -o "$out" "$uni_o" -x c - <<'EOF' 2>/tmp/std_unicode_gc_c_$$.log; then
#include <stdint.h>
extern int32_t grapheme_case_smoke(void);
int main(void){ return grapheme_case_smoke()!=0; }
EOF
    echo "std-unicode-grapheme-case OBS c smoke link (refuse soft ensure)" >&2
    return 1
  fi
  # Do not restore set -e here: return 1 must not trip the gate's set +e window.
  # PLATFORM: SHARED — SEGV/exit≠0 is obs, not soft die.
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-unicode-grapheme-case OBS c smoke run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Product tip -o smoke. Caller decides hard vs obs (tip UNDEF/SEGV = obs leave).
# PLATFORM: SHARED archaeology — product honesty path.
# Do not restore set -e between steps: return 1 must not trip the gate's set +e window.
std_unicode_gc_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_unicode_gc_${tag}_$$"
  local log="/tmp/xlang_std_unicode_gc_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-unicode-grapheme-case FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-unicode-grapheme-case OBS tip product -o $src (ec=$o_ec)" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-unicode-grapheme-case OBS tip run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired c=/x=).
std_unicode_gc_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_UNICODE_GC_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
