#!/usr/bin/env bash
# std-mem-boundary.sh — STD-018：core.mem / std.mem 职责边界校验辅助
#
# 用法（source 后）：
#   std_mem_boundary_symbols_ok CORE_X STD_X TSV
#   std_mem_boundary_forbidden_ok STD_X TSV
#   std_mem_boundary_emit_report status run obs skip
# PLATFORM: SHARED archaeology.

STD_MEM_BOUNDARY_PREFIX="${XLANG_STD_MEM_BOUNDARY_PREFIX:-xlang: [XLANG_STD_MEM_BOUNDARY]}"

# 校验 manifest core_only / std_only 锚点存在于对应 mod.x。
std_mem_boundary_symbols_ok() {
  local core_x="$1"
  local std_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      core_only)
        if ! grep -qF "$anchor" "$core_x" 2>/dev/null; then
          echo "std-mem-boundary FAIL: core missing '$anchor' in $core_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      std_only)
        if ! grep -qF "$anchor" "$std_x" 2>/dev/null; then
          echo "std-mem-boundary FAIL: std missing '$anchor' in $std_x" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# std.mem 不得 import core.mem（禁止双路径）。
std_mem_boundary_forbidden_ok() {
  local std_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ "$kind" = "forbidden" ] || continue
    if grep -qF "$anchor" "$std_x" 2>/dev/null; then
      echo "std-mem-boundary FAIL: forbidden '$anchor' in $std_x" >&2
      miss=$((miss + 1))
    fi
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report: run=/obs=/skip= (honesty 2026-08-28).
std_mem_boundary_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_MEM_BOUNDARY_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
