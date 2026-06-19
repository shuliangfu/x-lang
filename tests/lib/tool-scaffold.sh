#!/usr/bin/env bash
# tool-scaffold.sh — TOOL-006 共享：项目模板脚手架辅助
#
# 用法（source 后）：
#   tool_scaffold_copy_to DEST
#   tool_scaffold_rule_count [manifest]
#   tool_scaffold_template_files TEMPLATE_DIR

# 将官方 hello 模板复制到 DEST（须不存在或为空目录由调用方保证）。
tool_scaffold_copy_to() {
  local dest="$1"
  local root
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  local tpl="$root/tests/templates/project-hello"
  if [ ! -f "$tpl/main.sx" ]; then
    echo "tool-scaffold FAIL: missing $tpl/main.sx" >&2
    return 1
  fi
  mkdir -p "$dest"
  cp -R "$tpl"/. "$dest"/
  return 0
}

# 统计 manifest rules 行数。
tool_scaffold_rule_count() {
  local man="${1:-tests/baseline/tool-project-scaffold.tsv}"
  awk -F'\t' '$2=="rules" && $1 !~ /^#/ { n++ } END { print n+0 }' "$man"
}

# 统计模板目录内文件数（不含 .）。
tool_scaffold_template_files() {
  local dir="${1:-tests/templates/project-hello}"
  find "$dir" -maxdepth 1 -type f | wc -l | tr -d ' \n'
}
