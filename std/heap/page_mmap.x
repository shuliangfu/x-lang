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
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

/* See implementation. */
extern function shux_sys_mmap(addr: *u8, len: usize, prot: i32, flags: i32, fd: i32, offset: i64): *u8;

/* See implementation. */
extern function shux_sys_munmap(addr: *u8, len: usize): i32;

/* See implementation. */
export const HEAP_CAP: usize = 65536;
/** mmap prot：PROT_READ|PROT_WRITE。 */
export const HEAP_PROT: i32 = 3;
/** mmap flags：MAP_PRIVATE|MAP_ANONYMOUS。 */
export const HEAP_FLAGS: i32 = 0x22;
/* See implementation. */
export const HEAP_FD: i32 = -1;

/**
 * See implementation.
 */
allow(padding) struct PageMmapHeap {
  base: *u8;
  cap: usize;
  off: usize;
}

/**
 * See implementation.
 */
export function page_mmap_heap_available(): i32 {
  return 1;
}

/**
 * See implementation.
 */
export function page_mmap_heap_init(h: *PageMmapHeap): i32 {
  if (h == 0) {
    return -1;
  }
  h.base = 0 as *u8;
  h.cap = 0;
  h.off = 0;
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_sys_mmap(0 as *u8, HEAP_CAP, HEAP_PROT, HEAP_FLAGS, HEAP_FD, 0 as i64);
  }
  // See implementation.
  if (p == -1 as *u8) {
    return -1;
  }
  h.base = p;
  h.cap = HEAP_CAP;
  h.off = 0;
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function page_mmap_heap_alloc(h: *PageMmapHeap, size: usize, align_bytes: usize): *u8 {
  if (h == 0 as *PageMmapHeap) {
    return 1 as *u8;
  }
  if (h.base == 0 as *u8) {
    return 2 as *u8;
  }
  if (size == 0) {
    return 3 as *u8;
  }
  let a: usize = align_bytes;
  if (a == 0) {
    a = 1;
  }
  let start: usize = ((h.off + a - 1) / a) * a;
  let end: usize = start + size;
  if (end > h.cap) {
    return 4 as *u8;
  }
  if (end < start) {
    return 5 as *u8;
  }
  let out: *u8 = h.base + start;
  h.off = end;
  return out;
}

/**
 * See implementation.
 */
export function page_mmap_heap_free(_h: *PageMmapHeap, _ptr: *u8): void {
}

/**
 * See implementation.
 */
export function page_mmap_heap_deinit(h: *PageMmapHeap): void {
  if (h == 0) {
    return;
  }
  if (h.base != 0 && h.cap > 0) {
    unsafe {
      shux_sys_munmap(h.base, h.cap);
    }
  }
  h.base = 0 as *u8;
  h.cap = 0;
  h.off = 0;
}
