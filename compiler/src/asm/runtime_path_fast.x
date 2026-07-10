// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-21：runtime_path_fast 产品源迁 seeds/runtime_path_fast.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// G-02f-98：+ path_sep / is_sep / last_sep / last_dot 薄门闩。

extern "C" function path_sep_c_impl(): u8;
extern "C" function path_is_sep_c_impl(c: u8): i32;
extern "C" function path_last_sep_c_impl(path: *u8, path_len: i32): i32;
extern "C" function path_last_dot_c_impl(path: *u8, start: i32, len: i32): i32;

function runtime_path_fast_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-98：path pure helpers 门闩 ---- */

#[no_mangle]
function path_sep_c(): u8 {
  unsafe {
    return path_sep_c_impl();
  }
  return 47;
}

#[no_mangle]
function path_is_sep_c(c: u8): i32 {
  unsafe {
    return path_is_sep_c_impl(c);
  }
  return 0;
}

#[no_mangle]
function path_last_sep_c(path: *u8, path_len: i32): i32 {
  unsafe {
    return path_last_sep_c_impl(path, path_len);
  }
  return 0 - 1;
}

#[no_mangle]
function path_last_dot_c(path: *u8, start: i32, len: i32): i32 {
  unsafe {
    return path_last_dot_c_impl(path, start, len);
  }
  return 0 - 1;
}
