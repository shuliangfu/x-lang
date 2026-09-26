// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// std_async_formal_darwin.x — Darwin arm64 body of std/async/async.o.
//
// These four names are the leftover import faces. The scheduler body
// stays in runtime_scheduler_glue. This file only forwards.
// placeholder returns 0. drain, reset, and the net/fs smoke call the
// existing C symbols. Each function makes at most one call.
// Linux and Windows keep formal_surface.c.
// PLATFORM: MACOS|DARWIN arm64.

extern function xlang_async_run_drain_until_idle(): i32;
extern function xlang_async_queue_reset(): void;
extern function xlang_async_net_fs_smoke_c(): i32;

/**
 * Anchor for this Darwin async object.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_async_formal_darwin_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Module smoke marker. Matches the C face: no scheduler call.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_async_placeholder(): i32 {
  return 0;
}

/**
 * Drain the scheduler until it is idle.
 * @return i32 — xlang_async_run_drain_until_idle
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_async_drain_idle(): i32 {
  let n: i32 = 0;
  unsafe {
    n = xlang_async_run_drain_until_idle();
  }
  return n;
}

/**
 * Reset the scheduler queue. The body lives in the scheduler glue.
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_async_scheduler_reset(): void {
  unsafe {
    xlang_async_queue_reset();
  }
}

/**
 * Run the net and filesystem async smoke in the scheduler glue.
 * @return i32 — xlang_async_net_fs_smoke_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_async_net_fs_async_smoke(): i32 {
  let n: i32 = 0;
  unsafe {
    n = xlang_async_net_fs_smoke_c();
  }
  return n;
}
