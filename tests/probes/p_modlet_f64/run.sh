#!/bin/sh
# 10.53: module-level f64 let is one shared modlet cell across functions.
X=${1:-compiler/xlang_asm}
D=$(dirname "$0")
fail=0
for f in "$D"/*.x; do
  b=$(basename "$f" .x); o=/tmp/p_modlet_f64_$b
  rm -f "$o"; "$X" "$f" -o "$o" >/dev/null 2>&1 || { echo "$b NOBUILD"; fail=1; continue; }
  [ -f "$o" ] || { echo "$b NOBUILD"; fail=1; continue; }
  "$o"; r=$?; echo "$b rc=$r"; [ $r = 0 ] || fail=1
done
exit $fail
