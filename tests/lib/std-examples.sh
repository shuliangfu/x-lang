#!/usr/bin/env bash
# std-examples.sh — STD-012 共享：示例目录校验与 typeck
#
# 用法（source 后）：
#   std_ex_catalog_count [catalog_tsv]
#   std_ex_validate_paths [catalog_tsv]
#   std_ex_check_example SHU_BIN path

# 统计 catalog 中示例行数（不含注释）。
std_ex_catalog_count() {
  local cat="${1:-tests/baseline/std-examples-catalog.tsv}"
  awk -F'\t' '$1 !~ /^#/ && NF >= 3 { n++ } END { print n+0 }' "$cat"
}

# 校验 catalog 中每个 path 文件存在；失败返回 1。
std_ex_validate_paths() {
  local cat="${1:-tests/baseline/std-examples-catalog.tsv}"
  local miss=0
  while IFS=$'\t' read -r eid _cat path _tier _notes; do
    [ -z "${eid:-}" ] && continue
    case "$eid" in \#*) continue ;; esac
    if [ ! -f "$path" ]; then
      echo "std-examples FAIL: missing $path ($eid)" >&2
      miss=$((miss + 1))
    fi
  done < "$cat"
  [ "$miss" -eq 0 ]
}

# 对单个示例跑 shu check；失败返回 1。
std_ex_check_example() {
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

# 按 category 打印 catalog 摘要（stdout）。
std_ex_print_index() {
  local cat="${1:-tests/baseline/std-examples-catalog.tsv}"
  printf '\n| id | category | path | tier |\n'
  printf '|----|----------|------|------|\n'
  while IFS=$'\t' read -r eid category path tier _notes; do
    [ -z "${eid:-}" ] && continue
    case "$eid" in \#*) continue ;; esac
    printf '| %s | %s | %s | %s |\n' "$eid" "$category" "$path" "$tier"
  done < "$cat"
  printf '\n'
}
