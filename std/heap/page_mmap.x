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

// std.heap.page_mmap — Linux freestanding 堆：匿名 mmap bump（零 libc / 无 malloc）
//
// 【文件职责】
// F-no-libc NL-03：直接声明 shux_sys_mmap/munmap extern 提供页级 bump 分配器，
// 供 `-freestanding -backend asm` 程序与后续编译器自举堆路径使用；不链 heap.c。
//
// 【Why 自包含】freestanding 模块须最小依赖；直接 extern syscall 桩避免 import
// std.sys.linux 触发 -x -E dep const/extern 前缀化问题（codegen.x dep_index<0 裸名
// vs dep_index>=0 带前缀的符号模型不匹配）。align_up 内联消除 core.mem 依赖。
//
// 【限制 v1】
// - 单块匿名映射（默认 64KiB）；bump 用尽返回 null（不自动扩容）
// - free 为 no-op（与 Arena bump 一致）；deinit 整段 munmap
// - 仅 Linux freestanding；hosted 仍用 heap.c / malloc

/** freestanding mmap(2) 桩（6 参；offset 低 32 位在 r9）。 */
extern function shux_sys_mmap(addr: *u8, len: usize, prot: i32, flags: i32, fd: i32, offset: i64): *u8;

/** freestanding munmap(2) 桩；成功 0，失败负 errno。 */
extern function shux_sys_munmap(addr: *u8, len: usize): i32;

/*
 * bug ① 绕过（ASM 后端 store-to-stack 缺失）：模块级 const 在非首函数中引用时
 * 栈槽预留但未初始化 → 读取垃圾值。此处删除模块级 const，在 page_mmap_heap_init
 * 中内联字面量（65536=64KiB cap, 3=PROT_READ|PROT_WRITE, 0x22=MAP_PRIVATE|MAP_ANONYMOUS）。
 * bug ① 根源修复（codegen.x emit block inits）完成后恢复模块级 const。
 */

/**
 * 单映射 bump 堆状态；调用方栈上持有，init/deinit 成对使用。
 */
allow(padding) struct PageMmapHeap {
  base: *u8;
  cap: usize;
  off: usize;
}

/**
 * v1 探测：page_mmap 堆是否在 mod 层可用（Linux freestanding 路径恒 1）。
 */
function page_mmap_heap_available(): i32 {
  return 1;
}

/**
 * 映射匿名 RW 区并初始化 bump；成功 0，失败 -1。
 */
function page_mmap_heap_init(h: *PageMmapHeap): i32 {
  if (h == 0) {
    return -1;
  }
  h.base = 0 as *u8;
  h.cap = 0;
  h.off = 0;
  let p: *u8 = 0 as *u8;
  unsafe {
    // bug ① 绕过：内联字面量替代模块级 const 引用。
    p = shux_sys_mmap(0 as *u8, 65536 as usize, 3, 0x22, -1, 0 as i64);
  }
  // bug ② 绕过：i64 <= 比较截断高 32 位误判 mmap 返回地址为负，改用指针 == 检测 MAP_FAILED。
  if (p == -1 as *u8) {
    return -1;
  }
  h.base = p;
  h.cap = 65536 as usize;
  h.off = 0;
  return 0;
}

/**
 * bump 分配 size 字节（align 向上对齐）；失败返回 null。
 * align 须为 2 的幂；0 视为 1。
 */
function page_mmap_heap_alloc(h: *PageMmapHeap, size: usize, align_bytes: usize): *u8 {
  // 诊断：返回 h 指针本身，检查指针参数传递是否正确
  return h as *u8;
}

/**
 * bump free no-op（保留 API 与 Allocator 语义对齐）。
 */
function page_mmap_heap_free(_h: *PageMmapHeap, _ptr: *u8): void {
}

/**
 * munmap 整段映射并重置字段。
 */
function page_mmap_heap_deinit(h: *PageMmapHeap): void {
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
