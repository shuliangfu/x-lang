#!/usr/bin/env bash
# NL-04：Linux freestanding 读文件烟测（std.fs.freestanding_linux，零 libc / 无 fs.c）。
#
# 用法：./tests/run-no-libc-fs-gate.sh
# 环境：
#   SHUX_NOLIBC_FS_FAIL=1  — 失败时硬退出
#   SHUX=./compiler/shux
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_NOLIBC_FS_FAIL:-0}
X="tests/sys/linux_fs_freestanding_smoke.x"
FS_MOD="std/fs/freestanding_linux.x"
GATE_FILE="/tmp/shux_nolibc_fs_gate.txt"
OUT="/tmp/shux_nolibc_fs.$$.out"

die() {
  echo "nolibc-fs gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== NL-04: freestanding fs read (zero libc) ==="
for f in "$X" "$FS_MOD"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'freestanding_read_file_into' "$FS_MOD" || die "freestanding_linux.x incomplete"

if [ "$(uname -s 2>/dev/null)" != "Linux" ] || [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
  echo "nolibc-fs gate: N/A (Linux x86_64 freestanding only; manifest OK)"
  exit 0
fi

SHUX="${SHUX:-./compiler/shux}"
if [ ! -x "$SHUX" ] && [ -x ./compiler/shux_asm ]; then
  SHUX=./compiler/shux_asm
fi
if [ ! -x "$SHUX" ]; then
  echo "nolibc-fs gate: SKIP (no shux/shux_asm)"
  exit 0
fi

printf 'FS' >"$GATE_FILE"
rm -f "$OUT" 2>/dev/null || true

if ! "$SHUX" -freestanding -backend asm -o "$OUT" "$X" 2>/tmp/shux_nolibc_fs.log; then
  tail -n 12 /tmp/shux_nolibc_fs.log 2>/dev/null || true
  rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
  die "compile $X failed"
fi
[ -x "$OUT" ] || die "no executable $OUT"

if command -v ldd >/dev/null 2>&1; then
  if ldd "$OUT" 2>&1 | grep -qi 'libc\.so'; then
    ldd "$OUT" 2>&1 || true
    rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
    die "$OUT linked against libc.so"
  fi
fi

rc=0
OUT_TXT=$("$OUT" 2>/dev/null) || rc=$?
rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
if [ "$rc" -ne 0 ]; then
  die "expected exit 0, got $rc"
fi
if [ "$OUT_TXT" != "FS" ]; then
  die "stdout expected FS, got '$OUT_TXT'"
fi

echo "nolibc-fs gate OK (read file via syscall + mmap heap buf, no fs.c/libc)"
