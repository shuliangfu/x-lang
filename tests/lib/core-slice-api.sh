#!/usr/bin/env bash
# core-slice-api.sh — CORE-004：切片 subslice/split_at/chunks manifest 辅助
#
# 用法（source 后）：
#   core_slice_symbols_ok SLICE_SX TSV
#   core_slice_emit_report status check_ok run_ok skip

CORE_SLICE_PREFIX="${SHUX_CORE_SLICE_PREFIX:-shux: [SHUX_CORE_SLICE_API]}"

# 校验 manifest 中 symbol 锚点；echo 缺失数，成功返回 0。
core_slice_symbols_ok() {
  local slice_sx="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$slice_sx" 2>/dev/null; then
          echo "core-slice-api FAIL: missing '$anchor' in $slice_sx" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
core_slice_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${CORE_SLICE_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
