#!/usr/bin/env bash
# std-unicode-nfc.sh — STD-037 NFC / non-BMP helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_unicode_nfc_symbols_ok MOD_X UNI_IMPL TSV
#   std_unicode_nfc_run_smoke XLANG_BIN SRC [TAG]
#   std_unicode_nfc_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_UNICODE_NFC_PREFIX="${XLANG_STD_UNICODE_NFC_PREFIX:-xlang: [XLANG_STD_UNICODE_NFC]}"

# Validate manifest; echo miss count; return 0 iff miss==0.
std_unicode_nfc_symbols_ok() {
  local mod_x="$1"
  local unicode_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-unicode-nfc FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/unicode/unicode.x|std/unicode/unicode_glue.c) mod_path="$unicode_c" ;;
          std/unicode/mod.x) mod_path="$mod_x" ;;
        esac
        if [ ! -f "$mod_path" ] || ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-unicode-nfc FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        local doc="${XLANG_STD_UNICODE_NFC_DOC:-analysis/archive/std/std-unicode-nfc-v1.md}"
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-unicode-nfc FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-unicode-nfc FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-unicode-nfc FAIL: missing script '$anchor'" >&2
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
std_unicode_nfc_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_unicode_nfc_${tag}_$$"
  local log="/tmp/xlang_std_unicode_nfc_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-unicode-nfc FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-unicode-nfc OBS tip product -o $src (ec=$o_ec)" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-unicode-nfc OBS tip run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired nfc=/main=).
std_unicode_nfc_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_UNICODE_NFC_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
