#!/usr/bin/env bash
# std-heap-trace.sh — STD-017: heap XLANG_HEAP_TRACE manifest helpers.
#
# Usage (after source):
#   std_heap_trace_symbols_ok HEAP_X HEAP_LIBC TSV
#   std_heap_trace_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_HEAP_TRACE_PREFIX="${XLANG_STD_HEAP_TRACE_PREFIX:-xlang: [XLANG_STD_HEAP_TRACE]}"

# Validate manifest symbol anchors; echo miss count; return 0 when miss=0.
std_heap_trace_symbols_ok() {
  local heap_x="$1"
  local heap_libc="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        local target="$heap_x"
        case "$mod_path" in
          std/heap/libc.x) target="$heap_libc" ;;
          std/heap/heap.c) target="$heap_libc" ;;
        esac
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "std-heap-trace FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=; check residual = obs).
std_heap_trace_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_HEAP_TRACE_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
