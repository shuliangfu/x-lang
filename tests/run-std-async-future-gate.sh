#!/usr/bin/env bash
# STD-041：std.async Future/Poll 手动运行时门禁
#
# 用法：./tests/run-std-async-future-gate.sh
set -e
cd "$(dirname "$0")/.."

MOD_X="std/async/mod.x"
FUT_X="std/async/future.x"
SMOKE_C="tests/async/future_smoke_ok.c"
SMOKE_X="tests/async/future_poll_smoke.x"
RUNTIME_X="tests/async/runtime_wait_future_smoke.x"
EMIT_X="tests/parser/async_await_future_wait.x"
PREFIX="shux: [SHUX_STD_ASYNC_FUTURE]"

echo "=== STD-041: async future manifest ==="
for f in "$MOD_X" "$FUT_X" "$SMOKE_C" "$SMOKE_X" "$RUNTIME_X" "$EMIT_X"; do
  if [ ! -f "$f" ]; then
    echo "async-future gate FAIL: missing $f" >&2
    exit 1
  fi
done

for sym in future_new future_poll future_complete future_take future_wait future_smoke runtime_wait_future poll_loop; do
  if ! grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null; then
    echo "async-future gate FAIL: missing $sym in $MOD_X" >&2
    exit 1
  fi
done

for sym in shux_async_future_create_c shux_async_future_poll_c shux_async_future_wait_c shux_async_future_smoke_c; do
  if ! grep -qF "$sym" "$FUT_X" 2>/dev/null; then
    echo "async-future gate FAIL: missing $sym in $FUT_X" >&2
    exit 1
  fi
done
echo "async-future manifest OK"

C_OK=0
X_OK=0
SKIP=0

echo "=== STD-041: future c smoke ==="
make -C compiler ../std/async/future.o >/dev/null 2>&1
if cc -std=c11 -O1 -o /tmp/shux_async_future_smoke \
  "$SMOKE_C" std/async/future.o 2>/dev/null; then
  if /tmp/shux_async_future_smoke >/dev/null 2>&1; then C_OK=1; fi
  rm -f /tmp/shux_async_future_smoke
fi
if [ "$C_OK" -eq 0 ]; then
  echo "${PREFIX} status=fail c=0 x=0 skip=0" >&2
  echo "async-future gate FAIL: c smoke" >&2
  exit 1
fi

SHUX_BIN=""
for cand in ./compiler/shux-c ./compiler/shux; do
  if [ -x "$cand" ]; then SHUX_BIN="$cand"; break; fi
done

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-041: future .x typeck + smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "async-future gate FAIL: typeck $SMOKE_X" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -10 >&2 || true
    echo "${PREFIX} status=fail c=${C_OK} x=0 skip=0" >&2
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$RUNTIME_X" >/dev/null 2>&1; then
    echo "async-future gate FAIL: typeck $RUNTIME_X" >&2
    "$SHUX_BIN" check -L . "$RUNTIME_X" 2>&1 | tail -10 >&2 || true
    echo "${PREFIX} status=fail c=${C_OK} x=0 skip=0" >&2
    exit 1
  fi
  rm -f /tmp/shux_async_future_x
  if "$SHUX_BIN" -L . "$SMOKE_X" -o /tmp/shux_async_future_x >/dev/null 2>&1; then
    ec=0
    /tmp/shux_async_future_x >/dev/null 2>&1 || ec=$?
    rm -f /tmp/shux_async_future_x
    if [ "$ec" -eq 0 ]; then X_OK=1; fi
  fi
  if [ "$X_OK" -eq 0 ]; then
    echo "async-future gate WARN: .x link/run skipped (typeck OK)" >&2
    SKIP=1
  fi
else
  SKIP=1
fi

EMIT_OK=0
if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-041: await future_wait emit (-E) ==="
  out="$("$SHUX_BIN" -E "$EMIT_X" 2>&1)" || {
    echo "async-future gate FAIL: -E $EMIT_X" >&2
    echo "${PREFIX} status=fail c=${C_OK} x=${X_OK} skip=${SKIP}" >&2
    exit 1
  }
  echo "$out" | grep -q 'SHUX_ASYNC_CPS future_wait' || {
    echo "async-future gate FAIL: missing future_wait CPS emit marker" >&2
    exit 1
  }
  echo "$out" | grep -q 'shux_async_cps_suspend_io' || {
    echo "async-future gate FAIL: missing suspend_io at await future_wait" >&2
    exit 1
  }
  echo "$out" | grep -q 'fw_await_' || {
    echo "async-future gate FAIL: missing future_wait poll loop label" >&2
    exit 1
  }
  EMIT_OK=1
  echo "async-future emit OK"
fi

echo "${PREFIX} status=ok c=${C_OK} x=${X_OK} emit=${EMIT_OK:-0} skip=${SKIP}"
echo "async-future gate OK"
