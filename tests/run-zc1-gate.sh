#!/usr/bin/env bash
# ZC-1 Provided Buffers 一键门禁：io_uring 探测 → pipe smoke →（可选）net perf -10%
#
# 用法：
#   ./tests/run-zc1-gate.sh           # 仅 smoke（Linux + io_uring；否则 SKIP exit 0）
#   ./tests/run-zc1-gate.sh --perf    # smoke + 全量 net perf（与 ci.yml Net perf 对齐）
#
# 环境变量（--perf 时）：
#   SHU_PERF_FAIL_ON_NET_REGRESSION=1 — 默认随 --perf 开启
#   SHU_PERF_FAIL_ON_ZC1=1            — provided echo 须比 batch 快 ≥10%
#   SHU_NET_RUNS=1                    — CI=1 时 run-perf-net 默认已为 1
set -e
cd "$(dirname "$0")/.."

DO_PERF=0
for arg in "$@"; do
  case "$arg" in
    --perf) DO_PERF=1 ;;
    -h|--help)
      echo "Usage: $0 [--perf]"
      exit 0
      ;;
    *)
      echo "run-zc1-gate: unknown arg: $arg" >&2
      exit 2
      ;;
  esac
done

chmod +x tests/run-provided-buffers.sh tests/lib/io-uring-probe.sh 2>/dev/null || true
if [ "$DO_PERF" -eq 1 ]; then
  chmod +x tests/run-perf-net.sh 2>/dev/null || true
  make -C compiler -q 2>/dev/null || make -C compiler
  make -C compiler ../std/net/net.o ../std/thread/thread.o ../std/io/io.o -q 2>/dev/null \
    || make -C compiler ../std/net/net.o ../std/thread/thread.o ../std/io/io.o
fi

echo "=== ZC-1: provided buffers smoke ==="
./tests/run-provided-buffers.sh | tee /tmp/zc1_smoke.log

if grep -q "provided buffers smoke SKIP" /tmp/zc1_smoke.log; then
  if [ -n "${SHU_CI_NO_SKIP:-}" ] && [ "$(uname -s)" = "Linux" ]; then
    echo "ZC-1 gate FAIL: provided buffers skipped on Linux (SHU_CI_NO_SKIP=1)" >&2
    exit 1
  fi
  echo "ZC-1 gate SKIP (io_uring unavailable; e.g. Mac Docker linuxkit → defer to GitHub CI ubuntu)"
  if [ "$DO_PERF" -eq 1 ]; then
    exit 0
  fi
  echo "ZC-1 gate OK (smoke skipped)"
  exit 0
fi

if grep -q "provided buffers smoke FAIL" /tmp/zc1_smoke.log; then
  echo "ZC-1 gate FAIL (provided buffers smoke failed)" >&2
  exit 1
fi

grep -q "provided buffers smoke OK" /tmp/zc1_smoke.log

if [ "$DO_PERF" -eq 0 ]; then
  echo "ZC-1 gate OK (smoke)"
  exit 0
fi

echo "=== ZC-1: net perf (provided vs batch -10%) ==="
SHU_PERF_FAIL_ON_NET_REGRESSION=1 SHU_PERF_FAIL_ON_ZC1=1 SHU_NET_RUNS="${SHU_NET_RUNS:-1}" \
  ./tests/run-perf-net.sh --bench | tee /tmp/zc1_perf.log
grep -q 'net perf OK' /tmp/zc1_perf.log
grep -qE 'ZC-1 provided bench OK|net_echo_throughput_provided' /tmp/zc1_perf.log
grep -q 'ZC-1 provided vs batch OK' /tmp/zc1_perf.log
echo "ZC-1 gate OK (smoke + perf)"
