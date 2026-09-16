#!/usr/bin/env bash
# std-heap-allocator.sh — STD-112: Allocator / Vec_u8 manifest helpers.
#
# Usage (after source):
#   std_heap_alloc_symbols_ok HEAP_X VEC_X TSV
#   std_heap_alloc_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_HEAP_ALLOC_PREFIX="${XLANG_STD112_HEAP_ALLOC_PREFIX:-xlang: [XLANG_STD112_HEAP_ALLOC]}"

# Validate manifest api/file/smoke anchors against product heap/vec sources.
# Function anchors require `function <name>(` so product surface names
# (with_alloc / push / heap_alloc / …) match after API rename.
# Echo miss count; return 0 when miss=0.
std_heap_alloc_symbols_ok() {
  local heap_x="$1"
  local vec_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        local path="$heap_x"
        if [ "$mod_path" = "std/vec/mod.x" ]; then path="$vec_x"; fi
        if ! grep -qE "function ${anchor}\\(" "$path" 2>/dev/null; then
          echo "std-heap-allocator FAIL: missing function '${anchor}(' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-heap-allocator FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=; check residual = obs).
std_heap_alloc_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_HEAP_ALLOC_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
