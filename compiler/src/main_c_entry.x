// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-23：真迁 .x — LEGACY/shux-c 极简 C main（勿与 src/main.x 驱动混淆）。
// 产品：./shux-c -E → seeds/main.from_x.c
// 注意：argv 以 *u8 表示 char** 不透明指针（与 C ABI 一致按值传指针）。

extern "C" function shux_forward_main_to_main_entry(argc: i32, argv: *u8): i32;

#[no_mangle]
function main(argc: i32, argv: *u8): i32 {
  unsafe {
    let r: i32 = shux_forward_main_to_main_entry(argc, argv);
    return r;
  }
  return 0;
}
