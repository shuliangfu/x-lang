#!/bin/sh
# w1513 (终局待办 10.42, 10.51): every probe exits 0 when a local `let a: [N]S = [..]`
# stores every byte of each struct element (6/8/12/16/24 bytes, *u8 fields,
# nested structs; literal, var, index, call and computed-field elements).
# Usage: sh tests/probes/p_struct_arr_lit/run.sh [xlang_asm]
X=${1:-compiler/xlang_asm}
D=$(dirname "$0")
fail=0
for f in "$D"/*.x; do
  b=$(basename "$f" .x); o=/tmp/p_struct_arr_lit_$b
  rm -f "$o"; "$X" "$f" -o "$o" >/dev/null 2>&1 || { echo "$b NOBUILD"; fail=1; continue; }
  [ -f "$o" ] || { echo "$b NOBUILD"; fail=1; continue; }
  "$o"; r=$?; echo "$b rc=$r"; [ $r = 0 ] || fail=1
done
exit $fail
