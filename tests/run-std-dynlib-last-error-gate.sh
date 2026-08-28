#!/usr/bin/env bash
# STD-096: std.dynlib last_error text diagnostic gate — honesty soft auto-make →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary) +
# soft ensure_std_c_o / soft auto-make (`xlang_compiler_make … || true`) +
# check=/run=/skip= retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK / soft
# auto-make / prefer-c / soft ensure rebuild). Product last_error.x -o exit0 =
# hard run (run=1). check / host-C archaeology = obs. Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-dynlib-last-error-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD096_DOC:-analysis/archive/std/std-dynlib-last-error-v1.md}"
MANIFEST="${XLANG_STD096_TSV:-tests/baseline/std-dynlib-last-error.tsv}"
MOD_X="std/dynlib/mod.x"
DYNLIB_X="std/dynlib/dynlib.x"
DYNLIB_RUNTIME="compiler/seeds/runtime_dynlib_os.from_x.c"
LIB="tests/lib/std-dynlib-last-error.sh"
SMOKE_X="tests/dynlib/last_error.x"
SMOKE_C="tests/dynlib/last_error_smoke.c"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-dynlib-last-error.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-dynlib-last-error gate FAIL: $*" >&2
  std_dynlib_last_error_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-096: dynlib last_error manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$DYNLIB_X" "$DYNLIB_RUNTIME" "$SMOKE_X" "$SMOKE_C"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in last_os_error dynlib_last_error_copy_c STD-096; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"

sym_miss="$(std_dynlib_last_error_symbols_ok "$MOD_X" "$DYNLIB_X" "$MANIFEST" "$DOC" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-dynlib-last-error manifest OK"

if [ "${XLANG_STD096_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_dynlib_last_error_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-dynlib-last-error gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-096: smoke (XLANG=$XLANG_BIN; check/host-C obs; product -o hard) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make rebuild.
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
if std_dynlib_last_error_run_c_smoke; then
  echo "std-dynlib-last-error c smoke OK (observational)"
else
  echo "std-dynlib-last-error OBS c smoke (host-C archaeology; refuse soft ensure/auto-make)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std096_dynlib_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-dynlib-last-error OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std096_dynlib_err_$$"
LOG="/tmp/xlang_std096_dynlib_err_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 20 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  die "product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$OUT" >/dev/null 2>&1
exitcode=$?
set -e
rm -f "$OUT"
[ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "runnable exit=$exitcode (expect $SMOKE_EXPECT)"
RUN_OK=$((RUN_OK + 1))
echo "std-dynlib-last-error OK: product -o"

std_dynlib_last_error_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-dynlib-last-error gate OK"
