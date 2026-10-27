#!/usr/bin/env bash
# 10.65: runtime_asm_io_stubs.o must rebuild when .x is touched (warm ensure).
# PLATFORM: SHARED
set -u
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$ROOT/compiler" || exit 1
X=src/asm/runtime_asm_io_stubs.x
O=runtime_asm_io_stubs.o
[ -f "$X" ] || { echo "xlang: [IO_STUBS_FRESH] status=fail missing $X"; exit 1; }

# Ensure a baseline .o exists (may rebuild).
bash ../tests/lib/compiler-make.sh runtime_asm_io_stubs.o || exit 1
[ -s "$O" ] || { echo "xlang: [IO_STUBS_FRESH] status=fail no baseline .o"; exit 1; }

# Make .o older than .x, then ensure again — .o mtime must advance.
touch -t 202001010101.00 "$O" 2>/dev/null || touch -d '2020-01-01 01:01:00' "$O"
touch "$X"
before=$(stat -f '%m' "$O" 2>/dev/null || stat -c '%Y' "$O")
bash ../tests/lib/compiler-make.sh runtime_asm_io_stubs.o || exit 1
after=$(stat -f '%m' "$O" 2>/dev/null || stat -c '%Y' "$O")
if [ "$after" -le "$before" ]; then
  echo "xlang: [IO_STUBS_FRESH] status=fail run=0 obs=0 skip=0 host=$(uname -s)/$(uname -m) reason=mtime_not_advanced before=$before after=$after"
  exit 1
fi
if ! nm "$O" 2>/dev/null | grep -q "T _*runtime_asm_io_stubs_x_doc_anchor\$"; then
  echo "xlang: [IO_STUBS_FRESH] status=fail missing doc_anchor"
  exit 1
fi
echo "xlang: [IO_STUBS_FRESH] status=ok run=1 obs=0 skip=0 host=$(uname -s)/$(uname -m)"
exit 0
