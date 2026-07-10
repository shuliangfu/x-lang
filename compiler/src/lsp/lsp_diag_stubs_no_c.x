// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-22：lsp_diag_stubs_no_c 产品源迁 seeds/lsp_diag_stubs_no_c.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// G-02f-101：+ copy_text / json_escape_str 薄门闩。

extern "C" function lsp_diag_copy_text_impl(dst: *u8, cap: i32, src: *u8): void;
extern "C" function json_escape_str_impl(msg: *u8, out: *u8, out_cap: i32): i32;

function lsp_diag_stubs_no_c_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-101：lsp diag text helpers 门闩 ---- */

#[no_mangle]
function lsp_diag_copy_text(dst: *u8, cap: i32, src: *u8): void {
  unsafe {
    lsp_diag_copy_text_impl(dst, cap, src);
  }
}

#[no_mangle]
function json_escape_str(msg: *u8, out: *u8, out_cap: i32): i32 {
  unsafe {
    return json_escape_str_impl(msg, out, out_cap);
  }
  return 0;
}
