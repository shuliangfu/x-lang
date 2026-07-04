#!/usr/bin/env bash
# STD-127：std.encoding Base32/percent 门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-encoding-extra-v1.md"
MANIFEST="tests/baseline/std-encoding-extra-manifest.tsv"
MOD_X="std/encoding/mod.x"
ENCODING_X="${SHUX_STD_ENCODING_IMPL:-std/encoding/encoding.x}"
LIB="tests/lib/std-encoding-extra.sh"
SMOKE_X="tests/encoding/base32_percent_string.x"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$ENCODING_X" "$SMOKE_X"; do
  [ -f "$f" ] || { echo "std-encoding-extra gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-127 "$DOC" || { echo "std-encoding-extra gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_encoding_extra_symbols_ok "$MOD_X" "$ENCODING_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
C_OK=0
X_OK=0
SKIP=0
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/encoding/encoding.o
  ENCODING_O="$(cd compiler && pwd)/../std/encoding/encoding.o"
  std_encoding_extra_run_c_smoke "$ENCODING_O" && C_OK=1 || exit 1
else
  echo "std-encoding-extra gate SKIP c/su smoke (no shux-c; manifest OK)" >&2
  SKIP=1
fi
if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_X" >/dev/null
  std_encoding_extra_run_smoke ./compiler/shux-c "$SMOKE_X" && X_OK=1 || exit 1
else
  SKIP=1
fi
std_encoding_extra_emit_report ok "$C_OK" "$X_OK" "$SKIP"
echo "std-encoding-extra gate OK"
