#!/usr/bin/env bash
# F-05 v3：std.db.sqlite 去 C 门禁。
#
# 用法：./tests/run-f05-std-db-sqlite-v3-gate.sh
# 环境：SHUX_F05_DB_SQLITE_V3_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F05_DB_SQLITE_V3_FAIL:-0}
DOC="analysis/phase-f-f05-v3.md"

die() {
  echo "f05-db-sqlite-v3 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-05 v3: std.db.sqlite remove sqlite.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-05 v3' "$DOC" || die "doc missing F-05 v3 marker"
[ ! -f std/db/sqlite/sqlite.c ] || die "sqlite.c should be deleted"
[ -f std/db/sqlite/sqlite.x ] || die "missing sqlite.x"
[ -f compiler/src/asm/runtime_sqlite_glue.c ] || die "missing sqlite_glue.c"
grep -q 'db_open_c' std/db/sqlite/sqlite.x || die "sqlite.x missing db_open_c"
grep -q 'db_sqlite_exec_smoke_c' std/db/sqlite/sqlite.x || die "sqlite.x missing smoke"
grep -q 'shu_sqlite3_open_c' compiler/src/asm/runtime_sqlite_glue.c || die "glue missing open"
grep -q 'shu_db_use_sqlite3_c' compiler/src/asm/runtime_sqlite_glue.c || die "glue missing use probe"
grep -q 'sqlite.x' compiler/Makefile || die "Makefile missing sqlite.x build"
if grep -q 'std/db/sqlite/sqlite\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references sqlite.c"
fi

[ ! -f std/db/sqlite/sqlite_glue.c ] || die "sqlite_glue.c should be deleted (F-ZC)"
grep -q 'runtime_sqlite_glue' compiler/Makefile || die "Makefile missing runtime_sqlite_glue"
make -C compiler ../std/db/sqlite/sqlite.o runtime_sqlite_glue.o >/dev/null 2>&1 || die "make sqlite.o failed"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
if nm std/db/sqlite/sqlite.o 2>/dev/null | grep -q ' db_sqlite_exec_smoke_c'; then
  cat >"$TMP/sqlite_smoke_main.c" <<'EOF'
#include <stdint.h>
extern int32_t db_sqlite_exec_smoke_c(void);
int main(void) {
  return db_sqlite_exec_smoke_c() == 0 ? 0 : 1;
}
EOF
  if ! cc -o "$TMP/sqlite_smoke" "$TMP/sqlite_smoke_main.c" std/db/sqlite/sqlite.o compiler/runtime_sqlite_glue.o -lsqlite3 2>/dev/null; then
    die "sqlite smoke compile failed (need libsqlite3)"
  fi
  "$TMP/sqlite_smoke" || die "sqlite smoke run failed"
  echo "f05 sqlite smoke OK"
else
  echo "f05 sqlite smoke SKIP (sqlite.o missing .x symbols; need shux-c)"
fi

if [ -f tests/run-std-sqlite-gate.sh ]; then
  echo "=== F-05 v3: delegate std-sqlite gate ==="
  chmod +x tests/run-std-sqlite-gate.sh
  if ! ./tests/run-std-sqlite-gate.sh; then
    die "std-sqlite sub-gate failed"
  fi
fi

echo "f05 std.db.sqlite v3 gate OK (F-05 v3)"
