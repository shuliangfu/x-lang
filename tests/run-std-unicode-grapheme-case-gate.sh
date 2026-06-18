#!/usr/bin/env bash
# STD-114：std.unicode grapheme/case fold 门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-unicode-grapheme-case-v1.md"
MANIFEST="tests/baseline/std-unicode-grapheme-case.tsv"
MOD_SU="std/unicode/mod.su"
UNI_C="std/unicode/unicode.c"
LIB="tests/lib/std-unicode-grapheme-case.sh"
SMOKE_SU="tests/std-unicode/grapheme_case.su"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$UNI_C" "$SMOKE_SU"; do
  [ -f "$f" ] || { echo "std-unicode-grapheme-case gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF grapheme_next "$DOC" || exit 1
sym_miss="$(std_unicode_gc_symbols_ok "$MOD_SU" "$UNI_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/unicode/unicode.o
UNI_O="$(cd compiler && pwd)/../std/unicode/unicode.o"
C_OK=0
cc -std=c11 -O1 -o /tmp/shu_unicode_gc_c "$UNI_O" -x c - <<'EOF' && C_OK=1 || exit 1
#include <stdint.h>
extern int32_t unicode_grapheme_case_smoke_c(void);
int main(void){ return unicode_grapheme_case_smoke_c()!=0; }
EOF
/tmp/shu_unicode_gc_c >/dev/null
SU_OK=0
SKIP=0
if [ -x ./compiler/shu-c ]; then
  ./compiler/shu-c check -L . "$SMOKE_SU" >/dev/null
  std_unicode_gc_run_smoke ./compiler/shu-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi
std_unicode_gc_emit_report ok "$C_OK" "$SU_OK" "$SKIP"
echo "std-unicode-grapheme-case gate OK"
