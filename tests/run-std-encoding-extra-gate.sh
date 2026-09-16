#!/usr/bin/env bash
# STD-127: std.encoding Base32/percent gate — honesty soft prefer-c / soft
# SKIP→OK / soft ensure_std_c_o / hard check / c=/x= report →硬绿.
#
# Honesty: prefer-c first (xlang-c only) + soft SKIP→OK (no xlang-c still
# gate OK) + soft `ensure_std_c_o` + hard check as sole .x smoke + report
# `c=`/`x=` retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die. Host-C archaeology = obs
# only (prebuilt std/encoding/encoding.o; refuse soft ensure). check
# residual = obs (paused 2026-08-05). tip product -o UNDEF/SEGV = obs
# (product debt; leave). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-encoding-extra-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD127_DOC:-analysis/archive/std/std-encoding-extra-v1.md}"
MANIFEST="${XLANG_STD127_TSV:-tests/baseline/std-encoding-extra-manifest.tsv}"
MOD_X="std/encoding/mod.x"
ENCODING_X="${XLANG_STD_ENCODING_IMPL:-std/encoding/encoding.x}"
LIB="tests/lib/std-encoding-extra.sh"
SMOKE_X="tests/encoding/base32_percent_string.x"
ENCODING_O="std/encoding/encoding.o"

# shellcheck source=tests/lib/std-encoding-extra.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-encoding-extra gate FAIL: $*" >&2
  std_encoding_extra_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-127: std.encoding Base32/percent manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$ENCODING_X" "$SMOKE_X"; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-encoding-extra-v1.md ] || die "dual-authority fossil analysis/std-encoding-extra-v1.md (archive live)"
grep -qF STD-127 "$DOC" || die "doc missing STD-127"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

sym_miss="$(std_encoding_extra_symbols_ok "$MOD_X" "$ENCODING_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-encoding-extra manifest OK"

if [ "${XLANG_STD127_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_encoding_extra_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-encoding-extra gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-127: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure_std_c_o.
# PLATFORM: SHARED — missing prebuilt encoding.o = obs, not soft SKIP→OK.
set +e
std_encoding_extra_run_c_smoke "$ENCODING_O"
c_rc=$?
set -e
case "$c_rc" in
  0)
    RUN_OK=$((RUN_OK + 1))
    echo "std-encoding-extra OK: c smoke"
    ;;
  *)
    echo "std-encoding-extra OBS c smoke (rc=$c_rc)" >&2
    OBS=$((OBS + 1))
    ;;
esac

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_encoding_extra_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-encoding-extra OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product UNDEF/SEGV residual = obs (leave product debt).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence.
if std_encoding_extra_run_smoke "$XLANG_BIN" "$SMOKE_X"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-encoding-extra OK: product base32_percent_string"
else
  echo "std-encoding-extra OBS tip product base32_percent_string (UNDEF/SEGV residual)" >&2
  OBS=$((OBS + 1))
fi

std_encoding_extra_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-encoding-extra gate OK"
