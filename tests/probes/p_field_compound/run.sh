#!/bin/sh
# w1509 (终局待办 10.32): every probe exits 0 when field compound assign is right.
# Usage: sh tests/probes/p_field_compound/run.sh [xlang_asm]
X=${1:-compiler/xlang_asm}
D=$(dirname "$0")
fail=0
for f in "$D"/*.x; do
  b=$(basename "$f" .x); o=/tmp/p_field_compound_$b
  rm -f "$o"; "$X" "$f" -o "$o" >/dev/null 2>&1 || { echo "$b NOBUILD"; fail=1; continue; }
  "$o"; r=$?; echo "$b rc=$r"; [ $r = 0 ] || fail=1
done
exit $fail
