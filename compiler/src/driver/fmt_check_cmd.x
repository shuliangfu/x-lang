// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-31：真迁 .x — shux check 静默成功查询（deno check 语义）。
// 产品：./shux-c -E → seeds/fmt_check_cmd.from_x.c（+ C 尾段）。
// C 尾：路径收集、walk_dir、fmt/check CLI、argv 拼装、lint 策略。
// 说明：本 TU 提供 driver_check_quiet_ok_get 强符号（覆盖 driver_abi weak 默认）。
// G-02f-97：+ path_is_absolute / collect_error_kind / missing_path_code / lint_fail_on_warnings 门闩。
// G-02f-106：+ path_should_ignore / file_list / dep_clear / lib_root 门闩。
// G-02f-107：+ walk/collect/compile/check_one 薄门闩。

extern "C" function shux_path_is_absolute_impl(path: *u8): i32;
extern "C" function driver_collect_error_kind_impl(): *u8;
extern "C" function driver_collect_missing_path_code_impl(): *u8;
extern "C" function check_lint_fail_on_warnings_impl(): i32;
extern "C" function path_should_ignore_impl(path: *u8): i32;
extern "C" function file_list_push_impl(path: *u8): i32;
extern "C" function file_list_clear_impl(): void;
extern "C" function fmt_check_dep_clear_impl(): void;
extern "C" function check_init_user_lib_flags_impl(argc: i32, argv: *u8, path_start: i32): void;
extern "C" function check_try_append_lib_root_impl(check_argv: *u8, n: *i32, dir: *u8): void;

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


/* ---- G-02f-106：path/list/dep/lib 门闩 ---- */

#[no_mangle]
function path_should_ignore(path: *u8): i32 {
  unsafe { return path_should_ignore_impl(path); }
  return 0;
}

#[no_mangle]
function file_list_push(path: *u8): i32 {
  unsafe { return file_list_push_impl(path); }
  return 0;
}

#[no_mangle]
function file_list_clear(): void {
  unsafe { file_list_clear_impl(); }
}

#[no_mangle]
function fmt_check_dep_clear(): void {
  unsafe { fmt_check_dep_clear_impl(); }
}

#[no_mangle]
function check_init_user_lib_flags(argc: i32, argv: *u8, path_start: i32): void {
  unsafe { check_init_user_lib_flags_impl(argc, argv, path_start); }
}

#[no_mangle]
function check_try_append_lib_root(check_argv: *u8, n: *i32, dir: *u8): void {
  unsafe { check_try_append_lib_root_impl(check_argv, n, dir); }
}

extern "C" function check_append_repo_lib_roots_impl(check_argv: *u8, n: *i32): void;
extern "C" function check_argv_append_default_libs_for_path_impl(path: *u8, check_argv: *u8, n: *i32): void;
extern "C" function fmt_check_invoke_compile_impl(path: *u8): i32;
extern "C" function walk_dir_collect_impl(dir: *u8): void;
extern "C" function check_collect_default_product_dirs_impl(): void;
extern "C" function collect_paths_from_arg_impl(arg: *u8): void;
extern "C" function parse_ignore_opt_impl(arg: *u8): i32;
extern "C" function check_one_file_impl(path: *u8): i32;

/* ---- G-02f-107：fmt walk/collect/check 门闩 ---- */

#[no_mangle]
function check_append_repo_lib_roots(check_argv: *u8, n: *i32): void {
  unsafe { check_append_repo_lib_roots_impl(check_argv, n); }
}

#[no_mangle]
function check_argv_append_default_libs_for_path(path: *u8, check_argv: *u8, n: *i32): void {
  unsafe { check_argv_append_default_libs_for_path_impl(path, check_argv, n); }
}

#[no_mangle]
function fmt_check_invoke_compile(path: *u8): i32 {
  unsafe { return fmt_check_invoke_compile_impl(path); }
  return 0 - 1;
}

#[no_mangle]
function walk_dir_collect(dir: *u8): void {
  unsafe { walk_dir_collect_impl(dir); }
}

#[no_mangle]
function check_collect_default_product_dirs(): void {
  unsafe { check_collect_default_product_dirs_impl(); }
}

#[no_mangle]
function collect_paths_from_arg(arg: *u8): void {
  unsafe { collect_paths_from_arg_impl(arg); }
}

#[no_mangle]
function parse_ignore_opt(arg: *u8): i32 {
  unsafe { return parse_ignore_opt_impl(arg); }
  return 0;
}

#[no_mangle]
function check_one_file(path: *u8): i32 {
  unsafe { return check_one_file_impl(path); }
  return 0 - 1;
}

// G-02f-112：+ closedir_win 薄门闩。

extern "C" function closedir_win_impl(d: *u8): void;

/* ---- G-02f-112：closedir_win 门闩 ---- */

#[no_mangle]
function closedir_win(d: *u8): void {
  unsafe { closedir_win_impl(d); }
}

// G-02f-116：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

extern "C" function getenv(name: *u8): *u8;

#[no_mangle]
function check_lint_fail_on_warnings(): i32 {
  unsafe {
    let v: *u8 = getenv("SHUX_LINT_CI_FAIL_ON");
    if (v == 0) { return 0; }
    // "warn" or "warning"
    if (v[0] == 119 && v[1] == 97 && v[2] == 114 && v[3] == 110) {
      if (v[4] == 0) { return 1; }
      if (v[4] == 105 && v[5] == 110 && v[6] == 103 && v[7] == 0) { return 1; }
    }
  }
  return 0;
}
