// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// std.net.io_batch — F-04 v11：TcpStream 批量读写薄包装（→ std.io io_*）

extern function io_read_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): i32;
extern function io_write_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): i32;
extern function io_read_batch_provided(fd: i32, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): i32;

/** io_write_batch 包装（extern 须在 unsafe 内调用）。 */
function io_write_batch_w(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): i32 {
  let r: i32 = 0;
  unsafe { r = io_write_batch(fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms); }
  return r;
}

/** io_read_batch 包装。 */
function io_read_batch_w(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): i32 {
  let r: i32 = 0;
  unsafe { r = io_read_batch(fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms); }
  return r;
}

/** io_read_batch_provided 包装。 */
function io_read_batch_provided_w(fd: i32, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): i32 {
  let r: i32 = 0;
  unsafe { r = io_read_batch_provided(fd, n, timeout_ms, out_bids, out_lens); }
  return r;
}

/** stream_write_batch 薄包装 → io_write_batch（bench 用）。 */
function net_stream_write_batch_c(stream_fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): i32 {
  let r: i32 = io_write_batch_w(stream_fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
  return r;
}

/** stream_read_batch 薄包装 → io_read_batch。 */
function net_stream_read_batch_c(stream_fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): i32 {
  let r: i32 = io_read_batch_w(stream_fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
  return r;
}

/** ZC-1：stream 批量 provided recv 薄包装。 */
function net_stream_read_batch_provided_c(stream_fd: i32, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): i32 {
  let r: i32 = io_read_batch_provided_w(stream_fd, n, timeout_ms, out_bids, out_lens);
  return r;
}

/** 模块锚点：transitive import 解析时末位 function 须保留。 */
function io_batch_module_anchor(): i32 { return 0; }
