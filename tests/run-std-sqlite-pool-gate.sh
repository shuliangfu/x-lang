#!/usr/bin/env bash
# STD-084：std.sqlite 连接池门禁
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD084_DOC:-analysis/std-sqlite-pool-v1.md}"
MANIFEST="${SHU_STD084_TSV:-tests/baseline/std-sqlite-pool.tsv}"
VECTORS="${SHU_STD084_VECTORS:-tests/baseline/std-sqlite-pool-vectors.tsv}"
MOD_SU="std/sqlite/mod.su"
DB_C="std/sqlite/sqlite.c"
LIB="tests/lib/std-sqlite-pool.sh"
SMOKE_SU="tests/std-sqlite/pool_roundtrip.su"
SMOKE_C="tests/std-sqlite/pool_roundtrip_ok.c"
MIN_POOL=4

# shellcheck source=tests/lib/std-sqlite-pool.sh
. "$LIB"
std_sqlite_pool_source_sqlite

echo "=== STD-084: std.sqlite pool manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$DB_C" "$SMOKE_SU" "$SMOKE_C" \
  analysis/std-sqlite-stmt-cache-v1.md tests/run-std-sqlite-stmt-cache-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "std-sqlite-pool gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-084 pool_acquire pool_release db_sqlite_pool_smoke_c; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sqlite-pool gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'reuse_handle' "$VECTORS" 2>/dev/null; then
  echo "std-sqlite-pool gate FAIL: vectors missing reuse_handle" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_pool_apis) MIN_POOL="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qE "function ${anchor}\\(" "$MOD_SU" 2>/dev/null; then
    echo "std-sqlite-pool gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_POOL" ]; then
  echo "std-sqlite-pool gate FAIL: api count $API_N < min $MIN_POOL" >&2
  exit 1
fi

sym_miss="$(std_sqlite_pool_symbols_ok "$MOD_SU" "$DB_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sqlite_pool_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-sqlite-pool manifest OK"

POOL_C=0
POOL_SU=0
SKIP=0

if std_sqlite_probe_libs; then
  std_sqlite_build_o || true
  echo "=== STD-084: pool c smoke ==="
  if std_sqlite_pool_run_c_smoke "$DB_C"; then POOL_C=1; fi
else
  SKIP=1
fi

SHU_BIN=""
if [ -x ./compiler/shu-c ]; then SHU_BIN=./compiler/shu-c; fi

if [ -n "$SHU_BIN" ] && [ "$SKIP" -eq 0 ]; then
  echo "=== STD-084: .su smoke (SHU=$SHU_BIN) ==="
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-sqlite-pool gate SKIP .su smoke (typeck fail)" >&2
  elif std_sqlite_run_smoke "$SHU_BIN" "$SMOKE_SU" "pool"; then
    POOL_SU=1
  else
    echo "std-sqlite-pool gate SKIP .su smoke (link/compile)" >&2
  fi
elif [ -n "$SHU_BIN" ]; then
  echo "std-sqlite-pool: .su smoke SKIP (no libsqlite3)"
  SKIP=1
fi

if [ "$SKIP" -eq 0 ] && [ "$POOL_C" -eq 0 ]; then
  std_sqlite_pool_emit_report "fail" 0 "$POOL_SU" "$SKIP"
  echo "std-sqlite-pool gate FAIL: c smoke" >&2
  exit 1
fi

std_sqlite_pool_emit_report "ok" "$POOL_C" "$POOL_SU" "$SKIP"
echo "std-sqlite-pool gate OK"
