// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-27：真迁 .x — 用户链 heap_*_c 薄 libc 转发（alloc/free/realloc/zeroed）。
// G-02f-rest：rest→.x 迁移：Arena64 3 函数真迁 .x，heap_alloc_aligned_c 保留 seed（平台 #ifdef）。
// 产品：./shux-c -E → seeds/runtime_heap_user.from_x.c（+ C 尾段）。
// C 尾：heap_alloc_aligned（#if WIN / posix_memalign）保留 seed（平台 #ifdef 限制）。
// 注意：strict_glue 仍可 #include 本 seed；独立 o 由 link_abi ensure 使用。
// 约定：size==0 检查须在 unsafe/malloc 外，避免 -E 把 malloc 提前到 if 前。

export extern "C" function malloc(size: usize): *u8;
export extern "C" function free(ptr: *u8): void;
export extern "C" function realloc(ptr: *u8, new_size: usize): *u8;
export extern "C" function calloc(n: usize, size: usize): *u8;

// heap_alloc_aligned_c 保留 seed（平台 #ifdef：_WIN32 _aligned_malloc / POSIX posix_memalign）
export extern "C" function heap_alloc_aligned_c(align_bytes: usize, size: usize): *u8;

/** std.heap Arena64 布局（chunk/cap/off 各 8B），与 seed C struct ABI 兼容。 */
export struct ShuxHeapArena64 {
  chunk: *u8;
  cap: usize;
  off: usize;
}

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

#[no_mangle]
export function heap_free_c(ptr: *u8): void {
  unsafe {
    free(ptr);
  }
}

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

// ---- G-02f-rest：Arena64 bump allocator（rest→.x 迁移） ----

/** 初始化 Arena64；cap==0 时用 4096 默认 chunk。 */
#[no_mangle]
export function heap_arena_init_c(a: *ShuxHeapArena64, cap: usize): i32 {
  if (a == 0 as *ShuxHeapArena64) {
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

/** 从 arena bump 分配 size 字节；align_bytes 为对象对齐（0 视为 8）。 */
#[no_mangle]
export function heap_arena64_alloc_c(a: *ShuxHeapArena64, size: usize, align_bytes: usize): *u8 {
  if (a == 0 as *ShuxHeapArena64) {
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

/** 释放 arena chunk 并重置。 */
#[no_mangle]
export function heap_arena64_deinit_c(a: *ShuxHeapArena64): void {
  if (a == 0 as *ShuxHeapArena64) {
    return;
  }
  heap_free_c(a.chunk);
  a.chunk = 0 as *u8;
  a.cap = 0;
  a.off = 0;
}
