#!/usr/bin/env bash
# std.http GET 烟测；须链 ../std/http/http.o（bootstrap seed 不默认构建全量 std C）。
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q 2>/dev/null || make -C compiler
ensure_std_c_o ../std/http/http.o
SHU="${SHU:-./compiler/shu}"
exe="/tmp/shu_http_$$"
if ! $SHU -L . tests/http/main.su -o "$exe" 2>&1; then echo "http test: compile failed"; rm -f "$exe"; exit 1; fi
$exe 2>/dev/null; exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "http test: expected exit 0, got $exitcode"; exit 1; fi
echo "http test OK"
