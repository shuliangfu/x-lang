#!/usr/bin/env bash
# io-uring-probe.sh — 检测 Linux 上 io_uring 是否可用（非 Linux 或 ENOSYS 返回 1）。
# 用法：source tests/lib/io-uring-probe.sh && io_uring_available && echo ok

io_uring_available() {
  if [ "$(uname -s)" != "Linux" ]; then
    return 1
  fi
  if ! pkg-config --exists liburing 2>/dev/null && [ ! -f /usr/include/liburing.h ]; then
    return 1
  fi
  local probe="/tmp/shux_io_uring_probe_$$"
  if ! cc -O2 -Wall "${BASH_SOURCE%/*}/../bench/io_uring_probe.c" -o "$probe" -luring 2>/dev/null; then
    return 1
  fi
  if "$probe"; then
    rm -f "$probe"
    return 0
  fi
  rm -f "$probe"
  return 1
}
