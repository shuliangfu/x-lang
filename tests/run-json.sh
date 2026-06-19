#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q 2>/dev/null || make -C compiler
ensure_std_c_o ../std/json/json.o
SHUX="${SHUX:-}"
if [ -z "$SHUX" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if [ -x "$cand" ]; then SHUX="$cand"; break; fi
  done
fi
if [ -z "$SHUX" ] || [ ! -x "$SHUX" ]; then
  echo "json test SKIP (no shux/shux-c)"
  exit 0
fi
exe="/tmp/shux_json_$$"
if ! "$SHUX" -L . tests/json/main.sx -o "$exe" 2>&1; then echo "json test: compile failed"; rm -f "$exe"; exit 1; fi
$exe 2>/dev/null; exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "json test: expected exit 0, got $exitcode"; exit 1; fi
echo "json test OK"
