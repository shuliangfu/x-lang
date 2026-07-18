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

// std.io.backend — F-03 v2/v3: IO C ABI aggregation layer (replaces io.c + io.o)
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.

#[cfg(target_os = "linux")]
const io_platform = import("std.io.sync");
#[cfg(target_os = "macos")]
const io_platform = import("std.io.sync");
#[cfg(target_os = "windows")]
const io_platform = import("std.io.win32");

const io_read_ptr_mod = import("std.io.read_ptr");
const io_stubs_mod = import("std.io.stubs");

/* See implementation. */
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.

/* See implementation. */

export function io_read(fd: i32, buf: *u8, count: usize, timeout_ms: u32): isize {
  return io_platform.io_read(fd, buf, count, timeout_ms);
}

/** Exported function `io_write`.
 * Write path helper `io_write`.
 * @param fd i32
 * @param buf *u8
 * @param count usize
 * @param timeout_ms u32
 * @return isize
 */
export function io_write(fd: i32, buf: *u8, count: usize, timeout_ms: u32): isize {
  return io_platform.io_write(fd, buf, count, timeout_ms);
}

/** Exported function `io_read_batch`.
 * Read path helper `io_read_batch`.
 * @param fd i32
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @param p2 *u8
 * @param l2 usize
 * @param p3 *u8
 * @param l3 usize
 * @param n i32
 * @param timeout_ms u32
 * @return isize
 */
export function io_read_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): isize {
  return io_platform.io_read_batch(fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
}

/** Exported function `io_write_batch`.
 * Write path helper `io_write_batch`.
 * @param fd i32
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @param p2 *u8
 * @param l2 usize
 * @param p3 *u8
 * @param l3 usize
 * @param n i32
 * @param timeout_ms u32
 * @return isize
 */
export function io_write_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): isize {
  return io_platform.io_write_batch(fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
}

/** Exported function `io_read_batch_buf`.
 * Read path helper `io_read_batch_buf`.
 * @param fd i32
 * @param bufs *u8
 * @param n i32
 * @param timeout_ms u32
 * @return isize
 */
export function io_read_batch_buf(fd: i32, bufs: *u8, n: i32, timeout_ms: u32): isize {
  let batch: *IoBatchBuf = bufs as *IoBatchBuf;
  return io_platform.io_read_batch_buf(fd, batch, n, timeout_ms);
}

/** Exported function `io_write_batch_buf`.
 * Write path helper `io_write_batch_buf`.
 * @param fd i32
 * @param bufs *u8
 * @param n i32
 * @param timeout_ms u32
 * @return isize
 */
export function io_write_batch_buf(fd: i32, bufs: *u8, n: i32, timeout_ms: u32): isize {
  let batch: *IoBatchBuf = bufs as *IoBatchBuf;
  return io_platform.io_write_batch_buf(fd, batch, n, timeout_ms);
}

/** Exported function `io_register_buffer`.
 * Registration helper `io_register_buffer`.
 * @param ptr *u8
 * @param len usize
 * @return i32
 */
export function io_register_buffer(ptr: *u8, len: usize): i32 {
  return io_platform.io_register_buffer(ptr, len);
}

/** Exported function `io_register_buffers_4`.
 * Registration helper `io_register_buffers_4`.
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
export function io_register_buffers_4(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, nr: u32): i32 {
  return io_platform.io_register_buffers_4(p0, l0, p1, l1, p2, l2, p3, l3, nr);
}

/** Exported function `io_register_buffers_buf`.
 * Registration helper `io_register_buffers_buf`.
 * @param bufs *u8
 * @param nr i32
 * @return i32
 */
export function io_register_buffers_buf(bufs: *u8, nr: i32): i32 {
  let batch: *IoBatchBuf = bufs as *IoBatchBuf;
  return io_platform.io_register_buffers_buf(batch, nr);
}

/** Exported function `io_unregister_buffers`.
 * Registration helper `io_unregister_buffers`.
 * @return void
 */
export function io_unregister_buffers(): void {
  io_platform.io_unregister_buffers();
}

/** Exported function `io_read_fixed`.
 * Read path helper `io_read_fixed`.
 * @param fd i32
 * @param buf_index u32
 * @param offset usize
 * @param len usize
 * @param timeout_ms u32
 * @return isize
 */
export function io_read_fixed(fd: i32, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): isize {
  return io_platform.io_read_fixed(fd, buf_index, offset, len, timeout_ms);
}

/** Exported function `io_write_fixed`.
 * Write path helper `io_write_fixed`.
 * @param fd i32
 * @param buf_index u32
 * @param offset usize
 * @param len usize
 * @param timeout_ms u32
 * @return isize
 */
export function io_write_fixed(fd: i32, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): isize {
  return io_platform.io_write_fixed(fd, buf_index, offset, len, timeout_ms);
}

/** Exported function `io_wait_readable`.
 * Read path helper `io_wait_readable`.
 * @param fds *i32
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function io_wait_readable(fds: *i32, n: i32, timeout_ms: u32): i32 {
  return io_platform.io_wait_readable(fds, n, timeout_ms);
}

/* See implementation. */

export function io_read_ptr(handle: usize, timeout_ms: u32): *u8 {
  return io_read_ptr_mod.io_read_ptr(handle, timeout_ms);
}

/** Exported function `io_read_ptr_len`.
 * Read path helper `io_read_ptr_len`.
 * @return i32
 */
export function io_read_ptr_len(): i32 {
  return io_read_ptr_mod.io_read_ptr_len();
}

/** Exported function `io_read_ptr_gen`.
 * Read path helper `io_read_ptr_gen`.
 * @return u64
 */
export function io_read_ptr_gen(): u64 {
  return io_read_ptr_mod.io_read_ptr_gen();
}

/** Exported function `io_read_ptr_gen_valid`.
 * Read path helper `io_read_ptr_gen_valid`.
 * @param saved u64
 * @return i32
 */
export function io_read_ptr_gen_valid(saved: u64): i32 {
  return io_read_ptr_mod.io_read_ptr_gen_valid(saved);
}

/** Exported function `io_read_ptr_backend`.
 * Read path helper `io_read_ptr_backend`.
 * @return i32
 */
export function io_read_ptr_backend(): i32 {
  return io_read_ptr_mod.io_read_ptr_backend();
}

/** Exported function `io_read_ptr_slice`.
 * Read path helper `io_read_ptr_slice`.
 * @param handle usize
 * @param timeout_ms u32
 * @return u8[]<io_read_ptr>
 */
export function io_read_ptr_slice(handle: usize, timeout_ms: u32): u8[]<io_read_ptr> {
  let s: ShuxSliceU8 = io_read_ptr_mod.io_read_ptr_slice(handle, timeout_ms);
  let out: u8[]<io_read_ptr>;
  out.data = s.data;
  out.length = s.length;
  return out;
}

/* See implementation. */

export function io_register_provided_buffers(nr: u32, bufsz: u32): i32 {
  return io_stubs_mod.io_register_provided_buffers(nr, bufsz);
}

/** Exported function `io_unregister_provided_buffers`.
 * Registration helper `io_unregister_provided_buffers`.
 * @return void
 */
export function io_unregister_provided_buffers(): void {
  io_stubs_mod.io_unregister_provided_buffers();
}

/** Exported function `io_provided_buffer_ptr`.
 * Implements `io_provided_buffer_ptr`.
 * @param bid u32
 * @return *u8
 */
export function io_provided_buffer_ptr(bid: u32): *u8 {
  return io_stubs_mod.io_provided_buffer_ptr(bid);
}

/** Exported function `io_provided_buffer_size`.
 * Implements `io_provided_buffer_size`.
 * @return u32
 */
export function io_provided_buffer_size(): u32 {
  return io_stubs_mod.io_provided_buffer_size();
}

/** Exported function `io_read_provided`.
 * Read path helper `io_read_provided`.
 * @param fd i32
 * @param timeout_ms u32
 * @param out_bid *u32
 * @param out_len *u32
 * @return isize
 */
export function io_read_provided(fd: i32, timeout_ms: u32, out_bid: *u32, out_len: *u32): isize {
  return io_stubs_mod.io_read_provided(fd, timeout_ms, out_bid, out_len);
}

/** Exported function `io_read_batch_provided`.
 * Read path helper `io_read_batch_provided`.
 * @param fd i32
 * @param n i32
 * @param timeout_ms u32
 * @param out_bids *u32
 * @param out_lens *u32
 * @return isize
 */
export function io_read_batch_provided(fd: i32, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): isize {
  return io_stubs_mod.io_read_batch_provided(fd, n, timeout_ms, out_bids, out_lens);
}

/** Exported function `shux_io_submit_read_async`.
 * Read path helper `shux_io_submit_read_async`.
 * @param ptr *u8
 * @param len usize
 * @param handle usize
 * @return i32
 */
export function shux_io_submit_read_async(ptr: *u8, len: usize, handle: usize): i32 {
  return io_stubs_mod.shux_io_submit_read_async(ptr, len, handle);
}

/** Exported function `shux_io_complete_read_async`.
 * Read path helper `shux_io_complete_read_async`.
 * @return i32
 */
export function shux_io_complete_read_async(): i32 {
  return io_stubs_mod.shux_io_complete_read_async();
}

/** Exported function `shux_io_complete_read_async_slot`.
 * Read path helper `shux_io_complete_read_async_slot`.
 * @param slot i32
 * @return i32
 */
export function shux_io_complete_read_async_slot(slot: i32): i32 {
  return io_stubs_mod.shux_io_complete_read_async_slot(slot);
}

/** Exported function `shux_io_submit_write_async`.
 * Write path helper `shux_io_submit_write_async`.
 * @param ptr *u8
 * @param len usize
 * @param handle usize
 * @return i32
 */
export function shux_io_submit_write_async(ptr: *u8, len: usize, handle: usize): i32 {
  return io_stubs_mod.shux_io_submit_write_async(ptr, len, handle);
}

/** Exported function `shux_io_complete_write_async`.
 * Write path helper `shux_io_complete_write_async`.
 * @return i32
 */
export function shux_io_complete_write_async(): i32 {
  return io_stubs_mod.shux_io_complete_write_async();
}

/** Exported function `shux_io_complete_write_async_slot`.
 * Write path helper `shux_io_complete_write_async_slot`.
 * @param slot i32
 * @return i32
 */
export function shux_io_complete_write_async_slot(slot: i32): i32 {
  return io_stubs_mod.shux_io_complete_write_async_slot(slot);
}

/** Exported function `shux_io_poll_async_completions`.
 * Implements `shux_io_poll_async_completions`.
 * @param timeout_ms u32
 * @return u32
 */
export function shux_io_poll_async_completions(timeout_ms: u32): u32 {
  return io_stubs_mod.shux_io_poll_async_completions(timeout_ms);
}

/** Exported function `shux_io_uring_is_available_c`.
 * Implements `shux_io_uring_is_available_c`.
 * @return i32
 */
export function shux_io_uring_is_available_c(): i32 {
  return io_stubs_mod.shux_io_uring_is_available_c();
}

/* See implementation. */

export function shux_io_register(ptr: *u8, len: usize, handle: usize): i32 {
  if (handle >= 0) {
    /* handle currently unused. */
  }
  return io_register_buffer(ptr, len);
}

/** Exported function `shux_io_submit_read`.
 * Read path helper `shux_io_submit_read`.
 * @param ptr *u8
 * @param len usize
 * @param handle usize
 * @param timeout_ms u32
 * @return i32
 */
export function shux_io_submit_read(ptr: *u8, len: usize, handle: usize, timeout_ms: u32): i32 {
  let r: isize = io_read((handle as i32), ptr, len, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

/** Exported function `shux_io_submit_write`.
 * Write path helper `shux_io_submit_write`.
 * @param ptr *u8
 * @param len usize
 * @param handle usize
 * @param timeout_ms u32
 * @return i32
 */
export function shux_io_submit_write(ptr: *u8, len: usize, handle: usize, timeout_ms: u32): i32 {
  let r: isize = io_write((handle as i32), ptr, len, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

/** Exported function `shux_io_read_ptr`.
 * Read path helper `shux_io_read_ptr`.
 * @param handle usize
 * @param timeout_ms u32
 * @return *u8
 */
export function shux_io_read_ptr(handle: usize, timeout_ms: u32): *u8 {
  return io_read_ptr(handle, timeout_ms);
}

/** Exported function `shux_io_read_ptr_len`.
 * Read path helper `shux_io_read_ptr_len`.
 * @return i32
 */
export function shux_io_read_ptr_len(): i32 {
  return io_read_ptr_len();
}

/** Exported function `shux_io_read_ptr_gen`.
 * Read path helper `shux_io_read_ptr_gen`.
 * @return u64
 */
export function shux_io_read_ptr_gen(): u64 {
  return io_read_ptr_gen();
}

/** Exported function `shux_io_read_ptr_gen_valid`.
 * Read path helper `shux_io_read_ptr_gen_valid`.
 * @param saved u64
 * @return i32
 */
export function shux_io_read_ptr_gen_valid(saved: u64): i32 {
  return io_read_ptr_gen_valid(saved);
}

/** Exported function `shux_io_read_ptr_backend`.
 * Read path helper `shux_io_read_ptr_backend`.
 * @return i32
 */
export function shux_io_read_ptr_backend(): i32 {
  return io_read_ptr_backend();
}

/** Exported function `shux_io_read_ptr_slice`.
 * Read path helper `shux_io_read_ptr_slice`.
 * @param handle usize
 * @param timeout_ms u32
 * @return ShuxSliceU8
 */
export function shux_io_read_ptr_slice(handle: usize, timeout_ms: u32): ShuxSliceU8 {
  return io_read_ptr_mod.io_read_ptr_slice(handle, timeout_ms);
}

/** Exported function `handle_from_fd`.
 * Implements `handle_from_fd`.
 * @param fd i32
 * @param _unused i32
 * @return usize
 */
export function handle_from_fd(fd: i32, _unused: i32): usize {
  return (fd as usize);
}

/** Exported function `shux_io_read_fixed`.
 * Read path helper `shux_io_read_fixed`.
 * @param handle usize
 * @param buf_index u32
 * @param offset usize
 * @param len usize
 * @param timeout_ms u32
 * @return i32
 */
export function shux_io_read_fixed(handle: usize, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): i32 {
  let r: isize = io_read_fixed((handle as i32), buf_index, offset, len, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

/** Exported function `shux_io_write_fixed`.
 * Write path helper `shux_io_write_fixed`.
 * @param handle usize
 * @param buf_index u32
 * @param offset usize
 * @param len usize
 * @param timeout_ms u32
 * @return i32
 */
export function shux_io_write_fixed(handle: usize, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): i32 {
  let r: isize = io_write_fixed((handle as i32), buf_index, offset, len, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

/** Exported function `shux_io_submit_read_batch`.
 * Read path helper `shux_io_submit_read_batch`.
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @param p2 *u8
 * @param l2 usize
 * @param p3 *u8
 * @param l3 usize
 * @param handle usize
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function shux_io_submit_read_batch(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, handle: usize, n: i32, timeout_ms: u32): i32 {
  if (!(handle == 0 || handle >= 2)) {
    return -1;
  }
  let r: isize = io_read_batch((handle as i32), p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

/** Exported function `shux_io_submit_write_batch`.
 * Write path helper `shux_io_submit_write_batch`.
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @param p2 *u8
 * @param l2 usize
 * @param p3 *u8
 * @param l3 usize
 * @param handle usize
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function shux_io_submit_write_batch(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, handle: usize, n: i32, timeout_ms: u32): i32 {
  if (handle < 1) {
    return -1;
  }
  let r: isize = io_write_batch((handle as i32), p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

/** Exported function `submit_read_batch_buf`.
 * Read path helper `submit_read_batch_buf`.
 * @param handle usize
 * @param bufs *u8
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function submit_read_batch_buf(handle: usize, bufs: *u8, n: i32, timeout_ms: u32): i32 {
  let r: isize = io_read_batch_buf((handle as i32), bufs, n, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

/** Exported function `submit_write_batch_buf`.
 * Write path helper `submit_write_batch_buf`.
 * @param handle usize
 * @param bufs *u8
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function submit_write_batch_buf(handle: usize, bufs: *u8, n: i32, timeout_ms: u32): i32 {
  let r: isize = io_write_batch_buf((handle as i32), bufs, n, timeout_ms);
  if (r < 0) { return -1; }
  return (r as i32);
}

/** Exported function `submit_register_fixed_buffers_buf`.
 * Registration helper `submit_register_fixed_buffers_buf`.
 * @param bufs *u8
 * @param nr u32
 * @return i32
 */
export function submit_register_fixed_buffers_buf(bufs: *u8, nr: u32): i32 {
  let ok: i32 = io_register_buffers_buf(bufs, (nr as i32));
  if (ok != 0) { return ok; }
  return 0;
}

/** Exported function `shux_io_register_provided_buffers`.
 * Registration helper `shux_io_register_provided_buffers`.
 * @param nr u32
 * @param bufsz u32
 * @return i32
 */
export function shux_io_register_provided_buffers(nr: u32, bufsz: u32): i32 {
  return io_register_provided_buffers(nr, bufsz);
}

/** Exported function `shux_io_unregister_provided_buffers`.
 * Registration helper `shux_io_unregister_provided_buffers`.
 * @return void
 */
export function shux_io_unregister_provided_buffers(): void {
  io_unregister_provided_buffers();
}

/** Exported function `shux_io_provided_buffer_ptr`.
 * Implements `shux_io_provided_buffer_ptr`.
 * @param bid u32
 * @return *u8
 */
export function shux_io_provided_buffer_ptr(bid: u32): *u8 {
  return io_provided_buffer_ptr(bid);
}

/** Exported function `shux_io_provided_buffer_size`.
 * Implements `shux_io_provided_buffer_size`.
 * @return u32
 */
export function shux_io_provided_buffer_size(): u32 {
  return io_provided_buffer_size();
}

/** Exported function `shux_io_read_batch_provided`.
 * Read path helper `shux_io_read_batch_provided`.
 * @param handle usize
 * @param n i32
 * @param timeout_ms u32
 * @param out_bids *u32
 * @param out_lens *u32
 * @return i32
 */
export function shux_io_read_batch_provided(handle: usize, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): i32 {
  if (!(handle == 0 || handle >= 2)) {
    return -1;
  }
  let r: isize = io_read_batch_provided((handle as i32), n, timeout_ms, out_bids, out_lens);
  if (r < 0) { return -1; }
  return (r as i32);
}

/** Exported function `shux_io_read_provided`.
 * Read path helper `shux_io_read_provided`.
 * @param handle usize
 * @param timeout_ms u32
 * @param out_bid *u32
 * @param out_len *u32
 * @return i32
 */
export function shux_io_read_provided(handle: usize, timeout_ms: u32, out_bid: *u32, out_len: *u32): i32 {
  if (!(handle == 0 || handle >= 2)) {
    return -1;
  }
  let r: isize = io_read_provided((handle as i32), timeout_ms, out_bid, out_len);
  if (r < 0) { return -1; }
  return (r as i32);
}

/** Exported function `io_backend_anchor`.
 * Implements `io_backend_anchor`.
 * @return i32
 */
export function io_backend_anchor(): i32 { return 0; }
