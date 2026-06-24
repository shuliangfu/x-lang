#!/usr/bin/env bash
# F-json v1：std.json 去 C（json.c → json.sx；胶层 v2 已删，见 run-f-json-v2-gate.sh）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_JSON_V1_FAIL:-0}
DOC="analysis/phase-f-json-v1.md"
MANIFEST="tests/baseline/f-json-v1-closure.tsv"
die() { echo "f-json-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-json v1: json.c → json.sx (glue superseded by v2) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-json v1' "$DOC" || die "doc marker"
[ -f std/json/json.sx ] || die "missing json.sx"
[ ! -f std/json/json.c ] || die "json.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'json.sx' compiler/Makefile || die "Makefile missing json.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/json/json.o >/dev/null 2>&1 || die "make json.o failed"
else
  echo "f-json-v1 SKIP json.o build (no shux-c)" >&2
fi
for sub in run-std-json-gate.sh run-std-json-object-array-gate.sh \
  run-std-json-serialize-gate.sh run-std-json-typed-decode-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-json-v1 gate OK"
