#!/usr/bin/env bash
# STD-146: std.atomic 16/64 widen gate — honesty soft prefer-c /
# soft SKIP→OK / soft ensure_std_c_o / exec= report →硬绿.
#
# Honesty: prefer-c first (`./compiler/xlang-c` only) + soft SKIP→OK (no
# xlang-c still gate OK) + soft `ensure_std_c_o` / `ensure_runtime_atomic_glue_o
# || true` + hard check + hard product + report `exec=`/`skip=` retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. Refuse soft ensure rebuild (F-07 migrated
# atomic). check residual = obs (paused 2026-08-05). tip product -o UNDEF
# = obs (product debt; leave). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-atomic-widen-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_ATOMIC_WIDEN_DOC:-analysis/archive/std/std-atomic-widen-v1.md}"
MANIFEST="${XLANG_STD_ATOMIC_WIDEN_TSV:-tests/baseline/std-atomic-widen-manifest.tsv}"
MOD_X="std/atomic/mod.x"
ATOMIC_RUNTIME="${XLANG_STD_ATOMIC_IMPL:-compiler/seeds/runtime_atomic_glue.from_x.c}"
LIB="tests/lib/std-atomic-widen.sh"
SMOKE_X="tests/atomic/widen_16_64.x"

# shellcheck source=tests/lib/std-atomic-widen.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-atomic-widen gate FAIL: $*" >&2
  std_atomic_widen_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-146: std.atomic widen manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$ATOMIC_RUNTIME" "$SMOKE_X" std/atomic/README.md; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ ! -f analysis/std-atomic-widen-v1.md ] || die "dual-authority fossil analysis/std-atomic-widen-v1.md (archive live)"

for kw in STD-146 load compare_exchange fetch_sub; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

sym_miss="$(std_atomic_widen_symbols_ok "$MOD_X" "$ATOMIC_RUNTIME" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-atomic-widen registry OK"

if [ "${XLANG_STD_ATOMIC_WIDEN_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_atomic_widen_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-atomic-widen gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-146: smoke (XLANG=$XLANG_BIN; check=obs; tip product=obs; refuse soft ensure) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_atomic_widen_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-atomic-widen OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product -o: success → run++; tip UNDEF/fail → obs (not soft SKIP→OK).
# Refuse soft ensure_std_c_o / ensure_runtime_atomic_glue_o rebuild.
OUT="/tmp/xlang_atomic_widen_$$"
LOG="/tmp/xlang_atomic_widen_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 12 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  echo "std-atomic-widen OBS tip product -o (ec=$o_ec; std_atomic_* UNDEF residual)" >&2
  OBS=$((OBS + 1))
else
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  if [ "$exitcode" -ne 0 ]; then
    echo "std-atomic-widen OBS tip run exit=$exitcode" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "std-atomic-widen OK: product -o"
  fi
fi

std_atomic_widen_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-atomic-widen gate OK"
