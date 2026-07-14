// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-20：runtime_net_udp_batch 产品源迁 seeds/runtime_net_udp_batch.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_net_udp_batch.from_x.c → runtime_net_udp_batch.o
// G-02f-102：+ set_addr_port / poll_readable 薄门闩。

export extern "C" function shu_udp_batch_set_addr_port_impl(sin: *u8, addr_u32: u32, port_u32: u32): void;
export extern "C" function shu_udp_batch_poll_readable_impl(fd: i32, timeout_ms: u32): i32;

export function runtime_net_udp_batch_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-102：udp batch helpers 门闩 ---- */

#[no_mangle]
export function shu_udp_batch_set_addr_port(sin: *u8, addr_u32: u32, port_u32: u32): void {
  unsafe {
    shu_udp_batch_set_addr_port_impl(sin, addr_u32, port_u32);
  }
}

#[no_mangle]
export function shu_udp_batch_poll_readable(fd: i32, timeout_ms: u32): i32 {
  unsafe {
    return shu_udp_batch_poll_readable_impl(fd, timeout_ms);
  }
  return 0;
}
