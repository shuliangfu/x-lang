#!/usr/bin/env bash
# F-unicode v1：std.unicode 去 C（unicode.c → unicode.sx；v2 后逻辑全在 unicode.sx）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_UNICODE_V1_FAIL:-0}
DOC="analysis/phase-f-unicode-v1.md"
MANIFEST="tests/baseline/f-unicode-v1-closure.tsv"
die() { echo "f-unicode-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-unicode v1: unicode.c → unicode.sx + glue ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-unicode v1' "$DOC" || die "doc marker"
[ -f std/unicode/unicode.sx ] || die "missing unicode.sx"
[ ! -f std/unicode/unicode.c ] || die "unicode.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'unicode.sx' compiler/Makefile || die "Makefile missing unicode.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/unicode/unicode.o >/dev/null 2>&1 || die "make unicode.o failed"
else
  echo "f-unicode-v1 SKIP unicode.o build (no shux-c)" >&2
fi
for sub in run-std-unicode-nfc-gate.sh run-std-unicode-grapheme-case-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-unicode-v1 gate OK"
