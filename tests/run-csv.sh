#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q 2>/dev/null || make -C compiler
ensure_std_c_o ../std/csv/csv.o
SHUX="${SHUX:-./compiler/shux}"
exe="/tmp/shux_csv_$$"
if ! $SHUX -L . tests/csv/main.sx -o "$exe" 2>&1; then echo "csv test: compile failed"; rm -f "$exe"; exit 1; fi
set +e
$exe 2>/dev/null
exitcode=$?
set -e
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "csv test: expected exit 0, got $exitcode"; exit 1; fi
echo "csv test OK"
