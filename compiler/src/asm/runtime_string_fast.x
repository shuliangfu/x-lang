// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-21：runtime_string_fast 产品源迁 seeds/runtime_string_fast.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// G-02f-99：+ portable memmem 薄门闩。

extern "C" function shux_string_portable_memmem_c_impl(hay: *u8, hay_len: i32, needle: *u8, needle_len: i32): i32;

function runtime_string_fast_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-99：portable memmem 门闩 ---- */

#[no_mangle]
function shux_string_portable_memmem_c(hay: *u8, hay_len: i32, needle: *u8, needle_len: i32): i32 {
  unsafe {
    return shux_string_portable_memmem_c_impl(hay, hay_len, needle, needle_len);
  }
  return 0 - 1;
}
