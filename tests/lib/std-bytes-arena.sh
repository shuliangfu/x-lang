#!/usr/bin/env bash
# std-bytes-arena.sh — STD-155 manifest helpers (bytes ↔ Arena collaboration).
#
# Usage (after source):
#   std_bytes_arena_symbols_ok MOD_X TSV [DOC]
#   std_bytes_arena_emit_report status check_ok run_ok skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD155_PREFIX="${XLANG_STD155_BYTES_ARENA_PREFIX:-xlang: [XLANG_STD155_BYTES_ARENA]}"

# Validate manifest api/symbol/file/smoke/section anchors.
# Echo miss count; return 0 when miss=0.
# Optional DOC overrides archive path for section checks (default archived RFC).
std_bytes_arena_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local doc="${3:-analysis/archive/std/std-bytes-arena-v1.md}"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-bytes-arena FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        if ! grep -qF "$anchor" "$mod_x" 2>/dev/null; then
          echo "std-bytes-arena FAIL: missing '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|script|gate)
        if [ ! -f "$anchor" ]; then
          echo "std-bytes-arena FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-bytes-arena FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report line (check observational; run hard; skip only when no binary path).
std_bytes_arena_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD155_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
