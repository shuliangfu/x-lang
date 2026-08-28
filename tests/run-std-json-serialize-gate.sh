#!/usr/bin/env bash
# STD-035: std.json object/array serialize gate — honesty soft auto-make →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary) +
# soft auto-make (`xlang_compiler_make … || true`) + check=/run=/skip= retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
# Product object_array_roundtrip.x -o exit0 = hard run (run=1). check = obs.
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-json-serialize-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_JSZ_DOC:-analysis/archive/std/std-json-serialize-v1.md}"
MANIFEST="${XLANG_STD_JSZ_TSV:-tests/baseline/std-json-serialize.tsv}"
MOD_X="std/json/mod.x"
JSON_X="std/json/json.x"
LIB="tests/lib/std-json-serialize.sh"
RT_X="tests/json/object_array_roundtrip.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-json-serialize.sh
. tests/lib/std-json-serialize.sh

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-json-serialize gate FAIL: $*" >&2
  std_jsz_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-035: json serialize manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$JSON_X" "$RT_X"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in append_object append_array round-trip object_array_roundtrip; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"

sym_miss="$(std_jsz_symbols_ok "$MOD_X" "$JSON_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-json-serialize manifest OK"

if [ "${XLANG_STD_JSZ_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_jsz_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-json-serialize gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-035: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

# Refuse soft auto-make / soft ensure; leave ensure_std family alone.
# PLATFORM: SHARED archaeology.

set +e
"$XLANG_BIN" check -L . "$RT_X" >/tmp/xlang_std035_jsz_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-json-serialize OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std035_json_serialize_$$"
LOG="/tmp/xlang_std035_json_serialize_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$RT_X" -o "$OUT" >"$LOG" 2>&1
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
echo "std-json-serialize OK: product -o"

std_jsz_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-json-serialize gate OK"
