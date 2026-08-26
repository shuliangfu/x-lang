#!/usr/bin/env bash
# F-datetime v2: datetime logic in datetime.x (F-ZC; tz glue deleted).
#
# Usage: ./tests/run-f-datetime-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-datetime-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-074 datetime + STD-135 timezone + STD-136 iana hard delegate.
# Soft XLANG_F_DATETIME_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD already green).
# Report static=/ensure=/dt=/tz=/iana=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-datetime-v2.md"
MANIFEST="tests/baseline/f-datetime-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_DATETIME_V2]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
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

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make ../std/datetime/datetime.o >/dev/null 2>&1 \
  || die "ensure datetime.o failed (xlang_compiler_make; prefer asm)"
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
