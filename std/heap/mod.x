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
// See implementation.
//
// See implementation.
// Zig: page_allocator.alloc / free / realloc；Rust: alloc::alloc::{alloc, dealloc}；Go:
// See implementation.

const heap_ops = import("std.heap.ops");
const heap_libc = import("std.heap.libc");

/* See implementation. */
#[cfg(target_os = "linux")]
const page_mmap = import("std.heap.page_mmap");

/* See implementation. */
allow(padding) struct Arena64 {
  chunk: *u8;
  cap: usize;
  off: usize;
}

/** Exported function `mem_set`.
 * Implements `mem_set`.
 * @param ptr *u8
 * @param byte u8
 * @param n i32
 * @return void
 */
export function mem_set(ptr: *u8, byte: u8, n: i32): void {
  heap_ops.heap_mem_set_c(ptr, byte, n);
}

/** Exported function `mem_compare`.
 * Implements `mem_compare`.
 * @param a *u8
 * @param b *u8
 * @param n i32
 * @return i32
 */
export function mem_compare(a: *u8, b: *u8, n: i32): i32 {
  return heap_ops.heap_mem_compare_c(a, b, n);
}

/** Exported function `map_find`.
 * Implements `map_find`.
 * @param keys *i32
 * @param occupied *u8
 * @param cap i32
 * @param key i32
 * @return i32
 */
export function map_find(keys: *i32, occupied: *u8, cap: i32, key: i32): i32 {
  return heap_ops.map_i32_i32_find_c(keys, occupied, cap, key);
}

/* See implementation. */
allow(padding) struct HeapTraceStats {
  alloc_count: u64;
  free_count: u64;
  realloc_count: u64;
  bytes_allocated: u64;
}

/** Exported function `trace_on`.
 * Implements `trace_on`.
 * @return i32
 */
export function trace_on(): i32 {
  return heap_libc.heap_trace_enabled_c();
}

/** Exported function `trace_reset`.
 * Implements `trace_reset`.
 * @return void
 */
export function trace_reset(): void {
  heap_libc.heap_trace_reset_c();
}

/** Exported function `trace_stats`.
 * Implements `trace_stats`.
 * @param st *HeapTraceStats
 * @return void
 */
export function trace_stats(st: *HeapTraceStats): void {
  heap_libc.heap_trace_stats_c(&st.alloc_count, &st.free_count, &st.realloc_count, &st.bytes_allocated);
}

/** Exported function `alloc`.
 * Memory management helper `alloc`.
 * @param count i32
 * @return *u64
 */
export function alloc(count: i32): *u64 {
  return heap_libc.heap_alloc_u64_c(count);
}

/** Exported function `free`.
 * Memory management helper `free`.
 * @param ptr *u64
 * @return void
 */
export function free(ptr: *u64): void {
  heap_libc.heap_free_u64_c(ptr);
}

/** Exported function `realloc`.
 * Memory management helper `realloc`.
 * @param ptr *u64
 * @param new_count i32
 * @return *u64
 */
export function realloc(ptr: *u64, new_count: i32): *u64 {
  return heap_libc.heap_realloc_u64_c(ptr, new_count);
}

/** Exported function `copy`.
 * Implements `copy`.
 * @param dst *u64
 * @param dst_offset i32
 * @param src *u64
 * @param count i32
 * @return void
 */
export function copy(dst: *u64, dst_offset: i32, src: *u64, count: i32): void {
  heap_libc.heap_copy_u64_at_c(dst, dst_offset, src, count);
}

/** Exported function `alloc`.
 * Memory management helper `alloc`.
 * @param count i32
 * @return *f64
 */
export function alloc(count: i32): *f64 {
  return heap_libc.heap_alloc_f64_c(count);
}

/** Exported function `realloc`.
 * Memory management helper `realloc`.
 * @param ptr *f64
 * @param new_count i32
 * @return *f64
 */
export function realloc(ptr: *f64, new_count: i32): *f64 {
  return heap_libc.heap_realloc_f64_c(ptr, new_count);
}

/** Exported function `free`.
 * Memory management helper `free`.
 * @param ptr *f64
 * @return void
 */
export function free(ptr: *f64): void {
  heap_libc.heap_free_f64_c(ptr);
}

/** Exported function `copy`.
 * Implements `copy`.
 * @param dst *f64
 * @param dst_offset i32
 * @param src *f64
 * @param count i32
 * @return void
 */
export function copy(dst: *f64, dst_offset: i32, src: *f64, count: i32): void {
  heap_libc.heap_copy_f64_at_c(dst, dst_offset, src, count);
}

// See implementation.

/** Exported function `kind_heap`.
 * Implements `kind_heap`.
 * @return i32
 */
export function kind_heap(): i32 { return 0; }

/** Exported function `kind_arena`.
 * Implements `kind_arena`.
 * @return i32
 */
export function kind_arena(): i32 { return 1; }

/* See implementation. */
allow(padding) struct Allocator {
  kind: i32;
  arena: *Arena64;
}

/** Exported function `heap_alloc`.
 * Memory management helper `heap_alloc`.
 * @return Allocator
 */
export function heap_alloc(): Allocator {
  return Allocator { kind: kind_heap(), arena: 0 as *Arena64 };
}

/** Exported function `from_arena`.
 * Implements `from_arena`.
 * @param a *Arena64
 * @return Allocator
 */
export function from_arena(a: *Arena64): Allocator {
  return Allocator { kind: kind_arena(), arena: a };
}

/**
 * See implementation.
 * See implementation.
 */
export function scope_alloc(): Allocator {
  return heap_alloc();
}

/**
 * See implementation.
 * See implementation.
 */
export function default_alloc(): Allocator {
  return heap_alloc();
}

/** Exported function `alloc`.
 * Memory management helper `alloc`.
 * @param al Allocator
 * @param size usize
 * @return *u8
 */
export function alloc(al: Allocator, size: usize): *u8 {
  if (al.kind == kind_heap()) {
    return heap_libc.heap_alloc_c(size);
  }
  if (al.arena == 0) { return 0 as *u8; }
  return heap_libc.heap_arena64_alloc_c(al.arena, size, 8);
}

/** Exported function `free`.
 * Memory management helper `free`.
 * @param al Allocator
 * @param ptr *u8
 * @return void
 */
export function free(al: Allocator, ptr: *u8): void {
  if (al.kind == kind_heap()) {
    heap_libc.heap_free_c(ptr);
  }
}

/** Exported function `realloc`.
 * Memory management helper `realloc`.
 * @param al Allocator
 * @param ptr *u8
 * @param new_size usize
 * @return *u8
 */
export function realloc(al: Allocator, ptr: *u8, new_size: usize): *u8 {
  if (al.kind == kind_heap()) {
    return heap_libc.heap_realloc_c(ptr, new_size);
  }
  return 0 as *u8;
}

/**
 * See implementation.
 * See implementation.
 */
#[alloc]
export function bump(al: Allocator, size: usize): *u8 {
  return alloc(al, size);
}

// See implementation.

/** Exported function `arena64_empty`.
 * Implements `arena64_empty`.
 * @return Arena64
 */
export function arena64_empty(): Arena64 {
  return Arena64 { chunk: 0 as *u8, cap: 0, off: 0 };
}

/**
 * See implementation.
 * See implementation.
 */
export function arena64_init(a: *Arena64, cap: usize): i32 {
  return heap_libc.heap_arena64_init_c(a as *heap_libc.LibcArena64, cap);
}

/**
 * See implementation.
 * See implementation.
 */
export function arena64_alloc(a: *Arena64, size: usize, align_bytes: usize): *u8 {
  return heap_libc.heap_arena64_alloc_c(a as *heap_libc.LibcArena64, size, align_bytes);
}

/** Exported function `arena64_deinit`.
 * Implements `arena64_deinit`.
 * @param a *Arena64
 * @return void
 */
export function arena64_deinit(a: *Arena64): void {
  heap_libc.heap_arena64_deinit_c(a as *heap_libc.LibcArena64);
}

/** Exported function `ptr_mod`.
 * Implements `ptr_mod`.
 * @param ptr *u8
 * @param mod usize
 * @return usize
 */
export function ptr_mod(ptr: *u8, mod: usize): usize {
  return heap_libc.heap_ptr_mod_c(ptr, mod);
}

/** Exported function `alloc_align`.
 * Memory management helper `alloc_align`.
 * @param align_bytes usize
 * @param size usize
 * @return *u8
 */
export function alloc_align(align_bytes: usize, size: usize): *u8 {
  return heap_libc.heap_alloc_aligned_c(align_bytes, size);
}

/** Exported function `alloc`.
 * Memory management helper `alloc`.
 * @param size usize
 * @return *u8
 */
export function alloc(size: usize): *u8 {
  return heap_libc.heap_alloc_c(size);
}

/** Exported function `free`.
 * Memory management helper `free`.
 * @param ptr *u8
 * @return void
 */
export function free(ptr: *u8): void {
  heap_libc.heap_free_c(ptr);
}

/** Exported function `realloc`.
 * Memory management helper `realloc`.
 * @param ptr *u8
 * @param new_size usize
 * @return *u8
 */
export function realloc(ptr: *u8, new_size: usize): *u8 {
  return heap_libc.heap_realloc_c(ptr, new_size);
}

/** Exported function `alloc_zero`.
 * Memory management helper `alloc_zero`.
 * @param size usize
 * @return *u8
 */
export function alloc_zero(size: usize): *u8 {
  return heap_libc.heap_alloc_zeroed_c(size);
}

/** Exported function `alloc`.
 * Memory management helper `alloc`.
 * @param count i32): *i32 { return heap_libc.heap_alloc_i32_c(count
 * @return void
 */
export function alloc(count: i32): *i32 { return heap_libc.heap_alloc_i32_c(count); }

/** Exported function `realloc`.
 * Memory management helper `realloc`.
 * @param ptr *i32
 * @param new_count i32): *i32 { return heap_libc.heap_realloc_i32_c(ptr
 * @param new_count
 * @return void
 */
export function realloc(ptr: *i32, new_count: i32): *i32 { return heap_libc.heap_realloc_i32_c(ptr, new_count); }

/** Exported function `free`.
 * Memory management helper `free`.
 * @param ptr *i32): void { heap_libc.heap_free_i32_c(ptr
 * @return void
 */
export function free(ptr: *i32): void { heap_libc.heap_free_i32_c(ptr); }

/** Exported function `alloc`.
 * Memory management helper `alloc`.
 * @param count i32): *u8 { return heap_libc.heap_alloc_u8_c(count
 * @return void
 */
export function alloc(count: i32): *u8 { return heap_libc.heap_alloc_u8_c(count); }

/** Exported function `realloc`.
 * Memory management helper `realloc`.
 * @param ptr *u8
 * @param new_count i32): *u8 { return heap_libc.heap_realloc_u8_c(ptr
 * @param new_count
 * @return void
 */
export function realloc(ptr: *u8, new_count: i32): *u8 { return heap_libc.heap_realloc_u8_c(ptr, new_count); }

/** Exported function `copy`.
 * Implements `copy`.
 * @param dst *i32
 * @param dst_offset i32
 * @param src *i32
 * @param count i32
 * @return void
 */
export function copy(dst: *i32, dst_offset: i32, src: *i32, count: i32): void {
  heap_libc.heap_copy_i32_at_c(dst, dst_offset, src, count);
}

/** Exported function `copy`.
 * Implements `copy`.
 * @param dst *u8
 * @param dst_offset i32
 * @param src *u8
 * @param count i32
 * @return void
 */
export function copy(dst: *u8, dst_offset: i32, src: *u8, count: i32): void {
  heap_libc.heap_copy_u8_at_c(dst, dst_offset, src, count);
}

/** Exported function `alloc`.
 * Memory management helper `alloc`.
 * @param count i32): *f32 { return heap_libc.heap_alloc_f32_c(count
 * @return void
 */
export function alloc(count: i32): *f32 { return heap_libc.heap_alloc_f32_c(count); }

/** Exported function `realloc`.
 * Memory management helper `realloc`.
 * @param ptr *f32
 * @param new_count i32): *f32 { return heap_libc.heap_realloc_f32_c(ptr
 * @param new_count
 * @return void
 */
export function realloc(ptr: *f32, new_count: i32): *f32 { return heap_libc.heap_realloc_f32_c(ptr, new_count); }

/** Exported function `free`.
 * Memory management helper `free`.
 * @param ptr *f32): void { heap_libc.heap_free_f32_c(ptr
 * @return void
 */
export function free(ptr: *f32): void { heap_libc.heap_free_f32_c(ptr); }

/** Exported function `copy`.
 * Implements `copy`.
 * @param dst *f32
 * @param dst_offset i32
 * @param src *f32
 * @param count i32
 * @return void
 */
export function copy(dst: *f32, dst_offset: i32, src: *f32, count: i32): void {
  heap_libc.heap_copy_f32_at_c(dst, dst_offset, src, count);
}

/** Exported function `alloc_size_zero`.
 * Memory management helper `alloc_size_zero`.
 * @return i32
 */
export function alloc_size_zero(): i32 { return 0; }

// See implementation.

/** Exported function `page_heap_ok`.
 * Implements `page_heap_ok`.
 * @return i32
 */
#[cfg(target_os = "linux")]
export function page_heap_ok(): i32 {
  return page_mmap.page_mmap_heap_available();
}

/** Exported function `freestanding_page_heap_init`.
 * Memory management helper `freestanding_page_heap_init`.
 * @param h *page_mmap.PageMmapHeap
 * @return i32
 */
#[cfg(target_os = "linux")]
export function freestanding_page_heap_init(h: *page_mmap.PageMmapHeap): i32 {
  return page_mmap.page_mmap_heap_init(h);
}

/** Exported function `freestanding_page_heap_alloc`.
 * Memory management helper `freestanding_page_heap_alloc`.
 * @param h *page_mmap.PageMmapHeap
 * @param size usize
 * @param align_bytes usize
 * @return *u8
 */
#[cfg(target_os = "linux")]
export function freestanding_page_heap_alloc(h: *page_mmap.PageMmapHeap, size: usize, align_bytes: usize): *u8 {
  return page_mmap.page_mmap_heap_alloc(h, size, align_bytes);
}

/** Exported function `freestanding_page_heap_deinit`.
 * Memory management helper `freestanding_page_heap_deinit`.
 * @param h *page_mmap.PageMmapHeap
 * @return void
 */
#[cfg(target_os = "linux")]
export function freestanding_page_heap_deinit(h: *page_mmap.PageMmapHeap): void {
  page_mmap.page_mmap_heap_deinit(h);
}

/** Exported function `heap_module_anchor`.
 * Implements `heap_module_anchor`.
 * @return i32
 */
export function heap_module_anchor(): i32 { return 0; }
