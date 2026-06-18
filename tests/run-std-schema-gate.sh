#!/usr/bin/env bash
# STD-090：std.schema 门禁
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_SCHEMA_DOC:-analysis/std-schema-v1.md}"
MANIFEST="${SHU_STD_SCHEMA_MANIFEST:-tests/baseline/std-schema-manifest.tsv}"
MOD_SU="std/schema/mod.su"
SCHEMA_C="std/schema/schema.c"
LIB="tests/lib/std-schema.sh"
SMOKE_SU="tests/std-schema/decode_smoke.su"
SMOKE_C="tests/std-schema/schema_smoke_ok.c"
MIN_APIS=10

# shellcheck source=tests/lib/std-schema.sh
. "$LIB"

echo "=== STD-090: std.schema manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$SCHEMA_C" "$SMOKE_SU" "$SMOKE_C" std/schema/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-schema gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-090 schema_add_field decode_json decode_csv_row map_columns last_error_field; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-schema gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qE "function ${anchor}\\(" "$MOD_SU" 2>/dev/null; then
    echo "std-schema gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-schema gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_schema_symbols_ok "$MOD_SU" "$SCHEMA_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_schema_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-schema manifest OK"

C_OK=0
SU_OK=0
SKIP=0

echo "=== STD-090: schema c smoke ==="
make -C compiler ../std/schema/schema.o ../std/json/json.o ../std/csv/csv.o >/dev/null 2>&1
if cc -std=c11 -O1 -o /tmp/shu_schema_smoke \
  "$SMOKE_C" std/schema/schema.o std/json/json.o std/csv/csv.o 2>/dev/null; then
  if /tmp/shu_schema_smoke >/dev/null 2>&1; then C_OK=1; fi
  rm -f /tmp/shu_schema_smoke
fi
if [ "$C_OK" -eq 0 ]; then
  std_schema_emit_report "fail" 0 0 0
  echo "std-schema gate FAIL: c smoke" >&2
  exit 1
fi

SHU_BIN=""
if [ -x ./compiler/shu-c ]; then SHU_BIN=./compiler/shu-c; fi

if [ -n "$SHU_BIN" ]; then
  echo "=== STD-090: .su smoke (SHU=$SHU_BIN) ==="
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-schema gate FAIL: typeck" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_schema_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_schema_run_smoke "$SHU_BIN" "$SMOKE_SU" "decode"; then SU_OK=1; else
    std_schema_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_schema_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-schema gate OK"
