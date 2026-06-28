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

// std.io.read_ptr — F-03 v2/v3：TLS 风格 read_ptr 内部缓冲（无 mmap/dispatch_data）
//
// 【文件职责】
// io_read_ptr / io_read_ptr_len / generation 校验；v1 仅用模块级 64KiB 缓冲 + io_read 拷贝。
// backend 恒为 0（TLS）；ZC-2 mmap/dispatch_data 留待 v3+。
//
// 【依赖】
// 平台 sync 模块提供 io_read。

#[cfg(target_os = "linux")]
const io_sync = import("std.io.sync");
#[cfg(target_os = "macos")]
const io_sync = import("std.io.sync");
#[cfg(target_os = "windows")]
const io_sync = import("std.io.win32");

/** read_ptr 内部缓冲大小（与 io.c IO_READ_PTR_BUF_SIZE 一致）。 */
const IO_READ_PTR_BUF_SIZE: usize = 65536;

/** M-5：u8[] slice ABI（与 shux_slice_uint8_t 一致）。 */
allow(padding) struct ShuxSliceU8 { data: *u8; length: usize; }

/** 模块级 read_ptr 缓冲（v1 单缓冲；并发 read_ptr 不隔离）。 */
let g_io_read_ptr_buf: u8[65536] = [];
let g_io_read_ptr_len: i32 = 0;
let g_io_read_ptr_gen: u64 = 0 as u64;
let g_io_read_ptr_backend: i32 = 0;

/**
 * 零拷贝读：读入内部缓冲并返回只读指针；失败返回 0。
 * 任意调用均递增 generation（含失败路径）。
 */
function io_read_ptr(handle: usize, timeout_ms: u32): *u8 {
  g_io_read_ptr_gen = g_io_read_ptr_gen + 1;
  g_io_read_ptr_backend = 0;
  let fd: i32 = (handle as i32);
  let r: isize = io_sync.io_read(fd, &g_io_read_ptr_buf[0], IO_READ_PTR_BUF_SIZE, timeout_ms);
  if (r < 0) {
    g_io_read_ptr_len = 0;
    return 0;
  }
  g_io_read_ptr_len = (r as i32);
  return &g_io_read_ptr_buf[0];
}

/** 返回最近一次 io_read_ptr 成功读入的字节数。 */
function io_read_ptr_len(): i32 {
  return g_io_read_ptr_len;
}

/** 返回当前 read_ptr generation。 */
function io_read_ptr_gen(): u64 {
  return g_io_read_ptr_gen;
}

/** saved 与当前 gen 相等返回 1，否则 0。 */
function io_read_ptr_gen_valid(saved: u64): i32 {
  if (saved == g_io_read_ptr_gen) {
    return 1;
  }
  return 0;
}

/** 返回上次 read_ptr 后端：v1 恒为 0（TLS 缓冲）。 */
function io_read_ptr_backend(): i32 {
  return g_io_read_ptr_backend;
}

/** 零拷贝读并打包为 u8[] slice 视图。 */
function io_read_ptr_slice(handle: usize, timeout_ms: u32): ShuxSliceU8 {
  let p: *u8 = io_read_ptr(handle, timeout_ms);
  let s: ShuxSliceU8;
  s.data = p;
  if (p != 0) {
    s.length = (g_io_read_ptr_len as usize);
  } else {
    s.length = 0;
  }
  return s;
}
