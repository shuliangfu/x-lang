#!/usr/bin/env bash
# F-schema v1：std.schema 去 C（schema.c → schema.sx；v2 逻辑亦在 schema.sx）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_SCHEMA_V1_FAIL:-0}
DOC="analysis/phase-f-schema-v1.md"
MANIFEST="tests/baseline/f-schema-v1-closure.tsv"
die() { echo "f-schema-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-schema v1: schema.c → schema.sx (logic in sx since v2) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-schema v1' "$DOC" || die "doc marker"
[ -f std/schema/schema.sx ] || die "missing schema.sx"
[ ! -f std/schema/schema_glue.c ] || die "schema_glue.c should be deleted (see v2)"
[ ! -f std/schema/schema.c ] || die "schema.c should be deleted"
grep -q 'schema_create_c' std/schema/schema.sx || die "schema.sx missing decode logic"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'schema.sx' compiler/Makefile || die "Makefile missing schema.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/schema/schema.o >/dev/null 2>&1 || die "make schema.o failed"
else
  echo "f-schema-v1 SKIP schema.o build (no shux-c)" >&2
fi
chmod +x tests/run-std-schema-gate.sh
tests/run-std-schema-gate.sh || die "run-std-schema-gate failed"
echo "f-schema-v1 gate OK"
