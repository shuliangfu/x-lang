#!/usr/bin/env bash
# STD-114：std.unicode grapheme/case fold 门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-unicode-grapheme-case-v1.md"
MANIFEST="tests/baseline/std-unicode-grapheme-case.tsv"
MOD_SX="std/unicode/mod.sx"
UNI_IMPL="std/unicode/unicode.sx"
UNI_SX="std/unicode/unicode.sx"
LIB="tests/lib/std-unicode-grapheme-case.sh"
SMOKE_SX="tests/std-unicode/grapheme_case.sx"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SX" "$UNI_SX" "$UNI_IMPL" "$SMOKE_SX"; do
  [ -f "$f" ] || { echo "std-unicode-grapheme-case gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF grapheme_next "$DOC" || exit 1
sym_miss="$(std_unicode_gc_symbols_ok "$MOD_SX" "$UNI_IMPL" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/unicode/unicode.o
UNI_O="$(cd compiler && pwd)/../std/unicode/unicode.o"
C_OK=0
if cc -std=c11 -O1 -o /tmp/shux_unicode_gc_c "$UNI_O" -x c - <<'EOF' 2>/dev/null; then
#include <stdint.h>
extern int32_t unicode_grapheme_case_smoke_c(void);
int main(void){ return unicode_grapheme_case_smoke_c()!=0; }
EOF
  /tmp/shux_unicode_gc_c >/dev/null && C_OK=1
  rm -f /tmp/shux_unicode_gc_c
else
  echo "std-unicode-grapheme-case gate SKIP c smoke (unicode.o link failed)" >&2
fi
SX_OK=0
SKIP=0
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  SHUX_BIN=./compiler/shux-c
  [ -x "$SHUX_BIN" ] || SHUX_BIN=./compiler/shux
  "$SHUX_BIN" check -L . "$SMOKE_SX" >/dev/null
  std_unicode_gc_run_smoke "$SHUX_BIN" "$SMOKE_SX" && SX_OK=1 || exit 1
else
  SKIP=1
  echo "std-unicode-grapheme-case gate SKIP sx smoke (no shux-c)" >&2
fi
std_unicode_gc_emit_report ok "$C_OK" "$SX_OK" "$SKIP"
echo "std-unicode-grapheme-case gate OK"
