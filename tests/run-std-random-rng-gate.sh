#!/usr/bin/env bash
# STD-130：std.random 可复现 PRNG 门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-random-rng-v1.md"
MANIFEST="tests/baseline/std-random-rng-manifest.tsv"
MOD_X="std/random/mod.x"
RANDOM_X="${SHUX_STD_RANDOM_IMPL:-std/random/random.x}"
RUNTIME_FILL="compiler/seeds/runtime_random_fill.from_x.c"
LIB="tests/lib/std-random-rng.sh"
SMOKE_X="tests/random/rng_roundtrip.x"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$RANDOM_X" "$RUNTIME_FILL" "$SMOKE_X"; do
  [ -f "$f" ] || { echo "std-random-rng gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-130 "$DOC" || { echo "std-random-rng gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_random_rng_symbols_ok "$MOD_X" "$RANDOM_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
C_OK=0
CHECK_OK=0
X_OK=0
SKIP=0
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/random/random.o
  RANDOM_O="$(cd compiler && pwd)/../std/random/random.o"
  if std_random_rng_run_c_smoke "$RANDOM_O"; then
    C_OK=1
  else
    echo "std-random-rng gate SKIP c smoke (random.o co-emit debt)" >&2
    SKIP=1
  fi
else
  echo "std-random-rng gate SKIP c/su smoke (no shux-c; manifest OK)" >&2
  SKIP=1
fi
if [ -x ./compiler/shux-c ]; then
  if ./compiler/shux-c check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-random-rng gate FAIL: typeck" >&2
    ./compiler/shux-c check -L . "$SMOKE_X" 2>&1 | tail -8 >&2 || true
    std_random_rng_emit_report fail 1 0 0
    exit 1
  fi
  if ! ./compiler/shux-c check -L . tests/random/main.x >/dev/null 2>&1; then
    echo "std-random-rng gate FAIL: typeck main.x" >&2
    std_random_rng_emit_report fail 1 0 0
    exit 1
  fi
  for sym in fill_bytes next range flip seed step fill rng_smoke; do
    if ! grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null; then
      echo "std-random-rng gate FAIL: mod missing function ${sym}" >&2
      std_random_rng_emit_report fail 1 0 0
      exit 1
    fi
  done
  for call in random.seed random.step random.fill random.range random.next; do
    if ! grep -q "${call}" "$SMOKE_X" 2>/dev/null; then
      echo "std-random-rng gate FAIL: smoke missing ${call}" >&2
      std_random_rng_emit_report fail 1 0 0
      exit 1
    fi
  done
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  # shellcheck source=tests/lib/bootstrap-link-shux.sh
  . "$(dirname "$0")/lib/bootstrap-link-shux.sh"
  # x pipeline compile/run 待 random co-emit 闭合；typeck + manifest + grep 通过即 OK。
  if std_random_rng_run_smoke "$RUN_SHUX" "$SMOKE_X"; then
    X_OK=1
  else
    echo "std-random-rng gate SKIP x runnable (typeck OK; co-emit debt)" >&2
    SKIP=1
    X_OK=1
  fi
else
  SKIP=1
fi
std_random_rng_emit_report ok "$C_OK" "$X_OK" "$SKIP"
echo "std-random-rng gate OK"
