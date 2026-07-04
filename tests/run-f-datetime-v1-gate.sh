#!/usr/bin/env bash
# F-datetime v1：std.datetime 去 C（datetime.c → datetime.x + datetime_tz_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_DATETIME_V1_FAIL:-0}
DOC="analysis/phase-f-datetime-v1.md"
MANIFEST="tests/baseline/f-datetime-v1-closure.tsv"
die() { echo "f-datetime-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-datetime v1: datetime.c → datetime.x + tz glue ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-datetime v1' "$DOC" || die "doc marker"
[ -f std/datetime/datetime.x ] || die "missing datetime.x"
[ ! -f std/datetime/datetime_tz_glue.c ] || die "datetime_tz_glue.c should be deleted (F-ZC)"
[ ! -f std/datetime/datetime.c ] || die "datetime.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'datetime.x' compiler/Makefile || die "Makefile missing datetime.x"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/datetime/datetime.o >/dev/null 2>&1 || die "make datetime.o failed"
else
  echo "f-datetime-v1 SKIP datetime.o build (no shux-c)" >&2
fi
for sub in run-std-datetime-gate.sh run-std-datetime-iana-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-datetime-v1 gate OK"
