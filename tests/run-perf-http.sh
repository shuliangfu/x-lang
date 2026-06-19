#!/usr/bin/env bash
# STD-009：std.http GET 吞吐/延迟 bench
#
# 用法：./tests/run-perf-http.sh [--bench]
# 环境：
#   SHUX_PERF_FAIL_ON_HTTP_REGRESSION=1 — median ≤ http-perf.tsv + P99 ≤ latency.tsv
#   SHUX_PERF_UPDATE_HTTP_BASELINE=1 — 刷新基线
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/perf-http.sh
. tests/lib/perf-http.sh
# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh

HTTP_BENCH_PORT_DEFAULT=38460
BASELINE="${SHUX_HTTP_PERF_BASELINE:-tests/baseline/http-perf.tsv}"
LAT_BASELINE="${SHUX_HTTP_LAT_BASELINE:-tests/baseline/http-perf-latency.tsv}"
DO_BENCH=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
RUNS="${SHUX_HTTP_RUNS:-$([ "${CI:-0}" = "1" ] && echo 1 || echo 3)}"
[ "${SHUX_PERF_FAIL_ON_HTTP_REGRESSION:-0}" = "1" ] && FAIL_REGRESS=1 || FAIL_REGRESS=0
[ "${SHUX_PERF_UPDATE_HTTP_BASELINE:-0}" = "1" ] && UPDATE_BASE=1 || UPDATE_BASE=0

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

pick_free_port() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()'
  else
    echo $((38500 + RANDOM % 2000))
  fi
}

bench_cleanup() {
  pkill -f 'http_bench_server' 2>/dev/null || true
  if command -v lsof >/dev/null 2>&1; then
    lsof -ti :"${HTTP_BENCH_PORT_DEFAULT}" 2>/dev/null | xargs kill -9 2>/dev/null || true
  fi
  sleep 0.2
}

SHUX_BIN="${SHUX:-./compiler/shux}"
if ! native_shu "$SHUX_BIN"; then
  echo "run-perf-http SKIP: no native shux ($SHUX_BIN)"
  exit 0
fi

if [ "$DO_BENCH" -eq 0 ]; then
  echo "run-perf-http: use --bench to run http_get_bench"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler
ensure_std_c_o ../std/http/http.o

SERVER_BIN="/tmp/http_bench_server_$$"
CLIENT_BIN="/tmp/http_get_bench_$$"
bench_cleanup

if ! cc -O2 tests/bench/http_bench_server.c std/http/http.c -o "$SERVER_BIN" 2>/tmp/http_bench_server_build.log; then
  cat /tmp/http_bench_server_build.log >&2
  exit 1
fi

port="$(pick_free_port)"
sed -e "s/${HTTP_BENCH_PORT_DEFAULT}/${port}/g" tests/bench/http_get_bench.sx >"/tmp/http_get_bench_${port}.sx"
if ! "$SHUX_BIN" -L . "/tmp/http_get_bench_${port}.sx" -o "$CLIENT_BIN" >/tmp/http_bench_compile.log 2>&1; then
  cat /tmp/http_bench_compile.log >&2
  exit 1
fi

echo "=== STD-009: http_get_bench (port=${port} runs=${RUNS}) ==="
"$SERVER_BIN" "$port" &
srv_pid=$!
sleep 0.3

medians=""
p99s=""
r=0
while [ "$r" -lt "$RUNS" ]; do
  log="/tmp/http_bench_run_${r}.log"
  "$CLIENT_BIN" "$port" 2>"$log" || true
  if ! perf_http_parse_bench_log "$log"; then
    echo "run-perf-http FAIL: missing BENCH_* in $log" >&2
  cat "$log" >&2
    kill "$srv_pid" 2>/dev/null || true
    exit 1
  fi
  elapsed_s=$(awk -v ns="$ELAPSED_NS" 'BEGIN { printf "%.6f", ns / 1000000000 }')
  medians="${medians}${elapsed_s}"$'\n'
  p99s="${p99s}${P99_US}"$'\n'
  r=$((r + 1))
done
kill "$srv_pid" 2>/dev/null || true
wait "$srv_pid" 2>/dev/null || true

median_s=$(printf '%s\n' "$medians" | grep -v '^$' | sort -n | awk '{
  a[NR]=$1
} END {
  if (NR==0) exit 1
  if (NR%2==1) print a[(NR+1)/2]
  else print (a[NR/2]+a[NR/2+1])/2
}')
median_p99=$(printf '%s\n' "$p99s" | grep -v '^$' | sort -n | awk '{
  a[NR]=$1
} END {
  if (NR==0) exit 1
  if (NR%2==1) print a[(NR+1)/2]
  else print (a[NR/2]+a[NR/2+1])/2
}')

echo "run-perf-http: http_get_bench median_s=${median_s} p99_us=${median_p99}"

if [ "$UPDATE_BASE" -eq 1 ]; then
  {
    echo "# STD-009 std.http 吞吐基线（秒）；门禁：median elapsed ≤ 本列"
    echo "# 更新：SHUX_PERF_UPDATE_HTTP_BASELINE=1 ./tests/run-perf-http.sh --bench"
    printf 'http_get_bench\t%s\n' "$median_s"
  } >"$BASELINE"
  {
    echo "# STD-009 HTTP GET P99 延迟上限（微秒）；门禁：p99 ≤ 本列"
    echo "# 更新：SHUX_PERF_UPDATE_HTTP_BASELINE=1 ./tests/run-perf-http.sh --bench"
    printf 'http_get_bench_p99\t%s\n' "$median_p99"
  } >"$LAT_BASELINE"
  echo "run-perf-http: updated $BASELINE and $LAT_BASELINE"
fi

if [ "$FAIL_REGRESS" -eq 1 ]; then
  if ! perf_http_within_cap http_get_bench "$median_s" "$BASELINE"; then
    echo "run-perf-http FAIL: median ${median_s}s > cap $(perf_http_read_cap http_get_bench "$BASELINE")" >&2
    exit 1
  fi
  if ! perf_http_within_p99_cap http_get_bench_p99 "$median_p99" "$LAT_BASELINE"; then
    echo "run-perf-http FAIL: p99 ${median_p99}us > cap $(perf_http_read_cap http_get_bench_p99 "$LAT_BASELINE")" >&2
    exit 1
  fi
fi

rm -f "$SERVER_BIN" "$CLIENT_BIN"
echo "run-perf-http OK"
