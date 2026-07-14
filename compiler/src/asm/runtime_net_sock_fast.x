// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-20：runtime_net_sock_fast 产品源迁 seeds/runtime_net_sock_fast.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_net_sock_fast.from_x.c → ../std/net/net_sock_fast.o
// G-02f-104：+ ensure_wsa / wsa_ctor 薄门闩。

export extern "C" function net_ensure_wsa_impl(): void;
export extern "C" function net_wsa_ctor_impl(): void;

export function runtime_net_sock_fast_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-104：sock wsa helpers 门闩 ---- */

#[no_mangle]
export function net_ensure_wsa(): void {
  unsafe {
    net_ensure_wsa_impl();
  }
}

#[no_mangle]
export function net_wsa_ctor(): void {
  unsafe {
    net_wsa_ctor_impl();
  }
}
