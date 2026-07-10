// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-29/41/45/46/47：真迁 .x — driver flag/env/skip/dep_path/print + phase timing 门闩。
// 产品：./shux-c -E → seeds/runtime_driver_abi.from_x.c（+ C 尾 + getenv/slot 抛光）。
// C 尾：flag/len/path 槽、大栈 pthread、gettimeofday 累加、diag format。
// G-02f-47：+ compile_phase_timing enabled/begin/end/flush（计时本体 C）。
// 注意：set 侧禁止 if/else 写 *p → 直接 p[0]=v。

extern "C" function getenv(name: *u8): *u8;
extern "C" function driver_check_only_flag_slot(): *i32;
extern "C" function driver_check_diag_emitted_flag_slot(): *i32;
extern "C" function driver_freestanding_flag_slot(): *i32;
extern "C" function driver_sanitize_address_flag_slot(): *i32;
extern "C" function driver_fmt_check_only_flag_slot(): *i32;
extern "C" function driver_x_pipeline_skip_typeck_flag_slot(): *i32;
extern "C" function driver_x_pipeline_skip_codegen_flag_slot(): *i32;
extern "C" function driver_skip_codegen_dep_0_flag_slot(): *i32;
extern "C" function driver_pipeline_entry_source_len_i32(): i32;
extern "C" function driver_large_stack_thread_flag_slot(): *i32;
extern "C" function driver_current_dep_path_store(path: *u8): void;
extern "C" function driver_current_dep_path_load(): *u8;
extern "C" function driver_print_check_ok_impl(input_path: *u8): void;
extern "C" function driver_compile_phase_timing_begin_impl(phase: i32): void;
extern "C" function driver_compile_phase_timing_end_impl(phase: i32): void;
extern "C" function driver_compile_phase_timing_flush_impl(): void;

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

/* ---- G-02f-47：compile phase timing 门闩与边界（累加在 C）---- */

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

#[no_mangle]
function driver_compile_phase_timing_begin(phase: i32): void {
  unsafe {
    if (driver_compile_phase_timing_enabled() == 0) {
      return;
    }
    if (phase < 0) {
      return;
    }
    if (phase >= 3) {
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
    if (phase < 0) {
      return;
    }
    if (phase >= 3) {
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
