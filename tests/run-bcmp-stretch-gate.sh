#!/usr/bin/env bash
# L2 B-CMP stretch 门禁：xlang_asm -O3 中位数须 ≤ 0.95× C -O3（四例 microbench）。
# 与 GHA ci-full-suite 解耦：CI 硬门禁为 1.0× codegen；本脚本为 xlang_asm stretch 目标。
# 用法：
#   ./tests/run-bcmp-stretch-gate.sh
#   XLANG_PERF_FAIL_ON_C_O3=1 ./tests/run-bcmp-stretch-gate.sh   # 等同默认
#   XLANG_PERF_C_O3_RATIO=0.95 ./tests/run-bcmp-stretch-gate.sh
set -e
cd "$(dirname "$0")/.."
chmod +x tests/run-perf-baseline.sh
XLANG_PERF_FAIL_ON_C_O3=1 XLANG_PERF_FAIL_ON_ZIG=0 XLANG_PERF_BCMP_ASM=1 \
  XLANG_PERF_STRETCH_ASM_ONLY=1 XLANG_PERF_C_O3_RATIO="${XLANG_PERF_C_O3_RATIO:-0.95}" \
  ./tests/run-perf-baseline.sh --bench | tee /tmp/bcmp_stretch.log
grep -q 'perf baseline OK' /tmp/bcmp_stretch.log
echo "bcmp stretch gate OK (xlang_asm ≤${XLANG_PERF_C_O3_RATIO:-0.95}× C -O3 on loop_i32/mem_copy/struct_param/call_boundary)"
