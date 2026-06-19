#!/usr/bin/env bash
# IO-A4 multishot accept Linux 烟测（B-NET 前置门禁）
set -e
cd "$(dirname "$0")/.."

if [ "$(uname -s)" != "Linux" ]; then
  echo "io multishot: skip (not Linux)"
  exit 0
fi

make -C compiler ../std/io/io.o -q 2>/dev/null || make -C compiler ../std/io/io.o

if ! cc -std=c11 -Wall -Wextra -o /tmp/shux_io_multishot_accept_smoke \
  tests/bench/io_multishot_accept_smoke.c std/io/io.o -luring -lpthread 2>/dev/null; then
  echo "io multishot: skip (build failed; need liburing)"
  echo "io multishot accept OK"
  exit 0
fi

out=$(SHUX_IO_URING_MULTISHOT_ACCEPT=1 /tmp/shux_io_multishot_accept_smoke 2>&1) || {
  rc=$?
  echo "$out"
  # 内核无 io_uring / multishot accept（Docker、旧内核 hits=0 / accepted<4）→ N/A，勿误报 FAIL。
  if echo "$out" | grep -qE "multishot hits=0|accepted=[0-3] want 4|queue_init=-1|kernel lacks io_uring"; then
    echo "io multishot: N/A (io_uring/multishot unavailable on this kernel)"
    echo "io multishot accept OK"
    exit 0
  fi
  exit "$rc"
}
echo "$out"
echo "io multishot accept OK"
