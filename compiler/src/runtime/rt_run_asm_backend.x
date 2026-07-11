// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-315/457 / P2 runtime rest：-backend asm 主体。
// 产品实现：seeds/rt_run_asm_backend.from_x.c；hybrid 宏 SHUX_RT_RUN_ASM_BACKEND_FROM_X。
// G-02f-457：thin+rest PREFER_X_O；.x 薄门闩调 _impl，seed 宏重命名。

extern "C" function driver_run_asm_backend_impl(input_path: *u8, out_path: *u8, lib_roots: *u8, n_lib_roots: i32,
                                                 target: *u8, argc: i32, argv: *u8): i32;

/** asm backend 编排（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
function driver_run_asm_backend(input_path: *u8, out_path: *u8, lib_roots: *u8, n_lib_roots: i32, target: *u8,
                                argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_asm_backend_impl(input_path, out_path, lib_roots, n_lib_roots, target, argc, argv);
  }
  return 0;
}
