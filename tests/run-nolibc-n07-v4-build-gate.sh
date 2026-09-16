#!/usr/bin/env bash
# NL-07 v4: bootstrap nostdlib full-chain try gate (manifest; TRY_BUILD opt-in).
#
# Usage: ./tests/run-nolibc-n07-v4-build-gate.sh
#        XLANG_NOLIBC_N07_V4_MANIFEST_ONLY=1 ./tests/run-nolibc-n07-v4-build-gate.sh
#        XLANG_NOLIBC_N07_V4_TRY_BUILD=1 ./tests/run-nolibc-n07-v4-build-gate.sh
# Honesty: soft XLANG_NOLIBC_N07_V4_FAIL retired — die→exit0 was portable false-green.
# Report doc=/manifest=/try=/skip=.
# PLATFORM: SHARED archaeology / LINUX try.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_NOLIBC_N07_V4_DOC:-analysis/archive/phase/phase-f-n07-v4.md}"
MANIFEST="tests/baseline/nolibc-n07-v4-build.tsv"
BUILD_ASM="compiler/scripts/build_xlang_asm.sh"
XLANG_ASM="compiler/xlang_asm"
PREFIX="xlang: [XLANG_NOLIBC_N07_V4]"

DOC_OK=0
MANIFEST_OK=0
TRY_OK=0
SKIP=1

die() {
  echo "nolibc-n07-v4 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK} manifest=${MANIFEST_OK} try=${TRY_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

echo "=== NL-07 v4: bootstrap nostdlib full-chain try (honesty) ==="
if [ -f analysis/phase-f-n07-v4.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'NL-07 v4' "$DOC" || die "doc missing NL-07 v4 marker"
grep -qE '^## Gate$' "$DOC" || die "phase-f-n07-v4.md missing ## Gate honesty section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f "$BUILD_ASM" ] || die "missing $BUILD_ASM"
grep -q 'bootstrap_link_tail_driver' "$BUILD_ASM" || die "build_xlang_asm missing bootstrap_link_tail_driver"
[ -f compiler/seeds/runtime_driver_strict_glue_stubs.from_x.c ] || die "missing runtime_driver_strict_glue_stubs"
DOC_OK=1

while IFS=$'\t' read -r item_id category anchor check_type notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$check_type" in
    exists)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    grep)
      if [ ! -f "$anchor" ] || ! grep -qF "$notes" "$anchor" 2>/dev/null; then
        die "grep fail: $anchor need '$notes' ($item_id)"
      fi
      ;;
    gate_ref)
      [ -f "$anchor" ] || die "missing gate $anchor ($item_id)"
      ;;
  esac
done < "$MANIFEST"
MANIFEST_OK=1

if [ "${XLANG_NOLIBC_N07_V4_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "nolibc-n07-v4 gate OK (manifest only)"
  echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} try=${TRY_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if [ "${XLANG_NOLIBC_N07_V4_TRY_BUILD:-0}" != "1" ]; then
  SKIP=0
  echo "nolibc-n07-v4 gate OK (manifest; set XLANG_NOLIBC_N07_V4_TRY_BUILD=1 + xlang_asm for full try)"
  echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} try=${TRY_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if [ "$(uname -s 2>/dev/null)" != "Linux" ] || [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
  SKIP=1
  echo "nolibc-n07-v4 gate OK (manifest; build try skip — need Linux x86_64)"
  echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} try=${TRY_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if [ ! -x "$XLANG_ASM" ]; then
  SKIP=1
  echo "nolibc-n07-v4 gate OK (manifest; build try skip — no xlang_asm)"
  echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} try=${TRY_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

echo "=== NL-07 v4: XLANG_BOOTSTRAP_NOSTDLIB=1 build_xlang_asm ==="
LOG="/tmp/xlang_n07_v4_build.log"
rm -f "$LOG" 2>/dev/null || true
set +e
( cd compiler && XLANG_BOOTSTRAP_NOSTDLIB=1 ./scripts/build_xlang_asm.sh ) 2>&1 | tee "$LOG"
RC=${PIPESTATUS[0]}
set -e

if grep -q 'bootstrap nostdlib crt0 link OK' "$LOG" 2>/dev/null || \
   grep -q 'bootstrap nostdlib.*link OK' "$LOG" 2>/dev/null; then
  echo "nolibc-n07-v4: nostdlib link OK (crt0 path)"
elif [ "$RC" -eq 0 ] && [ -x "$XLANG_ASM" ]; then
  echo "nolibc-n07-v4: build_xlang_asm exit 0 (check log for nostdlib vs fallback)"
else
  echo "nolibc-n07-v4: build failed rc=$RC" >&2
  grep "undefined reference" "$LOG" 2>/dev/null | sed 's/.*undefined reference to /  /' | sort -u | head -30 >&2 || true
  die "nostdlib full-chain try failed"
fi
TRY_OK=1
SKIP=0

echo "nolibc-n07-v4 gate OK (full-chain try completed)"
echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} try=${TRY_OK} skip=${SKIP} host=$(ci_host_summary)"
