#!/usr/bin/env bash
# perf-alloc-hotspot.sh — PERF-007 共享：Linux strace 统计 heap 调用并 emit 报告行
#
# 用法（source 后）：
#   perf_ah_strace_probe_ok
#   perf_ah_strace_heap_counts /path/to/exe [expect_rc]
#   perf_ah_within_caps case_id malloc calloc realloc baseline_tsv
#   perf_ah_report_emit case_id malloc calloc realloc cap_m cap_c cap_r ok_flag
#
# 环境：
#   SHUX_ALLOC_HOTSPOT_PREFIX — 默认 shux: [SHUX_ALLOC_HOTSPOT]

# strace 在本机能否捕获 syscall（Docker Desktop ptrace 常失效）。
perf_ah_strace_probe_ok() {
  local probe_out
  [ "$(uname -s)" = "Linux" ] || return 1
  command -v strace >/dev/null 2>&1 || return 1
  probe_out="$(mktemp /tmp/shux_ah_strace_probe.XXXXXX)"
  strace -o "$probe_out" /bin/true >/dev/null 2>&1 || true
  if grep -qE 'execve|newfstatat|getdents' "$probe_out" 2>/dev/null; then
    rm -f "$probe_out"
    return 0
  fi
  rm -f "$probe_out"
  return 1
}

# 统计 strace 日志中 malloc/calloc/realloc 调用次数；结果写入 perf_ah_malloc 等变量。
perf_ah_count_from_strace_log() {
  local log="$1"
  perf_ah_malloc=0
  perf_ah_calloc=0
  perf_ah_realloc=0
  [ -f "$log" ] || return 1
  perf_ah_malloc=$(grep -cE 'malloc\(' "$log" 2>/dev/null || echo 0)
  perf_ah_calloc=$(grep -cE 'calloc\(' "$log" 2>/dev/null || echo 0)
  perf_ah_realloc=$(grep -cE 'realloc\(' "$log" 2>/dev/null || echo 0)
  return 0
}

# 对可执行文件跑 strace trace=memory，统计 heap 族 syscall 次数。
perf_ah_strace_heap_counts() {
  local exe="$1"
  local expect_rc="${2:-0}"
  local strace_out rc
  perf_ah_malloc=0
  perf_ah_calloc=0
  perf_ah_realloc=0
  if ! perf_ah_strace_probe_ok; then
    return 1
  fi
  strace_out="$(mktemp /tmp/shux_ah_strace.XXXXXX)"
  rc=0
  strace -e trace=memory -o "$strace_out" "$exe" >/dev/null 2>&1 || rc=$?
  if [ "$rc" != "$expect_rc" ]; then
    rm -f "$strace_out"
    return 2
  fi
  perf_ah_count_from_strace_log "$strace_out"
  rm -f "$strace_out"
  return 0
}

# 从 alloc-hotspot-perf.tsv 读取 case 的 max_malloc/max_calloc/max_realloc。
perf_ah_read_caps() {
  local case_id="$1"
  local baseline="${2:-tests/baseline/alloc-hotspot-perf.tsv}"
  perf_ah_cap_malloc=""
  perf_ah_cap_calloc=""
  perf_ah_cap_realloc=""
  while IFS=$'\t' read -r cid _src _exit cap_m cap_c cap_r _notes; do
    [ -z "${cid:-}" ] && continue
    case "$cid" in \#*) continue ;; esac
    if [ "$cid" = "$case_id" ]; then
      perf_ah_cap_malloc="$cap_m"
      perf_ah_cap_calloc="$cap_c"
      perf_ah_cap_realloc="$cap_r"
      return 0
    fi
  done < "$baseline"
  return 1
}

# 比较实测次数是否在 cap 内；stdout 输出 1/0。
perf_ah_within_caps() {
  local case_id="$1"
  local malloc_n="$2"
  local calloc_n="$3"
  local realloc_n="$4"
  local baseline="${5:-tests/baseline/alloc-hotspot-perf.tsv}"
  if ! perf_ah_read_caps "$case_id" "$baseline"; then
    echo 0
    return 1
  fi
  if [ "$malloc_n" -le "$perf_ah_cap_malloc" ] \
    && [ "$calloc_n" -le "$perf_ah_cap_calloc" ] \
    && [ "$realloc_n" -le "$perf_ah_cap_realloc" ]; then
    echo 1
    return 0
  fi
  echo 0
  return 0
}

# 输出结构化 alloc hotspot 报告行（OBS-003 bracket 兼容）。
perf_ah_report_emit() {
  local case_id="$1"
  local malloc_n="$2"
  local calloc_n="$3"
  local realloc_n="$4"
  local cap_m="$5"
  local cap_c="$6"
  local cap_r="$7"
  local ok_flag="$8"
  local prefix="${SHUX_ALLOC_HOTSPOT_PREFIX:-shux: [SHUX_ALLOC_HOTSPOT]}"
  printf '%s case=%s malloc=%s calloc=%s realloc=%s cap_malloc=%s cap_calloc=%s cap_realloc=%s ok=%s\n' \
    "$prefix" "$case_id" "$malloc_n" "$calloc_n" "$realloc_n" \
    "$cap_m" "$cap_c" "$cap_r" "$ok_flag" >&2
}
