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
// - libc：malloc、free、realloc、calloc、posix_memalign、getenv
// See implementation.

const mem = import("core.mem");

/* See implementation. */
export const HEAP_ARENA64_DEFAULT_CAP: usize = 4096;

/* See implementation. */
extern "C" function malloc(size: usize): *u8;
extern "C" function free(ptr: *u8): void;
extern "C" function realloc(ptr: *u8, new_size: usize): *u8;
extern "C" function calloc(nmemb: usize, size: usize): *u8;
extern "C" function posix_memalign(memptr: * *void, alignment: usize, size: usize): i32;
extern "C" function getenv(name: *u8): *u8;

/** Exported function `heap_libc_malloc`.
 * Memory management helper `heap_libc_malloc`.
 * @param size usize
 * @return *u8
 */
export function heap_libc_malloc(size: usize): *u8 {
  unsafe { return malloc(size); }
  return 0 as *u8; // unreachable — typeck workaround
}
/** Exported function `heap_libc_free`.
 * Memory management helper `heap_libc_free`.
 * @param ptr *u8
 * @return void
 */
export function heap_libc_free(ptr: *u8): void {
  unsafe { free(ptr); }
}
/** Exported function `heap_libc_realloc`.
 * Memory management helper `heap_libc_realloc`.
 * @param ptr *u8
 * @param new_size usize
 * @return *u8
 */
export function heap_libc_realloc(ptr: *u8, new_size: usize): *u8 {
  unsafe { return realloc(ptr, new_size); }
  return 0 as *u8; // unreachable — typeck workaround
}
/** Exported function `heap_libc_calloc`.
 * Memory management helper `heap_libc_calloc`.
 * @param nmemb usize
 * @param size usize
 * @return *u8
 */
export function heap_libc_calloc(nmemb: usize, size: usize): *u8 {
  unsafe { return calloc(nmemb, size); }
  return 0 as *u8; // unreachable — typeck workaround
}
/** Exported function `heap_libc_posix_memalign`.
 * Implements `heap_libc_posix_memalign`.
 * @param memptr * *void
 * @param alignment usize
 * @param size usize
 * @return i32
 */
export function heap_libc_posix_memalign(memptr: * *void, alignment: usize, size: usize): i32 {
  unsafe { return posix_memalign(memptr, alignment, size); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `heap_libc_getenv`.
 * Implements `heap_libc_getenv`.
 * @param name *u8
 * @return *u8
 */
export function heap_libc_getenv(name: *u8): *u8 {
  unsafe { return getenv(name); }
  return 0 as *u8; // unreachable — typeck workaround
}

/* See implementation. */
let XLANG_HEAP_TRACE_ENV: u8[17] = [88, 76, 65, 78, 71, 95, 72, 69, 65, 80, 95, 84, 82, 65, 67, 69, 0];

/* See implementation. */
let xlang_heap_trace_on: i32 = -1;
let xlang_heap_trace_alloc_count: u64 = 0;
let xlang_heap_trace_free_count: u64 = 0;
let xlang_heap_trace_realloc_count: u64 = 0;
let xlang_heap_trace_bytes: u64 = 0;

/* See implementation. */
export const HEAP_PTR_SIZE: usize = 8;

/** See implementation for details. */
allow(padding) struct LibcArena64 {
  chunk: *u8;
  cap: usize;
  off: usize;
}

/**
 * See implementation.
 * See implementation.
 */
export function heap_trace_is_on(): i32 {
  if (xlang_heap_trace_on >= 0) {
    return xlang_heap_trace_on;
  }
  let env: *u8 = heap_libc_getenv(&XLANG_HEAP_TRACE_ENV[0]);
  if (env != 0 && env[0] == 49) {
    xlang_heap_trace_on = 1;
  } else {
    xlang_heap_trace_on = 0;
  }
  return xlang_heap_trace_on;
}

/**
 * See implementation.
 */
export function heap_trace_note_alloc(size: usize): void {
  if (heap_trace_is_on() == 0) {
    return;
  }
  xlang_heap_trace_alloc_count = xlang_heap_trace_alloc_count + 1;
  xlang_heap_trace_bytes = xlang_heap_trace_bytes + (size as u64);
}

/**
 * See implementation.
 */
export function heap_trace_note_free(): void {
  if (heap_trace_is_on() == 0) {
    return;
  }
  xlang_heap_trace_free_count = xlang_heap_trace_free_count + 1;
}

/**
 * See implementation.
 * See implementation.
 */
export function heap_alloc_c(size: usize): *u8 {
  if (size == 0) {
    return 0 as *u8;
  }
  let p: *u8 = heap_libc_malloc(size);
  if (p != 0) {
    heap_trace_note_alloc(size);
  }
  return p;
}

/**
 * See implementation.
 */
export function heap_free_c(ptr: *u8): void {
  if (ptr == 0) {
    return;
  }
  heap_trace_note_free();
  heap_libc_free(ptr);
}

/**
 * See implementation.
 * See implementation.
 */
export function heap_realloc_c(ptr: *u8, new_size: usize): *u8 {
  if (new_size == 0) {
    if (ptr != 0) {
      heap_libc_free(ptr);
    }
    return 0 as *u8;
  }
  return heap_libc_realloc(ptr, new_size);
}

/**
 * See implementation.
 */
export function heap_alloc_zeroed_c(size: usize): *u8 {
  if (size == 0) {
    return 0 as *u8;
  }
  return heap_libc_calloc(1, size);
}

/**
 * See implementation.
 */
export function heap_alloc_i32_c(count: i32): *i32 {
  if (count <= 0) {
    return 0 as *i32;
  }
  let bytes: usize = (count as usize) * 4;
  return heap_libc_malloc(bytes) as *i32;
}

/**
 * See implementation.
 */
export function heap_realloc_i32_c(ptr: *i32, new_count: i32): *i32 {
  if (new_count <= 0) {
    if (ptr != 0) {
      heap_libc_free(ptr as *u8);
    }
    return 0 as *i32;
  }
  let bytes: usize = (new_count as usize) * 4;
  return heap_libc_realloc(ptr as *u8, bytes) as *i32;
}

/**
 * See implementation.
 */
export function heap_free_i32_c(ptr: *i32): void {
  if (ptr != 0) {
    heap_libc_free(ptr as *u8);
  }
}

/**
 * See implementation.
 */
export function heap_alloc_u8_c(count: i32): *u8 {
  if (count <= 0) {
    return 0 as *u8;
  }
  return heap_libc_malloc(count as usize);
}

/**
 * See implementation.
 */
export function heap_realloc_u8_c(ptr: *u8, new_count: i32): *u8 {
  if (new_count <= 0) {
    if (ptr != 0) {
      heap_libc_free(ptr);
    }
    return 0 as *u8;
  }
  return heap_libc_realloc(ptr, new_count);
}

/**
 * See implementation.
 */
export function heap_free_u8_c(ptr: *u8): void {
  if (ptr != 0) {
    heap_libc_free(ptr);
  }
}

/**
 * See implementation.
 */
export function heap_copy_i32_at_c(dst: *i32, dst_offset: i32, src: *i32, count: i32): void {
  if (count <= 0) {
    return;
  }
  let n: usize = (count as usize) * 4;
  mem.mem_copy((dst + dst_offset) as *u8, src as *u8, n);
}

/**
 * See implementation.
 */
export function heap_copy_u8_at_c(dst: *u8, dst_offset: i32, src: *u8, count: i32): void {
  if (count <= 0) {
    return;
  }
  mem.mem_copy((dst + dst_offset) as *u8, src, count);
}

/**
 * See implementation.
 */
export function heap_alloc_f32_c(count: i32): *f32 {
  if (count <= 0) {
    return 0 as *f32;
  }
  let bytes: usize = (count as usize) * 4;
  return heap_libc_malloc(bytes) as *f32;
}

/**
 * See implementation.
 */
export function heap_realloc_f32_c(ptr: *f32, new_count: i32): *f32 {
  if (new_count <= 0) {
    if (ptr != 0) {
      heap_libc_free(ptr as *u8);
    }
    return 0 as *f32;
  }
  let bytes: usize = (new_count as usize) * 4;
  return heap_libc_realloc(ptr as *u8, bytes) as *f32;
}

/**
 * See implementation.
 */
export function heap_free_f32_c(ptr: *f32): void {
  if (ptr != 0) {
    heap_libc_free(ptr as *u8);
  }
}

/**
 * See implementation.
 */
export function heap_copy_f32_at_c(dst: *f32, dst_offset: i32, src: *f32, count: i32): void {
  if (count <= 0) {
    return;
  }
  let n: usize = (count as usize) * 4;
  mem.mem_copy((dst + dst_offset) as *u8, src as *u8, n);
}

/**
 * See implementation.
 */
export function alloc_f32(count: i32): *f32 {
  return heap_alloc_f32_c(count);
}

/**
 * See implementation.
 */
export function realloc_f32(ptr: *f32, new_count: i32): *f32 {
  return heap_realloc_f32_c(ptr, new_count);
}

/**
 * See implementation.
 */
export function free_f32(ptr: *f32): void {
  heap_free_f32_c(ptr);
}

/**
 * See implementation.
 */
export function heap_alloc_aligned_c(align_bytes: usize, size: usize): *u8 {
  let obj_align: usize = align_bytes;
  let slot: *void = 0 as *void;
  if (size == 0) {
    return 0 as *u8;
  }
  if (obj_align < HEAP_PTR_SIZE) {
    obj_align = HEAP_PTR_SIZE;
  }
  if (heap_libc_posix_memalign(&slot, obj_align, size) != 0) {
    return 0 as *u8;
  }
  return slot as *u8;
}

/**
 * See implementation.
 */
export function heap_ptr_mod_c(ptr: *u8, mod: usize): usize {
  if (ptr == 0 || mod == 0) {
    return 0 as usize;
  }
  return (ptr as usize) % mod;
}

/**
 * See implementation.
 */
export function heap_arena64_init_c(a: *LibcArena64, cap: usize): i32 {
  if (a == 0) {
    return -1;
  }
  a.chunk = 0 as *u8;
  a.cap = 0;
  a.off = 0;
  let use_cap: usize = cap;
  if (use_cap == 0) {
    use_cap = HEAP_ARENA64_DEFAULT_CAP;
  }
  a.chunk = heap_alloc_aligned_c(64, use_cap);
  if (a.chunk == 0) {
    return -1;
  }
  a.cap = use_cap;
  return 0;
}

/**
 * See implementation.
 */
export function heap_arena64_bump_c(a: *LibcArena64, size: usize, obj_align: usize): *u8 {
  let cur: usize = 0;
  let rem: usize = 0;
  let gap: usize = 0;
  let next: usize = 0;
  if (a == 0 || a.chunk == 0 || size == 0) {
    return 0 as *u8;
  }
  cur = a.off;
  rem = cur % obj_align;
  if (rem != 0) {
    gap = obj_align - rem;
  }
  next = cur + gap + size;
  if (next > a.cap) {
    return 0 as *u8;
  }
  let out: *u8 = a.chunk + cur + gap;
  a.off = next;
  return out;
}

/**
 * See implementation.
 */
export function heap_arena64_alloc_c(a: *LibcArena64, size: usize, align_bytes: usize): *u8 {
  if (align_bytes == 0) {
    return heap_arena64_bump_c(a, size, HEAP_PTR_SIZE);
  }
  return heap_arena64_bump_c(a, size, align_bytes);
}

/**
 * See implementation.
 */
export function heap_arena64_deinit_c(a: *LibcArena64): void {
  if (a == 0) {
    return;
  }
  heap_free_c(a.chunk);
  a.chunk = 0 as *u8;
  a.cap = 0;
  a.off = 0;
}

/**
 * See implementation.
 */
export function heap_alloc_u64_c(count: i32): *u64 {
  if (count <= 0) {
    return 0 as *u64;
  }
  let bytes: usize = (count) * 8;
  return heap_libc_malloc(bytes) as *u64;
}

/**
 * See implementation.
 */
export function heap_free_u64_c(ptr: *u64): void {
  if (ptr != 0) {
    heap_libc_free(ptr as *u8);
  }
}

/**
 * See implementation.
 */
export function heap_realloc_u64_c(ptr: *u64, new_count: i32): *u64 {
  if (new_count <= 0) {
    if (ptr != 0) {
      heap_libc_free(ptr as *u8);
    }
    return 0 as *u64;
  }
  let bytes: usize = (new_count as usize) * 8;
  return heap_libc_realloc(ptr as *u8, bytes) as *u64;
}

/**
 * See implementation.
 */
export function heap_copy_u64_at_c(dst: *u64, dst_offset: i32, src: *u64, count: i32): void {
  if (count <= 0) {
    return;
  }
  let n: usize = (count as usize) * 8;
  mem.mem_copy((dst + dst_offset) as *u8, src as *u8, n);
}

/**
 * See implementation.
 */
export function heap_alloc_f64_c(count: i32): *f64 {
  if (count <= 0) {
    return 0 as *f64;
  }
  let bytes: usize = (count as usize) * 8;
  return heap_libc_malloc(bytes) as *f64;
}

/**
 * See implementation.
 */
export function heap_realloc_f64_c(ptr: *f64, new_count: i32): *f64 {
  if (new_count <= 0) {
    if (ptr != 0) {
      heap_libc_free(ptr as *u8);
    }
    return 0 as *f64;
  }
  let bytes: usize = (new_count as usize) * 8;
  return heap_libc_realloc(ptr as *u8, bytes) as *f64;
}

/**
 * See implementation.
 */
export function heap_free_f64_c(ptr: *f64): void {
  if (ptr != 0) {
    heap_libc_free(ptr as *u8);
  }
}

/**
 * See implementation.
 */
export function heap_copy_f64_at_c(dst: *f64, dst_offset: i32, src: *f64, count: i32): void {
  if (count <= 0) {
    return;
  }
  let n: usize = (count as usize) * 8;
  mem.mem_copy((dst + dst_offset) as *u8, src as *u8, n);
}

/**
 * See implementation.
 */
export function heap_trace_enabled_c(): i32 {
  return heap_trace_is_on();
}

/**
 * See implementation.
 */
export function heap_trace_reset_c(): void {
  xlang_heap_trace_alloc_count = 0;
  xlang_heap_trace_free_count = 0;
  xlang_heap_trace_realloc_count = 0;
  xlang_heap_trace_bytes = 0;
}

/**
 * See implementation.
 */
export function heap_trace_stats_c(alloc_count: *u64, free_count: *u64, realloc_count: *u64,
  bytes_allocated: *u64): void {
  if (alloc_count != 0) {
    alloc_count[0] = xlang_heap_trace_alloc_count;
  }
  if (free_count != 0) {
    free_count[0] = xlang_heap_trace_free_count;
  }
  if (realloc_count != 0) {
    realloc_count[0] = xlang_heap_trace_realloc_count;
  }
  if (bytes_allocated != 0) {
    bytes_allocated[0] = xlang_heap_trace_bytes;
  }
}

/** Exported function `heap_libc_module_anchor`.
 * Implements `heap_libc_module_anchor`.
 * @return i32
 */
export function heap_libc_module_anchor(): i32 { return 0; }
