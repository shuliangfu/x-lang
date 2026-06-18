#!/usr/bin/env bash
# STD-135：std.datetime 固定偏移时区门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-datetime-timezone-v1.md"
MANIFEST="tests/baseline/std-datetime-timezone-manifest.tsv"
MOD_SU="std/datetime/mod.su"
DT_C="std/datetime/datetime.c"
LIB="tests/lib/std-datetime-timezone.sh"
SMOKE_SU="tests/std-datetime/timezone.su"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$DT_C" "$SMOKE_SU"; do
  [ -f "$f" ] || { echo "std-datetime-timezone gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-135 "$DOC" || { echo "std-datetime-timezone gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_datetime_timezone_symbols_ok "$MOD_SU" "$DT_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/datetime/datetime.o
ensure_std_c_o ../std/time/time.o
DT_O="$(cd compiler && pwd)/../std/datetime/datetime.o"
TIME_O="$(cd compiler && pwd)/../std/time/time.o"
C_OK=0
std_datetime_timezone_run_c_smoke "$DT_O" "$TIME_O" && C_OK=1 || exit 1
SU_OK=0
SKIP=0
if [ -x ./compiler/shu-c ]; then
  ./compiler/shu-c check -L . "$SMOKE_SU" >/dev/null
  std_datetime_timezone_run_smoke ./compiler/shu-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi
std_datetime_timezone_emit_report ok "$C_OK" "$SU_OK" "$SKIP"
echo "std-datetime-timezone gate OK"
