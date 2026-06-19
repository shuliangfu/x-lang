#!/usr/bin/env bash
# strict smoke 硬门禁：shux_asm 须为 strict 重链产物（非 experimental fallback），且 compile+run 通过。
# 用法（仓库根）：
#   ./tests/run-strict-smoke-gate.sh
#   BUILD_LOG=/tmp/build_bstrict.log ./tests/run-strict-smoke-gate.sh
set -e
cd "$(dirname "$0")/.."

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

SHUX_ASM=./compiler/shux_asm
BUILD_DIR=./compiler/build_asm
MARKER="$BUILD_DIR/.strict_smoke_experimental_fallback"
STRICT_FAILED="$BUILD_DIR/shux_asm.strict_failed"
BUILD_LOG="${BUILD_LOG:-}"

if [ ! -x "$SHUX_ASM" ]; then
  echo "strict-smoke gate FAIL: $SHUX_ASM missing (make -C compiler bootstrap-driver-bstrict)" >&2
  exit 1
fi

if [ -f "$MARKER" ]; then
  echo "strict-smoke gate FAIL: experimental fallback marker ($MARKER)" >&2
  exit 1
fi

if [ -f "$STRICT_FAILED" ]; then
  echo "strict-smoke gate FAIL: strict binary backup exists ($STRICT_FAILED) — fallback was used" >&2
  exit 1
fi

if [ -n "$BUILD_LOG" ] && [ -f "$BUILD_LOG" ]; then
  if grep -q 'installed shux_asm.experimental as shux_asm (fallback OK)' "$BUILD_LOG"; then
    echo "strict-smoke gate FAIL: build log shows experimental fallback ($BUILD_LOG)" >&2
    exit 1
  fi
  if ! grep -qE 'strict shux_asm smoke passed|SHUX_ASM_SKIP_STRICT_SMOKE' "$BUILD_LOG"; then
    if ! grep -q 'strict smoke failed' "$BUILD_LOG"; then
      echo "strict-smoke gate: warn: no strict smoke pass/skip line in $BUILD_LOG" >&2
    fi
  fi
  if ! grep -qE 'pipeline_asm_orchestration_partial|strict link pipeline_asm_orchestration|pipeline_wpo_helpers|strict link pipeline_wpo_helpers' "$BUILD_LOG"; then
    echo "strict-smoke gate: warn: C orchestration / WPO helpers link line not in $BUILD_LOG" >&2
  fi
fi

# Linux x86_64：编排入口须为 C glue（非 pipeline_wpo SU 入口）；smoke 仅 compile+run（完整 gate 由 run-shux-asm-gate 覆盖）。
case "$(uname -s)-$(uname -m 2>/dev/null)" in
  Linux-x86_64|Linux-amd64)
    if command -v nm >/dev/null 2>&1; then
      if ! nm "$SHUX_ASM" 2>/dev/null | grep -q 'run_sx_pipeline_parse_entry_do_parse_c'; then
        echo "strict-smoke gate FAIL: shux_asm missing run_sx_pipeline_parse_entry_do_parse_c (C orchestration glue)" >&2
        exit 1
      fi
    fi
    ;;
esac

echo "strict-smoke gate: run_shux_asm_smoke (compile+run return-value) ..."
(cd compiler && SHUX_ASM_SMOKE_SKIP_GATE=1 ./scripts/run_shux_asm_smoke.sh)

echo "strict-smoke gate OK (strict shux_asm smoke, no experimental fallback)"
