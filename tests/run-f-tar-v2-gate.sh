#!/usr/bin/env bash
# F-tar v2: UStar/Pax logic in tar.x (tar_glue.c deleted).
#
# Usage: ./tests/run-f-tar-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-tar-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-038 ustar + STD-152 extended hard delegate. Soft XLANG_F_TAR_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD already green).
# Report static=/ensure=/ustar=/ext=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested std-tar-ustar / leftover nested
# std-tar-extended; refuse leftover ignore of explicit-bad). leftover
# auto-make of tar.o (`xlang_compiler_make` even when the leaf is
# present — try-heat/g05 raced L2) retired. leftover unused
# compiler-make.sh sourced unused after leftover auto-make retired.
# Missing leaf .o = hard die. leftover nested std-tar-ustar /
# std-tar-extended stay.
# G.7: complete existing resolve_shu; converge dod_native_exe; do not
# fork a third resolver.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-tar-v2.md"
MANIFEST="tests/baseline/f-tar-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_TAR_V2]"

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
  echo "f-tar-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} ustar=${USTAR_OK:-0} ext=${EXT_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
USTAR_OK=0
EXT_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested std-tar-ustar / leftover nested std-tar-extended
# (refuse leftover SKIP→OK / leftover ignore of explicit-bad /
# leftover XLANG fallthrough). leftover auto-make of tar.o retired;
# leftover nested std-tar-ustar / std-tar-extended stay.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-tar v2: tar logic → tar.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-tar v2' "$DOC" || die "doc missing F-tar v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/tar/tar.x ] || die "missing tar.x"
[ ! -f std/tar/tar_glue.c ] || die "tar_glue.c should be deleted"

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
grep -q 'tar_append_entry_c' std/tar/tar.x || die "tar.x missing append_entry"
grep -q 'tar_next_entry_c' std/tar/tar.x || die "tar.x missing next_entry"
grep -q 'tar_extended_smoke_c' std/tar/tar.x || die "tar.x missing extended smoke"
grep -q 'tar_f_tar_v2_marker_c' std/tar/tar.x || die "tar.x missing v2 marker"
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
if [ ! -f std/tar/tar.o ]; then
  die "missing std/tar/tar.o (refuse leftover auto-make)"
fi
ENSURE_OK=1

# Hard-delegate already soft→硬绿 STD-038 / STD-152.
# Do NOT export retired XLANG_F_TAR_V2_FAIL.
# PLATFORM: SHARED archaeology.
if [ -f tests/run-std-tar-ustar-gate.sh ]; then
  echo "=== F-tar v2: delegate run-std-tar-ustar-gate (hard) ==="
  chmod +x tests/run-std-tar-ustar-gate.sh
  if ! tests/run-std-tar-ustar-gate.sh; then
    die "std-tar-ustar sub-gate failed"
  fi
  USTAR_OK=1
else
  die "missing tests/run-std-tar-ustar-gate.sh"
fi

if [ -f tests/run-std-tar-extended-gate.sh ]; then
  echo "=== F-tar v2: delegate run-std-tar-extended-gate (hard) ==="
  chmod +x tests/run-std-tar-extended-gate.sh
  if ! tests/run-std-tar-extended-gate.sh; then
    die "std-tar-extended sub-gate failed"
  fi
  EXT_OK=1
else
  die "missing tests/run-std-tar-extended-gate.sh"
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} ustar=${USTAR_OK} ext=${EXT_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-tar-v2 gate OK (F-tar v2; honesty)"
