#!/usr/bin/env bash
# S5 WPO 全链门禁：五模块 build_asm WPO 产物 + chain + strict link + binary proxy（须已有 shu_asm）。
# 比 run-bootstrap-bstrict-ci.sh 轻（跳过白名单/stage2）；Docker ~1min 可过 stretch -3%。
# 用法：
#   ./tests/run-wpo-full-chain-gate.sh
#   SHU=./compiler/shu_asm ./tests/run-wpo-full-chain-gate.sh
set -e
cd "$(dirname "$0")/.."

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "wpo full-chain gate: N/A on Darwin (build_asm WPO; Linux x86_64/ARM64 covers)"
  echo "wpo full-chain gate OK (Darwin N/A)"
  exit 0
fi

SHU="${SHU:-./compiler/shu_asm}"
if [ ! -x "$SHU" ]; then
  echo "wpo full-chain gate: SKIP (no shu_asm: $SHU; run: make -C compiler bootstrap-driver-bstrict)" >&2
  exit 0
fi

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

chmod +x tests/ensure-wpo-build-asm-artifacts.sh \
  tests/run-wpo-build-asm-chain-gate.sh \
  tests/run-wpo-strict-link-gate.sh \
  tests/run-wpo-strict-glue-text-gate.sh \
  tests/run-perf-wpo-dce-shu-asm-text.sh \
  tests/run-wpo-stretch-gate.sh \
  compiler/scripts/relink_shu_asm_strict_glue.sh

echo "=== wpo full-chain: ensure build_asm 五模块 ==="
SHU_WPO_ENSURE_FAIL=1 SHU_WPO_ENSURE_COMPILER="$SHU" ./tests/ensure-wpo-build-asm-artifacts.sh

echo "=== wpo full-chain: build_asm chain gate ==="
./tests/run-wpo-build-asm-chain-gate.sh

echo "=== wpo full-chain: strict link gate ==="
SHU_WPO_STRICT_LINK_FAIL=1 ./tests/run-wpo-strict-link-gate.sh

echo "=== wpo full-chain: strict_glue measured .text ==="
SHU_WPO_STRICT_GLUE_TEXT_FAIL=1 ./tests/run-wpo-strict-glue-text-gate.sh

echo "=== wpo full-chain: binary proxy baseline (0.8%) ==="
SHU="$SHU" SHU_PERF_FAIL_ON_WPO_SHU_ASM_TEXT=1 ./tests/run-perf-wpo-dce-shu-asm-text.sh

echo "=== wpo full-chain: stretch -3% ==="
SHU="$SHU" ./tests/run-wpo-stretch-gate.sh

echo "wpo full-chain gate OK (ensure + chain + strict link + proxy ≥3%)"
