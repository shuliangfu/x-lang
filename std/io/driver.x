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
// See implementation.
// See implementation.
// See implementation.
const core = import("std.io.core");
// See implementation.
export enum IO_Result {
  Ok,
  Err,
  Timeout,
  Cancelled
}
// See implementation.
export struct Buffer {
  ptr: *u8;
  len: usize;
  handle: usize;
}
// See implementation.
export struct Completion {
  tag: i32;
}
// See implementation.
export struct AsyncContext {
  flags: u32;
}
// ——— Pre-register Buffer (same ABI as std.mem.Buffer, 24 bytes); calls std.io.core ———
/** Exported function `register`.
 * Registration helper `register`.
 * @param buf Buffer
 * @return i32
 */
export function register(buf: Buffer): i32 {
  return core.xlang_io_register(buf.ptr, buf.len, buf.handle);
}
// See implementation.
// See implementation.
// submit_register_fixed_buffers_buf: see function docblock below.
/** Exported function `submit_register_fixed_buffers_buf`.
 * Registration helper `submit_register_fixed_buffers_buf`.
 * @param bufs *Buffer
 * @param nr u32
 * @return i32
 */
export function submit_register_fixed_buffers_buf(bufs: *Buffer, nr: u32): i32 {
  return core.xlang_io_register_buffers_buf(bufs as *u8, nr as i32);
}
// submit_read: see function docblock below.
/** Exported function `submit_read`.
 * Read path helper `submit_read`.
 * @param buf Buffer
 * @param timeout_ms u32
 * @return i32
 */
export function submit_read(buf: Buffer, timeout_ms: u32): i32 {
  return core.xlang_io_submit_read(buf.ptr, buf.len, buf.handle, timeout_ms);
}
// driver_read_ptr: see function docblock below.
/** Exported function `driver_read_ptr`.
 * Read path helper `driver_read_ptr`.
 * @param handle usize
 * @param timeout_ms u32
 * @return *u8
 */
export function driver_read_ptr(handle: usize, timeout_ms: u32): *u8 {
  return core.xlang_io_read_ptr(handle, timeout_ms);
}
/** Exported function `driver_read_ptr_len`.
 * Read path helper `driver_read_ptr_len`.
 * @return i32
 */
export function driver_read_ptr_len(): i32 {
  return core.xlang_io_read_ptr_len();
}
/** Exported function `driver_read_ptr_gen`.
 * Read path helper `driver_read_ptr_gen`.
 * @return u64
 */
export function driver_read_ptr_gen(): u64 {
  return core.xlang_io_read_ptr_gen();
}
/** Exported function `driver_read_ptr_gen_valid`.
 * Read path helper `driver_read_ptr_gen_valid`.
 * @param saved u64
 * @return i32
 */
export function driver_read_ptr_gen_valid(saved: u64): i32 {
  return core.xlang_io_read_ptr_gen_valid(saved);
}
/** Exported function `driver_read_ptr_backend`.
 * Read path helper `driver_read_ptr_backend`.
 * @return i32
 */
export function driver_read_ptr_backend(): i32 {
  return core.xlang_io_read_ptr_backend();
}
/** Exported function `driver_read_ptr_slice`.
 * Read path helper `driver_read_ptr_slice`.
 * @param handle usize
 * @param timeout_ms u32
 * @return u8[]<io_read_ptr>
 */
export function driver_read_ptr_slice(handle: usize, timeout_ms: u32): u8[]<io_read_ptr> {
  return core.xlang_io_read_ptr_slice(handle, timeout_ms);
}
// submit_write: see function docblock below.
/** Exported function `submit_write`.
 * Write path helper `submit_write`.
 * @param buf Buffer
 * @param timeout_ms u32
 * @return i32
 */
export function submit_write(buf: Buffer, timeout_ms: u32): i32 {
  return core.xlang_io_submit_write(buf.ptr, buf.len, buf.handle, timeout_ms);
}
// submit_read_batch: see function docblock below.
/** Exported function `submit_read_batch`.
 * Read path helper `submit_read_batch`.
 * @param buffers Buffer[4]
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function submit_read_batch(buffers: Buffer[4], n: i32, timeout_ms: u32): i32 {
  let h: usize = buffers[0].handle;
  return core.xlang_io_submit_read_batch(buffers[0].ptr, buffers[0].len, buffers[1].ptr, buffers[1].len, buffers[2].ptr, buffers[2].len, buffers[3].ptr, buffers[3].len, h, n, timeout_ms);
}
// submit_write_batch: see function docblock below.
/** Exported function `submit_write_batch`.
 * Write path helper `submit_write_batch`.
 * @param buffers Buffer[4]
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function submit_write_batch(buffers: Buffer[4], n: i32, timeout_ms: u32): i32 {
  let h: usize = buffers[0].handle;
  return core.xlang_io_submit_write_batch(buffers[0].ptr, buffers[0].len, buffers[1].ptr, buffers[1].len, buffers[2].ptr, buffers[2].len, buffers[3].ptr, buffers[3].len, h, n, timeout_ms);
}
// submit_read_batch_buf: see function docblock below.
/** Exported function `submit_read_batch_buf`.
 * Read path helper `submit_read_batch_buf`.
 * @param handle usize
 * @param bufs *Buffer
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function submit_read_batch_buf(handle: usize, bufs: *Buffer, n: i32, timeout_ms: u32): i32 {
  let r: isize = core.xlang_io_read_batch_buf(handle as i32, bufs as *u8, n, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}
/** Exported function `submit_write_batch_buf`.
 * Write path helper `submit_write_batch_buf`.
 * @param handle usize
 * @param bufs *Buffer
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function submit_write_batch_buf(handle: usize, bufs: *Buffer, n: i32, timeout_ms: u32): i32 {
  let r: isize = core.xlang_io_write_batch_buf(handle as i32, bufs as *u8, n, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}
// See implementation.
