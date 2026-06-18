#!/usr/bin/env bash
# P1 性能门禁：对齐 Linux CI perf 步骤（本地 push 前自检）。
# Linux + io_uring 可用时额外跑 ZC-1（provided vs batch -10%），与 ci.yml Net perf 一致。
# 用法：./tests/run-perf-p1-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/ensure-compiler-seed.sh
source "$(dirname "$0")/lib/ensure-compiler-seed.sh"

echo "=== perf P1 gate: compute baseline (Zig) ==="
SHU_PERF_FAIL_ON_ZIG=1 ./tests/run-perf-baseline.sh --bench | tee /tmp/perf_p1_baseline.log
grep -q 'perf baseline OK' /tmp/perf_p1_baseline.log

echo "=== perf P1 gate: B-CMP (Shu -O3 codegen-fair vs C -O3, 1.0×) ==="
chmod +x tests/run-bcmp-gate.sh
./tests/run-bcmp-gate.sh | tee /tmp/perf_p1_bcmp.log

echo "=== perf P1 gate: IO (Zig + regression) ==="
SHU_PERF_FAIL_ON_IO_ZIG=1 SHU_PERF_FAIL_ON_IO_REGRESSION=1 ./tests/run-perf-io.sh --bench | tee /tmp/perf_p1_io.log
grep -q 'io perf OK' /tmp/perf_p1_io.log

echo "=== perf P1 gate: net (regression; Linux io_uring 时含 ZC-1 --perf) ==="
chmod +x tests/run-perf-net.sh tests/run-zc1-gate.sh 2>/dev/null || true
if [ "$(uname -s)" = "Linux" ]; then
  # shellcheck source=tests/lib/io-uring-probe.sh
  . tests/lib/io-uring-probe.sh
  if io_uring_available; then
    ./tests/run-zc1-gate.sh --perf | tee /tmp/perf_p1_net.log
  else
    echo "perf P1 gate: ZC-1 SKIP (io_uring unavailable on this kernel)"
    SHU_PERF_FAIL_ON_NET_REGRESSION=1 ./tests/run-perf-net.sh --bench | tee /tmp/perf_p1_net.log
    grep -q 'net perf OK' /tmp/perf_p1_net.log
  fi
else
  SHU_PERF_FAIL_ON_NET_REGRESSION=1 ./tests/run-perf-net.sh --bench | tee /tmp/perf_p1_net.log
  grep -q 'net perf OK' /tmp/perf_p1_net.log
fi

echo "=== perf P1 gate: compile dogfood (PERF-004) ==="
chmod +x tests/run-perf-compile-dogfood-gate.sh
./tests/run-perf-compile-dogfood-gate.sh | tee /tmp/perf_p1_dogfood.log
grep -qE 'compile dogfood OK|perf-compile-dogfood gate OK' /tmp/perf_p1_dogfood.log

echo "perf P1 gate OK (baseline + io + net + compile dogfood)"
