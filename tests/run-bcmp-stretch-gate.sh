#!/usr/bin/env bash
# L2 B-CMP stretch 门禁：shu_asm -O3 中位数须 ≤ 0.95× C -O3（四例 microbench）。
# 与 GHA ci-full-suite 解耦：CI 硬门禁为 1.0× codegen；本脚本为 shu_asm stretch 目标。
# 用法：
#   ./tests/run-bcmp-stretch-gate.sh
#   SHU_PERF_FAIL_ON_C_O3=1 ./tests/run-bcmp-stretch-gate.sh   # 等同默认
#   SHU_PERF_C_O3_RATIO=0.95 ./tests/run-bcmp-stretch-gate.sh
set -e
cd "$(dirname "$0")/.."
chmod +x tests/run-perf-baseline.sh
SHU_PERF_FAIL_ON_C_O3=1 SHU_PERF_FAIL_ON_ZIG=0 SHU_PERF_BCMP_ASM=1 \
  SHU_PERF_STRETCH_ASM_ONLY=1 SHU_PERF_C_O3_RATIO="${SHU_PERF_C_O3_RATIO:-0.95}" \
  ./tests/run-perf-baseline.sh --bench | tee /tmp/bcmp_stretch.log
grep -q 'perf baseline OK' /tmp/bcmp_stretch.log
echo "bcmp stretch gate OK (shu_asm ≤${SHU_PERF_C_O3_RATIO:-0.95}× C -O3 on loop_i32/mem_copy/struct_param/call_boundary)"
