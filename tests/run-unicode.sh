#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
XLANG="${XLANG:-./compiler/xlang}"
exe="/tmp/xlang_unicode_$$"
if ! $XLANG build -L . tests/unicode/main.x -o "$exe" 2>&1; then echo "unicode test: compile failed"; rm -f "$exe"; exit 1; fi
$exe 2>/dev/null; exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "unicode test: expected exit 0, got $exitcode"; exit 1; fi
echo "unicode test OK"
