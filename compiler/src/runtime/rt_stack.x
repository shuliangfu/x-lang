// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-317/449 / P2 runtime R8-lite：栈逃逸 gate 大栈 pthread 薄门闩。
// 产品实现：seeds/rt_stack.from_x.c；hybrid 宏 SHUX_RT_STACK_FROM_X。
// 🔒 pthread 体在 driver_run_thread_on_large_stack。
// G-02f-449：thin+rest PREFER_X_O；.x 薄门闩调 _impl，seed 宏重命名。

export extern "C" function driver_stack_esc_gate_large_stack_impl(src: *u8, src_len: i32): i32;

/** large_stack gate（薄门闩；实际实现 seed _impl）。 */
#[no_mangle]
export function driver_stack_esc_gate_large_stack(src: *u8, src_len: i32): i32 {
  unsafe {
    return driver_stack_esc_gate_large_stack_impl(src, src_len);
  }
  return 0;
}
