#!/usr/bin/env bash
# S5：pipeline_wpo.o 编排链 reach 门禁（pipeline_run_x_pipeline_impl 不应 U 其 direct callee）。
# G.7: dogfood source = runtime_pipeline_abi.x (pipeline.x pure-extern).
# ast_pool.c fixpoint + strict preserve 后须重编 pipeline_wpo.o（build_xlang_asm post-strict）。
# 用法：
#   ./tests/run-wpo-pipeline-reach-gate.sh
#   XLANG_WPO_PIPELINE_REACH_FAIL=1 ./tests/run-wpo-pipeline-reach-gate.sh
set -e
cd "$(dirname "$0")/.."

PIPE_O="${1:-compiler/build_asm/pipeline_wpo.o}"
FAIL=${XLANG_WPO_PIPELINE_REACH_FAIL:-1}
# abi-scale tip exports thousands; keep a modest floor for orch dogfood.
MIN_EXPORTS=${XLANG_WPO_PIPELINE_MIN_EXPORTS:-5}

if [ ! -f "$PIPE_O" ]; then
  echo "run-wpo-pipeline-reach-gate SKIP: missing $PIPE_O"
  exit 0
fi

if ! nm "$PIPE_O" 2>/dev/null | grep -qE '(_)?(pipeline_)?run_x_pipeline_impl'; then
  echo "run-wpo-pipeline-reach-gate FAIL: $PIPE_O missing pipeline_run_x_pipeline_impl/run_x_pipeline_impl" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

# Direct callees must not be undefined bare names (abi uses pipeline_ prefix T).
# PLATFORM: SHARED — Mach-O may prefix `_`; match both.
MISSING=""
for sym in \
  run_x_pipeline_parse_entry_if_needed \
  run_x_pipeline_typecheck_entry \
  run_x_pipeline_codegen_deps \
  run_x_pipeline_codegen_entry; do
  if nm "$PIPE_O" 2>/dev/null | grep -qE " U (_)?${sym}$"; then
    MISSING="${MISSING} ${sym}"
  fi
done

EXPORTS=$(nm "$PIPE_O" 2>/dev/null | awk '/ T / { c++ } END { print c+0 }')

echo "run-wpo-pipeline-reach-gate: $PIPE_O exports=${EXPORTS} (min=${MIN_EXPORTS})"

gate_fail=0
if [ -n "$MISSING" ]; then
  echo "run-wpo-pipeline-reach-gate FAIL: run_x_pipeline_impl undefined callee(s):${MISSING}" >&2
  echo "  hint: XLANG_WPO_REBUILD_ARTIFACTS_ONLY=1 ./compiler/scripts/build_xlang_asm.sh (src=runtime_pipeline_abi.x)" >&2
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
