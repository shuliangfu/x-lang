#!/usr/bin/env bash
# F-context v1：std.context 去 C（context.c → context.sx；v2 后节点也在 context.sx）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_CONTEXT_V1_FAIL:-0}
DOC="analysis/phase-f-context-v1.md"
MANIFEST="tests/baseline/f-context-v1-closure.tsv"
die() { echo "f-context-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-context v1: context.c → context.sx ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-context v1' "$DOC" || die "doc marker"
[ -f std/context/context.sx ] || die "missing context.sx"
[ ! -f std/context/context.c ] || die "context.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'context.sx' compiler/Makefile || die "Makefile missing context.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/context/context.o >/dev/null 2>&1 || die "make context.o failed"
else
  echo "f-context-v1 SKIP context.o build (no shux-c)" >&2
fi
if [ -f tests/run-std-context-gate.sh ]; then
  chmod +x tests/run-std-context-gate.sh
  tests/run-std-context-gate.sh || die "std-context gate failed"
fi
echo "f-context-v1 gate OK"
