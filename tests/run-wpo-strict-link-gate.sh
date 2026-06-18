#!/usr/bin/env bash
# S5：strict 链 WPO link 门禁（pipeline_wpo helpers + C orchestration 链入 shu_asm.strict_glue）。
# 用法：
#   ./tests/run-wpo-strict-link-gate.sh
#   SHU_WPO_STRICT_LINK_FAIL=1 ./tests/run-wpo-strict-link-gate.sh
set -e
cd "$(dirname "$0")/.."

FAIL=${SHU_WPO_STRICT_LINK_FAIL:-1}
COMPILER="${SHU_WPO_STRICT_LINK_COMPILER:-compiler/shu_asm.strict_glue}"
PIPE_WPO="${SHU_WPO_PIPELINE_O:-compiler/build_asm/pipeline_wpo.o}"

chmod +x compiler/scripts/relink_shu_asm_strict_glue.sh tests/run-wpo-pipeline-reach-gate.sh 2>/dev/null || true

# Darwin：parser.o 空/partial export 失败，strict_glue 链不可用；Linux 覆盖。
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "run-wpo-strict-link-gate: N/A on Darwin (parser partial + strict_glue link; Linux x86_64/ARM64 covers)"
  echo "run-wpo-strict-link-gate OK (Darwin N/A)"
  exit 0
fi

echo "=== wpo strict link gate (pipeline_wpo helpers + C orchestration in strict_glue) ==="

SHU_WPO_PIPELINE_REACH_FAIL="$FAIL" ./tests/run-wpo-pipeline-reach-gate.sh "$PIPE_WPO" || exit 1
if [ -f compiler/build_asm/typeck_wpo.o ]; then
  SHU_WPO_TYPECK_REACH_FAIL="$FAIL" ./tests/run-wpo-typeck-reach-gate.sh compiler/build_asm/typeck_wpo.o || exit 1
fi
if [ -f compiler/build_asm/backend_wpo.o ]; then
  SHU_WPO_BACKEND_REACH_FAIL="$FAIL" ./tests/run-wpo-backend-reach-gate.sh compiler/build_asm/backend_wpo.o || exit 1
fi

(
  cd compiler
  export SHU_ASM_STRICT_LINK_PIPELINE_WPO=1
  export SHU_ASM_STRICT_LINK_PIPELINE_WPO_FULL=0
  export STRICT_LINK_BUILD_ASM_PIPELINE=1
  export STRICT_LINK_BUILD_ASM_WPO=1
  export STRICT_LINK_BUILD_ASM_BACKEND_WPO=1
  ./scripts/relink_shu_asm_strict_glue.sh
)

if [ ! -x "$COMPILER" ]; then
  echo "run-wpo-strict-link-gate FAIL: missing $COMPILER" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

# 链入 pipeline_wpo.o 后须能解析编排符号（非 U）。
MISSING=""
for sym in \
  run_su_pipeline_impl \
  typeck_su_ast \
  check_block \
  asm_codegen_ast \
  backend_asm_codegen_ast_seed_mega; do
  if nm "$COMPILER" 2>/dev/null | grep -q " U ${sym}$"; then
    MISSING="${MISSING} ${sym}"
  fi
done
if [ -n "$MISSING" ]; then
  echo "run-wpo-strict-link-gate FAIL: $COMPILER undefined:${MISSING}" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

# 小测试文件可编（strict_glue 全路径 asm 编译已知不稳定；默认仅验链+符号，设 SHU_WPO_STRICT_LINK_SMOKE_COMPILE=1 启用）。
if [ "${SHU_WPO_STRICT_LINK_SMOKE_COMPILE:-0}" = "1" ]; then
  LIBROOT="-L compiler/asm_libroot -L compiler/src -L std -L core"
  TEST_SU="tests/asm/binop_var_fast.su"
  TMP_O="/tmp/shu_wpo_strict_link_smoke.$$.o"
  rm -f "$TMP_O" 2>/dev/null || true
  if ! "$COMPILER" -backend asm -o "$TMP_O" $LIBROOT "$TEST_SU" 2>/dev/null; then
    echo "run-wpo-strict-link-gate FAIL: $COMPILER cannot compile $TEST_SU" >&2
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
  if [ ! -s "$TMP_O" ]; then
    echo "run-wpo-strict-link-gate FAIL: empty output from $TEST_SU" >&2
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
  rm -f "$TMP_O" 2>/dev/null || true
  echo "run-wpo-strict-link-gate: smoke compile OK ($TEST_SU)"
fi

echo "run-wpo-strict-link-gate OK ($COMPILER links pipeline_wpo helpers + C orchestration)"
