// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-309/443 / P2 runtime rest：静态 arena/module 缓冲。
// 产品实现：seeds/rt_arena_buf.from_x.c；hybrid 宏 SHUX_RT_ARENA_BUF_FROM_X。
// 🔒 大 BSS 与 pipeline_arena_offset_num_types 在 seed。
// G-02f-443：thin+rest PREFER_X_O；.x 薄门闩调 _impl，seed 宏重命名。

extern "C" function driver_arena_buf_impl(): *u8;
extern "C" function driver_module_buf_impl(): *u8;

/** 清零并返回静态 arena 缓冲（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
function driver_arena_buf(): *u8 {
  unsafe {
    return driver_arena_buf_impl();
  }
  return 0 as *u8;
}

/** 清零并返回静态 module 缓冲（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
function driver_module_buf(): *u8 {
  unsafe {
    return driver_module_buf_impl();
  }
  return 0 as *u8;
}
