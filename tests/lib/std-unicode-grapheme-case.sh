#!/usr/bin/env bash
# std-unicode-grapheme-case.sh — STD-114 manifest 与烟测辅助

STD_UNICODE_GC_PREFIX="${SHUX_STD114_UNICODE_GC_PREFIX:-shux: [SHUX_STD114_UNICODE_GC]}"

std_unicode_gc_symbols_ok() {
  local mod_sx="$1"
  local uni_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _rest; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        grep -qE "function ${anchor}\\(" "$mod_sx" || miss=$((miss + 1))
        ;;
      symbol)
        grep -qF "$anchor" "$uni_c" || miss=$((miss + 1))
        ;;
      smoke)
        [ -f "$anchor" ] || miss=$((miss + 1))
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_unicode_gc_run_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_unicode_gc_$$"
  "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1 || return 1
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

std_unicode_gc_emit_report() {
  echo "${STD_UNICODE_GC_PREFIX} status=$1 c=$2 sx=$3 skip=$4"
}
