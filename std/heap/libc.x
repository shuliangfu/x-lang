// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// std.heap.libc — F-03 v2：libc 堆分配层（malloc/free/realloc/calloc/arena/trace）
//
// 【文件职责】
// 从 heap.c 迁出的全部 libc 薄封装：typed alloc/realloc/free、块拷贝、Arena64、
// SHUX_HEAP_TRACE 统计，以及 asm 链接兼容符号 alloc_f32/realloc_f32/free_f32。
//
// 【依赖】
// - libc：malloc、free、realloc、calloc、posix_memalign、getenv
// - core.mem：mem_copy（块拷贝，避免与系统 memcpy 宏冲突）

const mem = import("core.mem");

/** DOD-CL-S2：单 chunk bump arena 默认 chunk 字节数（须为 64 倍数）。 */
const HEAP_ARENA64_DEFAULT_CAP: usize = 4096;

/** libc 堆接口（hosted 路径由链接器解析 -lc）。 */
extern "C" function malloc(size: usize): *u8;
extern "C" function free(ptr: *u8): void;
extern "C" function realloc(ptr: *u8, new_size: usize): *u8;
extern "C" function calloc(nmemb: usize, size: usize): *u8;
extern "C" function posix_memalign(memptr: * *void, alignment: usize, size: usize): i32;
extern "C" function getenv(name: *u8): *u8;

/** libc 堆/环境 FFI 须 unsafe；薄包装供 heap_*_c 调用。 */
function heap_libc_malloc(size: usize): *u8 {
  unsafe { return malloc(size); }
}
function heap_libc_free(ptr: *u8): void {
  unsafe { free(ptr); }
}
function heap_libc_realloc(ptr: *u8, new_size: usize): *u8 {
  unsafe { return realloc(ptr, new_size); }
}
function heap_libc_calloc(nmemb: usize, size: usize): *u8 {
  unsafe { return calloc(nmemb, size); }
}
function heap_libc_posix_memalign(memptr: * *void, alignment: usize, size: usize): i32 {
  unsafe { return posix_memalign(memptr, alignment, size); }
}
function heap_libc_getenv(name: *u8): *u8 {
  unsafe { return getenv(name); }
}

/** SHUX_HEAP_TRACE 环境变量名（NUL 结尾）。 */
let SHUX_HEAP_TRACE_ENV: u8[16] = [
  83, 72, 85, 88, 95, 72, 69, 65, 80, 95, 84, 82, 65, 67, 69, 0,
];

/** STD-017：trace 懒加载状态（-1 未初始化，0/1 已读 getenv）。 */
let shu_heap_trace_on: i32 = -1;
let shu_heap_trace_alloc_count: u64 = 0;
let shu_heap_trace_free_count: u64 = 0;
let shu_heap_trace_realloc_count: u64 = 0;
let shu_heap_trace_bytes: u64 = 0;

/** void* 指针对齐下限（hosted 64-bit 为 8 字节）。 */
const HEAP_PTR_SIZE: usize = 8;

/** 与 std.heap/mod.x Arena64 布局一致（chunk/cap/off）。 */
allow(padding) struct Arena64 {
  chunk: *u8;
  cap: usize;
  off: usize;
}

/**
 * 懒加载 SHUX_HEAP_TRACE：env 首字符为 '1' 时启用统计。
 * 返回值：1 启用，0 未启用。
 */
function heap_trace_is_on(): i32 {
  if (shu_heap_trace_on >= 0) {
    return shu_heap_trace_on;
  }
  let env: *u8 = heap_libc_getenv(&SHUX_HEAP_TRACE_ENV[0]);
  if (env != 0 && env[0] == 49) {
    shu_heap_trace_on = 1;
  } else {
    shu_heap_trace_on = 0;
  }
  return shu_heap_trace_on;
}

/**
 * 分配成功时更新 trace 计数（alloc 次数与累计字节）。
 */
function heap_trace_note_alloc(size: usize): void {
  if (heap_trace_is_on() == 0) {
    return;
  }
  shu_heap_trace_alloc_count = shu_heap_trace_alloc_count + 1;
  shu_heap_trace_bytes = shu_heap_trace_bytes + (size as u64);
}

/**
 * free 时更新 trace 计数（free 次数）。
 */
function heap_trace_note_free(): void {
  if (heap_trace_is_on() == 0) {
    return;
  }
  shu_heap_trace_free_count = shu_heap_trace_free_count + 1;
}

/**
 * 分配 size 字节，未初始化；size==0 或失败返回 null。
 * 供 std.heap alloc 与 LSP heap_alloc_c 符号使用。
 */
function heap_alloc_c(size: usize): *u8 {
  if (size == 0) {
    return 0;
  }
  let p: *u8 = heap_libc_malloc(size);
  if (p != 0) {
    heap_trace_note_alloc(size);
  }
  return p;
}

/**
 * 释放 ptr；ptr 为 null 时不操作（与 C free 一致）。
 */
function heap_free_c(ptr: *u8): void {
  if (ptr == 0) {
    return;
  }
  heap_trace_note_free();
  heap_libc_free(ptr);
}

/**
 * 将 ptr 调整为 new_size 字节；new_size==0 等价于 free 并返回 null。
 * 失败返回 null 且原 ptr 未释放。
 */
function heap_realloc_c(ptr: *u8, new_size: usize): *u8 {
  if (new_size == 0) {
    if (ptr != 0) {
      heap_libc_free(ptr);
    }
    return 0;
  }
  return heap_libc_realloc(ptr, new_size);
}

/**
 * 分配 size 字节并清零（calloc(1,size)）；size==0 或失败返回 null。
 */
function heap_alloc_zeroed_c(size: usize): *u8 {
  if (size == 0) {
    return 0;
  }
  return heap_libc_calloc(1, size);
}

/**
 * 分配 count 个 i32；count<=0 或失败返回 null。
 */
function heap_alloc_i32_c(count: i32): *i32 {
  if (count <= 0) {
    return 0;
  }
  let bytes: usize = (count as usize) * 4;
  return heap_libc_malloc(bytes) as *i32;
}

/**
 * 将 ptr 调整为 new_count 个 i32；new_count<=0 时 free 并返回 null。
 */
function heap_realloc_i32_c(ptr: *i32, new_count: i32): *i32 {
  if (new_count <= 0) {
    if (ptr != 0) {
      heap_libc_free(ptr as *u8);
    }
    return 0;
  }
  let bytes: usize = (new_count as usize) * 4;
  return heap_libc_realloc(ptr as *u8, bytes) as *i32;
}

/**
 * 释放 heap_alloc_i32_c / heap_realloc_i32_c 分配的 ptr；ptr 可为 null。
 */
function heap_free_i32_c(ptr: *i32): void {
  if (ptr != 0) {
    heap_libc_free(ptr as *u8);
  }
}

/**
 * 分配 count 个 u8；count<=0 或失败返回 null。
 */
function heap_alloc_u8_c(count: i32): *u8 {
  if (count <= 0) {
    return 0;
  }
  return heap_libc_malloc(count as usize);
}

/**
 * 将 ptr 调整为 new_count 个 u8；new_count<=0 时 free 并返回 null。
 */
function heap_realloc_u8_c(ptr: *u8, new_count: i32): *u8 {
  if (new_count <= 0) {
    if (ptr != 0) {
      heap_libc_free(ptr);
    }
    return 0;
  }
  return heap_libc_realloc(ptr, new_count);
}

/**
 * 释放 heap_alloc_u8_c / heap_realloc_u8_c 分配的 ptr；ptr 可为 null。
 */
function heap_free_u8_c(ptr: *u8): void {
  if (ptr != 0) {
    heap_libc_free(ptr);
  }
}

/**
 * 块拷贝 i32：dst[dst_offset..] = src[0..count-1]；count<=0 不写。
 */
function heap_copy_i32_at_c(dst: *i32, dst_offset: i32, src: *i32, count: i32): void {
  if (count <= 0) {
    return;
  }
  let n: usize = (count as usize) * 4;
  mem.mem_copy((dst + dst_offset) as *u8, src as *u8, n);
}

/**
 * 块拷贝 u8：dst[dst_offset..] = src[0..count-1]；count<=0 不写。
 */
function heap_copy_u8_at_c(dst: *u8, dst_offset: i32, src: *u8, count: i32): void {
  if (count <= 0) {
    return;
  }
  mem.mem_copy((dst + dst_offset) as *u8, src, count);
}

/**
 * 分配 count 个 f32；count<=0 或失败返回 null（DOD-S2 SoA 列）。
 */
function heap_alloc_f32_c(count: i32): *f32 {
  if (count <= 0) {
    return 0;
  }
  let bytes: usize = (count as usize) * 4;
  return heap_libc_malloc(bytes) as *f32;
}

/**
 * 将 ptr 调整为 new_count 个 f32；new_count<=0 时 free 并返回 null。
 */
function heap_realloc_f32_c(ptr: *f32, new_count: i32): *f32 {
  if (new_count <= 0) {
    if (ptr != 0) {
      heap_libc_free(ptr as *u8);
    }
    return 0;
  }
  let bytes: usize = (new_count as usize) * 4;
  return heap_libc_realloc(ptr as *u8, bytes) as *f32;
}

/**
 * 释放 heap_alloc_f32_c / heap_realloc_f32_c 分配的 ptr；ptr 可为 null。
 */
function heap_free_f32_c(ptr: *f32): void {
  if (ptr != 0) {
    heap_libc_free(ptr as *u8);
  }
}

/**
 * 块拷贝 f32 列；count<=0 不写。
 */
function heap_copy_f32_at_c(dst: *f32, dst_offset: i32, src: *f32, count: i32): void {
  if (count <= 0) {
    return;
  }
  let n: usize = (count as usize) * 4;
  mem.mem_copy((dst + dst_offset) as *u8, src as *u8, n);
}

/**
 * asm 路径薄包装：alloc_f32 → heap_alloc_f32_c（与 ast_pool_bootstrap_glue 表一致）。
 */
function alloc_f32(count: i32): *f32 {
  return heap_alloc_f32_c(count);
}

/**
 * asm 路径薄包装：realloc_f32 → heap_realloc_f32_c。
 */
function realloc_f32(ptr: *f32, new_count: i32): *f32 {
  return heap_realloc_f32_c(ptr, new_count);
}

/**
 * asm 路径薄包装：free_f32 → heap_free_f32_c。
 */
function free_f32(ptr: *f32): void {
  heap_free_f32_c(ptr);
}

/**
 * posix_memalign 分配；align 须为 2 的幂且 ≥ sizeof(void*)；失败返回 null。
 */
function heap_alloc_aligned_c(align_bytes: usize, size: usize): *u8 {
  let obj_align: usize = align_bytes;
  let slot: *void = 0 as *void;
  if (size == 0) {
    return 0;
  }
  if (obj_align < HEAP_PTR_SIZE) {
    obj_align = HEAP_PTR_SIZE;
  }
  if (heap_libc_posix_memalign(&slot, obj_align, size) != 0) {
    return 0;
  }
  return slot as *u8;
}

/**
 * 返回 (ptr as usize) % mod；mod==0 或 ptr==null 时返回 0（对齐 smoke 用）。
 */
function heap_ptr_mod_c(ptr: *u8, mod: usize): usize {
  if (ptr == 0 || mod == 0) {
    return 0;
  }
  return (ptr as usize) % mod;
}

/**
 * 初始化 Arena64；cap==0 时用 HEAP_ARENA64_DEFAULT_CAP；失败返回 -1。
 */
function heap_arena64_init_c(a: *Arena64, cap: usize): i32 {
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
 * arena bump 内核：obj_align 须 >0（由 heap_arena64_alloc_c 保证默认 8）。
 */
function heap_arena64_bump_c(a: *Arena64, size: usize, obj_align: usize): *u8 {
  let cur: usize = 0;
  let rem: usize = 0;
  let gap: usize = 0;
  let next: usize = 0;
  if (a == 0 || a.chunk == 0 || size == 0) {
    return 0;
  }
  cur = a.off;
  rem = cur % obj_align;
  if (rem != 0) {
    gap = obj_align - rem;
  }
  next = cur + gap + size;
  if (next > a.cap) {
    return 0;
  }
  let out: *u8 = a.chunk + cur + gap;
  a.off = next;
  return out;
}

/**
 * 从 arena bump 分配 size 字节；align 为对象对齐（0 视为 8）；空间不足返回 null。
 */
function heap_arena64_alloc_c(a: *Arena64, size: usize, align_bytes: usize): *u8 {
  if (align_bytes == 0) {
    return heap_arena64_bump_c(a, size, HEAP_PTR_SIZE);
  }
  return heap_arena64_bump_c(a, size, align_bytes);
}

/**
 * 释放 arena chunk 并重置 off/cap（经 heap_free_c 以参与 trace）。
 */
function heap_arena64_deinit_c(a: *Arena64): void {
  if (a == 0) {
    return;
  }
  heap_free_c(a.chunk);
  a.chunk = 0 as *u8;
  a.cap = 0;
  a.off = 0;
}

/**
 * 分配 count 个 u64；count<=0 或失败返回 null（STD-013 Map_u64）。
 */
function heap_alloc_u64_c(count: i32): *u64 {
  if (count <= 0) {
    return 0;
  }
  let bytes: usize = (count) * 8;
  return heap_libc_malloc(bytes) as *u64;
}

/**
 * 释放 heap_alloc_u64_c 分配的 ptr。
 */
function heap_free_u64_c(ptr: *u64): void {
  if (ptr != 0) {
    heap_libc_free(ptr as *u8);
  }
}

/**
 * 将 ptr 调整为 new_count 个 u64；new_count<=0 时 free 并返回 null。
 */
function heap_realloc_u64_c(ptr: *u64, new_count: i32): *u64 {
  if (new_count <= 0) {
    if (ptr != 0) {
      heap_libc_free(ptr as *u8);
    }
    return 0;
  }
  let bytes: usize = (new_count as usize) * 8;
  return heap_libc_realloc(ptr as *u8, bytes) as *u64;
}

/**
 * 块拷贝 u64 列；count<=0 不写（STD-014 Vec_u64）。
 */
function heap_copy_u64_at_c(dst: *u64, dst_offset: i32, src: *u64, count: i32): void {
  if (count <= 0) {
    return;
  }
  let n: usize = (count as usize) * 8;
  mem.mem_copy((dst + dst_offset) as *u8, src as *u8, n);
}

/**
 * 分配 count 个 f64；count<=0 或失败返回 null（STD-014 Vec_f64）。
 */
function heap_alloc_f64_c(count: i32): *f64 {
  if (count <= 0) {
    return 0;
  }
  let bytes: usize = (count as usize) * 8;
  return heap_libc_malloc(bytes) as *f64;
}

/**
 * 将 ptr 调整为 new_count 个 f64；new_count<=0 时 free 并返回 null。
 */
function heap_realloc_f64_c(ptr: *f64, new_count: i32): *f64 {
  if (new_count <= 0) {
    if (ptr != 0) {
      heap_libc_free(ptr as *u8);
    }
    return 0;
  }
  let bytes: usize = (new_count as usize) * 8;
  return heap_libc_realloc(ptr as *u8, bytes) as *f64;
}

/**
 * 释放 heap_alloc_f64_c / heap_realloc_f64_c 分配的 ptr。
 */
function heap_free_f64_c(ptr: *f64): void {
  if (ptr != 0) {
    heap_libc_free(ptr as *u8);
  }
}

/**
 * 块拷贝 f64 列；count<=0 不写。
 */
function heap_copy_f64_at_c(dst: *f64, dst_offset: i32, src: *f64, count: i32): void {
  if (count <= 0) {
    return;
  }
  let n: usize = (count as usize) * 8;
  mem.mem_copy((dst + dst_offset) as *u8, src as *u8, n);
}

/**
 * STD-017：trace 是否启用（1/0）。
 */
function heap_trace_enabled_c(): i32 {
  return heap_trace_is_on();
}

/**
 * STD-017：重置 trace 计数器（不改变 on/off 懒加载状态）。
 */
function heap_trace_reset_c(): void {
  shu_heap_trace_alloc_count = 0;
  shu_heap_trace_free_count = 0;
  shu_heap_trace_realloc_count = 0;
  shu_heap_trace_bytes = 0;
}

/**
 * STD-017：读取 trace 统计到输出指针（与 HeapTraceStats ABI 一致；null 指针跳过）。
 */
function heap_trace_stats_c(alloc_count: *u64, free_count: *u64, realloc_count: *u64,
  bytes_allocated: *u64): void {
  if (alloc_count != 0) {
    alloc_count[0] = shu_heap_trace_alloc_count;
  }
  if (free_count != 0) {
    free_count[0] = shu_heap_trace_free_count;
  }
  if (realloc_count != 0) {
    realloc_count[0] = shu_heap_trace_realloc_count;
  }
  if (bytes_allocated != 0) {
    bytes_allocated[0] = shu_heap_trace_bytes;
  }
}

/** 模块尾占位：transitive import 解析锚点。 */
function heap_libc_module_anchor(): i32 { return 0; }
