// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-20：runtime_net_ipv6_fast 产品源迁 seeds/runtime_net_ipv6_fast.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_net_ipv6_fast.from_x.c → ../std/net/net_ipv6_fast.o
// G-02f-104：+ wsa/close/nonblock/poll/connect_retry 薄门闩。

export extern "C" function net_ipv6_ensure_wsa_c_impl(): i32;
export extern "C" function net_ipv6_close_socket_c_impl(fd: i32): i32;
export extern "C" function net_ipv6_set_nonblock_c_impl(fd: i32): i32;
export extern "C" function net_ipv6_poll_writable_c_impl(fd: i32, timeout_ms: u32): i32;
export extern "C" function net_ipv6_connect_retry_ok_c_impl(): i32;

export function runtime_net_ipv6_fast_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-104：ipv6 helpers 门闩 ---- */

#[no_mangle]
export function net_ipv6_ensure_wsa_c(): i32 {
  unsafe {
    return net_ipv6_ensure_wsa_c_impl();
  }
  return 0;
}

#[no_mangle]
export function net_ipv6_close_socket_c(fd: i32): i32 {
  unsafe {
    return net_ipv6_close_socket_c_impl(fd);
  }
  return 0 - 1;
}

#[no_mangle]
export function net_ipv6_set_nonblock_c(fd: i32): i32 {
  unsafe {
    return net_ipv6_set_nonblock_c_impl(fd);
  }
  return 0 - 1;
}

#[no_mangle]
export function net_ipv6_poll_writable_c(fd: i32, timeout_ms: u32): i32 {
  unsafe {
    return net_ipv6_poll_writable_c_impl(fd, timeout_ms);
  }
  return 0;
}

#[no_mangle]
export function net_ipv6_connect_retry_ok_c(): i32 {
  unsafe {
    return net_ipv6_connect_retry_ok_c_impl();
  }
  return 0;
}
