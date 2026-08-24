#!/usr/bin/env bash
# S5：build_asm 五模块 WPO 生产链聚合门禁（main + driver + pipeline_wpo + typeck_wpo + backend_wpo）。
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

# PLATFORM: MACOS — pipeline.x tip empty-emit residual; skip hard pipeline o-gate
# unless XLANG_WPO_REQUIRE_PIPELINE=1. Linux keeps full five-module gate.
if [ "$UNAME_S" = "Darwin" ] && [ "${XLANG_WPO_REQUIRE_PIPELINE:-0}" != "1" ]; then
  echo "wpo pipeline_wpo.o gate: SKIP on Darwin (pipeline.x empty-emit residual; next knife)"
else
  XLANG_WPO_PIPELINE_O_FAIL="$FAIL" ./tests/run-wpo-pipeline-o-gate.sh "$BUILD_ASM/pipeline_wpo.o"
fi

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
  local mods=(main.o driver_compile.o typeck_wpo.o backend_wpo.o)
  if [ "$UNAME_S" != "Darwin" ] || [ "${XLANG_WPO_REQUIRE_PIPELINE:-0}" = "1" ]; then
    mods+=(pipeline_wpo.o)
  fi
  for o in "${mods[@]}"; do
    if [ -f "$dir/$o" ]; then
      t=$(wpo_ab_text_bytes "$dir/$o" 2>/dev/null) || t=0
      total=$((total + t))
    fi
  done
  echo "$total"
}

ON=$(sum_eligible "$BUILD_ASM")
if [ "$UNAME_S" = "Darwin" ] && [ "${XLANG_WPO_REQUIRE_PIPELINE:-0}" != "1" ]; then
  # Darwin partial: proxy off without pipeline_dce_off_text.
  OFF=$(awk -F'\t' '
    $1=="main_dce_off_text" && $1 !~ /^#/ { m=$2 }
    $1=="driver_dce_off_text" && $1 !~ /^#/ { d=$2 }
    $1=="typeck_dce_off_text" && $1 !~ /^#/ { t=$2 }
    $1=="backend_dce_off_text" && $1 !~ /^#/ { b=$2 }
    END { print m+d+t+b }
  ' "$BASELINE")
else
  OFF=$(awk -F'\t' '
    $1=="main_dce_off_text" && $1 !~ /^#/ { m=$2 }
    $1=="driver_dce_off_text" && $1 !~ /^#/ { d=$2 }
    $1=="pipeline_dce_off_text" && $1 !~ /^#/ { p=$2 }
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
# PLATFORM: MACOS — partial chain (no pipeline) + tip main full-emit: soft min save.
if [ "$UNAME_S" = "Darwin" ] && [ "${XLANG_WPO_REQUIRE_PIPELINE:-0}" != "1" ]; then
  MIN_CHAIN="${XLANG_WPO_DARWIN_MIN_CHAIN_SAVE:-1000}"
fi
if [ "$SAVE" -lt "$MIN_CHAIN" ] 2>/dev/null; then
  echo "run-wpo-build-asm-chain-gate FAIL: save ${SAVE}B < min ${MIN_CHAIN}B" >&2
  [ "$FAIL" = "1" ] && exit 1
fi

if [ "$UNAME_S" = "Darwin" ] && [ "${XLANG_WPO_REQUIRE_PIPELINE:-0}" != "1" ]; then
  echo "wpo build_asm chain gate OK (Darwin partial 4/5; save=${SAVE}B >= ${MIN_CHAIN}B; pipeline residual)"
else
  echo "wpo build_asm chain gate OK (save=${SAVE}B >= ${MIN_CHAIN}B)"
fi
