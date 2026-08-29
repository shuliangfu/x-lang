#!/usr/bin/env bash
# STD-136: std.datetime IANA TZ + DST gate — honesty leftover unused compiler-make →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c / soft ensure rebuild). Product
# iana_dst_smoke.x -o exit0 = hard run (run=1). check / host-C archaeology = obs.
# Report: run=/obs=/skip=. G.7: complete existing resolve_shu; drop unused
# compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-datetime-iana-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD136_DATETIME_IANA_DOC:-analysis/archive/std/std-datetime-iana-v1.md}"
MANIFEST="${XLANG_STD136_DATETIME_IANA_MANIFEST:-tests/baseline/std-datetime-iana-manifest.tsv}"
MOD_X="std/datetime/mod.x"
DT_X="std/datetime/datetime.x"
LIB="tests/lib/std-datetime-iana.sh"
SMOKE_X="tests/std-datetime/iana_dst_smoke.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-datetime-iana.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-datetime-iana gate FAIL: $*" >&2
  std_datetime_iana_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-136: datetime IANA manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-datetime-iana-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$DT_X" "$SMOKE_X"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-136 timezone_iana timezone_offset_at iana_dst_smoke; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"

sym_miss="$(std_datetime_iana_symbols_ok "$MOD_X" "$DT_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-datetime-iana manifest OK"

if [ "${XLANG_STD136_DATETIME_IANA_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_datetime_iana_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-datetime-iana gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-136: smoke (XLANG=$XLANG_BIN; check/host-C obs; product -o hard) ==="

# Host-C archaeology = obs only; refuse leftover unused compiler-make.sh /
# soft ensure/auto-make rebuild. Product -o is the hard path.
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
if std_datetime_iana_run_c_smoke; then
  echo "std-datetime-iana c smoke OK (observational)"
else
  echo "std-datetime-iana OBS c smoke (host-C archaeology; refuse soft ensure/auto-make)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std136_iana_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-datetime-iana OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std136_datetime_iana_$$"
LOG="/tmp/xlang_std136_datetime_iana_build_$$.log"
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
echo "std-datetime-iana OK: product -o"

std_datetime_iana_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-datetime-iana gate OK"
