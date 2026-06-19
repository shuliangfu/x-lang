#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX="${SHUX:-./compiler/shux}"
exe="/tmp/shux_stdtest_$$"
if ! $SHUX -L . tests/stdtest/main.sx -o "$exe" 2>&1; then echo "stdtest test: compile failed"; rm -f "$exe"; exit 1; fi
exitcode=0; $exe 2>/dev/null || exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "stdtest test: expected exit 0, got $exitcode"; exit 1; fi
echo "stdtest test OK"
