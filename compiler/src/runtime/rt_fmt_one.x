// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-311/447 / P2 runtime rest：fmt 单文件。
// 产品实现：seeds/rt_fmt_one.from_x.c；hybrid 宏 SHUX_RT_FMT_ONE_FROM_X。
// G-02f-447：thin+rest PREFER_X_O；.x 薄门闩调 _impl，seed 宏重命名。

export extern "C" function driver_fmt_one_file_impl(path: *u8, path_len: i32): i32;

/** path → format → 可选写回（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
export function driver_fmt_one_file(path: *u8, path_len: i32): i32 {
  unsafe {
    return driver_fmt_one_file_impl(path, path_len);
  }
  return 1;
}
