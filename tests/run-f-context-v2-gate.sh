#!/usr/bin/env bash
# F-context v2：std.context 节点存储全量 .x（删除 context_node_glue.c）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_CONTEXT_V2_FAIL:-0}
DOC="analysis/archive/phase/phase-f-context-v2.md"
MANIFEST="tests/baseline/f-context-v2-closure.tsv"
die() { echo "f-context-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-context v2: node storage → context.x (zero glue) ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-context v2' "$DOC" || die "doc marker"
[ -f std/context/context.x ] || die "missing context.x"
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
grep -q 'ctx_glue_background_c' std/context/context.x || die "context.x missing glue background"
grep -q 'ctx_glue_alloc_c' std/context/context.x || die "context.x missing glue alloc"
grep -q 'ctx_smoke_c' std/context/context.x || die "context.x missing smoke"
grep -q 'ctx_f_context_v2_marker_c' std/context/context.x || die "context.x missing v2 marker"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/context/context.o >/dev/null 2>&1 || die "ensure context.o failed (xlang_compiler_make)"
else
  echo "f-context-v2 SKIP context.o build (no xlang-c)" >&2
fi
chmod +x tests/run-std-context-gate.sh
tests/run-std-context-gate.sh || die "run-std-context-gate failed"
echo "f-context-v2 gate OK"
