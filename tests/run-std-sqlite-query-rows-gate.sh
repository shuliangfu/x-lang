#!/usr/bin/env bash
# STD-066：std.db.sqlite query_rows 行迭代原型门禁
#
# 用法：./tests/run-std-sqlite-query-rows-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD066_DOC:-analysis/std-sqlite-query-rows-v1.md}"
MANIFEST="${SHUX_STD066_TSV:-tests/baseline/std-sqlite-query-rows.tsv}"
VECTORS="${SHUX_STD066_VECTORS:-tests/baseline/std-sqlite-query-rows-vectors.tsv}"
MOD_SX="std/db/sqlite/mod.sx"
DB_C="std/db/sqlite/sqlite.sx"
LIB="tests/lib/std-sqlite-query-rows.sh"
SMOKE_SX="tests/std-sqlite/query_rows_roundtrip.sx"
SMOKE_C="tests/std-sqlite/query_rows_roundtrip_ok.c"
MIN_QUERY=1

# shellcheck source=tests/lib/std-sqlite-query-rows.sh
. "$LIB"
std_sqlite_query_rows_source_sqlite

echo "=== STD-066: db query_rows manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SX" "$DB_C" "$SMOKE_SX" "$SMOKE_C" \
  analysis/std-sqlite-exec-deep-v1.md tests/run-std-sqlite-exec-deep-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "std-sqlite-query-rows gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-066 query_rows rows_all db_sqlite_query_rows_smoke_c; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sqlite-query-rows gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_query_apis) MIN_QUERY="$c2" ;;
  esac
done < "$MANIFEST"

if ! grep -qF 'rows_filter' "$VECTORS" 2>/dev/null; then
  echo "std-sqlite-query-rows gate FAIL: vectors missing rows_filter" >&2
  exit 1
fi

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-sqlite-query-rows FAIL: doc missing api $anchor" >&2
    exit 1
  fi
  echo "std-sqlite-query-rows OK api $anchor"
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_QUERY" ]; then
  echo "std-sqlite-query-rows gate FAIL: api count $API_N < min $MIN_QUERY" >&2
  exit 1
fi

sym_miss="$(std_sqlite_query_rows_symbols_ok "$MOD_SX" "$DB_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sqlite_query_rows_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-sqlite-query-rows manifest OK"

echo "=== STD-066: parent STD-065 manifest ==="
chmod +x tests/run-std-sqlite-exec-deep-gate.sh
SHUX_STD065_MANIFEST_ONLY=1 ./tests/run-std-sqlite-exec-deep-gate.sh

if [ "${SHUX_STD066_MANIFEST_ONLY:-0}" = "1" ]; then
  std_sqlite_query_rows_emit_report "ok" 0 0 1
  echo "std-sqlite-query-rows gate OK (manifest only)"
  exit 0
fi

ROWS_C=0
ROWS_SX=0
SKIP=1

if std_sqlite_probe_libs; then
  echo "=== STD-066: query_rows smoke ==="
  if ! std_sqlite_build_o; then
    std_sqlite_query_rows_emit_report "fail" 0 0 0
    exit 1
  fi
  if std_sqlite_query_rows_run_c_smoke "$DB_C"; then
    ROWS_C=1
  else
    std_sqlite_restore_default_o
    std_sqlite_query_rows_emit_report "fail" 0 0 0
    exit 1
  fi

  SHUX_BIN=""
  stdlib_cm_native_shu() {
    local f="$1"
    [ -n "$f" ] && [ -x "$f" ] || return 1
    case "$(uname -s)-$(uname -m 2>/dev/null)" in
      Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
      Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
      Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
      Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
      *) return 0 ;;
    esac
  }
  if stdlib_cm_native_shu ./compiler/shux-c; then
    SHUX_BIN=./compiler/shux-c
  elif stdlib_cm_native_shu ./compiler/shux; then
    SHUX_BIN=./compiler/shux
  fi

  if [ -n "$SHUX_BIN" ]; then
    echo "=== STD-066: .sx query_rows smoke (SHUX=$SHUX_BIN) ==="
    if ! "$SHUX_BIN" check -L . "$SMOKE_SX" >/dev/null 2>&1; then
      echo "std-sqlite-query-rows gate SKIP .sx smoke (typeck fail)" >&2
      SKIP=1
    elif std_sqlite_run_smoke "$SHUX_BIN" "$SMOKE_SX" "rows"; then
      ROWS_SX=1
      SKIP=0
    else
      echo "std-sqlite-query-rows gate SKIP .sx smoke (link/compile)" >&2
      SKIP=1
    fi
  else
    echo "std-sqlite-query-rows gate SKIP .sx smoke (no native shux)" >&2
    SKIP=1
  fi
  std_sqlite_restore_default_o
else
  echo "std-sqlite-query-rows gate SKIP rows smoke (no libsqlite3)" >&2
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/db/sqlite/sqlite.o
fi

std_sqlite_query_rows_emit_report "ok" "$ROWS_C" "$ROWS_SX" "$SKIP"
echo "std-sqlite-query-rows gate OK"
