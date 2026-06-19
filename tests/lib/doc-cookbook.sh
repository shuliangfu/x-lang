#!/usr/bin/env bash
# doc-cookbook.sh — DOC-001 共享：Cookbook 食谱 typeck 校验
#
# 用法（source 后）：
#   doc_cb_check_recipe SHUX_BIN path/to/recipe.sx

# 对单个 .sx 食谱跑 shux check；失败返回 1。
doc_cb_check_recipe() {
  local shux="$1"
  local src="$2"
  if [ ! -f "$src" ]; then
    return 1
  fi
  if "$shux" check -L . "$src" >/dev/null 2>&1; then
    return 0
  fi
  "$shux" check -L . "$src" 2>&1 | tail -5 >&2 || true
  return 1
}
