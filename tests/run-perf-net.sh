#!/usr/bin/env bash
# L0 network perf baseline (accept_many + echo + mixed + UDP; PERF-003).
#
# Honesty: soft XLANG_PERF_FAIL_ON_NET_*: -0 previously left over-cap /
# Zig-loss / P99 unchecked (silent OK = portable false-green). Soft
# auto-make before resolve retired. Prefer product xlang_asm. Over-cap =
# obs (FAIL_ON=1 still hard). Report run=/obs=/skip=.
#
# Usage: ./tests/run-perf-net.sh [--bench]
# Env:
#   XLANG_PERF_FAIL_ON_NET_REGRESSION=1 — ≤ net-perf.tsv hard
#   XLANG_PERF_FAIL_ON_NET_ZIG=1 — ≤ Zig -O2 hard
#   XLANG_PERF_FAIL_ON_NET_P99=1 — ≤ net-perf-latency.tsv hard
#   XLANG_PERF_FAIL_ON_ZC1=1 — Linux provided echo ≥10% faster than batch
#   XLANG_PERF_UPDATE_NET_BASELINE=1 — refresh baselines
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/zig-baseline.sh
. tests/lib/zig-baseline.sh
# shellcheck source=tests/lib/perf-net-zc.sh
. tests/lib/perf-net-zc.sh
# Honesty: do NOT auto-make before resolve.

PREFIX="xlang: [XLANG_PERF_NET]"
OBS=0
RUN_OK=0
SKIP=0

die() {
  echo "net perf FAIL: $*" >&2
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

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# PLATFORM: DARWIN — hosted net benches prefer xlang-c (asm __TEXT not r-x).
# PLATFORM: LINUX — product asm / xlang build.
NET_BUILD_XLANG="$XLANG_BIN"
case "$(uname -s 2>/dev/null)" in
  Darwin)
    if [ -x ./compiler/xlang-c ] && dod_native_exe "$(pwd)/compiler/xlang-c"; then
      NET_BUILD_XLANG="$(pwd)/compiler/xlang-c"
    fi
    ;;
esac
echo "net perf: resolve=$XLANG_BIN build=$NET_BUILD_XLANG"
# Historical "net_build" → NET_BUILD (thin wrapper).
net_build() {
  "$NET_BUILD_XLANG" build "$@"
}

NET_BENCH_PORT_DEFAULT=38456
NET_ECHO_PORT_DEFAULT=38457
NET_UDP_PORT_DEFAULT=38458
NET_MIXED_PORT_DEFAULT=38459
NET_BENCH_CONNS="${XLANG_NET_BENCH_CONNS:-1024}"
NET_UDP_PKTS="${XLANG_NET_UDP_PKTS:-1024}"
NET_UDP_BATCH=8
NET_UDP_PKT_LEN=64

bench_cleanup_stale() {
  pkill -f '/tmp/bench_net_' 2>/dev/null || true
  if command -v lsof >/dev/null 2>&1; then
    lsof -ti :"${NET_BENCH_PORT_DEFAULT}" 2>/dev/null | xargs kill -9 2>/dev/null || true
    lsof -ti :"${NET_ECHO_PORT_DEFAULT}" 2>/dev/null | xargs kill -9 2>/dev/null || true
    lsof -ti :"${NET_UDP_PORT_DEFAULT}" 2>/dev/null | xargs kill -9 2>/dev/null || true
    lsof -ti :"${NET_MIXED_PORT_DEFAULT}" 2>/dev/null | xargs kill -9 2>/dev/null || true
  fi
  sleep 0.25
}

# 每轮 bench 绑定新端口，避免 4096 建连后 ephemeral/TIME_WAIT 导致后续轮次超时。
pick_free_port() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()'
  else
    echo $((38000 + RANDOM % 2000))
  fi
}

compile_xlang_x() {
  local src_template="$1"
  local port_marker="$2"
  local port="$3"
  local out="$4"
  rm -f "$out"
  sed -e "s/${port_marker}/${port}/g" "$src_template" >"/tmp/bench_net_src_${port}.x"
  if ! net_build -L . "/tmp/bench_net_src_${port}.x" -o "$out" >/tmp/bench_net_compile.log 2>&1; then
    cat /tmp/bench_net_compile.log >&2
    return 1
  fi
  [ -x "$out" ]
}

# 替换 accept bench 端口与建连数（勿对 echo/udp 源做 4096 全局替换，会误伤数组长度）。
compile_shu_accept() {
  local src_template="$1"
  local port="$2"
  local out="$3"
  rm -f "$out"
  sed -e "s/${NET_BENCH_PORT_DEFAULT}/${port}/g" \
      -e "s/net_bench_conns: i32 = 4096/net_bench_conns: i32 = ${NET_BENCH_CONNS}/" \
      "$src_template" >"/tmp/bench_net_src_${port}.x"
  if ! net_build -L . "/tmp/bench_net_src_${port}.x" -o "$out" >/tmp/bench_net_compile.log 2>&1; then
    cat /tmp/bench_net_compile.log >&2
    return 1
  fi
  [ -x "$out" ]
}

# 替换 UDP bench 端口与报文数。
compile_shu_udp() {
  local src_template="$1"
  local port="$2"
  local out="$3"
  rm -f "$out"
  sed -e "s/${NET_UDP_PORT_DEFAULT}/${port}/g" \
      -e "s/udp_pkts: i32 = 4096/udp_pkts: i32 = ${NET_UDP_PKTS}/" \
      -e "s/batch, 5000/batch, 200/" \
      "$src_template" >"/tmp/bench_net_src_${port}.x"
  if ! net_build -L . "/tmp/bench_net_src_${port}.x" -o "$out" >/tmp/bench_net_compile.log 2>&1; then
    cat /tmp/bench_net_compile.log >&2
    return 1
  fi
  [ -x "$out" ]
}

DO_BENCH=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
# CI 默认 1 轮 median，本地可 XLANG_NET_RUNS=3
RUNS="${XLANG_NET_RUNS:-$([ "${CI:-0}" = "1" ] && echo 1 || echo 3)}"
[ "${XLANG_PERF_FAIL_ON_NET_REGRESSION:-0}" = "1" ] && PERF_FAIL_REGRESS=1 || PERF_FAIL_REGRESS=0
[ "${XLANG_PERF_FAIL_ON_NET_ZIG:-0}" = "1" ] && PERF_FAIL_ZIG=1 || PERF_FAIL_ZIG=0
[ "${XLANG_PERF_FAIL_ON_NET_P99:-0}" = "1" ] && PERF_FAIL_P99=1 || PERF_FAIL_P99=0
[ "${XLANG_PERF_FAIL_ON_ZC1:-0}" = "1" ] && PERF_FAIL_ZC1=1 || PERF_FAIL_ZC1=0
NET_CASE_MEDS=""
NET_CASE_P99S=""

extract_real_sec() {
  sed -n 's/^real[[:space:]]*\([0-9]*\)m\([0-9.]*\)s.*/\1 \2/p; s/^real[[:space:]]*\([0-9.]*\)s.*/0 \1/p' | awk 'NF==2 { print $1*60+$2; next } NF==1 { print $1 }'
}

time_accept_pair() {
  local server="$1"
  local client="$2"
  local port="$3"
  local spid
  case "$server" in
    *bench_net_c_*)
      "$server" "$NET_BENCH_CONNS" "$port" &
      ;;
    *)
      "$server" "$port" &
      ;;
  esac
  spid=$!
  sleep 0.15
  if ! "$client" "$port" "$NET_BENCH_CONNS"; then
    kill "$spid" 2>/dev/null || true
    wait "$spid" 2>/dev/null || true
    return 1
  fi
  wait "$spid"
}

median_accept_pair() {
  local su_template="$1"
  local c_server="$2"
  local tag="$3"
  local client="$4"
  local i vals med port xlang_exe
  vals=""
  xlang_exe="/tmp/bench_net_shu_${tag}"
  sed -e "s/net_bench_conns: i32 = 4096/net_bench_conns: i32 = ${NET_BENCH_CONNS}/" \
      "$su_template" >"/tmp/bench_net_accept.x"
  if ! net_build -L . "/tmp/bench_net_accept.x" -o "$xlang_exe" >/tmp/bench_net_compile.log 2>&1; then
    cat /tmp/bench_net_compile.log >&2
    echo "nan"
    return 1
  fi
  port=$(pick_free_port)
  time_accept_pair "$xlang_exe" "$client" "$port" >/dev/null 2>&1 || true
  time_accept_pair "$xlang_exe" "$client" "$port" >/dev/null 2>&1 || true
  for i in $(seq 1 "$RUNS"); do
    bench_cleanup_stale
    port=$(pick_free_port)
    vals=$( ( time time_accept_pair "$xlang_exe" "$client" "$port" ) 2>&1 | extract_real_sec; printf '\n%s' "$vals" )
    sleep 0.25
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "$med"
}

median_accept_pair_c() {
  local c_exe="$1"
  local client="$2"
  local i vals med port
  vals=""
  port=$(pick_free_port)
  time_accept_pair "$c_exe" "$client" "$port" >/dev/null 2>&1 || true
  for i in $(seq 1 "$RUNS"); do
    bench_cleanup_stale
    port=$(pick_free_port)
    vals=$( ( time time_accept_pair "$c_exe" "$client" "$port" ) 2>&1 | extract_real_sec; printf '\n%s' "$vals" )
    sleep 0.25
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "$med"
}

net_baseline_cap() {
  local name="$1"
  awk -F'\t' -v n="$name" '$1==n && $1 !~ /^#/ { print $2; exit }' "${XLANG_PERF_NET_BASELINE:-tests/baseline/net-perf.tsv}"
}

# 从 NET_CASE_MEDS 取已跑 case 的中位数（形如 name:0.12;）。
net_case_median_from_meds() {
  local name="$1"
  local pair med
  for pair in $(echo "$NET_CASE_MEDS" | tr ';' ' '); do
    [ -z "$pair" ] && continue
    case "$pair" in
      "${name}:"*)
        med="${pair#*:}"
        [ "$med" != "nan" ] && echo "$med" && return 0
        ;;
    esac
  done
  return 1
}

check_net_regress() {
  local name="$1"
  local xlang_med="$2"
  local cap
  if [ "$xlang_med" = "nan" ] || [ -z "$xlang_med" ]; then
    # Compile/run failure must not soft-silence as plain OK.
    echo "net perf OBS: ${name} xlang median nan (compile/run residual)" >&2
    OBS=$((OBS + 1))
    if [ "$PERF_FAIL_REGRESS" -eq 1 ]; then
      die "${name} xlang median nan (XLANG_PERF_FAIL_ON_NET_REGRESSION=1)"
    fi
    return 0
  fi
  cap=$(net_baseline_cap "$name")
  [ -n "$cap" ] || return 0
  if awk -v xlang="$xlang_med" -v cap="$cap" 'BEGIN { exit (xlang <= cap + 0.000001) ? 0 : 1 }'; then
    echo "net perf baseline OK: ${name} ${xlang_med}s <= cap ${cap}s"
  else
    echo "net perf OBS: ${name} ${xlang_med}s > cap ${cap}s" >&2
    OBS=$((OBS + 1))
    if [ "$PERF_FAIL_REGRESS" -eq 1 ]; then
      die "${name} ${xlang_med}s > cap ${cap}s (XLANG_PERF_FAIL_ON_NET_REGRESSION=1)"
    fi
  fi
}

# 从 client stderr 提取 BENCH_P99_US=（微秒）。
extract_p99_us() {
  sed -n 's/^BENCH_P99_US=\([0-9][0-9]*\).*/\1/p' | tail -1
}

net_latency_cap() {
  local name="$1"
  awk -F'\t' -v n="$name" '$1==n && $1 !~ /^#/ { print $2; exit }' \
    "${XLANG_PERF_NET_LATENCY_BASELINE:-tests/baseline/net-perf-latency.tsv}"
}

check_net_p99_regress() {
  local name="$1"
  local p99_us="$2"
  local cap
  if [ -z "$p99_us" ] || [ "$p99_us" = "nan" ]; then
    return 0
  fi
  cap=$(net_latency_cap "$name")
  [ -n "$cap" ] || return 0
  if awk -v p="$p99_us" -v cap="$cap" 'BEGIN { exit (p <= cap + 0.5) ? 0 : 1 }'; then
    echo "net p99 baseline OK: ${name} ${p99_us}us <= cap ${cap}us"
  else
    echo "net p99 OBS: ${name} ${p99_us}us > cap ${cap}us" >&2
    OBS=$((OBS + 1))
    if [ "$PERF_FAIL_P99" -eq 1 ]; then
      die "${name} ${p99_us}us > cap ${cap}us (XLANG_PERF_FAIL_ON_NET_P99=1)"
    fi
  fi
}

check_net_zig() {
  local name="$1"
  local xlang_med="$2"
  local zig_med="$3"
  if [ "$xlang_med" = "nan" ] || [ "$zig_med" = "nan" ] || [ -z "$zig_med" ]; then
    return 0
  fi
  if awk -v xlang="$xlang_med" -v zig="$zig_med" 'BEGIN { exit (xlang <= zig + 0.000001) ? 0 : 1 }'; then
    echo "net zig OK: ${name} Xlang ${xlang_med}s <= Zig ${zig_med}s"
  else
    echo "net zig OBS: ${name} Xlang ${xlang_med}s > Zig ${zig_med}s" >&2
    OBS=$((OBS + 1))
    if [ "$PERF_FAIL_ZIG" -eq 1 ]; then
      die "${name} Xlang ${xlang_med}s > Zig ${zig_med}s (XLANG_PERF_FAIL_ON_NET_ZIG=1)"
    fi
  fi
}

bench_net_accept_case() {
  local name="$1"
  local x="$2"
  local c_server="$3"
  local tag="${name}_"
  local XLANG_MED="nan"
  local C_MED="nan"
  local CLIENT="/tmp/bench_net_client_${tag}"

  echo "=== bench/${name} (${NET_BENCH_CONNS} conns @ 127.0.0.1:<dynamic>, default ${NET_BENCH_PORT_DEFAULT}) ==="

  if ! cc -O2 bench/i04_net_accept_many_client.c -o "$CLIENT" 2>/dev/null; then
    echo "run-perf-net: failed to build client" >&2
    exit 1
  fi

  if [ -f "$c_server" ] && cc -O2 "$c_server" -o "/tmp/bench_net_c_${tag}" 2>/dev/null && [ -x "/tmp/bench_net_c_${tag}" ]; then
    C_MED=$(median_accept_pair_c "/tmp/bench_net_c_${tag}" "$CLIENT")
    echo "C -O2 accept loop ${name} median real: ${C_MED}s"
  fi

  XLANG_MED=$(median_accept_pair "$x" "$c_server" "$tag" "$CLIENT")
  echo "Xlang (default asm) ${name} median real: ${XLANG_MED}s"

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Xlang (default asm) | %s |\n' "$XLANG_MED"
  printf '| C -O2 accept loop | %s |\n' "$C_MED"
  printf '\n'

  check_net_regress "$name" "$XLANG_MED"
  NET_CASE_MEDS="${NET_CASE_MEDS}${name}:${XLANG_MED};"
  bench_cleanup_stale
}

time_echo_pair() {
  local server="$1"
  local client="$2"
  local port="$3"
  local spid
  "$server" "$port" &
  spid=$!
  sleep 0.1
  if ! "$client" "$port"; then
    kill "$spid" 2>/dev/null || true
    wait "$spid" 2>/dev/null || true
    return 1
  fi
  wait "$spid"
}

median_echo_pair() {
  local su_template="$1"
  local c_server="$2"
  local c_client="$3"
  local tag="$4"
  local use_shu="$5"
  local i vals med port exe srv
  vals=""
  srv="/tmp/bench_net_echo_srv_${tag}"
  cc -O2 "$c_server" -o "$srv" 2>/dev/null || return 1
  if [ "$use_shu" -eq 1 ]; then
    exe="/tmp/bench_net_shu_${tag}"
    if ! net_build -L . "$su_template" -o "$exe" >/tmp/bench_net_compile.log 2>&1; then
      cat /tmp/bench_net_compile.log >&2
      return 1
    fi
    port=$(pick_free_port)
    time_echo_pair "$srv" "$exe" "$port" >/dev/null 2>&1 || true
    time_echo_pair "$srv" "$exe" "$port" >/dev/null 2>&1 || true
  else
    exe="/tmp/bench_net_c_${tag}"
    cc -O2 "$c_client" -o "$exe" 2>/dev/null || return 1
    port=$(pick_free_port)
    time_echo_pair "$srv" "$exe" "$port" >/dev/null 2>&1 || true
  fi
  for i in $(seq 1 "$RUNS"); do
    bench_cleanup_stale
    port=$(pick_free_port)
    vals=$( ( time time_echo_pair "$srv" "$exe" "$port" ) 2>&1 | extract_real_sec; printf '\n%s' "$vals" )
    sleep 0.25
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "$med"
}

bench_net_echo_case() {
  local name="$1"
  local su_client="$2"
  local c_server="$3"
  local c_client="$4"
  local tag="${name}_"
  local XLANG_MED="nan"
  local C_MED="nan"
  local ZIG_MED="nan"
  # Derive zig from remapped .x path (i03_/i04_…); refuse stale bench/${name}.zig.
  local zig_src="${su_client%.x}.zig"

  echo "=== bench/${name} (4×4KiB×1024 echo @ 127.0.0.1:<dynamic>, default ${NET_ECHO_PORT_DEFAULT}) ==="

  XLANG_MED=$(median_echo_pair "$su_client" "$c_server" "$c_client" "$tag" 1)
  echo "Xlang (stream_*_batch) ${name} median real: ${XLANG_MED}s"

  C_MED=$(median_echo_pair "$su_client" "$c_server" "$c_client" "$tag" 0)
  echo "C -O2 readv/writev ${name} median real: ${C_MED}s"

  if command -v zig >/dev/null 2>&1 && [ -f "$zig_src" ]; then
    if zig_build_exe_o2 "$zig_src" "/tmp/bench_net_zig_${tag}"; then
      ZIG_MED=$(median_echo_client_exe "/tmp/bench_net_zig_${tag}" "$c_server" "${tag}z_")
      echo "Zig -O2 ${name} median real: ${ZIG_MED}s"
    fi
  fi

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Xlang (stream_*_batch) | %s |\n' "$XLANG_MED"
  printf '| C -O2 readv/writev | %s |\n' "$C_MED"
  printf '| Zig -O2 echo client | %s |\n' "$ZIG_MED"
  printf '\n'

  check_net_regress "$name" "$XLANG_MED"
  check_net_zig "$name" "$XLANG_MED" "$ZIG_MED"
  NET_CASE_MEDS="${NET_CASE_MEDS}${name}:${XLANG_MED};"
  bench_cleanup_stale
}

# 预编译 client exe + C echo server，返回 wall 中位数（秒）。
median_echo_client_exe() {
  local client_exe="$1"
  local c_server="$2"
  local tag="$3"
  local i vals med port srv
  vals=""
  srv="/tmp/bench_net_echo_srv_${tag}"
  cc -O2 "$c_server" -o "$srv" 2>/dev/null || { echo "nan"; return 1; }
  port=$(pick_free_port)
  time_echo_pair "$srv" "$client_exe" "$port" >/dev/null 2>&1 || true
  time_echo_pair "$srv" "$client_exe" "$port" >/dev/null 2>&1 || true
  for i in $(seq 1 "$RUNS"); do
    bench_cleanup_stale
    port=$(pick_free_port)
    vals=$( ( time time_echo_pair "$srv" "$client_exe" "$port" ) 2>&1 | extract_real_sec; printf '\n%s' "$vals" )
    sleep 0.25
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "$med"
}

# mixed bench：C server + client；stdout 一行 "wall_med:p99_med"（p99 微秒，无则 nan）。
median_mixed_client() {
  local client_exe="$1"
  local c_server="$2"
  local tag="$3"
  local i vals p99_vals med p99_med port srv errf wall p99
  vals=""
  p99_vals=""
  srv="/tmp/bench_net_mixed_srv_${tag}"
  cc -O2 "$c_server" -o "$srv" 2>/dev/null || { echo "nan:nan"; return 1; }
  port=$(pick_free_port)
  errf=$(mktemp)
  "$srv" "$port" &
  local spid=$!
  sleep 0.1
  "$client_exe" "$port" 2>"$errf" >/dev/null || true
  wait "$spid" 2>/dev/null || true
  rm -f "$errf"
  for i in $(seq 1 "$RUNS"); do
    bench_cleanup_stale
    port=$(pick_free_port)
    errf=$(mktemp)
    wall=$( ( time {
      "$srv" "$port" &
      spid=$!
      sleep 0.1
      "$client_exe" "$port" 2>"$errf" >/dev/null
      wait "$spid"
    } ) 2>&1 | extract_real_sec)
    p99=$(extract_p99_us < "$errf")
    rm -f "$errf"
    vals=$(printf '%s\n%s' "$vals" "$wall")
    if [ -n "$p99" ]; then
      p99_vals=$(printf '%s\n%s' "$p99_vals" "$p99")
    fi
    sleep 0.25
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  p99_med=$(printf '%s\n' "$p99_vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "${med}:${p99_med}"
}

bench_net_mixed_case() {
  local name="$1"
  local su_client="$2"
  local c_server="$3"
  local c_client="$4"
  local tag="${name}_"
  local XLANG_PAIR="nan:nan"
  local C_PAIR="nan:nan"
  local ZIG_PAIR="nan:nan"
  local XLANG_MED C_MED ZIG_MED XLANG_P99 C_P99 ZIG_P99
  # Derive zig from remapped .x path (i03_/i04_…); refuse stale bench/${name}.zig.
  local zig_src="${su_client%.x}.zig"

  echo "=== bench/${name} (256×16×512B connect+echo @ 127.0.0.1:<dynamic>, default ${NET_MIXED_PORT_DEFAULT}) ==="

  if ! net_build -L . "$su_client" -o "/tmp/bench_net_shu_${tag}" >/tmp/bench_net_compile.log 2>&1; then
    cat /tmp/bench_net_compile.log >&2
  elif [ -x "/tmp/bench_net_shu_${tag}" ]; then
    XLANG_PAIR=$(median_mixed_client "/tmp/bench_net_shu_${tag}" "$c_server" "${tag}s_")
    echo "Xlang mixed ${name} median real/p99: ${XLANG_PAIR}"
  fi

  if cc -O2 "$c_client" -o "/tmp/bench_net_c_${tag}" 2>/dev/null && [ -x "/tmp/bench_net_c_${tag}" ]; then
    C_PAIR=$(median_mixed_client "/tmp/bench_net_c_${tag}" "$c_server" "${tag}c_")
    echo "C mixed ${name} median real/p99: ${C_PAIR}"
  fi

  if command -v zig >/dev/null 2>&1 && [ -f "$zig_src" ]; then
    if zig_build_exe_o2 "$zig_src" "/tmp/bench_net_zig_${tag}"; then
      ZIG_PAIR=$(median_mixed_client "/tmp/bench_net_zig_${tag}" "$c_server" "${tag}z_")
      echo "Zig mixed ${name} median real/p99: ${ZIG_PAIR}"
    fi
  fi

  XLANG_MED="${XLANG_PAIR%%:*}"
  XLANG_P99="${XLANG_PAIR#*:}"
  C_MED="${C_PAIR%%:*}"
  C_P99="${C_PAIR#*:}"
  ZIG_MED="${ZIG_PAIR%%:*}"
  ZIG_P99="${ZIG_PAIR#*:}"

  printf '\n'
  printf '| %s | real (s) 中位数 | P99 (us) 中位数 |\n' "$name"
  printf '|---|----------------|-----------------|\n'
  printf '| Xlang mixed client | %s | %s |\n' "$XLANG_MED" "$XLANG_P99"
  printf '| C -O2 mixed client | %s | %s |\n' "$C_MED" "$C_P99"
  printf '| Zig -O2 mixed client | %s | %s |\n' "$ZIG_MED" "$ZIG_P99"
  printf '\n'

  check_net_regress "$name" "$XLANG_MED"
  check_net_zig "$name" "$XLANG_MED" "$ZIG_MED"
  check_net_p99_regress "${name}_p99" "$XLANG_P99"
  NET_CASE_MEDS="${NET_CASE_MEDS}${name}:${XLANG_MED};"
  NET_CASE_P99S="${NET_CASE_P99S}${name}_p99:${XLANG_P99};"
  bench_cleanup_stale
}

# ZC-1 echo：读 provided / 写 batch；仅 Linux io_uring provide_buffers 有效。
bench_net_echo_provided_case() {
  local name="$1"
  local su_client="$2"
  local c_server="$3"
  local tag="${name}_"
  local XLANG_MED="nan"
  local BATCH_MED="nan"

  echo "=== bench/${name} (ZC-1 provided read + batch write @ 127.0.0.1:<dynamic>) ==="

  XLANG_MED=$(median_echo_pair "$su_client" "$c_server" bench/i03_net_echo_throughput.c "$tag" 1)
  echo "Xlang (stream_read_batch_provided) ${name} median real: ${XLANG_MED}s"

  BATCH_MED=$(net_case_median_from_meds net_echo_throughput || true)
  if [ -z "$BATCH_MED" ]; then
    BATCH_MED=$(net_baseline_cap net_echo_throughput)
  fi
  if [ -n "$BATCH_MED" ] && [ "$XLANG_MED" != "nan" ]; then
    ratio=$(awk -v p="$XLANG_MED" -v b="$BATCH_MED" 'BEGIN { if (b>0) printf "%.1f", (1.0-p/b)*100.0; else print "0" }')
    echo "vs net_echo_throughput ${BATCH_MED}s: ${ratio}% (target ZC-1: -10%)"
    if awk -v r="$ratio" 'BEGIN { exit (r + 0 >= 10.0) ? 0 : 1 }'; then
      echo "ZC-1 provided vs batch OK (${ratio}% faster)"
    else
      echo "ZC-1 OBS: provided vs batch ${ratio}% (stretch target -10%)" >&2
      OBS=$((OBS + 1))
      if [ "$PERF_FAIL_ZC1" -eq 1 ]; then
        die "provided echo not ≥10% faster than batch (XLANG_PERF_FAIL_ON_ZC1=1)"
      fi
    fi
  fi
  echo "ZC-1 provided bench OK"

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Xlang (provided read) | %s |\n' "$XLANG_MED"
  printf '\n'

  check_net_regress "$name" "$XLANG_MED"
  NET_CASE_MEDS="${NET_CASE_MEDS}${name}:${XLANG_MED};"

  # PERF-009：Linux perf cycles/MiB — provided vs batch（perf 可用时 advisory emit）
  if perf_nz_probe_ok; then
    local prov_exe batch_exe port nz_cpm_prov nz_cpm_batch nz_ok prov_cycles
    prov_exe="/tmp/bench_net_shu_${tag}"
    if [ -x "$prov_exe" ]; then
      port=$(pick_free_port)
      if perf_nz_run_echo_cycles "$prov_exe" "$c_server" "$port"; then
        prov_cycles="$perf_nz_cycles"
        nz_cpm_prov=$(perf_nz_cycles_per_mib "$prov_cycles" 33554432)
        batch_exe="/tmp/bench_net_shu_nz_batch_$$"
        if net_build -L . bench/i03_net_echo_throughput.x -o "$batch_exe" 2>/dev/null \
          && [ -x "$batch_exe" ]; then
          port=$(pick_free_port)
          if perf_nz_run_echo_cycles "$batch_exe" "$c_server" "$port"; then
            nz_cpm_batch=$(perf_nz_cycles_per_mib "$perf_nz_cycles" 33554432)
            nz_ok=0
            if awk -v p="$nz_cpm_prov" -v b="$nz_cpm_batch" 'BEGIN { exit (p+0 < b+0) ? 0 : 1 }'; then
              nz_ok=1
            fi
            perf_nz_report_emit net_echo_throughput_provided "$prov_cycles" 33554432 \
              "$nz_cpm_prov" 1500000000 net_echo_throughput "$nz_cpm_batch" "$nz_ok"
            echo "PERF-009: provided cycles/MiB=${nz_cpm_prov} vs batch=${nz_cpm_batch}"
          fi
        fi
        rm -f "$batch_exe"
      fi
    fi
  fi

  bench_cleanup_stale
}

time_udp_pair() {
  local server="$1"
  local client="$2"
  local port="$3"
  local spid
  case "$server" in
    *bench_net_c_*)
      "$server" "$port" "$NET_UDP_PKTS" &
      ;;
    *)
      "$server" "$port" &
      ;;
  esac
  spid=$!
  sleep 0.15
  if ! "$client" "$port" "$NET_UDP_PKTS"; then
    kill "$spid" 2>/dev/null || true
    wait "$spid" 2>/dev/null || true
    return 1
  fi
  wait "$spid"
}

median_udp_pair() {
  local su_template="$1"
  local c_server="$2"
  local tag="$3"
  local client="$4"
  local use_shu="$5"
  local i vals med port exe
  vals=""
  if [ "$use_shu" -eq 1 ]; then
    exe="/tmp/bench_net_shu_${tag}"
    sed -e "s/udp_pkts: i32 = 4096/udp_pkts: i32 = ${NET_UDP_PKTS}/" \
        -e "s/batch, 5000/batch, 200/" \
        "$su_template" >"/tmp/bench_udp.x"
    if ! net_build -L . "/tmp/bench_udp.x" -o "$exe" >/tmp/bench_net_compile.log 2>&1; then
      cat /tmp/bench_net_compile.log >&2
      echo "nan"
      return 1
    fi
    port=$(pick_free_port)
    time_udp_pair "$exe" "$client" "$port" >/dev/null 2>&1 || true
    time_udp_pair "$exe" "$client" "$port" >/dev/null 2>&1 || true
  else
    exe="/tmp/bench_net_c_${tag}"
    cc -O2 "$c_server" -o "$exe" 2>/dev/null || return 1
    port=$(pick_free_port)
    time_udp_pair "$exe" "$client" "$port" >/dev/null 2>&1 || true
  fi
  for i in $(seq 1 "$RUNS"); do
    bench_cleanup_stale
    port=$(pick_free_port)
    vals=$( ( time time_udp_pair "$exe" "$client" "$port" ) 2>&1 | extract_real_sec; printf '\n%s' "$vals" )
    sleep 0.25
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "$med"
}

bench_net_udp_case() {
  local name="$1"
  local x="$2"
  local c_server="$3"
  local tag="${name}_"
  local XLANG_MED="nan"
  local C_MED="nan"
  local CLIENT="/tmp/bench_net_udp_client_${tag}"

  echo "=== bench/${name} (${NET_UDP_PKTS} pkts×${NET_UDP_PKT_LEN}B batch=${NET_UDP_BATCH} @ 127.0.0.1:<dynamic>) ==="

  if ! cc -O2 bench/i04_net_udp_many_client.c -o "$CLIENT" 2>/dev/null; then
    echo "run-perf-net: failed to build udp client" >&2
    exit 1
  fi

  C_MED=$(median_udp_pair "$x" "$c_server" "${tag}c_" "$CLIENT" 0)
  echo "C -O2 recvmmsg/sendmmsg ${name} median real: ${C_MED}s"

  XLANG_MED=$(median_udp_pair "$x" "$c_server" "$tag" "$CLIENT" 1)
  echo "Xlang (udp_*_many_buf) ${name} median real: ${XLANG_MED}s"

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Xlang (udp_*_many_buf) | %s |\n' "$XLANG_MED"
  printf '| C -O2 recvmmsg/sendmmsg | %s |\n' "$C_MED"
  printf '\n'

  check_net_regress "$name" "$XLANG_MED"
  NET_CASE_MEDS="${NET_CASE_MEDS}${name}:${XLANG_MED};"
}

if [ "$DO_BENCH" -eq 0 ]; then
  echo "run-perf-net: use --bench to run net_accept_many + net_echo_throughput + net_mixed + net_udp_many"
  echo "${PREFIX} status=ok run=0 obs=0 skip=1 host=$(ci_host_summary)"
  exit 0
fi

BASELINE="${XLANG_PERF_NET_BASELINE:-tests/baseline/net-perf.tsv}"
LAT_BASELINE="${XLANG_PERF_NET_LATENCY_BASELINE:-tests/baseline/net-perf-latency.tsv}"
bench_net_accept_case net_accept_many bench/i04_net_accept_many.x bench/i04_net_accept_many_server.c
bench_net_echo_case net_echo_throughput bench/i03_net_echo_throughput.x \
  bench/i03_net_echo_throughput_server.c bench/i03_net_echo_throughput.c
bench_net_mixed_case net_mixed_conns_requests bench/i04_net_mixed_conns_requests.x \
  bench/i04_net_mixed_conns_requests_server.c bench/i04_net_mixed_conns_requests.c
if [ "$(uname -s)" = "Linux" ]; then
  # shellcheck source=tests/lib/io-uring-probe.sh
  . tests/lib/io-uring-probe.sh
  if io_uring_available; then
    chmod +x tests/run-provided-buffers.sh 2>/dev/null || true
    ./tests/run-provided-buffers.sh
    bench_net_echo_provided_case net_echo_throughput_provided bench/i03_net_echo_throughput_provided.x \
      bench/i03_net_echo_throughput_server.c
  else
    echo "ZC-1 provided bench SKIP (io_uring unavailable on this kernel; e.g. Mac Docker linuxkit)"
    SKIP=$((SKIP + 1))
  fi
fi
bench_net_udp_case net_udp_many bench/i04_net_udp_many.x bench/i04_net_udp_many_server.c

if [ "${XLANG_PERF_UPDATE_NET_BASELINE:-0}" = "1" ]; then
  {
    if [ -f "$BASELINE" ]; then
      awk -F'\t' '$1 !~ /^#/ && NF>=2 { print $1 "\t" $2 }' "$BASELINE"
    fi
    for pair in $(echo "$NET_CASE_MEDS" | tr ';' ' '); do
      [ -z "$pair" ] && continue
      cname="${pair%%:*}"
      cmed="${pair#*:}"
      [ "$cmed" = "nan" ] && continue
      printf '%s\t%s\n' "$cname" "$cmed"
    done
  } | awk -F'\t' 'NF>=2 { cap[$1]=$2 } END { for (k in cap) print k "\t" cap[k] }' >"${BASELINE}.body"
  {
    echo "# xlang net bench 中位数上限（秒）；门禁：实测 median ≤ 本列值"
    echo "# 更新：XLANG_PERF_UPDATE_NET_BASELINE=1 ./tests/run-perf-net.sh --bench"
    for c in net_accept_many net_echo_throughput net_echo_throughput_provided net_mixed_conns_requests net_udp_many; do
      grep "^${c}	" "${BASELINE}.body" 2>/dev/null || true
    done
  } >"$BASELINE"
  rm -f "${BASELINE}.body"
  echo "run-perf-net: updated $BASELINE"
fi

if [ "${XLANG_PERF_UPDATE_NET_BASELINE:-0}" = "1" ] && [ -n "$NET_CASE_P99S" ]; then
  {
    if [ -f "$LAT_BASELINE" ]; then
      awk -F'\t' '$1 !~ /^#/ && NF>=2 { print $1 "\t" $2 }' "$LAT_BASELINE"
    fi
    for pair in $(echo "$NET_CASE_P99S" | tr ';' ' '); do
      [ -z "$pair" ] && continue
      cname="${pair%%:*}"
      cp99="${pair#*:}"
      [ "$cp99" = "nan" ] && continue
      printf '%s\t%s\n' "$cname" "$cp99"
    done
  } | awk -F'\t' 'NF>=2 { cap[$1]=$2 } END { for (k in cap) print k "\t" cap[k] }' >"${LAT_BASELINE}.body"
  {
    echo "# mixed bench P99 延迟上限（微秒）；门禁：实测 p99 ≤ 本列"
    echo "# 更新：XLANG_PERF_UPDATE_NET_BASELINE=1 ./tests/run-perf-net.sh --bench"
    grep "^net_mixed_conns_requests_p99	" "${LAT_BASELINE}.body" 2>/dev/null || true
  } >"$LAT_BASELINE"
  rm -f "${LAT_BASELINE}.body"
  echo "run-perf-net: updated $LAT_BASELINE"
fi

RUN_OK=1
echo "=== net perf OK ==="
echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
exit 0
