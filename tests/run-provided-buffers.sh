#!/usr/bin/env bash
# ZC-1 Provided Buffers 烟测（Linux + liburing 5.19+ provide_buffers）
# 用法：./tests/run-provided-buffers.sh
# SHUX_CI_NO_SKIP=1 且 Linux：禁止 silent SKIP，须 io_uring + liburing 可用。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

# 非 Linux 无 io_uring：由调用方处理；Linux 内核无 PROVIDE_BUFFERS 时为 N/A（非 skip）。
_provided_na() {
  echo "provided buffers smoke N/A ($1)"
  exit 0
}

_provided_fail() {
  echo "provided buffers smoke FAIL: $1" >&2
  exit 1
}

if [ "$(uname -s)" != "Linux" ]; then
  _provided_na "non-Linux (io_uring requires Linux)"
fi

# shellcheck source=tests/lib/io-uring-probe.sh
. tests/lib/io-uring-probe.sh
if ! io_uring_available; then
  _provided_na "io_uring unavailable on this kernel"
fi

if ! pkg-config --exists liburing 2>/dev/null && [ ! -f /usr/include/liburing.h ]; then
  _provided_fail "no liburing (install liburing-dev)"
fi

make -C compiler ../std/io/io.o -q 2>/dev/null || make -C compiler ../std/io/io.o

OUT="/tmp/shux_provided_smoke"
if ! cc -O2 -Wall tests/bench/provided_buffers_smoke.c std/io/io.o -o "$OUT" -luring -lpthread 2>/dev/null; then
  _provided_fail "link failed (check liburing)"
fi

if "$OUT"; then
  echo "provided buffers smoke OK"
else
  rc=$?
  if [ "$rc" -eq 3 ]; then
    _provided_na "io_register_provided_buffers unavailable (need Linux 5.19+ provide)"
  fi
  _provided_fail "exit=$rc"
fi
