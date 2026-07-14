// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-20：runtime_dynlib_os 产品源迁 seeds/runtime_dynlib_os.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_dynlib_os.from_x.c → runtime_dynlib_os.o

export function runtime_dynlib_os_x_doc_anchor(): i32 {
  return 0;
}

// G-02f-112：+ win dynlib path helpers 薄门闩。

export extern "C" function dynlib_win_load_library_w_utf8_impl(path: *u8): *u8;

/* ---- G-02f-112：dynlib win helpers 门闩 ---- */


#[no_mangle]
export function dynlib_win_load_library_w_utf8(path: *u8): *u8 {
  unsafe { return dynlib_win_load_library_w_utf8_impl(path); }
}

// G-02f-123：dynlib_win_normalize_path 真迁 .x（签名对齐 seed：out, out_cap, path）

#[no_mangle]
export function dynlib_win_normalize_path(out: *u8, out_cap: i32, path: *u8): i32 {
  if (out == 0) { return 0; }
  if (out_cap < 2) { return 0; }
  if (path == 0) { return 0; }
  let i: i32 = 0;
  while (path[i] != 0) {
    if (i + 1 >= out_cap) { break; }
    let c: u8 = path[i];
    if (c == 47) { c = 92; } // '/' -> '\\'
    out[i] = c;
    i = i + 1;
  }
  out[i] = 0;
  return i;
}
