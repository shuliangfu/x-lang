#!/usr/bin/env bash
# std-regex-atomic.sh — STD-124 manifest 与烟测辅助

STD_REGEX_ATOMIC_PREFIX="${SHUX_STD124_REGEX_ATOMIC_PREFIX:-shux: [SHUX_STD124_REGEX_ATOMIC]}"

std_regex_atomic_symbols_ok() {
  local min_inc="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        grep -qF "$anchor" "$min_inc" 2>/dev/null || miss=$((miss + 1))
        ;;
      file|smoke)
        [ -f "$anchor" ] || miss=$((miss + 1))
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_regex_atomic_run_c_smoke() {
  local regex_c="$1"
  local out="/tmp/shux_std_regex_atomic_c_$$"
  cc -std=c11 -O1 -o "$out" tests/regex/regex_min_ok.c "$regex_c" 2>/dev/null || return 1
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

std_regex_atomic_run_x_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_regex_atomic_x_$$"
  "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1 || return 1
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

std_regex_atomic_emit_report() {
  echo "${STD_REGEX_ATOMIC_PREFIX} status=$1 c=$2 x=$3 skip=$4"
}
