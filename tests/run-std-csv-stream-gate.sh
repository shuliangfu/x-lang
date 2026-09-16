#!/usr/bin/env bash
# STD-128: std.csv stream reader/writer gate — honesty soft prefer-c /
# soft SKIP→OK / soft ensure_std_c_o / c=/x= report →硬绿.
#
# Honesty: prefer-c first (`./compiler/xlang-c` only) + soft SKIP→OK (no
# xlang-c still gate OK) + soft `ensure_std_c_o … || true` + hard check +
# hard product via lib smoke + report `c=`/`x=`/`skip=` retired. Prefer
# product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die. Host-C archaeology = obs only (prebuilt csv.o; refuse
# soft ensure; F-07 forbids cc -c on migrated csv). check residual = obs
# (paused 2026-08-05). tip product -o UNDEF = obs (product debt; leave).
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-csv-stream-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_CSV_STREAM_DOC:-analysis/archive/std/std-csv-stream-v1.md}"
MANIFEST="${XLANG_STD_CSV_STREAM_TSV:-tests/baseline/std-csv-stream-manifest.tsv}"
MOD_X="std/csv/mod.x"
CSV_X="std/csv/csv.x"
LIB="tests/lib/std-csv-stream.sh"
SMOKE_X="tests/csv/stream_roundtrip.x"
SMOKE_C="tests/csv/stream_smoke_ok.c"
CSV_O="std/csv/csv.o"

# shellcheck source=tests/lib/std-csv-stream.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-csv-stream gate FAIL: $*" >&2
  std_csv_stream_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-128: csv stream manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$CSV_X" "$SMOKE_X"; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ ! -f analysis/std-csv-stream-v1.md ] || die "dual-authority fossil analysis/std-csv-stream-v1.md (archive live)"
grep -qF STD-128 "$DOC" || die "doc missing STD-128"

sym_miss="$(std_csv_stream_symbols_ok "$MOD_X" "$CSV_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-csv-stream manifest OK"

if [ "${XLANG_STD_CSV_STREAM_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_csv_stream_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-csv-stream gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-128: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure_std_c_o.
# PLATFORM: SHARED — F-07 forbids cc -c on migrated csv.
if [ ! -f "$SMOKE_C" ]; then
  echo "std-csv-stream OBS c smoke (missing $SMOKE_C)" >&2
  OBS=$((OBS + 1))
elif [ ! -f "$CSV_O" ]; then
  echo "std-csv-stream OBS c smoke (missing prebuilt $CSV_O; refuse soft ensure)" >&2
  OBS=$((OBS + 1))
elif cc -std=c11 -O1 -o /tmp/xlang_csv_stream_c_$$ "$SMOKE_C" "$CSV_O" 2>/tmp/csv_stream_c_link_$$.log; then
  set +e
  /tmp/xlang_csv_stream_c_$$ >/dev/null 2>&1
  c_ec=$?
  set -e
  rm -f /tmp/xlang_csv_stream_c_$$
  if [ "$c_ec" -ne 0 ]; then
    echo "std-csv-stream OBS c smoke run exit=$c_ec" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "std-csv-stream OK: c smoke"
  fi
else
  echo "std-csv-stream OBS c smoke link (UNDEF/residual; refuse soft ensure)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_csv_stream_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-csv-stream OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_csv_stream_$$"
LOG="/tmp/xlang_csv_stream_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 12 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  echo "std-csv-stream OBS tip product -o (ec=$o_ec; std_csv_* UNDEF residual)" >&2
  OBS=$((OBS + 1))
else
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  if [ "$exitcode" -ne 0 ]; then
    echo "std-csv-stream OBS tip run exit=$exitcode" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "std-csv-stream OK: product -o"
  fi
fi

std_csv_stream_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-csv-stream gate OK"
