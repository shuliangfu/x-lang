#!/usr/bin/env bash
# F-regex v1：std.regex 去 C（regex.c → regex.sx；v2 后引擎全在 regex.sx）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_REGEX_V1_FAIL:-0}
DOC="analysis/phase-f-regex-v1.md"
MANIFEST="tests/baseline/f-regex-v1-closure.tsv"
die() { echo "f-regex-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-regex v1: regex.c → regex.sx ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-regex v1' "$DOC" || die "doc marker"
[ -f std/regex/regex.sx ] || die "missing regex.sx"
[ ! -f std/regex/regex.c ] || die "regex.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'regex.sx' compiler/Makefile || die "Makefile missing regex.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/regex/regex.o >/dev/null 2>&1 || die "make regex.o failed"
else
  echo "f-regex-v1 SKIP regex.o build (no shux-c)" >&2
fi
if [ -f tests/run-std-regex-gate.sh ]; then
  chmod +x tests/run-std-regex-gate.sh
  tests/run-std-regex-gate.sh || die "std-regex gate failed"
fi
echo "f-regex-v1 gate OK"
