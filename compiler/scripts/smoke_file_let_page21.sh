#!/bin/bash
# smoke_file_let_page21.sh — w759 Class J regression
# Darwin: file-level let must emit PAGE21/PAGEOFF12 (not BR26) so ld -r works.
# PLATFORM: MACOS|ARM64 primary; LINUX may skip (ELF uses different reloc).
set -e
cd "$(dirname "$0")/.."
ASM="./xlang_asm"
[ -x "$ASM" ] || ASM="./xlang"
[ -x "$ASM" ] || { echo "smoke_file_let_page21: need xlang_asm" >&2; exit 2; }
UNAME=$(uname -s)
TMP=$(mktemp -d /tmp/smoke_page21.XXXXXX)
trap 'rm -rf "$TMP"' EXIT
cat >"$TMP/let.x" <<'X'
let g_flag: i32 = 0;
#[no_mangle]
export function touch(): i32 {
  g_flag = g_flag + 1;
  return g_flag;
}
X
"$ASM" -backend asm -c "$TMP/let.x" -o "$TMP/let.o"
if [ "$UNAME" = Darwin ]; then
  if otool -rv "$TMP/let.o" | grep -q 'BR26.*Lxml'; then
    echo "smoke_file_let_page21 FAIL: BR26 on Lxml (want PAGE21)" >&2
    otool -rv "$TMP/let.o" | head -20 >&2
    exit 1
  fi
  if ! otool -rv "$TMP/let.o" | grep -q 'PAGE21'; then
    echo "smoke_file_let_page21 FAIL: no PAGE21 reloc" >&2
    exit 1
  fi
  /usr/bin/ld -arch "$(uname -m | sed 's/arm64/arm64/;s/x86_64/x86_64/')" -r -o "$TMP/r.o" "$TMP/let.o"
  echo "smoke_file_let_page21 OK (Darwin PAGE21 + ld -r)"
else
  echo "smoke_file_let_page21 OK (skip Darwin PAGE21 check on $UNAME)"
fi
