#!/bin/sh
# w2056: a slice returned from a call whose data sits on the callee's stack is
# copied in full (no 1024 cap); data elsewhere is aliased. Every probe exits 0
# when right; a non-zero code names the first wrong check.
# Usage: sh tests/probes/p_slice_ret_reent/run.sh [xlang_asm]
X=${1:-compiler/xlang_asm}
D=$(dirname "$0")
fail=0
for f in "$D"/*.x; do
  b=$(basename "$f" .x); o=/tmp/p_slice_ret_reent_$b
  rm -f "$o"; "$X" "$f" -o "$o" >/dev/null 2>&1 || { echo "$b NOBUILD"; fail=1; continue; }
  "$o"; r=$?; echo "$b rc=$r"; [ $r = 0 ] || fail=1
done
exit $fail
