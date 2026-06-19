#!/usr/bin/env bash
# STD-116：std.json 类型化 decode 门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-json-typed-decode-v1.md"
MANIFEST="tests/baseline/std-json-typed-decode.tsv"
VECTORS="tests/baseline/std-json-typed-decode-vectors.tsv"
MOD_SU="std/json/mod.sx"
JSON_C="std/json/json.c"
LIB="tests/lib/std-json-typed-decode.sh"
SMOKE_SU="tests/json/typed_decode.sx"
MIN_APIS=8
. "$LIB"
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$JSON_C" "$SMOKE_SU"; do
  [ -f "$f" ] || { echo "std-json-typed-decode gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF object_decode_dotted_i32 "$DOC" 2>/dev/null || grep -qF object_decode_i32 "$DOC" || exit 1
grep -qF '"age":30' "$VECTORS" || exit 1
grep -qF user.age "$VECTORS" || exit 1
sym_miss="$(std_json_typed_symbols_ok "$MOD_SU" "$JSON_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/json/json.o
JSON_O="$(cd compiler && pwd)/../std/json/json.o"
C_OK=0
std_json_typed_run_c_smoke "$JSON_O" && C_OK=1 || exit 1
SU_OK=0
SKIP=0
if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_SU" >/dev/null
  std_json_typed_run_sx_smoke ./compiler/shux-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi
std_json_typed_emit_report ok "$C_OK" "$SU_OK" "$SKIP"
echo "std-json-typed-decode gate OK"
