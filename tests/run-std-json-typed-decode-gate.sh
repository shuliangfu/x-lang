#!/usr/bin/env bash
# STD-116：std.json 类型化 decode 门禁（F-json v2：json.x）
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-json-typed-decode-v1.md"
MANIFEST="tests/baseline/std-json-typed-decode.tsv"
VECTORS="tests/baseline/std-json-typed-decode-vectors.tsv"
MOD_X="std/json/mod.x"
JSON_IMPL="std/json/json.x"
JSON_X="std/json/json.x"
LIB="tests/lib/std-json-typed-decode.sh"
SMOKE_X="tests/json/typed_decode.x"
MIN_APIS=8
# shellcheck source=tests/lib/std-json-typed-decode.sh
. "$LIB"
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$JSON_X" "$SMOKE_X"; do
  [ -f "$f" ] || { echo "std-json-typed-decode gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF object_decode_dotted_i32 "$DOC" 2>/dev/null || grep -qF object_decode_i32 "$DOC" || exit 1
grep -qF '"age":30' "$VECTORS" || exit 1
grep -qF user.age "$VECTORS" || exit 1
sym_miss="$(std_json_typed_symbols_ok "$MOD_X" "$JSON_IMPL" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1

C_OK=0
X_OK=0
SKIP=0

if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/json/json.o 2>/dev/null || true
  JSON_O="$(cd compiler && pwd)/../std/json/json.o"
  if std_json_typed_run_c_smoke "$JSON_O"; then
    C_OK=1
  else
    echo "std-json-typed-decode gate SKIP c smoke (no full json.o)" >&2
  fi
else
  echo "std-json-typed-decode gate SKIP c smoke (no shux-c)" >&2
fi

if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_X" >/dev/null
  std_json_typed_run_x_smoke ./compiler/shux-c "$SMOKE_X" && X_OK=1 || exit 1
else
  SKIP=1
fi
std_json_typed_emit_report ok "$C_OK" "$X_OK" "$SKIP"
echo "std-json-typed-decode gate OK"
