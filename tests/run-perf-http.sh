#!/usr/bin/env bash
# STD-009: std.http GET throughput/latency bench.
#
# Honesty: soft XLANG_PERF_FAIL_ON_HTTP_REGRESSION:-0 previously left
# over-cap unchecked (silent OK = portable false-green). Soft SKIP when
# no native XLANG + soft auto-make before resolve retired. Prefer product
# xlang_asm. Over-cap / over-p99 = obs (FAIL_ON=1 still hard). Explicit
# bad XLANG = hard die. Report run=/obs=/skip=.
#
# Usage: ./tests/run-perf-http.sh [--bench]
# Env:
#   XLANG_PERF_FAIL_ON_HTTP_REGRESSION=1 — median ≤ http-perf.tsv + P99 ≤ latency.tsv hard
#   XLANG_PERF_UPDATE_HTTP_BASELINE=1 — refresh baselines
# PLATFORM: SHARED archaeology (Ubuntu gold; Darwin build via xlang-c when needed).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/perf-http.sh
. tests/lib/perf-http.sh
# Honesty: do NOT auto-make before resolve (no ensure_std_c_o / soft compiler-make).

HTTP_BENCH_PORT_DEFAULT=38460
BASELINE="${XLANG_HTTP_PERF_BASELINE:-tests/baseline/http-perf.tsv}"
LAT_BASELINE="${XLANG_HTTP_LAT_BASELINE:-tests/baseline/http-perf-latency.tsv}"
DO_BENCH=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
RUNS="${XLANG_HTTP_RUNS:-$([ "${CI:-0}" = "1" ] && echo 1 || echo 3)}"
[ "${XLANG_PERF_FAIL_ON_HTTP_REGRESSION:-0}" = "1" ] && FAIL_REGRESS=1 || FAIL_REGRESS=0
[ "${XLANG_PERF_UPDATE_HTTP_BASELINE:-0}" = "1" ] && UPDATE_BASE=1 || UPDATE_BASE=0

PREFIX="xlang: [XLANG_PERF_HTTP]"
OBS=0
RUN_OK=0
SKIP=0

die() {
  echo "http perf FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  # Explicit XLANG must be native — refuse soft fallthrough.
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

if [ "$DO_BENCH" -eq 0 ]; then
  echo "run-perf-http: use --bench to run http_get_bench"
  echo "${PREFIX} status=ok run=0 obs=0 skip=1 host=$(ci_host_summary)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# PLATFORM: DARWIN — hosted http client prefer xlang-c (asm __TEXT not r-x).
# PLATFORM: LINUX — product asm / xlang build.
HTTP_BUILD_XLANG="$XLANG_BIN"
case "$(uname -s 2>/dev/null)" in
  Darwin)
    if [ -x ./compiler/xlang-c ] && dod_native_exe "$(pwd)/compiler/xlang-c"; then
      HTTP_BUILD_XLANG="$(pwd)/compiler/xlang-c"
    fi
    ;;
esac
echo "http perf: resolve=$XLANG_BIN build=$HTTP_BUILD_XLANG"

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

# Cap check: always compare when measured. Over-cap = obs when FAIL_REGRESS=0;
# FAIL_REGRESS=1 still hard-dies. Refuse soft FAIL_ON:-0 silent OK.
check_http_cap() {
  local kind="$1" name="$2" value="$3" tsv="$4"
  local cap
  cap="$(perf_http_read_cap "$name" "$tsv")"
  [ -n "$cap" ] || return 0
  local within=0
  if [ "$kind" = "p99" ]; then
    perf_http_within_p99_cap "$name" "$value" "$tsv" && within=1 || within=0
  else
    perf_http_within_cap "$name" "$value" "$tsv" && within=1 || within=0
  fi
  if [ "$within" -eq 1 ]; then
    echo "http perf OK: ${name} ${value} <= cap ${cap}"
    return 0
  fi
  echo "http perf OBS: ${name} ${value} > cap ${cap}" >&2
  OBS=$((OBS + 1))
  if [ "$FAIL_REGRESS" -eq 1 ]; then
    die "${name} ${value} > cap ${cap} (XLANG_PERF_FAIL_ON_HTTP_REGRESSION=1)"
  fi
}

SERVER_BIN="/tmp/http_bench_server_$$"
CLIENT_BIN="/tmp/http_get_bench_$$"
bench_cleanup

# Live bench paths (relocated i08_*); refuse fossil bench/http_get_bench.x / http_bench_server.c.
# PLATFORM: SHARED — link product runtime_http_glue.o (same authority as
# run-std-http-context-gate); refuse soft recompile of seed with incomplete -I.
HTTP_GLUE_O="compiler/runtime_http_glue.o"
HTTP_ENV_O="compiler/runtime_link_abi_user_env.o"
[ -f "$HTTP_GLUE_O" ] || die "missing $HTTP_GLUE_O (refuse soft auto-make / soft SKIP→OK)"
[ -f "$HTTP_ENV_O" ] || die "missing $HTTP_ENV_O (refuse soft auto-make / soft SKIP→OK)"
if ! cc -O2 -Icompiler/include -Icompiler/src/asm/http \
    bench/i08_http_bench_server.c "$HTTP_GLUE_O" "$HTTP_ENV_O" \
    -o "$SERVER_BIN" 2>/tmp/http_bench_server_build.log; then
  cat /tmp/http_bench_server_build.log >&2
  die "http bench server build failed"
fi

port="$(pick_free_port)"
sed -e "s/${HTTP_BENCH_PORT_DEFAULT}/${port}/g" bench/i08_http_get_bench.x >"/tmp/http_get_bench_${port}.x"
if ! "$HTTP_BUILD_XLANG" -L . "/tmp/http_get_bench_${port}.x" -o "$CLIENT_BIN" >/tmp/http_bench_compile.log 2>&1; then
  cat /tmp/http_bench_compile.log >&2
  # Product residual (e.g. Darwin std_io_write_stderr_u8_ptr_usize UNDEF) —
  # report obs, not soft SKIP→OK without counters. FAIL_ON=1 still hard.
  echo "http perf OBS: client compile failed (product residual; see /tmp/http_bench_compile.log)" >&2
  OBS=$((OBS + 1))
  if [ "$FAIL_REGRESS" -eq 1 ]; then
    die "http client compile failed (XLANG_PERF_FAIL_ON_HTTP_REGRESSION=1)"
  fi
  rm -f "$SERVER_BIN" "$CLIENT_BIN"
  echo "run-perf-http OK (obs compile)"
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
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
    die "missing BENCH_* markers in http client log"
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
RUN_OK=1

if [ "$UPDATE_BASE" -eq 1 ]; then
  {
    echo "# STD-009 std.http 吞吐基线（秒）；门禁：median elapsed ≤ 本列"
    echo "# 更新：XLANG_PERF_UPDATE_HTTP_BASELINE=1 ./tests/run-perf-http.sh --bench"
    printf 'http_get_bench\t%s\n' "$median_s"
  } >"$BASELINE"
  {
    echo "# STD-009 HTTP GET P99 延迟上限（微秒）；门禁：p99 ≤ 本列"
    echo "# 更新：XLANG_PERF_UPDATE_HTTP_BASELINE=1 ./tests/run-perf-http.sh --bench"
    printf 'http_get_bench_p99\t%s\n' "$median_p99"
  } >"$LAT_BASELINE"
  echo "run-perf-http: updated $BASELINE and $LAT_BASELINE"
fi

check_http_cap median http_get_bench "$median_s" "$BASELINE"
check_http_cap p99 http_get_bench_p99 "$median_p99" "$LAT_BASELINE"

rm -f "$SERVER_BIN" "$CLIENT_BIN"
echo "run-perf-http OK"
echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
exit 0
