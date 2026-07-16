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
//   + wave BSS pure：user ignore path slots 进 thin（32×256 flat BSS + at + parse_ignore）；
//     Cap residual：file_list ptrs / lib path slots / walk opendir / path_stat 仍 rest；
//     FROM_X rest 无 pure-dup user_ignore_at / parse_ignore_opt _impl。
//   + wave Cap residual pure：lib path slots + full try_append（8×512 BSS + at/store +
//     path_stat public + shux_ptr_slot_set argv）；FROM_X 无 pure-dup try_append_impl；
//     Cap residual：file_list ptrs / walk / stat / store / clear / argv_append / one_file /
//     run_fmt / run_check 仍 rest（ALWAYS residual 9→8）。
//   + wave Cap residual pure：full argv_append（getcwd + try_append cwd + compiler/src
//     (+asm) path_stat + lib slots + shux_ptr_slot_set）；FROM_X 无 pure-dup argv_append_impl；
//     Cap residual：file_list ptrs / walk / stat / store / clear / one_file / run_fmt /
//     run_check 仍 rest（ALWAYS residual 8→7）。
//   + wave Cap residual pure：file_list path slots + store + clear（8192×512 flat BSS +
//     at/store byte-copy + clear n=0）；FROM_X 无 pure-dup store_impl / clear_impl；
//     Cap residual：walk / path_stat / one_file_body / run_fmt / run_check 仍 rest
//     （ALWAYS residual 7→5）。
//   + wave Cap residual pure：driver_run_compiler_check full orch（mode/clear/init/
//     argv scan + collect + one_file public + empty-list diags；quiet success）；
//     FROM_X 无 pure-dup run_check_impl；Cap residual：walk / path_stat /
//     one_file_body / run_fmt 仍 rest（ALWAYS residual 5→4）。
//   + wave Cap residual pure：driver_run_fmt full orch（mode FMT + ignore n=0 + clear +
//     argv --check/--fail-fast/--ignore= + collect/cwd walk + empty FMT001 +
//     public fmt_one_file loop + check-mode summary lits；verbose fixed lit）；
//     FROM_X 无 pure-dup run_fmt_impl；Cap residual：walk / path_stat /
//     one_file_body 仍 rest（ALWAYS residual 4→3）。
//   + wave Cap residual pure：check_one_file full body（file view + diag/lsp collect +
//     check_argv build + inject "check" + append_default_libs + invoke + print +
//     fallback CHK001 fixed lit + finalize）；FROM_X 无 pure-dup body_impl；
//     Cap residual：walk opendir / path_stat 仍 rest（ALWAYS residual 3→2）。
//   + wave Cap residual pure：fmt_path_stat_kind（opendir dir probe + access F_OK；
//     no struct stat layout）；FROM_X 无 pure-dup path_stat_impl；
//     Cap residual：walk opendir 仍 rest（ALWAYS residual 2→1）。
// PREFER_X_O：thin.o + seed-rest（-DSHUX_L2_FMT_CHECK_THIN_FROM_X）ld -r
//   → fmt_check_cmd_driver.o
// Prove IDENTICAL：seeds/fmt_check_cmd_thin_surface.from_x.c
// Cap residual：walk opendir
//   等 *_impl 仍在 full seed rest；FROM_X 下 pure-duplicate _impl 已剔除（含
//   set_current_file / print / cwd_fallback / try_walk / path_resolve_abs /
//   append_repo / missing_diag / collect_mode / user_passed_L / init / file_list_n /
//   user_ignore_count / lib_bufs_n / user_ignore_at / parse_ignore_opt /
//   try_append_lib_root / argv_append / file_list store+clear / run_check / run_fmt /
//   check_one_file body / path_stat；H↓）。
//
// -E 约束：无 while 重赋值；无零参-only 不稳写法；6 参用扁平 if。
//

export extern "C" function strstr(hay: *u8, needle: *u8): *u8;
export extern "C" function getenv(name: *u8): *u8;
export extern "C" function getcwd(buf: *u8, size: i32): *u8;
export extern "C" function strcmp(a: *u8, b: *u8): i32;
export extern "C" function strncmp(a: *u8, b: *u8, n: i32): i32;
export extern "C" function lsp_diag_print_stderr_human(path: *u8): i32;
export extern "C" function driver_run_compiler_full(argc: i32, argv: *u8): i32;
export extern "C" function driver_dep_seeded_clear_all(): void;
export extern "C" function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;
export extern "C" function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void;
export extern "C" function diag_set_file(path: *u8, source: *u8, source_len: i64): void;
export extern "C" function diag_push_file(snapshot: *u8, path: *u8, source: *u8, source_len: i64): void;
export extern "C" function diag_restore(snapshot: *u8): void;
export extern "C" function runtime_read_file_view(path: *u8, out: *u8): i32;
export extern "C" function runtime_release_file_view(view: *u8): void;
export extern "C" function lsp_diag_collect_begin(): void;
export extern "C" function lsp_diag_collect_end(): void;
export extern "C" function lsp_diag_count_severity(severity: i32): i32;
export extern "C" function driver_check_diag_emitted_reset(): void;
export extern "C" function driver_check_diag_emitted_get(): i32;
export extern "C" function driver_check_only_set(v: i32): void;
// Cap residual：单文件 fmt 真体（read/format/write）；orch 调 public 面。
export extern "C" function driver_fmt_one_file(path: *u8, path_len: i32): i32;
export extern "C" function driver_fmt_check_only_set(v: i32): void;
export extern "C" function driver_fmt_check_only_get(): i32;
// Cap residual：可写路径 BSS 槽（0=current_file，1=resolve_abs）。
// -E 顶层 u8[N] 现退化为悬空指针（codegen.x 已根修，codegen_gen 再生后可收回此槽）。
export extern "C" function fmt_check_path_bss_slot(which: i32): *u8;
// G.7: load/store argv[i] / char** slot (pipeline authority pair).
export extern "C" function shux_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern "C" function shux_ptr_slot_set(arr: *u8, i: i32, p: *u8): void;

// ---- Cap residual pure: collect_mode + user_passed_L + file_list/ignore/lib_bufs n ----
// DRIVER_COLLECT_MODE_FMT=1, DRIVER_COLLECT_MODE_CHECK=2 (match seed enum).
// Hybrid thin owns cells; cold seed keeps C static + _impl. PLATFORM: SHARED.
// Counters pure; file_list path slots (8192×512) + ignore (32×256) + lib (8×512) pure.
let g_fmt_collect_mode: i32[1] = [1];
let g_fmt_user_passed_L: i32[1] = [0];
let g_fmt_file_list_n: i32[1] = [0];
let g_fmt_user_ignore_n: i32[1] = [0];
let g_fmt_check_lib_bufs_n: i32[1] = [0];
// User --ignore path slots: 32 entries × 256 bytes (match DRIVER_FMT_MAX_IGNORE × seed).
// PLATFORM: SHARED. Pure under PREFER hybrid; cold seed keeps s_ignore_paths[][].
let g_fmt_user_ignore_paths: u8[8192] = [];
// Check -L lib path slots: 8 entries × 512 bytes (match seed s_check_lib_bufs).
// PLATFORM: SHARED. Pure under PREFER hybrid; cold seed keeps s_check_lib_bufs[][].
let g_fmt_check_lib_bufs: u8[4096] = [];
// Collected .x path slots: DRIVER_FMT_MAX_FILES (8192) × 512 bytes flat BSS.
// Replaces Cap residual char* s_file_list[] + strdup/free under hybrid.
// PLATFORM: SHARED. Cold seed keeps pointer table + strdup/free.
let g_fmt_file_list_paths: u8[4194304] = [];

let g_fmt_lit_check_error: u8[12] = [99, 104, 101, 99, 107, 32, 101, 114, 114, 111, 114, 0];
let g_fmt_lit_fmt_error: u8[10] = [102, 109, 116, 32, 101, 114, 114, 111, 114, 0];
let g_fmt_lit_chk002: u8[7] = [67, 72, 75, 48, 48, 50, 0];
let g_fmt_lit_chk001: u8[7] = [67, 72, 75, 48, 48, 49, 0];
let g_fmt_lit_fmt001: u8[7] = [70, 77, 84, 48, 48, 49, 0];
// Fallback CHK001 message prefix "check failed: " (no varargs reportf).
let g_fmt_lit_check_failed_prefix: u8[15] = [99, 104, 101, 99, 107, 32, 102, 97, 105, 108, 101, 100, 58, 32, 0];
// ASCII "-L" for check_argv injection (try_append pure).
let g_fmt_lit_dash_L: u8[3] = [45, 76, 0];
// run_check argv flag / empty-list message lits (strcmp/strncmp; no string syntax).
let g_fmt_lit_cmd_check: u8[6] = [99, 104, 101, 99, 107, 0];
let g_fmt_lit_fail_fast: u8[12] = [45, 45, 102, 97, 105, 108, 45, 102, 97, 115, 116, 0];
let g_fmt_lit_ignore_eq: u8[10] = [45, 45, 105, 103, 110, 111, 114, 101, 61, 0];
let g_fmt_lit_dash_I: u8[3] = [45, 73, 0];
let g_fmt_lit_dash_o: u8[3] = [45, 111, 0];
let g_fmt_lit_dash_O: u8[3] = [45, 79, 0];
let g_fmt_lit_backend: u8[9] = [45, 98, 97, 99, 107, 101, 110, 100, 0];
let g_fmt_lit_no_x_paths: u8[38] = [110, 111, 32, 46, 120, 32, 102, 105, 108, 101, 115, 32, 102, 111, 117, 110, 100, 32, 117, 110, 100, 101, 114, 32, 103, 105, 118, 101, 110, 32, 112, 97, 116, 104, 40, 115, 41, 0];
let g_fmt_lit_no_x_cwd: u8[39] = [110, 111, 32, 46, 120, 32, 102, 105, 108, 101, 115, 32, 102, 111, 117, 110, 100, 32, 105, 110, 32, 99, 117, 114, 114, 101, 110, 116, 32, 100, 105, 114, 101, 99, 116, 111, 114, 121, 0];
// run_fmt flag / summary / verbose lits (no string syntax; no varargs diag_reportf).
let g_fmt_lit_dash_check: u8[8] = [45, 45, 99, 104, 101, 99, 107, 0];
let g_fmt_lit_note: u8[5] = [110, 111, 116, 101, 0];
let g_fmt_lit_info: u8[5] = [105, 110, 102, 111, 0];
let g_fmt_lit_needs_formatting: u8[18] = [110, 101, 101, 100, 115, 32, 102, 111, 114, 109, 97, 116, 116, 105, 110, 103, 0];
let g_fmt_lit_found_not_formatted: u8[26] = [102, 111, 117, 110, 100, 32, 110, 111, 116, 32, 102, 111, 114, 109, 97, 116, 116, 101, 100, 32, 102, 105, 108, 101, 115, 0];
let g_fmt_lit_run_shux_fmt: u8[37] = [114, 117, 110, 32, 96, 115, 104, 117, 120, 32, 102, 109, 116, 96, 32, 116, 111, 32, 102, 111, 114, 109, 97, 116, 32, 116, 104, 101, 115, 101, 32, 102, 105, 108, 101, 115, 0];
let g_fmt_lit_fmt_verbose_env: u8[17] = [83, 72, 85, 88, 95, 70, 77, 84, 95, 86, 69, 82, 66, 79, 83, 69, 0];
let g_fmt_lit_formatted_files: u8[17] = [70, 111, 114, 109, 97, 116, 116, 101, 100, 32, 102, 105, 108, 101, 115, 0];

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

/** Return pointer to user --ignore path slot i (256B each in flat BSS).
 * Pure under PREFER hybrid. Bounds: i in [0, g_fmt_user_ignore_n). PLATFORM: SHARED. */
#[no_mangle]
export function fmt_user_ignore_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  unsafe {
    if (i >= g_fmt_user_ignore_n[0]) {
      return 0 as *u8;
    }
    let base: *u8 = &g_fmt_user_ignore_paths[0];
    return base + (i * 256);
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

/** Set collected .x path count (store ++ / clear 0). Pure store/clear call this.
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

/** Return pointer to collected .x path slot i (512B each in flat BSS).
 * Pure under PREFER hybrid. Bounds: i in [0, n). PLATFORM: SHARED.
 * Cap residual run_fmt/run_check iterate via this public API (not s_file_list[]). */
#[no_mangle]
export function fmt_file_list_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  unsafe {
    if (i >= g_fmt_file_list_n[0]) {
      return 0 as *u8;
    }
    let base: *u8 = &g_fmt_file_list_paths[0];
    return base + (i * 512);
  }
  return 0 as *u8;
}

/** Copy abs_path into next free file_list path slot and bump n.
 * Returns 0 on success, -1 on null/full. Pure under hybrid (byte-copy, no strdup).
 * PLATFORM: SHARED — cold seed keeps strdup store_impl under non-FROM_X. */
#[no_mangle]
export function fmt_file_list_store(abs_path: *u8): i32 {
  if (abs_path == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    let n: i32 = g_fmt_file_list_n[0];
    if (n >= 8192) {
      return 0 - 1;
    }
    let base: *u8 = &g_fmt_file_list_paths[0];
    let slot: *u8 = base + (n * 512);
    let k: i32 = 0;
    while (k < 511) {
      let c: u8 = abs_path[k];
      slot[k] = c;
      if (c == 0) {
        fmt_file_list_n_set(n + 1);
        return 0;
      }
      k = k + 1;
    }
    slot[511] = 0;
    fmt_file_list_n_set(n + 1);
  }
  return 0;
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
 * Path slots live in pure g_fmt_check_lib_bufs under hybrid. PLATFORM: SHARED. */
#[no_mangle]
export function fmt_check_lib_bufs_reset(): void {
  fmt_check_lib_bufs_n_set(0);
}

/** Return pointer to check -L lib path slot i (512B each in flat BSS).
 * Pure under PREFER hybrid. Bounds: i in [0, 8). PLATFORM: SHARED. */
#[no_mangle]
export function fmt_check_lib_buf_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 8) {
    return 0 as *u8;
  }
  unsafe {
    let base: *u8 = &g_fmt_check_lib_bufs[0];
    return base + (i * 512);
  }
  return 0 as *u8;
}

/** Copy path into check -L lib path slot i (max 511 bytes + NUL).
 * Returns 1 on success, 0 on bad index/null. Pure under hybrid.
 * Cap residual argv_append uses this with public n get/set. PLATFORM: SHARED. */
#[no_mangle]
export function fmt_check_lib_buf_store(i: i32, path: *u8): i32 {
  if (i < 0) {
    return 0;
  }
  if (i >= 8) {
    return 0;
  }
  if (path == 0 as *u8) {
    return 0;
  }
  unsafe {
    let slot: *u8 = fmt_check_lib_buf_at(i);
    if (slot == 0 as *u8) {
      return 0;
    }
    let k: i32 = 0;
    while (k < 511) {
      let c: u8 = path[k];
      slot[k] = c;
      if (c == 0) {
        return 1;
      }
      k = k + 1;
    }
    slot[511] = 0;
  }
  return 1;
}

// ---- lint pure / invoke·dep_clear pure 分派；path_stat pure (POSIX probe) ----
// PLATFORM: POSIX — no struct stat layout (mac st_mode@4 vs Linux@24).
// Directory: opendir success → 1; else access(F_OK)==0 → 0; else -1.
// Matches seed S_ISDIR / exists semantics for product fmt/check path trees.
export extern "C" function opendir(name: *u8): *u8;
export extern "C" function closedir(dirp: *u8): i32;
export extern "C" function access(path: *u8, mode: i32): i32;

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

/** Classify path for fmt/check collect: -1 inaccessible, 1 directory, 0 file/other.
 * Pure under PREFER hybrid without struct stat (G.8 platform layout hazard):
 *   1) null path → -1;
 *   2) opendir(path) success → closedir + return 1 (directory);
 *   3) access(path, F_OK=0)==0 → return 0 (exists, non-dir for our purposes);
 *   4) else → -1.
 * Cold seed keeps libc stat+S_ISDIR under #ifndef FROM_X.
 * No fmt_path_stat_kind_impl under hybrid (ALWAYS residual 2→1).
 * PLATFORM: POSIX — dual-host prove; Windows cold seed remains C rest. */
#[no_mangle]
export function fmt_path_stat_kind(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    let d: *u8 = opendir(path);
    if (d != 0 as *u8) {
      closedir(d);
      return 1;
    }
    // F_OK = 0: existence only (no read bit required).
    if (access(path, 0) == 0) {
      return 0;
    }
  }
  return 0 - 1;
}

// ---- pure try_append full + current file/print pure；one_file body pure ----

/** If dir has both core/ and std/ subdirs, inject -L dir into check_argv (deduped).
 * Pure under PREFER hybrid: early gates + byte-build core/std paths + public
 * fmt_path_stat_kind (pure POSIX probe) + pure lib path slots + G.7 shux_ptr_slot_set.
 * No try_append_impl under hybrid (ALWAYS residual 9→8). PLATFORM: SHARED. */
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
    // Build dir+"/core" and dir+"/std" (no snprintf).
    let core_path: u8[560] = [];
    let std_path: u8[560] = [];
    let di: i32 = 0;
    while (di < 512) {
      let c: u8 = dir[di];
      if (c == 0) {
        break;
      }
      core_path[di] = c;
      std_path[di] = c;
      di = di + 1;
    }
    // Need room for "/core\0" (5+1) and "/std\0" (4+1).
    if ((di + 6) >= 560) {
      return;
    }
    core_path[di] = 47;
    core_path[di + 1] = 99;
    core_path[di + 2] = 111;
    core_path[di + 3] = 114;
    core_path[di + 4] = 101;
    core_path[di + 5] = 0;
    std_path[di] = 47;
    std_path[di + 1] = 115;
    std_path[di + 2] = 116;
    std_path[di + 3] = 100;
    std_path[di + 4] = 0;
    // Pure path_stat: directory = 1.
    if (fmt_path_stat_kind(&core_path[0]) != 1) {
      return;
    }
    if (fmt_path_stat_kind(&std_path[0]) != 1) {
      return;
    }
    let nb: i32 = fmt_check_lib_bufs_n();
    let i: i32 = 0;
    while (i < nb) {
      let slot: *u8 = fmt_check_lib_buf_at(i);
      if (slot != 0 as *u8) {
        // Byte-eq slot vs dir (NUL-terminated).
        let eq: i32 = 1;
        let j: i32 = 0;
        while (j < 512) {
          let a: u8 = slot[j];
          let b: u8 = dir[j];
          if (a != b) {
            eq = 0;
            break;
          }
          if (a == 0) {
            break;
          }
          j = j + 1;
        }
        if (eq != 0) {
          return;
        }
      }
      i = i + 1;
    }
    if (nb >= 8) {
      return;
    }
    if (fmt_check_lib_buf_store(nb, dir) == 0) {
      return;
    }
    let slot2: *u8 = fmt_check_lib_buf_at(nb);
    if (slot2 == 0 as *u8) {
      return;
    }
    let ni: i32 = n[0];
    shux_ptr_slot_set(check_argv, ni, &g_fmt_lit_dash_L[0]);
    shux_ptr_slot_set(check_argv, ni + 1, slot2);
    n[0] = ni + 2;
    fmt_check_lib_bufs_n_set(nb + 1);
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

/** Run check on one .x path (deno check single-file body).
 * Pure under PREFER hybrid:
 *   1) runtime_read_file_view into 32B stack ABI (ShuxRuntimeFileView layout) +
 *      diag_set_file from view data/len (or null/0 on read fail);
 *   2) lsp_diag_collect_begin + driver_check_diag_emitted_reset +
 *      driver_check_set_current_file (pure BSS) + fmt_check_lib_bufs_reset;
 *   3) build check_argv[64] via G.7 shux_ptr_slot_* on 512B stack:
 *      argv[0], inject lit "check" (product X pipeline; cold seed keeps #ifdef),
 *      copy flags from argv[2..] (-L|-I|-o|-backend|-O take value; --fail-fast),
 *      check_argv_append_default_libs_for_path (pure) + path;
 *   4) driver_check_only_set(1) → fmt_check_invoke_compile → set(0);
 *   5) diag_push_file snapshot + lsp_diag_print + count severity +
 *      check_one_need_fallback_diag → fixed lit CHK001 "check failed: <path>";
 *      nd_errors>0 forces rc=1; check_one_finalize_rc (lint warnings);
 *   6) lsp_diag_collect_end + release view + fmt_check_dep_clear.
 * No check_one_file_body_impl under hybrid (ALWAYS residual 3→2).
 * PLATFORM: SHARED — dual-host prove + check matrix. */
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
    // ShuxRuntimeFileView ABI: data@0 length@8 needs_free@16 needs_munmap@20 (24B; pad 32).
    let view: u8[32] = [];
    let z: i32 = 0;
    while (z < 32) {
      view[z] = 0;
      z = z + 1;
    }
    let have_diag_view: i32 = 0;
    let view_data: *u8 = 0 as *u8;
    let view_len: i64 = 0;
    if (runtime_read_file_view(path, &view[0]) == 0) {
      // Slot 0 = data (*u8); slot 1 = length bit-pattern as size_t on LP64.
      view_data = shux_ptr_slot_get(&view[0], 0);
      let len_bits: *u8 = shux_ptr_slot_get(&view[0], 1);
      view_len = len_bits as i64;
      diag_set_file(path, view_data, view_len);
      have_diag_view = 1;
    } else {
      diag_set_file(path, 0 as *u8, 0);
    }
    lsp_diag_collect_begin();
    driver_check_diag_emitted_reset();
    driver_check_set_current_file(path);
    fmt_check_lib_bufs_reset();

    // char* check_argv[64] as 64×8 pointer slots on stack.
    let check_argv: u8[512] = [];
    let n: i32 = 0;
    let a0: *u8 = shux_ptr_slot_get(argv, 0);
    shux_ptr_slot_set(&check_argv[0], 0, a0);
    n = 1;
    // Product path always X pipeline: inject subcommand "check".
    shux_ptr_slot_set(&check_argv[0], n, &g_fmt_lit_cmd_check[0]);
    n = n + 1;
    let i: i32 = 2;
    while (i < argc) {
      if (n >= 60) {
        break;
      }
      let ai: *u8 = shux_ptr_slot_get(argv, i);
      if (ai != 0 as *u8) {
        if (ai[0] == 45) {
          shux_ptr_slot_set(&check_argv[0], n, ai);
          n = n + 1;
          // -L / -I / -o / -backend / -O take a following value.
          let take_val: i32 = 0;
          if (strcmp(ai, &g_fmt_lit_dash_L[0]) == 0) {
            take_val = 1;
          } else {
            if (strcmp(ai, &g_fmt_lit_dash_I[0]) == 0) {
              take_val = 1;
            } else {
              if (strcmp(ai, &g_fmt_lit_dash_o[0]) == 0) {
                take_val = 1;
              } else {
                if (strcmp(ai, &g_fmt_lit_backend[0]) == 0) {
                  take_val = 1;
                } else {
                  if (strcmp(ai, &g_fmt_lit_dash_O[0]) == 0) {
                    take_val = 1;
                  }
                }
              }
            }
          }
          if (take_val != 0) {
            if ((i + 1) < argc) {
              if (n < 60) {
                i = i + 1;
                let av: *u8 = shux_ptr_slot_get(argv, i);
                shux_ptr_slot_set(&check_argv[0], n, av);
                n = n + 1;
              }
            }
          }
        } else {
          if (strcmp(ai, &g_fmt_lit_fail_fast[0]) == 0) {
            shux_ptr_slot_set(&check_argv[0], n, ai);
            n = n + 1;
          }
        }
      }
      i = i + 1;
    }
    check_argv_append_default_libs_for_path(path, &check_argv[0], &n);
    if (n < 64) {
      shux_ptr_slot_set(&check_argv[0], n, path);
      n = n + 1;
    }

    driver_check_only_set(1);
    let rc: i32 = fmt_check_invoke_compile(n, &check_argv[0]);
    driver_check_only_set(0);

    // DiagContextSnapshot: file@0 source@8 len@16 color@24 → 32B stack.
    let snap: u8[32] = [];
    let si: i32 = 0;
    while (si < 32) {
      snap[si] = 0;
      si = si + 1;
    }
    if (have_diag_view != 0) {
      diag_push_file(&snap[0], path, view_data, view_len);
    } else {
      diag_push_file(&snap[0], path, 0 as *u8, 0);
    }
    let nd: i32 = lsp_diag_print_stderr_human(path);
    let nd_errors: i32 = lsp_diag_count_severity(1);
    let nd_warnings: i32 = lsp_diag_count_severity(2);
    let nd_infos: i32 = lsp_diag_count_severity(3);
    let direct_diag: i32 = driver_check_diag_emitted_get();
    diag_restore(&snap[0]);
    if (check_one_need_fallback_diag(rc, nd, nd_errors, nd_warnings, nd_infos, direct_diag) != 0) {
      // "check failed: " + path (no reportf).
      let msg: u8[600] = [];
      let at: i32 = 0;
      let pfx: *u8 = &g_fmt_lit_check_failed_prefix[0];
      let pi: i32 = 0;
      while (pi < 14) {
        msg[at] = pfx[pi];
        at = at + 1;
        pi = pi + 1;
      }
      let qi: i32 = 0;
      while (qi < 512) {
        let c: u8 = path[qi];
        if (c == 0) {
          break;
        }
        if (at >= 598) {
          break;
        }
        msg[at] = c;
        at = at + 1;
        qi = qi + 1;
      }
      msg[at] = 0;
      diag_report_with_code(path, 0, 0, &g_fmt_lit_check_error[0], &g_fmt_lit_chk001[0], &msg[0], 0 as *u8);
    }
    if (nd_errors > 0) {
      rc = 1;
    }
    rc = check_one_finalize_rc(rc, nd_warnings);

    lsp_diag_collect_end();
    if (have_diag_view != 0) {
      runtime_release_file_view(&view[0]);
    }
    fmt_check_dep_clear();
    return rc;
  }
  return 0 - 1;
}

// ---- pure ignore / file_list orch / walk process_child；Cap：walk opendir ----
export extern "C" function walk_dir_collect_impl(dir: *u8): void;

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

/** Orch: full / resolve_abs / ignore / .x suffix then pure store into path slots.
 * No Cap store_impl under hybrid (ALWAYS residual 7→5 with clear). PLATFORM: SHARED. */
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
    return fmt_file_list_store(abs_path);
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

/** Parse --ignore=a,b,c into pure user-ignore path slots (max 32 × 256B).
 * Prefix gate + comma token walk + byte copy (no snprintf). PLATFORM: SHARED. */
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
  // -E hoists all let in a block to the top: do not bind end=p after mutating p.
  // Scan with end; copy [start,end); then p=end and optional comma skip.
  unsafe {
    let p: i32 = 9;
    let n: i32 = fmt_user_ignore_count();
    let base: *u8 = &g_fmt_user_ignore_paths[0];
    while (n < 32) {
      if (arg[p] == 0) {
        break;
      }
      let start: i32 = p;
      let end: i32 = p;
      while (arg[end] != 0) {
        if (arg[end] == 44) {
          break;
        }
        end = end + 1;
      }
      if (start < end) {
        let slot: *u8 = base + (n * 256);
        let k: i32 = 0;
        while (k < 255) {
          if ((start + k) >= end) {
            break;
          }
          slot[k] = arg[start + k];
          k = k + 1;
        }
        slot[k] = 0;
        n = n + 1;
        fmt_user_ignore_count_set(n);
      }
      p = end;
      if (arg[p] == 44) {
        p = p + 1;
      } else {
        break;
      }
    }
  }
}

/** Clear collected .x path list by setting n=0 (slot bytes left stale; at bounds-checked).
 * Pure under hybrid — no free loop. PLATFORM: SHARED.
 * Cap residual run_fmt/run_check call this public API. */
#[no_mangle]
export function file_list_clear(): void {
  fmt_file_list_n_set(0);
}

// ---- G-02f-408：try_walk pure；collect orch + cwd_fallback pure；
//      append_repo pure / missing_diag pure；argv_append full pure ----

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

/** Inject default -L roots for a check argv before the user source path.
 * Pure under PREFER hybrid:
 *   1) early gates (user_passed_L / n cap) via pure getters;
 *   2) public check_append_repo_lib_roots (pure under hybrid);
 *   3) getcwd + public check_try_append_lib_root(cwd);
 *   4) if path contains "compiler/src/", byte-build cwd+"/compiler/src"
 *      (+ "/asm" when path also has "compiler/src/asm/"), then public
 *      fmt_path_stat_kind (pure POSIX probe) + pure lib path slots +
 *      G.7 shux_ptr_slot_set for "-L" injection (no snprintf / no _impl).
 * No check_argv_append_default_libs_for_path_impl under hybrid
 * (ALWAYS residual 8→7). PLATFORM: SHARED. */
#[no_mangle]
export function check_argv_append_default_libs_for_path(path: *u8, check_argv: *u8, n: *i32): void {
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
    check_append_repo_lib_roots(path, check_argv, n);
    let cwd: u8[512] = [];
    let p: *u8 = getcwd(&cwd[0], 512);
    if (p == 0 as *u8) {
      return;
    }
    check_try_append_lib_root(check_argv, n, &cwd[0]);
    if (path == 0 as *u8) {
      return;
    }
    // ASCII "compiler/src/\0"
    let needle_src: u8[14] = [99, 111, 109, 112, 105, 108, 101, 114, 47, 115, 114, 99, 47, 0];
    if (strstr(path, &needle_src[0]) == 0 as *u8) {
      return;
    }
    if (n[0] >= 56) {
      return;
    }
    // Build cwd+"/compiler/src" (no snprintf).
    let cs: u8[560] = [];
    let ci: i32 = 0;
    while (ci < 511) {
      let c: u8 = cwd[ci];
      if (c == 0) {
        break;
      }
      cs[ci] = c;
      ci = ci + 1;
    }
    // Need room for "/compiler/src\0" (14 bytes).
    if ((ci + 14) >= 560) {
      return;
    }
    cs[ci] = 47;
    cs[ci + 1] = 99;
    cs[ci + 2] = 111;
    cs[ci + 3] = 109;
    cs[ci + 4] = 112;
    cs[ci + 5] = 105;
    cs[ci + 6] = 108;
    cs[ci + 7] = 101;
    cs[ci + 8] = 114;
    cs[ci + 9] = 47;
    cs[ci + 10] = 115;
    cs[ci + 11] = 114;
    cs[ci + 12] = 99;
    cs[ci + 13] = 0;
    // Pure path_stat: directory = 1. Match seed: inject without core/std dedup.
    if (fmt_path_stat_kind(&cs[0]) == 1) {
      let nb: i32 = fmt_check_lib_bufs_n();
      if (nb < 8) {
        if (fmt_check_lib_buf_store(nb, &cs[0]) != 0) {
          let slot: *u8 = fmt_check_lib_buf_at(nb);
          if (slot != 0 as *u8) {
            let ni: i32 = n[0];
            shux_ptr_slot_set(check_argv, ni, &g_fmt_lit_dash_L[0]);
            shux_ptr_slot_set(check_argv, ni + 1, slot);
            n[0] = ni + 2;
            fmt_check_lib_bufs_n_set(nb + 1);
          }
        }
      }
    }
    // ASCII "compiler/src/asm/\0"
    let needle_asm: u8[18] = [99, 111, 109, 112, 105, 108, 101, 114, 47, 115, 114, 99, 47, 97, 115, 109, 47, 0];
    if (strstr(path, &needle_asm[0]) == 0 as *u8) {
      return;
    }
    if (n[0] >= 56) {
      return;
    }
    // Build cwd+"/compiler/src/asm" (reuse cs).
    let ai: i32 = 0;
    while (ai < 511) {
      let c2: u8 = cwd[ai];
      if (c2 == 0) {
        break;
      }
      cs[ai] = c2;
      ai = ai + 1;
    }
    // Need room for "/compiler/src/asm\0" (18 bytes).
    if ((ai + 18) >= 560) {
      return;
    }
    cs[ai] = 47;
    cs[ai + 1] = 99;
    cs[ai + 2] = 111;
    cs[ai + 3] = 109;
    cs[ai + 4] = 112;
    cs[ai + 5] = 105;
    cs[ai + 6] = 108;
    cs[ai + 7] = 101;
    cs[ai + 8] = 114;
    cs[ai + 9] = 47;
    cs[ai + 10] = 115;
    cs[ai + 11] = 114;
    cs[ai + 12] = 99;
    cs[ai + 13] = 47;
    cs[ai + 14] = 97;
    cs[ai + 15] = 115;
    cs[ai + 16] = 109;
    cs[ai + 17] = 0;
    if (fmt_path_stat_kind(&cs[0]) == 1) {
      let nb2: i32 = fmt_check_lib_bufs_n();
      if (nb2 < 8) {
        if (fmt_check_lib_buf_store(nb2, &cs[0]) != 0) {
          let slot2: *u8 = fmt_check_lib_buf_at(nb2);
          if (slot2 != 0 as *u8) {
            let ni2: i32 = n[0];
            shux_ptr_slot_set(check_argv, ni2, &g_fmt_lit_dash_L[0]);
            shux_ptr_slot_set(check_argv, ni2 + 1, slot2);
            n[0] = ni2 + 2;
            fmt_check_lib_bufs_n_set(nb2 + 1);
          }
        }
      }
    }
  }
}

// ---- G-02f-410：fmt + check entry pure under hybrid ----

/** Run `shux fmt` (deno fmt: multi-file/dir; optional --check lists unformatted).
 * Pure under PREFER hybrid:
 *   1) ignore n=0 + collect mode FMT + file_list_clear (pure);
 *   2) argv scan from 1: --check (set check_only) / --fail-fast / --ignore= /
 *      other -flags skip / path → collect_paths_from_arg (Cap residual walk/stat);
 *   3) no path → getcwd + walk_dir_collect public (Cap residual opendir body);
 *   4) empty list → diag FMT001 with path/cwd message;
 *   5) each path → driver_fmt_one_file (Cap residual one-file body);
 *      on fail in --check: per-file note "needs formatting" (path as diag file);
 *   6) clear check_only + file_list; on --check failures: summary "found not
 *      formatted files" + note "run `shux fmt`…"; optional SHUX_FMT_VERBOSE lit.
 * No varargs diag_reportf; fixed lits satisfy run-fmt-check-cmd greps.
 * No driver_run_fmt_impl under hybrid (ALWAYS residual 4→3).
 * PLATFORM: SHARED — dual-host prove + fmt matrix. */
#[no_mangle]
export function driver_run_fmt(argc: i32, argv: *u8): i32 {
  // DRIVER_COLLECT_MODE_FMT = 1 (match seed enum).
  fmt_user_ignore_count_set(0);
  driver_collect_mode_set(1);
  file_list_clear();
  let fail_fast: i32 = 0;
  let any_path: i32 = 0;
  let failed: i32 = 0;
  let formatted: i32 = 0;
  let check_mode: i32 = 0;
  unsafe {
    let i: i32 = 1;
    while (i < argc) {
      if (argv != 0 as *u8) {
        let a: *u8 = shux_ptr_slot_get(argv, i);
        if (a != 0 as *u8) {
          if (strcmp(a, &g_fmt_lit_dash_check[0]) == 0) {
            driver_fmt_check_only_set(1);
            check_mode = 1;
          } else {
            if (strcmp(a, &g_fmt_lit_fail_fast[0]) == 0) {
              fail_fast = 1;
            } else {
              if (strncmp(a, &g_fmt_lit_ignore_eq[0], 9) == 0) {
                parse_ignore_opt(a);
              } else {
                if (a[0] != 45) {
                  any_path = 1;
                  collect_paths_from_arg(a);
                }
              }
            }
          }
        }
      }
      i = i + 1;
    }
  }
  if (any_path == 0) {
    let cwd: u8[512] = [];
    unsafe {
      let p: *u8 = getcwd(&cwd[0], 512);
      if (p != 0 as *u8) {
        walk_dir_collect(&cwd[0]);
      }
    }
  }
  if (fmt_file_list_n() == 0) {
    unsafe {
      let kind: *u8 = &g_fmt_lit_fmt_error[0];
      let code: *u8 = &g_fmt_lit_fmt001[0];
      if (any_path != 0) {
        diag_report_with_code(0 as *u8, 0, 0, kind, code, &g_fmt_lit_no_x_paths[0], 0 as *u8);
      } else {
        diag_report_with_code(0 as *u8, 0, 0, kind, code, &g_fmt_lit_no_x_cwd[0], 0 as *u8);
      }
    }
    return 1;
  }
  unsafe {
    let n: i32 = fmt_file_list_n();
    let j: i32 = 0;
    while (j < n) {
      let path: *u8 = fmt_file_list_at(j);
      if (path != 0 as *u8) {
        let plen: i32 = 0;
        while (plen < 512) {
          if (path[plen] == 0) {
            break;
          }
          plen = plen + 1;
        }
        let rc: i32 = driver_fmt_one_file(path, plen);
        if (rc != 0) {
          failed = 1;
          if (check_mode != 0) {
            // Path as diag file so path appears; msg matches run-fmt-check-cmd greps.
            diag_report(path, 0, 0, &g_fmt_lit_note[0], &g_fmt_lit_needs_formatting[0], 0 as *u8);
          }
          if (fail_fast != 0) {
            break;
          }
        } else {
          if (check_mode == 0) {
            formatted = formatted + 1;
          }
        }
      }
      j = j + 1;
    }
  }
  unsafe {
    driver_fmt_check_only_set(0);
  }
  file_list_clear();
  if (failed != 0) {
    if (check_mode != 0) {
      unsafe {
        diag_report_with_code(0 as *u8, 0, 0, &g_fmt_lit_fmt_error[0], &g_fmt_lit_fmt001[0], &g_fmt_lit_found_not_formatted[0], 0 as *u8);
        diag_report(0 as *u8, 0, 0, &g_fmt_lit_note[0], &g_fmt_lit_run_shux_fmt[0], 0 as *u8);
      }
      return 1;
    }
    return 1;
  }
  if (check_mode == 0) {
    if (formatted > 0) {
      unsafe {
        let ev: *u8 = getenv(&g_fmt_lit_fmt_verbose_env[0]);
        if (ev != 0 as *u8) {
          diag_report(0 as *u8, 0, 0, &g_fmt_lit_info[0], &g_fmt_lit_formatted_files[0], 0 as *u8);
        }
      }
    }
  }
  return 0;
}

/** Run `shux check` (deno check: multi-file/dir; failures print diagnostics).
 * Pure under PREFER hybrid:
 *   1) collect mode CHECK + file_list_clear (pure);
 *   2) path_start: argv[1]=="check" → 2 else 1 (main.x vs shux-c drop subcmd);
 *   3) check_init_user_lib_flags (pure) then argv scan:
 *      --fail-fast / --ignore= / -L|-I|-o|-backend|-O (skip value) / other -flags /
 *      path → collect_paths_from_arg (pure orch; Cap residual walk/stat);
 *   4) no path → check_collect_default_product_dirs (pure orch);
 *   5) empty list → diag CHK002 with path/cwd message;
 *   6) each path → public check_one_file (pure body under hybrid);
 *   7) quiet success (no check OK line) — matches driver_check_quiet_ok_get()==1.
 * No driver_run_compiler_check_impl under hybrid (ALWAYS residual 5→4 with run_fmt pure).
 * PLATFORM: SHARED — dual-host prove + check matrix. */
#[no_mangle]
export function driver_run_compiler_check(argc: i32, argv: *u8): i32 {
  // DRIVER_COLLECT_MODE_CHECK = 2 (match seed enum).
  driver_collect_mode_set(2);
  file_list_clear();
  let path_start: i32 = 1;
  let fail_fast: i32 = 0;
  let any_path: i32 = 0;
  let failed: i32 = 0;
  unsafe {
    if (argc >= 2) {
      if (argv != 0 as *u8) {
        let a1: *u8 = shux_ptr_slot_get(argv, 1);
        if (a1 != 0 as *u8) {
          if (strcmp(a1, &g_fmt_lit_cmd_check[0]) == 0) {
            path_start = 2;
          }
        }
      }
    }
  }
  check_init_user_lib_flags(argc, argv, path_start);
  unsafe {
    let i: i32 = path_start;
    while (i < argc) {
      let step: i32 = 1;
      if (argv != 0 as *u8) {
        let a: *u8 = shux_ptr_slot_get(argv, i);
        if (a != 0 as *u8) {
          if (strcmp(a, &g_fmt_lit_fail_fast[0]) == 0) {
            fail_fast = 1;
          } else {
            if (strncmp(a, &g_fmt_lit_ignore_eq[0], 9) == 0) {
              parse_ignore_opt(a);
            } else {
              if (strcmp(a, &g_fmt_lit_dash_L[0]) == 0) {
                step = 2;
              } else {
                if (strcmp(a, &g_fmt_lit_dash_I[0]) == 0) {
                  step = 2;
                } else {
                  if (strcmp(a, &g_fmt_lit_dash_o[0]) == 0) {
                    step = 2;
                  } else {
                    if (strcmp(a, &g_fmt_lit_backend[0]) == 0) {
                      step = 2;
                    } else {
                      if (strcmp(a, &g_fmt_lit_dash_O[0]) == 0) {
                        step = 2;
                      } else {
                        if (a[0] != 45) {
                          any_path = 1;
                          collect_paths_from_arg(a);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      i = i + step;
    }
  }
  if (any_path == 0) {
    check_collect_default_product_dirs();
  }
  if (fmt_file_list_n() == 0) {
    unsafe {
      let kind: *u8 = &g_fmt_lit_check_error[0];
      let code: *u8 = &g_fmt_lit_chk002[0];
      if (any_path != 0) {
        diag_report_with_code(0 as *u8, 0, 0, kind, code, &g_fmt_lit_no_x_paths[0], 0 as *u8);
      } else {
        diag_report_with_code(0 as *u8, 0, 0, kind, code, &g_fmt_lit_no_x_cwd[0], 0 as *u8);
      }
    }
    return 1;
  }
  unsafe {
    let n: i32 = fmt_file_list_n();
    let j: i32 = 0;
    while (j < n) {
      let path: *u8 = fmt_file_list_at(j);
      if (path != 0 as *u8) {
        if (check_one_file(path, argc, argv) != 0) {
          failed = 1;
          if (fail_fast != 0) {
            break;
          }
        }
      }
      j = j + 1;
    }
  }
  file_list_clear();
  if (failed != 0) {
    return 1;
  }
  // Quiet success: seed always sets s_check_quiet_ok=1; no check OK line.
  return 0;
}
