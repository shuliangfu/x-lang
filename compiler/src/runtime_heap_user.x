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

/**
 * posix_memalign. align_bytes must be a power of two and a multiple of sizeof(void*).
 * Declared on macOS and Linux separately: a sole foreign cfg, and cfg(not(...))
 * inside a large translation unit, are avoided.
 * @param out **u8 — slot that receives the block
 * @param align_bytes usize — alignment; the name is not `align` (that word is a keyword)
 * @param size usize — byte count
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
#[cfg(target_os = "macos")]
export extern "C" function posix_memalign(out: **u8, align_bytes: usize, size: usize): i32;

/**
 * posix_memalign. Same contract as the macOS declaration.
 * @param out **u8 — slot that receives the block
 * @param align_bytes usize — alignment
 * @param size usize — byte count
 * @return i32 — 0 on success
 * PLATFORM: LINUX
 */
#[cfg(target_os = "linux")]
export extern "C" function posix_memalign(out: **u8, align_bytes: usize, size: usize): i32;

/**
 * Windows aligned allocation. The caller frees with heap_free_c's free path only
 * when the block came from malloc; this product tail matches the C seed and
 * returns the pointer for the arena init.
 * @param size usize — byte count
 * @param align_bytes usize — alignment
 * @return *u8 — block, or null
 * PLATFORM: WINDOWS
 */
#[cfg(target_os = "windows")]
export extern "C" function _aligned_malloc(size: usize, align_bytes: usize): *u8;

/**
 * Allocate size bytes at align_bytes. A zero size or a zero alignment returns null.
 * @param align_bytes usize — alignment; 0 fails
 * @param size usize — byte count; 0 fails
 * @return *u8 — block, or null
 * PLATFORM: MACOS|DARWIN
 */
#[cfg(target_os = "macos")]
#[no_mangle]
export function heap_alloc_aligned_c(align_bytes: usize, size: usize): *u8 {
  if (size == 0 || align_bytes == 0) {
    return 0 as *u8;
  }
  let p: *u8 = 0 as *u8;
  let slot: **u8 = &p;
  unsafe {
    if (posix_memalign(slot, align_bytes, size) != 0) {
      return 0 as *u8;
    }
  }
  return p;
}

/**
 * Allocate size bytes at align_bytes. A zero size or a zero alignment returns null.
 * @param align_bytes usize — alignment; 0 fails
 * @param size usize — byte count; 0 fails
 * @return *u8 — block, or null
 * PLATFORM: LINUX
 */
#[cfg(target_os = "linux")]
#[no_mangle]
export function heap_alloc_aligned_c(align_bytes: usize, size: usize): *u8 {
  if (size == 0 || align_bytes == 0) {
    return 0 as *u8;
  }
  let p: *u8 = 0 as *u8;
  let slot: **u8 = &p;
  unsafe {
    if (posix_memalign(slot, align_bytes, size) != 0) {
      return 0 as *u8;
    }
  }
  return p;
}

/**
 * Allocate size bytes at align_bytes. A zero size or a zero alignment returns null.
 * @param align_bytes usize — alignment; 0 fails
 * @param size usize — byte count; 0 fails
 * @return *u8 — block, or null
 * PLATFORM: WINDOWS
 */
#[cfg(target_os = "windows")]
#[no_mangle]
export function heap_alloc_aligned_c(align_bytes: usize, size: usize): *u8 {
  if (size == 0 || align_bytes == 0) {
    return 0 as *u8;
  }
  unsafe {
    return _aligned_malloc(size, align_bytes);
  }
  return 0 as *u8;
}

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
  // obj_align is 8 when the caller passes 0, and posix_memalign already
  // rejects a non-power-of-two. A variable divisor emits xlang_panic_ and
  // pure asm refuses the object, so the gap is cur masked by align-1.
  // PLATFORM: SHARED.
  let mask: usize = obj_align - 1;
  let rem: usize = cur & mask;
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
