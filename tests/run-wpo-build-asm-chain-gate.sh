#!/usr/bin/env bash
# S5：build_asm 五模块 WPO 生产链聚合门禁（main + driver + pipeline_wpo + typeck_wpo + backend_wpo）。
# 用法：
#   ./tests/run-wpo-build-asm-chain-gate.sh
#   SHU_WPO_CHAIN_FAIL=1 ./tests/run-wpo-build-asm-chain-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-ab-proxy.sh
. tests/lib/wpo-ab-proxy.sh

BUILD_ASM="${1:-compiler/build_asm}"
FAIL=${SHU_WPO_CHAIN_FAIL:-1}
BASELINE="${SHU_WPO_CHAIN_BASELINE:-tests/baseline/wpo-dce-compiler-self-text.tsv}"

# Darwin：五模块 WPO .o 链（尤其 main.o）在 gen_driver hybrid 上不可用；Linux 覆盖 chain save 门禁。
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "wpo build_asm chain: N/A on Darwin (main.o WPO + parser partial; Linux x86_64/ARM64 covers)"
  echo "wpo build_asm chain gate OK (Darwin N/A)"
  exit 0
fi

chmod +x tests/ensure-wpo-build-asm-artifacts.sh tests/run-wpo-main-o-gate.sh tests/run-wpo-driver-o-gate.sh \
  tests/run-wpo-pipeline-o-gate.sh tests/run-wpo-typeck-o-gate.sh tests/run-wpo-backend-o-gate.sh

if [ "${SHU_WPO_ENSURE_ARTIFACTS:-1}" = "1" ]; then
  SHU_WPO_ENSURE_FAIL="$FAIL" ./tests/ensure-wpo-build-asm-artifacts.sh
fi

chmod +x tests/run-wpo-build-asm-chain-gate.sh 2>/dev/null || true

echo "=== wpo build_asm chain gate (main+driver+pipeline_wpo+typeck_wpo+backend_wpo) ==="

SHU_WPO_MAIN_O_FAIL="$FAIL" ./tests/run-wpo-main-o-gate.sh "$BUILD_ASM/main.o"
SHU_WPO_DRIVER_O_FAIL="$FAIL" ./tests/run-wpo-driver-o-gate.sh "$BUILD_ASM/driver_compile.o"
SHU_WPO_PIPELINE_O_FAIL="$FAIL" ./tests/run-wpo-pipeline-o-gate.sh "$BUILD_ASM/pipeline_wpo.o"
SHU_WPO_TYPECK_O_FAIL="$FAIL" ./tests/run-wpo-typeck-o-gate.sh "$BUILD_ASM/typeck_wpo.o"
SHU_WPO_BACKEND_O_FAIL="$FAIL" ./tests/run-wpo-backend-o-gate.sh "$BUILD_ASM/backend_wpo.o"

# 汇总 wpo-eligible .text（与 perf 脚本一致）。
sum_eligible() {
  local dir="$1"
  local total=0 t
  for o in main.o driver_compile.o pipeline_wpo.o typeck_wpo.o backend_wpo.o; do
    if [ -f "$dir/$o" ]; then
      t=$(wpo_ab_text_bytes "$dir/$o" 2>/dev/null) || t=0
      total=$((total + t))
    fi
  done
  echo "$total"
}

ON=$(sum_eligible "$BUILD_ASM")
OFF=$(awk -F'\t' '
  $1=="main_dce_off_text" && $1 !~ /^#/ { m=$2 }
  $1=="driver_dce_off_text" && $1 !~ /^#/ { d=$2 }
  $1=="pipeline_dce_off_text" && $1 !~ /^#/ { p=$2 }
  $1=="typeck_dce_off_text" && $1 !~ /^#/ { t=$2 }
  $1=="backend_dce_off_text" && $1 !~ /^#/ { b=$2 }
  END { print m+d+p+t+b }
' "$BASELINE")
SAVE=$((OFF - ON))
PCT=0
[ "$OFF" -gt 0 ] && PCT=$((SAVE * 100 / OFF))

echo "wpo build_asm chain: eligible on=${ON}B off_proxy=${OFF}B save=${SAVE}B (${PCT}%)"
MIN_CHAIN=$(awk -F'\t' '$1=="build_asm_min_text_save_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_CHAIN=${MIN_CHAIN:-50000}
if [ "$SAVE" -lt "$MIN_CHAIN" ] 2>/dev/null; then
  echo "run-wpo-build-asm-chain-gate FAIL: save ${SAVE}B < min ${MIN_CHAIN}B" >&2
  [ "$FAIL" = "1" ] && exit 1
fi

echo "wpo build_asm chain gate OK (save=${SAVE}B >= ${MIN_CHAIN}B)"
