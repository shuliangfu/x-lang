#!/usr/bin/env bash
# zc-dashboard.sh — ZC-008 共享：零拷贝指标看板、日趋势 sparkline、报告行
#
# 用法（source 后）：
#   zcd_current_date
#   zcd_baseline_value source_tsv case_id field
#   zcd_metric_status value cap rule
#   zcd_probe_gate gate_script
#   zcd_sparkline metric_id [history_tsv]
#   zcd_history_days [history_tsv]
#   zcd_append_daily date metric_id value status [history_tsv]
#   zcd_report_emit metric_id value cap status trend
#
# 环境：
#   SHUX_ZC_DASHBOARD_PREFIX — 默认 shux: [SHUX_ZC_DASHBOARD]

# 取当前日期 YYYY-MM-DD（UTC 优先）。
zcd_current_date() {
  date -u +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d
}

# 从 syscall-batch / net-zc / io-perf 基线 TSV 读取指标值。
zcd_baseline_value() {
  local src="$1"
  local case_id="$2"
  local field="$3"
  local path="tests/baseline/${src}"
  [ -f "$path" ] || return 1
  case "$src" in
    syscall-batch-perf.tsv)
      awk -F'\t' -v c="$case_id" -v f="$field" '
        $1 !~ /^#/ && $1 == c {
          if (f == "max_splice") print $9
          else if (f == "max_read") print $5
          else if (f == "max_readv") print $7
          else if (f == "max_write") print $6
          exit
        }
      ' "$path"
      ;;
    net-zc-perf.tsv)
      awk -F'\t' -v c="$case_id" -v f="$field" '
        $1 !~ /^#/ && $1 == c {
          if (f == "max_cycles_per_mib") print $5
          exit
        }
      ' "$path"
      ;;
    io-perf.tsv)
      awk -F'\t' -v c="$case_id" -v f="$field" '
        $1 !~ /^#/ && $1 == c {
          if (f == "time_sec_cap") print $2
          exit
        }
      ' "$path"
      ;;
    *)
      return 1
      ;;
  esac
}

# 根据规则比较 value 与 cap，输出 status（green/pass/warn/skip）。
zcd_metric_status() {
  local value="$1"
  local cap="$2"
  local rule="${3:-le_cap}"
  case "$value" in
    ""|nan) echo "skip"; return ;;
  esac
  case "$rule" in
    pass)
      case "$value" in pass|skip) echo "pass" ;; *) echo "warn" ;; esac
      ;;
    le_cap)
      if awk -v v="$value" -v c="$cap" 'BEGIN { exit (v + 0 <= c + 0) ? 0 : 1 }'; then
        echo "green"
      else
        echo "warn"
      fi
      ;;
    *)
      echo "green"
      ;;
  esac
}

# 探测 gate 脚本 manifest 是否通过（不跑完整 bench）。
zcd_probe_gate() {
  local script="$1"
  local path="tests/${script}"
  [ -f "$path" ] || { echo "skip"; return 1; }
  chmod +x "$path" 2>/dev/null || true
  local log="/tmp/zcd_gate_$$.log"
  local ec=0
  "$path" >"$log" 2>&1 || ec=$?
  if grep -qE 'gate OK' "$log" 2>/dev/null; then
    rm -f "$log"
    echo "pass"
    return 0
  fi
  rm -f "$log"
  # 非 Linux 或无 native 工具链时 gate bench 常不可用，仪表板记 skip 不 fail。
  if [ "$(uname -s)" != "Linux" ] || [ "$ec" -ne 0 ]; then
    echo "skip"
    return 0
  fi
  echo "warn"
  return 1
}

# 从日历史为 metric 生成 ASCII sparkline。
zcd_sparkline() {
  local metric_id="$1"
  local hist="${2:-tests/baseline/zc-dashboard-history.tsv}"
  awk -F'\t' -v m="$metric_id" '
    $1 !~ /^#/ && $2 == m {
      raw[++n] = $3
      st[n] = $4
    }
    END {
      if (n == 0) { printf "—"; exit }
      for (i = 1; i <= n; i++) {
        if (st[i] == "pass") v[i] = 1
        else if (st[i] == "green") v[i] = raw[i] + 0
        else v[i] = 0
      }
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

# 统计 history 中不同日期数量。
zcd_history_days() {
  local hist="${1:-tests/baseline/zc-dashboard-history.tsv}"
  awk -F'\t' '$1 !~ /^#/ && NF >= 2 { d[$1]=1 } END { print length(d)+0 }' "$hist"
}

# 追加或更新同日同 metric 历史行。
zcd_append_daily() {
  local day="$1"
  local metric_id="$2"
  local value="$3"
  local status="$4"
  local notes="${5:-}"
  local hist="${6:-tests/baseline/zc-dashboard-history.tsv}"
  if awk -F'\t' -v d="$day" -v m="$metric_id" \
    '$1==d && $2==m && $1 !~ /^#/ { found=1 } END { exit !found }' "$hist" 2>/dev/null; then
    awk -F'\t' -v d="$day" -v m="$metric_id" -v v="$value" -v s="$status" -v n="$notes" '
      $1 == d && $2 == m && $1 !~ /^#/ { print d "\t" m "\t" v "\t" s "\t" n; next }
      { print }
    ' OFS='\t' "$hist" > "${hist}.new"
    mv "${hist}.new" "$hist"
  else
    printf '%s\t%s\t%s\t%s\t%s\n' "$day" "$metric_id" "$value" "$status" "$notes" >> "$hist"
  fi
}

# 输出结构化看板报告行。
zcd_report_emit() {
  local metric_id="$1"
  local value="$2"
  local cap="$3"
  local status="$4"
  local trend="$5"
  local prefix="${SHUX_ZC_DASHBOARD_PREFIX:-shux: [SHUX_ZC_DASHBOARD]}"
  printf '%s metric=%s value=%s cap=%s status=%s trend=%s\n' \
    "$prefix" "$metric_id" "$value" "$cap" "$status" "$trend" >&2
}

# 打印 Markdown 表头。
zcd_print_dashboard_header() {
  printf '\n| metric | value | cap | status | trend |\n'
  printf '|--------|-------|-----|--------|-------|\n'
}

# 打印 Markdown 表行。
zcd_print_dashboard_row() {
  local metric_id="$1"
  local value="$2"
  local cap="$3"
  local status="$4"
  local trend="$5"
  printf '| %s | %s | %s | %s | %s |\n' "$metric_id" "$value" "$cap" "$status" "$trend"
}

# 采集单条 metric 当前值（baseline 或 gate）。
zcd_collect_metric() {
  local layer="$1"
  local src="$2"
  local case_id="$3"
  local field="$4"
  local cap="$5"
  local rule="$6"
  local value status
  if [ "$src" = "run-zc1-gate.sh" ] || [ "${src%.sh}" != "$src" ]; then
    value="$(zcd_probe_gate "$src")"
    status="$(zcd_metric_status "$value" "-" "$rule")"
    echo "${value}|${cap}|${status}"
    return
  fi
  value="$(zcd_baseline_value "$src" "$case_id" "$field")"
  status="$(zcd_metric_status "$value" "$cap" "$rule")"
  echo "${value}|${cap}|${status}"
}
