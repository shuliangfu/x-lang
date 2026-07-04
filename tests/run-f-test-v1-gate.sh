#!/usr/bin/env bash
# F-test v1：std.test 去 C（test.c → test.x；F-ZC 删 test_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_TEST_V1_FAIL:-0}
die() { echo "f-test-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-test v1: std.test test.c → test.x (F-ZC) ==="
[ -f analysis/phase-f-test-v1.md ] || die "missing phase-f-test-v1.md"
[ -f std/test/test.x ] || die "missing test.x"
[ -f compiler/src/asm/runtime_test_fn_invoke.c ] || die "missing runtime_test_fn_invoke.c"
[ ! -f std/test/test_glue.c ] || die "test_glue.c should be deleted"
[ ! -f std/test/test.c ] || die "test.c should be deleted"
grep -q 'test.x' compiler/Makefile || die "Makefile missing test.x"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/test/test.o >/dev/null 2>&1 || die "make test.o failed"
else
  echo "f-test-v1 SKIP test.o build (no shux-c)" >&2
fi
echo "f-test-v1 std.test gate OK"
