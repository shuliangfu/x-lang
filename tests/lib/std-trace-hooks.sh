#!/usr/bin/env bash
# std-trace-hooks.sh — STD-118 manifest 与烟测辅助

STD_TRACE_HOOKS_PREFIX="${SHU_STD118_TRACE_HOOKS_PREFIX:-shu: [SHU_STD118_TRACE_HOOKS]}"

std_trace_hooks_symbols_ok() {
  local mod_su="$1"
  local trace_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null || miss=$((miss + 1))
        ;;
      symbol)
        local path="$mod_path"
        [ "$path" = "std/trace/trace.c" ] && path="$trace_c"
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

std_trace_hooks_run_su_smoke() {
  local shu="$1"
  local src="$2"
  local exe="/tmp/shu_std_trace_hooks_$$"
  "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1 || return 1
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

std_trace_hooks_run_c_smoke() {
  local trace_o="$1"
  local time_o="$2"
  local random_o="$3"
  local out="/tmp/shu_std_trace_hooks_c_$$"
  cc -std=c11 -O1 -o "$out" tests/std-trace/hooks_smoke_ok.c "$trace_o" "$time_o" "$random_o" 2>/dev/null || return 1
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

std_trace_hooks_emit_report() {
  echo "${STD_TRACE_HOOKS_PREFIX} status=$1 c=$2 su=$3 skip=$4"
}
