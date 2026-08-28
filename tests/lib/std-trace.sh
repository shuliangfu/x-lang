#!/usr/bin/env bash
# std-trace.sh — STD-088 manifest helpers (F-trace v2: pure trace.x).
#
# Usage (after source):
#   std_trace_symbols_ok MOD_X TRACE_X TSV
#   std_trace_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash.
# Honesty: refuse soft auto-make / soft SKIP→OK; report run=/obs=/skip=.

STD_TRACE_PREFIX="${XLANG_STD_TRACE_PREFIX:-xlang: [XLANG_STD_TRACE]}"

# Validate manifest api/symbol/file anchors. Echo miss count; return 0 when miss=0.
std_trace_symbols_ok() {
  local mod_x="$1"
  local trace_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-trace FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/trace/trace.c|std/trace/trace.x|std/trace/trace_span_glue.c) path="$trace_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-trace FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if [ ! -f "$mod_path" ] || ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-trace FAIL: missing section '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors|script)
        if [ ! -f "$anchor" ]; then
          echo "std-trace FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=; retired c_smoke=/x=).
std_trace_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_TRACE_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
