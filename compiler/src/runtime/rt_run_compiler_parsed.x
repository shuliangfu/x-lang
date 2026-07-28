// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-316/457 → R2 full: compile orchestration after argv is parsed.
// .x owns driver_run_compiler_parsed; product PREFER rest is marker only (business H=0).
// Cap residual (driver_abi): DriverCompileParsed fields / C frontend / FILE+invoke_cc /
//   work slots / pctx skip_codegen_dep_0.
// Steps: read_pp / try_c / parse / load_deps / open_out / prerun / pipeline / finish.
// PLATFORM: SHARED — surface short names are the link-name contract (Track L).
// Comment rule: never put star-slash sequences inside block comments.

export extern "C" function malloc(n: usize): *u8;
export extern "C" function free(p: *u8): void;
export extern "C" function memset(p: *u8, c: i32, n: usize): *u8;
export extern "C" function strlen(s: *u8): usize;
/* wave238 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PRODUCT PREFER: full .x body does not call env here; cold seed twin (below FROM_X)
 * uses link_abi_getenv for XLANG_KEEP_C / XLANG_DUMP_PREP / XLANG_DEBUG_PIPE.
 * PLATFORM: SHARED orch / host residual via single face. */
export extern "C" function link_abi_getenv(name: *u8): *u8;
export extern "C" function unlink(path: *u8): i32;
export extern "C" function runtime_read_file_malloc(path: *u8, out_len: *usize): *u8;
export extern "C" function xlang_preprocess_with_path(
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
export extern "C" function xlang_get_entry_dir(path: *u8, out: *u8, out_sz: usize): void;
export extern "C" function pipeline_set_entry_dir(dir: *u8): void;
export extern "C" function driver_dep_seeded_clear_all(): void;
export extern "C" function driver_set_current_dep_path_for_codegen(path: *u8): void;
export extern "C" function driver_dep_publish_slot(j: i32, arena: *u8, module: *u8, path: *u8): void;
export extern "C" function pipeline_set_dep_slots(arenas: *u8, modules: *u8): void;
export extern "C" function driver_dep_seed_slots(arenas: *u8, modules: *u8, n: i32): void;
export extern "C" function codegen_set_dep_slots_for_x_pipeline(mods: *u8, paths: *u8, n: i32): void;
export extern "C" function codegen_set_preamble_has_core_option_result(on: i32): void;
export extern "C" function runtime_report_precise_parse_failure_if_known(
  input_path: *u8, src: *u8, src_len: usize): i32;
/* See signature and body for contracts. */
 * See signature and body for params/returns/contracts.
 * See signature and body for params/returns/contracts.
export extern "C" function runtime_report_parse_recovery_diagnostics(
  input_path: *u8, src: *u8, src_len: usize): i32;
export extern "C" function pipeline_dep_ctx_heap_destroy(ctx: *u8): void;
export extern "C" function xlang_pipeline_run_x_pipeline_large_stack(
  module: *u8, arena: *u8, src: *u8, src_len: usize, out_buf: *u8, pctx: *u8): i32;
export extern "C" function xlang_pipeline_fill_ctx_path_buffers(
  ctx: *u8, entry_dir: *u8, lib_roots: *u8, n_lib: i32): void;
export extern "C" function xlang_pipeline_pctx_seed_dep_slots(
  ctx: *u8, dep_mods: *u8, dep_ar: *u8, dep_paths: *u8, n: i32): void;
export extern "C" function xlang_pipeline_one_ctx_for_dep_prerun(
  ctx: *u8, j: i32, dep_mods: *u8, dep_ar: *u8, dep_paths: *u8, n: i32,
  dep_src: *u8, dep_len: usize): void;
export extern "C" function xlang_collect_deps_transitive(
  module: *u8, arena_sz: usize, module_sz: usize, lib_roots: *u8, n_lib: i32,
  entry_dir: *u8, defines: *u8, n_defines: i32,
  cls: *u8, clens: *u8, cpaths: *u8, n_closure: *i32): i32;
export extern "C" function xlang_dep_prerun_entry_dir(
  entry_dir: *u8, lib_roots: *u8, n_lib: i32): *u8;
export extern "C" function xlang_pipeline_dep_prerun_parse_only(
  mod: *u8, arena: *u8, src: *u8, len: usize): i32;
export extern "C" function xlang_pipeline_dep_prerun_typeck_only(
  mod: *u8, arena: *u8, src: *u8, len: usize, out: *u8, ctx: *u8): i32;
export extern "C" function xlang_asm_user_std_dep_skip_x_typeck(dep_path: *u8): i32;
export extern "C" function xlang_output_want_exe(path: *u8): i32;
export extern "C" function driver_source_has_generic_syntax(path: *u8, path_len: i32): i32;
export extern "C" function driver_bump_stack_limit(): void;
export extern "C" function driver_check_only_get(): i32;
export extern "C" function driver_print_x_smoke_summary(module: *u8, codegen_len: usize): void;
export extern "C" function driver_print_check_ok(input_path: *u8): void;
export extern "C" function driver_x_pipeline_skip_typeck_set(v: i32): void;
export extern "C" function driver_deps_are_std_core_closure_only(dep_paths: *u8, n: i32): i32;
export extern "C" function driver_run_asm_backend(
  input_path: *u8, out_path: *u8, lib_roots: *u8, n_lib: i32,
  target: *u8, argc: i32, argv: *u8): i32;
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
export extern "C" function driver_pipeline_dep_ctx_set_entry_already_parsed(ctx: *u8, v: i32): void;
export extern "C" function driver_pipeline_dep_ctx_set_asm_entry_module_only(ctx: *u8, v: i32): void;
export extern "C" function driver_pipeline_dep_ctx_set_skip_codegen_dep_0(ctx: *u8, v: i32): void;

export extern "C" function driver_parsed_input_path(p: *u8): *u8;
export extern "C" function driver_parsed_out_path(p: *u8): *u8;
export extern "C" function driver_parsed_lib_roots(p: *u8): *u8;
export extern "C" function driver_parsed_n_lib_roots(p: *u8): i32;
export extern "C" function driver_parsed_want_asm(p: *u8): i32;
export extern "C" function driver_parsed_target(p: *u8): *u8;
export extern "C" function driver_parsed_opt_level(p: *u8): *u8;
export extern "C" function driver_parsed_use_lto(p: *u8): i32;
export extern "C" function driver_parsed_try_c_after_pp(
  input_path: *u8, src: *u8, src_len: usize, lib_roots: *u8, n_lib: i32, out_path: *u8,
  argc: i32, argv: *u8, opt_level: *u8, use_lto: i32, ndefines: i32, defines: *u8): i32;
export extern "C" function driver_parsed_open_out_file(
  out_path: *u8, tmp_c_out64: *u8, emit_stdout: *i32): *u8;
export extern "C" function driver_parsed_fclose(fp: *u8): void;
export extern "C" function driver_parsed_fclose_rc(fp: *u8): i32;
export extern "C" function driver_parsed_write_out(fp: *u8, data: *u8, len: i32): i32;
export extern "C" function driver_parsed_invoke_cc(
  tmp_c: *u8, out_path: *u8, opt_level: *u8, use_lto: i32, argv0: *u8,
  argc: i32, argv: *u8): i32;
export extern "C" function driver_parsed_maybe_dump_prep(
  input_path: *u8, src: *u8, src_len: usize): void;
export extern "C" function driver_parsed_apply_preamble_skip(dep_paths: *u8, n_deps: i32): void;
export extern "C" function driver_asm_collect_defines(argc: i32, argv: *u8): i32;
export extern "C" function driver_asm_defines_as_u8(): *u8;
export extern "C" function driver_asm_bind_lib_roots(lib_roots: *u8, n: i32, n_out: *i32): *u8;
export extern "C" function driver_asm_argv0(argv: *u8): *u8;
export extern "C" function driver_parsed_work_reset(): void;
export extern "C" function driver_parsed_work_p_get(i: i32): *u8;
export extern "C" function driver_parsed_work_p_set(i: i32, v: *u8): void;
export extern "C" function driver_parsed_work_i_get(i: i32): i32;
export extern "C" function driver_parsed_work_i_set(i: i32, v: i32): void;
export extern "C" function driver_parsed_work_z_get(i: i32): usize;
export extern "C" function driver_parsed_work_z_set(i: i32, v: usize): void;
export extern "C" function driver_parsed_work_cleanup(): void;

/* work pointer indices */
/** Work-slot index for entry path pointer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_path(): i32 { return 0; }
/** Work-slot index for preprocess source buffer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_src(): i32 { return 1; }
/** Work-slot index for output path pointer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_out_path(): i32 { return 2; }
/** Work-slot index for main parse arena.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_arena(): i32 { return 3; }
/** Work-slot index for main module pointer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_module(): i32 { return 4; }
/** Work-slot index for entry-dir buffer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_entry(): i32 { return 5; }
/** Work-slot index for dep source pointer table.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_dsrc(): i32 { return 6; }
/** Work-slot index for dep path pointer table.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_dpath(): i32 { return 7; }
/** Work-slot index for dep source-length table.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_dlens(): i32 { return 8; }
/** Work-slot index for dep arena pointer table.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_dar(): i32 { return 9; }
/** Work-slot index for dep module pointer table.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_dmod(): i32 { return 10; }
/** Work-slot index for codegen OutBuf.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_out(): i32 { return 11; }
/** Work-slot index for pipeline dep context.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_pctx(): i32 { return 12; }
/** Work-slot index for diagnostic kind scratch buffer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_kind(): i32 { return 13; }
/** Work-slot index for diagnostic code scratch buffer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_code(): i32 { return 14; }
/** Work-slot index for diagnostic message scratch buffer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_msg(): i32 { return 15; }
/** Work-slot index for lib-roots pointer table.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_lib(): i32 { return 16; }
/** Work-slot index for opt-level / flags blob.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_opt(): i32 { return 17; }
/** Work-slot index for argv pointer.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_argv(): i32 { return 18; }
/** Work-slot index for C frontend FILE* / handle.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_cf(): i32 { return 19; }
/** Work-slot index for temporary .c path.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_tmpc(): i32 { return 20; }
/** Work-slot index for target triple string.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_target(): i32 { return 21; }
/** Work-slot index for define list.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pp_defs(): i32 { return 22; }

/** Work-int index for n_lib_roots.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pi_nlib(): i32 { return 0; }
/** Work-int index for n_deps.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pi_ndeps(): i32 { return 1; }
/** Work-int index for module import count.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pi_nimp(): i32 { return 2; }
/** Work-int index for main function index.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pi_main(): i32 { return 3; }
/** Work-int index for want-asm backend flag.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pi_want_asm(): i32 { return 4; }
/** Work-int index for emit-to-stdout flag.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pi_emit_stdout(): i32 { return 5; }
/** Work-int index for n_defines.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pi_ndef(): i32 { return 6; }
/** Work-int index for LTO flag.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pi_use_lto(): i32 { return 7; }
/** Work-int index for argc.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pi_argc(): i32 { return 8; }
/** Work-int index for exit/error code.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pi_ec(): i32 { return 9; }
/** Work-int index for check-only flag.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pi_check(): i32 { return 11; }

/** Work-size index for source length.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pz_slen(): i32 { return 0; }
/** Work-size index for arena sizeof.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pz_asz(): i32 { return 1; }
/** Work-size index for module sizeof.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function pz_msz(): i32 { return 2; }

/** Fill kind buffer with io error (byte writes; no string lit).
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_fill_kind_io(k: *u8): void {
  k[0] = 105; k[1] = 111; k[2] = 32; k[3] = 101; k[4] = 114; k[5] = 114;
  k[6] = 111; k[7] = 114; k[8] = 0;
}
/** Fill code buffer with IO001.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_fill_code_io001(c: *u8): void {
  c[0] = 73; c[1] = 79; c[2] = 48; c[3] = 48; c[4] = 49; c[5] = 0;
}
/** Fill kind buffer with preprocess error.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_fill_kind_pp(k: *u8): void {
  k[0] = 112; k[1] = 114; k[2] = 101; k[3] = 112; k[4] = 114; k[5] = 111;
  k[6] = 99; k[7] = 101; k[8] = 115; k[9] = 115; k[10] = 32; k[11] = 101;
  k[12] = 114; k[13] = 114; k[14] = 111; k[15] = 114; k[16] = 0;
}
/** Fill code buffer with PP002.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_fill_code_pp002(c: *u8): void {
  c[0] = 80; c[1] = 80; c[2] = 48; c[3] = 48; c[4] = 50; c[5] = 0;
}
/** Fill kind buffer with pipeline error.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_fill_kind_pipe(k: *u8): void {
  k[0] = 112; k[1] = 105; k[2] = 112; k[3] = 101; k[4] = 108; k[5] = 105;
  k[6] = 110; k[7] = 101; k[8] = 32; k[9] = 101; k[10] = 114; k[11] = 114;
  k[12] = 111; k[13] = 114; k[14] = 0;
}
/** Fill code buffer with XP003.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_fill_code_xp003(c: *u8): void {
  c[0] = 88; c[1] = 80; c[2] = 48; c[3] = 48; c[4] = 51; c[5] = 0;
}
/** Fill code buffer with XP005.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_fill_code_xp005(c: *u8): void {
  c[0] = 88; c[1] = 80; c[2] = 48; c[3] = 48; c[4] = 53; c[5] = 0;
}
/** Fill code buffer with XP006.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_fill_code_xp006(c: *u8): void {
  c[0] = 88; c[1] = 80; c[2] = 48; c[3] = 48; c[4] = 54; c[5] = 0;
}
/** Fill code buffer with XP007.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_fill_code_xp007(c: *u8): void {
  c[0] = 88; c[1] = 80; c[2] = 48; c[3] = 48; c[4] = 55; c[5] = 0;
}
/** Fill code buffer with XP008.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_fill_code_xp008(c: *u8): void {
  c[0] = 88; c[1] = 80; c[2] = 48; c[3] = 48; c[4] = 56; c[5] = 0;
}
/** Fill kind buffer with parse error.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_fill_kind_parse(k: *u8): void {
  k[0] = 112; k[1] = 97; k[2] = 114; k[3] = 115; k[4] = 101; k[5] = 32;
  k[6] = 101; k[7] = 114; k[8] = 114; k[9] = 111; k[10] = 114; k[11] = 0;
}
/** Fill code buffer with P001.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_fill_code_p001(c: *u8): void {
  c[0] = 80; c[1] = 48; c[2] = 48; c[3] = 49; c[4] = 0;
}
/** Fill message buffer with cannot read file.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_msg_cannot_read(m: *u8): void {
  m[0] = 99; m[1] = 97; m[2] = 110; m[3] = 110; m[4] = 111; m[5] = 116;
  m[6] = 32; m[7] = 114; m[8] = 101; m[9] = 97; m[10] = 100; m[11] = 32;
  m[12] = 102; m[13] = 105; m[14] = 108; m[15] = 101; m[16] = 0;
}
/** Fill message buffer with preprocess failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_msg_pp_failed(m: *u8): void {
  m[0] = 112; m[1] = 114; m[2] = 101; m[3] = 112; m[4] = 114; m[5] = 111;
  m[6] = 99; m[7] = 101; m[8] = 115; m[9] = 115; m[10] = 32; m[11] = 102;
  m[12] = 97; m[13] = 105; m[14] = 108; m[15] = 101; m[16] = 100; m[17] = 0;
}
/** Fill message buffer with pipeline allocation failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_msg_alloc(m: *u8): void {
  m[0] = 46; m[1] = 120; m[2] = 32; m[3] = 112; m[4] = 105; m[5] = 112;
  m[6] = 101; m[7] = 108; m[8] = 105; m[9] = 110; m[10] = 101; m[11] = 32;
  m[12] = 97; m[13] = 108; m[14] = 108; m[15] = 111; m[16] = 99; m[17] = 32;
  m[18] = 102; m[19] = 97; m[20] = 105; m[21] = 108; m[22] = 101; m[23] = 100;
  m[24] = 0;
}
/** Fill message buffer with source too large.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_msg_src_large(m: *u8): void {
  m[0] = 101; m[1] = 110; m[2] = 116; m[3] = 114; m[4] = 121; m[5] = 32;
  m[6] = 115; m[7] = 111; m[8] = 117; m[9] = 114; m[10] = 99; m[11] = 101;
  m[12] = 32; m[13] = 116; m[14] = 111; m[15] = 111; m[16] = 32; m[17] = 108;
  m[18] = 97; m[19] = 114; m[20] = 103; m[21] = 101; m[22] = 0;
}
/** Fill message buffer with parse failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_msg_parse(m: *u8): void {
  m[0] = 112; m[1] = 97; m[2] = 114; m[3] = 115; m[4] = 101; m[5] = 32;
  m[6] = 102; m[7] = 97; m[8] = 105; m[9] = 108; m[10] = 101; m[11] = 100;
  m[12] = 0;
}
/** Fill message buffer with dep alloc failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_msg_dep_alloc(m: *u8): void {
  m[0] = 100; m[1] = 101; m[2] = 112; m[3] = 32; m[4] = 97; m[5] = 108;
  m[6] = 108; m[7] = 111; m[8] = 99; m[9] = 32; m[10] = 102; m[11] = 97;
  m[12] = 105; m[13] = 108; m[14] = 101; m[15] = 100; m[16] = 0;
}
/** Fill message buffer with out/ctx alloc failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_msg_out_ctx(m: *u8): void {
  m[0] = 111; m[1] = 117; m[2] = 116; m[3] = 47; m[4] = 99; m[5] = 116;
  m[6] = 120; m[7] = 32; m[8] = 97; m[9] = 108; m[10] = 108; m[11] = 111;
  m[12] = 99; m[13] = 32; m[14] = 102; m[15] = 97; m[16] = 105; m[17] = 108;
  m[18] = 101; m[19] = 100; m[20] = 0;
}
/** Fill message buffer with dep prerun failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_msg_dep_prerun(m: *u8): void {
  m[0] = 100; m[1] = 101; m[2] = 112; m[3] = 32; m[4] = 112; m[5] = 114;
  m[6] = 101; m[7] = 114; m[8] = 117; m[9] = 110; m[10] = 32; m[11] = 102;
  m[12] = 97; m[13] = 105; m[14] = 108; m[15] = 101; m[16] = 100; m[17] = 0;
}
/** Fill message buffer with pipeline failed.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_msg_pipe(m: *u8): void {
  m[0] = 112; m[1] = 105; m[2] = 112; m[3] = 101; m[4] = 108; m[5] = 105;
  m[6] = 110; m[7] = 101; m[8] = 32; m[9] = 102; m[10] = 97; m[11] = 105;
  m[12] = 108; m[13] = 101; m[14] = 100; m[15] = 0;
}

/** Dispatch kind/code/msg fillers by selector ids, then diag_report_with_code. kind_fn/code_fn/msg_fn are integer selectors for Cap residual. Uses work slots pp_kind/pp_code/pp_msg.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_diag(path: *u8, kind_fn: i32, code_fn: i32, msg_fn: i32): void {
  let k: *u8 = 0 as *u8;
  let c: *u8 = 0 as *u8;
  let m: *u8 = 0 as *u8;
  unsafe {
    k = driver_parsed_work_p_get(pp_kind());
    c = driver_parsed_work_p_get(pp_code());
    m = driver_parsed_work_p_get(pp_msg());
  }
  if (k == 0 as *u8) {
    return;
  }
  if (kind_fn == 1) { rt_cp_fill_kind_io(k); }
  if (kind_fn == 2) { rt_cp_fill_kind_pp(k); }
  if (kind_fn == 3) { rt_cp_fill_kind_pipe(k); }
  if (kind_fn == 4) { rt_cp_fill_kind_parse(k); }
  if (code_fn == 1) { rt_cp_fill_code_io001(c); }
  if (code_fn == 2) { rt_cp_fill_code_pp002(c); }
  if (code_fn == 3) { rt_cp_fill_code_xp003(c); }
  if (code_fn == 5) { rt_cp_fill_code_xp005(c); }
  if (code_fn == 6) { rt_cp_fill_code_xp006(c); }
  if (code_fn == 7) { rt_cp_fill_code_xp007(c); }
  if (code_fn == 8) { rt_cp_fill_code_xp008(c); }
  if (code_fn == 9) { rt_cp_fill_code_p001(c); }
  if (msg_fn == 1) { rt_cp_msg_cannot_read(m); }
  if (msg_fn == 2) { rt_cp_msg_pp_failed(m); }
  if (msg_fn == 3) { rt_cp_msg_alloc(m); }
  if (msg_fn == 4) { rt_cp_msg_src_large(m); }
  if (msg_fn == 5) { rt_cp_msg_parse(m); }
  if (msg_fn == 6) { rt_cp_msg_dep_alloc(m); }
  if (msg_fn == 7) { rt_cp_msg_out_ctx(m); }
  if (msg_fn == 8) { rt_cp_msg_dep_prerun(m); }
  if (msg_fn == 9) { rt_cp_msg_pipe(m); }
  unsafe {
    diag_report_with_code(path, 0, 0, k, c, m, 0 as *u8);
  }
}

/** Step: read source + preprocess into work slots. Returns 0 ok / 1 fail.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_step_read_pp(): i32 {
  let path: *u8 = 0 as *u8;
  let raw: *u8 = 0 as *u8;
  let raw_len: usize = 0;
  let src: *u8 = 0 as *u8;
  let src_len: usize = 0;
  let em: i32 = 0;
  let ndef: i32 = 0;
  let defs: *u8 = 0 as *u8;
  unsafe {
    path = driver_parsed_work_p_get(pp_path());
    raw = runtime_read_file_malloc(path, &raw_len);
    ndef = driver_parsed_work_i_get(pi_ndef());
    defs = driver_parsed_work_p_get(pp_defs());
  }
  if (raw == 0 as *u8) {
    rt_cp_diag(path, 1, 1, 1);
    return 1;
  }
  unsafe {
    pipeline_diag_emitted_reset();
    /* See signature and body for contracts. */
    src = xlang_preprocess_with_path(raw, raw_len, path, defs, ndef, &src_len);
    free(raw);
  }
  if (src == 0 as *u8) {
    unsafe {
      em = pipeline_diag_emitted_get();
    }
    if (em == 0) {
      rt_cp_diag(path, 2, 2, 2);
    }
    return 1;
  }
  unsafe {
    diag_set_file(path, src, src_len);
    driver_parsed_work_p_set(pp_src(), src);
    driver_parsed_work_z_set(pz_slen(), src_len);
    driver_parsed_maybe_dump_prep(path, src, src_len);
  }
  return 0;
}

/** Step: optional C frontend early path. Returns 0 continue / non-zero handled.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_step_try_c(): i32 {
  let path: *u8 = 0 as *u8;
  let src: *u8 = 0 as *u8;
  let src_len: usize = 0;
  let lib: *u8 = 0 as *u8;
  let nlib: i32 = 0;
  let outp: *u8 = 0 as *u8;
  let argc: i32 = 0;
  let argv: *u8 = 0 as *u8;
  let opt: *u8 = 0 as *u8;
  let use_lto: i32 = 0;
  let ndef: i32 = 0;
  let defs: *u8 = 0 as *u8;
  let rc: i32 = 0;
  unsafe {
    path = driver_parsed_work_p_get(pp_path());
    src = driver_parsed_work_p_get(pp_src());
    src_len = driver_parsed_work_z_get(pz_slen());
    lib = driver_parsed_work_p_get(pp_lib());
    nlib = driver_parsed_work_i_get(pi_nlib());
    outp = driver_parsed_work_p_get(pp_out_path());
    argc = driver_parsed_work_i_get(pi_argc());
    argv = driver_parsed_work_p_get(pp_argv());
    opt = driver_parsed_work_p_get(pp_opt());
    use_lto = driver_parsed_work_i_get(pi_use_lto());
    ndef = driver_parsed_work_i_get(pi_ndef());
    defs = driver_parsed_work_p_get(pp_defs());
    rc = driver_parsed_try_c_after_pp(
      path, src, src_len, lib, nlib, outp, argc, argv, opt, use_lto, ndef, defs);
  }
  if (rc == 0 - 2) {
    return 0;
  }
  unsafe {
    driver_parsed_work_i_set(pi_ec(), rc);
  }
  return 2;
}

/** Step: parse main module into arena/module work slots. Returns 0 ok / 1 fail.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_step_parse(): i32 {
  let path: *u8 = 0 as *u8;
  let src: *u8 = 0 as *u8;
  let src_len: usize = 0;
  let asz: usize = 0;
  let msz: usize = 0;
  let arena: *u8 = 0 as *u8;
  let module: *u8 = 0 as *u8;
  let main_idx: i32 = 0;
  let pr: i32 = 0;
  let nimp: i32 = 0;
  let entry: *u8 = 0 as *u8;
  let max_i32: i32 = 2147483647;
  unsafe {
    path = driver_parsed_work_p_get(pp_path());
    src = driver_parsed_work_p_get(pp_src());
    src_len = driver_parsed_work_z_get(pz_slen());
    asz = pipeline_sizeof_arena();
    msz = pipeline_sizeof_module();
    arena = malloc(asz);
    module = malloc(msz);
  }
  if (arena == 0 as *u8) {
    if (module != 0 as *u8) {
      unsafe { free(module); }
    }
    return 1;
  }
  if (module == 0 as *u8) {
    unsafe { free(arena); }
    return 1;
  }
  if (src_len > max_i32 as usize) {
    rt_cp_diag(path, 3, 7, 4);
    unsafe {
      free(arena);
      free(module);
    }
    return 1;
  }
  unsafe {
    memset(arena, 0, asz);
    memset(module, 0, msz);
    parser_parse_into_init(module, arena);
    pr = driver_parse_into_buf_rc(arena, module, src, src_len as i32, &main_idx);
  }
  if (pr != 0) {
    let rec_n: i32 = 0;
    unsafe {
      pr = runtime_report_precise_parse_failure_if_known(path, src, src_len);
    }
    if (pr == 0) {
      unsafe {
        rec_n = runtime_report_parse_recovery_diagnostics(path, src, src_len);
      }
    }
    if (pr == 0 && rec_n == 0) {
      rt_cp_diag(path, 4, 9, 5);
    }
    unsafe {
      free(arena);
      free(module);
    }
    return 1;
  }
  unsafe {
    parser_parse_into_set_main_index(module, main_idx);
    nimp = parser_get_module_num_imports(module);
    entry = driver_entry_dir_slot();
    xlang_get_entry_dir(path, entry, 512 as usize);
    if (nimp > 0) {
      pipeline_set_entry_dir(entry);
    }
    driver_parsed_work_p_set(pp_arena(), arena);
    driver_parsed_work_p_set(pp_module(), module);
    driver_parsed_work_p_set(pp_entry(), entry);
    driver_parsed_work_z_set(pz_asz(), asz);
    driver_parsed_work_z_set(pz_msz(), msz);
    driver_parsed_work_i_set(pi_main(), main_idx);
    driver_parsed_work_i_set(pi_nimp(), nimp);
  }
  return 0;
}

/** Step: load direct/transitive deps into work tables. Returns 0 ok / 1 fail.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_step_load_deps(): i32 {
  let module: *u8 = 0 as *u8;
  let asz: usize = 0;
  let msz: usize = 0;
  let lib: *u8 = 0 as *u8;
  let nlib: i32 = 0;
  let entry: *u8 = 0 as *u8;
  let defs: *u8 = 0 as *u8;
  let ndef: i32 = 0;
  let nimp: i32 = 0;
  let dsrc: *u8 = 0 as *u8;
  let dpath: *u8 = 0 as *u8;
  let dlens: *u8 = 0 as *u8;
  let dar: *u8 = 0 as *u8;
  let dmod: *u8 = 0 as *u8;
  let n_deps: i32 = 0;
  let out_buf: *u8 = 0 as *u8;
  let pctx: *u8 = 0 as *u8;
  let j: i32 = 0;
  let rc: i32 = 0;
  unsafe {
    module = driver_parsed_work_p_get(pp_module());
    asz = driver_parsed_work_z_get(pz_asz());
    msz = driver_parsed_work_z_get(pz_msz());
    lib = driver_parsed_work_p_get(pp_lib());
    nlib = driver_parsed_work_i_get(pi_nlib());
    entry = driver_parsed_work_p_get(pp_entry());
    defs = driver_parsed_work_p_get(pp_defs());
    ndef = driver_parsed_work_i_get(pi_ndef());
    nimp = driver_parsed_work_i_get(pi_nimp());
  }
  if (nimp > 0) {
    if (nimp <= 32) {
      unsafe {
        dsrc = driver_ptr_table_calloc(128);
        dpath = driver_ptr_table_calloc(128);
        dlens = driver_size_table_calloc(128);
      }
      if (dsrc == 0 as *u8) {
        return 1;
      }
      if (dpath == 0 as *u8) {
        unsafe { driver_ptr_table_free(dsrc); }
        return 1;
      }
      if (dlens == 0 as *u8) {
        unsafe {
          driver_ptr_table_free(dsrc);
          driver_ptr_table_free(dpath);
        }
        return 1;
      }
      unsafe {
        rc = xlang_collect_deps_transitive(
          module, asz, msz, lib, nlib, entry, defs, ndef, dsrc, dlens, dpath, &n_deps);
      }
      if (rc != 0) {
        unsafe {
          driver_ptr_table_free(dsrc);
          driver_ptr_table_free(dpath);
          driver_size_table_free(dlens);
        }
        return 1;
      }
      unsafe {
        driver_parsed_work_p_set(pp_dsrc(), dsrc);
        driver_parsed_work_p_set(pp_dpath(), dpath);
        driver_parsed_work_p_set(pp_dlens(), dlens);
        driver_parsed_work_i_set(pi_ndeps(), n_deps);
      }
    }
  }
  unsafe {
    n_deps = driver_parsed_work_i_get(pi_ndeps());
  }
  if (n_deps > 0) {
    unsafe {
      dar = driver_ptr_table_calloc(n_deps);
      dmod = driver_ptr_table_calloc(n_deps);
    }
    if (dar == 0 as *u8) {
      return 1;
    }
    if (dmod == 0 as *u8) {
      unsafe { driver_ptr_table_free(dar); }
      return 1;
    }
    j = n_deps - 1;
    while (j >= 0) {
      let a: *u8 = 0 as *u8;
      let m: *u8 = 0 as *u8;
      unsafe {
        a = malloc(asz);
        m = malloc(msz);
      }
      if (a == 0 as *u8) {
        if (m != 0 as *u8) {
          unsafe { free(m); }
        }
        rt_cp_diag(0 as *u8, 3, 5, 6);
        unsafe {
          driver_ptr_table_free(dar);
          driver_ptr_table_free(dmod);
        }
        return 1;
      }
      if (m == 0 as *u8) {
        unsafe { free(a); }
        rt_cp_diag(0 as *u8, 3, 5, 6);
        unsafe {
          driver_ptr_table_free(dar);
          driver_ptr_table_free(dmod);
        }
        return 1;
      }
      unsafe {
        memset(a, 0, asz);
        memset(m, 0, msz);
        driver_ptr_table_set(dar, j, a);
        driver_ptr_table_set(dmod, j, m);
      }
      j = j - 1;
    }
    unsafe {
      driver_parsed_work_p_set(pp_dar(), dar);
      driver_parsed_work_p_set(pp_dmod(), dmod);
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
    rt_cp_diag(0 as *u8, 3, 6, 7);
    return 1;
  }
  if (pctx == 0 as *u8) {
    unsafe { driver_codegen_outbuf_free(out_buf); }
    rt_cp_diag(0 as *u8, 3, 6, 7);
    return 1;
  }
  unsafe {
    xlang_pipeline_fill_ctx_path_buffers(pctx, entry, lib, nlib);
    dmod = driver_parsed_work_p_get(pp_dmod());
    dar = driver_parsed_work_p_get(pp_dar());
    dpath = driver_parsed_work_p_get(pp_dpath());
    n_deps = driver_parsed_work_i_get(pi_ndeps());
    xlang_pipeline_pctx_seed_dep_slots(pctx, dmod, dar, dpath, n_deps);
    driver_pipeline_dep_ctx_set_skip_codegen_dep_0(pctx, 0);
    driver_parsed_work_p_set(pp_out(), out_buf);
    driver_parsed_work_p_set(pp_pctx(), pctx);
  }
  return 0;
}

/** Step: open output path or stdout emit layout. Returns 0 ok / 1 fail.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_step_open_out(): i32 {
  let outp: *u8 = 0 as *u8;
  let tmp: *u8 = 0 as *u8;
  let cf: *u8 = 0 as *u8;
  let emit_stdout: i32 = 0;
  /* PLATFORM: SHARED — 256 bytes accommodates Windows long TEMP paths
   * (e.g. C:\xlang_tmp\xlang_xlang_x.YZXDC4.c = 32 chars) with safety margin.
   * Must match g_driver_parsed_tmp_c[256] in runtime_driver_abi.from_x.c. */
  unsafe {
    outp = driver_parsed_work_p_get(pp_out_path());
    tmp = malloc(256 as usize);
  }
  if (tmp == 0 as *u8) {
    return 1;
  }
  unsafe {
    memset(tmp, 0, 256 as usize);
    cf = driver_parsed_open_out_file(outp, tmp, &emit_stdout);
  }
  if (cf == 0 as *u8) {
    unsafe { free(tmp); }
    return 1;
  }
  unsafe {
    driver_parsed_work_p_set(pp_cf(), cf);
    driver_parsed_work_p_set(pp_tmpc(), tmp);
    driver_parsed_work_i_set(pi_emit_stdout(), emit_stdout);
  }
  return 0;
}

/** Step: dep prerun (parse/typeck) + publish slots. Returns 0 ok / 1 fail.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_step_prerun(): i32 {
  let n_deps: i32 = 0;
  let j: i32 = 0;
  let entry: *u8 = 0 as *u8;
  let lib: *u8 = 0 as *u8;
  let nlib: i32 = 0;
  let dsrc: *u8 = 0 as *u8;
  let dpath: *u8 = 0 as *u8;
  let dlens: *u8 = 0 as *u8;
  let dar: *u8 = 0 as *u8;
  let dmod: *u8 = 0 as *u8;
  let one: *u8 = 0 as *u8;
  let dep_out: *u8 = 0 as *u8;
  let dep_src: *u8 = 0 as *u8;
  let dep_len: usize = 0;
  let p: *u8 = 0 as *u8;
  let ec: i32 = 0;
  let check: i32 = 0;
  let skip: i32 = 0;
  unsafe {
    n_deps = driver_parsed_work_i_get(pi_ndeps());
    entry = driver_parsed_work_p_get(pp_entry());
    lib = driver_parsed_work_p_get(pp_lib());
    nlib = driver_parsed_work_i_get(pi_nlib());
    dsrc = driver_parsed_work_p_get(pp_dsrc());
    dpath = driver_parsed_work_p_get(pp_dpath());
    dlens = driver_parsed_work_p_get(pp_dlens());
    dar = driver_parsed_work_p_get(pp_dar());
    dmod = driver_parsed_work_p_get(pp_dmod());
    check = driver_check_only_get();
    driver_dep_seeded_clear_all();
  }
  if (n_deps <= 0) {
    return 0;
  }
  j = n_deps - 1;
  while (j >= 0) {
    unsafe {
      one = driver_pipeline_dep_ctx_calloc();
      dep_out = driver_codegen_outbuf_calloc();
    }
    if (one == 0 as *u8) {
      if (dep_out != 0 as *u8) {
        unsafe { driver_codegen_outbuf_free(dep_out); }
      }
      rt_cp_diag(0 as *u8, 3, 6, 7);
      return 1;
    }
    if (dep_out == 0 as *u8) {
      unsafe { pipeline_dep_ctx_heap_destroy(one); }
      rt_cp_diag(0 as *u8, 3, 6, 7);
      return 1;
    }
    unsafe {
      p = xlang_dep_prerun_entry_dir(entry, lib, nlib);
      xlang_pipeline_fill_ctx_path_buffers(one, p, lib, nlib);
      dep_src = driver_ptr_table_get(dsrc, j);
      dep_len = driver_size_table_get(dlens, j);
      xlang_pipeline_one_ctx_for_dep_prerun(one, j, dmod, dar, dpath, n_deps, dep_src, dep_len);
      p = driver_ptr_table_get(dpath, j);
      driver_set_current_dep_path_for_codegen(p);
      skip = 0;
      if (check != 0) {
        skip = 1;
      }
      if (xlang_asm_user_std_dep_skip_x_typeck(p) != 0) {
        skip = 1;
      }
      if (driver_deps_are_std_core_closure_only(dpath, n_deps) != 0) {
        skip = 1;
      }
    }
    if (skip != 0) {
      unsafe {
        ec = xlang_pipeline_dep_prerun_parse_only(
          driver_ptr_table_get(dmod, j), driver_ptr_table_get(dar, j), dep_src, dep_len);
      }
    } else {
      unsafe {
        ec = xlang_pipeline_dep_prerun_typeck_only(
          driver_ptr_table_get(dmod, j), driver_ptr_table_get(dar, j),
          dep_src, dep_len, dep_out, one);
      }
    }
    unsafe {
      driver_set_current_dep_path_for_codegen(0 as *u8);
      pipeline_dep_ctx_heap_destroy(one);
      driver_codegen_outbuf_free(dep_out);
    }
    if (ec != 0) {
      rt_cp_diag(p, 3, 8, 8);
      return 1;
    }
    unsafe {
      driver_dep_publish_slot(
        j, driver_ptr_table_get(dar, j), driver_ptr_table_get(dmod, j),
        driver_ptr_table_get(dpath, j));
    }
    j = j - 1;
  }
  return 0;
}

/** Step: run x pipeline large-stack for parsed compile. Returns 0 ok / 1 fail.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_step_pipeline(): i32 {
  let path: *u8 = 0 as *u8;
  let src: *u8 = 0 as *u8;
  let src_len: usize = 0;
  let arena: *u8 = 0 as *u8;
  let module: *u8 = 0 as *u8;
  let asz: usize = 0;
  let msz: usize = 0;
  let n_deps: i32 = 0;
  let dar: *u8 = 0 as *u8;
  let dmod: *u8 = 0 as *u8;
  let dpath: *u8 = 0 as *u8;
  let out_buf: *u8 = 0 as *u8;
  let pctx: *u8 = 0 as *u8;
  let j: i32 = 0;
  let ec: i32 = 0;
  let out_len: i32 = 0;
  let check: i32 = 0;
  let want_asm: i32 = 0;
  let core_only: i32 = 0;
  unsafe {
    path = driver_parsed_work_p_get(pp_path());
    src = driver_parsed_work_p_get(pp_src());
    src_len = driver_parsed_work_z_get(pz_slen());
    arena = driver_parsed_work_p_get(pp_arena());
    module = driver_parsed_work_p_get(pp_module());
    asz = driver_parsed_work_z_get(pz_asz());
    msz = driver_parsed_work_z_get(pz_msz());
    n_deps = driver_parsed_work_i_get(pi_ndeps());
    dar = driver_parsed_work_p_get(pp_dar());
    dmod = driver_parsed_work_p_get(pp_dmod());
    dpath = driver_parsed_work_p_get(pp_dpath());
    out_buf = driver_parsed_work_p_get(pp_out());
    pctx = driver_parsed_work_p_get(pp_pctx());
    check = driver_check_only_get();
    want_asm = driver_parsed_work_i_get(pi_want_asm());
    driver_typeck_ndep_set(n_deps);
  }
  j = 0;
  while (j < n_deps) {
    unsafe {
      driver_typeck_dep_ptrs_set(
        j, driver_ptr_table_get(dmod, j), driver_ptr_table_get(dar, j));
    }
    j = j + 1;
  }
  unsafe {
    pipeline_set_dep_slots(dar, dmod);
    driver_dep_seed_slots(dar, dmod, n_deps);
    codegen_set_dep_slots_for_x_pipeline(dmod, dpath, n_deps);
    codegen_set_preamble_has_core_option_result(1);
    driver_parsed_apply_preamble_skip(dpath, n_deps);
    memset(arena, 0, asz);
    memset(module, 0, msz);
    parser_parse_into_init(module, arena);
    driver_pipeline_dep_ctx_set_entry_already_parsed(pctx, 0);
    core_only = 0;
    if (n_deps > 0) {
      core_only = driver_deps_are_std_core_closure_only(dpath, n_deps);
    }
  }
  if (n_deps > 0) {
    if (check == 0) {
      if (want_asm != 0) {
        if (core_only != 0) {
          unsafe {
            driver_pipeline_dep_ctx_set_asm_entry_module_only(pctx, 1);
          }
        }
      }
    }
  }
  /* See signature and body for contracts. */
   * See signature and body for params/returns/contracts.
  if (check != 0) {
    if (n_deps > 0) {
      if (core_only != 0) {
        let rec_n: i32 = 0;
        unsafe {
          rec_n = runtime_report_parse_recovery_diagnostics(path, src, src_len);
        }
        if (rec_n > 0) {
          return 1;
        }
        unsafe {
          driver_print_check_ok(path);
        }
        return 2;
      }
    }
  }
  unsafe {
    ec = xlang_pipeline_run_x_pipeline_large_stack(
      module, arena, src, src_len, out_buf, pctx);
    driver_x_pipeline_skip_typeck_set(0);
    driver_dep_seeded_clear_all();
    codegen_set_dep_slots_for_x_pipeline(0 as *u8, 0 as *u8, 0);
    out_len = driver_codegen_outbuf_len(out_buf);
  }
  if (ec != 0) {
    rt_cp_diag(path, 3, 3, 9);
    return 1;
  }
  if (check == 0) {
    if (out_len == 0) {
      rt_cp_diag(path, 3, 3, 9);
      return 1;
    }
  }
  if (check != 0) {
    let rec_n: i32 = 0;
    let nfuncs: i32 = 0;
    unsafe {
      rec_n = runtime_report_parse_recovery_diagnostics(path, src, src_len);
    }
    if (rec_n > 0) {
      return 1;
    }
    unsafe {
      nfuncs = driver_get_module_num_funcs(module);
    }
    if (nfuncs <= 0) {
      rt_cp_diag(path, 4, 9, 5);
      return 1;
    }
    unsafe {
      driver_print_check_ok(path);
    }
    return 2;
  }
  return 0;
}

/** Step: write output / invoke_cc / cleanup. Returns 0 ok / 1 fail.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_cp_step_finish(): i32 {
  let path: *u8 = 0 as *u8;
  let module: *u8 = 0 as *u8;
  let out_buf: *u8 = 0 as *u8;
  let out_data: *u8 = 0 as *u8;
  let out_len: i32 = 0;
  let cf: *u8 = 0 as *u8;
  let tmpc: *u8 = 0 as *u8;
  let outp: *u8 = 0 as *u8;
  let opt: *u8 = 0 as *u8;
  let argv: *u8 = 0 as *u8;
  let argv0: *u8 = 0 as *u8;
  let argc: i32 = 0;
  let use_lto: i32 = 0;
  let emit_stdout: i32 = 0;
  let rc: i32 = 0;
  unsafe {
    path = driver_parsed_work_p_get(pp_path());
    module = driver_parsed_work_p_get(pp_module());
    out_buf = driver_parsed_work_p_get(pp_out());
    out_len = driver_codegen_outbuf_len(out_buf);
    out_data = driver_codegen_outbuf_data(out_buf);
    cf = driver_parsed_work_p_get(pp_cf());
    tmpc = driver_parsed_work_p_get(pp_tmpc());
    outp = driver_parsed_work_p_get(pp_out_path());
    opt = driver_parsed_work_p_get(pp_opt());
    argv = driver_parsed_work_p_get(pp_argv());
    argc = driver_parsed_work_i_get(pi_argc());
    use_lto = driver_parsed_work_i_get(pi_use_lto());
    emit_stdout = driver_parsed_work_i_get(pi_emit_stdout());
  }
  if (emit_stdout != 0) {
    unsafe {
      driver_print_x_smoke_summary(module, out_len as usize);
    }
  }
  /* free arena/module/src early like C path after smoke */
  unsafe {
    free(driver_parsed_work_p_get(pp_arena()));
    free(driver_parsed_work_p_get(pp_module()));
    free(driver_parsed_work_p_get(pp_src()));
    driver_parsed_work_p_set(pp_arena(), 0 as *u8);
    driver_parsed_work_p_set(pp_module(), 0 as *u8);
    driver_parsed_work_p_set(pp_src(), 0 as *u8);
    rc = driver_parsed_write_out(cf, out_data, out_len);
  }
  if (rc != 0) {
    return 1;
  }
  if (emit_stdout != 0) {
    return 0;
  }
  unsafe {
    rc = driver_parsed_fclose_rc(cf);
    driver_parsed_work_p_set(pp_cf(), 0 as *u8);
  }
  if (rc != 0) {
    if (tmpc != 0 as *u8) {
      unsafe { unlink(tmpc); }
    }
    return 1;
  }
  unsafe {
    argv0 = driver_asm_argv0(argv);
    rc = driver_parsed_invoke_cc(tmpc, outp, opt, use_lto, argv0, argc, argv);
    /* invoke_cc unlinks tmp_c on success; clear so cleanup won't double-unlink */
    if (rc == 0) {
      driver_parsed_work_p_set(pp_tmpc(), 0 as *u8);
      free(tmpc);
    }
  }
  return rc;
}

/** Public entry: run compile pipeline after argv parse via work slots and steps. Seeds DriverCompileParsed fields then read_pp through finish.
 * Track-L: no_mangle keeps surface short name (not module-prefix mangled).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function driver_run_compiler_parsed(p: *u8, argc: i32, argv: *u8): i32 {
  let path: *u8 = 0 as *u8;
  let outp: *u8 = 0 as *u8;
  let lib: *u8 = 0 as *u8;
  let nlib: i32 = 0;
  let want_asm: i32 = 0;
  let target: *u8 = 0 as *u8;
  let opt: *u8 = 0 as *u8;
  let use_lto: i32 = 0;
  let ndef: i32 = 0;
  let defs: *u8 = 0 as *u8;
  let k: *u8 = 0 as *u8;
  let c: *u8 = 0 as *u8;
  let m: *u8 = 0 as *u8;
  let rc: i32 = 0;
  let plen: i32 = 0;
  let want_exe: i32 = 0;
  if (p == 0 as *u8) {
    return 1;
  }
  unsafe {
    driver_bump_stack_limit();
    path = driver_parsed_input_path(p);
    outp = driver_parsed_out_path(p);
    lib = driver_parsed_lib_roots(p);
    nlib = driver_parsed_n_lib_roots(p);
    want_asm = driver_parsed_want_asm(p);
    target = driver_parsed_target(p);
    opt = driver_parsed_opt_level(p);
    use_lto = driver_parsed_use_lto(p);
  }
  if (path == 0 as *u8) {
    return 1;
  }
  unsafe {
    if (driver_check_only_get() != 0) {
      want_asm = 0;
    }
  }
  /* See signature and body for contracts. */
  if (want_asm != 0) {
    want_exe = 1;
    if (outp != 0 as *u8) {
      unsafe {
        want_exe = xlang_output_want_exe(outp);
      }
    }
    if (want_exe != 0) {
      unsafe {
        plen = strlen(path) as i32;
      }
      if (plen > 0) {
        if (plen < 512) {
          unsafe {
            if (driver_source_has_generic_syntax(path, plen) != 0) {
              want_asm = 0;
            }
          }
        }
      }
    }
  }
  if (want_asm != 0) {
    unsafe {
      lib = driver_asm_bind_lib_roots(lib, nlib, &nlib);
      return driver_run_asm_backend(path, outp, lib, nlib, target, argc, argv);
    }
  }
  unsafe {
    driver_parsed_work_reset();
    driver_parsed_work_p_set(pp_path(), path);
    driver_parsed_work_p_set(pp_out_path(), outp);
    driver_parsed_work_p_set(pp_target(), target);
    driver_parsed_work_p_set(pp_argv(), argv);
    driver_parsed_work_p_set(pp_opt(), opt);
    driver_parsed_work_i_set(pi_use_lto(), use_lto);
    driver_parsed_work_i_set(pi_argc(), argc);
    driver_parsed_work_i_set(pi_want_asm(), want_asm);
    lib = driver_asm_bind_lib_roots(lib, nlib, &nlib);
    driver_parsed_work_p_set(pp_lib(), lib);
    driver_parsed_work_i_set(pi_nlib(), nlib);
    ndef = driver_asm_collect_defines(argc, argv);
    defs = driver_asm_defines_as_u8();
    driver_parsed_work_i_set(pi_ndef(), ndef);
    driver_parsed_work_p_set(pp_defs(), defs);
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
    driver_parsed_work_p_set(pp_kind(), k);
    driver_parsed_work_p_set(pp_code(), c);
    driver_parsed_work_p_set(pp_msg(), m);
    rc = rt_cp_step_read_pp();
  }
  if (rc != 0) {
    unsafe { driver_parsed_work_cleanup(); }
    return 1;
  }
  unsafe {
    rc = rt_cp_step_try_c();
  }
  if (rc == 2) {
    unsafe {
      rc = driver_parsed_work_i_get(pi_ec());
      driver_parsed_work_cleanup();
    }
    return rc;
  }
  if (rc != 0) {
    unsafe { driver_parsed_work_cleanup(); }
    return 1;
  }
  unsafe {
    rc = rt_cp_step_parse();
  }
  if (rc != 0) {
    unsafe { driver_parsed_work_cleanup(); }
    return 1;
  }
  unsafe {
    rc = rt_cp_step_load_deps();
  }
  if (rc != 0) {
    unsafe { driver_parsed_work_cleanup(); }
    return 1;
  }
  unsafe {
    rc = rt_cp_step_open_out();
  }
  if (rc != 0) {
    unsafe { driver_parsed_work_cleanup(); }
    return 1;
  }
  unsafe {
    rc = rt_cp_step_prerun();
  }
  if (rc != 0) {
    unsafe { driver_parsed_work_cleanup(); }
    return 1;
  }
  unsafe {
    rc = rt_cp_step_pipeline();
  }
  if (rc == 2) {
    /* check-only success */
    unsafe { driver_parsed_work_cleanup(); }
    return 0;
  }
  if (rc != 0) {
    unsafe { driver_parsed_work_cleanup(); }
    return 1;
  }
  unsafe {
    rc = rt_cp_step_finish();
    driver_parsed_work_cleanup();
  }
  return rc;
}
