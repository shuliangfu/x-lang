#!/usr/bin/env bash
# 烟测 std.io 链路与 std.process spawn（不跑全量 run-process，避免 seed 与 exit(99) 语义差）。
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/bootstrap-link-shu.sh
. "$(dirname "$0")/lib/bootstrap-link-shu.sh"
if [ -z "${SHULANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi

"$RUN_SHU" -L . examples/hello.su -o /tmp/shu_io_hello 2>&1
rc=0
/tmp/shu_io_hello >/dev/null 2>&1 || rc=$?
[ "$rc" -ne 0 ] && { echo "hello: expected exit 0, got $rc"; exit 1; }

"$RUN_SHU" -L . tests/process/spawn_wait.su -o /tmp/shu_spawn_wait 2>&1
rc=0
/tmp/shu_spawn_wait >/dev/null 2>&1 || rc=$?
if [ "$rc" -ne 0 ]; then
  echo "spawn_wait: expected exit 0, got $rc (Windows 可 SKIP)"
  exit 1
fi

echo "io-driver-process smoke OK"
