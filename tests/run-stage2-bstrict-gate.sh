#!/usr/bin/env bash
# M5 Stage2 硬门禁：在已有 shu_asm（gen1）上跑二遍自举 → shu_asm2，验 42/hello/struct_mk。
# 与 verify-selfhost-stage2-bstrict.sh 相同验收；默认 SHU_STAGE2_SKIP_BOOTSTRAP=1 跳过重复 bootstrap。
# 用法（仓库根）：
#   ./tests/run-stage2-bstrict-gate.sh
#   SHU_STAGE2_SKIP_BOOTSTRAP=0 ./tests/run-stage2-bstrict-gate.sh   # 含 Step 0 全量 bootstrap
set -e
cd "$(dirname "$0")/.."

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "stage2-bstrict-gate: N/A on Darwin (strict_glue/parser partial; Linux x86_64/ARM64 covers)"
  echo "stage2-bstrict-gate OK (Darwin N/A)"
  exit 0
fi

if [ ! -x compiler/shu_asm ]; then
  echo "stage2-bstrict-gate FAIL: compiler/shu_asm missing (make -C compiler bootstrap-driver-bstrict)" >&2
  exit 1
fi

if [ ! -x compiler/shu ] && [ ! -x compiler/shu-su ]; then
  echo "stage2-bstrict-gate FAIL: seed shu missing (make -C compiler OPT=1 all)" >&2
  exit 1
fi

chmod +x compiler/verify-selfhost-stage2-bstrict.sh tests/run-bootstrap-stage2-bstrict.sh 2>/dev/null || true

export SHU_STAGE2_SKIP_BOOTSTRAP="${SHU_STAGE2_SKIP_BOOTSTRAP:-1}"
echo "stage2-bstrict-gate: verify-selfhost-stage2-bstrict (SKIP_BOOTSTRAP=${SHU_STAGE2_SKIP_BOOTSTRAP}) ..."
(
  cd compiler
  export SHU_STAGE2_SKIP_BOOTSTRAP
  # CI=1 时 round2 须全量 B-strict；与 verify Step 2 一致，门禁入口也清 CI fast 变量。
  env -u CI \
    SHU_ASM_CI_SKIP_FAST=1 \
    SHU_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY= \
    SHU_ASM_CI_SKIP_SECOND_PASS= \
    bash ./verify-selfhost-stage2-bstrict.sh
)

echo "stage2-bstrict-gate OK (gen1/gen2 parity: 42 + hello + struct_mk inline)"
