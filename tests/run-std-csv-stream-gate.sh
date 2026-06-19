#!/usr/bin/env bash
# STD-128：std.csv 流式 reader/writer 门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-csv-stream-v1.md"
MANIFEST="tests/baseline/std-csv-stream-manifest.tsv"
MOD_SU="std/csv/mod.sx"
CSV_C="std/csv/csv.c"
LIB="tests/lib/std-csv-stream.sh"
SMOKE_SU="tests/csv/stream_roundtrip.sx"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$CSV_C" "$SMOKE_SU"; do
  [ -f "$f" ] || { echo "std-csv-stream gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-128 "$DOC" || { echo "std-csv-stream gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_csv_stream_symbols_ok "$MOD_SU" "$CSV_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/csv/csv.o
CSV_O="$(cd compiler && pwd)/../std/csv/csv.o"
C_OK=0
std_csv_stream_run_c_smoke "$CSV_O" && C_OK=1 || exit 1
SU_OK=0
SKIP=0
if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_SU" >/dev/null
  std_csv_stream_run_smoke ./compiler/shux-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi
std_csv_stream_emit_report ok "$C_OK" "$SU_OK" "$SKIP"
echo "std-csv-stream gate OK"
