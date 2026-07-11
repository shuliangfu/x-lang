// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-301/310/456 / P2 runtime R10：入口侧 thin gates。
// 产品实现：seeds/rt_entry.from_x.c；hybrid 宏 SHUX_RT_ENTRY_FROM_X。
// G-02f-456：thin+rest PREFER_X_O；.x 薄门闩调 _impl，seed 宏重命名。
//   run_compiler_c 保留在 rest（char **argv 签名不匹配 .x 的 *u8）。

extern "C" function shux_smoke_diag_enabled_impl(): i32;
extern "C" function driver_build_build_x_impl(): i32;

/** smoke 结构化诊断是否启用（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
function shux_smoke_diag_enabled(): i32 {
  unsafe {
    return shux_smoke_diag_enabled_impl();
  }
  return 0;
}

/** make build-tool + build_tool（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
function driver_build_build_x(): i32 {
  unsafe {
    return driver_build_build_x_impl();
  }
  return 0;
}
