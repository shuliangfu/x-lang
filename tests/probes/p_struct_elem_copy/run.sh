#!/bin/sh
# w1512 (终局待办 10.41): every probe exits 0 when `qs[i] = <lvalue>` copies the
# whole struct element (12/16/24 bytes; local, module, uninitialised, var,
# field and index rhs) and leaves the neighbouring elements alone.
# Usage: sh tests/probes/p_struct_elem_copy/run.sh [xlang_asm]
X=${1:-compiler/xlang_asm}
D=$(dirname "$0")
fail=0
for f in "$D"/*.x; do
  b=$(basename "$f" .x); o=/tmp/p_struct_elem_copy_$b
  rm -f "$o"; "$X" "$f" -o "$o" >/dev/null 2>&1 || { echo "$b NOBUILD"; fail=1; continue; }
  [ -f "$o" ] || { echo "$b NOBUILD"; fail=1; continue; }
  "$o"; r=$?; echo "$b rc=$r"; [ $r = 0 ] || fail=1
done
exit $fail
