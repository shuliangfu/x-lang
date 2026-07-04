#!/usr/bin/env bash
# STD-114：std.unicode grapheme/case fold 门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-unicode-grapheme-case-v1.md"
MANIFEST="tests/baseline/std-unicode-grapheme-case.tsv"
MOD_X="std/unicode/mod.x"
UNI_IMPL="std/unicode/unicode.x"
UNI_X="std/unicode/unicode.x"
LIB="tests/lib/std-unicode-grapheme-case.sh"
SMOKE_X="tests/std-unicode/grapheme_case.x"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$UNI_X" "$UNI_IMPL" "$SMOKE_X"; do
  [ -f "$f" ] || { echo "std-unicode-grapheme-case gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF grapheme_next "$DOC" || exit 1
sym_miss="$(std_unicode_gc_symbols_ok "$MOD_X" "$UNI_IMPL" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/unicode/unicode.o
UNI_O="$(cd compiler && pwd)/../std/unicode/unicode.o"
C_OK=0
if cc -std=c11 -O1 -o /tmp/shux_unicode_gc_c "$UNI_O" -x c - <<'EOF' 2>/dev/null; then
#include <stdint.h>
extern int32_t grapheme_case_smoke(void);
int main(void){ return grapheme_case_smoke()!=0; }
EOF
  /tmp/shux_unicode_gc_c >/dev/null && C_OK=1
  rm -f /tmp/shux_unicode_gc_c
else
  echo "std-unicode-grapheme-case gate SKIP c smoke (unicode.o link failed)" >&2
fi
X_OK=0
SKIP=0
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  SHUX_BIN=./compiler/shux-c
  [ -x "$SHUX_BIN" ] || SHUX_BIN=./compiler/shux
  "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null
  std_unicode_gc_run_smoke "$SHUX_BIN" "$SMOKE_X" && X_OK=1 || exit 1
else
  SKIP=1
  echo "std-unicode-grapheme-case gate SKIP x smoke (no shux-c)" >&2
fi
std_unicode_gc_emit_report ok "$C_OK" "$X_OK" "$SKIP"
echo "std-unicode-grapheme-case gate OK"
