#!/usr/bin/env bash
# STD-133：std.time benchmark 计时器门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-time-bench-timer-v1.md"
MANIFEST="tests/baseline/std-time-bench-timer-manifest.tsv"
MOD_X="std/time/mod.x"
LIB="tests/lib/std-time-bench-timer.sh"
SMOKE_X="tests/time/bench_timer.x"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SMOKE_X"; do
  [ -f "$f" ] || { echo "std-time-bench-timer gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-133 "$DOC" || { echo "std-time-bench-timer gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_time_bench_timer_symbols_ok "$MOD_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/time/time.o
X_OK=0
SKIP=0
if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_X" >/dev/null
  std_time_bench_timer_run_smoke ./compiler/shux-c "$SMOKE_X" && X_OK=1 || exit 1
else
  SKIP=1
fi
std_time_bench_timer_emit_report ok "$X_OK" "$SKIP"
echo "std-time-bench-timer gate OK"
