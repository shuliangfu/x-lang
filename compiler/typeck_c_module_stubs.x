// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-24：真迁 .x — typeck_module / typeck_one_function 回退桩（返回 -1）。
// 产品：./shux-c -E → seeds/typeck_c_module_stubs.from_x.c（再抛光 __attribute__((weak))）。
// 指针参数以 *u8 表示不透明 ASTModule** 等（C ABI 同宽）。

#[no_mangle]
function typeck_module(m: *u8, dep_mods: *u8, num_deps: i32, all_dep_mods: *u8, n_all_deps: i32): i32 {
  return -1;
}

#[no_mangle]
function typeck_one_function(m: *u8, dep_mods: *u8, num_deps: i32, all_dep_mods: *u8, n_all_deps: i32,
                             only_func_index: i32): i32 {
  return -1;
}
