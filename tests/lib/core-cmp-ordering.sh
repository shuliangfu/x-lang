#!/usr/bin/env bash
# core-cmp-ordering.sh — CORE-005：cmp/Ordering manifest 辅助
#
# 用法（source 后）：
#   core_cmp_symbols_ok CMP_X TSV
#   core_cmp_emit_report status check_ok run_ok skip

CORE_CMP_PREFIX="${SHUX_CORE_CMP_PREFIX:-shux: [SHUX_CORE_CMP_ORDERING]}"

# 校验 manifest 中 symbol 锚点；echo 缺失数，成功返回 0。
core_cmp_symbols_ok() {
  local cmp_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$cmp_x" 2>/dev/null; then
          echo "core-cmp-ordering FAIL: missing '$anchor' in $cmp_x" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
core_cmp_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${CORE_CMP_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
