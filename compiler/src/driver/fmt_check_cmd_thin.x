// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// fmt_check_cmd R2 thin + Cap residual pure 深迁（续）：
//   lit/entry 门闩 + pure 业务真体（path_should_ignore / .x 后缀 / lint /
//   file_list_push / walk process_child / collect_paths_from_arg /
//   check_collect_default_product_dirs / check_one_file 门闩 /
//   try_append 早退 / parse_ignore 前缀 / invoke_compile·dep_clear 分派 /
//   set_current_file + print_collected + cwd_fallback +
//   try_walk_if_product_subdir + path_resolve_abs +
//   append_repo_lib_roots + missing_diag）进 thin.x；
//   + wave BSS pure：collect_mode + user_passed_L 进 thin；
//     check_init_user_lib_flags pure（G.7 shux_ptr_slot_get + lib_bufs_reset Cap）；
//     FROM_X rest 无 pure-dup is_check / user_passed_L_get / init_user_lib_flags _impl。
//   + wave BSS pure：file_list n 进 thin（fmt_file_list_n / n_set）；
//     Cap residual：s_file_list 指针表 + store strdup + clear free 仍 rest；
//     FROM_X rest 无 pure-dup file_list_n _impl。
//   + wave BSS pure：user ignore n 进 thin（fmt_user_ignore_count / count_set）；
//     Cap residual：s_ignore_paths[] 槽 + parse token 写槽 + at 读槽 仍 rest；
//     FROM_X rest 无 pure-dup user_ignore_count _impl。
//   + wave BSS pure：lib_bufs n 进 thin（fmt_check_lib_bufs_n / n_set / reset）；
//     Cap residual：s_check_lib_bufs[] 路径槽 + try_append/argv_append 写槽 仍 rest；
//     FROM_X rest 无 pure-dup lib_bufs_reset _impl。
// PREFER_X_O：thin.o + seed-rest（-DSHUX_L2_FMT_CHECK_THIN_FROM_X）ld -r
//   → fmt_check_cmd_driver.o
// Prove IDENTICAL：seeds/fmt_check_cmd_thin_surface.from_x.c
// Cap residual：walk opendir/stat/argv/大 BSS（ignore path slots / file_list ptrs /
//   lib path slots）/ check_one_file_body 等 *_impl 仍在 full seed rest；FROM_X 下
//   pure-duplicate _impl 已剔除（含 set_current_file / print / cwd_fallback /
//   try_walk / path_resolve_abs / append_repo / missing_diag / collect_mode /
//   user_passed_L / init / file_list_n / user_ignore_count / lib_bufs_n；H↓）。
//
// -E 约束：无 while 重赋值；无零参-only 不稳写法；6 参用扁平 if。
//

export extern "C" function strstr(hay: *u8, needle: *u8): *u8;
export extern "C" function getenv(name: *u8): *u8;
export extern "C" function getcwd(buf: *u8, size: i32): *u8;
export extern "C" function lsp_diag_print_stderr_human(path: *u8): i32;
export extern "C" function driver_run_compiler_full(argc: i32, argv: *u8): i32;
export extern "C" function driver_dep_seeded_clear_all(): void;
export extern "C" function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;
export extern "C" function fmt_user_ignore_at_impl(i: i32): *u8;
export extern "C" function fmt_file_list_store_impl(abs_path: *u8): i32;
// Cap residual：可写路径 BSS 槽（0=current_file，1=resolve_abs）。
// -E 顶层 u8[N] 现退化为悬空指针（codegen.x 已根修，codegen_gen 再生后可收回此槽）。
export extern "C" function fmt_check_path_bss_slot(which: i32): *u8;
// G.7: load argv[i] / char** slot (pipeline authority pair with shux_ptr_slot_set).
export extern "C" function shux_ptr_slot_get(arr: *u8, i: i32): *u8;

// ---- Cap residual pure: collect_mode + user_passed_L + file_list/ignore/lib_bufs n ----
// DRIVER_COLLECT_MODE_FMT=1, DRIVER_COLLECT_MODE_CHECK=2 (match seed enum).
// Hybrid thin owns cells; cold seed keeps C static + _impl. PLATFORM: SHARED.
// Counters pure; Cap residual path tables (ignore/file_list/lib bufs) stay rest.
let g_fmt_collect_mode: i32[1] = [1];
let g_fmt_user_passed_L: i32[1] = [0];
let g_fmt_file_list_n: i32[1] = [0];
let g_fmt_user_ignore_n: i32[1] = [0];
let g_fmt_check_lib_bufs_n: i32[1] = [0];

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
  if (driver_collect_mode_is_check() != 0) {
    return &g_fmt_lit_check_error[0];
  }
  return &g_fmt_lit_fmt_error[0];
}

#[no_mangle]
export function driver_collect_missing_path_code(): *u8 {
  if (driver_collect_mode_is_check() != 0) {
    return &g_fmt_lit_chk002[0];
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

/** Return 1 when collect mode is check (value 2), else 0 (fmt mode=1).
 * Pure BSS authority under PREFER hybrid. PLATFORM: SHARED. */
#[no_mangle]
export function driver_collect_mode_is_check(): i32 {
  unsafe {
    if (g_fmt_collect_mode[0] == 2) {
      return 1;
    }
  }
  return 0;
}

/** Set collect mode (1=fmt, 2=check). Rest run_fmt/run_check call this under hybrid.
 * PLATFORM: SHARED — same enum as cold seed DriverCollectMode. */
#[no_mangle]
export function driver_collect_mode_set(v: i32): void {
  unsafe {
    g_fmt_collect_mode[0] = v;
  }
}

/** Return 1 if user already passed -L (skip default lib-root injection).
 * Pure BSS authority under PREFER hybrid. PLATFORM: SHARED. */
#[no_mangle]
export function check_user_passed_L_get(): i32 {
  unsafe {
    return g_fmt_user_passed_L[0];
  }
  return 0;
}

/** Store user-passed -L flag (0/1). Used by pure init and cold twin under hybrid.
 * PLATFORM: SHARED. */
#[no_mangle]
export function check_user_passed_L_set(v: i32): void {
  unsafe {
    if (v != 0) {
      g_fmt_user_passed_L[0] = 1;
    } else {
      g_fmt_user_passed_L[0] = 0;
    }
  }
}

// ---- G-02f-389：.x 后缀 pure；ignore n / file_list n pure BSS ----
/** Return --ignore path slot count. Pure BSS under PREFER hybrid. PLATFORM: SHARED. */
#[no_mangle]
export function fmt_user_ignore_count(): i32 {
  unsafe {
    return g_fmt_user_ignore_n[0];
  }
  return 0;
}

/** Set --ignore path slot count (parse ++ / run reset 0). Rest Cap parse/at call this.
 * PLATFORM: SHARED — same counter as cold seed s_n_ignore. */
#[no_mangle]
export function fmt_user_ignore_count_set(v: i32): void {
  unsafe {
    if (v < 0) {
      g_fmt_user_ignore_n[0] = 0;
    } else {
      g_fmt_user_ignore_n[0] = v;
    }
  }
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

/** Return collected .x path count. Pure BSS under PREFER hybrid. PLATFORM: SHARED. */
#[no_mangle]
export function fmt_file_list_n(): i32 {
  unsafe {
    return g_fmt_file_list_n[0];
  }
  return 0;
}

/** Set collected .x path count (store ++ / clear 0). Rest Cap store/clear call this.
 * PLATFORM: SHARED — same counter as cold seed s_n_files. */
#[no_mangle]
export function fmt_file_list_n_set(v: i32): void {
  unsafe {
    if (v < 0) {
      g_fmt_file_list_n[0] = 0;
    } else {
      g_fmt_file_list_n[0] = v;
    }
  }
}

/** Return check -L lib path buffer slot count. Pure BSS under PREFER hybrid.
 * PLATFORM: SHARED — same counter as cold seed s_n_check_lib_bufs. */
#[no_mangle]
export function fmt_check_lib_bufs_n(): i32 {
  unsafe {
    return g_fmt_check_lib_bufs_n[0];
  }
  return 0;
}

/** Set check -L lib path buffer slot count (try_append ++ / reset 0).
 * Cap residual path table writers call this. PLATFORM: SHARED. */
#[no_mangle]
export function fmt_check_lib_bufs_n_set(v: i32): void {
  unsafe {
    if (v < 0) {
      g_fmt_check_lib_bufs_n[0] = 0;
    } else {
      g_fmt_check_lib_bufs_n[0] = v;
    }
  }
}

/** Reset check -L lib path buffer count to 0 (per-file / init). Pure under hybrid.
 * Cap residual keeps s_check_lib_bufs[] path slots. PLATFORM: SHARED. */
#[no_mangle]
export function fmt_check_lib_bufs_reset(): void {
  fmt_check_lib_bufs_n_set(0);
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

/** Scan argv[path_start..) for "-L"; set user_passed_L and reset lib-buf count.
 * Pure under PREFER hybrid: G.7 shux_ptr_slot_get for argv[i]; byte-eq "-L" (45,76,0).
 * lib_bufs n pure (fmt_check_lib_bufs_reset); Cap residual keeps path slots. PLATFORM: SHARED. */
#[no_mangle]
export function check_init_user_lib_flags(argc: i32, argv: *u8, path_start: i32): void {
  check_user_passed_L_set(0);
  fmt_check_lib_bufs_reset();
  if (argv == 0 as *u8) {
    return;
  }
  if (path_start < 0) {
    return;
  }
  unsafe {
    let i: i32 = path_start;
    while (i < argc) {
      let a: *u8 = shux_ptr_slot_get(argv, i);
      if (a != 0 as *u8) {
        // ASCII "-L"
        if (a[0] == 45) {
          if (a[1] == 76) {
            if (a[2] == 0) {
              check_user_passed_L_set(1);
              return;
            }
          }
        }
      }
      i = i + 1;
    }
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

// ---- G-02f-408：try_walk pure；collect orch + cwd_fallback pure；
//      append_repo pure / missing_diag pure；argv_append Cap ----
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

/** Report a missing/inaccessible path diagnostic (no printf/reportf).
 * Builds the message "cannot access path '<path>'" byte-by-byte into a local
 * buffer (max 600), then calls diag_report_with_code with collect kind/code.
 * `path` may be null (message still ends with empty quotes). Side effect only.
 * Track-L: #[no_mangle] keeps surface short name collect_paths_missing_diag_pure
 * (without it, codegen emits driver_collect_paths_missing_diag_pure).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function collect_paths_missing_diag_pure(path: *u8): void {
  unsafe {
    let msg: u8[600] = [];
    // ASCII: "cannot access path '"
    msg[0] = 99;
    msg[1] = 97;
    msg[2] = 110;
    msg[3] = 110;
    msg[4] = 111;
    msg[5] = 116;
    msg[6] = 32;
    msg[7] = 97;
    msg[8] = 99;
    msg[9] = 99;
    msg[10] = 101;
    msg[11] = 115;
    msg[12] = 115;
    msg[13] = 32;
    msg[14] = 112;
    msg[15] = 97;
    msg[16] = 116;
    msg[17] = 104;
    msg[18] = 32;
    msg[19] = 39;
    let at: i32 = 20;
    // Append path bytes (cap) then closing quote and NUL.
    if (path != 0 as *u8) {
      let i: i32 = 0;
      while (i < 512) {
        let c: u8 = path[i];
        if (c == 0) {
          break;
        }
        if (at >= 598) {
          break;
        }
        msg[at] = c;
        at = at + 1;
        i = i + 1;
      }
    }
    if (at < 599) {
      msg[at] = 39;
      at = at + 1;
    }
    msg[at] = 0;
    let kind: *u8 = driver_collect_error_kind();
    let code: *u8 = driver_collect_missing_path_code();
    diag_report_with_code(path, 0, 0, kind, code, &msg[0], 0 as *u8);
  }
}

// pure 编排：null / stat_kind / missing diag pure / dir→walk / file→push
#[no_mangle]
export function collect_paths_from_arg(arg: *u8): void {
  if (arg == 0 as *u8) {
    return;
  }
  unsafe {
    let k: i32 = fmt_path_stat_kind(arg);
    if (k < 0) {
      collect_paths_missing_diag_pure(arg);
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

// pure：从 path 所在目录向上 8 层找含 core+std 的仓库根并 try_append（无 snprintf/rest _impl）
#[no_mangle]
export function check_append_repo_lib_roots(path: *u8, check_argv: *u8, n: *i32): void {
  if (check_argv == 0 as *u8) {
    return;
  }
  if (n == 0 as *i32) {
    return;
  }
  if (check_user_passed_L_get() != 0) {
    return;
  }
  unsafe {
    if (n[0] >= 58) {
      return;
    }
    let start: u8[512] = [];
    if (path == 0 as *u8) {
      let p0: *u8 = getcwd(&start[0], 512);
      if (p0 == 0 as *u8) {
        return;
      }
      check_try_append_lib_root(check_argv, n, &start[0]);
      return;
    }
    if (path[0] == 0) {
      let p1: *u8 = getcwd(&start[0], 512);
      if (p1 == 0 as *u8) {
        return;
      }
      check_try_append_lib_root(check_argv, n, &start[0]);
      return;
    }
    // 解析 start：绝对路径拷贝，相对路径 cwd/path
    if (path[0] == 47) {
      let i: i32 = 0;
      while (i < 511) {
        let c: u8 = path[i];
        start[i] = c;
        if (c == 0) {
          break;
        }
        i = i + 1;
      }
      start[511] = 0;
    } else {
      let p2: *u8 = getcwd(&start[0], 512);
      if (p2 == 0 as *u8) {
        return;
      }
      let sl: i32 = 0;
      while (sl < 511) {
        if (start[sl] == 0) {
          break;
        }
        sl = sl + 1;
      }
      let plen: i32 = 0;
      while (plen < 512) {
        if (path[plen] == 0) {
          break;
        }
        plen = plen + 1;
      }
      if (sl + 1 + plen >= 512) {
        return;
      }
      start[sl] = 47;
      sl = sl + 1;
      let j: i32 = 0;
      while (j <= plen) {
        let c2: u8 = path[j];
        start[sl + j] = c2;
        if (c2 == 0) {
          break;
        }
        j = j + 1;
      }
    }
    // 取目录部分：最后 '/' 截断（根 '/' 保留为 "/"）
    let last_slash: i32 = 0 - 1;
    let k: i32 = 0;
    while (k < 512) {
      if (start[k] == 0) {
        break;
      }
      if (start[k] == 47) {
        last_slash = k;
      }
      k = k + 1;
    }
    if (last_slash > 0) {
      start[last_slash] = 0;
    } else {
      if (last_slash == 0) {
        start[1] = 0;
      }
    }
    // cur = start；向上 8 层 try_append
    let cur: u8[512] = [];
    let ci: i32 = 0;
    while (ci < 512) {
      let cc: u8 = start[ci];
      cur[ci] = cc;
      if (cc == 0) {
        break;
      }
      ci = ci + 1;
    }
    let depth: i32 = 0;
    while (depth < 8) {
      check_try_append_lib_root(check_argv, n, &cur[0]);
      // cur == "/"
      if (cur[0] == 47) {
        if (cur[1] == 0) {
          break;
        }
      }
      // parent = dirname(cur)
      let plash: i32 = 0 - 1;
      let pi: i32 = 0;
      while (pi < 512) {
        if (cur[pi] == 0) {
          break;
        }
        if (cur[pi] == 47) {
          plash = pi;
        }
        pi = pi + 1;
      }
      if (plash < 0) {
        break;
      }
      if (plash == 0) {
        cur[0] = 47;
        cur[1] = 0;
      } else {
        cur[plash] = 0;
      }
      depth = depth + 1;
    }
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
