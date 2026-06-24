#!/usr/bin/env bash
# STD-135：std.datetime 固定偏移时区门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-datetime-timezone-v1.md"
MANIFEST="tests/baseline/std-datetime-timezone-manifest.tsv"
MOD_SX="std/datetime/mod.sx"
DT_SX="std/datetime/datetime.sx"
LIB="tests/lib/std-datetime-timezone.sh"
SMOKE_SX="tests/std-datetime/timezone.sx"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SX" "$DT_SX" "$SMOKE_SX"; do
  [ -f "$f" ] || { echo "std-datetime-timezone gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-135 "$DOC" || { echo "std-datetime-timezone gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_datetime_timezone_symbols_ok "$MOD_SX" "$DT_SX" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/datetime/datetime.o
ensure_std_c_o ../std/time/time.o
DT_O="$(cd compiler && pwd)/../std/datetime/datetime.o"
TIME_O="$(cd compiler && pwd)/../std/time/time.o"
C_OK=0
if nm "$DT_O" 2>/dev/null | grep -qF 'datetime_timezone_smoke_c'; then
  std_datetime_timezone_run_c_smoke "$DT_O" "$TIME_O" && C_OK=1 || exit 1
else
  echo "std-datetime-timezone gate SKIP c smoke (datetime.o missing sx symbols; need shux-c)" >&2
  SKIP=1
fi
SX_OK=0
SKIP=${SKIP:-0}
if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_SX" >/dev/null
  std_datetime_timezone_run_smoke ./compiler/shux-c "$SMOKE_SX" && SX_OK=1 || exit 1
else
  SKIP=1
fi
std_datetime_timezone_emit_report ok "$C_OK" "$SX_OK" "$SKIP"
echo "std-datetime-timezone gate OK"
