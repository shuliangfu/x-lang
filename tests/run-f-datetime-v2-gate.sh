#!/usr/bin/env bash
# F-datetime v2：std.datetime 逻辑下沉（F-ZC 纯 .x；本地偏移经 std.time）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_DATETIME_V2_FAIL:-0}
DOC="analysis/phase-f-datetime-v2.md"
MANIFEST="tests/baseline/f-datetime-v2-closure.tsv"
die() { echo "f-datetime-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-datetime v2: datetime.x (F-ZC zero C) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-datetime v2' "$DOC" || die "doc marker"
[ -f std/datetime/datetime.x ] || die "missing datetime.x"
[ ! -f std/datetime/datetime_tz_glue.c ] || die "datetime_tz_glue.c should be deleted (F-ZC)"
[ ! -f std/datetime/datetime_glue.c ] || die "datetime_glue.c should be deleted"
[ ! -f std/datetime/timezone_iana.inc.c ] || die "timezone_iana.inc.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'datetime_parse_rfc3339_c' std/datetime/datetime.x || die "datetime.x missing parse"
grep -q 'datetime_iana_dst_smoke_c' std/datetime/datetime.x || die "datetime.x missing iana smoke"
grep -q 'datetime_smoke_c' std/datetime/datetime.x || die "datetime.x missing smoke"
grep -q 'datetime_f_datetime_v2_marker_c' std/datetime/datetime.x || die "datetime.x missing v2 marker"
grep -q 'datetime_f_zero_c_marker_c' std/datetime/datetime.x || die "datetime.x missing zero-c marker"
grep -q 'datetime_local_offset_min_c' std/datetime/datetime.x || die "datetime.x missing local offset"
grep -q 'time_wall_local_offset_min_c' std/datetime/datetime.x || die "datetime.x missing time extern"
grep -q 'datetime.x' compiler/Makefile || die "Makefile missing datetime.x"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/datetime/datetime.o >/dev/null 2>&1 || die "make datetime.o failed"
else
  echo "f-datetime-v2 SKIP datetime.o build (no shux-c)" >&2
fi
for sub in run-std-datetime-gate.sh run-std-datetime-timezone-gate.sh run-std-datetime-iana-gate.sh; do
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-datetime-v2 gate OK"
