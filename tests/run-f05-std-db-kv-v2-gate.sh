#!/usr/bin/env bash
# F-05 v2：std.db.kv 去 C 门禁。
#
# 用法：./tests/run-f05-std-db-kv-v2-gate.sh
# 环境：SHUX_F05_DB_KV_V2_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F05_DB_KV_V2_FAIL:-0}
DOC="analysis/phase-f-f05-v2.md"

die() {
  echo "f05-db-kv-v2 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-05 v2: std.db.kv remove kv.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-05 v2' "$DOC" || die "doc missing F-05 v2 marker"
[ ! -f std/db/kv/kv.c ] || die "kv.c should be deleted"
[ -f std/db/kv/kv.sx ] || die "missing kv.sx"
[ -f compiler/src/asm/runtime_kv_mmap_glue.c ] || die "missing kv_mmap_glue.c"
grep -q 'db_kv_open_c' std/db/kv/kv.sx || die "kv.sx missing db_kv_open_c"
grep -q 'db_kv_smoke_c' std/db/kv/kv.sx || die "kv.sx missing smoke"
[ ! -f std/db/kv/kv_mmap_glue.c ] || die "kv_mmap_glue.c should be deleted (F-ZC)"
grep -q 'shu_kv_mmap_file_c' compiler/src/asm/runtime_kv_mmap_glue.c || die "glue missing mmap"
grep -q 'runtime_kv_mmap_glue' compiler/Makefile || die "Makefile missing runtime_kv_mmap_glue"
grep -q 'kv.sx' compiler/Makefile || die "Makefile missing kv.sx build"
if grep -q 'std/db/kv/kv\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references kv.c"
fi

make -C compiler ../std/db/kv/kv.o runtime_kv_mmap_glue.o >/dev/null 2>&1 || die "make kv.o failed"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
if nm std/db/kv/kv.o 2>/dev/null | grep -q ' db_kv_smoke_c'; then
  KV_PATH="$TMP/kv_smoke.dat"
  cat >"$TMP/kv_smoke_main.c" <<EOF
#include <stdint.h>
extern int32_t db_kv_smoke_c(uint8_t *path);
int main(void) {
  uint8_t p[] = "$KV_PATH";
  return db_kv_smoke_c(p) == 0 ? 0 : 1;
}
EOF
  if ! cc -o "$TMP/kv_smoke" "$TMP/kv_smoke_main.c" std/db/kv/kv.o compiler/runtime_kv_mmap_glue.o 2>/dev/null; then
    die "kv smoke compile failed"
  fi
  "$TMP/kv_smoke" || die "kv smoke run failed"
  echo "f05 kv smoke OK"
else
  echo "f05 kv smoke SKIP (kv.o missing .sx symbols; need shux-c)"
fi

if [ -f tests/run-std-db-kv-arrow-gate.sh ]; then
  echo "=== F-05 v2: delegate kv+arrow gate ==="
  chmod +x tests/run-std-db-kv-arrow-gate.sh
  if ! ./tests/run-std-db-kv-arrow-gate.sh; then
    die "kv+arrow sub-gate failed"
  fi
fi

echo "f05 std.db.kv v2 gate OK (F-05 v2)"
