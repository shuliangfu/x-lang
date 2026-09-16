#!/usr/bin/env bash
# F-uuid v1: std.uuid de-C (uuid.c → uuid.x).
#
# Usage: ./tests/run-f-uuid-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-uuid-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-075 manifest hard; full uuid product smoke observational (asm UNDEF
# residual — do not soft-swallow as exit0). Soft XLANG_F_UUID_V1_FAIL retired.
# Root: soft die→exit0 = portable false-green. Report
# static=/ensure=/manifest=/smoke=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested std-uuid; refuse leftover ignore of
# explicit-bad). leftover auto-make of uuid.o (`xlang_compiler_make`
# even when the leaf is present — try-heat/g05 raced L2) retired.
# leftover unused compiler-make.sh sourced unused after leftover
# auto-make retired. Missing leaf .o = hard die. leftover nested
# std-uuid stay observational (product residual listed skip).
# G.7: complete existing resolve_shu; converge dod_native_exe; do not
# fork a third resolver.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-uuid-v1.md"
MANIFEST="tests/baseline/f-uuid-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_UUID_V1]"

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
  echo "f-uuid-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} manifest=${MANIFEST_OK:-0} smoke=${SMOKE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
MANIFEST_OK=0
SMOKE_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested std-uuid (refuse leftover SKIP→OK / leftover ignore
# of explicit-bad / leftover XLANG fallthrough). leftover auto-make of
# uuid.o retired; leftover nested std-uuid stay observational.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-uuid v1: std.uuid uuid.c → uuid.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-uuid v1' "$DOC" || die "doc missing F-uuid v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/uuid/uuid.x ] || die "missing std/uuid/uuid.x"
[ ! -f std/uuid/uuid.c ] || die "std/uuid/uuid.c should be deleted"

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
if [ ! -f std/uuid/uuid.o ]; then
  die "missing std/uuid/uuid.o (refuse leftover auto-make)"
fi
ENSURE_OK=1

if [ -f tests/run-std-uuid-gate.sh ]; then
  echo "=== F-uuid v1: delegate run-std-uuid-gate (manifest hard) ==="
  chmod +x tests/run-std-uuid-gate.sh
  if ! XLANG_STD_UUID_MANIFEST_ONLY=1 tests/run-std-uuid-gate.sh; then
    die "std-uuid manifest sub-gate failed"
  fi
  MANIFEST_OK=1

  # Full product smoke is observational: STD uuid asm UNDEF residual
  # (do not hard-fail this soft archaeology knife; do not soft-exit0).
  echo "=== F-uuid v1: std-uuid full smoke (observational; product UNDEF residual) ==="
  if tests/run-std-uuid-gate.sh; then
    SMOKE_OK=1
  else
    echo "f-uuid-v1 WARN: std-uuid full smoke failed (observational; product UNDEF)" >&2
    SMOKE_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} manifest=${MANIFEST_OK} smoke=${SMOKE_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-uuid-v1 std.uuid gate OK (F-uuid v1; honesty)"
