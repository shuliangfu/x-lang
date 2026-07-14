// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-343/344/345/387/388/400–402/413/414/416：runtime_driver_abi R2 thin full（门闩 thin）。
// 产品 PREFER_X_O：thin.o + full seed rest（-DSHUX_L2_RDABI_THIN_FROM_X）ld -r → runtime_driver_abi.o
// prove IDENTICAL：thin.x ↔ seeds/runtime_driver_abi_thin_surface.from_x.c（公共面 61+；_impl 仍 U / rest）
// Cap residual：*_impl / 静态槽 / path-read / spawn 等 C 尾仍在 full seed rest。
//

export extern "C" function driver_check_only_flag_slot_impl(): *i32;
export extern "C" function driver_check_diag_emitted_flag_slot_impl(): *i32;
export extern "C" function driver_freestanding_flag_slot_impl(): *i32;
export extern "C" function driver_sanitize_address_flag_slot_impl(): *i32;
export extern "C" function driver_fmt_check_only_flag_slot_impl(): *i32;
export extern "C" function driver_x_pipeline_skip_typeck_flag_slot_impl(): *i32;
export extern "C" function driver_x_pipeline_skip_codegen_flag_slot_impl(): *i32;
export extern "C" function driver_skip_codegen_dep_0_flag_slot_impl(): *i32;
export extern "C" function driver_large_stack_thread_flag_slot_impl(): *i32;
export extern "C" function driver_path_read_preprocess_malloc_impl(path: *u8): *u8;
export extern "C" function driver_current_dep_path_store_impl(path: *u8): void;
export extern "C" function driver_current_dep_path_load_impl(): *u8;
export extern "C" function driver_pipeline_entry_source_len_store_impl(len: i64): void;
export extern "C" function driver_target_arg_os_kind_impl(target: *u8): i32;
export extern "C" function driver_pipeline_entry_source_len_i32_impl(): i32;
export extern "C" function driver_sanitize_address_env_enabled_impl(): i32;

// driver_check_quiet_ok_get：weak default 由 seed 提供，强符号由 fmt_check_cmd 提供。
// thin.x 不导出，仅 extern 声明供 driver_print_check_ok 调用。
export extern "C" function driver_check_quiet_ok_get(): i32;

#[no_mangle]
export function driver_check_only_flag_slot(): *i32 {
  unsafe { return driver_check_only_flag_slot_impl(); }
  return 0 as *i32;
}

#[no_mangle]
export function driver_check_diag_emitted_flag_slot(): *i32 {
  unsafe { return driver_check_diag_emitted_flag_slot_impl(); }
  return 0 as *i32;
}

#[no_mangle]
export function driver_freestanding_flag_slot(): *i32 {
  unsafe { return driver_freestanding_flag_slot_impl(); }
  return 0 as *i32;
}

#[no_mangle]
export function driver_sanitize_address_flag_slot(): *i32 {
  unsafe { return driver_sanitize_address_flag_slot_impl(); }
  return 0 as *i32;
}

#[no_mangle]
export function driver_fmt_check_only_flag_slot(): *i32 {
  unsafe { return driver_fmt_check_only_flag_slot_impl(); }
  return 0 as *i32;
}

#[no_mangle]
export function driver_x_pipeline_skip_typeck_flag_slot(): *i32 {
  unsafe { return driver_x_pipeline_skip_typeck_flag_slot_impl(); }
  return 0 as *i32;
}

#[no_mangle]
export function driver_x_pipeline_skip_codegen_flag_slot(): *i32 {
  unsafe { return driver_x_pipeline_skip_codegen_flag_slot_impl(); }
  return 0 as *i32;
}

#[no_mangle]
export function driver_skip_codegen_dep_0_flag_slot(): *i32 {
  unsafe { return driver_skip_codegen_dep_0_flag_slot_impl(); }
  return 0 as *i32;
}

#[no_mangle]
export function driver_large_stack_thread_flag_slot(): *i32 {
  unsafe { return driver_large_stack_thread_flag_slot_impl(); }
  return 0 as *i32;
}

#[no_mangle]
export function driver_path_read_preprocess_malloc(path: *u8): *u8 {
  unsafe { return driver_path_read_preprocess_malloc_impl(path); }
  return 0 as *u8;
}

#[no_mangle]
export function driver_fmt_check_only_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_fmt_check_only_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
export function driver_large_stack_thread_mark(on: i32): void {
  unsafe {
    let p: *i32 = driver_large_stack_thread_flag_slot();
    p[0] = on;
  }
}

#[no_mangle]
export function driver_is_large_stack_thread(): i32 {
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
export function driver_check_only_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_check_only_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
export function driver_skip_codegen_dep_0_get(): i32 {
  unsafe {
    let p: *i32 = driver_skip_codegen_dep_0_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
export function driver_x_pipeline_skip_typeck_get(): i32 {
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
export function driver_freestanding_get(): i32 {
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
export function driver_check_only_get(): i32 {
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
export function driver_set_current_dep_path_for_codegen(path: *u8): void {
  unsafe {
    driver_current_dep_path_store_impl(path);
  }
}

#[no_mangle]
export function driver_current_dep_path_store(path: *u8): void {
  unsafe {
    driver_current_dep_path_store_impl(path);
  }
}

#[no_mangle]
export function driver_current_dep_path_load(): *u8 {
  unsafe {
    return driver_current_dep_path_load_impl();
  }
  return 0 as *u8;
}

#[no_mangle]
export function driver_pipeline_entry_source_len_store(len: i64): void {
  unsafe {
    driver_pipeline_entry_source_len_store_impl(len);
  }
}

#[no_mangle]
export function driver_target_arg_os_kind(target: *u8): i32 {
  unsafe {
    return driver_target_arg_os_kind_impl(target);
  }
  return 0;
}

#[no_mangle]
export function driver_x_pipeline_skip_typeck_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_x_pipeline_skip_typeck_flag_slot();
    p[0] = v;
  }
}

// driver_check_quiet_ok_get：weak default 由 seed 提供（fmt_check_cmd 强符号覆盖）。
// thin.x 不导出，避免与 fmt_check_cmd_thin.x 的强符号冲突。

#[no_mangle]
export function driver_x_pipeline_skip_codegen_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_x_pipeline_skip_codegen_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
export function driver_sanitize_address_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_sanitize_address_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
export function driver_x_pipeline_skip_codegen_get(): i32 {
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
export function driver_skip_codegen_dep_0_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_skip_codegen_dep_0_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
export function driver_freestanding_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_freestanding_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
export function driver_check_diag_emitted_note(): void {
  unsafe {
    let p: *i32 = driver_check_diag_emitted_flag_slot();
    p[0] = 1;
  }
}

#[no_mangle]
export function driver_check_diag_emitted_reset(): void {
  unsafe {
    let p: *i32 = driver_check_diag_emitted_flag_slot();
    p[0] = 0;
  }
}

#[no_mangle]
export function driver_fmt_check_only_get(): i32 {
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
export function driver_check_diag_emitted_get(): i32 {
  unsafe {
    let p: *i32 = driver_check_diag_emitted_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

// ---- G-02f-343 gates (direct _impl; seed rest keeps full logic wrappers optional) ----
export extern "C" function driver_print_check_ok_impl(input_path: *u8): void;
export extern "C" function compile_phase_now_sec_impl(): f64;
export extern "C" function driver_call_fn_void_arg_impl(fn: *u8, arg: *u8): void;

#[no_mangle]
export function driver_print_check_ok(input_path: *u8): void {
  unsafe {
    if (driver_check_quiet_ok_get() != 0) {
      return;
    }
    driver_print_check_ok_impl(input_path);
  }
}

#[no_mangle]
export function compile_phase_now_sec(): f64 {
  unsafe {
    return compile_phase_now_sec_impl();
  }
  return 0.0;
}

#[no_mangle]
export function driver_run_fn_on_current_large_stack(fn: *u8, arg: *u8): void {
  unsafe {
    driver_call_fn_void_arg_impl(fn, arg);
  }
}

// ---- G-02f-344：timing 全套 ----
export extern "C" function driver_compile_phase_timing_begin_impl(phase: i32): void;
export extern "C" function driver_compile_phase_timing_end_impl(phase: i32): void;
export extern "C" function driver_compile_phase_timing_flush_impl(): void;
export extern "C" function driver_compile_phase_timing_enabled_impl(): i32;

#[no_mangle]
export function driver_compile_phase_index_ok(phase: i32): i32 {
  if (phase < 0) {
    return 0;
  }
  if (phase >= 3) {
    return 0;
  }
  return 1;
}

#[no_mangle]
export function driver_compile_phase_timing_enabled(): i32 {
  unsafe {
    return driver_compile_phase_timing_enabled_impl();
  }
  return 0;
}

#[no_mangle]
export function driver_compile_phase_timing_begin(phase: i32): void {
  unsafe {
    if (driver_compile_phase_timing_enabled_impl() == 0) {
      return;
    }
    if (driver_compile_phase_index_ok(phase) == 0) {
      return;
    }
    driver_compile_phase_timing_begin_impl(phase);
  }
}

#[no_mangle]
export function driver_compile_phase_timing_end(phase: i32): void {
  unsafe {
    if (driver_compile_phase_timing_enabled_impl() == 0) {
      return;
    }
    if (driver_compile_phase_index_ok(phase) == 0) {
      return;
    }
    driver_compile_phase_timing_end_impl(phase);
  }
}

#[no_mangle]
export function driver_compile_phase_timing_flush(): void {
  unsafe {
    if (driver_compile_phase_timing_enabled_impl() == 0) {
      return;
    }
    driver_compile_phase_timing_flush_impl();
  }
}

// ---- G-02f-345：ascii_toupper / typeck_skip / sanitize_get ----
// -E：嵌套 if 会丢整函数体，用早退扁平控制流
#[no_mangle]
export function driver_ascii_toupper(c: i32): i32 {
  if (c < 97) {
    return c;
  }
  if (c > 122) {
    return c;
  }
  return c - 32;
}

#[no_mangle]
export function driver_typeck_skip_large_entry(): i32 {
  unsafe {
    let len: i32 = driver_pipeline_entry_source_len_i32_impl();
    if (len > 150000) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
export function driver_sanitize_address_get(): i32 {
  unsafe {
    let p: *i32 = driver_sanitize_address_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return driver_sanitize_address_env_enabled_impl();
  }
  return 0;
}

// ---- G-02f-387：env flag getters → seed impl（-E 勿写 getenv 字符串）----
export extern "C" function driver_typeck_force_c_enabled_impl(): i32;
export extern "C" function driver_asm_build_skip_typeck_impl(): i32;
export extern "C" function driver_asm_entry_emit_heavy_impl(): i32;
export extern "C" function driver_pipeline_no_large_stack_env_impl(): i32;

#[no_mangle]
export function driver_typeck_force_c_enabled(): i32 {
  unsafe {
    return driver_typeck_force_c_enabled_impl();
  }
  return 0;
}

#[no_mangle]
export function driver_asm_build_skip_typeck(): i32 {
  unsafe {
    return driver_asm_build_skip_typeck_impl();
  }
  return 0;
}

#[no_mangle]
export function driver_asm_entry_emit_heavy(): i32 {
  unsafe {
    return driver_asm_entry_emit_heavy_impl();
  }
  return 0;
}

#[no_mangle]
export function driver_pipeline_no_large_stack_env(): i32 {
  unsafe {
    return driver_pipeline_no_large_stack_env_impl();
  }
  return 0;
}

// ---- G-02f-388：module_only / parse_metric_only / entry_source_len_i32 → seed impl ----
export extern "C" function driver_asm_entry_module_only_from_env_impl(): i32;
export extern "C" function driver_asm_parse_metric_only_from_env_impl(): i32;

#[no_mangle]
export function driver_asm_entry_module_only_from_env(): i32 {
  unsafe {
    return driver_asm_entry_module_only_from_env_impl();
  }
  return 0;
}

#[no_mangle]
export function driver_asm_parse_metric_only_from_env(): i32 {
  unsafe {
    return driver_asm_parse_metric_only_from_env_impl();
  }
  return 0;
}

#[no_mangle]
export function driver_pipeline_entry_source_len_i32(): i32 {
  unsafe {
    return driver_pipeline_entry_source_len_i32_impl();
  }
  return 0;
}

// ---- G-02f-400：defines_set_at / stack_limit_want / path_last_preprocess_len → seed impl ----
export extern "C" function driver_defines_set_at_impl(defines: *u8, i: i32, s: *u8): void;
export extern "C" function driver_stack_limit_want_bytes_impl(): i64;
export extern "C" function driver_path_last_preprocess_len_impl(): i64;

#[no_mangle]
export function driver_defines_set_at(defines: *u8, i: i32, s: *u8): void {
  unsafe {
    driver_defines_set_at_impl(defines, i, s);
  }
}

#[no_mangle]
export function driver_stack_limit_want_bytes(): i64 {
  unsafe {
    return driver_stack_limit_want_bytes_impl();
  }
  return 0;
}

#[no_mangle]
export function driver_path_last_preprocess_len(): i64 {
  unsafe {
    return driver_path_last_preprocess_len_impl();
  }
  return 0;
}

// ---- G-02f-402：bump_stack / set_entry_len / phase_timing / os_define_lit ----
export extern "C" function driver_bump_stack_limit_to_impl(want_bytes: i64): void;
export extern "C" function compile_phase_timing_enabled_impl(): i32;
export extern "C" function driver_os_define_lit_impl(kind: i32): *u8;

#[no_mangle]
export function driver_bump_stack_limit(): void {
  unsafe {
    driver_bump_stack_limit_to_impl(driver_stack_limit_want_bytes_impl());
  }
}

#[no_mangle]
export function driver_set_pipeline_entry_source_len(len: i64): void {
  unsafe {
    driver_pipeline_entry_source_len_store_impl(len);
  }
}

#[no_mangle]
export function compile_phase_timing_enabled(): i32 {
  unsafe {
    return compile_phase_timing_enabled_impl();
  }
  return 0;
}

#[no_mangle]
export function driver_os_define_lit(kind: i32): *u8 {
  unsafe {
    return driver_os_define_lit_impl(kind);
  }
  return 0 as *u8;
}

// ---- G-02f-413：fail_code / smoke / peek / get_dep / argv_defines → seed impl ----
export extern "C" function driver_pipeline_fail_code_impl(rc: i32, path: *u8): void;
export extern "C" function driver_print_x_smoke_summary_impl(module: *u8, codegen_len: i64): void;
export extern "C" function driver_peek_source_file_impl(path: *u8, content: *u8, cap: i64): i32;
export extern "C" function driver_get_current_dep_path_for_codegen_impl(): *u8;
export extern "C" function driver_argv_collect_defines_impl(argc: i32, argv: *u8, defines: *u8, max_defines: i32): i32;

#[no_mangle]
export function driver_pipeline_fail_code(rc: i32, path: *u8): void {
  unsafe {
    driver_pipeline_fail_code_impl(rc, path);
  }
}

#[no_mangle]
export function driver_print_x_smoke_summary(module: *u8, codegen_len: i64): void {
  unsafe {
    driver_print_x_smoke_summary_impl(module, codegen_len);
  }
}

#[no_mangle]
export function driver_peek_source_file(path: *u8, content: *u8, cap: i64): i32 {
  unsafe {
    return driver_peek_source_file_impl(path, content, cap);
  }
  return 0 - 1;
}

#[no_mangle]
export function driver_get_current_dep_path_for_codegen(): *u8 {
  unsafe {
    return driver_get_current_dep_path_for_codegen_impl();
  }
  return 0 as *u8;
}

#[no_mangle]
export function driver_argv_collect_defines(argc: i32, argv: *u8, defines: *u8, max_defines: i32): i32 {
  unsafe {
    return driver_argv_collect_defines_impl(argc, argv, defines, max_defines);
  }
  return 0;
}

// ---- G-02f-414：import scan + large-stack entry → seed impl ----
export extern "C" function driver_source_scan_top_level_import_impl(src: *u8, src_len: i64): i32;
export extern "C" function driver_source_has_top_level_import_impl(src: *u8, src_len: i64): i32;
export extern "C" function driver_source_has_top_level_import_path_impl(path: *u8): i32;
export extern "C" function driver_run_thread_on_large_stack_impl(fn: *u8, arg: *u8): void;
export extern "C" function driver_run_on_large_stack_pthread_impl(fn: *u8, arg: *u8): void;

#[no_mangle]
export function driver_source_scan_top_level_import(src: *u8, src_len: i64): i32 {
  unsafe {
    return driver_source_scan_top_level_import_impl(src, src_len);
  }
  return 0;
}

#[no_mangle]
export function driver_source_has_top_level_import(src: *u8, src_len: i64): i32 {
  unsafe {
    return driver_source_has_top_level_import_impl(src, src_len);
  }
  return 0;
}

#[no_mangle]
export function driver_source_has_top_level_import_path(path: *u8): i32 {
  unsafe {
    return driver_source_has_top_level_import_path_impl(path);
  }
  return 0;
}

#[no_mangle]
export function driver_run_thread_on_large_stack(fn: *u8, arg: *u8): void {
  unsafe {
    driver_run_thread_on_large_stack_impl(fn, arg);
  }
}

#[no_mangle]
export function driver_run_on_large_stack_pthread(fn: *u8, arg: *u8): void {
  unsafe {
    driver_run_on_large_stack_pthread_impl(fn, arg);
  }
}

// ---- G-02f-416：entry_source_len load/query → seed impl ----
export extern "C" function driver_pipeline_entry_source_len_load_and_maybe_debug_impl(): i64;
export extern "C" function driver_pipeline_entry_source_len_impl(): i64;

#[no_mangle]
export function driver_pipeline_entry_source_len_load_and_maybe_debug(): i64 {
  unsafe {
    return driver_pipeline_entry_source_len_load_and_maybe_debug_impl();
  }
  return 0;
}

#[no_mangle]
export function driver_pipeline_entry_source_len(): i64 {
  unsafe {
    return driver_pipeline_entry_source_len_impl();
  }
  return 0;
}
