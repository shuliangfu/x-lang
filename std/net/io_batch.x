// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0

// See implementation.

extern function io_read_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): i32;
extern function io_write_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): i32;
extern function io_read_batch_provided(fd: i32, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): i32;

/** Exported function `io_write_batch_w`.
 * Write path helper `io_write_batch_w`.
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
 * @return i32
 */
export function io_write_batch_w(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): i32 {
  let r: i32 = 0;
  unsafe { r = io_write_batch(fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms); }
  return r;
}

/** Exported function `io_read_batch_w`.
 * Read path helper `io_read_batch_w`.
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
 * @return i32
 */
export function io_read_batch_w(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): i32 {
  let r: i32 = 0;
  unsafe { r = io_read_batch(fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms); }
  return r;
}

/** Exported function `io_read_batch_provided_w`.
 * Read path helper `io_read_batch_provided_w`.
 * @param fd i32
 * @param n i32
 * @param timeout_ms u32
 * @param out_bids *u32
 * @param out_lens *u32
 * @return i32
 */
export function io_read_batch_provided_w(fd: i32, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): i32 {
  let r: i32 = 0;
  unsafe { r = io_read_batch_provided(fd, n, timeout_ms, out_bids, out_lens); }
  return r;
}

/** Exported function `net_stream_write_batch_c`.
 * Write path helper `net_stream_write_batch_c`.
 * @param stream_fd i32
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
 * @return i32
 */
export function net_stream_write_batch_c(stream_fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): i32 {
  let r: i32 = io_write_batch_w(stream_fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
  return r;
}

/** Exported function `net_stream_read_batch_c`.
 * Read path helper `net_stream_read_batch_c`.
 * @param stream_fd i32
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
 * @return i32
 */
export function net_stream_read_batch_c(stream_fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): i32 {
  let r: i32 = io_read_batch_w(stream_fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
  return r;
}

/** Exported function `net_stream_read_batch_provided_c`.
 * Read path helper `net_stream_read_batch_provided_c`.
 * @param stream_fd i32
 * @param n i32
 * @param timeout_ms u32
 * @param out_bids *u32
 * @param out_lens *u32
 * @return i32
 */
export function net_stream_read_batch_provided_c(stream_fd: i32, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): i32 {
  let r: i32 = io_read_batch_provided_w(stream_fd, n, timeout_ms, out_bids, out_lens);
  return r;
}

/** Exported function `io_batch_module_anchor`.
 * Implements `io_batch_module_anchor`.
 * @return i32
 */
export function io_batch_module_anchor(): i32 { return 0; }
