// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-317 / P2 runtime R8-lite：栈逃逸 gate 大栈 pthread 薄门闩。
// 产品实现：seeds/rt_stack.from_x.c；hybrid 宏 SHUX_RT_STACK_FROM_X。
// 🔒 pthread 体在 driver_run_thread_on_large_stack。

/** large_stack gate（逻辑锚点；完整实现见 seed）。 */
#[no_mangle]
function driver_stack_esc_gate_large_stack(src: *u8, src_len: i32): i32 {
  if (src == 0 as *u8 || src_len <= 0) {
    return 0;
  }
  return 0;
}
