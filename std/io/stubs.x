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
//
// See implementation.
// See implementation.
// See implementation.

/** Exported function `io_register_provided_buffers`.
 * Registration helper `io_register_provided_buffers`.
 * @param nr u32
 * @param bufsz u32
 * @return i32
 */
export function io_register_provided_buffers(nr: u32, bufsz: u32): i32 {
  if (nr > 0 || bufsz > 0) {
    /* See implementation. */
  }
  return 0;
}

/** Exported function `io_unregister_provided_buffers`.
 * Registration helper `io_unregister_provided_buffers`.
 * @return void
 */
export function io_unregister_provided_buffers(): void {
}

/** Exported function `io_provided_buffer_ptr`.
 * Implements `io_provided_buffer_ptr`.
 * @param bid u32
 * @return *u8
 */
export function io_provided_buffer_ptr(bid: u32): *u8 {
  if (bid > 0) {
    return 0 as *u8;
  }
  return 0 as *u8;
}

/** Exported function `io_provided_buffer_size`.
 * Implements `io_provided_buffer_size`.
 * @return u32
 */
export function io_provided_buffer_size(): u32 {
  return 0 as u32;
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
  if (fd >= 0 || timeout_ms >= 0 || out_bid != 0 || out_len != 0) {
    /* See implementation. */
  }
  return -1 as isize;
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
  if (fd >= 0 || n > 0 || timeout_ms >= 0 || out_bids != 0 || out_lens != 0) {
  }
  return -1 as isize;
}

/** Exported function `xlang_io_submit_read_async`.
 * Read path helper `xlang_io_submit_read_async`.
 * @param ptr *u8
 * @param len usize
 * @param handle usize
 * @return i32
 */
export function xlang_io_submit_read_async(ptr: *u8, len: usize, handle: usize): i32 {
  if (ptr != 0 && len > 0 && handle >= 0) {
    return -1;
  }
  return -1;
}

/** Exported function `xlang_io_complete_read_async`.
 * Read path helper `xlang_io_complete_read_async`.
 * @return i32
 */
export function xlang_io_complete_read_async(): i32 {
  return -1;
}

/** Exported function `xlang_io_complete_read_async_slot`.
 * Read path helper `xlang_io_complete_read_async_slot`.
 * @param slot i32
 * @return i32
 */
export function xlang_io_complete_read_async_slot(slot: i32): i32 {
  if (slot >= 0) {
    return -1;
  }
  return -1;
}

/** Exported function `xlang_io_submit_write_async`.
 * Write path helper `xlang_io_submit_write_async`.
 * @param ptr *u8
 * @param len usize
 * @param handle usize
 * @return i32
 */
export function xlang_io_submit_write_async(ptr: *u8, len: usize, handle: usize): i32 {
  if (ptr != 0 && len > 0 && handle >= 0) {
    return -1;
  }
  return -1;
}

/** Exported function `xlang_io_complete_write_async`.
 * Write path helper `xlang_io_complete_write_async`.
 * @return i32
 */
export function xlang_io_complete_write_async(): i32 {
  return -1;
}

/** Exported function `xlang_io_complete_write_async_slot`.
 * Write path helper `xlang_io_complete_write_async_slot`.
 * @param slot i32
 * @return i32
 */
export function xlang_io_complete_write_async_slot(slot: i32): i32 {
  if (slot >= 0) {
    return -1;
  }
  return -1;
}

/** Exported function `xlang_io_poll_async_completions`.
 * Implements `xlang_io_poll_async_completions`.
 * @param timeout_ms u32
 * @return u32
 */
export function xlang_io_poll_async_completions(timeout_ms: u32): u32 {
  if (timeout_ms >= 0) {
  }
  return 0 as u32;
}

/** Exported function `xlang_io_uring_is_available_c`.
 * Implements `xlang_io_uring_is_available_c`.
 * @return i32
 */
export function xlang_io_uring_is_available_c(): i32 {
  return 0;
}
