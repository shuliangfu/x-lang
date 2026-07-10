// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-312 / P2 runtime rest：分派薄门闩 + shux-c sibling。
// 产品实现：seeds/rt_dispatch_thin.from_x.c；hybrid 宏 SHUX_RT_DISPATCH_THIN_FROM_X。

/** 兼容旧 asm_backend_c 名（逻辑锚点；完整实现见 seed）。 */
#[no_mangle]
function driver_run_asm_backend_c(input_path: *u8, out_path: *u8, lib_key: *u8, target: *u8, argc: i32,
                                  argv: *u8): i32 {
  if (input_path == 0 as *u8) {
    return 1;
  }
  return 0;
}

/** 完整编译入口（逻辑锚点；完整实现见 seed）。 */
#[no_mangle]
function driver_run_compiler_full(argc: i32, argv: *u8): i32 {
  if (argc < 0) {
    return 1;
  }
  return 0;
}
