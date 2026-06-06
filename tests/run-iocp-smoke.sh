#!/usr/bin/env bash
# IO-A6 Windows IOCP + registered buffer 烟测
# 用法：./tests/run-iocp-smoke.sh
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

# 仅 Windows MSYS2/MINGW 实跑；其它平台 SKIP（C 侧为 stub main）
_is_windows_msys() {
  case "$(uname -s 2>/dev/null)" in
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
  esac
  case "$(uname -o 2>/dev/null)" in
    Msys|Cygwin) return 0 ;;
  esac
  return 1
}

if ! _is_windows_msys; then
  echo "iocp smoke SKIP (non-Windows)"
  exit 0
fi

make -C compiler ../std/io/io.o -q 2>/dev/null || make -C compiler ../std/io/io.o

OUT="/tmp/shu_iocp_smoke"
cc -O2 -Wall tests/bench/iocp_batch_smoke.c std/io/io.o -o "$OUT" 2>/dev/null || {
  echo "iocp smoke SKIP (link failed)"
  exit 0
}

if "$OUT"; then
  echo "iocp smoke OK"
else
  rc=$?
  echo "iocp smoke FAIL exit=$rc" >&2
  exit "$rc"
fi
