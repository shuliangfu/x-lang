#!/bin/sh
# w1511 (终局待办 10.40): every probe exits 0 when a module-level f32 let is one
# shared cell that every function reads and writes (no per-function slot).
# Usage: sh tests/probes/p_modlet_float/run.sh [xlang_asm]
X=${1:-compiler/xlang_asm}
D=$(dirname "$0")
fail=0
for f in "$D"/*.x; do
  b=$(basename "$f" .x); o=/tmp/p_modlet_float_$b
  rm -f "$o"; "$X" "$f" -o "$o" >/dev/null 2>&1 || { echo "$b NOBUILD"; fail=1; continue; }
  [ -f "$o" ] || { echo "$b NOBUILD"; fail=1; continue; }
  "$o"; r=$?; echo "$b rc=$r"; [ $r = 0 ] || fail=1
done
exit $fail
