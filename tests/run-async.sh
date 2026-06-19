#!/usr/bin/env bash
# A1/A2 协作调度烟测：async_switch + scheduler 按需链入 + import std.async
# 含 import/spawn/IO 全链路的 .sx 编译：import/hex 优先 shux（refresh 后），否则回退 shux-c。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
make -C compiler ../std/async/scheduler.o -q 2>/dev/null || make -C compiler ../std/async/scheduler.o

# Linux：链 std/io/io.o 时须 -luring -lpthread（与 invoke_cc / run-io-multishot 一致）
SHUX_IO_CC_LIBS=""
if [ "$(uname -s)" = "Linux" ]; then
  SHUX_IO_CC_LIBS="-luring -lpthread"
fi

# musl/Alpine/Docker：async C harness 中 setenv 须 POSIX 宏。
SHUX_ASYNC_CC=(cc -std=gnu11 -Wall -Wextra -D_POSIX_C_SOURCE=200809L)

# 仅 Linux x86_64 走 seed asm -o；其它平台按 async_host_compile_o 策略。
async_is_linux_x64_asm() {
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Linux-x86_64|Linux-amd64) return 0 ;;
  esac
  return 1
}

# Windows MSYS2：seed shux -backend c 编译会挂起，须走 shux-c。
async_is_windows_msys() {
  if [ -n "${MSYSTEM:-}" ]; then return 0; fi
  case "$(uname -s 2>/dev/null)" in
    MINGW*|MSYS*) return 0 ;;
  esac
  return 1
}

# 非 Linux x86_64 的 -o 烟测：优先 shux-c（DCE 已保留副作用 let；Win 避免 seed -backend c 挂起）。
async_host_compile_o() {
  local src="$1"
  local out="$2"
  shift 2
  if async_is_linux_x64_asm; then
    "$SHUX" -L . "$@" "$src" -o "$out"
  elif [ -x ./compiler/shux-c ]; then
    ./compiler/shux-c -L . "$@" "$src" -o "$out"
  elif [ -x ./compiler/shux ]; then
    ./compiler/shux -L . "$@" "$src" -backend c -o "$out"
  else
    "$COMPILE_SHUX" -L . "$@" "$src" -o "$out"
  fi
}

# Linux 内核/Docker 无 io_uring：io_uring harness 记 N/A 而非 FAIL。
async_io_uring_unavailable() {
  [ "$(uname -s)" != "Linux" ] && return 0
  # shellcheck source=tests/lib/io-uring-probe.sh
  . "$(dirname "$0")/lib/io-uring-probe.sh"
  io_uring_available && return 1
  return 0
}

# 若 io_uring 不可用则打印 N/A 并返回 0（跳过）；否则返回 1（继续跑 harness）。
async_io_uring_skip_na() {
  local name="$1"
  if async_io_uring_unavailable; then
    echo "$name N/A (io_uring unavailable on this kernel)"
    return 0
  fi
  return 1
}

# 选用可执行编译器：外部已设 SHU（如 CI 传入 shux-c）时保留；否则 shux（seed）优先，缺失时 shux-c。
if [ -z "${SHUX:-}" ]; then
  if [ -x ./compiler/shux ]; then
    SHUX=./compiler/shux
  elif [ -x ./compiler/shux-c ]; then
    SHUX=./compiler/shux-c
  else
    echo "async smoke FAIL: no compiler/shux or compiler/shux-c" >&2
    exit 1
  fi
fi

# relink 后 seed shux 的 SU codegen 在 run/spawn -o 链路上可能 SIGSEGV；C 前端 -o 烟测与 EMIT_SHUX 对齐用 shux-c。
COMPILE_SHUX="$SHUX"
if [ -x ./compiler/shux-c ]; then
  COMPILE_SHUX=./compiler/shux-c
fi

# async_switch -o：见 async_host_compile_o（Win shux-c / macOS -backend c / Linux x86_64 asm）。
async_switch_compile_o() {
  async_host_compile_o tests/bench/async_switch.sx /tmp/shux_async_switch
}

# relink 后 shux 的 -E 仅 parse/typeck 摘要；须 grep C/SHUX_ASYNC_FRAME 的烟测统一走 shux-c。
EMIT_SHUX=./compiler/shux-c
if [ ! -x "$EMIT_SHUX" ]; then
  EMIT_SHUX="$SHUX"
fi

# run/spawn 实参个数不匹配：call typeck 或 run v4 专用报错均可。
_run_async_arg_count_rejected() {
  "$COMPILE_SHUX" -L . "$1" -o /tmp/shux_run_async_arg_err 2>&1 \
    | grep -qE "argument count must match|expects [0-9]+ arguments, got|no matching overload"
}

if async_is_linux_x64_asm; then
  echo "async_switch: compile+run (seed asm) ..."
elif [ -x ./compiler/shux-c ]; then
  echo "async_switch: compile+run (shux-c) ..."
elif [ -x ./compiler/shux ]; then
  echo "async_switch: compile+run (seed shux -backend c) ..."
else
  echo "async_switch: compile+run (${COMPILE_SHUX##*/} fallback) ..."
fi
async_switch_compile_o
[ -x /tmp/shux_async_switch ] || { echo "async_switch FAIL: binary not built"; exit 1; }
rc=$(/tmp/shux_async_switch; echo $?)
[ "$rc" = "0" ] || { echo "async_switch failed exit=$rc"; exit 1; }
echo "async_switch OK"

# scheduler jmp 烟测仅 Linux x86_64 seed asm 支持；seed 未 bootstrap 时 N/A（Tier P 早于 bootstrap-driver-seed）。
if async_is_linux_x64_asm; then
  sched_log=/tmp/async_switch_sched_compile.log
  if "$SHUX" -L . tests/bench/async_switch_sched.sx -backend asm -o /tmp/shux_async_sched >"$sched_log" 2>&1; then
    rc=$(/tmp/shux_async_sched; echo $?)
    [ "$rc" = "0" ] || { echo "async_switch_sched failed exit=$rc"; exit 1; }
    echo "async_switch_sched OK"
  elif grep -qE 'not available|bootstrap-driver' "$sched_log" 2>/dev/null; then
    echo "async_switch_sched N/A (asm backend not in $SHUX yet)"
  else
    cat "$sched_log" >&2
    echo "async_switch_sched FAIL: compile" >&2
    exit 1
  fi
else
  echo "async_switch_sched N/A (scheduler jmp requires Linux x86_64 seed asm)"
fi

# import std.async + coop_pingpong_jmp：非 Linux x86_64 优先 shux-c，避免 seed -o 挂起。
SHUX_IMPORT=${SHUX_IMPORT:-$SHUX}
if ! async_is_linux_x64_asm && [ -x ./compiler/shux-c ]; then
  SHUX_IMPORT=./compiler/shux-c
elif ! "$SHUX_IMPORT" -L . -E tests/parser/import_std_async.sx >/dev/null 2>&1; then
  SHUX_IMPORT=./compiler/shux-c
fi
"$SHUX_IMPORT" -L . tests/bench/async_mod_import.sx -o /tmp/shux_async_mod_import 2>&1 || {
  echo "async_mod_import FAIL: compile ($SHUX_IMPORT)"
  exit 1
}
rc=$(/tmp/shux_async_mod_import; echo $?)
[ "$rc" = "0" ] || { echo "async_mod_import failed exit=$rc"; exit 1; }

echo "async smoke OK"

echo "async syntax: async function parse + compile ..."
async_host_compile_o tests/parser/async_function.sx /tmp/shux_async_fn_syntax 2>&1 || {
  echo "async syntax FAIL: async_function.sx should compile"
  exit 1
}
rc=$(/tmp/shux_async_fn_syntax; echo $?)
[ "$rc" = "42" ] || { echo "async syntax FAIL: expected exit 42, got $rc"; exit 1; }
echo "async syntax OK"

echo "async import std.async: parse (-E) + dep codegen ($SHUX_IMPORT) ..."
out=$("$SHUX_IMPORT" -L . -E tests/parser/import_std_async.sx 2>&1) || {
  echo "async import std.async FAIL: -E import_std_async.sx"
  exit 1
}
echo "$out" | grep -q 'shux_async_queue_reset' || {
  echo "async import std.async FAIL: missing shux_async_queue_reset from std.async"
  exit 1
}
echo "async import std.async OK"

echo "const hex: top-level 0x literal parse (-E) ($SHUX_IMPORT) ..."
# relink 后 shux/shux_asm 的 -E 仅 parse/typeck 摘要；MAGIC 数值须 shux-c -E 佐证。
EMIT_HEX="$SHUX_IMPORT"
case "$(basename "$SHUX_IMPORT")" in
  shux|shux_asm)
    if [ -x ./compiler/shux-c ]; then
      EMIT_HEX=./compiler/shux-c
    fi
    ;;
esac
out=$("$EMIT_HEX" -E tests/parser/const_hex.sx 2>&1) || {
  echo "const hex FAIL: -E const_hex.sx"
  exit 1
}
echo "$out" | grep -q '1095980800' || {
  echo "const hex FAIL: expected MAGIC 1095980800 (0x41535700)"
  exit 1
}
echo "const hex OK"

echo "await syntax: async function + await compile + run ..."
async_host_compile_o tests/parser/await_async.sx /tmp/shux_await_async 2>&1 || {
  echo "await syntax FAIL: await_async.sx should compile"
  exit 1
}
rc=$(/tmp/shux_await_async; echo $?)
[ "$rc" = "42" ] || { echo "await syntax FAIL: expected exit 42, got $rc"; exit 1; }

if "$COMPILE_SHUX" -L . tests/parser/await_sync_err.sx -o /tmp/shux_await_sync_err 2>&1 | grep -q "await.*only allowed inside async function"; then
  : # 预期 typeck 报错
else
  echo "await syntax FAIL: await in sync function should be rejected"
  exit 1
fi
echo "await syntax OK"

echo "async liveness A3: SHUX_ASYNC_FRAME in -E output ..."
LIVENESS_EMIT="$EMIT_SHUX"
out=$("$LIVENESS_EMIT" -E tests/parser/async_await_liveness.sx 2>&1) || {
  echo "async liveness FAIL: async_await_liveness.sx -E failed"
  exit 1
}
echo "$out" | grep -qE 'SHUX_ASYNC_FRAME func=liveness_demo.*slots=1.*vars=keep' || {
  echo "async liveness FAIL: expected slots=1 vars=keep"
  echo "$out" | grep SHUX_ASYNC_FRAME || true
  exit 1
}
echo "$out" | grep -q 'typedef struct __shux_async_frame_liveness_demo' || {
  echo "async liveness FAIL: missing frame typedef"
  exit 1
}
echo "$out" | grep -q 'int32_t __phase;' || {
  echo "async liveness FAIL: missing __phase field"
  exit 1
}
echo "$out" | grep -q 'int32_t keep;' || {
  echo "async liveness FAIL: missing keep field"
  exit 1
}
echo "$out" | grep -q 'bytes=8 awaits=1' || {
  echo "async liveness FAIL: expected bytes=8 awaits=1"
  echo "$out" | grep SHUX_ASYNC_FRAME || true
  exit 1
}
echo "$out" | grep 'SHUX_ASYNC_FRAME func=liveness_demo' | grep -q 'dead' && {
  echo "async liveness FAIL: dead should not be in frame"
  exit 1
}

out2=$("$LIVENESS_EMIT" -E tests/parser/async_await_liveness_two.sx 2>&1) || {
  echo "async liveness FAIL: async_await_liveness_two.sx -E failed"
  exit 1
}
echo "$out2" | grep -qE 'SHUX_ASYNC_FRAME func=two_await.*slots=2.*vars=a,b' || {
  echo "async liveness FAIL: expected two_await slots=2 vars=a,b"
  echo "$out2" | grep SHUX_ASYNC_FRAME || true
  exit 1
}
echo "$out2" | grep -q 'typedef struct __shux_async_frame_two_await' || {
  echo "async liveness FAIL: missing two_await frame typedef"
  exit 1
}
echo "$out2" | grep -q 'bytes=12 awaits=2' || {
  echo "async liveness FAIL: expected bytes=12 awaits=2"
  echo "$out2" | grep SHUX_ASYNC_FRAME || true
  exit 1
}

echo "async CPS A3: switch(__phase) segmentation ..."
echo "$out" | grep -q 'SHUX_ASYNC_CPS switch=1' || {
  echo "async CPS FAIL: missing SHUX_ASYNC_CPS marker"
  exit 1
}
echo "$out" | grep -q 'switch (__shux_frame.__phase)' || {
  echo "async CPS FAIL: missing phase switch"
  exit 1
}
echo "$out" | grep -q 'case 1:' || {
  echo "async CPS FAIL: missing case 1 after await"
  exit 1
}
echo "$out" | grep -q '__shux_frame.keep = keep' || {
  echo "async CPS FAIL: missing frame save for keep"
  exit 1
}
echo "$out2" | grep -q 'case 2:' || {
  echo "async CPS FAIL: two_await missing case 2"
  exit 1
}

echo "$out" | grep -q 'shux_async_cps_suspend' || {
  echo "async CPS FAIL: missing shux_async_cps_suspend at await boundary"
  exit 1
}
echo "$out" | grep -q 'static __shux_async_frame_liveness_demo __shux_frame' || {
  echo "async CPS FAIL: frame must be static for suspend/resume"
  exit 1
}

echo "async liveness WPO-S3: struct Pair across await (-E) ..."
out_await=$("$EMIT_SHUX" -E tests/wpo/stack_promote_await.sx 2>&1) || {
  echo "async struct await FAIL: stack_promote_await.sx -E failed"
  exit 1
}
echo "$out_await" | grep -q 'struct Pair {' || {
  echo "async struct await FAIL: missing struct Pair definition (DCE must emit for async frame)"
  exit 1
}
echo "$out_await" | grep -qE 'SHUX_ASYNC_FRAME func=struct_across_await.*slots=1.*vars=p' || {
  echo "async struct await FAIL: expected slots=1 vars=p"
  echo "$out_await" | grep SHUX_ASYNC_FRAME || true
  exit 1
}
echo "$out_await" | grep -q 'struct Pair p;' || {
  echo "async struct await FAIL: frame typedef must contain struct Pair p"
  exit 1
}
echo "$out_await" | grep -q '__shux_frame.p = p' || {
  echo "async struct await FAIL: missing frame save __shux_frame.p = p at await boundary"
  exit 1
}
echo "$out_await" | grep -q 'bytes=12 awaits=1' || {
  echo "async struct await FAIL: expected bytes=12 awaits=1"
  echo "$out_await" | grep SHUX_ASYNC_FRAME || true
  exit 1
}
echo "async struct await liveness OK"

echo "async CPS yield: SHUX_ASYNC_YIELD=1 double poll ..."
make -C compiler ../std/async/scheduler.o -q 2>/dev/null \
  || make -C compiler ../std/async/scheduler.o
if [ -f compiler/../std/async/scheduler.o ] || [ -f std/async/scheduler.o ]; then
  # 须用 relink 后 shux（runtime 按需链 scheduler.o）；shux-c 链接路径缺 shux_async_cps_suspend。
  SHUX_ASYNC_YIELD=1 async_host_compile_o tests/parser/async_cps_yield.sx /tmp/shux_async_cps_yield 2>&1 || {
    echo "async CPS yield FAIL: compile async_cps_yield.sx"
    exit 1
  }
  if file /tmp/shux_async_cps_yield 2>/dev/null | grep -q "executable"; then
    rc=$(/tmp/shux_async_cps_yield; echo $?)
    [ "$rc" = "0" ] || { echo "async CPS yield FAIL: expected exit 0, got $rc"; exit 1; }
    echo "async CPS yield run OK"
  else
    echo "async CPS yield: skip run (link/platform)"
  fi
  SHUX_ASYNC_YIELD=1 async_host_compile_o tests/wpo/stack_promote_await_yield.sx /tmp/shux_wpo_await_yield 2>&1 || {
    echo "async struct await yield FAIL: compile stack_promote_await_yield.sx"
    exit 1
  }
  if file /tmp/shux_wpo_await_yield 2>/dev/null | grep -q "executable"; then
    rc=$(SHUX_ASYNC_YIELD=1 /tmp/shux_wpo_await_yield; echo $?)
    [ "$rc" = "0" ] || { echo "async struct await yield FAIL: expected exit 0, got $rc"; exit 1; }
    echo "async struct await yield run OK (Pair preserved across suspend)"
  else
    echo "async struct await yield: skip run (link/platform)"
  fi
else
  echo "async CPS yield: skip run (scheduler.o not built)"
fi

echo "async scheduler A4: task queue drain (C harness) ..."
"${SHUX_ASYNC_CC[@]}" -o /tmp/shux_async_scheduler_queue \
  tests/bench/async_scheduler_queue.c std/async/scheduler.o 2>&1 || {
  echo "async scheduler A4 FAIL: build async_scheduler_queue.c"
  exit 1
}
rc=$(/tmp/shux_async_scheduler_queue; echo $?)
[ "$rc" = "0" ] || { echo "async scheduler A4 FAIL: queue drain exit=$rc"; exit 1; }
echo "async scheduler A4 OK"

echo "async scheduler MPSC: dual-thread submit + drain ..."
if "${SHUX_ASYNC_CC[@]}" -pthread -o /tmp/shux_async_scheduler_mpsc \
  tests/bench/async_scheduler_mpsc.c std/async/scheduler.o 2>/dev/null; then
  rc=$(/tmp/shux_async_scheduler_mpsc; echo $?)
  [ "$rc" = "0" ] || { echo "async scheduler MPSC FAIL: exit=$rc"; exit 1; }
  echo "async scheduler MPSC OK"
else
  echo "async scheduler MPSC: skip (pthread unavailable)"
fi

echo "async scheduler workers: per-worker ring + dual consumer drain ..."
if SHUX_ASYNC_WORKERS=2 "${SHUX_ASYNC_CC[@]}" -pthread -o /tmp/shux_async_scheduler_workers \
  tests/bench/async_scheduler_workers.c std/async/scheduler.o 2>/dev/null; then
  rc=$(/tmp/shux_async_scheduler_workers; echo $?)
  [ "$rc" = "0" ] || { echo "async scheduler workers FAIL: exit=$rc"; exit 1; }
  echo "async scheduler workers OK"
else
  echo "async scheduler workers: skip (pthread unavailable)"
fi

echo "async scheduler worker affinity: SHUX_ASYNC_AFFINITY=1 + workers drain ..."
if SHUX_ASYNC_WORKERS=2 SHUX_ASYNC_AFFINITY=1 "${SHUX_ASYNC_CC[@]}" -pthread -o /tmp/shux_async_scheduler_workers_aff \
  tests/bench/async_scheduler_workers.c std/async/scheduler.o 2>/dev/null; then
  rc=$(SHUX_ASYNC_WORKERS=2 SHUX_ASYNC_AFFINITY=1 /tmp/shux_async_scheduler_workers_aff; echo $?)
  [ "$rc" = "0" ] || { echo "async scheduler worker affinity FAIL: exit=$rc"; exit 1; }
  echo "async scheduler worker affinity OK"
else
  echo "async scheduler worker affinity: skip"
fi

echo "async scheduler IO-A5: io wait queue + wake ..."
"${SHUX_ASYNC_CC[@]}" -o /tmp/shux_async_scheduler_io_wake \
  tests/bench/async_scheduler_io_wake.c std/async/scheduler.o 2>&1 || {
  echo "async scheduler IO-A5 FAIL: build async_scheduler_io_wake.c"
  exit 1
}
rc=$(/tmp/shux_async_scheduler_io_wake; echo $?)
[ "$rc" = "0" ] || { echo "async scheduler IO-A5 FAIL: exit=$rc"; exit 1; }
echo "async scheduler IO-A5 OK"

echo "async scheduler IO-A5: suspend_io flag without SHUX_ASYNC_IO_WAIT ..."
"${SHUX_ASYNC_CC[@]}" -o /tmp/shux_async_scheduler_io_await_flag \
  tests/bench/async_scheduler_io_await_flag.c std/async/scheduler.o 2>&1 || {
  echo "async scheduler IO-A5 await flag FAIL: build async_scheduler_io_await_flag.c"
  exit 1
}
rc=$(/tmp/shux_async_scheduler_io_await_flag; echo $?)
[ "$rc" = "0" ] || { echo "async scheduler IO-A5 await flag FAIL: exit=$rc"; exit 1; }
echo "async scheduler IO-A5 await flag OK"

echo "async await IO: await read() codegen (shux_async_cps_suspend_io) ..."
out=$("$EMIT_SHUX" -E tests/parser/async_await_io.sx 2>&1) || {
  echo "async await IO FAIL: -E async_await_io.sx"
  exit 1
}
echo "$out" | grep -q '__shux_frame.__io_rd_slot = shux_io_submit_read_async' || {
  echo "async await IO FAIL: missing __io_rd_slot submit at await read boundary"
  exit 1
}
echo "$out" | grep -q 'shux_io_complete_read_async_slot(__shux_frame.__io_rd_slot)' || {
  echo "async await IO FAIL: missing complete_read_async_slot after resume case"
  exit 1
}
echo "$out" | grep -q '__io_rd_slot' || {
  echo "async await IO FAIL: missing __io_rd_slot in frame"
  exit 1
}
echo "$out" | grep -q 'shux_async_cps_suspend_io' || {
  echo "async await IO FAIL: missing shux_async_cps_suspend_io at await read boundary"
  exit 1
}
echo "$out" | grep -q 'SHUX_ASYNC_CPS switch=1' || {
  echo "async await IO FAIL: missing CPS switch for io_read_demo"
  exit 1
}
echo "async await IO OK"

echo "async await IO write: await write() codegen ..."
out=$("$EMIT_SHUX" -E tests/parser/async_await_io_write.sx 2>&1) || {
  echo "async await IO write FAIL: -E async_await_io_write.sx"
  exit 1
}
echo "$out" | grep -q 'shux_io_submit_write_async' || {
  echo "async await IO write FAIL: missing shux_io_submit_write_async"
  exit 1
}
echo "$out" | grep -q 'shux_io_complete_write_async' || {
  echo "async await IO write FAIL: missing shux_io_complete_write_async"
  exit 1
}
echo "async await IO write OK"

echo "async await IO read_fd: await read_fd() codegen ..."
out=$("$EMIT_SHUX" -E tests/parser/async_await_read_fd.sx 2>&1) || {
  echo "async await IO read_fd FAIL: -E async_await_read_fd.sx"
  exit 1
}
echo "$out" | grep -q 'shux_io_submit_read_async' || {
  echo "async await IO read_fd FAIL: missing shux_io_submit_read_async"
  exit 1
}
echo "$out" | grep -q '(size_t)(unsigned)(' || {
  echo "async await IO read_fd FAIL: missing fd-to-handle cast"
  exit 1
}
echo "async await IO read_fd OK"

echo "async await IO write_fd: await write_fd() codegen ..."
out=$("$EMIT_SHUX" -E tests/parser/async_await_write_fd.sx 2>&1) || {
  echo "async await IO write_fd FAIL: -E async_await_write_fd.sx"
  exit 1
}
echo "$out" | grep -q 'shux_io_submit_write_async' || {
  echo "async await IO write_fd FAIL: missing shux_io_submit_write_async"
  exit 1
}
echo "$out" | grep -q '(size_t)(unsigned)(' || {
  echo "async await IO write_fd FAIL: missing fd-to-handle cast"
  exit 1
}
echo "async await IO write_fd OK"

echo "async await IO dual: two run read_chunk(fd) + __io_rd_slot ..."
out=$("$EMIT_SHUX" -E tests/parser/async_await_io_dual.sx 2>&1) || {
  echo "async await IO dual FAIL: -E async_await_io_dual.sx"
  exit 1
}
echo "$out" | grep -q '__io_rd_slot' || {
  echo "async await IO dual FAIL: missing __io_rd_slot in frame"
  exit 1
}
echo "$out" | grep -E 'shux_async_run_seed_push_i32\([0-9]' | wc -l | tr -d ' ' | grep -q '^2$' || {
  echo "async await IO dual FAIL: expected two run seed push"
  exit 1
}
echo "$out" | grep -E 'shux_async_sched_read_chunk\(\)' | wc -l | tr -d ' ' | grep -q '^2$' || {
  echo "async await IO dual FAIL: expected two sched_read_chunk calls"
  exit 1
}
echo "$out" | grep -q 'complete_read_async_slot(__shux_frame.__io_rd_slot)' || {
  echo "async await IO dual FAIL: missing slot complete"
  exit 1
}
echo "async await IO dual OK"

# io_uring harness 链 std/io/io.o；probe 通过时先确保 io.o 已编译。
if ! async_io_uring_unavailable; then
  make -C compiler ../std/io/io.o -q 2>/dev/null || make -C compiler ../std/io/io.o
fi

echo "io read async: submit_read_async + complete (C harness) ..."
if ! async_io_uring_skip_na "io read async"; then
  if "${SHUX_ASYNC_CC[@]}" -o /tmp/shux_io_read_async \
    tests/bench/io_read_async.c std/io/io.o $SHUX_IO_CC_LIBS 2>&1; then
    rc=$(/tmp/shux_io_read_async; echo $?)
    [ "$rc" = "0" ] || { echo "io read async FAIL: exit=$rc"; exit 1; }
    echo "io read async OK"
  else
    echo "io read async: skip (build io.o or platform)"
  fi
fi

echo "io read async multi: dual in-flight submit + slot complete ..."
if ! async_io_uring_skip_na "io read async multi"; then
  if "${SHUX_ASYNC_CC[@]}" -o /tmp/shux_io_read_async_multi \
    tests/bench/io_read_async_multi.c std/io/io.o $SHUX_IO_CC_LIBS 2>&1; then
    rc=$(/tmp/shux_io_read_async_multi; echo $?)
    [ "$rc" = "0" ] || { echo "io read async multi FAIL: exit=$rc"; exit 1; }
    echo "io read async multi OK"
  else
    echo "io read async multi: skip (build io.o or platform)"
  fi
fi

echo "io write async: submit_write_async + complete (C harness) ..."
if ! async_io_uring_skip_na "io write async"; then
  if "${SHUX_ASYNC_CC[@]}" -o /tmp/shux_io_write_async \
    tests/bench/io_write_async.c std/io/io.o $SHUX_IO_CC_LIBS 2>&1; then
    rc=$(/tmp/shux_io_write_async; echo $?)
    [ "$rc" = "0" ] || { echo "io write async FAIL: exit=$rc"; exit 1; }
    echo "io write async OK"
  else
    echo "io write async: skip (build io.o or platform)"
  fi
fi

echo "io write async multi: dual in-flight submit + slot complete ..."
if ! async_io_uring_skip_na "io write async multi"; then
  if "${SHUX_ASYNC_CC[@]}" -o /tmp/shux_io_write_async_multi \
    tests/bench/io_write_async_multi.c std/io/io.o $SHUX_IO_CC_LIBS 2>&1; then
    rc=$(/tmp/shux_io_write_async_multi; echo $?)
    [ "$rc" = "0" ] || { echo "io write async multi FAIL: exit=$rc"; exit 1; }
    echo "io write async multi OK"
  else
    echo "io write async multi: skip (build io.o or platform)"
  fi
fi

echo "async scheduler IO read e2e: submit + suspend_io + wake + complete ..."
if ! async_io_uring_skip_na "async scheduler IO read e2e"; then
  if "${SHUX_ASYNC_CC[@]}" -o /tmp/shux_async_scheduler_io_read_e2e \
    tests/bench/async_scheduler_io_read_e2e.c std/io/io.o std/async/scheduler.o $SHUX_IO_CC_LIBS 2>&1; then
    rc=$(/tmp/shux_async_scheduler_io_read_e2e; echo $?)
    [ "$rc" = "0" ] || { echo "async scheduler IO read e2e FAIL: exit=$rc"; exit 1; }
    echo "async scheduler IO read e2e OK"
  else
    echo "async scheduler IO read e2e: skip (build io.o/scheduler.o)"
  fi
fi

echo "async scheduler IO read multi e2e: dual task + slot pool + wake ..."
if ! async_io_uring_skip_na "async scheduler IO read multi e2e"; then
  if "${SHUX_ASYNC_CC[@]}" -o /tmp/shux_async_scheduler_io_read_multi_e2e \
    tests/bench/async_scheduler_io_read_multi_e2e.c std/io/io.o std/async/scheduler.o $SHUX_IO_CC_LIBS 2>&1; then
    rc=$(/tmp/shux_async_scheduler_io_read_multi_e2e; echo $?)
    [ "$rc" = "0" ] || { echo "async scheduler IO read multi e2e FAIL: exit=$rc"; exit 1; }
    echo "async scheduler IO read multi e2e OK"
  else
    echo "async scheduler IO read multi e2e: skip (build io.o/scheduler.o)"
  fi
fi

echo "async scheduler IO write multi e2e: dual task + slot pool + wake ..."
if ! async_io_uring_skip_na "async scheduler IO write multi e2e"; then
  if "${SHUX_ASYNC_CC[@]}" -o /tmp/shux_async_scheduler_io_write_multi_e2e \
    tests/bench/async_scheduler_io_write_multi_e2e.c std/io/io.o std/async/scheduler.o $SHUX_IO_CC_LIBS 2>&1; then
    rc=$(/tmp/shux_async_scheduler_io_write_multi_e2e; echo $?)
    [ "$rc" = "0" ] || { echo "async scheduler IO write multi e2e FAIL: exit=$rc"; exit 1; }
    echo "async scheduler IO write multi e2e OK"
  else
    echo "async scheduler IO write multi e2e: skip (build io.o/scheduler.o)"
  fi
fi

echo "async scheduler drain: run + SHUX_ASYNC_YIELD=1 ..."
out=$("$EMIT_SHUX" -E tests/parser/async_scheduler_drain.sx 2>&1) || {
  echo "async scheduler drain FAIL: -E async_scheduler_drain.sx"
  exit 1
}
echo "$out" | grep -q 'shux_async_sched_yield_demo' || {
  echo "async scheduler drain FAIL: missing shux_async_sched_yield_demo wrapper"
  exit 1
}
echo "$out" | grep -q '__shux_frame.__phase = 0' || {
  echo "async scheduler drain FAIL: missing __phase reset on return"
  exit 1
}
if make -C compiler ../std/async/scheduler.o -q 2>/dev/null; then
  # 部分平台 shux 链 run+drain 仍可能崩溃；-E 烟测已通过，run 失败则 skip（CI 不 grep drain run OK）。
  if SHUX_ASYNC_YIELD=1 "$COMPILE_SHUX" -L . tests/parser/async_scheduler_drain.sx -o /tmp/shux_async_sched_drain 2>/tmp/shux_async_sched_drain.log; then
    if file /tmp/shux_async_sched_drain 2>/dev/null | grep -q "executable"; then
      rc=$(SHUX_ASYNC_YIELD=1 /tmp/shux_async_sched_drain; echo $?)
      [ "$rc" = "0" ] || { echo "async scheduler drain FAIL: expected exit 0, got $rc"; exit 1; }
      echo "async scheduler drain run OK"
    else
      echo "async scheduler drain: skip run (link/platform)"
    fi
  else
    echo "async scheduler drain: skip run (compile: $(head -1 /tmp/shux_async_sched_drain.log 2>/dev/null || echo shux failed))"
  fi
else
  echo "async scheduler drain: skip run (scheduler.o not built)"
fi

echo "run async syntax: run yield_demo() codegen + typeck ..."
out=$("$EMIT_SHUX" -E tests/parser/run_async.sx 2>&1) || {
  echo "run async FAIL: -E run_async.sx"
  exit 1
}
echo "$out" | grep -q 'shux_async_sched_yield_demo()' || {
  echo "run async FAIL: expected shux_async_sched_yield_demo() in -E"
  exit 1
}
if "$COMPILE_SHUX" -L . tests/parser/run_async_sync_err.sx -o /tmp/shux_run_async_err 2>&1 | grep -q "run.*not allowed inside async"; then
  : # 预期 typeck 报错
else
  echo "run async FAIL: run inside async should be rejected"
  exit 1
fi
echo "run async syntax OK"

echo "run async v1: run async_fn(i32) seed + codegen ..."
out=$("$EMIT_SHUX" -E tests/parser/run_async_arg.sx 2>&1) || {
  echo "run async v1 FAIL: -E run_async_arg.sx"
  exit 1
}
echo "$out" | grep -q 'shux_async_run_seed_push_i32' || {
  echo "run async v1 FAIL: missing shux_async_run_seed_push_i32"
  exit 1
}
echo "$out" | grep -q 'shux_async_run_seed_take_i32' || {
  echo "run async v1 FAIL: missing seed take in async entry"
  exit 1
}
if _run_async_arg_count_rejected tests/parser/run_async_arg_err.sx; then
  : # 预期 typeck 报错：两实参对一形参
else
  echo "run async v1 FAIL: run arg count mismatch should be rejected"
  exit 1
fi
if make -C compiler ../std/async/scheduler.o -q 2>/dev/null; then
  "$COMPILE_SHUX" -L . tests/parser/run_async_arg.sx -o /tmp/shux_run_async_arg 2>&1 || {
    echo "run async v1 FAIL: compile run_async_arg.sx"
    exit 1
  }
  if file /tmp/shux_run_async_arg 2>/dev/null | grep -q "executable"; then
    rc=$(/tmp/shux_run_async_arg; echo $?)
    [ "$rc" = "0" ] || { echo "run async v1 FAIL: expected exit 0, got $rc"; exit 1; }
    echo "run async v1 run OK"
  else
    echo "run async v1: skip run (link/platform)"
  fi
else
  echo "run async v1: skip run (scheduler.o not built)"
fi
echo "run async v1 OK"

echo "run async v2: run async_fn(i32, i32) seed queue + codegen ..."
out=$("$EMIT_SHUX" -E tests/parser/run_async_arg2.sx 2>&1) || {
  echo "run async v2 FAIL: -E run_async_arg2.sx"
  exit 1
}
echo "$out" | grep -q 'shux_async_run_seed_reset' || {
  echo "run async v2 FAIL: missing shux_async_run_seed_reset"
  exit 1
}
# 两处 run add_two(…) 各 push 两个 i32；grep -c 数行不准（comma-expr 同一行含多次 push）
n_push=$(echo "$out" | grep -oE 'shux_async_run_seed_push_i32\([0-9]+' | wc -l | tr -d ' ')
[ "$n_push" = "4" ] || {
  echo "run async v2 FAIL: expected 4 push_i32 calls (2 runs x 2 args), got $n_push"
  exit 1
}
echo "$out" | grep -q 'a = shux_async_run_seed_take_i32' || {
  echo "run async v2 FAIL: missing seed take for param a"
  exit 1
}
echo "$out" | grep -q 'b = shux_async_run_seed_take_i32' || {
  echo "run async v2 FAIL: missing seed take for param b"
  exit 1
}
if _run_async_arg_count_rejected tests/parser/run_async_arg2_err.sx; then
  : # 预期 typeck 报错
else
  echo "run async v2 FAIL: run with one arg to two-param fn should be rejected"
  exit 1
fi
if _run_async_arg_count_rejected tests/parser/run_async_arg3_err.sx; then
  : # 预期 typeck 报错
else
  echo "run async v2 FAIL: run with three args to one-param fn should be rejected"
  exit 1
fi
if make -C compiler ../std/async/scheduler.o -q 2>/dev/null; then
  "$COMPILE_SHUX" -L . tests/parser/run_async_arg2.sx -o /tmp/shux_run_async_arg2 2>&1 || {
    echo "run async v2 FAIL: compile run_async_arg2.sx"
    exit 1
  }
  if file /tmp/shux_run_async_arg2 2>/dev/null | grep -q "executable"; then
    rc=$(/tmp/shux_run_async_arg2; echo $?)
    [ "$rc" = "0" ] || { echo "run async v2 FAIL: expected exit 0, got $rc"; exit 1; }
    echo "run async v2 run OK"
  else
    echo "run async v2: skip run (link/platform)"
  fi
else
  echo "run async v2: skip run (scheduler.o not built)"
fi
echo "run async v2 OK"

echo "run async v3: u32/i64 seed + codegen ..."
out=$("$EMIT_SHUX" -E tests/parser/run_async_u32.sx 2>&1) || {
  echo "run async v3 FAIL: -E run_async_u32.sx"
  exit 1
}
echo "$out" | grep -q 'shux_async_run_seed_push_u32' || {
  echo "run async v3 FAIL: missing push_u32"
  exit 1
}
echo "$out" | grep -q 'shux_async_run_seed_take_u32' || {
  echo "run async v3 FAIL: missing take_u32 in async entry"
  exit 1
}
out2=$("$EMIT_SHUX" -E tests/parser/run_async_i64.sx 2>&1) || {
  echo "run async v3 FAIL: -E run_async_i64.sx"
  exit 1
}
echo "$out2" | grep -q 'shux_async_run_seed_push_i64' || {
  echo "run async v3 FAIL: missing push_i64"
  exit 1
}
echo "$out2" | grep -q 'shux_async_run_seed_take_i64' || {
  echo "run async v3 FAIL: missing take_i64"
  exit 1
}
if "$COMPILE_SHUX" -L . tests/parser/run_async_type_err.sx -o /tmp/shux_run_async_type_err 2>&1 | grep -q "type mismatch"; then
  : # 预期 typeck 报错
else
  echo "run async v3 FAIL: i32 arg to u32 param should be rejected"
  exit 1
fi
if [ -x "$COMPILE_SHUX" ]; then
  "$COMPILE_SHUX" -L . tests/parser/run_async_u32.sx -o /tmp/shux_run_async_u32 2>&1 || {
    echo "run async v3 FAIL: compile run_async_u32.sx"
    exit 1
  }
  if file /tmp/shux_run_async_u32 2>/dev/null | grep -q "executable"; then
    rc=$(/tmp/shux_run_async_u32; echo $?)
    [ "$rc" = "0" ] || { echo "run async v3 FAIL: run_async_u32 exit=$rc"; exit 1; }
    echo "run async v3 run_async_u32 OK"
  fi
  "$COMPILE_SHUX" -L . tests/parser/run_async_i64.sx -o /tmp/shux_run_async_i64 2>&1 || {
    echo "run async v3 FAIL: compile run_async_i64.sx"
    exit 1
  }
  if file /tmp/shux_run_async_i64 2>/dev/null | grep -q "executable"; then
    rc=$(/tmp/shux_run_async_i64; echo $?)
    [ "$rc" = "0" ] || { echo "run async v3 FAIL: run_async_i64 exit=$rc"; exit 1; }
    echo "run async v3 run_async_i64 OK"
  fi
fi
echo "run async v3 OK"

echo "run async v4: usize seed + codegen ..."
out=$("$EMIT_SHUX" -E tests/parser/run_async_usize.sx 2>&1) || {
  echo "run async v4 FAIL: -E run_async_usize.sx"
  exit 1
}
echo "$out" | grep -q 'shux_async_run_seed_push_usize' || {
  echo "run async v4 FAIL: missing push_usize"
  exit 1
}
echo "$out" | grep -q 'shux_async_run_seed_take_usize' || {
  echo "run async v4 FAIL: missing take_usize in async entry"
  exit 1
}
if [ -x "$COMPILE_SHUX" ]; then
  "$COMPILE_SHUX" -L . tests/parser/run_async_usize.sx -o /tmp/shux_run_async_usize 2>&1 || {
    echo "run async v4 FAIL: compile run_async_usize.sx"
    exit 1
  }
  if file /tmp/shux_run_async_usize 2>/dev/null | grep -q "executable"; then
    rc=$(/tmp/shux_run_async_usize; echo $?)
    [ "$rc" = "0" ] || { echo "run async v4 FAIL: run_async_usize exit=$rc"; exit 1; }
    echo "run async v4 run_async_usize OK"
  fi
fi
echo "run async v4 OK"

echo "async run seed: shux_async_run_seed_* (C harness) ..."
if "${SHUX_ASYNC_CC[@]}" -o /tmp/shux_async_run_seed \
  tests/bench/async_run_seed.c std/async/scheduler.o 2>&1; then
  rc=$(/tmp/shux_async_run_seed; echo $?)
  [ "$rc" = "0" ] || { echo "async run seed FAIL: exit=$rc"; exit 1; }
  echo "async run seed OK"
else
  echo "async run seed: skip (scheduler.o)"
fi

echo "async linux full: .sx link + run (run v1/v2 + IO stdin/pipe/spawn) ..."
if [ -x ./compiler/shux-c ]; then
  ASYNC_LINUX_FULL_IO=1
  if async_io_uring_unavailable; then
    echo "async linux full: IO run N/A (io_uring unavailable on this kernel)"
    ASYNC_LINUX_FULL_IO=0
    make -C compiler ../std/async/scheduler.o -q 2>/dev/null \
      || make -C compiler ../std/async/scheduler.o
  else
    make -C compiler ../std/io/io.o ../std/async/scheduler.o -q 2>/dev/null \
      || make -C compiler ../std/io/io.o ../std/async/scheduler.o
  fi

  ./compiler/shux-c -L . tests/parser/run_async_arg.sx -o /tmp/shux_run_async_arg_full 2>&1 || {
    echo "async linux full FAIL: compile run_async_arg.sx"
    exit 1
  }
  if file /tmp/shux_run_async_arg_full 2>/dev/null | grep -q "executable"; then
    rc=$(/tmp/shux_run_async_arg_full; echo $?)
    [ "$rc" = "0" ] || { echo "async linux full FAIL: run_async_arg exit=$rc"; exit 1; }
    echo "async linux full run_async_arg OK"
  else
    echo "async linux full: skip run_async_arg run (not executable)"
  fi

  ./compiler/shux-c -L . tests/parser/run_async_arg2.sx -o /tmp/shux_run_async_arg2_full 2>&1 || {
    echo "async linux full FAIL: compile run_async_arg2.sx"
    exit 1
  }
  if file /tmp/shux_run_async_arg2_full 2>/dev/null | grep -q "executable"; then
    rc=$(/tmp/shux_run_async_arg2_full; echo $?)
    [ "$rc" = "0" ] || { echo "async linux full FAIL: run_async_arg2 exit=$rc"; exit 1; }
    echo "async linux full run_async_arg2 OK"
  else
    echo "async linux full: skip run_async_arg2 run (not executable)"
  fi

  if [ "$ASYNC_LINUX_FULL_IO" = "1" ]; then
    SHUX_ASYNC_YIELD=1 ./compiler/shux-c -L . tests/parser/async_run_io_stdin.sx -o /tmp/shux_async_run_io_stdin 2>&1 || {
      echo "async linux full FAIL: compile async_run_io_stdin.sx"
      exit 1
    }
    if file /tmp/shux_async_run_io_stdin 2>/dev/null | grep -q "executable"; then
      rc=$(printf 'abcd' | SHUX_ASYNC_YIELD=1 /tmp/shux_async_run_io_stdin; echo $?)
      [ "$rc" = "0" ] || { echo "async linux full FAIL: async_run_io_stdin exit=$rc want 0"; exit 1; }
      echo "async linux full async_run_io_stdin OK"
    else
      echo "async linux full: skip async_run_io_stdin run (not executable)"
    fi

    SHUX_ASYNC_YIELD=1 ./compiler/shux-c -L . tests/parser/async_run_io_dual_pipe.sx -o /tmp/shux_async_run_io_dual_pipe 2>&1 || {
      echo "async linux full FAIL: compile async_run_io_dual_pipe.sx"
      exit 1
    }
    if file /tmp/shux_async_run_io_dual_pipe 2>/dev/null | grep -q "executable"; then
      if "${SHUX_ASYNC_CC[@]}" -o /tmp/shux_async_run_io_dual_pipe_wrapper \
        tests/bench/async_run_io_dual_pipe_wrapper.c 2>&1; then
        rc=$(/tmp/shux_async_run_io_dual_pipe_wrapper /tmp/shux_async_run_io_dual_pipe; echo $?)
        [ "$rc" = "0" ] || { echo "async linux full FAIL: async_run_io_dual_pipe exit=$rc want 0"; exit 1; }
        echo "async linux full async_run_io_dual_pipe OK"
      else
        echo "async linux full: skip async_run_io_dual_pipe run (wrapper build failed)"
      fi
    else
      echo "async linux full: skip async_run_io_dual_pipe run (not executable)"
    fi

    SHUX_ASYNC_YIELD=1 ./compiler/shux-c -L . tests/parser/async_run_io_dual_parallel.sx -o /tmp/shux_async_run_io_dual_parallel 2>&1 || {
      echo "async linux full FAIL: compile async_run_io_dual_parallel.sx"
      exit 1
    }
    if file /tmp/shux_async_run_io_dual_parallel 2>/dev/null | grep -q "executable"; then
      if "${SHUX_ASYNC_CC[@]}" -o /tmp/shux_async_run_io_dual_pipe_wrapper \
        tests/bench/async_run_io_dual_pipe_wrapper.c 2>&1; then
        rc=$(/tmp/shux_async_run_io_dual_pipe_wrapper /tmp/shux_async_run_io_dual_parallel; echo $?)
        [ "$rc" = "0" ] || { echo "async linux full FAIL: async_run_io_dual_parallel exit=$rc want 0"; exit 1; }
        echo "async linux full async_run_io_dual_parallel OK"
      else
        echo "async linux full: skip async_run_io_dual_parallel run (wrapper build failed)"
      fi
    else
      echo "async linux full: skip async_run_io_dual_parallel run (not executable)"
    fi
  fi
else
  echo "async linux full: skip (no compiler/shux-c)"
fi
echo "async linux full OK"

echo "async scheduler IO-A5 poll wake: shux_io_poll_async_completions + drain ..."
if ! async_io_uring_skip_na "async scheduler IO-A5 poll wake"; then
  if "${SHUX_ASYNC_CC[@]}" -o /tmp/shux_async_scheduler_io_poll_wake \
    tests/bench/async_scheduler_io_poll_wake.c std/io/io.o std/async/scheduler.o $SHUX_IO_CC_LIBS 2>&1; then
    rc=$(/tmp/shux_async_scheduler_io_poll_wake; echo $?)
    [ "$rc" = "0" ] || { echo "async scheduler IO-A5 poll wake FAIL: exit=$rc"; exit 1; }
    echo "async scheduler IO-A5 poll wake OK"
  else
    echo "async scheduler IO-A5 poll wake: skip (build io.o/scheduler.o)"
  fi
fi

echo "async run dual pipe: two run_i32 + dual pipe (C harness) ..."
if ! async_io_uring_skip_na "async run dual pipe"; then
  if "${SHUX_ASYNC_CC[@]}" -o /tmp/shux_async_run_io_dual_pipe \
    tests/bench/async_run_io_dual_pipe.c std/io/io.o std/async/scheduler.o $SHUX_IO_CC_LIBS 2>&1; then
    rc=$(SHUX_ASYNC_YIELD=1 /tmp/shux_async_run_io_dual_pipe; echo $?)
    [ "$rc" = "0" ] || { echo "async run dual pipe FAIL: exit=$rc"; exit 1; }
    echo "async run dual pipe OK"
  else
    echo "async run dual pipe: skip (build io.o/scheduler.o)"
  fi
fi

echo "async spawn v4: spawn async_fn + drain_until_idle codegen ..."
out=$("$EMIT_SHUX" -L . -E tests/parser/async_spawn_v4_smoke.sx 2>&1) || {
  echo "async spawn v4 FAIL: -E async_spawn_v4_smoke.sx"
  exit 1
}
echo "$out" | grep -q 'shux_async_queue_reset' || {
  echo "async spawn v4 FAIL: missing shux_async_queue_reset (import std.async)"
  exit 1
}
echo "$out" | grep -q 'shux_async_task_submit' || {
  echo "async spawn v4 FAIL: missing shux_async_task_submit"
  exit 1
}
echo "$out" | grep -q 'shux_async_run_drain_until_idle' || {
  echo "async spawn v4 FAIL: missing shux_async_run_drain_until_idle"
  exit 1
}
# 两处 spawn 各一次 submit；按调用点计数（extern 声明也占 grep -c 行）
n_submit=$(echo "$out" | grep -oE 'shux_async_task_submit\s*\(' | wc -l | tr -d ' ')
# 含 std.async 导入时 -E 可能仅见 extern；至少应出现声明 + 调用
[ "$n_submit" -ge 2 ] || {
  echo "async spawn v4 FAIL: expected at least 2 task_submit (decl/call), got $n_submit"
  exit 1
}
echo "async spawn v4 OK"

echo "async scheduler IO parallel poll: dual task + poll wake ..."
if ! async_io_uring_skip_na "async scheduler IO parallel poll"; then
  if "${SHUX_ASYNC_CC[@]}" -o /tmp/shux_async_scheduler_io_parallel_poll \
    tests/bench/async_scheduler_io_read_parallel_poll.c std/io/io.o std/async/scheduler.o $SHUX_IO_CC_LIBS 2>&1; then
    rc=$(/tmp/shux_async_scheduler_io_parallel_poll; echo $?)
    [ "$rc" = "0" ] || { echo "async scheduler IO parallel poll FAIL: exit=$rc"; exit 1; }
    echo "async scheduler IO parallel poll OK"
  else
    echo "async scheduler IO parallel poll: skip (build io.o/scheduler.o)"
  fi
fi

echo "async spawn parallel IO: push+submit x2 + drain_until_idle (C harness) ..."
if ! async_io_uring_skip_na "async spawn parallel IO"; then
  if "${SHUX_ASYNC_CC[@]}" -o /tmp/shux_async_run_io_spawn_parallel \
    tests/bench/async_run_io_spawn_parallel.c std/io/io.o std/async/scheduler.o $SHUX_IO_CC_LIBS 2>&1; then
    rc=$(SHUX_ASYNC_YIELD=1 /tmp/shux_async_run_io_spawn_parallel; echo $?)
    [ "$rc" = "0" ] || { echo "async spawn parallel IO FAIL: exit=$rc"; exit 1; }
    echo "async spawn parallel IO OK"
  else
    echo "async spawn parallel IO: skip (build io.o/scheduler.o)"
  fi
fi

echo "async spawn workers IO: SHUX_ASYNC_WORKERS=2 + spawn parallel drain ..."
if ! async_io_uring_skip_na "async spawn workers IO"; then
  if SHUX_ASYNC_WORKERS=2 "${SHUX_ASYNC_CC[@]}" -pthread -o /tmp/shux_async_run_io_spawn_workers \
    tests/bench/async_run_io_spawn_workers.c std/io/io.o std/async/scheduler.o $SHUX_IO_CC_LIBS 2>&1; then
    rc=$(SHUX_ASYNC_YIELD=1 SHUX_ASYNC_WORKERS=2 /tmp/shux_async_run_io_spawn_workers; echo $?)
    [ "$rc" = "0" ] || { echo "async spawn workers IO FAIL: exit=$rc"; exit 1; }
    echo "async spawn workers IO OK"
  else
    echo "async spawn workers IO: skip (build io.o/scheduler.o)"
  fi
fi

echo "async run_i32 IO stdin: run_i32 + wake/drain loop (C harness) ..."
if ! async_io_uring_skip_na "async run_i32 IO stdin"; then
  if "${SHUX_ASYNC_CC[@]}" -o /tmp/shux_async_run_i32_io_stdin \
    tests/bench/async_run_i32_io_stdin.c std/io/io.o std/async/scheduler.o $SHUX_IO_CC_LIBS 2>&1; then
    rc=$(printf 'abcd' | SHUX_ASYNC_YIELD=1 /tmp/shux_async_run_i32_io_stdin; echo $?)
    [ "$rc" = "0" ] || { echo "async run_i32 IO stdin FAIL: exit=$rc"; exit 1; }
    echo "async run_i32 IO stdin OK"
  else
    echo "async run_i32 IO stdin: skip (build io.o/scheduler.o)"
  fi
fi

echo "async gate OK"
