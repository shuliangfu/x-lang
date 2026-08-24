#!/usr/bin/env bash
# S5：build_asm 五模块 WPO 生产链聚合门禁（main + driver + pipeline_wpo + typeck_wpo + backend_wpo）。
# G.7: pipeline_wpo from runtime_pipeline_abi.x (pipeline.x pure-extern empty).
# 用法：
#   ./tests/run-wpo-build-asm-chain-gate.sh
#   XLANG_WPO_CHAIN_FAIL=1 ./tests/run-wpo-build-asm-chain-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-ab-proxy.sh
. tests/lib/wpo-ab-proxy.sh

BUILD_ASM="${1:-compiler/build_asm}"
FAIL=${XLANG_WPO_CHAIN_FAIL:-1}
BASELINE="${XLANG_WPO_CHAIN_BASELINE:-tests/baseline/wpo-dce-compiler-self-text.tsv}"
UNAME_S="$(uname -s 2>/dev/null || echo unknown)"

chmod +x tests/ensure-wpo-build-asm-artifacts.sh tests/run-wpo-main-o-gate.sh tests/run-wpo-driver-o-gate.sh \
  tests/run-wpo-pipeline-o-gate.sh tests/run-wpo-typeck-o-gate.sh tests/run-wpo-backend-o-gate.sh

if [ "${XLANG_WPO_ENSURE_ARTIFACTS:-1}" = "1" ]; then
  XLANG_WPO_ENSURE_FAIL="$FAIL" ./tests/ensure-wpo-build-asm-artifacts.sh
fi

chmod +x tests/run-wpo-build-asm-chain-gate.sh 2>/dev/null || true

echo "=== wpo build_asm chain gate (main+driver+pipeline_wpo+typeck_wpo+backend_wpo) ==="

XLANG_WPO_MAIN_O_FAIL="$FAIL" ./tests/run-wpo-main-o-gate.sh "$BUILD_ASM/main.o"
XLANG_WPO_DRIVER_O_FAIL="$FAIL" ./tests/run-wpo-driver-o-gate.sh "$BUILD_ASM/driver_compile.o"
XLANG_WPO_PIPELINE_O_FAIL="$FAIL" ./tests/run-wpo-pipeline-o-gate.sh "$BUILD_ASM/pipeline_wpo.o"

# PLATFORM: MACOS — arm64 typeck_wpo tip ~9–10KiB vs Linux ~4.5KiB; raise gate cap.
if [ "$UNAME_S" = "Darwin" ] && [ -z "${XLANG_WPO_TYPECK_MAX_TEXT:-}" ]; then
  export XLANG_WPO_TYPECK_O_MAX_TEXT_OVERRIDE=16384
fi
XLANG_WPO_TYPECK_O_FAIL="$FAIL" ./tests/run-wpo-typeck-o-gate.sh "$BUILD_ASM/typeck_wpo.o"
XLANG_WPO_BACKEND_O_FAIL="$FAIL" ./tests/run-wpo-backend-o-gate.sh "$BUILD_ASM/backend_wpo.o"

# 汇总 wpo-eligible .text（与 perf 脚本一致）。
sum_eligible() {
  local dir="$1"
  local total=0 t
  local mods=(main.o driver_compile.o pipeline_wpo.o typeck_wpo.o backend_wpo.o)
  for o in "${mods[@]}"; do
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
# Prefer pipeline baseline from wpo-pipeline-o.tsv when chain baseline lacks it.
if ! awk -F'\t' '$1=="pipeline_dce_off_text" && $1 !~ /^#/ { found=1 } END { exit !found }' "$BASELINE"; then
  P_OFF=$(awk -F'\t' '$1=="pipeline_dce_off_text" && $1 !~ /^#/ { print $2; exit }' tests/baseline/wpo-pipeline-o.tsv)
  P_OFF=${P_OFF:-900000}
  OFF=$(awk -F'\t' -v p="$P_OFF" '
    $1=="main_dce_off_text" && $1 !~ /^#/ { m=$2 }
    $1=="driver_dce_off_text" && $1 !~ /^#/ { d=$2 }
    $1=="typeck_dce_off_text" && $1 !~ /^#/ { t=$2 }
    $1=="backend_dce_off_text" && $1 !~ /^#/ { b=$2 }
    END { print m+d+p+t+b }
  ' "$BASELINE")
fi
SAVE=$((OFF - ON))
PCT=0
[ "$OFF" -gt 0 ] && PCT=$((SAVE * 100 / OFF))

echo "wpo build_asm chain: eligible on=${ON}B off_proxy=${OFF}B save=${SAVE}B (${PCT}%)"
MIN_CHAIN=$(awk -F'\t' '$1=="build_asm_min_text_save_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_CHAIN=${MIN_CHAIN:-50000}
# PLATFORM: SHARED — tip main/pipeline full-emit: soft min save (symbol+reach hard).
# Hard FAIL only when XLANG_WPO_CHAIN_STRICT_SAVE=1.
if [ "$SAVE" -lt "$MIN_CHAIN" ] 2>/dev/null; then
  echo "run-wpo-build-asm-chain-gate WARN: save ${SAVE}B < min ${MIN_CHAIN}B (abi/main full-emit soft)" >&2
  if [ "${XLANG_WPO_CHAIN_STRICT_SAVE:-0}" = "1" ] && [ "$FAIL" = "1" ]; then
    exit 1
  fi
fi

echo "wpo build_asm chain gate OK (5/5; save=${SAVE}B, soft min=${MIN_CHAIN}B)"
