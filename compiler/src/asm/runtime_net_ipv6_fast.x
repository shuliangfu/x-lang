// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function net_ipv6_ensure_wsa_c_impl(): i32;
export extern "C" function net_ipv6_close_socket_c_impl(fd: i32): i32;
export extern "C" function net_ipv6_set_nonblock_c_impl(fd: i32): i32;
export extern "C" function net_ipv6_poll_writable_c_impl(fd: i32, timeout_ms: u32): i32;
export extern "C" function net_ipv6_connect_retry_ok_c_impl(): i32;

/** Exported function `runtime_net_ipv6_fast_x_doc_anchor`.
 * Implements `runtime_net_ipv6_fast_x_doc_anchor`.
 * @return i32
 */
export function runtime_net_ipv6_fast_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function net_ipv6_ensure_wsa_c(): i32 {
  unsafe {
    return net_ipv6_ensure_wsa_c_impl();
  }
  return 0;
}

#[no_mangle]
/** Exported function `net_ipv6_close_socket_c`.
 * Implements `net_ipv6_close_socket_c`.
 * @param fd i32
 * @return i32
 */
export function net_ipv6_close_socket_c(fd: i32): i32 {
  unsafe {
    return net_ipv6_close_socket_c_impl(fd);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `net_ipv6_set_nonblock_c`.
 * Implements `net_ipv6_set_nonblock_c`.
 * @param fd i32
 * @return i32
 */
export function net_ipv6_set_nonblock_c(fd: i32): i32 {
  unsafe {
    return net_ipv6_set_nonblock_c_impl(fd);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `net_ipv6_poll_writable_c`.
 * Implements `net_ipv6_poll_writable_c`.
 * @param fd i32
 * @param timeout_ms u32
 * @return i32
 */
export function net_ipv6_poll_writable_c(fd: i32, timeout_ms: u32): i32 {
  unsafe {
    return net_ipv6_poll_writable_c_impl(fd, timeout_ms);
  }
  return 0;
}

#[no_mangle]
/** Exported function `net_ipv6_connect_retry_ok_c`.
 * Implements `net_ipv6_connect_retry_ok_c`.
 * @return i32
 */
export function net_ipv6_connect_retry_ok_c(): i32 {
  unsafe {
    return net_ipv6_connect_retry_ok_c_impl();
  }
  return 0;
}
