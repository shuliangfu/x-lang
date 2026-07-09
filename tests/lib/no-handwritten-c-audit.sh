#!/usr/bin/env bash
# no-handwritten-c-audit.sh — F-09 手写 C 存量审计（std/core + compiler/src）。
#
# 用法（source）：
#   . tests/lib/no-handwritten-c-audit.sh
#   nhc_collect_scope_c | nhc_audit_whitelist tests/baseline/no-handwritten-c-whitelist.tsv

# 永久 C 桩白名单（语言限制 C glue，STRICT 模式允许保留）
NHC_PERMANENT_STUBS="${NHC_PERMANENT_STUBS:-tests/baseline/no-handwritten-c-permanent.tsv}"

# 收集 F-09 审计范围内的全部 .c（相对仓库根路径，LC_ALL=C 排序）。
# 排除 gitignored 构建产物（pinned _gen.c 等），仅审计 git 跟踪的手写 C。
nhc_collect_scope_c() {
  {
    find std core -type f -name '*.c' 2>/dev/null
    find compiler/src -type f -name '*.c' 2>/dev/null
  } | while IFS= read -r f; do
    git check-ignore "$f" >/dev/null 2>&1 || printf '%s\n' "$f"
  done | LC_ALL=C sort -u
}

# 统计各 scope 下 .c 数量（排除 gitignored 构建产物）。
nhc_count_scope_c() {
  local std_n core_n comp_n total
  std_n=$(find std -type f -name '*.c' 2>/dev/null | while IFS= read -r f; do git check-ignore "$f" >/dev/null 2>&1 || echo "$f"; done | wc -l | tr -d ' ')
  core_n=$(find core -type f -name '*.c' 2>/dev/null | while IFS= read -r f; do git check-ignore "$f" >/dev/null 2>&1 || echo "$f"; done | wc -l | tr -d ' ')
  comp_n=$(find compiler/src -type f -name '*.c' 2>/dev/null | while IFS= read -r f; do git check-ignore "$f" >/dev/null 2>&1 || echo "$f"; done | wc -l | tr -d ' ')
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

# 读取永久 C 桩列表（LC_ALL=C 排序）。
nhc_collect_permanent_stubs() {
  [ -f "$NHC_PERMANENT_STUBS" ] || return 0
  awk -F'\t' '$1=="file" { print $2 }' "$NHC_PERMANENT_STUBS" | LC_ALL=C sort -u
}

# 对比当前磁盘与 baseline；返回 0=OK，1=有新增未登记 .c，2=baseline 缺失。
# 环境：NHC_AUDIT_STRICT=1 时检查非永久桩 .c 是否归零（G-04 终局模式）。
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
    echo "nhc-audit FAIL: ${new_n} new .c not in whitelist (stage F requires .x migration):" >&2
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

  # G-04 STRICT：检查非永久桩 .c 是否归零
  if [ "$strict" = "1" ] && [ "$total" -gt 0 ] 2>/dev/null; then
    local perm_n nonperm_n perm_lst
    perm_lst="/tmp/shux_nhc_perm.$$.lst"
    nhc_collect_permanent_stubs >"$perm_lst"
    perm_n=$(wc -l <"$perm_lst" | tr -d ' ')
    # 非永久桩 = 当前 .c 中不在永久桩列表的
    nonperm_n=$(comm -23 "$cur" "$perm_lst" | wc -l | tr -d ' ')
    if [ "$nonperm_n" -gt 0 ] 2>/dev/null; then
      echo "nhc-audit STRICT FAIL: ${nonperm_n}/${total} .c are NOT permanent stubs (need .x migration):" >&2
      comm -23 "$cur" "$perm_lst" | head -30 >&2
      echo "  (${perm_n} permanent stubs in $NHC_PERMANENT_STUBS)" >&2
      rm -f "$tmp" "$cur" "$perm_lst"
      return 1
    else
      echo "nhc-audit STRICT OK: all ${total} .c are permanent stubs (language limitation C glue)"
    fi
    rm -f "$perm_lst"
  fi

  rm -f "$tmp" "$cur"
  return 0
}
