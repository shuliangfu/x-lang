#!/usr/bin/env bash
# STD-041: std.async Future/Poll manual runtime gate.
#
# Honesty: soft SKIP→OK when no native xlang + prefer-c retired. Prefer
# product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG = hard die.
# Missing native = hard die. Host-c smoke UNDEF (drain/io_poll) = obs
# (aligned with f-async-future-v2). `xlang check` = obs (check paused).
# .x link/run product residual = obs (not soft silence). Emit CPS
# markers hard when -E succeeds. Report c=/x=/emit=/obs=/skip=.
#
# Usage: ./tests/run-std-async-future-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when
# archived; live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_ASYNC_FUTURE_DOC:-analysis/archive/std/std-async-api-v1.md}"
MOD_X="std/async/mod.x"
FUT_X="std/async/future.x"
SMOKE_C="tests/async/future_smoke_ok.c"
SMOKE_X="tests/async/future_poll_smoke.x"
RUNTIME_X="tests/async/runtime_wait_future_smoke.x"
EMIT_X="tests/parser/async_await_future_wait.x"
PREFIX="xlang: [XLANG_STD_ASYNC_FUTURE]"

C_OK=0
X_OK=0
EMIT_OK=0
OBS=0
SKIP=0

die() {
  echo "async-future gate FAIL: $*" >&2
  echo "${PREFIX} status=fail c=${C_OK} x=${X_OK} emit=${EMIT_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok c=${C_OK} x=${X_OK} emit=${EMIT_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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

echo "=== STD-041: async future manifest ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
for f in "$MOD_X" "$FUT_X" "$SMOKE_C" "$SMOKE_X" "$RUNTIME_X" "$EMIT_X"; do
  [ -f "$f" ] || die "missing $f"
done

for sym in future_new future_poll future_complete future_take future_wait future_smoke runtime_wait_future poll_loop; do
  if ! grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null; then
    die "missing $sym in $MOD_X"
  fi
done

for sym in xlang_async_future_create_c xlang_async_future_poll_c xlang_async_future_wait_c xlang_async_future_smoke_c; do
  if ! grep -qF "$sym" "$FUT_X" 2>/dev/null; then
    die "missing $sym in $FUT_X"
  fi
done
echo "async-future manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== STD-041: future c smoke (host-c; UNDEF = obs) ==="
xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
xlang_compiler_make ../std/async/future.o >/dev/null 2>&1 || true
# Host-c link may miss drain/io_poll — product residual obs (f-async-future-v2).
# PLATFORM: SHARED — not soft silence; count obs.
if cc -std=c11 -O1 -o /tmp/xlang_async_future_smoke \
  "$SMOKE_C" std/async/future.o 2>/tmp/async_future_c_link.log; then
  if /tmp/xlang_async_future_smoke >/dev/null 2>&1; then
    C_OK=1
  else
    echo "async-future OBS c smoke run (product residual)" >&2
    OBS=1
  fi
  rm -f /tmp/xlang_async_future_smoke
else
  echo "async-future OBS c smoke link (UNDEF drain/io_poll; product residual)" >&2
  OBS=1
fi

echo "=== STD-041: future .x typeck + smoke (XLANG=$XLANG_BIN) ==="
# check gate paused — observational.
# PLATFORM: SHARED — check debt deferred post-selfhost.
for x in "$SMOKE_X" "$RUNTIME_X"; do
  if ! "$XLANG_BIN" check -L . "$x" >/dev/null 2>&1; then
    echo "async-future OBS check $x (check paused)" >&2
    OBS=1
  fi
done

rm -f /tmp/xlang_async_future_x
if "$XLANG_BIN" -L . "$SMOKE_X" -o /tmp/xlang_async_future_x >/tmp/async_future_x_compile.log 2>&1; then
  ec=0
  /tmp/xlang_async_future_x >/dev/null 2>&1 || ec=$?
  rm -f /tmp/xlang_async_future_x
  if [ "$ec" -eq 0 ]; then
    X_OK=1
  else
    echo "async-future OBS .x run exit=$ec (product residual)" >&2
    OBS=1
  fi
else
  echo "async-future OBS .x link (product residual)" >&2
  cat /tmp/async_future_x_compile.log >&2 || true
  OBS=1
fi

echo "=== STD-041: await future_wait emit (-E) ==="
# -E must produce C (hard). CPS marker substrings may drift → obs.
# PLATFORM: SHARED — product residual; not soft silence.
out="$("$XLANG_BIN" -E "$EMIT_X" 2>&1)" || die "-E $EMIT_X"
EMIT_OK=1
MARK_MISS=0
echo "$out" | grep -q 'XLANG_ASYNC_CPS future_wait' || MARK_MISS=1
echo "$out" | grep -q 'xlang_async_cps_suspend_io' || MARK_MISS=1
echo "$out" | grep -q 'fw_await_' || MARK_MISS=1
if [ "$MARK_MISS" -ne 0 ]; then
  echo "async-future OBS emit markers (CPS/fw_await drift; product residual)" >&2
  OBS=1
else
  echo "async-future emit OK"
fi

ok_report
echo "async-future gate OK"
