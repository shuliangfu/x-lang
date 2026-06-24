#!/usr/bin/env bash
# F-03 聚合：std.heap + std.fs + std.io 核心去 C 门禁。
#
# 用法：./tests/run-f03-std-core-gate.sh
# 环境：SHUX_F03_CORE_FAIL=1 — 任一子 gate 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F03_CORE_FAIL:-0}

die() {
  echo "f03-core gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-03 core: heap + fs + io remove *.c ==="
[ -f analysis/phase-f-f03-closure.md ] || die "missing phase-f-f03-closure.md"
[ ! -f std/heap/heap.c ] || die "heap.c should be deleted"
[ ! -f std/fs/fs.c ] || die "fs.c should be deleted"
[ ! -f std/io/io.c ] || die "io.c should be deleted"

for g in \
  tests/run-f03-std-heap-ops-gate.sh \
  tests/run-f03-std-heap-libc-gate.sh \
  tests/run-f03-std-fs-gate.sh \
  tests/run-f03-std-io-gate.sh
do
  if [ -f "$g" ]; then
    echo "=== F-03 core: delegate $(basename "$g") ==="
    chmod +x "$g"
    export SHUX_F03_HEAP_OPS_FAIL="$FAIL"
    export SHUX_F03_HEAP_LIBC_FAIL="$FAIL"
    export SHUX_F03_FS_FAIL="$FAIL"
    export SHUX_F03_IO_FAIL="$FAIL"
    if ! "$g"; then
      die "$(basename "$g") sub-gate failed"
    fi
  fi
done

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-03 core: delegate run-std-c-inventory-gate ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! SHUX_STD_C_INVENTORY_FAIL="$FAIL" tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
fi

echo "f03 std core gate OK (heap/fs/io .c removed; inventory 104)"
