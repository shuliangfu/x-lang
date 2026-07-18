// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-315/457 → R2 full: -backend asm body.
// .x owns driver_run_asm_backend; product PREFER rest is marker only (business H=0).
// Cap residual (driver_abi): FILE*/pctx fields/host defaults/defines/**u8/work slots/
//   C frontend precheck (product NO_C always skips).
// Steps: read_pp / early / parse / load_deps / open_out / prerun / pipeline / finish.
// PLATFORM: SHARED — surface short names are the link-name contract (Track L).
// Comment rule: never put star-slash sequences inside block comments.

export extern "C" function malloc(n: usize): *u8;
export extern "C" function free(p: *u8): void;
export extern "C" function memset(p: *u8, c: i32, n: usize): *u8;
export extern "C" function strlen(s: *u8): usize;
export extern "C" function getenv(name: *u8): *u8;
export extern "C" function unlink(path: *u8): i32;
export extern "C" function runtime_read_file_malloc(path: *u8, out_len: *usize): *u8;
export extern "C" function shux_preprocess_with_path(
  data: *u8, len: usize, path: *u8, defines: *u8, n_defines: i32, out_len: *usize): *u8;
export extern "C" function pipeline_diag_emitted_reset(): void;
export extern "C" function pipeline_diag_emitted_get(): i32;
export extern "C" function diag_set_file(path: *u8, src: *u8, len: usize): void;
export extern "C" function pipeline_sizeof_arena(): usize;
export extern "C" function pipeline_sizeof_module(): usize;
export extern "C" function parser_parse_into_init(module: *u8, arena: *u8): void;
export extern "C" function parser_parse_into_set_main_index(module: *u8, main_idx: i32): void;
export extern "C" function driver_get_module_num_funcs(m: *u8): i32;
export extern "C" function parser_get_module_num_imports(module: *u8): i32;
export extern "C" function shux_get_entry_dir(path: *u8, out: *u8, out_sz: usize): void;
export extern "C" function driver_dep_seeded_clear_all(): void;
export extern "C" function driver_dep_publish_slot(j: i32, arena: *u8, module: *u8, path: *u8): void;
export extern "C" function pipeline_set_dep_slots(arenas: *u8, modules: *u8): void;
export extern "C" function driver_dep_seed_slots(arenas: *u8, modules: *u8, n: i32): void;
export extern "C" function codegen_set_dep_slots_for_x_pipeline(mods: *u8, paths: *u8, n: i32): void;
export extern "C" function codegen_set_preamble_has_core_option_result(on: i32): void;
export extern "C" function runtime_report_precise_parse_failure_if_known(
  input_path: *u8, src: *u8, src_len: usize): i32;
export extern "C" function pipeline_dep_ctx_heap_destroy(ctx: *u8): void;
export extern "C" function shux_pipeline_run_x_pipeline_large_stack(
  module: *u8, arena: *u8, src: *u8, src_len: usize, out_buf: *u8, pctx: *u8): i32;
export extern "C" function shux_pipeline_fill_ctx_path_buffers(
  ctx: *u8, entry_dir: *u8, lib_roots: *u8, n_lib: i32): void;
export extern "C" function shux_pipeline_pctx_seed_dep_slots(
  ctx: *u8, dep_mods: *u8, dep_ar: *u8, dep_paths: *u8, n: i32): void;
export extern "C" function shux_pipeline_one_ctx_for_dep_prerun(
  ctx: *u8, j: i32, dep_mods: *u8, dep_ar: *u8, dep_paths: *u8, n: i32,
  dep_src: *u8, dep_len: usize): void;
export extern "C" function shux_load_direct_imports_for_asm_layout(
  module: *u8, lib_roots: *u8, n_lib: i32, entry_dir: *u8,
  defines: *u8, n_defines: i32,
  dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, n_deps: *i32): i32;
export extern "C" function shux_collect_deps_transitive(
  module: *u8, arena_sz: usize, module_sz: usize, lib_roots: *u8, n_lib: i32,
  entry_dir: *u8, defines: *u8, n_defines: i32,
  cls: *u8, clens: *u8, cpaths: *u8, n_closure: *i32): i32;
export extern "C" function shux_merge_direct_then_transitive_deps(
  module: *u8, n_imports: i32, cls: *u8, clens: *u8, cpaths: *u8, n_closure: i32,
  dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, n_deps: *i32): i32;
export extern "C" function shux_dep_prerun_entry_dir(
  entry_dir: *u8, lib_roots: *u8, n_lib: i32): *u8;
export extern "C" function shux_pipeline_dep_prerun_parse_only(
  mod: *u8, arena: *u8, src: *u8, len: usize): i32;
export extern "C" function shux_pipeline_dep_prerun_parse_skip_typeck(
  mod: *u8, arena: *u8, src: *u8, len: usize, out: *u8, ctx: *u8): i32;
export extern "C" function shux_pipeline_dep_prerun_for_asm_module_o(
  mod: *u8, arena: *u8, src: *u8, len: usize, out: *u8, ctx: *u8): i32;
export extern "C" function shux_asm_user_std_dep_skip_x_typeck(dep_path: *u8): i32;
export extern "C" function shux_asm_user_dep_parse_skip_typeck_path(dep_path: *u8): i32;
export extern "C" function shux_asm_user_std_net_dep_path(dep_path: *u8): i32;
export extern "C" function pipeline_asm_seed_std_net_struct_layouts(m: *u8): void;
export extern "C" function pipeline_asm_user_deps_need_coemit(dep_paths: *u8, n: i32): i32;
export extern "C" function shux_output_want_exe(path: *u8): i32;
export extern "C" function shux_output_is_elf_o(path: *u8): i32;
export extern "C" function shux_asm_out_buf_is_object(data: *u8, len: usize): i32;
export extern "C" function shux_driver_asm_prepare_entry_elf_emit(
  module: *u8, arena: *u8, pctx: *u8): void;
export extern "C" function shux_asm_codegen_elf_o_large_stack(
  module: *u8, arena: *u8, pctx: *u8, elf_ctx: *u8, out_buf: *u8): i32;
export extern "C" function shux_invoke_ld_for_exe(
  o_path: *u8, exe_path: *u8, target: *u8, use_macho: i32, use_coff: i32,
  link_argv0: *u8, lib_roots: *u8, n_lib: i32): i32;
export extern "C" function runtime_pipeline_elf_ctx_diag_note(ctx_bytes: *u8): void;
export extern "C" function runtime_diag_errno_path(
  file: *u8, kind: *u8, op: *u8, path: *u8): void;
export extern "C" function driver_unlink_failed_output(out_path: *u8): void;
export extern "C" function driver_bump_stack_limit(): void;
export extern "C" function cfg_apply_compile_target_from_triple(triple: *u8, len: i32): void;
export extern "C" function cfg_reset_compile_target(): void;
export extern "C" function driver_set_pipeline_entry_source_len(len: usize): void;
export extern "C" function driver_asm_build_skip_typeck(): i32;
export extern "C" function driver_asm_entry_module_only_from_env(): i32;
export extern "C" function driver_asm_parse_metric_only_from_env(): i32;
export extern "C" function driver_freestanding_get(): i32;
export extern "C" function driver_check_only_get(): i32;
export extern "C" function driver_check_diag_emitted_get(): i32;
export extern "C" function driver_x_pipeline_skip_typeck_set(v: i32): void;
export extern "C" function driver_x_pipeline_skip_codegen_set(v: i32): void;
export extern "C" function driver_deps_are_std_core_closure_only(dep_paths: *u8, n: i32): i32;
export extern "C" function driver_print_x_smoke_summary(module: *u8, codegen_len: usize): void;
export extern "C" function driver_print_check_ok(input_path: *u8): void;
export extern "C" function driver_diagnostic_after_entry_parse(num_funcs: i32): void;
export extern "C" function driver_diagnostic_after_entry_parse_module(module: *u8): void;
export extern "C" function diag_report_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;

export extern "C" function driver_codegen_outbuf_calloc(): *u8;
export extern "C" function driver_codegen_outbuf_free(p: *u8): void;
export extern "C" function driver_codegen_outbuf_len(p: *u8): i32;
export extern "C" function driver_codegen_outbuf_data(p: *u8): *u8;
export extern "C" function driver_pipeline_dep_ctx_calloc(): *u8;
export extern "C" function driver_ptr_table_calloc(n: i32): *u8;
export extern "C" function driver_ptr_table_free(t: *u8): void;
export extern "C" function driver_ptr_table_get(t: *u8, i: i32): *u8;
export extern "C" function driver_ptr_table_set(t: *u8, i: i32, p: *u8): void;
export extern "C" function driver_size_table_calloc(n: i32): *u8;
export extern "C" function driver_size_table_free(t: *u8): void;
export extern "C" function driver_size_table_get(t: *u8, i: i32): usize;
export extern "C" function driver_size_table_set(t: *u8, i: i32, v: usize): void;
export extern "C" function driver_parse_into_buf_rc(
  arena: *u8, module: *u8, data: *u8, len: i32, out_main_idx: *i32): i32;
export extern "C" function driver_typeck_ndep_set(n: i32): void;
export extern "C" function driver_typeck_dep_ptrs_set(j: i32, mod: *u8, arena: *u8): void;
export extern "C" function driver_entry_dir_slot(): *u8;
export extern "C" function driver_pipeline_dep_ctx_set_use_asm(ctx: *u8, v: i32): void;
export extern "C" function driver_pipeline_dep_ctx_set_target_arch(ctx: *u8, v: i32): void;
export extern "C" function driver_pipeline_dep_ctx_set_target_cpu_features(ctx: *u8, v: i32): void;
export extern "C" function driver_pipeline_dep_ctx_set_use_macho_o(ctx: *u8, v: i32): void;
export extern "C" function driver_pipeline_dep_ctx_set_use_coff_o(ctx: *u8, v: i32): void;
export extern "C" function driver_pipeline_dep_ctx_set_entry_already_parsed(ctx: *u8, v: i32): void;
export extern "C" function driver_pipeline_dep_ctx_set_asm_entry_module_only(ctx: *u8, v: i32): void;
export extern "C" function driver_pipeline_dep_ctx_get_asm_entry_module_only(ctx: *u8): i32;
export extern "C" function driver_pipeline_dep_ctx_get_use_macho_o(ctx: *u8): i32;
export extern "C" function driver_pipeline_dep_ctx_get_use_coff_o(ctx: *u8): i32;
export extern "C" function driver_asm_pctx_apply_host_defaults(
  ctx: *u8, target: *u8, emit_elf_o: i32): void;
export extern "C" function driver_asm_fopen_wb(path: *u8): *u8;
export extern "C" function driver_asm_mkstemp_fdopen(path_out64: *u8): *u8;
export extern "C" function driver_asm_fclose(fp: *u8): void;
export extern "C" function driver_asm_fwrite(fp: *u8, data: *u8, len: i32): i32;
export extern "C" function driver_asm_fflush_stdout(): void;
export extern "C" function driver_asm_write_metric_o(path: *u8): i32;
export extern "C" function driver_asm_elf_ctx_calloc(): *u8;
export extern "C" function driver_asm_elf_ctx_free(p: *u8): void;
export extern "C" function driver_asm_tmp_path_slot(): *u8;
export extern "C" function driver_asm_collect_defines(argc: i32, argv: *u8): i32;
export extern "C" function driver_asm_defines_as_u8(): *u8;
export extern "C" function driver_asm_ndefines_get(): i32;
export extern "C" function driver_asm_bind_lib_roots(
  lib_roots: *u8, n: i32, n_out: *i32): *u8;
export extern "C" function driver_asm_argv0(argv: *u8): *u8;
export extern "C" function driver_asm_try_c_frontend_early(
  input_path: *u8, src: *u8, lib_roots: *u8, n_lib: i32, out_path: *u8): i32;
export extern "C" function driver_asm_try_c_typeck_precheck(
  input_path: *u8, src: *u8, lib_roots: *u8, n_lib: i32): i32;
export extern "C" function driver_asm_use_compiler_impl_c(): i32;
export extern "C" function driver_asm_work_reset(): void;
export extern "C" function driver_asm_work_p_get(i: i32): *u8;
export extern "C" function driver_asm_work_p_set(i: i32, v: *u8): void;
export extern "C" function driver_asm_work_i_get(i: i32): i32;
export extern "C" function driver_asm_work_i_set(i: i32, v: i32): void;
export extern "C" function driver_asm_work_z_get(i: i32): usize;
export extern "C" function driver_asm_work_z_set(i: i32, v: usize): void;
export extern "C" function driver_asm_work_cleanup(): void;

/* work pointer indices */
/** Work-slot index for entry path pointer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_path(): i32 { return 0; }
/** Work-slot index for preprocess source buffer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_src(): i32 { return 1; }
/** Work-slot index for output path pointer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_out_path(): i32 { return 2; }
/** Work-slot index for main parse arena.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_arena(): i32 { return 3; }
/** Work-slot index for main module pointer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_module(): i32 { return 4; }
/** Work-slot index for entry-dir buffer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_entry(): i32 { return 5; }
/** Work-slot index for dep source pointer table.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_dsrc(): i32 { return 6; }
/** Work-slot index for dep path pointer table.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_dpath(): i32 { return 7; }
/** Work-slot index for dep source-length table.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_dlens(): i32 { return 8; }
/** Work-slot index for dep arena pointer table.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_dar(): i32 { return 9; }
/** Work-slot index for dep module pointer table.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_dmod(): i32 { return 10; }
/** Work-slot index for codegen OutBuf.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_out(): i32 { return 11; }
/** Work-slot index for pipeline dep context.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_pctx(): i32 { return 12; }
/** Work-slot index for diagnostic kind scratch buffer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_kind(): i32 { return 13; }
/** Work-slot index for diagnostic code scratch buffer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_code(): i32 { return 14; }
/** Work-slot index for diagnostic message scratch buffer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_msg(): i32 { return 15; }
/** Work-slot index for lib-roots pointer table.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_lib(): i32 { return 16; }
/** Work-slot index for target triple string.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_target(): i32 { return 17; }
/** Work-slot index for argv pointer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_argv(): i32 { return 18; }
/** Work-slot index for asm FILE* / out handle.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_asm_out(): i32 { return 19; }
/** Work-slot index for ELF emit context.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_elf(): i32 { return 20; }
/** Work-slot index for define list.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_defs(): i32 { return 21; }
/** Work-slot index for temporary path buffer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ap_tmp(): i32 { return 22; }

/** Work-int index for n_lib_roots.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ai_nlib(): i32 { return 0; }
/** Work-int index for n_deps.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ai_ndeps(): i32 { return 1; }
/** Work-int index for module import count.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ai_nimp(): i32 { return 2; }
/** Work-int index for main function index.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ai_main(): i32 { return 3; }
/** Work-int index for emit ELF object flag.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ai_emit_elf(): i32 { return 4; }
/** Work-int index for want-exe flag.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ai_want_exe(): i32 { return 5; }
/** Work-int index for smoke summary flag.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ai_smoke(): i32 { return 6; }
/** Work-int index for n_defines.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ai_ndef(): i32 { return 7; }
/** Work-int index for exit/error code.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ai_ec(): i32 { return 9; }
/** Work-int index for entry-module-only flag.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function ai_entry_only(): i32 { return 11; }

/** Work-size index for source length.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function az_slen(): i32 { return 0; }
/** Work-size index for arena sizeof.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function az_asz(): i32 { return 1; }
/** Work-size index for module sizeof.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function az_msz(): i32 { return 2; }

/** Fill kind buffer with io error (byte writes; no string lit).
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_fill_kind_io(k: *u8): void {
  k[0] = 105; k[1] = 111; k[2] = 32; k[3] = 101; k[4] = 114; k[5] = 114;
  k[6] = 111; k[7] = 114; k[8] = 0;
}
/** Fill code buffer with IO001.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_fill_code_io001(c: *u8): void {
  c[0] = 73; c[1] = 79; c[2] = 48; c[3] = 48; c[4] = 49; c[5] = 0;
}
/** Fill kind buffer with preprocess error.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_fill_kind_pp(k: *u8): void {
  k[0] = 112; k[1] = 114; k[2] = 101; k[3] = 112; k[4] = 114; k[5] = 111;
  k[6] = 99; k[7] = 101; k[8] = 115; k[9] = 115; k[10] = 32; k[11] = 101;
  k[12] = 114; k[13] = 114; k[14] = 111; k[15] = 114; k[16] = 0;
}
/** Fill code buffer with PP002.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_fill_code_pp002(c: *u8): void {
  c[0] = 80; c[1] = 80; c[2] = 48; c[3] = 48; c[4] = 50; c[5] = 0;
}
/** Fill kind buffer with pipeline error.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_fill_kind_pipe(k: *u8): void {
  k[0] = 112; k[1] = 105; k[2] = 112; k[3] = 101; k[4] = 108; k[5] = 105;
  k[6] = 110; k[7] = 101; k[8] = 32; k[9] = 101; k[10] = 114; k[11] = 114;
  k[12] = 111; k[13] = 114; k[14] = 0;
}
/** Fill code buffer with XP001.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_fill_code_xp001(c: *u8): void {
  c[0] = 88; c[1] = 80; c[2] = 48; c[3] = 48; c[4] = 49; c[5] = 0;
}
/** Fill code buffer with XP005.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_fill_code_xp005(c: *u8): void {
  c[0] = 88; c[1] = 80; c[2] = 48; c[3] = 48; c[4] = 53; c[5] = 0;
}
/** Fill code buffer with XP006.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_fill_code_xp006(c: *u8): void {
  c[0] = 88; c[1] = 80; c[2] = 48; c[3] = 48; c[4] = 54; c[5] = 0;
}
/** Fill code buffer with XP008.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_fill_code_xp008(c: *u8): void {
  c[0] = 88; c[1] = 80; c[2] = 48; c[3] = 48; c[4] = 56; c[5] = 0;
}
/** Fill kind buffer with parse error.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_fill_kind_parse(k: *u8): void {
  k[0] = 112; k[1] = 97; k[2] = 114; k[3] = 115; k[4] = 101; k[5] = 32;
  k[6] = 101; k[7] = 114; k[8] = 114; k[9] = 111; k[10] = 114; k[11] = 0;
}
/** Fill code buffer with P001.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_fill_code_p001(c: *u8): void {
  c[0] = 80; c[1] = 48; c[2] = 48; c[3] = 49; c[4] = 0;
}
/** Fill kind buffer with codegen error.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_fill_kind_cg(k: *u8): void {
  k[0] = 99; k[1] = 111; k[2] = 100; k[3] = 101; k[4] = 103; k[5] = 101;
  k[6] = 110; k[7] = 32; k[8] = 101; k[9] = 114; k[10] = 114; k[11] = 111;
  k[12] = 114; k[13] = 0;
}
/** Fill code buffer with CG002.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_fill_code_cg002(c: *u8): void {
  c[0] = 67; c[1] = 71; c[2] = 48; c[3] = 48; c[4] = 50; c[5] = 0;
}
/** Fill kind buffer with build error.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_fill_kind_build(k: *u8): void {
  k[0] = 98; k[1] = 117; k[2] = 105; k[3] = 108; k[4] = 100; k[5] = 32;
  k[6] = 101; k[7] = 114; k[8] = 114; k[9] = 111; k[10] = 114; k[11] = 0;
}
/** Fill code buffer with BLD001.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_fill_code_bld001(c: *u8): void {
  c[0] = 66; c[1] = 76; c[2] = 68; c[3] = 48; c[4] = 48; c[5] = 49; c[6] = 0;
}
/** Fill message buffer with cannot read file.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_msg_cannot_read(m: *u8): void {
  m[0] = 99; m[1] = 97; m[2] = 110; m[3] = 110; m[4] = 111; m[5] = 116;
  m[6] = 32; m[7] = 114; m[8] = 101; m[9] = 97; m[10] = 100; m[11] = 32;
  m[12] = 102; m[13] = 105; m[14] = 108; m[15] = 101; m[16] = 0;
}
/** Fill message buffer with preprocess failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_msg_pp_failed(m: *u8): void {
  m[0] = 112; m[1] = 114; m[2] = 101; m[3] = 112; m[4] = 114; m[5] = 111;
  m[6] = 99; m[7] = 101; m[8] = 115; m[9] = 115; m[10] = 32; m[11] = 102;
  m[12] = 97; m[13] = 105; m[14] = 108; m[15] = 101; m[16] = 100; m[17] = 0;
}
/** Fill message buffer with asm pipeline allocation failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_msg_alloc_failed(m: *u8): void {
  m[0] = 46; m[1] = 120; m[2] = 32; m[3] = 112; m[4] = 105; m[5] = 112;
  m[6] = 101; m[7] = 108; m[8] = 105; m[9] = 110; m[10] = 101; m[11] = 32;
  m[12] = 97; m[13] = 108; m[14] = 108; m[15] = 111; m[16] = 99; m[17] = 32;
  m[18] = 102; m[19] = 97; m[20] = 105; m[21] = 108; m[22] = 101; m[23] = 100;
  m[24] = 0;
}
/** Fill message buffer with parse failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_msg_parse_failed(m: *u8): void {
  m[0] = 97; m[1] = 115; m[2] = 109; m[3] = 32; m[4] = 112; m[5] = 97;
  m[6] = 114; m[7] = 115; m[8] = 101; m[9] = 32; m[10] = 102; m[11] = 97;
  m[12] = 105; m[13] = 108; m[14] = 101; m[15] = 100; m[16] = 0;
}
/** Fill message buffer with dep alloc failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_msg_dep_alloc(m: *u8): void {
  m[0] = 100; m[1] = 101; m[2] = 112; m[3] = 32; m[4] = 97; m[5] = 108;
  m[6] = 108; m[7] = 111; m[8] = 99; m[9] = 32; m[10] = 102; m[11] = 97;
  m[12] = 105; m[13] = 108; m[14] = 101; m[15] = 100; m[16] = 0;
}
/** Fill message buffer with out/ctx alloc failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_msg_out_ctx(m: *u8): void {
  m[0] = 111; m[1] = 117; m[2] = 116; m[3] = 47; m[4] = 99; m[5] = 116;
  m[6] = 120; m[7] = 32; m[8] = 97; m[9] = 108; m[10] = 108; m[11] = 111;
  m[12] = 99; m[13] = 32; m[14] = 102; m[15] = 97; m[16] = 105; m[17] = 108;
  m[18] = 101; m[19] = 100; m[20] = 0;
}
/** Fill message buffer with dep prerun failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_msg_dep_prerun(m: *u8): void {
  m[0] = 100; m[1] = 101; m[2] = 112; m[3] = 32; m[4] = 112; m[5] = 114;
  m[6] = 101; m[7] = 114; m[8] = 117; m[9] = 110; m[10] = 32; m[11] = 102;
  m[12] = 97; m[13] = 105; m[14] = 108; m[15] = 101; m[16] = 100; m[17] = 0;
}
/** Fill message buffer with pipeline failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_msg_pipe_failed(m: *u8): void {
  m[0] = 46; m[1] = 120; m[2] = 32; m[3] = 112; m[4] = 105; m[5] = 112;
  m[6] = 101; m[7] = 108; m[8] = 105; m[9] = 110; m[10] = 101; m[11] = 32;
  m[12] = 102; m[13] = 97; m[14] = 105; m[15] = 108; m[16] = 101; m[17] = 100;
  m[18] = 0;
}
/** Fill message buffer with no functions.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_msg_no_funcs(m: *u8): void {
  m[0] = 110; m[1] = 111; m[2] = 32; m[3] = 102; m[4] = 117; m[5] = 110;
  m[6] = 99; m[7] = 116; m[8] = 105; m[9] = 111; m[10] = 110; m[11] = 115;
  m[12] = 0;
}
/** Fill message buffer with ELF emit failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_msg_elf_failed(m: *u8): void {
  m[0] = 97; m[1] = 115; m[2] = 109; m[3] = 95; m[4] = 99; m[5] = 111;
  m[6] = 100; m[7] = 101; m[8] = 103; m[9] = 101; m[10] = 110; m[11] = 32;
  m[12] = 102; m[13] = 97; m[14] = 105; m[15] = 108; m[16] = 101; m[17] = 100;
  m[18] = 0;
}
/** Fill message buffer with ld failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_msg_ld_failed(m: *u8): void {
  m[0] = 108; m[1] = 100; m[2] = 32; m[3] = 102; m[4] = 97; m[5] = 105;
  m[6] = 108; m[7] = 101; m[8] = 100; m[9] = 0;
}
/** Fill message buffer with ELF ctx alloc failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_msg_elf_ctx(m: *u8): void {
  m[0] = 69; m[1] = 76; m[2] = 70; m[3] = 32; m[4] = 99; m[5] = 116;
  m[6] = 120; m[7] = 32; m[8] = 97; m[9] = 108; m[10] = 108; m[11] = 111;
  m[12] = 99; m[13] = 32; m[14] = 102; m[15] = 97; m[16] = 105; m[17] = 108;
  m[18] = 101; m[19] = 100; m[20] = 0;
}
/** Fill message buffer with metric-only write note.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_msg_metric(m: *u8): void {
  m[0] = 109; m[1] = 101; m[2] = 116; m[3] = 114; m[4] = 105; m[5] = 99;
  m[6] = 32; m[7] = 119; m[8] = 114; m[9] = 105; m[10] = 116; m[11] = 101;
  m[12] = 32; m[13] = 102; m[14] = 97; m[15] = 105; m[16] = 108; m[17] = 101;
  m[18] = 100; m[19] = 0;
}

/** Dispatch kind/code/msg fillers by selector ids, then diag_report_with_code. kind_fn/code_fn/msg_fn are integer selectors for Cap residual. Uses work slots ap_kind/ap_code/ap_msg.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_diag(path: *u8, kind_fn: i32, code_fn: i32, msg_fn: i32): void {
  let k: *u8 = 0 as *u8;
  let c: *u8 = 0 as *u8;
  let m: *u8 = 0 as *u8;
  unsafe {
    k = driver_asm_work_p_get(ap_kind());
    c = driver_asm_work_p_get(ap_code());
    m = driver_asm_work_p_get(ap_msg());
  }
  if (k == 0 as *u8) {
    return;
  }
  if (kind_fn == 1) { rt_ab_fill_kind_io(k); }
  if (kind_fn == 2) { rt_ab_fill_kind_pp(k); }
  if (kind_fn == 3) { rt_ab_fill_kind_pipe(k); }
  if (kind_fn == 4) { rt_ab_fill_kind_parse(k); }
  if (kind_fn == 5) { rt_ab_fill_kind_cg(k); }
  if (kind_fn == 6) { rt_ab_fill_kind_build(k); }
  if (code_fn == 1) { rt_ab_fill_code_io001(c); }
  if (code_fn == 2) { rt_ab_fill_code_pp002(c); }
  if (code_fn == 3) { rt_ab_fill_code_xp001(c); }
  if (code_fn == 5) { rt_ab_fill_code_xp005(c); }
  if (code_fn == 6) { rt_ab_fill_code_xp006(c); }
  if (code_fn == 8) { rt_ab_fill_code_xp008(c); }
  if (code_fn == 9) { rt_ab_fill_code_p001(c); }
  if (code_fn == 10) { rt_ab_fill_code_cg002(c); }
  if (code_fn == 11) { rt_ab_fill_code_bld001(c); }
  if (msg_fn == 1) { rt_ab_msg_cannot_read(m); }
  if (msg_fn == 2) { rt_ab_msg_pp_failed(m); }
  if (msg_fn == 3) { rt_ab_msg_alloc_failed(m); }
  if (msg_fn == 5) { rt_ab_msg_parse_failed(m); }
  if (msg_fn == 6) { rt_ab_msg_dep_alloc(m); }
  if (msg_fn == 7) { rt_ab_msg_out_ctx(m); }
  if (msg_fn == 8) { rt_ab_msg_dep_prerun(m); }
  if (msg_fn == 9) { rt_ab_msg_pipe_failed(m); }
  if (msg_fn == 10) { rt_ab_msg_no_funcs(m); }
  if (msg_fn == 11) { rt_ab_msg_elf_failed(m); }
  if (msg_fn == 12) { rt_ab_msg_ld_failed(m); }
  if (msg_fn == 13) { rt_ab_msg_elf_ctx(m); }
  if (msg_fn == 14) { rt_ab_msg_metric(m); }
  unsafe {
    diag_report_with_code(path, 0, 0, k, c, m, 0 as *u8);
  }
}

/** Step: read source + preprocess into work slots. Returns 0 ok / 1 fail.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_step_read_pp(): i32 {
  let path: *u8 = 0 as *u8;
  let raw: *u8 = 0 as *u8;
  let raw_len: usize = 0;
  let src: *u8 = 0 as *u8;
  let src_len: usize = 0;
  let defs: *u8 = 0 as *u8;
  let ndef: i32 = 0;
  let rc: i32 = 0;
  unsafe {
    path = driver_asm_work_p_get(ap_path());
    ndef = driver_asm_work_i_get(ai_ndef());
    defs = driver_asm_work_p_get(ap_defs());
    raw = runtime_read_file_malloc(path, &raw_len);
  }
  if (raw == 0 as *u8) {
    rt_ab_diag(path, 1, 1, 1);
    return 1;
  }
  unsafe {
    pipeline_diag_emitted_reset();
    src = shux_preprocess_with_path(raw, raw_len, path, defs, ndef, &src_len);
    free(raw);
  }
  if (src == 0 as *u8) {
    unsafe {
      rc = pipeline_diag_emitted_get();
    }
    if (rc == 0) {
      rt_ab_diag(path, 2, 2, 2);
    }
    return 1;
  }
  unsafe {
    driver_asm_work_p_set(ap_src(), src);
    driver_asm_work_z_set(az_slen(), src_len);
    diag_set_file(path, src, src_len);
  }
  return 0;
}

/** Step: early exits (C frontend precheck / metric / env). Returns 0 ok / 1 fail / special.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_step_early(): i32 {
  let path: *u8 = 0 as *u8;
  let src: *u8 = 0 as *u8;
  let lib: *u8 = 0 as *u8;
  let nlib: i32 = 0;
  let outp: *u8 = 0 as *u8;
  let rc: i32 = 0;
  unsafe {
    path = driver_asm_work_p_get(ap_path());
    src = driver_asm_work_p_get(ap_src());
    lib = driver_asm_work_p_get(ap_lib());
    nlib = driver_asm_work_i_get(ai_nlib());
    outp = driver_asm_work_p_get(ap_out_path());
    rc = driver_asm_try_c_frontend_early(path, src, lib, nlib, outp);
  }
  if (rc == 0 - 2) {
    return 0;
  }
  unsafe {
    driver_asm_work_i_set(ai_ec(), rc);
  }
  return 2;
}

/** Step: parse main module into arena/module work slots. Returns 0 ok / 1 fail.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_step_parse(): i32 {
  let path: *u8 = 0 as *u8;
  let src: *u8 = 0 as *u8;
  let src_len: usize = 0;
  let asz: usize = 0;
  let msz: usize = 0;
  let arena: *u8 = 0 as *u8;
  let module: *u8 = 0 as *u8;
  let main_idx: i32 = 0;
  let pr_ok: i32 = 0;
  let outp: *u8 = 0 as *u8;
  let rc: i32 = 0;
  let nimp: i32 = 0;
  let entry: *u8 = 0 as *u8;
  unsafe {
    path = driver_asm_work_p_get(ap_path());
    src = driver_asm_work_p_get(ap_src());
    src_len = driver_asm_work_z_get(az_slen());
    outp = driver_asm_work_p_get(ap_out_path());
    asz = pipeline_sizeof_arena();
    msz = pipeline_sizeof_module();
    arena = malloc(asz);
    module = malloc(msz);
  }
  if (arena == 0 as *u8) {
    if (module != 0 as *u8) {
      unsafe { free(module); }
    }
    rt_ab_diag(0 as *u8, 3, 5, 3);
    return 1;
  }
  if (module == 0 as *u8) {
    unsafe { free(arena); }
    rt_ab_diag(0 as *u8, 3, 5, 3);
    return 1;
  }
  unsafe {
    memset(arena, 0, asz);
    memset(module, 0, msz);
    parser_parse_into_init(module, arena);
    pr_ok = driver_parse_into_buf_rc(arena, module, src, src_len as i32, &main_idx);
  }
  if (pr_ok != 0) {
    unsafe {
      rc = runtime_report_precise_parse_failure_if_known(path, src, src_len);
    }
    if (rc == 0) {
      rt_ab_diag(path, 4, 9, 5);
    }
    unsafe {
      free(arena);
      free(module);
    }
    return 1;
  }
  unsafe {
    parser_parse_into_set_main_index(module, main_idx);
    driver_set_pipeline_entry_source_len(src_len);
    driver_asm_work_p_set(ap_arena(), arena);
    driver_asm_work_p_set(ap_module(), module);
    driver_asm_work_z_set(az_asz(), asz);
    driver_asm_work_z_set(az_msz(), msz);
    driver_asm_work_i_set(ai_main(), main_idx);
  }
  unsafe {
    rc = driver_asm_parse_metric_only_from_env();
  }
  if (rc != 0) {
    if (outp != 0 as *u8) {
      unsafe {
        driver_diagnostic_after_entry_parse(driver_get_module_num_funcs(module));
        driver_diagnostic_after_entry_parse_module(module);
        rc = driver_asm_write_metric_o(outp);
      }
      if (rc != 0) {
        rt_ab_diag(outp, 1, 1, 14);
        return 1;
      }
      unsafe {
        driver_asm_work_i_set(ai_ec(), 0);
      }
      return 2;
    }
  }
  unsafe {
    nimp = parser_get_module_num_imports(module);
    entry = driver_entry_dir_slot();
    shux_get_entry_dir(path, entry, 512 as usize);
    driver_asm_work_p_set(ap_entry(), entry);
    driver_asm_work_i_set(ai_nimp(), nimp);
  }
  return 0;
}

/** Step: load direct/transitive deps into work tables. Returns 0 ok / 1 fail.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_step_load_deps(): i32 {
  let module: *u8 = 0 as *u8;
  let lib: *u8 = 0 as *u8;
  let nlib: i32 = 0;
  let entry: *u8 = 0 as *u8;
  let defs: *u8 = 0 as *u8;
  let ndef: i32 = 0;
  let nimp: i32 = 0;
  let asz: usize = 0;
  let msz: usize = 0;
  let ds: *u8 = 0 as *u8;
  let dp: *u8 = 0 as *u8;
  let dl: *u8 = 0 as *u8;
  let n_deps: i32 = 0;
  let skip_load: i32 = 0;
  let rc: i32 = 0;
  let cls: *u8 = 0 as *u8;
  let clens: *u8 = 0 as *u8;
  let cpaths: *u8 = 0 as *u8;
  let n_closure: i32 = 0;
  let rev: i32 = 0;
  let o: i32 = 0;
  let ts: *u8 = 0 as *u8;
  let tl: usize = 0;
  let tp: *u8 = 0 as *u8;
  unsafe {
    module = driver_asm_work_p_get(ap_module());
    lib = driver_asm_work_p_get(ap_lib());
    nlib = driver_asm_work_i_get(ai_nlib());
    entry = driver_asm_work_p_get(ap_entry());
    defs = driver_asm_work_p_get(ap_defs());
    ndef = driver_asm_work_i_get(ai_ndef());
    nimp = driver_asm_work_i_get(ai_nimp());
    asz = driver_asm_work_z_get(az_asz());
    msz = driver_asm_work_z_get(az_msz());
    skip_load = 0;
    if (driver_asm_entry_module_only_from_env() != 0) {
      if (driver_asm_build_skip_typeck() != 0) {
        skip_load = 1;
      }
    }
  }
  if (nimp <= 0) {
    unsafe {
      driver_asm_work_i_set(ai_ndeps(), 0);
    }
    return 0;
  }
  if (nimp > 32) {
    unsafe {
      driver_asm_work_i_set(ai_ndeps(), 0);
    }
    return 0;
  }
  unsafe {
    ds = driver_ptr_table_calloc(128);
    dp = driver_ptr_table_calloc(128);
    dl = driver_size_table_calloc(128);
  }
  if (ds == 0 as *u8) {
    return 1;
  }
  if (dp == 0 as *u8) {
    unsafe { free(ds); }
    return 1;
  }
  if (dl == 0 as *u8) {
    unsafe { free(ds); free(dp); }
    return 1;
  }
  if (skip_load != 0) {
    unsafe {
      rc = shux_load_direct_imports_for_asm_layout(
        module, lib, nlib, entry, defs, ndef, ds, dl, dp, &n_deps);
    }
    if (rc != 0) {
      unsafe {
        free(ds);
        free(dp);
        free(dl);
      }
      return 1;
    }
  } else {
    unsafe {
      cls = driver_ptr_table_calloc(128);
      clens = driver_size_table_calloc(128);
      cpaths = driver_ptr_table_calloc(128);
    }
    if (cls == 0 as *u8) {
      unsafe { free(ds); free(dp); free(dl); }
      return 1;
    }
    if (clens == 0 as *u8) {
      unsafe { free(ds); free(dp); free(dl); free(cls); }
      return 1;
    }
    if (cpaths == 0 as *u8) {
      unsafe { free(ds); free(dp); free(dl); free(cls); free(clens); }
      return 1;
    }
    unsafe {
      rc = shux_collect_deps_transitive(
        module, asz, msz, lib, nlib, entry, defs, ndef, cls, clens, cpaths, &n_closure);
    }
    if (rc != 0) {
      unsafe {
        free(ds); free(dp); free(dl); free(cls); free(clens); free(cpaths);
      }
      return 1;
    }
    rev = 0;
    while (rev < n_closure / 2) {
      o = n_closure - 1 - rev;
      unsafe {
        ts = driver_ptr_table_get(cls, rev);
        driver_ptr_table_set(cls, rev, driver_ptr_table_get(cls, o));
        driver_ptr_table_set(cls, o, ts);
        tl = driver_size_table_get(clens, rev);
        driver_size_table_set(clens, rev, driver_size_table_get(clens, o));
        driver_size_table_set(clens, o, tl);
        tp = driver_ptr_table_get(cpaths, rev);
        driver_ptr_table_set(cpaths, rev, driver_ptr_table_get(cpaths, o));
        driver_ptr_table_set(cpaths, o, tp);
      }
      rev = rev + 1;
    }
    unsafe {
      rc = shux_merge_direct_then_transitive_deps(
        module, nimp, cls, clens, cpaths, n_closure, ds, dl, dp, &n_deps);
    }
    if (rc != 0) {
      while (n_closure > 0) {
        n_closure = n_closure - 1;
        unsafe {
          free(driver_ptr_table_get(cls, n_closure));
          free(driver_ptr_table_get(cpaths, n_closure));
        }
      }
      unsafe {
        free(ds); free(dp); free(dl); free(cls); free(clens); free(cpaths);
      }
      return 1;
    }
    unsafe {
      free(cls);
      free(clens);
      free(cpaths);
    }
  }
  unsafe {
    driver_asm_work_p_set(ap_dsrc(), ds);
    driver_asm_work_p_set(ap_dpath(), dp);
    driver_asm_work_p_set(ap_dlens(), dl);
    driver_asm_work_i_set(ai_ndeps(), n_deps);
  }
  return 0;
}

/** Step: open output path / prepare elf or exe layout. Returns 0 ok / 1 fail.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_step_open_out(): i32 {
  let path: *u8 = 0 as *u8;
  let outp: *u8 = 0 as *u8;
  let target: *u8 = 0 as *u8;
  let lib: *u8 = 0 as *u8;
  let nlib: i32 = 0;
  let entry: *u8 = 0 as *u8;
  let module: *u8 = 0 as *u8;
  let n_deps: i32 = 0;
  let smoke: i32 = 0;
  let want_exe: i32 = 0;
  let emit_elf: i32 = 0;
  let asm_out: *u8 = 0 as *u8;
  let tmp: *u8 = 0 as *u8;
  let elf: *u8 = 0 as *u8;
  let out_buf: *u8 = 0 as *u8;
  let pctx: *u8 = 0 as *u8;
  let da: *u8 = 0 as *u8;
  let dm: *u8 = 0 as *u8;
  let asz: usize = 0;
  let msz: usize = 0;
  let j: i32 = 0;
  let ar: *u8 = 0 as *u8;
  let mo: *u8 = 0 as *u8;
  let nf: i32 = 0;
  let eo: i32 = 0;
  unsafe {
    path = driver_asm_work_p_get(ap_path());
    outp = driver_asm_work_p_get(ap_out_path());
    target = driver_asm_work_p_get(ap_target());
    lib = driver_asm_work_p_get(ap_lib());
    nlib = driver_asm_work_i_get(ai_nlib());
    entry = driver_asm_work_p_get(ap_entry());
    module = driver_asm_work_p_get(ap_module());
    n_deps = driver_asm_work_i_get(ai_ndeps());
    asz = driver_asm_work_z_get(az_asz());
    msz = driver_asm_work_z_get(az_msz());
    driver_typeck_ndep_set(0);
  }
  if (outp == 0 as *u8) {
    smoke = 1;
    want_exe = 0;
    emit_elf = 0;
  } else {
    smoke = 0;
    unsafe {
      want_exe = shux_output_want_exe(outp);
    }
    if (want_exe != 0) {
      unsafe {
        tmp = driver_asm_tmp_path_slot();
        asm_out = driver_asm_mkstemp_fdopen(tmp);
      }
      if (asm_out == 0 as *u8) {
        unsafe {
          runtime_diag_errno_path(path, 0 as *u8, 0 as *u8, tmp);
        }
        return 1;
      }
      emit_elf = 1;
      unsafe {
        driver_asm_work_p_set(ap_tmp(), tmp);
      }
    } else {
      unsafe {
        asm_out = driver_asm_fopen_wb(outp);
      }
      if (asm_out == 0 as *u8) {
        unsafe {
          runtime_diag_errno_path(outp, 0 as *u8, 0 as *u8, outp);
        }
        return 1;
      }
      unsafe {
        emit_elf = shux_output_is_elf_o(outp);
      }
    }
  }
  unsafe {
    driver_asm_work_i_set(ai_smoke(), smoke);
    driver_asm_work_i_set(ai_want_exe(), want_exe);
    driver_asm_work_i_set(ai_emit_elf(), emit_elf);
    driver_asm_work_p_set(ap_asm_out(), asm_out);
  }
  if (emit_elf != 0) {
    unsafe {
      elf = driver_asm_elf_ctx_calloc();
    }
    if (elf == 0 as *u8) {
      rt_ab_diag(0 as *u8, 3, 5, 13);
      return 1;
    }
    unsafe {
      driver_asm_work_p_set(ap_elf(), elf);
    }
  }
  if (n_deps > 0) {
    unsafe {
      da = driver_ptr_table_calloc(n_deps);
      dm = driver_ptr_table_calloc(n_deps);
    }
    if (da == 0 as *u8) {
      return 1;
    }
    if (dm == 0 as *u8) {
      unsafe { free(da); }
      return 1;
    }
    j = 0;
    while (j < n_deps) {
      unsafe {
        ar = malloc(asz);
        mo = malloc(msz);
      }
      if (ar == 0 as *u8) {
        if (mo != 0 as *u8) {
          unsafe { free(mo); }
        }
        rt_ab_diag(0 as *u8, 3, 5, 6);
        unsafe {
          driver_asm_work_p_set(ap_dar(), da);
          driver_asm_work_p_set(ap_dmod(), dm);
        }
        return 1;
      }
      if (mo == 0 as *u8) {
        unsafe { free(ar); }
        rt_ab_diag(0 as *u8, 3, 5, 6);
        unsafe {
          driver_asm_work_p_set(ap_dar(), da);
          driver_asm_work_p_set(ap_dmod(), dm);
        }
        return 1;
      }
      unsafe {
        memset(ar, 0, asz);
        memset(mo, 0, msz);
        driver_ptr_table_set(da, j, ar);
        driver_ptr_table_set(dm, j, mo);
      }
      j = j + 1;
    }
    unsafe {
      driver_asm_work_p_set(ap_dar(), da);
      driver_asm_work_p_set(ap_dmod(), dm);
    }
  }
  unsafe {
    out_buf = driver_codegen_outbuf_calloc();
    pctx = driver_pipeline_dep_ctx_calloc();
  }
  if (out_buf == 0 as *u8) {
    if (pctx != 0 as *u8) {
      unsafe { pipeline_dep_ctx_heap_destroy(pctx); }
    }
    rt_ab_diag(0 as *u8, 3, 6, 7);
    return 1;
  }
  if (pctx == 0 as *u8) {
    unsafe { driver_codegen_outbuf_free(out_buf); }
    rt_ab_diag(0 as *u8, 3, 6, 7);
    return 1;
  }
  unsafe {
    driver_asm_work_p_set(ap_out(), out_buf);
    driver_asm_work_p_set(ap_pctx(), pctx);
    shux_pipeline_fill_ctx_path_buffers(pctx, entry, lib, nlib);
    driver_pipeline_dep_ctx_set_use_asm(pctx, 0);
    driver_asm_pctx_apply_host_defaults(pctx, target, emit_elf);
  }
  eo = 0;
  if (emit_elf != 0) {
    unsafe {
      eo = driver_asm_entry_module_only_from_env();
    }
  }
  unsafe {
    if (want_exe != 0) {
      if (n_deps > 0) {
        if (smoke == 0) {
          if (driver_asm_build_skip_typeck() != 0) {
            eo = 1;
          }
        }
      }
    }
    if (emit_elf != 0) {
      if (n_deps == 0) {
        if (smoke == 0) {
          if (driver_asm_build_skip_typeck() == 0) {
            nf = driver_get_module_num_funcs(module);
            if (nf <= 1) {
              eo = 1;
            }
          }
        }
      }
    }
    if (emit_elf != 0) {
      if (n_deps > 0) {
        if (smoke == 0) {
          if (driver_asm_build_skip_typeck() == 0) {
            if (driver_freestanding_get() == 0) {
              if (pipeline_asm_user_deps_need_coemit(
                    driver_asm_work_p_get(ap_dpath()), n_deps) == 0) {
                eo = 1;
              }
            }
          }
        }
      }
    }
    driver_pipeline_dep_ctx_set_asm_entry_module_only(pctx, eo);
    driver_asm_work_i_set(ai_entry_only(), eo);
    driver_dep_seeded_clear_all();
  }
  return 0;
}

/** Step: dep prerun (parse/typeck) + publish slots. Returns 0 ok / 1 fail.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_step_prerun(): i32 {
  let n_deps: i32 = 0;
  let emit_elf: i32 = 0;
  let smoke: i32 = 0;
  let eo: i32 = 0;
  let j: i32 = 0;
  let da: *u8 = 0 as *u8;
  let dm: *u8 = 0 as *u8;
  let ds: *u8 = 0 as *u8;
  let dp: *u8 = 0 as *u8;
  let dl: *u8 = 0 as *u8;
  let lib: *u8 = 0 as *u8;
  let nlib: i32 = 0;
  let entry: *u8 = 0 as *u8;
  let pctx: *u8 = 0 as *u8;
  let one: *u8 = 0 as *u8;
  let dep_out: *u8 = 0 as *u8;
  let dep_src: *u8 = 0 as *u8;
  let dep_len: usize = 0;
  let dep_path: *u8 = 0 as *u8;
  let prerun_dir: *u8 = 0 as *u8;
  let ec_loop: i32 = 0;
  let skip_tk: i32 = 0;
  unsafe {
    n_deps = driver_asm_work_i_get(ai_ndeps());
    emit_elf = driver_asm_work_i_get(ai_emit_elf());
    smoke = driver_asm_work_i_get(ai_smoke());
    eo = driver_asm_work_i_get(ai_entry_only());
    da = driver_asm_work_p_get(ap_dar());
    dm = driver_asm_work_p_get(ap_dmod());
    ds = driver_asm_work_p_get(ap_dsrc());
    dp = driver_asm_work_p_get(ap_dpath());
    dl = driver_asm_work_p_get(ap_dlens());
    lib = driver_asm_work_p_get(ap_lib());
    nlib = driver_asm_work_i_get(ai_nlib());
    entry = driver_asm_work_p_get(ap_entry());
    pctx = driver_asm_work_p_get(ap_pctx());
  }
  if (n_deps <= 0) {
    return 0;
  }
  unsafe {
    skip_tk = driver_asm_build_skip_typeck();
  }
  if (emit_elf != 0) {
    if (eo != 0) {
      if (skip_tk != 0) {
        j = 0;
        while (j < n_deps) {
          unsafe {
            dep_src = driver_ptr_table_get(ds, j);
            dep_len = driver_size_table_get(dl, j);
            dep_path = driver_ptr_table_get(dp, j);
            ec_loop = shux_pipeline_dep_prerun_parse_only(
              driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
              dep_src, dep_len);
          }
          if (ec_loop != 0) {
            rt_ab_diag(dep_path, 4, 9, 5);
            return 1;
          }
          unsafe {
            driver_dep_publish_slot(
              j, driver_ptr_table_get(da, j), driver_ptr_table_get(dm, j), dep_path);
          }
          j = j + 1;
        }
        return 0;
      }
    }
  }
  j = 0;
  while (j < n_deps) {
    unsafe {
      one = driver_pipeline_dep_ctx_calloc();
      dep_out = driver_codegen_outbuf_calloc();
      dep_src = driver_ptr_table_get(ds, j);
      dep_len = driver_size_table_get(dl, j);
      dep_path = driver_ptr_table_get(dp, j);
    }
    if (one == 0 as *u8) {
      if (dep_out != 0 as *u8) {
        unsafe { driver_codegen_outbuf_free(dep_out); }
      }
      rt_ab_diag(0 as *u8, 3, 6, 7);
      return 1;
    }
    if (dep_out == 0 as *u8) {
      unsafe { pipeline_dep_ctx_heap_destroy(one); }
      rt_ab_diag(0 as *u8, 3, 6, 7);
      return 1;
    }
    unsafe {
      prerun_dir = shux_dep_prerun_entry_dir(entry, lib, nlib);
      shux_pipeline_fill_ctx_path_buffers(one, prerun_dir, lib, nlib);
      shux_pipeline_one_ctx_for_dep_prerun(one, j, dm, da, dp, n_deps, dep_src, dep_len);
    }
    if (smoke != 0) {
      unsafe {
        ec_loop = shux_pipeline_dep_prerun_parse_only(
          driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j), dep_src, dep_len);
      }
    } else {
      if (emit_elf != 0) {
        unsafe {
          if (shux_asm_user_std_dep_skip_x_typeck(dep_path) != 0) {
            ec_loop = shux_pipeline_dep_prerun_parse_only(
              driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j), dep_src, dep_len);
          } else {
            if (shux_asm_user_dep_parse_skip_typeck_path(dep_path) != 0) {
              ec_loop = shux_pipeline_dep_prerun_parse_skip_typeck(
                driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
                dep_src, dep_len, dep_out, one);
              if (ec_loop == 0) {
                if (shux_asm_user_std_net_dep_path(dep_path) != 0) {
                  pipeline_asm_seed_std_net_struct_layouts(driver_ptr_table_get(dm, j));
                }
              }
            } else {
              if (eo != 0) {
                if (skip_tk == 0) {
                  ec_loop = shux_pipeline_dep_prerun_parse_only(
                    driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
                    dep_src, dep_len);
                } else {
                  if (driver_asm_use_compiler_impl_c() != 0) {
                    if (skip_tk == 0) {
                      ec_loop = shux_pipeline_dep_prerun_parse_only(
                        driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
                        dep_src, dep_len);
                    } else {
                      ec_loop = shux_pipeline_dep_prerun_for_asm_module_o(
                        driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
                        dep_src, dep_len, dep_out, one);
                    }
                  } else {
                    ec_loop = shux_pipeline_dep_prerun_for_asm_module_o(
                      driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
                      dep_src, dep_len, dep_out, one);
                  }
                }
              } else {
                if (driver_asm_use_compiler_impl_c() != 0) {
                  if (skip_tk == 0) {
                    ec_loop = shux_pipeline_dep_prerun_parse_only(
                      driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
                      dep_src, dep_len);
                  } else {
                    ec_loop = shux_pipeline_dep_prerun_for_asm_module_o(
                      driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
                      dep_src, dep_len, dep_out, one);
                  }
                } else {
                  ec_loop = shux_pipeline_dep_prerun_for_asm_module_o(
                    driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
                    dep_src, dep_len, dep_out, one);
                }
              }
            }
          }
        }
      } else {
        unsafe {
          ec_loop = shux_pipeline_dep_prerun_for_asm_module_o(
            driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
            dep_src, dep_len, dep_out, one);
        }
      }
    }
    unsafe {
      pipeline_dep_ctx_heap_destroy(one);
      driver_codegen_outbuf_free(dep_out);
    }
    if (ec_loop != 0) {
      rt_ab_diag(dep_path, 3, 8, 8);
      return 1;
    }
    unsafe {
      driver_dep_publish_slot(
        j, driver_ptr_table_get(da, j), driver_ptr_table_get(dm, j), dep_path);
    }
    j = j + 1;
  }
  return 0;
}

/** Step: run x pipeline large-stack for asm backend. Returns 0 ok / 1 fail.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_step_pipeline(): i32 {
  let path: *u8 = 0 as *u8;
  let src: *u8 = 0 as *u8;
  let src_len: usize = 0;
  let arena: *u8 = 0 as *u8;
  let module: *u8 = 0 as *u8;
  let n_deps: i32 = 0;
  let da: *u8 = 0 as *u8;
  let dm: *u8 = 0 as *u8;
  let dp: *u8 = 0 as *u8;
  let out_buf: *u8 = 0 as *u8;
  let pctx: *u8 = 0 as *u8;
  let lib: *u8 = 0 as *u8;
  let nlib: i32 = 0;
  let smoke: i32 = 0;
  let j: i32 = 0;
  let ec: i32 = 0;
  let pre: i32 = 0;
  unsafe {
    path = driver_asm_work_p_get(ap_path());
    src = driver_asm_work_p_get(ap_src());
    src_len = driver_asm_work_z_get(az_slen());
    arena = driver_asm_work_p_get(ap_arena());
    module = driver_asm_work_p_get(ap_module());
    n_deps = driver_asm_work_i_get(ai_ndeps());
    da = driver_asm_work_p_get(ap_dar());
    dm = driver_asm_work_p_get(ap_dmod());
    dp = driver_asm_work_p_get(ap_dpath());
    out_buf = driver_asm_work_p_get(ap_out());
    pctx = driver_asm_work_p_get(ap_pctx());
    lib = driver_asm_work_p_get(ap_lib());
    nlib = driver_asm_work_i_get(ai_nlib());
    smoke = driver_asm_work_i_get(ai_smoke());
    driver_typeck_ndep_set(n_deps);
  }
  j = 0;
  while (j < n_deps) {
    unsafe {
      driver_typeck_dep_ptrs_set(
        j, driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j));
    }
    j = j + 1;
  }
  unsafe {
    shux_pipeline_pctx_seed_dep_slots(pctx, dm, da, dp, n_deps);
    pipeline_set_dep_slots(da, dm);
    driver_dep_seed_slots(da, dm, n_deps);
    codegen_set_dep_slots_for_x_pipeline(dm, dp, n_deps);
    codegen_set_preamble_has_core_option_result(1);
    driver_pipeline_dep_ctx_set_entry_already_parsed(pctx, 1);
    pre = driver_asm_try_c_typeck_precheck(path, src, lib, nlib);
  }
  if (pre == 1) {
    return 1;
  }
  if (smoke == 0) {
    if (n_deps > 0) {
      unsafe {
        driver_x_pipeline_skip_typeck_set(1);
      }
    }
    unsafe {
      driver_x_pipeline_skip_codegen_set(1);
    }
  } else {
    if (n_deps > 0) {
      unsafe {
        if (driver_deps_are_std_core_closure_only(dp, n_deps) != 0) {
          driver_x_pipeline_skip_typeck_set(1);
        }
      }
    }
    unsafe {
      driver_x_pipeline_skip_codegen_set(1);
    }
  }
  unsafe {
    ec = shux_pipeline_run_x_pipeline_large_stack(
      module, arena, src, src_len, out_buf, pctx);
    driver_x_pipeline_skip_typeck_set(0);
    driver_x_pipeline_skip_codegen_set(0);
    driver_pipeline_dep_ctx_set_use_asm(pctx, 1);
    driver_asm_work_i_set(ai_ec(), ec);
  }
  return 0;
}

/** Step: write object/exe, ld if needed, cleanup. Returns 0 ok / 1 fail.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_ab_step_finish(): i32 {
  let path: *u8 = 0 as *u8;
  let outp: *u8 = 0 as *u8;
  let target: *u8 = 0 as *u8;
  let argv: *u8 = 0 as *u8;
  let lib: *u8 = 0 as *u8;
  let nlib: i32 = 0;
  let arena: *u8 = 0 as *u8;
  let module: *u8 = 0 as *u8;
  let n_deps: i32 = 0;
  let da: *u8 = 0 as *u8;
  let dm: *u8 = 0 as *u8;
  let dp: *u8 = 0 as *u8;
  let out_buf: *u8 = 0 as *u8;
  let pctx: *u8 = 0 as *u8;
  let asm_out: *u8 = 0 as *u8;
  let elf: *u8 = 0 as *u8;
  let tmp: *u8 = 0 as *u8;
  let smoke: i32 = 0;
  let emit_elf: i32 = 0;
  let want_exe: i32 = 0;
  let ec: i32 = 0;
  let out_len: i32 = 0;
  let out_data: *u8 = 0 as *u8;
  let j: i32 = 0;
  let nf: i32 = 0;
  let diag_em: i32 = 0;
  let elf_ec: i32 = 0;
  let is_obj: i32 = 0;
  let macho: i32 = 0;
  let coff: i32 = 0;
  let argv0: *u8 = 0 as *u8;
  let ld_ok: i32 = 0;
  let exe_out: *u8 = 0 as *u8;
  unsafe {
    path = driver_asm_work_p_get(ap_path());
    outp = driver_asm_work_p_get(ap_out_path());
    target = driver_asm_work_p_get(ap_target());
    argv = driver_asm_work_p_get(ap_argv());
    lib = driver_asm_work_p_get(ap_lib());
    nlib = driver_asm_work_i_get(ai_nlib());
    arena = driver_asm_work_p_get(ap_arena());
    module = driver_asm_work_p_get(ap_module());
    n_deps = driver_asm_work_i_get(ai_ndeps());
    da = driver_asm_work_p_get(ap_dar());
    dm = driver_asm_work_p_get(ap_dmod());
    dp = driver_asm_work_p_get(ap_dpath());
    out_buf = driver_asm_work_p_get(ap_out());
    pctx = driver_asm_work_p_get(ap_pctx());
    asm_out = driver_asm_work_p_get(ap_asm_out());
    elf = driver_asm_work_p_get(ap_elf());
    tmp = driver_asm_work_p_get(ap_tmp());
    smoke = driver_asm_work_i_get(ai_smoke());
    emit_elf = driver_asm_work_i_get(ai_emit_elf());
    want_exe = driver_asm_work_i_get(ai_want_exe());
    ec = driver_asm_work_i_get(ai_ec());
    out_len = driver_codegen_outbuf_len(out_buf);
    out_data = driver_codegen_outbuf_data(out_buf);
  }
  if (smoke != 0) {
    unsafe {
      nf = driver_get_module_num_funcs(module);
      diag_em = driver_check_diag_emitted_get();
    }
    if (ec != 0) {
      if (diag_em == 0) {
        rt_ab_diag(path, 3, 3, 9);
      }
    } else {
      if (nf <= 0) {
        rt_ab_diag(path, 4, 9, 10);
      } else {
        unsafe {
          if (driver_check_only_get() != 0) {
            if (diag_em == 0) {
              driver_print_x_smoke_summary(module, out_len as usize);
              if (path != 0 as *u8) {
                driver_print_check_ok(path);
              }
            }
          } else {
            driver_print_x_smoke_summary(module, out_len as usize);
          }
        }
      }
    }
    unsafe {
      driver_dep_seeded_clear_all();
      driver_typeck_ndep_set(0);
    }
    if (ec != 0) {
      return 1;
    }
    if (nf <= 0) {
      return 1;
    }
    unsafe {
      if (driver_check_only_get() != 0) {
        if (diag_em != 0) {
          return 1;
        }
      }
    }
    return 0;
  }
  if (ec == 0) {
    if (out_len > 0) {
      /* fall through emit */
    } else {
      if (emit_elf != 0) {
        /* fall through emit */
      } else {
        if (want_exe != 0) {
          if (tmp != 0 as *u8) {
            unsafe { unlink(tmp); }
          }
        }
        if (ec != 0) {
          unsafe {
            driver_unlink_failed_output(outp);
          }
          rt_ab_diag(path, 3, 3, 9);
        }
        unsafe {
          driver_dep_seeded_clear_all();
          codegen_set_dep_slots_for_x_pipeline(0 as *u8, 0 as *u8, 0);
        }
        return 1;
      }
    }
    if (emit_elf != 0) {
      if (elf != 0 as *u8) {
        unsafe {
          is_obj = shux_asm_out_buf_is_object(out_data, out_len as usize);
        }
        if (is_obj == 0) {
          if (n_deps > 0) {
            j = 0;
            while (j < n_deps) {
              unsafe {
                driver_dep_publish_slot(
                  j, driver_ptr_table_get(da, j), driver_ptr_table_get(dm, j),
                  driver_ptr_table_get(dp, j));
                driver_typeck_dep_ptrs_set(
                  j, driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j));
              }
              j = j + 1;
            }
            unsafe {
              driver_typeck_ndep_set(n_deps);
              pipeline_set_dep_slots(da, dm);
              driver_dep_seed_slots(da, dm, n_deps);
              shux_pipeline_pctx_seed_dep_slots(pctx, dm, da, dp, n_deps);
              if (driver_asm_entry_module_only_from_env() == 0) {
                if (pipeline_asm_user_deps_need_coemit(dp, n_deps) != 0) {
                  driver_pipeline_dep_ctx_set_asm_entry_module_only(pctx, 0);
                }
              }
              driver_pipeline_dep_ctx_set_use_asm(pctx, 1);
            }
          }
          unsafe {
            shux_driver_asm_prepare_entry_elf_emit(module, arena, pctx);
            elf_ec = shux_asm_codegen_elf_o_large_stack(module, arena, pctx, elf, out_buf);
            out_len = driver_codegen_outbuf_len(out_buf);
            out_data = driver_codegen_outbuf_data(out_buf);
          }
          if (elf_ec != 0) {
            rt_ab_diag(path, 5, 10, 11);
            if (elf != 0 as *u8) {
              unsafe {
                runtime_pipeline_elf_ctx_diag_note(elf);
              }
            }
            unsafe {
              driver_unlink_failed_output(outp);
            }
            return 1;
          }
          if (out_len <= 0) {
            rt_ab_diag(path, 5, 10, 11);
            unsafe {
              driver_unlink_failed_output(outp);
            }
            return 1;
          }
        }
      }
    }
    unsafe {
      driver_asm_fwrite(asm_out, out_data, out_len);
    }
    if (asm_out == 0 as *u8) {
      unsafe {
        driver_asm_fflush_stdout();
      }
    }
    unsafe {
      driver_asm_fclose(asm_out);
      driver_asm_work_p_set(ap_asm_out(), 0 as *u8);
      if (elf != 0 as *u8) {
        driver_asm_elf_ctx_free(elf);
        driver_asm_work_p_set(ap_elf(), 0 as *u8);
      }
    }
    if (want_exe != 0) {
      if (tmp != 0 as *u8) {
        exe_out = outp;
        if (exe_out == 0 as *u8) {
          /* a.out — fill via byte assign on tmp message slot unused; use path slot msg */
          /* Cap: use outp as provided by caller; smoke path never want_exe */
        }
        unsafe {
          driver_bump_stack_limit();
          macho = driver_pipeline_dep_ctx_get_use_macho_o(pctx);
          coff = driver_pipeline_dep_ctx_get_use_coff_o(pctx);
          argv0 = driver_asm_argv0(argv);
          ld_ok = shux_invoke_ld_for_exe(tmp, exe_out, target, macho, coff, argv0, lib, nlib);
          unlink(tmp);
        }
        if (ld_ok != 0) {
          unsafe {
            driver_unlink_failed_output(exe_out);
          }
          rt_ab_diag(0 as *u8, 6, 11, 12);
          return 1;
        }
      }
    }
  } else {
    if (want_exe != 0) {
      if (tmp != 0 as *u8) {
        unsafe { unlink(tmp); }
      }
    }
    unsafe {
      driver_unlink_failed_output(outp);
    }
    rt_ab_diag(path, 3, 3, 9);
    return 1;
  }
  unsafe {
    nf = driver_get_module_num_funcs(module);
  }
  if (ec == 0) {
    if (emit_elf != 0) {
      if (nf <= 0) {
        rt_ab_diag(path, 4, 9, 10);
        return 1;
      }
    }
  }
  unsafe {
    driver_dep_seeded_clear_all();
    codegen_set_dep_slots_for_x_pipeline(0 as *u8, 0 as *u8, 0);
  }
  if (ec != 0) {
    return 1;
  }
  return 0;
}

/** Public entry: run -backend asm pipeline via work slots and eight steps. Seeds path/out/lib/target/argv then read_pp through finish.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function driver_run_asm_backend(
  input_path: *u8, out_path: *u8, lib_roots: *u8, n_lib_roots: i32,
  target: *u8, argc: i32, argv: *u8): i32 {
  let path: *u8 = 0 as *u8;
  let lib: *u8 = 0 as *u8;
  let nlib: i32 = 0;
  let ndef: i32 = 0;
  let defs: *u8 = 0 as *u8;
  let k: *u8 = 0 as *u8;
  let c: *u8 = 0 as *u8;
  let m: *u8 = 0 as *u8;
  let rc: i32 = 0;
  let tlen: i32 = 0;
  unsafe {
    driver_bump_stack_limit();
    driver_asm_work_reset();
    path = input_path;
    if (path == 0 as *u8) {
      return 1;
    }
    driver_asm_work_p_set(ap_path(), path);
    driver_asm_work_p_set(ap_out_path(), out_path);
    driver_asm_work_p_set(ap_target(), target);
    driver_asm_work_p_set(ap_argv(), argv);
    lib = driver_asm_bind_lib_roots(lib_roots, n_lib_roots, &nlib);
    driver_asm_work_p_set(ap_lib(), lib);
    driver_asm_work_i_set(ai_nlib(), nlib);
    ndef = driver_asm_collect_defines(argc, argv);
    defs = driver_asm_defines_as_u8();
    driver_asm_work_i_set(ai_ndef(), ndef);
    driver_asm_work_p_set(ap_defs(), defs);
    if (target != 0 as *u8) {
      tlen = strlen(target) as i32;
      cfg_apply_compile_target_from_triple(target, tlen);
    } else {
      cfg_reset_compile_target();
    }
    k = malloc(32 as usize);
    c = malloc(16 as usize);
    m = malloc(64 as usize);
  }
  if (k == 0 as *u8) {
    return 1;
  }
  if (c == 0 as *u8) {
    unsafe { free(k); }
    return 1;
  }
  if (m == 0 as *u8) {
    unsafe { free(k); free(c); }
    return 1;
  }
  unsafe {
    driver_asm_work_p_set(ap_kind(), k);
    driver_asm_work_p_set(ap_code(), c);
    driver_asm_work_p_set(ap_msg(), m);
    rc = rt_ab_step_read_pp();
  }
  if (rc != 0) {
    unsafe { driver_asm_work_cleanup(); }
    return 1;
  }
  unsafe {
    rc = rt_ab_step_early();
  }
  if (rc == 2) {
    unsafe {
      rc = driver_asm_work_i_get(ai_ec());
      driver_asm_work_cleanup();
    }
    return rc;
  }
  if (rc != 0) {
    unsafe { driver_asm_work_cleanup(); }
    return 1;
  }
  unsafe {
    rc = rt_ab_step_parse();
  }
  if (rc == 2) {
    unsafe {
      driver_asm_work_cleanup();
    }
    return 0;
  }
  if (rc != 0) {
    unsafe { driver_asm_work_cleanup(); }
    return 1;
  }
  unsafe {
    rc = rt_ab_step_load_deps();
  }
  if (rc != 0) {
    unsafe { driver_asm_work_cleanup(); }
    return 1;
  }
  unsafe {
    rc = rt_ab_step_open_out();
  }
  if (rc != 0) {
    unsafe { driver_asm_work_cleanup(); }
    return 1;
  }
  unsafe {
    rc = rt_ab_step_prerun();
  }
  if (rc != 0) {
    unsafe { driver_asm_work_cleanup(); }
    return 1;
  }
  unsafe {
    rc = rt_ab_step_pipeline();
  }
  if (rc != 0) {
    unsafe { driver_asm_work_cleanup(); }
    return 1;
  }
  unsafe {
    rc = rt_ab_step_finish();
    driver_asm_work_cleanup();
  }
  return rc;
}
