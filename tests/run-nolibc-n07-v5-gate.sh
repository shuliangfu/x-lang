#!/usr/bin/env bash
# NL-07 v5: bootstrap nostdlib hard-green gate (manifest; TRY_BUILD opt-in).
#
# Usage: ./tests/run-nolibc-n07-v5-gate.sh
#        XLANG_NOLIBC_N07_V5_MANIFEST_ONLY=1 ./tests/run-nolibc-n07-v5-gate.sh
#        XLANG_NOLIBC_N07_V5_TRY_BUILD=1 ./tests/run-nolibc-n07-v5-gate.sh
# Honesty: soft XLANG_NOLIBC_N07_V5_FAIL retired — die→exit0 was portable false-green.
# Shared nostdlib authority = bootstrap_nostdlib_shared.sh + build_xlang_asm.
# Report doc=/manifest=/try=/ldd=/skip=.
# PLATFORM: SHARED archaeology / LINUX try.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_NOLIBC_N07_V5_DOC:-analysis/archive/phase/phase-f-n07-v5.md}"
MANIFEST="tests/baseline/nolibc-n07-v5.tsv"
BUILD_ASM="compiler/scripts/build_xlang_asm.sh"
NOSTDLIB_SHARED="compiler/scripts/bootstrap_nostdlib_shared.sh"
XLANG_ASM="compiler/xlang_asm"
PREFIX="xlang: [XLANG_NOLIBC_N07_V5]"

DOC_OK=0
MANIFEST_OK=0
TRY_OK=0
LDD_OK=0
SKIP=1

die() {
  echo "nolibc-n07-v5 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK} manifest=${MANIFEST_OK} try=${TRY_OK} ldd=${LDD_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

echo "=== NL-07 v5: bootstrap nostdlib hard green (honesty) ==="
if [ -f analysis/phase-f-n07-v5.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'NL-07 v5' "$DOC" || die "doc missing NL-07 v5 marker"
grep -qE '^## Gate$' "$DOC" || die "phase-f-n07-v5.md missing ## Gate honesty section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f "$BUILD_ASM" ] || die "missing $BUILD_ASM"
[ -f "$NOSTDLIB_SHARED" ] || die "missing $NOSTDLIB_SHARED"
grep -q 'NL-07 v5' "$BUILD_ASM" || die "build_xlang_asm missing NL-07 v5 marker"
grep -q 'bootstrap_nostdlib_shared.sh' "$BUILD_ASM" || die "build_xlang_asm must source shared nostdlib authority"
grep -q 'XLANG_BOOTSTRAP_ALLOW_LIBC' "$NOSTDLIB_SHARED" || die "missing XLANG_BOOTSTRAP_ALLOW_LIBC escape in shared"
grep -q 'NL-07 v5: Linux x86_64 defaults to nostdlib' "$NOSTDLIB_SHARED" || die "shared missing default-nostdlib v5 policy"
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

if [ "${XLANG_NOLIBC_N07_V5_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "nolibc-n07-v5 gate OK (manifest only)"
  echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} try=${TRY_OK} ldd=${LDD_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if [ "${XLANG_NOLIBC_N07_V5_TRY_BUILD:-0}" != "1" ]; then
  SKIP=0
  echo "nolibc-n07-v5 gate OK (manifest; set XLANG_NOLIBC_N07_V5_TRY_BUILD=1 + xlang_asm for ldd audit)"
  echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} try=${TRY_OK} ldd=${LDD_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if [ "$(uname -s 2>/dev/null)" != "Linux" ] || [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
  SKIP=1
  echo "nolibc-n07-v5 gate OK (manifest; build try skip — need Linux x86_64)"
  echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} try=${TRY_OK} ldd=${LDD_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if [ ! -x "$XLANG_ASM" ]; then
  SKIP=1
  echo "nolibc-n07-v5 gate OK (manifest; build try skip — no xlang_asm)"
  echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} try=${TRY_OK} ldd=${LDD_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

echo "=== NL-07 v5: default nostdlib build_xlang_asm + ldd audit ==="
LOG="/tmp/xlang_n07_v5_build.log"
rm -f "$LOG" 2>/dev/null || true
set +e
( cd compiler && unset XLANG_BOOTSTRAP_ALLOW_LIBC XLANG_BOOTSTRAP_NOSTDLIB; ./scripts/build_xlang_asm.sh ) 2>&1 | tee "$LOG"
RC=${PIPESTATUS[0]}
set -e

if [ "$RC" -ne 0 ] || [ ! -x "$XLANG_ASM" ]; then
  echo "nolibc-n07-v5: build failed rc=$RC" >&2
  grep "undefined reference" "$LOG" 2>/dev/null | sed 's/.*undefined reference to /  /' | sort -u | head -30 >&2 || true
  die "nostdlib default build failed"
fi

if ! grep -q 'bootstrap nostdlib crt0 link OK' "$LOG" 2>/dev/null \
  && ! grep -q 'bootstrap nostdlib.*link OK' "$LOG" 2>/dev/null; then
  die "build succeeded but nostdlib path not taken (check XLANG_BOOTSTRAP_ALLOW_LIBC or fallback -lc)"
fi
TRY_OK=1

if command -v ldd >/dev/null 2>&1; then
  if ldd "$XLANG_ASM" 2>/dev/null | grep -q 'libc\.so'; then
    ldd "$XLANG_ASM" 2>&1 | head -20 >&2 || true
    die "ldd shows libc.so on xlang_asm (nostdlib hard green violated)"
  fi
  LDD_OK=1
  echo "nolibc-n07-v5: ldd OK (no libc.so)"
else
  echo "nolibc-n07-v5: ldd not available (skip dynamic audit)"
fi
SKIP=0

echo "nolibc-n07-v5 gate OK (default nostdlib + ldd audit)"
echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} try=${TRY_OK} ldd=${LDD_OK} skip=${SKIP} host=$(ci_host_summary)"
