#!/usr/bin/env bash
# NL-07 v2 prep: bootstrap nostdlib first-try gate (manifest + stubs .o).
#
# Usage: ./tests/run-nolibc-n07-v2-prep-gate.sh
#        XLANG_NOLIBC_N07_V2_TRY_LINK=1 ./tests/run-nolibc-n07-v2-prep-gate.sh
# Honesty: soft XLANG_NOLIBC_N07_V2_FAIL retired — missing compiler/Makefile
# after MG wave941 was portable false-green (die→exit0). Live authority =
# build_xlang_asm + xlang_compiler_make 0-make hub (refuse Makefile resurrect).
# Report doc=/manifest=/stubs=/io=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_NOLIBC_N07_V2_DOC:-analysis/archive/phase/phase-f-n07-v2.md}"
MANIFEST="tests/baseline/nolibc-n07-v2-prep.tsv"
STUBS="compiler/seeds/bootstrap_nostdlib_stubs.from_x.c"
BUILD_ASM="compiler/scripts/build_xlang_asm.sh"
PREFIX="xlang: [XLANG_NOLIBC_N07_V2]"

DOC_OK=0
MANIFEST_OK=0
STUBS_OK=0
IO_OK=0
SKIP=1

die() {
  echo "nolibc-n07-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK} manifest=${MANIFEST_OK} stubs=${STUBS_OK} io=${IO_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

echo "=== NL-07 v2 prep: bootstrap nostdlib first try (honesty) ==="
if [ -f analysis/phase-f-n07-v2.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild + compiler-make hub)"
fi
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'NL-07 v2' "$DOC" || die "doc missing NL-07 v2 marker"
grep -qE '^## Gate$' "$DOC" || die "phase-f-n07-v2.md missing ## Gate honesty section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f "$STUBS" ] || die "missing $STUBS"
[ -f "$BUILD_ASM" ] || die "missing $BUILD_ASM"
grep -q 'XLANG_BOOTSTRAP_NOSTDLIB' "$BUILD_ASM" || die "build_xlang_asm missing XLANG_BOOTSTRAP_NOSTDLIB"
grep -q 'bootstrap_nostdlib_stubs' "$BUILD_ASM" || die "build_xlang_asm missing bootstrap_nostdlib_stubs"
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

echo "=== NL-07 v2: compile bootstrap_nostdlib_stubs.o (0-make hub) ==="
xlang_compiler_make src/asm/bootstrap_nostdlib_stubs.o >/dev/null 2>&1 \
  || die "ensure bootstrap_nostdlib_stubs.o failed (xlang_compiler_make)"
STUBS_OK=1

if [ "${XLANG_NOLIBC_N07_V2_TRY_LINK:-0}" = "1" ]; then
  if [ "$(uname -s 2>/dev/null)" = "Linux" ] && [ "$(uname -m 2>/dev/null)" = "x86_64" ]; then
    echo "=== NL-07 v2: compile freestanding_io_x86_64.o (link smoke prep) ==="
    xlang_compiler_make src/asm/freestanding_io_x86_64.o >/dev/null 2>&1 \
      || die "ensure freestanding_io_x86_64.o failed (xlang_compiler_make)"
    IO_OK=1
    echo "nolibc-n07-v2: freestanding_io + stubs OK"
  else
    echo "nolibc-n07-v2: TRY_LINK static-only (need Linux x86_64 for io.o)" >&2
  fi
fi
SKIP=0

echo "nolibc-n07-v2 gate OK (bootstrap nostdlib prep v2)"
echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} stubs=${STUBS_OK} io=${IO_OK} skip=${SKIP} host=$(ci_host_summary)"
