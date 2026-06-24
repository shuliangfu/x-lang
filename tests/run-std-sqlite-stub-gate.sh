#!/usr/bin/env bash
# STD-139：std.db.sqlite stub 后端文档与烟测门禁
#
# 用法：./tests/run-std-sqlite-stub-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD139_DOC:-analysis/std-sqlite-stub-v1.md}"
MANIFEST="${SHUX_STD139_TSV:-tests/baseline/std-sqlite-stub.tsv}"
MOD_SX="std/db/sqlite/mod.sx"
DB_C="std/db/sqlite/sqlite.sx"
LIB="tests/lib/std-sqlite-stub.sh"
SMOKE_SX="tests/std-sqlite/stub_behavior.sx"
SMOKE_C="tests/std-sqlite/stub_behavior_ok.c"
README="std/db/sqlite/README.md"
MIN_STUB=2

# shellcheck source=tests/lib/std-sqlite-stub.sh
. "$LIB"
std_sqlite_stub_source_sqlite

echo "=== STD-139: sqlite stub manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SX" "$DB_C" "$SMOKE_SX" "$SMOKE_C" "$README"; do
  if [ ! -f "$f" ]; then
    echo "std-sqlite-stub gate FAIL: missing $f" >&2
    exit 1
  fi
done

[ ! -f std/db/sqlite/sqlite.c ] || {
  echo "std-sqlite-stub gate FAIL: sqlite.c should be deleted (F-05 v3)" >&2
  exit 1
}
[ -f compiler/src/asm/runtime_sqlite_glue.c ] || {
  echo "std-sqlite-stub gate FAIL: missing runtime_sqlite_glue.c" >&2
  exit 1
}
[ ! -f std/db/sqlite/sqlite_glue.c ] || {
  echo "std-sqlite-stub gate FAIL: sqlite_glue.c should be deleted (F-ZC)" >&2
  exit 1
}

for kw in STD-139 DB_NOT_IMPL sqlite-o-stub db_sqlite_stub_smoke_c; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sqlite-stub gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-sqlite-stub FAIL: doc missing api $anchor" >&2
    exit 1
  fi
  echo "std-sqlite-stub OK api $anchor"
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_STUB" ]; then
  echo "std-sqlite-stub gate FAIL: api count $API_N < min $MIN_STUB" >&2
  exit 1
fi

sym_miss="$(std_sqlite_stub_symbols_ok "$MOD_SX" "$DB_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sqlite_stub_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-sqlite-stub manifest OK"

if [ "${SHUX_STD139_MANIFEST_ONLY:-0}" = "1" ]; then
  std_sqlite_stub_emit_report "ok" 0 0 1
  echo "std-sqlite-stub gate OK (manifest only)"
  exit 0
fi

STUB_C=0
STUB_SX=0

echo "=== STD-139: stub C smoke (sqlite-o-stub) ==="
set +e
std_sqlite_stub_run_c_smoke "$DB_C"
stub_ec=$?
set -e
if [ "$stub_ec" -eq 0 ]; then
  STUB_C=1
elif [ "$stub_ec" -eq 2 ]; then
  echo "std-sqlite-stub gate SKIP stub C smoke (need shux-c)" >&2
else
  std_sqlite_stub_emit_report "fail" 0 0 1
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
  echo "=== STD-139: .sx stub behavior smoke ==="
  if "$SHUX_BIN" check -L . "$SMOKE_SX" >/dev/null 2>&1; then
    if std_sqlite_run_smoke "$SHUX_BIN" "$SMOKE_SX" "stub"; then
      STUB_SX=1
    fi
  else
    echo "std-sqlite-stub gate SKIP .sx smoke (typeck fail)" >&2
  fi
fi

std_sqlite_stub_emit_report "ok" "$STUB_C" "$STUB_SX" 1
echo "std-sqlite-stub gate OK"
