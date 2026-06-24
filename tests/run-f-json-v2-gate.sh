#!/usr/bin/env bash
# F-json v2：std.json 逻辑下沉（解析/游标/序列化 → json.sx；删除 json_parse_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_JSON_V2_FAIL:-0}
DOC="analysis/phase-f-json-v2.md"
MANIFEST="tests/baseline/f-json-v2-closure.tsv"
die() { echo "f-json-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-json v2: json logic → json.sx (pure) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-json v2' "$DOC" || die "doc marker"
[ -f std/json/json.sx ] || die "missing json.sx"
[ ! -f std/json/json_parse_glue.c ] || die "json_parse_glue.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'json_parse_number_c' std/json/json.sx || die "json.sx missing parse_number"
grep -q 'json_typed_decode_smoke_c' std/json/json.sx || die "json.sx missing typed smoke"
grep -q 'json_parse_string_view_c' std/json/json.sx || die "json.sx missing string view"
grep -q 'json_f_json_v2_marker_c' std/json/json.sx || die "json.sx missing v2 marker"
grep -q 'json.sx' compiler/Makefile || die "Makefile missing json.sx"
grep -q 'json_parse_glue.c' compiler/Makefile && die "Makefile still references json_parse_glue.c"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/json/json.o >/dev/null 2>&1 || die "make json.o failed"
else
  echo "f-json-v2 SKIP json.o build (no shux-c)" >&2
fi
for sub in run-std-json-gate.sh run-std-json-object-array-gate.sh \
  run-std-json-serialize-gate.sh run-std-json-typed-decode-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-json-v2 gate OK"
