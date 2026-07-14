// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-264/451：产品路径 pure flags（R5-lite；RFC R4 DCE 不进 SHUX_USE_X_DRIVER 产品 .o）。
// hybrid → seeds/rt_emit_flags.from_x.c；默认仍在 runtime.from_x.c。
// G-02f-451：thin+rest PREFER_X_O；.x 薄门闩调 _impl，seed 宏重命名。

export extern "C" function driver_argv_has_emit_c_flag_impl(argc: i32, argv: **u8): i32;

/** argv 是否含 -E / -E-extern（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
export function driver_argv_has_emit_c_flag(argc: i32, argv: **u8): i32 {
  unsafe {
    return driver_argv_has_emit_c_flag_impl(argc, argv);
  }
  return 0;
}
