#!/usr/bin/env bash
# F-02 v1：std.sys mmap 去 C 门禁（Linux 烟测 + 无 mmap.inc.c + F-01 委托）。
#
# 用法：./tests/run-f02-std-sys-mmap-gate.sh
# 环境：SHUX_F02_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F02_FAIL:-0}
DOC="analysis/phase-f-f02-v1.md"

die() {
  echo "f02 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-02 v1: std.sys mmap remove mmap.inc.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-02 v1' "$DOC" || die "doc missing F-02 v1 marker"
[ ! -f std/sys/mmap.inc.c ] || die "mmap.inc.c should be deleted"
grep -q 'linux_mmap_rw' std/sys/linux.sx || die "linux.sx missing linux_mmap_rw"
grep -q 'linux_m' std/sys/mmap.sx || die "mmap.sx should import std.sys.linux"
if grep -q 'shux_sys_mmap_rw_c' std/sys/mmap.sx 2>/dev/null; then
  die "mmap.sx still references shux_sys_mmap_rw_c"
fi

if [ -f tests/run-linux-mmap-file-gate.sh ]; then
  echo "=== F-02: delegate run-linux-mmap-file-gate ==="
  chmod +x tests/run-linux-mmap-file-gate.sh
  if ! SHUX_LINUX_MMAP_FILE_FAIL="$FAIL" tests/run-linux-mmap-file-gate.sh; then
    die "linux-mmap-file sub-gate failed"
  fi
fi

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-02: delegate run-std-c-inventory-gate (F-01) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! SHUX_STD_C_INVENTORY_FAIL="$FAIL" tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
fi

echo "f02 std.sys mmap gate OK (F-02 v1; Linux smoke N/A on non-Linux hosts)"
