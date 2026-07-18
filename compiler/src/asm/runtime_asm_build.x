// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-24：真迁 .x — Goal2 asm 构建桩：main + asm_driver_* 转发。
// 产品：./shux-c -E → seeds/runtime_asm_build.from_x.c（main argv 抛光 char**）。

export extern "C" function shux_forward_main_to_main_entry(argc: i32, argv: *u8): i32;
export extern "C" function driver_skip_codegen_dep_0_get(): i32;
export extern "C" function driver_set_current_dep_path_for_codegen(path: *u8): void;

// main 保留 seed：.x 无法表达 char** argv（Clang 强制 main 第二参数为 char**）
// main 定义见 seeds/runtime_asm_build.from_x.c

#[no_mangle]
export function asm_driver_skip_codegen_dep_0_get(): i32 {
  unsafe {
    let r: i32 = driver_skip_codegen_dep_0_get();
    return r;
  }
  return 0;
}

#[no_mangle]
export function asm_driver_set_current_dep_path_for_codegen(path: *u8): void {
  unsafe {
    driver_set_current_dep_path_for_codegen(path);
  }
}
