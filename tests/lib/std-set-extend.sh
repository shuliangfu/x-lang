#!/usr/bin/env bash
# std-set-extend.sh — STD-015：Set_u64/Set_str manifest 辅助
#
# 用法（source 后）：
#   std_set_extend_symbols_ok SET_SX TSV
#   std_set_extend_emit_report status check_ok run_ok skip

STD_SET_EXTEND_PREFIX="${SHUX_STD_SET_EXTEND_PREFIX:-shux: [SHUX_STD_SET_EXTEND]}"

# 校验 manifest symbol 锚点；echo 缺失数，成功返回 0。
std_set_extend_symbols_ok() {
  local set_sx="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$set_sx" 2>/dev/null; then
          echo "std-set-extend FAIL: missing '$anchor' in $set_sx" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_set_extend_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_SET_EXTEND_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
