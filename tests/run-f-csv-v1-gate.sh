#!/usr/bin/env bash
# F-csv v1：std.csv 去 C（csv.c → csv.x）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_CSV_V1_FAIL:-0}
DOC="analysis/phase-f-csv-v1.md"
MANIFEST="tests/baseline/f-csv-v1-closure.tsv"
die() { echo "f-csv-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-csv v1: csv.c → csv.x ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-csv v1' "$DOC" || die "doc marker"
[ -f std/csv/csv.x ] || die "missing csv.x"
[ ! -f std/csv/csv.c ] || die "csv.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'csv.x' compiler/Makefile || die "Makefile missing csv.x"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/csv/csv.o >/dev/null 2>&1 || die "make csv.o failed"
else
  echo "f-csv-v1 SKIP csv.o build (no shux-c)" >&2
fi
for sub in run-std-csv-row-gate.sh run-std-csv-stream-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-csv-v1 gate OK"
