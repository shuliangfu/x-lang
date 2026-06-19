#!/usr/bin/env bash
# STD-127：std.encoding Base32/percent 门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-encoding-extra-v1.md"
MANIFEST="tests/baseline/std-encoding-extra-manifest.tsv"
MOD_SU="std/encoding/mod.sx"
ENCODING_C="std/encoding/encoding.c"
LIB="tests/lib/std-encoding-extra.sh"
SMOKE_SU="tests/encoding/base32_percent_string.sx"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$ENCODING_C" "$SMOKE_SU"; do
  [ -f "$f" ] || { echo "std-encoding-extra gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-127 "$DOC" || { echo "std-encoding-extra gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_encoding_extra_symbols_ok "$MOD_SU" "$ENCODING_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/encoding/encoding.o
ENCODING_O="$(cd compiler && pwd)/../std/encoding/encoding.o"
C_OK=0
std_encoding_extra_run_c_smoke "$ENCODING_O" && C_OK=1 || exit 1
SU_OK=0
SKIP=0
if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_SU" >/dev/null
  std_encoding_extra_run_smoke ./compiler/shux-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi
std_encoding_extra_emit_report ok "$C_OK" "$SU_OK" "$SKIP"
echo "std-encoding-extra gate OK"
