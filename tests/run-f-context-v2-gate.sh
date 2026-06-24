#!/usr/bin/env bash
# F-context v2：std.context 节点存储全量 .sx（删除 context_node_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_CONTEXT_V2_FAIL:-0}
DOC="analysis/phase-f-context-v2.md"
MANIFEST="tests/baseline/f-context-v2-closure.tsv"
die() { echo "f-context-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-context v2: node storage → context.sx (zero glue) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-context v2' "$DOC" || die "doc marker"
[ -f std/context/context.sx ] || die "missing context.sx"
[ ! -f std/context/context_node_glue.c ] || die "context_node_glue.c should be deleted"
[ ! -f std/context/context.c ] || die "context.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'ctx_glue_background_c' std/context/context.sx || die "context.sx missing glue background"
grep -q 'ctx_glue_alloc_c' std/context/context.sx || die "context.sx missing glue alloc"
grep -q 'ctx_smoke_c' std/context/context.sx || die "context.sx missing smoke"
grep -q 'ctx_f_context_v2_marker_c' std/context/context.sx || die "context.sx missing v2 marker"
grep -q 'F-context v2' compiler/Makefile || die "Makefile missing F-context v2 note"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/context/context.o >/dev/null 2>&1 || die "make context.o failed"
else
  echo "f-context-v2 SKIP context.o build (no shux-c)" >&2
fi
chmod +x tests/run-std-context-gate.sh
tests/run-std-context-gate.sh || die "run-std-context-gate failed"
echo "f-context-v2 gate OK"
