#!/usr/bin/env bash
# Sync EMIT_HEAVY typeck.o into compiler/build_asm/ for S2 gate / strict chain.
#
# Honesty: soft XLANG_S2_FAIL_ON_EMIT_HEAVY retired. Delegates size floors to
# run-s2-typeck-emit-heavy.sh (hard on Linux gold; skip on Darwin N/A).
# When emit-heavy skip=1, this script skips too (no false-green write).
#
# Usage: ./tests/run-s2-typeck-sync-build-o.sh
# Report: run=/obs=/skip=
# PLATFORM: LINUX|UBUNTU x86_64 gold; DARWIN N/A when emit-heavy skips.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. ./tests/lib/ci-host.sh

DEST="compiler/build_asm/typeck.o"
BASELINE="${XLANG_S2_TYPECK_BASELINE:-tests/baseline/s2-typeck-o.tsv}"
MIN_TEXT_EH=$(awk -F'\t' '$1=="min_text_emit_heavy" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT_EH=${MIN_TEXT_EH:-8192}

PREFIX="xlang: [XLANG_S2_TYPECK_SYNC_BUILD_O]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "s2 sync-build-o FAIL: $*" >&2
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

if [ -z "${XLANG_S2_EMIT_HEAVY_COMPILER:-}" ]; then
  for cand in ./compiler/xlang_asm ./compiler/xlang_asm.strict_glue ./compiler/xlang_asm.experimental; do
    if [ -x "$cand" ]; then
      export XLANG_S2_EMIT_HEAVY_COMPILER="$cand"
      break
    fi
  done
fi

eh_log=/tmp/xlang_s2_typeck_emit_heavy_sync.log
set +e
./tests/run-s2-typeck-emit-heavy.sh >"$eh_log" 2>&1
eh_rc=$?
set -e
cat "$eh_log"
if grep -qE 'skip=1' "$eh_log"; then
  SKIP=1
  echo "s2 sync-build-o: emit-heavy N/A — skip write"
  ok_report
  exit 0
fi
if [ "$eh_rc" -ne 0 ]; then
  die "emit-heavy failed"
fi

SRC="/tmp/xlang_s2_typeck_emit_heavy.o"
[ -f "$SRC" ] || die "missing $SRC"

mkdir -p "$(dirname "$DEST")"
cp -f "$SRC" "$DEST"

# layout symbol subset partial: strict chain vs typeck_x_no_layout (S2 same chain)
# shellcheck source=tests/lib/s2-typeck-layout-partial.sh
. "$(dirname "$0")/lib/s2-typeck-layout-partial.sh"
if s2_rebuild_typeck_layout_partial "$DEST"; then
  echo "s2 sync-build-o: rebuilt compiler/build_asm/typeck_asm_layout_partial.o"
else
  OBS=$((OBS + 1))
  echo "s2 sync-build-o: obs — layout partial rebuild failed (strict may duplicate layout)"
fi

sz=$(text_section_size "$DEST")
echo "s2 sync-build-o: wrote $DEST __text=${sz} (min_text_emit_heavy=${MIN_TEXT_EH})"

if ! awk -v s="$sz" -v m="$MIN_TEXT_EH" 'BEGIN { exit (s > m) ? 0 : 1 }'; then
  if ci_is_linux_x64; then
    die "__text ${sz} <= min_text_emit_heavy ${MIN_TEXT_EH}"
  fi
  SKIP=1
  echo "s2 sync-build-o: under on non-gold — N/A (skip=1)"
  ok_report
  exit 0
fi

RUN_OK=1
echo "s2 sync-build-o OK ($DEST)"
ok_report
