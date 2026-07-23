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

/* See implementation. */
export const XLANG_NET_MAX_WORKERS: i32 = 64;

/* See implementation. */
allow(padding) struct NetWorkerArg {
  listener_fd: i32;
  timeout_ms: u32;
  worker_index: i32;
}

extern function thread_create_c(entry: usize, arg: usize): i64;

extern function thread_join_c(thread_id: i64): i32;

extern function xlang_net_worker_accept_entry_ptr_c(): usize;

/**
 * See implementation.
 */
export function net_worker_arg_slot_ptr_c(base: *NetWorkerArg, i: i32): *NetWorkerArg {
  return base + i;
}

/**
 * See implementation.
 */
export function net_worker_arg_fill_c(slot: *NetWorkerArg, listener_fd: i32, timeout_ms: u32, worker_index: i32): void {
  slot.listener_fd = listener_fd;
  slot.timeout_ms = timeout_ms;
  slot.worker_index = worker_index;
}

/**
 * See implementation.
 * See implementation.
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
  if (nw > XLANG_NET_MAX_WORKERS) {
    nw = XLANG_NET_MAX_WORKERS;
  }
  i = 0;
  while (i < nw) {
    net_worker_arg_fill_c(net_worker_arg_slot_ptr_c(&args[0], i), listener_fd, timeout_ms, i);
    i = i + 1;
  }
  unsafe { entry = xlang_net_worker_accept_entry_ptr_c(); }
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
