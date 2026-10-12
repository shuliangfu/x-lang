// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_net_io_batch_fast_linux.x — Linux OS half for net_io_batch_fast.o.
// Forwards UDP batch impl to Cap xlang_net_udp_*mmsg_buf_c (U here;
// product Cap body lives in runtime_net_udp_batch.o).
// PLATFORM: LINUX.

struct XlangBuffer {
  ptr: *u8;
  len: usize;
  handle: usize;
}

extern "C" function xlang_net_udp_recvmmsg_buf_c(fd: i32, bufs: *XlangBuffer, n: i32, timeout_ms: u32,
  out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32;
extern "C" function xlang_net_udp_sendmmsg_buf_c(fd: i32, addrs: *u32, ports: *u32, bufs: *XlangBuffer, n: i32): i32;

#[no_mangle]
export function net_udp_recv_many_buf_impl_c(fd: i32, bufs: *XlangBuffer, n: i32, timeout_ms: u32,
  out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32 {
  unsafe {
    return xlang_net_udp_recvmmsg_buf_c(fd, bufs, n, timeout_ms, out_sizes, out_addrs, out_ports);
  }
}

#[no_mangle]
export function net_udp_send_many_buf_impl_c(fd: i32, addrs: *u32, ports: *u32, bufs: *XlangBuffer, n: i32): i32 {
  unsafe {
    return xlang_net_udp_sendmmsg_buf_c(fd, addrs, ports, bufs, n);
  }
}
