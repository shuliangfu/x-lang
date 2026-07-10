// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-14/71/72：runtime 产品源 seeds/runtime.from_x.c + 真迁 .x 门闩。
// G-02f-85：smoke_diag / unlink_failed_out / asm direct-import 门闩。
// G-02f-86：explain CLI / errno diag / legacy smoke summary 门闩。
// G-02f-87：argv 令牌/path 后缀纯 helper（drv_eq_* / path_ends / lib_root_usable）门闩。
// G-02f-88：源扫描 content_has_*、core-only deps/imports、check/fmt 薄委托门闩。
// G-02f-90：DCE 回调 / tmp 前缀 / parse fail / lib_roots_from_key / run_test 门闩。
// G-02f-93：large-stack helpers / prepare_dce_ctx / x_emit_from_compile_state 门闩。
// G-02f-94：C frontend smoke / shu-c sibling / smoke lex thread 门闩。
// G-02f-95：fs/path/map ABI emit / pipeline_glue include / elf diag / argv_step 门闩。
// G-02f-71/72：driver compile/run 薄封装 + main_entry/argv/exec/fmt/大 run_* 门闩。
// 产品：cc seeds/runtime.from_x.c + RUNTIME_DRIVER_NO_C_CFLAGS → src/runtime_driver_no_c.o
// C 尾：argv 解析循环、#if 变体、大 driver 路径、syscall/fs。

extern "C" function driver_run_x_emit_c_set_path_impl(path: *u8, path_len: i32): i32;
extern "C" function driver_run_x_emit_c_set_lib_impl(i: i32, buf: *u8, len: i32): i32;
extern "C" function driver_fs_open_read_path_impl(path: *u8, path_len: i32): i32;
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

extern "C" function driver_deps_are_std_core_closure_only_impl(dep_paths: *u8, n_deps: i32): i32;
extern "C" function driver_c_mod_imports_are_core_only_impl(mod: *u8): i32;
extern "C" function driver_x_emit_asm_dep_parse_only_ok_impl(input_path: *u8, dep_path: *u8): i32;
extern "C" function driver_check_only_c_typeck_impl(input_path: *u8, src: *u8, lib_roots_arr: *u8, n_lib_roots: i32): i32;
extern "C" function driver_lib_root_default_impl(root_buf: *u8): void;
extern "C" function runtime_test_status_to_rc_impl(script: *u8, st: i32): i32;

extern "C" function shux_get_tmp_prefix_impl(): *u8;
extern "C" function dce_is_func_used_impl(ctx: *u8, mod: *u8, func: *u8): i32;
extern "C" function dce_is_mono_used_impl(ctx: *u8, mod: *u8, k: i32): i32;
extern "C" function dce_is_type_used_impl(ctx: *u8, mod: *u8, type_name: *u8): i32;
extern "C" function runtime_report_precise_parse_failure_if_known_impl(input_path: *u8, src: *u8, src_len: i64): i32;
extern "C" function runtime_run_test_c_impl(argc: i32, argv: *u8): i32;
extern "C" function driver_lib_roots_from_key_impl(lib_key: *u8, out_arr: *u8, bufs: *u8): i32;

extern "C" function driver_smoke_lex_dump_on_large_stack_impl(src: *u8): void;
extern "C" function driver_stack_esc_gate_thread_fn_impl(arg: *u8): *u8;
extern "C" function driver_stack_esc_gate_large_stack_impl(src: *u8, src_len: i32): i32;
extern "C" function driver_c_typeck_entry_thread_fn_impl(arg: *u8): *u8;
extern "C" function driver_c_typeck_entry_large_stack_impl(input_path: *u8, src: *u8, lib_roots_arr: *u8, n_lib_roots: i32, print_ok: i32): i32;
extern "C" function runtime_prepare_dce_ctx_impl(mod: *u8, all_dep_mods: *u8, n_all: i32, used_funcs: *u8, n_used: *i32, used_mono: *u8, used_type_names: *u8, n_used_types: *i32, wpo_reach: *u8, dce: *u8, dce_ready: *i32): void;
extern "C" function driver_run_x_emit_c_from_compile_state_impl(state: *u8, argc: i32, argv: *u8): i32;

extern "C" function driver_c_frontend_smoke_impl(input_path: *u8, src: *u8, lib_roots_arr: *u8, n_lib_roots: i32): i32;
extern "C" function driver_try_compile_via_shu_c_sibling_impl(argc: i32, argv: *u8): i32;
extern "C" function driver_smoke_lex_dump_thread_fn_impl(arg: *u8): *u8;

extern "C" function write_fs_path_map_error_abi_inline_impl(cf: *u8): i32;
extern "C" function codegen_emit_include_pipeline_glue_c_impl(out: *u8, argv0: *u8): void;
extern "C" function runtime_pipeline_elf_ctx_diag_note_impl(ctx_bytes: *u8): void;
extern "C" function driver_compile_parse_argv_step_c_impl(argc: i32, argv: *u8, state: *u8, i: i32, arg_buf: *u8, arg_cap: i32): i32;



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
function driver_fs_open_read_path(path: *u8, path_len: i32): i32 {
  unsafe {
    return driver_fs_open_read_path_impl(path, path_len);
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






















/* ---- G-02f-88：源扫描 / core-only / check·fmt 薄委托 门闩 ---- */





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

/* ---- G-02f-93：large-stack / prepare_dce / x_emit_from_state 门闩 ---- */

#[no_mangle]
function driver_smoke_lex_dump_on_large_stack(src: *u8): void {
  unsafe {
    driver_smoke_lex_dump_on_large_stack_impl(src);
  }
}

#[no_mangle]
function driver_stack_esc_gate_thread_fn(arg: *u8): *u8 {
  unsafe {
    return driver_stack_esc_gate_thread_fn_impl(arg);
  }
  return 0 as *u8;
}

#[no_mangle]
function driver_stack_esc_gate_large_stack(src: *u8, src_len: i32): i32 {
  unsafe {
    return driver_stack_esc_gate_large_stack_impl(src, src_len);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_c_typeck_entry_thread_fn(arg: *u8): *u8 {
  unsafe {
    return driver_c_typeck_entry_thread_fn_impl(arg);
  }
  return 0 as *u8;
}

#[no_mangle]
function driver_c_typeck_entry_large_stack(input_path: *u8, src: *u8, lib_roots_arr: *u8, n_lib_roots: i32, print_ok: i32): i32 {
  unsafe {
    return driver_c_typeck_entry_large_stack_impl(input_path, src, lib_roots_arr, n_lib_roots, print_ok);
  }
  return 0 - 1;
}

#[no_mangle]
function runtime_prepare_dce_ctx(mod: *u8, all_dep_mods: *u8, n_all: i32, used_funcs: *u8, n_used: *i32, used_mono: *u8, used_type_names: *u8, n_used_types: *i32, wpo_reach: *u8, dce: *u8, dce_ready: *i32): void {
  unsafe {
    runtime_prepare_dce_ctx_impl(mod, all_dep_mods, n_all, used_funcs, n_used, used_mono, used_type_names, n_used_types, wpo_reach, dce, dce_ready);
  }
}

#[no_mangle]
function driver_run_x_emit_c_from_compile_state(state: *u8, argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_x_emit_c_from_compile_state_impl(state, argc, argv);
  }
  return 0 - 1;
}

/* ---- G-02f-94：C frontend smoke / shu-c sibling / smoke lex thread 门闩 ---- */

#[no_mangle]
function driver_c_frontend_smoke(input_path: *u8, src: *u8, lib_roots_arr: *u8, n_lib_roots: i32): i32 {
  unsafe {
    return driver_c_frontend_smoke_impl(input_path, src, lib_roots_arr, n_lib_roots);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_try_compile_via_shu_c_sibling(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_try_compile_via_shu_c_sibling_impl(argc, argv);
  }
  return 0 - 1;
}

#[no_mangle]
function driver_smoke_lex_dump_thread_fn(arg: *u8): *u8 {
  unsafe {
    return driver_smoke_lex_dump_thread_fn_impl(arg);
  }
  return 0 as *u8;
}

/* ---- G-02f-95：ABI emit / pipeline_glue include / elf diag / argv_step 门闩 ---- */

#[no_mangle]
function write_fs_path_map_error_abi_inline(cf: *u8): i32 {
  unsafe {
    return write_fs_path_map_error_abi_inline_impl(cf);
  }
  return 0 - 1;
}

#[no_mangle]
function codegen_emit_include_pipeline_glue_c(out: *u8, argv0: *u8): void {
  unsafe {
    codegen_emit_include_pipeline_glue_c_impl(out, argv0);
  }
}

#[no_mangle]
function runtime_pipeline_elf_ctx_diag_note(ctx_bytes: *u8): void {
  unsafe {
    runtime_pipeline_elf_ctx_diag_note_impl(ctx_bytes);
  }
}

#[no_mangle]
function driver_compile_parse_argv_step_c(argc: i32, argv: *u8, state: *u8, i: i32, arg_buf: *u8, arg_cap: i32): i32 {
  unsafe {
    return driver_compile_parse_argv_step_c_impl(argc, argv, state, i, arg_buf, arg_cap);
  }
  return i + 1;
}

// G-02f-111：+ write_io_net_abi_inline / driver_run_compiler_parsed / x_emit_c_extern 薄门闩。
// 注：driver_c_typeck_entry 仍 static（#if 分支花括号，自动 promote 暂跳过）。

extern "C" function write_io_net_abi_inline_impl(cf: *u8): i32;
extern "C" function driver_run_compiler_parsed_impl(p: *u8, argc: i32, argv: *u8): i32;
extern "C" function driver_run_x_emit_c_extern_via_cparser_impl(path: *u8): i32;

/* ---- G-02f-111：runtime driver helpers 门闩 ---- */

#[no_mangle]
function write_io_net_abi_inline(cf: *u8): i32 { unsafe { return write_io_net_abi_inline_impl(cf); } return 0; }
#[no_mangle]
function driver_run_compiler_parsed(p: *u8, argc: i32, argv: *u8): i32 { unsafe { return driver_run_compiler_parsed_impl(p, argc, argv); } return 0; }
#[no_mangle]
function driver_run_x_emit_c_extern_via_cparser(path: *u8): i32 { unsafe { return driver_run_x_emit_c_extern_via_cparser_impl(path); } return 0; }

// G-02f-112：+ driver_c_typeck_entry 薄门闩（#if-aware promote）。

extern "C" function driver_c_typeck_entry_impl(mod: *u8, arena: *u8): i32;

/* ---- G-02f-112：driver typeck entry 门闩 ---- */

#[no_mangle]
function driver_c_typeck_entry(mod: *u8, arena: *u8): i32 {
  unsafe { return driver_c_typeck_entry_impl(mod, arena); }
  return 0;
}

// G-02f-114：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
function drv_eq_minus_o(buf: *u8, len: i32): i32 {
  if (len != 2) { return 0; }
  if (buf[0] == 45 && buf[1] == 111) { return 1; }
  return 0;
}

#[no_mangle]
function drv_eq_minus_L(buf: *u8, len: i32): i32 {
  if (len != 2) { return 0; }
  if (buf[0] == 45 && buf[1] == 76) { return 1; }
  return 0;
}

#[no_mangle]
function drv_eq_minus_O(buf: *u8, len: i32): i32 {
  if (len != 2) { return 0; }
  if (buf[0] == 45 && buf[1] == 79) { return 1; }
  return 0;
}

#[no_mangle]
function drv_eq_flto(buf: *u8, len: i32): i32 {
  if (len != 5) { return 0; }
  if (buf[0] == 45 && buf[1] == 102 && buf[2] == 108 && buf[3] == 116 && buf[4] == 111) { return 1; }
  return 0;
}

#[no_mangle]
function drv_eq_minus_freestanding(buf: *u8, len: i32): i32 {
  if (len != 13) { return 0; }
  // -freestanding
  if (buf[0] == 45 && buf[1] == 102 && buf[2] == 114 && buf[3] == 101 && buf[4] == 101
      && buf[5] == 115 && buf[6] == 116 && buf[7] == 97 && buf[8] == 110 && buf[9] == 100
      && buf[10] == 105 && buf[11] == 110 && buf[12] == 103) { return 1; }
  return 0;
}

#[no_mangle]
function drv_eq_legacy_f32_abi(buf: *u8, len: i32): i32 {
  if (len != 15) { return 0; }
  // -legacy-f32-abi
  if (buf[0] == 45 && buf[1] == 108 && buf[2] == 101 && buf[3] == 103 && buf[4] == 97
      && buf[5] == 99 && buf[6] == 121 && buf[7] == 45 && buf[8] == 102 && buf[9] == 51
      && buf[10] == 50 && buf[11] == 45 && buf[12] == 97 && buf[13] == 98 && buf[14] == 105) { return 1; }
  return 0;
}

#[no_mangle]
function drv_eq_fsanitize_address(buf: *u8, len: i32): i32 {
  if (len != 18) { return 0; }
  // -fsanitize=address
  if (buf[0] == 45 && buf[1] == 102 && buf[2] == 115 && buf[3] == 97 && buf[4] == 110
      && buf[5] == 105 && buf[6] == 116 && buf[7] == 105 && buf[8] == 122 && buf[9] == 101
      && buf[10] == 61 && buf[11] == 97 && buf[12] == 100 && buf[13] == 100 && buf[14] == 114
      && buf[15] == 101 && buf[16] == 115 && buf[17] == 115) { return 1; }
  return 0;
}

#[no_mangle]
function drv_eq_minus_backend(buf: *u8, len: i32): i32 {
  if (len != 8) { return 0; }
  // -backend
  if (buf[0] == 45 && buf[1] == 98 && buf[2] == 97 && buf[3] == 99 && buf[4] == 107
      && buf[5] == 101 && buf[6] == 110 && buf[7] == 100) { return 1; }
  return 0;
}

#[no_mangle]
function drv_eq_minus_target(buf: *u8, len: i32): i32 {
  if (len < 7) { return 0; }
  // -target
  if (buf[0] == 45 && buf[1] == 116 && buf[2] == 97 && buf[3] == 114 && buf[4] == 103
      && buf[5] == 101 && buf[6] == 116) { return 1; }
  return 0;
}

#[no_mangle]
function drv_eq_minus_target_cpu(buf: *u8, len: i32): i32 {
  if (len < 11) { return 0; }
  // -target-cpu
  if (buf[0] == 45 && buf[1] == 116 && buf[2] == 97 && buf[3] == 114 && buf[4] == 103
      && buf[5] == 101 && buf[6] == 116 && buf[7] == 45 && buf[8] == 99 && buf[9] == 112
      && buf[10] == 117) { return 1; }
  return 0;
}

#[no_mangle]
function drv_eq_print_target_cpu(buf: *u8, len: i32): i32 {
  // --print-target-cpu (18) or -print-target-cpu (17)
  if (len == 18) {
    if (buf[0] == 45 && buf[1] == 45 && buf[2] == 112 && buf[3] == 114 && buf[4] == 105
        && buf[5] == 110 && buf[6] == 116 && buf[7] == 45 && buf[8] == 116 && buf[9] == 97
        && buf[10] == 114 && buf[11] == 103 && buf[12] == 101 && buf[13] == 116 && buf[14] == 45
        && buf[15] == 99 && buf[16] == 112 && buf[17] == 117) { return 1; }
  }
  if (len == 17) {
    if (buf[0] == 45 && buf[1] == 112 && buf[2] == 114 && buf[3] == 105 && buf[4] == 110
        && buf[5] == 116 && buf[6] == 45 && buf[7] == 116 && buf[8] == 97 && buf[9] == 114
        && buf[10] == 103 && buf[11] == 101 && buf[12] == 116 && buf[13] == 45 && buf[14] == 99
        && buf[15] == 112 && buf[16] == 117) { return 1; }
  }
  return 0;
}

#[no_mangle]
function drv_eq_asm_word(buf: *u8, len: i32): i32 {
  if (len != 3) { return 0; }
  if (buf[0] == 97 && buf[1] == 115 && buf[2] == 109) { return 1; }
  return 0;
}

#[no_mangle]
function drv_eq_c_word(buf: *u8, len: i32): i32 {
  if (len != 1) { return 0; }
  if (buf[0] == 99) { return 1; }
  return 0;
}

#[no_mangle]
function drv_path_ends_x(buf: *u8, len: i32): i32 {
  if (len >= 2) {
    if (buf[len - 2] == 46 && buf[len - 1] == 120) { return 1; }
  }
  if (len >= 3) {
    if (buf[len - 3] == 46 && buf[len - 2] == 115 && buf[len - 1] == 117) { return 1; }
  }
  return 0;
}

#[no_mangle]
function driver_lib_root_ptr_usable(p: *u8): i32 {
  // .x 路径：非空指针且非空串（C 侧另有 >=4096 哨兵；seed 保持原语义）
  if (p == 0) { return 0; }
  if (p[0] == 0) { return 0; }
  return 1;
}

extern "C" function getenv(name: *u8): *u8;

extern "C" function diag_json_enabled(): i32;

// G-02f-117：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
function shux_smoke_diag_enabled(): i32 {
  unsafe {
    let j: i32 = diag_json_enabled();
    if (j != 0) { return 1; }
    let e: *u8 = getenv("SHUX_SMOKE_DIAG");
    if (e == 0) { return 0; }
    if (e[0] == 0) { return 0; }
    if (e[0] == 48) { return 0; }
    return 1;
  }
  return 0;
}

// G-02f-122：driver_asm_output_want_exe 真迁 .x

extern "C" function shux_output_want_exe(path: *u8): i32;

#[no_mangle]
function driver_asm_output_want_exe(path: *u8): i32 {
  unsafe {
    return shux_output_want_exe(path);
  }
  return 0;
}

// G-02f-125：driver pure argv/target/basename helpers 真迁 .x

extern "C" function driver_argv_at(argv: *u8, i: i32): *u8;

#[no_mangle]
function drv_target_has_arm(buf: *u8, len: i32): i32 {
  if (buf == 0) { return 0; }
  let start: i32 = 0;
  while (start + 5 <= len) {
    // arm64
    if (buf[start]==97 && buf[start+1]==114 && buf[start+2]==109 && buf[start+3]==54 && buf[start+4]==52) {
      return 1;
    }
    start = start + 1;
  }
  return 0;
}

#[no_mangle]
function driver_argv_has_emit_c_flag(argc: i32, argv: *u8): i32 {
  if (argc < 2) { return 0; }
  if (argv == 0) { return 0; }
  let i: i32 = 1;
  while (i < argc) {
    unsafe {
      let s: *u8 = driver_argv_at(argv, i);
      if (s != 0) {
        // "-E"
        if (s[0]==45 && s[1]==69 && s[2]==0) { return 1; }
        // "-E-extern"
        if (s[0]==45 && s[1]==69 && s[2]==45 && s[3]==101 && s[4]==120 && s[5]==116
            && s[6]==101 && s[7]==114 && s[8]==110 && s[9]==0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

#[no_mangle]
function driver_argv0_basename_is(argv0: *u8, base: *u8): i32 {
  if (base == 0) { return 0; }
  // find last / or \
  let name: *u8 = argv0;
  if (argv0 != 0) {
    let i: i32 = 0;
    let last: i32 = 0 - 1;
    while (i < 4096) {
      let c: u8 = argv0[i];
      if (c == 0) { break; }
      if (c == 47) { last = i; }
      if (c == 92) { last = i; }
      i = i + 1;
    }
    if (last >= 0) {
      // name = argv0 + last + 1
      unsafe {
        // compare from last+1
        let j: i32 = 0;
        while (j < 256) {
          let a: u8 = argv0[last + 1 + j];
          let b: u8 = base[j];
          if (a != b) { return 0; }
          if (a == 0) { return 1; }
          j = j + 1;
        }
      }
      return 0;
    }
  } else {
    name = 0 as *u8;
  }
  // no slash: compare argv0 or empty with base
  if (argv0 == 0) {
    if (base[0] == 0) { return 1; }
    return 0;
  }
  let j: i32 = 0;
  while (j < 256) {
    let a: u8 = argv0[j];
    let b: u8 = base[j];
    if (a != b) { return 0; }
    if (a == 0) { return 1; }
    j = j + 1;
  }
  return 0;
}

// G-02f-126：content_has_* 语法探测真迁 .x；emit setter 产品以 seed C 为准

#[no_mangle]
function content_has_generic_syntax(content: *u8, n: i64): i32 {
  if (content == 0) { return 0; }
  if (n == 0) { return 0; }
  let ni: i32 = n as i32;
  // scan for '<'
  let p: i32 = 0;
  while (p < ni) {
    if (content[p] == 60) { // '<'
      if (p + 1 >= ni) { break; }
      // skip T[]<region> — previous char is ']'
      if (p > 0) {
        if (content[p - 1] == 93) { // ']'
          p = p + 1;
          continue;
        }
      }
      // <T> or <T,
      if (content[p + 1] == 84) { // 'T'
        if (p + 2 >= ni) { return 1; }
        if (content[p + 2] == 62) { return 1; } // '>'
        if (content[p + 2] == 44) { return 1; } // ','
      }
      // generic type tokens
      // <i8> <i16> <i32> <i64> <u8> <u16> <u32> <u64> <f32> <f64> <bool>
      if (p + 4 <= ni) {
        // <i8>
        if (content[p+1]==105 && content[p+2]==56 && content[p+3]==62) { return 1; }
        // <u8>
        if (content[p+1]==117 && content[p+2]==56 && content[p+3]==62) { return 1; }
      }
      if (p + 5 <= ni) {
        // <i16> <i32> <i64> <u16> <u32> <u64> <f32> <f64>
        if (content[p+1]==105 && content[p+2]==49 && content[p+3]==54 && content[p+4]==62) { return 1; }
        if (content[p+1]==105 && content[p+2]==51 && content[p+3]==50 && content[p+4]==62) { return 1; }
        if (content[p+1]==105 && content[p+2]==54 && content[p+3]==52 && content[p+4]==62) { return 1; }
        if (content[p+1]==117 && content[p+2]==49 && content[p+3]==54 && content[p+4]==62) { return 1; }
        if (content[p+1]==117 && content[p+2]==51 && content[p+3]==50 && content[p+4]==62) { return 1; }
        if (content[p+1]==117 && content[p+2]==54 && content[p+3]==52 && content[p+4]==62) { return 1; }
        if (content[p+1]==102 && content[p+2]==51 && content[p+3]==50 && content[p+4]==62) { return 1; }
        if (content[p+1]==102 && content[p+2]==54 && content[p+3]==52 && content[p+4]==62) { return 1; }
      }
      if (p + 6 <= ni) {
        // <bool>
        if (content[p+1]==98 && content[p+2]==111 && content[p+3]==111 && content[p+4]==108 && content[p+5]==62) {
          return 1;
        }
      }
    }
    p = p + 1;
  }
  // "trait " / " impl "
  if (ni >= 6) {
    let i: i32 = 0;
    while (i <= ni - 6) {
      // trait 
      if (content[i]==116 && content[i+1]==114 && content[i+2]==97 && content[i+3]==105
          && content[i+4]==116 && content[i+5]==32) {
        return 1;
      }
      //  impl 
      if (content[i]==32 && content[i+1]==105 && content[i+2]==109 && content[i+3]==112
          && content[i+4]==108 && content[i+5]==32) {
        return 1;
      }
      i = i + 1;
    }
  }
  return 0;
}

#[no_mangle]
function content_has_compound_assign_syntax(content: *u8, n: i64): i32 {
  if (content == 0) { return 0; }
  if (n < 3) { return 0; }
  let ni: i32 = n as i32;
  let pos: i32 = 0;
  while (pos < ni) {
    // // line comment
    if (pos + 1 < ni) {
      if (content[pos] == 47 && content[pos + 1] == 47) {
        pos = pos + 2;
        while (pos < ni) {
          if (content[pos] == 10) { break; }
          pos = pos + 1;
        }
        continue;
      }
      // /* block */
      if (content[pos] == 47 && content[pos + 1] == 42) {
        pos = pos + 2;
        while (pos + 1 < ni) {
          if (content[pos] == 42 && content[pos + 1] == 47) { break; }
          pos = pos + 1;
        }
        if (pos + 1 < ni) { pos = pos + 2; }
        continue;
      }
    }
    // string "
    if (content[pos] == 34) {
      pos = pos + 1;
      while (pos < ni) {
        if (content[pos] == 34) { break; }
        if (content[pos] == 92) {
          if (pos + 1 < ni) { pos = pos + 2; continue; }
        }
        pos = pos + 1;
      }
      if (pos < ni) { pos = pos + 1; }
      continue;
    }
    // tokens long first: <<= >>= += -= *= /= %= &= |= ^=
    if (pos + 3 <= ni) {
      if (content[pos]==60 && content[pos+1]==60 && content[pos+2]==61) { return 1; }
      if (content[pos]==62 && content[pos+1]==62 && content[pos+2]==61) { return 1; }
    }
    if (pos + 2 <= ni) {
      let a: u8 = content[pos];
      let b: u8 = content[pos + 1];
      if (b == 61) {
        if (a == 43) { return 1; }
        if (a == 45) { return 1; }
        if (a == 42) { return 1; }
        if (a == 47) { return 1; }
        if (a == 37) { return 1; }
        if (a == 38) { return 1; }
        if (a == 124) { return 1; }
        if (a == 94) { return 1; }
      }
    }
    pos = pos + 1;
  }
  return 0;
}

// emit setters: product seed C owns static state; .x documents entry (return 0)
#[no_mangle]
function driver_run_x_emit_c_set_emit_extern(v: i32): i32 {
  // product: seeds/runtime.from_x.c sets driver_x_emit_c_want_extern
  return 0;
}

#[no_mangle]
function driver_run_x_emit_c_set_n_lib_roots(n: i32): i32 {
  // product: seeds/runtime.from_x.c clamps to X_EMIT_MAX_LIB_ROOTS(16)
  return 0;
}

// G-02f-127：runtime 入口转发真迁 .x

extern "C" function main_run_compiler_c(argc: i32, argv: *u8): i32;
extern "C" function driver_run_fmt(argc: i32, argv: *u8): i32;
extern "C" function driver_run_compiler_check(argc: i32, argv: *u8): i32;

#[no_mangle]
function run_compiler_c(argc: i32, argv: *u8): i32 {
  unsafe {
    return main_run_compiler_c(argc, argv);
  }
  return 0 - 1;
}

#[no_mangle]
function runtime_run_fmt_c(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_fmt(argc, argv);
  }
  return 0 - 1;
}

#[no_mangle]
function runtime_run_compiler_check_c(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_compiler_check(argc, argv);
  }
  return 0 - 1;
}

