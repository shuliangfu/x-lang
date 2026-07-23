#!/usr/bin/env bash
# 测试 std.queue：Queue_i32 push/pop/len/deinit（link_only → 须预编 queue.o）
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c 2>/dev/null || true
fi
# link_only：用户 C 仅 extern std_queue_*，须存在预编 .o（与 run-set / run-vec 同权威）
make -C compiler -q ../std/heap/heap.o ../std/queue/queue.o 2>/dev/null \
  || make -C compiler ../std/heap/heap.o ../std/queue/queue.o
ensure_runtime_panic_o
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
XLANG=${XLANG:-./compiler/xlang}
LINK_XLANG="${XLANG_LINK_XLANG:-${RUN_XLANG:-$XLANG}}"
exe="/tmp/xlang_queue_$$"
if ! $LINK_XLANG build -L . tests/queue/main.x -o "$exe" 2>&1; then
  echo "queue test: compile failed"
  rm -f "$exe"
  exit 1
fi
exitcode=0
"$exe" 2>/dev/null || exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then
  echo "queue test: expected exit 0, got $exitcode"
  exit 1
fi
echo "queue test OK"
