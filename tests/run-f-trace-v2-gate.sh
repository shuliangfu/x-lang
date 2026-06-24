#!/usr/bin/env bash
# F-trace v2：std.trace 逻辑全量 .sx（删除 trace_span_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_TRACE_V2_FAIL:-0}
DOC="analysis/phase-f-trace-v2.md"
MANIFEST="tests/baseline/f-trace-v2-closure.tsv"
die() { echo "f-trace-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-trace v2: span/export logic → trace.sx (zero glue) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-trace v2' "$DOC" || die "doc marker"
[ -f std/trace/trace.sx ] || die "missing trace.sx"
[ ! -f std/trace/trace_span_glue.c ] || die "trace_span_glue.c should be deleted"
[ ! -f std/trace/trace.c ] || die "trace.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'trace_create_c' std/trace/trace.sx || die "trace.sx missing trace_create_c"
grep -q 'trace_export_text_c' std/trace/trace.sx || die "trace.sx missing export"
grep -q 'trace_smoke_c' std/trace/trace.sx || die "trace.sx missing smoke"
grep -q 'trace_f_trace_v2_marker_c' std/trace/trace.sx || die "trace.sx missing v2 marker"
grep -q 'F-trace v2' compiler/Makefile || die "Makefile missing F-trace v2 note"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/trace/trace.o >/dev/null 2>&1 || die "make trace.o failed"
else
  echo "f-trace-v2 SKIP trace.o build (no shux-c)" >&2
fi
for sub in run-std-trace-gate.sh run-std-trace-hooks-gate.sh; do
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-trace-v2 gate OK"
