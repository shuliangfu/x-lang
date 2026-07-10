#!/usr/bin/env bash
# std-env-iter.sh — STD-025：env_iter manifest 辅助
#
# 用法（source 后）：
#   std_env_iter_symbols_ok ENV_X ENV_C TSV
#   std_env_iter_emit_report status check_ok run_ok skip

STD_ENV_ITER_PREFIX="${SHUX_STD_ENV_ITER_PREFIX:-shux: [SHUX_STD_ENV_ITER]}"

# 校验 manifest symbol 锚点；echo 缺失数。
std_env_iter_symbols_ok() {
  local mod_x="$1"
  local env_impl="$2"
  local env_glue="$3"
  local tsv="$4"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*) continue ;; esac
    case "$kind" in
      symbol)
        local target="$mod_x"
        case "$mod_path" in
          std/env/env.c|std/env/env.x) target="$env_impl" ;;
          std/env/env_os_glue.c|compiler/seeds/runtime_env_os.from_x.c) target="$env_glue" ;;
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
