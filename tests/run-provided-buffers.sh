#!/usr/bin/env bash
# ZC-1 Provided Buffers 烟测（Linux + liburing 5.19+ provide_buffers）
# 用法：./tests/run-provided-buffers.sh
# SHU_CI_NO_SKIP=1 且 Linux：禁止 silent SKIP，须 io_uring + liburing 可用。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

# 非 Linux 无 io_uring：由调用方（run-zc1-gate）处理；本脚本仅 Linux 实跑。
_provided_skip_or_fail() {
  local msg="$1"
  if [ -n "${SHU_CI_NO_SKIP:-}" ] && [ "$(uname -s)" = "Linux" ]; then
    echo "provided buffers smoke FAIL: $msg (SHU_CI_NO_SKIP=1)" >&2
    exit 1
  fi
  echo "provided buffers smoke SKIP ($msg)"
  exit 0
}

if [ "$(uname -s)" != "Linux" ]; then
  _provided_skip_or_fail "non-Linux"
fi

# shellcheck source=tests/lib/io-uring-probe.sh
. tests/lib/io-uring-probe.sh
if ! io_uring_available; then
  _provided_skip_or_fail "io_uring unavailable on this kernel"
fi

if ! pkg-config --exists liburing 2>/dev/null && [ ! -f /usr/include/liburing.h ]; then
  _provided_skip_or_fail "no liburing"
fi

make -C compiler ../std/io/io.o -q 2>/dev/null || make -C compiler ../std/io/io.o

OUT="/tmp/shu_provided_smoke"
if ! cc -O2 -Wall tests/bench/provided_buffers_smoke.c std/io/io.o -o "$OUT" -luring -lpthread 2>/dev/null; then
  _provided_skip_or_fail "link failed; kernel/liburing may lack PROVIDE_BUFFERS"
fi

if "$OUT"; then
  echo "provided buffers smoke OK"
else
  rc=$?
  if [ "$rc" -eq 3 ]; then
    _provided_skip_or_fail "io_register_provided_buffers unavailable; need Linux 5.19+ provide"
  fi
  echo "provided buffers smoke FAIL exit=$rc" >&2
  exit "$rc"
fi
