// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-31：真迁 .x — shux check 静默成功查询（deno check 语义）。
// 产品：./shux-c -E → seeds/fmt_check_cmd.from_x.c（+ C 尾段）。
// C 尾：路径收集、walk_dir、fmt/check CLI、argv 拼装、lint 策略。
// 说明：本 TU 提供 driver_check_quiet_ok_get 强符号（覆盖 driver_abi weak 默认）。
// G-02f-97：+ path_is_absolute / collect_error_kind / missing_path_code / lint_fail_on_warnings 门闩。

extern "C" function shux_path_is_absolute_impl(path: *u8): i32;
extern "C" function driver_collect_error_kind_impl(): *u8;
extern "C" function driver_collect_missing_path_code_impl(): *u8;
extern "C" function check_lint_fail_on_warnings_impl(): i32;

#[no_mangle]
function driver_check_quiet_ok_get(): i32 {
  // deno check：全部成功时不打印逐文件 check OK。
  return 1;
}

/* ---- G-02f-97：path / collect / lint 门闩 ---- */

#[no_mangle]
function shux_path_is_absolute(path: *u8): i32 {
  unsafe {
    return shux_path_is_absolute_impl(path);
  }
  return 0;
}

#[no_mangle]
function driver_collect_error_kind(): *u8 {
  unsafe {
    return driver_collect_error_kind_impl();
  }
  return 0 as *u8;
}

#[no_mangle]
function driver_collect_missing_path_code(): *u8 {
  unsafe {
    return driver_collect_missing_path_code_impl();
  }
  return 0 as *u8;
}

#[no_mangle]
function check_lint_fail_on_warnings(): i32 {
  unsafe {
    return check_lint_fail_on_warnings_impl();
  }
  return 0;
}
