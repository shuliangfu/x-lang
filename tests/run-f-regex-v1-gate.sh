#!/usr/bin/env bash
# F-regex v1：std.regex 去 C（regex.c → regex.x；v2 后引擎全在 regex.x）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_REGEX_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-regex-v1.md"
MANIFEST="tests/baseline/f-regex-v1-closure.tsv"
die() { echo "f-regex-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-regex v1: regex.c → regex.x ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-regex v1' "$DOC" || die "doc marker"
[ -f std/regex/regex.x ] || die "missing regex.x"
[ ! -f std/regex/regex.c ] || die "regex.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/regex/regex.o >/dev/null 2>&1 || die "ensure regex.o failed (xlang_compiler_make)"
else
  echo "f-regex-v1 SKIP regex.o build (no xlang-c)" >&2
fi
if [ -f tests/run-std-regex-gate.sh ]; then
  chmod +x tests/run-std-regex-gate.sh
  tests/run-std-regex-gate.sh || die "std-regex gate failed"
fi
echo "f-regex-v1 gate OK"
