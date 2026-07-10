// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-24：真迁 .x — Goal2 asm 构建桩：main + asm_driver_* 转发。
// 产品：./shux-c -E → seeds/runtime_asm_build.from_x.c（main argv 抛光 char**）。

extern "C" function shux_forward_main_to_main_entry(argc: i32, argv: *u8): i32;
extern "C" function driver_skip_codegen_dep_0_get(): i32;
extern "C" function driver_set_current_dep_path_for_codegen(path: *u8): void;

#[no_mangle]
function main(argc: i32, argv: *u8): i32 {
  unsafe {
    let r: i32 = shux_forward_main_to_main_entry(argc, argv);
    return r;
  }
  return 0;
}

#[no_mangle]
function asm_driver_skip_codegen_dep_0_get(): i32 {
  unsafe {
    let r: i32 = driver_skip_codegen_dep_0_get();
    return r;
  }
  return 0;
}

#[no_mangle]
function asm_driver_set_current_dep_path_for_codegen(path: *u8): void {
  unsafe {
    driver_set_current_dep_path_for_codegen(path);
  }
}
