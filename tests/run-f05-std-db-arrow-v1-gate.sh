#!/usr/bin/env bash
# F-05 v1：std.db.arrow 去 C 门禁。
#
# 用法：./tests/run-f05-std-db-arrow-v1-gate.sh
# 环境：SHUX_F05_DB_ARROW_V1_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F05_DB_ARROW_V1_FAIL:-0}
DOC="analysis/phase-f-f05-v1.md"

die() {
  echo "f05-db-arrow-v1 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-05 v1: std.db.arrow remove arrow.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-05 v1' "$DOC" || die "doc missing F-05 v1 marker"
[ ! -f std/db/arrow/arrow.c ] || die "arrow.c should be deleted"
[ -f std/db/arrow/arrow.sx ] || die "missing arrow.sx"
[ -f compiler/src/asm/runtime_arrow_simd_glue.c ] || die "missing arrow_simd_glue.c"
grep -q 'arrow_column_i32_create_c' std/db/arrow/arrow.sx || die "arrow.sx missing create"
grep -q 'arrow_smoke_c' std/db/arrow/arrow.sx || die "arrow.sx missing smoke"
[ ! -f std/db/arrow/arrow_simd_glue.c ] || die "arrow_simd_glue.c should be deleted (F-ZC)"
grep -q 'runtime_arrow_simd_glue' compiler/Makefile || die "Makefile missing runtime_arrow_simd_glue"
grep -q 'arrow_column_f32_sum_c' compiler/src/asm/runtime_arrow_simd_glue.c || die "glue missing f32 sum"
grep -q 'arrow.sx' compiler/Makefile || die "Makefile missing arrow.sx build"
if grep -q 'std/db/arrow/arrow\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references arrow.c"
fi

make -C compiler ../std/db/arrow/arrow.o runtime_arrow_simd_glue.o >/dev/null 2>&1 || die "make arrow.o failed"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
if nm std/db/arrow/arrow.o 2>/dev/null | grep -q ' arrow_smoke_c'; then
  cat >"$TMP/arrow_smoke_main.c" <<'EOF'
#include <stdint.h>
extern int32_t arrow_smoke_c(void);
int main(void) { return arrow_smoke_c() == 0 ? 0 : 1; }
EOF
  if ! cc -o "$TMP/arrow_smoke" "$TMP/arrow_smoke_main.c" std/db/arrow/arrow.o compiler/runtime_arrow_simd_glue.o 2>/dev/null; then
    die "arrow smoke compile failed"
  fi
  "$TMP/arrow_smoke" || die "arrow smoke run failed"
  echo "f05 arrow smoke OK"
else
  echo "f05 arrow smoke SKIP (arrow.o missing .sx symbols; need shux-c)"
fi

if [ -f tests/run-std-db-kv-arrow-gate.sh ]; then
  echo "=== F-05 v1: delegate kv+arrow gate ==="
  chmod +x tests/run-std-db-kv-arrow-gate.sh
  if ! ./tests/run-std-db-kv-arrow-gate.sh; then
    die "kv+arrow sub-gate failed"
  fi
fi

echo "f05 std.db.arrow v1 gate OK (F-05 v1)"
