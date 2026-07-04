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

// std.mem — 内存操作 + 零拷贝 Buffer（对标 Zig std.mem、Rust std::mem/ptr、Go
// bytes）
//
// 【文件职责】
// 1) 内存操作：copy/set/compare（对标 Zig std.mem.copy/set/compare、Rust
// ptr::copy/write_bytes、Go bytes.Equal/Compare）；
// 2) Buffer ABI 与舒 IO 预注册（高并发 IO 第八节）：Buffer 24
// 字节、register_buffer 调 shux_io_register。
//
// 【对标】
// Zig: std.mem.copy、std.mem.set、std.mem.compare、@sizeOf；Rust:
// std::mem::size_of、std::ptr::copy/copy_nonoverlapping、write_bytes；
// Go: bytes.Equal、bytes.Compare（无独立 mem 包，bytes 提供比较）。
const core = import("std.io.core");
const heap = import("std.heap");
const heap_libc = import("std.heap.libc");
// ——— Buffer ABI 与预注册（与 std.io.driver 同布局） ———
/** Buffer：ptr 指向内存，len 为字节数，handle 为可选内核预注册句柄（0
* 表示未注册）；64 位下 8+8+8=24 字节。 */
struct Buffer {
  ptr: *u8
  len: usize
  handle: usize
}
/** 舒 IO 预注册：解构 import("std.io.core") 后调用 shux_io_register，与 std.io.driver 共用同一实现。
*/
function register_buffer(buf: Buffer): i32 {
  return core.shux_io_register(buf.ptr, buf.len, buf.handle);
}
// ——— 内存操作（对标 Zig/Rust/Go） ———
/** 字节拷贝：dst[0..n-1] = src[0..n-1]；n<=0 不写。对标 Zig std.mem.copy、Rust
* ptr::copy。 */
function copy(dst: *u8, src: *u8, n: i32): void {
  if (n <= 0) { return; }
  heap_libc.heap_copy_u8_at_c(dst, 0, src, n);
}
/** 字节填充：ptr[0..n-1] = byte；n<=0 不写。对标 Zig std.mem.set、Rust
* ptr::write_bytes。 */
function set(ptr: *u8, byte: u8, n: i32): void {
  heap.mem_set(ptr, byte, n);
}
/** 字节比较：比较 a[0..n-1] 与 b[0..n-1]；返回 <0 / 0 / >0。对标 Zig
* std.mem.compare、Go bytes.Compare。 */
function compare(a: *u8, b: *u8, n: i32): i32 {
  return heap.mem_compare(a, b, n);
}

// ——— 有界封装（STD-144） ———
/** 有界拷贝：n>dst_cap 返回 -1；n<=0 返回 0；否则 copy 并返回 n。 */
function copy_bounded(dst: *u8, dst_cap: i32, src: *u8, n: i32): i32 {
  if (n > dst_cap) { return -1; }
  if (n <= 0) { return 0; }
  copy(dst, src, n);
  return n;
}
/** 有界填充：n>cap 返回 -1；n<=0 返回 0；否则 set 并返回 n。 */
function set_bounded(ptr: *u8, cap: i32, byte: u8, n: i32): i32 {
  if (n > cap) { return -1; }
  if (n <= 0) { return 0; }
  set(ptr, byte, n);
  return n;
}
/** 有界比较：先比公共前缀，再按长度决胜。 */
function compare_bounded(a: *u8, a_len: i32, b: *u8, b_len: i32): i32 {
  let min_len: i32 = a_len;
  if (b_len < min_len) { min_len = b_len; }
  if (min_len > 0) {
    let c: i32 = compare(a, b, min_len);
    if (c != 0) { return c; }
  }
  if (a_len < b_len) { return -1; }
  if (a_len > b_len) { return 1; }
  return 0;
}
/** 从 ptr/len 构造 Buffer（handle=0）。 */
function buffer_from(ptr: *u8, len: usize): Buffer {
  return Buffer { ptr: ptr, len: len, handle: 0 };
}

/** 模块尾占位：transitive import 解析时末位 function 会丢失，须保留非 API 锚点。 */
function module_anchor(): i32 { return 0; }