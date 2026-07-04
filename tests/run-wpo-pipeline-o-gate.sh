#!/usr/bin/env bash
# S5：build_asm/pipeline_wpo.o WPO 生产链硬门禁（WPO 压缩 pipeline.x dogfood）。
# strict 链仍用全量 build_asm/pipeline.o；本门禁仅验 pipeline_wpo.o。
# 用法：
#   ./tests/run-wpo-pipeline-o-gate.sh
#   ./tests/run-wpo-pipeline-o-gate.sh compiler/build_asm/pipeline_wpo.o
#   SHUX_WPO_PIPELINE_O_FAIL=1 ./tests/run-wpo-pipeline-o-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-ab-proxy.sh
. tests/lib/wpo-ab-proxy.sh

PIPE_O="${1:-compiler/build_asm/pipeline_wpo.o}"
BASELINE="${SHUX_WPO_PIPELINE_O_BASELINE:-tests/baseline/wpo-pipeline-o.tsv}"
MAX_TEXT=$(awk -F'\t' '$1=="pipeline_wpo_max_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MAX_TEXT=${MAX_TEXT:-2048}
MIN_SAVE=$(awk -F'\t' '$1=="pipeline_wpo_min_save_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_SAVE=${MIN_SAVE:-8000}
OFF_PROXY=$(awk -F'\t' '$1=="pipeline_dce_off_text" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
OFF_PROXY=${OFF_PROXY:-11588}
FAIL=${SHUX_WPO_PIPELINE_O_FAIL:-1}

if [ ! -f "$PIPE_O" ]; then
  echo "run-wpo-pipeline-o-gate FAIL: missing $PIPE_O" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

TXT=$(wpo_ab_text_bytes "$PIPE_O") || {
  echo "run-wpo-pipeline-o-gate FAIL: cannot read .text from $PIPE_O" >&2
  exit 1
}

if ! nm "$PIPE_O" 2>/dev/null | grep -q 'run_x_pipeline_impl'; then
  echo "run-wpo-pipeline-o-gate FAIL: $PIPE_O missing run_x_pipeline_impl" >&2
  exit 1
fi

SAVE=$((OFF_PROXY - TXT))
echo "wpo pipeline_wpo.o gate: $PIPE_O __text=${TXT}B (max=${MAX_TEXT}B, save=${SAVE}B vs proxy off=${OFF_PROXY}B)"

if [ "$TXT" -gt "$MAX_TEXT" ] 2>/dev/null; then
  echo "run-wpo-pipeline-o-gate WARN: __text ${TXT}B > cap ${MAX_TEXT}B" >&2
  [ "$FAIL" = "1" ] && exit 1
fi
if [ "$SAVE" -lt "$MIN_SAVE" ] 2>/dev/null; then
  echo "run-wpo-pipeline-o-gate FAIL: save ${SAVE}B < min ${MIN_SAVE}B" >&2
  [ "$FAIL" = "1" ] && exit 1
fi

# 编排链 reach：run_x_pipeline_impl 不应 U 其 direct callee（须 ast_pool fixpoint 后重编 pipeline_wpo.o）。
if [ -x "$(dirname "$0")/run-wpo-pipeline-reach-gate.sh" ]; then
  SHUX_WPO_PIPELINE_REACH_FAIL="${SHUX_WPO_PIPELINE_REACH_FAIL:-0}" \
    "$(dirname "$0")/run-wpo-pipeline-reach-gate.sh" "$PIPE_O" || {
    [ "$FAIL" = "1" ] && exit 1
  }
fi

echo "wpo pipeline_wpo.o gate OK (__text=${TXT}B <= ${MAX_TEXT}B, save=${SAVE}B, run_x_pipeline_impl present)"
