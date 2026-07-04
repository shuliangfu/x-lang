#!/usr/bin/env bash
# F-regex v2：std.regex 引擎全量 .x（删除 regex_engine_glue.c + regex_min.inc.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_REGEX_V2_FAIL:-0}
DOC="analysis/phase-f-regex-v2.md"
MANIFEST="tests/baseline/f-regex-v2-closure.tsv"
die() { echo "f-regex-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-regex v2: engine → regex.x (zero glue/inc) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-regex v2' "$DOC" || die "doc marker"
[ -f std/regex/regex.x ] || die "missing regex.x"
[ ! -f std/regex/regex_engine_glue.c ] || die "regex_engine_glue.c should be deleted"
[ ! -f std/regex/regex_min.inc.c ] || die "regex_min.inc.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'regex_compile_c' std/regex/regex.x || die "regex.x missing compile"
grep -q 'regex_min_smoke_c' std/regex/regex.x || die "regex.x missing smoke"
grep -q 'regex_f_regex_v2_marker_c' std/regex/regex.x || die "regex.x missing v2 marker"
grep -q 'atomic_nest' std/regex/regex.x || die "regex.x missing atomic_nest"
grep -q 'F-regex v2' compiler/Makefile || die "Makefile missing F-regex v2 note"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/regex/regex.o >/dev/null 2>&1 || die "make regex.o failed"
else
  echo "f-regex-v2 SKIP regex.o build (no shux-c)" >&2
fi
for sub in run-std-regex-gate.sh run-std-regex-atomic-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-regex-v2 gate OK"
