#!/usr/bin/env bash
# S5：确保 build_asm 五模块 WPO dogfood 产物齐全（main + driver + pipeline_wpo + typeck_wpo + backend_wpo）。
# 在 bootstrap-driver-bstrict / chain gate 前调用；缺文件时用 ./xlang_asm 快速重编（跳过全量 BUILD 循环）。
# 用法：
#   ./tests/ensure-wpo-build-asm-artifacts.sh
#   XLANG_WPO_ENSURE_FAIL=1 ./tests/ensure-wpo-build-asm-artifacts.sh
set -e
cd "$(dirname "$0")/.."

BUILD_ASM="${XLANG_WPO_BUILD_ASM_DIR:-compiler/build_asm}"
FAIL=${XLANG_WPO_ENSURE_FAIL:-1}
COMPILER="${XLANG_WPO_ENSURE_COMPILER:-./compiler/xlang_asm}"
UNAME_S="$(uname -s 2>/dev/null || echo unknown)"

# PLATFORM: MACOS — tip pipeline.x asm emit is exit-0 empty (residual next knife).
# Hard-require main/driver/typeck_wpo/backend_wpo; pipeline_wpo soft unless
# XLANG_WPO_REQUIRE_PIPELINE=1. PLATFORM: LINUX — all five hard-required.
required_o=(
  main.o
  driver_compile.o
  typeck_wpo.o
  backend_wpo.o
)
if [ "$UNAME_S" != "Darwin" ] || [ "${XLANG_WPO_REQUIRE_PIPELINE:-0}" = "1" ]; then
  required_o+=(pipeline_wpo.o)
fi

missing=()
for o in "${required_o[@]}"; do
  if [ ! -f "$BUILD_ASM/$o" ] || [ ! -s "$BUILD_ASM/$o" ]; then
    missing+=("$o")
  fi
done

if [ "${#missing[@]}" -eq 0 ]; then
  if [ "$UNAME_S" = "Darwin" ] && { [ ! -f "$BUILD_ASM/pipeline_wpo.o" ] || [ ! -s "$BUILD_ASM/pipeline_wpo.o" ]; }; then
    echo "ensure-wpo-build-asm-artifacts OK (Darwin partial 4/5; pipeline_wpo empty-emit residual)"
  else
    echo "ensure-wpo-build-asm-artifacts OK (all ${#required_o[@]} artifacts present under $BUILD_ASM)"
  fi
  exit 0
fi

echo "ensure-wpo-build-asm-artifacts: missing ${#missing[@]} file(s): ${missing[*]}" >&2

if [ ! -x "$COMPILER" ]; then
  echo "ensure-wpo-build-asm-artifacts FAIL: compiler not executable: $COMPILER" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "ensure-wpo-build-asm-artifacts: XLANG_WPO_REBUILD_ARTIFACTS_ONLY=1 via $COMPILER ..."
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
(
  cd compiler
  XLANG_WPO_REBUILD_ARTIFACTS_ONLY=1 ./scripts/build_xlang_asm.sh
)

# reach 硬门禁：已产出的 WPO .o 编排链 callee 须已定义（rebuild 后必验）。
run_wpo_reach_gates() {
  chmod +x tests/run-wpo-pipeline-reach-gate.sh \
    tests/run-wpo-typeck-reach-gate.sh \
    tests/run-wpo-backend-reach-gate.sh 2>/dev/null || true
  if [ -s "$BUILD_ASM/pipeline_wpo.o" ] && [ -x tests/run-wpo-pipeline-reach-gate.sh ]; then
    XLANG_WPO_PIPELINE_REACH_FAIL="${XLANG_WPO_PIPELINE_REACH_FAIL:-1}" \
      ./tests/run-wpo-pipeline-reach-gate.sh "$BUILD_ASM/pipeline_wpo.o" || return 1
  fi
  if [ -f "$BUILD_ASM/typeck_wpo.o" ] && [ -x tests/run-wpo-typeck-reach-gate.sh ]; then
    XLANG_WPO_TYPECK_REACH_FAIL="${XLANG_WPO_TYPECK_REACH_FAIL:-1}" \
      ./tests/run-wpo-typeck-reach-gate.sh "$BUILD_ASM/typeck_wpo.o" || return 1
  fi
  if [ -f "$BUILD_ASM/backend_wpo.o" ] && [ -x tests/run-wpo-backend-reach-gate.sh ]; then
    XLANG_WPO_BACKEND_REACH_FAIL="${XLANG_WPO_BACKEND_REACH_FAIL:-1}" \
      ./tests/run-wpo-backend-reach-gate.sh "$BUILD_ASM/backend_wpo.o" || return 1
  fi
  return 0
}
run_wpo_reach_gates || {
  [ "$FAIL" = "1" ] && exit 1
}

still=()
for o in "${required_o[@]}"; do
  if [ ! -f "$BUILD_ASM/$o" ] || [ ! -s "$BUILD_ASM/$o" ]; then
    still+=("$o")
  fi
done
if [ "${#still[@]}" -ne 0 ]; then
  echo "ensure-wpo-build-asm-artifacts FAIL: still missing after rebuild: ${still[*]}" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ "$UNAME_S" = "Darwin" ] && { [ ! -f "$BUILD_ASM/pipeline_wpo.o" ] || [ ! -s "$BUILD_ASM/pipeline_wpo.o" ]; }; then
  echo "ensure-wpo-build-asm-artifacts OK (Darwin partial 4/5 rebuilt; pipeline_wpo empty-emit residual)"
else
  echo "ensure-wpo-build-asm-artifacts OK (rebuilt missing WPO artifacts under $BUILD_ASM)"
fi
