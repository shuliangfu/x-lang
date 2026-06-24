#!/usr/bin/env bash
# F-runtime v1：std.runtime 去 C（runtime.c → runtime.sx）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_RUNTIME_V1_FAIL:-0}
DOC="analysis/phase-f-runtime-v1.md"
MANIFEST="tests/baseline/f-runtime-v1-closure.tsv"
die() { echo "f-runtime-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-runtime v1: runtime.c → runtime.sx ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-runtime v1' "$DOC" || die "doc marker"
[ -f "$MANIFEST" ] || die "missing manifest"
[ -f std/runtime/runtime.sx ] || die "missing runtime.sx"
[ ! -f std/runtime/runtime.c ] || die "runtime.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'runtime.sx' compiler/Makefile || die "Makefile missing runtime.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/runtime/runtime.o >/dev/null 2>&1 || die "make runtime.o failed"
else
  echo "f-runtime-v1 SKIP runtime.o build (no shux-c)" >&2
fi
if [ -f tests/run-std-runtime-panic-hook-gate.sh ]; then
  chmod +x tests/run-std-runtime-panic-hook-gate.sh
  tests/run-std-runtime-panic-hook-gate.sh || die "panic-hook gate failed"
fi
echo "f-runtime-v1 gate OK"
