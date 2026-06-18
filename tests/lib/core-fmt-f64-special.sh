#!/usr/bin/env bash
# core-fmt-f64-special.sh — CORE-011：f64 NaN/Inf/精度 manifest 辅助
#
# 用法（source 后）：
#   core_fmt_f64_special_symbols_ok FMT_SU STD_FMT_SU TSV
#   core_fmt_f64_special_emit_report status check_ok skip

CORE_FMT_F64_SPECIAL_PREFIX="${SHU_CORE_FMT_F64_SPECIAL_PREFIX:-shu: [SHU_CORE_FMT_F64_SPECIAL]}"

# 校验 manifest 中 symbol 锚点；echo 缺失数，成功返回 0。
core_fmt_f64_special_symbols_ok() {
  local fmt_su="$1"
  local std_fmt_su="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        local target="${mod_path:-$fmt_su}"
        if [ "$item_id" = "std_reexport" ]; then
          target="$std_fmt_su"
        elif [ -z "$mod_path" ] || [ "$mod_path" = "core/fmt/mod.su" ]; then
          target="$fmt_su"
        fi
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "core-fmt-f64-special FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
core_fmt_f64_special_emit_report() {
  local status="$1"
  local check_ok="$2"
  local skip="$3"
  echo "${CORE_FMT_F64_SPECIAL_PREFIX} status=${status} check=${check_ok} skip=${skip}"
}
