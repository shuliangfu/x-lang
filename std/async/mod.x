// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

/**
 * Async runtime C ABI wrappers.
 *
 * All `xlang_async_*` / `xlang_io_poll_async_*` functions below are thin
 * wrappers over the XLANG async runtime C implementation (see seeds).
 * They are exposed to XLANG via `extern "C"` declarations.
 *
 * ABI: C (System V / AAPCS). Calling convention matches the C runtime
 * (cooperative scheduler + CPS suspend/resume + work-stealing worker
 * pool + io_wait/wake + context binding + seed-based argument passing).
 * PLATFORM: SHARED — pure C with pthreads/atomic intrinsics; available
 * on all targets (macOS arm64 / Ubuntu x86_64 / Windows MSYS2/MinGW).
 *
 * Categories:
 *   - xlang_async_coop_*       : cooperative ping-pong benchmarks
 *                               (jmp-based + direct)
 *   - xlang_async_cps_*        : CPS suspend/resume with phase tracking
 *   - xlang_async_run_*        : task runner + seed stack (push/set/
 *                               take i32/u32/i64/usize + drain_until_
 *                               idle + seed_reset)
 *   - xlang_async_task_*       : task submission (default + targeted
 *                               worker + context-bound)
 *   - xlang_async_scheduler_*  : scheduler drain + pending count
 *   - xlang_async_worker_*     : per-worker drain/count/pending
 *   - xlang_async_queue_*      : queue reset
 *   - xlang_async_io_*         : io waiters wake/pending
 *   - xlang_io_poll_async_*    : io completion polling with timeout
 *   - xlang_async_*_context_*  : context bind/unbind/current
 *   - xlang_async_spawn_*      : spawn i32 task + ctx smoke test
 *
 * Error codes: i32 returns; 0 = OK, negative = error
 *   (XLANG_ASYNC_ERR_CTX_ABORT = -3 for context abort).
 *
 * Unsafe contract: callers must wrap `xlang_async_*_c` / `xlang_io_poll_*
 * ` calls in `unsafe { }` blocks. P0a semantic downgrade currently
 * allows unwrapped calls; P1 typeck enforcement (post-bootstrap) will
 * reject unwrapped calls.
 */
const io = import("std.io");
const context = import("std.context");
const err = import("std.error");

/**
 * See implementation.
 * See implementation.
 */
export function wait_completion(fds: *i32, n: i32, timeout_ms: u32): i32 {
  return io.wait_readable(fds, n, timeout_ms);
}

/**
 * See implementation.
 * See implementation.
 */
export function submit_read_sync(handle: usize, ptr: *u8, len: usize, timeout_ms: u32): i32 {
  return io.read(handle, ptr, len, timeout_ms);
}

/**
 * See implementation.
 */
export function submit_write_sync(handle: usize, ptr: *u8, len: usize, timeout_ms: u32): i32 {
  return io.write(handle, ptr, len, timeout_ms);
}

// See implementation.
extern "C" function xlang_async_coop_pingpong(rounds: i64): i64;
extern "C" function xlang_async_coop_pingpong_jmp(rounds: i64): i64;

// See implementation.
extern "C" function xlang_async_cps_suspend(phase: *i32, next_phase: i32): i32;
/* See implementation. */
extern "C" function xlang_async_cps_suspend_io(phase: *i32, next_phase: i32): i32;
extern "C" function xlang_async_run_i32(fn: *u8): i32;
/* See implementation. */
extern "C" function xlang_async_spawn_i32(fn: *u8, seed: i32): i32;
/* See implementation. */
extern "C" function xlang_async_run_drain_until_idle(): i32;
/* See implementation. */
extern "C" function xlang_async_run_seed_reset(): void;
extern "C" function xlang_async_run_seed_push_i32(v: i32): void;
extern "C" function xlang_async_run_seed_push_u32(v: u32): void;
extern "C" function xlang_async_run_seed_push_i64(v: i64): void;
extern "C" function xlang_async_run_seed_push_usize(v: usize): void;
/* See implementation. */
extern "C" function xlang_async_run_seed_set_i32(v: i32): void;
extern "C" function xlang_async_run_seed_valid(): i32;
extern "C" function xlang_async_run_seed_take_i32(): i32;
extern "C" function xlang_async_run_seed_take_u32(): u32;
extern "C" function xlang_async_run_seed_take_i64(): i64;
extern "C" function xlang_async_run_seed_take_usize(): usize;

// See implementation.
// See implementation.
extern "C" function xlang_async_task_submit(fn: *u8): i32;
/* See implementation. */
extern "C" function xlang_async_task_submit_to(worker_id: u32, fn: *u8): i32;
extern "C" function xlang_async_scheduler_drain(): i32;
/* See implementation. */
extern "C" function xlang_async_worker_drain(worker_id: u32): i32;
extern "C" function xlang_async_worker_count(): u32;
extern "C" function xlang_async_worker_pending(worker_id: u32): u32;
extern "C" function xlang_async_queue_reset(): void;
extern "C" function xlang_async_scheduler_pending(): u32;
extern "C" function xlang_async_io_wake_all(): void;
extern "C" function xlang_async_io_waiters_pending(): u32;
/* See implementation. */
extern "C" function xlang_io_poll_async_completions(timeout_ms: u32): u32;

// See implementation.
extern "C" function xlang_async_bind_context_c(ctx_handle: i64): void;
extern "C" function xlang_async_unbind_context_c(): void;
extern "C" function xlang_async_current_context_c(): i64;
extern "C" function xlang_async_task_submit_with_ctx(fn: *u8, ctx_handle: i64): i32;
extern "C" function xlang_async_spawn_ctx_smoke_c(): i32;

/* See implementation. */
export const XLANG_ASYNC_ERR_CTX_ABORT: i32 = -3;

/* See implementation. */
allow(padding) struct AsyncRuntime {
  ctx_handle: i64;
}

/** Exported function `err_ctx_abort`.
 * Implements `err_ctx_abort`.
 * @return i32
 */
export function err_ctx_abort(): i32 {
  return XLANG_ASYNC_ERR_CTX_ABORT;
}

/** Exported function `bind_ctx`.
 * Implements `bind_ctx`.
 * @param ctx Context
 * @return void
 */
export function bind_ctx(ctx: Context): void {
  unsafe { xlang_async_bind_context_c(ctx.handle); }
}

/** Exported function `unbind_ctx`.
 * Implements `unbind_ctx`.
 * @return void
 */
export function unbind_ctx(): void {
  unsafe { xlang_async_unbind_context_c(); }
}

/** Exported function `current_ctx`.
 * Implements `current_ctx`.
 * @return Context
 */
export function current_ctx(): Context {
  let _rc: Context = 0;
  unsafe { _rc = Context { handle: xlang_async_current_context_c() }; }
  return _rc;
}

/** Exported function `runtime`.
 * Implements `runtime`.
 * @param ctx Context
 * @return AsyncRuntime
 */
export function runtime(ctx: Context): AsyncRuntime {
  return AsyncRuntime { ctx_handle: ctx.handle };
}

/** Exported function `runtime_reset`.
 * Implements `runtime_reset`.
 * @param rt *AsyncRuntime
 * @return void
 */
export function runtime_reset(rt: *AsyncRuntime): void {
  scheduler_reset();
  if (rt != 0 && rt.ctx_handle != 0) {
    unsafe { xlang_async_bind_context_c(rt.ctx_handle); }
  }
}

/** Exported function `drain`.
 * Implements `drain`.
 * @param rt *AsyncRuntime
 * @return i32
 */
export function drain(rt: *AsyncRuntime): i32 {
  if (rt != 0 && rt.ctx_handle != 0) {
    unsafe { xlang_async_bind_context_c(rt.ctx_handle); }
  }
  unsafe {
    return xlang_async_run_drain_until_idle();
  }
}

/** Exported function `submit`.
 * Implements `submit`.
 * @param fn *u8
 * @return i32
 */
export function submit(fn: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = xlang_async_task_submit(fn); }
  return _rc;
}

/** Exported function `submit`.
 * Implements `submit`.
 * @param fn *u8
 * @param seed i32
 * @return i32
 */
export function submit(fn: *u8, seed: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = xlang_async_spawn_i32(fn, seed); }
  return _rc;
}

/** Exported function `submit_ctx`.
 * Implements `submit_ctx`.
 * @param fn *u8
 * @param ctx Context
 * @return i32
 */
export function submit_ctx(fn: *u8, ctx: Context): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = xlang_async_task_submit_with_ctx(fn, ctx.handle); }
  return _rc;
}

/** Exported function `spawn_ctx_smoke`.
 * Implements `spawn_ctx_smoke`.
 * @return i32
 */
export function spawn_ctx_smoke(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = xlang_async_spawn_ctx_smoke_c(); }
  return _rc;
}

/** Exported function `scheduler_reset`.
 * Implements `scheduler_reset`.
 * @return void
 */
export function scheduler_reset(): void {
  unsafe { xlang_async_queue_reset(); }
}

/** Exported function `drain_idle`.
 * Implements `drain_idle`.
 * @return i32
 */
export function drain_idle(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = xlang_async_run_drain_until_idle(); }
  return _rc;
}

/** Exported function `cps_suspend_io`.
 * Implements `cps_suspend_io`.
 * @param phase *i32
 * @param next_phase i32
 * @return i32
 */
export function cps_suspend_io(phase: *i32, next_phase: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = xlang_async_cps_suspend_io(phase, next_phase); }
  return _rc;
}

/** Exported function `poll_completions`.
 * Implements `poll_completions`.
 * @param timeout_ms u32
 * @return u32
 */
export function poll_completions(timeout_ms: u32): u32 {
  let _rc: u32 = 0;
  unsafe { _rc = xlang_io_poll_async_completions(timeout_ms); }
  return _rc;
}

// See implementation.

/* See implementation. */
export const IO_ASYNC_NOT_READY: i32 = -2;

/** Exported function `uring_ok`.
 * Implements `uring_ok`.
 * @return i32
 */
export function uring_ok(): i32 {
  return io.uring_ok();
}

/** Exported function `read_async`.
 * Read path helper `read_async`.
 * @param handle usize
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function read_async(handle: usize, ptr: *u8, len: usize): i32 {
  return io.read_async(handle, ptr, len);
}

/** Exported function `write_async`.
 * Write path helper `write_async`.
 * @param handle usize
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function write_async(handle: usize, ptr: *u8, len: usize): i32 {
  return io.write_async(handle, ptr, len);
}

/** Exported function `read_async_fd`.
 * Read path helper `read_async_fd`.
 * @param fd i32
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function read_async_fd(fd: i32, ptr: *u8, len: usize): i32 {
  return io.read_async(io.from_fd(fd, 0), ptr, len);
}

/** Exported function `write_async_fd`.
 * Write path helper `write_async_fd`.
 * @param fd i32
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function write_async_fd(fd: i32, ptr: *u8, len: usize): i32 {
  return io.write_async(io.from_fd(fd, 0), ptr, len);
}

/** Exported function `complete_read`.
 * Read path helper `complete_read`.
 * @param slot i32
 * @return i32
 */
export function complete_read(slot: i32): i32 {
  return io.complete_read(slot);
}

/** Exported function `complete_write`.
 * Write path helper `complete_write`.
 * @param slot i32
 * @return i32
 */
export function complete_write(slot: i32): i32 {
  return io.complete_write(slot);
}

/** Exported function `pump`.
 * Implements `pump`.
 * @return i32
 */
export function pump(): i32 {
  poll_completions(0);
  return drain_idle();
}

/**
 * See implementation.
 */
export function timeout_from_ctx(ctx: Context): i32 {
  if (context.is_cancelled(ctx) != 0) {
    return err.net_err_cancelled();
  }
  let rem: i64 = context.remaining_ns(ctx);
  let dl: i64 = context.deadline_ns(ctx);
  if (dl > 0 && rem <= 0) {
    return err.net_err_timeout();
  }
  if (rem <= 0) {
    return 0;
  }
  let ms: i64 = rem / 1000000;
  if (ms <= 0) {
    return 1;
  }
  if (ms > 2147483647) {
    return 2147483647;
  }
  return ms as i32;
}

/** Exported function `ctx_check`.
 * Implements `ctx_check`.
 * @param ctx Context
 * @return i32
 */
export function ctx_check(ctx: Context): i32 {
  let tm: i32 = timeout_from_ctx(ctx);
  if (tm == err.net_err_cancelled()) {
    return tm;
  }
  if (tm == err.net_err_timeout()) {
    return tm;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function await_read_fd(rt: *AsyncRuntime, fd: i32, ptr: *u8, len: usize, max_rounds: i32): i32 {
  let slot: i32 = read_async_fd(fd, ptr, len);
  if (slot < 0) {
    return -1;
  }
  let round: i32 = 0;
  while (round < max_rounds) {
    if (rt != 0) {
      let chk: i32 = ctx_check(current_ctx());
      if (chk != 0) {
        return chk;
      }
    }
    let n: i32 = complete_read(slot);
    if (n != IO_ASYNC_NOT_READY) {
      return n;
    }
    if (rt != 0) {
      poll_loop_ctx(rt, 1);
    } else {
      poll_completions(0);
      drain_idle();
    }
    round = round + 1;
  }
  return IO_ASYNC_NOT_READY;
}

/**
 * See implementation.
 * See implementation.
 */
export function await_write_fd(rt: *AsyncRuntime, fd: i32, ptr: *u8, len: usize, max_rounds: i32): i32 {
  let slot: i32 = write_async_fd(fd, ptr, len);
  if (slot < 0) {
    return -1;
  }
  let round: i32 = 0;
  while (round < max_rounds) {
    if (rt != 0) {
      let chk: i32 = ctx_check(current_ctx());
      if (chk != 0) {
        return chk;
      }
    }
    let n: i32 = complete_write(slot);
    if (n != IO_ASYNC_NOT_READY) {
      return n;
    }
    if (rt != 0) {
      poll_loop_ctx(rt, 1);
    } else {
      poll_completions(0);
      drain_idle();
    }
    round = round + 1;
  }
  return IO_ASYNC_NOT_READY;
}

/** Exported function `net_read_async`.
 * Read path helper `net_read_async`.
 * @param rt *AsyncRuntime
 * @param fd i32
 * @param ptr *u8
 * @param len usize
 * @param max_rounds i32
 * @return i32
 */
export function net_read_async(rt: *AsyncRuntime, fd: i32, ptr: *u8, len: usize, max_rounds: i32): i32 {
  return await_read_fd(rt, fd, ptr, len, max_rounds);
}

/** Exported function `net_write_async`.
 * Write path helper `net_write_async`.
 * @param rt *AsyncRuntime
 * @param fd i32
 * @param ptr *u8
 * @param len usize
 * @param max_rounds i32
 * @return i32
 */
export function net_write_async(rt: *AsyncRuntime, fd: i32, ptr: *u8, len: usize, max_rounds: i32): i32 {
  return await_write_fd(rt, fd, ptr, len, max_rounds);
}

/** Exported function `fs_read_async`.
 * Read path helper `fs_read_async`.
 * @param rt *AsyncRuntime
 * @param fd i32
 * @param ptr *u8
 * @param len usize
 * @param max_rounds i32
 * @return i32
 */
export function fs_read_async(rt: *AsyncRuntime, fd: i32, ptr: *u8, len: usize, max_rounds: i32): i32 {
  return await_read_fd(rt, fd, ptr, len, max_rounds);
}

/** Exported function `fs_write_async`.
 * Write path helper `fs_write_async`.
 * @param rt *AsyncRuntime
 * @param fd i32
 * @param ptr *u8
 * @param len usize
 * @param max_rounds i32
 * @return i32
 */
export function fs_write_async(rt: *AsyncRuntime, fd: i32, ptr: *u8, len: usize, max_rounds: i32): i32 {
  return await_write_fd(rt, fd, ptr, len, max_rounds);
}

extern "C" function xlang_async_net_fs_smoke_c(): i32;

/** Exported function `net_fs_async_smoke`.
 * Implements `net_fs_async_smoke`.
 * @return i32
 */
export function net_fs_async_smoke(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = xlang_async_net_fs_smoke_c(); }
  return _rc;
}

/** Exported function `waiters`.
 * Implements `waiters`.
 * @return u32
 */
export function waiters(): u32 {
  let _rc: u32 = 0;
  unsafe { _rc = xlang_async_io_waiters_pending(); }
  return _rc;
}

/* See implementation. */
export const XLANG_ASYNC_SUSPENDED: i32 = 0x41535700;

/* See implementation. */
export const POLL_PENDING: i32 = 0;
/* See implementation. */
export const POLL_READY: i32 = 1;

/* See implementation. */
allow(padding) struct Future {
  handle: i64;
}

extern "C" function xlang_async_future_create_c(): i64;
extern "C" function xlang_async_future_poll_c(handle: i64): i32;
extern "C" function xlang_async_future_complete_c(handle: i64, value: i32): void;
extern "C" function xlang_async_future_take_c(handle: i64, out: *i32): i32;
extern "C" function xlang_async_future_reset_c(): void;
extern "C" function xlang_async_future_wait_c(handle: i64, max_rounds: i32): i32;
extern "C" function xlang_async_future_smoke_c(): i32;

/** Exported function `future_new`.
 * Implements `future_new`.
 * @return Future
 */
export function future_new(): Future {
  let _rc: Future = 0;
  unsafe { _rc = Future { handle: xlang_async_future_create_c() }; }
  return _rc;
}

/**
 * See implementation.
 */
export function future_poll(fut: *Future): i32 {
  let zero: i64 = 0;
  if (fut == 0 || fut.handle == zero) { return -1; }
  unsafe {
    return xlang_async_future_poll_c(fut.handle);
  }
}

/** Exported function `future_complete`.
 * Implements `future_complete`.
 * @param fut *Future
 * @param value i32
 * @return void
 */
export function future_complete(fut: *Future, value: i32): void {
  let zero: i64 = 0;
  if (fut == 0 || fut.handle == zero) { return; }
  unsafe { xlang_async_future_complete_c(fut.handle, value); }
}

/**
 * See implementation.
 */
export function future_take(fut: *Future, out: *i32): i32 {
  let zero: i64 = 0;
  if (fut == 0 || fut.handle == zero || out == 0) { return -1; }
  unsafe {
    return xlang_async_future_take_c(fut.handle, out);
  }
}

/** Exported function `future_reset`.
 * Implements `future_reset`.
 * @return void
 */
export function future_reset(): void {
  unsafe { xlang_async_future_reset_c(); }
}

/** Exported function `future_smoke`.
 * Implements `future_smoke`.
 * @return i32
 */
export function future_smoke(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = xlang_async_future_smoke_c(); }
  return _rc;
}

/**
 * See implementation.
 * See implementation.
 */
export function future_wait(fut: *Future, max_rounds: i32): i32 {
  let zero: i64 = 0;
  if (fut == 0 || fut.handle == zero) { return -1; }
  unsafe {
    return xlang_async_future_wait_c(fut.handle, max_rounds);
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function runtime_wait_future(rt: *AsyncRuntime, fut: *Future, max_rounds: i32): i32 {
  let zero: i64 = 0;
  if (fut == 0 || fut.handle == zero) { return -1; }
  if (rt != 0 && rt.ctx_handle != zero) {
    unsafe { xlang_async_bind_context_c(rt.ctx_handle); }
  }
  return future_wait(fut, max_rounds);
}

/**
 * See implementation.
 * See implementation.
 */
export function poll_loop(max_rounds: i32): i32 {
  let round: i32 = 0;
  let sum: i32 = 0;
  while (round < max_rounds) {
    poll_completions(0);
    let drained: i32 = drain_idle();
    sum = sum + drained;
    let pend: u32 = 0;
    unsafe {
      pend = xlang_async_scheduler_pending();
    }
    if (pend == 0 && waiters() == 0) {
      break;
    }
    round = round + 1;
  }
  return sum;
}

/**
 * See implementation.
 * See implementation.
 */
export function poll_loop_ctx(rt: *AsyncRuntime, max_rounds: i32): i32 {
  let round: i32 = 0;
  let sum: i32 = 0;
  let zero: i64 = 0;
  if (rt != 0 && rt.ctx_handle != zero) {
    unsafe { xlang_async_bind_context_c(rt.ctx_handle); }
  }
  let ctx: Context = current_ctx();
  while (round < max_rounds) {
    let chk: i32 = ctx_check(ctx);
    if (chk != 0) {
      return chk;
    }
    let tm: i32 = timeout_from_ctx(ctx);
    let poll_ms: u32 = 0;
    if (tm > 0) {
      poll_ms = tm as u32;
    }
    poll_completions(poll_ms);
    let drained: i32 = drain_idle();
    sum = sum + drained;
    let pend: u32 = 0;
    unsafe {
      pend = xlang_async_scheduler_pending();
    }
    if (pend == 0 && waiters() == 0) {
      break;
    }
    round = round + 1;
  }
  return sum;
}

/** Exported function `coop_pingpong`.
 * Implements `coop_pingpong`.
 * @param rounds i64
 * @return i64
 */
export function coop_pingpong(rounds: i64): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = xlang_async_coop_pingpong(rounds); }
  return _rc;
}

/** Exported function `coop_pingpong_jmp`.
 * Implements `coop_pingpong_jmp`.
 * @param rounds i64
 * @return i64
 */
export function coop_pingpong_jmp(rounds: i64): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = xlang_async_coop_pingpong_jmp(rounds); }
  return _rc;
}

/** Exported function `placeholder`.
 * Module import/smoke marker; returns 0.
 * @return i32
 */
export function placeholder(): i32 {
  return 0;
}
/** Exported function `async_module_anchor`.
 * Implements `async_module_anchor`.
 * @return i32
 */
export function async_module_anchor(): i32 { return 0; }
