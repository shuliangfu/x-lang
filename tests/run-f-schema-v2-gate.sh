#!/usr/bin/env bash
# F-schema v2：std.schema 逻辑全量 .x（删除 schema_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_SCHEMA_V2_FAIL:-0}
DOC="analysis/phase-f-schema-v2.md"
MANIFEST="tests/baseline/f-schema-v2-closure.tsv"
die() { echo "f-schema-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-schema v2: JSON/CSV decode → schema.x (zero glue) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-schema v2' "$DOC" || die "doc marker"
[ -f std/schema/schema.x ] || die "missing schema.x"
[ ! -f std/schema/schema_glue.c ] || die "schema_glue.c should be deleted"
[ ! -f std/schema/schema.c ] || die "schema.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'schema_create_c' std/schema/schema.x || die "schema.x missing create"
grep -q 'schema_decode_json_c' std/schema/schema.x || die "schema.x missing decode_json"
grep -q 'schema_smoke_c' std/schema/schema.x || die "schema.x missing smoke"
grep -q 'schema_f_schema_v2_marker_c' std/schema/schema.x || die "schema.x missing v2 marker"
grep -q 'F-schema v2' compiler/Makefile || die "Makefile missing F-schema v2 note"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/schema/schema.o >/dev/null 2>&1 || die "make schema.o failed"
else
  echo "f-schema-v2 SKIP schema.o build (no shux-c)" >&2
fi
chmod +x tests/run-std-schema-gate.sh
tests/run-std-schema-gate.sh || die "run-std-schema-gate failed"
echo "f-schema-v2 gate OK"
