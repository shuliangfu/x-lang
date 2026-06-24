#!/usr/bin/env bash
# F-05 v4：std.db 三后端闭合门禁（v1～v3 聚合 + manifest）。
#
# 用法：./tests/run-f05-std-db-closure-gate.sh
# 环境：SHUX_F05_DB_CLOSURE_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F05_DB_CLOSURE_FAIL:-0}
DOC="analysis/phase-f-f05-v4-closure.md"
MANIFEST="tests/baseline/f05-std-db-closure.tsv"

die() {
  echo "f05-db-closure gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-05 v4: std.db closure (arrow + kv + sqlite) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-05 v4' "$DOC" || die "doc missing F-05 v4 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|script|manifest)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)"
      ;;
  esac
done < "$MANIFEST"

grep -q 'kv.sx' compiler/Makefile || die "Makefile missing kv.sx in kv.o"
grep -q 'arrow.sx' compiler/Makefile || die "Makefile missing arrow.sx in arrow.o"
grep -q 'sqlite.sx' compiler/Makefile || die "Makefile missing sqlite.sx in sqlite.o"
if grep -q 'std/db/kv/kv\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references std/db/kv/kv.c"
fi
if grep -q 'std/db/arrow/arrow\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references std/db/arrow/arrow.c"
fi
if grep -q 'std/db/sqlite/sqlite\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references std/db/sqlite/sqlite.c"
fi

make -C compiler runtime_kv_mmap_glue.o runtime_arrow_simd_glue.o runtime_sqlite_glue.o >/dev/null 2>&1 || true
make -C compiler ../std/db/kv/kv.o >/dev/null 2>&1 || die "make kv.o failed"
make -C compiler ../std/db/arrow/arrow.o >/dev/null 2>&1 || die "make arrow.o failed"
make -C compiler ../std/db/sqlite/sqlite.o >/dev/null 2>&1 || die "make sqlite.o failed"

for sub in run-f05-std-db-arrow-v1-gate.sh run-f05-std-db-kv-v2-gate.sh \
  run-f05-std-db-sqlite-v3-gate.sh; do
  if [ -f "tests/$sub" ]; then
    echo "=== F-05 v4: delegate $sub ==="
    chmod +x "tests/$sub"
    case "$sub" in
      *arrow-v1*) env_var=SHUX_F05_DB_ARROW_V1_FAIL ;;
      *kv-v2*) env_var=SHUX_F05_DB_KV_V2_FAIL ;;
      *sqlite-v3*) env_var=SHUX_F05_DB_SQLITE_V3_FAIL ;;
      *) env_var=SHUX_F05_DB_CLOSURE_FAIL ;;
    esac
    if ! env "$env_var=$FAIL" "tests/$sub"; then
      die "$sub failed"
    fi
  fi
done

if [ -f tests/run-std-db-kv-arrow-gate.sh ]; then
  echo "=== F-05 v4: delegate kv+arrow gate ==="
  chmod +x tests/run-std-db-kv-arrow-gate.sh
  if ! ./tests/run-std-db-kv-arrow-gate.sh; then
    die "run-std-db-kv-arrow-gate failed"
  fi
fi

if [ -f tests/run-std-sqlite-gate.sh ]; then
  echo "=== F-05 v4: delegate std-sqlite gate (manifest) ==="
  chmod +x tests/run-std-sqlite-gate.sh
  if ! SHUX_STD_SQLITE_MANIFEST_ONLY=1 tests/run-std-sqlite-gate.sh; then
    die "run-std-sqlite-gate failed"
  fi
fi

echo "f05 std.db closure gate OK (F-05 v4)"
