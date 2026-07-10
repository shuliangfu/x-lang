// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-297～299 / P2 runtime R7：run/exec 门闩与 exec_compiled。
// 产品实现：seeds/rt_run_exec.from_x.c；hybrid 宏 SHUX_RT_RUN_EXEC_FROM_X。
//
// f-297：want_asm / print_usage
// f-298：test_status / print_target_cpu
// f-299：exec_scan_out_path / path_is_non_exe / exec_compiled（spawn 🔒 在 seed）

extern "C" function strcmp(a: *u8, b: *u8): i32;
extern "C" function strlen(s: *u8): usize;

/** 路径是否非可执行产物后缀（逻辑锚点；完整实现见 seed）。 */
#[no_mangle]
function driver_exec_path_is_non_exe(exe: *u8): i32 {
  if (exe == 0 as *u8) {
    return 1;
  }
  unsafe {
    let n: usize = strlen(exe);
    if (n >= 2 as usize && exe[(n - 2 as usize)] == 46) {
      let c: u8 = exe[(n - 1 as usize)];
      if (c == 111 || c == 79 || c == 115) {
        return 1;
      }
    }
  }
  return 0;
}
