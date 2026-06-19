#!/usr/bin/env bash
# perf-syscall-batch.sh — PERF-008 共享：Linux strace 统计 I/O syscall 并 emit 报告行
#
# 用法（source 后）：
#   perf_sb_strace_probe_ok
#   perf_sb_strace_io_counts /path/to/exe [expect_rc] [args...]
#   perf_sb_read_caps case_id [baseline_tsv]
#   perf_sb_within_caps case_id ...
#   perf_sb_io_total read write readv writev
#   perf_sb_report_emit case_id counts... caps... ok_flag
#
# 环境：
#   SHUX_SYSCALL_BATCH_PREFIX — 默认 shux: [SHUX_SYSCALL_BATCH]

# strace 能否捕获 syscall（Docker Desktop ptrace 常失效）。
perf_sb_strace_probe_ok() {
  local probe_out
  [ "$(uname -s)" = "Linux" ] || return 1
  command -v strace >/dev/null 2>&1 || return 1
  probe_out="$(mktemp /tmp/shux_sb_strace_probe.XXXXXX)"
  strace -o "$probe_out" /bin/ls / >/dev/null 2>&1 || true
  if grep -qE '^openat\(' "$probe_out" 2>/dev/null; then
    rm -f "$probe_out"
    return 0
  fi
  rm -f "$probe_out"
  return 1
}

# 从 strace 日志统计 I/O 相关 syscall 次数。
perf_sb_count_from_strace_log() {
  local log="$1"
  perf_sb_read=0
  perf_sb_write=0
  perf_sb_readv=0
  perf_sb_writev=0
  perf_sb_splice=0
  perf_sb_sendfile=0
  [ -f "$log" ] || return 1
  perf_sb_read=$(grep -cE '^read\(' "$log" 2>/dev/null || echo 0)
  perf_sb_write=$(grep -cE '^write\(' "$log" 2>/dev/null || echo 0)
  perf_sb_readv=$(grep -cE 'readv\(' "$log" 2>/dev/null || echo 0)
  perf_sb_writev=$(grep -cE 'writev\(' "$log" 2>/dev/null || echo 0)
  perf_sb_splice=$(grep -cE 'splice\(' "$log" 2>/dev/null || echo 0)
  perf_sb_sendfile=$(grep -cE 'sendfile\(' "$log" 2>/dev/null || echo 0)
  return 0
}

# read+readv+write+writev+splice+sendfile 合计（同吞吐 syscall 代理指标）。
perf_sb_io_total() {
  local r="${1:-0}" w="${2:-0}" rv="${3:-0}" wv="${4:-0}" sp="${5:-0}" sf="${6:-0}"
  echo $((r + w + rv + wv + sp + sf))
}

# 对可执行文件跑 strace 并统计 I/O syscall。
perf_sb_strace_io_counts() {
  local exe="$1"
  local expect_rc="$2"
  shift 2
  local strace_out rc
  perf_sb_read=0
  perf_sb_write=0
  perf_sb_readv=0
  perf_sb_writev=0
  perf_sb_splice=0
  perf_sb_sendfile=0
  if ! perf_sb_strace_probe_ok; then
    return 1
  fi
  strace_out="$(mktemp /tmp/shux_sb_strace.XXXXXX)"
  rc=0
  strace -e trace=read,write,readv,writev,splice,sendfile -o "$strace_out" "$exe" "$@" >/dev/null 2>&1 || rc=$?
  if [ "$rc" != "$expect_rc" ]; then
    rm -f "$strace_out"
    return 2
  fi
  perf_sb_count_from_strace_log "$strace_out"
  rm -f "$strace_out"
  return 0
}

# 从 syscall-batch-perf.tsv 读取 case cap / min / ref。
perf_sb_read_caps() {
  local case_id="$1"
  local baseline="${2:-tests/baseline/syscall-batch-perf.tsv}"
  perf_sb_cap_read=""
  perf_sb_cap_write=""
  perf_sb_cap_readv=""
  perf_sb_cap_writev=""
  perf_sb_cap_splice=""
  perf_sb_cap_sendfile=""
  perf_sb_min_splice=""
  perf_sb_min_sendfile=""
  perf_sb_batch_lt_ref=""
  while IFS=$'\t' read -r cid _src _exit _sink cap_r cap_w cap_rv cap_wv cap_sp cap_sf min_sp min_sf ref_case _notes; do
    [ -z "${cid:-}" ] && continue
    case "$cid" in \#*) continue ;; esac
    if [ "$cid" = "$case_id" ]; then
      perf_sb_cap_read="$cap_r"
      perf_sb_cap_write="$cap_w"
      perf_sb_cap_readv="$cap_rv"
      perf_sb_cap_writev="$cap_wv"
      perf_sb_cap_splice="$cap_sp"
      perf_sb_cap_sendfile="$cap_sf"
      perf_sb_min_splice="$min_sp"
      perf_sb_min_sendfile="$min_sf"
      perf_sb_batch_lt_ref="$ref_case"
      return 0
    fi
  done < "$baseline"
  return 1
}

# 比较实测次数是否在 cap/min 内；stdout 输出 1/0。
perf_sb_within_caps() {
  local case_id="$1"
  local read_n="$2"
  local write_n="$3"
  local readv_n="$4"
  local writev_n="$5"
  local splice_n="$6"
  local sendfile_n="$7"
  local baseline="${8:-tests/baseline/syscall-batch-perf.tsv}"
  if ! perf_sb_read_caps "$case_id" "$baseline"; then
    echo 0
    return 1
  fi
  if [ "$read_n" -gt "$perf_sb_cap_read" ] \
    || [ "$write_n" -gt "$perf_sb_cap_write" ] \
    || [ "$readv_n" -gt "$perf_sb_cap_readv" ] \
    || [ "$writev_n" -gt "$perf_sb_cap_writev" ] \
    || [ "$splice_n" -gt "$perf_sb_cap_splice" ] \
    || [ "$sendfile_n" -gt "$perf_sb_cap_sendfile" ]; then
    echo 0
    return 0
  fi
  if [ -n "$perf_sb_min_splice" ] && [ "$perf_sb_min_splice" != "0" ] \
    && [ "$splice_n" -lt "$perf_sb_min_splice" ]; then
    echo 0
    return 0
  fi
  if [ -n "$perf_sb_min_sendfile" ] && [ "$perf_sb_min_sendfile" != "0" ] \
    && [ "$sendfile_n" -lt "$perf_sb_min_sendfile" ]; then
    echo 0
    return 0
  fi
  echo 1
  return 0
}

# 输出结构化 syscall batch 报告行（OBS-003 bracket 兼容）。
perf_sb_report_emit() {
  local case_id="$1"
  local read_n="$2"
  local write_n="$3"
  local readv_n="$4"
  local writev_n="$5"
  local splice_n="$6"
  local sendfile_n="$7"
  local io_total="$8"
  local ref_case="$9"
  local ref_total="${10:--}"
  local ok_flag="${11:-0}"
  local prefix="${SHUX_SYSCALL_BATCH_PREFIX:-shux: [SHUX_SYSCALL_BATCH]}"
  printf '%s case=%s read=%s write=%s readv=%s writev=%s splice=%s sendfile=%s io_total=%s ref_case=%s ref_io_total=%s ok=%s\n' \
    "$prefix" "$case_id" "$read_n" "$write_n" "$readv_n" "$writev_n" \
    "$splice_n" "$sendfile_n" "$io_total" "$ref_case" "$ref_total" "$ok_flag" >&2
}
