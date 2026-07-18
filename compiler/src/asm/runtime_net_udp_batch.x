// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function shu_udp_batch_set_addr_port_impl(sin: *u8, addr_u32: u32, port_u32: u32): void;
export extern "C" function shu_udp_batch_poll_readable_impl(fd: i32, timeout_ms: u32): i32;

/** Exported function `runtime_net_udp_batch_x_doc_anchor`.
 * Implements `runtime_net_udp_batch_x_doc_anchor`.
 * @return i32
 */
export function runtime_net_udp_batch_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function shu_udp_batch_set_addr_port(sin: *u8, addr_u32: u32, port_u32: u32): void {
  unsafe {
    shu_udp_batch_set_addr_port_impl(sin, addr_u32, port_u32);
  }
}

/** Exported function `shu_udp_batch_poll_readable`.
 * Read path helper `shu_udp_batch_poll_readable`.
 * @param fd i32
 * @param timeout_ms u32
 * @return i32
 */
#[no_mangle]
export function shu_udp_batch_poll_readable(fd: i32, timeout_ms: u32): i32 {
  unsafe {
    return shu_udp_batch_poll_readable_impl(fd, timeout_ms);
  }
  return 0;
}
