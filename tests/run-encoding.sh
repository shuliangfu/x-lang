#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q 2>/dev/null || make -C compiler
ensure_std_c_o ../std/encoding/encoding.o
SHUX="${SHUX:-./compiler/shux}"
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
LINK_SHUX="$RUN_SHUX"
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
exe="${TMPDIR:-/tmp}/shux_encoding_$$"
if ! $LINK_SHUX -L . tests/encoding/main.sx -o "$exe" 2>&1; then echo "encoding test: compile failed"; rm -f "$exe"; exit 1; fi
exitcode=0; $exe 2>/dev/null || exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "encoding test: expected exit 0, got $exitcode"; exit 1; fi
echo "encoding test OK"
