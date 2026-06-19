#!/usr/bin/env bash
# std-error-semantics.sh — STD-158 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_error_semantics_symbols_ok ERR_MOD TSV
#   std_error_semantics_emit_report status check_ok run_ok skip

STD_ERR_SEM_PREFIX="${SHUX_STD_ERR_SEM_PREFIX:-shux: [SHUX_STD_ERROR_SEMANTICS]}"

# 校验 manifest symbol；echo 缺失数。
std_error_semantics_symbols_ok() {
  local err_mod="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor path
  while IFS=$'\t' read -r item_id kind anchor path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        if ! grep -qE "function ${anchor}\\(" "$err_mod" 2>/dev/null; then
          echo "std-error-semantics FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|run|recipe)
        if [ ! -f "$anchor" ]; then
          echo "std-error-semantics FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_error_semantics_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_ERR_SEM_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
