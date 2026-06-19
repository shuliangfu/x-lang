#!/usr/bin/env bash
# track-only：整颗 pipeline_wpo.o SU 编排链入 strict_glue（SHUX_ASM_STRICT_LINK_PIPELINE_WPO_FULL=1）。
# 链接 + return-value/hello 编译运行须成功（2026-06-10：+ pipeline_su_glue_support astpool 桥接）。
# 用法：
#   ./tests/run-pipeline-wpo-full-link-smoke.sh
#   SHUX_PIPELINE_WPO_FULL_COMPILE_FAIL=1 ./tests/run-pipeline-wpo-full-link-smoke.sh  # 同默认（硬门禁）
set -e
cd "$(dirname "$0")/.."

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "pipeline-wpo-full-link: N/A on Darwin"
  exit 0
fi

if [ ! -x compiler/shux ] && [ ! -x compiler/shux-sx ]; then
  echo "pipeline-wpo-full-link: SKIP (no seed shux)"
  exit 0
fi

chmod +x tests/ensure-wpo-build-asm-artifacts.sh compiler/scripts/relink_shux_asm_strict_glue.sh
SHUX_WPO_REBUILD_ARTIFACTS_ONLY=1 ./tests/ensure-wpo-build-asm-artifacts.sh

if [ ! -f compiler/build_asm/pipeline_wpo.o ]; then
  echo "pipeline-wpo-full-link: SKIP (no pipeline_wpo.o)"
  exit 0
fi

echo "pipeline-wpo-full-link: relink strict_glue (whole pipeline_wpo.o) ..."
rm -f compiler/build_asm/pipeline_strict_link_partial.o \
  compiler/build_asm/pipeline_wpo_helpers_partial.o \
  compiler/build_asm/asm_shux_lsp_diag_stub.o \
  compiler/build_asm/typeck_lsp_io_stub.o
(
  cd compiler
  export SHUX_ASM_STRICT_LINK_PIPELINE_WPO=1
  export SHUX_ASM_STRICT_LINK_PIPELINE_WPO_FULL=1
  export STRICT_LINK_BUILD_ASM_PIPELINE=1
  ./scripts/relink_shux_asm_strict_glue.sh 2>&1 | tee /tmp/pipeline_wpo_full_relink.log
)

if ! grep -q 'whole pipeline_wpo.o' /tmp/pipeline_wpo_full_relink.log; then
  echo "pipeline-wpo-full-link FAIL: relink log missing whole pipeline_wpo.o line" >&2
  exit 1
fi
if ! grep -q 'pipeline_sx glue support (FULL wpo' /tmp/pipeline_wpo_full_relink.log; then
  echo "pipeline-wpo-full-link FAIL: relink log missing pipeline_sx glue support (FULL) line" >&2
  exit 1
fi

if [ ! -x compiler/shux_asm.strict_glue ]; then
  echo "pipeline-wpo-full-link FAIL: shux_asm.strict_glue not built" >&2
  tail -n 8 /tmp/pipeline_wpo_full_relink.log >&2 || true
  exit 1
fi

if ! nm compiler/shux_asm.strict_glue 2>/dev/null | grep -qE ' T run_sx_pipeline_impl$'; then
  echo "pipeline-wpo-full-link FAIL: strict_glue missing T run_sx_pipeline_impl" >&2
  exit 1
fi

OUT="/tmp/shux_wpo_full_rv"
rm -f "$OUT"
RC=0
(
  cd compiler
  ulimit -s 65532 2>/dev/null || true
  ./shux_asm.strict_glue ../tests/return-value/main.sx -o "$OUT" -backend asm
) || RC=$?

if [ "$RC" -ne 0 ] || [ ! -x "$OUT" ]; then
  echo "pipeline-wpo-full-link FAIL: compile rc=$RC" >&2
  exit 1
fi
RUN_RC=0
"$OUT" || RUN_RC=$?
if [ "$RUN_RC" -ne 42 ]; then
  echo "pipeline-wpo-full-link FAIL: run exit $RUN_RC (expected 42)" >&2
  exit 1
fi

HELLO_OUT="/tmp/shux_wpo_full_hello"
rm -f "$HELLO_OUT"
(
  cd compiler
  ulimit -s 65532 2>/dev/null || true
  ./shux_asm.strict_glue -L "$(pwd)/.." ../examples/hello.sx -o "$HELLO_OUT" -backend asm
)
if [ ! -x "$HELLO_OUT" ] || ! "$HELLO_OUT" | grep -q "Hello World"; then
  echo "pipeline-wpo-full-link FAIL: hello compile/run" >&2
  exit 1
fi

echo "pipeline-wpo-full-link OK (whole pipeline_wpo.o + glue support, return-value 42 + hello)"
