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

// std.thread — 线程：spawn/join/self，多核易用（与 std.net 多 worker
// 配合压榨性能）
//
// 职责：提供 self、create、join；实现由 std/thread/thread.x + thread_glue.c
// 提供，链接 thread.o；Unix 需 -lpthread。
// 约定：create(entry, arg) 的 entry 为 C 函数地址（void* (*)(void*)），当前
// .x 无函数指针时可用 dummy_entry_ptr() 测试或由 C 层提供入口。
// 后续：语言支持 &amp;fn 后可直接 spawn(.x 函数)；或 net 提供 listen_workers
// 时内部使用本模块。
// —— C 层：由 std/thread/thread_glue.c 提供（F-thread v1）——
extern function thread_self_c(): i64;
extern function thread_create_c(entry: usize, arg: usize): i64;
extern function thread_create_with_stack_c(entry: usize, arg: usize, stack_size: usize): i64;
extern function thread_join_c(thread_id: i64): i32;
extern function thread_set_affinity_self_c(cpu_index: i32): i32;
extern function thread_set_affinity_c(thread_id: i64, cpu_index: i32): i32;
extern function thread_set_qos_class_self_c(qos_class: i32): i32;
extern function thread_dummy_entry_ptr_c(): usize;
/** 返回当前线程 ID（用于区分线程、多核时每线程一 io_uring）。 */
function id(): i64 {
  unsafe { return thread_self_c(); }
}
/**
* 创建新线程；entry 为 C 函数地址（签名 void* (*)(void*)），arg 传入该函数。
* 成功返回 thread_id（用于 join），失败返回 0。
* 当前 .x 无法直接取 .x 函数地址时，可用 dummy_entry_ptr()
* 做测试，或由 C 提供入口。
*/
function create(entry: usize, arg: usize): i64 {
  unsafe { return thread_create_c(entry, arg); }
}
/**
* 创建新线程并指定栈大小；stack_size 为 0 表示使用默认栈。
* 多 worker 时可用较小栈（如 262144）省内存。成功返回 thread_id，失败返回
* 0。
*/
function create_with_stack(entry: usize, arg: usize, stack_size: usize): i64 {
  unsafe { return thread_create_with_stack_c(entry, arg, stack_size); }
}
/** 等待线程结束；thread_id 为 create 返回值。返回 0 成功，-1 失败。 */
function join(thread_id: i64): i32 {
  unsafe { return thread_join_c(thread_id); }
}
/**
* 将当前线程绑定到指定 CPU（绑核）；多 worker 时减少迁移与缓存抖动。
* cpu_index 为逻辑 CPU 编号（从 0 开始）。成功返回 0，失败返回 -1；macOS/BSD
* 暂不支持返回 -1。
*/
function set_affinity_self(cpu_index: i32): i32 {
  unsafe { return thread_set_affinity_self_c(cpu_index); }
}
/**
* 将指定线程绑定到指定 CPU；thread_id 为 create 返回值。
* 成功返回 0，失败返回 -1。
*/
function set_affinity(thread_id: i64, cpu_index: i32): i32 {
  unsafe { return thread_set_affinity_c(thread_id, cpu_index); }
}
/**
* 仅 macOS 有效：设置当前线程 QoS
* 等级，提升调度优先级（无法绑核时的替代）。
* qos_class：0=default，1=user_interactive，2=user_initiated，3=utility，4=background；worker
* 建议 2。成功 0，失败或非 macOS 返回 -1。
*/
function set_qos_class_self(qos_class: i32): i32 {
  unsafe { return thread_set_qos_class_self_c(qos_class); }
}
/** 返回测试用 C 入口 dummy_entry 的地址，可用于
* create(dummy_entry_ptr(), 0) 验证 spawn+join。 */
function dummy_entry_ptr(): usize {
  unsafe { return thread_dummy_entry_ptr_c(); }
}

// —— STD-043：命名线程与固定 worker 线程池 ——

extern function thread_set_name_self_c(name: *u8, len: i32): i32;
extern function thread_pool_start_c(workers: i32): i32;
extern function thread_pool_submit_c(entry: usize, arg: usize): i32;
extern function thread_pool_drain_c(): i32;
extern function thread_pool_stop_c(): i32;
extern function thread_pool_pending_c(): i32;

/** 设置当前线程名（≤15 字节）；成功 0，不支持 -1。 */
function set_name_self(name: *u8, len: i32): i32 {
  unsafe { return thread_set_name_self_c(name, len); }
}

/** 启动固定 worker 线程池；workers 1..8；成功 0（Windows v1 返回 -1）。 */
function start(workers: i32): i32 {
  unsafe { return thread_pool_start_c(workers); }
}

/** 向池提交 C 入口任务；成功 0。 */
function submit(entry: usize, arg: usize): i32 {
  unsafe { return thread_pool_submit_c(entry, arg); }
}

/** 阻塞直至队列与 in-flight 皆空；成功 0。 */
function drain(): i32 {
  unsafe { return thread_pool_drain_c(); }
}

/** 停止池并 join worker；成功 0。 */
function stop(): i32 {
  unsafe { return thread_pool_stop_c(); }
}

/** 观测 pending（队列 + in-flight）；未启动 -1。 */
function pending(): i32 {
  unsafe { return thread_pool_pending_c(); }
}

/** 线程池统计快照（STD-165）。 */
struct ThreadPoolStats {
  pending: i32;
  in_flight: i32;
  workers: i32;
}

/** 读取全局线程池统计；未启动池时返回 -1。 */
function stats(st: *ThreadPoolStats): i32 {
  if (st == 0) { return -1; }
  st.pending = 0;
  st.in_flight = 0;
  st.workers = 0;
  return -1;
}
