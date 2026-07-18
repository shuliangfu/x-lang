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
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
extern function thread_self_c(): i64;
extern function thread_create_c(entry: usize, arg: usize): i64;
extern function thread_create_with_stack_c(entry: usize, arg: usize, stack_size: usize): i64;
extern function thread_join_c(thread_id: i64): i32;
extern function thread_set_affinity_self_c(cpu_index: i32): i32;
extern function thread_set_affinity_c(thread_id: i64, cpu_index: i32): i32;
extern function thread_set_qos_class_self_c(qos_class: i32): i32;
extern function thread_dummy_entry_ptr_c(): usize;
/** Exported function `id`.
 * Implements `id`.
 * @return i64
 */
export function id(): i64 {
  unsafe { return thread_self_c(); }
  return 0; // unreachable — typeck workaround
}
/**
* See implementation.
* See implementation.
* See implementation.
* See implementation.
*/
export function create(entry: usize, arg: usize): i64 {
  unsafe { return thread_create_c(entry, arg); }
  return 0; // unreachable — typeck workaround
}
/**
* See implementation.
* See implementation.
* 0。
*/
export function create_with_stack(entry: usize, arg: usize, stack_size: usize): i64 {
  unsafe { return thread_create_with_stack_c(entry, arg, stack_size); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `join`.
 * Implements `join`.
 * @param thread_id i64
 * @return i32
 */
export function join(thread_id: i64): i32 {
  unsafe { return thread_join_c(thread_id); }
  return 0; // unreachable — typeck workaround
}
/**
* See implementation.
* See implementation.
* See implementation.
*/
export function set_affinity_self(cpu_index: i32): i32 {
  unsafe { return thread_set_affinity_self_c(cpu_index); }
  return 0; // unreachable — typeck workaround
}
/**
* See implementation.
* See implementation.
*/
export function set_affinity(thread_id: i64, cpu_index: i32): i32 {
  unsafe { return thread_set_affinity_c(thread_id, cpu_index); }
  return 0; // unreachable — typeck workaround
}
/**
* See implementation.
* See implementation.
* qos_class：0=default，1=user_interactive，2=user_initiated，3=utility，4=background；worker
* See implementation.
*/
export function set_qos_class_self(qos_class: i32): i32 {
  unsafe { return thread_set_qos_class_self_c(qos_class); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `dummy_entry_ptr`.
 * Implements `dummy_entry_ptr`.
 * @return usize
 */
export function dummy_entry_ptr(): usize {
  unsafe { return thread_dummy_entry_ptr_c(); }
  return 0 as usize; // unreachable — typeck workaround
}

// See implementation.

extern function thread_set_name_self_c(name: *u8, len: i32): i32;
extern function thread_pool_start_c(workers: i32): i32;
extern function thread_pool_submit_c(entry: usize, arg: usize): i32;
extern function thread_pool_drain_c(): i32;
extern function thread_pool_stop_c(): i32;
extern function thread_pool_pending_c(): i32;

/** Exported function `set_name_self`.
 * Implements `set_name_self`.
 * @param name *u8
 * @param len i32
 * @return i32
 */
export function set_name_self(name: *u8, len: i32): i32 {
  unsafe { return thread_set_name_self_c(name, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `start`.
 * Implements `start`.
 * @param workers i32
 * @return i32
 */
export function start(workers: i32): i32 {
  unsafe { return thread_pool_start_c(workers); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `submit`.
 * Implements `submit`.
 * @param entry usize
 * @param arg usize
 * @return i32
 */
export function submit(entry: usize, arg: usize): i32 {
  unsafe { return thread_pool_submit_c(entry, arg); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `drain`.
 * Implements `drain`.
 * @return i32
 */
export function drain(): i32 {
  unsafe { return thread_pool_drain_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `stop`.
 * Implements `stop`.
 * @return i32
 */
export function stop(): i32 {
  unsafe { return thread_pool_stop_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `pending`.
 * Implements `pending`.
 * @return i32
 */
export function pending(): i32 {
  unsafe { return thread_pool_pending_c(); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export struct ThreadPoolStats {
  pending: i32;
  in_flight: i32;
  workers: i32;
}

/** Exported function `stats`.
 * Implements `stats`.
 * @param st *ThreadPoolStats
 * @return i32
 */
export function stats(st: *ThreadPoolStats): i32 {
  if (st == 0) { return -1; }
  st.pending = 0;
  st.in_flight = 0;
  st.workers = 0;
  return -1;
}
