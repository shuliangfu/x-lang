#!/bin/sh
# w1510 (终局待办 10.29): every probe exits 0 when STRUCT_LIT fields written in
# a different order than the struct declaration land at their own offsets.
# Usage: sh tests/probes/p_struct_lit_order/run.sh [xlang_asm]
X=${1:-compiler/xlang_asm}
D=$(dirname "$0")
fail=0
for f in "$D"/*.x; do
  b=$(basename "$f" .x); o=/tmp/p_struct_lit_order_$b
  rm -f "$o"; "$X" "$f" -o "$o" >/dev/null 2>&1 || { echo "$b NOBUILD"; fail=1; continue; }
  [ -f "$o" ] || { echo "$b NOBUILD"; fail=1; continue; }
  "$o"; r=$?; echo "$b rc=$r"; [ $r = 0 ] || fail=1
done
exit $fail
