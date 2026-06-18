#!/usr/bin/env bash
# S5 WPO stretch 门禁：shu_asm 全链 binary proxy 须 ≥ 3%（strict bstrict 后实锤）。
# CI-fast 仅 ~0.8% proxy，勿在默认 job 硬开；bootstrap-driver-bstrict + build_asm 齐全后跑本脚本。
# 用法：
#   ./tests/run-wpo-stretch-gate.sh
#   SHU=./compiler/shu_asm ./tests/run-wpo-stretch-gate.sh
set -e
cd "$(dirname "$0")/.."
SHU="${SHU:-./compiler/shu_asm}"
if [ ! -x "$SHU" ]; then
  echo "wpo stretch gate: SKIP (no shu_asm: $SHU)" >&2
  exit 0
fi
chmod +x tests/run-perf-wpo-dce-shu-asm-text.sh
SHU="$SHU" SHU_WPO_STRETCH_3PCT=1 SHU_PERF_FAIL_ON_WPO_SHU_ASM_TEXT=1 \
  ./tests/run-perf-wpo-dce-shu-asm-text.sh | tee /tmp/wpo_stretch_3pct.log
grep -q 'wpo shu_asm text OK' /tmp/wpo_stretch_3pct.log
echo "wpo stretch gate OK (binary proxy save ≥ 3%)"
