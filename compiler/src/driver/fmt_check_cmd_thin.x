// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-350/383/389/405：fmt_check_cmd L2 thin — pure + lit 门闩（16）。
// PREFER_X_O：thin.o + seed-rest（-DSHUX_L2_FMT_CHECK_THIN_FROM_X）ld -r
//   → fmt_check_cmd_driver.o
// 对照：src/driver/fmt_check_cmd.x；默认仍整 seed。
//
// -E 约束：无 while 重赋值；无零参-only 不稳写法；6 参用扁平 if。
//

extern "C" function driver_collect_mode_is_check_impl(): i32;
extern "C" function check_user_passed_L_get_impl(): i32;
extern "C" function fmt_user_ignore_count_impl(): i32;
extern "C" function fmt_path_ends_with_dot_x_impl(path: *u8): i32;
extern "C" function fmt_file_list_n_impl(): i32;
extern "C" function driver_fmt_check_lit_check_error(): *u8;
extern "C" function driver_fmt_check_lit_fmt_error(): *u8;
extern "C" function driver_fmt_check_lit_chk002(): *u8;
extern "C" function driver_fmt_check_lit_fmt001(): *u8;
extern "C" function check_one_finalize_rc_lint_impl(warn_count: i32): i32;

// deno check：全部成功时不打印逐文件 check OK
#[no_mangle]
function driver_check_quiet_ok_get(): i32 {
  return 1;
}

// 跳过 "." 名与空名
#[no_mangle]
function fmt_walk_skip_dot_name(name: *u8): i32 {
  if (name == 0 as *u8) {
    return 1;
  }
  if (name[0] == 0) {
    return 1;
  }
  if (name[0] == 46) {
    return 1;
  }
  return 0;
}

// rc!=0 且无 direct_diag 且无有效 nd* 时需要 fallback 收集
#[no_mangle]
function check_one_need_fallback_diag(rc: i32, nd: i32, nd_errors: i32, nd_warnings: i32, nd_infos: i32, direct_diag: i32): i32 {
  if (rc == 0) {
    return 0;
  }
  if (direct_diag != 0) {
    return 0;
  }
  if (nd == 0) {
    return 1;
  }
  if (nd_errors != 0) {
    return 0;
  }
  if (nd_warnings != 0) {
    return 0;
  }
  if (nd_infos != 0) {
    return 0;
  }
  return 1;
}

// POSIX / 或 Windows 盘符:
#[no_mangle]
function shux_path_is_absolute(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  if (path[0] == 0) {
    return 0;
  }
  if (path[0] == 47) {
    return 1;
  }
  if (path[1] == 0) {
    return 0;
  }
  if (path[1] != 58) {
    return 0;
  }
  if (path[0] < 65) {
    return 0;
  }
  if (path[0] <= 90) {
    return 1;
  }
  if (path[0] < 97) {
    return 0;
  }
  if (path[0] <= 122) {
    return 1;
  }
  return 0;
}

// rc==0 且 lint fail-on-warnings 时升失败
#[no_mangle]
function check_one_finalize_rc(rc: i32, warn_count: i32): i32 {
  if (rc != 0) {
    return rc;
  }
  if (warn_count <= 0) {
    return 0;
  }
  unsafe {
    return check_one_finalize_rc_lint_impl(warn_count);
  }
  return 0;
}

#[no_mangle]
function driver_collect_error_kind(): *u8 {
  unsafe {
    if (driver_collect_mode_is_check_impl() != 0) {
      return driver_fmt_check_lit_check_error();
    }
    return driver_fmt_check_lit_fmt_error();
  }
  return 0 as *u8;
}

#[no_mangle]
function driver_collect_missing_path_code(): *u8 {
  unsafe {
    if (driver_collect_mode_is_check_impl() != 0) {
      return driver_fmt_check_lit_chk002();
    }
    return driver_fmt_check_lit_fmt001();
  }
  return 0 as *u8;
}

// ---- G-02f-383：collect_mode / user_passed_L → seed impl ----
#[no_mangle]
function driver_collect_mode_is_check(): i32 {
  unsafe {
    return driver_collect_mode_is_check_impl();
  }
  return 0;
}

#[no_mangle]
function check_user_passed_L_get(): i32 {
  unsafe {
    return check_user_passed_L_get_impl();
  }
  return 0;
}

// ---- G-02f-389：ignore count / .x 后缀 / file list n → seed impl ----
#[no_mangle]
function fmt_user_ignore_count(): i32 {
  unsafe {
    return fmt_user_ignore_count_impl();
  }
  return 0;
}

#[no_mangle]
function fmt_path_ends_with_dot_x(path: *u8): i32 {
  unsafe {
    return fmt_path_ends_with_dot_x_impl(path);
  }
  return 0;
}

#[no_mangle]
function fmt_file_list_n(): i32 {
  unsafe {
    return fmt_file_list_n_impl();
  }
  return 0;
}

// ---- G-02f-405：lint/invoke/dep_clear/path_stat → seed impl ----
extern "C" function check_lint_fail_on_warnings_impl(): i32;
extern "C" function fmt_check_invoke_compile_impl(argc: i32, check_argv: *u8): i32;
extern "C" function fmt_check_dep_clear_impl(): void;
extern "C" function fmt_path_stat_kind_impl(path: *u8): i32;

#[no_mangle]
function check_lint_fail_on_warnings(): i32 {
  unsafe {
    return check_lint_fail_on_warnings_impl();
  }
  return 0;
}

#[no_mangle]
function fmt_check_invoke_compile(argc: i32, check_argv: *u8): i32 {
  unsafe {
    return fmt_check_invoke_compile_impl(argc, check_argv);
  }
  return 0;
}

#[no_mangle]
function fmt_check_dep_clear(): void {
  unsafe {
    fmt_check_dep_clear_impl();
  }
}

#[no_mangle]
function fmt_path_stat_kind(path: *u8): i32 {
  unsafe {
    return fmt_path_stat_kind_impl(path);
  }
  return 0 - 1;
}
