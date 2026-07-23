#!/usr/bin/env bash
# 测试 std.set：Set_i32 insert、contains、remove、len、deinit
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q ../std/heap/heap.o ../std/set/set.o 2>/dev/null \
  || make -C compiler ../std/heap/heap.o ../std/set/set.o
ensure_runtime_panic_o
ensure_runtime_process_argv_o
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
# shellcheck source=lib/collection-asm-gcc-link.sh
. "$(dirname "$0")/lib/collection-asm-gcc-link.sh"
XLANG=${XLANG:-./compiler/xlang}
LINK_XLANG="${XLANG_LINK_XLANG:-${RUN_XLANG:-$XLANG}}"
exe="/tmp/xlang_set_$$"
if ! collection_link_exe "$LINK_XLANG" tests/set/main.x "$exe" set 2>&1; then
  echo "set test: compile failed"
  rm -f "$exe"
  exit 1
fi
exitcode=0
"$exe" 2>/dev/null || exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then
  echo "set test: expected exit 0, got $exitcode"
  exit 1
fi
echo "set test OK"
