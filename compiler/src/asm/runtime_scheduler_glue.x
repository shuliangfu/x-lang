// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-18：runtime_scheduler_glue 产品源迁 seeds/runtime_scheduler_glue.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_scheduler_glue.from_x.c → runtime_scheduler_glue.o
// G-02f-106：+ async trace / io_wait / affinity 薄门闩。
// G-02f-107：+ bound/suspend/occupancy/coop step 薄门闩。

extern "C" function shu_async_runtime_trace_enabled_impl(): i32;
extern "C" function shu_async_trace_topn_impl(): i32;
extern "C" function shu_async_trace_sample_rate_impl(): i32;
extern "C" function shu_async_trace_slow_us_impl(): u64;
extern "C" function shu_async_trace_now_us_impl(): u64;
extern "C" function shux_async_io_wait_enabled_impl(): i32;
extern "C" function shux_async_affinity_enabled_impl(): i32;

function runtime_scheduler_glue_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-106：async scheduler helpers 门闩 ---- */

#[no_mangle]
function shu_async_runtime_trace_enabled(): i32 {
  unsafe { return shu_async_runtime_trace_enabled_impl(); }
  return 0;
}

#[no_mangle]
function shu_async_trace_topn(): i32 {
  unsafe { return shu_async_trace_topn_impl(); }
  return 0;
}

#[no_mangle]
function shu_async_trace_sample_rate(): i32 {
  unsafe { return shu_async_trace_sample_rate_impl(); }
  return 0;
}

#[no_mangle]
function shu_async_trace_slow_us(): u64 {
  unsafe { return shu_async_trace_slow_us_impl(); }
  return 0;
}

#[no_mangle]
function shu_async_trace_now_us(): u64 {
  unsafe { return shu_async_trace_now_us_impl(); }
  return 0;
}

#[no_mangle]
function shux_async_io_wait_enabled(): i32 {
  unsafe { return shux_async_io_wait_enabled_impl(); }
  return 0;
}

#[no_mangle]
function shux_async_affinity_enabled(): i32 {
  unsafe { return shux_async_affinity_enabled_impl(); }
  return 0;
}

extern "C" function shux_async_bound_ctx_cancelled_impl(ctx: *u8): i32;
extern "C" function shux_async_take_suspend_io_flag_impl(): i32;
extern "C" function shux_async_q_occupancy_impl(): i32;
extern "C" function shu_coop_frame_step_jmp_impl(frame: *u8): i32;
extern "C" function shu_coop_frame_step_switch_impl(frame: *u8): i32;

/* ---- G-02f-107：async scheduler step 门闩 ---- */

#[no_mangle]
function shux_async_bound_ctx_cancelled(ctx: *u8): i32 {
  unsafe { return shux_async_bound_ctx_cancelled_impl(ctx); }
  return 0;
}

#[no_mangle]
function shux_async_take_suspend_io_flag(): i32 {
  unsafe { return shux_async_take_suspend_io_flag_impl(); }
  return 0;
}


#[no_mangle]
function shu_coop_frame_step_jmp(frame: *u8): i32 {
  unsafe { return shu_coop_frame_step_jmp_impl(frame); }
  return 0;
}

#[no_mangle]
function shu_coop_frame_step_switch(frame: *u8): i32 {
  unsafe { return shu_coop_frame_step_switch_impl(frame); }
  return 0;
}

// G-02f-108：+ init_workers / io_wait_push / bind / drain / echo 薄门闩。

extern "C" function shux_async_init_workers_impl(): void;
extern "C" function shux_async_io_wait_push_impl(fn: *u8): i32;
extern "C" function shux_async_maybe_bind_worker_impl(wid: u32): void;
extern "C" function shux_async_drain_queue_impl(q: *u8, wid: u32, acc: *i32): i32;
extern "C" function shux_async_spawn_ctx_echo_task_impl(): i32;

/* ---- G-02f-108：scheduler workers/queue 门闩 ---- */

#[no_mangle]
function shux_async_init_workers(): void {
  unsafe { shux_async_init_workers_impl(); }
}

#[no_mangle]
function shux_async_io_wait_push(fn: *u8): i32 {
  unsafe { return shux_async_io_wait_push_impl(fn); }
  return 0;
}

#[no_mangle]
function shux_async_maybe_bind_worker(wid: u32): void {
  unsafe { shux_async_maybe_bind_worker_impl(wid); }
}

#[no_mangle]
function shux_async_drain_queue(q: *u8, wid: u32, acc: *i32): i32 {
  unsafe { return shux_async_drain_queue_impl(q, wid, acc); }
  return 0;
}

#[no_mangle]
function shux_async_spawn_ctx_echo_task(): i32 {
  unsafe { return shux_async_spawn_ctx_echo_task_impl(); }
  return 0;
}

// G-02f-115：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
function shux_async_q_occupancy(head: u32, tail: u32): u32 {
  return tail - head;
}
