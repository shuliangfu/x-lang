#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
make -C compiler -q xlang-c 2>/dev/null || XLANG_LEGACY_C_FRONTEND=1 make -C compiler xlang-c 2>/dev/null || make -C compiler -q 2>/dev/null || make -C compiler
XLANG="${XLANG:-}"
if [ -z "$XLANG" ]; then
  for cand in ./compiler/xlang-c ./compiler/xlang; do
    if [ -x "$cand" ]; then XLANG="$cand"; break; fi
  done
fi
if [ -z "$XLANG" ] || [ ! -x "$XLANG" ]; then
  echo "log test SKIP (no xlang/xlang-c)"
  exit 0
fi
# shellcheck source=tests/lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
ensure_std_c_o ../std/log/log.o 2>/dev/null || true
ensure_runtime_log_os_o 2>/dev/null || true
exe="/tmp/xlang_log_$$"
if ! $XLANG build -L . tests/log/main.x -o "$exe" 2>&1; then echo "log test: compile failed"; rm -f "$exe"; exit 1; fi
exitcode=0; $exe 2>/dev/null || exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "log test: expected exit 0, got $exitcode"; exit 1; fi
echo "log test OK"
