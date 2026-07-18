// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-20：runtime_net_dns_fast 产品源迁 seeds/runtime_net_dns_fast.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_net_dns_fast.from_x.c → ../std/net/net_dns_fast.o
// G-02f-103：+ ai_addconfig / map_gai / ensure_wsa 薄门闩。

export extern "C" function net_dns_ai_addconfig_c_impl(): i32;
export extern "C" function net_dns_map_gai_error_c_impl(err: i32): i32;
export extern "C" function net_dns_ensure_wsa_c_impl(): i32;

export function runtime_net_dns_fast_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-103：dns helpers 门闩 ---- */

#[no_mangle]
export function net_dns_ai_addconfig_c(): i32 {
  unsafe {
    return net_dns_ai_addconfig_c_impl();
  }
  return 0;
}

#[no_mangle]
export function net_dns_map_gai_error_c(err: i32): i32 {
  unsafe {
    return net_dns_map_gai_error_c_impl(err);
  }
  return 0;
}

#[no_mangle]
export function net_dns_ensure_wsa_c(): i32 {
  unsafe {
    return net_dns_ensure_wsa_c_impl();
  }
  return 0;
}
