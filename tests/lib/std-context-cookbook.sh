#!/usr/bin/env bash
# std-context-cookbook.sh — STD-156 Cookbook manifest 与 runnable 辅助
#
# 用法（source 后）：
#   std_context_cookbook_symbols_ok MOD_SU TSV
#   std_context_cookbook_run_smoke RUN_SHU RECIPE
#   std_context_cookbook_emit_report status run_ok skip

STD_CTX_CB_PREFIX="${SHU_STD_CTX_CB_PREFIX:-shu: [SHU_STD_CONTEXT_COOKBOOK]}"

# 校验 manifest 中 symbol/recipe 锚点；echo 缺失数。
std_context_cookbook_symbols_ok() {
  local mod_su="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor path
  while IFS=$'\t' read -r item_id kind anchor path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-context-cookbook FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      recipe|file)
        if [ ! -f "$anchor" ]; then
          echo "std-context-cookbook FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 Cookbook 食谱；成功返回 0。
std_context_cookbook_run_smoke() {
  local run_shu="$1"
  local recipe="$2"
  local out="/tmp/shu_std_context_cookbook"
  if ! $run_shu -L . "$recipe" -o "$out" 2>/tmp/shu_std_context_cookbook_build.log; then
    echo "std-context-cookbook gate FAIL: link" >&2
    tail -8 /tmp/shu_std_context_cookbook_build.log 2>/dev/null >&2 || true
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne 0 ]; then
    echo "std-context-cookbook gate FAIL: exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_context_cookbook_emit_report() {
  local status="$1"
  local run_ok="$2"
  local skip="$3"
  echo "${STD_CTX_CB_PREFIX} status=${status} run=${run_ok} skip=${skip}"
}
