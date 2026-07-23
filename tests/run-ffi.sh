#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q 2>/dev/null || make -C compiler
ensure_std_c_o ../std/ffi/ffi.o
XLANG="${XLANG:-}"
if [ -z "$XLANG" ]; then
  for cand in ./compiler/xlang-c ./compiler/xlang; do
    if [ -x "$cand" ]; then
      XLANG="$cand"
      break
    fi
  done
fi
XLANG="${XLANG:-./compiler/xlang}"
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
LINK_XLANG="$RUN_XLANG"
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
exe="/tmp/xlang_ffi_$$"
if ! $LINK_XLANG build -L . tests/ffi/main.x -o "$exe" 2>&1; then echo "ffi test: compile failed"; rm -f "$exe"; exit 1; fi
exitcode=0; $exe 2>/dev/null || exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "ffi test: expected exit 0, got $exitcode"; exit 1; fi
echo "ffi test OK"
