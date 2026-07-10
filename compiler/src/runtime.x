// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-14/71：runtime 产品源 seeds/runtime.from_x.c + 真迁 .x 门闩。
// G-02f-71：driver compile/run 薄封装门闩（argv set/apply、run_*、fmt/test）。
// 产品：cc seeds/runtime.from_x.c + RUNTIME_DRIVER_NO_C_CFLAGS → src/runtime_driver_no_c.o
// C 尾：argv 解析循环、#if 变体、大 driver 路径、syscall/fs。

extern "C" function run_compiler_c_impl(argc: i32, argv: *u8): i32;
extern "C" function driver_run_x_emit_c_set_path_impl(path: *u8, path_len: i32): i32;
extern "C" function driver_run_x_emit_c_set_lib_impl(i: i32, buf: *u8, len: i32): i32;
extern "C" function driver_run_x_emit_c_set_n_lib_roots_impl(n: i32): i32;
extern "C" function driver_run_x_emit_c_set_emit_extern_impl(v: i32): i32;
extern "C" function driver_fs_open_read_path_impl(path: *u8, path_len: i32): i32;
extern "C" function driver_asm_output_want_exe_impl(path: *u8): i32;
extern "C" function driver_run_asm_backend_c_impl(input_path: *u8, out_path: *u8, lib_key: *u8, target: *u8, argc: i32, argv: *u8): i32;
extern "C" function driver_run_emit_c_path_c_impl(input_path: *u8, out_path: *u8, lib_key: *u8, target: *u8, opt_level: *u8, use_lto: i32, argc: i32, argv: *u8): i32;
extern "C" function driver_compile_state_free_c_impl(state: *u8): void;
extern "C" function cfg_sync_compile_target_from_state_c_impl(state: *u8): void;
extern "C" function driver_compile_ensure_default_lib_c_impl(key: *u8): void;
extern "C" function driver_compile_parse_argv_init_c_impl(state: *u8): void;
extern "C" function driver_compile_append_lib_root_c_impl(state: *u8, path: *u8, len: i32): void;
extern "C" function driver_compile_argv_apply_minus_o_next_c_impl(state: *u8, argc: i32, argv_opaque: *u8, i: i32): void;
extern "C" function driver_compile_argv_apply_minus_L_next_c_impl(state: *u8, argc: i32, argv_opaque: *u8, i: i32, arg_buf: *u8, arg_cap: i32): void;
extern "C" function driver_compile_argv_apply_minus_O_next_c_impl(state: *u8, argc: i32, argv_opaque: *u8, i: i32): void;
extern "C" function driver_compile_argv_set_use_lto_c_impl(state: *u8): void;
extern "C" function driver_compile_argv_set_use_freestanding_c_impl(state: *u8): void;
extern "C" function driver_compile_argv_set_legacy_f32_abi_c_impl(): void;
extern "C" function driver_compile_argv_set_sanitize_address_c_impl(): void;
extern "C" function driver_compile_argv_apply_backend_next_c_impl(state: *u8, argc: i32, argv_opaque: *u8, i: i32, arg_buf: *u8, arg_cap: i32): void;
extern "C" function driver_compile_argv_apply_target_next_c_impl(state: *u8, argc: i32, argv_opaque: *u8, i: i32): void;
extern "C" function driver_compile_argv_apply_target_cpu_next_c_impl(state: *u8, argc: i32, argv_opaque: *u8, i: i32): void;
extern "C" function driver_compile_argv_set_print_target_cpu_c_impl(state: *u8): void;
extern "C" function driver_print_target_cpu_features_c_impl(features: i32): i32;
extern "C" function driver_compile_resolve_target_cpu_c_impl(state: *u8): void;
extern "C" function driver_run_compiler_full_impl(argc: i32, argv: *u8): i32;
extern "C" function driver_run_test_impl(argc: i32, argv: *u8): i32;
extern "C" function driver_fmt_report_no_files_impl(): i32;

/* ---- G-02f-71：driver compile/run 薄门闩 ---- */

#[no_mangle]
function run_compiler_c(argc: i32, argv: *u8): i32 {
  unsafe {
    return run_compiler_c_impl(argc, argv);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_run_x_emit_c_set_path(path: *u8, path_len: i32): i32 {
  unsafe {
    return driver_run_x_emit_c_set_path_impl(path, path_len);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_run_x_emit_c_set_lib(i: i32, buf: *u8, len: i32): i32 {
  unsafe {
    return driver_run_x_emit_c_set_lib_impl(i, buf, len);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_run_x_emit_c_set_n_lib_roots(n: i32): i32 {
  unsafe {
    return driver_run_x_emit_c_set_n_lib_roots_impl(n);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_run_x_emit_c_set_emit_extern(v: i32): i32 {
  unsafe {
    return driver_run_x_emit_c_set_emit_extern_impl(v);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_fs_open_read_path(path: *u8, path_len: i32): i32 {
  unsafe {
    return driver_fs_open_read_path_impl(path, path_len);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_asm_output_want_exe(path: *u8): i32 {
  unsafe {
    return driver_asm_output_want_exe_impl(path);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_run_asm_backend_c(input_path: *u8, out_path: *u8, lib_key: *u8, target: *u8, argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_asm_backend_c_impl(input_path, out_path, lib_key, target, argc, argv);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_run_emit_c_path_c(input_path: *u8, out_path: *u8, lib_key: *u8, target: *u8, opt_level: *u8, use_lto: i32, argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_emit_c_path_c_impl(input_path, out_path, lib_key, target, opt_level, use_lto, argc, argv);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_compile_state_free_c(state: *u8): void {
  unsafe {
    driver_compile_state_free_c_impl(state);
  }
}

#[no_mangle]
function cfg_sync_compile_target_from_state_c(state: *u8): void {
  unsafe {
    cfg_sync_compile_target_from_state_c_impl(state);
  }
}

#[no_mangle]
function driver_compile_ensure_default_lib_c(key: *u8): void {
  unsafe {
    driver_compile_ensure_default_lib_c_impl(key);
  }
}

#[no_mangle]
function driver_compile_parse_argv_init_c(state: *u8): void {
  unsafe {
    driver_compile_parse_argv_init_c_impl(state);
  }
}

#[no_mangle]
function driver_compile_append_lib_root_c(state: *u8, path: *u8, len: i32): void {
  unsafe {
    driver_compile_append_lib_root_c_impl(state, path, len);
  }
}

#[no_mangle]
function driver_compile_argv_apply_minus_o_next_c(state: *u8, argc: i32, argv_opaque: *u8, i: i32): void {
  unsafe {
    driver_compile_argv_apply_minus_o_next_c_impl(state, argc, argv_opaque, i);
  }
}

#[no_mangle]
function driver_compile_argv_apply_minus_L_next_c(state: *u8, argc: i32, argv_opaque: *u8, i: i32, arg_buf: *u8, arg_cap: i32): void {
  unsafe {
    driver_compile_argv_apply_minus_L_next_c_impl(state, argc, argv_opaque, i, arg_buf, arg_cap);
  }
}

#[no_mangle]
function driver_compile_argv_apply_minus_O_next_c(state: *u8, argc: i32, argv_opaque: *u8, i: i32): void {
  unsafe {
    driver_compile_argv_apply_minus_O_next_c_impl(state, argc, argv_opaque, i);
  }
}

#[no_mangle]
function driver_compile_argv_set_use_lto_c(state: *u8): void {
  unsafe {
    driver_compile_argv_set_use_lto_c_impl(state);
  }
}

#[no_mangle]
function driver_compile_argv_set_use_freestanding_c(state: *u8): void {
  unsafe {
    driver_compile_argv_set_use_freestanding_c_impl(state);
  }
}

#[no_mangle]
function driver_compile_argv_set_legacy_f32_abi_c(): void {
  unsafe {
    driver_compile_argv_set_legacy_f32_abi_c_impl();
  }
}

#[no_mangle]
function driver_compile_argv_set_sanitize_address_c(): void {
  unsafe {
    driver_compile_argv_set_sanitize_address_c_impl();
  }
}

#[no_mangle]
function driver_compile_argv_apply_backend_next_c(state: *u8, argc: i32, argv_opaque: *u8, i: i32, arg_buf: *u8, arg_cap: i32): void {
  unsafe {
    driver_compile_argv_apply_backend_next_c_impl(state, argc, argv_opaque, i, arg_buf, arg_cap);
  }
}

#[no_mangle]
function driver_compile_argv_apply_target_next_c(state: *u8, argc: i32, argv_opaque: *u8, i: i32): void {
  unsafe {
    driver_compile_argv_apply_target_next_c_impl(state, argc, argv_opaque, i);
  }
}

#[no_mangle]
function driver_compile_argv_apply_target_cpu_next_c(state: *u8, argc: i32, argv_opaque: *u8, i: i32): void {
  unsafe {
    driver_compile_argv_apply_target_cpu_next_c_impl(state, argc, argv_opaque, i);
  }
}

#[no_mangle]
function driver_compile_argv_set_print_target_cpu_c(state: *u8): void {
  unsafe {
    driver_compile_argv_set_print_target_cpu_c_impl(state);
  }
}

#[no_mangle]
function driver_print_target_cpu_features_c(features: i32): i32 {
  unsafe {
    return driver_print_target_cpu_features_c_impl(features);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_compile_resolve_target_cpu_c(state: *u8): void {
  unsafe {
    driver_compile_resolve_target_cpu_c_impl(state);
  }
}

#[no_mangle]
function driver_run_compiler_full(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_compiler_full_impl(argc, argv);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_run_test(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_test_impl(argc, argv);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_fmt_report_no_files(): i32 {
  unsafe {
    return driver_fmt_report_no_files_impl();
  }
  return 0 - 1;
}
