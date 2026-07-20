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
// bytes）
//
// See implementation.
// See implementation.
// ptr::copy/write_bytes、Go bytes.Equal/Compare）；
// 2) Buffer ABI and IO pre-registration: Buffer 24
// See implementation.
//
// See implementation.
// Zig: std.mem.copy、std.mem.set、std.mem.compare、@sizeOf；Rust:
// std::mem::size_of、std::ptr::copy/copy_nonoverlapping、write_bytes；
// See implementation.
const core = import("std.io.core");
const heap = import("std.heap");
const heap_libc = import("std.heap.libc");
// See implementation.
/** See implementation for details. */
export struct Buffer {
  ptr: *u8
  len: usize
  handle: usize
}
/** IO pre-register: after import("std.io.core"), call shux_io_register; shared with std.io.driver.
*/
export function register_buffer(buf: Buffer): i32 {
  return core.shux_io_register(buf.ptr, buf.len, buf.handle);
}
// See implementation.
/** Exported function `copy`.
 * Implements `copy`.
 * @param dst *u8
 * @param src *u8
 * @param n i32
 * @return void
 */
export function copy(dst: *u8, src: *u8, n: i32): void {
  if (n <= 0) { return; }
  heap_libc.heap_copy_u8_at_c(dst, 0, src, n);
}
/** Exported function `set`.
 * Implements `set`.
 * @param ptr *u8
 * @param byte u8
 * @param n i32
 * @return void
 */
export function set(ptr: *u8, byte: u8, n: i32): void {
  heap.mem_set(ptr, byte, n);
}
/** Exported function `compare`.
 * Implements `compare`.
 * @param a *u8
 * @param b *u8
 * @param n i32
 * @return i32
 */
export function compare(a: *u8, b: *u8, n: i32): i32 {
  return heap.mem_compare(a, b, n);
}

// See implementation.
/** Exported function `copy_bounded`.
 * Implements `copy_bounded`.
 * @param dst *u8
 * @param dst_cap i32
 * @param src *u8
 * @param n i32
 * @return i32
 */
export function copy_bounded(dst: *u8, dst_cap: i32, src: *u8, n: i32): i32 {
  if (n > dst_cap) { return -1; }
  if (n <= 0) { return 0; }
  copy(dst, src, n);
  return n;
}
/** Exported function `set_bounded`.
 * Implements `set_bounded`.
 * @param ptr *u8
 * @param cap i32
 * @param byte u8
 * @param n i32
 * @return i32
 */
export function set_bounded(ptr: *u8, cap: i32, byte: u8, n: i32): i32 {
  if (n > cap) { return -1; }
  if (n <= 0) { return 0; }
  set(ptr, byte, n);
  return n;
}
/** Exported function `compare_bounded`.
 * Implements `compare_bounded`.
 * @param a *u8
 * @param a_len i32
 * @param b *u8
 * @param b_len i32
 * @return i32
 */
export function compare_bounded(a: *u8, a_len: i32, b: *u8, b_len: i32): i32 {
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
/** Exported function `buffer_from`.
 * Implements `buffer_from`.
 * @param ptr *u8
 * @param len usize
 * @return Buffer
 */
export function buffer_from(ptr: *u8, len: usize): Buffer {
  return Buffer { ptr: ptr, len: len, handle: 0 };
}

/** Exported function `module_anchor`.
 * Implements `module_anchor`.
 * @return i32
 */
export function module_anchor(): i32 { return 0; }
