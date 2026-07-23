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

// std.io.core — IO core layer for driver and std.mem.
// F-03 v2/v3: underlying io_* comes from std.io.backend pure .x (libc sync).
// Contract: return >0 = bytes transferred, 0 = EOF (read only), -1 = error; timeout_ms 0 = no timeout.
const io_backend = import("std.io.backend");

// Pre-register a fixed buffer for this thread (single buffer). v1 stores (ptr,len) for read_fixed/write_fixed. handle unused. Returns 1 ok, 0 fail.
/** Exported function `xlang_io_register`.
 * Registration helper `xlang_io_register`.
 * @param ptr *u8
 * @param len usize
 * @param handle usize
 * @return i32
 */
export function xlang_io_register(ptr: *u8, len: usize, handle: usize): i32 {
  if (handle >= 0) {
    /* handle currently unused. */
  }
  return io_backend.io_register_buffer(ptr, len);
}
// Pre-register up to 4 fixed buffers for this thread ((p0,l0)..(p3,l3)); nr is count 1..4. Returns 1 ok, 0 fail.
/** Exported function `xlang_io_register_buffers`.
 * Registration helper `xlang_io_register_buffers`.
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @param p2 *u8
 * @param l2 usize
 * @param p3 *u8
 * @param l3 usize
 * @param nr u32
 * @return i32
 */
export function xlang_io_register_buffers(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, nr: u32): i32 {
  return io_backend.io_register_buffers_4(p0, l0, p1, l1, p2, l2, p3, l3, nr);
}
// Unregister the thread-local fixed buffer pool.
/** Exported function `xlang_io_unregister_buffers`.
 * Registration helper `xlang_io_unregister_buffers`.
 * @return void
 */
export function xlang_io_unregister_buffers(): void {
  io_backend.io_unregister_buffers();
}
// Read into a registered fixed buffer. buf_index currently only 0; offset+len must be within registered length. handle is fd. Returns bytes, 0=EOF, -1=error/timeout.
/** Exported function `xlang_io_read_fixed`.
 * Read path helper `xlang_io_read_fixed`.
 * @param handle usize
 * @param buf_index u32
 * @param offset usize
 * @param len usize
 * @param timeout_ms u32
 * @return i32
 */
export function xlang_io_read_fixed(handle: usize, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): i32 {
  let fd: i32 = (handle as i32);
  let r: isize = io_backend.io_read_fixed(fd, buf_index, offset, len, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}
// Write from a registered fixed buffer. buf_index currently only 0; offset+len within registered length. Returns bytes written, -1=error/timeout.
/** Exported function `xlang_io_write_fixed`.
 * Write path helper `xlang_io_write_fixed`.
 * @param handle usize
 * @param buf_index u32
 * @param offset usize
 * @param len usize
 * @param timeout_ms u32
 * @return i32
 */
export function xlang_io_write_fixed(handle: usize, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): i32 {
  let fd: i32 = (handle as i32);
  let r: isize = io_backend.io_write_fixed(fd, buf_index, offset, len, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}
// Wait until any of n fds is readable. Returns index 0..n-1 of first ready fd, or -1 on timeout/error. Prefer n <= 8.
/** Exported function `xlang_io_wait_readable`.
 * Read path helper `xlang_io_wait_readable`.
 * @param fds *i32
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function xlang_io_wait_readable(fds: *i32, n: i32, timeout_ms: u32): i32 {
  return io_backend.io_wait_readable(fds, n, timeout_ms);
}
// Synchronous read: handle 0=stdin, handle>=2 is fd; timeout_ms in ms (0=no timeout). Returns bytes, 0=EOF, -1=error/timeout.
/** Exported function `xlang_io_submit_read`.
 * Read path helper `xlang_io_submit_read`.
 * @param ptr *u8
 * @param len usize
 * @param handle usize
 * @param timeout_ms u32
 * @return i32
 */
export function xlang_io_submit_read(ptr: *u8, len: usize, handle: usize, timeout_ms: u32): i32 {
  let fd: i32 = (handle as i32);
  if (handle == 0 || handle >= 2) {
    let r: isize = io_backend.io_read(fd, ptr, len, timeout_ms);
    if (r < 0) { return -1; }
    return (r as i32);
  }
  return -1;
}
// xlang_io_read_ptr: see function docblock below.
/** Exported function `xlang_io_read_ptr`.
 * Read path helper `xlang_io_read_ptr`.
 * @param handle usize
 * @param timeout_ms u32
 * @return *u8
 */
export function xlang_io_read_ptr(handle: usize, timeout_ms: u32): *u8 {
  return io_backend.io_read_ptr(handle, timeout_ms);
}
/** Exported function `xlang_io_read_ptr_len`.
 * Read path helper `xlang_io_read_ptr_len`.
 * @return i32
 */
export function xlang_io_read_ptr_len(): i32 {
  return io_backend.io_read_ptr_len();
}
/** Exported function `xlang_io_read_ptr_gen`.
 * Read path helper `xlang_io_read_ptr_gen`.
 * @return u64
 */
export function xlang_io_read_ptr_gen(): u64 {
  return io_backend.io_read_ptr_gen();
}
/** Exported function `xlang_io_read_ptr_gen_valid`.
 * Read path helper `xlang_io_read_ptr_gen_valid`.
 * @param saved u64
 * @return i32
 */
export function xlang_io_read_ptr_gen_valid(saved: u64): i32 {
  return io_backend.io_read_ptr_gen_valid(saved);
}
/** Exported function `xlang_io_read_ptr_backend`.
 * Read path helper `xlang_io_read_ptr_backend`.
 * @return i32
 */
export function xlang_io_read_ptr_backend(): i32 {
  return io_backend.io_read_ptr_backend();
}
/** Exported function `xlang_io_read_ptr_slice`.
 * Read path helper `xlang_io_read_ptr_slice`.
 * @param handle usize
 * @param timeout_ms u32
 * @return u8[]<io_read_ptr>
 */
export function xlang_io_read_ptr_slice(handle: usize, timeout_ms: u32): u8[]<io_read_ptr> {
  return io_backend.io_read_ptr_slice(handle, timeout_ms);
}
// xlang_io_submit_write: see function docblock below.
/** Exported function `xlang_io_submit_write`.
 * Write path helper `xlang_io_submit_write`.
 * @param ptr *u8
 * @param len usize
 * @param handle usize
 * @param timeout_ms u32
 * @return i32
 */
export function xlang_io_submit_write(ptr: *u8, len: usize, handle: usize, timeout_ms: u32): i32 {
  let fd: i32 = (handle as i32);
  if (handle >= 1) {
    let r: isize = io_backend.io_write(fd, ptr, len, timeout_ms);
    if (r < 0) { return -1; }
    return (r as i32);
  }
  return -1;
}
// xlang_io_submit_read_batch: see function docblock below.
/** Exported function `xlang_io_submit_read_batch`.
 * Read path helper `xlang_io_submit_read_batch`.
 * @param ptr0 *u8
 * @param len0 usize
 * @param ptr1 *u8
 * @param len1 usize
 * @param ptr2 *u8
 * @param len2 usize
 * @param ptr3 *u8
 * @param len3 usize
 * @param handle usize
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function xlang_io_submit_read_batch(ptr0: *u8, len0: usize, ptr1: *u8, len1: usize, ptr2: *u8, len2: usize, ptr3: *u8, len3: usize, handle: usize, n: i32, timeout_ms: u32): i32 {
  let fd: i32 = (handle as i32);
  if (handle == 0 || handle >= 2) {
    let r: isize = io_backend.io_read_batch(fd, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, n, timeout_ms);
    if (r < 0) { return -1; }
    return (r as i32);
  }
  return -1;
}
// xlang_io_submit_write_batch: see function docblock below.
/** Exported function `xlang_io_submit_write_batch`.
 * Write path helper `xlang_io_submit_write_batch`.
 * @param ptr0 *u8
 * @param len0 usize
 * @param ptr1 *u8
 * @param len1 usize
 * @param ptr2 *u8
 * @param len2 usize
 * @param ptr3 *u8
 * @param len3 usize
 * @param handle usize
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function xlang_io_submit_write_batch(ptr0: *u8, len0: usize, ptr1: *u8, len1: usize, ptr2: *u8, len2: usize, ptr3: *u8, len3: usize, handle: usize, n: i32, timeout_ms: u32): i32 {
  let fd: i32 = (handle as i32);
  if (handle >= 1) {
    let r: isize = io_backend.io_write_batch(fd, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, n, timeout_ms);
    if (r < 0) { return -1; }
    return (r as i32);
  }
  return -1;
}
/** Exported function `xlang_io_register_buffers_buf`.
 * Registration helper `xlang_io_register_buffers_buf`.
 * @param bufs *u8
 * @param nr i32
 * @return i32
 */
export function xlang_io_register_buffers_buf(bufs: *u8, nr: i32): i32 {
  return io_backend.io_register_buffers_buf(bufs, nr);
}
/** Exported function `xlang_io_read_batch_buf`.
 * Read path helper `xlang_io_read_batch_buf`.
 * @param fd i32
 * @param bufs *u8
 * @param n i32
 * @param timeout_ms u32
 * @return isize
 */
export function xlang_io_read_batch_buf(fd: i32, bufs: *u8, n: i32, timeout_ms: u32): isize {
  return io_backend.io_read_batch_buf(fd, bufs, n, timeout_ms);
}
/** Exported function `xlang_io_write_batch_buf`.
 * Write path helper `xlang_io_write_batch_buf`.
 * @param fd i32
 * @param bufs *u8
 * @param n i32
 * @param timeout_ms u32
 * @return isize
 */
export function xlang_io_write_batch_buf(fd: i32, bufs: *u8, n: i32, timeout_ms: u32): isize {
  return io_backend.io_write_batch_buf(fd, bufs, n, timeout_ms);
}
// See implementation.
/** Exported function `xlang_io_register_provided_buffers`.
 * Registration helper `xlang_io_register_provided_buffers`.
 * @param nr u32
 * @param bufsz u32
 * @return i32
 */
export function xlang_io_register_provided_buffers(nr: u32, bufsz: u32): i32 {
  return io_backend.io_register_provided_buffers(nr, bufsz);
}
/** Exported function `xlang_io_unregister_provided_buffers`.
 * Registration helper `xlang_io_unregister_provided_buffers`.
 * @return void
 */
export function xlang_io_unregister_provided_buffers(): void {
  io_backend.io_unregister_provided_buffers();
}
/** Exported function `xlang_io_provided_buffer_ptr`.
 * Implements `xlang_io_provided_buffer_ptr`.
 * @param bid u32
 * @return *u8
 */
export function xlang_io_provided_buffer_ptr(bid: u32): *u8 {
  return io_backend.io_provided_buffer_ptr(bid);
}
/** Exported function `xlang_io_provided_buffer_size`.
 * Implements `xlang_io_provided_buffer_size`.
 * @return u32
 */
export function xlang_io_provided_buffer_size(): u32 {
  return io_backend.io_provided_buffer_size();
}
/** Exported function `xlang_io_read_provided`.
 * Read path helper `xlang_io_read_provided`.
 * @param handle usize
 * @param timeout_ms u32
 * @param out_bid *u32
 * @param out_len *u32
 * @return i32
 */
export function xlang_io_read_provided(handle: usize, timeout_ms: u32, out_bid: *u32, out_len: *u32): i32 {
  let fd: i32 = (handle as i32);
  if (handle == 0 || handle >= 2) {
    let r: isize = io_backend.io_read_provided(fd, timeout_ms, out_bid, out_len);
    if (r < 0) { return -1; }
    return (r as i32);
  }
  return -1;
}
/** Exported function `xlang_io_read_batch_provided`.
 * Read path helper `xlang_io_read_batch_provided`.
 * @param handle usize
 * @param n i32
 * @param timeout_ms u32
 * @param out_bids *u32
 * @param out_lens *u32
 * @return i32
 */
export function xlang_io_read_batch_provided(handle: usize, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): i32 {
  let fd: i32 = (handle as i32);
  if (handle == 0 || handle >= 2) {
    let r: isize = io_backend.io_read_batch_provided(fd, n, timeout_ms, out_bids, out_lens);
    if (r < 0) { return -1; }
    return (r as i32);
  }
  return -1;
}
// xlang_io_submit_read_async: see function docblock below.
/** Exported function `xlang_io_submit_read_async`.
 * Read path helper `xlang_io_submit_read_async`.
 * @param ptr *u8
 * @param len usize
 * @param handle usize
 * @return i32
 */
export function xlang_io_submit_read_async(ptr: *u8, len: usize, handle: usize): i32 {
  return io_backend.xlang_io_submit_read_async(ptr, len, handle);
}
/** Exported function `xlang_io_complete_read_async`.
 * Read path helper `xlang_io_complete_read_async`.
 * @return i32
 */
export function xlang_io_complete_read_async(): i32 {
  return io_backend.xlang_io_complete_read_async();
}
/** Exported function `xlang_io_complete_read_async_slot`.
 * Read path helper `xlang_io_complete_read_async_slot`.
 * @param slot i32
 * @return i32
 */
export function xlang_io_complete_read_async_slot(slot: i32): i32 {
  return io_backend.xlang_io_complete_read_async_slot(slot);
}
/** Exported function `xlang_io_submit_write_async`.
 * Write path helper `xlang_io_submit_write_async`.
 * @param ptr *u8
 * @param len usize
 * @param handle usize
 * @return i32
 */
export function xlang_io_submit_write_async(ptr: *u8, len: usize, handle: usize): i32 {
  return io_backend.xlang_io_submit_write_async(ptr, len, handle);
}
/** Exported function `xlang_io_complete_write_async`.
 * Write path helper `xlang_io_complete_write_async`.
 * @return i32
 */
export function xlang_io_complete_write_async(): i32 {
  return io_backend.xlang_io_complete_write_async();
}
/** Exported function `xlang_io_complete_write_async_slot`.
 * Write path helper `xlang_io_complete_write_async_slot`.
 * @param slot i32
 * @return i32
 */
export function xlang_io_complete_write_async_slot(slot: i32): i32 {
  return io_backend.xlang_io_complete_write_async_slot(slot);
}
/** Exported function `xlang_io_poll_async_completions`.
 * Implements `xlang_io_poll_async_completions`.
 * @param timeout_ms u32
 * @return u32
 */
export function xlang_io_poll_async_completions(timeout_ms: u32): u32 {
  return io_backend.xlang_io_poll_async_completions(timeout_ms);
}
/** Exported function `xlang_io_uring_is_available_c`.
 * Implements `xlang_io_uring_is_available_c`.
 * @return i32
 */
export function xlang_io_uring_is_available_c(): i32 {
  return io_backend.xlang_io_uring_is_available_c();
}
