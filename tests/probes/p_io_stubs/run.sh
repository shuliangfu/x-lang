#!/bin/sh
# w1515 (终局待办 5.7a): user programs linked against runtime_asm_io_stubs.o
# (now built from src/asm/runtime_asm_io_stubs.x). Each probe exits 0; when a
# .expected file exists its stdout must match byte for byte (i64/u64 prints,
# JSON struct print). stdin is "ABCDEF\n".
# PLATFORM: WINDOWS — outputs get .exe, live under $TMPDIR (C:/…), and CR is
# stripped from both sides before the compare (_write on a text-mode fd emits
# CRLF; a Windows checkout may turn the .expected files into CRLF).
# Usage: sh tests/probes/p_io_stubs/run.sh [xlang_asm]
X=${1:-compiler/xlang_asm}
D=$(dirname "$0")
T=${TMPDIR:-/tmp}
ext=
case "$(uname -s 2>/dev/null)" in MINGW*|MSYS*|CYGWIN*|Windows_NT*) ext=.exe; X=${1:-compiler/xlang_asm.exe} ;; esac
fail=0
for f in "$D"/*.x; do
  b=$(basename "$f" .x); o=$T/p_io_stubs_$b$ext
  rm -f "$o" "$o.out"; "$X" "$f" -o "$o" >/dev/null 2>&1 || { echo "$b NOBUILD"; fail=1; continue; }
  [ -f "$o" ] || { echo "$b NOBUILD"; fail=1; continue; }
  printf 'ABCDEF\n' | "$o" | tr -d '\r' > "$o.out"
  printf 'ABCDEF\n' | "$o" > /dev/null; r=$?
  m=ok
  if [ -f "$D/$b.expected" ]; then
    tr -d '\r' < "$D/$b.expected" > "$o.exp"
    cmp -s "$o.out" "$o.exp" || { m=MISMATCH; fail=1; }
  fi
  echo "$b rc=$r out=$m"; [ $r = 0 ] || fail=1
done
exit $fail
