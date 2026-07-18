// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-20：runtime_random_fill 产品源迁 seeds/runtime_random_fill.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_random_fill.from_x.c → runtime_random_fill.o
// G-02f-104：+ random_get_alg 薄门闩（Windows BCrypt；init_callback 仍 C CALLBACK）。

export extern "C" function random_get_alg_impl(): *u8;

export function runtime_random_fill_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-104：random alg 门闩 ---- */

#[no_mangle]
export function random_get_alg(): *u8 {
  unsafe {
    return random_get_alg_impl();
  }
  return 0 as *u8;
}
