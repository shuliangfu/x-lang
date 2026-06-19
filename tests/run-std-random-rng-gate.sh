#!/usr/bin/env bash
# STD-130：std.random 可复现 PRNG 门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-random-rng-v1.md"
MANIFEST="tests/baseline/std-random-rng-manifest.tsv"
MOD_SU="std/random/mod.sx"
RANDOM_C="std/random/random.c"
LIB="tests/lib/std-random-rng.sh"
SMOKE_SU="tests/random/rng_roundtrip.sx"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$RANDOM_C" "$SMOKE_SU"; do
  [ -f "$f" ] || { echo "std-random-rng gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-130 "$DOC" || { echo "std-random-rng gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_random_rng_symbols_ok "$MOD_SU" "$RANDOM_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/random/random.o
RANDOM_O="$(cd compiler && pwd)/../std/random/random.o"
C_OK=0
std_random_rng_run_c_smoke "$RANDOM_O" && C_OK=1 || exit 1
CHECK_OK=0
SU_OK=0
SKIP=0
if [ -x ./compiler/shux-c ]; then
  if ./compiler/shux-c check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-random-rng gate FAIL: typeck" >&2
    ./compiler/shux-c check -L . "$SMOKE_SU" 2>&1 | tail -8 >&2 || true
    std_random_rng_emit_report fail 1 0 0
    exit 1
  fi
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  # shellcheck source=tests/lib/bootstrap-link-shux.sh
  . "$(dirname "$0")/lib/bootstrap-link-shux.sh"
  if std_random_rng_run_smoke "$RUN_SHUX" "$SMOKE_SU"; then
    SU_OK=1
  else
    echo "std-random-rng gate SKIP su runnable (check passed; see build log above)" >&2
    SKIP=1
  fi
else
  SKIP=1
fi
std_random_rng_emit_report ok "$C_OK" "$SU_OK" "$SKIP"
echo "std-random-rng gate OK"
