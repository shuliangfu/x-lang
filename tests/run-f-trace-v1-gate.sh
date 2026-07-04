#!/usr/bin/env bash
# F-trace v1：std.trace 去 C（trace.c → trace.x；v2 后逻辑全在 trace.x）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_TRACE_V1_FAIL:-0}
DOC="analysis/phase-f-trace-v1.md"
MANIFEST="tests/baseline/f-trace-v1-closure.tsv"
die() { echo "f-trace-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-trace v1: trace.c → trace.x ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-trace v1' "$DOC" || die "doc marker"
[ -f std/trace/trace.x ] || die "missing trace.x"
[ ! -f std/trace/trace.c ] || die "trace.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'trace.x' compiler/Makefile || die "Makefile missing trace.x"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/trace/trace.o >/dev/null 2>&1 || die "make trace.o failed"
else
  echo "f-trace-v1 SKIP trace.o build (no shux-c)" >&2
fi
for sub in run-std-trace-gate.sh run-std-trace-hooks-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-trace-v1 gate OK"
