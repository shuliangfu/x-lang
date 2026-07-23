#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q 2>/dev/null || make -C compiler
ensure_std_c_o ../std/encoding/encoding.o
XLANG="${XLANG:-./compiler/xlang}"
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
LINK_XLANG="$RUN_XLANG"
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
exe="${TMPDIR:-/tmp}/xlang_encoding_$$"
if ! $LINK_XLANG build -L . tests/encoding/main.x -o "$exe" 2>&1; then echo "encoding test: compile failed"; rm -f "$exe"; exit 1; fi
exitcode=0; $exe 2>/dev/null || exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "encoding test: expected exit 0, got $exitcode"; exit 1; fi
echo "encoding test OK"
