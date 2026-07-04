#!/usr/bin/env bash
# STD-137：std.time 墙钟格式化与时区偏移门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-time-format-timezone-v1.md"
MANIFEST="tests/baseline/std-time-format-timezone-manifest.tsv"
MOD_X="std/time/mod.x"
TIME_X="${SHUX_STD_TIME_IMPL:-std/time/time.x}"
TIME_RUNTIME="compiler/src/asm/runtime_time_os.c"
LIB="tests/lib/std-time-format-timezone.sh"
SMOKE_X="tests/time/format_timezone.x"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$TIME_X" "$TIME_RUNTIME" "$SMOKE_X"; do
  [ -f "$f" ] || { echo "std-time-format-timezone gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-137 "$DOC" || { echo "std-time-format-timezone gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_time_format_tz_symbols_ok "$MOD_X" "$TIME_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
C_OK=0
X_OK=0
SKIP=0
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/time/time.o
  ensure_std_c_o ../std/datetime/datetime.o
  TIME_O="$(cd compiler && pwd)/../std/time/time.o"
  DT_O="$(cd compiler && pwd)/../std/datetime/datetime.o"
  std_time_format_tz_run_c_smoke "$TIME_O" "$DT_O" && C_OK=1 || exit 1
else
  echo "std-time-format-timezone gate SKIP c smoke (no shux-c; manifest OK)" >&2
  SKIP=1
fi
if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_X" >/dev/null
  std_time_format_tz_run_smoke ./compiler/shux-c "$SMOKE_X" && X_OK=1 || exit 1
else
  SKIP=1
fi
std_time_format_tz_emit_report ok "$C_OK" "$X_OK" "$SKIP"
echo "std-time-format-timezone gate OK"
