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
// F-no-libc NL-03：用 std.sys.linux 的 shux_sys_mmap/munmap 提供页级 bump 分配器，
// 供 `-freestanding -backend asm` 程序与后续编译器自举堆路径使用；不链 heap.c。
//
// 【限制 v1】
// - 单块匿名映射（默认 64KiB）；bump 用尽返回 null（不自动扩容）
// - free 为 no-op（与 Arena bump 一致）；deinit 整段 munmap
// - 仅 Linux freestanding；hosted 仍用 heap.c / malloc

const linux = import("std.sys.linux");
const mem = import("core.mem");

/** 默认映射大小：64KiB（16 × 4KiB 页，够 freestanding smoke 与小工具）。 */
const PAGE_MMAP_DEFAULT_CAP: usize = 65536;

/** Linux MAP_PRIVATE | MAP_ANONYMOUS（与 linux_mmap_invoke_smoke 一致）。 */
const PAGE_MMAP_PROT_RW: i32 = 1 | 2;
const PAGE_MMAP_FLAGS: i32 = 2 | 0x20;

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
  let p: *u8 = linux.linux_anonymous_mmap(
    PAGE_MMAP_DEFAULT_CAP,
    PAGE_MMAP_PROT_RW,
    PAGE_MMAP_FLAGS,
  );
  let p_i: i64 = p as i64;
  if (p_i <= 0) {
    return -1;
  }
  h.base = p;
  h.cap = PAGE_MMAP_DEFAULT_CAP;
  h.off = 0;
  return 0;
}

/**
 * bump 分配 size 字节（align 向上对齐）；失败返回 null。
 * align 须为 2 的幂；0 视为 1。
 */
function page_mmap_heap_alloc(h: *PageMmapHeap, size: usize, align_bytes: usize): *u8 {
  if (h == 0 || h.base == 0 || size == 0) {
    return 0;
  }
  let a: usize = align_bytes;
  if (a == 0) {
    a = 1;
  }
  let start: usize = mem.align_up(h.off, a);
  let end: usize = start + size;
  if (end > h.cap || end < start) {
    return 0;
  }
  let out: *u8 = h.base + start;
  h.off = end;
  return out;
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
    linux.linux_syscall_munmap(h.base, h.cap);
  }
  h.base = 0 as *u8;
  h.cap = 0;
  h.off = 0;
}
