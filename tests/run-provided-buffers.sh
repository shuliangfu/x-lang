#!/usr/bin/env bash
# ZC-1 Provided Buffers 烟测（Linux + liburing 5.19+ provide_buffers）
# 用法：./tests/run-provided-buffers.sh
# Mac Docker Desktop linuxkit 无 io_uring（queue_init ENOSYS）时 SKIP exit 0。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

if [ "$(uname -s)" != "Linux" ]; then
  echo "provided buffers smoke SKIP (non-Linux)"
  exit 0
fi

# 内核无 io_uring 时跳过（如 Mac Docker linuxkit），避免误报 FAIL
# shellcheck source=tests/lib/io-uring-probe.sh
. tests/lib/io-uring-probe.sh
if ! io_uring_available; then
  echo "provided buffers smoke SKIP (io_uring unavailable on this kernel; use GitHub CI ubuntu runner)"
  exit 0
fi

if ! pkg-config --exists liburing 2>/dev/null && [ ! -f /usr/include/liburing.h ]; then
  echo "provided buffers smoke SKIP (no liburing)"
  exit 0
fi

make -C compiler ../std/io/io.o -q 2>/dev/null || make -C compiler ../std/io/io.o

OUT="/tmp/shu_provided_smoke"
cc -O2 -Wall tests/bench/provided_buffers_smoke.c std/io/io.o -o "$OUT" -luring -lpthread 2>/dev/null || {
  echo "provided buffers smoke SKIP (link failed; kernel/liburing may lack PROVIDE_BUFFERS)"
  exit 0
}

if "$OUT"; then
  echo "provided buffers smoke OK"
else
  rc=$?
  # 内核/io_uring 无 PROVIDE_BUFFERS（如部分 GitHub ubuntu 22.04）时烟测 exit 3，CI 应 SKIP 而非 FAIL。
  if [ "$rc" -eq 3 ]; then
    echo "provided buffers smoke SKIP (io_register_provided_buffers unavailable; need Linux 5.19+ provide)"
    exit 0
  fi
  echo "provided buffers smoke FAIL exit=$rc" >&2
  exit "$rc"
fi
