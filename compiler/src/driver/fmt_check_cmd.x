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
// G-02f-247：P1-8 开局 — collect lit pure + path_should_ignore pure + 多门闩 null 边界。

extern "C" function getenv(name: *u8): *u8;
extern "C" function strstr(hay: *u8, needle: *u8): *u8;
/* collect mode / lit：G-02f-247 下方真迁 */
extern "C" function driver_collect_mode_is_check(): i32;
extern "C" function driver_fmt_check_lit_check_error(): *u8;
extern "C" function driver_fmt_check_lit_fmt_error(): *u8;
extern "C" function driver_fmt_check_lit_chk002(): *u8;
extern "C" function driver_fmt_check_lit_fmt001(): *u8;
/* path_should_ignore：G-02f-247 下方真迁；ignore 槽 🔒 */
extern "C" function fmt_builtin_ignore_at(i: i32): *u8;
extern "C" function fmt_user_ignore_count(): i32;
extern "C" function fmt_user_ignore_at(i: i32): *u8;
extern "C" function file_list_push_impl(path: *u8): i32;
extern "C" function file_list_clear_impl(): void;
extern "C" function fmt_check_dep_clear_impl(): void;
extern "C" function check_init_user_lib_flags_impl(argc: i32, argv: *u8, path_start: i32): void;
extern "C" function check_try_append_lib_root_impl(check_argv: *u8, n: *i32, dir: *u8): void;
extern "C" function check_append_repo_lib_roots_impl(check_argv: *u8, n: *i32): void;
extern "C" function check_argv_append_default_libs_for_path_impl(path: *u8, check_argv: *u8, n: *i32): void;
extern "C" function fmt_check_invoke_compile_impl(path: *u8): i32;
extern "C" function walk_dir_collect_impl(dir: *u8): void;
extern "C" function check_collect_default_product_dirs_impl(): void;
extern "C" function collect_paths_from_arg_impl(arg: *u8): void;
extern "C" function parse_ignore_opt_impl(arg: *u8): void;
extern "C" function check_one_file_impl(path: *u8): i32;
extern "C" function closedir_win_impl(d: *u8): void;

#[no_mangle]
function driver_check_quiet_ok_get(): i32 {
  // deno check：全部成功时不打印逐文件 check OK。
  return 1;
}

/* ---- G-02f-97 / G-02f-247：path / collect / lint ---- */

// G-02f-247：check 模式 → "check error"，否则 "fmt error"
#[no_mangle]
function driver_collect_error_kind(): *u8 {
  unsafe {
    if (driver_collect_mode_is_check() != 0) {
      return driver_fmt_check_lit_check_error();
    }
    return driver_fmt_check_lit_fmt_error();
  }
  return 0 as *u8;
}

// G-02f-247：check → CHK002，否则 FMT001
#[no_mangle]
function driver_collect_missing_path_code(): *u8 {
  unsafe {
    if (driver_collect_mode_is_check() != 0) {
      return driver_fmt_check_lit_chk002();
    }
    return driver_fmt_check_lit_fmt001();
  }
  return 0 as *u8;
}

/* ---- G-02f-106 / G-02f-247：path/list/dep/lib ---- */

// G-02f-247：内置 + --ignore 子串；null path → 忽略
#[no_mangle]
function path_should_ignore(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 1;
  }
  unsafe {
    let i: i32 = 0;
    while (i < 32) {
      let b: *u8 = fmt_builtin_ignore_at(i);
      if (b == 0 as *u8) {
        break;
      }
      if (strstr(path, b) != 0 as *u8) {
        return 1;
      }
      i = i + 1;
    }
    let n: i32 = fmt_user_ignore_count();
    let j: i32 = 0;
    while (j < n) {
      let u: *u8 = fmt_user_ignore_at(j);
      if (u != 0 as *u8) {
        if (u[0] != 0) {
          if (strstr(path, u) != 0 as *u8) {
            return 1;
          }
        }
      }
      j = j + 1;
    }
  }
  return 0;
}

#[no_mangle]
function file_list_push(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return file_list_push_impl(path);
  }
  return 0 - 1;
}

#[no_mangle]
function file_list_clear(): void {
  unsafe {
    file_list_clear_impl();
  }
}

#[no_mangle]
function fmt_check_dep_clear(): void {
  unsafe {
    fmt_check_dep_clear_impl();
  }
}

#[no_mangle]
function check_init_user_lib_flags(argc: i32, argv: *u8, path_start: i32): void {
  if (argv == 0 as *u8) {
    return;
  }
  unsafe {
    check_init_user_lib_flags_impl(argc, argv, path_start);
  }
}

#[no_mangle]
function check_try_append_lib_root(check_argv: *u8, n: *i32, dir: *u8): void {
  if (check_argv == 0 as *u8) {
    return;
  }
  if (n == 0 as *i32) {
    return;
  }
  if (dir == 0 as *u8) {
    return;
  }
  unsafe {
    check_try_append_lib_root_impl(check_argv, n, dir);
  }
}

/* ---- G-02f-107：fmt walk/collect/check 门闩 ---- */

#[no_mangle]
function check_append_repo_lib_roots(check_argv: *u8, n: *i32): void {
  if (check_argv == 0 as *u8) {
    return;
  }
  if (n == 0 as *i32) {
    return;
  }
  unsafe {
    check_append_repo_lib_roots_impl(check_argv, n);
  }
}

#[no_mangle]
function check_argv_append_default_libs_for_path(path: *u8, check_argv: *u8, n: *i32): void {
  if (check_argv == 0 as *u8) {
    return;
  }
  if (n == 0 as *i32) {
    return;
  }
  unsafe {
    check_argv_append_default_libs_for_path_impl(path, check_argv, n);
  }
}

#[no_mangle]
function fmt_check_invoke_compile(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return fmt_check_invoke_compile_impl(path);
  }
  return 0 - 1;
}

#[no_mangle]
function walk_dir_collect(dir: *u8): void {
  if (dir == 0 as *u8) {
    return;
  }
  unsafe {
    walk_dir_collect_impl(dir);
  }
}

#[no_mangle]
function check_collect_default_product_dirs(): void {
  unsafe {
    check_collect_default_product_dirs_impl();
  }
}

#[no_mangle]
function collect_paths_from_arg(arg: *u8): void {
  if (arg == 0 as *u8) {
    return;
  }
  unsafe {
    collect_paths_from_arg_impl(arg);
  }
}

// G-02f-247：前缀 `--ignore=` pure；体 C 写 s_ignore_paths
#[no_mangle]
function parse_ignore_opt(arg: *u8): i32 {
  if (arg == 0 as *u8) {
    return 0;
  }
  unsafe {
    // --ignore=
    if (arg[0] != 45) {
      return 0;
    }
    if (arg[1] != 45) {
      return 0;
    }
    if (arg[2] != 105) {
      return 0;
    }
    if (arg[3] != 103) {
      return 0;
    }
    if (arg[4] != 110) {
      return 0;
    }
    if (arg[5] != 111) {
      return 0;
    }
    if (arg[6] != 114) {
      return 0;
    }
    if (arg[7] != 101) {
      return 0;
    }
    if (arg[8] != 61) {
      return 0;
    }
    parse_ignore_opt_impl(arg);
  }
  return 1;
}

#[no_mangle]
function check_one_file(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return check_one_file_impl(path);
  }
  return 0 - 1;
}

/* ---- G-02f-112：closedir_win 门闩 ---- */

#[no_mangle]
function closedir_win(d: *u8): void {
  if (d == 0 as *u8) {
    return;
  }
  unsafe {
    closedir_win_impl(d);
  }
}

// G-02f-116：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
function check_lint_fail_on_warnings(): i32 {
  unsafe {
    let v: *u8 = getenv("SHUX_LINT_CI_FAIL_ON");
    if (v == 0) {
      return 0;
    }
    // "warn" or "warning"
    if (v[0] == 119) {
      if (v[1] == 97) {
        if (v[2] == 114) {
          if (v[3] == 110) {
            if (v[4] == 0) {
              return 1;
            }
            if (v[4] == 105) {
              if (v[5] == 110) {
                if (v[6] == 103) {
                  if (v[7] == 0) {
                    return 1;
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  return 0;
}

// G-02f-118：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
function shux_path_is_absolute(path: *u8): i32 {
  if (path == 0) {
    return 0;
  }
  if (path[0] == 0) {
    return 0;
  }
  if (path[0] == 47) {
    return 1;
  } // '/'
  // Windows drive letter: A-Z/a-z then ':'
  let c0: u8 = path[0];
  let ok: i32 = 0;
  if (c0 >= 65) {
    if (c0 <= 90) {
      ok = 1;
    }
  }
  if (c0 >= 97) {
    if (c0 <= 122) {
      ok = 1;
    }
  }
  if (ok != 0) {
    if (path[1] == 58) {
      return 1;
    }
  }
  return 0;
}
