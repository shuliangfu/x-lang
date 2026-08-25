#!/usr/bin/env bash
# std-set-ops.sh — STD-129：Set_i32 union/intersect/difference manifest helpers
#
# Usage (after source):
#   std_set_ops_symbols_ok MOD_X TSV
#   std_set_ops_emit_report status check_ok run_ok skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_SET_OPS_PREFIX="${XLANG_STD129_SET_OPS_PREFIX:-xlang: [XLANG_STD129_SET_OPS]}"

# Validate manifest api/smoke/script anchors against product std/set/mod.x.
# Function anchors require `function <name>(` so product surface names
# (union_into / intersect_into / difference_into) match after API rename.
# Echo miss count; return 0 when miss=0.
std_set_ops_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-set-ops FAIL: missing function '${anchor}(' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-set-ops FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report line (check observational; run hard; skip only when no binary path).
std_set_ops_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_SET_OPS_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
