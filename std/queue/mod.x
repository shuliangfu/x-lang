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
// erve、deinit。
//
// See implementation.
const heap_libc = import("std.heap.libc");
/* See implementation. */
const sync = import("std.sync");
const atomic = import("std.atomic");
/** See implementation for details. */
allow(padding) struct Queue_i32 {
  data: *i32;
  cap: i32;
  length: i32;
  head: i32;
}
/** Exported function `new`.
 * Implements `new`.
 * @return Queue_i32
 */
export function new(): Queue_i32 {
  return Queue_i32 { data: 0, cap: 0, length: 0, head: 0 };
}
/** Exported function `with_capacity`.
 * Implements `with_capacity`.
 * @param q *Queue_i32
 * @param capacity i32
 * @return i32
 */
export function with_capacity(q: *Queue_i32, capacity: i32): i32 {
  if (capacity <= 0) {
    q.data = 0;
    q.cap = 0;
    q.length = 0;
    q.head = 0;
    return 0;
  }
  let p: *i32 = heap_libc.heap_alloc_i32_c(capacity);
  if (p == 0) { return -1; }
  q.data = p;
  q.cap = capacity;
  q.length = 0;
  q.head = 0;
  return 0;
}
/** Exported function `at`.
 * Implements `at`.
 * @param q Queue_i32
 * @param i i32
 * @return i32
 */
export function at(q: Queue_i32, i: i32): i32 {
  let idx: i32 = q.head + i;
  if (idx >= q.cap) { idx = idx - q.cap; }
  return idx;
}
/** Exported function `grow`.
 * Implements `grow`.
 * @param q *Queue_i32
 * @return i32
 */
export function grow(q: *Queue_i32): i32 {
  let new_cap: i32 = if (q.cap <= 0) { 8 } else { q.cap * 2 };
  if (new_cap <= q.cap) { return 0; }
  let p: *i32 = heap_libc.heap_alloc_i32_c(new_cap);
  if (p == 0) { return -1; }
  let i: i32 = 0;
  while (i < q.length) {
    let idx: i32 = 0;
    unsafe { idx = at(*q, i); }
    p[i] = q.data[idx];
    i = i + 1;
  }
  if (q.data != 0) { heap_libc.heap_free_i32_c(q.data); }
  q.data = p;
  q.cap = new_cap;
  q.head = 0;
  return 0;
}
/** Exported function `push_back`.
 * Implements `push_back`.
 * @param q *Queue_i32
 * @param x i32
 * @return i32
 */
export function push_back(q: *Queue_i32, x: i32): i32 {
  if (q.length >= q.cap && grow(q) != 0) { return -1; }
  let tail: i32 = 0;
  unsafe { tail = at(*q, q.length); }
  q.data[tail] = x;
  q.length = q.length + 1;
  return 0;
}
/** Exported function `push_front`.
 * Implements `push_front`.
 * @param q *Queue_i32
 * @param x i32
 * @return i32
 */
export function push_front(q: *Queue_i32, x: i32): i32 {
  if (q.length >= q.cap && grow(q) != 0) { return -1; }
  q.head = q.head - 1;
  if (q.head < 0) { q.head = q.head + q.cap; }
  q.data[q.head] = x;
  q.length = q.length + 1;
  return 0;
}
/** Exported function `pop_back`.
 * Implements `pop_back`.
 * @param q *Queue_i32
 * @return i32
 */
export function pop_back(q: *Queue_i32): i32 {
  if (q.length <= 0) { return 0; }
  q.length = q.length - 1;
  let idx: i32 = 0;
  unsafe { idx = at(*q, q.length); }
  return q.data[idx];
}
/** Exported function `pop_front`.
 * Implements `pop_front`.
 * @param q *Queue_i32
 * @return i32
 */
export function pop_front(q: *Queue_i32): i32 {
  if (q.length <= 0) { return 0; }
  let x: i32 = q.data[q.head];
  q.head = q.head + 1;
  if (q.head >= q.cap) { q.head = 0; }
  q.length = q.length - 1;
  return x;
}
/** Exported function `get`.
 * Implements `get`.
 * @param q Queue_i32
 * @param i i32
 * @return i32
 */
export function get(q: Queue_i32, i: i32): i32 {
  if (i < 0 || i >= q.length) { return 0; }
  return q.data[at(q, i)];
}
/** Exported function `len`.
 * Implements `len`.
 * @param q Queue_i32
 * @return i32
 */
export function length(q: Queue_i32): i32 { return q.length; }
/** Exported function `is_empty`.
 * Query helper `is_empty`.
 * @param q Queue_i32
 * @return i32
 */
export function is_empty(q: Queue_i32): i32 {
  if (q.length <= 0) { return 1; }
  return 0;
}
/** Exported function `clear`.
 * Implements `clear`.
 * @param q *Queue_i32
 * @return void
 */
export function clear(q: *Queue_i32): void {
  q.length = 0;
  q.head = 0;
}
/** Exported function `reserve`.
 * Implements `reserve`.
 * @param q *Queue_i32
 * @param new_cap i32
 * @return i32
 */
export function reserve(q: *Queue_i32, new_cap: i32): i32 {
  if (new_cap <= q.cap) { return 0; }
  let p: *i32 = heap_libc.heap_alloc_i32_c(new_cap);
  if (p == 0) { return -1; }
  let i: i32 = 0;
  while (i < q.length) {
    let idx: i32 = 0;
    unsafe { idx = at(*q, i); }
    p[i] = q.data[idx];
    i = i + 1;
  }
  if (q.data != 0) { heap_libc.heap_free_i32_c(q.data); }
  q.data = p;
  q.cap = new_cap;
  q.head = 0;
  return 0;
}
/** Exported function `deinit`.
 * Implements `deinit`.
 * @param q *Queue_i32
 * @return void
 */
export function deinit(q: *Queue_i32): void {
  if (q.data != 0) { heap_libc.heap_free_i32_c(q.data); q.data = 0; }
  q.cap = 0;
  q.length = 0;
  q.head = 0;
}

// ——— SyncQueue_i32（STD-048） ———
/* See implementation. */
allow(padding) struct SyncQueue_i32 {
  q: Queue_i32;
  lock: *u8;
}

/* See implementation. */
extern function sync_queue_contention_smoke_c(): i32;

/** Exported function `sync_new`.
 * Implements `sync_new`.
 * @return SyncQueue_i32
 */
export function sync_new(): SyncQueue_i32 {
  let lock: *u8 = sync.new_mutex();
  let q: Queue_i32 = Queue_i32 { data: 0, cap: 0, length: 0, head: 0 };
  return SyncQueue_i32 { q: q, lock: lock };
}

/** Exported function `sync_deinit`.
 * Implements `sync_deinit`.
 * @param sq *SyncQueue_i32
 * @return void
 */
export function sync_deinit(sq: *SyncQueue_i32): void {
  if (sq.lock != 0) {
    sync.lock(sq.lock);
    deinit(&sq.q);
    sync.unlock(sq.lock);
    sync.free_mutex(sq.lock);
    sq.lock = 0 as *u8;
  } else {
    deinit(&sq.q);
  }
}

/** Exported function `sync_push`.
 * Implements `sync_push`.
 * @param sq *SyncQueue_i32
 * @param x i32
 * @return i32
 */
export function sync_push(sq: *SyncQueue_i32, x: i32): i32 {
  if (sq.lock == 0) { return -1; }
  if (sync.lock(sq.lock) != 0) { return -1; }
  let r: i32 = push_back(&sq.q, x);
  sync.unlock(sq.lock);
  return r;
}

/**
 * See implementation.
 */
export function sync_try_pop(sq: *SyncQueue_i32, out: *i32): i32 {
  if (sq.lock == 0) { return -1; }
  if (sync.lock(sq.lock) != 0) { return -1; }
  if (is_empty(sq.q) != 0) {
    sync.unlock(sq.lock);
    return 1;
  }
  atomic.store(out, pop_front(&sq.q));
  sync.unlock(sq.lock);
  return 0;
}

/** Exported function `len`.
 * Implements `len`.
 * @param sq SyncQueue_i32
 * @return i32
 */
export function length(sq: SyncQueue_i32): i32 {
  if (sq.lock == 0) { return 0; }
  if (sync.lock(sq.lock) != 0) { return 0; }
  let n: i32 = len(sq.q);
  sync.unlock(sq.lock);
  return n;
}

/** Exported function `is_empty`.
 * Query helper `is_empty`.
 * @param sq SyncQueue_i32
 * @return i32
 */
export function is_empty(sq: SyncQueue_i32): i32 {
  if (sq.lock == 0) { return 1; }
  if (sync.lock(sq.lock) != 0) { return 1; }
  let e: i32 = is_empty(sq.q);
  sync.unlock(sq.lock);
  return e;
}

/** Exported function `sync_smoke`.
 * Implements `sync_smoke`.
 * @return i32
 */
export function sync_smoke(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = sync_queue_contention_smoke_c(); }
  return _rc;
}

// ——— Queue_u8（STD-163） ———
/* See implementation. */
allow(padding) struct Queue_u8 {
  data: *u8;
  cap: i32;
  length: i32;
  head: i32;
}

/** Exported function `new`.
 * Implements `new`.
 * @return Queue_u8
 */
export function new(): Queue_u8 {
  return Queue_u8 { data: 0, cap: 0, length: 0, head: 0 };
}

/** Exported function `at`.
 * Implements `at`.
 * @param q Queue_u8
 * @param i i32
 * @return i32
 */
export function at(q: Queue_u8, i: i32): i32 {
  let idx: i32 = q.head + i;
  if (idx >= q.cap) { idx = idx - q.cap; }
  return idx;
}

/** Exported function `grow`.
 * Implements `grow`.
 * @param q *Queue_u8
 * @return i32
 */
export function grow(q: *Queue_u8): i32 {
  let new_cap: i32 = if (q.cap <= 0) { 8 } else { q.cap * 2 };
  let p: *u8 = heap_libc.heap_alloc_u8_c(new_cap);
  if (p == 0) { return -1; }
  let i: i32 = 0;
  while (i < q.length) {
    let idx: i32 = 0;
    unsafe { idx = at(*q, i); }
    p[i] = q.data[idx];
    i = i + 1;
  }
  if (q.data != 0) { heap_libc.heap_free_u8_c(q.data); }
  q.data = p;
  q.cap = new_cap;
  q.head = 0;
  return 0;
}

/** Exported function `push_back`.
 * Implements `push_back`.
 * @param q *Queue_u8
 * @param x u8
 * @return i32
 */
export function push_back(q: *Queue_u8, x: u8): i32 {
  if (q.length >= q.cap && grow(q) != 0) { return -1; }
  let tail: i32 = 0;
  unsafe { tail = at(*q, q.length); }
  q.data[tail] = x;
  q.length = q.length + 1;
  return 0;
}

/** Exported function `pop_front`.
 * Implements `pop_front`.
 * @param q *Queue_u8
 * @return u8
 */
export function pop_front(q: *Queue_u8): u8 {
  if (q.length <= 0) { return 0 as u8; }
  let x: u8 = q.data[q.head];
  q.head = q.head + 1;
  if (q.head >= q.cap) { q.head = 0; }
  q.length = q.length - 1;
  return x;
}

/** Exported function `len`.
 * Implements `len`.
 * @param q Queue_u8
 * @return i32
 */
export function length(q: Queue_u8): i32 { return q.length; }

/** Exported function `deinit`.
 * Implements `deinit`.
 * @param q *Queue_u8
 * @return void
 */
export function deinit(q: *Queue_u8): void {
  if (q.data != 0) { heap_libc.heap_free_u8_c(q.data); q.data = 0; }
  q.cap = 0;
  q.length = 0;
  q.head = 0;
}
