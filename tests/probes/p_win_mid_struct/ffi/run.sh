#!/bin/sh
# w1545 10.72: X <-> C interop for 12/16-byte structs (args and returns, both directions).
# Usage (repo root): sh tests/probes/p_win_mid_struct/ffi/run.sh compiler/xlang_asm [cc]
X=${1:-compiler/xlang_asm}
CCX=${2:-${CC:-cc}}
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*|Windows_NT*) ;; *) echo "ffi skip (Windows x64 only)"; exit 0;; esac
D=$(dirname "$0")
T=${TMPDIR:-/tmp}/p_win_mid_ffi; mkdir -p "$T"
rm -f "$T/ffi.o" "$T/ffi_c.o" "$T/ffi" "$T/ffi.exe"
"$X" "$D/ffi.x" -o "$T/ffi.o" >/dev/null 2>&1 || { echo "ffi NOBUILD_X"; exit 1; }
"$CCX" -c -O1 "$D/ffi_c.c" -o "$T/ffi_c.o" || { echo "ffi NOBUILD_C"; exit 1; }
"$CCX" "$T/ffi.o" "$T/ffi_c.o" -o "$T/ffi" || { echo "ffi NOLINK"; exit 1; }
[ -f "$T/ffi" ] || T_EXE="$T/ffi.exe"
"${T_EXE:-$T/ffi}"; r=$?; echo "ffi rc=$r"; [ $r = 0 ]
