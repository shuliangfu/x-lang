#!/usr/bin/env bash
# F-backtrace v1：std.backtrace 去 C（backtrace.c → backtrace.x；胶层 v2 已拆，见 run-f-backtrace-v2-gate.sh）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_BACKTRACE_V1_FAIL:-0}
DOC="analysis/phase-f-backtrace-v1.md"
MANIFEST="tests/baseline/f-backtrace-v1-closure.tsv"
die() { echo "f-backtrace-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-backtrace v1: backtrace.c → backtrace.x (glue superseded by v2) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-backtrace v1' "$DOC" || die "doc marker"
[ -f std/backtrace/backtrace.x ] || die "missing backtrace.x"
[ ! -f std/backtrace/backtrace.c ] || die "backtrace.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'backtrace.x' compiler/Makefile || die "Makefile missing backtrace.x"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/backtrace/backtrace.o >/dev/null 2>&1 || die "make backtrace.o failed"
else
  echo "f-backtrace-v1 SKIP backtrace.o build (no shux-c)" >&2
fi
for sub in run-std-backtrace-symbolicate-gate.sh run-std-backtrace-xplat-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-backtrace-v1 gate OK"
