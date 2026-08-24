#!/usr/bin/env bash
# S5：build_asm/pipeline_wpo.o WPO 生产链硬门禁（dogfood from runtime_pipeline_abi.x）。
# G.7: pipeline.x is pure-extern; live orch = runtime_pipeline_abi.x.
# strict 链仍用全量 build_asm/pipeline.o / C orchestration；本门禁仅验 pipeline_wpo.o。
# 用法：
#   ./tests/run-wpo-pipeline-o-gate.sh
#   ./tests/run-wpo-pipeline-o-gate.sh compiler/build_asm/pipeline_wpo.o
#   XLANG_WPO_PIPELINE_O_FAIL=1 ./tests/run-wpo-pipeline-o-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-ab-proxy.sh
. tests/lib/wpo-ab-proxy.sh

PIPE_O="${1:-compiler/build_asm/pipeline_wpo.o}"
BASELINE="${XLANG_WPO_PIPELINE_O_BASELINE:-tests/baseline/wpo-pipeline-o.tsv}"
MAX_TEXT=$(awk -F'\t' '$1=="pipeline_wpo_max_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MAX_TEXT=${MAX_TEXT:-98304}
MIN_SAVE=$(awk -F'\t' '$1=="pipeline_wpo_min_save_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_SAVE=${MIN_SAVE:-0}
OFF_PROXY=$(awk -F'\t' '$1=="pipeline_dce_off_text" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
OFF_PROXY=${OFF_PROXY:-40000}
FAIL=${XLANG_WPO_PIPELINE_O_FAIL:-1}

if [ ! -f "$PIPE_O" ] || [ ! -s "$PIPE_O" ]; then
  echo "run-wpo-pipeline-o-gate FAIL: missing or empty $PIPE_O" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

TXT=$(wpo_ab_text_bytes "$PIPE_O") || {
  echo "run-wpo-pipeline-o-gate FAIL: cannot read .text from $PIPE_O" >&2
  exit 1
}

# PLATFORM: SHARED — product name is pipeline_run_x_pipeline_impl; bare
# run_x_pipeline_impl also matches (substring / historical X emit).
if ! nm "$PIPE_O" 2>/dev/null | grep -qE '(_)?(pipeline_)?run_x_pipeline_impl'; then
  echo "run-wpo-pipeline-o-gate FAIL: $PIPE_O missing pipeline_run_x_pipeline_impl/run_x_pipeline_impl" >&2
  exit 1
fi

SAVE=$((OFF_PROXY - TXT))
echo "wpo pipeline_wpo.o gate: $PIPE_O __text=${TXT}B (max=${MAX_TEXT}B, save=${SAVE}B vs proxy off=${OFF_PROXY}B)"

if [ "$TXT" -gt "$MAX_TEXT" ] 2>/dev/null; then
  # Post-compress tip ~37KiB; soft WARN like main. Hard FAIL only STRICT_SIZE=1.
  echo "run-wpo-pipeline-o-gate WARN: __text ${TXT}B > soft cap ${MAX_TEXT}B (post-compress orch)" >&2
  if [ "${XLANG_WPO_PIPELINE_STRICT_SIZE:-0}" = "1" ] && [ "$FAIL" = "1" ]; then
    exit 1
  fi
fi
if [ "$MIN_SAVE" -gt 0 ] && [ "$SAVE" -lt "$MIN_SAVE" ] 2>/dev/null; then
  echo "run-wpo-pipeline-o-gate WARN: save ${SAVE}B < min ${MIN_SAVE}B (pipeline_wpo soft)" >&2
  if [ "${XLANG_WPO_PIPELINE_STRICT_SIZE:-0}" = "1" ] && [ "$FAIL" = "1" ]; then
    exit 1
  fi
fi

# 编排链 reach：pipeline_run_x_pipeline_impl 不应 U 其 direct callee。
if [ -x "$(dirname "$0")/run-wpo-pipeline-reach-gate.sh" ]; then
  XLANG_WPO_PIPELINE_REACH_FAIL="${XLANG_WPO_PIPELINE_REACH_FAIL:-0}" \
    "$(dirname "$0")/run-wpo-pipeline-reach-gate.sh" "$PIPE_O" || {
    [ "$FAIL" = "1" ] && exit 1
  }
fi

echo "wpo pipeline_wpo.o gate OK (__text=${TXT}B, pipeline_run_x_pipeline_impl present, reach soft)"
