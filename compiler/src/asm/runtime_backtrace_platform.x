// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-19：runtime_backtrace_platform 产品源迁 seeds/runtime_backtrace_platform.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_backtrace_platform.from_x.c → runtime_backtrace_platform.o
// G-02f-101：+ hex2 / gold_anchor 薄门闩。
// G-02f-106：+ capture_and_check_gold 薄门闩。

extern "C" function backtrace_u8_hex2_impl(b: u8, out: *u8): void;
extern "C" function backtrace_capture_and_check_gold_c_impl(): i32;

function runtime_backtrace_platform_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-101：backtrace helpers 门闩 ---- */

#[no_mangle]
function backtrace_u8_hex2(b: u8, out: *u8): void {
  unsafe {
    backtrace_u8_hex2_impl(b, out);
  }
}



/* ---- G-02f-106：capture gold 门闩 ---- */

#[no_mangle]
function backtrace_capture_and_check_gold_c(): i32 {
  unsafe {
    return backtrace_capture_and_check_gold_c_impl();
  }
  return 0;
}

// G-02f-127：name_has_gold_anchor 真迁 .x

extern "C" function backtrace_name_has_gold_anchor_c(name: *u8): i32;

#[no_mangle]
function name_has_gold_anchor(name: *u8): i32 {
  unsafe {
    return backtrace_name_has_gold_anchor_c(name);
  }
  return 0;
}

