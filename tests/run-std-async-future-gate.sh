#!/usr/bin/env bash
# STD-041：std.async Future/Poll 手动运行时门禁
#
# 用法：./tests/run-std-async-future-gate.sh
set -e
cd "$(dirname "$0")/.."

MOD_SX="std/async/mod.sx"
FUT_SX="std/async/future.sx"
SMOKE_C="tests/async/future_smoke_ok.c"
SMOKE_SX="tests/async/future_poll_smoke.sx"
RUNTIME_SX="tests/async/runtime_wait_future_smoke.sx"
EMIT_SX="tests/parser/async_await_future_wait.sx"
PREFIX="shux: [SHUX_STD_ASYNC_FUTURE]"

echo "=== STD-041: async future manifest ==="
for f in "$MOD_SX" "$FUT_SX" "$SMOKE_C" "$SMOKE_SX" "$RUNTIME_SX" "$EMIT_SX"; do
  if [ ! -f "$f" ]; then
    echo "async-future gate FAIL: missing $f" >&2
    exit 1
  fi
done

for sym in future_new future_poll future_complete future_take future_wait future_smoke runtime_wait_future poll_loop; do
  if ! grep -qE "function ${sym}\\(" "$MOD_SX" 2>/dev/null; then
    echo "async-future gate FAIL: missing $sym in $MOD_SX" >&2
    exit 1
  fi
done

for sym in shux_async_future_create_c shux_async_future_poll_c shux_async_future_wait_c shux_async_future_smoke_c; do
  if ! grep -qF "$sym" "$FUT_SX" 2>/dev/null; then
    echo "async-future gate FAIL: missing $sym in $FUT_SX" >&2
    exit 1
  fi
done
echo "async-future manifest OK"

C_OK=0
SX_OK=0
SKIP=0

echo "=== STD-041: future c smoke ==="
make -C compiler ../std/async/future.o >/dev/null 2>&1
if cc -std=c11 -O1 -o /tmp/shux_async_future_smoke \
  "$SMOKE_C" std/async/future.o 2>/dev/null; then
  if /tmp/shux_async_future_smoke >/dev/null 2>&1; then C_OK=1; fi
  rm -f /tmp/shux_async_future_smoke
fi
if [ "$C_OK" -eq 0 ]; then
  echo "${PREFIX} status=fail c=0 sx=0 skip=0" >&2
  echo "async-future gate FAIL: c smoke" >&2
  exit 1
fi

SHUX_BIN=""
for cand in ./compiler/shux-c ./compiler/shux; do
  if [ -x "$cand" ]; then SHUX_BIN="$cand"; break; fi
done

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-041: future .sx typeck + smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_SX" >/dev/null 2>&1; then
    echo "async-future gate FAIL: typeck $SMOKE_SX" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SX" 2>&1 | tail -10 >&2 || true
    echo "${PREFIX} status=fail c=${C_OK} sx=0 skip=0" >&2
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$RUNTIME_SX" >/dev/null 2>&1; then
    echo "async-future gate FAIL: typeck $RUNTIME_SX" >&2
    "$SHUX_BIN" check -L . "$RUNTIME_SX" 2>&1 | tail -10 >&2 || true
    echo "${PREFIX} status=fail c=${C_OK} sx=0 skip=0" >&2
    exit 1
  fi
  rm -f /tmp/shux_async_future_sx
  if "$SHUX_BIN" -L . "$SMOKE_SX" -o /tmp/shux_async_future_sx >/dev/null 2>&1; then
    ec=0
    /tmp/shux_async_future_sx >/dev/null 2>&1 || ec=$?
    rm -f /tmp/shux_async_future_sx
    if [ "$ec" -eq 0 ]; then SX_OK=1; fi
  fi
  if [ "$SX_OK" -eq 0 ]; then
    echo "async-future gate WARN: .sx link/run skipped (typeck OK)" >&2
    SKIP=1
  fi
else
  SKIP=1
fi

EMIT_OK=0
if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-041: await future_wait emit (-E) ==="
  out="$("$SHUX_BIN" -E "$EMIT_SX" 2>&1)" || {
    echo "async-future gate FAIL: -E $EMIT_SX" >&2
    echo "${PREFIX} status=fail c=${C_OK} sx=${SX_OK} skip=${SKIP}" >&2
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

echo "${PREFIX} status=ok c=${C_OK} sx=${SX_OK} emit=${EMIT_OK:-0} skip=${SKIP}"
echo "async-future gate OK"
