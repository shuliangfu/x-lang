#!/usr/bin/env bash
# I6 A/B：io_uring ring 512 vs 2048；read_batch 普通 vs fixed buffer（Linux io_uring 有意义）
# 用法：./tests/run-perf-io-ring-ab.sh
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

BENCH_MMAP_FILE="tests/bench/.io_mmap_bench_tmp"
BENCH_MB="${SHUX_IO_BENCH_MB:-16}"
RUNS=3

extract_real_sec() {
  sed -n 's/^real[[:space:]]*\([0-9]*\)m\([0-9.]*\)s.*/\1 \2/p; s/^real[[:space:]]*\([0-9.]*\)s.*/0 \1/p' | awk 'NF==2 { print $1*60+$2; next } NF==1 { print $1 }'
}

median_real() {
  local exe="$1"
  local i vals med
  vals=""
  for i in $(seq 1 "$RUNS"); do
    vals=$( ( time "$exe" >/dev/null ) 2>&1 | extract_real_sec; printf '\n%s' "$vals" )
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "$med"
}

ensure_io_mmap_bench_file() {
  rm -f "$BENCH_MMAP_FILE"
  python3 -c "
import os
p='$BENCH_MMAP_FILE'
os.makedirs(os.path.dirname(p), exist_ok=True)
n=int(${BENCH_MB})*1024*1024
with open(p,'wb') as f:
    for i in range(n):
        f.write(bytes([i & 255]))
" 2>/dev/null || dd if=/dev/zero of="$BENCH_MMAP_FILE" bs=1048576 count="$BENCH_MB" 2>/dev/null
  [ -f "$BENCH_MMAP_FILE" ] || { echo "run-perf-io-ring-ab: failed to create $BENCH_MMAP_FILE" >&2; exit 1; }
}

bench_one() {
  local label="$1"
  local su="$2"
  local ring="$3"
  local out="/tmp/bench_io_ring_ab_${label}"
  export SHUX_IO_URING_RING_ENTRIES="$ring"
  ./compiler/shux -L . "$su" -o "$out" 2>&1
  if [ ! -x "$out" ]; then
    echo "nan"
    return
  fi
  median_real "$out"
}

ensure_io_mmap_bench_file

echo "=== I6 io_uring ring / fixed buffer A/B (${BENCH_MB}MiB read_batch_fd) ==="
if [ "$(uname -s)" != "Linux" ]; then
  echo "note: ring size A/B 仅在 Linux io_uring 生效；本机 $(uname -s) 仍跑 fixed vs 普通对照。"
fi

M512=$(bench_one "512" tests/bench/io_batch_readv.sx 512)
M2048=$(bench_one "2048" tests/bench/io_batch_readv.sx 2048)
MFIX=$(bench_one "fixed512" tests/bench/io_batch_readv_fixed.sx 512)

printf '\n| 配置 | median real (s) |\n'
printf '|---|----------------|\n'
printf '| read_batch ring=512 | %s |\n' "$M512"
printf '| read_batch ring=2048 | %s |\n' "$M2048"
printf '| read_batch + fixed buf (ring=512) | %s |\n' "$MFIX"
printf '\n'

rm -f "$BENCH_MMAP_FILE"
echo "io ring A/B OK"
