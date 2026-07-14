// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-312/453 / P2 runtime rest：分派薄门闩 + shux-c sibling。
// 产品实现：seeds/rt_dispatch_thin.from_x.c；hybrid 宏 SHUX_RT_DISPATCH_THIN_FROM_X。
// G-02f-453：thin+rest PREFER_X_O；.x 薄门闩调 _impl，seed 宏重命名。
//   driver_run_compiler_full 保留在 rest（char **argv 签名不匹配 .x 的 *u8）。

export extern "C" function driver_run_asm_backend_c_impl(input_path: *u8, out_path: *u8, lib_key: *u8, target: *u8,
                                                   argc: i32, argv: *u8): i32;

/** 兼容旧 asm_backend_c 名（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
export function driver_run_asm_backend_c(input_path: *u8, out_path: *u8, lib_key: *u8, target: *u8,
                                  argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_asm_backend_c_impl(input_path, out_path, lib_key, target, argc, argv);
  }
  return 0;
}
