#!/usr/bin/env bash
# F-unicode v2：std.unicode 逻辑全量 .sx（删除 unicode_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_UNICODE_V2_FAIL:-0}
DOC="analysis/phase-f-unicode-v2.md"
MANIFEST="tests/baseline/f-unicode-v2-closure.tsv"
die() { echo "f-unicode-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-unicode v2: category/NFC/grapheme → unicode.sx (zero glue) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-unicode v2' "$DOC" || die "doc marker"
[ -f std/unicode/unicode.sx ] || die "missing unicode.sx"
[ ! -f std/unicode/unicode_glue.c ] || die "unicode_glue.c should be deleted"
[ ! -f std/unicode/unicode.c ] || die "unicode.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'unicode_category_c' std/unicode/unicode.sx || die "unicode.sx missing category"
grep -q 'unicode_nfc_buf_c' std/unicode/unicode.sx || die "unicode.sx missing nfc"
grep -q 'unicode_grapheme_next_c' std/unicode/unicode.sx || die "unicode.sx missing grapheme"
grep -q 'unicode_grapheme_case_smoke_c' std/unicode/unicode.sx || die "unicode.sx missing smoke"
grep -q 'unicode_f_unicode_v2_marker_c' std/unicode/unicode.sx || die "unicode.sx missing v2 marker"
grep -q 'F-unicode v2' compiler/Makefile || die "Makefile missing F-unicode v2 note"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/unicode/unicode.o >/dev/null 2>&1 || die "make unicode.o failed"
else
  echo "f-unicode-v2 SKIP unicode.o build (no shux-c)" >&2
fi
for sub in run-std-unicode-nfc-gate.sh run-std-unicode-grapheme-case-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-unicode-v2 gate OK"
