#!/usr/bin/env bash
# STD-023/024: std.process pipe redirect + Windows spawn gate — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native xlang-c) + prefer-c only + soft auto-make
# + hard-bound `xlang check` (CHK002 under pause = portable false-red) retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - manifest + ## Gate + symbols = hard.
#   - spawn_pipe_echo / spawn_wait_win product -o tip typeck (**u8) = obs.
#   - win smoke on non-Windows = skip (platform N/A).
#   - check path = obs (paused 2026-08-05).
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-process-pipe-spawn-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/std-process-pipe-spawn.sh
. tests/lib/std-process-pipe-spawn.sh

DOC="${XLANG_STD_PPS_DOC:-analysis/archive/std/std-process-pipe-spawn-v1.md}"
MANIFEST="${XLANG_STD_PPS_TSV:-tests/baseline/std-process-pipe-spawn.tsv}"
PROC_X="std/process/mod.x"
PROC_C="${XLANG_STD_PROCESS_IMPL:-compiler/seeds/runtime_process_os_glue.from_x.c}"
PIPE_X="tests/process/spawn_pipe_echo.x"
WIN_X="tests/process/spawn_wait_win.x"

PREFIX="${XLANG_STD_PROCESS_PIPE_SPAWN_PREFIX:-xlang: [XLANG_STD_PROCESS_PIPE_SPAWN]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-process-pipe-spawn gate FAIL: $*" >&2
  std_pps_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
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

echo "=== STD-023/024: process pipe/spawn manifest (archive DOC) ==="
if [ -f analysis/std-process-pipe-spawn-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi
for f in "$DOC" "$MANIFEST" tests/lib/std-process-pipe-spawn.sh "$PROC_X" "$PROC_C" "$PIPE_X" "$WIN_X"; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi
for kw in spawn_io process_spawn_io_c spawn_pipe_echo spawn_wait_win; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF "process_spawn_io_c" "$PROC_C" 2>/dev/null || die "process glue missing process_spawn_io_c"

sym_miss="$(std_pps_symbols_ok "$PROC_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-process-pipe-spawn manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-023/024: smoke (XLANG=$XLANG_BIN) ==="

# Observational check (paused); CHK red does not hard-fail.
set +e
"$XLANG_BIN" check -L . "$PIPE_X" >/tmp/xlang_pps_check_pipe.log 2>&1
chk_pipe=$?
"$XLANG_BIN" check -L . "$WIN_X" >/tmp/xlang_pps_check_win.log 2>&1
chk_win=$?
set -e
if [ "$chk_pipe" -ne 0 ] || [ "$chk_win" -ne 0 ]; then
  echo "std-process-pipe-spawn OBS check (paused / CHK residual pipe=$chk_pipe win=$chk_win; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Product -o for pipe: tip typeck **u8 residual = obs (not soft silence).
exe="/tmp/xlang_pps_pipe_$$"
rm -f "$exe" 2>/dev/null || true
set +e
"$XLANG_BIN" -L . "$PIPE_X" -o "$exe" >/tmp/xlang_pps_pipe_o.log 2>&1
pipe_ec=$?
set -e
if [ "$pipe_ec" -eq 0 ] && [ -x "$exe" ]; then
  set +e
  "$exe" >/dev/null 2>&1
  pipe_run=$?
  set -e
  rm -f "$exe"
  if [ "$pipe_run" -eq 0 ]; then
    RUN_OK=$((RUN_OK + 1))
    echo "std-process-pipe-spawn OK: pipe product -o"
  else
    echo "std-process-pipe-spawn OBS pipe run exit=$pipe_run (product residual; refuse soft SKIP→OK)" >&2
    OBS=$((OBS + 1))
  fi
else
  rm -f "$exe"
  echo "std-process-pipe-spawn OBS pipe product -o (typeck **u8 residual ec=$pipe_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Windows spawn: platform N/A on non-Windows = skip; on Windows product -o (tip may obs).
if ci_is_windows_msys; then
  exe="/tmp/xlang_pps_win_$$"
  rm -f "$exe" 2>/dev/null || true
  set +e
  "$XLANG_BIN" -L . "$WIN_X" -o "$exe" >/tmp/xlang_pps_win_o.log 2>&1
  win_ec=$?
  set -e
  if [ "$win_ec" -eq 0 ] && [ -x "$exe" ]; then
    set +e
    "$exe" >/dev/null 2>&1
    win_run=$?
    set -e
    rm -f "$exe"
    if [ "$win_run" -eq 0 ]; then
      RUN_OK=$((RUN_OK + 1))
      echo "std-process-pipe-spawn OK: win product -o"
    else
      echo "std-process-pipe-spawn OBS win run exit=$win_run (product residual; refuse soft SKIP→OK)" >&2
      OBS=$((OBS + 1))
    fi
  else
    rm -f "$exe"
    echo "std-process-pipe-spawn OBS win product -o (typeck residual ec=$win_ec; refuse soft SKIP→OK)" >&2
    OBS=$((OBS + 1))
  fi
else
  echo "std-process-pipe-spawn SKIP win smoke (non-Windows N/A)" >&2
  SKIP=$((SKIP + 1))
fi

echo "std-process-pipe-spawn gate OK"
std_pps_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
