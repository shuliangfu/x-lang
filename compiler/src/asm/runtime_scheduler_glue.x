// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-18：runtime_scheduler_glue 产品源迁 seeds/runtime_scheduler_glue.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_scheduler_glue.from_x.c → runtime_scheduler_glue.o
// G-02f-106：+ async trace / io_wait / affinity 薄门闩。
// G-02f-107：+ bound/suspend/occupancy/coop step 薄门闩。

// G-02f-116/117：trace/io_wait/affinity 真迁 .x 函数体（见文件尾）。
export extern "C" function shu_async_runtime_trace_enabled_impl(): i32;
export extern "C" function shu_async_trace_now_us_impl(): u64;
export extern "C" function getenv(name: *u8): *u8;

export function runtime_scheduler_glue_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-106：async scheduler helpers 门闩 ---- */





#[no_mangle]
export function shu_async_trace_now_us(): u64 {
  unsafe { return shu_async_trace_now_us_impl(); }
}



export extern "C" function shux_async_bound_ctx_cancelled_impl(): i32;
export extern "C" function shux_async_take_suspend_io_flag_impl(): i32;
// G-02f-115：shux_async_q_occupancy 真迁 .x
export extern "C" function shu_coop_frame_step_jmp_impl(frame: *u8): i32;
export extern "C" function shu_coop_frame_step_switch_impl(frame: *u8): i32;

/* ---- G-02f-107：async scheduler step 门闩 ---- */

#[no_mangle]
export function shux_async_bound_ctx_cancelled(): i32 {
  unsafe { return shux_async_bound_ctx_cancelled_impl(); }
}

#[no_mangle]
export function shux_async_take_suspend_io_flag(): i32 {
  unsafe { return shux_async_take_suspend_io_flag_impl(); }
}


#[no_mangle]
export function shu_coop_frame_step_jmp(frame: *u8): i32 {
  unsafe { return shu_coop_frame_step_jmp_impl(frame); }
}

#[no_mangle]
export function shu_coop_frame_step_switch(frame: *u8): i32 {
  unsafe { return shu_coop_frame_step_switch_impl(frame); }
}

// G-02f-108：+ init_workers / io_wait_push / bind / drain / echo 薄门闩。

export extern "C" function shux_async_init_workers_impl(): void;
export extern "C" function shux_async_io_wait_push_impl(fn: *u8): i32;
export extern "C" function shux_async_maybe_bind_worker_impl(wid: u32): void;
export extern "C" function shux_async_drain_queue_impl(q: *u8, wid: u32, acc: *i32): i32;
export extern "C" function shux_async_spawn_ctx_echo_task_impl(): i32;

/* ---- G-02f-108：scheduler workers/queue 门闩 ---- */

#[no_mangle]
export function shux_async_init_workers(): void {
  unsafe { shux_async_init_workers_impl(); }
}

#[no_mangle]
export function shux_async_io_wait_push(fn: *u8): i32 {
  unsafe { return shux_async_io_wait_push_impl(fn); }
}

#[no_mangle]
export function shux_async_maybe_bind_worker(wid: u32): void {
  unsafe { shux_async_maybe_bind_worker_impl(wid); }
}

#[no_mangle]
export function shux_async_drain_queue(q: *u8, wid: u32, acc: *i32): i32 {
  unsafe { return shux_async_drain_queue_impl(q, wid, acc); }
}

#[no_mangle]
export function shux_async_spawn_ctx_echo_task(): i32 {
  unsafe { return shux_async_spawn_ctx_echo_task_impl(); }
}

// G-02f-115：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
export function shux_async_q_occupancy(head: u32, tail: u32): u32 {
  return tail - head;
}

// G-02f-116：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

export extern "C" function getenv(name: *u8): *u8;

#[no_mangle]
export function shu_async_runtime_trace_enabled(): i32 {
  unsafe {
    let e: *u8 = getenv("SHUX_ASYNC_RUNTIME_TRACE");
    if (e == 0) { return 0; }
    if (e[0] == 0) { return 0; }
    if (e[0] == 48) {
      if (e[1] == 0) { return 0; }
    }
    return 1;
  }
}

// G-02f-117：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
export function shux_async_io_wait_enabled(): i32 {
  // SHUX_ASYNC_IO_WAIT == "1"
  unsafe {
    let e: *u8 = getenv("SHUX_ASYNC_IO_WAIT");
    if (e == 0) { return 0; }
    if (e[0] == 49) {
      if (e[1] == 0) { return 1; }
    }
  }
}

#[no_mangle]
export function shux_async_affinity_enabled(): i32 {
  // SHUX_ASYNC_AFFINITY == "1"
  unsafe {
    let e: *u8 = getenv("SHUX_ASYNC_AFFINITY");
    if (e == 0) { return 0; }
    if (e[0] == 49) {
      if (e[1] == 0) { return 1; }
    }
  }
}

// Parse unsigned decimal; defaults handled by callers.
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

#[no_mangle]
export function shu_async_trace_topn(): u32 {
  unsafe {
    let e: *u8 = getenv("SHUX_ASYNC_RUNTIME_TRACE_TOPN");
    let v: u32 = env_parse_u32_default(e, 20);
    if (v < 1) { return 1; }
    if (v > 64) { return 64; }
    return v;
  }
  return 20;
}

#[no_mangle]
export function shu_async_trace_sample_rate(): u32 {
  unsafe {
    let e: *u8 = getenv("SHUX_ASYNC_RUNTIME_TRACE_SAMPLE");
    let v: u32 = env_parse_u32_default(e, 1);
    if (v < 1) { return 1; }
    return v;
  }
  return 1;
}

#[no_mangle]
export function shu_async_trace_slow_us(): u64 {
  unsafe {
    let e: *u8 = getenv("SHUX_ASYNC_RUNTIME_TRACE_SLOW_US");
    let v: u32 = env_parse_u32_default(e, 500);
    return v;
  }
  return 500;
}
