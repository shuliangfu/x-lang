// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

// libc
export extern "C" function malloc(size: usize): *u8;
export extern "C" function free(ptr: *u8): void;

// See implementation.
export extern "C" function queue_os_mutex_create_c(): *u8;
export extern "C" function queue_os_mutex_destroy_c(mu: *u8): void;
export extern "C" function queue_os_mutex_lock_c(mu: *u8): void;
export extern "C" function queue_os_mutex_unlock_c(mu: *u8): void;
export extern "C" function queue_os_run_two_workers_c(ctx: *u8): i32;

/** See implementation for details. */
allow(padding) struct QueueSmokeState {
  mu: *u8;
  data: *i32;
  cap: i32;
  len: i32;
  head: i32;
}

/** Exported function `runtime_queue_contention_x_doc_anchor`.
 * Implements `runtime_queue_contention_x_doc_anchor`.
 * @return i32
 */
export function runtime_queue_contention_x_doc_anchor(): i32 {
  return 0;
}

// See implementation.

/** Exported function `queue_smoke_at_impl`.
 * Implements `queue_smoke_at_impl`.
 * @param q *QueueSmokeState
 * @param i i32
 * @return i32
 */
#[no_mangle]
export function queue_smoke_at_impl(q: *QueueSmokeState, i: i32): i32 {
  let idx: i32 = q.head + i;
  if (idx >= q.cap) {
    idx = idx - q.cap;
  }
  return idx;
}

#[no_mangle]
/** Exported function `queue_smoke_at`.
 * Implements `queue_smoke_at`.
 * @param q *QueueSmokeState
 * @param i i32
 * @return i32
 */
export function queue_smoke_at(q: *QueueSmokeState, i: i32): i32 {
  return queue_smoke_at_impl(q, i);
}

/** Exported function `queue_smoke_push_back_impl`.
 * Implements `queue_smoke_push_back_impl`.
 * @param q *QueueSmokeState
 * @param x i32
 * @return i32
 */
#[no_mangle]
export function queue_smoke_push_back_impl(q: *QueueSmokeState, x: i32): i32 {
  if (q == 0 as *QueueSmokeState) {
    return -1;
  }
  if (q.len >= q.cap) {
    let new_cap: i32 = 8;
    if (q.cap > 0) {
      new_cap = q.cap * 2;
    }
    let p: *i32 = 0 as *i32;
    unsafe {
      p = malloc((new_cap as usize) * 4) as *i32;
    }
    if (p == 0 as *i32) {
      return -1;
    }
    let i: i32 = 0;
    while (i < q.len) {
      p[i] = q.data[queue_smoke_at(q, i)];
      i = i + 1;
    }
    if (q.data != 0 as *i32) {
      unsafe {
        free(q.data as *u8);
      }
    }
    q.data = p;
    q.cap = new_cap;
    q.head = 0;
  }
  q.data[queue_smoke_at(q, q.len)] = x;
  q.len = q.len + 1;
  return 0;
}

#[no_mangle]
/** Exported function `queue_smoke_push_back`.
 * Implements `queue_smoke_push_back`.
 * @param q *QueueSmokeState
 * @param x i32
 * @return i32
 */
export function queue_smoke_push_back(q: *QueueSmokeState, x: i32): i32 {
  return queue_smoke_push_back_impl(q, x);
}

/** Exported function `queue_contention_worker_push_c`.
 * Implements `queue_contention_worker_push_c`.
 * @param ctx *u8
 * @return i32
 */
#[no_mangle]
export function queue_contention_worker_push_c(ctx: *u8): i32 {
  let q: *QueueSmokeState = ctx as *QueueSmokeState;
  if (q == 0 as *QueueSmokeState) {
    return -1;
  }
  let i: i32 = 0;
  while (i < 500) {
    unsafe {
      queue_os_mutex_lock_c(q.mu);
      queue_smoke_push_back(q, 1);
      queue_os_mutex_unlock_c(q.mu);
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `queue_os_worker_trampoline_impl`.
 * Implements `queue_os_worker_trampoline_impl`.
 * @param arg *u8
 * @return *u8
 */
#[no_mangle]
export function queue_os_worker_trampoline_impl(arg: *u8): *u8 {
  queue_contention_worker_push_c(arg);
  return 0 as *u8;
}

#[no_mangle]
/** Exported function `queue_os_worker_trampoline`.
 * Implements `queue_os_worker_trampoline`.
 * @param arg *u8
 * @return *u8
 */
export function queue_os_worker_trampoline(arg: *u8): *u8 {
  return queue_os_worker_trampoline_impl(arg);
}

/** Exported function `sync_queue_contention_smoke_c`.
 * Implements `sync_queue_contention_smoke_c`.
 * @return i32
 */
#[no_mangle]
export function sync_queue_contention_smoke_c(): i32 {
  let st: QueueSmokeState = QueueSmokeState {
    mu: 0 as *u8,
    data: 0 as *i32,
    cap: 0,
    len: 0,
    head: 0,
  };
  let rc: i32 = -1;
  unsafe {
    st.mu = queue_os_mutex_create_c();
  }
  if (st.mu == 0 as *u8) {
    return -1;
  }
  let workers_rc: i32 = 0;
  unsafe {
    workers_rc = queue_os_run_two_workers_c(&st as *u8);
  }
  if (workers_rc != 0) {
    unsafe {
      queue_os_mutex_destroy_c(st.mu);
    }
    if (st.data != 0 as *i32) {
      unsafe {
        free(st.data as *u8);
      }
    }
    return -1;
  }
  if (st.len == 1000) {
    rc = 0;
  }
  if (st.data != 0 as *i32) {
    unsafe {
      free(st.data as *u8);
    }
  }
  unsafe {
    queue_os_mutex_destroy_c(st.mu);
  }
  return rc;
}
