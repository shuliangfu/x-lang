#!/usr/bin/env bash
# F-json v2：std.json 逻辑下沉（解析/游标/序列化 → json.x；删除 json_parse_glue.c）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_JSON_V2_FAIL:-0}
DOC="analysis/archive/phase/phase-f-json-v2.md"
MANIFEST="tests/baseline/f-json-v2-closure.tsv"
die() { echo "f-json-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-json v2: json logic → json.x (pure) ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-json v2' "$DOC" || die "doc marker"
[ -f std/json/json.x ] || die "missing json.x"
[ ! -f std/json/json_parse_glue.c ] || die "json_parse_glue.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'json_parse_number_c' std/json/json.x || die "json.x missing parse_number"
grep -q 'json_typed_decode_smoke_c' std/json/json.x || die "json.x missing typed smoke"
grep -q 'json_parse_string_view_c' std/json/json.x || die "json.x missing string view"
grep -q 'json_f_json_v2_marker_c' std/json/json.x || die "json.x missing v2 marker"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/json/json.o >/dev/null 2>&1 || die "ensure json.o failed (xlang_compiler_make)"
else
  echo "f-json-v2 SKIP json.o build (no xlang-c)" >&2
fi
for sub in run-std-json-gate.sh run-std-json-object-array-gate.sh \
  run-std-json-serialize-gate.sh run-std-json-typed-decode-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-json-v2 gate OK"
