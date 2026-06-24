#!/usr/bin/env bash
# no-handwritten-c-audit.sh — F-09 手写 C 存量审计（std/core + compiler/src）。
#
# 用法（source）：
#   . tests/lib/no-handwritten-c-audit.sh
#   nhc_collect_scope_c | nhc_audit_whitelist tests/baseline/no-handwritten-c-whitelist.tsv

# 收集 F-09 审计范围内的全部 .c（相对仓库根路径，LC_ALL=C 排序）。
nhc_collect_scope_c() {
  {
    find std core -type f -name '*.c' 2>/dev/null
    find compiler/src -type f -name '*.c' 2>/dev/null
  } | LC_ALL=C sort -u
}

# 统计各 scope 下 .c 数量。
nhc_count_scope_c() {
  local std_n core_n comp_n total
  std_n=$(find std -type f -name '*.c' 2>/dev/null | wc -l | tr -d ' ')
  core_n=$(find core -type f -name '*.c' 2>/dev/null | wc -l | tr -d ' ')
  comp_n=$(find compiler/src -type f -name '*.c' 2>/dev/null | wc -l | tr -d ' ')
  total=$((std_n + core_n + comp_n))
  printf 'summary_std_c\t%s\n' "$std_n"
  printf 'summary_core_c\t%s\n' "$core_n"
  printf 'summary_compiler_src_c\t%s\n' "$comp_n"
  printf 'summary_total_c\t%s\n' "$total"
}

# 写入完整快照 TSV（含 summary 行与 file 行）。
nhc_write_snapshot_tsv() {
  local out="$1"
  {
    echo "# F-09 no-handwritten-C whitelist (终局目标：summary_total_c=0)"
    echo "# scope: std/**/*.c + core/**/*.c + compiler/src/**/*.c"
    echo "# 更新：SHUX_NO_HANDWRITTEN_C_UPDATE=1 ./tests/run-no-handwritten-c-gate.sh"
    nhc_count_scope_c
    nhc_collect_scope_c | while IFS= read -r p; do
      [ -n "$p" ] && printf 'file\t%s\n' "$p"
    done
  } >"$out"
}

# 对比当前磁盘与 baseline；返回 0=OK，1=有新增未登记 .c，2=baseline 缺失。
# 环境：NHC_AUDIT_STRICT=1 时 whitelist 非空也视为失败（终局零 C 模式）。
nhc_audit_whitelist() {
  local baseline="${1:-tests/baseline/no-handwritten-c-whitelist.tsv}"
  local strict="${NHC_AUDIT_STRICT:-0}"
  local tmp cur total base_total new_n=0

  if [ ! -f "$baseline" ]; then
    echo "nhc-audit: missing baseline $baseline" >&2
    return 2
  fi

  tmp="/tmp/shux_nhc_audit.$$.tsv"
  nhc_write_snapshot_tsv "$tmp"
  cur="/tmp/shux_nhc_cur.$$.lst"
  nhc_collect_scope_c >"$cur"

  total=$(awk -F'\t' '$1=="summary_total_c" { print $2; exit }' "$tmp")
  base_total=$(awk -F'\t' '$1=="summary_total_c" { print $2; exit }' "$baseline")
  base_total=${base_total:-999999}

  # 新增：当前存在但 baseline 未登记
  new_n=$(comm -23 "$cur" <(awk -F'\t' '$1=="file" { print $2 }' "$baseline" | LC_ALL=C sort) | wc -l | tr -d ' ')
  if [ "$new_n" -gt 0 ] 2>/dev/null; then
    echo "nhc-audit FAIL: ${new_n} new .c not in whitelist (stage F requires .sx migration):" >&2
    comm -23 "$cur" <(awk -F'\t' '$1=="file" { print $2 }' "$baseline" | LC_ALL=C sort) | head -20 >&2
    rm -f "$tmp" "$cur"
    return 1
  fi

  removed_n=$(comm -13 "$cur" <(awk -F'\t' '$1=="file" { print $2 }' "$baseline" | LC_ALL=C sort) | wc -l | tr -d ' ')
  if [ "$removed_n" -gt 0 ] 2>/dev/null; then
    echo "nhc-audit OK (${total} .c in scope; ${removed_n} removed vs baseline — run SHUX_NO_HANDWRITTEN_C_UPDATE=1 to refresh)"
  elif [ "$total" -lt "$base_total" ] 2>/dev/null; then
    echo "nhc-audit OK (total=${total} < baseline ${base_total}; run SHUX_NO_HANDWRITTEN_C_UPDATE=1 to refresh)"
  else
    echo "nhc-audit OK (std+core+compiler/src total=${total}; baseline ${base_total})"
  fi

  if [ "$strict" = "1" ] && [ "$total" -gt 0 ] 2>/dev/null; then
    echo "nhc-audit STRICT FAIL: ${total} handwritten .c remain (F-09终局要求 0)" >&2
    rm -f "$tmp" "$cur"
    return 1
  fi

  rm -f "$tmp" "$cur"
  return 0
}
