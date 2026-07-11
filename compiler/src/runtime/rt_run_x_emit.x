// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-314/444 / P2 runtime rest：-x -E emit 主体。
// 产品实现：seeds/rt_run_x_emit.from_x.c；hybrid 宏 SHUX_RT_RUN_X_EMIT_FROM_X。
// G-02f-444：thin+rest PREFER_X_O；.x 薄门闩调 _impl，seed 宏重命名。

extern "C" function driver_run_x_emit_c_impl(): i32;

/** 执行 -x -E（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
function driver_run_x_emit_c(): i32 {
  unsafe {
    return driver_run_x_emit_c_impl();
  }
  return 1;
}
