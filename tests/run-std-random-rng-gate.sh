#!/usr/bin/env bash
# STD-130: std.random reproducible PRNG gate — honesty leftover unused compiler-make →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c / soft ensure rebuild). Product
# rng_roundtrip.x + main.x -o exit0 = hard run (run=2). check / host-C
# archaeology = obs. Report: run=/obs=/skip=. G.7: complete existing
# resolve_shu; drop unused compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-random-rng-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_RANDOM_RNG_DOC:-analysis/archive/std/std-random-rng-v1.md}"
MANIFEST="${XLANG_STD_RANDOM_RNG_TSV:-tests/baseline/std-random-rng-manifest.tsv}"
MOD_X="std/random/mod.x"
RANDOM_X="${XLANG_STD_RANDOM_IMPL:-std/random/random.x}"
RUNTIME_FILL="compiler/seeds/runtime_random_fill.from_x.c"
LIB="tests/lib/std-random-rng.sh"
SMOKE_X="tests/random/rng_roundtrip.x"
MAIN_X="tests/random/main.x"
MIN_APIS=5

# shellcheck source=tests/lib/std-random-rng.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-random-rng gate FAIL: $*" >&2
  std_random_rng_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== STD-130: random PRNG manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$RANDOM_X" "$RUNTIME_FILL" "$SMOKE_X" "$MAIN_X"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-130 Rng seed step fill range rng_smoke; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF -- '## 5. Gate' "$DOC" 2>/dev/null || die "doc missing '## 5. Gate'"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
      ;;
    section)
      grep -qF -- "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_random_rng_symbols_ok "$MOD_X" "$RANDOM_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-random-rng manifest OK"

if [ "${XLANG_STD_RANDOM_RNG_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_random_rng_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-random-rng gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-130: smoke (XLANG=$XLANG_BIN; check/host-C obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_random_rng_check_rt.log 2>&1
chk_rt=$?
"$XLANG_BIN" check -L . "$MAIN_X" >/tmp/xlang_std_random_rng_check_main.log 2>&1
chk_main=$?
set -e
if [ "$chk_rt" -ne 0 ] || [ "$chk_main" -ne 0 ]; then
  echo "std-random-rng OBS check (paused / CHK residual rt=$chk_rt main=$chk_main; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse leftover unused compiler-make.sh (product -o is the hard path).
# Host-C archaeology = obs only; refuse soft ensure_std rebuild.
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
RANDOM_O="std/random/random.o"
if [ -f "$RANDOM_O" ] && std_random_rng_run_c_smoke "$RANDOM_O"; then
  echo "std-random-rng c smoke OK (observational)"
else
  echo "std-random-rng OBS c smoke (host-C archaeology; refuse soft ensure/auto-make)" >&2
  OBS=$((OBS + 1))
fi

for pair in "rt:$SMOKE_X" "main:$MAIN_X"; do
  tag="${pair%%:*}"
  src="${pair#*:}"
  OUT="/tmp/xlang_std_random_rng_${tag}_$$"
  LOG="/tmp/xlang_std_random_rng_${tag}_build_$$.log"
  rm -f "$OUT" "$LOG"
  set +e
  "$XLANG_BIN" -L . "$src" -o "$OUT" >"$LOG" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
    tail -n 20 "$LOG" 2>/dev/null || true
    rm -f "$OUT"
    die "product -o $src failed (ec=$o_ec; refuse soft SKIP→OK)"
  fi
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  [ "$exitcode" -eq 0 ] || die "runnable $src exit=$exitcode"
  RUN_OK=$((RUN_OK + 1))
  echo "std-random-rng OK: product -o $tag"
done

std_random_rng_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-random-rng gate OK"
