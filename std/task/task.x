// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
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
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// std/task/task.x — F-task v2：TaskGroup/JoinSet 纯 .x（替代 task_async_glue.c）
//
// 【文件职责】
// TaskGroup / JoinSet 封装 std.async spawn + drain；Context 取消传播；
// 结构化并发 leak 检测；Supervisor 重试；烟测入口。
// 经 shux -backend asm 编译为 task.o；对外 API 在 mod.x。
//
// 【依赖】scheduler（spawn/drain/seed）、context（取消）、time（退避）、libc（calloc/free）。

const TASK_OK: i32 = 0;
const TASK_ERR_NULL: i32 = -1;
const TASK_ERR_FULL: i32 = -2;
const TASK_ERR_CANCELLED: i32 = -3;
const TASK_ERR_LEAK: i32 = -4;
const TASK_ERR_INVALID: i32 = -5;

const TASK_MAX: i32 = 32;

/** TaskGroup 内存布局（与 v1 C task_group_t 一致）。 */
allow(padding) struct TaskGroupMem {
  capacity: i32;
  spawned: i32;
  joined: i32;
  ctx_handle: i64;
  join_total: i64;
}

/** JoinSet 内存布局（与 v1 C join_set_t 一致）。 */
allow(padding) struct JoinSetMem {
  capacity: i32;
  spawned: i32;
  joined: i32;
  join_total: i64;
}

extern function shux_async_spawn_i32(fn: *u8, seed: i32): i32;
extern function shux_async_run_seed_reset(): void;
extern function shux_async_queue_reset(): void;
extern function shux_async_run_drain_until_idle(): i32;
extern function shux_async_run_seed_valid(): i32;
extern function shux_async_run_seed_take_i32(): i32;
extern function shux_async_bind_context_c(ctx_handle: i64): void;
extern function ctx_is_cancelled_c(handle: i64): i32;
extern function ctx_cancel_c(handle: i64): void;
extern function time_sleep_ns_c(ns: i64): void;
extern function calloc(nmemb: usize, size: usize): *u8;
extern function free(ptr: *u8): void;

/**
 * F-task v2：.x 尚不能同模块取函数址；scheduler 在链 task.o 时解析 task_echo_fn_c 符号。
 */
extern function shux_async_task_echo_fn_ptr_c(): *u8;

/** F-task v1 版本标记；供 v1 聚合 gate 校验。 */
function task_f_task_v1_marker_c(): i32 {
  return 1;
}

/** F-task v2 逻辑全量 .x 标记。 */
function task_f_task_v2_marker_c(): i32 {
  return 1;
}

/** handle → TaskGroup 指针；0 返回 null。 */
function tg_from_handle(handle: i64): *TaskGroupMem {
  if (handle == 0) {
    return 0;
  }
  return handle as *TaskGroupMem;
}

/** handle → JoinSet 指针；0 返回 null。 */
function js_from_handle(handle: i64): *JoinSetMem {
  if (handle == 0) {
    return 0;
  }
  return handle as *JoinSetMem;
}

/** 组是否已取消（绑定 Context 时沿链检测）。 */
function tg_is_cancelled(g: *TaskGroupMem): i32 {
  if (g == 0) {
    return 0;
  }
  if (g.ctx_handle == 0) {
    return 0;
  }
  unsafe { return ctx_is_cancelled_c(g.ctx_handle); }
}

/** 烟测/demo 任务：返回 seed*10。 */
function task_echo_fn_c(): i32 {
  let seed: i32 = 0;
  unsafe { if (shux_async_run_seed_valid() != 0) {
    seed = shux_async_run_seed_take_i32();
  } }
  return seed * 10;
}

/** 返回 demo 任务函数指针（供 .x spawn 烟测）。 */
function task_echo_fn_ptr_c(): *u8 {
  unsafe { return shux_async_task_echo_fn_ptr_c(); }
}

/** 创建 TaskGroup；capacity 须 1..TASK_MAX。 */
function task_group_create_c(capacity: i32): i64 {
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

/** 释放 TaskGroup；未 join 且 spawned>0 时仍释放（调用方应 check_leak）。 */
function task_group_free_c(handle: i64): void {
  let g: *TaskGroupMem = tg_from_handle(handle);
  if (g != 0) {
    unsafe { free(g as *u8); }
  }
}

/** 绑定 Context 用于取消传播。 */
function task_group_bind_context_c(handle: i64, ctx_handle: i64): void {
  let g: *TaskGroupMem = tg_from_handle(handle);
  if (g == 0) {
    return;
  }
  g.ctx_handle = ctx_handle;
}

/** 提交单任务到 async 就绪环；0 成功。 */
function task_group_spawn_c(handle: i64, fn: *u8, seed: i32): i32 {
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
  unsafe { spawn_r = shux_async_spawn_i32(fn, seed); }
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

/** 等待组内全部任务完成；返回 drain 结果之和。 */
function task_group_join_c(handle: i64): i32 {
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
    unsafe { shux_async_bind_context_c(g.ctx_handle); }
  }
  unsafe { total = shux_async_run_drain_until_idle(); }
  if (total == -3) {
    return TASK_ERR_CANCELLED;
  }
  g.join_total = total as i64;
  g.joined = 1;
  g.spawned = 0;
  return total;
}

/** 未 join 的 spawn 数。 */
function task_group_pending_c(handle: i64): i32 {
  let g: *TaskGroupMem = tg_from_handle(handle);
  if (g == 0) {
    return TASK_ERR_NULL;
  }
  return g.spawned;
}

/** 结构化并发：未 join 且仍有 pending 时返回 TASK_ERR_LEAK。 */
function task_group_check_leak_c(handle: i64): i32 {
  let g: *TaskGroupMem = tg_from_handle(handle);
  if (g == 0) {
    return TASK_ERR_NULL;
  }
  if (g.spawned > 0 && g.joined == 0) {
    return TASK_ERR_LEAK;
  }
  return TASK_OK;
}

/** 取消绑定 Context。 */
function task_group_cancel_c(handle: i64): void {
  let g: *TaskGroupMem = tg_from_handle(handle);
  if (g == 0 || g.ctx_handle == 0) {
    return;
  }
  unsafe { ctx_cancel_c(g.ctx_handle); }
}

/** 读取上次 join 累计结果。 */
function task_group_join_total_c(handle: i64): i64 {
  let g: *TaskGroupMem = tg_from_handle(handle);
  if (g == 0) {
    return 0;
  }
  return g.join_total;
}

/** 创建 JoinSet。 */
function join_set_create_c(capacity: i32): i64 {
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

/** 释放 JoinSet。 */
function join_set_free_c(handle: i64): void {
  let s: *JoinSetMem = js_from_handle(handle);
  if (s != 0) {
    unsafe { free(s as *u8); }
  }
}

/** JoinSet spawn。 */
function join_set_spawn_c(handle: i64, fn: *u8, seed: i32): i32 {
  let s: *JoinSetMem = js_from_handle(handle);
  if (s == 0 || fn == 0) {
    return TASK_ERR_NULL;
  }
  if (s.spawned >= s.capacity) {
    return TASK_ERR_FULL;
  }
  unsafe { if (shux_async_spawn_i32(fn, seed) != 0) {
    return TASK_ERR_INVALID;
  } }
  s.spawned = s.spawned + 1;
  s.joined = 0;
  return TASK_OK;
}

/** JoinSet 等待全部完成。 */
function join_set_join_c(handle: i64): i32 {
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
  unsafe { total = shux_async_run_drain_until_idle(); }
  s.join_total = total as i64;
  s.joined = 1;
  s.spawned = 0;
  return total;
}

/** JoinSet leak 检测。 */
function join_set_check_leak_c(handle: i64): i32 {
  let s: *JoinSetMem = js_from_handle(handle);
  if (s == 0) {
    return TASK_ERR_NULL;
  }
  if (s.spawned > 0 && s.joined == 0) {
    return TASK_ERR_LEAK;
  }
  return TASK_OK;
}

/** Supervisor：失败时重试 fn(seed)；成功返回最终 drain 结果。 */
function task_supervise_retry_c(fn: *u8, seed: i32, max_attempts: i32, backoff_ns: i64): i32 {
  let attempt: i32 = 0;
  let total: i32 = 0;
  if (fn == 0 || max_attempts <= 0) {
    return TASK_ERR_NULL;
  }
  while (attempt < max_attempts) {
    unsafe { shux_async_run_seed_reset(); }
    unsafe { shux_async_queue_reset(); }
    unsafe { if (shux_async_spawn_i32(fn, seed) != 0) {
      return TASK_ERR_INVALID;
    } }
    unsafe { total = shux_async_run_drain_until_idle(); }
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

/** 烟测：双任务 spawn + join + leak 检测 + supervise（spawn 用 task_echo_fn_ptr_c）。 */
function task_smoke_c(): i32 {
  let grp: i64 = task_group_create_c(4);
  let js: i64 = join_set_create_c(2);
  let echo_fn: *u8 = task_echo_fn_ptr_c();
  let r: i32 = 0;
  if (grp == 0 || js == 0) {
    return 1;
  }
  unsafe { shux_async_run_seed_reset(); }
  unsafe { shux_async_queue_reset(); }
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
  unsafe { shux_async_run_seed_reset(); }
  unsafe { shux_async_queue_reset(); }
  if (join_set_spawn_c(js, echo_fn, 4) != TASK_OK) {
    return 7;
  }
  r = join_set_join_c(js);
  if (r != 40) {
    return 8;
  }
  unsafe { shux_async_run_seed_reset(); }
  unsafe { shux_async_queue_reset(); }
  r = task_supervise_retry_c(echo_fn, 5, 3, 0);
  if (r != 50) {
    return 9;
  }
  task_group_free_c(grp);
  join_set_free_c(js);
  return 0;
}
