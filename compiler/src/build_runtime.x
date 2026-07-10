// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f：build_runtime 产品源迁 seeds/build_runtime.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// G-02f-105：+ info / warn 薄门闩。

extern "C" function build_runtime_info_impl(msg: *u8): void;
extern "C" function build_runtime_warn_impl(msg: *u8): void;

function build_runtime_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-105：build_runtime log 门闩 ---- */

#[no_mangle]
function build_runtime_info(msg: *u8): void {
  unsafe {
    build_runtime_info_impl(msg);
  }
}

#[no_mangle]
function build_runtime_warn(msg: *u8): void {
  unsafe {
    build_runtime_warn_impl(msg);
  }
}
