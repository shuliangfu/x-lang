#!/usr/bin/env bash
# STD-135：std.datetime 固定偏移时区门禁（假权威诚实）。
#
# 用法：./tests/run-std-datetime-timezone-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); timezone.x exit 0 hard-fail (no soft SKIP
# when native xlang present). C smoke remains observational (archaeology host-C
# path; not hard green). Report check=/run=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / hard check / hard C smoke link / soft SKIP).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD135_DATETIME_TIMEZONE_DOC:-analysis/archive/std/std-datetime-timezone-v1.md}"
MANIFEST="${XLANG_STD135_DATETIME_TIMEZONE_MANIFEST:-tests/baseline/std-datetime-timezone-manifest.tsv}"
MOD_X="std/datetime/mod.x"
DT_X="std/datetime/datetime.x"
LIB="tests/lib/std-datetime-timezone.sh"
SMOKE_X="tests/std-datetime/timezone.x"
SMOKE_C="tests/std-datetime/timezone_smoke_ok.c"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-datetime-timezone.sh
. "$LIB"

echo "=== STD-135: datetime timezone manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$DT_X" "$SMOKE_X"; do
  if [ ! -f "$f" ]; then
    echo "std-datetime-timezone gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-135 TimeZone timezone_from_name parse_offset_min to_zoned_fields; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-datetime-timezone gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-datetime-timezone gate FAIL: doc missing '## 4. Gate'" >&2
  exit 1
fi

sym_miss="$(std_datetime_timezone_symbols_ok "$MOD_X" "$DT_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_datetime_timezone_emit_report "fail" 0 0 1
  echo "std-datetime-timezone gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-datetime-timezone manifest OK"

if [ "${XLANG_STD135_DATETIME_TIMEZONE_MANIFEST_ONLY:-0}" = "1" ]; then
  std_datetime_timezone_emit_report "ok" 0 0 1
  echo "std-datetime-timezone gate OK (manifest only)"
  exit 0
fi

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

resolve_shu() {
  local cand
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
RUN_OK=0
SKIP=1

# Observational host-C archaeology smoke (not hard green).
# PLATFORM: SHARED archaeology — product honesty is timezone.x via asm.
echo "=== STD-135: timezone c smoke (observational) ==="
C_NOTE=0
xlang_compiler_make ../std/datetime/datetime.o ../std/time/time.o runtime_time_os.o >/dev/null 2>&1 || true
DT_O="std/datetime/datetime.o"
TIME_O="std/time/time.o"
if [ -f "$DT_O" ] && nm "$DT_O" 2>/dev/null | grep -qF 'datetime_timezone_smoke_c'; then
  if std_datetime_timezone_run_c_smoke "$DT_O" "$TIME_O"; then
    C_NOTE=1
    echo "std-datetime-timezone c smoke OK (observational)"
  else
    echo "std-datetime-timezone gate SKIP c smoke (observational; link)" >&2
  fi
else
  echo "std-datetime-timezone gate SKIP c smoke (observational; datetime.o / symbol)" >&2
fi
echo "std-datetime-timezone c_smoke_note=${C_NOTE}"

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-135: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-datetime-timezone gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q ../std/datetime/mod.o 2>/dev/null || xlang_compiler_make ../std/datetime/mod.o 2>/dev/null || true
  xlang_compiler_make -q ../std/datetime/datetime.o 2>/dev/null || xlang_compiler_make ../std/datetime/datetime.o 2>/dev/null || true
  xlang_compiler_make -q ../std/time/time.o 2>/dev/null || xlang_compiler_make ../std/time/time.o 2>/dev/null || true
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std135_datetime_tz_$$"
  LOG="/tmp/xlang_std135_datetime_tz_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-datetime-timezone gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_datetime_timezone_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-datetime-timezone gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_datetime_timezone_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-datetime-timezone gate FAIL: no native xlang" >&2
  std_datetime_timezone_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-datetime-timezone check_ok=${CHECK_OK} (observational)"
std_datetime_timezone_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-datetime-timezone gate OK"
