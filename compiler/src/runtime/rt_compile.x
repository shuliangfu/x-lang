// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-291～296/454 / P2 runtime R6 compile helpers。
// 产品实现：seeds/rt_compile.from_x.c；hybrid 宏 SHUX_RT_COMPILE_FROM_X。
// G-02f-454：thin+rest PREFER_X_O；.x 薄门闩调 _impl，seed 宏重命名。
//   原函数含 unsafe{let+if+strncmp} 组合（shux -E 易丢体）；thin wrapper 消除此风险。

export extern "C" function driver_deps_are_std_core_closure_only_impl(dep_paths: **u8, n_deps: i32): i32;

/** dep 列表是否全为 std./core. 闭包（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
export function driver_deps_are_std_core_closure_only(dep_paths: **u8, n_deps: i32): i32 {
  unsafe {
    return driver_deps_are_std_core_closure_only_impl(dep_paths, n_deps);
  }
  return 0;
}
