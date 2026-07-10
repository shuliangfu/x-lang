// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-27：真迁 .x — 用户链 heap_*_c 薄 libc 转发（alloc/free/realloc/zeroed）。
// 产品：./shux-c -E → seeds/runtime_heap_user.from_x.c（+ C 尾段）。
// C 尾：heap_alloc_aligned（#if WIN / posix_memalign）与 Arena64 bump（struct 字段）。
// 注意：strict_glue 仍可 #include 本 seed；独立 o 由 link_abi ensure 使用。
// 约定：size==0 检查须在 unsafe/malloc 外，避免 -E 把 malloc 提前到 if 前。

extern "C" function malloc(size: usize): *u8;
extern "C" function free(ptr: *u8): void;
extern "C" function realloc(ptr: *u8, new_size: usize): *u8;
extern "C" function calloc(n: usize, size: usize): *u8;

#[no_mangle]
function heap_alloc_c(size: usize): *u8 {
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
function heap_free_c(ptr: *u8): void {
  unsafe {
    free(ptr);
  }
}

#[no_mangle]
function heap_realloc_c(ptr: *u8, new_size: usize): *u8 {
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
function heap_alloc_zeroed_c(size: usize): *u8 {
  if (size == 0) {
    return 0 as *u8;
  }
  unsafe {
    let r: *u8 = calloc(1, size);
    return r;
  }
  return 0 as *u8;
}
