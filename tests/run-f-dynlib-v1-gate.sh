#!/usr/bin/env bash
# F-dynlib v1：std.dynlib 去 C（dynlib.c → dynlib.sx；胶层 v2 已拆，见 run-f-dynlib-v2-gate.sh）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_DYNLIB_V1_FAIL:-0}
DOC="analysis/phase-f-dynlib-v1.md"
MANIFEST="tests/baseline/f-dynlib-v1-closure.tsv"
die() { echo "f-dynlib-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-dynlib v1: dynlib.c → dynlib.sx (glue superseded by v2) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-dynlib v1' "$DOC" || die "doc marker"
[ -f std/dynlib/dynlib.sx ] || die "missing dynlib.sx"
[ ! -f std/dynlib/dynlib.c ] || die "dynlib.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'dynlib.sx' compiler/Makefile || die "Makefile missing dynlib.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/dynlib/dynlib.o >/dev/null 2>&1 || die "make dynlib.o failed"
else
  echo "f-dynlib-v1 SKIP dynlib.o build (no shux-c)" >&2
fi
for sub in run-std-dynlib-windows-gate.sh run-std-dynlib-last-error-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-dynlib-v1 gate OK"
