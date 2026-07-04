#!/usr/bin/env bash
# STD-090：std.schema 门禁
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_SCHEMA_DOC:-analysis/std-schema-v1.md}"
MANIFEST="${SHUX_STD_SCHEMA_MANIFEST:-tests/baseline/std-schema-manifest.tsv}"
MOD_X="std/schema/mod.x"
SCHEMA_X="std/schema/schema.x"
LIB="tests/lib/std-schema.sh"
SMOKE_X="tests/std-schema/decode_smoke.x"
SMOKE_C="tests/std-schema/schema_smoke_ok.c"
MIN_APIS=10

# shellcheck source=tests/lib/std-schema.sh
. "$LIB"

echo "=== STD-090: std.schema manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SCHEMA_X" "$SMOKE_X" "$SMOKE_C" std/schema/README.md; do
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
  if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
    echo "std-schema gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-schema gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_schema_symbols_ok "$MOD_X" "$SCHEMA_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_schema_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-schema manifest OK"

C_OK=0
X_OK=0
SKIP=0

echo "=== STD-090: schema c smoke ==="
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/schema/schema.o ../std/json/json.o >/dev/null 2>&1
  make -C compiler ../std/csv/csv.o >/dev/null 2>&1 || true
  if [ -f std/csv/csv.o ] && [ -f std/json/json.o ] && [ -f std/schema/schema.o ]; then
    if cc -std=c11 -O1 -o /tmp/shux_schema_smoke \
      "$SMOKE_C" std/schema/schema.o std/json/json.o std/csv/csv.o 2>/dev/null; then
      if /tmp/shux_schema_smoke >/dev/null 2>&1; then C_OK=1; fi
      rm -f /tmp/shux_schema_smoke
    fi
  fi
else
  echo "std-schema gate SKIP c smoke (need shux-c for schema.x → schema.o)" >&2
  SKIP=1
fi
if [ "$C_OK" -eq 0 ] && [ "$SKIP" -eq 0 ]; then
  std_schema_emit_report "fail" 0 0 0
  echo "std-schema gate FAIL: c smoke" >&2
  exit 1
fi

SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-090: .x smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "std-schema gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -10 >&2 || true
    std_schema_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_schema_run_smoke "$SHUX_BIN" "$SMOKE_X" "decode"; then X_OK=1; else
    std_schema_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  echo "std-schema gate SKIP .x smoke (no shux)" >&2
  SKIP=1
fi

std_schema_emit_report "ok" "$C_OK" "$X_OK" "$SKIP"
echo "std-schema gate OK"
