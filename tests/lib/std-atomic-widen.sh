#!/usr/bin/env bash
# std-atomic-widen.sh — STD-146 i16/u16/i64/u64 widen helpers.
#
# Usage (after source):
#   std_atomic_widen_symbols_ok MOD_X ATOMIC_RUNTIME TSV
#   std_atomic_widen_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash.

STD146_PREFIX="${XLANG_STD146_ATOMIC_WIDEN_PREFIX:-xlang: [XLANG_STD146_ATOMIC_WIDEN]}"

# Validate manifest api/symbol/section/smoke anchors. Echo miss count.
# Section paths come from TSV mod_path (archive DOC); refuse fossil top-level DOC.
std_atomic_widen_symbols_ok() {
  local mod_x="$1"
  local atomic_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-atomic-widen FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/atomic/atomic_glue.c" ] || [ "$path" = "compiler/seeds/runtime_atomic_glue.from_x.c" ]; then
          path="$atomic_c"
        fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-atomic-widen FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke|gate|script)
        if [ ! -f "$anchor" ]; then
          echo "std-atomic-widen FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        # Use TSV mod_path (archive); refuse hard-coded top-level DOC dual-authority.
        local doc_path="${mod_path:-analysis/archive/std/std-atomic-widen-v1.md}"
        if ! grep -qF "$anchor" "$doc_path" 2>/dev/null; then
          echo "std-atomic-widen FAIL: missing section '$anchor' in $doc_path" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=; retired exec=).
std_atomic_widen_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD146_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
