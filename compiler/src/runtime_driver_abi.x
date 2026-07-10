// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-29/41/45..49/54/55/57：真迁 .x — driver flags/env/phase + peek/smoke/stack/defines。
// G-02f-83：+ driver_source_scan_top_level_import / entry_source_len_i32 门闩。
// G-02f-92：+ driver_ascii_toupper 门闩。
// G-02f-94：+ large_stack trampoline / run_fn_on_current_large_stack 门闩。
// G-02f-104：+ compile_phase_now_sec 门闩。
// G-02f-243：P1-6 开局 — entry_source_len_i32 saturate + scan_top_level_import 字节扫描 pure。
// G-02f-244：phase index / stack want / path import 编排 pure；smoke/thread null 门闩。
// 产品：./shux-c -E → seeds/runtime_driver_abi.from_x.c（+ C 尾 + getenv/slot 抛光）。
// C 尾：flag/len/path 槽、大栈 pthread 本体、gettimeofday、diag format、argv defines 扫描、path IO。
// G-02f-57：+ driver_argv_collect_defines 薄门闩（扫描本体 C）。
// 注意：set 侧禁止 if/else 写 *p → 直接 p[0]=v；禁止 if (ptr!=null) 整函数被 -E 丢掉。

extern "C" function getenv(name: *u8): *u8;
extern "C" function free(p: *u8): void;
extern "C" function driver_check_only_flag_slot(): *i32;
extern "C" function driver_check_diag_emitted_flag_slot(): *i32;
extern "C" function driver_freestanding_flag_slot(): *i32;
extern "C" function driver_sanitize_address_flag_slot(): *i32;
extern "C" function driver_fmt_check_only_flag_slot(): *i32;
extern "C" function driver_x_pipeline_skip_typeck_flag_slot(): *i32;
extern "C" function driver_x_pipeline_skip_codegen_flag_slot(): *i32;
extern "C" function driver_skip_codegen_dep_0_flag_slot(): *i32;
/* entry_source_len_i32：G-02f-243 下方真迁（load + saturate） */
extern "C" function driver_large_stack_thread_flag_slot(): *i32;
extern "C" function driver_current_dep_path_store(path: *u8): void;
extern "C" function driver_current_dep_path_load(): *u8;
extern "C" function driver_print_check_ok_impl(input_path: *u8): void;
extern "C" function driver_compile_phase_timing_begin_impl(phase: i32): void;
extern "C" function driver_compile_phase_timing_end_impl(phase: i32): void;
extern "C" function driver_compile_phase_timing_flush_impl(): void;
extern "C" function compile_phase_now_sec_impl(): f64;
extern "C" function shux_read_file_into_path(path: *u8, buf: *u8, cap: i64): i32;
extern "C" function driver_pipeline_fail_code_rc_impl(rc: i32): void;
extern "C" function driver_pipeline_fail_code_path_impl(path: *u8): void;
extern "C" function driver_run_thread_on_large_stack_impl(fn: *u8, arg: *u8): void;
extern "C" function driver_get_module_num_funcs(m: *u8): i32;
extern "C" function driver_get_module_main_func_index(m: *u8): i32;
extern "C" function driver_print_x_smoke_parse_ok_impl(num_funcs: i32, main_ix: i32, codegen_len: i64): void;
extern "C" function driver_print_x_smoke_parse_empty_impl(): void;
extern "C" function driver_print_x_smoke_typeck_ok_impl(): void;
/* scan_top_level_import：G-02f-243；path：G-02f-244 下方真迁编排 */
extern "C" function driver_path_read_preprocess_malloc(path: *u8): *u8;
extern "C" function driver_path_last_preprocess_len(): i64;
extern "C" function driver_pipeline_entry_source_len_store(len: i64): void;
extern "C" function driver_pipeline_entry_source_len_load_and_maybe_debug(): i64;
/* bump：G-02f-244 want pure → to_impl(setrlimit) */
extern "C" function driver_bump_stack_limit_to_impl(want_bytes: i64): void;
extern "C" function driver_argv_collect_defines_impl(argc: i32, argv: *u8, defines: *u8, max_defines: i32): i32;
extern "C" function driver_large_stack_thread_trampoline_impl(v: *u8): *u8;
extern "C" function driver_run_fn_on_current_large_stack_impl(fn: *u8, arg: *u8): void;

#[no_mangle]
function driver_check_quiet_ok_get(): i32 {
  return 1;
}

#[no_mangle]
function driver_typeck_force_c_enabled(): i32 {
  unsafe {
    let e: *u8 = getenv("SHUX_TYPECK_FORCE_C");
    if (e == 0 as *u8) {
      return 0;
    }
    if (e[0] == 0) {
      return 0;
    }
    if (e[0] == 48) {
      return 0;
    }
    return 1;
  }
  return 0;
}

#[no_mangle]
function driver_asm_build_skip_typeck(): i32 {
  unsafe {
    let e: *u8 = getenv("SHUX_ASM_BUILD_SKIP_TYPECK");
    if (e == 0 as *u8) {
      return 0;
    }
    if (e[0] == 0) {
      return 0;
    }
    if (e[0] == 48) {
      return 0;
    }
    return 1;
  }
  return 0;
}

#[no_mangle]
function driver_asm_entry_emit_heavy(): i32 {
  unsafe {
    let e: *u8 = getenv("SHUX_ASM_ENTRY_EMIT_HEAVY");
    if (e == 0 as *u8) {
      return 0;
    }
    if (e[0] == 0) {
      return 0;
    }
    if (e[0] == 48) {
      return 0;
    }
    return 1;
  }
  return 0;
}

#[no_mangle]
function driver_asm_entry_module_only_from_env(): i32 {
  unsafe {
    let e: *u8 = getenv("SHUX_ASM_ENTRY_MODULE_ONLY");
    if (e == 0 as *u8) {
      return 0;
    }
    if (e[0] == 0) {
      return 0;
    }
    if (e[0] == 48) {
      return 0;
    }
    return 1;
  }
  return 0;
}

#[no_mangle]
function driver_asm_parse_metric_only_from_env(): i32 {
  unsafe {
    let e: *u8 = getenv("SHUX_ASM_PARSE_METRIC_ONLY");
    if (e == 0 as *u8) {
      return 0;
    }
    if (e[0] == 0) {
      return 0;
    }
    if (e[0] == 48) {
      return 0;
    }
    return 1;
  }
  return 0;
}

#[no_mangle]
function driver_check_only_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_check_only_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
function driver_check_only_get(): i32 {
  unsafe {
    let p: *i32 = driver_check_only_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function driver_check_diag_emitted_reset(): void {
  unsafe {
    let p: *i32 = driver_check_diag_emitted_flag_slot();
    p[0] = 0;
  }
}

#[no_mangle]
function driver_check_diag_emitted_note(): void {
  unsafe {
    let p: *i32 = driver_check_diag_emitted_flag_slot();
    p[0] = 1;
  }
}

#[no_mangle]
function driver_check_diag_emitted_get(): i32 {
  unsafe {
    let p: *i32 = driver_check_diag_emitted_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function driver_freestanding_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_freestanding_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
function driver_freestanding_get(): i32 {
  unsafe {
    let p: *i32 = driver_freestanding_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function driver_sanitize_address_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_sanitize_address_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
function driver_sanitize_address_get(): i32 {
  unsafe {
    let p: *i32 = driver_sanitize_address_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    let e: *u8 = getenv("SHUX_SANITIZE_ADDRESS");
    if (e == 0 as *u8) {
      return 0;
    }
    if (e[0] == 0) {
      return 0;
    }
    if (e[0] == 48) {
      return 0;
    }
    return 1;
  }
  return 0;
}

#[no_mangle]
function driver_fmt_check_only_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_fmt_check_only_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
function driver_fmt_check_only_get(): i32 {
  unsafe {
    let p: *i32 = driver_fmt_check_only_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function driver_x_pipeline_skip_typeck_get(): i32 {
  unsafe {
    let p: *i32 = driver_x_pipeline_skip_typeck_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function driver_x_pipeline_skip_typeck_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_x_pipeline_skip_typeck_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
function driver_x_pipeline_skip_codegen_get(): i32 {
  unsafe {
    let p: *i32 = driver_x_pipeline_skip_codegen_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function driver_x_pipeline_skip_codegen_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_x_pipeline_skip_codegen_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
function driver_skip_codegen_dep_0_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_skip_codegen_dep_0_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
function driver_skip_codegen_dep_0_get(): i32 {
  unsafe {
    let p: *i32 = driver_skip_codegen_dep_0_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/* ---- G-02f-45：大入口 skip + large_stack 标记 ---- */

#[no_mangle]
function driver_typeck_skip_large_entry(): i32 {
  unsafe {
    let len: i32 = driver_pipeline_entry_source_len_i32();
    if (len > 150000) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function driver_is_large_stack_thread(): i32 {
  unsafe {
    let p: *i32 = driver_large_stack_thread_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function driver_large_stack_thread_mark(on: i32): void {
  unsafe {
    let p: *i32 = driver_large_stack_thread_flag_slot();
    p[0] = on;
  }
}

/* ---- G-02f-46：codegen dep 路径槽 + check OK 打印 ---- */

#[no_mangle]
function driver_set_current_dep_path_for_codegen(path: *u8): void {
  unsafe {
    driver_current_dep_path_store(path);
  }
}

#[no_mangle]
function driver_get_current_dep_path_for_codegen(): *u8 {
  unsafe {
    let r: *u8 = driver_current_dep_path_load();
    return r;
  }
  return 0 as *u8;
}

#[no_mangle]
function driver_print_check_ok(input_path: *u8): void {
  unsafe {
    if (driver_check_quiet_ok_get() != 0) {
      return;
    }
    driver_print_check_ok_impl(input_path);
  }
}

/* ---- G-02f-47 / G-02f-244：compile phase timing 门闩与边界 ---- */

#[no_mangle]
function driver_compile_phase_timing_enabled(): i32 {
  unsafe {
    let e: *u8 = getenv("SHUX_COMPILE_PHASE_TIMING");
    if (e == 0 as *u8) {
      return 0;
    }
    return 1;
  }
  return 0;
}

// G-02f-244：phase 0..2 合法
#[no_mangle]
function driver_compile_phase_index_ok(phase: i32): i32 {
  if (phase < 0) {
    return 0;
  }
  if (phase >= 3) {
    return 0;
  }
  return 1;
}

#[no_mangle]
function driver_compile_phase_timing_begin(phase: i32): void {
  unsafe {
    if (driver_compile_phase_timing_enabled() == 0) {
      return;
    }
    if (driver_compile_phase_index_ok(phase) == 0) {
      return;
    }
    driver_compile_phase_timing_begin_impl(phase);
  }
}

#[no_mangle]
function driver_compile_phase_timing_end(phase: i32): void {
  unsafe {
    if (driver_compile_phase_timing_enabled() == 0) {
      return;
    }
    if (driver_compile_phase_index_ok(phase) == 0) {
      return;
    }
    driver_compile_phase_timing_end_impl(phase);
  }
}

#[no_mangle]
function driver_compile_phase_timing_flush(): void {
  unsafe {
    if (driver_compile_phase_timing_enabled() == 0) {
      return;
    }
    driver_compile_phase_timing_flush_impl();
  }
}

/* ---- G-02f-48：peek_source_file / pipeline_fail_code / large_stack 薄别名 ---- */

#[no_mangle]
function driver_peek_source_file(path: *u8, content: *u8, cap: i64): i32 {
  if (path == 0 as *u8) {
    return -1;
  }
  if (content == 0 as *u8) {
    return -1;
  }
  if (cap <= 1) {
    return -1;
  }
  unsafe {
    let n: i32 = shux_read_file_into_path(path, content, cap - 1);
    return n;
  }
  return -1;
}

#[no_mangle]
function driver_pipeline_fail_code(rc: i32, path: *u8): void {
  unsafe {
    driver_pipeline_fail_code_rc_impl(rc);
    if (rc != -7) {
      return;
    }
    if (path == 0 as *u8) {
      return;
    }
    driver_pipeline_fail_code_path_impl(path);
  }
}

#[no_mangle]
function driver_run_thread_on_large_stack(fn: *u8, arg: *u8): void {
  if (fn == 0 as *u8) {
    return;
  }
  unsafe {
    driver_run_thread_on_large_stack_impl(fn, arg);
  }
}

#[no_mangle]
function driver_run_on_large_stack_pthread(fn: *u8, arg: *u8): void {
  if (fn == 0 as *u8) {
    return;
  }
  driver_run_thread_on_large_stack(fn, arg);
}

/* ---- G-02f-49 / G-02f-244：smoke summary / top-level import / entry source len ---- */

#[no_mangle]
function driver_print_x_smoke_summary(module: *u8, codegen_len: i64): void {
  if (module == 0 as *u8) {
    return;
  }
  unsafe {
    if (driver_check_diag_emitted_get() != 0) {
      return;
    }
    let num_funcs: i32 = driver_get_module_num_funcs(module);
    let main_ix: i32 = driver_get_module_main_func_index(module);
    driver_print_x_smoke_parse_ok_impl(num_funcs, main_ix, codegen_len);
    if (num_funcs <= 0) {
      driver_print_x_smoke_parse_empty_impl();
      return;
    }
    driver_print_x_smoke_typeck_ok_impl();
  }
}

#[no_mangle]
function driver_source_has_top_level_import(src: *u8, src_len: i64): i32 {
  if (src == 0 as *u8) {
    return 0;
  }
  if (src_len < 9) {
    return 0;
  }
  return driver_source_scan_top_level_import(src, src_len);
}

// G-02f-244：read+preprocess 🔒 → scan pure → free
#[no_mangle]
function driver_source_has_top_level_import_path(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  unsafe {
    let src: *u8 = driver_path_read_preprocess_malloc(path);
    if (src == 0 as *u8) {
      return 0;
    }
    let len: i64 = driver_path_last_preprocess_len();
    let has: i32 = driver_source_has_top_level_import(src, len);
    free(src);
    return has;
  }
  return 0;
}

#[no_mangle]
function driver_set_pipeline_entry_source_len(len: i64): void {
  unsafe {
    driver_pipeline_entry_source_len_store(len);
  }
}

#[no_mangle]
function driver_pipeline_entry_source_len(): i64 {
  unsafe {
    return driver_pipeline_entry_source_len_load_and_maybe_debug();
  }
  return 0;
}

/* ---- G-02f-54 / G-02f-244：抬高 RLIMIT_STACK（want pure + setrlimit 🔒）---- */

// G-02f-244：解析无符号十进制串；非法返回 -1
function driver_parse_u32_cstr(s: *u8): i64 {
  if (s == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    if (s[0] == 0) {
      return 0 - 1;
    }
    let n: i64 = 0;
    let i: i32 = 0;
    while (i < 20) {
      let c: u8 = s[i];
      if (c == 0) {
        break;
      }
      if (c < 48) {
        return 0 - 1;
      }
      if (c > 57) {
        return 0 - 1;
      }
      let dig: i32 = (c as i32) - 48;
      n = n * 10 + (dig as i64);
      i = i + 1;
    }
    if (i == 0) {
      return 0 - 1;
    }
    return n;
  }
  return 0 - 1;
}

// G-02f-244：默认 512MiB；SHUX_STACK_LIMIT_MB 在 [64,8192] 时覆盖
#[no_mangle]
function driver_stack_limit_want_bytes(): i64 {
  let def: i64 = 536870912;
  unsafe {
    let e: *u8 = getenv("SHUX_STACK_LIMIT_MB");
    if (e == 0 as *u8) {
      return def;
    }
    if (e[0] == 0) {
      return def;
    }
    let mb: i64 = driver_parse_u32_cstr(e);
    if (mb < 64) {
      return def;
    }
    if (mb > 8192) {
      return def;
    }
    return mb * 1048576;
  }
  return def;
}

#[no_mangle]
function driver_bump_stack_limit(): void {
  let want: i64 = driver_stack_limit_want_bytes();
  unsafe {
    driver_bump_stack_limit_to_impl(want);
  }
}

/* ---- G-02f-57：argv -D/-target defines 收集 ---- */

#[no_mangle]
function driver_argv_collect_defines(argc: i32, argv: *u8, defines: *u8, max_defines: i32): i32 {
  if (argv == 0 as *u8) {
    return 0;
  }
  if (defines == 0 as *u8) {
    return 0;
  }
  if (max_defines <= 0) {
    return 0;
  }
  if (argc <= 0) {
    return 0;
  }
  unsafe {
    return driver_argv_collect_defines_impl(argc, argv, defines, max_defines);
  }
  return 0;
}


/* ---- G-02f-83 / G-02f-243：entry_source_len_i32 / scan_top_level_import pure ---- */

// G-02f-243：size_t 全局 → i32 饱和（>0x7fffffff → INT_MAX）；load 可带 SHUX_DEBUG_PIPE 笔记
#[no_mangle]
function driver_pipeline_entry_source_len_i32(): i32 {
  unsafe {
    let len: i64 = driver_pipeline_entry_source_len_load_and_maybe_debug();
    if (len > 2147483647) {
      return 2147483647;
    }
    if (len < 0) {
      return 0;
    }
    return len as i32;
  }
  return 0;
}

// G-02f-243：扫描 `import("` / `= import(`；无 memcmp，按字节 pure
#[no_mangle]
function driver_source_scan_top_level_import(src: *u8, src_len: i64): i32 {
  if (src == 0 as *u8) {
    return 0;
  }
  if (src_len < 8) {
    return 0;
  }
  unsafe {
    let i: i64 = 0;
    while (i + 8 <= src_len) {
      // import("
      if (src[i] == 105) {
        if (src[i + 1] == 109) {
          if (src[i + 2] == 112) {
            if (src[i + 3] == 111) {
              if (src[i + 4] == 114) {
                if (src[i + 5] == 116) {
                  if (src[i + 6] == 40) {
                    if (src[i + 7] == 34) {
                      return 1;
                    }
                  }
                }
              }
            }
          }
        }
      }
      // = import(  （需 9 字节）
      if (i + 9 <= src_len) {
        if (src[i] == 61) {
          if (src[i + 1] == 32) {
            if (src[i + 2] == 105) {
              if (src[i + 3] == 109) {
                if (src[i + 4] == 112) {
                  if (src[i + 5] == 111) {
                    if (src[i + 6] == 114) {
                      if (src[i + 7] == 116) {
                        if (src[i + 8] == 40) {
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
      }
      i = i + 1;
    }
  }
  return 0;
}

/* ---- G-02f-92：ascii_toupper 真迁见文末 ---- */

/* ---- G-02f-94：large_stack trampoline / run_fn 门闩（pthread/fn 指针 🔒）---- */

/* ---- G-02f-104：phase clock 门闩（gettimeofday 🔒）---- */

#[no_mangle]
function compile_phase_now_sec(): f64 {
  unsafe {
    return compile_phase_now_sec_impl();
  }
  return 0.0;
}

#[no_mangle]
function driver_large_stack_thread_trampoline(v: *u8): *u8 {
  if (v == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    return driver_large_stack_thread_trampoline_impl(v);
  }
  return 0 as *u8;
}

#[no_mangle]
function driver_run_fn_on_current_large_stack(fn: *u8, arg: *u8): void {
  if (fn == 0 as *u8) {
    return;
  }
  unsafe {
    driver_run_fn_on_current_large_stack_impl(fn, arg);
  }
}

// G-02f-116：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
function compile_phase_timing_enabled(): i32 {
  unsafe {
    let e: *u8 = getenv("SHUX_COMPILE_PHASE_TIMING");
    if (e != 0) { return 1; }
  }
  return 0;
}

// G-02f-119：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
function driver_ascii_toupper(c: i32): i32 {
  if (c >= 97) {
    if (c <= 122) {
      return c - 32;
    }
  }
  return c;
}
