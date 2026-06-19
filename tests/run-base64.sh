#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q 2>/dev/null || make -C compiler
ensure_std_c_o ../std/base64/base64.o
SHUX="${SHUX:-./compiler/shux}"
exe="/tmp/shux_base64_$$"
if ! $SHUX -L . tests/base64/main.sx -o "$exe" 2>&1; then echo "base64 test: compile failed"; rm -f "$exe"; exit 1; fi
exitcode=0; $exe 2>/dev/null || exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "base64 test: expected exit 0, got $exitcode"; exit 1; fi
echo "base64 test OK"
