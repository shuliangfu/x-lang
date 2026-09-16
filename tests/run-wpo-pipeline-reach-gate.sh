#!/usr/bin/env bash
# S5: pipeline_wpo.o orchestration reach gate (pipeline_run_x_pipeline_impl
# must not leave direct callees undefined).
#
# G.7: dogfood source = runtime_pipeline_abi.x (pipeline.x pure-extern).
# After runtime_pipeline_abi / pipeline.x fixpoint + strict preserve, rebuild
# pipeline_wpo.o (build_xlang_asm post-strict; ast_pool.c left wave309).
#
# Honesty: soft XLANG_WPO_PIPELINE_REACH_FAIL:-0 retired — missing .o soft
# SKIP→OK and soft die→exit0 on U-callees/under-exports were portable
# false-green. Missing artifact is hard die. Parent o-gates must not force
# REACH_FAIL=0 ("reach soft").
#
# Usage:
#   ./tests/run-wpo-pipeline-reach-gate.sh
#   ./tests/run-wpo-pipeline-reach-gate.sh compiler/build_asm/pipeline_wpo.o
# Report: run=/exports=/skip=
# PLATFORM: SHARED — Mach-O may prefix `_`; nm matches both.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

PIPE_O="${1:-compiler/build_asm/pipeline_wpo.o}"
# abi-scale tip exports thousands; keep a modest floor for orch dogfood.
MIN_EXPORTS=${XLANG_WPO_PIPELINE_MIN_EXPORTS:-5}
PREFIX="xlang: [XLANG_WPO_PIPELINE_REACH]"

die() {
  echo "run-wpo-pipeline-reach-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=0 exports=0 skip=0 host=$(ci_host_summary)"
  exit 1
}

if [ ! -f "$PIPE_O" ]; then
  die "missing $PIPE_O (refuse soft SKIP→OK)"
fi

if ! nm "$PIPE_O" 2>/dev/null | grep -qE '(_)?(pipeline_)?run_x_pipeline_impl'; then
  die "$PIPE_O missing pipeline_run_x_pipeline_impl/run_x_pipeline_impl"
fi

# Direct callees must not be undefined bare names (abi uses pipeline_ prefix T).
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

if [ -n "$MISSING" ]; then
  echo "  hint: XLANG_WPO_REBUILD_ARTIFACTS_ONLY=1 ./compiler/scripts/build_xlang_asm.sh (src=runtime_pipeline_abi.x)" >&2
  die "run_x_pipeline_impl undefined callee(s):${MISSING}"
fi

if [ "$EXPORTS" -lt "$MIN_EXPORTS" ] 2>/dev/null; then
  die "export count ${EXPORTS} < min ${MIN_EXPORTS}"
fi

echo "run-wpo-pipeline-reach-gate OK (orchestration callee defined, exports=${EXPORTS})"
echo "${PREFIX} status=ok run=1 exports=${EXPORTS} skip=0 host=$(ci_host_summary)"
