#!/usr/bin/env bash
# STD-090/093：std.async ↔ std.context 联动 + spawn 自动绑 Context 门禁
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

MOD_SX="std/async/mod.sx"
SCHED_C="compiler/src/asm/runtime_scheduler_glue.c"
SMOKE_CANCEL="tests/async/context_cancel_drain.sx"
SMOKE_SPAWN="tests/async/spawn_context_inherit.sx"
PREFIX="shux: [SHUX_STD090_ASYNC_CTX]"

stdlib_cm_native_shu() {
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

echo "=== STD-090/093: async-context manifest ==="
for f in "$MOD_SX" "$SCHED_C" "$SMOKE_CANCEL" "$SMOKE_SPAWN"; do
  if [ ! -f "$f" ]; then
    echo "async-context gate FAIL: missing $f" >&2
    exit 1
  fi
done
for sym in bind_context async_err_ctx_abort runtime_new runtime_reset runtime_drain \
           task_submit task_submit_with_context spawn_context_smoke \
           shux_async_bind_context_c shux_async_task_submit_with_ctx shux_async_spawn_ctx_smoke_c; do
  case "$sym" in
    shux_async_bind_context_c|shux_async_task_submit_with_ctx|shux_async_spawn_ctx_smoke_c)
      if ! grep -qF "$sym" "$SCHED_C" 2>/dev/null; then
        echo "async-context gate FAIL: missing $sym in runtime_scheduler_glue.c" >&2
        exit 1
      fi
      ;;
    *)
      if ! grep -qE "function ${sym}\\(" "$MOD_SX" 2>/dev/null; then
        echo "async-context gate FAIL: missing api $sym" >&2
        exit 1
      fi
      ;;
  esac
done
if ! grep -qF 'ctx_slots' "$SCHED_C" 2>/dev/null; then
  echo "async-context gate FAIL: missing ctx_slots in runtime_scheduler_glue.c" >&2
  exit 1
fi
echo "async-context manifest OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/async/scheduler.o
ensure_std_c_o ../std/context/context.o
ensure_std_c_o ../std/time/time.o
ensure_std_c_o ../std/task/task.o

echo "=== STD-093: C smoke ==="
if nm std/context/context.o 2>/dev/null | grep -qF 'ctx_background_c'; then
  make -C compiler runtime_time_os.o >/dev/null 2>&1 || true
  if ! cc -std=c11 -O1 -pthread -o /tmp/shux_std093_spawn_ctx_smoke \
    tests/async/spawn_context_smoke.c std/async/scheduler.o std/context/context.o std/time/time.o compiler/runtime_time_os.o 2>/dev/null; then
    echo "async-context gate FAIL: build spawn_context_smoke.c" >&2
    exit 1
  fi
  set +e
  /tmp/shux_std093_spawn_ctx_smoke >/dev/null 2>&1
  smoke_ec=$?
  set -e
  rm -f /tmp/shux_std093_spawn_ctx_smoke
  if [ "$smoke_ec" -ne 0 ]; then
    echo "async-context gate FAIL: spawn_context_smoke.c exit=${smoke_ec}" >&2
    exit 1
  fi
  echo "async-context C smoke OK"
else
  echo "async-context gate SKIP C smoke (context.o missing ctx_background_c; need shux-c)" >&2
fi

SHUX_BIN=""
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
fi

SX_OK=0
SKIP=0
if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-090/093: smoke (SHUX=$SHUX_BIN) ==="
  for sx in "$SMOKE_CANCEL" "$SMOKE_SPAWN"; do
    if ! "$SHUX_BIN" check -L . "$sx" >/dev/null 2>&1; then
      echo "async-context gate FAIL: typeck $sx" >&2
      exit 1
    fi
  done
  if [ "$SMOKE_CANCEL" != "" ]; then
    exe="/tmp/shux_std090_async_ctx_$$"
    if ! "$SHUX_BIN" -L . "$SMOKE_CANCEL" -o "$exe" >/dev/null 2>&1; then
      echo "async-context gate FAIL: compile $SMOKE_CANCEL" >&2
      exit 1
    fi
    set +e
    "$exe" >/dev/null 2>&1
    ec=$?
    set -e
    rm -f "$exe"
    if [ "$ec" -ne 0 ]; then
      echo "async-context gate FAIL: run $SMOKE_CANCEL exit=$ec" >&2
      exit 1
    fi
  fi
  SX_OK=1
else
  echo "async-context gate SKIP .sx (no native shux)" >&2
  SKIP=1
fi

echo "${PREFIX} status=ok sx=${SX_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "std-async-context gate OK"
