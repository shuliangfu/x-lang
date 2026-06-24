#!/usr/bin/env bash
# std-fmt-multi.sh — STD-019：format_2/3 manifest 辅助
#
# 用法（source 后）：
#   std_fmt_multi_symbols_ok FMT_SX TSV
#   std_fmt_multi_emit_report status check_ok run_ok skip

STD_FMT_MULTI_PREFIX="${SHUX_STD_FMT_MULTI_PREFIX:-shux: [SHUX_STD_FMT_MULTI]}"

# 校验 manifest symbol/overload 锚点；echo 缺失数。
std_fmt_multi_symbols_ok() {
  local fmt_sx="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$fmt_sx" 2>/dev/null; then
          echo "std-fmt-multi FAIL: missing '$anchor' in $fmt_sx" >&2
          miss=$((miss + 1))
        fi
        ;;
      overload)
        if ! grep -qE "$anchor" "$fmt_sx" 2>/dev/null; then
          echo "std-fmt-multi FAIL: missing overload pattern '$anchor' in $fmt_sx" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_fmt_multi_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_FMT_MULTI_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
