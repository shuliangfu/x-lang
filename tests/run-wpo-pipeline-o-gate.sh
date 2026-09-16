#!/usr/bin/env bash
# S5: build_asm/pipeline_wpo.o WPO production-chain hard gate (dogfood from
# runtime_pipeline_abi.x). G.7: pipeline.x is pure-extern; live orch =
# runtime_pipeline_abi.x. Strict chain still uses full build_asm/pipeline.o /
# C orchestration; this gate only checks pipeline_wpo.o.
#
# Honesty: parent must not force XLANG_WPO_PIPELINE_REACH_FAIL=0 — reach is
# hard (soft "reach soft" OK retired). Missing .o is hard die. Soft size
# overage (post-compress orch tip > TSV soft cap) is obs, not silent OK and
# not hard-fail (Darwin heat / mega ban; STRICT_SIZE=1 still hard).
#
# Usage:
#   ./tests/run-wpo-pipeline-o-gate.sh
#   ./tests/run-wpo-pipeline-o-gate.sh compiler/build_asm/pipeline_wpo.o
# Report: run=/obs=/skip=
# PLATFORM: SHARED — product name pipeline_run_x_pipeline_impl; bare
# run_x_pipeline_impl also matches (substring / historical X emit).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-ab-proxy.sh
. tests/lib/wpo-ab-proxy.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

PIPE_O="${1:-compiler/build_asm/pipeline_wpo.o}"
BASELINE="${XLANG_WPO_PIPELINE_O_BASELINE:-tests/baseline/wpo-pipeline-o.tsv}"
MAX_TEXT=$(awk -F'\t' '$1=="pipeline_wpo_max_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MAX_TEXT=${MAX_TEXT:-98304}
MIN_SAVE=$(awk -F'\t' '$1=="pipeline_wpo_min_save_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_SAVE=${MIN_SAVE:-0}
OFF_PROXY=$(awk -F'\t' '$1=="pipeline_dce_off_text" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
OFF_PROXY=${OFF_PROXY:-40000}
PREFIX="xlang: [XLANG_WPO_PIPELINE_O]"
OBS=0

die() {
  echo "run-wpo-pipeline-o-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=0 obs=${OBS} skip=0 host=$(ci_host_summary)"
  exit 1
}

if [ ! -f "$PIPE_O" ] || [ ! -s "$PIPE_O" ]; then
  die "missing or empty $PIPE_O (refuse soft SKIP→OK)"
fi

TXT=$(wpo_ab_text_bytes "$PIPE_O") || die "cannot read .text from $PIPE_O"

if ! nm "$PIPE_O" 2>/dev/null | grep -qE '(_)?(pipeline_)?run_x_pipeline_impl'; then
  die "$PIPE_O missing pipeline_run_x_pipeline_impl/run_x_pipeline_impl"
fi

SAVE=$((OFF_PROXY - TXT))
echo "wpo pipeline_wpo.o gate: $PIPE_O __text=${TXT}B (max=${MAX_TEXT}B, save=${SAVE}B vs proxy off=${OFF_PROXY}B)"

if [ "$TXT" -gt "$MAX_TEXT" ] 2>/dev/null; then
  # Post-compress tip may exceed soft TSV cap; product obs (not silent OK).
  echo "run-wpo-pipeline-o-gate OBS: __text ${TXT}B > soft cap ${MAX_TEXT}B (post-compress orch; product residual)" >&2
  OBS=1
  if [ "${XLANG_WPO_PIPELINE_STRICT_SIZE:-0}" = "1" ]; then
    die "__text ${TXT}B > soft cap ${MAX_TEXT}B (STRICT_SIZE=1)"
  fi
fi
if [ "$MIN_SAVE" -gt 0 ] && [ "$SAVE" -lt "$MIN_SAVE" ] 2>/dev/null; then
  echo "run-wpo-pipeline-o-gate OBS: save ${SAVE}B < min ${MIN_SAVE}B (pipeline_wpo soft save floor)" >&2
  OBS=1
  if [ "${XLANG_WPO_PIPELINE_STRICT_SIZE:-0}" = "1" ]; then
    die "save ${SAVE}B < min ${MIN_SAVE}B (STRICT_SIZE=1)"
  fi
fi

"$(dirname "$0")/run-wpo-pipeline-reach-gate.sh" "$PIPE_O" || die "reach gate failed"

echo "wpo pipeline_wpo.o gate OK (__text=${TXT}B, pipeline_run_x_pipeline_impl present, reach hard)"
echo "${PREFIX} status=ok run=1 obs=${OBS} skip=0 host=$(ci_host_summary)"
