#!/usr/bin/env bash
# F-datetime v2: datetime logic in datetime.x (F-ZC; tz glue deleted).
#
# Usage: ./tests/run-f-datetime-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-datetime-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-074 datetime + STD-135 timezone + STD-136 iana hard delegate.
# Soft XLANG_F_DATETIME_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD already green).
# Report static=/ensure=/dt=/tz=/iana=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested std-datetime / leftover nested
# std-datetime-timezone / leftover nested std-datetime-iana; refuse
# leftover ignore of explicit-bad). leftover auto-make of datetime.o
# (`xlang_compiler_make` even when the leaf is present — try-heat/g05
# raced L2) retired. leftover unused compiler-make.sh sourced unused
# after leftover auto-make retired. Missing leaf .o = hard die.
# leftover nested std-datetime / std-datetime-timezone /
# std-datetime-iana stay.
# G.7: complete existing resolve_shu; converge dod_native_exe; do not
# fork a third resolver.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-datetime-v2.md"
MANIFEST="tests/baseline/f-datetime-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_DATETIME_V2]"

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
  echo "f-datetime-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} dt=${DT_OK:-0} tz=${TZ_OK:-0} iana=${IANA_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
DT_OK=0
TZ_OK=0
IANA_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested std-datetime family (refuse leftover SKIP→OK /
# leftover ignore of explicit-bad / leftover XLANG fallthrough).
# leftover auto-make of datetime.o retired; leftover nested
# std-datetime / std-datetime-timezone / std-datetime-iana stay.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-datetime v2: datetime.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-datetime v2' "$DOC" || die "doc missing F-datetime v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/datetime/datetime.x ] || die "missing datetime.x"
[ ! -f std/datetime/datetime_tz_glue.c ] || die "datetime_tz_glue.c should be deleted (F-ZC)"
[ ! -f std/datetime/datetime_glue.c ] || die "datetime_glue.c should be deleted"
[ ! -f std/datetime/timezone_iana.inc.c ] || die "timezone_iana.inc.c should be deleted"

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
grep -q 'datetime_parse_rfc3339_c' std/datetime/datetime.x || die "datetime.x missing parse"
grep -q 'datetime_iana_dst_smoke_c' std/datetime/datetime.x || die "datetime.x missing iana smoke"
grep -q 'datetime_smoke_c' std/datetime/datetime.x || die "datetime.x missing smoke"
grep -q 'datetime_f_datetime_v2_marker_c' std/datetime/datetime.x || die "datetime.x missing v2 marker"
grep -q 'datetime_f_zero_c_marker_c' std/datetime/datetime.x || die "datetime.x missing zero-c marker"
grep -q 'datetime_local_offset_min_c' std/datetime/datetime.x || die "datetime.x missing local offset"
grep -q 'time_wall_local_offset_min_c' std/datetime/datetime.x || die "datetime.x missing time extern"
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
if [ ! -f std/datetime/datetime.o ]; then
  die "missing std/datetime/datetime.o (refuse leftover auto-make)"
fi
ENSURE_OK=1

# Hard-delegate already soft→硬绿 STD-074 / STD-135 / STD-136.
# Do NOT export retired XLANG_F_DATETIME_V2_FAIL.
# PLATFORM: SHARED archaeology.
if [ -f tests/run-std-datetime-gate.sh ]; then
  echo "=== F-datetime v2: delegate run-std-datetime-gate (hard) ==="
  chmod +x tests/run-std-datetime-gate.sh
  if ! tests/run-std-datetime-gate.sh; then
    die "std-datetime sub-gate failed"
  fi
  DT_OK=1
else
  die "missing tests/run-std-datetime-gate.sh"
fi

if [ -f tests/run-std-datetime-timezone-gate.sh ]; then
  echo "=== F-datetime v2: delegate run-std-datetime-timezone-gate (hard) ==="
  chmod +x tests/run-std-datetime-timezone-gate.sh
  if ! tests/run-std-datetime-timezone-gate.sh; then
    die "std-datetime-timezone sub-gate failed"
  fi
  TZ_OK=1
else
  die "missing tests/run-std-datetime-timezone-gate.sh"
fi

if [ -f tests/run-std-datetime-iana-gate.sh ]; then
  echo "=== F-datetime v2: delegate run-std-datetime-iana-gate (hard) ==="
  chmod +x tests/run-std-datetime-iana-gate.sh
  if ! tests/run-std-datetime-iana-gate.sh; then
    die "std-datetime-iana sub-gate failed"
  fi
  IANA_OK=1
else
  die "missing tests/run-std-datetime-iana-gate.sh"
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} dt=${DT_OK} tz=${TZ_OK} iana=${IANA_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-datetime-v2 gate OK (F-datetime v2; honesty)"
