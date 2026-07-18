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
//
// See implementation.

const context = import("std.context");

/* See implementation. */
allow(padding) struct TaskGroup {
  handle: i64;
}

/* See implementation. */
allow(padding) struct JoinSet {
  handle: i64;
}

/** Exported function `err_ok`.
 * Implements `err_ok`.
 * @return i32
 */
export function err_ok(): i32 { return 0; }
/** Exported function `err_null`.
 * Implements `err_null`.
 * @return i32
 */
export function err_null(): i32 { return -1; }
/** Exported function `err_full`.
 * Implements `err_full`.
 * @return i32
 */
export function err_full(): i32 { return -2; }
/** Exported function `err_cancelled`.
 * Implements `err_cancelled`.
 * @return i32
 */
export function err_cancelled(): i32 { return -3; }
/** Exported function `err_leak`.
 * Implements `err_leak`.
 * @return i32
 */
export function err_leak(): i32 { return -4; }
/** Exported function `err_invalid`.
 * Implements `err_invalid`.
 * @return i32
 */
export function err_invalid(): i32 { return -5; }

extern function task_group_create_c(capacity: i32): i64;
extern function task_group_free_c(handle: i64): void;
extern function task_group_bind_context_c(handle: i64, ctx_handle: i64): void;
extern function task_group_spawn_c(handle: i64, fn: *u8, seed: i32): i32;
extern function task_group_join_c(handle: i64): i32;
extern function task_group_pending_c(handle: i64): i32;
extern function task_group_check_leak_c(handle: i64): i32;
extern function task_group_cancel_c(handle: i64): void;
extern function task_group_join_total_c(handle: i64): i64;

extern function join_set_create_c(capacity: i32): i64;
extern function join_set_free_c(handle: i64): void;
extern function join_set_spawn_c(handle: i64, fn: *u8, seed: i32): i32;
extern function join_set_join_c(handle: i64): i32;
extern function join_set_check_leak_c(handle: i64): i32;

extern function task_supervise_retry_c(fn: *u8, seed: i32, max_attempts: i32, backoff_ns: i64): i32;
extern function task_echo_fn_c(): i32;
extern function task_echo_fn_ptr_c(): *u8;

/** Exported function `echo`.
 * Implements `echo`.
 * @return i32
 */
export function echo(): i32 {
  unsafe { return task_echo_fn_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `echo_ptr`.
 * Implements `echo_ptr`.
 * @return *u8
 */
export function echo_ptr(): *u8 {
  unsafe { return task_echo_fn_ptr_c(); }
  return 0 as *u8; // unreachable — typeck workaround
}

/** Exported function `new`.
 * Implements `new`.
 * @param capacity i32
 * @return TaskGroup
 */
export function new(capacity: i32): TaskGroup {
  let h: i64 = 0;
  unsafe { h = task_group_create_c(capacity); }
  return TaskGroup { handle: h };
}

/** Exported function `free`.
 * Memory management helper `free`.
 * @param tg *TaskGroup
 * @return void
 */
export function free(tg: *TaskGroup): void {
  let zero: i64 = 0;
  if (tg == 0) { return; }
  if (tg.handle != zero) {
    unsafe { task_group_free_c(tg.handle); }
    tg.handle = zero;
  }
}

/** Exported function `bind`.
 * Implements `bind`.
 * @param tg *TaskGroup
 * @param ctx Context
 * @return void
 */
export function bind(tg: *TaskGroup, ctx: Context): void {
  let zero: i64 = 0;
  if (tg == 0 || tg.handle == zero) { return; }
  unsafe { task_group_bind_context_c(tg.handle, ctx.handle); }
}

/** Exported function `spawn`.
 * Implements `spawn`.
 * @param tg *TaskGroup
 * @param fn *u8
 * @param seed i32
 * @return i32
 */
export function spawn(tg: *TaskGroup, fn: *u8, seed: i32): i32 {
  let zero: i64 = 0;
  if (tg == 0 || tg.handle == zero || fn == 0) { return err_null(); }
  unsafe { return task_group_spawn_c(tg.handle, fn, seed); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `join`.
 * Implements `join`.
 * @param tg *TaskGroup
 * @return i32
 */
export function join(tg: *TaskGroup): i32 {
  let zero: i64 = 0;
  if (tg == 0 || tg.handle == zero) { return err_null(); }
  unsafe { return task_group_join_c(tg.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `pending`.
 * Implements `pending`.
 * @param tg *TaskGroup
 * @return i32
 */
export function pending(tg: *TaskGroup): i32 {
  let zero: i64 = 0;
  if (tg == 0 || tg.handle == zero) { return err_null(); }
  unsafe { return task_group_pending_c(tg.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `check_leak`.
 * Implements `check_leak`.
 * @param tg *TaskGroup
 * @return i32
 */
export function check_leak(tg: *TaskGroup): i32 {
  let zero: i64 = 0;
  if (tg == 0 || tg.handle == zero) { return err_null(); }
  unsafe { return task_group_check_leak_c(tg.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `cancel`.
 * Implements `cancel`.
 * @param tg *TaskGroup
 * @return void
 */
export function cancel(tg: *TaskGroup): void {
  let zero: i64 = 0;
  if (tg == 0 || tg.handle == zero) { return; }
  unsafe { task_group_cancel_c(tg.handle); }
}

/** Exported function `total`.
 * Implements `total`.
 * @param tg *TaskGroup
 * @return i64
 */
export function total(tg: *TaskGroup): i64 {
  let zero: i64 = 0;
  if (tg == 0 || tg.handle == zero) { return zero; }
  unsafe { return task_group_join_total_c(tg.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `set_new`.
 * Implements `set_new`.
 * @param capacity i32
 * @return JoinSet
 */
export function set_new(capacity: i32): JoinSet {
  let h: i64 = 0;
  unsafe { h = join_set_create_c(capacity); }
  return JoinSet { handle: h };
}

/** Exported function `set_free`.
 * Memory management helper `set_free`.
 * @param js *JoinSet
 * @return void
 */
export function set_free(js: *JoinSet): void {
  let zero: i64 = 0;
  if (js == 0) { return; }
  if (js.handle != zero) {
    unsafe { join_set_free_c(js.handle); }
    js.handle = zero;
  }
}

/** Exported function `set_spawn`.
 * Implements `set_spawn`.
 * @param js *JoinSet
 * @param fn *u8
 * @param seed i32
 * @return i32
 */
export function set_spawn(js: *JoinSet, fn: *u8, seed: i32): i32 {
  let zero: i64 = 0;
  if (js == 0 || js.handle == zero || fn == 0) { return err_null(); }
  unsafe { return join_set_spawn_c(js.handle, fn, seed); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `set_join`.
 * Implements `set_join`.
 * @param js *JoinSet
 * @return i32
 */
export function set_join(js: *JoinSet): i32 {
  let zero: i64 = 0;
  if (js == 0 || js.handle == zero) { return err_null(); }
  unsafe { return join_set_join_c(js.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `set_check_leak`.
 * Implements `set_check_leak`.
 * @param js *JoinSet
 * @return i32
 */
export function set_check_leak(js: *JoinSet): i32 {
  let zero: i64 = 0;
  if (js == 0 || js.handle == zero) { return err_null(); }
  unsafe { return join_set_check_leak_c(js.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `retry`.
 * Implements `retry`.
 * @param fn *u8
 * @param seed i32
 * @param max_attempts i32
 * @param backoff_ns i64
 * @return i32
 */
export function retry(fn: *u8, seed: i32, max_attempts: i32, backoff_ns: i64): i32 {
  if (fn == 0) { return err_null(); }
  unsafe { return task_supervise_retry_c(fn, seed, max_attempts, backoff_ns); }
  return 0; // unreachable — typeck workaround
}
