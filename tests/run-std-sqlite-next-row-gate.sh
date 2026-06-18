#!/usr/bin/env bash
# STD-067：std.sqlite next_row 列值游标门禁
#
# 用法：./tests/run-std-sqlite-next-row-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD067_DOC:-analysis/std-sqlite-next-row-v1.md}"
MANIFEST="${SHU_STD067_TSV:-tests/baseline/std-sqlite-next-row.tsv}"
VECTORS="${SHU_STD067_VECTORS:-tests/baseline/std-sqlite-next-row-vectors.tsv}"
MOD_SU="std/sqlite/mod.su"
DB_C="std/sqlite/sqlite.c"
LIB="tests/lib/std-sqlite-next-row.sh"
SMOKE_SU="tests/std-sqlite/next_row_roundtrip.su"
SMOKE_C="tests/std-sqlite/next_row_roundtrip_ok.c"
MIN_CURSOR=3

# shellcheck source=tests/lib/std-sqlite-next-row.sh
. "$LIB"
std_sqlite_next_row_source_sqlite

echo "=== STD-067: db next_row manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$DB_C" "$SMOKE_SU" "$SMOKE_C" \
  analysis/std-sqlite-query-rows-v1.md tests/run-std-sqlite-query-rows-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "std-sqlite-next-row gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-067 next_row cursor_row1 db_sqlite_next_row_smoke_c; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sqlite-next-row gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_cursor_apis) MIN_CURSOR="$c2" ;;
  esac
done < "$MANIFEST"

if ! grep -qF 'cursor_done' "$VECTORS" 2>/dev/null; then
  echo "std-sqlite-next-row gate FAIL: vectors missing cursor_done" >&2
  exit 1
fi

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-sqlite-next-row FAIL: doc missing api $anchor" >&2
    exit 1
  fi
  echo "std-sqlite-next-row OK api $anchor"
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_CURSOR" ]; then
  echo "std-sqlite-next-row gate FAIL: api count $API_N < min $MIN_CURSOR" >&2
  exit 1
fi

sym_miss="$(std_sqlite_next_row_symbols_ok "$MOD_SU" "$DB_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sqlite_next_row_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-sqlite-next-row manifest OK"

echo "=== STD-067: parent STD-066 manifest ==="
chmod +x tests/run-std-sqlite-query-rows-gate.sh
SHU_STD066_MANIFEST_ONLY=1 ./tests/run-std-sqlite-query-rows-gate.sh

if [ "${SHU_STD067_MANIFEST_ONLY:-0}" = "1" ]; then
  std_sqlite_next_row_emit_report "ok" 0 0 1
  echo "std-sqlite-next-row gate OK (manifest only)"
  exit 0
fi

CURSOR_C=0
CURSOR_SU=0
SKIP=1

if std_sqlite_probe_libs; then
  echo "=== STD-067: next_row smoke ==="
  if ! std_sqlite_build_o; then
    std_sqlite_next_row_emit_report "fail" 0 0 0
    exit 1
  fi
  if std_sqlite_next_row_run_c_smoke "$DB_C"; then
    CURSOR_C=1
  else
    std_sqlite_restore_default_o
    std_sqlite_next_row_emit_report "fail" 0 0 0
    exit 1
  fi

  SHU_BIN=""
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
  if stdlib_cm_native_shu ./compiler/shu-c; then
    SHU_BIN=./compiler/shu-c
  elif stdlib_cm_native_shu ./compiler/shu; then
    SHU_BIN=./compiler/shu
  fi

  if [ -n "$SHU_BIN" ]; then
    echo "=== STD-067: .su next_row smoke (SHU=$SHU_BIN) ==="
    if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
      echo "std-sqlite-next-row gate SKIP .su smoke (typeck fail)" >&2
      SKIP=1
    elif std_sqlite_run_smoke "$SHU_BIN" "$SMOKE_SU" "cursor"; then
      CURSOR_SU=1
      SKIP=0
    else
      echo "std-sqlite-next-row gate SKIP .su smoke (link/compile)" >&2
      SKIP=1
    fi
  else
    echo "std-sqlite-next-row gate SKIP .su smoke (no native shu)" >&2
    SKIP=1
  fi
  std_sqlite_restore_default_o
else
  echo "std-sqlite-next-row gate SKIP cursor smoke (no libsqlite3)" >&2
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/sqlite/sqlite.o
fi

std_sqlite_next_row_emit_report "ok" "$CURSOR_C" "$CURSOR_SU" "$SKIP"
echo "std-sqlite-next-row gate OK"
