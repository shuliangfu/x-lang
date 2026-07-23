// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

/* wave234 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED — full .x cold path uses same face as hybrid thin. */
export extern "C" function link_abi_getenv(name: *u8): *u8;
export extern "C" function strstr(hay: *u8, needle: *u8): *u8;
/* See implementation. */
export extern "C" function driver_collect_mode_is_check(): i32;
export extern "C" function driver_fmt_check_lit_check_error(): *u8;
export extern "C" function driver_fmt_check_lit_fmt_error(): *u8;
export extern "C" function driver_fmt_check_lit_chk002(): *u8;
export extern "C" function driver_fmt_check_lit_fmt001(): *u8;
/* See implementation. */
export extern "C" function fmt_builtin_ignore_at(i: i32): *u8;
export extern "C" function fmt_user_ignore_count(): i32;
export extern "C" function fmt_user_ignore_at(i: i32): *u8;
/* See implementation. */
export extern "C" function fmt_file_list_n(): i32;
export extern "C" function fmt_path_resolve_abs(path: *u8): *u8;
export extern "C" function fmt_file_list_store_impl(abs_path: *u8): i32;
export extern "C" function file_list_clear_impl(): void;
export extern "C" function fmt_check_dep_clear_impl(): void;
export extern "C" function check_init_user_lib_flags_impl(argc: i32, argv: *u8, path_start: i32): void;
/* See implementation. */
export extern "C" function check_user_passed_L_get(): i32;
export extern "C" function check_try_append_lib_root_impl(check_argv: *u8, n: *i32, dir: *u8): void;
export extern "C" function check_append_repo_lib_roots_impl(check_argv: *u8, n: *i32): void;
export extern "C" function check_argv_append_default_libs_for_path_impl(path: *u8, check_argv: *u8, n: *i32): void;
export extern "C" function fmt_check_invoke_compile_impl(path: *u8): i32;
/* See implementation. */
export extern "C" function walk_dir_collect_impl(dir: *u8): void;
/* See implementation. */
export extern "C" function fmt_default_product_sub_at(i: i32): *u8;
export extern "C" function fmt_try_walk_if_product_subdir(sub: *u8): i32;
export extern "C" function fmt_walk_cwd_fallback_impl(): void;
/* See implementation. */
export extern "C" function fmt_path_stat_kind(path: *u8): i32;
export extern "C" function collect_paths_missing_diag_impl(path: *u8): void;
export extern "C" function parse_ignore_opt_impl(arg: *u8): void;
/* See implementation. */
export extern "C" function check_one_file_body_impl(path: *u8, argc: i32, argv: *u8): i32;
export extern "C" function closedir_win_impl(d: *u8): void;

/** Exported function `driver_check_quiet_ok_get`.
 * Implements `driver_check_quiet_ok_get`.
 * @return i32
 */
#[no_mangle]
export function driver_check_quiet_ok_get(): i32 {
  // See implementation.
  return 1;
}

/* ---- G-02f-97 / G-02f-247：path / collect / lint ---- */

// driver_collect_error_kind: see function docblock below.
/** Exported function `driver_collect_error_kind`.
 * Implements `driver_collect_error_kind`.
 * @return *u8
 */
#[no_mangle]
export function driver_collect_error_kind(): *u8 {
  unsafe {
    if (driver_collect_mode_is_check() != 0) {
      return driver_fmt_check_lit_check_error();
    }
    return driver_fmt_check_lit_fmt_error();
  }
  return 0 as *u8;
}

// driver_collect_missing_path_code: see function docblock below.
/** Exported function `driver_collect_missing_path_code`.
 * Implements `driver_collect_missing_path_code`.
 * @return *u8
 */
#[no_mangle]
export function driver_collect_missing_path_code(): *u8 {
  unsafe {
    if (driver_collect_mode_is_check() != 0) {
      return driver_fmt_check_lit_chk002();
    }
    return driver_fmt_check_lit_fmt001();
  }
  return 0 as *u8;
}

/* ---- G-02f-106 / G-02f-247 / G-02f-248：path/list/dep/lib ---- */

// path_should_ignore: see function docblock below.
/** Exported function `path_should_ignore`.
 * Implements `path_should_ignore`.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function path_should_ignore(path: *u8): i32 {
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

// fmt_path_ends_with_dot_x: see function docblock below.
/** Exported function `fmt_path_ends_with_dot_x`.
 * Implements `fmt_path_ends_with_dot_x`.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function fmt_path_ends_with_dot_x(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  unsafe {
    let i: i32 = 0;
    while (i < 4096) {
      if (path[i] == 0) {
        if (i < 2) {
          return 0;
        }
        // ".x"
        if (path[i - 2] == 46) {
          if (path[i - 1] == 120) {
            return 1;
          }
        }
        return 0;
      }
      i = i + 1;
    }
  }
  return 0;
}

// file_list_push: see function docblock below.
/** Exported function `file_list_push`.
 * Implements `file_list_push`.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function file_list_push(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    if (fmt_file_list_n() >= 8192) {
      return 0 - 1;
    }
    let abs_path: *u8 = fmt_path_resolve_abs(path);
    if (abs_path == 0 as *u8) {
      return 0 - 1;
    }
    if (path_should_ignore(abs_path) != 0) {
      return 0;
    }
    if (fmt_path_ends_with_dot_x(abs_path) == 0) {
      return 0;
    }
    return fmt_file_list_store_impl(abs_path);
  }
  return 0 - 1;
}

/** Exported function `file_list_clear`.
 * Implements `file_list_clear`.
 * @return void
 */
#[no_mangle]
export function file_list_clear(): void {
  unsafe {
    file_list_clear_impl();
  }
}

/** Exported function `fmt_check_dep_clear`.
 * Implements `fmt_check_dep_clear`.
 * @return void
 */
#[no_mangle]
export function fmt_check_dep_clear(): void {
  unsafe {
    fmt_check_dep_clear_impl();
  }
}

/** Exported function `check_init_user_lib_flags`.
 * Implements `check_init_user_lib_flags`.
 * @param argc i32
 * @param argv *u8
 * @param path_start i32
 * @return void
 */
#[no_mangle]
export function check_init_user_lib_flags(argc: i32, argv: *u8, path_start: i32): void {
  if (argv == 0 as *u8) {
    return;
  }
  unsafe {
    check_init_user_lib_flags_impl(argc, argv, path_start);
  }
}

// check_try_append_lib_root: see function docblock below.
/** Exported function `check_try_append_lib_root`.
 * Implements `check_try_append_lib_root`.
 * @param check_argv *u8
 * @param n *i32
 * @param dir *u8
 * @return void
 */
#[no_mangle]
export function check_try_append_lib_root(check_argv: *u8, n: *i32, dir: *u8): void {
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
    if (dir[0] == 0) {
      return;
    }
    if (check_user_passed_L_get() != 0) {
      return;
    }
    if (*n >= 58) {
      return;
    }
    check_try_append_lib_root_impl(check_argv, n, dir);
  }
}

/* See implementation. */

#[no_mangle]
export function check_append_repo_lib_roots(check_argv: *u8, n: *i32): void {
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

/** Exported function `check_argv_append_default_libs_for_path`.
 * Implements `check_argv_append_default_libs_for_path`.
 * @param path *u8
 * @param check_argv *u8
 * @param n *i32
 * @return void
 */
#[no_mangle]
export function check_argv_append_default_libs_for_path(path: *u8, check_argv: *u8, n: *i32): void {
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

/** Exported function `fmt_check_invoke_compile`.
 * Implements `fmt_check_invoke_compile`.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function fmt_check_invoke_compile(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return fmt_check_invoke_compile_impl(path);
  }
  return 0 - 1;
}

// fmt_walk_skip_dot_name: see function docblock below.
/** Exported function `fmt_walk_skip_dot_name`.
 * Implements `fmt_walk_skip_dot_name`.
 * @param name *u8
 * @return i32
 */
#[no_mangle]
export function fmt_walk_skip_dot_name(name: *u8): i32 {
  if (name == 0 as *u8) {
    return 1;
  }
  unsafe {
    if (name[0] == 0) {
      return 1;
    }
    if (name[0] == 46) {
      return 1;
    }
  }
  return 0;
}

// walk_dir_collect_process_child: see function docblock below.
/** Exported function `walk_dir_collect_process_child`.
 * Implements `walk_dir_collect_process_child`.
 * @param child *u8
 * @param is_dir i32
 * @param is_reg i32
 * @return void
 */
#[no_mangle]
export function walk_dir_collect_process_child(child: *u8, is_dir: i32, is_reg: i32): void {
  if (child == 0 as *u8) {
    return;
  }
  if (path_should_ignore(child) != 0) {
    return;
  }
  if (is_dir != 0) {
    walk_dir_collect(child);
    return;
  }
  if (is_reg != 0) {
    if (fmt_path_ends_with_dot_x(child) != 0) {
      file_list_push(child);
    }
  }
}

/** Exported function `walk_dir_collect`.
 * Implements `walk_dir_collect`.
 * @param dir *u8
 * @return void
 */
#[no_mangle]
export function walk_dir_collect(dir: *u8): void {
  if (dir == 0 as *u8) {
    return;
  }
  unsafe {
    walk_dir_collect_impl(dir);
  }
}

// check_collect_default_product_dirs: see function docblock below.
/** Exported function `check_collect_default_product_dirs`.
 * Implements `check_collect_default_product_dirs`.
 * @return void
 */
#[no_mangle]
export function check_collect_default_product_dirs(): void {
  let any: i32 = 0;
  let i: i32 = 0;
  while (i < 8) {
    unsafe {
      let sub: *u8 = fmt_default_product_sub_at(i);
      if (sub == 0 as *u8) {
        break;
      }
      if (fmt_try_walk_if_product_subdir(sub) != 0) {
        any = 1;
      }
    }
    i = i + 1;
  }
  if (any == 0) {
    unsafe {
      fmt_walk_cwd_fallback_impl();
    }
  }
}

// See implementation.
// collect_paths_from_arg: see function docblock below.
/** Exported function `collect_paths_from_arg`.
 * Implements `collect_paths_from_arg`.
 * @param arg *u8
 * @return void
 */
#[no_mangle]
export function collect_paths_from_arg(arg: *u8): void {
  if (arg == 0 as *u8) {
    return;
  }
  unsafe {
    let k: i32 = fmt_path_stat_kind(arg);
    if (k < 0) {
      collect_paths_missing_diag_impl(arg);
      return;
    }
    if (k == 1) {
      let base: *u8 = fmt_path_resolve_abs(arg);
      if (base != 0 as *u8) {
        walk_dir_collect(base);
      }
      return;
    }
    file_list_push(arg);
  }
}

// parse_ignore_opt: see function docblock below.
/** Exported function `parse_ignore_opt`.
 * Implements `parse_ignore_opt`.
 * @param arg *u8
 * @return i32
 */
#[no_mangle]
export function parse_ignore_opt(arg: *u8): i32 {
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

// check_one_need_fallback_diag: see function docblock below.
/** Exported function `check_one_need_fallback_diag`.
 * Implements `check_one_need_fallback_diag`.
 * @param rc i32
 * @param nd i32
 * @param nd_errors i32
 * @param nd_warnings i32
 * @param nd_infos i32
 * @param direct_diag i32
 * @return i32
 */
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
  if (nd_errors == 0) {
    if (nd_warnings == 0) {
      if (nd_infos == 0) {
        return 1;
      }
    }
  }
  return 0;
}

// check_one_finalize_rc: see function docblock below.
/** Exported function `check_one_finalize_rc`.
 * Implements `check_one_finalize_rc`.
 * @param rc i32
 * @param warn_count i32
 * @return i32
 */
#[no_mangle]
export function check_one_finalize_rc(rc: i32, warn_count: i32): i32 {
  if (rc != 0) {
    return rc;
  }
  if (check_lint_fail_on_warnings() != 0) {
    if (warn_count > 0) {
      return 1;
    }
  }
  return rc;
}

// check_one_file: see function docblock below.
/** Exported function `check_one_file`.
 * Implements `check_one_file`.
 * @param path *u8
 * @param argc i32
 * @param argv *u8
 * @return i32
 */
#[no_mangle]
export function check_one_file(path: *u8, argc: i32, argv: *u8): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  if (argv == 0 as *u8) {
    return 0 - 1;
  }
  if (argc <= 0) {
    return 0 - 1;
  }
  unsafe {
    return check_one_file_body_impl(path, argc, argv);
  }
  return 0 - 1;
}

/* See implementation. */

#[no_mangle]
export function closedir_win(d: *u8): void {
  if (d == 0 as *u8) {
    return;
  }
  unsafe {
    closedir_win_impl(d);
  }
}

/**
 * Whether `xlang check` should fail on warning-level diagnostics.
 * Truthy when XLANG_LINT_CI_FAIL_ON is "warn" or "warning".
 * wave234 G.7: env via public pure thin link_abi_getenv (not raw libc getenv).
 * @return i32 — 1 if warnings are fatal, 0 otherwise
 * PLATFORM: SHARED — host residual only link_abi_getenv_impl
 */
#[no_mangle]
export function check_lint_fail_on_warnings(): i32 {
  unsafe {
    // wave234 G.7: XLANG_LINT_CI_FAIL_ON via link_abi_getenv (not raw getenv).
    let v: *u8 = link_abi_getenv("XLANG_LINT_CI_FAIL_ON");
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

// xlang_path_is_absolute: see function docblock below.

/** Exported function `xlang_path_is_absolute`.
 * Implements `xlang_path_is_absolute`.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function xlang_path_is_absolute(path: *u8): i32 {
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
