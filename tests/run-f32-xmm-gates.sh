#!/usr/bin/env bash
# 统一 f32 xmm SysV ABI 门禁（默认开启；legacy 仅 run-abi 内 CLI -legacy-f32-abi 烟测）。
# 覆盖：tests/abi/* 烟测 + DOD-S2 import vec3f_soa_push gp/xmm disasm。
# 用法：
#   SHU=./compiler/shu_asm ./tests/run-f32-xmm-gates.sh
# 文档：compiler/docs/F32_XMM_ABI.md
set -e
cd "$(dirname "$0")/.."

if [ "${SHU_ABI_F32_XMM:-1}" = "0" ]; then
  echo "f32-xmm-gates SKIP (SHU_ABI_F32_XMM=0 legacy path)"
  exit 0
fi

echo "=== f32 xmm gates: ABI smokes + DOD-S2 vec3f push ==="

chmod +x tests/run-abi-f32-xmm-gate.sh tests/run-dod-s2-gate.sh tests/lib/dod-native-exe.sh 2>/dev/null || true

SHU="${SHU:-./compiler/shu_asm}" ./tests/run-abi-f32-xmm-gate.sh
SHU="${SHU:-./compiler/shu_asm}" ./tests/run-dod-s2-gate.sh

echo "f32-xmm-gates OK"
