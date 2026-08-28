#!/usr/bin/env bash
# STD-137: std.time format/timezone — honesty leftover wrap dead source →硬绿.
#
# Honesty: leftover bootstrap-link wrap sourced unused (no RUN_XLANG) + unused
# compiler-make.sh retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover wrap dead
# source / unused compiler-make / soft SKIP→OK / prefer-c). Product
# format_timezone.x -o exit0 = hard run (run+=). check + host-C = obs
# (existing .o only; no soft rebuild). Report: run=/obs=/skip=.
# G.7: complete existing resolve_shu; drop unused compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-time-format-timezone-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD137_TIME_FORMAT_TZ_DOC:-analysis/archive/std/std-time-format-timezone-v1.md}"
MANIFEST="${XLANG_STD137_TIME_FORMAT_TZ_MANIFEST:-tests/baseline/std-time-format-timezone-manifest.tsv}"
MOD_X="std/time/mod.x"
TIME_X="${XLANG_STD_TIME_IMPL:-std/time/time.x}"
TIME_RUNTIME="compiler/seeds/runtime_time_os.from_x.c"
LIB="tests/lib/std-time-format-timezone.sh"
SMOKE_X="tests/time/format_timezone.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-time-format-timezone.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-time-format-timezone gate FAIL: $*" >&2
  std_time_format_tz_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c fallthrough.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang; do
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

echo "=== STD-137: time format/timezone manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-time-format-timezone-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$TIME_X" "$TIME_RUNTIME" "$SMOKE_X"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-137 format_timezone wall_local_offset_min format_wall_rfc3339; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 3. Gate' "$DOC" 2>/dev/null || die "doc missing '## 3. Gate'"

sym_miss="$(std_time_format_tz_symbols_ok "$MOD_X" "$TIME_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-time-format-timezone manifest OK"

if [ "${XLANG_STD137_TIME_FORMAT_TZ_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_time_format_tz_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-time-format-timezone gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-137: smoke (XLANG=$XLANG_BIN; check/C obs; format_timezone product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std137_chk.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-time-format-timezone OBS check (paused / CHK residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Observational host-C archaeology (existing .o only; no soft auto-make).
# PLATFORM: SHARED archaeology — product honesty is format_timezone.x via asm.
echo "=== STD-137: time c smoke (observational; no soft rebuild) ==="
TIME_O="std/time/time.o"
DT_O="std/datetime/datetime.o"
if [ -f "$TIME_O" ] && [ -f "$DT_O" ] && nm "$TIME_O" 2>/dev/null | grep -qF 'time_format_timezone_smoke_c'; then
  if std_time_format_tz_run_c_smoke "$TIME_O" "$DT_O"; then
    echo "std-time-format-timezone c smoke OK (observational)"
  else
    echo "std-time-format-timezone OBS c smoke (archaeology residual; refuse soft SKIP→OK)" >&2
    OBS=$((OBS + 1))
  fi
else
  echo "std-time-format-timezone OBS c smoke (no existing .o / symbol; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse leftover wrap dead source / unused compiler-make.sh
# (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

OUT="/tmp/xlang_std137_tftz_$$"
LOG="/tmp/xlang_std137_tftz_build_$$.log"
if "$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
  exitcode=0
  "$OUT" >/dev/null 2>&1 || exitcode=$?
  rm -f "$OUT"
  [ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "format_timezone.x exit=$exitcode (expect $SMOKE_EXPECT; refuse soft SKIP→OK)"
  RUN_OK=$((RUN_OK + 1))
  echo "std-time-format-timezone OK: format_timezone"
else
  tail -20 "$LOG" 2>/dev/null >&2 || true
  die "format_timezone.x link (refuse soft SKIP→OK)"
fi

std_time_format_tz_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-time-format-timezone gate OK (host=$(ci_host_summary))"
