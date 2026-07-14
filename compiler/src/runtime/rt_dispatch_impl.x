// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-313/446 / P2 runtime rest：分派中型 impl_c 门闩。
// 产品实现：seeds/rt_dispatch_impl.from_x.c；hybrid 宏 SHUX_RT_DISPATCH_IMPL_FROM_X。
// G-02f-446：thin+rest PREFER_X_O；.x 薄门闩调 _impl，seed 宏重命名。

export extern "C" function driver_run_compiler_full_x_impl_c_impl(argc: i32, argv: *u8): i32;

/** full_x 入口（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
export function driver_run_compiler_full_x_impl_c(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_compiler_full_x_impl_c_impl(argc, argv);
  }
  return 0;
}
