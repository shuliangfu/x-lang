// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-297/298 / P2 runtime R7-lite：run/exec pure 薄门闩（spawn 🔒 仍 mega）。
// 产品实现：seeds/rt_run_exec.from_x.c；hybrid 宏 SHUX_RT_RUN_EXEC_FROM_X。
//
// f-297：want_asm_emit_to_file / print_usage
// f-298：runtime_test_status_to_rc / print_target_cpu_features
// exec/spawn 主体不在本册。

extern "C" function strcmp(a: *u8, b: *u8): i32;

/** argv 是否应走 asm 后端（逻辑锚点；完整实现见 seed）。 */
#[no_mangle]
function driver_want_asm_emit_to_file(argc: i32, argv: **u8): i32 {
  if (argv == 0 as **u8 || argc < 2) {
    return 0;
  }
  return 1;
}
