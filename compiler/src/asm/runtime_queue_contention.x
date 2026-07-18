// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-21：runtime_queue_contention 产品源迁 seeds/runtime_queue_contention.from_x.c。
// G-02f-102：+ queue_smoke / worker_trampoline 薄门闩。
// G-02f-rest：rest→.x 迁移：5 个 rest 函数真迁 .x（struct + pthread extern），
//   5 个平台 #ifdef 函数（mutex create/destroy/lock/unlock + run_two_workers）保留 seed。

// libc
export extern "C" function malloc(size: usize): *u8;
export extern "C" function free(ptr: *u8): void;

// seed 提供（平台 #ifdef：pthread / Win32 CRITICAL_SECTION）
export extern "C" function queue_os_mutex_create_c(): *u8;
export extern "C" function queue_os_mutex_destroy_c(mu: *u8): void;
export extern "C" function queue_os_mutex_lock_c(mu: *u8): void;
export extern "C" function queue_os_mutex_unlock_c(mu: *u8): void;
export extern "C" function queue_os_run_two_workers_c(ctx: *u8): i32;

/** 烟测用 mutex 保护环形队列（与 seed C QueueSmokeState 布局一致）。
* allow(padding)：mu/data 各 8B，cap/len/head 各 4B，总 28B 对齐到 32B，尾部 4B padding。 */
allow(padding) struct QueueSmokeState {
  mu: *u8;
  data: *i32;
  cap: i32;
  len: i32;
  head: i32;
}

export function runtime_queue_contention_x_doc_anchor(): i32 {
  return 0;
}

// ---- G-02f-102：queue smoke / trampoline 门闩（thin wrapper + impl） ----

/** 逻辑下标 i 对应的物理下标。 */
#[no_mangle]
export function queue_smoke_at_impl(q: *QueueSmokeState, i: i32): i32 {
  let idx: i32 = q.head + i;
  if (idx >= q.cap) {
    idx = idx - q.cap;
  }
  return idx;
}

#[no_mangle]
export function queue_smoke_at(q: *QueueSmokeState, i: i32): i32 {
  return queue_smoke_at_impl(q, i);
}

/** 队尾插入；失败 -1。 */
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
export function queue_smoke_push_back(q: *QueueSmokeState, x: i32): i32 {
  return queue_smoke_push_back_impl(q, x);
}

/** 每 worker 线程：加锁 push 500 次。 */
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

/** 每 worker 线程 trampoline。 */
#[no_mangle]
export function queue_os_worker_trampoline_impl(arg: *u8): *u8 {
  queue_contention_worker_push_c(arg);
  return 0 as *u8;
}

#[no_mangle]
export function queue_os_worker_trampoline(arg: *u8): *u8 {
  return queue_os_worker_trampoline_impl(arg);
}

/** STD-048：双线程并发 push 烟测；0 通过，-1 失败。 */
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
