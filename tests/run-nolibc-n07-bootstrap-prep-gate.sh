#!/usr/bin/env bash
# NL-07 v1: compiler bootstrap no-libc prep gate (manifest + lc track).
#
# Usage: ./tests/run-nolibc-n07-bootstrap-prep-gate.sh
#        XLANG_NOLIBC_N07_MANIFEST_ONLY=1 ./tests/run-nolibc-n07-bootstrap-prep-gate.sh
#        XLANG_NOLIBC_N07_LC_HARD=1 ./tests/run-nolibc-n07-bootstrap-prep-gate.sh
# Honesty: soft XLANG_NOLIBC_N07_FAIL retired — die→exit0 was portable false-green.
# Report doc=/manifest=/lc=/b32=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

LC_HARD=${XLANG_NOLIBC_N07_LC_HARD:-0}
DOC="${XLANG_NOLIBC_N07_DOC:-analysis/archive/phase/phase-f-n07-v1.md}"
MANIFEST="tests/baseline/nolibc-n07-bootstrap-prep.tsv"
LC_BASELINE="tests/baseline/nolibc-n07-bootstrap-lc-track.tsv"
BUILD_ASM="compiler/scripts/build_xlang_asm.sh"
PREFIX="xlang: [XLANG_NOLIBC_N07]"

DOC_OK=0
MANIFEST_OK=0
LC_OK=0
B32_OK=0
SKIP=1

die() {
  echo "nolibc-n07 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK} manifest=${MANIFEST_OK} lc=${LC_OK} b32=${B32_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

echo "=== NL-07: compiler bootstrap no-libc prep (honesty) ==="
if [ -f analysis/phase-f-n07-v1.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'NL-07 v1' "$DOC" || die "doc missing NL-07 v1 marker"
grep -qE '^## Gate$' "$DOC" || die "phase-f-n07-v1.md missing ## Gate honesty section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f "$LC_BASELINE" ] || die "missing $LC_BASELINE"
[ -f "$BUILD_ASM" ] || die "missing $BUILD_ASM"
DOC_OK=1

# shellcheck source=tests/lib/nolibc-n07-bootstrap-audit.sh
. tests/lib/nolibc-n07-bootstrap-audit.sh

if ! nolibc_n07_audit_manifest "$MANIFEST"; then
  die "NL-07 bootstrap prep manifest audit failed"
fi
MANIFEST_OK=1

if ! nolibc_n07_audit_lc_baseline "$LC_BASELINE" "$LC_HARD"; then
  die "NL-07 lc baseline audit failed"
fi
LC_OK=1

lc_n=$(nolibc_n07_count_lc_link_cmds "$BUILD_ASM")
std_c_n=$(nolibc_n07_count_ensure_std_c "$BUILD_ASM")
echo "nolibc-n07: lc_link_cmds=${lc_n} ensure_std_c=${std_c_n} (track-only until NL-07 v2)"

if [ "${XLANG_NOLIBC_N07_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "nolibc-n07 gate OK (manifest + lc track only)"
  echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} lc=${LC_OK} b32=${B32_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if [ -f tests/run-b32-no-cc-std-gate.sh ]; then
  echo "=== NL-07: delegate run-b32-no-cc-std-gate (B-32 track) ==="
  chmod +x tests/run-b32-no-cc-std-gate.sh
  ./tests/run-b32-no-cc-std-gate.sh || die "B-32 cc-std track failed"
  B32_OK=1
fi
SKIP=0

echo "nolibc-n07 gate OK (bootstrap -lc/.c track; enable nostdlib → NL-07 v2)"
echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} lc=${LC_OK} b32=${B32_OK} skip=${SKIP} host=$(ci_host_summary)"
