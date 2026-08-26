#!/usr/bin/env bash
# F-datetime v1: std.datetime de-C (datetime.x; tz glue retired F-ZC).
#
# Usage: ./tests/run-f-datetime-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-datetime-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-074 datetime + STD-136 iana hard delegate. Soft XLANG_F_DATETIME_V1_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD already green).
# Report static=/ensure=/dt=/iana=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-datetime-v1.md"
MANIFEST="tests/baseline/f-datetime-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_DATETIME_V1]"

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
  echo "f-datetime-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} dt=${DT_OK:-0} iana=${IANA_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
DT_OK=0
IANA_OK=0
SKIP=1

echo "=== F-datetime v1: std.datetime datetime.c → datetime.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-datetime v1' "$DOC" || die "doc missing F-datetime v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/datetime/datetime.x ] || die "missing datetime.x"
[ ! -f std/datetime/datetime_tz_glue.c ] || die "datetime_tz_glue.c should be deleted (F-ZC)"
[ ! -f std/datetime/datetime.c ] || die "datetime.c should be deleted"

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

if [ -f tests/run-std-datetime-gate.sh ]; then
  echo "=== F-datetime v1: delegate run-std-datetime-gate ==="
  chmod +x tests/run-std-datetime-gate.sh
  if ! tests/run-std-datetime-gate.sh; then
    die "std-datetime sub-gate failed"
  fi
  DT_OK=1
fi

if [ -f tests/run-std-datetime-iana-gate.sh ]; then
  echo "=== F-datetime v1: delegate run-std-datetime-iana-gate ==="
  chmod +x tests/run-std-datetime-iana-gate.sh
  if ! tests/run-std-datetime-iana-gate.sh; then
    die "std-datetime-iana sub-gate failed"
  fi
  IANA_OK=1
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} dt=${DT_OK} iana=${IANA_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-datetime-v1 std.datetime gate OK (F-datetime v1; honesty)"
