#!/usr/bin/env bash
# std-path-extreme.sh — STD-140 manifest helpers (path extreme clean/resolve).
#
# Usage (after source):
#   std_path_extreme_symbols_ok MOD_X TSV
#   std_path_extreme_vectors_ok VECTORS_TSV [MIN_ROWS]
#   std_path_extreme_emit_report status check_ok run_ok skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_PATH_EXTREME_PREFIX="${XLANG_STD140_PATH_EXTREME_PREFIX:-xlang: [XLANG_STD140_PATH_EXTREME]}"

# Validate manifest api/file/smoke/script/section anchors.
# Echo miss count; return 0 when miss=0.
std_path_extreme_symbols_ok() {
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
          echo "std-path-extreme FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|script|section)
        if [ "$kind" = "section" ]; then
          if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
            echo "std-path-extreme FAIL: missing section '$anchor' in $mod_path" >&2
            miss=$((miss + 1))
          fi
        elif [ ! -f "$anchor" ]; then
          echo "std-path-extreme FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Validate vectors TSV has at least min_rows data lines.
std_path_extreme_vectors_ok() {
  local tsv="$1"
  local min_rows="${2:-8}"
  local n=0
  while IFS= read -r _line; do
    case "$_line" in \#*|"") continue ;; esac
    n=$((n + 1))
  done < "$tsv"
  if [ "$n" -lt "$min_rows" ]; then
    echo "std-path-extreme FAIL: vectors $n < min $min_rows" >&2
    return 1
  fi
  return 0
}

# Structured report line (check observational; run hard; skip only when no binary path).
std_path_extreme_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_PATH_EXTREME_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
