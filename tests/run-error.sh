#!/usr/bin/env bash
# 测试 std.error（ok）
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi
# PLATFORM: SHARED — C backend prelinks error.o (no co-emit of std_error_* bodies).
# SHUX_SKIP_SUBSCRIPT_MAKE only skips shux-c rebuild; must still ensure error.o.
# L4 cold: BSTRICT_STD_O used to omit error.o → UNDEF std_error_ok (Ubuntu gold).
make -C compiler -q ../std/error/error.o 2>/dev/null \
  || make -C compiler ../std/error/error.o
SHUX=${SHUX:-./compiler/shux}

$SHUX -L . tests/error/main.x -o /tmp/shux_error 2>&1
exitcode=0; /tmp/shux_error >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (ok), got $exitcode"; exit 1; }

echo "error test OK"
