// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-350/383/389/405–410：fmt_check_cmd L2 thin — pure + lit + entry 门闩（34）。
// PREFER_X_O：thin.o + seed-rest（-DSHUX_L2_FMT_CHECK_THIN_FROM_X）ld -r
//   → fmt_check_cmd_driver.o
// 对照：src/driver/fmt_check_cmd.x；默认仍整 seed。
//
// -E 约束：无 while 重赋值；无零参-only 不稳写法；6 参用扁平 if。
//

export extern "C" function driver_collect_mode_is_check_impl(): i32;
export extern "C" function check_user_passed_L_get_impl(): i32;
export extern "C" function fmt_user_ignore_count_impl(): i32;
export extern "C" function fmt_path_ends_with_dot_x_impl(path: *u8): i32;
export extern "C" function fmt_file_list_n_impl(): i32;
export extern "C" function fmt_user_ignore_at_impl(i: i32): *u8;
export extern "C" function fmt_path_resolve_abs_impl(path: *u8): *u8;
export extern "C" function check_one_finalize_rc_lint_impl(warn_count: i32): i32;

let g_fmt_lit_check_error: u8[12] = [99, 104, 101, 99, 107, 32, 101, 114, 114, 111, 114, 0];
let g_fmt_lit_fmt_error: u8[10] = [102, 109, 116, 32, 101, 114, 114, 111, 114, 0];
let g_fmt_lit_chk002: u8[7] = [67, 72, 75, 48, 48, 50, 0];
let g_fmt_lit_fmt001: u8[7] = [70, 77, 84, 48, 48, 49, 0];

let g_fmt_builtin_ignore_0: u8[8] = [47, 46, 103, 105, 116, 47, 0, 0];
let g_fmt_builtin_ignore_1: u8[12] = [47, 98, 117, 105, 108, 100, 95, 97, 115, 109, 47, 0];
let g_fmt_builtin_ignore_2: u8[8] = [47, 98, 117, 105, 108, 100, 47, 0];
let g_fmt_builtin_ignore_3: u8[15] = [47, 110, 111, 100, 101, 95, 109, 111, 100, 117, 108, 101, 115, 47, 0];
let g_fmt_builtin_ignore_4: u8[11] = [47, 46, 99, 117, 114, 115, 111, 114, 47, 0, 0];
let g_fmt_builtin_ignore_5: u8[21] = [47, 99, 111, 109, 112, 105, 108, 101, 114, 47, 98, 117, 105, 108, 100, 95, 97, 115, 109, 47, 0];
let g_fmt_builtin_ignore_6: u8[17] = [47, 99, 111, 109, 112, 105, 108, 101, 114, 47, 98, 117, 105, 108, 100, 47, 0];
let g_fmt_builtin_ignore_7: u8[17] = [47, 99, 111, 109, 112, 105, 108, 101, 114, 47, 116, 101, 115, 116, 115, 47, 0];

let g_fmt_default_product_sub_0: u8[13] = [99, 111, 109, 112, 105, 108, 101, 114, 47, 115, 114, 99, 0];
let g_fmt_default_product_sub_1: u8[5] = [99, 111, 114, 101, 0];
let g_fmt_default_product_sub_2: u8[4] = [115, 116, 100, 0];
let g_fmt_default_product_sub_3: u8[9] = [101, 120, 97, 109, 112, 108, 101, 115, 0];

// deno check：全部成功时不打印逐文件 check OK
#[no_mangle]
export function driver_check_quiet_ok_get(): i32 {
  return 1;
}

// 跳过 "." 名与空名
#[no_mangle]
export function fmt_walk_skip_dot_name(name: *u8): i32 {
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
export function check_one_need_fallback_diag(rc: i32, nd: i32, nd_errors: i32, nd_warnings: i32, nd_infos: i32, direct_diag: i32): i32 {
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
export function shux_path_is_absolute(path: *u8): i32 {
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
export function check_one_finalize_rc(rc: i32, warn_count: i32): i32 {
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
export function driver_fmt_check_lit_check_error(): *u8 {
  return &g_fmt_lit_check_error[0];
}

#[no_mangle]
export function driver_fmt_check_lit_fmt_error(): *u8 {
  return &g_fmt_lit_fmt_error[0];
}

#[no_mangle]
export function driver_fmt_check_lit_chk002(): *u8 {
  return &g_fmt_lit_chk002[0];
}

#[no_mangle]
export function driver_fmt_check_lit_fmt001(): *u8 {
  return &g_fmt_lit_fmt001[0];
}

#[no_mangle]
export function driver_collect_error_kind(): *u8 {
  unsafe {
    if (driver_collect_mode_is_check_impl() != 0) {
      return &g_fmt_lit_check_error[0];
    }
  }
  return &g_fmt_lit_fmt_error[0];
}

#[no_mangle]
export function driver_collect_missing_path_code(): *u8 {
  unsafe {
    if (driver_collect_mode_is_check_impl() != 0) {
      return &g_fmt_lit_chk002[0];
    }
  }
  return &g_fmt_lit_fmt001[0];
}

#[no_mangle]
export function fmt_builtin_ignore_at(i: i32): *u8 {
  if (i == 0) {
    return &g_fmt_builtin_ignore_0[0];
  }
  if (i == 1) {
    return &g_fmt_builtin_ignore_1[0];
  }
  if (i == 2) {
    return &g_fmt_builtin_ignore_2[0];
  }
  if (i == 3) {
    return &g_fmt_builtin_ignore_3[0];
  }
  if (i == 4) {
    return &g_fmt_builtin_ignore_4[0];
  }
  if (i == 5) {
    return &g_fmt_builtin_ignore_5[0];
  }
  if (i == 6) {
    return &g_fmt_builtin_ignore_6[0];
  }
  if (i == 7) {
    return &g_fmt_builtin_ignore_7[0];
  }
  return 0 as *u8;
}

#[no_mangle]
export function fmt_default_product_sub_at(i: i32): *u8 {
  if (i == 0) {
    return &g_fmt_default_product_sub_0[0];
  }
  if (i == 1) {
    return &g_fmt_default_product_sub_1[0];
  }
  if (i == 2) {
    return &g_fmt_default_product_sub_2[0];
  }
  if (i == 3) {
    return &g_fmt_default_product_sub_3[0];
  }
  return 0 as *u8;
}

#[no_mangle]
export function fmt_user_ignore_at(i: i32): *u8 {
  unsafe {
    return fmt_user_ignore_at_impl(i);
  }
  return 0 as *u8;
}

#[no_mangle]
export function fmt_path_resolve_abs(path: *u8): *u8 {
  unsafe {
    return fmt_path_resolve_abs_impl(path);
  }
  return 0 as *u8;
}

// ---- G-02f-383：collect_mode / user_passed_L → seed impl ----
#[no_mangle]
export function driver_collect_mode_is_check(): i32 {
  unsafe {
    return driver_collect_mode_is_check_impl();
  }
  return 0;
}

#[no_mangle]
export function check_user_passed_L_get(): i32 {
  unsafe {
    return check_user_passed_L_get_impl();
  }
  return 0;
}

// ---- G-02f-389：ignore count / .x 后缀 / file list n → seed impl ----
#[no_mangle]
export function fmt_user_ignore_count(): i32 {
  unsafe {
    return fmt_user_ignore_count_impl();
  }
  return 0;
}

#[no_mangle]
export function fmt_path_ends_with_dot_x(path: *u8): i32 {
  unsafe {
    return fmt_path_ends_with_dot_x_impl(path);
  }
  return 0;
}

#[no_mangle]
export function fmt_file_list_n(): i32 {
  unsafe {
    return fmt_file_list_n_impl();
  }
  return 0;
}

// ---- G-02f-405：lint/invoke/dep_clear/path_stat → seed impl ----
export extern "C" function check_lint_fail_on_warnings_impl(): i32;
export extern "C" function fmt_check_invoke_compile_impl(argc: i32, check_argv: *u8): i32;
export extern "C" function fmt_check_dep_clear_impl(): void;
export extern "C" function fmt_path_stat_kind_impl(path: *u8): i32;

#[no_mangle]
export function check_lint_fail_on_warnings(): i32 {
  unsafe {
    return check_lint_fail_on_warnings_impl();
  }
  return 0;
}

#[no_mangle]
export function fmt_check_invoke_compile(argc: i32, check_argv: *u8): i32 {
  unsafe {
    return fmt_check_invoke_compile_impl(argc, check_argv);
  }
  return 0;
}

#[no_mangle]
export function fmt_check_dep_clear(): void {
  unsafe {
    fmt_check_dep_clear_impl();
  }
}

#[no_mangle]
export function fmt_path_stat_kind(path: *u8): i32 {
  unsafe {
    return fmt_path_stat_kind_impl(path);
  }
  return 0 - 1;
}

// ---- G-02f-406：lib roots / current file / one_file → seed impl ----
export extern "C" function check_try_append_lib_root_impl(check_argv: *u8, n: *i32, dir: *u8): void;
export extern "C" function check_init_user_lib_flags_impl(argc: i32, argv: *u8, path_start: i32): void;
export extern "C" function driver_check_set_current_file_impl(path: *u8): void;
export extern "C" function driver_check_print_collected_diagnostics_impl(path: *u8): i32;
export extern "C" function check_one_file_impl(path: *u8, argc: i32, argv: *u8): i32;

#[no_mangle]
export function check_try_append_lib_root(check_argv: *u8, n: *i32, dir: *u8): void {
  unsafe {
    check_try_append_lib_root_impl(check_argv, n, dir);
  }
}

#[no_mangle]
export function check_init_user_lib_flags(argc: i32, argv: *u8, path_start: i32): void {
  unsafe {
    check_init_user_lib_flags_impl(argc, argv, path_start);
  }
}

#[no_mangle]
export function driver_check_set_current_file(path: *u8): void {
  unsafe {
    driver_check_set_current_file_impl(path);
  }
}

#[no_mangle]
export function driver_check_print_collected_diagnostics(path: *u8): i32 {
  unsafe {
    return driver_check_print_collected_diagnostics_impl(path);
  }
  return 0;
}

#[no_mangle]
export function check_one_file(path: *u8, argc: i32, argv: *u8): i32 {
  unsafe {
    return check_one_file_impl(path, argc, argv);
  }
  return 0 - 1;
}

// ---- G-02f-407：ignore / file_list / walk / parse_ignore → seed impl ----
export extern "C" function path_should_ignore_impl(path: *u8): i32;
export extern "C" function file_list_push_impl(path: *u8): i32;
export extern "C" function walk_dir_collect_process_child_impl(child: *u8, is_dir: i32, is_reg: i32): void;
export extern "C" function walk_dir_collect_impl(dir: *u8): void;
export extern "C" function parse_ignore_opt_impl(arg: *u8): void;
export extern "C" function file_list_clear_impl(): void;

#[no_mangle]
export function path_should_ignore(path: *u8): i32 {
  unsafe {
    return path_should_ignore_impl(path);
  }
  return 0;
}

#[no_mangle]
export function file_list_push(path: *u8): i32 {
  unsafe {
    return file_list_push_impl(path);
  }
  return 0 - 1;
}

#[no_mangle]
export function walk_dir_collect_process_child(child: *u8, is_dir: i32, is_reg: i32): void {
  unsafe {
    walk_dir_collect_process_child_impl(child, is_dir, is_reg);
  }
}

#[no_mangle]
export function walk_dir_collect(dir: *u8): void {
  unsafe {
    walk_dir_collect_impl(dir);
  }
}

#[no_mangle]
export function parse_ignore_opt(arg: *u8): void {
  unsafe {
    parse_ignore_opt_impl(arg);
  }
}

#[no_mangle]
export function file_list_clear(): void {
  unsafe {
    file_list_clear_impl();
  }
}

// ---- G-02f-408：collect/walk product dirs / lib roots → seed impl ----
export extern "C" function fmt_try_walk_if_product_subdir_impl(sub: *u8): i32;
export extern "C" function check_collect_default_product_dirs_impl(): void;
export extern "C" function collect_paths_from_arg_impl(arg: *u8): void;
export extern "C" function check_append_repo_lib_roots_impl(path: *u8, check_argv: *u8, n: *i32): void;
export extern "C" function check_argv_append_default_libs_for_path_impl(path: *u8, check_argv: *u8, n: *i32): void;

#[no_mangle]
export function fmt_try_walk_if_product_subdir(sub: *u8): i32 {
  unsafe {
    return fmt_try_walk_if_product_subdir_impl(sub);
  }
  return 0;
}

#[no_mangle]
export function check_collect_default_product_dirs(): void {
  unsafe {
    check_collect_default_product_dirs_impl();
  }
}

#[no_mangle]
export function collect_paths_from_arg(arg: *u8): void {
  unsafe {
    collect_paths_from_arg_impl(arg);
  }
}

#[no_mangle]
export function check_append_repo_lib_roots(path: *u8, check_argv: *u8, n: *i32): void {
  unsafe {
    check_append_repo_lib_roots_impl(path, check_argv, n);
  }
}

#[no_mangle]
export function check_argv_append_default_libs_for_path(path: *u8, check_argv: *u8, n: *i32): void {
  unsafe {
    check_argv_append_default_libs_for_path_impl(path, check_argv, n);
  }
}

// ---- G-02f-410：fmt/check entry → seed impl ----
export extern "C" function driver_run_fmt_impl(argc: i32, argv: *u8): i32;
export extern "C" function driver_run_compiler_check_impl(argc: i32, argv: *u8): i32;

#[no_mangle]
export function driver_run_fmt(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_fmt_impl(argc, argv);
  }
  return 0;
}

#[no_mangle]
export function driver_run_compiler_check(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_compiler_check_impl(argc, argv);
  }
  return 0;
}
