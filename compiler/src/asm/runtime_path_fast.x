// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-21：runtime_path_fast 产品源迁 seeds/runtime_path_fast.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// G-02f-98：+ path_sep / is_sep / last_sep / last_dot 薄门闩。


function runtime_path_fast_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-98：path pure helpers 门闩 ---- */









// G-02f-119：path pure helper 真迁 .x

#[no_mangle]
function path_sep_c(): u8 {
  // 产品 seed 在 Win 下为 '\\'；posix 验收路径为 '/'
  return 47 as u8;
}

#[no_mangle]
function path_is_sep_c(c: u8): i32 {
  if (c == 47) { return 1; }
  if (c == 92) { return 1; }
  return 0;
}

#[no_mangle]
function path_last_sep_c(path: *u8, path_len: i32): i32 {
  let i: i32 = path_len - 1;
  while (i >= 0) {
    if (path_is_sep_c(path[i]) != 0) { return i; }
    i = i - 1;
  }
  return 0 - 1;
}

// G-02f-123：path_last_dot_c 真迁 .x

#[no_mangle]
function path_last_dot_c(path: *u8, start: i32, len: i32): i32 {
  let i: i32 = start + len - 1;
  while (i >= start) {
    if (path[i] == 46) { return i - start; }
    i = i - 1;
  }
  return 0 - 1;
}
