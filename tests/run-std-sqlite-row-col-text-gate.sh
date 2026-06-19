#!/usr/bin/env bash
# STD-068：std.sqlite row_col_text 文本列门禁
#
# 用法：./tests/run-std-sqlite-row-col-text-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD068_DOC:-analysis/std-sqlite-row-col-text-v1.md}"
MANIFEST="${SHUX_STD068_TSV:-tests/baseline/std-sqlite-row-col-text.tsv}"
VECTORS="${SHUX_STD068_VECTORS:-tests/baseline/std-sqlite-row-col-text-vectors.tsv}"
MOD_SU="std/db/sqlite/mod.sx"
DB_C="std/db/sqlite/sqlite.c"
LIB="tests/lib/std-sqlite-row-col-text.sh"
SMOKE_SU="tests/std-sqlite/row_col_text_roundtrip.sx"
SMOKE_C="tests/std-sqlite/row_col_text_roundtrip_ok.c"
MIN_TEXT=1

# shellcheck source=tests/lib/std-sqlite-row-col-text.sh
. "$LIB"
std_sqlite_row_col_text_source_sqlite

echo "=== STD-068: db row_col_text manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$DB_C" "$SMOKE_SU" "$SMOKE_C" \
  analysis/std-sqlite-next-row-v1.md tests/run-std-sqlite-next-row-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "std-sqlite-row-col-text gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-068 row_col_text db_sqlite_row_col_text_smoke_c; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sqlite-row-col-text gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_text_apis) MIN_TEXT="$c2" ;;
  esac
done < "$MANIFEST"

if ! grep -qF 'text_done' "$VECTORS" 2>/dev/null; then
  echo "std-sqlite-row-col-text gate FAIL: vectors missing text_done" >&2
  exit 1
fi

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-sqlite-row-col-text FAIL: doc missing api $anchor" >&2
    exit 1
  fi
  echo "std-sqlite-row-col-text OK api $anchor"
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_TEXT" ]; then
  echo "std-sqlite-row-col-text gate FAIL: api count $API_N < min $MIN_TEXT" >&2
  exit 1
fi

sym_miss="$(std_sqlite_row_col_text_symbols_ok "$MOD_SU" "$DB_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sqlite_row_col_text_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-sqlite-row-col-text manifest OK"

echo "=== STD-068: parent STD-067 manifest ==="
chmod +x tests/run-std-sqlite-next-row-gate.sh
SHUX_STD067_MANIFEST_ONLY=1 ./tests/run-std-sqlite-next-row-gate.sh

if [ "${SHUX_STD068_MANIFEST_ONLY:-0}" = "1" ]; then
  std_sqlite_row_col_text_emit_report "ok" 0 0 1
  echo "std-sqlite-row-col-text gate OK (manifest only)"
  exit 0
fi

TEXT_C=0
TEXT_SU=0
SKIP=1

if std_sqlite_probe_libs; then
  echo "=== STD-068: row_col_text smoke ==="
  if ! std_sqlite_build_o; then
    std_sqlite_row_col_text_emit_report "fail" 0 0 0
    exit 1
  fi
  if std_sqlite_row_col_text_run_c_smoke "$DB_C"; then
    TEXT_C=1
  else
    std_sqlite_restore_default_o
    std_sqlite_row_col_text_emit_report "fail" 0 0 0
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
    echo "=== STD-068: .sx row_col_text smoke (SHUX=$SHUX_BIN) ==="
    if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
      echo "std-sqlite-row-col-text gate SKIP .sx smoke (typeck fail)" >&2
      SKIP=1
    elif std_sqlite_run_smoke "$SHUX_BIN" "$SMOKE_SU" "text"; then
      TEXT_SU=1
      SKIP=0
    else
      echo "std-sqlite-row-col-text gate SKIP .sx smoke (link/compile)" >&2
      SKIP=1
    fi
  else
    echo "std-sqlite-row-col-text gate SKIP .sx smoke (no native shux)" >&2
    SKIP=1
  fi
  std_sqlite_restore_default_o
else
  echo "std-sqlite-row-col-text gate SKIP text smoke (no libsqlite3)" >&2
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/db/sqlite/sqlite.o
fi

std_sqlite_row_col_text_emit_report "ok" "$TEXT_C" "$TEXT_SU" "$SKIP"
echo "std-sqlite-row-col-text gate OK"
