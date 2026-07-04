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

// lsp_io_std_heap.x — 提供 std_heap_alloc / std_heap_free，供 lsp_io_x.o 链接
//
// 职责：在 bootstrap 构建中，lsp_io.x 使用 std.heap 时仅生成 extern
// std_heap_alloc/std_heap_free；
// 本模块转调 libc malloc/free/calloc（F-03 v2 不再依赖 std/heap/heap.o）。

/** libc 堆分配/释放/清零；链接时由 -lc 解析。 */
extern function malloc(size: usize): *u8;
extern function free(ptr: *u8): void;
extern function calloc(nmemb: usize, size: usize): *u8;

/** 分配 size 字节，返回指针；失败返回 null。供 lsp_io 层通过 std_heap_alloc
* 名链接。 */
function std_heap_alloc(size: usize): *u8 {
  if (size == 0 as usize) {
    return 0 as *u8;
  }
  return malloc(size);
}

/** 分配 size 字节并清零；失败返回 null。parser -E-extern 路径引用
* std_heap_alloc_zeroed 名。 */
function std_heap_alloc_zeroed(size: usize): *u8 {
  if (size == 0 as usize) {
    return 0 as *u8;
  }
  return calloc(1 as usize, size);
}

/** 释放 ptr；ptr 可为 null（libc free 对 null 无操作）。供 lsp_io 层通过
* std_heap_free 名链接。 */
function std_heap_free(ptr: *u8): void {
  if (ptr == 0 as *u8) {
    return;
  }
  free(ptr);
}
