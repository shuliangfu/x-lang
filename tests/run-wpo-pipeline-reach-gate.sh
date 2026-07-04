#!/usr/bin/env bash
# S5：pipeline_wpo.o 编排链 reach 门禁（run_x_pipeline_impl 不应 U 其 direct callee）。
# ast_pool.c fixpoint + strict preserve 后须重编 pipeline_wpo.o（build_shux_asm post-strict）。
# 用法：
#   ./tests/run-wpo-pipeline-reach-gate.sh
#   SHUX_WPO_PIPELINE_REACH_FAIL=1 ./tests/run-wpo-pipeline-reach-gate.sh
set -e
cd "$(dirname "$0")/.."

PIPE_O="${1:-compiler/build_asm/pipeline_wpo.o}"
FAIL=${SHUX_WPO_PIPELINE_REACH_FAIL:-1}
MIN_EXPORTS=${SHUX_WPO_PIPELINE_MIN_EXPORTS:-12}

if [ ! -f "$PIPE_O" ]; then
  echo "run-wpo-pipeline-reach-gate SKIP: missing $PIPE_O"
  exit 0
fi

if ! nm "$PIPE_O" 2>/dev/null | grep -q 'run_x_pipeline_impl'; then
  echo "run-wpo-pipeline-reach-gate FAIL: $PIPE_O missing run_x_pipeline_impl" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

# run_x_pipeline_impl 直接 callee：WPO reach 修复后须在 pipeline_wpo.o 内定义（非 U）。
MISSING=""
for sym in \
  run_x_pipeline_parse_entry_if_needed \
  run_x_pipeline_typecheck_entry \
  run_x_pipeline_codegen_deps \
  run_x_pipeline_codegen_entry; do
  if nm "$PIPE_O" 2>/dev/null | grep -q " U ${sym}$"; then
    MISSING="${MISSING} ${sym}"
  fi
done

EXPORTS=$(nm "$PIPE_O" 2>/dev/null | awk '/ T / { c++ } END { print c+0 }')

echo "run-wpo-pipeline-reach-gate: $PIPE_O exports=${EXPORTS} (min=${MIN_EXPORTS})"

gate_fail=0
if [ -n "$MISSING" ]; then
  echo "run-wpo-pipeline-reach-gate FAIL: run_x_pipeline_impl undefined callee(s):${MISSING}" >&2
  echo "  hint: touch compiler/ast_pool.c && SHUX_WPO_REBUILD_ARTIFACTS_ONLY=1 ./compiler/scripts/build_shux_asm.sh" >&2
  gate_fail=1
fi

if [ "$EXPORTS" -lt "$MIN_EXPORTS" ] 2>/dev/null; then
  echo "run-wpo-pipeline-reach-gate FAIL: export count ${EXPORTS} < min ${MIN_EXPORTS}" >&2
  gate_fail=1
fi

if [ "$gate_fail" -ne 0 ]; then
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "run-wpo-pipeline-reach-gate OK (orchestration callee defined, exports=${EXPORTS})"
