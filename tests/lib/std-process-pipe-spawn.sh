#!/usr/bin/env bash
# std-process-pipe-spawn.sh — STD-023/024 manifest helpers (honesty soft→硬绿).
#
# Usage (source):
#   std_pps_symbols_ok PROC_X TSV
#   std_pps_emit_report status run obs skip
# PLATFORM: SHARED archaeology.

STD_PPS_PREFIX="${XLANG_STD_PROCESS_PIPE_SPAWN_PREFIX:-xlang: [XLANG_STD_PROCESS_PIPE_SPAWN]}"

# Validate manifest symbol/file anchors; echo miss count; return 0 on clean.
std_pps_symbols_ok() {
  local proc_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$proc_x" 2>/dev/null; then
          echo "std-process-pipe-spawn FAIL: missing '$anchor' in $proc_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$anchor" ]; then
          echo "std-process-pipe-spawn FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report: run=/obs=/skip= (honesty 2026-08-28).
std_pps_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_PPS_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
