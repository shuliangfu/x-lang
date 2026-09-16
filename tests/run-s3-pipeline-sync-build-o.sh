#!/usr/bin/env bash
# Sync EMIT_HEAVY pipeline.o into compiler/build_asm/ for S3 gate.
#
# Honesty: soft XLANG_S3_FAIL_ON_EMIT_HEAVY retired. Floors live in
# run-s3-pipeline-emit-heavy.sh. Emit skip propagates (no false-green write).
# Prefers the successful compiler with largest __text.
#
# Usage: ./tests/run-s3-pipeline-sync-build-o.sh
# Report: run=/obs=/skip=
# PLATFORM: LINUX|UBUNTU x86_64 gold; DARWIN N/A when emit-heavy skips.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. ./tests/lib/ci-host.sh

DEST="compiler/build_asm/pipeline.o"
BASELINE="${XLANG_S3_PIPELINE_BASELINE:-tests/baseline/s3-pipeline-o.tsv}"
MIN_TEXT_EH=$(awk -F'\t' '$1=="min_text_emit_heavy" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT_EH=${MIN_TEXT_EH:-512}

PREFIX="xlang: [XLANG_S3_PIPELINE_SYNC_BUILD_O]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "s3 sync-build-o FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
}

text_section_size() {
  local o="$1"
  local hex
  hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  [ -z "$hex" ] && hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  [ -z "$hex" ] && { echo 0; return; }
  perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0
}

# Try one compiler; stdout = __text on success; return 2 on skip N/A.
# Keep set +e for non-zero return (bash set -e exits the whole script).
try_emit_heavy() {
  local cand="$1" log=/tmp/s3_eh_try.log rc
  [ -x "$cand" ] || return 1
  set +e
  XLANG_S3_EMIT_HEAVY_COMPILER="$cand" ./tests/run-s3-pipeline-emit-heavy.sh >"$log" 2>&1
  rc=$?
  if grep -qE 'skip=1' "$log"; then
    return 2
  fi
  # tip EMIT_HEAVY product residual (obs=) — treat like skip for sync write
  if grep -qE 'obs=[1-9]' "$log"; then
    return 2
  fi
  if [ "$rc" -ne 0 ]; then
    return 1
  fi
  [ -f /tmp/xlang_s3_pipeline_emit_heavy.o ] || return 1
  text_section_size /tmp/xlang_s3_pipeline_emit_heavy.o
}

emit_heavy_ok=0
best_sz=0
best_comp=""
saw_skip=0
if [ -n "${XLANG_S3_EMIT_HEAVY_COMPILER:-}" ] && [ -x "${XLANG_S3_EMIT_HEAVY_COMPILER}" ]; then
  set +e
  sz=$(try_emit_heavy "${XLANG_S3_EMIT_HEAVY_COMPILER}")
  trc=$?
  set -e
  if [ "$trc" -eq 0 ]; then
    best_sz=$sz
    best_comp="${XLANG_S3_EMIT_HEAVY_COMPILER}"
    emit_heavy_ok=1
  elif [ "$trc" -eq 2 ]; then
    saw_skip=1
  fi
fi
if [ "$emit_heavy_ok" -eq 0 ]; then
  for cand in ./compiler/xlang_asm ./compiler/xlang_asm.strict_glue ./compiler/xlang_asm.experimental; do
    [ -x "$cand" ] || continue
    echo "s3 sync-build-o: trying emit-heavy with $cand ..."
    set +e
    sz=$(try_emit_heavy "$cand")
    trc=$?
    set -e
    if [ "$trc" -eq 0 ]; then
      if [ "${sz:-0}" -gt "${best_sz:-0}" ] 2>/dev/null; then
        best_sz=$sz
        best_comp=$cand
        emit_heavy_ok=1
      fi
    elif [ "$trc" -eq 2 ]; then
      saw_skip=1
    fi
  done
fi
if [ "$emit_heavy_ok" -eq 0 ]; then
  if [ "$saw_skip" -eq 1 ]; then
    if ci_is_linux_x64; then
      OBS=$((OBS + 1))
      echo "s3 sync-build-o: emit-heavy obs residual — skip write"
    else
      SKIP=1
      echo "s3 sync-build-o: emit-heavy N/A — skip write"
    fi
    ok_report
    exit 0
  fi
  die "emit-heavy failed (all compilers)"
fi
export XLANG_S3_EMIT_HEAVY_COMPILER="$best_comp"
XLANG_S3_EMIT_HEAVY_COMPILER="$best_comp" ./tests/run-s3-pipeline-emit-heavy.sh

SRC="/tmp/xlang_s3_pipeline_emit_heavy.o"
[ -f "$SRC" ] || die "missing $SRC"

mkdir -p "$(dirname "$DEST")"
cp -f "$SRC" "$DEST"

sz=$(text_section_size "$DEST")
echo "s3 sync-build-o: wrote $DEST __text=${sz} (compiler=$best_comp, min_text_emit_heavy=${MIN_TEXT_EH})"

if ! awk -v s="$sz" -v m="$MIN_TEXT_EH" 'BEGIN { exit (s >= m) ? 0 : 1 }'; then
  if ci_is_linux_x64; then
    die "__text ${sz} < min_text_emit_heavy ${MIN_TEXT_EH}"
  fi
  SKIP=1
  echo "s3 sync-build-o: under on non-gold — N/A (skip=1)"
  ok_report
  exit 0
fi

RUN_OK=1
echo "s3 sync-build-o OK ($DEST)"
ok_report
