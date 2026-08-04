#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
XLANG="${XLANG:-./compiler/xlang}"
exe="/tmp/xlang_channel_$$"
if ! $XLANG build -L . tests/channel/main.x -o "$exe" 2>&1; then echo "channel test: compile failed"; rm -f "$exe"; exit 1; fi
exitcode=0; $exe 2>/dev/null || exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "channel test: expected exit 0, got $exitcode"; exit 1; fi
echo "channel test OK"
