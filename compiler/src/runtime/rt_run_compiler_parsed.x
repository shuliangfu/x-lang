// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-316/457 / P2 runtime rest：argv 已解析后的编译编排（末块）。
// 产品实现：seeds/rt_run_compiler_parsed.from_x.c；hybrid 宏 SHUX_RT_RUN_COMPILER_PARSED_FROM_X。
// G-02f-457：thin+rest PREFER_X_O；.x 薄门闩调 _impl，seed 宏重命名。

extern "C" function driver_run_compiler_parsed_impl(p: *u8, argc: i32, argv: *u8): i32;

/** parsed 分派（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
function driver_run_compiler_parsed(p: *u8, argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_compiler_parsed_impl(p, argc, argv);
  }
  return 0;
}
