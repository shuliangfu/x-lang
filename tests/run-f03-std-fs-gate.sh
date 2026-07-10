#!/usr/bin/env bash
# F-03 v2：std.fs 去 C 门禁（无 fs.c + posix/win32 + F-01）。
#
# 用法：./tests/run-f03-std-fs-gate.sh
# 环境：SHUX_F03_FS_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F03_FS_FAIL:-0}
DOC="analysis/phase-f-f03-v2-fs.md"

die() {
  echo "f03-fs gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-03 v2: std.fs remove fs.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-03 v2' "$DOC" || die "doc missing F-03 v2 marker"
[ ! -f std/fs/fs.c ] || die "fs.c should be deleted"
[ -f std/fs/posix.x ] || die "missing posix.x"
[ -f std/fs/win32.x ] || die "missing win32.x"
grep -q 'import("std.fs.posix")' std/fs/mod.x || die "mod.x missing posix import"
grep -q 'fs_open_read_c' std/fs/posix.x || die "fs_posix missing fs_open_read_c"
grep -q 'fs_mmap_ro_c' std/fs/win32.x || die "fs_win32 missing fs_mmap_ro_c"
if grep -q 'extern function fs_open_read_c' std/fs/mod.x 2>/dev/null; then
  die "mod.x still extern fs_open_read_c (should forward to platform)"
fi
if grep -q '../std/fs/fs.o' compiler/Makefile 2>/dev/null; then
  die "Makefile still references ../std/fs/fs.o"
fi
if grep -q 'std/fs/fs.o' compiler/src/runtime_link_abi.inc 2>/dev/null; then
  die "runtime_link_abi.inc still pushes std/fs/fs.o"
fi
grep -q 'have_fs' compiler/src/runtime_link_abi.h || die "runtime_link_abi.h missing have_fs"

for g in tests/run-std-fs-dirmeta-gate.sh tests/run-std-fs-crossplatform-gate.sh; do
  if [ -f "$g" ]; then
    echo "=== F-03 v2: delegate $(basename "$g") ==="
    chmod +x "$g"
    if ! "$g"; then
      die "$(basename "$g") sub-gate failed"
    fi
  fi
done

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-03 v2: delegate run-std-c-inventory-gate (F-01) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! SHUX_STD_C_INVENTORY_FAIL="$FAIL" tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
fi

echo "f03 std.fs gate OK (F-03 v2; fs.c removed)"
