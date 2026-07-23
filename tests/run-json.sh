#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q xlang-c 2>/dev/null || XLANG_LEGACY_C_FRONTEND=1 make -C compiler xlang-c 2>/dev/null || true
# shellcheck source=tests/lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
ensure_std_c_o ../std/json/json.o
XLANG="${XLANG:-}"
if [ -z "$XLANG" ]; then
  for cand in ./compiler/xlang-c ./compiler/xlang; do
    if [ -x "$cand" ]; then XLANG="$cand"; break; fi
  done
fi
if [ -z "$XLANG" ] || [ ! -x "$XLANG" ]; then
  echo "json test SKIP (no xlang/xlang-c)"
  exit 0
fi
exe="/tmp/xlang_json_$$"
if ! "$XLANG" build -L . tests/json/main.x -o "$exe" 2>&1; then echo "json test: compile failed"; rm -f "$exe"; exit 1; fi
$exe 2>/dev/null; exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "json test: expected exit 0, got $exitcode"; exit 1; fi
echo "json test OK"
