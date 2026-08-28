#!/usr/bin/env bash
# std-context-cookbook.sh — STD-156: std.context cookbook manifest helpers.
#
# Usage (after source):
#   std_context_cookbook_symbols_ok MOD_X TSV
#   std_context_cookbook_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_CTX_CB_PREFIX="${XLANG_STD_CTX_CB_PREFIX:-xlang: [XLANG_STD_CONTEXT_COOKBOOK]}"

# Validate manifest symbol/recipe/file/cross_ref anchors against mod.x.
# Echo miss count; return 0 when miss=0.
std_context_cookbook_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor path
  while IFS=$'\t' read -r item_id kind anchor path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-context-cookbook FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      recipe|file)
        if [ ! -f "$anchor" ]; then
          echo "std-context-cookbook FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$anchor" ]; then
          echo "std-context-cookbook FAIL: missing cross_ref '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=; check residual = obs).
std_context_cookbook_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_CTX_CB_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
