#!/usr/bin/env bash
# D-01 v1: Stage 0 (seed) → Stage 1 (xlang_asm B-strict) gate.
#
# Honesty: soft XLANG_D01_FAIL retired — missing compiler/Makefile was
# portable false-green after MG wave941. Live authority = ./xbuild +
# bootstrap_driver_bstrict.sh + build_xlang_asm.sh (refuse Makefile resurrect).
#
# Usage: ./tests/run-d01-stage0-to-stage1-gate.sh
# Env:
#   XLANG_D01_BUILD_LOG=/path       — optional bstrict build log
#   XLANG_D01_MANIFEST_ONLY=1       — manifest + static only (skip native smoke)
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

if [ -f analysis/phase-d-d01-v1.md ]; then
  echo "d01-stage0-to-stage1-gate gate FAIL: top-level DOC resurrected (live = archive/phase/)" >&2
  exit 1
fi

DOC="analysis/archive/phase/phase-d-d01-v1.md"
MANIFEST="tests/baseline/d01-stage0-to-stage1.tsv"
BUILD_ASM="compiler/scripts/build_xlang_asm.sh"
BSTRICT="compiler/scripts/bootstrap_driver_bstrict.sh"
XBUILD_SH="xlang-build.sh"
LOG="${XLANG_D01_BUILD_LOG:-/tmp/build_bstrict.log}"
XLANG_ASM="compiler/xlang_asm"
PREFIX="xlang: [XLANG_D01]"

die() {
  echo "d01 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} bstrict=${BSTRICT_OK:-0} native=${NATIVE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

d01_native_exe() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

DOC_OK=0
BSTRICT_OK=0
NATIVE_OK=0
SKIP=1

echo "=== D-01: Stage0 seed → Stage1 xlang_asm (honesty) ==="
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild + bootstrap scripts)"
fi
for f in "$DOC" "$MANIFEST" "$BUILD_ASM" "$BSTRICT" "$XBUILD_SH" compiler/bootstrap.sh; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'D-01 v1' "$DOC" || die "doc missing D-01 v1 marker"
grep -qE '^## Gate' "$DOC" || die "phase-d-d01-v1.md missing ## Gate honesty section"
DOC_OK=1

grep -q 'bootstrap-driver-seed\|bootstrap_driver_seed' "$BUILD_ASM" \
  || die "build_xlang_asm missing seed reference"
grep -qE 'bootstrap-driver-bstrict' "$XBUILD_SH" || die "xlang-build.sh missing bootstrap-driver-bstrict"
grep -q 'XLANG_ASM_EXPERIMENTAL_SKIP_GEN=1' "$BSTRICT" || die "bootstrap_driver_bstrict missing SKIP_GEN=1"
BSTRICT_OK=1

MISS=0
while IFS=$'\t' read -r item_id _layer anchor check_type notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$check_type" in
    gate_ref|cross_ref)
      [ -f "$anchor" ] || { echo "d01 manifest missing: $anchor" >&2; MISS=$((MISS + 1)); }
      ;;
    grep)
      [ -f "$anchor" ] || { echo "d01 manifest missing file: $anchor" >&2; MISS=$((MISS + 1)); continue; }
      [ -n "${notes:-}" ] || continue
      grep -qE "$notes|SKIP_GEN|bootstrap-driver-bstrict|seed" "$anchor" \
        || { echo "d01 manifest grep fail: $anchor ($notes)" >&2; MISS=$((MISS + 1)); }
      ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || die "$MISS manifest item(s) failed"

if [ "${XLANG_D01_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "d01 stage0-to-stage1 gate OK (manifest only)"
  echo "${PREFIX} status=ok doc=${DOC_OK} bstrict=${BSTRICT_OK} native=${NATIVE_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if [ -f "$LOG" ]; then
  grep -qE 'Target-B-strict|B-strict OK|LINK_MODE=asm_only_strict|bootstrap-driver-bstrict' "$LOG" || \
    die "build log missing B-strict markers ($LOG)"
  echo "d01 OK: audited build log $LOG"
fi

if ! d01_native_exe "$XLANG_ASM"; then
  die "no native $XLANG_ASM (soft SKIP retired; run ./xbuild bootstrap-driver-bstrict)"
fi
NATIVE_OK=1

# Stage 1 must be executable with asm backend (vs pure xlang-c).
if ! "$XLANG_ASM" --help 2>/dev/null | grep -qE '\-backend|backend'; then
  die "$XLANG_ASM build missing -backend (not Stage1 asm compiler?)"
fi

SKIP=0
echo "d01 stage0-to-stage1 gate OK (Stage1=$XLANG_ASM build native executable)"
echo "${PREFIX} status=ok doc=${DOC_OK} bstrict=${BSTRICT_OK} native=${NATIVE_OK} skip=${SKIP} host=$(ci_host_summary)"
