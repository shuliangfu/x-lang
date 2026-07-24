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
// net_udp_recv_many_buf_c / net_udp_send_many_buf_c。
// See implementation.
//
// See implementation.

/* See implementation. */
allow(padding) struct NetBatchBuf { ptr: *u8; length: usize; handle: usize; }

/* See implementation. */
export const UDP_BATCH_MAX: i32 = 2;

/* See implementation. */
export const UDP_BATCH_BUF_MAX: i32 = 8;

extern function net_udp_recv_from_c(fd: i32, buf: *u8, len: usize, timeout_ms: u32, out_addr_u32: *u32, out_port_u32: *u32): i32;

extern function net_udp_send_to_c(fd: i32, addr_u32: u32, port_u32: u32, buf: *u8, len: usize): i32;

#[cfg(target_os = "linux")]
extern function xlang_net_udp_recvmmsg2_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32;

#[cfg(target_os = "linux")]
extern function xlang_net_udp_sendmmsg2_c(fd: i32, a0: u32, port0: u32, p0: *u8, l0: usize, a1: u32, port1: u32, p1: *u8, l1: usize, n: i32): i32;

#[cfg(target_os = "linux")]
extern function xlang_net_udp_recvmmsg_buf_c(fd: i32, bufs: *NetBatchBuf, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32;

#[cfg(target_os = "linux")]
extern function xlang_net_udp_sendmmsg_buf_c(fd: i32, addrs: *u32, ports: *u32, bufs: *NetBatchBuf, n: i32): i32;

/**
 * See implementation.
 */
#[cfg(target_os = "linux")]
export function net_udp_recv_many_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32 {
  if (n <= 0 || n > UDP_BATCH_MAX || out_sizes == 0 || out_addrs == 0 || out_ports == 0) {
    return -1;
  }
  unsafe { return xlang_net_udp_recvmmsg2_c(fd, p0, l0, p1, l1, n, timeout_ms, out_sizes, out_addrs, out_ports); }
  return 0; // unreachable — typeck workaround
}

/**
 * See implementation.
 */
#[cfg(not(target_os = "linux"))]
export function net_udp_recv_many_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32 {
  let count: i32 = 0;
  let got: i32 = 0;
  let tm: u32 = 0;
  if (n <= 0 || n > UDP_BATCH_MAX || out_sizes == 0 || out_addrs == 0 || out_ports == 0) {
    return -1;
  }
  count = 0;
  while (count < n) {
    tm = 0;
    if (count == 0) {
      tm = timeout_ms;
    }
    if (count == 0) {
      unsafe { got = net_udp_recv_from_c(fd, p0, l0, tm, out_addrs, out_ports); }
    } else {
      unsafe { got = net_udp_recv_from_c(fd, p1, l1, tm, out_addrs + 1, out_ports + 1); }
    }
    if (got < 0) {
      return -1;
    }
    if (got == 0) {
      return count;
    }
    out_sizes[count] = got;
    count = count + 1;
  }
  return count;
}

/**
 * See implementation.
 */
#[cfg(target_os = "linux")]
export function net_udp_send_many_c(fd: i32, a0: u32, port0: u32, p0: *u8, l0: usize, a1: u32, port1: u32, p1: *u8, l1: usize, n: i32): i32 {
  if (n <= 0 || n > UDP_BATCH_MAX) {
    return -1;
  }
  unsafe { return xlang_net_udp_sendmmsg2_c(fd, a0, port0, p0, l0, a1, port1, p1, l1, n); }
  return 0; // unreachable — typeck workaround
}

/**
 * See implementation.
 */
#[cfg(not(target_os = "linux"))]
export function net_udp_send_many_c(fd: i32, a0: u32, port0: u32, p0: *u8, l0: usize, a1: u32, port1: u32, p1: *u8, l1: usize, n: i32): i32 {
  let i: i32 = 0;
  let sent: i32 = 0;
  if (n <= 0 || n > UDP_BATCH_MAX) {
    return -1;
  }
  i = 0;
  while (i < n) {
    if (i == 0) {
      unsafe { sent = net_udp_send_to_c(fd, a0, port0, p0, l0); }
    } else {
      unsafe { sent = net_udp_send_to_c(fd, a1, port1, p1, l1); }
    }
    if (sent < 0) {
      return -1;
    }
    i = i + 1;
  }
  return n;
}

/**
 * See implementation.
 */
extern function net_udp_recv_many_buf_c(fd: i32, bufs: *NetBatchBuf, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32;

/**
 * See implementation.
 */
extern function net_udp_send_many_buf_c(fd: i32, addrs: *u32, ports: *u32, bufs: *NetBatchBuf, n: i32): i32;
