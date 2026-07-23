#!/usr/bin/env bash
# 测试 std.error（ok）
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi
# PLATFORM: SHARED — C backend prelinks error.o (no co-emit of std_error_* bodies).
# XLANG_SKIP_SUBSCRIPT_MAKE only skips xlang-c rebuild; must still ensure error.o.
# L4 cold: BSTRICT_STD_O used to omit error.o → UNDEF std_error_ok (Ubuntu gold).
make -C compiler -q ../std/error/error.o 2>/dev/null \
  || make -C compiler ../std/error/error.o
XLANG=${XLANG:-./compiler/xlang}

$XLANG build -L . tests/error/main.x -o /tmp/xlang_error 2>&1
exitcode=0; /tmp/xlang_error >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (ok), got $exitcode"; exit 1; }

echo "error test OK"
