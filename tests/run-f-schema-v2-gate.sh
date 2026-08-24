#!/usr/bin/env bash
# F-schema v2：std.schema 逻辑全量 .x（删除 schema_glue.c）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_SCHEMA_V2_FAIL:-0}
DOC="analysis/archive/phase/phase-f-schema-v2.md"
MANIFEST="tests/baseline/f-schema-v2-closure.tsv"
die() { echo "f-schema-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-schema v2: JSON/CSV decode → schema.x (zero glue) ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
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
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/schema/schema.o >/dev/null 2>&1 || die "ensure schema.o failed (xlang_compiler_make)"
else
  echo "f-schema-v2 SKIP schema.o build (no xlang-c)" >&2
fi
chmod +x tests/run-std-schema-gate.sh
tests/run-std-schema-gate.sh || die "run-std-schema-gate failed"
echo "f-schema-v2 gate OK"
