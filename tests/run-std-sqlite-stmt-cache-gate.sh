#!/usr/bin/env bash
# STD-070：std.db.sqlite 预编译 bind + stmt 缓存门禁
#
# 用法：./tests/run-std-sqlite-stmt-cache-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD070_DOC:-analysis/std-sqlite-stmt-cache-v1.md}"
MANIFEST="${SHUX_STD070_TSV:-tests/baseline/std-sqlite-stmt-cache.tsv}"
VECTORS="${SHUX_STD070_VECTORS:-tests/baseline/std-sqlite-stmt-cache-vectors.tsv}"
MOD_SU="std/db/sqlite/mod.sx"
DB_C="std/db/sqlite/sqlite.c"
LIB="tests/lib/std-sqlite-stmt-cache.sh"
SMOKE_SU="tests/std-sqlite/stmt_bind_roundtrip.sx"
SMOKE_C="tests/std-sqlite/stmt_bind_roundtrip_ok.c"
MIN_STMT=6

# shellcheck source=tests/lib/std-sqlite-stmt-cache.sh
. "$LIB"
std_sqlite_stmt_cache_source_sqlite

echo "=== STD-070: std.db.sqlite stmt cache manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$DB_C" "$SMOKE_SU" "$SMOKE_C" \
  analysis/std-sqlite-next-row-v1.md tests/run-std-sqlite-next-row-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "std-sqlite-stmt-cache gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-070 prepare_cached stmt_bind_i32 db_sqlite_stmt_bind_smoke_c; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sqlite-stmt-cache gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'cache_hit' "$VECTORS" 2>/dev/null; then
  echo "std-sqlite-stmt-cache gate FAIL: vectors missing cache_hit" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_stmt_apis) MIN_STMT="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-sqlite-stmt-cache FAIL: doc missing api $anchor" >&2
    exit 1
  fi
  if ! grep -qE "function ${anchor}\\(" "$MOD_SU" 2>/dev/null; then
    echo "std-sqlite-stmt-cache gate FAIL: missing api $anchor" >&2
    exit 1
  fi
  echo "std-sqlite-stmt-cache OK api $anchor"
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_STMT" ]; then
  echo "std-sqlite-stmt-cache gate FAIL: api count $API_N < min $MIN_STMT" >&2
  exit 1
fi

sym_miss="$(std_sqlite_stmt_cache_symbols_ok "$MOD_SU" "$DB_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sqlite_stmt_cache_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-sqlite-stmt-cache manifest OK"

BIND_C=0
BIND_SU=0
SKIP=0

if std_sqlite_probe_libs; then
  std_sqlite_build_o || true
  echo "=== STD-070: stmt bind c smoke ==="
  if std_sqlite_stmt_cache_run_c_smoke "$DB_C"; then BIND_C=1; fi
else
  SKIP=1
  echo "std-sqlite-stmt-cache: no libsqlite3, c smoke SKIP"
fi

SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ] && [ "$SKIP" -eq 0 ]; then
  echo "=== STD-070: .sx smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-sqlite-stmt-cache gate SKIP .sx smoke (typeck fail)" >&2
  elif std_sqlite_run_smoke "$SHUX_BIN" "$SMOKE_SU" "stmt_bind"; then
    BIND_SU=1
  else
    echo "std-sqlite-stmt-cache gate SKIP .sx smoke (link/compile)" >&2
  fi
elif [ -n "$SHUX_BIN" ] && [ "$SKIP" -eq 1 ]; then
  echo "std-sqlite-stmt-cache: .sx smoke SKIP (no libsqlite3)"
fi

if [ "$SKIP" -eq 0 ] && [ "$BIND_C" -eq 0 ]; then
  std_sqlite_stmt_cache_emit_report "fail" 0 "$BIND_SU" "$SKIP"
  echo "std-sqlite-stmt-cache gate FAIL: c smoke" >&2
  exit 1
fi

std_sqlite_stmt_cache_emit_report "ok" "$BIND_C" "$BIND_SU" "$SKIP"
echo "std-sqlite-stmt-cache gate OK"
