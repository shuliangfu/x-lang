#!/usr/bin/env bash
# perf-http.sh — STD-009 shared: HTTP bench parse + baseline compare.
#
# Usage (after source):
#   perf_http_read_cap case_id [baseline_tsv]
#   perf_http_parse_bench_log logfile
#   perf_http_within_cap case_id elapsed_s [baseline_tsv]
#   perf_http_within_p99_cap case_id p99_us [latency_tsv]
# PLATFORM: SHARED — single authority for HTTP cap helpers (G.7).

# Read case cap from baseline TSV (seconds or microseconds; caller picks file).
perf_http_read_cap() {
  local case_id="$1"
  local tsv="${2:-tests/baseline/http-perf.tsv}"
  awk -F'\t' -v c="$case_id" '$1==c && $1 !~ /^#/ { print $2; exit }' "$tsv"
}

# Parse BENCH_ELAPSED_NS and BENCH_P99_US from bench stderr log.
perf_http_parse_bench_log() {
  local log="$1"
  ELAPSED_NS=""
  P99_US=""
  ELAPSED_NS=$(grep -E '^BENCH_ELAPSED_NS=' "$log" 2>/dev/null | tail -1 | sed 's/^BENCH_ELAPSED_NS=//')
  P99_US=$(grep -E '^BENCH_P99_US=' "$log" 2>/dev/null | tail -1 | sed 's/^BENCH_P99_US=//')
  [ -n "$ELAPSED_NS" ] && [ -n "$P99_US" ]
}

# elapsed seconds within throughput cap (median ≤ cap).
# Optional $3 = baseline tsv (default http-perf.tsv). Authority accepts path.
perf_http_within_cap() {
  local case_id="$1"
  local elapsed_s="$2"
  local tsv="${3:-tests/baseline/http-perf.tsv}"
  local cap
  cap="$(perf_http_read_cap "$case_id" "$tsv")"
  [ -n "$cap" ] || return 1
  awk -v e="$elapsed_s" -v c="$cap" 'BEGIN { exit !(e <= c + 1e-9) }'
}

# P99 microseconds within latency baseline cap.
perf_http_within_p99_cap() {
  local case_id="$1"
  local p99_us="$2"
  local tsv="${3:-tests/baseline/http-perf-latency.tsv}"
  local cap
  cap="$(perf_http_read_cap "$case_id" "$tsv")"
  [ -n "$cap" ] || return 1
  awk -v p="$p99_us" -v c="$cap" 'BEGIN { exit !(p <= c + 1e-9) }'
}
