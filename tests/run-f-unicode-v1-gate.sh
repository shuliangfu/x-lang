#!/usr/bin/env bash
# F-unicode v1：std.unicode 去 C（unicode.c → unicode.x；v2 后逻辑全在 unicode.x）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_UNICODE_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-unicode-v1.md"
MANIFEST="tests/baseline/f-unicode-v1-closure.tsv"
die() { echo "f-unicode-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-unicode v1: unicode.c → unicode.x + glue ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-unicode v1' "$DOC" || die "doc marker"
[ -f std/unicode/unicode.x ] || die "missing unicode.x"
[ ! -f std/unicode/unicode.c ] || die "unicode.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/unicode/unicode.o >/dev/null 2>&1 || die "ensure unicode.o failed (xlang_compiler_make)"
else
  echo "f-unicode-v1 SKIP unicode.o build (no xlang-c)" >&2
fi
for sub in run-std-unicode-nfc-gate.sh run-std-unicode-grapheme-case-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-unicode-v1 gate OK"
