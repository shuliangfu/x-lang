// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// fmt_check_cmd R2 thin + Cap residual pure 深迁（续）：
//   lit/entry 门闩 + pure 业务真体（path_should_ignore / .x 后缀 / lint /
//   file_list_push / walk process_child / collect_paths_from_arg /
//   check_collect_default_product_dirs / check_one_file 门闩 /
//   try_append 早退 / parse_ignore 前缀 / invoke_compile·dep_clear 分派 /
//   set_current_file + print_collected + cwd_fallback +
//   try_walk_if_product_subdir + path_resolve_abs）进 thin.x；
// PREFER_X_O：thin.o + seed-rest（-DSHUX_L2_FMT_CHECK_THIN_FROM_X）ld -r
//   → fmt_check_cmd_driver.o
// Prove IDENTICAL：seeds/fmt_check_cmd_thin_surface.from_x.c
// Cap residual：walk opendir/stat/argv/大 BSS / missing-diag format /
//   check_one_file_body 等 *_impl 仍在 full seed rest；FROM_X 下 pure-duplicate
//   _impl 已剔除（含 set_current_file / print / cwd_fallback / try_walk /
//   path_resolve_abs；H↓）。
//
// -E 约束：无 while 重赋值；无零参-only 不稳写法；6 参用扁平 if。
//

export extern "C" function strstr(hay: *u8, needle: *u8): *u8;
export extern "C" function getenv(name: *u8): *u8;
export extern "C" function getcwd(buf: *u8, size: i32): *u8;
export extern "C" function lsp_diag_print_stderr_human(path: *u8): i32;
export extern "C" function driver_run_compiler_full(argc: i32, argv: *u8): i32;
export extern "C" function driver_dep_seeded_clear_all(): void;
export extern "C" function driver_collect_mode_is_check_impl(): i32;
export extern "C" function check_user_passed_L_get_impl(): i32;
export extern "C" function fmt_user_ignore_count_impl(): i32;
export extern "C" function fmt_file_list_n_impl(): i32;
export extern "C" function fmt_user_ignore_at_impl(i: i32): *u8;
export extern "C" function fmt_file_list_store_impl(abs_path: *u8): i32;
// Cap residual：可写路径 BSS 槽（0=current_file，1=resolve_abs）。
// -E 顶层 u8[N] 现退化为悬空指针（codegen.x 已根修，codegen_gen 再生后可收回此槽）。
export extern "C" function fmt_check_path_bss_slot(which: i32): *u8;

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

// rc==0 且 lint fail-on-warnings 时升失败（pure：直接调 check_lint_fail_on_warnings）
#[no_mangle]
export function check_one_finalize_rc(rc: i32, warn_count: i32): i32 {
  if (rc != 0) {
    return rc;
  }
  if (warn_count <= 0) {
    return 0;
  }
  if (check_lint_fail_on_warnings() != 0) {
    return 1;
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

// pure：相对路径 getcwd+字节拼；绝对路径字节拷贝；写 Cap residual BSS slot(1)
#[no_mangle]
export function fmt_path_resolve_abs(path: *u8): *u8 {
  if (path == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    let buf: *u8 = fmt_check_path_bss_slot(1);
    if (buf == 0 as *u8) {
      return 0 as *u8;
    }
    if (shux_path_is_absolute(path) != 0) {
      let i: i32 = 0;
      while (i < 511) {
        let c: u8 = path[i];
        buf[i] = c;
        if (c == 0) {
          return buf;
        }
        i = i + 1;
      }
      buf[511] = 0;
      return buf;
    }
    let p: *u8 = getcwd(buf, 512);
    if (p == 0 as *u8) {
      return 0 as *u8;
    }
    let n: i32 = 0;
    while (n < 511) {
      if (buf[n] == 0) {
        break;
      }
      n = n + 1;
    }
    let plen: i32 = 0;
    while (plen < 512) {
      if (path[plen] == 0) {
        break;
      }
      plen = plen + 1;
    }
    if (n + 1 + plen >= 512) {
      return 0 as *u8;
    }
    buf[n] = 47;
    n = n + 1;
    let j: i32 = 0;
    while (j <= plen) {
      let c2: u8 = path[j];
      buf[n + j] = c2;
      if (c2 == 0) {
        break;
      }
      j = j + 1;
    }
    return buf;
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

// pure：路径是否以 ".x" 结尾（字节扫描，无 strlen）
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

#[no_mangle]
export function fmt_file_list_n(): i32 {
  unsafe {
    return fmt_file_list_n_impl();
  }
  return 0;
}

// ---- lint pure / invoke·dep_clear pure 分派；path_stat Cap residual ----
export extern "C" function fmt_path_stat_kind_impl(path: *u8): i32;

// pure：SHUX_LINT_CI_FAIL_ON=warn|warning
#[no_mangle]
export function check_lint_fail_on_warnings(): i32 {
  unsafe {
    let v: *u8 = getenv("SHUX_LINT_CI_FAIL_ON");
    if (v == 0 as *u8) {
      return 0;
    }
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

// pure 分派：产品 X pipeline → driver_run_compiler_full（冷 seed 仍 #ifdef 双路径）
#[no_mangle]
export function fmt_check_invoke_compile(argc: i32, check_argv: *u8): i32 {
  unsafe {
    return driver_run_compiler_full(argc, check_argv);
  }
  return 0;
}

// pure 分派：清 typeck dep 侧车（产品恒 X pipeline）
#[no_mangle]
export function fmt_check_dep_clear(): void {
  unsafe {
    driver_dep_seeded_clear_all();
  }
}

#[no_mangle]
export function fmt_path_stat_kind(path: *u8): i32 {
  unsafe {
    return fmt_path_stat_kind_impl(path);
  }
  return 0 - 1;
}

// ---- pure 门闩 / try_append 早退 / current file + print pure；Cap：lib root body / one_file body ----
export extern "C" function check_try_append_lib_root_impl(check_argv: *u8, n: *i32, dir: *u8): void;
export extern "C" function check_init_user_lib_flags_impl(argc: i32, argv: *u8, path_start: i32): void;
export extern "C" function check_one_file_body_impl(path: *u8, argc: i32, argv: *u8): i32;

// pure 早退：null/空 dir / 用户已传 -L / argv 槽满；stat+BSS 去重 🔒 _impl
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
  if (dir[0] == 0) {
    return;
  }
  if (check_user_passed_L_get() != 0) {
    return;
  }
  unsafe {
    if (n[0] >= 58) {
      return;
    }
    check_try_append_lib_root_impl(check_argv, n, dir);
  }
}

#[no_mangle]
export function check_init_user_lib_flags(argc: i32, argv: *u8, path_start: i32): void {
  unsafe {
    check_init_user_lib_flags_impl(argc, argv, path_start);
  }
}

// pure：写 current_file 到 Cap residual BSS slot(0)（字节拷贝，无 snprintf）
#[no_mangle]
export function driver_check_set_current_file(path: *u8): void {
  unsafe {
    let buf: *u8 = fmt_check_path_bss_slot(0);
    if (buf == 0 as *u8) {
      return;
    }
    if (path == 0 as *u8) {
      buf[0] = 0;
      return;
    }
    let i: i32 = 0;
    while (i < 511) {
      let c: u8 = path[i];
      buf[i] = c;
      if (c == 0) {
        return;
      }
      i = i + 1;
    }
    buf[511] = 0;
  }
}

// pure：LSP human 打印；path 空则用 current_file BSS slot(0)
#[no_mangle]
export function driver_check_print_collected_diagnostics(path: *u8): i32 {
  unsafe {
    if (path != 0 as *u8) {
      return lsp_diag_print_stderr_human(path);
    }
    let buf: *u8 = fmt_check_path_bss_slot(0);
    if (buf == 0 as *u8) {
      return 0;
    }
    return lsp_diag_print_stderr_human(buf);
  }
  return 0;
}

// pure 门闩：null path/argv / argc<=0；单文件 check 体 🔒 body_impl
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

// ---- pure ignore / file_list orch / walk process_child；Cap：walk opendir / parse_ignore 体 ----
export extern "C" function walk_dir_collect_impl(dir: *u8): void;
export extern "C" function parse_ignore_opt_impl(arg: *u8): void;
export extern "C" function file_list_clear_impl(): void;

// pure：内置 + --ignore 子串；null path → 忽略
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

// pure 编排：满员 / resolve / ignore / .x；strdup 入表 🔒 store_impl
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

// pure：ignore / 递归 / .x 入表
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

#[no_mangle]
export function walk_dir_collect(dir: *u8): void {
  unsafe {
    walk_dir_collect_impl(dir);
  }
}

// pure 前缀：null / 非 "--ignore=" 早退；写槽 🔒 _impl
#[no_mangle]
export function parse_ignore_opt(arg: *u8): void {
  if (arg == 0 as *u8) {
    return;
  }
  // "--ignore=" = 45,45,105,103,110,111,114,101,61
  if (arg[0] != 45) {
    return;
  }
  if (arg[1] != 45) {
    return;
  }
  if (arg[2] != 105) {
    return;
  }
  if (arg[3] != 103) {
    return;
  }
  if (arg[4] != 110) {
    return;
  }
  if (arg[5] != 111) {
    return;
  }
  if (arg[6] != 114) {
    return;
  }
  if (arg[7] != 101) {
    return;
  }
  if (arg[8] != 61) {
    return;
  }
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

// ---- G-02f-408：try_walk pure；collect orch + cwd_fallback pure；lib roots Cap ----
export extern "C" function collect_paths_missing_diag_impl(path: *u8): void;
export extern "C" function check_append_repo_lib_roots_impl(path: *u8, check_argv: *u8, n: *i32): void;
export extern "C" function check_argv_append_default_libs_for_path_impl(path: *u8, check_argv: *u8, n: *i32): void;

// pure：getcwd + 字节拼接 cwd/sub + stat_kind public + walk（无 snprintf/rest _impl）
#[no_mangle]
export function fmt_try_walk_if_product_subdir(sub: *u8): i32 {
  if (sub == 0 as *u8) {
    return 0;
  }
  unsafe {
    let cwd: u8[512] = [];
    let p: *u8 = getcwd(&cwd[0], 512);
    if (p == 0 as *u8) {
      return 0;
    }
    let subp: u8[560] = [];
    let i: i32 = 0;
    while (i < 511) {
      let c: u8 = cwd[i];
      if (c == 0) {
        break;
      }
      subp[i] = c;
      i = i + 1;
    }
    if (i >= 559) {
      return 0;
    }
    subp[i] = 47;
    i = i + 1;
    let j: i32 = 0;
    while (i < 559) {
      let c2: u8 = sub[j];
      subp[i] = c2;
      if (c2 == 0) {
        break;
      }
      i = i + 1;
      j = j + 1;
    }
    subp[559] = 0;
    if (fmt_path_stat_kind(&subp[0]) == 1) {
      walk_dir_collect(&subp[0]);
      return 1;
    }
  }
  return 0;
}

// pure：getcwd + walk_dir_collect public（栈 512B；无 rest _impl）
#[no_mangle]
export function fmt_walk_cwd_fallback(): void {
  unsafe {
    let cwd: u8[512] = [];
    let p: *u8 = getcwd(&cwd[0], 512);
    if (p == 0 as *u8) {
      return;
    }
    walk_dir_collect(&cwd[0]);
  }
}

// pure 编排：默认产品子目录 try_walk；全未命中则 cwd fallback pure
#[no_mangle]
export function check_collect_default_product_dirs(): void {
  unsafe {
    let any_product: i32 = 0;
    let i: i32 = 0;
    while (i < 64) {
      let sub: *u8 = fmt_default_product_sub_at(i);
      if (sub == 0 as *u8) {
        break;
      }
      if (fmt_try_walk_if_product_subdir(sub) != 0) {
        any_product = 1;
      }
      i = i + 1;
    }
    if (any_product == 0) {
      fmt_walk_cwd_fallback();
    }
  }
}

// pure 编排：null / stat_kind / missing diag🔒 / dir→walk / file→push
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
