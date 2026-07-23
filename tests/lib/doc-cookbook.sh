#!/usr/bin/env bash
# doc-cookbook.sh — DOC-001 共享：Cookbook 食谱 typeck 校验
#
# 用法（source 后）：
#   doc_cb_check_recipe XLANG_BIN path/to/recipe.x

# 对单个 .x 食谱跑 xlang check；失败返回 1。
doc_cb_check_recipe() {
  local xlang="$1"
  local src="$2"
  if [ ! -f "$src" ]; then
    return 1
  fi
  if "$xlang" check -L . "$src" >/dev/null 2>&1; then
    return 0
  fi
  "$xlang" check -L . "$src" 2>&1 | tail -5 >&2 || true
  return 1
}
