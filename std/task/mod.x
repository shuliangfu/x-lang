// Copyright (C) 2026 Shuliang Fu &lt;admin@shuliangfu.com&gt;
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see &lt;https://www.gnu.org/licenses/&gt;.

// std.task — 任务组与结构化并发（STD-089）
//
// 【文件职责】
// TaskGroup / JoinSet 封装 std.async spawn + drain；Context 取消传播；
// 结构化并发 leak 检测；Supervisor 重试。
//
// 【对标】Go errgroup、Rust tokio JoinSet、结构化并发最小子集。

const context = import("std.context");

/** TaskGroup 句柄。 */
allow(padding) struct TaskGroup {
  handle: i64;
}

/** JoinSet 句柄。 */
allow(padding) struct JoinSet {
  handle: i64;
}

/** 成功。 */
function err_ok(): i32 { return 0; }
/** 空指针/非法句柄。 */
function err_null(): i32 { return -1; }
/** 容量已满。 */
function err_full(): i32 { return -2; }
/** 已取消。 */
function err_cancelled(): i32 { return -3; }
/** 未 join 泄漏。 */
function err_leak(): i32 { return -4; }
/** 其它非法状态。 */
function err_invalid(): i32 { return -5; }

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

/** 烟测用回显任务入口。 */
function echo(): i32 {
  unsafe { return task_echo_fn_c(); }
}

/** 烟测用回显任务函数指针。 */
function echo_ptr(): *u8 {
  unsafe { return task_echo_fn_ptr_c(); }
}

/** 创建 TaskGroup。 */
function new(capacity: i32): TaskGroup {
  let h: i64 = 0;
  unsafe { h = task_group_create_c(capacity); }
  return TaskGroup { handle: h };
}

/** 释放 TaskGroup。 */
function free(tg: *TaskGroup): void {
  let zero: i64 = 0;
  if (tg == 0) { return; }
  if (tg.handle != zero) {
    unsafe { task_group_free_c(tg.handle); }
    tg.handle = zero;
  }
}

/** 绑定 Context 以传播取消。 */
function bind(tg: *TaskGroup, ctx: Context): void {
  let zero: i64 = 0;
  if (tg == 0 || tg.handle == zero) { return; }
  unsafe { task_group_bind_context_c(tg.handle, ctx.handle); }
}

/** 提交任务（fn 为 C 协程入口指针）。 */
function spawn(tg: *TaskGroup, fn: *u8, seed: i32): i32 {
  let zero: i64 = 0;
  if (tg == 0 || tg.handle == zero || fn == 0) { return err_null(); }
  unsafe { return task_group_spawn_c(tg.handle, fn, seed); }
}

/** 等待组内全部任务完成；返回结果之和。 */
function join(tg: *TaskGroup): i32 {
  let zero: i64 = 0;
  if (tg == 0 || tg.handle == zero) { return err_null(); }
  unsafe { return task_group_join_c(tg.handle); }
}

/** 未 join 的 pending 任务数。 */
function pending(tg: *TaskGroup): i32 {
  let zero: i64 = 0;
  if (tg == 0 || tg.handle == zero) { return err_null(); }
  unsafe { return task_group_pending_c(tg.handle); }
}

/** 结构化并发边界检查；泄漏返回 err_leak()。 */
function check_leak(tg: *TaskGroup): i32 {
  let zero: i64 = 0;
  if (tg == 0 || tg.handle == zero) { return err_null(); }
  unsafe { return task_group_check_leak_c(tg.handle); }
}

/** 取消绑定 Context。 */
function cancel(tg: *TaskGroup): void {
  let zero: i64 = 0;
  if (tg == 0 || tg.handle == zero) { return; }
  unsafe { task_group_cancel_c(tg.handle); }
}

/** 上次 join 累计结果。 */
function total(tg: *TaskGroup): i64 {
  let zero: i64 = 0;
  if (tg == 0 || tg.handle == zero) { return zero; }
  unsafe { return task_group_join_total_c(tg.handle); }
}

/** 创建 JoinSet。 */
function set_new(capacity: i32): JoinSet {
  let h: i64 = 0;
  unsafe { h = join_set_create_c(capacity); }
  return JoinSet { handle: h };
}

/** 释放 JoinSet。 */
function set_free(js: *JoinSet): void {
  let zero: i64 = 0;
  if (js == 0) { return; }
  if (js.handle != zero) {
    unsafe { join_set_free_c(js.handle); }
    js.handle = zero;
  }
}

/** JoinSet 提交任务。 */
function set_spawn(js: *JoinSet, fn: *u8, seed: i32): i32 {
  let zero: i64 = 0;
  if (js == 0 || js.handle == zero || fn == 0) { return err_null(); }
  unsafe { return join_set_spawn_c(js.handle, fn, seed); }
}

/** JoinSet 等待全部完成。 */
function set_join(js: *JoinSet): i32 {
  let zero: i64 = 0;
  if (js == 0 || js.handle == zero) { return err_null(); }
  unsafe { return join_set_join_c(js.handle); }
}

/** JoinSet 泄漏检测。 */
function set_check_leak(js: *JoinSet): i32 {
  let zero: i64 = 0;
  if (js == 0 || js.handle == zero) { return err_null(); }
  unsafe { return join_set_check_leak_c(js.handle); }
}

/** Supervisor：带退避的重试执行。 */
function retry(fn: *u8, seed: i32, max_attempts: i32, backoff_ns: i64): i32 {
  if (fn == 0) { return err_null(); }
  unsafe { return task_supervise_retry_c(fn, seed, max_attempts, backoff_ns); }
}
