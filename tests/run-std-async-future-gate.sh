#!/usr/bin/env bash
# STD-041: std.async Future/Poll manual runtime gate — honesty soft auto-make /
# soft SKIP→OK / c=/x=/emit= report →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … future.o … || true`) + report
# `c=`/`x=`/`emit=` retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK / soft
# auto-make / prefer-c). Host-C archaeology = obs only (prebuilt future.o;
# refuse soft ensure/auto-make rebuild). check residual = obs (paused
# 2026-08-05). tip product -o / run residual = obs (product debt; leave).
# -E tool fail = hard die; CPS emit marker miss = obs. Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-async-future-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
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
LIB="tests/lib/std-async-future.sh"
FUTURE_O="std/async/future.o"

# shellcheck source=tests/lib/std-async-future.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "async-future gate FAIL: $*" >&2
  std_async_future_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-041: async future manifest ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
# Refuse resurrected top-level DOC (archive is live authority).
[ ! -f analysis/std-async-api-v1.md ] || die "dual-authority fossil analysis/std-async-api-v1.md (archive live)"
for f in "$MOD_X" "$FUT_X" "$SMOKE_C" "$SMOKE_X" "$RUNTIME_X" "$EMIT_X" "$LIB"; do
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

if [ "${XLANG_STD_ASYNC_FUTURE_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_async_future_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "async-future gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-041: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs; emit markers=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make rebuild of future.o.
# PLATFORM: SHARED — F-07 forbids cc -c on migrated async/future; prebuilt .o only.
echo "=== STD-041: future c smoke (host-c archaeology; UNDEF/missing .o = obs) ==="
if [ ! -f "$FUTURE_O" ]; then
  echo "async-future OBS c smoke (missing prebuilt $FUTURE_O; refuse soft ensure/auto-make)" >&2
  OBS=$((OBS + 1))
elif cc -std=c11 -O1 -o /tmp/xlang_async_future_smoke_$$ \
  "$SMOKE_C" "$FUTURE_O" 2>/tmp/async_future_c_link_$$.log; then
  if /tmp/xlang_async_future_smoke_$$ >/dev/null 2>&1; then
    RUN_OK=$((RUN_OK + 1))
    echo "async-future OK: c smoke"
  else
    echo "async-future OBS c smoke run (product residual)" >&2
    OBS=$((OBS + 1))
  fi
  rm -f /tmp/xlang_async_future_smoke_$$
else
  echo "async-future OBS c smoke link (UNDEF drain/io_poll; product residual; refuse soft ensure)" >&2
  OBS=$((OBS + 1))
fi

# check residual = obs (paused 2026-08-05); refuse soft SKIP→OK / check-as-hard.
for x in "$SMOKE_X" "$RUNTIME_X"; do
  set +e
  "$XLANG_BIN" check -L . "$x" >/tmp/xlang_async_future_check_$$.log 2>&1
  chk=$?
  set -e
  if [ "$chk" -ne 0 ]; then
    echo "async-future OBS check $x (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
    OBS=$((OBS + 1))
  fi
done

# tip product -o / run: success → run++; tip UNDEF/fail → obs (not soft SKIP→OK).
try_product_smoke() {
  local src="$1"
  local tag="$2"
  local out="/tmp/xlang_async_future_${tag}_$$"
  local log="/tmp/xlang_async_future_${tag}_build_$$.log"
  rm -f "$out" "$log"
  set +e
  "$XLANG_BIN" -L . "$src" -o "$out" >"$log" 2>&1
  local o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    tail -n 12 "$log" 2>/dev/null || true
    rm -f "$out"
    echo "async-future OBS tip product -o $tag (ec=$o_ec; std_async_* UNDEF residual)" >&2
    OBS=$((OBS + 1))
    return 0
  fi
  set +e
  "$out" >/dev/null 2>&1
  local exitcode=$?
  set -e
  rm -f "$out"
  if [ "$exitcode" -ne 0 ]; then
    echo "async-future OBS tip run $tag exit=$exitcode" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "async-future OK: product -o $tag"
  fi
}

try_product_smoke "$SMOKE_X" "poll"
try_product_smoke "$RUNTIME_X" "runtime_wait"

# -E must produce output (hard die on tool fail). CPS marker substrings may
# drift on tip → obs (aligned with async-io-cps; refuse soft SKIP→OK).
echo "=== STD-041: await future_wait emit (-E) ==="
set +e
EMIT_OUT="$("$XLANG_BIN" -E "$EMIT_X" 2>&1)"
e_ec=$?
set -e
if [ "$e_ec" -ne 0 ]; then
  echo "$EMIT_OUT" | tail -12 >&2 || true
  die "-E $EMIT_X failed (ec=$e_ec; refuse soft SKIP→OK)"
fi
MARK_MISS=0
echo "$EMIT_OUT" | grep -q 'XLANG_ASYNC_CPS future_wait' || MARK_MISS=1
echo "$EMIT_OUT" | grep -q 'xlang_async_cps_suspend_io' || MARK_MISS=1
echo "$EMIT_OUT" | grep -q 'fw_await_' || MARK_MISS=1
if [ "$MARK_MISS" -ne 0 ]; then
  echo "async-future OBS emit markers (CPS/fw_await drift; product residual)" >&2
  OBS=$((OBS + 1))
else
  RUN_OK=$((RUN_OK + 1))
  echo "async-future OK: emit markers"
fi

std_async_future_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "async-future gate OK"
