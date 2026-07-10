// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-311 / P2 runtime rest：fmt 单文件。
// 产品实现：seeds/rt_fmt_one.from_x.c；hybrid 宏 SHUX_RT_FMT_ONE_FROM_X。

/** path → format → 可选写回（逻辑锚点；完整实现见 seed）。 */
#[no_mangle]
function driver_fmt_one_file(path: *u8, path_len: i32): i32 {
  if (path == 0 as *u8 || path_len <= 0) {
    return 1;
  }
  return 0;
}
