#!/usr/bin/env bash
# std-compress-unified-stream.sh — STD-122 unified stream helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_compress_unified_symbols_ok MOD_X TSV
#   std_compress_unified_run_smoke XLANG_BIN SRC [TAG]
#   std_compress_unified_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_COMPRESS_UNIFIED_PREFIX="${XLANG_STD122_COMPRESS_UNIFIED_PREFIX:-xlang: [XLANG_STD122_COMPRESS_UNIFIED]}"

# Validate manifest; echo miss count; return 0 iff miss==0.
std_compress_unified_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-compress-unified-stream FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        local doc="${XLANG_STD122_COMPRESS_UNIFIED_DOC:-analysis/archive/std/std-compress-unified-stream-v1.md}"
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-compress-unified-stream FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-compress-unified-stream FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-compress-unified-stream FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Product tip -o smoke. Caller decides hard vs obs (tip UNDEF/SEGV = obs leave).
# PLATFORM: SHARED archaeology — product honesty path.
# Do not restore set -e between steps: return 1 must not trip the gate's set +e window.
std_compress_unified_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_compress_unified_${tag}_$$"
  local log="/tmp/xlang_std_compress_unified_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-compress-unified-stream FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-compress-unified-stream OBS tip product -o (ec=$o_ec)" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-compress-unified-stream OBS tip run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired stream=).
std_compress_unified_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_COMPRESS_UNIFIED_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
