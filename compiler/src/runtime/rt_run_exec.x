// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-297 / P2 runtime R7-lite：run/exec 路径 pure 薄门闩（spawn 🔒 仍 mega）。
// 产品实现：seeds/rt_run_exec.from_x.c；hybrid 宏 SHUX_RT_RUN_EXEC_FROM_X。
//
// 符号：driver_want_asm_emit_to_file / driver_print_usage_c。
// exec/spawn 主体不在本册。

extern "C" function strcmp(a: *u8, b: *u8): i32;

/** argv 是否应走 asm 后端（无 `-backend c` 则为 1；逻辑锚点，完整实现见 seed）。 */
#[no_mangle]
function driver_want_asm_emit_to_file(argc: i32, argv: **u8): i32 {
  if (argv == 0 as **u8 || argc < 2) {
    return 0;
  }
  // 完整扫描在 seed C（driver_get_argv_i）
  return 1;
}
