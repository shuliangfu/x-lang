// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-343/344/345/387/388/400–402：runtime_driver_abi L2 thin（49 门闩）。
// PREFER_X_O：thin.o + seed-rest（-DSHUX_L2_RDABI_THIN_FROM_X）ld -r → runtime_driver_abi.o
//

extern "C" function driver_check_only_flag_slot(): *i32;
extern "C" function driver_check_diag_emitted_flag_slot(): *i32;
extern "C" function driver_freestanding_flag_slot(): *i32;
extern "C" function driver_sanitize_address_flag_slot(): *i32;
extern "C" function driver_fmt_check_only_flag_slot(): *i32;
extern "C" function driver_x_pipeline_skip_typeck_flag_slot(): *i32;
extern "C" function driver_x_pipeline_skip_codegen_flag_slot(): *i32;
extern "C" function driver_skip_codegen_dep_0_flag_slot(): *i32;
extern "C" function driver_large_stack_thread_flag_slot(): *i32;
extern "C" function driver_current_dep_path_store_impl(path: *u8): void;
extern "C" function driver_current_dep_path_load_impl(): *u8;
extern "C" function driver_pipeline_entry_source_len_store_impl(len: i64): void;
extern "C" function driver_target_arg_os_kind_impl(target: *u8): i32;
extern "C" function driver_pipeline_entry_source_len_i32_impl(): i32;
extern "C" function driver_sanitize_address_env_enabled_impl(): i32;

#[no_mangle]
function driver_fmt_check_only_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_fmt_check_only_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
function driver_large_stack_thread_mark(on: i32): void {
  unsafe {
    let p: *i32 = driver_large_stack_thread_flag_slot();
    p[0] = on;
  }
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
function driver_check_only_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_check_only_flag_slot();
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
function driver_set_current_dep_path_for_codegen(path: *u8): void {
  unsafe {
    driver_current_dep_path_store_impl(path);
  }
}

#[no_mangle]
function driver_current_dep_path_store(path: *u8): void {
  unsafe {
    driver_current_dep_path_store_impl(path);
  }
}

#[no_mangle]
function driver_current_dep_path_load(): *u8 {
  unsafe {
    return driver_current_dep_path_load_impl();
  }
  return 0 as *u8;
}

#[no_mangle]
function driver_pipeline_entry_source_len_store(len: i64): void {
  unsafe {
    driver_pipeline_entry_source_len_store_impl(len);
  }
}

#[no_mangle]
function driver_target_arg_os_kind(target: *u8): i32 {
  unsafe {
    return driver_target_arg_os_kind_impl(target);
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
function driver_check_quiet_ok_get(): i32 {
  return 1;
}

#[no_mangle]
function driver_x_pipeline_skip_codegen_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_x_pipeline_skip_codegen_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
function driver_sanitize_address_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_sanitize_address_flag_slot();
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
function driver_skip_codegen_dep_0_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_skip_codegen_dep_0_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
function driver_freestanding_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_freestanding_flag_slot();
    p[0] = v;
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
function driver_check_diag_emitted_reset(): void {
  unsafe {
    let p: *i32 = driver_check_diag_emitted_flag_slot();
    p[0] = 0;
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

// ---- G-02f-343 gates (direct _impl; seed rest keeps full logic wrappers optional) ----
extern "C" function driver_print_check_ok_impl(input_path: *u8): void;
extern "C" function compile_phase_now_sec_impl(): f64;
extern "C" function driver_call_fn_void_arg_impl(fn: *u8, arg: *u8): void;

#[no_mangle]
function driver_print_check_ok(input_path: *u8): void {
  unsafe {
    if (driver_check_quiet_ok_get() != 0) {
      return;
    }
    driver_print_check_ok_impl(input_path);
  }
}

#[no_mangle]
function compile_phase_now_sec(): f64 {
  unsafe {
    return compile_phase_now_sec_impl();
  }
  return 0.0;
}

#[no_mangle]
function driver_run_fn_on_current_large_stack(fn: *u8, arg: *u8): void {
  unsafe {
    driver_call_fn_void_arg_impl(fn, arg);
  }
}

// ---- G-02f-344：timing 全套 ----
extern "C" function driver_compile_phase_timing_begin_impl(phase: i32): void;
extern "C" function driver_compile_phase_timing_end_impl(phase: i32): void;
extern "C" function driver_compile_phase_timing_flush_impl(): void;
extern "C" function driver_compile_phase_timing_enabled_impl(): i32;

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
function driver_compile_phase_timing_enabled(): i32 {
  unsafe {
    return driver_compile_phase_timing_enabled_impl();
  }
  return 0;
}

#[no_mangle]
function driver_compile_phase_timing_begin(phase: i32): void {
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
function driver_compile_phase_timing_end(phase: i32): void {
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
function driver_compile_phase_timing_flush(): void {
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
function driver_ascii_toupper(c: i32): i32 {
  if (c < 97) {
    return c;
  }
  if (c > 122) {
    return c;
  }
  return c - 32;
}

#[no_mangle]
function driver_typeck_skip_large_entry(): i32 {
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
function driver_sanitize_address_get(): i32 {
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
extern "C" function driver_typeck_force_c_enabled_impl(): i32;
extern "C" function driver_asm_build_skip_typeck_impl(): i32;
extern "C" function driver_asm_entry_emit_heavy_impl(): i32;
extern "C" function driver_pipeline_no_large_stack_env_impl(): i32;

#[no_mangle]
function driver_typeck_force_c_enabled(): i32 {
  unsafe {
    return driver_typeck_force_c_enabled_impl();
  }
  return 0;
}

#[no_mangle]
function driver_asm_build_skip_typeck(): i32 {
  unsafe {
    return driver_asm_build_skip_typeck_impl();
  }
  return 0;
}

#[no_mangle]
function driver_asm_entry_emit_heavy(): i32 {
  unsafe {
    return driver_asm_entry_emit_heavy_impl();
  }
  return 0;
}

#[no_mangle]
function driver_pipeline_no_large_stack_env(): i32 {
  unsafe {
    return driver_pipeline_no_large_stack_env_impl();
  }
  return 0;
}

// ---- G-02f-388：module_only / parse_metric_only / entry_source_len_i32 → seed impl ----
extern "C" function driver_asm_entry_module_only_from_env_impl(): i32;
extern "C" function driver_asm_parse_metric_only_from_env_impl(): i32;

#[no_mangle]
function driver_asm_entry_module_only_from_env(): i32 {
  unsafe {
    return driver_asm_entry_module_only_from_env_impl();
  }
  return 0;
}

#[no_mangle]
function driver_asm_parse_metric_only_from_env(): i32 {
  unsafe {
    return driver_asm_parse_metric_only_from_env_impl();
  }
  return 0;
}

#[no_mangle]
function driver_pipeline_entry_source_len_i32(): i32 {
  unsafe {
    return driver_pipeline_entry_source_len_i32_impl();
  }
  return 0;
}

// ---- G-02f-400：defines_set_at / stack_limit_want / path_last_preprocess_len → seed impl ----
extern "C" function driver_defines_set_at_impl(defines: *u8, i: i32, s: *u8): void;
extern "C" function driver_stack_limit_want_bytes_impl(): i64;
extern "C" function driver_path_last_preprocess_len_impl(): i64;

#[no_mangle]
function driver_defines_set_at(defines: *u8, i: i32, s: *u8): void {
  unsafe {
    driver_defines_set_at_impl(defines, i, s);
  }
}

#[no_mangle]
function driver_stack_limit_want_bytes(): i64 {
  unsafe {
    return driver_stack_limit_want_bytes_impl();
  }
  return 0;
}

#[no_mangle]
function driver_path_last_preprocess_len(): i64 {
  unsafe {
    return driver_path_last_preprocess_len_impl();
  }
  return 0;
}

// ---- G-02f-402：bump_stack / set_entry_len / phase_timing / os_define_lit ----
extern "C" function driver_bump_stack_limit_to_impl(want_bytes: i64): void;
extern "C" function compile_phase_timing_enabled_impl(): i32;
extern "C" function driver_os_define_lit_impl(kind: i32): *u8;

#[no_mangle]
function driver_bump_stack_limit(): void {
  unsafe {
    driver_bump_stack_limit_to_impl(driver_stack_limit_want_bytes_impl());
  }
}

#[no_mangle]
function driver_set_pipeline_entry_source_len(len: i64): void {
  unsafe {
    driver_pipeline_entry_source_len_store_impl(len);
  }
}

#[no_mangle]
function compile_phase_timing_enabled(): i32 {
  unsafe {
    return compile_phase_timing_enabled_impl();
  }
  return 0;
}

#[no_mangle]
function driver_os_define_lit(kind: i32): *u8 {
  unsafe {
    return driver_os_define_lit_impl(kind);
  }
  return 0 as *u8;
}
