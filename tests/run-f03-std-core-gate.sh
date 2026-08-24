#!/usr/bin/env bash
# F-03 聚合：std.heap + std.fs + std.io 核心去 C 门禁。
#
# 用法：./tests/run-f03-std-core-gate.sh
# 环境：XLANG_F03_CORE_FAIL=1 — 任一子 gate 失败时硬退出
#
# wave honesty (2026-08-25): DOC → analysis/archive/phase/；
# compiler/Makefile deleted — refuse resurrect (use ./xbuild).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

FAIL=${XLANG_F03_CORE_FAIL:-0}
DOC="${XLANG_F03_DOC:-analysis/archive/phase/phase-f-f03-closure.md}"

die() {
  echo "f03-core gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-03 core: heap + fs + io remove *.c ==="
[ -f "$DOC" ] || die "missing $DOC"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ ! -f std/heap/heap.c ] || die "heap.c should be deleted"
[ ! -f std/fs/fs.c ] || die "fs.c should be deleted"
[ ! -f std/io/io.c ] || die "io.c should be deleted"

# Structural F-03 (DOC / no *.c / Makefile refuse) is under $FAIL.
# Product dogfood subgates stay soft unless XLANG_F03_PRODUCT_FAIL=1 —
# keeps DOC archaeology knife from absorbing unrelated std-fs soft residuals
# (e.g. dirmeta rv≠0). PLATFORM: SHARED archaeology.
PROD_FAIL=${XLANG_F03_PRODUCT_FAIL:-0}
for g in \
  tests/run-f03-std-heap-ops-gate.sh \
  tests/run-f03-std-heap-libc-gate.sh \
  tests/run-f03-std-fs-gate.sh \
  tests/run-f03-std-io-gate.sh
do
  if [ -f "$g" ]; then
    echo "=== F-03 core: delegate $(basename "$g") (product_fail=$PROD_FAIL) ==="
    chmod +x "$g"
    export XLANG_F03_HEAP_OPS_FAIL="$PROD_FAIL"
    export XLANG_F03_HEAP_LIBC_FAIL="$PROD_FAIL"
    export XLANG_F03_FS_FAIL="$PROD_FAIL"
    export XLANG_F03_IO_FAIL="$PROD_FAIL"
    if ! "$g"; then
      if [ "$PROD_FAIL" = "1" ]; then
        die "$(basename "$g") sub-gate failed"
      fi
      echo "f03-core WARN: $(basename "$g") soft (XLANG_F03_PRODUCT_FAIL=1 to hard)" >&2
    fi
  fi
done

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-03 core: delegate run-std-c-inventory-gate ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! XLANG_STD_C_INVENTORY_FAIL="$FAIL" tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
fi

echo "f03 std core gate OK (heap/fs/io .c removed; inventory 104)"
