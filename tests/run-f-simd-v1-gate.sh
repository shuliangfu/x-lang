#!/usr/bin/env bash
# F-simd v1: std.simd de-C (simd.c → simd.x; F-ZC pure .x).
#
# Usage: ./tests/run-f-simd-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-simd-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-153 autovec + STD-061 prod + intrinsic + shuffle-select hard delegate.
# Soft XLANG_F_SIMD_V1_FAIL retired. Root: soft die→exit0 = portable false-green
# (static+STD simd family already green). Report
# static=/ensure=/autovec=/prod=/intr=/shuffle=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested std-simd-autovec-strategy / leftover nested
# std-simd-prod / leftover nested std-simd-intrinsic / leftover nested
# std-simd-shuffle-select; refuse leftover ignore of explicit-bad).
# leftover auto-make of simd.o (`xlang_compiler_make` even when the leaf
# is present — try-heat/g05 raced L2) retired. leftover unused
# compiler-make.sh sourced unused after leftover auto-make retired.
# Missing leaf .o = hard die. leftover nested std-simd-autovec-strategy /
# leftover nested std-simd-prod / leftover nested std-simd-intrinsic /
# leftover nested std-simd-shuffle-select stay.
# G.7: complete existing resolve_shu; converge dod_native_exe; do not
# fork a third resolver.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-simd-v1.md"
MANIFEST="tests/baseline/f-simd-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_SIMD_V1]"

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "f-simd-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} autovec=${AUTOVEC_OK:-0} prod=${PROD_OK:-0} intr=${INTR_OK:-0} shuffle=${SHUFFLE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
AUTOVEC_OK=0
PROD_OK=0
INTR_OK=0
SHUFFLE_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested std-simd-autovec-strategy / leftover nested
# std-simd-prod / leftover nested std-simd-intrinsic / leftover nested
# std-simd-shuffle-select (refuse leftover SKIP→OK / leftover ignore of
# explicit-bad / leftover XLANG fallthrough). leftover auto-make of
# simd.o retired; leftover nested std-simd-autovec-strategy /
# leftover nested std-simd-prod / leftover nested std-simd-intrinsic /
# leftover nested std-simd-shuffle-select stay.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-simd v1: simd.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-simd v1' "$DOC" || die "doc missing F-simd v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/simd/simd.x ] || die "missing simd.x"
[ ! -f std/simd/simd_os_glue.c ] || die "simd_os_glue.c should be deleted (F-ZC)"
[ ! -f std/simd/simd.c ] || die "simd.c should be deleted"
grep -q 'simd_autovec_smoke_c' std/simd/simd.x || die "simd.x missing smoke"
grep -q 'simd_f_zero_c_marker_c' std/simd/simd.x || die "simd.x missing zero-c marker"

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
STATIC_OK=1

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

# leftover auto-make retired: require the leaf already present (refuse try-heat/g05).
# PLATFORM: SHARED — missing leaf = hard die; Ubuntu gold still required.
if [ ! -f std/simd/simd.o ]; then
  die "missing std/simd/simd.o (refuse leftover auto-make)"
fi
ENSURE_OK=1

# Hard-delegate already soft→硬绿 STD simd family.
if [ -f tests/run-std-simd-autovec-strategy-gate.sh ]; then
  echo "=== F-simd v1: delegate run-std-simd-autovec-strategy-gate ==="
  chmod +x tests/run-std-simd-autovec-strategy-gate.sh
  if ! tests/run-std-simd-autovec-strategy-gate.sh; then
    die "std-simd-autovec sub-gate failed"
  fi
  AUTOVEC_OK=1
fi

if [ -f tests/run-std-simd-prod-gate.sh ]; then
  echo "=== F-simd v1: delegate run-std-simd-prod-gate ==="
  chmod +x tests/run-std-simd-prod-gate.sh
  if ! tests/run-std-simd-prod-gate.sh; then
    die "std-simd-prod sub-gate failed"
  fi
  PROD_OK=1
fi

if [ -f tests/run-std-simd-intrinsic-gate.sh ]; then
  echo "=== F-simd v1: delegate run-std-simd-intrinsic-gate ==="
  chmod +x tests/run-std-simd-intrinsic-gate.sh
  if ! tests/run-std-simd-intrinsic-gate.sh; then
    die "std-simd-intrinsic sub-gate failed"
  fi
  INTR_OK=1
fi

if [ -f tests/run-std-simd-shuffle-select-gate.sh ]; then
  echo "=== F-simd v1: delegate run-std-simd-shuffle-select-gate ==="
  chmod +x tests/run-std-simd-shuffle-select-gate.sh
  if ! tests/run-std-simd-shuffle-select-gate.sh; then
    die "std-simd-shuffle-select sub-gate failed"
  fi
  SHUFFLE_OK=1
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} autovec=${AUTOVEC_OK} prod=${PROD_OK} intr=${INTR_OK} shuffle=${SHUFFLE_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-simd-v1 std.simd gate OK (F-simd v1; honesty)"
