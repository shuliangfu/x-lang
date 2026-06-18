#!/usr/bin/env bash
# perf-http.sh — STD-009 共享：HTTP bench 解析与基线比较
#
# 用法（source 后）：
#   perf_http_read_cap case_id [baseline_tsv]
#   perf_http_parse_bench_log logfile
#   perf_http_within_cap case_id elapsed_s p99_us

# 从 baseline TSV 读取 case 上限（秒或微秒由调用方区分文件）。
perf_http_read_cap() {
  local case_id="$1"
  local tsv="${2:-tests/baseline/http-perf.tsv}"
  awk -F'\t' -v c="$case_id" '$1==c && $1 !~ /^#/ { print $2; exit }' "$tsv"
}

# 从 bench stderr 解析 BENCH_ELAPSED_NS 与 BENCH_P99_US。
perf_http_parse_bench_log() {
  local log="$1"
  ELAPSED_NS=""
  P99_US=""
  ELAPSED_NS=$(grep -E '^BENCH_ELAPSED_NS=' "$log" 2>/dev/null | tail -1 | sed 's/^BENCH_ELAPSED_NS=//')
  P99_US=$(grep -E '^BENCH_P99_US=' "$log" 2>/dev/null | tail -1 | sed 's/^BENCH_P99_US=//')
  [ -n "$ELAPSED_NS" ] && [ -n "$P99_US" ]
}

# elapsed 秒数是否在 cap 内（median ≤ cap）。
perf_http_within_cap() {
  local case_id="$1"
  local elapsed_s="$2"
  local cap
  cap="$(perf_http_read_cap "$case_id")"
  [ -n "$cap" ] || return 1
  awk -v e="$elapsed_s" -v c="$cap" 'BEGIN { exit !(e <= c + 1e-9) }'
}

# P99 微秒是否在 latency baseline cap 内。
perf_http_within_p99_cap() {
  local case_id="$1"
  local p99_us="$2"
  local tsv="${3:-tests/baseline/http-perf-latency.tsv}"
  local cap
  cap="$(perf_http_read_cap "$case_id" "$tsv")"
  [ -n "$cap" ] || return 1
  awk -v p="$p99_us" -v c="$cap" 'BEGIN { exit !(p <= c + 1e-9) }'
}
