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

// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.

export const TASK_OK: i32 = 0;
export const TASK_ERR_NULL: i32 = -1;
export const TASK_ERR_FULL: i32 = -2;
export const TASK_ERR_CANCELLED: i32 = -3;
export const TASK_ERR_LEAK: i32 = -4;
export const TASK_ERR_INVALID: i32 = -5;

export const TASK_MAX: i32 = 32;

/* See implementation. */
allow(padding) struct TaskGroupMem {
  capacity: i32;
  spawned: i32;
  joined: i32;
  ctx_handle: i64;
  join_total: i64;
}

/* See implementation. */
allow(padding) struct JoinSetMem {
  capacity: i32;
  spawned: i32;
  joined: i32;
  join_total: i64;
}

extern function xlang_async_spawn_i32(fn: *u8, seed: i32): i32;
extern function xlang_async_run_seed_reset(): void;
extern function xlang_async_queue_reset(): void;
extern function xlang_async_run_drain_until_idle(): i32;
extern function xlang_async_run_seed_valid(): i32;
extern function xlang_async_run_seed_take_i32(): i32;
extern function xlang_async_bind_context_c(ctx_handle: i64): void;
extern function ctx_is_cancelled_c(handle: i64): i32;
extern function ctx_cancel_c(handle: i64): void;
extern function time_sleep_ns_c(ns: i64): void;
extern "C" function calloc(nmemb: usize, size: usize): *u8;
extern "C" function free(ptr: *u8): void;

/**
 * See implementation.
 */
extern function xlang_async_task_echo_fn_ptr_c(): *u8;

/** Exported function `task_f_task_v1_marker_c`.
 * Implements `task_f_task_v1_marker_c`.
 * @return i32
 */
export function task_f_task_v1_marker_c(): i32 {
  return 1;
}

/** Exported function `task_f_task_v2_marker_c`.
 * Implements `task_f_task_v2_marker_c`.
 * @return i32
 */
export function task_f_task_v2_marker_c(): i32 {
  return 1;
}

/** Exported function `tg_from_handle`.
 * Implements `tg_from_handle`.
 * @param handle i64
 * @return *TaskGroupMem
 */
export function tg_from_handle(handle: i64): *TaskGroupMem {
  if (handle == 0) {
    return 0 as *TaskGroupMem;
  }
  return handle as *TaskGroupMem;
}

/** Exported function `js_from_handle`.
 * Implements `js_from_handle`.
 * @param handle i64
 * @return *JoinSetMem
 */
export function js_from_handle(handle: i64): *JoinSetMem {
  if (handle == 0) {
    return 0 as *JoinSetMem;
  }
  return handle as *JoinSetMem;
}

/** Exported function `tg_is_cancelled`.
 * Implements `tg_is_cancelled`.
 * @param g *TaskGroupMem
 * @return i32
 */
export function tg_is_cancelled(g: *TaskGroupMem): i32 {
  if (g == 0) {
    return 0;
  }
  if (g.ctx_handle == 0) {
    return 0;
  }
  unsafe { return ctx_is_cancelled_c(g.ctx_handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `task_echo_fn_c`.
 * Implements `task_echo_fn_c`.
 * @return i32
 */
export function task_echo_fn_c(): i32 {
  let seed: i32 = 0;
  unsafe { if (xlang_async_run_seed_valid() != 0) {
    seed = xlang_async_run_seed_take_i32();
  } }
  return seed * 10;
}

/** Exported function `task_echo_fn_ptr_c`.
 * Implements `task_echo_fn_ptr_c`.
 * @return *u8
 */
export function task_echo_fn_ptr_c(): *u8 {
  unsafe { return xlang_async_task_echo_fn_ptr_c(); }
  return 0 as *u8; // unreachable — typeck workaround
}

/** Exported function `task_group_create_c`.
 * Implements `task_group_create_c`.
 * @param capacity i32
 * @return i64
 */
export function task_group_create_c(capacity: i32): i64 {
  let cap: i32 = capacity;
  let raw: *u8 = 0 as *u8;
  let g: *TaskGroupMem = 0 as *TaskGroupMem;
  if (cap <= 0 || cap > TASK_MAX) {
    return 0;
  }
  unsafe { raw = calloc(1, 32); }
  if (raw == 0) {
    return 0;
  }
  g = raw as *TaskGroupMem;
  g.capacity = cap;
  return raw as i64;
}

/** Exported function `task_group_free_c`.
 * Memory management helper `task_group_free_c`.
 * @param handle i64
 * @return void
 */
export function task_group_free_c(handle: i64): void {
  let g: *TaskGroupMem = tg_from_handle(handle);
  if (g != 0) {
    unsafe { free(g as *u8); }
  }
}

/** Exported function `task_group_bind_context_c`.
 * Implements `task_group_bind_context_c`.
 * @param handle i64
 * @param ctx_handle i64
 * @return void
 */
export function task_group_bind_context_c(handle: i64, ctx_handle: i64): void {
  let g: *TaskGroupMem = tg_from_handle(handle);
  if (g == 0) {
    return;
  }
  g.ctx_handle = ctx_handle;
}

/** Exported function `task_group_spawn_c`.
 * Implements `task_group_spawn_c`.
 * @param handle i64
 * @param fn *u8
 * @param seed i32
 * @return i32
 */
export function task_group_spawn_c(handle: i64, fn: *u8, seed: i32): i32 {
  let g: *TaskGroupMem = tg_from_handle(handle);
  let spawn_r: i32 = 0;
  if (g == 0 || fn == 0) {
    return TASK_ERR_NULL;
  }
  if (tg_is_cancelled(g) != 0) {
    return TASK_ERR_CANCELLED;
  }
  if (g.spawned >= g.capacity) {
    return TASK_ERR_FULL;
  }
  unsafe { spawn_r = xlang_async_spawn_i32(fn, seed); }
  if (spawn_r != 0) {
    if (spawn_r == -2 || tg_is_cancelled(g) != 0) {
      return TASK_ERR_CANCELLED;
    }
    return TASK_ERR_INVALID;
  }
  g.spawned = g.spawned + 1;
  g.joined = 0;
  return TASK_OK;
}

/** Exported function `task_group_join_c`.
 * Implements `task_group_join_c`.
 * @param handle i64
 * @return i32
 */
export function task_group_join_c(handle: i64): i32 {
  let g: *TaskGroupMem = tg_from_handle(handle);
  let total: i32 = 0;
  if (g == 0) {
    return TASK_ERR_NULL;
  }
  if (tg_is_cancelled(g) != 0) {
    return TASK_ERR_CANCELLED;
  }
  if (g.spawned <= 0) {
    g.joined = 1;
    g.join_total = 0 as i64;
    return TASK_OK;
  }
  if (g.ctx_handle != 0) {
    unsafe { xlang_async_bind_context_c(g.ctx_handle); }
  }
  unsafe { total = xlang_async_run_drain_until_idle(); }
  if (total == -3) {
    return TASK_ERR_CANCELLED;
  }
  g.join_total = total as i64;
  g.joined = 1;
  g.spawned = 0;
  return total;
}

/** Exported function `task_group_pending_c`.
 * Implements `task_group_pending_c`.
 * @param handle i64
 * @return i32
 */
export function task_group_pending_c(handle: i64): i32 {
  let g: *TaskGroupMem = tg_from_handle(handle);
  if (g == 0) {
    return TASK_ERR_NULL;
  }
  return g.spawned;
}

/** Exported function `task_group_check_leak_c`.
 * Implements `task_group_check_leak_c`.
 * @param handle i64
 * @return i32
 */
export function task_group_check_leak_c(handle: i64): i32 {
  let g: *TaskGroupMem = tg_from_handle(handle);
  if (g == 0) {
    return TASK_ERR_NULL;
  }
  if (g.spawned > 0 && g.joined == 0) {
    return TASK_ERR_LEAK;
  }
  return TASK_OK;
}

/** Exported function `task_group_cancel_c`.
 * Implements `task_group_cancel_c`.
 * @param handle i64
 * @return void
 */
export function task_group_cancel_c(handle: i64): void {
  let g: *TaskGroupMem = tg_from_handle(handle);
  if (g == 0 || g.ctx_handle == 0) {
    return;
  }
  unsafe { ctx_cancel_c(g.ctx_handle); }
}

/** Exported function `task_group_join_total_c`.
 * Implements `task_group_join_total_c`.
 * @param handle i64
 * @return i64
 */
export function task_group_join_total_c(handle: i64): i64 {
  let g: *TaskGroupMem = tg_from_handle(handle);
  if (g == 0) {
    return 0;
  }
  return g.join_total;
}

/** Exported function `join_set_create_c`.
 * Implements `join_set_create_c`.
 * @param capacity i32
 * @return i64
 */
export function join_set_create_c(capacity: i32): i64 {
  let cap: i32 = capacity;
  let raw: *u8 = 0 as *u8;
  let s: *JoinSetMem = 0 as *JoinSetMem;
  if (cap <= 0 || cap > TASK_MAX) {
    return 0;
  }
  unsafe { raw = calloc(1, 20); }
  if (raw == 0) {
    return 0;
  }
  s = raw as *JoinSetMem;
  s.capacity = cap;
  return raw as i64;
}

/** Exported function `join_set_free_c`.
 * Memory management helper `join_set_free_c`.
 * @param handle i64
 * @return void
 */
export function join_set_free_c(handle: i64): void {
  let s: *JoinSetMem = js_from_handle(handle);
  if (s != 0) {
    unsafe { free(s as *u8); }
  }
}

/** JoinSet spawn。 */
export function join_set_spawn_c(handle: i64, fn: *u8, seed: i32): i32 {
  let s: *JoinSetMem = js_from_handle(handle);
  if (s == 0 || fn == 0) {
    return TASK_ERR_NULL;
  }
  if (s.spawned >= s.capacity) {
    return TASK_ERR_FULL;
  }
  unsafe { if (xlang_async_spawn_i32(fn, seed) != 0) {
    return TASK_ERR_INVALID;
  } }
  s.spawned = s.spawned + 1;
  s.joined = 0;
  return TASK_OK;
}

/** Exported function `join_set_join_c`.
 * Implements `join_set_join_c`.
 * @param handle i64
 * @return i32
 */
export function join_set_join_c(handle: i64): i32 {
  let s: *JoinSetMem = js_from_handle(handle);
  let total: i32 = 0;
  if (s == 0) {
    return TASK_ERR_NULL;
  }
  if (s.spawned <= 0) {
    s.joined = 1;
    s.join_total = 0 as i64;
    return TASK_OK;
  }
  unsafe { total = xlang_async_run_drain_until_idle(); }
  s.join_total = total as i64;
  s.joined = 1;
  s.spawned = 0;
  return total;
}

/** Exported function `join_set_check_leak_c`.
 * Implements `join_set_check_leak_c`.
 * @param handle i64
 * @return i32
 */
export function join_set_check_leak_c(handle: i64): i32 {
  let s: *JoinSetMem = js_from_handle(handle);
  if (s == 0) {
    return TASK_ERR_NULL;
  }
  if (s.spawned > 0 && s.joined == 0) {
    return TASK_ERR_LEAK;
  }
  return TASK_OK;
}

/** Exported function `task_supervise_retry_c`.
 * Implements `task_supervise_retry_c`.
 * @param fn *u8
 * @param seed i32
 * @param max_attempts i32
 * @param backoff_ns i64
 * @return i32
 */
export function task_supervise_retry_c(fn: *u8, seed: i32, max_attempts: i32, backoff_ns: i64): i32 {
  let attempt: i32 = 0;
  let total: i32 = 0;
  if (fn == 0 || max_attempts <= 0) {
    return TASK_ERR_NULL;
  }
  while (attempt < max_attempts) {
    unsafe { xlang_async_run_seed_reset(); }
    unsafe { xlang_async_queue_reset(); }
    unsafe { if (xlang_async_spawn_i32(fn, seed) != 0) {
      return TASK_ERR_INVALID;
    } }
    unsafe { total = xlang_async_run_drain_until_idle(); }
    if (total >= 0) {
      return total;
    }
    if (backoff_ns > 0) {
      unsafe { time_sleep_ns_c(backoff_ns); }
    }
    attempt = attempt + 1;
  }
  return TASK_ERR_INVALID;
}

/** Exported function `task_smoke_c`.
 * Implements `task_smoke_c`.
 * @return i32
 */
export function task_smoke_c(): i32 {
  let grp: i64 = task_group_create_c(4);
  let js: i64 = join_set_create_c(2);
  let echo_fn: *u8 = task_echo_fn_ptr_c();
  let r: i32 = 0;
  if (grp == 0 || js == 0) {
    return 1;
  }
  unsafe { xlang_async_run_seed_reset(); }
  unsafe { xlang_async_queue_reset(); }
  if (task_group_spawn_c(grp, echo_fn, 2) != TASK_OK) {
    return 2;
  }
  if (task_group_spawn_c(grp, echo_fn, 3) != TASK_OK) {
    return 3;
  }
  if (task_group_check_leak_c(grp) != TASK_ERR_LEAK) {
    return 4;
  }
  r = task_group_join_c(grp);
  if (r != 50) {
    return 5;
  }
  if (task_group_check_leak_c(grp) != TASK_OK) {
    return 6;
  }
  unsafe { xlang_async_run_seed_reset(); }
  unsafe { xlang_async_queue_reset(); }
  if (join_set_spawn_c(js, echo_fn, 4) != TASK_OK) {
    return 7;
  }
  r = join_set_join_c(js);
  if (r != 40) {
    return 8;
  }
  unsafe { xlang_async_run_seed_reset(); }
  unsafe { xlang_async_queue_reset(); }
  r = task_supervise_retry_c(echo_fn, 5, 3, 0);
  if (r != 50) {
    return 9;
  }
  task_group_free_c(grp);
  join_set_free_c(js);
  return 0;
}
