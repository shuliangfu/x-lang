// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

// See implementation.
export extern "C" function xlang_async_runtime_trace_enabled_impl(): i32;
export extern "C" function xlang_async_trace_now_us_impl(): u64;
/* wave230 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED — product hybrid scheduler pure env gates. */
export extern "C" function link_abi_getenv(name: *u8): *u8;

/** Exported function `runtime_scheduler_glue_x_doc_anchor`.
 * Implements `runtime_scheduler_glue_x_doc_anchor`.
 * @return i32
 */
export function runtime_scheduler_glue_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */





#[no_mangle]
export function xlang_async_trace_now_us(): u64 {
  unsafe { return xlang_async_trace_now_us_impl(); }
}



export extern "C" function xlang_async_bound_ctx_cancelled_impl(): i32;
export extern "C" function xlang_async_take_suspend_io_flag_impl(): i32;
// See implementation.
export extern "C" function xlang_coop_frame_step_jmp_impl(frame: *u8): i32;
export extern "C" function xlang_coop_frame_step_switch_impl(frame: *u8): i32;

/* See implementation. */

#[no_mangle]
export function xlang_async_bound_ctx_cancelled(): i32 {
  unsafe { return xlang_async_bound_ctx_cancelled_impl(); }
}

/** Exported function `xlang_async_take_suspend_io_flag`.
 * Implements `xlang_async_take_suspend_io_flag`.
 * @return i32
 */
#[no_mangle]
export function xlang_async_take_suspend_io_flag(): i32 {
  unsafe { return xlang_async_take_suspend_io_flag_impl(); }
}


/** Exported function `xlang_coop_frame_step_jmp`.
 * Implements `xlang_coop_frame_step_jmp`.
 * @param frame *u8
 * @return i32
 */
#[no_mangle]
export function xlang_coop_frame_step_jmp(frame: *u8): i32 {
  unsafe { return xlang_coop_frame_step_jmp_impl(frame); }
}

/** Exported function `xlang_coop_frame_step_switch`.
 * Implements `xlang_coop_frame_step_switch`.
 * @param frame *u8
 * @return i32
 */
#[no_mangle]
export function xlang_coop_frame_step_switch(frame: *u8): i32 {
  unsafe { return xlang_coop_frame_step_switch_impl(frame); }
}

// See implementation.

export extern "C" function xlang_async_init_workers_impl(): void;
export extern "C" function xlang_async_io_wait_push_impl(fn: *u8): i32;
export extern "C" function xlang_async_maybe_bind_worker_impl(wid: u32): void;
export extern "C" function xlang_async_drain_queue_impl(q: *u8, wid: u32, acc: *i32): i32;
export extern "C" function xlang_async_spawn_ctx_echo_task_impl(): i32;

/* See implementation. */

#[no_mangle]
export function xlang_async_init_workers(): void {
  unsafe { xlang_async_init_workers_impl(); }
}

/** Exported function `xlang_async_io_wait_push`.
 * Implements `xlang_async_io_wait_push`.
 * @param fn *u8
 * @return i32
 */
#[no_mangle]
export function xlang_async_io_wait_push(fn: *u8): i32 {
  unsafe { return xlang_async_io_wait_push_impl(fn); }
}

/** Exported function `xlang_async_maybe_bind_worker`.
 * Implements `xlang_async_maybe_bind_worker`.
 * @param wid u32
 * @return void
 */
#[no_mangle]
export function xlang_async_maybe_bind_worker(wid: u32): void {
  unsafe { xlang_async_maybe_bind_worker_impl(wid); }
}

/** Exported function `xlang_async_drain_queue`.
 * Implements `xlang_async_drain_queue`.
 * @param q *u8
 * @param wid u32
 * @param acc *i32
 * @return i32
 */
#[no_mangle]
export function xlang_async_drain_queue(q: *u8, wid: u32, acc: *i32): i32 {
  unsafe { return xlang_async_drain_queue_impl(q, wid, acc); }
}

/** Exported function `xlang_async_spawn_ctx_echo_task`.
 * Implements `xlang_async_spawn_ctx_echo_task`.
 * @return i32
 */
#[no_mangle]
export function xlang_async_spawn_ctx_echo_task(): i32 {
  unsafe { return xlang_async_spawn_ctx_echo_task_impl(); }
}

// xlang_async_q_occupancy: see function docblock below.

/** Exported function `xlang_async_q_occupancy`.
 * Implements `xlang_async_q_occupancy`.
 * @param head u32
 * @param tail u32
 * @return u32
 */
#[no_mangle]
export function xlang_async_q_occupancy(head: u32, tail: u32): u32 {
  return tail - head;
}

// See implementation.

/** Truthy env gate for XLANG_ASYNC_RUNTIME_TRACE (non-empty and not "0").
 * @return i32 — 1 when trace should run; 0 when disabled/missing/"0"
 * wave230 G.7: env via public pure thin link_abi_getenv (not raw libc getenv).
 * PLATFORM: SHARED — host residual only link_abi_getenv_impl.
 */
#[no_mangle]
export function xlang_async_runtime_trace_enabled(): i32 {
  unsafe {
    // wave230 G.7: XLANG_ASYNC_RUNTIME_TRACE via link_abi_getenv.
    let e: *u8 = link_abi_getenv("XLANG_ASYNC_RUNTIME_TRACE");
    if (e == 0) { return 0; }
    if (e[0] == 0) { return 0; }
    if (e[0] == 48) {
      if (e[1] == 0) { return 0; }
    }
    return 1;
  }
}

// xlang_async_io_wait_enabled: see function docblock below.

/** Gate: XLANG_ASYNC_IO_WAIT == "1" (exact).
 * @return i32 — 1 when IO-wait suspend path is enabled; else 0
 * wave230 G.7: env via public pure thin link_abi_getenv (not raw libc getenv).
 * PLATFORM: SHARED — host residual only link_abi_getenv_impl.
 */
#[no_mangle]
export function xlang_async_io_wait_enabled(): i32 {
  // XLANG_ASYNC_IO_WAIT == "1"
  unsafe {
    // wave230 G.7: XLANG_ASYNC_IO_WAIT via link_abi_getenv.
    let e: *u8 = link_abi_getenv("XLANG_ASYNC_IO_WAIT");
    if (e == 0) { return 0; }
    if (e[0] == 49) {
      if (e[1] == 0) { return 1; }
    }
  }
}

/** Gate: XLANG_ASYNC_AFFINITY == "1" (exact).
 * @return i32 — 1 when worker drain should bind CPU; else 0
 * wave230 G.7: env via public pure thin link_abi_getenv (not raw libc getenv).
 * PLATFORM: SHARED — host residual only link_abi_getenv_impl.
 */
#[no_mangle]
export function xlang_async_affinity_enabled(): i32 {
  // XLANG_ASYNC_AFFINITY == "1"
  unsafe {
    // wave230 G.7: XLANG_ASYNC_AFFINITY via link_abi_getenv.
    let e: *u8 = link_abi_getenv("XLANG_ASYNC_AFFINITY");
    if (e == 0) { return 0; }
    if (e[0] == 49) {
      if (e[1] == 0) { return 1; }
    }
  }
}

// Parse unsigned decimal; defaults handled by callers.
/** Exported function `env_parse_u32_default`.
 * Implements `env_parse_u32_default`.
 * @param e *u8
 * @param defv u32
 * @return u32
 */
export function env_parse_u32_default(e: *u8, defv: u32): u32 {
  if (e == 0) { return defv; }
  if (e[0] == 0) { return defv; }
  let v: u32 = 0;
  let i: i32 = 0;
  while (i < 16) {
    let c: u8 = e[i];
    if (c < 48) { break; }
    if (c > 57) { break; }
    v = v * 10 + (c - 48);
    i = i + 1;
  }
  if (i == 0) { return defv; }
  return v;
}

/** Parse XLANG_ASYNC_RUNTIME_TRACE_TOPN (clamp 1..64, default 20).
 * @return u32 — top-N events for trace summary
 * wave230 G.7: env via public pure thin link_abi_getenv (not raw libc getenv).
 * PLATFORM: SHARED — host residual only link_abi_getenv_impl.
 */
#[no_mangle]
export function xlang_async_trace_topn(): u32 {
  unsafe {
    // wave230 G.7: XLANG_ASYNC_RUNTIME_TRACE_TOPN via link_abi_getenv.
    let e: *u8 = link_abi_getenv("XLANG_ASYNC_RUNTIME_TRACE_TOPN");
    let v: u32 = env_parse_u32_default(e, 20);
    if (v < 1) { return 1; }
    if (v > 64) { return 64; }
    return v;
  }
  return 20;
}

/** Parse XLANG_ASYNC_RUNTIME_TRACE_SAMPLE (min 1, default 1).
 * @return u32 — sample rate (1 = every event)
 * wave230 G.7: env via public pure thin link_abi_getenv (not raw libc getenv).
 * PLATFORM: SHARED — host residual only link_abi_getenv_impl.
 */
#[no_mangle]
export function xlang_async_trace_sample_rate(): u32 {
  unsafe {
    // wave230 G.7: XLANG_ASYNC_RUNTIME_TRACE_SAMPLE via link_abi_getenv.
    let e: *u8 = link_abi_getenv("XLANG_ASYNC_RUNTIME_TRACE_SAMPLE");
    let v: u32 = env_parse_u32_default(e, 1);
    if (v < 1) { return 1; }
    return v;
  }
  return 1;
}

/** Parse XLANG_ASYNC_RUNTIME_TRACE_SLOW_US (default 500 microseconds).
 * @return u64 — slow-event threshold in microseconds
 * wave230 G.7: env via public pure thin link_abi_getenv (not raw libc getenv).
 * PLATFORM: SHARED — host residual only link_abi_getenv_impl.
 */
#[no_mangle]
export function xlang_async_trace_slow_us(): u64 {
  unsafe {
    // wave230 G.7: XLANG_ASYNC_RUNTIME_TRACE_SLOW_US via link_abi_getenv.
    let e: *u8 = link_abi_getenv("XLANG_ASYNC_RUNTIME_TRACE_SLOW_US");
    let v: u32 = env_parse_u32_default(e, 500);
    return v;
  }
  return 500;
}
