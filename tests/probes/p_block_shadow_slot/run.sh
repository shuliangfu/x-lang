#!/bin/sh
# w2057: a loop body inside a branch must resolve its names in the enclosing
# blocks before any same-named let in a sibling branch. Every probe exits 0
# when right; a wrong slot loops forever (timeout) or returns non-zero.
# Usage: sh tests/probes/p_block_shadow_slot/run.sh [xlang_asm]
X=${1:-compiler/xlang_asm}
D=$(dirname "$0")
T=""
command -v timeout >/dev/null 2>&1 && T="timeout 10"
fail=0
for f in "$D"/*.x; do
  b=$(basename "$f" .x); o=/tmp/p_block_shadow_slot_$b
  rm -f "$o"; "$X" "$f" -o "$o" >/dev/null 2>&1 || { echo "$b NOBUILD"; fail=1; continue; }
  $T "$o"; r=$?; echo "$b rc=$r"; [ $r = 0 ] || fail=1
done
exit $fail
