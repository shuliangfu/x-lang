#!/usr/bin/env bash
# std.tar UStar 头读写烟测；须链 ../std/tar/tar.o。
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q 2>/dev/null || make -C compiler
ensure_std_c_o ../std/tar/tar.o
SHUX="${SHUX:-./compiler/shux}"
exe="/tmp/shux_tar_$$"
if ! $SHUX -L . tests/tar/main.x -o "$exe" 2>&1; then echo "tar test: compile failed"; rm -f "$exe"; exit 1; fi
$exe 2>/dev/null; exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "tar test: expected exit 0, got $exitcode"; exit 1; fi
echo "tar test OK"
