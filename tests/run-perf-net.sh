#!/usr/bin/env bash
# L0 网络性能基线（NEXT N1/N2/N3/N4 + PERF-003）：accept_many + echo + mixed + UDP
# 用法：./tests/run-perf-net.sh [--bench]
# 门禁（可选）：
#   SHUX_PERF_FAIL_ON_NET_REGRESSION=1 — Shu default asm ≤ tests/baseline/net-perf.tsv
#   SHUX_PERF_FAIL_ON_NET_ZIG=1 — Shu client median ≤ Zig -O2（echo + mixed）
#   SHUX_PERF_FAIL_ON_NET_P99=1 — mixed P99 ≤ tests/baseline/net-perf-latency.tsv
#   SHUX_PERF_FAIL_ON_ZC1=1 — Linux：provided echo 须比 batch 中位数快 ≥10%
#   SHUX_PERF_UPDATE_NET_BASELINE=1 — 用本次 median 刷新 net-perf.tsv / net-perf-latency.tsv
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/zig-baseline.sh
. "$(dirname "$0")/lib/zig-baseline.sh"
# shellcheck source=tests/lib/perf-net-zc.sh
. "$(dirname "$0")/lib/perf-net-zc.sh"
make -C compiler -q 2>/dev/null || make -C compiler
make -C compiler ../std/net/net.o ../std/thread/thread.o -q 2>/dev/null || make -C compiler ../std/net/net.o ../std/thread/thread.o

NET_BENCH_PORT_DEFAULT=38456
NET_ECHO_PORT_DEFAULT=38457
NET_UDP_PORT_DEFAULT=38458
NET_MIXED_PORT_DEFAULT=38459
NET_BENCH_CONNS="${SHUX_NET_BENCH_CONNS:-1024}"
NET_UDP_PKTS="${SHUX_NET_UDP_PKTS:-1024}"
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

compile_shux_x() {
  local src_template="$1"
  local port_marker="$2"
  local port="$3"
  local out="$4"
  rm -f "$out"
  sed -e "s/${port_marker}/${port}/g" "$src_template" >"/tmp/bench_net_src_${port}.x"
  if ! ./compiler/shux -L . "/tmp/bench_net_src_${port}.x" -o "$out" >/tmp/bench_net_compile.log 2>&1; then
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
  if ! ./compiler/shux -L . "/tmp/bench_net_src_${port}.x" -o "$out" >/tmp/bench_net_compile.log 2>&1; then
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
  if ! ./compiler/shux -L . "/tmp/bench_net_src_${port}.x" -o "$out" >/tmp/bench_net_compile.log 2>&1; then
    cat /tmp/bench_net_compile.log >&2
    return 1
  fi
  [ -x "$out" ]
}

DO_BENCH=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
# CI 默认 1 轮 median，本地可 SHUX_NET_RUNS=3
RUNS="${SHUX_NET_RUNS:-$([ "${CI:-0}" = "1" ] && echo 1 || echo 3)}"
[ "${SHUX_PERF_FAIL_ON_NET_REGRESSION:-0}" = "1" ] && PERF_FAIL_REGRESS=1 || PERF_FAIL_REGRESS=0
[ "${SHUX_PERF_FAIL_ON_NET_ZIG:-0}" = "1" ] && PERF_FAIL_ZIG=1 || PERF_FAIL_ZIG=0
[ "${SHUX_PERF_FAIL_ON_NET_P99:-0}" = "1" ] && PERF_FAIL_P99=1 || PERF_FAIL_P99=0
[ "${SHUX_PERF_FAIL_ON_ZC1:-0}" = "1" ] && PERF_FAIL_ZC1=1 || PERF_FAIL_ZC1=0
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
  local i vals med port shu_exe
  vals=""
  shu_exe="/tmp/bench_net_shu_${tag}"
  sed -e "s/net_bench_conns: i32 = 4096/net_bench_conns: i32 = ${NET_BENCH_CONNS}/" \
      "$su_template" >"/tmp/bench_net_accept.x"
  if ! ./compiler/shux -L . "/tmp/bench_net_accept.x" -o "$shu_exe" >/tmp/bench_net_compile.log 2>&1; then
    cat /tmp/bench_net_compile.log >&2
    echo "nan"
    return 1
  fi
  port=$(pick_free_port)
  time_accept_pair "$shu_exe" "$client" "$port" >/dev/null 2>&1 || true
  time_accept_pair "$shu_exe" "$client" "$port" >/dev/null 2>&1 || true
  for i in $(seq 1 "$RUNS"); do
    bench_cleanup_stale
    port=$(pick_free_port)
    vals=$( ( time time_accept_pair "$shu_exe" "$client" "$port" ) 2>&1 | extract_real_sec; printf '\n%s' "$vals" )
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
  awk -F'\t' -v n="$name" '$1==n && $1 !~ /^#/ { print $2; exit }' "${SHUX_PERF_NET_BASELINE:-tests/baseline/net-perf.tsv}"
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
  local shu_med="$2"
  if [ "$PERF_FAIL_REGRESS" -eq 1 ] && [ "$shu_med" != "nan" ]; then
    cap=$(net_baseline_cap "$name")
    if [ -n "$cap" ]; then
      if awk -v shux="$shu_med" -v cap="$cap" 'BEGIN { exit (shux <= cap + 0.000001) ? 0 : 1 }'; then
        echo "net perf baseline OK: ${name} ${shu_med}s <= cap ${cap}s"
      else
        echo "net perf baseline FAIL: ${name} ${shu_med}s > cap ${cap}s" >&2
        exit 1
      fi
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
    "${SHUX_PERF_NET_LATENCY_BASELINE:-tests/baseline/net-perf-latency.tsv}"
}

check_net_p99_regress() {
  local name="$1"
  local p99_us="$2"
  if [ "$PERF_FAIL_P99" -eq 1 ] && [ -n "$p99_us" ] && [ "$p99_us" != "nan" ]; then
    cap=$(net_latency_cap "$name")
    if [ -n "$cap" ]; then
      if awk -v p="$p99_us" -v cap="$cap" 'BEGIN { exit (p <= cap + 0.5) ? 0 : 1 }'; then
        echo "net p99 baseline OK: ${name} ${p99_us}us <= cap ${cap}us"
      else
        echo "net p99 baseline FAIL: ${name} ${p99_us}us > cap ${cap}us" >&2
        exit 1
      fi
    fi
  fi
}

check_net_zig() {
  local name="$1"
  local shu_med="$2"
  local zig_med="$3"
  if [ "$PERF_FAIL_ZIG" -eq 1 ] && [ "$shu_med" != "nan" ] && [ "$zig_med" != "nan" ]; then
    if awk -v shux="$shu_med" -v zig="$zig_med" 'BEGIN { exit (shux <= zig + 0.000001) ? 0 : 1 }'; then
      echo "net zig OK: ${name} Shu ${shu_med}s <= Zig ${zig_med}s"
    else
      echo "net zig FAIL: ${name} Shu ${shu_med}s > Zig ${zig_med}s" >&2
      exit 1
    fi
  fi
}

bench_net_accept_case() {
  local name="$1"
  local x="$2"
  local c_server="$3"
  local tag="${name}_"
  local SHUX_MED="nan"
  local C_MED="nan"
  local CLIENT="/tmp/bench_net_client_${tag}"

  echo "=== tests/bench/${name} (${NET_BENCH_CONNS} conns @ 127.0.0.1:<dynamic>, default ${NET_BENCH_PORT_DEFAULT}) ==="

  if ! cc -O2 tests/bench/net_accept_many_client.c -o "$CLIENT" 2>/dev/null; then
    echo "run-perf-net: failed to build client" >&2
    exit 1
  fi

  if [ -f "$c_server" ] && cc -O2 "$c_server" -o "/tmp/bench_net_c_${tag}" 2>/dev/null && [ -x "/tmp/bench_net_c_${tag}" ]; then
    C_MED=$(median_accept_pair_c "/tmp/bench_net_c_${tag}" "$CLIENT")
    echo "C -O2 accept loop ${name} median real: ${C_MED}s"
  fi

  SHUX_MED=$(median_accept_pair "$x" "$c_server" "$tag" "$CLIENT")
  echo "Shu (default asm) ${name} median real: ${SHUX_MED}s"

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Shu (default asm) | %s |\n' "$SHUX_MED"
  printf '| C -O2 accept loop | %s |\n' "$C_MED"
  printf '\n'

  check_net_regress "$name" "$SHUX_MED"
  NET_CASE_MEDS="${NET_CASE_MEDS}${name}:${SHUX_MED};"
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
    if ! ./compiler/shux -L . "$su_template" -o "$exe" >/tmp/bench_net_compile.log 2>&1; then
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
  local SHUX_MED="nan"
  local C_MED="nan"
  local ZIG_MED="nan"
  local zig_src="tests/bench/${name}.zig"

  echo "=== tests/bench/${name} (4×4KiB×1024 echo @ 127.0.0.1:<dynamic>, default ${NET_ECHO_PORT_DEFAULT}) ==="

  SHUX_MED=$(median_echo_pair "$su_client" "$c_server" "$c_client" "$tag" 1)
  echo "Shu (stream_*_batch) ${name} median real: ${SHUX_MED}s"

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
  printf '| Shu (stream_*_batch) | %s |\n' "$SHUX_MED"
  printf '| C -O2 readv/writev | %s |\n' "$C_MED"
  printf '| Zig -O2 echo client | %s |\n' "$ZIG_MED"
  printf '\n'

  check_net_regress "$name" "$SHUX_MED"
  check_net_zig "$name" "$SHUX_MED" "$ZIG_MED"
  NET_CASE_MEDS="${NET_CASE_MEDS}${name}:${SHUX_MED};"
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
  local SHUX_PAIR="nan:nan"
  local C_PAIR="nan:nan"
  local ZIG_PAIR="nan:nan"
  local SHUX_MED C_MED ZIG_MED SHUX_P99 C_P99 ZIG_P99
  local zig_src="tests/bench/${name}.zig"

  echo "=== tests/bench/${name} (256×16×512B connect+echo @ 127.0.0.1:<dynamic>, default ${NET_MIXED_PORT_DEFAULT}) ==="

  if ! ./compiler/shux -L . "$su_client" -o "/tmp/bench_net_shu_${tag}" >/tmp/bench_net_compile.log 2>&1; then
    cat /tmp/bench_net_compile.log >&2
  elif [ -x "/tmp/bench_net_shu_${tag}" ]; then
    SHUX_PAIR=$(median_mixed_client "/tmp/bench_net_shu_${tag}" "$c_server" "${tag}s_")
    echo "Shu mixed ${name} median real/p99: ${SHUX_PAIR}"
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

  SHUX_MED="${SHUX_PAIR%%:*}"
  SHUX_P99="${SHUX_PAIR#*:}"
  C_MED="${C_PAIR%%:*}"
  C_P99="${C_PAIR#*:}"
  ZIG_MED="${ZIG_PAIR%%:*}"
  ZIG_P99="${ZIG_PAIR#*:}"

  printf '\n'
  printf '| %s | real (s) 中位数 | P99 (us) 中位数 |\n' "$name"
  printf '|---|----------------|-----------------|\n'
  printf '| Shu mixed client | %s | %s |\n' "$SHUX_MED" "$SHUX_P99"
  printf '| C -O2 mixed client | %s | %s |\n' "$C_MED" "$C_P99"
  printf '| Zig -O2 mixed client | %s | %s |\n' "$ZIG_MED" "$ZIG_P99"
  printf '\n'

  check_net_regress "$name" "$SHUX_MED"
  check_net_zig "$name" "$SHUX_MED" "$ZIG_MED"
  check_net_p99_regress "${name}_p99" "$SHUX_P99"
  NET_CASE_MEDS="${NET_CASE_MEDS}${name}:${SHUX_MED};"
  NET_CASE_P99S="${NET_CASE_P99S}${name}_p99:${SHUX_P99};"
  bench_cleanup_stale
}

# ZC-1 echo：读 provided / 写 batch；仅 Linux io_uring provide_buffers 有效。
bench_net_echo_provided_case() {
  local name="$1"
  local su_client="$2"
  local c_server="$3"
  local tag="${name}_"
  local SHUX_MED="nan"
  local BATCH_MED="nan"

  echo "=== tests/bench/${name} (ZC-1 provided read + batch write @ 127.0.0.1:<dynamic>) ==="

  SHUX_MED=$(median_echo_pair "$su_client" "$c_server" tests/bench/net_echo_throughput.c "$tag" 1)
  echo "Shu (stream_read_batch_provided) ${name} median real: ${SHUX_MED}s"

  BATCH_MED=$(net_case_median_from_meds net_echo_throughput || true)
  if [ -z "$BATCH_MED" ]; then
    BATCH_MED=$(net_baseline_cap net_echo_throughput)
  fi
  if [ -n "$BATCH_MED" ] && [ "$SHUX_MED" != "nan" ]; then
    ratio=$(awk -v p="$SHUX_MED" -v b="$BATCH_MED" 'BEGIN { if (b>0) printf "%.1f", (1.0-p/b)*100.0; else print "0" }')
    echo "vs net_echo_throughput ${BATCH_MED}s: ${ratio}% (target ZC-1: -10%)"
    if awk -v r="$ratio" 'BEGIN { exit (r + 0 >= 10.0) ? 0 : 1 }'; then
      echo "ZC-1 provided vs batch OK (${ratio}% faster)"
    else
      echo "ZC-1 provided vs batch: ${ratio}% (stretch target -10%)"
      if [ "$PERF_FAIL_ZC1" -eq 1 ]; then
        echo "ZC-1 FAIL: provided echo not ≥10% faster than batch" >&2
        exit 1
      fi
    fi
  fi
  echo "ZC-1 provided bench OK"

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Shu (provided read) | %s |\n' "$SHUX_MED"
  printf '\n'

  check_net_regress "$name" "$SHUX_MED"
  NET_CASE_MEDS="${NET_CASE_MEDS}${name}:${SHUX_MED};"

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
        if ./compiler/shux -L . tests/bench/net_echo_throughput.x -o "$batch_exe" 2>/dev/null \
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
    if ! ./compiler/shux -L . "/tmp/bench_udp.x" -o "$exe" >/tmp/bench_net_compile.log 2>&1; then
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
  local SHUX_MED="nan"
  local C_MED="nan"
  local CLIENT="/tmp/bench_net_udp_client_${tag}"

  echo "=== tests/bench/${name} (${NET_UDP_PKTS} pkts×${NET_UDP_PKT_LEN}B batch=${NET_UDP_BATCH} @ 127.0.0.1:<dynamic>) ==="

  if ! cc -O2 tests/bench/net_udp_many_client.c -o "$CLIENT" 2>/dev/null; then
    echo "run-perf-net: failed to build udp client" >&2
    exit 1
  fi

  C_MED=$(median_udp_pair "$x" "$c_server" "${tag}c_" "$CLIENT" 0)
  echo "C -O2 recvmmsg/sendmmsg ${name} median real: ${C_MED}s"

  SHUX_MED=$(median_udp_pair "$x" "$c_server" "$tag" "$CLIENT" 1)
  echo "Shu (udp_*_many_buf) ${name} median real: ${SHUX_MED}s"

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Shu (udp_*_many_buf) | %s |\n' "$SHUX_MED"
  printf '| C -O2 recvmmsg/sendmmsg | %s |\n' "$C_MED"
  printf '\n'

  check_net_regress "$name" "$SHUX_MED"
  NET_CASE_MEDS="${NET_CASE_MEDS}${name}:${SHUX_MED};"
}

if [ "$DO_BENCH" -eq 0 ]; then
  echo "run-perf-net: use --bench to run net_accept_many + net_echo_throughput + net_mixed + net_udp_many"
  exit 0
fi

BASELINE="${SHUX_PERF_NET_BASELINE:-tests/baseline/net-perf.tsv}"
LAT_BASELINE="${SHUX_PERF_NET_LATENCY_BASELINE:-tests/baseline/net-perf-latency.tsv}"
bench_net_accept_case net_accept_many tests/bench/net_accept_many.x tests/bench/net_accept_many_server.c
bench_net_echo_case net_echo_throughput tests/bench/net_echo_throughput.x \
  tests/bench/net_echo_throughput_server.c tests/bench/net_echo_throughput.c
bench_net_mixed_case net_mixed_conns_requests tests/bench/net_mixed_conns_requests.x \
  tests/bench/net_mixed_conns_requests_server.c tests/bench/net_mixed_conns_requests.c
if [ "$(uname -s)" = "Linux" ]; then
  # shellcheck source=tests/lib/io-uring-probe.sh
  . tests/lib/io-uring-probe.sh
  if io_uring_available; then
    chmod +x tests/run-provided-buffers.sh 2>/dev/null || true
    ./tests/run-provided-buffers.sh
    bench_net_echo_provided_case net_echo_throughput_provided tests/bench/net_echo_throughput_provided.x \
      tests/bench/net_echo_throughput_server.c
  else
    echo "ZC-1 provided bench SKIP (io_uring unavailable on this kernel; e.g. Mac Docker linuxkit)"
  fi
fi
bench_net_udp_case net_udp_many tests/bench/net_udp_many.x tests/bench/net_udp_many_server.c

if [ "${SHUX_PERF_UPDATE_NET_BASELINE:-0}" = "1" ]; then
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
    echo "# shux net bench 中位数上限（秒）；门禁：实测 median ≤ 本列值"
    echo "# 更新：SHUX_PERF_UPDATE_NET_BASELINE=1 ./tests/run-perf-net.sh --bench"
    for c in net_accept_many net_echo_throughput net_echo_throughput_provided net_mixed_conns_requests net_udp_many; do
      grep "^${c}	" "${BASELINE}.body" 2>/dev/null || true
    done
  } >"$BASELINE"
  rm -f "${BASELINE}.body"
  echo "run-perf-net: updated $BASELINE"
fi

if [ "${SHUX_PERF_UPDATE_NET_BASELINE:-0}" = "1" ] && [ -n "$NET_CASE_P99S" ]; then
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
    echo "# 更新：SHUX_PERF_UPDATE_NET_BASELINE=1 ./tests/run-perf-net.sh --bench"
    grep "^net_mixed_conns_requests_p99	" "${LAT_BASELINE}.body" 2>/dev/null || true
  } >"$LAT_BASELINE"
  rm -f "${LAT_BASELINE}.body"
  echo "run-perf-net: updated $LAT_BASELINE"
fi

echo "=== net perf OK ==="
