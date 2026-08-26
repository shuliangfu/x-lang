#!/usr/bin/env bash
# F-unicode v2: category/NFC/grapheme in unicode.x (unicode_glue deleted).
#
# Usage: ./tests/run-f-unicode-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-unicode-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure.
# Soft XLANG_F_UNICODE_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green. STD-037 nfc／STD-114 grapheme-case
# product residuals observational (listed skip).
# Report static=/ensure=/nfc=/gc=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-unicode-v2.md"
MANIFEST="tests/baseline/f-unicode-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_UNICODE_V2]"

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
  echo "f-unicode-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} nfc=${NFC_OK:-0} gc=${GC_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
NFC_OK=0
GC_OK=0
SKIP=1

echo "=== F-unicode v2: category/NFC/grapheme → unicode.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-unicode v2' "$DOC" || die "doc missing F-unicode v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/unicode/unicode.x ] || die "missing unicode.x"
[ ! -f std/unicode/unicode_glue.c ] || die "unicode_glue.c should be deleted"
[ ! -f std/unicode/unicode.c ] || die "unicode.c should be deleted"

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
# Soft gate grepped fossil C names (unicode_category_c / unicode_nfc_buf_c / …);
# those never existed in unicode.x — soft die→exit0 hid the miss. Authority
# surface uses short export names (category / nfc_buf / grapheme_*), plus v2 marker.
grep -q 'export function category(' std/unicode/unicode.x || die "unicode.x missing category"
grep -q 'export function nfc_buf(' std/unicode/unicode.x || die "unicode.x missing nfc_buf"
grep -q 'export function grapheme_next(' std/unicode/unicode.x || die "unicode.x missing grapheme_next"
grep -q 'export function grapheme_case_smoke(' std/unicode/unicode.x || die "unicode.x missing grapheme_case_smoke"
grep -q 'unicode_f_unicode_v2_marker_c' std/unicode/unicode.x || die "unicode.x missing v2 marker"
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make ../std/unicode/unicode.o >/dev/null 2>&1 \
  || die "ensure unicode.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# Do NOT export retired XLANG_F_UNICODE_V2_FAIL.
# STD-037 nfc／STD-114 grapheme-case product residuals — observational.
# PLATFORM: SHARED archaeology.
if [ -f tests/run-std-unicode-nfc-gate.sh ]; then
  echo "=== F-unicode v2: std-unicode-nfc (observational; product residual) ==="
  chmod +x tests/run-std-unicode-nfc-gate.sh
  if tests/run-std-unicode-nfc-gate.sh; then
    NFC_OK=1
  else
    echo "f-unicode-v2 WARN: std-unicode-nfc failed (observational)" >&2
    NFC_OK=0
  fi
fi

if [ -f tests/run-std-unicode-grapheme-case-gate.sh ]; then
  echo "=== F-unicode v2: std-unicode-grapheme-case (observational; product residual) ==="
  chmod +x tests/run-std-unicode-grapheme-case-gate.sh
  if tests/run-std-unicode-grapheme-case-gate.sh; then
    GC_OK=1
  else
    echo "f-unicode-v2 WARN: std-unicode-grapheme-case failed (observational)" >&2
    GC_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} nfc=${NFC_OK} gc=${GC_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-unicode-v2 gate OK (F-unicode v2; honesty)"
