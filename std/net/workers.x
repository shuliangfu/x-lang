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

// std.net.workers — F-04 v14：多 worker accept 压测（run_accept_workers）
//
// 【文件职责】
// 从 net.c 迁出 net_run_accept_workers_c / net_run_accept_workers_c_real_c。
// 线程入口见 runtime_net_workers.c；create/join 走 std/thread/thread.x + thread_glue.c。
//
// 【依赖】tcp.x net_accept_many_c；sock.x net_close_socket_c；thread.o

/** 每 listener 最多 worker 数。 */
export const SHUX_NET_MAX_WORKERS: i32 = 64;

/** 传入 worker 线程的参数块。 */
allow(padding) struct NetWorkerArg {
  listener_fd: i32;
  timeout_ms: u32;
  worker_index: i32;
}

extern function thread_create_c(entry: usize, arg: usize): i64;

extern function thread_join_c(thread_id: i64): i32;

extern function shu_net_worker_accept_entry_ptr_c(): usize;

/**
 * 取 NetWorkerArg 数组第 i 项指针（seed emit 不支持 &args[i] 直接作 call 实参）。
 */
export function net_worker_arg_slot_ptr_c(base: *NetWorkerArg, i: i32): *NetWorkerArg {
  return base + i;
}

/**
 * 写入单条 worker 参数（避免 struct 字面量初始化触发 parse skip）。
 */
export function net_worker_arg_fill_c(slot: *NetWorkerArg, listener_fd: i32, timeout_ms: u32, worker_index: i32): void {
  slot.listener_fd = listener_fd;
  slot.timeout_ms = timeout_ms;
  slot.worker_index = worker_index;
}

/**
 * 起 n_workers 线程，每线程循环 accept_many 后立即 close。
 * 主线程阻塞 join（永不返回）；失败 -1。
 */
export function net_run_accept_workers_c(listener_fd: i32, n_workers: i32, timeout_ms: u32): i32 {
  let nw: i32 = n_workers;
  let args: NetWorkerArg[64] = [];
  let tids: i64[64] = [];
  let entry: usize = 0;
  let i: i32 = 0;
  if (listener_fd < 0 || nw <= 0) {
    return -1;
  }
  if (nw > SHUX_NET_MAX_WORKERS) {
    nw = SHUX_NET_MAX_WORKERS;
  }
  i = 0;
  while (i < nw) {
    net_worker_arg_fill_c(net_worker_arg_slot_ptr_c(&args[0], i), listener_fd, timeout_ms, i);
    i = i + 1;
  }
  unsafe { entry = shu_net_worker_accept_entry_ptr_c(); }
  i = 0;
  while (i < nw) {
    unsafe { tids[i] = thread_create_c(entry, net_worker_arg_slot_ptr_c(&args[0], i) as usize); }
    if (tids[i] == 0) {
      return -1;
    }
    i = i + 1;
  }
  i = 0;
  while (i < nw) {
    unsafe { if (thread_join_c(tids[i]) != 0) {
      return -1;
    } }
    i = i + 1;
  }
  return 0;
}
