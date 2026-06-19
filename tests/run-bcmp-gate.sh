#!/usr/bin/env bash
# L2 B-CMP CI 门禁：Shu -O3 codegen-fair 中位数须 ≤ SHUX_PERF_C_O3_RATIO× C -O3（默认 1.0×）。
# GHA 原生 ubuntu x64 由 run-ci-full-suite.sh 调用；本地 push 前自检同参。
# 用法：
#   ./tests/run-bcmp-gate.sh
#   SHUX_PERF_C_O3_RATIO=1.0 ./tests/run-bcmp-gate.sh
set -e
cd "$(dirname "$0")/.."
chmod +x tests/run-perf-baseline.sh
SHUX_PERF_FAIL_ON_C_O3=1 SHUX_PERF_FAIL_ON_ZIG=0 SHUX_PERF_C_O3_RATIO="${SHUX_PERF_C_O3_RATIO:-1.0}" \
  ./tests/run-perf-baseline.sh --bench | tee /tmp/bcmp_gate.log
grep -q 'perf baseline OK' /tmp/bcmp_gate.log
echo "bcmp gate OK (≤${SHUX_PERF_C_O3_RATIO:-1.0}× C -O3 on loop_i32/mem_copy/struct_param/call_boundary)"
