// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-305 / P2 runtime rest：lib root 指针可用性 + 默认根 + from_key。
// 产品实现：seeds/rt_lib_root.from_x.c；hybrid 宏 SHUX_RT_LIB_ROOT_FROM_X。

/** 指针是否可安全当 lib root 用（逻辑锚点；完整实现见 seed）。 */
#[no_mangle]
function driver_lib_root_ptr_usable(p: *u8): i32 {
  if (p == 0 as *u8) {
    return 0;
  }
  if (p[0] == 0) {
    return 0;
  }
  return 1;
}
