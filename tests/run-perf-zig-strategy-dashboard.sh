#!/usr/bin/env bash
# PERF-011：超越 Zig 战略看板 — 采集 Shu/Zig median、趋势 sparkline、可选 --record
#
# 用法：
#   ./tests/run-perf-zig-strategy-dashboard.sh
#   ./tests/run-perf-zig-strategy-dashboard.sh --record
#   SHUX_ZIG_STRATEGY_RECORD=1 ./tests/run-perf-zig-strategy-dashboard.sh --record
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/zig-baseline.sh
. tests/lib/zig-baseline.sh
# shellcheck source=tests/lib/zig-strategy-dashboard.sh
. tests/lib/zig-strategy-dashboard.sh

CASES="${SHUX_ZIG_STRATEGY_CASES:-tests/baseline/zig-strategy-cases.tsv}"
HISTORY="${SHUX_ZIG_STRATEGY_HISTORY:-tests/baseline/zig-strategy-history.tsv}"
BENCH_ROOT="tests/bench"
RUNS="$(zig_baseline_meta_get runs)"
[ -n "$RUNS" ] || RUNS=3
FAIL_FLAG="${SHUX_ZIG_STRATEGY_FAIL:-0}"
DO_RECORD=0

for arg in "$@"; do
  case "$arg" in
    --record) DO_RECORD=1 ;;
  esac
done
[ "${SHUX_ZIG_STRATEGY_RECORD:-0}" = "1" ] && DO_RECORD=1

PERF_COMPILE_SHUX=./compiler/shux
if [ -x ./compiler/shux-c ]; then
  PERF_COMPILE_SHUX=./compiler/shux-c
fi

pick_free_port() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()'
  else
    echo $((38600 + RANDOM % 2000))
  fi
}

# 起 C echo server 跑 client 一次。
zsd_run_net_echo_client() {
  local client="$1"
  local port="$2"
  local srv spid rc
  srv="$(mktemp /tmp/shux_zsd_echo_srv.XXXXXX)"
  if ! cc -O2 tests/bench/net_echo_throughput_server.c -o "$srv" 2>/dev/null; then
    return 1
  fi
  "$srv" "$port" >/dev/null 2>&1 &
  spid=$!
  sleep 0.15
  rc=0
  "$client" "$port" >/dev/null 2>&1 || rc=$?
  kill "$spid" 2>/dev/null || true
  wait "$spid" 2>/dev/null || true
  rm -f "$srv"
  return "$rc"
}

# net echo client 的 wall 中位数。
zsd_median_net_client() {
  local client="$1"
  local runs="$2"
  local i vals med port
  vals=""
  [ -x "$client" ] || { echo "nan"; return; }
  for i in $(seq 1 "$runs"); do
    port=$(pick_free_port)
    vals=$( ( time zsd_run_net_echo_client "$client" "$port" >/dev/null ) 2>&1 \
      | zig_baseline_extract_real_sec; printf '\n%s' "$vals" )
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "$med"
}

# 确保 io mmap bench 文件存在。
zsd_ensure_io_bench_file() {
  local f="tests/bench/.io_mmap_bench_tmp"
  local mb="${SHUX_IO_BENCH_MB:-16}"
  if [ ! -f "$f" ]; then
    dd if=/dev/zero of="$f" bs=1M count="$mb" status=none 2>/dev/null || \
      dd if=/dev/zero of="$f" bs=1048576 count="$mb" 2>/dev/null || return 1
  fi
}

echo "=== PERF-011: Zig strategy dashboard ==="
zig_baseline_host_summary

if ! command -v zig >/dev/null 2>&1; then
  echo "zig-strategy dashboard SKIP: no zig"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler

HARD_FAIL=0
CASE_OK=0
CASE_TOTAL=0
MONTH="$(zsd_current_month)"

zsd_print_dashboard_header

while IFS=$'\t' read -r case_id category su_src zig_src target_pct notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*) continue ;; esac
  CASE_TOTAL=$((CASE_TOTAL + 1))

  su_path="${BENCH_ROOT}/${su_src}"
  zig_path="${BENCH_ROOT}/${zig_src}"
  if [ ! -f "$su_path" ] || [ ! -f "$zig_path" ]; then
    echo "zig-strategy SKIP: $case_id missing bench source" >&2
    continue
  fi

  if [ "$category" = "io" ]; then
    zsd_ensure_io_bench_file || {
      echo "zig-strategy SKIP: $case_id io bench file" >&2
      continue
    }
  fi

  tag="zsd_${case_id}"
  shu_out="/tmp/${tag}_shu"
  zig_out="/tmp/${tag}_zig"
  rm -f "$shu_out" "$zig_out"

  SHUX_MED="nan"
  ZIG_MED="nan"

  if [ "$category" = "net" ]; then
    if ! $PERF_COMPILE_SHUX -L . "$su_path" -o "$shu_out" 2>/dev/null \
      || ! zig_build_exe_o2 "$zig_path" "$zig_out"; then
      echo "zig-strategy SKIP: $case_id compile (net)" >&2
      continue
    fi
    SHUX_MED=$(zsd_median_net_client "$shu_out" "$RUNS")
    ZIG_MED=$(zsd_median_net_client "$zig_out" "$RUNS")
  else
    if ! $PERF_COMPILE_SHUX -O2 "$su_path" -o "$shu_out" 2>/dev/null; then
      echo "zig-strategy SKIP: $case_id shux compile" >&2
      continue
    fi
    if ! zig_build_exe_o2 "$zig_path" "$zig_out"; then
      echo "zig-strategy SKIP: $case_id zig compile" >&2
      continue
    fi
    SHUX_MED=$(zig_baseline_median_real "$shu_out" "$RUNS")
    ZIG_MED=$(zig_baseline_median_real "$zig_out" "$RUNS")
  fi

  AHEAD=$(zsd_ahead_pct "$SHUX_MED" "$ZIG_MED")
  STATUS=$(zsd_status "$AHEAD" "$target_pct")
  TREND=$(zsd_sparkline "$case_id" "$HISTORY")

  zsd_report_emit "$case_id" "$SHUX_MED" "$ZIG_MED" "$AHEAD" "$target_pct" "$STATUS" "$TREND"
  zsd_print_dashboard_row "$case_id" "$SHUX_MED" "$ZIG_MED" "$AHEAD" "$TREND" "$STATUS"

  if [ "$STATUS" = "ahead" ]; then
    CASE_OK=$((CASE_OK + 1))
  elif [ "$STATUS" = "behind" ] && [ "$category" = "microbench" ] && [ "$FAIL_FLAG" = "1" ]; then
    HARD_FAIL=1
  fi

  if [ "$DO_RECORD" = "1" ] && [ "$AHEAD" != "nan" ]; then
    zsd_append_history "$MONTH" "$case_id" "$SHUX_MED" "$ZIG_MED" "$AHEAD" "$HISTORY"
    echo "zig-strategy RECORD: $MONTH $case_id ahead=${AHEAD}%"
  fi
done < "$CASES"

printf '\n'
echo "zig-strategy history months=$(zsd_history_months "$HISTORY") cases_run=${CASE_TOTAL} ahead_ok=${CASE_OK}"

if [ "$HARD_FAIL" -ne 0 ]; then
  echo "zig-strategy dashboard FAIL" >&2
  exit 1
fi

echo "zig-strategy dashboard OK"
