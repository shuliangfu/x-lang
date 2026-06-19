#!/usr/bin/env bash
# zig-strategy-dashboard.sh — PERF-011 共享：Shu vs Zig 战略看板、趋势 sparkline、报告行
#
# 用法（source 后）：
#   zsd_ahead_pct shu_sec zig_sec
#   zsd_status ahead_pct target_pct
#   zsd_sparkline case_id [history_tsv]
#   zsd_history_months [history_tsv]
#   zsd_report_emit case_id shux zig ahead target status trend
#   zsd_append_history month case_id shux zig ahead [history_tsv]
#
# 环境：
#   SHUX_ZIG_STRATEGY_PREFIX — 默认 shux: [SHUX_ZIG_STRATEGY]

# 计算领先 Zig 的百分点；shux/zig 无效时输出 nan。
zsd_ahead_pct() {
  local shux="$1"
  local zig="$2"
  awk -v s="$shux" -v z="$zig" 'BEGIN {
    if (z <= 0 || s == "nan" || z == "nan" || s == "") { print "nan"; exit }
    printf "%.1f", (1.0 - s / z) * 100.0
  }'
}

# 根据 ahead_pct 与目标判断 status（ahead/behind/skip）。
zsd_status() {
  local ahead="$1"
  local target="${2:-0}"
  case "$ahead" in
    nan|"") echo "skip"; return ;;
  esac
  if awk -v a="$ahead" -v t="$target" 'BEGIN { exit (a + 0 >= t + 0) ? 0 : 1 }'; then
    echo "ahead"
  else
    echo "behind"
  fi
}

# 从 history TSV 为 case 生成 ASCII sparkline（基于 ahead_pct 序列）。
zsd_sparkline() {
  local case_id="$1"
  local hist="${2:-tests/baseline/zig-strategy-history.tsv}"
  awk -F'\t' -v c="$case_id" '
    $1 !~ /^#/ && $2 == c {
      v[++n] = $5 + 0
    }
    END {
      if (n == 0) { printf "—"; exit }
      min = v[1]; max = v[1]
      for (i = 2; i <= n; i++) {
        if (v[i] < min) min = v[i]
        if (v[i] > max) max = v[i]
      }
      blocks = "▁▂▃▄▅▆▇█"
      for (i = 1; i <= n; i++) {
        if (max == min) idx = 4
        else idx = int((v[i] - min) / (max - min) * 7)
        printf "%s", substr(blocks, idx + 1, 1)
      }
    }
  ' "$hist"
}

# 统计 history 中不同月份数量。
zsd_history_months() {
  local hist="${1:-tests/baseline/zig-strategy-history.tsv}"
  awk -F'\t' '$1 !~ /^#/ && NF >= 2 { m[$1]=1 } END { print length(m)+0 }' "$hist"
}

# 取当前月份 YYYY-MM（UTC 日期；本地 CI 可接受）。
zsd_current_month() {
  date -u +%Y-%m 2>/dev/null || date +%Y-%m
}

# 追加一行历史（不重复同月同 case）。
zsd_append_history() {
  local month="$1"
  local case_id="$2"
  local shux="$3"
  local zig="$4"
  local ahead="$5"
  local hist="${6:-tests/baseline/zig-strategy-history.tsv}"
  if awk -F'\t' -v m="$month" -v c="$case_id" \
    '$1==m && $2==c && $1 !~ /^#/ { found=1 } END { exit !found }' "$hist" 2>/dev/null; then
    awk -F'\t' -v m="$month" -v c="$case_id" -v s="$shux" -v z="$zig" -v a="$ahead" '
      $1 == m && $2 == c && $1 !~ /^#/ { print m "\t" c "\t" s "\t" z "\t" a; next }
      { print }
    ' OFS='\t' "$hist" > "${hist}.new"
    mv "${hist}.new" "$hist"
  else
    printf '%s\t%s\t%s\t%s\t%s\n' "$month" "$case_id" "$shux" "$zig" "$ahead" >> "$hist"
  fi
}

# 输出结构化战略看板报告行（OBS-003 bracket 兼容）。
zsd_report_emit() {
  local case_id="$1"
  local shux="$2"
  local zig="$3"
  local ahead="$4"
  local target="$5"
  local status="$6"
  local trend="$7"
  local prefix="${SHUX_ZIG_STRATEGY_PREFIX:-shux: [SHUX_ZIG_STRATEGY]}"
  printf '%s case=%s shu_sec=%s zig_sec=%s ahead_pct=%s target_pct=%s status=%s trend=%s\n' \
    "$prefix" "$case_id" "$shux" "$zig" "$ahead" "$target" "$status" "$trend" >&2
}

# 打印看板表头（Markdown 风格到 stdout）。
zsd_print_dashboard_header() {
  printf '\n| case | shux (s) | zig (s) | ahead%% | trend | status |\n'
  printf '|------|---------|---------|--------|-------|--------|\n'
}

# 打印看板一行。
zsd_print_dashboard_row() {
  local case_id="$1"
  local shux="$2"
  local zig="$3"
  local ahead="$4"
  local trend="$5"
  local status="$6"
  printf '| %s | %s | %s | %s | %s | %s |\n' \
    "$case_id" "$shux" "$zig" "$ahead" "$trend" "$status"
}
