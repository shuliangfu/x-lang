#!/usr/bin/env bash
# std-env-iter.sh — STD-025：env_iter manifest 辅助
#
# 用法（source 后）：
#   std_env_iter_symbols_ok ENV_SU ENV_C TSV
#   std_env_iter_emit_report status check_ok run_ok skip

STD_ENV_ITER_PREFIX="${SHU_STD_ENV_ITER_PREFIX:-shu: [SHU_STD_ENV_ITER]}"

# 校验 manifest symbol 锚点；echo 缺失数。
std_env_iter_symbols_ok() {
  local env_su="$1"
  local env_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*) continue ;; esac
    case "$kind" in
      symbol)
        local target="$env_su"
        case "$mod_path" in
          std/env/env.c) target="$env_c" ;;
        esac
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "std-env-iter FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_env_iter_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_ENV_ITER_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
