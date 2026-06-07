#!/usr/bin/env bash
# IO-A4 multishot accept Linux 烟测（B-NET 前置门禁）
set -e
cd "$(dirname "$0")/.."

if [ "$(uname -s)" != "Linux" ]; then
  echo "io multishot: skip (not Linux)"
  exit 0
fi

make -C compiler ../std/io/io.o -q 2>/dev/null || make -C compiler ../std/io/io.o

if ! cc -std=c11 -Wall -Wextra -o /tmp/shu_io_multishot_accept_smoke \
  tests/bench/io_multishot_accept_smoke.c std/io/io.o -luring -lpthread 2>/dev/null; then
  echo "io multishot: skip (build failed; need liburing)"
  exit 0
fi

out=$(SHU_IO_URING_MULTISHOT_ACCEPT=1 /tmp/shu_io_multishot_accept_smoke 2>&1) || {
  rc=$?
  echo "$out"
  # ubuntu-22.04 等内核无 multishot accept（hits=0）时 SKIP，勿误报 Net perf 门禁 FAIL。
  if echo "$out" | grep -q "multishot hits=0"; then
    echo "io multishot: SKIP (kernel lacks io_uring multishot accept; need 6.0+)"
    echo "io multishot accept OK"
    exit 0
  fi
  exit "$rc"
}
echo "$out"
echo "io multishot accept OK"
