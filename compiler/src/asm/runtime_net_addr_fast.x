// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-20：runtime_net_addr_fast 产品源迁 seeds/runtime_net_addr_fast.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_net_addr_fast.from_x.c → ../std/net/net_addr_fast.o
// G-02f-102：+ sockaddr pack 薄门闩。

extern "C" function net_sockaddr_in_pack_addr_port_c_impl(sin_ptr: *u8): i64;

function runtime_net_addr_fast_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-102：net addr pack 门闩 ---- */

#[no_mangle]
function net_sockaddr_in_pack_addr_port_c(sin_ptr: *u8): i64 {
  unsafe {
    return net_sockaddr_in_pack_addr_port_c_impl(sin_ptr);
  }
  return 0;
}
