// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function malloc(size: usize): *u8;
export extern "C" function free(ptr: *u8): void;
export extern "C" function realloc(ptr: *u8, new_size: usize): *u8;
export extern "C" function calloc(n: usize, size: usize): *u8;

// See implementation.
export extern "C" function heap_alloc_aligned_c(align_bytes: usize, size: usize): *u8;

/* See implementation. */
export struct XlangHeapArena64 {
  chunk: *u8;
  cap: usize;
  off: usize;
}

/** Exported function `heap_alloc_c`.
 * Memory management helper `heap_alloc_c`.
 * @param size usize
 * @return *u8
 */
#[no_mangle]
export function heap_alloc_c(size: usize): *u8 {
  if (size == 0) {
    return 0 as *u8;
  }
  unsafe {
    let r: *u8 = malloc(size);
    return r;
  }
  return 0 as *u8;
}

/** Exported function `heap_free_c`.
 * Memory management helper `heap_free_c`.
 * @param ptr *u8
 * @return void
 */
#[no_mangle]
export function heap_free_c(ptr: *u8): void {
  unsafe {
    free(ptr);
  }
}

/** Exported function `heap_realloc_c`.
 * Memory management helper `heap_realloc_c`.
 * @param ptr *u8
 * @param new_size usize
 * @return *u8
 */
#[no_mangle]
export function heap_realloc_c(ptr: *u8, new_size: usize): *u8 {
  if (new_size == 0) {
    unsafe {
      free(ptr);
    }
    return 0 as *u8;
  }
  unsafe {
    let r: *u8 = realloc(ptr, new_size);
    return r;
  }
  return 0 as *u8;
}

/** Exported function `heap_alloc_zeroed_c`.
 * Memory management helper `heap_alloc_zeroed_c`.
 * @param size usize
 * @return *u8
 */
#[no_mangle]
export function heap_alloc_zeroed_c(size: usize): *u8 {
  if (size == 0) {
    return 0 as *u8;
  }
  unsafe {
    let r: *u8 = calloc(1, size);
    return r;
  }
  return 0 as *u8;
}

// See implementation.

/** Exported function `heap_arena_init_c`.
 * Implements `heap_arena_init_c`.
 * @param a *XlangHeapArena64
 * @param cap usize
 * @return i32
 */
#[no_mangle]
export function heap_arena_init_c(a: *XlangHeapArena64, cap: usize): i32 {
  if (a == 0 as *XlangHeapArena64) {
    return 0 - 1;
  }
  a.chunk = 0 as *u8;
  a.cap = 0;
  a.off = 0;
  let use_cap: usize = cap;
  if (use_cap == 0) {
    use_cap = 4096;
  }
  unsafe {
    a.chunk = heap_alloc_aligned_c(64, use_cap);
  }
  if (a.chunk == 0 as *u8) {
    return 0 - 1;
  }
  a.cap = use_cap;
  return 0;
}

/** Exported function `heap_arena64_alloc_c`.
 * Memory management helper `heap_arena64_alloc_c`.
 * @param a *XlangHeapArena64
 * @param size usize
 * @param align_bytes usize
 * @return *u8
 */
#[no_mangle]
export function heap_arena64_alloc_c(a: *XlangHeapArena64, size: usize, align_bytes: usize): *u8 {
  if (a == 0 as *XlangHeapArena64) {
    return 0 as *u8;
  }
  if (a.chunk == 0 as *u8) {
    return 0 as *u8;
  }
  if (size == 0) {
    return 0 as *u8;
  }
  let obj_align: usize = align_bytes;
  if (obj_align == 0) {
    obj_align = 8;
  }
  let cur: usize = a.off;
  let rem: usize = cur % obj_align;
  let gap: usize = 0;
  if (rem != 0) {
    gap = obj_align - rem;
  }
  let next: usize = cur + gap + size;
  if (next > a.cap) {
    return 0 as *u8;
  }
  let out: *u8 = a.chunk + cur + gap;
  a.off = next;
  return out;
}

/** Exported function `heap_arena64_deinit_c`.
 * Implements `heap_arena64_deinit_c`.
 * @param a *XlangHeapArena64
 * @return void
 */
#[no_mangle]
export function heap_arena64_deinit_c(a: *XlangHeapArena64): void {
  if (a == 0 as *XlangHeapArena64) {
    return;
  }
  heap_free_c(a.chunk);
  a.chunk = 0 as *u8;
  a.cap = 0;
  a.off = 0;
}
