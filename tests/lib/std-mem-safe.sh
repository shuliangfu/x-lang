#!/usr/bin/env bash
# std-mem-safe.sh — STD-144 manifest / report helpers.
# PLATFORM: SHARED archaeology.
#
# Usage (source then):
#   std_mem_safe_symbols_ok MOD_X TSV DOC
#   std_mem_safe_emit_report status run obs skip

STD_MEM_SAFE_PREFIX="${XLANG_STD144_MEM_SAFE_PREFIX:-xlang: [XLANG_STD144_MEM_SAFE]}"

# Validate manifest api / smoke / gate / script / section anchors.
# @param mod_x path — std/mem/mod.x
# @param tsv path — baseline TSV
# @param doc path — archive DOC (section anchors live here; refuse top-level)
# echo missing count; return 0 iff miss==0.
std_mem_safe_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local doc="${3:-analysis/archive/std/std-mem-safe-v1.md}"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-mem-safe FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke|gate|script)
        if [ ! -f "$anchor" ]; then
          echo "std-mem-safe FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        # Section text lives in archive DOC (mod_path column); never top-level fossil.
        local sec_doc="$doc"
        if [ -n "${mod_path:-}" ] && [ -f "$mod_path" ]; then
          sec_doc="$mod_path"
        fi
        if ! grep -qF "$anchor" "$sec_doc" 2>/dev/null; then
          echo "std-mem-safe FAIL: missing section '$anchor' in $sec_doc" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report: run=/obs=/skip= (honesty 2026-08-28).
std_mem_safe_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_MEM_SAFE_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
