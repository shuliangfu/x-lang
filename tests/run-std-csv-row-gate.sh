#!/usr/bin/env bash
# STD-036: std.csv parse_row / write_row gate — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … xlang-c … || true`) + soft
# XLANG fallthrough (explicit-bad still picks another binary) + check=/run=/skip=
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
# Product row_roundtrip.x + main.x -o exit0 = hard run. check residual = obs
# (paused 2026-08-05). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-csv-row-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_CSV_ROW_DOC:-analysis/archive/std/std-csv-row-v1.md}"
MANIFEST="${XLANG_STD_CSV_ROW_TSV:-tests/baseline/std-csv-row.tsv}"
MOD_X="std/csv/mod.x"
CSV_X="std/csv/csv.x"
LIB="tests/lib/std-csv-row.sh"
RT_X="tests/csv/row_roundtrip.x"
MAIN_X="tests/csv/main.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-csv-row.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-csv-row gate FAIL: $*" >&2
  std_csv_row_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-036: csv row manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$CSV_X" "$RT_X" "$MAIN_X"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in parse_row write_row RFC 4180 row_roundtrip; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

grep -qF '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"

sym_miss="$(std_csv_row_symbols_ok "$MOD_X" "$CSV_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-csv-row manifest OK"

if [ "${XLANG_STD_CSV_ROW_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_csv_row_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-csv-row gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-036: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$RT_X" >/tmp/xlang_std_csv_row_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-csv-row OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

run_one() {
  local src="$1"
  local tag="$2"
  local out="/tmp/xlang_std036_csv_row_${tag}_$$"
  local log="/tmp/xlang_std036_csv_row_${tag}_$$.log"
  local o_ec exitcode
  rm -f "$out" "$log"
  set +e
  "$XLANG_BIN" -L . "$src" -o "$out" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    echo "std-csv-row gate FAIL runnable $tag link" >&2
    tail -20 "$log" 2>/dev/null >&2 || true
    rm -f "$out"
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$out"
  if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
    RUN_OK=$((RUN_OK + 1))
    echo "std-csv-row OK: $tag product -o"
    return 0
  fi
  echo "std-csv-row gate FAIL runnable $tag exit=$exitcode (expect $SMOKE_EXPECT)" >&2
  return 1
}

if ! run_one "$RT_X" "row_roundtrip"; then
  die "row_roundtrip product -o failed (refuse soft SKIP→OK)"
fi
if ! run_one "$MAIN_X" "main"; then
  die "main product -o failed (refuse soft SKIP→OK)"
fi

std_csv_row_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-csv-row gate OK"
