#!/bin/sh
# w1521 10.57: >16-byte struct call ABI (sret return, byref args, forwarding).
# Usage (repo root): sh tests/probes/p_big_struct/run.sh compiler/xlang_asm
X=${1:-compiler/xlang_asm}
D=$(dirname "$0")
T=${TMPDIR:-/tmp}
fail=0
for f in "$D"/*.x; do
  grep -q 'function main' "$f" || continue
  b=$(basename "$f" .x); o=$T/p_big_struct_$b
  rm -f "$o" "$o.exe"; ( cd "$D" && "$OLDPWD/$X" "$b.x" -o "$o" ) >/dev/null 2>&1
  [ -f "$o" ] || [ -f "$o.exe" ] || { echo "$b NOBUILD"; fail=1; continue; }
  [ -f "$o" ] || o="$o.exe"
  "$o"; r=$?; echo "$b rc=$r"; [ $r = 0 ] || fail=1
done
exit $fail
