#!/usr/bin/env bash
# L0 网络性能基线（NEXT N1/N2/N3/N4）：accept_many + echo batch + UDP buf 批量
# 用法：./tests/run-perf-net.sh [--bench]
# 门禁（可选）：
#   SHU_PERF_FAIL_ON_NET_REGRESSION=1 — Shu default asm ≤ tests/baseline/net-perf.tsv
#   SHU_PERF_FAIL_ON_ZC1=1 — Linux：provided echo 须比 batch 中位数快 ≥10%
#   SHU_PERF_UPDATE_NET_BASELINE=1 — 用本次 median 刷新 net-perf.tsv
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
make -C compiler ../std/net/net.o ../std/thread/thread.o -q 2>/dev/null || make -C compiler ../std/net/net.o ../std/thread/thread.o

NET_BENCH_PORT_DEFAULT=38456
NET_ECHO_PORT_DEFAULT=38457
NET_UDP_PORT_DEFAULT=38458
NET_BENCH_CONNS="${SHU_NET_BENCH_CONNS:-1024}"
NET_UDP_PKTS="${SHU_NET_UDP_PKTS:-1024}"
NET_UDP_BATCH=8
NET_UDP_PKT_LEN=64

bench_cleanup_stale() {
  pkill -f '/tmp/bench_net_' 2>/dev/null || true
  if command -v lsof >/dev/null 2>&1; then
    lsof -ti :"${NET_BENCH_PORT_DEFAULT}" 2>/dev/null | xargs kill -9 2>/dev/null || true
    lsof -ti :"${NET_ECHO_PORT_DEFAULT}" 2>/dev/null | xargs kill -9 2>/dev/null || true
    lsof -ti :"${NET_UDP_PORT_DEFAULT}" 2>/dev/null | xargs kill -9 2>/dev/null || true
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

compile_shu_su() {
  local src_template="$1"
  local port_marker="$2"
  local port="$3"
  local out="$4"
  rm -f "$out"
  sed -e "s/${port_marker}/${port}/g" "$src_template" >"/tmp/bench_net_src_${port}.su"
  if ! ./compiler/shu -L . "/tmp/bench_net_src_${port}.su" -o "$out" >/tmp/bench_net_compile.log 2>&1; then
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
      "$src_template" >"/tmp/bench_net_src_${port}.su"
  if ! ./compiler/shu -L . "/tmp/bench_net_src_${port}.su" -o "$out" >/tmp/bench_net_compile.log 2>&1; then
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
      "$src_template" >"/tmp/bench_net_src_${port}.su"
  if ! ./compiler/shu -L . "/tmp/bench_net_src_${port}.su" -o "$out" >/tmp/bench_net_compile.log 2>&1; then
    cat /tmp/bench_net_compile.log >&2
    return 1
  fi
  [ -x "$out" ]
}

DO_BENCH=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
# CI 默认 1 轮 median，本地可 SHU_NET_RUNS=3
RUNS="${SHU_NET_RUNS:-$([ "${CI:-0}" = "1" ] && echo 1 || echo 3)}"
[ "${SHU_PERF_FAIL_ON_NET_REGRESSION:-0}" = "1" ] && PERF_FAIL_REGRESS=1 || PERF_FAIL_REGRESS=0
[ "${SHU_PERF_FAIL_ON_ZC1:-0}" = "1" ] && PERF_FAIL_ZC1=1 || PERF_FAIL_ZC1=0
NET_CASE_MEDS=""

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
      "$su_template" >"/tmp/bench_net_accept.su"
  if ! ./compiler/shu -L . "/tmp/bench_net_accept.su" -o "$shu_exe" >/tmp/bench_net_compile.log 2>&1; then
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
  awk -F'\t' -v n="$name" '$1==n && $1 !~ /^#/ { print $2; exit }' "${SHU_PERF_NET_BASELINE:-tests/baseline/net-perf.tsv}"
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
      if awk -v shu="$shu_med" -v cap="$cap" 'BEGIN { exit (shu <= cap + 0.000001) ? 0 : 1 }'; then
        echo "net perf baseline OK: ${name} ${shu_med}s <= cap ${cap}s"
      else
        echo "net perf baseline FAIL: ${name} ${shu_med}s > cap ${cap}s" >&2
        exit 1
      fi
    fi
  fi
}

bench_net_accept_case() {
  local name="$1"
  local su="$2"
  local c_server="$3"
  local tag="${name}_"
  local SHU_MED="nan"
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

  SHU_MED=$(median_accept_pair "$su" "$c_server" "$tag" "$CLIENT")
  echo "Shu (default asm) ${name} median real: ${SHU_MED}s"

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Shu (default asm) | %s |\n' "$SHU_MED"
  printf '| C -O2 accept loop | %s |\n' "$C_MED"
  printf '\n'

  check_net_regress "$name" "$SHU_MED"
  NET_CASE_MEDS="${NET_CASE_MEDS}${name}:${SHU_MED};"
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
    if ! ./compiler/shu -L . "$su_template" -o "$exe" >/tmp/bench_net_compile.log 2>&1; then
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
  local SHU_MED="nan"
  local C_MED="nan"

  echo "=== tests/bench/${name} (4×4KiB×1024 echo @ 127.0.0.1:<dynamic>, default ${NET_ECHO_PORT_DEFAULT}) ==="

  SHU_MED=$(median_echo_pair "$su_client" "$c_server" "$c_client" "$tag" 1)
  echo "Shu (stream_*_batch) ${name} median real: ${SHU_MED}s"

  C_MED=$(median_echo_pair "$su_client" "$c_server" "$c_client" "$tag" 0)
  echo "C -O2 readv/writev ${name} median real: ${C_MED}s"

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Shu (stream_*_batch) | %s |\n' "$SHU_MED"
  printf '| C -O2 readv/writev | %s |\n' "$C_MED"
  printf '\n'

  check_net_regress "$name" "$SHU_MED"
  NET_CASE_MEDS="${NET_CASE_MEDS}${name}:${SHU_MED};"
  bench_cleanup_stale
}

# ZC-1 echo：读 provided / 写 batch；仅 Linux io_uring provide_buffers 有效。
bench_net_echo_provided_case() {
  local name="$1"
  local su_client="$2"
  local c_server="$3"
  local tag="${name}_"
  local SHU_MED="nan"
  local BATCH_MED="nan"

  echo "=== tests/bench/${name} (ZC-1 provided read + batch write @ 127.0.0.1:<dynamic>) ==="

  SHU_MED=$(median_echo_pair "$su_client" "$c_server" tests/bench/net_echo_throughput.c "$tag" 1)
  echo "Shu (stream_read_batch_provided) ${name} median real: ${SHU_MED}s"

  BATCH_MED=$(net_case_median_from_meds net_echo_throughput || true)
  if [ -z "$BATCH_MED" ]; then
    BATCH_MED=$(net_baseline_cap net_echo_throughput)
  fi
  if [ -n "$BATCH_MED" ] && [ "$SHU_MED" != "nan" ]; then
    ratio=$(awk -v p="$SHU_MED" -v b="$BATCH_MED" 'BEGIN { if (b>0) printf "%.1f", (1.0-p/b)*100.0; else print "0" }')
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
  printf '| Shu (provided read) | %s |\n' "$SHU_MED"
  printf '\n'

  check_net_regress "$name" "$SHU_MED"
  NET_CASE_MEDS="${NET_CASE_MEDS}${name}:${SHU_MED};"
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
        "$su_template" >"/tmp/bench_net_udp.su"
    if ! ./compiler/shu -L . "/tmp/bench_net_udp.su" -o "$exe" >/tmp/bench_net_compile.log 2>&1; then
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
  local su="$2"
  local c_server="$3"
  local tag="${name}_"
  local SHU_MED="nan"
  local C_MED="nan"
  local CLIENT="/tmp/bench_net_udp_client_${tag}"

  echo "=== tests/bench/${name} (${NET_UDP_PKTS} pkts×${NET_UDP_PKT_LEN}B batch=${NET_UDP_BATCH} @ 127.0.0.1:<dynamic>) ==="

  if ! cc -O2 tests/bench/net_udp_many_client.c -o "$CLIENT" 2>/dev/null; then
    echo "run-perf-net: failed to build udp client" >&2
    exit 1
  fi

  C_MED=$(median_udp_pair "$su" "$c_server" "${tag}c_" "$CLIENT" 0)
  echo "C -O2 recvmmsg/sendmmsg ${name} median real: ${C_MED}s"

  SHU_MED=$(median_udp_pair "$su" "$c_server" "$tag" "$CLIENT" 1)
  echo "Shu (udp_*_many_buf) ${name} median real: ${SHU_MED}s"

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Shu (udp_*_many_buf) | %s |\n' "$SHU_MED"
  printf '| C -O2 recvmmsg/sendmmsg | %s |\n' "$C_MED"
  printf '\n'

  check_net_regress "$name" "$SHU_MED"
  NET_CASE_MEDS="${NET_CASE_MEDS}${name}:${SHU_MED};"
}

if [ "$DO_BENCH" -eq 0 ]; then
  echo "run-perf-net: use --bench to run net_accept_many + net_echo_throughput + net_udp_many"
  exit 0
fi

BASELINE="${SHU_PERF_NET_BASELINE:-tests/baseline/net-perf.tsv}"
bench_net_accept_case net_accept_many tests/bench/net_accept_many.su tests/bench/net_accept_many_server.c
bench_net_echo_case net_echo_throughput tests/bench/net_echo_throughput.su \
  tests/bench/net_echo_throughput_server.c tests/bench/net_echo_throughput.c
if [ "$(uname -s)" = "Linux" ]; then
  # shellcheck source=tests/lib/io-uring-probe.sh
  . tests/lib/io-uring-probe.sh
  if io_uring_available; then
    chmod +x tests/run-provided-buffers.sh 2>/dev/null || true
    ./tests/run-provided-buffers.sh
    bench_net_echo_provided_case net_echo_throughput_provided tests/bench/net_echo_throughput_provided.su \
      tests/bench/net_echo_throughput_server.c
  else
    echo "ZC-1 provided bench SKIP (io_uring unavailable on this kernel; e.g. Mac Docker linuxkit)"
  fi
fi
bench_net_udp_case net_udp_many tests/bench/net_udp_many.su tests/bench/net_udp_many_server.c

if [ "${SHU_PERF_UPDATE_NET_BASELINE:-0}" = "1" ]; then
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
    echo "# shu net bench 中位数上限（秒）；门禁：实测 median ≤ 本列值"
    echo "# 更新：SHU_PERF_UPDATE_NET_BASELINE=1 ./tests/run-perf-net.sh --bench"
    for c in net_accept_many net_echo_throughput net_echo_throughput_provided net_udp_many; do
      grep "^${c}	" "${BASELINE}.body" 2>/dev/null || true
    done
  } >"$BASELINE"
  rm -f "${BASELINE}.body"
  echo "run-perf-net: updated $BASELINE"
fi

echo "=== net perf OK ==="
