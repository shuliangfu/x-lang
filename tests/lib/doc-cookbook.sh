#!/usr/bin/env bash
# doc-cookbook.sh — DOC-001 共享：Cookbook 食谱 typeck 校验
#
# 用法（source 后）：
#   doc_cb_check_recipe SHU_BIN path/to/recipe.su

# 对单个 .su 食谱跑 shu check；失败返回 1。
doc_cb_check_recipe() {
  local shu="$1"
  local src="$2"
  if [ ! -f "$src" ]; then
    return 1
  fi
  if "$shu" check -L . "$src" >/dev/null 2>&1; then
    return 0
  fi
  "$shu" check -L . "$src" 2>&1 | tail -5 >&2 || true
  return 1
}
