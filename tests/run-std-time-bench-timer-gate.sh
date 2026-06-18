#!/usr/bin/env bash
# STD-133：std.time benchmark 计时器门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-time-bench-timer-v1.md"
MANIFEST="tests/baseline/std-time-bench-timer-manifest.tsv"
MOD_SU="std/time/mod.su"
LIB="tests/lib/std-time-bench-timer.sh"
SMOKE_SU="tests/time/bench_timer.su"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$SMOKE_SU"; do
  [ -f "$f" ] || { echo "std-time-bench-timer gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-133 "$DOC" || { echo "std-time-bench-timer gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_time_bench_timer_symbols_ok "$MOD_SU" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/time/time.o
SU_OK=0
SKIP=0
if [ -x ./compiler/shu-c ]; then
  ./compiler/shu-c check -L . "$SMOKE_SU" >/dev/null
  std_time_bench_timer_run_smoke ./compiler/shu-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi
std_time_bench_timer_emit_report ok "$SU_OK" "$SKIP"
echo "std-time-bench-timer gate OK"
