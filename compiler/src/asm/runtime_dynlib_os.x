// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-20：runtime_dynlib_os 产品源迁 seeds/runtime_dynlib_os.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_dynlib_os.from_x.c → runtime_dynlib_os.o

function runtime_dynlib_os_x_doc_anchor(): i32 {
  return 0;
}

// G-02f-112：+ win dynlib path helpers 薄门闩。

extern "C" function dynlib_win_normalize_path_impl(src: *u8, dst: *u8, cap: i32): i32;
extern "C" function dynlib_win_load_library_w_utf8_impl(path: *u8): *u8;

/* ---- G-02f-112：dynlib win helpers 门闩 ---- */

#[no_mangle]
function dynlib_win_normalize_path(src: *u8, dst: *u8, cap: i32): i32 {
  unsafe { return dynlib_win_normalize_path_impl(src, dst, cap); }
  return 0;
}
#[no_mangle]
function dynlib_win_load_library_w_utf8(path: *u8): *u8 {
  unsafe { return dynlib_win_load_library_w_utf8_impl(path); }
  return 0;
}
