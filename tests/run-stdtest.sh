#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
fi
# PLATFORM: SHARED — C backend prelinks test.o (std_test_expect*).
# L4 cold mac: partial test.o can be mtime-fresh yet lack std_test_* (only bare
# test_expect_c + preamble) → UNDEF. Force rebuild when symbol gate fails.
xlang_compiler_make -q ../std/test/test.o 2>/dev/null \
  || xlang_compiler_make ../std/test/test.o
if ! nm std/test/test.o 2>/dev/null | grep -q 'std_test_expect'; then
  echo "run-stdtest: test.o missing std_test_expect — force rebuild" >&2
  rm -f std/test/test.o
  xlang_compiler_make ../std/test/test.o
fi
xlang_compiler_make -q runtime_test_fn_invoke.o 2>/dev/null \
  || xlang_compiler_make runtime_test_fn_invoke.o
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
exe="/tmp/xlang_stdtest_$$"
if ! $RUN_XLANG build -L . tests/stdtest/main.x -o "$exe" 2>&1; then echo "stdtest test: compile failed"; rm -f "$exe"; exit 1; fi
exitcode=0; $exe 2>/dev/null || exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "stdtest test: expected exit 0, got $exitcode"; exit 1; fi
echo "stdtest test OK"
