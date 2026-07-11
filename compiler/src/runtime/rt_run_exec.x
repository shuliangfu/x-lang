// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-297～299 / P2 runtime R7：run/exec 门闩与 exec_compiled。
// 产品实现：seeds/rt_run_exec.from_x.c；hybrid 宏 SHUX_RT_RUN_EXEC_FROM_X。
//
// f-297：want_asm / print_usage
// f-298：test_status / print_target_cpu
// f-299：exec_scan_out_path / path_is_non_exe / exec_compiled（spawn 🔒 在 seed）
//
// G-02f-434：driver_exec_path_is_non_exe .x 真迁（flat early-return + helper 函数，
//   消除 &&/||/嵌套 if/unsafe 内 let+if → 修复 shux -E 丢弃函数体）。

extern "C" function strlen(s: *u8): usize;

// 2-byte suffix check: .o (111) / .O (79) / .s (115) — 46='.'
function rt_exec_suffix2_non_exe(exe: *u8, n: usize): i32 {
  if (n < 2 as usize) { return 0; }
  if (exe[(n - 2 as usize)] != 46) { return 0; }
  if (exe[(n - 1 as usize)] == 111) { return 1; }
  if (exe[(n - 1 as usize)] == 79) { return 1; }
  if (exe[(n - 1 as usize)] == 115) { return 1; }
  return 0;
}

// 4-byte suffix check: .obj (111,98,106) — 46='.'
function rt_exec_suffix4_non_exe(exe: *u8, n: usize): i32 {
  if (n < 4 as usize) { return 0; }
  if (exe[(n - 4 as usize)] != 46) { return 0; }
  if (exe[(n - 3 as usize)] != 111) { return 0; }
  if (exe[(n - 2 as usize)] != 98) { return 0; }
  if (exe[(n - 1 as usize)] != 106) { return 0; }
  return 1;
}

function rt_exec_check_non_exe(exe: *u8, n: usize): i32 {
  if (rt_exec_suffix2_non_exe(exe, n) == 1) { return 1; }
  if (rt_exec_suffix4_non_exe(exe, n) == 1) { return 1; }
  return 0;
}

/** 路径是否非可执行产物后缀（.o/.O/.obj/.s）。 */
#[no_mangle]
function driver_exec_path_is_non_exe(exe: *u8): i32 {
  if (exe == 0 as *u8) { return 1; }
  unsafe {
    let n: usize = strlen(exe);
    return rt_exec_check_non_exe(exe, n);
  }
  return 0;
}
