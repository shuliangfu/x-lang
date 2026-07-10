// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-14/71/72：runtime 产品源 seeds/runtime.from_x.c + 真迁 .x 门闩。
// G-02f-85：smoke_diag / unlink_failed_out / asm direct-import 门闩。
// G-02f-86：explain CLI / errno diag / legacy smoke summary 门闩。
// G-02f-87：argv 令牌/path 后缀纯 helper（drv_eq_* / path_ends / lib_root_usable）门闩。
// G-02f-88：源扫描 content_has_*、core-only deps/imports、check/fmt 薄委托门闩。
// G-02f-90：DCE 回调 / tmp 前缀 / parse fail / lib_roots_from_key / run_test 门闩。
// G-02f-71/72：driver compile/run 薄封装 + main_entry/argv/exec/fmt/大 run_* 门闩。
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

extern "C" function run_compiler_x_path_impl(argc: i32, argv: *u8): i32;
extern "C" function driver_want_asm_emit_to_file_impl(argc: i32, argv: *u8): i32;
extern "C" function driver_exec_compiled_impl(argc: i32, argv_opaque: *u8): i32;
extern "C" function driver_build_build_x_impl(): i32;
extern "C" function driver_fs_open_write_impl(path: *u8, path_len: i32): i32;
extern "C" function driver_source_has_generic_syntax_impl(path: *u8, path_len: i32): i32;
extern "C" function driver_source_has_compound_assign_syntax_impl(path: *u8, path_len: i32): i32;
extern "C" function driver_run_asm_backend_impl(input_path: *u8, out_path: *u8, lib_roots_arr: *u8, n_lib_roots: i32, target: *u8, argc: i32, argv: *u8): i32;
extern "C" function driver_compile_parse_argv_scan_c_impl(argc: i32, argv_opaque: *u8, state: *u8): void;
extern "C" function driver_compile_argv_copy_path_c_impl(state: *u8, arg_buf: *u8, plen: i32): void;
extern "C" function driver_compile_argv_is_help_c_impl(argc: i32, argv_opaque: *u8): i32;
extern "C" function driver_print_usage_c_impl(): void;
extern "C" function driver_argv_parse_x_emit_c_impl(argc: i32, argv: *u8): i32;
extern "C" function driver_run_x_emit_c_impl(): i32;
extern "C" function driver_fmt_one_file_impl(path: *u8, path_len: i32): i32;
extern "C" function main_entry_impl(argc: i32, argv: *u8): i32;

/* ---- G-02f-71：driver compile/run 薄门闩 ---- */


extern "C" function shux_smoke_diag_enabled_impl(): i32;
extern "C" function driver_unlink_failed_output_impl(out_path: *u8): void;
extern "C" function driver_x_emit_asm_direct_import_only_impl(input_path: *u8): i32;
extern "C" function driver_x_emit_asm_dep_parse_skip_typeck_ok_impl(input_path: *u8, dep_path: *u8): i32;


extern "C" function runtime_diag_cli_usage_note_impl(argv0: *u8): void;
extern "C" function runtime_diag_errno_impl(file: *u8, kind: *u8, op: *u8): void;
extern "C" function runtime_diag_errno_path_impl(file: *u8, kind: *u8, op: *u8, path: *u8): void;
extern "C" function runtime_diag_errno_path_pair_impl(file: *u8, kind: *u8, op: *u8, from_path: *u8, to_path: *u8): void;
extern "C" function runtime_try_handle_explain_cli_impl(argc: i32, argv: *u8): i32;
extern "C" function driver_emit_legacy_smoke_summary_stdout_impl(main_name: *u8, main_final_lit: i32, has_main_body: i32): void;
extern "C" function runtime_diag_code_for_kind_impl(kind: *u8): *u8;

extern "C" function driver_lib_root_ptr_usable_impl(p: *u8): i32;
extern "C" function drv_eq_minus_o_impl(buf: *u8, len: i32): i32;
extern "C" function drv_eq_minus_L_impl(buf: *u8, len: i32): i32;
extern "C" function drv_eq_minus_O_impl(buf: *u8, len: i32): i32;
extern "C" function drv_eq_flto_impl(buf: *u8, len: i32): i32;
extern "C" function drv_eq_minus_freestanding_impl(buf: *u8, len: i32): i32;
extern "C" function drv_eq_legacy_f32_abi_impl(buf: *u8, len: i32): i32;
extern "C" function drv_eq_fsanitize_address_impl(buf: *u8, len: i32): i32;
extern "C" function drv_eq_minus_backend_impl(buf: *u8, len: i32): i32;
extern "C" function drv_eq_minus_target_impl(buf: *u8, len: i32): i32;
extern "C" function drv_eq_minus_target_cpu_impl(buf: *u8, len: i32): i32;
extern "C" function drv_eq_print_target_cpu_impl(buf: *u8, len: i32): i32;
extern "C" function drv_eq_asm_word_impl(buf: *u8, len: i32): i32;
extern "C" function drv_eq_c_word_impl(buf: *u8, len: i32): i32;
extern "C" function drv_path_ends_x_impl(buf: *u8, len: i32): i32;
extern "C" function drv_target_has_arm_impl(buf: *u8, len: i32): i32;
extern "C" function driver_argv_has_emit_c_flag_impl(argc: i32, argv: *u8): i32;
extern "C" function driver_argv0_basename_is_impl(argv0: *u8, base: *u8): i32;

extern "C" function content_has_generic_syntax_impl(content: *u8, n: i64): i32;
extern "C" function content_has_compound_assign_syntax_impl(content: *u8, n: i64): i32;
extern "C" function driver_deps_are_std_core_closure_only_impl(dep_paths: *u8, n_deps: i32): i32;
extern "C" function driver_c_mod_imports_are_core_only_impl(mod: *u8): i32;
extern "C" function driver_x_emit_asm_dep_parse_only_ok_impl(input_path: *u8, dep_path: *u8): i32;
extern "C" function driver_check_only_c_typeck_impl(input_path: *u8, src: *u8, lib_roots_arr: *u8, n_lib_roots: i32): i32;
extern "C" function driver_lib_root_default_impl(root_buf: *u8): void;
extern "C" function runtime_test_status_to_rc_impl(script: *u8, st: i32): i32;
extern "C" function runtime_run_compiler_check_c_impl(argc: i32, argv: *u8): i32;
extern "C" function runtime_run_fmt_c_impl(argc: i32, argv: *u8): i32;

extern "C" function shux_get_tmp_prefix_impl(): *u8;
extern "C" function dce_is_func_used_impl(ctx: *u8, mod: *u8, func: *u8): i32;
extern "C" function dce_is_mono_used_impl(ctx: *u8, mod: *u8, k: i32): i32;
extern "C" function dce_is_type_used_impl(ctx: *u8, mod: *u8, type_name: *u8): i32;
extern "C" function runtime_report_precise_parse_failure_if_known_impl(input_path: *u8, src: *u8, src_len: i64): i32;
extern "C" function runtime_run_test_c_impl(argc: i32, argv: *u8): i32;
extern "C" function driver_lib_roots_from_key_impl(lib_key: *u8, out_arr: *u8, bufs: *u8): i32;

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

/* ---- G-02f-72：driver mid gates (argv scan / main_entry / emit / fmt) ---- */

#[no_mangle]
function run_compiler_x_path(argc: i32, argv: *u8): i32 {
  unsafe {
    return run_compiler_x_path_impl(argc, argv);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_want_asm_emit_to_file(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_want_asm_emit_to_file_impl(argc, argv);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_exec_compiled(argc: i32, argv_opaque: *u8): i32 {
  unsafe {
    return driver_exec_compiled_impl(argc, argv_opaque);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_build_build_x(): i32 {
  unsafe {
    return driver_build_build_x_impl();
  }
  return 0 - 1;
}

#[no_mangle]
function driver_fs_open_write(path: *u8, path_len: i32): i32 {
  unsafe {
    return driver_fs_open_write_impl(path, path_len);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_source_has_generic_syntax(path: *u8, path_len: i32): i32 {
  unsafe {
    return driver_source_has_generic_syntax_impl(path, path_len);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_source_has_compound_assign_syntax(path: *u8, path_len: i32): i32 {
  unsafe {
    return driver_source_has_compound_assign_syntax_impl(path, path_len);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_run_asm_backend(input_path: *u8, out_path: *u8, lib_roots_arr: *u8, n_lib_roots: i32, target: *u8, argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_asm_backend_impl(input_path, out_path, lib_roots_arr, n_lib_roots, target, argc, argv);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_compile_parse_argv_scan_c(argc: i32, argv_opaque: *u8, state: *u8): void {
  unsafe {
    driver_compile_parse_argv_scan_c_impl(argc, argv_opaque, state);
  }
}

#[no_mangle]
function driver_compile_argv_copy_path_c(state: *u8, arg_buf: *u8, plen: i32): void {
  unsafe {
    driver_compile_argv_copy_path_c_impl(state, arg_buf, plen);
  }
}

#[no_mangle]
function driver_compile_argv_is_help_c(argc: i32, argv_opaque: *u8): i32 {
  unsafe {
    return driver_compile_argv_is_help_c_impl(argc, argv_opaque);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_print_usage_c(): void {
  unsafe {
    driver_print_usage_c_impl();
  }
}

#[no_mangle]
function driver_argv_parse_x_emit_c(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_argv_parse_x_emit_c_impl(argc, argv);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_run_x_emit_c(): i32 {
  unsafe {
    return driver_run_x_emit_c_impl();
  }
  return 0 - 1;
}

#[no_mangle]
function driver_fmt_one_file(path: *u8, path_len: i32): i32 {
  unsafe {
    return driver_fmt_one_file_impl(path, path_len);
  }
  return 0 - 1;
}

#[no_mangle]
function main_entry(argc: i32, argv: *u8): i32 {
  unsafe {
    return main_entry_impl(argc, argv);
  }
  return 0 - 1;
}


/* ---- G-02f-85：smoke / failed-output unlink / asm path 门闩 ---- */

#[no_mangle]
function shux_smoke_diag_enabled(): i32 {
  unsafe {
    return shux_smoke_diag_enabled_impl();
  }
  return 0;
}

#[no_mangle]
function driver_unlink_failed_output(out_path: *u8): void {
  unsafe {
    driver_unlink_failed_output_impl(out_path);
  }
}

#[no_mangle]
function driver_x_emit_asm_direct_import_only(input_path: *u8): i32 {
  unsafe {
    return driver_x_emit_asm_direct_import_only_impl(input_path);
  }
  return 0;
}

#[no_mangle]
function driver_x_emit_asm_dep_parse_skip_typeck_ok(input_path: *u8, dep_path: *u8): i32 {
  unsafe {
    return driver_x_emit_asm_dep_parse_skip_typeck_ok_impl(input_path, dep_path);
  }
  return 0;
}


/* ---- G-02f-86：explain / errno diag / smoke summary 门闩 ---- */

#[no_mangle]
function runtime_diag_cli_usage_note(argv0: *u8): void {
  unsafe {
    runtime_diag_cli_usage_note_impl(argv0);
  }
}

#[no_mangle]
function runtime_diag_errno(file: *u8, kind: *u8, op: *u8): void {
  unsafe {
    runtime_diag_errno_impl(file, kind, op);
  }
}

#[no_mangle]
function runtime_diag_errno_path(file: *u8, kind: *u8, op: *u8, path: *u8): void {
  unsafe {
    runtime_diag_errno_path_impl(file, kind, op, path);
  }
}

#[no_mangle]
function runtime_diag_errno_path_pair(file: *u8, kind: *u8, op: *u8, from_path: *u8, to_path: *u8): void {
  unsafe {
    runtime_diag_errno_path_pair_impl(file, kind, op, from_path, to_path);
  }
}

#[no_mangle]
function runtime_try_handle_explain_cli(argc: i32, argv: *u8): i32 {
  unsafe {
    return runtime_try_handle_explain_cli_impl(argc, argv);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_emit_legacy_smoke_summary_stdout(main_name: *u8, main_final_lit: i32, has_main_body: i32): void {
  unsafe {
    driver_emit_legacy_smoke_summary_stdout_impl(main_name, main_final_lit, has_main_body);
  }
}

#[no_mangle]
function runtime_diag_code_for_kind(kind: *u8): *u8 {
  unsafe {
    return runtime_diag_code_for_kind_impl(kind);
  }
  return 0 as *u8;
}

/* ---- G-02f-87：argv 令牌 / path 后缀 / lib_root 纯 helper 门闩 ---- */

#[no_mangle]
function driver_lib_root_ptr_usable(p: *u8): i32 {
  unsafe {
    return driver_lib_root_ptr_usable_impl(p);
  }
  return 0;
}

#[no_mangle]
function drv_eq_minus_o(buf: *u8, len: i32): i32 {
  unsafe {
    return drv_eq_minus_o_impl(buf, len);
  }
  return 0;
}

#[no_mangle]
function drv_eq_minus_L(buf: *u8, len: i32): i32 {
  unsafe {
    return drv_eq_minus_L_impl(buf, len);
  }
  return 0;
}

#[no_mangle]
function drv_eq_minus_O(buf: *u8, len: i32): i32 {
  unsafe {
    return drv_eq_minus_O_impl(buf, len);
  }
  return 0;
}

#[no_mangle]
function drv_eq_flto(buf: *u8, len: i32): i32 {
  unsafe {
    return drv_eq_flto_impl(buf, len);
  }
  return 0;
}

#[no_mangle]
function drv_eq_minus_freestanding(buf: *u8, len: i32): i32 {
  unsafe {
    return drv_eq_minus_freestanding_impl(buf, len);
  }
  return 0;
}

#[no_mangle]
function drv_eq_legacy_f32_abi(buf: *u8, len: i32): i32 {
  unsafe {
    return drv_eq_legacy_f32_abi_impl(buf, len);
  }
  return 0;
}

#[no_mangle]
function drv_eq_fsanitize_address(buf: *u8, len: i32): i32 {
  unsafe {
    return drv_eq_fsanitize_address_impl(buf, len);
  }
  return 0;
}

#[no_mangle]
function drv_eq_minus_backend(buf: *u8, len: i32): i32 {
  unsafe {
    return drv_eq_minus_backend_impl(buf, len);
  }
  return 0;
}

#[no_mangle]
function drv_eq_minus_target(buf: *u8, len: i32): i32 {
  unsafe {
    return drv_eq_minus_target_impl(buf, len);
  }
  return 0;
}

#[no_mangle]
function drv_eq_minus_target_cpu(buf: *u8, len: i32): i32 {
  unsafe {
    return drv_eq_minus_target_cpu_impl(buf, len);
  }
  return 0;
}

#[no_mangle]
function drv_eq_print_target_cpu(buf: *u8, len: i32): i32 {
  unsafe {
    return drv_eq_print_target_cpu_impl(buf, len);
  }
  return 0;
}

#[no_mangle]
function drv_eq_asm_word(buf: *u8, len: i32): i32 {
  unsafe {
    return drv_eq_asm_word_impl(buf, len);
  }
  return 0;
}

#[no_mangle]
function drv_eq_c_word(buf: *u8, len: i32): i32 {
  unsafe {
    return drv_eq_c_word_impl(buf, len);
  }
  return 0;
}

#[no_mangle]
function drv_path_ends_x(buf: *u8, len: i32): i32 {
  unsafe {
    return drv_path_ends_x_impl(buf, len);
  }
  return 0;
}

#[no_mangle]
function drv_target_has_arm(buf: *u8, len: i32): i32 {
  unsafe {
    return drv_target_has_arm_impl(buf, len);
  }
  return 0;
}

#[no_mangle]
function driver_argv_has_emit_c_flag(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_argv_has_emit_c_flag_impl(argc, argv);
  }
  return 0;
}

#[no_mangle]
function driver_argv0_basename_is(argv0: *u8, base: *u8): i32 {
  unsafe {
    return driver_argv0_basename_is_impl(argv0, base);
  }
  return 0;
}

/* ---- G-02f-88：源扫描 / core-only / check·fmt 薄委托 门闩 ---- */

#[no_mangle]
function content_has_generic_syntax(content: *u8, n: i64): i32 {
  unsafe {
    return content_has_generic_syntax_impl(content, n);
  }
  return 0;
}

#[no_mangle]
function content_has_compound_assign_syntax(content: *u8, n: i64): i32 {
  unsafe {
    return content_has_compound_assign_syntax_impl(content, n);
  }
  return 0;
}

#[no_mangle]
function driver_deps_are_std_core_closure_only(dep_paths: *u8, n_deps: i32): i32 {
  unsafe {
    return driver_deps_are_std_core_closure_only_impl(dep_paths, n_deps);
  }
  return 0;
}

#[no_mangle]
function driver_c_mod_imports_are_core_only(mod: *u8): i32 {
  unsafe {
    return driver_c_mod_imports_are_core_only_impl(mod);
  }
  return 0;
}

#[no_mangle]
function driver_x_emit_asm_dep_parse_only_ok(input_path: *u8, dep_path: *u8): i32 {
  unsafe {
    return driver_x_emit_asm_dep_parse_only_ok_impl(input_path, dep_path);
  }
  return 0;
}

#[no_mangle]
function driver_check_only_c_typeck(input_path: *u8, src: *u8, lib_roots_arr: *u8, n_lib_roots: i32): i32 {
  unsafe {
    return driver_check_only_c_typeck_impl(input_path, src, lib_roots_arr, n_lib_roots);
  }
  return 0;
}

#[no_mangle]
function driver_lib_root_default(root_buf: *u8): void {
  unsafe {
    driver_lib_root_default_impl(root_buf);
  }
}

#[no_mangle]
function runtime_test_status_to_rc(script: *u8, st: i32): i32 {
  unsafe {
    return runtime_test_status_to_rc_impl(script, st);
  }
  return 0;
}

#[no_mangle]
function runtime_run_compiler_check_c(argc: i32, argv: *u8): i32 {
  unsafe {
    return runtime_run_compiler_check_c_impl(argc, argv);
  }
  return 0;
}

#[no_mangle]
function runtime_run_fmt_c(argc: i32, argv: *u8): i32 {
  unsafe {
    return runtime_run_fmt_c_impl(argc, argv);
  }
  return 0;
}

/* ---- G-02f-90：DCE 回调 / tmp 前缀 / parse fail / lib_roots / run_test 门闩 ---- */

#[no_mangle]
function shux_get_tmp_prefix(): *u8 {
  unsafe {
    return shux_get_tmp_prefix_impl();
  }
  return 0 as *u8;
}

#[no_mangle]
function dce_is_func_used(ctx: *u8, mod: *u8, func: *u8): i32 {
  unsafe {
    return dce_is_func_used_impl(ctx, mod, func);
  }
  return 0;
}

#[no_mangle]
function dce_is_mono_used(ctx: *u8, mod: *u8, k: i32): i32 {
  unsafe {
    return dce_is_mono_used_impl(ctx, mod, k);
  }
  return 0;
}

#[no_mangle]
function dce_is_type_used(ctx: *u8, mod: *u8, type_name: *u8): i32 {
  unsafe {
    return dce_is_type_used_impl(ctx, mod, type_name);
  }
  return 0;
}

#[no_mangle]
function runtime_report_precise_parse_failure_if_known(input_path: *u8, src: *u8, src_len: i64): i32 {
  unsafe {
    return runtime_report_precise_parse_failure_if_known_impl(input_path, src, src_len);
  }
  return 0;
}

#[no_mangle]
function runtime_run_test_c(argc: i32, argv: *u8): i32 {
  unsafe {
    return runtime_run_test_c_impl(argc, argv);
  }
  return 0;
}

#[no_mangle]
function driver_lib_roots_from_key(lib_key: *u8, out_arr: *u8, bufs: *u8): i32 {
  unsafe {
    return driver_lib_roots_from_key_impl(lib_key, out_arr, bufs);
  }
  return 0;
}

