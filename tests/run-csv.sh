#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q 2>/dev/null || make -C compiler
ensure_std_c_o ../std/csv/csv.o
SHU="${SHU:-./compiler/shu}"
exe="/tmp/shu_csv_$$"
if ! $SHU -L . tests/csv/main.su -o "$exe" 2>&1; then echo "csv test: compile failed"; rm -f "$exe"; exit 1; fi
set +e
$exe 2>/dev/null
exitcode=$?
set -e
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "csv test: expected exit 0, got $exitcode"; exit 1; fi
echo "csv test OK"
