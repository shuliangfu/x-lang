#!/usr/bin/env bash
# STD-128：std.csv 流式 reader/writer 门禁（F-csv v1：csv.x）
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-csv-stream-v1.md"
MANIFEST="tests/baseline/std-csv-stream-manifest.tsv"
MOD_X="std/csv/mod.x"
CSV_X="std/csv/csv.x"
LIB="tests/lib/std-csv-stream.sh"
SMOKE_X="tests/csv/stream_roundtrip.x"
# shellcheck source=tests/lib/std-csv-stream.sh
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$CSV_X" "$SMOKE_X"; do
  [ -f "$f" ] || { echo "std-csv-stream gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-128 "$DOC" || { echo "std-csv-stream gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_csv_stream_symbols_ok "$MOD_X" "$CSV_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1

C_OK=0
X_OK=0
SKIP=0

if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/csv/csv.o 2>/dev/null || true
  CSV_O="$(cd compiler && pwd)/../std/csv/csv.o"
  if std_csv_stream_run_c_smoke "$CSV_O"; then
    C_OK=1
  else
    echo "std-csv-stream gate SKIP c smoke (no full csv.o)" >&2
  fi
else
  echo "std-csv-stream gate SKIP c smoke (no shux-c)" >&2
fi

if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_X" >/dev/null
  std_csv_stream_run_smoke ./compiler/shux-c "$SMOKE_X" && X_OK=1 || exit 1
else
  SKIP=1
fi
std_csv_stream_emit_report ok "$C_OK" "$X_OK" "$SKIP"
echo "std-csv-stream gate OK"
