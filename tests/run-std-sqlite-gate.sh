#!/usr/bin/env bash
# STD-057：std.sqlite SQLite3 后端门禁
#
# 用法：./tests/run-std-sqlite-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_SQLITE_DOC:-analysis/std-sqlite-v1.md}"
MANIFEST="${SHUX_STD_SQLITE_TSV:-tests/baseline/std-sqlite.tsv}"
VECTORS="${SHUX_STD_SQLITE_VECTORS:-tests/baseline/std-sqlite-vectors.tsv}"
MOD_SU="std/db/sqlite/mod.sx"
SQLITE_C="std/db/sqlite/sqlite.c"
LIB="tests/lib/std-sqlite-gate.sh"
SMOKE_SU="tests/std-sqlite/exec_roundtrip.sx"
SMOKE_IMPORT_SU="tests/std-sqlite/import_smoke.sx"
SMOKE_C="tests/std-sqlite/exec_roundtrip_ok.c"
PREREQ_DOC="analysis/std-sqlite-prereq-v1.md"
MIN_APIS=4

# shellcheck source=tests/lib/std-sqlite-gate.sh
. "$LIB"

echo "=== STD-057: std.sqlite manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$SQLITE_C" "$SMOKE_SU" "$SMOKE_IMPORT_SU" "$SMOKE_C" "$PREREQ_DOC" std/db/sqlite/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-sqlite gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-057 sqlite3_exec DB_ERR_EXEC exec_roundtrip; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sqlite gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'INSERT INTO t' "$VECTORS" 2>/dev/null; then
  echo "std-sqlite gate FAIL: vectors missing insert_row" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$MOD_SU" 2>/dev/null; then
        echo "std-sqlite gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-sqlite gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-sqlite gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_sqlite_symbols_ok "$MOD_SU" "$SQLITE_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sqlite_emit_report "fail" 0 0 0
  echo "std-sqlite gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-sqlite manifest OK"

if [ "${SHUX_STD_SQLITE_MANIFEST_ONLY:-0}" = "1" ]; then
  std_sqlite_emit_report "ok" 0 0 1
  echo "std-sqlite gate OK (manifest only)"
  exit 0
fi

C_OK=0
SU_OK=0
SKIP=0

if std_sqlite_probe_libs; then
  echo "=== STD-057: sqlite exec smoke ==="
  if ! std_sqlite_build_o; then
    std_sqlite_emit_report "fail" 0 0 0
    exit 1
  fi
  if std_sqlite_run_c_smoke "$SQLITE_C"; then
    C_OK=1
  else
    std_sqlite_restore_default_o
    std_sqlite_emit_report "fail" 0 0 0
    exit 1
  fi

  SHUX_BIN=""
  if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

  if [ -n "$SHUX_BIN" ]; then
    echo "=== STD-057: .sx smoke (SHUX=$SHUX_BIN) ==="
    if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
      echo "std-sqlite gate FAIL: typeck $SMOKE_SU" >&2
      std_sqlite_restore_default_o
      std_sqlite_emit_report "fail" "$C_OK" 0 0
      exit 1
    fi
    if std_sqlite_run_smoke "$SHUX_BIN" "$SMOKE_SU" "rt"; then
      SU_OK=1
    else
      std_sqlite_restore_default_o
      std_sqlite_emit_report "fail" "$C_OK" 0 0
      exit 1
    fi
    if ! "$SHUX_BIN" check -L . "$SMOKE_IMPORT_SU" >/dev/null 2>&1; then
      echo "std-sqlite gate FAIL: typeck $SMOKE_IMPORT_SU" >&2
      std_sqlite_restore_default_o
      std_sqlite_emit_report "fail" "$C_OK" "$SU_OK" 0
      exit 1
    fi
    if ! std_sqlite_run_smoke "$SHUX_BIN" "$SMOKE_IMPORT_SU" "import"; then
      std_sqlite_restore_default_o
      std_sqlite_emit_report "fail" "$C_OK" "$SU_OK" 0
      exit 1
    fi
  else
    echo "std-sqlite gate SKIP .sx smoke (no native shux)" >&2
    SKIP=1
  fi
  std_sqlite_restore_default_o
else
  echo "std-sqlite gate SKIP exec smoke (no libsqlite3)" >&2
  SKIP=1
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/db/sqlite/sqlite.o
fi

std_sqlite_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-sqlite gate OK"
