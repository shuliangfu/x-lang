// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// R2 runtime_pipeline_abi pure authority (product PREFER hybrid wave45–wave58).
// Product: g05_try_x_to_o this file + seeds/runtime_pipeline_abi.from_x.c rest
//   (-DSHUX_RUNTIME_PIPELINE_ABI_FROM_X) ld -r → src/runtime_pipeline_abi.o
// Cap residual always-seed: pipeline_run_x_thread_fn_ptr
//   (fn address for driver_run_thread_on_large_stack; same pattern as driver_abi wave37).
// Cap residual always-seed (wave57): shux_asm_codegen_elf_o_thread_fn_ptr only.
// wave80: pure product_emit thin via export-extern asm_asm_codegen_elf_o (no same-TU -1 body).
// wave45 root fix: never put the two-char end-comment marker inside block prose
//   (historical char**/void* truncated parse → silent drop of all later export function).
// wave46: pure merge/collect helpers (ptr/size slots, i32_store, module import cstr,
//   collect_to_load_has, preprocess directive diag codes) — seed cold twins under FROM_X.
// wave47: pure collect seed_to_load + enqueue_module_imports (strdup Cap residual then pure).
// wave48: pure collect deps_process_one orch; Cap residual tmp_parse_and_enqueue;
//   G.7 reuses load_one_direct_import_at for resolve/read/preprocess store.
// wave49: pure collect paths_process_one orch; Cap residual paths_tmp_resolve_parse_enqueue
//   (resolve/read/preprocess + G.7 tmp_parse_and_enqueue + free prep).
// wave50: pure collect deps/paths transitive_impl orch (stack to_load[32] + process_one loop).
// wave51: pure load_one_direct_import_at + load_direct_fail_cleanup orch;
//   Cap residual then pure (wave55) shux_load_one_direct_resolve_read_preprocess;
//   G.7 paths_tmp reuses same resolve_read (no dual resolve/read/preprocess).
// wave52: pure collect tmp_parse_and_enqueue orch (malloc/memset ensure + parse + G.7 enqueue).
// wave53: pure collect paths_tmp_resolve_parse_enqueue orch (ensure tmp + resolve_read
//   + G.7 pure tmp_parse + free prep).
// wave54: pure collect strdup thin shell (malloc + scan len + byte copy + NUL; no libc strdup name).
// wave55: pure resolve_read_preprocess orch (stack resolved[4096] + FileView u8[32]
//   + pure resolve multi + runtime_read_file_view + pure preprocess + release + diags).
// wave56: pure pipeline_run_x thread large-stack _impl orch (PipelineRunSuArgs stack pack;
//   Cap-fn-ptr + G.7 driver_run_thread_on_large_stack; SHUX_DEBUG_PIPE notes cold-only).
// wave57: pure asm elf_o large-stack _impl orch (AsmElfLargeArgs stack pack u8[48];
//   Cap-fn-ptr + product_emit Cap residual; G.7 driver_run_thread_on_large_stack).
// wave58: pure dep_prerun_parse_skip_typeck_impl orch (check_only + skip typeck/codegen
//   flags + G.7 driver_pipeline_dep_ctx_* asm_entry_module_only + pure large_stack).
// wave59: pure dep_prerun_parse_only_impl orch (parser_parse_into_init +
//   pipeline_parse_set_main_from_buf_c; SHUX_ASM_DEBUG notes cold-only).
// wave60: pure dep_prerun_typeck_only_impl orch (parse_set_main + load_sync deps +
//   typeck_dep_prerun_module; SHUX_DEBUG_PIPE notes cold-only).
// wave61: pure preprocess_raw_to_malloc_impl orch (scratch + define table + preprocess_x_buf
//   + owned dup; Cap residual preprocess_* / pure diag helpers; oversized → pure fail).
// wave62: pure one_ctx_for_dep_prerun_map_impl orch (tmp malloc arena/module + parse_into
//   ok/allow -2 + import map via find_loaded; G.7 pctx_update / module import path).
// wave63: pure typeck_module_entry_only / with_sidecar / pipeline_typeck_module_for_ctx_impl
//   orch (Cap residual typeck_module C frontend + typeck_dep_module_ptrs_base BSS base).
// wave64: pure pipeline_parse_into_bytes orch (G.7 pure parser_parse_into_init +
//   G.7 pure driver_parse_into_buf_rc; non-zero ok → -1; cold twin under FROM_X).
// wave65: pure pipeline_resolve_path_into_static orch (G.7 pure multi resolve +
//   entry_dir_get (wave68 pure) / resolved_path_buf_slot (wave69 pure BSS); cold twin under FROM_X).
// wave66: pure pipeline_read_file_stage_prep + pipeline_read_file_commit_prep orch
//   (G.7 pure preprocess + stage clear/set/take (wave71 pure BSS) + Cap residual
//   loaded_import_commit_from_owned; cold twins under FROM_X).
// wave67: pure pipeline_dep_ctx_path_bufs_reset + pipeline_dep_ctx_copy_entry_dir orch
//   (LP64 offsetof + LE store/byte copy; same layout as driver_abi wave19);
//   pure pipeline_dep_ctx_set_use_asm_backend thin → G.7 driver_pipeline_dep_ctx_set_use_asm;
//   cold twins under FROM_X.
// wave68: pure pipeline_entry_dir_copy / set_dot / get orch (module BSS buf 512 +
//   "." lit + is_dot flag; G.7 single authority for resolve_path / set_entry_dir;
//   cold twins under FROM_X).
// wave69: pure pipeline_resolved_path_buf_slot (module BSS buf 512; G.7 single authority
//   for pure into_static + read_file_stage_prep path base; cold twin under FROM_X).
// wave70: pure pipeline_dep_arena/module_slot_set/at (module BSS 32×LP64 ptr cells each;
//   G.7 shux_ptr_slot_* on raw u8[256]; single authority for pure set_dep_slots / get_dep_*;
//   cold twins under FROM_X).
// wave71: pure pipeline_rf_stage_prep_clear/set/take (module BSS ptr cell + size cell;
//   G.7 shux_ptr_slot_* / shux_size_slot_*; single authority for pure stage_prep / commit_prep;
//   cold twins under FROM_X).
// wave72: pure pipeline_loaded_import_commit_from_owned / data / len_get (module BSS
//   buf+len+cap cells; G.7 ptr/size slots + malloc ensure floor SHUX_PIPELINE_IMPORT_BUF_CAP;
//   cold twins under FROM_X).
// wave73: pure pipeline_diag_emitted_flag_slot (module BSS i32 flag; G.7 single authority for
//   pure reset/note/get; cold twin under FROM_X).
// wave74: pure driver_dep_* table BSS orch (arena/module/path_registry/seeded 32 slots;
//   G.7 shux_ptr_slot_* + pure seeded_slot; no cross-TU naked global — only accessors;
//   cold twins under FROM_X).
// wave75: pure entry_lib authority (shux_cstr_typeck_lit / shux_entry_lib_keyword_lit /
//   shux_entry_lib_name_from_path_impl + thin gate); module BSS stem_buf[128] + keyword lits;
//   G.7 single path matches C seed order (keywords before std/stem — closes pure std/-first drift);
//   cold twins under FROM_X).
// wave76: pure shux_cstr_offset (G.7 &s[off] → C &s[off] / s+off; closes Cap residual pointer
//   arith leaf for pipe_dir_tail / pipe_strip_prefix_seg / driver -D parse); cold twin under FROM_X.
// wave77: pure typeck_ndep / typeck_dep_* table BSS + slot/get/set_impl / ptrs_base
//   (G.7 shux_ptr_slot_*; product hybrid writers only via accessors — rt_run_* pure +
//   driver_typeck_*; cold seed naked C globals stay under #ifndef FROM_X for cold twins).
// wave78: pure shu_lsp_ptr_slot_clear (G.7 shux_ptr_slot_set null) + shux_fputs_stdout
//   (G.7 g05 shux_driver_stdout_ptr + shux_driver_fputs_opaque) + driver_asm_fp_is_stdout
//   + driver_asm_fclose_file (G.7 g05 stdout_ptr compare + fclose_opaque); cold twins under FROM_X.
// wave79: pure shux_path_try_realpath_inplace (G.7 g05 shux_driver_realpath_opaque + stack
//   resolved[1024] + pipe_cstr_copy; fail → leave path unchanged; matches seed POSIX/APPLE
//   realpath+snprintf and non-POSIX no-op via harness null); cold twin under FROM_X.
// wave80: pure shux_asm_codegen_elf_o_product_emit thin (export-extern asm_asm_codegen_elf_o only —
//   remove same-TU weak -1 stub so call keeps external reloc → final strong bridge;
//   seed cold twin under #ifndef FROM_X). Closes product_emit Cap residual leaf.
// wave81: pure shux_preprocess / shux_preprocess_quiet / shux_preprocess_with_path thin public
//   surface (G.7 pure shux_preprocess_raw_to_malloc_impl; product always X-pipeline path;
//   seed cold twin keeps LEGACY preprocess_c_fallback under #ifndef FROM_X).
// Cap residual still: fn-ptr / typeck_module C frontend
//   (+ pipeline_sizeof_* / preprocess engine residual).
// PLATFORM: SHARED — pure link-name contract; verify mac + Ubuntu L2 PREFER hybrid.

// wave73: pipeline_diag_emitted_flag_slot is pure export function below (pure BSS).
// wave74: driver_dep_seeded_slot / *_ptr_set_impl / path_registry_* / *_buf are pure below.
// wave75: shux_cstr_typeck_lit / shux_entry_lib_keyword_lit / name_from_path_impl pure below.
// wave76: shux_cstr_offset is pure export function below (not Cap residual).
// wave77: typeck_ndep_slot / store_impl / typeck_dep_*_get/set_impl / ptrs_base pure below.
// wave78: shu_lsp_ptr_slot_clear / shux_fputs_stdout / driver_asm_fp_is_stdout /
//   driver_asm_fclose_file are pure export functions below.
// wave79: shux_path_try_realpath_inplace is pure export function below.
// wave80: shux_asm_codegen_elf_o_product_emit is pure export function below.
export extern "C" function strchr(s: *u8, c: i32): *u8;
export extern "C" function pipeline_asm_user_dep_skip_x_typeck(path: *u8): i32;
export extern "C" function pipeline_asm_user_std_net_dep_path(path: *u8): i32;
export extern "C" function pipeline_codegen_path_is_std_io_driver_bytes(path: *u8): i32;
// wave63: typeck_module_entry_only / typeck_module_with_sidecar are pure export functions below.
// Cap residual: C frontend typeck_module only (wave77 pure owns typeck_dep_module_ptrs_base BSS).
// PLATFORM: SHARED — same ABI as seed cold twins; pure owns null gates and ndep branch.
export extern "C" function typeck_module(module: *u8, dep_mods: *u8, ndep: i32, a: *u8, b: i32): i32;
export extern "C" function free(p: *u8): void;
// wave52 pure tmp_parse orch: libc malloc/memset for large tmp arena/module ensure+zero.
// PLATFORM: SHARED — same ABI as seed cold twin; free() still releases ownership.
export extern "C" function malloc(n: usize): *u8;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
// wave54: shux_collect_strdup is pure export function below (not Cap residual).
// Do not export-extern libc strdup by name — conflicts with string.h after -E preamble.
// wave52: shux_collect_tmp_parse_and_enqueue is pure export function below (not Cap residual).
// wave53: shux_collect_paths_tmp_resolve_parse_enqueue is pure export function below.
// wave55: shux_load_one_direct_resolve_read_preprocess is pure export function below.
// wave55 pure resolve_read: runtime file view (ShuxRuntimeFileView 24B; pad 32 stack).
// PLATFORM: SHARED — same ABI as fmt_check pure path; G.7 no second view layout.
export extern "C" function runtime_read_file_view(path: *u8, out: *u8): i32;
export extern "C" function runtime_release_file_view(view: *u8): void;
export extern "C" function ast_module_free(mod: *u8): void;
// wave78: shu_lsp_ptr_slot_clear is pure export function below (G.7 shux_ptr_slot_set).
/* See implementation. */
export extern "C" function ast_pipeline_dep_ctx_reset(ctx: *u8): void;
export extern "C" function ast_pipeline_dep_ctx_set_module(ctx: *u8, idx: i32, m: *u8): void;
export extern "C" function ast_pipeline_dep_ctx_set_arena(ctx: *u8, idx: i32, a: *u8): void;
export extern "C" function ast_pipeline_dep_ctx_set_import_path(ctx: *u8, idx: i32, bytes: *u8, len: i32): void;
export extern "C" function ast_pipeline_dep_ctx_set_ndep(ctx: *u8, n: i32): void;
// wave56: pipeline_run_x_thread_fn_impl is pure export function below.
// wave57: shux_asm_codegen_elf_o_thread_fn_impl is pure export function below.
// wave80: product_emit is pure thin below (G.7 export-extern asm_asm_codegen_elf_o → bridge).
// Cap residual always-seed: Cap-fn-ptr for asm large-stack only (wave57/wave80).
// PLATFORM: SHARED — must not define same-TU body for asm_asm_codegen_elf_o (weak -1 was Cap trap).
export extern "C" function asm_asm_codegen_elf_o(module: *u8, arena: *u8, ctx: *u8, elf_ctx: *u8, out_buf: *u8): i32;
export extern "C" function shux_asm_codegen_elf_o_thread_fn_ptr(): *u8;
// Cap-fn-ptr residual: always-seed address of thin pipeline_run_x_thread_fn.
export extern "C" function pipeline_run_x_thread_fn_ptr(): *u8;
// wave56 pure pipeline large-stack orch: set entry source_len + run pipeline.
export extern "C" function driver_set_pipeline_entry_source_len(len: i64): void;
export extern "C" function pipeline_run_x_pipeline(module: *u8, arena: *u8, source_data: *u8, source_len: i64, out_buf: *u8, ctx: *u8): i32;
export extern "C" function driver_run_thread_on_large_stack(fn: *u8, arg: *u8): void;

// wave78: shux_fputs_stdout / driver_asm_fp_is_stdout / driver_asm_fclose_file are pure below.
// g05 prologue harness (same as driver_abi wave22/26): FILE* cast residual for pure .x.
// PLATFORM: SHARED — static inline in g05_try_x_to_o prologue; not a second product authority.
export extern "C" function shux_driver_fputs_opaque(s: *u8, stream: *u8): i32;
export extern "C" function shux_driver_stdout_ptr(): *u8;
export extern "C" function shux_driver_fclose_opaque(stream: *u8): i32;
// wave79: g05 harness — libc realpath char* cast residual (labi_path_io same clash avoidance).
// PLATFORM: SHARED POSIX/APPLE call realpath; non-POSIX harness returns null (seed no-op).
export extern "C" function shux_driver_realpath_opaque(path: *u8, resolved: *u8): *u8;
// wave75: shux_import_dep_dir_from_path_impl removed — pure import_dep_dir is full body.
/* wave45: do not export-extern pipeline_debug_trace_named_func_bodies here —
 * pure export function below is the single authority (#[no_mangle]).
 * A prior export extern + export function dual caused call sites to emit the
 * mangled name while the def stayed short → UNDEF under hybrid. */
/* See implementation. */
/* See implementation. */
/* See implementation. */
export extern "C" function driver_asm_fflush_stdout(): void;
// wave79: shux_path_try_realpath_inplace is pure export function below (not Cap residual).
// wave67: pipeline_dep_ctx_path_bufs_reset / copy_entry_dir are pure export functions below.
// wave67: pipeline_dep_ctx_set_use_asm_backend is pure thin over G.7 driver authority.
export extern "C" function driver_pipeline_dep_ctx_set_use_asm(ctx: *u8, v: i32): void;
export extern "C" function ast_pipeline_ctx_append_lib_root(ctx: *u8, path: *u8, len: i32): i32;
/* wave61: shux_preprocess_raw_to_malloc_impl is pure export function below.
 * Cap residual preprocess engine still C (ast_pool / preprocess.x authority): */
export extern "C" function preprocess_define_reset(): void;
export extern "C" function preprocess_define_add(name: *u8): void;
export extern "C" function preprocess_x_buf(src: *u8, src_len: i64, out_buf: *u8, out_cap: i32): i32;
export extern "C" function preprocess_if_stack_len(): i32;
// PLATFORM: SHARED — same C ABI as seed cold twin; pure orch owns malloc/copy/diag gates.
// wave74: driver_dep_seed_slots pure orch owns tables (no seed_slots_impl body required under hybrid).
// wave75: shux_entry_lib_name_from_path_impl / shux_cstr_typeck_lit /
//   shux_entry_lib_keyword_lit are pure export functions below (not Cap residual).
// wave70: pipeline_dep_arena/module_slot_set/at are pure export functions below (pure BSS 32×LP64).
// PLATFORM: SHARED — G.7 single authority for pure set_dep_slots / get_dep_*; seed cold twins only.
/* See implementation. */
// wave75: pipeline_asm_debug_enabled_impl removed — pure pipeline_asm_debug_enabled uses getenv.
export extern "C" function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;
export extern "C" function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void;
/* See implementation. */

// wave65: pipeline_resolve_path_into_static is pure export function below (not Cap residual).
// wave68: pipeline_entry_dir_get / copy / set_dot are pure export functions below (pure BSS).
// wave69: pipeline_resolved_path_buf_slot is pure export function below (pure BSS 512).
// PLATFORM: SHARED — pure entry_dir + pure resolved_path for into_static orch.
// wave66: pipeline_read_file_stage_prep / commit_prep are pure export functions below.
// wave71: pipeline_rf_stage_prep_clear/set/take are pure export functions below (pure BSS).
// wave72: pipeline_loaded_import_commit_from_owned / data / len_get are pure export functions below.
// PLATFORM: SHARED — pure owns stage BSS + loaded_import ensure policy (single G.7 authority).
// wave72 pure commit: libc memcpy for ensure-buffer fill (same ABI as seed cold twin).
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
// wave64: pipeline_parse_into_bytes is pure export function below (not Cap residual).
// wave65: pipeline_resolve_path_into_static is pure export function below.
// wave66: pipeline_read_file_stage_prep / commit_prep are pure export functions below.
// wave56: shux_pipeline_run_x_pipeline_large_stack_impl is pure export function below.
// wave58: shux_pipeline_dep_prerun_parse_skip_typeck_impl is pure export function below.
// wave59: shux_pipeline_dep_prerun_parse_only_impl is pure export function below.
// wave60: shux_pipeline_dep_prerun_typeck_only_impl is pure export function below.
// Cap residual glue still called from pure typeck_only orch (strong defs in glue/ast_pool):
// PLATFORM: SHARED — same C ABI as seed _impl; weak pure parse_set_main_from_buf surface in this TU.
export extern "C" function pipeline_load_and_sync_direct_import_deps_c(module: *u8, arena: *u8, ctx: *u8): i32;
export extern "C" function pipeline_typeck_dep_prerun_module_c(module: *u8, arena: *u8, ctx: *u8): i32;
// wave58 pure skip_typeck orch: G.7 driver flags + asm_entry field accessors (runtime_driver_abi).
// PLATFORM: SHARED — same symbols as rt_run_asm_backend pure path.
export extern "C" function driver_check_only_get(): i32;
export extern "C" function driver_check_only_set(v: i32): void;
export extern "C" function driver_x_pipeline_skip_typeck_set(v: i32): void;
export extern "C" function driver_x_pipeline_skip_codegen_set(v: i32): void;
export extern "C" function driver_pipeline_dep_ctx_get_asm_entry_module_only(ctx: *u8): i32;
export extern "C" function driver_pipeline_dep_ctx_set_asm_entry_module_only(ctx: *u8, v: i32): void;
/* See implementation. */
export extern "C" function access(path: *u8, mode: i32): i32;
// wave76: shux_cstr_offset is pure export function below (not Cap residual).
/* See implementation. */
// wave68: pipeline_entry_dir_copy / set_dot are pure export functions below (not Cap residual).
// wave75: pipeline_set_dep_slots_impl removed — pure pipeline_set_dep_slots uses wave70 slots.
/* See implementation. */
/* See implementation. */
/* See implementation. */
// wave67: pipeline_dep_ctx_set_use_asm_backend is pure export function below (G.7 driver thin).
// wave62: shux_pipeline_one_ctx_for_dep_prerun_map_impl is pure export function below.
// Cap residual sizes (glue) + Cap-struct-return parse ok unpack (driver residual):
// PLATFORM: SHARED — same symbols as collect tmp_parse / driver_parse_into_buf_rc pure path.
export extern "C" function pipeline_sizeof_arena(): usize;
export extern "C" function pipeline_sizeof_module(): usize;
export extern "C" function driver_parse_into_buf_rc(arena: *u8, module: *u8, data: *u8, len: i32, out_main_idx: *i32): i32;
// wave57: shux_asm_codegen_elf_o_large_stack_impl is pure export function below.
/* See implementation. */
/* wave46: shux_module_num_imports / import_path_cstr / ptr+size slots / i32_store
 * are pure export function below (not export-extern Cap residual). */
// wave51: shux_load_one_direct_import_at + shux_load_direct_fail_cleanup are pure orch below
// (wave55 pure shux_load_one_direct_resolve_read_preprocess for resolve+read+preprocess).
// wave50: shux_collect_deps_transitive_impl / shux_collect_dep_paths_transitive_impl
// are pure export function below (not export-extern Cap residual).
// wave52: shux_collect_tmp_parse_and_enqueue is pure export function below.
// wave55: shux_load_one_direct_resolve_read_preprocess is pure export function below.
export extern "C" function pipeline_debug_trace_named_func_bodies_impl(phase: *u8, module: *u8, arena: *u8): void;

/* See implementation. */

#[no_mangle]
export function parser_parse_into_init(module: *u8, arena: *u8): void {
}

/** Exported function `parser_get_module_num_imports`.
 * Implements `parser_get_module_num_imports`.
 * @param module *u8
 * @return i32
 */
#[no_mangle]
export function parser_get_module_num_imports(module: *u8): i32 {
  return 0;
}

/** Exported function `parser_get_module_import_path`.
 * Implements `parser_get_module_import_path`.
 * @param module *u8
 * @param idx i32
 * @param path_buf *u8
 * @return void
 */
#[no_mangle]
export function parser_get_module_import_path(module: *u8, idx: i32, path_buf: *u8): void {
  if (path_buf == 0 as *u8) {
    return;
  }
  unsafe {
    path_buf[0] = 0;
  }
}

/** Exported function `asm_skip_heavy_set_pipeline_ctx`.
 * Implements `asm_skip_heavy_set_pipeline_ctx`.
 * @param ctx *u8
 * @return void
 */
#[no_mangle]
export function asm_skip_heavy_set_pipeline_ctx(ctx: *u8): void {
}

/** Exported function `pipeline_fill_array_lit_types_for_skipped_typeck`.
 * Implements `pipeline_fill_array_lit_types_for_skipped_typeck`.
 * @param m *u8
 * @param a *u8
 * @return void
 */
#[no_mangle]
export function pipeline_fill_array_lit_types_for_skipped_typeck(m: *u8, a: *u8): void {
}

/** Exported function `pipeline_fill_soa_field_access_for_asm_emit`.
 * Implements `pipeline_fill_soa_field_access_for_asm_emit`.
 * @param m *u8
 * @param a *u8
 * @return void
 */
#[no_mangle]
export function pipeline_fill_soa_field_access_for_asm_emit(m: *u8, a: *u8): void {
}

/** Exported function `pipeline_module_fixup_with_arena_stmt_orders`.
 * Implements `pipeline_module_fixup_with_arena_stmt_orders`.
 * @param m *u8
 * @param a *u8
 * @return void
 */
#[no_mangle]
export function pipeline_module_fixup_with_arena_stmt_orders(m: *u8, a: *u8): void {
}

/* wave80: asm_asm_codegen_elf_o is export-extern only (see top of file).
 * Historical pure weak body returned -1 and poisoned same-TU product emit;
 * G.7 product_emit thin below keeps external reloc → user_asm_seed_bridge strong. */

/**
 * Product asm elf_o emit trampoline: true bridge emit for pure large-stack orch.
 * @param module *u8 — AST module
 * @param arena *u8 — AST arena
 * @param ctx *u8 — PipelineDepCtx
 * @param elf_ctx *u8 — ElfCodegenCtx
 * @param out_buf *u8 — emit out buffer
 * @return i32 — emit status from strong asm_asm_codegen_elf_o (bridge)
 * wave80 pure Cap residual:
 *   thin forward to export-extern asm_asm_codegen_elf_o (no same-TU body);
 *   closes always-seed product_emit leaf; cold twin under seed #ifndef FROM_X.
 * PLATFORM: SHARED — final link must provide strong user_asm_seed_bridge (or equiv).
 */
#[no_mangle]
export function shux_asm_codegen_elf_o_product_emit(module: *u8, arena: *u8, ctx: *u8, elf_ctx: *u8, out_buf: *u8): i32 {
  unsafe {
    return asm_asm_codegen_elf_o(module, arena, ctx, elf_ctx, out_buf);
  }
  return 0 - 1;
}

/** Exported function `pipeline_parse_set_main_from_buf_c`.
 * Implements `pipeline_parse_set_main_from_buf_c`.
 * @param m *u8
 * @param a *u8
 * @param d *u8
 * @param len i32
 * @return i32
 */
#[no_mangle]
export function pipeline_parse_set_main_from_buf_c(m: *u8, a: *u8, d: *u8, len: i32): i32 {
  return 0;
}

/**
 * Reset the pipeline "diag already emitted" sticky flag to 0.
 * @return void
 * wave73: pure G.7 pipeline_diag_emitted_flag_slot (pure BSS).
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_diag_emitted_reset(): void {
  unsafe {
    let p: *i32 = pipeline_diag_emitted_flag_slot();
    p[0] = 0;
  }
}

/**
 * Set the pipeline "diag already emitted" sticky flag to 1.
 * @return void
 * wave73: pure G.7 pipeline_diag_emitted_flag_slot (pure BSS).
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_diag_emitted_note(): void {
  unsafe {
    let p: *i32 = pipeline_diag_emitted_flag_slot();
    p[0] = 1;
  }
}

/**
 * Read the pipeline "diag already emitted" sticky flag (normalize to 0/1).
 * @return i32 — 1 when any prior note was recorded; 0 when clear
 * wave73: pure G.7 pipeline_diag_emitted_flag_slot (pure BSS).
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_diag_emitted_get(): i32 {
  unsafe {
    let p: *i32 = pipeline_diag_emitted_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `get_ndep`.
 * Query helper `get_ndep`.
 * @return i32
 */
#[no_mangle]
export function get_ndep(): i32 {
  unsafe {
    let p: *i32 = typeck_ndep_slot();
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

/* ---- G-02f-34：set_ndep + dep_seeded get/set ---- */

// pipeline_set_ndep: see function docblock below.
/** Exported function `pipeline_set_ndep`.
 * Implements `pipeline_set_ndep`.
 * @param n i32
 * @return void
 */
#[no_mangle]
export function pipeline_set_ndep(n: i32): void {
  typeck_ndep_store(n);
}

/** Exported function `driver_dep_seeded_get`.
 * Implements `driver_dep_seeded_get`.
 * @param i i32
 * @return i32
 */
#[no_mangle]
export function driver_dep_seeded_get(i: i32): i32 {
  if (i < 0) {
    return 0;
  }
  if (i >= 32) {
    return 0;
  }
  unsafe {
    let p: *i32 = driver_dep_seeded_slot(i);
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `driver_dep_seeded_set`.
 * Implements `driver_dep_seeded_set`.
 * @param i i32
 * @param v i32
 * @return void
 */
#[no_mangle]
export function driver_dep_seeded_set(i: i32, v: i32): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  unsafe {
    let p: *i32 = driver_dep_seeded_slot(i);
    p[0] = v;
  }
}

/** Exported function `typeck_driver_dep_seeded_get`.
 * Implements `typeck_driver_dep_seeded_get`.
 * @param i i32
 * @return i32
 */
#[no_mangle]
export function typeck_driver_dep_seeded_get(i: i32): i32 {
  return driver_dep_seeded_get(i);
}

/* See implementation. */

#[no_mangle]
export function get_dep_module(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  unsafe {
    let n: i32 = get_ndep();
    if (i >= n) {
      return 0 as *u8;
    }
    let r: *u8 = typeck_dep_module_get(i);
    return r;
  }
  return 0 as *u8;
}

/** Exported function `get_dep_arena`.
 * Query helper `get_dep_arena`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function get_dep_arena(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  unsafe {
    let n: i32 = get_ndep();
    if (i >= n) {
      return 0 as *u8;
    }
    let r: *u8 = typeck_dep_arena_get(i);
    return r;
  }
  return 0 as *u8;
}

/** Exported function `typeck_get_dep_module`.
 * Implements `typeck_get_dep_module`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function typeck_get_dep_module(i: i32): *u8 {
  return get_dep_module(i);
}

/** Exported function `typeck_get_dep_arena`.
 * Implements `typeck_get_dep_arena`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function typeck_get_dep_arena(i: i32): *u8 {
  return get_dep_arena(i);
}

/** Exported function `pipeline_set_dep`.
 * Implements `pipeline_set_dep`.
 * @param i i32
 * @param mod *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_set_dep(i: i32, mod: *u8, arena: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  unsafe {
    typeck_dep_module_set_impl(i, mod);
    typeck_dep_arena_set_impl(i, arena);
  }
}

/* See implementation. */

#[no_mangle]
export function driver_dep_publish_slot(i: i32, arena: *u8, module: *u8, import_path: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  unsafe {
    driver_dep_arena_ptr_set_impl(i, arena);
    driver_dep_module_ptr_set_impl(i, module);
    driver_dep_seeded_set(i, 1);
    /* See implementation. */
    driver_dep_path_registry_set(i, import_path);
  }
}

/** Exported function `typeck_driver_dep_module_buf`.
 * Implements `typeck_driver_dep_module_buf`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function typeck_driver_dep_module_buf(i: i32): *u8 {
  unsafe {
    let r: *u8 = driver_dep_module_buf(i);
    return r;
  }
  return 0 as *u8;
}

/** Exported function `typeck_driver_dep_arena_buf`.
 * Implements `typeck_driver_dep_arena_buf`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function typeck_driver_dep_arena_buf(i: i32): *u8 {
  unsafe {
    let r: *u8 = driver_dep_arena_buf(i);
    return r;
  }
  return 0 as *u8;
}

/* See implementation. */

/* See implementation. */
#[no_mangle]
export function shux_cstr_ends_with_dot_x(s: *u8): i32 {
  if (s == 0 as *u8) {
    return 0;
  }
  unsafe {
    let n: i64 = 0;
    while (s[n] != 0) {
      n = n + 1;
    }
    if (n < 2) {
      return 0;
    }
    /* '.' == 46, 'x' == 120 */
    if (s[n - 2] != 46) {
      return 0;
    }
    if (s[n - 1] != 120) {
      return 0;
    }
    return 1;
  }
  return 0;
}

/* See implementation. */
#[no_mangle]
export function shux_asm_out_buf_is_object_magic(data: *u8): i32 {
  if (data == 0 as *u8) {
    return 0;
  }
  unsafe {
    let b0: u8 = data[0];
    let b1: u8 = data[1];
    let b2: u8 = data[2];
    let b3: u8 = data[3];
    /* MH_MAGIC_64 LE: cf fa ed fe */
    if (b0 == 207) {
      if (b1 == 250) {
        if (b2 == 237) {
          if (b3 == 254) {
            return 1;
          }
        }
      }
    }
    /* MH_CIGAM_64: fe ed fa cf */
    if (b0 == 254) {
      if (b1 == 237) {
        if (b2 == 250) {
          if (b3 == 207) {
            return 1;
          }
        }
      }
    }
    /* ELF: 7f 'E' 'L' 'F' */
    if (b0 == 127) {
      if (b1 == 69) {
        if (b2 == 76) {
          if (b3 == 70) {
            return 1;
          }
        }
      }
    }
    return 0;
  }
  return 0;
}

/** Exported function `shux_import_path_is_file_path`.
 * Implements `shux_import_path_is_file_path`.
 * @param import_path *u8
 * @return i32
 */
#[no_mangle]
export function shux_import_path_is_file_path(import_path: *u8): i32 {
  if (import_path == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (import_path[0] == 0) {
      return 0;
    }
    /* '/' or '.' */
    if (import_path[0] == 47) {
      return 1;
    }
    if (import_path[0] == 46) {
      return 1;
    }
    if (strchr(import_path, 47) != 0 as *u8) {
      return 1;
    }
    if (shux_cstr_ends_with_dot_x(import_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `shux_asm_user_std_dep_skip_x_typeck`.
 * Implements `shux_asm_user_std_dep_skip_x_typeck`.
 * @param dep_path *u8
 * @return i32
 */
#[no_mangle]
export function shux_asm_user_std_dep_skip_x_typeck(dep_path: *u8): i32 {
  if (dep_path == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (dep_path[0] == 0) {
      return 0;
    }
    if (pipeline_asm_user_dep_skip_x_typeck(dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `shux_asm_user_std_net_dep_path`.
 * Implements `shux_asm_user_std_net_dep_path`.
 * @param dep_path *u8
 * @return i32
 */
#[no_mangle]
export function shux_asm_user_std_net_dep_path(dep_path: *u8): i32 {
  if (dep_path == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (dep_path[0] == 0) {
      return 0;
    }
    if (pipeline_asm_user_std_net_dep_path(dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `shux_asm_user_std_io_driver_dep_path`.
 * Implements `shux_asm_user_std_io_driver_dep_path`.
 * @param dep_path *u8
 * @return i32
 */
#[no_mangle]
export function shux_asm_user_std_io_driver_dep_path(dep_path: *u8): i32 {
  if (dep_path == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (dep_path[0] == 0) {
      return 0;
    }
    if (pipeline_codegen_path_is_std_io_driver_bytes(dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `shux_asm_user_dep_parse_skip_typeck_path`.
 * Implements `shux_asm_user_dep_parse_skip_typeck_path`.
 * @param dep_path *u8
 * @return i32
 */
#[no_mangle]
export function shux_asm_user_dep_parse_skip_typeck_path(dep_path: *u8): i32 {
  unsafe {
    if (shux_asm_user_std_net_dep_path(dep_path) != 0) {
      return 1;
    }
    if (shux_asm_user_std_io_driver_dep_path(dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `shux_asm_out_buf_is_object`.
 * Implements `shux_asm_out_buf_is_object`.
 * @param data *u8
 * @param len i64
 * @return i32
 */
#[no_mangle]
export function shux_asm_out_buf_is_object(data: *u8, len: i64): i32 {
  if (data == 0 as *u8) {
    return 0;
  }
  if (len < 4) {
    return 0;
  }
  unsafe {
    return shux_asm_out_buf_is_object_magic(data);
  }
  return 0;
}

/* See implementation. */

#[no_mangle]
export function shux_dep_prerun_entry_dir(main_entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): *u8 {
  unsafe {
    if (n_lib_roots <= 0) {
      return main_entry_dir;
    }
    return shux_dep_prerun_entry_dir_pick(main_entry_dir, lib_roots, n_lib_roots);
  }
  return main_entry_dir;
}

/** Exported function `shux_find_loaded_import_index`.
 * Implements `shux_find_loaded_import_index`.
 * @param import_path *u8
 * @param all_paths *u8
 * @param n_all i32
 * @return i32
 */
#[no_mangle]
export function shux_find_loaded_import_index(import_path: *u8, all_paths: *u8, n_all: i32): i32 {
  if (import_path == 0 as *u8) {
    return -1;
  }
  if (all_paths == 0 as *u8) {
    return -1;
  }
  if (n_all <= 0) {
    return -1;
  }
  return shux_find_loaded_import_index_scan(import_path, all_paths, n_all);
}

/** Exported function `shux_merge_deps_path_already_out`.
 * Read path helper `shux_merge_deps_path_already_out`.
 * @param path *u8
 * @param out_paths *u8
 * @param n_out i32
 * @return i32
 */
#[no_mangle]
export function shux_merge_deps_path_already_out(path: *u8, out_paths: *u8, n_out: i32): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  if (out_paths == 0 as *u8) {
    return 0;
  }
  if (n_out <= 0) {
    return 0;
  }
  return shux_merge_deps_path_already_out_scan(path, out_paths, n_out);
}

/**
 * Write NUL-terminated C string s to host stdout via fputs.
 * @param s *u8 — C string; null → no-op
 * @return void
 * wave78 pure: G.7 g05 shux_driver_stdout_ptr + shux_driver_fputs_opaque (FILE* cast residual
 * lives in g05_try_x_to_o prologue; .x never names FILE*).
 * Closes always-seed Cap soft residual for emit_pipeline_glue_include.
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function shux_fputs_stdout(s: *u8): void {
  if (s == 0 as *u8) {
    return;
  }
  unsafe {
    let so: *u8 = shux_driver_stdout_ptr();
    if (so != 0 as *u8) {
      shux_driver_fputs_opaque(s, so);
    }
  }
}

// shux_emit_pipeline_glue_include: see function docblock below.
/**
 * Emit the pipeline_glue.c include line to stdout (codegen glue surface).
 * @return void
 * G.7 pure shux_fputs_stdout (wave78) owns stdout write.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_emit_pipeline_glue_include(): void {
  // "\n#include \"pipeline_glue.c\"\n"
  let s: u8[32] = [];
  s[0]=10;s[1]=35;s[2]=105;s[3]=110;s[4]=99;s[5]=108;s[6]=117;s[7]=100;
  s[8]=101;s[9]=32;s[10]=34;s[11]=112;s[12]=105;s[13]=112;s[14]=101;s[15]=108;
  s[16]=105;s[17]=110;s[18]=101;s[19]=95;s[20]=103;s[21]=108;s[22]=117;s[23]=101;
  s[24]=46;s[25]=99;s[26]=34;s[27]=10;s[28]=0;
  unsafe {
    shux_fputs_stdout(&s[0]);
  }
}

// shux_import_dep_dir_from_path: see function docblock below.
/** Exported function `shux_import_dep_dir_from_path`.
 * Implements `shux_import_dep_dir_from_path`.
 * @param path *u8
 * @param dep_dir *u8
 * @param dep_dir_size i64
 * @return i32
 */
#[no_mangle]
export function shux_import_dep_dir_from_path(path: *u8, dep_dir: *u8, dep_dir_size: i64): i32 {
  if (path == 0 as *u8) { return 0 - 1; }
  if (dep_dir == 0 as *u8) { return 0 - 1; }
  if (dep_dir_size == 0) { return 0 - 1; }
  unsafe {
    let n: i64 = 0;
    while (n < 4096) {
      if (path[n] == 0) { break; }
      n = n + 1;
    }
    let last_slash: i64 = 0 - 1;
    let i: i64 = 0;
    while (i < n) {
      // '/'
      if (path[i] == 47) { last_slash = i; }
      i = i + 1;
    }
    if (last_slash < 0) {
      if (dep_dir_size < 2) { return 0 - 1; }
      dep_dir[0] = 46; // '.'
      dep_dir[1] = 0;
      return 0;
    }
    let dlen: i64 = last_slash;
    if (dlen >= dep_dir_size) { return 0 - 1; }
    let j: i64 = 0;
    while (j < dlen) {
      dep_dir[j] = path[j];
      j = j + 1;
    }
    dep_dir[dlen] = 0;
    return 0;
  }
  return 0 - 1;
}

/* See implementation. */

#[no_mangle]
export function pipeline_debug_trace_body_x_mega_pre_reset(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_pre_reset", module, arena);
  }
}

/** Exported function `pipeline_debug_trace_body_x_mega_post_reset`.
 * Implements `pipeline_debug_trace_body_x_mega_post_reset`.
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_body_x_mega_post_reset(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_post_reset", module, arena);
  }
}

/** Exported function `pipeline_debug_trace_body_x_mega_post_params`.
 * Implements `pipeline_debug_trace_body_x_mega_post_params`.
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_body_x_mega_post_params(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_post_params", module, arena);
  }
}

/** Exported function `pipeline_debug_trace_body_x_mega_post_frame`.
 * Implements `pipeline_debug_trace_body_x_mega_post_frame`.
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_body_x_mega_post_frame(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_post_frame", module, arena);
  }
}

/** Exported function `pipeline_debug_trace_body_x_mega_post_locals`.
 * Implements `pipeline_debug_trace_body_x_mega_post_locals`.
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_body_x_mega_post_locals(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_post_locals", module, arena);
  }
}

/** Exported function `pipeline_debug_trace_body_x_mega_pre_emit`.
 * Implements `pipeline_debug_trace_body_x_mega_pre_emit`.
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_body_x_mega_pre_emit(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_pre_emit", module, arena);
  }
}

// driver_typeck_dep_sidecar_clear: see function docblock below.
/** Exported function `driver_typeck_dep_sidecar_clear`.
 * Implements `driver_typeck_dep_sidecar_clear`.
 * @return void
 */
#[no_mangle]
export function driver_typeck_dep_sidecar_clear(): void {
  typeck_ndep_store(0);
  let i: i32 = 0;
  while (i < 32) {
    typeck_dep_module_set(i, 0 as *u8);
    typeck_dep_arena_set(i, 0 as *u8);
    i = i + 1;
  }
}

// driver_dep_seeded_clear_slots: see function docblock below.
/** Exported function `driver_dep_seeded_clear_slots`.
 * Implements `driver_dep_seeded_clear_slots`.
 * @return void
 */
#[no_mangle]
export function driver_dep_seeded_clear_slots(): void {
  let i: i32 = 0;
  while (i < 32) {
    driver_dep_seeded_set(i, 0);
    unsafe {
      driver_dep_path_registry_set(i, 0 as *u8);
      driver_dep_arena_ptr_set(i, 0 as *u8);
      driver_dep_module_ptr_set(i, 0 as *u8);
    }
    i = i + 1;
  }
}

// driver_dep_seeded_clear_all: see function docblock below.
/** Exported function `driver_dep_seeded_clear_all`.
 * Implements `driver_dep_seeded_clear_all`.
 * @return void
 */
#[no_mangle]
export function driver_dep_seeded_clear_all(): void {
  driver_dep_seeded_clear_slots();
  driver_typeck_dep_sidecar_clear();
}

// shux_get_entry_dir: see function docblock below.
/** Exported function `shux_get_entry_dir`.
 * Implements `shux_get_entry_dir`.
 * @param input_path *u8
 * @param entry_dir *u8
 * @param size i64
 * @return void
 */
#[no_mangle]
export function shux_get_entry_dir(input_path: *u8, entry_dir: *u8, size: i64): void {
  if (entry_dir == 0 as *u8) {
    return;
  }
  if (size == 0) {
    return;
  }
  if (input_path == 0 as *u8) {
    unsafe {
      entry_dir[0] = 0;
    }
    return;
  }
  unsafe {
    let last: i32 = 0 - 1;
    let i: i32 = 0;
    while (i < 65536) {
      if (input_path[i] == 0) {
        break;
      }
      if (input_path[i] == 47) {
        last = i;
      }
      i = i + 1;
    }
    if (last < 0) {
      if (size >= 2) {
        entry_dir[0] = 46;
        entry_dir[1] = 0;
      } else {
        entry_dir[0] = 0;
      }
      return;
    }
    let len: i32 = last;
    let cap: i32 = size as i32;
    if (cap <= 0) {
      return;
    }
    if (len >= cap) {
      len = cap - 1;
    }
    let k: i32 = 0;
    while (k < len) {
      entry_dir[k] = input_path[k];
      k = k + 1;
    }
    entry_dir[len] = 0;
  }
}

/**
 * Return 1 if opaque stream fp is host stdout, else 0.
 * @param fp *u8 — opaque FILE* as *u8; null → 0
 * @return i32 — 1 when fp equals stdout, else 0
 * wave78 pure: G.7 g05 shux_driver_stdout_ptr identity compare (no FILE* in .x).
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function driver_asm_fp_is_stdout(fp: *u8): i32 {
  if (fp == 0 as *u8) {
    return 0;
  }
  unsafe {
    let so: *u8 = shux_driver_stdout_ptr();
    if (fp == so) {
      return 1;
    }
  }
  return 0;
}

/**
 * fclose an opaque non-stdout stream (null-safe).
 * @param fp *u8 — opaque FILE* as *u8; null → no-op
 * @return void
 * wave78 pure: G.7 g05 shux_driver_fclose_opaque (FILE* cast residual in g05 prologue).
 * Does not special-case stdout — callers use driver_asm_fclose_asm_out for that.
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function driver_asm_fclose_file(fp: *u8): void {
  if (fp == 0 as *u8) {
    return;
  }
  unsafe {
    shux_driver_fclose_opaque(fp);
  }
}

// driver_asm_fclose_asm_out: see function docblock below.
/**
 * Close asm output stream: fflush stdout when fp is null/stdout; else fclose.
 * @param fp *u8 — opaque FILE* as *u8; null or stdout → fflush only
 * @return void
 * G.7 pure driver_asm_fp_is_stdout + driver_asm_fclose_file (wave78) + residual fflush.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function driver_asm_fclose_asm_out(fp: *u8): void {
  unsafe {
    if (fp == 0 as *u8) {
      driver_asm_fflush_stdout();
      return;
    }
    if (driver_asm_fp_is_stdout(fp) != 0) {
      driver_asm_fflush_stdout();
      return;
    }
    driver_asm_fclose_file(fp);
  }
}

/* See implementation. */

// G-02f-229：lib_root + import（'.'→'/'）+ ".x"
/** Exported function `shux_import_path_to_file_path`.
 * Implements `shux_import_path_to_file_path`.
 * @param lib_root *u8
 * @param import_path *u8
 * @param path *u8
 * @param path_size i64
 * @return void
 */
#[no_mangle]
export function shux_import_path_to_file_path(lib_root: *u8, import_path: *u8, path: *u8, path_size: i64): void {
  if (path == 0 as *u8) {
    return;
  }
  if (path_size == 0) {
    return;
  }
  unsafe {
    let cap: i32 = path_size as i32;
    if (cap <= 0) {
      return;
    }
    let r: *u8 = lib_root;
    if (r == 0 as *u8) {
      // "."
      r = 0 as *u8;
    } else {
      if (r[0] == 0) {
        r = 0 as *u8;
      }
    }
    let off: i32 = 0;
    if (r == 0 as *u8) {
      if (off + 1 < cap) {
        path[off] = 46;
        off = off + 1;
      }
    } else {
      let ri: i32 = 0;
      while (ri < 4096) {
        if (r[ri] == 0) {
          break;
        }
        if (off + 1 >= cap) {
          break;
        }
        path[off] = r[ri];
        off = off + 1;
        ri = ri + 1;
      }
    }
    if (off + 1 < cap) {
      path[off] = 47;
      off = off + 1;
    }
    if (import_path != 0 as *u8) {
      let s: i32 = 0;
      while (s < 4096) {
        if (import_path[s] == 0) {
          break;
        }
        if (off + 1 >= cap) {
          break;
        }
        let ch: u8 = import_path[s];
        if (ch == 46) {
          path[off] = 47;
        } else {
          path[off] = ch;
        }
        off = off + 1;
        s = s + 1;
      }
    }
    // ".x"
    if (off + 2 < cap) {
      path[off] = 46;
      path[off + 1] = 120;
      path[off + 2] = 0;
    } else {
      if (off < cap) {
        path[off] = 0;
      } else {
        if (cap > 0) {
          path[cap - 1] = 0;
        }
      }
    }
  }
}

// pipe_cstr_join_slash: see function docblock below.
/** Exported function `pipe_cstr_join_slash`.
 * Implements `pipe_cstr_join_slash`.
 * @param dst *u8
 * @param cap i32
 * @param a *u8
 * @param b *u8
 * @return void
 */
export function pipe_cstr_join_slash(dst: *u8, cap: i32, a: *u8, b: *u8): void {
  if (dst == 0 as *u8) { return; }
  if (cap <= 0) { return; }
  let off: i32 = 0;
  unsafe {
    if (a != 0 as *u8) {
      let i: i32 = 0;
      while (i < 4096) {
        if (a[i] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = a[i];
        off = off + 1;
        i = i + 1;
      }
    }
    if (off + 1 < cap) {
      dst[off] = 47;
      off = off + 1;
    }
    if (b != 0 as *u8) {
      let j: i32 = 0;
      while (j < 4096) {
        if (b[j] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = b[j];
        off = off + 1;
        j = j + 1;
      }
    }
    if (off < cap) {
      dst[off] = 0;
    } else {
      dst[cap - 1] = 0;
    }
  }
}

/**
 * Best-effort realpath into path in place; on failure leave path unchanged.
 * @param path *u8 — mutable C string buffer; null → no-op
 * @param path_size i64 — buffer capacity including trailing NUL; 0 → no-op
 * @return void
 * wave79 pure Cap residual orch:
 *   stack resolved[1024] (matches seed char resolved[1024]);
 *   G.7 g05 shux_driver_realpath_opaque (libc realpath char* cast residual;
 *   non-POSIX host returns null → no-op, matches seed #else);
 *   success → G.7 pipe_cstr_copy into path with path_size cap (snprintf "%s" equiv).
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function shux_path_try_realpath_inplace(path: *u8, path_size: i64): void {
  if (path == 0 as *u8) {
    return;
  }
  if (path_size == 0) {
    return;
  }
  unsafe {
    // Match seed stack resolved[1024]; PATH_MAX on gold Linux is larger but seed pin is 1024.
    let resolved: u8[1024] = [];
    let r: *u8 = shux_driver_realpath_opaque(path, &resolved[0]);
    if (r != 0 as *u8) {
      let cap: i32 = path_size as i32;
      if (cap > 0) {
        pipe_cstr_copy(path, cap, r);
      }
    }
  }
}

// shux_resolve_file_import_path: see function docblock below.
/** Exported function `shux_resolve_file_import_path`.
 * Implements `shux_resolve_file_import_path`.
 * @param entry_dir *u8
 * @param import_path *u8
 * @param path *u8
 * @param path_size i64
 * @return void
 * G.7 pure shux_path_try_realpath_inplace (wave79) owns realpath-in-place after join.
 */
#[no_mangle]
export function shux_resolve_file_import_path(entry_dir: *u8, import_path: *u8, path: *u8, path_size: i64): void {
  if (path == 0 as *u8) {
    return;
  }
  if (path_size == 0) {
    return;
  }
  if (import_path == 0 as *u8) {
    unsafe {
      path[0] = 0;
    }
    return;
  }
  let cap: i32 = path_size as i32;
  if (cap <= 0) {
    return;
  }
  unsafe {
    // absolute
    if (import_path[0] == 47) {
      pipe_cstr_copy(path, cap, import_path);
    } else {
      if (entry_dir != 0 as *u8) {
        if (entry_dir[0] != 0) {
          pipe_cstr_join_slash(path, cap, entry_dir, import_path);
        } else {
          pipe_cstr_copy(path, cap, import_path);
        }
      } else {
        pipe_cstr_copy(path, cap, import_path);
      }
    }
    shux_path_try_realpath_inplace(path, path_size);
  }
}

// driver_dep_slot_for_path_scan: see function docblock below.
/** Exported function `driver_dep_slot_for_path_scan`.
 * Implements `driver_dep_slot_for_path_scan`.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function driver_dep_slot_for_path_scan(path: *u8): i32 {
  if (path == 0 as *u8) { return 0 - 1; }
  unsafe {
    let i: i32 = 0;
    while (i < 32) {
      let reg: *u8 = driver_dep_path_registry_at(i);
      if (reg != 0 as *u8) {
        if (pipe_cstr_eq(reg, path) != 0) { return i; }
      }
      i = i + 1;
    }
  }
  return 0 - 1;
}

/** Exported function `driver_dep_slot_for_path`.
 * Implements `driver_dep_slot_for_path`.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function driver_dep_slot_for_path(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  return driver_dep_slot_for_path_scan(path);
}

/* See implementation. */

/**
 * Preprocess raw source into an owned NUL-terminated malloc buffer.
 * @param raw *u8 — source bytes; null only allowed when raw_len == 0
 * @param raw_len i64 — byte count; must fit SHUX_PIPELINE_CTX_BUF_SIZE (4MiB)
 * @param out_src *u8 — char** base as bytes; slot 0 set to owned prep (or null on fail)
 * @param out_src_len *u8 — size_t* base as bytes; slot 0 set to output length (0 on fail)
 * @param path_diag *u8 — path for preprocess diags; may be null
 * @param defines *u8 — const char** define names base; may be null when ndefines == 0
 * @param ndefines i32 — define count; < 0 rejected by thin gate
 * @param emit_diag i32 — non-zero → emit PP/XP diags on failure
 * @return i32 — 0 success; -1 fail (OOM / oversized / preprocess error / unclosed #if)
 * wave61 pure Cap residual orch:
 *   G.7 preprocess_define_reset / preprocess_define_add / preprocess_x_buf /
 *   preprocess_if_stack_len (preprocess engine Cap residual in C);
 *   G.7 pure pipeline_diag_preprocess_* (no va_list reportf);
 *   G.7 shux_ptr_slot_set / shux_size_slot_set for out slots (char** / size_t*);
 *   oversized raw → pure pipeline_diag_preprocess_fail (fixed msg; seed reportf cold-only).
 * PLATFORM: SHARED — same control flow as historical seed _impl.
 */
#[no_mangle]
export function shux_preprocess_raw_to_malloc_impl(raw: *u8, raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, defines: *u8, ndefines: i32, emit_diag: i32): i32 {
  // Clear outs first (same as seed).
  if (out_src != 0 as *u8) {
    shux_ptr_slot_set(out_src, 0, 0 as *u8);
  }
  if (out_src_len != 0 as *u8) {
    shux_size_slot_set(out_src_len, 0, 0);
  }
  // SHUX_PIPELINE_CTX_BUF_SIZE — fixed 4MiB pipeline ctx buffer (runtime_pipeline_abi.h).
  let buf_cap: i32 = 4194304;
  let buf_cap_i64: i64 = buf_cap as i64;
  if (raw_len > buf_cap_i64) {
    if (emit_diag != 0) {
      // Cold twin uses reportf with sizes; pure keeps fixed PP002 fail (no va_list).
      pipeline_diag_preprocess_fail(path_diag);
    }
    return 0 - 1;
  }
  let scratch: *u8 = 0 as *u8;
  unsafe {
    scratch = malloc(buf_cap as usize);
  }
  if (scratch == 0 as *u8) {
    if (emit_diag != 0) {
      // "scratch buffer"
      let what: u8[16] = [];
      what[0] = 115; what[1] = 99; what[2] = 114; what[3] = 97; what[4] = 116;
      what[5] = 99; what[6] = 104; what[7] = 32; what[8] = 98; what[9] = 117;
      what[10] = 102; what[11] = 102; what[12] = 101; what[13] = 114; what[14] = 0;
      pipeline_diag_preprocess_alloc_fail(path_diag, &what[0]);
    }
    return 0 - 1;
  }
  // Reset define table then add caller defines (char** via ptr slots).
  unsafe {
    preprocess_define_reset();
  }
  let di: i32 = 0;
  while (di < ndefines) {
    if (defines != 0 as *u8) {
      let dname: *u8 = shux_ptr_slot_get(defines, di);
      if (dname != 0 as *u8) {
        unsafe {
          preprocess_define_add(dname);
        }
      }
    }
    di = di + 1;
  }
  let n: i32 = 0;
  unsafe {
    // Authority preprocess engine; raw may be null only when raw_len == 0 (thin gate).
    n = preprocess_x_buf(raw, raw_len, scratch, buf_cap);
  }
  if (n < 0) {
    unsafe {
      free(scratch);
    }
    if (emit_diag != 0) {
      // Directive-level negative codes (-2..-7) prefer over unclosed-if (stack may be non-empty).
      if (n <= (0 - 2)) {
        pipeline_diag_preprocess_directive_code(path_diag, n);
      } else {
        let stack_n: i32 = 0;
        unsafe {
          stack_n = preprocess_if_stack_len();
        }
        if (stack_n != 0) {
          pipeline_diag_preprocess_unclosed_if(path_diag);
        } else {
          pipeline_diag_preprocess_fail(path_diag);
        }
      }
    }
    return 0 - 1;
  }
  let stack_after: i32 = 0;
  unsafe {
    stack_after = preprocess_if_stack_len();
  }
  if (stack_after != 0) {
    unsafe {
      free(scratch);
    }
    if (emit_diag != 0) {
      pipeline_diag_preprocess_unclosed_if(path_diag);
    }
    return 0 - 1;
  }
  // Owned output: n bytes + trailing NUL (byte copy; no memcpy short name).
  let dup: *u8 = 0 as *u8;
  unsafe {
    dup = malloc((n + 1) as usize);
  }
  if (dup == 0 as *u8) {
    unsafe {
      free(scratch);
    }
    if (emit_diag != 0) {
      // "output buffer"
      let what2: u8[16] = [];
      what2[0] = 111; what2[1] = 117; what2[2] = 116; what2[3] = 112; what2[4] = 117;
      what2[5] = 116; what2[6] = 32; what2[7] = 98; what2[8] = 117; what2[9] = 102;
      what2[10] = 102; what2[11] = 101; what2[12] = 114; what2[13] = 0;
      pipeline_diag_preprocess_alloc_fail(path_diag, &what2[0]);
    }
    return 0 - 1;
  }
  let i: i32 = 0;
  unsafe {
    while (i < n) {
      dup[i] = scratch[i];
      i = i + 1;
    }
    dup[n] = 0;
    free(scratch);
  }
  if (out_src != 0 as *u8) {
    shux_ptr_slot_set(out_src, 0, dup);
  }
  if (out_src_len != 0 as *u8) {
    shux_size_slot_set(out_src_len, 0, n as i64);
  }
  return 0;
}

/**
 * Thin gate for preprocess raw→malloc (null/oversized rejects; emit_diag fixed 1).
 * @param raw *u8 — source bytes; null with raw_len > 0 → -1
 * @param raw_len i64 — byte count; < 0 → -1
 * @param out_src *u8 — char** out base as bytes
 * @param out_src_len *u8 — size_t* out base as bytes
 * @param path_diag *u8 — path for diags
 * @param defines *u8 — const char** define table
 * @param ndefines i32 — define count; < 0 → -1
 * @return i32 — 0 success; -1 fail
 * wave61: body in pure shux_preprocess_raw_to_malloc_impl.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_preprocess_raw_to_malloc(raw: *u8, raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, defines: *u8, ndefines: i32): i32 {
  if (raw_len < 0) {
    return 0 - 1;
  }
  if (raw == 0 as *u8) {
    if (raw_len > 0) {
      return 0 - 1;
    }
  }
  if (ndefines < 0) {
    return 0 - 1;
  }
  unsafe {
    return shux_preprocess_raw_to_malloc_impl(raw, raw_len, out_src, out_src_len, path_diag, defines, ndefines, 1);
  }
  return 0 - 1;
}

/**
 * Public preprocess surface with path diags (owned malloc prep or null).
 * @param source *u8 — source bytes; null → null (out_length cleared when non-null)
 * @param source_len usize — byte count; 0 → pipe_cstr_len(source) (≡ seed strlen)
 * @param path_diag *u8 — path for PP/XP diags; may be null
 * @param defines *u8 — const char** define names base; used only when ndefines > 0
 * @param ndefines i32 — define count
 * @param out_length *u8 — size_t* out length as bytes; may be null
 * @return *u8 — owned NUL-terminated prep (caller free); null on fail
 * wave81 pure Cap residual thin:
 *   G.7 pure shux_preprocess_raw_to_malloc_impl with emit_diag=1 (product X-pipeline path);
 *   LP64 stack out cells for char** / size_t* (same pattern as stage_prep);
 *   seed cold twin keeps LEGACY preprocess_c_fallback under #ifndef FROM_X.
 * PLATFORM: SHARED — matches seed SHUX_USE_X_PIPELINE && !LEGACY control flow.
 */
#[no_mangle]
export function shux_preprocess_with_path(source: *u8, source_len: usize, path_diag: *u8, defines: *u8, ndefines: i32, out_length: *u8): *u8 {
  if (out_length != 0 as *u8) {
    shux_size_slot_set(out_length, 0, 0);
  }
  if (source == 0 as *u8) {
    return 0 as *u8;
  }
  let slen: i64 = source_len as i64;
  if (slen == 0) {
    slen = pipe_cstr_len(source) as i64;
  }
  // LP64 out cells for impl (char** / size_t*).
  let out_prep: u8[8] = [];
  let out_len: u8[8] = [];
  pipe_store_ptr_slot(&out_prep[0], 0, 0 as *u8);
  shux_size_slot_set(&out_len[0], 0, 0);
  let def_arg: *u8 = 0 as *u8;
  if (ndefines > 0) {
    def_arg = defines;
  }
  let rc: i32 = 0;
  unsafe {
    rc = shux_preprocess_raw_to_malloc_impl(source, slen, &out_prep[0], &out_len[0], path_diag, def_arg, ndefines, 1);
  }
  if (rc != 0) {
    return 0 as *u8;
  }
  let prep: *u8 = pipe_load_ptr_slot(&out_prep[0], 0);
  let olen: i64 = shux_size_slot_get(&out_len[0], 0);
  if (out_length != 0 as *u8) {
    shux_size_slot_set(out_length, 0, olen);
  }
  return prep;
}

/**
 * Public preprocess surface quiet (no path diags; emit_diag=0).
 * @param source *u8 — source bytes; null → null
 * @param source_len usize — byte count; 0 → pipe_cstr_len(source)
 * @param defines *u8 — const char** define names base; used only when ndefines > 0
 * @param ndefines i32 — define count
 * @param out_length *u8 — size_t* out length as bytes; may be null
 * @return *u8 — owned prep or null
 * wave81 pure Cap residual thin: G.7 pure raw_to_malloc_impl emit_diag=0 path_diag null.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_preprocess_quiet(source: *u8, source_len: usize, defines: *u8, ndefines: i32, out_length: *u8): *u8 {
  if (out_length != 0 as *u8) {
    shux_size_slot_set(out_length, 0, 0);
  }
  if (source == 0 as *u8) {
    return 0 as *u8;
  }
  let slen: i64 = source_len as i64;
  if (slen == 0) {
    slen = pipe_cstr_len(source) as i64;
  }
  let out_prep: u8[8] = [];
  let out_len: u8[8] = [];
  pipe_store_ptr_slot(&out_prep[0], 0, 0 as *u8);
  shux_size_slot_set(&out_len[0], 0, 0);
  let def_arg: *u8 = 0 as *u8;
  if (ndefines > 0) {
    def_arg = defines;
  }
  let rc: i32 = 0;
  unsafe {
    rc = shux_preprocess_raw_to_malloc_impl(source, slen, &out_prep[0], &out_len[0], 0 as *u8, def_arg, ndefines, 0);
  }
  if (rc != 0) {
    return 0 as *u8;
  }
  let prep: *u8 = pipe_load_ptr_slot(&out_prep[0], 0);
  let olen: i64 = shux_size_slot_get(&out_len[0], 0);
  if (out_length != 0 as *u8) {
    shux_size_slot_set(out_length, 0, olen);
  }
  return prep;
}

/**
 * Public preprocess surface (default quiet).
 * @param source *u8 — source bytes
 * @param source_len usize — byte count; 0 → cstr len
 * @param defines *u8 — const char** define table
 * @param ndefines i32 — define count
 * @param out_length *u8 — size_t* out length
 * @return *u8 — owned prep or null
 * wave81 pure Cap residual thin: G.7 pure shux_preprocess_quiet.
 * PLATFORM: SHARED — matches seed alias.
 */
#[no_mangle]
export function shux_preprocess(source: *u8, source_len: usize, defines: *u8, ndefines: i32, out_length: *u8): *u8 {
  return shux_preprocess_quiet(source, source_len, defines, ndefines, out_length);
}

// driver_dep_seed_slots: see function docblock below.
/** Exported function `driver_dep_seed_slots`.
 * Implements `driver_dep_seed_slots`.
 * @param arenas *u8
 * @param modules *u8
 * @param n i32
 * @return void
 */
#[no_mangle]
export function driver_dep_seed_slots(arenas: *u8, modules: *u8, n: i32): void {
  let j: i32 = 0;
  while (j < 32) {
    if (j < n) {
      unsafe {
        let a: *u8 = 0 as *u8;
        let m: *u8 = 0 as *u8;
        if (arenas != 0 as *u8) {
          a = pipe_load_ptr_slot(arenas, j);
        }
        if (modules != 0 as *u8) {
          m = pipe_load_ptr_slot(modules, j);
        }
        driver_dep_arena_ptr_set(j, a);
        driver_dep_module_ptr_set(j, m);
        driver_dep_seeded_set(j, 1);
      }
    } else {
      driver_dep_seeded_set(j, 0);
    }
    j = j + 1;
  }
}

// pipe_cstr_contains: see function docblock below.
/** Exported function `pipe_cstr_contains`.
 * Implements `pipe_cstr_contains`.
 * @param hay *u8
 * @param needle *u8
 * @return i32
 */
export function pipe_cstr_contains(hay: *u8, needle: *u8): i32 {
  if (hay == 0 as *u8) { return 0; }
  if (needle == 0 as *u8) { return 0; }
  if (needle[0] == 0) { return 1; }
  unsafe {
    let hi: i32 = 0;
    while (hi < 4096) {
      if (hay[hi] == 0) { return 0; }
      let j: i32 = 0;
      let ok: i32 = 1;
      while (ok != 0) {
        if (needle[j] == 0) { return 1; }
        if (hay[hi + j] == 0) { ok = 0; }
        else {
          if (hay[hi + j] != needle[j]) { ok = 0; }
          else { j = j + 1; }
        }
      }
      hi = hi + 1;
    }
  }
  return 0;
}

/**
 * Thin gate: -E lib_prefix from entry path (null → "typeck"; else pure impl).
 * @param input_path *u8 — entry .x path; null → static "typeck"
 * @return *u8 — never null; keyword lit or stem BSS or "typeck"
 * wave75: G.7 pure shux_entry_lib_name_from_path_impl owns full keyword/std/core/basename
 * order (matches seed cold twin; no pure std/-first dual path).
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function shux_entry_lib_name_from_path(input_path: *u8): *u8 {
  if (input_path == 0 as *u8) {
    return shux_cstr_typeck_lit();
  }
  return shux_entry_lib_name_from_path_impl(input_path);
}

/* See implementation. */

#[no_mangle]
export function pipeline_get_dep_arena_slot(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  unsafe {
    return pipeline_dep_arena_slot_at(i);
  }
  return 0 as *u8;
}

/** Exported function `pipeline_get_dep_module_slot`.
 * Implements `pipeline_get_dep_module_slot`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function pipeline_get_dep_module_slot(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  unsafe {
    return pipeline_dep_module_slot_at(i);
  }
  return 0 as *u8;
}

// See implementation.
let g_import_open_valid: i32 = 0;
let g_import_open_import: u8[65] = [];
let g_import_open_resolved: u8[512] = [];

/** Exported function `pipe_cstr_copy`.
 * Implements `pipe_cstr_copy`.
 * @param dst *u8
 * @param cap i32
 * @param src *u8
 * @return void
 */
export function pipe_cstr_copy(dst: *u8, cap: i32, src: *u8): void {
  let i: i32 = 0;
  if (dst == 0 as *u8) { return; }
  if (cap <= 0) { return; }
  if (src == 0 as *u8) {
    dst[0] = 0;
    return;
  }
  unsafe {
    while (i < (cap - 1)) {
      let c: u8 = src[i];
      dst[i] = c;
      if (c == 0) { return; }
      i = i + 1;
    }
    dst[cap - 1] = 0;
  }
}

/** Exported function `pipeline_diag_import_open_fail_once`.
 * Implements `pipeline_diag_import_open_fail_once`.
 * @param import_path *u8
 * @param resolved_path *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_import_open_fail_once(import_path: *u8, resolved_path: *u8): void {
  let q: u8[2] = [];
  q[0] = 63; // '?'
  q[1] = 0;
  let import_key: *u8 = import_path;
  let resolved_key: *u8 = resolved_path;
  if (import_key == 0 as *u8) { import_key = &q[0]; }
  if (resolved_key == 0 as *u8) { resolved_key = &q[0]; }
  unsafe {
    if (g_import_open_valid != 0) {
      if (pipe_cstr_eq(&g_import_open_import[0], import_key) != 0) {
        if (pipe_cstr_eq(&g_import_open_resolved[0], resolved_key) != 0) {
          pipeline_diag_emitted_note();
          return;
        }
      }
    }
    pipe_cstr_copy(&g_import_open_import[0], 65, import_key);
    pipe_cstr_copy(&g_import_open_resolved[0], 512, resolved_key);
    g_import_open_valid = 1;
    pipeline_diag_emitted_note();
    let kind: u8[16] = [];
    let code: u8[8] = [];
    let msg: u8[32] = [];
    // "import error"
    kind[0]=105;kind[1]=109;kind[2]=112;kind[3]=111;kind[4]=114;kind[5]=116;kind[6]=32;kind[7]=101;
    kind[8]=114;kind[9]=114;kind[10]=111;kind[11]=114;kind[12]=0;
    // "IMP001"
    code[0]=73;code[1]=77;code[2]=80;code[3]=48;code[4]=48;code[5]=49;code[6]=0;
    // "cannot open import"
    msg[0]=99;msg[1]=97;msg[2]=110;msg[3]=110;msg[4]=111;msg[5]=116;msg[6]=32;msg[7]=111;
    msg[8]=112;msg[9]=101;msg[10]=110;msg[11]=32;msg[12]=105;msg[13]=109;msg[14]=112;msg[15]=111;
    msg[16]=114;msg[17]=116;msg[18]=0;
    let file: *u8 = resolved_path;
    if (file == 0 as *u8) { file = import_path; }
    diag_report_with_code(file, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
}

/* ---- G-02f-56：resolve_path / read_file / parse loaded import ---- */

/**
 * Resolve import logical path into the pipeline static resolved_path BSS buffer.
 * Uses a single lib root "." and the current pipeline entry_dir (set via pipeline_set_entry_dir).
 * @param path_c *u8 — NUL-terminated import path; null → no-op
 * @return void
 * wave65 pure Cap residual orch (wave69: resolved slot pure):
 *   G.7 pure shux_resolve_import_file_path_multi (file-path / -L / entry_dir fallbacks);
 *   pure pipeline_entry_dir_get (wave68 BSS) + pure pipeline_resolved_path_buf_slot (wave69 BSS).
 * Stack packs one LP64 ptr slot for lib_roots[1] = {"."} (same as historical seed).
 * PLATFORM: SHARED — resolved buffer cap 512 matches historical seed pipeline_resolved_path_buf.
 */
#[no_mangle]
export function pipeline_resolve_path_into_static(path_c: *u8): void {
  if (path_c == 0 as *u8) {
    return;
  }
  // Single root "." — same as seed lib_roots[1] = { "." }.
  let dot: u8[2] = [];
  dot[0] = 46;
  dot[1] = 0;
  // LP64: one void* slot for multi(lib_roots, n=1, ...).
  let roots: u8[8] = [];
  unsafe {
    shux_ptr_slot_set(&roots[0], 0, &dot[0]);
    let entry: *u8 = pipeline_entry_dir_get();
    let rbuf: *u8 = pipeline_resolved_path_buf_slot();
    // Cap 512 — pure g_pipe_resolved_path_buf (wave69; cold seed char[512]).
    shux_resolve_import_file_path_multi(&roots[0], 1, entry, path_c, rbuf, 512 as i64);
  }
}

/**
 * Copy path_ptr[0..path_len) into a local C string and resolve into static BSS.
 * @param path_ptr *u8 — import path bytes; null → -1
 * @param path_len i32 — max copy length; clamped to 1..64 (0 or negative → 64)
 * @return i32 — 0 on success (always after null gate; multi writes last try path)
 * wave65: body uses pure pipeline_resolve_path_into_static (no seed _impl).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_resolve_path(path_ptr: *u8, path_len: i32): i32 {
  if (path_ptr == 0 as *u8) {
    return 0 - 1;
  }
  let plen: i32 = path_len;
  if (plen <= 0) {
    plen = 64;
  }
  if (plen > 64) {
    plen = 64;
  }
  let path_c: u8[65] = [];
  let k: i32 = 0;
  unsafe {
    while (k < plen) {
      if (path_ptr[k] == 0) {
        break;
      }
      path_c[k] = path_ptr[k];
      k = k + 1;
    }
    path_c[k] = 0;
    // G.7 pure into_static (wave65) — pure entry_dir + pure resolved BSS (wave68/69).
    pipeline_resolve_path_into_static(&path_c[0]);
  }
  return 0;
}

/**
 * Read resolved_path BSS file, preprocess into owned prep, store in stage BSS.
 * @return i32 — 0 success; -1 open fail / preprocess fail / null prep
 * wave66 pure orch (wave69 resolved slot; wave71 pure stage clear/set):
 *   pure pipeline_rf_stage_prep_clear / pipeline_rf_stage_prep_set (wave71 pure BSS);
 *   pure pipeline_resolved_path_buf_slot (wave69 BSS; path written by resolve_path_into_static);
 *   runtime_read_file_view into 32B stack ShuxRuntimeFileView (G.7 same as wave55 load_one);
 *   open fail → pure pipeline_diag_import_open_fail_once(null, path);
 *   G.7 pure shux_preprocess_raw_to_malloc (defines null, ndefines 0);
 *   runtime_release_file_view always after read success;
 *   null prep after preprocess ok → pure pipeline_diag_import_preprocess_fail.
 * PLATFORM: SHARED — same semantics as historical seed stage_prep.
 */
#[no_mangle]
export function pipeline_read_file_stage_prep(): i32 {
  // Drop any prior stage prep (owned heap).
  unsafe {
    pipeline_rf_stage_prep_clear();
  }
  let path: *u8 = 0 as *u8;
  unsafe {
    path = pipeline_resolved_path_buf_slot();
  }
  // ShuxRuntimeFileView ABI: data@0 length@8 needs_free@16 needs_munmap@20 (24B; pad 32).
  let view: u8[32] = [];
  let z: i32 = 0;
  while (z < 32) {
    view[z] = 0;
    z = z + 1;
  }
  let view_rc: i32 = 0;
  unsafe {
    view_rc = runtime_read_file_view(path, &view[0]);
  }
  if (view_rc != 0) {
    // Historical seed: import_path null, resolved_path = BSS path.
    pipeline_diag_import_open_fail_once(0 as *u8, path);
    return 0 - 1;
  }
  let raw_data: *u8 = shux_ptr_slot_get(&view[0], 0);
  let raw_len: i64 = shux_size_slot_get(&view[0], 1);
  // LP64 out cells for preprocess (char** / size_t*).
  let out_prep: u8[8] = [];
  let out_len: u8[8] = [];
  pipe_store_ptr_slot(&out_prep[0], 0, 0 as *u8);
  shux_size_slot_set(&out_len[0], 0, 0);
  let prep_rc: i32 = 0;
  unsafe {
    // defines null / ndefines 0 — same as historical stage_prep.
    prep_rc = shux_preprocess_raw_to_malloc(raw_data, raw_len, &out_prep[0], &out_len[0], path, 0 as *u8, 0);
  }
  unsafe {
    runtime_release_file_view(&view[0]);
  }
  if (prep_rc != 0) {
    return 0 - 1;
  }
  let prep: *u8 = pipe_load_ptr_slot(&out_prep[0], 0);
  let prep_len: i64 = shux_size_slot_get(&out_len[0], 0);
  if (prep == 0 as *u8) {
    pipeline_diag_import_preprocess_fail(0 as *u8, path);
    return 0 - 1;
  }
  unsafe {
    pipeline_rf_stage_prep_set(prep, prep_len);
  }
  return 0;
}

/**
 * Move stage prep into loaded_import BSS (ensure buffer + copy + free prep).
 * @return i32 — 0 success; -1 empty stage or OOM on loaded buffer ensure
 * wave66 pure orch (wave71 pure take + wave72 pure commit):
 *   pure pipeline_rf_stage_prep_take (wave71 BSS) → owned prep on stack slots;
 *   pure pipeline_loaded_import_commit_from_owned (wave72 ensure/memcpy/free).
 * PLATFORM: SHARED — G.7 single ensure body in pure commit (no Cap residual twin under hybrid).
 */
#[no_mangle]
export function pipeline_read_file_commit_prep(): i32 {
  // LP64: out_prep is char**; out_len is size_t*.
  let out_prep: u8[8] = [];
  let out_len: u8[8] = [];
  pipe_store_ptr_slot(&out_prep[0], 0, 0 as *u8);
  shux_size_slot_set(&out_len[0], 0, 0);
  let take_rc: i32 = 0;
  unsafe {
    // pure take expects char** / size_t* (slots as raw bytes).
    take_rc = pipeline_rf_stage_prep_take(&out_prep[0], &out_len[0]);
  }
  if (take_rc != 0) {
    return 0 - 1;
  }
  let prep: *u8 = pipe_load_ptr_slot(&out_prep[0], 0);
  let prep_len: i64 = shux_size_slot_get(&out_len[0], 0);
  if (prep == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return pipeline_loaded_import_commit_from_owned(prep, prep_len);
  }
  return 0 - 1;
}

/**
 * Resolve-path then read/preprocess/commit into loaded_import (two-stage).
 * @return i32 — 0 success; -1 if stage_prep or commit_prep fails
 * wave66: body uses pure stage_prep + pure commit_prep (no seed _impl).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_read_file(): i32 {
  unsafe {
    if (pipeline_read_file_stage_prep() != 0) {
      return 0 - 1;
    }
    if (pipeline_read_file_commit_prep() != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Parse source bytes into module via Cap residual parser_parse_into (ok unpack).
 * @param arena *u8 — AST arena; null → -1
 * @param module *u8 — AST module; null → -1
 * @param data *u8 — source bytes; null → -1
 * @param len i64 — byte length; negative or > INT32_MAX → -1; zero length allowed
 * @return i32 — 0 if parser ok==0; -1 on null/oversized/any non-zero ok
 * wave64 pure Cap residual orch:
 *   G.7 pure parser_parse_into_init (weak empty here; strong parser wins final link);
 *   G.7 pure driver_parse_into_buf_rc (unpacks Cap-struct-return ParseIntoResult.ok).
 * Contract: this API collapses every non-zero ok to -1 (including historical ok==-2).
 *   Contrast one_ctx map_impl (wave62), which accepts ok==-2 for import-table scan.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_parse_into_bytes(arena: *u8, module: *u8, data: *u8, len: i64): i32 {
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (data == 0 as *u8) {
    return 0 - 1;
  }
  // INT32_MAX — driver_parse_into_buf_rc residual takes int32_t len.
  let imax: i64 = 2147483647;
  if (len < 0) {
    return 0 - 1;
  }
  if (len > imax) {
    return 0 - 1;
  }
  let len_i32: i32 = len as i32;
  unsafe {
    // Same order as historical seed: init then parse_into.
    parser_parse_into_init(module, arena);
    // Cap-struct-return residual unpacks ParseIntoResult.ok; null out_main_idx.
    let pr_ok: i32 = driver_parse_into_buf_rc(arena, module, data, len_i32, 0 as *i32);
    // Historical: only ok==0 is success; any other code (incl. -2) → -1.
    if (pr_ok == 0) {
      return 0;
    }
    return 0 - 1;
  }
  return 0 - 1;
}

/**
 * Parse the pipeline loaded-import buffer into module (after resolve/read/preprocess stages).
 * @param arena *u8 — AST arena; null → -1
 * @param module *u8 — AST module; null → -1
 * @return i32 — 0 success, -1 null arena/module, empty loaded buffer, or parse fail
 * wave64: body uses pure pipeline_parse_into_bytes after pure loaded buffer accessors.
 * wave72: pure pipeline_loaded_import_data / pipeline_loaded_import_len_get (pure BSS).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_parse_into_loaded_import(arena: *u8, module: *u8): i32 {
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    let data: *u8 = pipeline_loaded_import_data();
    if (data == 0 as *u8) {
      return 0 - 1;
    }
    let len: i64 = pipeline_loaded_import_len_get();
    return pipeline_parse_into_bytes(arena, module, data, len);
  }
  return 0 - 1;
}

/* See implementation. */

// shux_pipeline_run_x_pipeline_large_stack: see function docblock below.
/**
 * Thin gate for large-stack pipeline_run_x_pipeline (null / empty source rejected).
 * @param module *u8 — AST module; null → -1
 * @param arena *u8 — AST arena; null → -1
 * @param source_data *u8 — source bytes; null → -1
 * @param source_len i64 — byte length; <=0 → -1
 * @param out_buf *u8 — codegen out buffer; may be null (pipeline accepts)
 * @param ctx *u8 — PipelineDepCtx; may be null
 * @return i32 — pipeline ec; -1 on thin reject
 * wave56: body in pure shux_pipeline_run_x_pipeline_large_stack_impl.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_pipeline_run_x_pipeline_large_stack(module: *u8, arena: *u8, source_data: *u8, source_len: i64, out_buf: *u8, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (source_data == 0 as *u8) {
    return 0 - 1;
  }
  if (source_len <= 0) {
    return 0 - 1;
  }
  unsafe {
    return shux_pipeline_run_x_pipeline_large_stack_impl(module, arena, source_data, source_len, out_buf, ctx);
  }
  return 0 - 1;
}

/* See implementation. */

/**
 * Dep prerun: full parse on large stack, skip typeck and codegen.
 * Saves/restores check_only + asm_entry_module_only; sets skip flags around large_stack.
 * @param dep_mod *u8 — dep AST module; caller thin already null-checked
 * @param dep_arena *u8 — dep AST arena
 * @param src *u8 — source bytes
 * @param len i64 — byte length
 * @param dep_out *u8 — optional out buffer (pipeline accepts null)
 * @param one_ctx *u8 — PipelineDepCtx; may be null (asm_entry field skipped)
 * @return i32 — pipeline ec from pure large_stack
 * wave58 pure Cap residual:
 *   G.7 driver_check_only_get/set;
 *   G.7 driver_x_pipeline_skip_typeck_set + skip_codegen_set;
 *   G.7 driver_pipeline_dep_ctx_get/set_asm_entry_module_only (no C struct field access);
 *   pure shux_pipeline_run_x_pipeline_large_stack (wave56).
 * PLATFORM: SHARED — same flag order as historical seed _impl.
 */
#[no_mangle]
export function shux_pipeline_dep_prerun_parse_skip_typeck_impl(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  unsafe {
    let saved: i32 = driver_check_only_get();
    let saved_entry_only: i32 = 0;
    driver_check_only_set(1);
    // Save/set asm_entry_module_only only when one_ctx is non-null (seed pctx branch).
    if (one_ctx != 0 as *u8) {
      saved_entry_only = driver_pipeline_dep_ctx_get_asm_entry_module_only(one_ctx);
      driver_pipeline_dep_ctx_set_asm_entry_module_only(one_ctx, 1);
    }
    driver_x_pipeline_skip_typeck_set(1);
    driver_x_pipeline_skip_codegen_set(1);
    // G.7 pure large_stack surface (wave56); re-null-checks inside thin gate are fine.
    let ec: i32 = shux_pipeline_run_x_pipeline_large_stack(dep_mod, dep_arena, src, len, dep_out, one_ctx);
    driver_x_pipeline_skip_codegen_set(0);
    driver_x_pipeline_skip_typeck_set(0);
    if (one_ctx != 0 as *u8) {
      driver_pipeline_dep_ctx_set_asm_entry_module_only(one_ctx, saved_entry_only);
    }
    // Restore check_only as 0/1 (seed: saved ? 1 : 0).
    if (saved != 0) {
      driver_check_only_set(1);
    } else {
      driver_check_only_set(0);
    }
    return ec;
  }
  return 0 - 1;
}

// shux_pipeline_dep_prerun_parse_skip_typeck: see function docblock below.
/**
 * Thin gate for dep prerun parse-skip-typeck (null / empty source rejected).
 * @param dep_mod *u8 — dep AST module; null → -1
 * @param dep_arena *u8 — dep AST arena; null → -1
 * @param src *u8 — source bytes; null → -1
 * @param len i64 — byte length; <=0 → -1
 * @param dep_out *u8 — optional out buffer
 * @param one_ctx *u8 — PipelineDepCtx; may be null
 * @return i32 — pipeline ec; -1 on thin reject
 * wave58: body in pure shux_pipeline_dep_prerun_parse_skip_typeck_impl.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_pipeline_dep_prerun_parse_skip_typeck(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  if (dep_mod == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_arena == 0 as *u8) {
    return 0 - 1;
  }
  if (src == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  unsafe {
    return shux_pipeline_dep_prerun_parse_skip_typeck_impl(dep_mod, dep_arena, src, len, dep_out, one_ctx);
  }
  return 0 - 1;
}

/**
 * Dep prerun parse-only body: init parse + set_main_from_buf (no typeck).
 * Must use pipeline_parse_set_main_from_buf_c (parse_into_with_init_buf); a bare
 * parser_parse_into slice path under-parses large std modules (ok=-2, ~2 funcs).
 * @param dep_mod *u8 — dep AST module; caller thin already null-checked
 * @param dep_arena *u8 — dep AST arena
 * @param src *u8 — source bytes
 * @param len i64 — byte length; > INT32_MAX → -1
 * @return i32 — 0 on parse ok; -1 on null/oversized/parse fail
 * wave59 pure Cap residual:
 *   G.7 pure parser_parse_into_init (weak empty in this TU; strong parser wins final link);
 *   G.7 pure pipeline_parse_set_main_from_buf_c surface (real body in pipeline_glue);
 *   SHUX_ASM_DEBUG notes cold-only (seed twin keeps pipeline_asm_debug_enabled diags).
 * PLATFORM: SHARED — same return mapping as historical seed _impl (parse_rc==0 → 0 else -1).
 */
#[no_mangle]
export function shux_pipeline_dep_prerun_parse_only_impl(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64): i32 {
  if (dep_mod == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_arena == 0 as *u8) {
    return 0 - 1;
  }
  if (src == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  // INT32_MAX — pipeline glue takes int32_t len.
  let imax: i64 = 2147483647;
  if (len > imax) {
    return 0 - 1;
  }
  unsafe {
    let len_i32: i32 = len as i32;
    // Authority parse path for dep prerun (not bare parser_parse_into).
    parser_parse_into_init(dep_mod, dep_arena);
    let parse_rc: i32 = pipeline_parse_set_main_from_buf_c(dep_mod, dep_arena, src, len_i32);
    if (parse_rc == 0) {
      return 0;
    }
    return 0 - 1;
  }
  return 0 - 1;
}

/**
 * Thin gate for dep prerun parse-only (null / empty source rejected).
 * @param dep_mod *u8 — dep AST module; null → -1
 * @param dep_arena *u8 — dep AST arena; null → -1
 * @param src *u8 — source bytes; null → -1
 * @param len i64 — byte length; <=0 → -1
 * @return i32 — 0 ok; -1 reject or parse fail
 * wave59: body in pure shux_pipeline_dep_prerun_parse_only_impl.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_pipeline_dep_prerun_parse_only(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64): i32 {
  if (dep_mod == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_arena == 0 as *u8) {
    return 0 - 1;
  }
  if (src == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  unsafe {
    return shux_pipeline_dep_prerun_parse_only_impl(dep_mod, dep_arena, src, len);
  }
  return 0 - 1;
}

/* ---- G-02f-59 / G-02f-239 / wave60：dep prerun typeck ---- */

/**
 * Dep prerun typeck-only body: parse + load/sync direct imports + typeck (no codegen).
 * Does not walk run_x_pipeline (large modules drop ctx); uses C glue authorities.
 * @param dep_mod *u8 — dep AST module; caller thin already null-checked
 * @param dep_arena *u8 — dep AST arena
 * @param src *u8 — source bytes
 * @param len i64 — byte length; > INT32_MAX → -1
 * @param dep_out *u8 — unused (historical signature; seed voids it)
 * @param one_ctx *u8 — PipelineDepCtx; required for load + typeck
 * @return i32 — 0 ok; -1 null/oversized; -2 parse fail; else load_rc / typeck_rc
 * wave60 pure Cap residual:
 *   G.7 pure pipeline_parse_set_main_from_buf_c surface (weak empty here; strong glue wins);
 *   G.7 pipeline_load_and_sync_direct_import_deps_c (ast_pool authority);
 *   G.7 pipeline_typeck_dep_prerun_module_c (pipeline_glue authority);
 *   SHUX_DEBUG_PIPE notes cold-only (seed twin keeps getenv diags).
 * PLATFORM: SHARED — same return mapping as historical seed _impl.
 */
#[no_mangle]
export function shux_pipeline_dep_prerun_typeck_only_impl(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  // dep_out is public ABI only; historical seed voids it (no consumer on this path).
  if (dep_mod == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_arena == 0 as *u8) {
    return 0 - 1;
  }
  if (src == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  if (one_ctx == 0 as *u8) {
    return 0 - 1;
  }
  // INT32_MAX — pipeline glue takes int32_t len.
  let imax: i64 = 2147483647;
  if (len > imax) {
    return 0 - 1;
  }
  unsafe {
    let len_i32: i32 = len as i32;
    // Authority parse path (same as seed; not bare parser_parse_into).
    let parse_rc: i32 = pipeline_parse_set_main_from_buf_c(dep_mod, dep_arena, src, len_i32);
    // Seed maps any non-zero parse to -2 (not -1).
    if (parse_rc != 0) {
      return 0 - 2;
    }
    let load_rc: i32 = pipeline_load_and_sync_direct_import_deps_c(dep_mod, dep_arena, one_ctx);
    if (load_rc != 0) {
      return load_rc;
    }
    // Typeck dep prerun module (skip codegen); return code is authority surface.
    let tc_rc: i32 = pipeline_typeck_dep_prerun_module_c(dep_mod, dep_arena, one_ctx);
    return tc_rc;
  }
  return 0 - 1;
}

/**
 * Thin gate for dep prerun typeck-only (null / empty source / missing ctx rejected).
 * @param dep_mod *u8 — dep AST module; null → -1
 * @param dep_arena *u8 — dep AST arena; null → -1
 * @param src *u8 — source bytes; null → -1
 * @param len i64 — byte length; <=0 → -1
 * @param dep_out *u8 — optional unused out (forwarded)
 * @param one_ctx *u8 — PipelineDepCtx; null → -1
 * @return i32 — typeck path rc; -1 on thin reject
 * wave60: body in pure shux_pipeline_dep_prerun_typeck_only_impl.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_pipeline_dep_prerun_typeck_only(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  if (dep_mod == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_arena == 0 as *u8) {
    return 0 - 1;
  }
  if (src == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  if (one_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return shux_pipeline_dep_prerun_typeck_only_impl(dep_mod, dep_arena, src, len, dep_out, one_ctx);
  }
  return 0 - 1;
}

// shux_pipeline_dep_prerun_for_asm_module_o: see function docblock below.
/** Exported function `shux_pipeline_dep_prerun_for_asm_module_o`.
 * Implements `shux_pipeline_dep_prerun_for_asm_module_o`.
 * @param dep_mod *u8
 * @param dep_arena *u8
 * @param src *u8
 * @param len i64
 * @param dep_out *u8
 * @param one_ctx *u8
 * @return i32
 */
#[no_mangle]
export function shux_pipeline_dep_prerun_for_asm_module_o(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  return shux_pipeline_dep_prerun_typeck_only(dep_mod, dep_arena, src, len, dep_out, one_ctx);
}

// pipe_path_readable: see function docblock below.
/** Exported function `pipe_path_readable`.
 * Read path helper `pipe_path_readable`.
 * @param path *u8
 * @return i32
 */
export function pipe_path_readable(path: *u8): i32 {
  if (path == 0 as *u8) { return 0; }
  unsafe {
    if (access(path, 4) == 0) { return 1; }
  }
  return 0;
}

/** Exported function `pipe_cstr_has_char`.
 * Implements `pipe_cstr_has_char`.
 * @param s *u8
 * @param ch u8
 * @return i32
 */
export function pipe_cstr_has_char(s: *u8, ch: u8): i32 {
  if (s == 0 as *u8) { return 0; }
  let i: i32 = 0;
  while (i < 4096) {
    if (s[i] == 0) { return 0; }
    if (s[i] == ch) { return 1; }
    i = i + 1;
  }
  return 0;
}

// pipe_write_nested_name_x: see function docblock below.
/** Exported function `pipe_write_nested_name_x`.
 * Write path helper `pipe_write_nested_name_x`.
 * @param dst *u8
 * @param cap i32
 * @param root *u8
 * @param name *u8
 * @return void
 */
export function pipe_write_nested_name_x(dst: *u8, cap: i32, root: *u8, name: *u8): void {
  if (dst == 0 as *u8) { return; }
  if (cap <= 0) { return; }
  let off: i32 = 0;
  unsafe {
    if (root != 0 as *u8) {
      let i: i32 = 0;
      while (i < 4096) {
        if (root[i] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = root[i];
        off = off + 1;
        i = i + 1;
      }
    }
    if (off + 1 < cap) { dst[off] = 47; off = off + 1; }
    if (name != 0 as *u8) {
      let j: i32 = 0;
      while (j < 4096) {
        if (name[j] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = name[j];
        off = off + 1;
        j = j + 1;
      }
    }
    if (off + 1 < cap) { dst[off] = 47; off = off + 1; }
    if (name != 0 as *u8) {
      let k: i32 = 0;
      while (k < 4096) {
        if (name[k] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = name[k];
        off = off + 1;
        k = k + 1;
      }
    }
    if (off + 2 < cap) {
      dst[off] = 46; dst[off + 1] = 120; dst[off + 2] = 0;
    } else if (off < cap) {
      dst[off] = 0;
    } else {
      dst[cap - 1] = 0;
    }
  }
}

// pipe_write_root_dotted_imp: see function docblock below.
/** Exported function `pipe_write_root_dotted_imp`.
 * Write path helper `pipe_write_root_dotted_imp`.
 * @param dst *u8
 * @param cap i32
 * @param root *u8
 * @param imp *u8
 * @return i32
 */
export function pipe_write_root_dotted_imp(dst: *u8, cap: i32, root: *u8, imp: *u8): i32 {
  if (dst == 0 as *u8) { return 0; }
  if (cap <= 0) { return 0; }
  let off: i32 = 0;
  unsafe {
    if (root != 0 as *u8) {
      let i: i32 = 0;
      while (i < 4096) {
        if (root[i] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = root[i];
        off = off + 1;
        i = i + 1;
      }
    }
    if (off + 1 < cap) { dst[off] = 47; off = off + 1; }
    if (imp != 0 as *u8) {
      let j: i32 = 0;
      while (j < 4096) {
        if (imp[j] == 0) { break; }
        if (off + 1 >= cap) { break; }
        let ch: u8 = imp[j];
        if (ch == 46) { dst[off] = 47; } else { dst[off] = ch; }
        off = off + 1;
        j = j + 1;
      }
    }
    if (off < cap) { dst[off] = 0; } else { dst[cap - 1] = 0; }
  }
  return off;
}

/** Exported function `pipe_append_suffix`.
 * Implements `pipe_append_suffix`.
 * @param dst *u8
 * @param cap i32
 * @param off i32
 * @param suf *u8
 * @return void
 */
export function pipe_append_suffix(dst: *u8, cap: i32, off: i32, suf: *u8): void {
  if (dst == 0 as *u8) { return; }
  if (suf == 0 as *u8) { return; }
  if (cap <= 0) { return; }
  let o: i32 = off;
  let si: i32 = 0;
  unsafe {
    while (si < 16) {
      if (suf[si] == 0) { break; }
      if (o + 1 >= cap) { break; }
      dst[o] = suf[si];
      o = o + 1;
      si = si + 1;
    }
    if (o < cap) { dst[o] = 0; } else { dst[cap - 1] = 0; }
  }
}

/**
 * Byte-offset a C string pointer (null-safe; negative off → base).
 * @param s *u8 — base C string or byte buffer; null → null
 * @param off i32 — byte offset from s; off < 0 → return s unchanged
 * @return *u8 — s+off (as &s[off]); null when s is null
 * wave76 pure: G.7 single authority for pipe_dir_tail / pipe_strip_prefix_seg / driver -D
 * parse (driver_abi imports this symbol). Codegen emits C `&((s)[off])` ≡ s+off on LP64.
 * Historical Cap residual claimed ".x has no reliable pointer arithmetic"; pure index
 * address-of closes that leaf without a C helper.
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function shux_cstr_offset(s: *u8, off: i32): *u8 {
  if (s == 0 as *u8) {
    return 0 as *u8;
  }
  if (off < 0) {
    return s;
  }
  unsafe {
    return &s[off];
  }
  return s;
}

// pipe_dir_tail: see function docblock below.
/**
 * Basename segment of a directory path (bytes after last '/'; whole path if none).
 * @param entry_dir *u8 — directory path; null → null
 * @return *u8 — pointer into entry_dir at last slash+1 (or entry_dir); lifetime = entry_dir
 * wave76: G.7 pure shux_cstr_offset for tail pointer (no Cap residual).
 * PLATFORM: SHARED.
 */
export function pipe_dir_tail(entry_dir: *u8): *u8 {
  if (entry_dir == 0 as *u8) { return 0 as *u8; }
  let last: i32 = 0 - 1;
  let i: i32 = 0;
  unsafe {
    while (i < 4096) {
      if (entry_dir[i] == 0) { break; }
      if (entry_dir[i] == 47) { last = i; }
      i = i + 1;
    }
    if (last < 0) { return entry_dir; }
    return shux_cstr_offset(entry_dir, last + 1);
  }
  return entry_dir;
}

// pipe_strip_prefix_seg: see function docblock below.
/** Exported function `pipe_strip_prefix_seg`.
 * Implements `pipe_strip_prefix_seg`.
 * @param import_path *u8
 * @param dir_tail *u8
 * @return *u8
 */
export function pipe_strip_prefix_seg(import_path: *u8, dir_tail: *u8): *u8 {
  if (import_path == 0 as *u8) { return import_path; }
  if (dir_tail == 0 as *u8) { return import_path; }
  unsafe {
    let tl: i32 = pipe_cstr_len(dir_tail);
    let i: i32 = 0;
    while (i < tl) {
      if (import_path[i] == 0) { return import_path; }
      if (import_path[i] != dir_tail[i]) { return import_path; }
      i = i + 1;
    }
    if (import_path[tl] == 46) {
      return shux_cstr_offset(import_path, tl + 1);
    }
  }
  return import_path;
}

// shux_resolve_import_file_path_multi: see function docblock below.
/** Exported function `shux_resolve_import_file_path_multi`.
 * Implements `shux_resolve_import_file_path_multi`.
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @param entry_dir *u8
 * @param import_path *u8
 * @param path *u8
 * @param path_size i64
 * @return void
 */
#[no_mangle]
export function shux_resolve_import_file_path_multi(lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, import_path: *u8, path: *u8, path_size: i64): void {
  if (path == 0 as *u8) {
    return;
  }
  if (path_size == 0) {
    return;
  }
  if (import_path == 0 as *u8) {
    unsafe {
      path[0] = 0;
    }
    return;
  }
  let cap: i32 = path_size as i32;
  if (cap <= 0) {
    return;
  }
  // See implementation.
  if (shux_import_path_is_file_path(import_path) != 0) {
    shux_resolve_file_import_path(entry_dir, import_path, path, path_size);
    if (pipe_path_readable(path) != 0) { return; }
    unsafe {
      if (import_path[0] != 47) {
        pipe_cstr_copy(path, cap, import_path);
        if (pipe_path_readable(path) != 0) { return; }
      }
    }
  }
  // -L roots
  let r: i32 = 0;
  while (r < n_lib_roots) {
    let lib_root: *u8 = 0 as *u8;
    unsafe {
      if (lib_roots != 0 as *u8) {
        lib_root = pipe_load_ptr_slot(lib_roots, r);
      }
    }
    let use_root: *u8 = lib_root;
    let dot: u8[2] = [];
    dot[0] = 46;
    dot[1] = 0;
    if (use_root == 0 as *u8) {
      use_root = &dot[0];
    } else {
      unsafe {
        if (use_root[0] == 0) { use_root = &dot[0]; }
      }
    }
    shux_import_path_to_file_path(use_root, import_path, path, path_size);
    if (pipe_path_readable(path) != 0) { return; }
    // See implementation.
    if (pipe_cstr_has_char(import_path, 46) == 0) {
      if (path_size >= 16) {
        let n: i32 = pipe_cstr_len(import_path);
        if (n > 0) {
          if (n < 64) {
            pipe_write_nested_name_x(path, cap, use_root, import_path);
            if (pipe_path_readable(path) != 0) { return; }
          }
        }
      }
    } else {
      if (path_size >= 16) {
        let off: i32 = pipe_write_root_dotted_imp(path, cap, use_root, import_path);
        let modx: u8[8] = [];
        modx[0] = 47; modx[1] = 109; modx[2] = 111; modx[3] = 100; modx[4] = 46; modx[5] = 120; modx[6] = 0;
        if (off + 8 <= cap) {
          pipe_append_suffix(path, cap, off, &modx[0]);
          if (pipe_path_readable(path) != 0) { return; }
        }
        shux_import_path_to_file_path(use_root, import_path, path, path_size);
        if (pipe_path_readable(path) != 0) { return; }
      }
    }
    r = r + 1;
  }
  // See implementation.
  if (entry_dir != 0 as *u8) {
    unsafe {
      if (entry_dir[0] != 0) {
        if (pipe_cstr_has_char(import_path, 46) == 0) {
          let off2: i32 = pipe_write_root_dotted_imp(path, cap, entry_dir, import_path);
          // pipe_write already did entry/import with dots; for no-dot it's entry/import
          // need entry/import.x
          let dx: u8[4] = [];
          dx[0] = 46; dx[1] = 120; dx[2] = 0;
          pipe_append_suffix(path, cap, off2, &dx[0]);
          if (pipe_path_readable(path) != 0) { return; }
        } else {
          if (path_size >= 16) {
            let tail: *u8 = pipe_dir_tail(entry_dir);
            let eff: *u8 = pipe_strip_prefix_seg(import_path, tail);
            let off3: i32 = pipe_write_root_dotted_imp(path, cap, entry_dir, eff);
            let dx2: u8[4] = [];
            dx2[0] = 46; dx2[1] = 120; dx2[2] = 0;
            if (off3 + 3 <= cap) {
              pipe_append_suffix(path, cap, off3, &dx2[0]);
              if (pipe_path_readable(path) != 0) { return; }
            }
            let modx2: u8[8] = [];
            modx2[0] = 47; modx2[1] = 109; modx2[2] = 111; modx2[3] = 100;
            modx2[4] = 46; modx2[5] = 120; modx2[6] = 0;
            if (off3 + 8 <= cap) {
              pipe_append_suffix(path, cap, off3, &modx2[0]);
              if (pipe_path_readable(path) != 0) { return; }
            }
          }
        }
      }
    }
  }
}

/* See implementation. */

/**
 * LP64 offsetof(ast_PipelineDepCtx, entry_dir_buf) — layout authority runtime_pipeline_abi.h.
 * PLATFORM: SHARED LP64 (Ubuntu x86_64 + Darwin arm64/x86_64).
 */
function pipe_pctx_off_entry_dir_buf(): i32 {
  return 4;
}

/**
 * LP64 offsetof(ast_PipelineDepCtx, entry_dir_len).
 * PLATFORM: SHARED LP64.
 */
function pipe_pctx_off_entry_dir_len(): i32 {
  return 516;
}

/**
 * LP64 offsetof(ast_PipelineDepCtx, num_lib_roots).
 * PLATFORM: SHARED LP64.
 */
function pipe_pctx_off_num_lib_roots(): i32 {
  return 520;
}

/**
 * LP64 offsetof(ast_PipelineDepCtx, loaded_len) — ptrdiff_t / i64 cell.
 * PLATFORM: SHARED LP64.
 */
function pipe_pctx_off_loaded_len(): i32 {
  return 4195344;
}

/**
 * LP64 offsetof(ast_PipelineDepCtx, preprocess_len).
 * PLATFORM: SHARED LP64.
 */
function pipe_pctx_off_preprocess_len(): i32 {
  return 8389656;
}

/**
 * Store host LE i32 at base[off..off+3]. Null base or off negative → no-op.
 * @param base *u8 — object base
 * @param off i32 — byte offset
 * @param v i32 — value
 * @return void
 * G.7 same pattern as driver_abi_store_i32_le (wave19); local copy — not exported.
 * PLATFORM: SHARED LP64 little-endian.
 */
function pipe_store_i32_le(base: *u8, off: i32, v: i32): void {
  if (base == 0 as *u8) {
    return;
  }
  if (off < 0) {
    return;
  }
  unsafe {
    let u: u32 = v as u32;
    base[off] = (u & 255) as u8;
    base[off + 1] = ((u / 256) & 255) as u8;
    base[off + 2] = ((u / 65536) & 255) as u8;
    base[off + 3] = ((u / 16777216) & 255) as u8;
  }
}

/**
 * Store eight zero bytes at base[off..off+7] (clear ptrdiff_t / i64 cell).
 * Null base or off negative → no-op. wave67 only needs clear (loaded_len=0).
 * @param base *u8 — object base
 * @param off i32 — byte offset
 * @return void
 * PLATFORM: SHARED LP64.
 */
function pipe_store_i64_zero(base: *u8, off: i32): void {
  if (base == 0 as *u8) {
    return;
  }
  if (off < 0) {
    return;
  }
  pipe_store_i32_le(base, off, 0);
  pipe_store_i32_le(base, off + 4, 0);
}

/**
 * Clear PipelineDepCtx path/source length cells used by fill_ctx orch.
 * @param ctx *u8 — opaque ast_PipelineDepCtx; null → no-op
 * @return void
 * wave67 pure: zeros loaded_len (i64), preprocess_len, entry_dir_len, num_lib_roots
 *   via LP64 offsetof + LE store (no C struct in .x). Does not clear buffer bytes.
 * PLATFORM: SHARED LP64 — cold twin under non-FROM_X keeps C field writes.
 */
#[no_mangle]
export function pipeline_dep_ctx_path_bufs_reset(ctx: *u8): void {
  if (ctx == 0 as *u8) {
    return;
  }
  pipe_store_i64_zero(ctx, pipe_pctx_off_loaded_len());
  pipe_store_i32_le(ctx, pipe_pctx_off_preprocess_len(), 0);
  pipe_store_i32_le(ctx, pipe_pctx_off_entry_dir_len(), 0);
  pipe_store_i32_le(ctx, pipe_pctx_off_num_lib_roots(), 0);
}

/**
 * Copy entry_dir C string into pctx.entry_dir_buf (cap 512 incl NUL) and set entry_dir_len.
 * @param ctx *u8 — opaque ast_PipelineDepCtx; null → no-op
 * @param entry_dir *u8 — NUL-terminated path; null → no-op
 * @return void
 * wave67 pure: byte copy into ctx[entry_dir_buf_off..] then LE store entry_dir_len.
 * Truncates at 511 payload bytes. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function pipeline_dep_ctx_copy_entry_dir(ctx: *u8, entry_dir: *u8): void {
  if (ctx == 0 as *u8) {
    return;
  }
  if (entry_dir == 0 as *u8) {
    return;
  }
  let el: i32 = 0;
  unsafe {
    while (el < 511) {
      let c: u8 = entry_dir[el];
      if (c == 0) {
        break;
      }
      el = el + 1;
    }
  }
  let base_off: i32 = pipe_pctx_off_entry_dir_buf();
  let k: i32 = 0;
  unsafe {
    while (k < el) {
      ctx[base_off + k] = entry_dir[k];
      k = k + 1;
    }
    ctx[base_off + el] = 0;
  }
  pipe_store_i32_le(ctx, pipe_pctx_off_entry_dir_len(), el);
}

/**
 * Store pctx.use_asm_backend = v (null ctx no-op).
 * @param ctx *u8 — opaque ast_PipelineDepCtx
 * @param v i32 — flag value
 * @return void
 * wave67 pure thin: G.7 single authority driver_pipeline_dep_ctx_set_use_asm
 *   (driver_abi wave19 LE store). PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function pipeline_dep_ctx_set_use_asm_backend(ctx: *u8, v: i32): void {
  unsafe {
    driver_pipeline_dep_ctx_set_use_asm(ctx, v);
  }
}

// wave68 pure entry_dir BSS (G.7 single authority for resolve_path / set_entry_dir).
// PLATFORM: SHARED LP64 — same ABI as seed cold twins; hybrid pure owns these cells.
let g_pipe_entry_dir_buf: u8[512] = [];
let g_pipe_entry_dir_dot: u8[2] = [];
let g_pipe_entry_dir_is_dot: i32 = 1;

// wave69 pure resolved_path BSS (G.7 single authority for into_static + stage_prep path base).
// PLATFORM: SHARED — same ABI as seed cold static char pipeline_resolved_path_buf[512].
let g_pipe_resolved_path_buf: u8[512] = [];

// wave70 pure dep arena/module slot BSS (G.7 single authority for set_dep_slots / get_dep_*).
// PLATFORM: SHARED LP64 — 32 void* cells × 8B = 256B raw; same capacity as seed void*[32].
let g_pipe_dep_arena_slots: u8[256] = [];
let g_pipe_dep_module_slots: u8[256] = [];

// wave71 pure stage-prep BSS (owned preprocess buffer pending commit into loaded_import).
// PLATFORM: SHARED LP64 — one ptr cell + one size cell; same ABI as seed static char* + size_t.
// G.7 single authority for pure stage_prep / commit_prep; free on clear releases ownership.
let g_pipe_rf_stage_prep: u8[8] = [];
let g_pipe_rf_stage_prep_len: u8[8] = [];

// wave72 pure loaded-import BSS (committed source after stage prep commit).
// PLATFORM: SHARED LP64 — buf ptr + len + cap size cells; same ABI as seed statics.
// G.7 single authority for pure commit_from_owned / data / len_get / commit_prep path.
// Cap floor SHUX_PIPELINE_IMPORT_BUF_CAP = 4194304 (runtime_pipeline_abi.h).
let g_pipe_loaded_import_buf: u8[8] = [];
let g_pipe_loaded_import_len: u8[8] = [];
let g_pipe_loaded_import_cap: u8[8] = [];

// wave73 pure diag-emitted sticky flag BSS (G.7 single authority for reset/note/get).
// PLATFORM: SHARED — same ABI as seed static int pipeline_diag_emitted_flag (0/1 sticky).
// Consumers (rt_run_asm_backend / rt_run_compiler_parsed pure) only call reset/get accessors;
// no cross-TU raw global writes — safe pure BSS authority under hybrid PREFER.
let g_pipe_diag_emitted_flag: i32 = 0;

// wave74 pure driver_dep table BSS (G.7 single authority for seeded/publish/slot_for_path/buf).
// PLATFORM: SHARED LP64 — 32 slots each; same capacity as seed SHUX_DRIVER_DEP_SLOT_MAX.
// arena/module/path_registry = 32×void* (256B raw); seeded = 32×i32 (128B raw as i32[32]).
// No cross-TU naked global — ast_pool/glue call driver_dep_*_buf / path_registry_at accessors only.
let g_pipe_driver_dep_arena: u8[256] = [];
let g_pipe_driver_dep_module: u8[256] = [];
let g_pipe_driver_dep_path_registry: u8[256] = [];
let g_pipe_driver_dep_seeded: i32[32] = [];

// wave77 pure typeck dep sidecar BSS (G.7 single authority for C typeck_module sidecar + pure orch).
// PLATFORM: SHARED LP64 — same capacity as seed typeck_dep_*_ptrs[32] + typeck_ndep.
// Product hybrid: pure accessors only (rt_run_* pure + driver_typeck_* + pure set_dep/store);
// no cross-TU naked global under PREFER FROM_X (cold seed naked globals under #ifndef FROM_X).
// typeck_dep_module_ptrs_base returns &module table[0] as *u8 for Cap residual typeck_module void**.
let g_pipe_typeck_ndep: i32 = 0;
let g_pipe_typeck_dep_module_ptrs: u8[256] = [];
let g_pipe_typeck_dep_arena_ptrs: u8[256] = [];

// wave75 pure entry_lib lit + stem BSS (G.7 single authority for -E lib_prefix).
// PLATFORM: SHARED — same string values as seed static lits / stem_buf[128].
// Keyword order matches seed shux_entry_lib_keyword_lit / strstr checks in name_from_path_impl.
let g_pipe_cstr_typeck_lit: u8[7] = [116, 121, 112, 101, 99, 107, 0];
let g_pipe_entry_lib_kw0: u8[5] = [109, 97, 105, 110, 0];
let g_pipe_entry_lib_kw1: u8[6] = [98, 117, 105, 108, 100, 0];
let g_pipe_entry_lib_kw2: u8[9] = [112, 105, 112, 101, 108, 105, 110, 101, 0];
let g_pipe_entry_lib_kw3: u8[7] = [100, 114, 105, 118, 101, 114, 0];
let g_pipe_entry_lib_kw4: u8[8] = [99, 111, 100, 101, 103, 101, 110, 0];
let g_pipe_entry_lib_kw5: u8[7] = [116, 121, 112, 101, 99, 107, 0];
let g_pipe_entry_lib_kw6: u8[7] = [112, 97, 114, 115, 101, 114, 0];
let g_pipe_entry_lib_kw7: u8[6] = [116, 111, 107, 101, 110, 0];
let g_pipe_entry_lib_kw8: u8[6] = [108, 101, 120, 101, 114, 0];
let g_pipe_entry_lib_kw9: u8[4] = [97, 115, 116, 0];
let g_pipe_entry_lib_stem_buf: u8[128] = [];

/**
 * Storage slot for pure get_ndep (points at g_pipe_typeck_ndep).
 * @return *i32 — never null; LP64 i32 cell
 * wave77 pure: G.7 single authority for typeck_ndep count; pure get_ndep / store path.
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X returns &typeck_ndep.
 */
#[no_mangle]
export function typeck_ndep_slot(): *i32 {
  return &g_pipe_typeck_ndep;
}

/**
 * Store final clamped typeck_ndep value into pure BSS (bounds owned by typeck_ndep_store orch).
 * @param n i32 — already-clamped dep count [0,32]
 * @return void
 * wave77 pure: Cap residual was always-seed BSS write; pure owns the cell.
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X writes seed typeck_ndep.
 */
#[no_mangle]
export function typeck_ndep_store_impl(n: i32): void {
  g_pipe_typeck_ndep = n;
}

/**
 * Load typeck_dep_module_ptrs[i] from pure BSS (capacity 32).
 * @param i i32 — slot index; i < 0 or i >= 32 → null
 * @return *u8 — stored module pointer (may be null)
 * wave77 pure: G.7 shux_ptr_slot_get on g_pipe_typeck_dep_module_ptrs.
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function typeck_dep_module_get(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  return shux_ptr_slot_get(&g_pipe_typeck_dep_module_ptrs[0], i);
}

/**
 * Load typeck_dep_arena_ptrs[i] from pure BSS (capacity 32).
 * @param i i32 — slot index; i < 0 or i >= 32 → null
 * @return *u8 — stored arena pointer (may be null)
 * wave77 pure: G.7 shux_ptr_slot_get on g_pipe_typeck_dep_arena_ptrs.
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function typeck_dep_arena_get(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  return shux_ptr_slot_get(&g_pipe_typeck_dep_arena_ptrs[0], i);
}

/**
 * Store mod into typeck_dep_module_ptrs[i] pure BSS (capacity 32).
 * @param i i32 — slot index; OOB → no-op
 * @param mod *u8 — module pointer (may be null)
 * @return void
 * wave77 pure: G.7 shux_ptr_slot_set; pure typeck_dep_module_set / pipeline_set_dep orch own bounds.
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function typeck_dep_module_set_impl(i: i32, mod: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  shux_ptr_slot_set(&g_pipe_typeck_dep_module_ptrs[0], i, mod);
}

/**
 * Store arena into typeck_dep_arena_ptrs[i] pure BSS (capacity 32).
 * @param i i32 — slot index; OOB → no-op
 * @param arena *u8 — arena pointer (may be null)
 * @return void
 * wave77 pure: G.7 shux_ptr_slot_set; pure typeck_dep_arena_set / pipeline_set_dep orch own bounds.
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function typeck_dep_arena_set_impl(i: i32, arena: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  shux_ptr_slot_set(&g_pipe_typeck_dep_arena_ptrs[0], i, arena);
}

/**
 * Base address of pure typeck_dep_module_ptrs table for Cap residual typeck_module void**.
 * @return *u8 — never null; LP64 void*[32] raw base (cast to void** at call site)
 * wave77 pure: pure BSS base; pure with_sidecar passes this when get_ndep() > 0.
 * Historical Cap residual: seed BSS addr not takeable from pure .x — closed by pure table.
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X returns seed array.
 */
#[no_mangle]
export function typeck_dep_module_ptrs_base(): *u8 {
  return &g_pipe_typeck_dep_module_ptrs[0];
}

/**
 * Return static "typeck" C string (default -E lib prefix).
 * @return *u8 — always non-null; points at g_pipe_cstr_typeck_lit
 * wave75 pure: module BSS lit; matches seed shux_cstr_typeck_lit return "typeck".
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function shux_cstr_typeck_lit(): *u8 {
  return &g_pipe_cstr_typeck_lit[0];
}

/**
 * Return static keyword C string for entry_lib keyword index.
 * @param k i32 — 0=main .. 9=ast; other → "typeck"
 * @return *u8 — always non-null; pointer into module BSS keyword lits
 * wave75 pure: G.7 single authority for keyword lits used by pure name_from_path_impl.
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function shux_entry_lib_keyword_lit(k: i32): *u8 {
  if (k == 0) {
    return &g_pipe_entry_lib_kw0[0];
  }
  if (k == 1) {
    return &g_pipe_entry_lib_kw1[0];
  }
  if (k == 2) {
    return &g_pipe_entry_lib_kw2[0];
  }
  if (k == 3) {
    return &g_pipe_entry_lib_kw3[0];
  }
  if (k == 4) {
    return &g_pipe_entry_lib_kw4[0];
  }
  if (k == 5) {
    return &g_pipe_entry_lib_kw5[0];
  }
  if (k == 6) {
    return &g_pipe_entry_lib_kw6[0];
  }
  if (k == 7) {
    return &g_pipe_entry_lib_kw7[0];
  }
  if (k == 8) {
    return &g_pipe_entry_lib_kw8[0];
  }
  if (k == 9) {
    return &g_pipe_entry_lib_kw9[0];
  }
  return &g_pipe_cstr_typeck_lit[0];
}

/**
 * Derive -E C lib_prefix from entry .x path (keywords / std_ / core_ / basename stem).
 * @param input_path *u8 — entry path; null → "typeck" (caller may short-circuit)
 * @return *u8 — static keyword lit or g_pipe_entry_lib_stem_buf; never null
 * wave75 pure Cap residual orch (full body):
 *   1) strstr-style keywords (main..ast) via pipe_cstr_contains + pure keyword_lit;
 *   2) path-boundary "std/" → "std_" + segments (skip trailing mod; strip .x/.su);
 *   3) path-boundary "core/" → "core_" + same segment rules;
 *   4) basename stem without .x/.su;
 *   5) default "typeck".
 * G.7 single authority — matches seed order (keywords BEFORE std/ stem). Historical pure
 * gate checked std/ first and could return std_* for paths that also contain "main".
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X; stem reuses one 128B BSS cell.
 */
#[no_mangle]
export function shux_entry_lib_name_from_path_impl(input_path: *u8): *u8 {
  if (input_path == 0 as *u8) {
    return shux_cstr_typeck_lit();
  }
  // Keyword substring checks — same order as seed strstr chain.
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw0[0]) != 0) {
    return shux_entry_lib_keyword_lit(0);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw1[0]) != 0) {
    return shux_entry_lib_keyword_lit(1);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw2[0]) != 0) {
    return shux_entry_lib_keyword_lit(2);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw3[0]) != 0) {
    return shux_entry_lib_keyword_lit(3);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw4[0]) != 0) {
    return shux_entry_lib_keyword_lit(4);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw5[0]) != 0) {
    return shux_entry_lib_keyword_lit(5);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw6[0]) != 0) {
    return shux_entry_lib_keyword_lit(6);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw7[0]) != 0) {
    return shux_entry_lib_keyword_lit(7);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw8[0]) != 0) {
    return shux_entry_lib_keyword_lit(8);
  }
  if (pipe_cstr_contains(input_path, &g_pipe_entry_lib_kw9[0]) != 0) {
    return shux_entry_lib_keyword_lit(9);
  }

  // std/ at path boundary → std_ + segments (skip mod; strip .x/.su).
  let std_after: i32 = 0 - 1;
  let si: i32 = 0;
  unsafe {
    while (si < 4096) {
      if (input_path[si] == 0) {
        break;
      }
      let at_bound: i32 = 0;
      if (si == 0) {
        at_bound = 1;
      } else {
        if (input_path[si - 1] == 47) {
          at_bound = 1;
        }
        if (input_path[si - 1] == 92) {
          at_bound = 1;
        }
      }
      if (at_bound != 0) {
        // "std/"
        if (input_path[si] == 115 && input_path[si + 1] == 116 && input_path[si + 2] == 100 && input_path[si + 3] == 47) {
          std_after = si + 4;
          break;
        }
      }
      si = si + 1;
    }
  }
  if (std_after >= 0) {
    // "std_" prefix into stem_buf
    g_pipe_entry_lib_stem_buf[0] = 115;
    g_pipe_entry_lib_stem_buf[1] = 116;
    g_pipe_entry_lib_stem_buf[2] = 100;
    g_pipe_entry_lib_stem_buf[3] = 95;
    let off: i32 = 4;
    let p: i32 = std_after;
    unsafe {
      while (input_path[p] != 0 && off + 2 < 128) {
        let seg_start: i32 = p;
        while (input_path[p] != 0 && input_path[p] != 47 && input_path[p] != 92) {
          p = p + 1;
        }
        let seg_len: i32 = p - seg_start;
        // strip .su / .x
        if (seg_len >= 3) {
          if (input_path[seg_start + seg_len - 3] == 46 && input_path[seg_start + seg_len - 2] == 115 && input_path[seg_start + seg_len - 1] == 117) {
            seg_len = seg_len - 3;
          }
        }
        if (seg_len >= 2) {
          if (input_path[seg_start + seg_len - 2] == 46 && input_path[seg_start + seg_len - 1] == 120) {
            seg_len = seg_len - 2;
          }
        }
        // skip "mod"
        let is_mod: i32 = 0;
        if (seg_len == 3) {
          if (input_path[seg_start] == 109 && input_path[seg_start + 1] == 111 && input_path[seg_start + 2] == 100) {
            is_mod = 1;
          }
        }
        if (is_mod == 0 && seg_len > 0) {
          if (off > 4 && off + seg_len + 1 < 128) {
            g_pipe_entry_lib_stem_buf[off] = 95;
            off = off + 1;
          }
          if (off + seg_len < 128) {
            let k: i32 = 0;
            while (k < seg_len) {
              g_pipe_entry_lib_stem_buf[off + k] = input_path[seg_start + k];
              k = k + 1;
            }
            off = off + seg_len;
          }
        }
        if (input_path[p] != 0) {
          p = p + 1;
        }
      }
    }
    if (off > 4) {
      g_pipe_entry_lib_stem_buf[off] = 0;
      return &g_pipe_entry_lib_stem_buf[0];
    }
  }

  // core/ at path boundary → core_ + segments.
  let core_after: i32 = 0 - 1;
  let ci: i32 = 0;
  unsafe {
    while (ci < 4096) {
      if (input_path[ci] == 0) {
        break;
      }
      let at_bound2: i32 = 0;
      if (ci == 0) {
        at_bound2 = 1;
      } else {
        if (input_path[ci - 1] == 47) {
          at_bound2 = 1;
        }
        if (input_path[ci - 1] == 92) {
          at_bound2 = 1;
        }
      }
      if (at_bound2 != 0) {
        // "core/"
        if (input_path[ci] == 99 && input_path[ci + 1] == 111 && input_path[ci + 2] == 114 && input_path[ci + 3] == 101 && input_path[ci + 4] == 47) {
          core_after = ci + 5;
          break;
        }
      }
      ci = ci + 1;
    }
  }
  if (core_after >= 0) {
    g_pipe_entry_lib_stem_buf[0] = 99;
    g_pipe_entry_lib_stem_buf[1] = 111;
    g_pipe_entry_lib_stem_buf[2] = 114;
    g_pipe_entry_lib_stem_buf[3] = 101;
    g_pipe_entry_lib_stem_buf[4] = 95;
    let off2: i32 = 5;
    let p2: i32 = core_after;
    unsafe {
      while (input_path[p2] != 0 && off2 + 2 < 128) {
        let seg_start2: i32 = p2;
        while (input_path[p2] != 0 && input_path[p2] != 47 && input_path[p2] != 92) {
          p2 = p2 + 1;
        }
        let seg_len2: i32 = p2 - seg_start2;
        if (seg_len2 >= 3) {
          if (input_path[seg_start2 + seg_len2 - 3] == 46 && input_path[seg_start2 + seg_len2 - 2] == 115 && input_path[seg_start2 + seg_len2 - 1] == 117) {
            seg_len2 = seg_len2 - 3;
          }
        }
        if (seg_len2 >= 2) {
          if (input_path[seg_start2 + seg_len2 - 2] == 46 && input_path[seg_start2 + seg_len2 - 1] == 120) {
            seg_len2 = seg_len2 - 2;
          }
        }
        let is_mod2: i32 = 0;
        if (seg_len2 == 3) {
          if (input_path[seg_start2] == 109 && input_path[seg_start2 + 1] == 111 && input_path[seg_start2 + 2] == 100) {
            is_mod2 = 1;
          }
        }
        if (is_mod2 == 0 && seg_len2 > 0) {
          if (off2 > 5 && off2 + seg_len2 + 1 < 128) {
            g_pipe_entry_lib_stem_buf[off2] = 95;
            off2 = off2 + 1;
          }
          if (off2 + seg_len2 < 128) {
            let k2: i32 = 0;
            while (k2 < seg_len2) {
              g_pipe_entry_lib_stem_buf[off2 + k2] = input_path[seg_start2 + k2];
              k2 = k2 + 1;
            }
            off2 = off2 + seg_len2;
          }
        }
        if (input_path[p2] != 0) {
          p2 = p2 + 1;
        }
      }
    }
    if (off2 > 5) {
      g_pipe_entry_lib_stem_buf[off2] = 0;
      return &g_pipe_entry_lib_stem_buf[0];
    }
  }

  // basename stem without .x/.su
  let last_slash: i32 = 0 - 1;
  let bi: i32 = 0;
  unsafe {
    while (bi < 4096) {
      if (input_path[bi] == 0) {
        break;
      }
      if (input_path[bi] == 47 || input_path[bi] == 92) {
        last_slash = bi;
      }
      bi = bi + 1;
    }
  }
  let base: i32 = 0;
  if (last_slash >= 0) {
    base = last_slash + 1;
  }
  let last_dot: i32 = 0 - 1;
  let di: i32 = base;
  unsafe {
    while (di < 4096) {
      if (input_path[di] == 0) {
        break;
      }
      if (input_path[di] == 46) {
        last_dot = di;
      }
      di = di + 1;
    }
  }
  if (last_dot > base) {
    let is_x: i32 = 0;
    unsafe {
      if (input_path[last_dot] == 46 && input_path[last_dot + 1] == 120 && input_path[last_dot + 2] == 0) {
        is_x = 1;
      }
      if (input_path[last_dot] == 46 && input_path[last_dot + 1] == 115 && input_path[last_dot + 2] == 117 && input_path[last_dot + 3] == 0) {
        is_x = 1;
      }
    }
    if (is_x != 0) {
      let stem_len: i32 = last_dot - base;
      if (stem_len > 0 && stem_len < 128) {
        let k3: i32 = 0;
        unsafe {
          while (k3 < stem_len) {
            g_pipe_entry_lib_stem_buf[k3] = input_path[base + k3];
            k3 = k3 + 1;
          }
        }
        g_pipe_entry_lib_stem_buf[stem_len] = 0;
        return &g_pipe_entry_lib_stem_buf[0];
      }
    }
  }
  return shux_cstr_typeck_lit();
}

/**
 * Return address of the pipeline diag-emitted sticky flag (i32 cell).
 * @return *i32 — always non-null; points at g_pipe_diag_emitted_flag
 * wave73 pure: pure reset/note/get write/read this cell (0 clear / non-zero noted).
 * Matches historical seed pipeline_diag_emitted_flag_slot → static int.
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X; hybrid pure owns this cell only.
 */
#[no_mangle]
export function pipeline_diag_emitted_flag_slot(): *i32 {
  return &g_pipe_diag_emitted_flag;
}

/**
 * Return address of driver_dep seeded flag cell for slot i (i32).
 * @param i i32 — slot index; OOB clamped to 0..31 (matches historical seed clamp)
 * @return *i32 — always non-null; points at g_pipe_driver_dep_seeded[idx]
 * wave74 pure: pure seeded_get/set write/read this cell; G.7 single authority.
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X; hybrid pure owns the table.
 */
#[no_mangle]
export function driver_dep_seeded_slot(i: i32): *i32 {
  let idx: i32 = i;
  if (idx < 0) {
    idx = 0;
  }
  if (idx >= 32) {
    idx = 31;
  }
  return &g_pipe_driver_dep_seeded[idx];
}

/**
 * Store arena pointer into driver_dep arena slot i (capacity 32).
 * @param i i32 — slot index; i < 0 or i >= 32 → no-op
 * @param arena *u8 — arena pointer (may be null to clear)
 * @return void
 * wave74 pure: G.7 shux_ptr_slot_set on g_pipe_driver_dep_arena.
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function driver_dep_arena_ptr_set_impl(i: i32, arena: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  shux_ptr_slot_set(&g_pipe_driver_dep_arena[0], i, arena);
}

/**
 * Store module pointer into driver_dep module slot i (capacity 32).
 * @param i i32 — slot index; OOB → no-op
 * @param module *u8 — module pointer (may be null to clear)
 * @return void
 * wave74 pure: G.7 shux_ptr_slot_set on g_pipe_driver_dep_module.
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function driver_dep_module_ptr_set_impl(i: i32, module: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  shux_ptr_slot_set(&g_pipe_driver_dep_module[0], i, module);
}

/**
 * Store import-path pointer into driver_dep path registry slot i (capacity 32).
 * @param i i32 — slot index; OOB → no-op
 * @param path *u8 — logical import path pointer (lifetime until clear); null clears the slot
 * @return void
 * wave74 pure: G.7 shux_ptr_slot_set on g_pipe_driver_dep_path_registry.
 * Null path stores null so pure clear_slots can wipe registry (seed cold set rejected null
 * and relied on clear_slots_impl direct assignment; pure set is the single clear path).
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function driver_dep_path_registry_set(i: i32, path: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  shux_ptr_slot_set(&g_pipe_driver_dep_path_registry[0], i, path);
}

/**
 * Load path registry pointer at slot i.
 * @param i i32 — slot index; OOB → null
 * @return *u8 — stored path pointer (may be null)
 * wave74 pure: G.7 shux_ptr_slot_get on g_pipe_driver_dep_path_registry.
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X; used by pure slot_for_path_scan.
 */
#[no_mangle]
export function driver_dep_path_registry_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  return shux_ptr_slot_get(&g_pipe_driver_dep_path_registry[0], i);
}

/**
 * Return (and lazily allocate) driver_dep arena buffer for slot i.
 * @param i i32 — slot index; OOB → null
 * @return *u8 — arena byte region (zeroed on first malloc); null on OOB/OOM
 * wave74 pure: load slot; if null, malloc(pipeline_sizeof_arena)+memset0 then store.
 * Matches historical seed driver_dep_arena_buf (reuse pre-seeded pointers; no free on clear).
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X; Cap residual pipeline_sizeof_arena glue.
 */
#[no_mangle]
export function driver_dep_arena_buf(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  let p: *u8 = shux_ptr_slot_get(&g_pipe_driver_dep_arena[0], i);
  if (p != 0 as *u8) {
    return p;
  }
  let sz: usize = 0 as usize;
  unsafe {
    sz = pipeline_sizeof_arena();
    p = malloc(sz);
    if (p == 0 as *u8) {
      return 0 as *u8;
    }
    memset(p, 0, sz);
  }
  shux_ptr_slot_set(&g_pipe_driver_dep_arena[0], i, p);
  return p;
}

/**
 * Return (and lazily allocate) driver_dep module buffer for slot i.
 * @param i i32 — slot index; OOB → null
 * @return *u8 — module byte region (zeroed on first malloc); null on OOB/OOM
 * wave74 pure: same pattern as driver_dep_arena_buf with pipeline_sizeof_module.
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function driver_dep_module_buf(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  let p: *u8 = shux_ptr_slot_get(&g_pipe_driver_dep_module[0], i);
  if (p != 0 as *u8) {
    return p;
  }
  let sz: usize = 0 as usize;
  unsafe {
    sz = pipeline_sizeof_module();
    p = malloc(sz);
    if (p == 0 as *u8) {
      return 0 as *u8;
    }
    memset(p, 0, sz);
  }
  shux_ptr_slot_set(&g_pipe_driver_dep_module[0], i, p);
  return p;
}

/**
 * Free any owned stage-prep buffer and clear stage BSS cells to null/0.
 * @return void
 * wave71 pure: free(g_pipe_rf_stage_prep) then G.7 shux_ptr_slot_set / shux_size_slot_set zero.
 * Matches historical seed pipeline_rf_stage_prep_clear (always free then null).
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X; hybrid pure owns these cells.
 */
#[no_mangle]
export function pipeline_rf_stage_prep_clear(): void {
  let p: *u8 = shux_ptr_slot_get(&g_pipe_rf_stage_prep[0], 0);
  if (p != 0 as *u8) {
    unsafe {
      free(p);
    }
  }
  shux_ptr_slot_set(&g_pipe_rf_stage_prep[0], 0, 0 as *u8);
  shux_size_slot_set(&g_pipe_rf_stage_prep_len[0], 0, 0);
}

/**
 * Store owned prep into stage BSS (does not free prior; caller must clear first).
 * @param prep *u8 — owned heap buffer (or null for empty stage)
 * @param prep_len i64 — byte length; if prep is null, stored len is forced to 0
 * @return void
 * wave71 pure: G.7 shux_ptr_slot_set / shux_size_slot_set on pure stage cells.
 * Matches seed: prep may be null → stores empty (len 0).
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_rf_stage_prep_set(prep: *u8, prep_len: i64): void {
  shux_ptr_slot_set(&g_pipe_rf_stage_prep[0], 0, prep);
  if (prep == 0 as *u8) {
    shux_size_slot_set(&g_pipe_rf_stage_prep_len[0], 0, 0);
    return;
  }
  shux_size_slot_set(&g_pipe_rf_stage_prep_len[0], 0, prep_len);
}

/**
 * Move stage prep out without free (caller owns); clear stage BSS.
 * @param out_prep *u8 — char** as raw bytes (LP64 8B slot); may be null (still clears)
 * @param out_len *u8 — size_t* as raw bytes; may be null
 * @return i32 — 0 if prep non-null; -1 if stage empty (null prep)
 * wave71 pure: load cells → zero cells → write outs via G.7 ptr/size slot set.
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X; pure commit_prep uses this.
 */
#[no_mangle]
export function pipeline_rf_stage_prep_take(out_prep: *u8, out_len: *u8): i32 {
  let prep: *u8 = shux_ptr_slot_get(&g_pipe_rf_stage_prep[0], 0);
  let prep_len: i64 = shux_size_slot_get(&g_pipe_rf_stage_prep_len[0], 0);
  // Clear stage before writing outs (same order as historical seed).
  shux_ptr_slot_set(&g_pipe_rf_stage_prep[0], 0, 0 as *u8);
  shux_size_slot_set(&g_pipe_rf_stage_prep_len[0], 0, 0);
  if (out_prep != 0 as *u8) {
    shux_ptr_slot_set(out_prep, 0, prep);
  }
  if (out_len != 0 as *u8) {
    // Historical: out_len = prep ? prep_len : 0 after clear path already read prep_len.
    if (prep == 0 as *u8) {
      shux_size_slot_set(out_len, 0, 0);
    } else {
      shux_size_slot_set(out_len, 0, prep_len);
    }
  }
  if (prep == 0 as *u8) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Ensure loaded-import BSS, copy owned prep into it, free prep.
 * @param prep *u8 — owned heap source buffer; null → -1 (does not free)
 * @param prep_len i64 — byte length to copy; may be 0 if prep non-null
 * @return i32 — 0 success; -1 null prep or OOM (prep freed on OOM only)
 * wave72 pure: G.7 shux_ptr_slot_* / shux_size_slot_* on g_pipe_loaded_import_*.
 * Ensure policy (matches historical seed / SHUX_PIPELINE_IMPORT_BUF_CAP):
 *   if prep_len > cap or buf null → free old buf; new_cap =
 *     (prep_len < 4194304) ? 4194304 : (prep_len + 65536); malloc; OOM → free(prep) -1.
 *   else reuse existing buf; memcpy prep_len bytes; set len; free(prep).
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X; hybrid pure owns cells.
 */
#[no_mangle]
export function pipeline_loaded_import_commit_from_owned(prep: *u8, prep_len: i64): i32 {
  if (prep == 0 as *u8) {
    return 0 - 1;
  }
  let buf: *u8 = shux_ptr_slot_get(&g_pipe_loaded_import_buf[0], 0);
  let cap: i64 = shux_size_slot_get(&g_pipe_loaded_import_cap[0], 0);
  // Reallocate when buffer missing or too small for prep_len (same order as seed).
  if (prep_len > cap || buf == 0 as *u8) {
    // free(NULL) is fine; seed always free then assign new cap before malloc.
    unsafe {
      free(buf);
    }
    // Cap floor 4194304 = SHUX_PIPELINE_IMPORT_BUF_CAP; else prep_len + 65536.
    // Seed: prep_len < floor ? floor : prep_len + 65536  (i.e. >= floor → grow).
    let floor_cap: i64 = 4194304;
    let new_cap: i64 = floor_cap;
    if (prep_len >= floor_cap) {
      new_cap = prep_len + 65536;
    }
    // Seed sets cap before malloc; OOM leaves cap=new_cap and buf=null (len unchanged).
    shux_size_slot_set(&g_pipe_loaded_import_cap[0], 0, new_cap);
    let fresh: *u8 = 0 as *u8;
    unsafe {
      fresh = malloc(new_cap as usize);
    }
    if (fresh == 0 as *u8) {
      shux_ptr_slot_set(&g_pipe_loaded_import_buf[0], 0, 0 as *u8);
      unsafe {
        free(prep);
      }
      return 0 - 1;
    }
    shux_ptr_slot_set(&g_pipe_loaded_import_buf[0], 0, fresh);
    buf = fresh;
  }
  unsafe {
    // Copy prep into committed buffer; then transfer ownership of prep away (free).
    memcpy(buf, prep, prep_len as usize);
    free(prep);
  }
  shux_size_slot_set(&g_pipe_loaded_import_len[0], 0, prep_len);
  return 0;
}

/**
 * Return pointer to committed loaded-import source bytes (or null if empty).
 * @return *u8 — pipeline_loaded_import_buf; null when never committed / OOM cleared
 * wave72 pure: G.7 shux_ptr_slot_get on pure BSS. Matches seed null when buf null.
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_loaded_import_data(): *u8 {
  return shux_ptr_slot_get(&g_pipe_loaded_import_buf[0], 0);
}

/**
 * Return byte length of committed loaded-import buffer.
 * @return i64 — size_t length cell (0 when empty / never committed)
 * wave72 pure: G.7 shux_size_slot_get on pure BSS. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function pipeline_loaded_import_len_get(): i64 {
  return shux_size_slot_get(&g_pipe_loaded_import_len[0], 0);
}

/**
 * Return base of the pipeline resolved-path static buffer (cap 512 incl trailing NUL room).
 * @return *u8 — always non-null; points at g_pipe_resolved_path_buf[0]
 * wave69 pure: pure resolve_path_into_static writes here via multi resolve;
 * pure read_file_stage_prep reads the path for open/preprocess diags.
 * Cap 512 matches historical seed `static char pipeline_resolved_path_buf[512]`.
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X; hybrid pure owns this cell only.
 */
#[no_mangle]
export function pipeline_resolved_path_buf_slot(): *u8 {
  return &g_pipe_resolved_path_buf[0];
}

/**
 * Store pointer p into pipeline dep-arena slot i (capacity 32).
 * @param i i32 — slot index; i < 0 or i >= 32 → no-op
 * @param p *u8 — arena pointer (may be null)
 * @return void
 * wave70 pure: G.7 shux_ptr_slot_set on g_pipe_dep_arena_slots (32×LP64 LE cells).
 * Matches seed bounds policy on set (reject OOB; do not trap).
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X; hybrid pure owns the table.
 */
#[no_mangle]
export function pipeline_dep_arena_slot_set(i: i32, p: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  shux_ptr_slot_set(&g_pipe_dep_arena_slots[0], i, p);
}

/**
 * Store pointer p into pipeline dep-module slot i (capacity 32).
 * @param i i32 — slot index; i < 0 or i >= 32 → no-op
 * @param p *u8 — module pointer (may be null)
 * @return void
 * wave70 pure: G.7 shux_ptr_slot_set on g_pipe_dep_module_slots (pair of arena table).
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_dep_module_slot_set(i: i32, p: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  shux_ptr_slot_set(&g_pipe_dep_module_slots[0], i, p);
}

/**
 * Load pipeline dep-arena slot i (capacity 32; historical seed had no OOB guard).
 * @param i i32 — slot index; pure rejects i < 0 or i >= 32 → null (safer than seed raw index)
 * @return *u8 — stored arena pointer (may be null)
 * wave70 pure: G.7 shux_ptr_slot_get on g_pipe_dep_arena_slots.
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X; pure get_dep_* bounds first.
 */
#[no_mangle]
export function pipeline_dep_arena_slot_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  return shux_ptr_slot_get(&g_pipe_dep_arena_slots[0], i);
}

/**
 * Load pipeline dep-module slot i (capacity 32).
 * @param i i32 — slot index; pure rejects OOB → null
 * @return *u8 — stored module pointer (may be null)
 * wave70 pure: G.7 shux_ptr_slot_get on g_pipe_dep_module_slots.
 * PLATFORM: SHARED LP64 — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_dep_module_slot_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  return shux_ptr_slot_get(&g_pipe_dep_module_slots[0], i);
}

/**
 * Copy NUL-terminated path into the pipeline entry_dir BSS buffer and select it.
 * @param path *u8 — directory path; null → no-op (keeps prior selection)
 * @return void
 * wave68 pure: snprintf-equivalent byte copy into g_pipe_entry_dir_buf (cap 512 incl NUL).
 * Clears is_dot so pipeline_entry_dir_get returns the buffer base.
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_entry_dir_copy(path: *u8): void {
  if (path == 0 as *u8) {
    return;
  }
  let i: i32 = 0;
  unsafe {
    // Cap 511 data bytes + trailing NUL — matches seed snprintf into char[512].
    while (i < 511) {
      let c: u8 = path[i];
      g_pipe_entry_dir_buf[i] = c;
      if (c == 0) {
        g_pipe_entry_dir_is_dot = 0;
        return;
      }
      i = i + 1;
    }
    g_pipe_entry_dir_buf[511] = 0;
    g_pipe_entry_dir_is_dot = 0;
  }
}

/**
 * Reset pipeline entry_dir selection to the static "." literal BSS.
 * @return void
 * wave68 pure: sets is_dot and ensures g_pipe_entry_dir_dot holds '.' + NUL.
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function pipeline_entry_dir_set_dot(): void {
  g_pipe_entry_dir_is_dot = 1;
  g_pipe_entry_dir_dot[0] = 46;
  g_pipe_entry_dir_dot[1] = 0;
}

/**
 * Return the active pipeline entry_dir C string (never null).
 * @return *u8 — either g_pipe_entry_dir_dot (".") or g_pipe_entry_dir_buf; always NUL-terminated
 * wave68 pure: is_dot selects lit vs copy buffer; default is_dot=1 matches seed ".".
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X; used by pure into_static orch.
 */
#[no_mangle]
export function pipeline_entry_dir_get(): *u8 {
  if (g_pipe_entry_dir_is_dot != 0) {
    // First get before set_dot may see zeroed BSS — always materialize "." lit.
    g_pipe_entry_dir_dot[0] = 46;
    g_pipe_entry_dir_dot[1] = 0;
    return &g_pipe_entry_dir_dot[0];
  }
  return &g_pipe_entry_dir_buf[0];
}

// pipeline_set_entry_dir: see function docblock below.
/**
 * Set pipeline resolve/read entry directory from path (null/empty → ".").
 * @param path *u8 — NUL-terminated directory; null or empty → pure set_dot
 * @return void
 * Pure orch over pure entry_dir_copy / set_dot (wave68 BSS writers).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_set_entry_dir(path: *u8): void {
  unsafe {
    if (path == 0 as *u8) {
      pipeline_entry_dir_set_dot();
      return;
    }
    if (path[0] == 0) {
      pipeline_entry_dir_set_dot();
      return;
    }
    pipeline_entry_dir_copy(path);
  }
}

/**
 * Bulk-write all 32 dep arena/module slots from two void-star tables (or clear if null).
 * @param arenas *u8 — void** base as bytes (32 cells); null → write null arenas
 * @param modules *u8 — void** base as bytes (32 cells); null → write null modules
 * @return void
 * Pure orch: load each cell via pipe_load_ptr_slot then G.7 pure pipeline_dep_*_slot_set
 * (wave70 BSS; single authority — no direct second write into g_pipe_dep_*).
 * PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function pipeline_set_dep_slots(arenas: *u8, modules: *u8): void {
  let i: i32 = 0;
  while (i < 32) {
    unsafe {
      let a: *u8 = 0 as *u8;
      let m: *u8 = 0 as *u8;
      if (arenas != 0 as *u8) {
        a = pipe_load_ptr_slot(arenas, i);
      }
      if (modules != 0 as *u8) {
        m = pipe_load_ptr_slot(modules, i);
      }
      // G.7 pure wave70 slot writers — same cells pure get_dep_* / slot_at read.
      pipeline_dep_arena_slot_set(i, a);
      pipeline_dep_module_slot_set(i, m);
    }
    i = i + 1;
  }
}

// shux_pipeline_fill_ctx_path_buffers: see function docblock below.
/** Exported function `shux_pipeline_fill_ctx_path_buffers`.
 * Implements `shux_pipeline_fill_ctx_path_buffers`.
 * @param ctx *u8
 * @param entry_dir *u8
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @return void
 */
#[no_mangle]
export function shux_pipeline_fill_ctx_path_buffers(ctx: *u8, entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  unsafe {
    pipeline_dep_ctx_path_bufs_reset(ctx);
    if (entry_dir != 0 as *u8) {
      pipeline_dep_ctx_copy_entry_dir(ctx, entry_dir);
    }
  }
  if (lib_roots == 0 as *u8) {
    return;
  }
  if (n_lib_roots <= 0) {
    return;
  }
  let i: i32 = 0;
  while (i < n_lib_roots) {
    unsafe {
      let p: *u8 = pipe_load_ptr_slot(lib_roots, i);
      if (p != 0 as *u8) {
        let ll: i32 = pipe_cstr_len(p);
        if (ll > 255) {
          ll = 255;
        }
        if (ll > 0) {
          let _r: i32 = ast_pipeline_ctx_append_lib_root(ctx, p, ll);
        }
      }
    }
    i = i + 1;
  }
}

// pipe_cstr_len: see function docblock below.
/** Exported function `pipe_cstr_len`.
 * Query helper `pipe_cstr_len`.
 * @param s *u8
 * @return i32
 */
export function pipe_cstr_len(s: *u8): i32 {
  if (s == 0 as *u8) { return 0; }
  let i: i32 = 0;
  while (i < 65536) {
    if (s[i] == 0) { return i; }
    i = i + 1;
  }
  return i;
}

// shux_pipeline_pctx_seed_dep_slots: see function docblock below.
/** Exported function `shux_pipeline_pctx_seed_dep_slots`.
 * Implements `shux_pipeline_pctx_seed_dep_slots`.
 * @param ctx *u8
 * @param dep_mods *u8
 * @param dep_ar *u8
 * @param import_paths *u8
 * @param n i32
 * @return void
 */
#[no_mangle]
export function shux_pipeline_pctx_seed_dep_slots(ctx: *u8, dep_mods: *u8, dep_ar: *u8, import_paths: *u8, n: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  unsafe {
    ast_pipeline_dep_ctx_reset(ctx);
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      let m: *u8 = 0 as *u8;
      let a: *u8 = 0 as *u8;
      if (dep_mods != 0 as *u8) {
        m = pipe_load_ptr_slot(dep_mods, i);
      }
      if (dep_ar != 0 as *u8) {
        a = pipe_load_ptr_slot(dep_ar, i);
      }
      ast_pipeline_dep_ctx_set_module(ctx, i, m);
      ast_pipeline_dep_ctx_set_arena(ctx, i, a);
      if (import_paths != 0 as *u8) {
        let p: *u8 = pipe_load_ptr_slot(import_paths, i);
        if (p != 0 as *u8) {
          let pl: i32 = pipe_cstr_len(p);
          ast_pipeline_dep_ctx_set_import_path(ctx, i, p, pl);
        }
      }
    }
    i = i + 1;
  }
  unsafe {
    ast_pipeline_dep_ctx_set_ndep(ctx, n);
  }
}

// shux_pipeline_pctx_seed_dep_import_paths_only: see function docblock below.
/** Exported function `shux_pipeline_pctx_seed_dep_import_paths_only`.
 * Implements `shux_pipeline_pctx_seed_dep_import_paths_only`.
 * @param ctx *u8
 * @param import_paths *u8
 * @param n i32
 * @return void
 */
#[no_mangle]
export function shux_pipeline_pctx_seed_dep_import_paths_only(ctx: *u8, import_paths: *u8, n: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  unsafe {
    ast_pipeline_dep_ctx_reset(ctx);
  }
  let i: i32 = 0;
  while (i < n) {
    if (import_paths != 0 as *u8) {
      unsafe {
        let p: *u8 = pipe_load_ptr_slot(import_paths, i);
        if (p != 0 as *u8) {
          let pl: i32 = pipe_cstr_len(p);
          ast_pipeline_dep_ctx_set_import_path(ctx, i, p, pl);
        }
      }
    }
    i = i + 1;
  }
}

/**
 * Map one dep prerun ctx slots from dep's own import table (not entry full dep list).
 * Allocates tmp arena/module, parses dep_src, filters dep_mods/ars/paths by import names,
 * writes compact ctx slots [0..mapped). Hard parse fail falls back to full ndep slots.
 * @param ctx *u8 — PipelineDepCtx*; null → no-op
 * @param dep_mods *u8 — void star-star loaded dep modules base
 * @param dep_ars *u8 — void star-star loaded dep arenas base
 * @param dep_paths *u8 — char star-star loaded dep path keys base
 * @param ndep i32 — loaded dep count (table width)
 * @param dep_src *u8 — dep source bytes for import scan; caller thin already validated
 * @param dep_src_len i64 — byte length; must be in (0, INT32_MAX]
 * @return void
 * wave62 pure Cap residual orch:
 *   G.7 pipeline_sizeof_arena / pipeline_sizeof_module (glue Cap residual);
 *   G.7 pure parser_parse_into_init (weak empty here; strong parser wins final link);
 *   G.7 pure driver_parse_into_buf_rc (returns raw ok; allow 0 and -2 like historical seed);
 *   G.7 pure shux_module_num_imports / shux_module_import_path_cstr /
 *   shux_find_loaded_import_index / shux_pipeline_pctx_update_dep_slots_no_reset /
 *   pipe_load_ptr_slot / pipe_cstr_len / ast_pipeline_dep_ctx_set_*.
 * Why not pipeline_parse_into_bytes: that maps non-zero ok to -1 and loses ok==-2
 * (under-parse still has usable import table). PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_pipeline_one_ctx_for_dep_prerun_map_impl(ctx: *u8, dep_mods: *u8, dep_ars: *u8, dep_paths: *u8, ndep: i32, dep_src: *u8, dep_src_len: i64): void {
  if (ctx == 0 as *u8) {
    return;
  }
  let asz: usize = 0 as usize;
  let msz: usize = 0 as usize;
  unsafe {
    asz = pipeline_sizeof_arena();
    msz = pipeline_sizeof_module();
  }
  let tmp_arena: *u8 = 0 as *u8;
  let tmp_module: *u8 = 0 as *u8;
  unsafe {
    tmp_arena = malloc(asz);
    tmp_module = malloc(msz);
  }
  // OOM: fall back to full entry dep table (same as historical seed).
  if (tmp_arena == 0 as *u8) {
    if (tmp_module != 0 as *u8) {
      unsafe {
        free(tmp_module);
      }
    }
    shux_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
    return;
  }
  if (tmp_module == 0 as *u8) {
    unsafe {
      free(tmp_arena);
    }
    shux_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
    return;
  }
  unsafe {
    memset(tmp_arena, 0, asz);
    memset(tmp_module, 0, msz);
    // Init before parse_into_buf residual (same order as seed map_impl).
    parser_parse_into_init(tmp_module, tmp_arena);
  }
  // INT32_MAX already gated by thin; cast for buf_rc ABI.
  let len_i32: i32 = dep_src_len as i32;
  let pr_ok: i32 = 0;
  unsafe {
    // Cap-struct-return residual unpacks ParseIntoResult.ok; null out_main_idx.
    pr_ok = driver_parse_into_buf_rc(tmp_arena, tmp_module, dep_src, len_i32, 0 as *i32);
  }
  // Historical: accept ok==0 (full) and ok==-2 (under-parse; import table still usable).
  // Any other non-zero → free tmp + full slots fallback.
  if (pr_ok != 0) {
    if (pr_ok != (0 - 2)) {
      unsafe {
        free(tmp_arena);
        free(tmp_module);
      }
      shux_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
      return;
    }
  }
  let n_imp: i32 = shux_module_num_imports(tmp_module);
  if (n_imp <= 0) {
    unsafe {
      free(tmp_arena);
      free(tmp_module);
      ast_pipeline_dep_ctx_set_ndep(ctx, 0);
    }
    return;
  }
  // Compact map: only imports that match a loaded dep path key (import_idx → ctx slot).
  let mapped: i32 = 0;
  let ii: i32 = 0;
  while (ii < n_imp) {
    let path_c: u8[65] = [];
    shux_module_import_path_cstr(tmp_module, ii, &path_c[0], 65);
    let g: i32 = shux_find_loaded_import_index(&path_c[0], dep_paths, ndep);
    if (g < 0) {
      ii = ii + 1;
      continue;
    }
    unsafe {
      let m: *u8 = pipe_load_ptr_slot(dep_mods, g);
      let a: *u8 = pipe_load_ptr_slot(dep_ars, g);
      ast_pipeline_dep_ctx_set_module(ctx, mapped, m);
      ast_pipeline_dep_ctx_set_arena(ctx, mapped, a);
      let p: *u8 = pipe_load_ptr_slot(dep_paths, g);
      if (p != 0 as *u8) {
        let pl: i32 = pipe_cstr_len(p);
        ast_pipeline_dep_ctx_set_import_path(ctx, mapped, p, pl);
      }
    }
    mapped = mapped + 1;
    ii = ii + 1;
  }
  unsafe {
    free(tmp_arena);
    free(tmp_module);
    ast_pipeline_dep_ctx_set_ndep(ctx, mapped);
  }
}

/**
 * Thin gate for one-ctx dep prerun mapping (null/empty/oversized → full slots or ndep=0).
 * @param ctx *u8 — PipelineDepCtx*; null → no-op
 * @param j i32 — historical dep index; unused (kept for ABI)
 * @param dep_mods *u8 — void star-star modules; null → ndep=0
 * @param dep_ars *u8 — void star-star arenas; null → ndep=0
 * @param dep_paths *u8 — char star-star paths; null → ndep=0
 * @param ndep i32 — loaded count; <=0 → ndep=0
 * @param dep_src *u8 — dep source for import scan; null/empty/oversized → full slots
 * @param dep_src_len i64 — source length; <=0 or > INT32_MAX → full slots
 * @return void
 * wave62: body in pure shux_pipeline_one_ctx_for_dep_prerun_map_impl after flags.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_pipeline_one_ctx_for_dep_prerun(ctx: *u8, j: i32, dep_mods: *u8, dep_ars: *u8, dep_paths: *u8, ndep: i32, dep_src: *u8, dep_src_len: i64): void {
  if (ctx == 0 as *u8) {
    return;
  }
  // Historical signature keeps j; map path ignores it.
  let _j: i32 = j;
  unsafe {
    pipeline_dep_ctx_set_use_asm_backend(ctx, 0);
  }
  if (dep_mods == 0 as *u8) {
    unsafe { ast_pipeline_dep_ctx_set_ndep(ctx, 0); }
    return;
  }
  if (dep_ars == 0 as *u8) {
    unsafe { ast_pipeline_dep_ctx_set_ndep(ctx, 0); }
    return;
  }
  if (dep_paths == 0 as *u8) {
    unsafe { ast_pipeline_dep_ctx_set_ndep(ctx, 0); }
    return;
  }
  if (ndep <= 0) {
    unsafe { ast_pipeline_dep_ctx_set_ndep(ctx, 0); }
    return;
  }
  if (dep_src == 0 as *u8) {
    shux_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
    return;
  }
  if (dep_src_len <= 0) {
    shux_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
    return;
  }
  // INT32_MAX — parse_into_buf residual takes int32_t len.
  let imax: i64 = 2147483647;
  if (dep_src_len > imax) {
    shux_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
    return;
  }
  unsafe {
    shux_pipeline_one_ctx_for_dep_prerun_map_impl(ctx, dep_mods, dep_ars, dep_paths, ndep, dep_src, dep_src_len);
  }
}

/* See implementation. */

// shux_driver_asm_prepare_entry_elf_emit: see function docblock below.
/** Exported function `shux_driver_asm_prepare_entry_elf_emit`.
 * Implements `shux_driver_asm_prepare_entry_elf_emit`.
 * @param module *u8
 * @param arena *u8
 * @param pctx *u8
 * @return void
 */
#[no_mangle]
export function shux_driver_asm_prepare_entry_elf_emit(module: *u8, arena: *u8, pctx: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (arena == 0 as *u8) {
    return;
  }
  unsafe {
    asm_skip_heavy_set_pipeline_ctx(pctx);
    pipeline_fill_array_lit_types_for_skipped_typeck(module, arena);
    pipeline_fill_soa_field_access_for_asm_emit(module, arena);
    pipeline_debug_trace_named_func_bodies("emit_prepare_pre_fixup", module, arena);
    pipeline_module_fixup_with_arena_stmt_orders(module, arena);
    pipeline_debug_trace_named_func_bodies("emit_prepare_post_fixup", module, arena);
  }
}

// shux_asm_codegen_elf_o_large_stack: see function docblock below.
/**
 * Thin gate → pure shux_asm_codegen_elf_o_large_stack_impl (wave57).
 * @param module *u8 — AST module; null → -1
 * @param arena *u8 — AST arena; null → -1
 * @param ctx *u8 — PipelineDepCtx (may be null)
 * @param elf_ctx *u8 — ElfCodegenCtx (may be null)
 * @param out_buf *u8 — emit out buffer; null → -1
 * @return i32 — emit ec from large-stack orch
 * wave57: body in pure _impl; product emit via Cap residual (not same-TU weak stub).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_asm_codegen_elf_o_large_stack(module: *u8, arena: *u8, ctx: *u8, elf_ctx: *u8, out_buf: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (out_buf == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return shux_asm_codegen_elf_o_large_stack_impl(module, arena, ctx, elf_ctx, out_buf);
  }
  return 0 - 1;
}

/**
 * Free dep_sources/dep_paths slots [0, mi) on load_direct failure (partial fill).
 * @param dep_sources *u8 — char star-star prep sources; may be null (skip frees)
 * @param dep_paths *u8 — char star-star owned keys; may be null (skip frees)
 * @param mi i32 — exclusive upper bound of slots to free; mi<=0 → no-op
 * @return void
 * wave51 pure Cap residual orch: walk mi-1..0; free non-null slots; clear to null.
 * G.7 single authority for fail cleanup (load_direct_imports layout + cold twin).
 * PLATFORM: SHARED — pure link-name; free still libc.
 */
#[no_mangle]
export function shux_load_direct_fail_cleanup(dep_sources: *u8, dep_paths: *u8, mi: i32): void {
  let i: i32 = mi;
  while (i > 0) {
    i = i - 1;
    if (dep_sources != 0 as *u8) {
      let s: *u8 = pipe_load_ptr_slot(dep_sources, i);
      if (s != 0 as *u8) {
        unsafe {
          free(s);
        }
        pipe_store_ptr_slot(dep_sources, i, 0 as *u8);
      }
    }
    if (dep_paths != 0 as *u8) {
      let p: *u8 = pipe_load_ptr_slot(dep_paths, i);
      if (p != 0 as *u8) {
        unsafe {
          free(p);
        }
        pipe_store_ptr_slot(dep_paths, i, 0 as *u8);
      }
    }
  }
}

/**
 * Resolve import key, read file view, preprocess → owned prep (no dep slot store).
 * @param lib_roots *u8 — char star-star lib roots; may be null if n_lib_roots==0
 * @param n_lib_roots i32 — lib root count
 * @param entry_dir *u8 — entry directory C string; may be null
 * @param import_key *u8 — import path key C string; null → fail 1
 * @param defines *u8 — char star-star define names; may be null if ndefines==0
 * @param ndefines i32 — define count; if <=0 pass null defines into preprocess
 * @param out_prep *u8 — char star-star out cell (LP64 8B); null → fail 1; cleared on entry
 * @param out_prep_len *u8 — size_t out cell as bytes; null → fail 1; cleared on entry
 * @return i32 — 0 success (*out_prep owned, free with free); 1 fail (out cleared)
 * wave55 pure Cap residual orch (was always-seed PATH_MAX+FILE view):
 *   stack resolved[4096] (SHARED path cap; gold Linux PATH_MAX);
 *   pure shux_resolve_import_file_path_multi;
 *   runtime_read_file_view into 32B stack ShuxRuntimeFileView (G.7 same as fmt_check);
 *   open fail → pure pipeline_diag_import_open_fail_once;
 *   pure shux_preprocess_raw_to_malloc(view.data, view.length, out_prep, out_prep_len, …);
 *   runtime_release_file_view always after read success path;
 *   null prep after preprocess ok → pure pipeline_diag_import_preprocess_fail.
 * G.7 load_one + paths_tmp call this (single resolve/read/preprocess body). PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_load_one_direct_resolve_read_preprocess(lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, import_key: *u8, defines: *u8, ndefines: i32, out_prep: *u8, out_prep_len: *u8): i32 {
  if (import_key == 0 as *u8) {
    return 1;
  }
  if (out_prep == 0 as *u8) {
    return 1;
  }
  if (out_prep_len == 0 as *u8) {
    return 1;
  }
  // Clear out cells first (same contract as seed cold twin).
  pipe_store_ptr_slot(out_prep, 0, 0 as *u8);
  shux_size_slot_set(out_prep_len, 0, 0);
  // Resolved path buffer: 4096 matches gold Linux PATH_MAX; pure stack (no BSS dual path).
  let resolved: u8[4096] = [];
  let zi: i32 = 0;
  while (zi < 4096) {
    resolved[zi] = 0;
    zi = zi + 1;
  }
  unsafe {
    shux_resolve_import_file_path_multi(lib_roots, n_lib_roots, entry_dir, import_key, &resolved[0], 4096 as i64);
  }
  // ShuxRuntimeFileView ABI: data@0 length@8 needs_free@16 needs_munmap@20 (24B; pad 32).
  let view: u8[32] = [];
  let z: i32 = 0;
  while (z < 32) {
    view[z] = 0;
    z = z + 1;
  }
  let view_rc: i32 = 0;
  unsafe {
    view_rc = runtime_read_file_view(&resolved[0], &view[0]);
  }
  if (view_rc != 0) {
    pipeline_diag_import_open_fail_once(import_key, &resolved[0]);
    return 1;
  }
  let raw_data: *u8 = shux_ptr_slot_get(&view[0], 0);
  let raw_len: i64 = shux_size_slot_get(&view[0], 1);
  // defines: only pass table when ndefines > 0 (seed cold twin ternary).
  let def_arg: *u8 = 0 as *u8;
  if (ndefines > 0) {
    def_arg = defines;
  }
  let prep_rc: i32 = 0;
  unsafe {
    prep_rc = shux_preprocess_raw_to_malloc(raw_data, raw_len, out_prep, out_prep_len, &resolved[0], def_arg, ndefines);
  }
  unsafe {
    runtime_release_file_view(&view[0]);
  }
  if (prep_rc != 0) {
    // Preprocess failed: keep out cleared (preprocess may have written partial; re-clear).
    pipe_store_ptr_slot(out_prep, 0, 0 as *u8);
    shux_size_slot_set(out_prep_len, 0, 0);
    return 1;
  }
  let prep: *u8 = pipe_load_ptr_slot(out_prep, 0);
  if (prep == 0 as *u8) {
    pipeline_diag_import_preprocess_fail(import_key, &resolved[0]);
    shux_size_slot_set(out_prep_len, 0, 0);
    return 1;
  }
  return 0;
}

/**
 * Resolve one import key, read+preprocess into prep, store dep_sources/lens/paths[mi].
 * @param lib_roots *u8 — char star-star lib roots; may be null if n_lib_roots==0
 * @param n_lib_roots i32 — lib root count
 * @param entry_dir *u8 — entry directory C string; may be null
 * @param import_key *u8 — import path key C string; null → fail 1
 * @param defines *u8 — char star-star define names; may be null if ndefines==0
 * @param ndefines i32 — define count
 * @param dep_sources *u8 — char star-star prep sources out; may be null (skip store)
 * @param dep_lens *u8 — size_t array base as bytes; may be null (skip store)
 * @param dep_paths *u8 — char star-star owned keys out; may be null (skip strdup store)
 * @param mi i32 — slot index; mi < 0 → fail 1
 * @return i32 — 0 success (slot written); 1 fail (no partial slot leave when paths OOM frees prep)
 * wave51 pure Cap residual orch:
 *   wave55 pure shux_load_one_direct_resolve_read_preprocess → owned prep;
 *   store prep + prep_len at mi;
 *   wave54 pure shux_collect_strdup(import_key) → dep_paths[mi];
 *   OOM on key: free prep, clear source slot, return 1.
 * G.7 process_one / load_direct_imports layout call this. PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_load_one_direct_import_at(lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, import_key: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, mi: i32): i32 {
  if (import_key == 0 as *u8) {
    return 1;
  }
  if (mi < 0) {
    return 1;
  }
  // out_prep (char*) and out_prep_len (size_t) as 8-byte stack cells (LP64).
  let prep_cell: u8[8] = [];
  let prep_len_cell: u8[8] = [];
  let rc: i32 = 0;
  unsafe {
    rc = shux_load_one_direct_resolve_read_preprocess(lib_roots, n_lib_roots, entry_dir, import_key, defines, ndefines, &prep_cell[0], &prep_len_cell[0]);
  }
  if (rc != 0) {
    return 1;
  }
  let prep: *u8 = pipe_load_ptr_slot(&prep_cell[0], 0);
  let prep_len: i64 = shux_size_slot_get(&prep_len_cell[0], 0);
  if (prep == 0 as *u8) {
    return 1;
  }
  if (dep_sources != 0 as *u8) {
    pipe_store_ptr_slot(dep_sources, mi, prep);
  }
  if (dep_lens != 0 as *u8) {
    shux_size_slot_set(dep_lens, mi, prep_len);
  }
  if (dep_paths != 0 as *u8) {
    let key: *u8 = 0 as *u8;
    unsafe {
      key = shux_collect_strdup(import_key);
    }
    if (key == 0 as *u8) {
      unsafe {
        free(prep);
      }
      if (dep_sources != 0 as *u8) {
        pipe_store_ptr_slot(dep_sources, mi, 0 as *u8);
      }
      return 1;
    }
    pipe_store_ptr_slot(dep_paths, mi, key);
  }
  return 0;
}

// shux_load_direct_imports_for_asm_layout: see function docblock below.
/**
 * Load all direct module imports into dep_sources/lens/paths for asm layout.
 * @param module *u8 — AST module; null → -1
 * @param lib_roots *u8 — char star-star lib roots; may be null if n_lib_roots==0
 * @param n_lib_roots i32 — lib root count
 * @param entry_dir *u8 — entry directory C string; may be null
 * @param defines *u8 — char star-star define names; may be null if ndefines==0
 * @param ndefines i32 — define count
 * @param dep_sources *u8 — char star-star prep sources out slots
 * @param dep_lens *u8 — size_t array base as bytes for prep lengths
 * @param dep_paths *u8 — char star-star owned path keys out slots
 * @param out_n *i32 — out live count; null → -1
 * @return i32 — 0 success; 1 load fail (partial freed); -1 null args
 * wave45+ pure orch; wave51 uses pure load_one + fail_cleanup. PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_load_direct_imports_for_asm_layout(module: *u8, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, out_n: *i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (out_n == 0 as *i32) {
    return 0 - 1;
  }
  unsafe {
    shux_i32_store(out_n, 0);
  }
  let n_imports: i32 = 0;
  unsafe {
    n_imports = shux_module_num_imports(module);
  }
  if (n_imports <= 0) {
    return 0;
  }
  let mi: i32 = 0;
  let i: i32 = 0;
  while (i < n_imports) {
    if (i >= 32) { break; }
    if (mi >= 32) { break; }
    let path_c: u8[65] = [];
    unsafe {
      shux_module_import_path_cstr(module, i, &path_c[0], 65);
    }
    let rc: i32 = 0;
    unsafe {
      rc = shux_load_one_direct_import_at(lib_roots, n_lib_roots, entry_dir, &path_c[0], defines, ndefines, dep_sources, dep_lens, dep_paths, mi);
    }
    if (rc != 0) {
      unsafe {
        shux_load_direct_fail_cleanup(dep_sources, dep_paths, mi);
        shux_i32_store(out_n, 0);
      }
      return 1;
    }
    mi = mi + 1;
    i = i + 1;
  }
  unsafe {
    shux_i32_store(out_n, mi);
  }
  return 0;
}

// shux_merge_direct_then_transitive_dep_paths: see function docblock below.
/** Exported function `shux_merge_direct_then_transitive_dep_paths`.
 * Implements `shux_merge_direct_then_transitive_dep_paths`.
 * @param module *u8
 * @param n_imports i32
 * @param cpaths *u8
 * @param n_closure i32
 * @param out_paths *u8
 * @param out_n *i32
 * @return i32
 */
#[no_mangle]
export function shux_merge_direct_then_transitive_dep_paths(module: *u8, n_imports: i32, cpaths: *u8, n_closure: i32, out_paths: *u8, out_n: *i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (out_n == 0 as *i32) {
    return 0 - 1;
  }
  if (out_paths == 0 as *u8) {
    return 0 - 1;
  }
  let used: u8[32] = [];
  let ui: i32 = 0;
  while (ui < 32) {
    used[ui] = 0;
    ui = ui + 1;
  }
  let mi: i32 = 0;
  let i: i32 = 0;
  while (i < n_imports) {
    if (i >= 32) { break; }
    if (mi >= 32) { break; }
    let path_c: u8[65] = [];
    unsafe {
      shux_module_import_path_cstr(module, i, &path_c[0], 65);
    }
    let found: i32 = 0 - 1;
    let kk: i32 = 0;
    while (kk < n_closure) {
      unsafe {
        let cp: *u8 = 0 as *u8;
        if (cpaths != 0 as *u8) {
          cp = pipe_load_ptr_slot(cpaths, kk);
        }
        if (cp != 0 as *u8) {
          if (pipe_cstr_eq(cp, &path_c[0]) != 0) {
            found = kk;
          }
        }
      }
      if (found >= 0) { break; }
      kk = kk + 1;
    }
    if (found < 0) {
      pipeline_diag_merge_dep_missing(&path_c[0]);
      return 1;
    }
    unsafe {
      let pfound: *u8 = pipe_load_ptr_slot(cpaths, found);
      shux_ptr_slot_set(out_paths, mi, pfound);
    }
    if (found < 32) {
      used[found] = 1;
    }
    mi = mi + 1;
    i = i + 1;
  }
  let kj: i32 = 0;
  while (kj < n_closure) {
    if (mi >= 32) { break; }
    if (kj < 32) {
      if (used[kj] == 0) {
        unsafe {
          let cp2: *u8 = 0 as *u8;
          if (cpaths != 0 as *u8) {
            cp2 = pipe_load_ptr_slot(cpaths, kj);
          }
          if (cp2 != 0 as *u8) {
            if (shux_merge_deps_path_already_out(cp2, out_paths, mi) != 0) {
              used[kj] = 1;
            } else {
              shux_ptr_slot_set(out_paths, mi, cp2);
              mi = mi + 1;
            }
          } else {
            shux_ptr_slot_set(out_paths, mi, cp2);
            mi = mi + 1;
          }
        }
      }
    }
    kj = kj + 1;
  }
  unsafe {
    shux_i32_store(out_n, mi);
  }
  return 0;
}

/* See implementation. */

// shux_merge_direct_then_transitive_deps: see function docblock below.
/** Exported function `shux_merge_direct_then_transitive_deps`.
 * Implements `shux_merge_direct_then_transitive_deps`.
 * @param module *u8
 * @param n_imports i32
 * @param cls *u8
 * @param clens *u8
 * @param cpaths *u8
 * @param n_closure i32
 * @param out_src *u8
 * @param out_lens *u8
 * @param out_paths *u8
 * @param out_n *i32
 * @return i32
 */
#[no_mangle]
export function shux_merge_direct_then_transitive_deps(module: *u8, n_imports: i32, cls: *u8, clens: *u8, cpaths: *u8, n_closure: i32, out_src: *u8, out_lens: *u8, out_paths: *u8, out_n: *i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (out_n == 0 as *i32) {
    return 0 - 1;
  }
  if (out_paths == 0 as *u8) {
    return 0 - 1;
  }
  let used: u8[32] = [];
  let ui: i32 = 0;
  while (ui < 32) {
    used[ui] = 0;
    ui = ui + 1;
  }
  let mi: i32 = 0;
  let i: i32 = 0;
  while (i < n_imports) {
    if (i >= 32) { break; }
    if (mi >= 32) { break; }
    let path_c: u8[65] = [];
    unsafe {
      shux_module_import_path_cstr(module, i, &path_c[0], 65);
    }
    let found: i32 = 0 - 1;
    let kk: i32 = 0;
    while (kk < n_closure) {
      unsafe {
        let cp: *u8 = 0 as *u8;
        if (cpaths != 0 as *u8) {
          cp = pipe_load_ptr_slot(cpaths, kk);
        }
        if (cp != 0 as *u8) {
          if (pipe_cstr_eq(cp, &path_c[0]) != 0) {
            found = kk;
          }
        }
      }
      if (found >= 0) { break; }
      kk = kk + 1;
    }
    if (found < 0) {
      pipeline_diag_merge_dep_missing(&path_c[0]);
      return 1;
    }
    unsafe {
      let pfound: *u8 = 0 as *u8;
      let sfound: *u8 = 0 as *u8;
      let lfound: i64 = 0;
      if (cpaths != 0 as *u8) {
        pfound = pipe_load_ptr_slot(cpaths, found);
      }
      if (cls != 0 as *u8) {
        sfound = pipe_load_ptr_slot(cls, found);
      }
      if (clens != 0 as *u8) {
        lfound = shux_size_slot_get(clens, found);
      }
      if (out_src != 0 as *u8) {
        shux_ptr_slot_set(out_src, mi, sfound);
      }
      if (out_lens != 0 as *u8) {
        shux_size_slot_set(out_lens, mi, lfound);
      }
      shux_ptr_slot_set(out_paths, mi, pfound);
    }
    if (found < 32) {
      used[found] = 1;
    }
    mi = mi + 1;
    i = i + 1;
  }
  let kj: i32 = 0;
  while (kj < n_closure) {
    if (mi >= 32) { break; }
    if (kj < 32) {
      if (used[kj] == 0) {
        unsafe {
          let cp2: *u8 = 0 as *u8;
          if (cpaths != 0 as *u8) {
            cp2 = pipe_load_ptr_slot(cpaths, kj);
          }
          if (cp2 != 0 as *u8) {
            if (shux_merge_deps_path_already_out(cp2, out_paths, mi) != 0) {
              used[kj] = 1;
            } else {
              let s2: *u8 = 0 as *u8;
              let l2: i64 = 0;
              if (cls != 0 as *u8) {
                s2 = pipe_load_ptr_slot(cls, kj);
              }
              if (clens != 0 as *u8) {
                l2 = shux_size_slot_get(clens, kj);
              }
              if (out_src != 0 as *u8) {
                shux_ptr_slot_set(out_src, mi, s2);
              }
              if (out_lens != 0 as *u8) {
                shux_size_slot_set(out_lens, mi, l2);
              }
              shux_ptr_slot_set(out_paths, mi, cp2);
              mi = mi + 1;
            }
          } else {
            let s3: *u8 = 0 as *u8;
            let l3: i64 = 0;
            if (cls != 0 as *u8) {
              s3 = pipe_load_ptr_slot(cls, kj);
            }
            if (clens != 0 as *u8) {
              l3 = shux_size_slot_get(clens, kj);
            }
            if (out_src != 0 as *u8) {
              shux_ptr_slot_set(out_src, mi, s3);
            }
            if (out_lens != 0 as *u8) {
              shux_size_slot_set(out_lens, mi, l3);
            }
            shux_ptr_slot_set(out_paths, mi, cp2);
            mi = mi + 1;
          }
        }
      }
    }
    kj = kj + 1;
  }
  unsafe {
    shux_i32_store(out_n, mi);
  }
  return 0;
}

// shux_collect_deps_transitive: see function docblock below.
/** Exported function `shux_collect_deps_transitive`.
 * Implements `shux_collect_deps_transitive`.
 * @param module *u8
 * @param arena_sz i64
 * @param module_sz i64
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @param entry_dir *u8
 * @param defines *u8
 * @param ndefines i32
 * @param dep_sources *u8
 * @param dep_lens *u8
 * @param dep_paths *u8
 * @param n_deps *i32
 * @return i32
 */
#[no_mangle]
export function shux_collect_deps_transitive(module: *u8, arena_sz: i64, module_sz: i64, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, n_deps: *i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (n_deps == 0 as *i32) {
    return 0 - 1;
  }
  let nimp: i32 = 0;
  unsafe {
    nimp = shux_module_num_imports(module);
  }
  if (nimp <= 0) {
    unsafe {
      shux_i32_store(n_deps, 0);
    }
    return 0;
  }
  unsafe {
    return shux_collect_deps_transitive_impl(module, arena_sz, module_sz, lib_roots, n_lib_roots, entry_dir, defines, ndefines, dep_sources, dep_lens, dep_paths, n_deps);
  }
  return 0 - 1;
}

// shux_collect_dep_paths_transitive: see function docblock below.
/** Exported function `shux_collect_dep_paths_transitive`.
 * Implements `shux_collect_dep_paths_transitive`.
 * @param module *u8
 * @param arena_sz i64
 * @param module_sz i64
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @param entry_dir *u8
 * @param defines *u8
 * @param ndefines i32
 * @param dep_paths *u8
 * @param n_deps *i32
 * @return i32
 */
#[no_mangle]
export function shux_collect_dep_paths_transitive(module: *u8, arena_sz: i64, module_sz: i64, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_paths: *u8, n_deps: *i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (n_deps == 0 as *i32) {
    return 0 - 1;
  }
  let nimp: i32 = 0;
  unsafe {
    nimp = shux_module_num_imports(module);
  }
  if (nimp <= 0) {
    unsafe {
      shux_i32_store(n_deps, 0);
    }
    return 0;
  }
  unsafe {
    return shux_collect_dep_paths_transitive_impl(module, arena_sz, module_sz, lib_roots, n_lib_roots, entry_dir, defines, ndefines, dep_paths, n_deps);
  }
  return 0 - 1;
}

/** Exported function `pipeline_debug_trace_named_func_bodies`.
 * Implements `pipeline_debug_trace_named_func_bodies`.
 * @param phase *u8
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_named_func_bodies(phase: *u8, module: *u8, arena: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (arena == 0 as *u8) {
    return;
  }
  unsafe {
    pipeline_debug_trace_named_func_bodies_impl(phase, module, arena);
  }
}

/* ---- G-02f-63 / G-02f-242 / wave63：typeck_for_ctx / lsp free_loaded ---- */

/**
 * Typecheck entry module with no dep sidecar (ndep path unused).
 * @param module *u8 — AST module; null → -1
 * @return i32 — 0 success, -1 null or typeck_module failure
 * wave63 pure Cap residual orch: G.7 Cap residual typeck_module (C frontend).
 * PLATFORM: SHARED — same semantics as seed cold twin.
 */
#[no_mangle]
export function typeck_module_entry_only(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let rc: i32 = 0;
  unsafe {
    // Cap residual C typeck frontend; no dep table.
    rc = typeck_module(module, 0 as *u8, 0, 0 as *u8, 0);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Typecheck entry module with typeck_ndep / typeck_dep_module_ptrs sidecar when ndep>0.
 * @param module *u8 — AST module; null → -1
 * @return i32 — 0 success, -1 null or typeck_module failure
 * wave63 pure Cap residual orch (wave77 pure owns BSS base):
 *   G.7 pure get_ndep (typeck_ndep_slot pure BSS);
 *   G.7 pure typeck_dep_module_ptrs_base (wave77 pure table base for void**);
 *   G.7 Cap residual typeck_module (C frontend).
 * PLATFORM: SHARED — same as seed: deps null when ndep==0.
 */
#[no_mangle]
export function typeck_module_with_sidecar(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let n: i32 = get_ndep();
  let deps: *u8 = 0 as *u8;
  if (n > 0) {
    unsafe {
      deps = typeck_dep_module_ptrs_base();
    }
  }
  let rc: i32 = 0;
  unsafe {
    rc = typeck_module(module, deps, n, 0 as *u8, 0);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Choose entry-only vs sidecar typeck from current typeck_ndep (arena/ctx unused).
 * @param module *u8 — AST module; null → -1
 * @param arena *u8 — historical; unused (kept for ABI)
 * @param ctx_void *u8 — historical; unused (kept for ABI)
 * @return i32 — 0 success, -1 failure
 * wave63 pure Cap residual orch: G.7 pure typeck_module_entry_only / with_sidecar.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_typeck_module_for_ctx_impl(module: *u8, arena: *u8, ctx_void: *u8): i32 {
  let _a: *u8 = arena;
  let _c: *u8 = ctx_void;
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let n: i32 = get_ndep();
  if (n > 0) {
    return typeck_module_with_sidecar(module);
  }
  return typeck_module_entry_only(module);
}

/**
 * Thin gate for pipeline typeck-for-ctx (null module → -1).
 * @param module *u8 — AST module; null → -1
 * @param arena *u8 — passed through (unused by impl)
 * @param ctx *u8 — passed through (unused by impl)
 * @return i32 — 0 success, -1 failure
 * wave63: body in pure pipeline_typeck_module_for_ctx_impl after null gate.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_typeck_module_for_ctx(module: *u8, arena: *u8, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  return pipeline_typeck_module_for_ctx_impl(module, arena, ctx);
}

/**
 * Clear pointer table slot i to null (after free/ast_module_free of the old value).
 * @param arr *u8 — void-star / char-star table base; null → no-op
 * @param i i32 — index; i < 0 → no-op
 * @return void
 * wave78 pure: G.7 thin → shux_ptr_slot_set(arr, i, null); single authority for slot stores.
 * PLATFORM: SHARED — cold twin under seed #ifndef FROM_X.
 */
#[no_mangle]
export function shu_lsp_ptr_slot_clear(arr: *u8, i: i32): void {
  if (arr == 0 as *u8) {
    return;
  }
  if (i < 0) {
    return;
  }
  unsafe {
    shux_ptr_slot_set(arr, i, 0 as *u8);
  }
}

// shu_lsp_free_loaded_imports: see function docblock below.
/**
 * Free dep modules/paths written by shu_lsp_resolve_and_load_imports (not entry module).
 * @param all_dep_mods *u8 — void** module table base
 * @param all_dep_paths *u8 — char** path table base
 * @param n_all i32 — slot count; <=0 → no-op
 * @return void
 * G.7 pure shu_lsp_ptr_slot_clear (wave78) nulls slots after free.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function shu_lsp_free_loaded_imports(all_dep_mods: *u8, all_dep_paths: *u8, n_all: i32): void {
  if (all_dep_mods == 0 as *u8) { return; }
  if (all_dep_paths == 0 as *u8) { return; }
  if (n_all <= 0) { return; }
  let i: i32 = 0;
  while (i < n_all) {
    unsafe {
      let p: *u8 = pipe_load_ptr_slot(all_dep_paths, i);
      if (p != 0 as *u8) {
        free(p);
        shu_lsp_ptr_slot_clear(all_dep_paths, i);
      }
      let m: *u8 = pipe_load_ptr_slot(all_dep_mods, i);
      if (m != 0 as *u8) {
        ast_module_free(m);
        shu_lsp_ptr_slot_clear(all_dep_mods, i);
      }
    }
    i = i + 1;
  }
}


/* See implementation. */


// See implementation.
// kind="preprocess error" / "pipeline error" / "import error"；code=PP001/PP002/XP005/IMP002/IMP004

/** Exported function `pipeline_diag_preprocess_unclosed_if`.
 * Implements `pipeline_diag_preprocess_unclosed_if`.
 * @param path_diag *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_preprocess_unclosed_if(path_diag: *u8): void {
  pipeline_diag_emitted_note();
  let kind: u8[24] = [];
  let code: u8[8] = [];
  let msg: u8[16] = [];
  // "preprocess error"
  kind[0]=112;kind[1]=114;kind[2]=101;kind[3]=112;kind[4]=114;kind[5]=111;kind[6]=99;kind[7]=101;
  kind[8]=115;kind[9]=115;kind[10]=32;kind[11]=101;kind[12]=114;kind[13]=114;kind[14]=111;kind[15]=114;kind[16]=0;
  // "PP001"
  code[0]=80;code[1]=80;code[2]=48;code[3]=48;code[4]=49;code[5]=0;
  // "unclosed #if"
  msg[0]=117;msg[1]=110;msg[2]=99;msg[3]=108;msg[4]=111;msg[5]=115;msg[6]=101;msg[7]=100;
  msg[8]=32;msg[9]=35;msg[10]=105;msg[11]=102;msg[12]=0;
  unsafe {
    diag_report_with_code(path_diag, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
}

/** Exported function `pipeline_diag_preprocess_fail`.
 * Implements `pipeline_diag_preprocess_fail`.
 * @param path_diag *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_preprocess_fail(path_diag: *u8): void {
  pipeline_diag_emitted_note();
  let kind: u8[24] = [];
  let code: u8[8] = [];
  let msg: u8[40] = [];
  kind[0]=112;kind[1]=114;kind[2]=101;kind[3]=112;kind[4]=114;kind[5]=111;kind[6]=99;kind[7]=101;
  kind[8]=115;kind[9]=115;kind[10]=32;kind[11]=101;kind[12]=114;kind[13]=114;kind[14]=111;kind[15]=114;kind[16]=0;
  code[0]=80;code[1]=80;code[2]=48;code[3]=48;code[4]=50;code[5]=0; // PP002
  // ".x preprocess failed"
  msg[0]=46;msg[1]=120;msg[2]=32;msg[3]=112;msg[4]=114;msg[5]=101;msg[6]=112;msg[7]=114;
  msg[8]=111;msg[9]=99;msg[10]=101;msg[11]=115;msg[12]=115;msg[13]=32;msg[14]=102;msg[15]=97;
  msg[16]=105;msg[17]=108;msg[18]=101;msg[19]=100;msg[20]=0;
  unsafe {
    diag_report_with_code(path_diag, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
}

/** Exported function `pipeline_diag_import_preprocess_fail`.
 * Implements `pipeline_diag_import_preprocess_fail`.
 * @param import_path *u8
 * @param resolved_path *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_import_preprocess_fail(import_path: *u8, resolved_path: *u8): void {
  pipeline_diag_emitted_note();
  let kind: u8[24] = [];
  let code: u8[8] = [];
  let msg: u8[40] = [];
  kind[0]=112;kind[1]=114;kind[2]=101;kind[3]=112;kind[4]=114;kind[5]=111;kind[6]=99;kind[7]=101;
  kind[8]=115;kind[9]=115;kind[10]=32;kind[11]=101;kind[12]=114;kind[13]=114;kind[14]=111;kind[15]=114;kind[16]=0;
  code[0]=73;code[1]=77;code[2]=80;code[3]=48;code[4]=48;code[5]=50;code[6]=0; // IMP002
  // "import preprocess failed"
  msg[0]=105;msg[1]=109;msg[2]=112;msg[3]=111;msg[4]=114;msg[5]=116;msg[6]=32;msg[7]=112;
  msg[8]=114;msg[9]=101;msg[10]=112;msg[11]=114;msg[12]=111;msg[13]=99;msg[14]=101;msg[15]=115;
  msg[16]=115;msg[17]=32;msg[18]=102;msg[19]=97;msg[20]=105;msg[21]=108;msg[22]=101;msg[23]=100;msg[24]=0;
  let file: *u8 = resolved_path;
  if (file == 0 as *u8) { file = import_path; }
  unsafe {
    diag_report_with_code(file, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
}

/** Exported function `pipeline_diag_preprocess_alloc_fail`.
 * Memory management helper `pipeline_diag_preprocess_alloc_fail`.
 * @param path_diag *u8
 * @param what *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_preprocess_alloc_fail(path_diag: *u8, what: *u8): void {
  pipeline_diag_emitted_note();
  let kind: u8[24] = [];
  let code: u8[8] = [];
  let msg: u8[48] = [];
  // "pipeline error"
  kind[0]=112;kind[1]=105;kind[2]=112;kind[3]=101;kind[4]=108;kind[5]=105;kind[6]=110;kind[7]=101;
  kind[8]=32;kind[9]=101;kind[10]=114;kind[11]=114;kind[12]=111;kind[13]=114;kind[14]=0;
  code[0]=88;code[1]=80;code[2]=48;code[3]=48;code[4]=53;code[5]=0; // XP005
  // "allocation failed during preprocess"
  msg[0]=97;msg[1]=108;msg[2]=108;msg[3]=111;msg[4]=99;msg[5]=97;msg[6]=116;msg[7]=105;
  msg[8]=111;msg[9]=110;msg[10]=32;msg[11]=102;msg[12]=97;msg[13]=105;msg[14]=108;msg[15]=101;
  msg[16]=100;msg[17]=32;msg[18]=100;msg[19]=117;msg[20]=114;msg[21]=105;msg[22]=110;msg[23]=103;
  msg[24]=32;msg[25]=112;msg[26]=114;msg[27]=101;msg[28]=112;msg[29]=114;msg[30]=111;msg[31]=99;
  msg[32]=101;msg[33]=115;msg[34]=115;msg[35]=0;
  let _w: *u8 = what;
  unsafe {
    diag_report_with_code(path_diag, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
}

/** Exported function `pipeline_diag_merge_dep_missing`.
 * Implements `pipeline_diag_merge_dep_missing`.
 * @param import_path *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_merge_dep_missing(import_path: *u8): void {
  pipeline_diag_emitted_note();
  let kind: u8[16] = [];
  let code: u8[8] = [];
  let msg: u8[48] = [];
  let note_k: u8[8] = [];
  let note_m: u8[64] = [];
  // "import error"
  kind[0]=105;kind[1]=109;kind[2]=112;kind[3]=111;kind[4]=114;kind[5]=116;kind[6]=32;kind[7]=101;
  kind[8]=114;kind[9]=114;kind[10]=111;kind[11]=114;kind[12]=0;
  code[0]=73;code[1]=77;code[2]=80;code[3]=48;code[4]=48;code[5]=52;code[6]=0; // IMP004
  // "direct import missing from dependency closure"
  msg[0]=100;msg[1]=105;msg[2]=114;msg[3]=101;msg[4]=99;msg[5]=116;msg[6]=32;msg[7]=105;
  msg[8]=109;msg[9]=112;msg[10]=111;msg[11]=114;msg[12]=116;msg[13]=32;msg[14]=109;msg[15]=105;
  msg[16]=115;msg[17]=115;msg[18]=105;msg[19]=110;msg[20]=103;msg[21]=32;msg[22]=102;msg[23]=114;
  msg[24]=111;msg[25]=109;msg[26]=32;msg[27]=100;msg[28]=101;msg[29]=112;msg[30]=32;msg[31]=99;
  msg[32]=108;msg[33]=111;msg[34]=115;msg[35]=117;msg[36]=114;msg[37]=101;msg[38]=0;
  note_k[0]=110;note_k[1]=111;note_k[2]=116;note_k[3]=101;note_k[4]=0;
  // "dependency closure construction failed before merge_deps completed"
  note_m[0]=100;note_m[1]=101;note_m[2]=112;note_m[3]=101;note_m[4]=110;note_m[5]=100;note_m[6]=101;note_m[7]=110;
  note_m[8]=99;note_m[9]=121;note_m[10]=32;note_m[11]=99;note_m[12]=108;note_m[13]=111;note_m[14]=115;note_m[15]=117;
  note_m[16]=114;note_m[17]=101;note_m[18]=32;note_m[19]=99;note_m[20]=111;note_m[21]=110;note_m[22]=115;note_m[23]=116;
  note_m[24]=114;note_m[25]=117;note_m[26]=99;note_m[27]=116;note_m[28]=105;note_m[29]=111;note_m[30]=110;note_m[31]=32;
  note_m[32]=102;note_m[33]=97;note_m[34]=105;note_m[35]=108;note_m[36]=101;note_m[37]=100;note_m[38]=0;
  unsafe {
    diag_report_with_code(import_path, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
    diag_report(0 as *u8, 0, 0, &note_k[0], &note_m[0], 0 as *u8);
  }
}

// typeck_ndep_store: see function docblock below.
/** Exported function `typeck_ndep_store`.
 * Implements `typeck_ndep_store`.
 * @param n i32
 * @return void
 */
#[no_mangle]
export function typeck_ndep_store(n: i32): void {
  let v: i32 = n;
  if (v > 32) { v = 32; }
  if (v < 0) { v = 0; }
  unsafe {
    typeck_ndep_store_impl(v);
  }
}

// typeck_dep_module_set: see function docblock below.
/** Exported function `typeck_dep_module_set`.
 * Implements `typeck_dep_module_set`.
 * @param i i32
 * @param mod *u8
 * @return void
 */
#[no_mangle]
export function typeck_dep_module_set(i: i32, mod: *u8): void {
  if (i < 0) { return; }
  if (i >= 32) { return; }
  unsafe {
    typeck_dep_module_set_impl(i, mod);
  }
}

// typeck_dep_arena_set: see function docblock below.
/** Exported function `typeck_dep_arena_set`.
 * Implements `typeck_dep_arena_set`.
 * @param i i32
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function typeck_dep_arena_set(i: i32, arena: *u8): void {
  if (i < 0) { return; }
  if (i >= 32) { return; }
  unsafe {
    typeck_dep_arena_set_impl(i, arena);
  }
}

// driver_dep_arena_ptr_set: see function docblock below.
/** Exported function `driver_dep_arena_ptr_set`.
 * Implements `driver_dep_arena_ptr_set`.
 * @param i i32
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function driver_dep_arena_ptr_set(i: i32, arena: *u8): void {
  if (i < 0) { return; }
  if (i >= 32) { return; }
  unsafe {
    driver_dep_arena_ptr_set_impl(i, arena);
  }
}

/** Exported function `driver_dep_module_ptr_set`.
 * Implements `driver_dep_module_ptr_set`.
 * @param i i32
 * @param module *u8
 * @return void
 */
#[no_mangle]
export function driver_dep_module_ptr_set(i: i32, module: *u8): void {
  if (i < 0) { return; }
  if (i >= 32) { return; }
  unsafe {
    driver_dep_module_ptr_set_impl(i, module);
  }
}


/* ---- G-02f-85 / G-02f-134：import path scan ---- */

export function pipe_cstr_eq(a: *u8, b: *u8): i32 {
  if (a == 0) { return 0; }
  if (b == 0) { return 0; }
  let i: i32 = 0;
  while (i < 4096) {
    if (a[i] != b[i]) { return 0; }
    if (a[i] == 0) { return 1; }
    i = i + 1;
  }
  return 0;
}

// pipe_load_ptr_slot: see function docblock below.
/** Exported function `pipe_load_ptr_slot`.
 * Implements `pipe_load_ptr_slot`.
 * @param base *u8
 * @param i i32
 * @return *u8
 */
export function pipe_load_ptr_slot(base: *u8, i: i32): *u8 {
  if (base == 0) { return 0 as *u8; }
  let off: i32 = i * 8;
  let m: usize = 256;
  let m2: usize = m * m;
  let m4: usize = m2 * m2;
  let a: usize = base[off] as usize;
  a = a + (base[off + 1] as usize) * m;
  a = a + (base[off + 2] as usize) * m2;
  a = a + (base[off + 3] as usize) * (m2 * m);
  a = a + (base[off + 4] as usize) * m4;
  a = a + (base[off + 5] as usize) * (m4 * m);
  a = a + (base[off + 6] as usize) * (m4 * m2);
  a = a + (base[off + 7] as usize) * (m4 * m2 * m);
  return a as *u8;
}

/**
 * Store little-endian pointer into base[i] (LP64 8-byte cell).
 * Module-local pair of pipe_load_ptr_slot (no second G.7 path).
 * @param base *u8 — table base; null → no-op
 * @param i i32 — slot index; i < 0 → no-op
 * @param val *u8 — pointer bits to store (may be null)
 * @return void
 * PLATFORM: SHARED LP64 little-endian.
 */
function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void {
  if (base == 0 as *u8) {
    return;
  }
  if (i < 0) {
    return;
  }
  let off: i32 = i * 8;
  unsafe {
    let m: usize = 256 as usize;
    let b255: usize = 255 as usize;
    let u0: usize = val as usize;
    base[off] = (u0 & b255) as u8;
    let u1: usize = u0 / m;
    base[off + 1] = (u1 & b255) as u8;
    let u2: usize = u1 / m;
    base[off + 2] = (u2 & b255) as u8;
    let u3: usize = u2 / m;
    base[off + 3] = (u3 & b255) as u8;
    let u4: usize = u3 / m;
    base[off + 4] = (u4 & b255) as u8;
    let u5: usize = u4 / m;
    base[off + 5] = (u5 & b255) as u8;
    let u6: usize = u5 / m;
    base[off + 6] = (u6 & b255) as u8;
    let u7: usize = u6 / m;
    base[off + 7] = (u7 & b255) as u8;
  }
}

/**
 * Load size_t / i64 slot i from an array of LP64 8-byte cells (LE).
 * @param arr *u8 — size_t* base as bytes; null → 0
 * @param i i32 — index; i < 0 → 0
 * @return i64 — cell value as signed i64 (path lengths fit)
 * wave46 pure Cap residual; cold twin under #ifndef FROM_X.
 * PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function shux_size_slot_get(arr: *u8, i: i32): i64 {
  if (arr == 0 as *u8) {
    return 0;
  }
  if (i < 0) {
    return 0;
  }
  // Same LE reconstruct as pipe_load_ptr_slot; cast pointer bits → i64 length.
  let p: *u8 = pipe_load_ptr_slot(arr, i);
  return p as i64;
}

/**
 * Store size_t / i64 into arr[i] (LP64 8-byte LE cell).
 * @param arr *u8 — size_t* base as bytes; null → no-op
 * @param i i32 — index; i < 0 → no-op
 * @param v i64 — value (path length / buffer size)
 * @return void
 * wave46 pure; pairs shux_size_slot_get. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function shux_size_slot_set(arr: *u8, i: i32, v: i64): void {
  if (arr == 0 as *u8) {
    return;
  }
  if (i < 0) {
    return;
  }
  pipe_store_ptr_slot(arr, i, v as *u8);
}

/**
 * Write pointer p into char-star / void-star array slot i (G.7 product authority).
 * @param arr *u8 — void** / char** table base as bytes; null → no-op
 * @param i i32 — slot index; i < 0 → no-op
 * @param p *u8 — pointer to store (may be null)
 * @return void
 * wave46 pure; driver_abi / fmt_check call this as Cap residual surface.
 * PLATFORM: SHARED LP64 — single authority in this TU under PREFER hybrid.
 */
#[no_mangle]
export function shux_ptr_slot_set(arr: *u8, i: i32, p: *u8): void {
  pipe_store_ptr_slot(arr, i, p);
}

/**
 * Load pointer slot i from a char-star / void-star array base (G.7 pair with set).
 * @param arr *u8 — table base; null → null
 * @param i i32 — index; i < 0 → null
 * @return *u8 — pointer at slot (may be null)
 * wave46 pure. PLATFORM: SHARED LP64.
 * Note: never put the two-char end-comment marker inside prose (truncates the block).
 */
#[no_mangle]
export function shux_ptr_slot_get(arr: *u8, i: i32): *u8 {
  if (arr == 0 as *u8) {
    return 0 as *u8;
  }
  if (i < 0) {
    return 0 as *u8;
  }
  return pipe_load_ptr_slot(arr, i);
}

/**
 * Store i32 v through pointer p (null-safe).
 * @param p *i32 — destination; null → no-op
 * @param v i32 — value
 * @return void
 * wave46 pure Cap residual (merge out_n / n_deps). PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_i32_store(p: *i32, v: i32): void {
  if (p == 0 as *i32) {
    return;
  }
  unsafe {
    p[0] = v;
  }
}

/**
 * Return module import count (null module → 0).
 * @param module *u8 — opaque AST module; null → 0
 * @return i32 — import count from parser authority
 * wave46 pure thin over parser_get_module_num_imports (strong from parser_x at final link).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_module_num_imports(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  return parser_get_module_num_imports(module);
}

/**
 * Copy import path at idx into buf as a C string (NUL-terminated).
 * @param module *u8 — opaque AST module; null → buf[0]=0 when buf valid
 * @param idx i32 — import index
 * @param buf *u8 — destination; null or cap<=0 → no-op
 * @param cap i32 — capacity including NUL; copies min(path, cap-1)
 * @return void
 * wave46 pure: parser path bytes then copy loop (no libc). PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_module_import_path_cstr(module: *u8, idx: i32, buf: *u8, cap: i32): void {
  if (buf == 0 as *u8) {
    return;
  }
  if (cap <= 0) {
    return;
  }
  unsafe {
    buf[0] = 0;
  }
  if (module == 0 as *u8) {
    return;
  }
  let path_buf: u8[64] = [];
  unsafe {
    parser_get_module_import_path(module, idx, &path_buf[0]);
  }
  let k: i32 = 0;
  while (k < 64) {
    let ch: u8 = 0;
    unsafe {
      ch = path_buf[k];
    }
    if (ch == 0) {
      break;
    }
    if (k + 1 >= cap) {
      break;
    }
    unsafe {
      buf[k] = ch;
    }
    k = k + 1;
  }
  unsafe {
    buf[k] = 0;
  }
}

/**
 * True if to_load[0..to_load_n) already contains path (C-string eq).
 * @param to_load *u8 — char** queue base as bytes; null → 0
 * @param to_load_n i32 — live count
 * @param path *u8 — candidate C string; null → 0
 * @return i32 — 1 if found, 0 otherwise
 * wave46 pure; used by Cap residual collect enqueue. PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_to_load_has(to_load: *u8, to_load_n: i32, path: *u8): i32 {
  if (to_load == 0 as *u8) {
    return 0;
  }
  if (path == 0 as *u8) {
    return 0;
  }
  if (to_load_n <= 0) {
    return 0;
  }
  let t: i32 = 0;
  while (t < to_load_n) {
    let p: *u8 = pipe_load_ptr_slot(to_load, t);
    if (p != 0 as *u8) {
      if (pipe_cstr_eq(p, path) != 0) {
        return 1;
      }
    }
    t = t + 1;
  }
  return 0;
}

/**
 * Owned C-string copy for collect queue / dep_paths keys (malloc + byte copy + trailing NUL).
 * @param s *u8 — source NUL-terminated C string; null → null
 * @return *u8 — newly owned copy (release with free()); null if s is null or OOM
 * wave54 pure Cap residual thin shell:
 *   null s → null; scan length until NUL; malloc(n+1); copy n bytes + trailing NUL.
 * Do not name this libc strdup — string.h after -E preamble would conflict on the short name.
 * G.7 seed_to_load / enqueue / load_one / paths_process_one call this. PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_strdup(s: *u8): *u8 {
  if (s == 0 as *u8) {
    return 0 as *u8;
  }
  // Count bytes before trailing NUL (same unbounded scan as libc strdup).
  let n: i32 = 0;
  unsafe {
    while (s[n] != 0) {
      n = n + 1;
    }
  }
  let out: *u8 = 0 as *u8;
  unsafe {
    out = malloc((n + 1) as usize);
  }
  if (out == 0 as *u8) {
    return 0 as *u8;
  }
  let i: i32 = 0;
  unsafe {
    while (i < n) {
      out[i] = s[i];
      i = i + 1;
    }
    out[n] = 0;
  }
  return out;
}

/**
 * Seed the collect to_load queue from module direct imports (owned strdup keys).
 * @param module *u8 — opaque AST module; null → empty queue + 0
 * @param to_load *u8 — char** queue base as bytes; null → fail 1
 * @param to_load_n *i32 — out live count; null → fail 1; reset to 0 first
 * @return i32 — 0 success; 1 OOM (queue freed and count cleared)
 * wave47 pure Cap residual: G.7 reuses shux_module_num_imports / import_path_cstr /
 *   pipe_store_ptr_slot; wave54 pure shux_collect_strdup for ownership (free on fail).
 * Slot max = SHUX_DRIVER_DEP_SLOT_MAX (32). PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_seed_to_load(module: *u8, to_load: *u8, to_load_n: *i32): i32 {
  if (to_load == 0 as *u8) {
    return 1;
  }
  if (to_load_n == 0 as *i32) {
    return 1;
  }
  unsafe {
    to_load_n[0] = 0;
  }
  if (module == 0 as *u8) {
    return 0;
  }
  let slot_max: i32 = 32;
  let n_imports: i32 = shux_module_num_imports(module);
  let j: i32 = 0;
  while (j < n_imports) {
    if (j >= slot_max) {
      break;
    }
    let n: i32 = 0;
    unsafe {
      n = to_load_n[0];
    }
    if (n >= slot_max) {
      break;
    }
    let path_c: u8[65] = [];
    shux_module_import_path_cstr(module, j, &path_c[0], 65);
    let owned: *u8 = 0 as *u8;
    unsafe {
      owned = shux_collect_strdup(&path_c[0]);
    }
    if (owned == 0 as *u8) {
      // Free partial queue on OOM (same contract as seed cold twin).
      while (n > 0) {
        n = n - 1;
        let p: *u8 = pipe_load_ptr_slot(to_load, n);
        if (p != 0 as *u8) {
          unsafe {
            free(p);
          }
        }
        pipe_store_ptr_slot(to_load, n, 0 as *u8);
      }
      unsafe {
        to_load_n[0] = 0;
      }
      return 1;
    }
    pipe_store_ptr_slot(to_load, n, owned);
    unsafe {
      to_load_n[0] = n + 1;
    }
    j = j + 1;
  }
  return 0;
}

/**
 * Ensure tmp arena/module, parse prep bytes into them, enqueue sub-imports onto to_load.
 * @param tmp_arena *u8 — void star-star slot for reusable tmp arena; null → no-op
 * @param tmp_module *u8 — void star-star slot for reusable tmp module; null → no-op
 * @param arena_sz i64 — malloc size when *tmp_arena is null; must match ParseInto arena layout
 * @param module_sz i64 — malloc size when first ensuring tmp; must match ParseInto module layout
 * @param prep *u8 — owned prep source bytes (not freed here); null → no-op
 * @param prep_len i64 — byte length of prep
 * @param debug_path *u8 — path key for optional SHUX_DEBUG_PIPE note (cold twin only; pure ignores)
 * @param to_load *u8 — char star-star queue base for sub-import keys
 * @param to_load_n *i32 — live queue count (in/out)
 * @param dep_paths *u8 — already-loaded keys as char star-star; may be null if n_loaded==0
 * @param n_loaded i32 — count of committed dep_paths
 * @return void
 * wave52 pure Cap residual orch:
 *   if *tmp_arena null → malloc arena_sz + module_sz into both slots;
 *   if both live → memset zero, pipeline_parse_into_bytes, G.7 pure enqueue_module_imports.
 *   OOM on malloc: leave null slots and return (same as cold twin skip parse).
 * G.7 process_one / paths_tmp Cap residual call this. PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_tmp_parse_and_enqueue(tmp_arena: *u8, tmp_module: *u8, arena_sz: i64, module_sz: i64, prep: *u8, prep_len: i64, debug_path: *u8, to_load: *u8, to_load_n: *i32, dep_paths: *u8, n_loaded: i32): void {
  if (tmp_arena == 0 as *u8) {
    return;
  }
  if (tmp_module == 0 as *u8) {
    return;
  }
  if (prep == 0 as *u8) {
    return;
  }
  // Silence unused debug_path in pure (cold twin may log under SHUX_DEBUG_PIPE).
  if (debug_path == 0 as *u8) {
  }
  let ta: *u8 = pipe_load_ptr_slot(tmp_arena, 0);
  let tm: *u8 = pipe_load_ptr_slot(tmp_module, 0);
  // First use: allocate both buffers (same order as cold twin).
  if (ta == 0 as *u8) {
    unsafe {
      ta = malloc(arena_sz as usize);
      tm = malloc(module_sz as usize);
    }
    pipe_store_ptr_slot(tmp_arena, 0, ta);
    pipe_store_ptr_slot(tmp_module, 0, tm);
  }
  // Historical: if either buffer missing, skip parse (path already registered upstream).
  if (ta == 0 as *u8) {
    return;
  }
  if (tm == 0 as *u8) {
    return;
  }
  unsafe {
    memset(ta, 0, arena_sz as usize);
    memset(tm, 0, module_sz as usize);
  }
  // ParseIntoResult lives in seed; pure only sees rc (unused beyond call).
  let pr_rc: i32 = 0;
  unsafe {
    pr_rc = pipeline_parse_into_bytes(ta, tm, prep, prep_len);
  }
  if (pr_rc != 0) {
    // Still enqueue whatever imports the partial/failed parse left (same as cold twin).
  }
  shux_collect_enqueue_module_imports(tm, to_load, to_load_n, dep_paths, n_loaded);
}

/**
 * Paths-only shell: ensure tmp, resolve+read+preprocess path_c, parse+enqueue, free prep.
 * Called after paths_process_one has registered the owned dep_paths key.
 * @param path_c *u8 — import key C string (not owned; not freed here); null → fail 1
 * @param lib_roots *u8 — char star-star lib roots; may be null if n_lib_roots==0
 * @param n_lib_roots i32 — lib root count
 * @param entry_dir *u8 — entry directory C string; may be null
 * @param defines *u8 — char star-star define names; may be null if ndefines==0
 * @param ndefines i32 — define count
 * @param tmp_arena *u8 — void star-star tmp arena slot; null → fail 1
 * @param tmp_module *u8 — void star-star tmp module slot; null → fail 1
 * @param arena_sz i64 — malloc size when first ensuring tmp arena
 * @param module_sz i64 — malloc size when first ensuring tmp module
 * @param to_load *u8 — char star-star queue base for sub-import keys
 * @param to_load_n *i32 — live queue count (in/out)
 * @param dep_paths *u8 — already-loaded keys as char star-star
 * @param n_loaded i32 — count of committed dep_paths
 * @return i32 — 0 continue (incl. tmp OOM skip parse); 1 resolve/preprocess fail
 * wave53 pure Cap residual orch:
 *   if *tmp_arena null → malloc arena_sz + module_sz into both slots;
 *   if either buffer missing → return 0 (path already registered upstream; historical);
 *   wave55 pure shux_load_one_direct_resolve_read_preprocess → owned prep;
 *   G.7 pure shux_collect_tmp_parse_and_enqueue; free prep.
 * G.7 paths_process_one calls this. PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_paths_tmp_resolve_parse_enqueue(path_c: *u8, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, tmp_arena: *u8, tmp_module: *u8, arena_sz: i64, module_sz: i64, to_load: *u8, to_load_n: *i32, dep_paths: *u8, n_loaded: i32): i32 {
  if (path_c == 0 as *u8) {
    return 1;
  }
  if (tmp_arena == 0 as *u8) {
    return 1;
  }
  if (tmp_module == 0 as *u8) {
    return 1;
  }
  // Historical early ensure (before resolve): if *tmp_arena null, allocate both.
  let ta: *u8 = pipe_load_ptr_slot(tmp_arena, 0);
  if (ta == 0 as *u8) {
    let tm_new: *u8 = 0 as *u8;
    unsafe {
      ta = malloc(arena_sz as usize);
      tm_new = malloc(module_sz as usize);
    }
    pipe_store_ptr_slot(tmp_arena, 0, ta);
    pipe_store_ptr_slot(tmp_module, 0, tm_new);
  }
  ta = pipe_load_ptr_slot(tmp_arena, 0);
  let tm: *u8 = pipe_load_ptr_slot(tmp_module, 0);
  // Historical: if tmp unavailable, path stays registered and we skip parse (return 0).
  if (ta == 0 as *u8) {
    return 0;
  }
  if (tm == 0 as *u8) {
    return 0;
  }
  // wave55 pure: stack PATH + FILE view + preprocess → owned prep (not stored in dep slots).
  let prep_cell: u8[8] = [];
  let prep_len_cell: u8[8] = [];
  let rc: i32 = 0;
  unsafe {
    rc = shux_load_one_direct_resolve_read_preprocess(lib_roots, n_lib_roots, entry_dir, path_c, defines, ndefines, &prep_cell[0], &prep_len_cell[0]);
  }
  if (rc != 0) {
    return 1;
  }
  let prep: *u8 = pipe_load_ptr_slot(&prep_cell[0], 0);
  let prep_len: i64 = shux_size_slot_get(&prep_len_cell[0], 0);
  // G.7 pure: memset + parse_into_bytes + enqueue (tmp already live from ensure above).
  unsafe {
    shux_collect_tmp_parse_and_enqueue(tmp_arena, tmp_module, arena_sz, module_sz, prep, prep_len, path_c, to_load, to_load_n, dep_paths, n_loaded);
  }
  // prep is owned only by this shell (paths-only does not keep sources); always free.
  if (prep != 0 as *u8) {
    unsafe {
      free(prep);
    }
  }
  return 0;
}

/**
 * Process one owned to_load path into dep_sources/lens/paths and enqueue its sub-imports.
 * @param path_c *u8 — owned C-string import key; consumed (freed) on all return paths
 * @param lib_roots *u8 — char star-star lib roots for resolve; may be null if n_lib_roots==0
 * @param n_lib_roots i32 — lib root count
 * @param entry_dir *u8 — entry directory C string; may be null
 * @param defines *u8 — char star-star define names; may be null if ndefines==0
 * @param ndefines i32 — define count
 * @param dep_sources *u8 — char star-star prep sources; written at slot *n
 * @param dep_lens *u8 — size_t array base as bytes; written at slot *n
 * @param dep_paths *u8 — char star-star owned keys; written at slot *n
 * @param n *i32 — live loaded count (in/out); null → fail 1
 * @param to_load *u8 — char star-star queue base; null → fail 1
 * @param to_load_n *i32 — live queue count (in/out for enqueue); null → fail 1
 * @param tmp_arena *u8 — void star-star tmp arena slot; null → fail 1
 * @param tmp_module *u8 — void star-star tmp module slot; null → fail 1
 * @param arena_sz i64 — malloc size for tmp arena when first needed
 * @param module_sz i64 — malloc size for tmp module when first needed
 * @return i32 — 0 continue; 1 fail (caller cleans queue + partial deps)
 * wave48 pure Cap residual orch:
 *   already-loaded → free path_c + 0;
 *   G.7 load_one_direct_import_at stores prep/path at mi=*n (resolve/read/preprocess Cap);
 *   free path_c; *n = mi+1;
 *   wave52 pure shux_collect_tmp_parse_and_enqueue for parse + enqueue.
 * wave50: called from pure transitive_impl orch. PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_deps_process_one(path_c: *u8, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, n: *i32, to_load: *u8, to_load_n: *i32, tmp_arena: *u8, tmp_module: *u8, arena_sz: i64, module_sz: i64): i32 {
  if (path_c == 0 as *u8) {
    return 1;
  }
  if (n == 0 as *i32) {
    return 1;
  }
  if (to_load == 0 as *u8) {
    return 1;
  }
  if (to_load_n == 0 as *i32) {
    return 1;
  }
  if (tmp_arena == 0 as *u8) {
    return 1;
  }
  if (tmp_module == 0 as *u8) {
    return 1;
  }
  let mi: i32 = 0;
  unsafe {
    mi = n[0];
  }
  // Already loaded: drop owned path and continue (same as cold twin).
  if (shux_find_loaded_import_index(path_c, dep_paths, mi) >= 0) {
    unsafe {
      free(path_c);
    }
    return 0;
  }
  // Cap residual: resolve + read file view + preprocess → dep_sources/lens/paths[mi].
  let rc: i32 = 0;
  unsafe {
    rc = shux_load_one_direct_import_at(lib_roots, n_lib_roots, entry_dir, path_c, defines, ndefines, dep_sources, dep_lens, dep_paths, mi);
  }
  unsafe {
    free(path_c);
  }
  if (rc != 0) {
    return 1;
  }
  let key: *u8 = pipe_load_ptr_slot(dep_paths, mi);
  if (key == 0 as *u8) {
    return 1;
  }
  unsafe {
    n[0] = mi + 1;
  }
  let prep: *u8 = pipe_load_ptr_slot(dep_sources, mi);
  let prep_len: i64 = shux_size_slot_get(dep_lens, mi);
  let n_loaded: i32 = mi + 1;
  unsafe {
    shux_collect_tmp_parse_and_enqueue(tmp_arena, tmp_module, arena_sz, module_sz, prep, prep_len, key, to_load, to_load_n, dep_paths, n_loaded);
  }
  return 0;
}

/**
 * Paths-only process one owned to_load path into dep_paths and enqueue sub-imports.
 * Unlike deps_process_one, does not keep prep sources/lens — only owned path keys.
 * @param path_c *u8 — owned C-string import key; consumed (freed) on all return paths
 * @param lib_roots *u8 — char star-star lib roots for resolve; may be null if n_lib_roots==0
 * @param n_lib_roots i32 — lib root count
 * @param entry_dir *u8 — entry directory C string; may be null
 * @param defines *u8 — char star-star define names; may be null if ndefines==0
 * @param ndefines i32 — define count
 * @param dep_paths *u8 — char star-star owned keys; written at slot *n
 * @param n *i32 — live loaded count (in/out); null → fail 1
 * @param to_load *u8 — char star-star queue base; null → fail 1
 * @param to_load_n *i32 — live queue count (in/out for enqueue); null → fail 1
 * @param tmp_arena *u8 — void star-star tmp arena slot; null → fail 1
 * @param tmp_module *u8 — void star-star tmp module slot; null → fail 1
 * @param arena_sz i64 — malloc size for tmp arena when first needed
 * @param module_sz i64 — malloc size for tmp module when first needed
 * @return i32 — 0 continue; 1 fail (caller cleans queue + partial paths)
 * wave49 pure Cap residual orch:
 *   already-loaded → free path_c + 0;
 *   wave54 pure shux_collect_strdup stores owned key at mi=*n; *n = mi+1;
 *   wave53 pure shux_collect_paths_tmp_resolve_parse_enqueue
 *     (ensure tmp; Cap residual resolve/read/preprocess; G.7 pure tmp_parse; free prep);
 *   free path_c. If tmp malloc fails residual no-ops success (path still registered).
 * wave50: called from pure paths transitive_impl orch. PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_paths_process_one(path_c: *u8, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_paths: *u8, n: *i32, to_load: *u8, to_load_n: *i32, tmp_arena: *u8, tmp_module: *u8, arena_sz: i64, module_sz: i64): i32 {
  if (path_c == 0 as *u8) {
    return 1;
  }
  if (n == 0 as *i32) {
    return 1;
  }
  if (to_load == 0 as *u8) {
    return 1;
  }
  if (to_load_n == 0 as *i32) {
    return 1;
  }
  if (tmp_arena == 0 as *u8) {
    return 1;
  }
  if (tmp_module == 0 as *u8) {
    return 1;
  }
  let mi: i32 = 0;
  unsafe {
    mi = n[0];
  }
  // Already loaded: drop owned path and continue (same as cold twin).
  if (shux_find_loaded_import_index(path_c, dep_paths, mi) >= 0) {
    unsafe {
      free(path_c);
    }
    return 0;
  }
  // Register owned path key before resolve (fail paths leave key for caller cleanup).
  let key: *u8 = 0 as *u8;
  unsafe {
    key = shux_collect_strdup(path_c);
  }
  if (key == 0 as *u8) {
    unsafe {
      free(path_c);
    }
    return 1;
  }
  pipe_store_ptr_slot(dep_paths, mi, key);
  unsafe {
    n[0] = mi + 1;
  }
  let n_loaded: i32 = mi + 1;
  let rc: i32 = 0;
  unsafe {
    rc = shux_collect_paths_tmp_resolve_parse_enqueue(path_c, lib_roots, n_lib_roots, entry_dir, defines, ndefines, tmp_arena, tmp_module, arena_sz, module_sz, to_load, to_load_n, dep_paths, n_loaded);
  }
  unsafe {
    free(path_c);
  }
  return rc;
}

/**
 * Transitive collect of dep sources/lens/paths: seed queue, drain via process_one, free leftovers.
 * @param module *u8 — entry AST module; may be null (seed_to_load then empty)
 * @param arena_sz i64 — tmp arena malloc size for first process_one that needs parse
 * @param module_sz i64 — tmp module malloc size for first process_one that needs parse
 * @param lib_roots *u8 — char star-star lib roots; may be null if n_lib_roots==0
 * @param n_lib_roots i32 — lib root count
 * @param entry_dir *u8 — entry directory C string; may be null
 * @param defines *u8 — char star-star define names; may be null if ndefines==0
 * @param ndefines i32 — define count
 * @param dep_sources *u8 — char star-star prep sources out slots
 * @param dep_lens *u8 — size_t array base as bytes for prep lengths
 * @param dep_paths *u8 — char star-star owned path keys out slots
 * @param n_deps *i32 — out live count; null → fail 1
 * @return i32 — 0 success; 1 fail (partial deps freed; queue/tmp freed)
 * wave50 pure Cap residual orch:
 *   stack char star-star to_load[32] as 256B + two void-star tmp cells as 16B
 *   (G.7 same stack-ptr pattern as check_one_file argv);
 *   G.7 shux_collect_seed_to_load then drain with pure process_one;
 *   success: free remaining queue + tmp, store *n_deps;
 *   fail: free queue + tmp + dep_sources/paths[0..n).
 * Slot max = SHUX_DRIVER_DEP_SLOT_MAX (32). PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_deps_transitive_impl(module: *u8, arena_sz: i64, module_sz: i64, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, n_deps: *i32): i32 {
  if (n_deps == 0 as *i32) {
    return 1;
  }
  // char* to_load[32] as 32×8 pointer slots on stack (LP64).
  let to_load: u8[256] = [];
  let z: i32 = 0;
  while (z < 256) {
    to_load[z] = 0;
    z = z + 1;
  }
  let to_load_n: i32 = 0;
  // void* tmp_arena / tmp_module as two pointer cells (void star-star for process_one).
  let tmp_cells: u8[16] = [];
  z = 0;
  while (z < 16) {
    tmp_cells[z] = 0;
    z = z + 1;
  }
  let n: i32 = 0;
  let slot_max: i32 = 32;
  if (shux_collect_seed_to_load(module, &to_load[0], &to_load_n) != 0) {
    // Fail: free any partial queue (seed_to_load already clears on OOM; still drain).
    while (to_load_n > 0) {
      to_load_n = to_load_n - 1;
      let p: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
      if (p != 0 as *u8) {
        unsafe {
          free(p);
        }
      }
      pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
    }
    return 1;
  }
  while (to_load_n > 0) {
    if (n >= slot_max) {
      break;
    }
    to_load_n = to_load_n - 1;
    let path_c: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
    pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
    let rc: i32 = 0;
    unsafe {
      rc = shux_collect_deps_process_one(path_c, lib_roots, n_lib_roots, entry_dir, defines, ndefines, dep_sources, dep_lens, dep_paths, &n, &to_load[0], &to_load_n, &tmp_cells[0], &tmp_cells[8], arena_sz, module_sz);
    }
    if (rc != 0) {
      // Fail path: free remaining queue, tmp, and partial deps.
      while (to_load_n > 0) {
        to_load_n = to_load_n - 1;
        let p2: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
        if (p2 != 0 as *u8) {
          unsafe {
            free(p2);
          }
        }
        pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
      }
      let ta: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 0);
      let tm: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 1);
      if (ta != 0 as *u8) {
        unsafe {
          free(ta);
        }
      }
      if (tm != 0 as *u8) {
        unsafe {
          free(tm);
        }
      }
      while (n > 0) {
        n = n - 1;
        let s: *u8 = pipe_load_ptr_slot(dep_sources, n);
        let k: *u8 = pipe_load_ptr_slot(dep_paths, n);
        if (s != 0 as *u8) {
          unsafe {
            free(s);
          }
        }
        if (k != 0 as *u8) {
          unsafe {
            free(k);
          }
        }
        pipe_store_ptr_slot(dep_sources, n, 0 as *u8);
        pipe_store_ptr_slot(dep_paths, n, 0 as *u8);
      }
      return 1;
    }
  }
  // Success: free leftover queue entries and tmp arena/module.
  while (to_load_n > 0) {
    to_load_n = to_load_n - 1;
    let p3: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
    if (p3 != 0 as *u8) {
      unsafe {
        free(p3);
      }
    }
    pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
  }
  let ta_ok: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 0);
  let tm_ok: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 1);
  if (ta_ok != 0 as *u8) {
    unsafe {
      free(ta_ok);
    }
  }
  if (tm_ok != 0 as *u8) {
    unsafe {
      free(tm_ok);
    }
  }
  unsafe {
    shux_i32_store(n_deps, n);
  }
  return 0;
}

/**
 * Paths-only transitive collect: seed queue, drain via paths_process_one, free leftovers.
 * @param module *u8 — entry AST module; may be null (seed_to_load then empty)
 * @param arena_sz i64 — tmp arena malloc size for first process_one that needs parse
 * @param module_sz i64 — tmp module malloc size for first process_one that needs parse
 * @param lib_roots *u8 — char star-star lib roots; may be null if n_lib_roots==0
 * @param n_lib_roots i32 — lib root count
 * @param entry_dir *u8 — entry directory C string; may be null
 * @param defines *u8 — char star-star define names; may be null if ndefines==0
 * @param ndefines i32 — define count
 * @param dep_paths *u8 — char star-star owned path keys out slots
 * @param n_deps *i32 — out live count; null → fail 1
 * @return i32 — 0 success; 1 fail (partial paths freed; queue/tmp freed)
 * wave50 pure Cap residual orch: same stack to_load + tmp_cells as deps transitive;
 *   G.7 seed_to_load + pure paths_process_one; fail frees only dep_paths (no sources).
 * Slot max = SHUX_DRIVER_DEP_SLOT_MAX (32). PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_dep_paths_transitive_impl(module: *u8, arena_sz: i64, module_sz: i64, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_paths: *u8, n_deps: *i32): i32 {
  if (n_deps == 0 as *i32) {
    return 1;
  }
  let to_load: u8[256] = [];
  let z: i32 = 0;
  while (z < 256) {
    to_load[z] = 0;
    z = z + 1;
  }
  let to_load_n: i32 = 0;
  let tmp_cells: u8[16] = [];
  z = 0;
  while (z < 16) {
    tmp_cells[z] = 0;
    z = z + 1;
  }
  let n: i32 = 0;
  let slot_max: i32 = 32;
  if (shux_collect_seed_to_load(module, &to_load[0], &to_load_n) != 0) {
    while (to_load_n > 0) {
      to_load_n = to_load_n - 1;
      let p: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
      if (p != 0 as *u8) {
        unsafe {
          free(p);
        }
      }
      pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
    }
    return 1;
  }
  while (to_load_n > 0) {
    if (n >= slot_max) {
      break;
    }
    to_load_n = to_load_n - 1;
    let path_c: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
    pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
    let rc: i32 = 0;
    unsafe {
      rc = shux_collect_paths_process_one(path_c, lib_roots, n_lib_roots, entry_dir, defines, ndefines, dep_paths, &n, &to_load[0], &to_load_n, &tmp_cells[0], &tmp_cells[8], arena_sz, module_sz);
    }
    if (rc != 0) {
      while (to_load_n > 0) {
        to_load_n = to_load_n - 1;
        let p2: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
        if (p2 != 0 as *u8) {
          unsafe {
            free(p2);
          }
        }
        pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
      }
      let ta: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 0);
      let tm: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 1);
      if (ta != 0 as *u8) {
        unsafe {
          free(ta);
        }
      }
      if (tm != 0 as *u8) {
        unsafe {
          free(tm);
        }
      }
      while (n > 0) {
        n = n - 1;
        let k: *u8 = pipe_load_ptr_slot(dep_paths, n);
        if (k != 0 as *u8) {
          unsafe {
            free(k);
          }
        }
        pipe_store_ptr_slot(dep_paths, n, 0 as *u8);
      }
      return 1;
    }
  }
  while (to_load_n > 0) {
    to_load_n = to_load_n - 1;
    let p3: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
    if (p3 != 0 as *u8) {
      unsafe {
        free(p3);
      }
    }
    pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
  }
  let ta_ok: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 0);
  let tm_ok: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 1);
  if (ta_ok != 0 as *u8) {
    unsafe {
      free(ta_ok);
    }
  }
  if (tm_ok != 0 as *u8) {
    unsafe {
      free(tm_ok);
    }
  }
  unsafe {
    shux_i32_store(n_deps, n);
  }
  return 0;
}

/**
 * Enqueue sub-imports from a parsed tmp_module into to_load (skip loaded / already queued).
 * @param tmp_module *u8 — parsed dep module; null → no-op
 * @param to_load *u8 — char** queue base; null → no-op
 * @param to_load_n *i32 — live queue count (in/out); null → no-op
 * @param dep_paths *u8 — already-loaded import keys as char star-star; may be null if n_loaded==0
 * @param n_loaded i32 — count of dep_paths already committed
 * @return void
 * wave47 pure Cap residual: G.7 reuses module_num_imports / import_path_cstr /
 *   shux_find_loaded_import_index / shux_collect_to_load_has / pipe slots;
 *   wave54 pure shux_collect_strdup.
 * OOM on one strdup: skip that import (same as cold twin continue). PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_enqueue_module_imports(tmp_module: *u8, to_load: *u8, to_load_n: *i32, dep_paths: *u8, n_loaded: i32): void {
  if (tmp_module == 0 as *u8) {
    return;
  }
  if (to_load == 0 as *u8) {
    return;
  }
  if (to_load_n == 0 as *i32) {
    return;
  }
  let slot_max: i32 = 32;
  let n_imp: i32 = 0;
  unsafe {
    n_imp = parser_get_module_num_imports(tmp_module);
  }
  if (n_imp <= 0) {
    return;
  }
  let jj: i32 = 0;
  while (jj < n_imp) {
    if (jj >= slot_max) {
      break;
    }
    let n: i32 = 0;
    unsafe {
      n = to_load_n[0];
    }
    if (n >= slot_max) {
      break;
    }
    let sub_c: u8[65] = [];
    shux_module_import_path_cstr(tmp_module, jj, &sub_c[0], 65);
    // Skip if already loaded or already queued.
    if (shux_find_loaded_import_index(&sub_c[0], dep_paths, n_loaded) >= 0) {
      jj = jj + 1;
      continue;
    }
    if (shux_collect_to_load_has(to_load, n, &sub_c[0]) != 0) {
      jj = jj + 1;
      continue;
    }
    let owned: *u8 = 0 as *u8;
    unsafe {
      owned = shux_collect_strdup(&sub_c[0]);
    }
    if (owned == 0 as *u8) {
      jj = jj + 1;
      continue;
    }
    pipe_store_ptr_slot(to_load, n, owned);
    unsafe {
      to_load_n[0] = n + 1;
    }
    jj = jj + 1;
  }
}

/**
 * Map preprocess_x_buf negative directive codes to fixed diag strings (PP002).
 * @param path_diag *u8 — path for report; may be null
 * @param code i32 — negative directive fail code (-2..-7 known; else generic fail)
 * @return void
 * wave46 pure: fixed msgs via stack byte lits + diag_report_with_code (no va_list).
 * PLATFORM: SHARED — Cap residual was always-seed; hybrid pure authority.
 */
#[no_mangle]
export function pipeline_diag_preprocess_directive_code(path_diag: *u8, code: i32): void {
  // Known codes -2..-7; anything else → generic preprocess fail.
  if (code != (0 - 2)) {
    if (code != (0 - 3)) {
      if (code != (0 - 4)) {
        if (code != (0 - 5)) {
          if (code != (0 - 6)) {
            if (code != (0 - 7)) {
              pipeline_diag_preprocess_fail(path_diag);
              return;
            }
          }
        }
      }
    }
  }
  pipeline_diag_emitted_note();
  let kind: u8[24] = [];
  let dcode: u8[8] = [];
  // "preprocess error"
  kind[0] = 112; kind[1] = 114; kind[2] = 101; kind[3] = 112;
  kind[4] = 114; kind[5] = 111; kind[6] = 99; kind[7] = 101;
  kind[8] = 115; kind[9] = 115; kind[10] = 32; kind[11] = 101;
  kind[12] = 114; kind[13] = 114; kind[14] = 111; kind[15] = 114; kind[16] = 0;
  // "PP002"
  dcode[0] = 80; dcode[1] = 80; dcode[2] = 48; dcode[3] = 48; dcode[4] = 50; dcode[5] = 0;
  let msg: u8[32] = [];
  // Fill msg by code (ASCII byte tables; keep under ~63 lit cap).
  if (code == (0 - 2)) {
    // "#else without #if"
    msg[0] = 35; msg[1] = 101; msg[2] = 108; msg[3] = 115; msg[4] = 101;
    msg[5] = 32; msg[6] = 119; msg[7] = 105; msg[8] = 116; msg[9] = 104;
    msg[10] = 111; msg[11] = 117; msg[12] = 116; msg[13] = 32; msg[14] = 35;
    msg[15] = 105; msg[16] = 102; msg[17] = 0;
  } else if (code == (0 - 3)) {
    // "#endif without #if"
    msg[0] = 35; msg[1] = 101; msg[2] = 110; msg[3] = 100; msg[4] = 105;
    msg[5] = 102; msg[6] = 32; msg[7] = 119; msg[8] = 105; msg[9] = 116;
    msg[10] = 104; msg[11] = 111; msg[12] = 117; msg[13] = 116; msg[14] = 32;
    msg[15] = 35; msg[16] = 105; msg[17] = 102; msg[18] = 0;
  } else if (code == (0 - 4)) {
    // "#elseif without #if"
    msg[0] = 35; msg[1] = 101; msg[2] = 108; msg[3] = 115; msg[4] = 101;
    msg[5] = 105; msg[6] = 102; msg[7] = 32; msg[8] = 119; msg[9] = 105;
    msg[10] = 116; msg[11] = 104; msg[12] = 111; msg[13] = 117; msg[14] = 116;
    msg[15] = 32; msg[16] = 35; msg[17] = 105; msg[18] = 102; msg[19] = 0;
  } else if (code == (0 - 5)) {
    // "#elseif after #else"
    msg[0] = 35; msg[1] = 101; msg[2] = 108; msg[3] = 115; msg[4] = 101;
    msg[5] = 105; msg[6] = 102; msg[7] = 32; msg[8] = 97; msg[9] = 102;
    msg[10] = 116; msg[11] = 101; msg[12] = 114; msg[13] = 32; msg[14] = 35;
    msg[15] = 101; msg[16] = 108; msg[17] = 115; msg[18] = 101; msg[19] = 0;
  } else if (code == (0 - 6)) {
    // "duplicate #else"
    msg[0] = 100; msg[1] = 117; msg[2] = 112; msg[3] = 108; msg[4] = 105;
    msg[5] = 99; msg[6] = 97; msg[7] = 116; msg[8] = 101; msg[9] = 32;
    msg[10] = 35; msg[11] = 101; msg[12] = 108; msg[13] = 115; msg[14] = 101;
    msg[15] = 0;
  } else {
    // code == -7: "#if nesting too deep"
    msg[0] = 35; msg[1] = 105; msg[2] = 102; msg[3] = 32; msg[4] = 110;
    msg[5] = 101; msg[6] = 115; msg[7] = 116; msg[8] = 105; msg[9] = 110;
    msg[10] = 103; msg[11] = 32; msg[12] = 116; msg[13] = 111; msg[14] = 111;
    msg[15] = 32; msg[16] = 100; msg[17] = 101; msg[18] = 101; msg[19] = 112;
    msg[20] = 0;
  }
  unsafe {
    diag_report_with_code(path_diag, 0, 0, &kind[0], &dcode[0], &msg[0], 0 as *u8);
  }
}

// shux_dep_prerun_entry_dir_pick: see function docblock below.
/** Exported function `shux_dep_prerun_entry_dir_pick`.
 * Implements `shux_dep_prerun_entry_dir_pick`.
 * @param main_entry_dir *u8
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @return *u8
 */
#[no_mangle]
export function shux_dep_prerun_entry_dir_pick(main_entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): *u8 {
  if (lib_roots == 0 as *u8) { return main_entry_dir; }
  if (n_lib_roots <= 0) { return main_entry_dir; }
  unsafe {
    let r0: *u8 = pipe_load_ptr_slot(lib_roots, 0);
    if (r0 != 0 as *u8) {
      if (r0[0] != 0) { return r0; }
    }
  }
  return main_entry_dir;
}

/** Exported function `shux_find_loaded_import_index_scan`.
 * Implements `shux_find_loaded_import_index_scan`.
 * @param path *u8
 * @param all_paths *u8
 * @param n_all i32
 * @return i32
 */
#[no_mangle]
export function shux_find_loaded_import_index_scan(path: *u8, all_paths: *u8, n_all: i32): i32 {
  if (path == 0 as *u8) { return 0 - 1; }
  if (all_paths == 0 as *u8) { return 0 - 1; }
  if (n_all <= 0) { return 0 - 1; }
  let i: i32 = 0;
  while (i < n_all) {
    let p: *u8 = pipe_load_ptr_slot(all_paths, i);
    if (p != 0) {
      if (pipe_cstr_eq(p, path) != 0) { return i; }
    }
    i = i + 1;
  }
  return 0 - 1;
}

/** Exported function `shux_merge_deps_path_already_out_scan`.
 * Read path helper `shux_merge_deps_path_already_out_scan`.
 * @param path *u8
 * @param out_paths *u8
 * @param n_out i32
 * @return i32
 */
#[no_mangle]
export function shux_merge_deps_path_already_out_scan(path: *u8, out_paths: *u8, n_out: i32): i32 {
  if (path == 0 as *u8) { return 0; }
  if (out_paths == 0 as *u8) { return 0; }
  if (n_out <= 0) { return 0; }
  let j: i32 = 0;
  while (j < n_out) {
    let p: *u8 = pipe_load_ptr_slot(out_paths, j);
    if (p != 0) {
      if (pipe_cstr_eq(p, path) != 0) { return 1; }
    }
    j = j + 1;
  }
  return 0;
}

/* See implementation. */

// shux_pipeline_pctx_update_dep_slots_no_reset: see function docblock below.
/** Exported function `shux_pipeline_pctx_update_dep_slots_no_reset`.
 * Implements `shux_pipeline_pctx_update_dep_slots_no_reset`.
 * @param ctx *u8
 * @param dep_mods *u8
 * @param dep_ars *u8
 * @param import_paths *u8
 * @param n i32
 * @return void
 */
#[no_mangle]
export function shux_pipeline_pctx_update_dep_slots_no_reset(ctx: *u8, dep_mods: *u8, dep_ars: *u8, import_paths: *u8, n: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      let m: *u8 = 0 as *u8;
      let a: *u8 = 0 as *u8;
      if (dep_mods != 0 as *u8) {
        m = pipe_load_ptr_slot(dep_mods, i);
      }
      if (dep_ars != 0 as *u8) {
        a = pipe_load_ptr_slot(dep_ars, i);
      }
      ast_pipeline_dep_ctx_set_module(ctx, i, m);
      ast_pipeline_dep_ctx_set_arena(ctx, i, a);
      if (import_paths != 0 as *u8) {
        let p: *u8 = pipe_load_ptr_slot(import_paths, i);
        if (p != 0 as *u8) {
          let pl: i32 = pipe_cstr_len(p);
          ast_pipeline_dep_ctx_set_import_path(ctx, i, p, pl);
        }
      }
    }
    i = i + 1;
  }
  unsafe {
    ast_pipeline_dep_ctx_set_ndep(ctx, n);
  }
}



/* ---- G-02f-95 / G-02f-241 / wave56: pipeline large-stack thread fns pure ---- */

/**
 * pthread entry body: run pipeline_run_x_pipeline and store ec into args.result.
 * @param arg *u8 — PipelineRunSuArgs LP64 pack (56B):
 *   module@0 arena@8 source_data@16 source_len@24 out_buf@32 ctx@40 result@48;
 *   null → return null
 * @return *u8 — always null (pthread start_routine contract)
 * wave56 pure Cap residual:
 *   load pack fields via pipe/size slots; driver_set_pipeline_entry_source_len;
 *   pipeline_run_x_pipeline; store result as LE i64 cell at slot 6 (i32@48 + pad).
 * SHUX_DEBUG_PIPE start/done notes stay cold-twin only (pure skips; same as tmp_parse).
 * PLATFORM: SHARED LP64 little-endian.
 */
#[no_mangle]
export function pipeline_run_x_thread_fn_impl(arg: *u8): *u8 {
  if (arg == 0 as *u8) {
    return 0 as *u8;
  }
  let module: *u8 = pipe_load_ptr_slot(arg, 0);
  let arena: *u8 = pipe_load_ptr_slot(arg, 1);
  let source_data: *u8 = pipe_load_ptr_slot(arg, 2);
  let source_len: i64 = shux_size_slot_get(arg, 3);
  let out_buf: *u8 = pipe_load_ptr_slot(arg, 4);
  let ctx: *u8 = pipe_load_ptr_slot(arg, 5);
  unsafe {
    driver_set_pipeline_entry_source_len(source_len);
  }
  let ec: i32 = 0;
  unsafe {
    ec = pipeline_run_x_pipeline(module, arena, source_data, source_len, out_buf, ctx);
  }
  // result i32 lives at byte 48 = slot index 6; write full LE cell (pad ok).
  shux_size_slot_set(arg, 6, ec as i64);
  return 0 as *u8;
}

/**
 * Thin pthread entry for large-stack pipeline_run_x_pipeline (null reject).
 * @param arg *u8 — PipelineRunSuArgs pack; null → null
 * @return *u8 — always null
 * wave56: forwards to pure pipeline_run_x_thread_fn_impl.
 * PLATFORM: SHARED — address taken by always-seed pipeline_run_x_thread_fn_ptr.
 */
#[no_mangle]
export function pipeline_run_x_thread_fn(arg: *u8): *u8 {
  if (arg == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    return pipeline_run_x_thread_fn_impl(arg);
  }
  return 0 as *u8;
}

/**
 * Large-stack orch: pack PipelineRunSuArgs, run thread_fn via Cap-fn-ptr, fallback current thread.
 * @param module *u8 — AST module (caller thin already null-checked)
 * @param arena *u8 — AST arena
 * @param source_data *u8 — source bytes
 * @param source_len i64 — byte length
 * @param out_buf *u8 — codegen out buffer
 * @param ctx *u8 — PipelineDepCtx
 * @return i32 — pipeline ec; fallback path if result still sentinel -99
 * wave56 pure Cap residual:
 *   stack args[56] zeroed; set entry source_len; fill pack; result sentinel -99;
 *   Cap-fn-ptr pipeline_run_x_thread_fn_ptr + G.7 driver_run_thread_on_large_stack;
 *   if result still -99 → direct pipeline_run_x_pipeline (pthread create failed / skipped).
 * PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function shux_pipeline_run_x_pipeline_large_stack_impl(module: *u8, arena: *u8, source_data: *u8, source_len: i64, out_buf: *u8, ctx: *u8): i32 {
  let args: u8[56] = [];
  let zi: i32 = 0;
  while (zi < 56) {
    args[zi] = 0;
    zi = zi + 1;
  }
  unsafe {
    driver_set_pipeline_entry_source_len(source_len);
  }
  pipe_store_ptr_slot(&args[0], 0, module);
  pipe_store_ptr_slot(&args[0], 1, arena);
  pipe_store_ptr_slot(&args[0], 2, source_data);
  shux_size_slot_set(&args[0], 3, source_len);
  pipe_store_ptr_slot(&args[0], 4, out_buf);
  pipe_store_ptr_slot(&args[0], 5, ctx);
  // Sentinel -99: thread_fn overwrites on success; unchanged → current-thread fallback.
  shux_size_slot_set(&args[0], 6, 0 - 99);
  let fn: *u8 = 0 as *u8;
  unsafe {
    fn = pipeline_run_x_thread_fn_ptr();
  }
  if (fn != 0 as *u8) {
    unsafe {
      driver_run_thread_on_large_stack(fn, &args[0]);
    }
  }
  let result: i64 = shux_size_slot_get(&args[0], 6);
  if (result == (0 - 99) as i64) {
    unsafe {
      return pipeline_run_x_pipeline(module, arena, source_data, source_len, out_buf, ctx);
    }
  }
  return result as i32;
}

// shux_asm_codegen_elf_o_thread_fn: see function docblock below.
/**
 * Thin pthread entry for large-stack asm emit (null reject).
 * @param arg *u8 — AsmElfLargeArgs pack; null → null
 * @return *u8 — always null
 * wave57: forwards to pure shux_asm_codegen_elf_o_thread_fn_impl.
 * PLATFORM: SHARED — address taken by always-seed shux_asm_codegen_elf_o_thread_fn_ptr.
 */
#[no_mangle]
export function shux_asm_codegen_elf_o_thread_fn(arg: *u8): *u8 {
  if (arg == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    return shux_asm_codegen_elf_o_thread_fn_impl(arg);
  }
  return 0 as *u8;
}

/**
 * Pthread body: unpack AsmElfLargeArgs, Cap residual product emit, store result.
 * @param arg *u8 — AsmElfLargeArgs LP64 pack (48B):
 *   module@0 arena@8 ctx@16 elf_ctx@24 out_buf@32 result@40;
 *   null → return null
 * @return *u8 — always null (pthread start_routine contract)
 * wave57 pure Cap residual orch; wave80 product_emit is pure G.7 thin (bridge reloc).
 *   load pack via pipe/size slots; G.7 pure shux_asm_codegen_elf_o_product_emit;
 *   store result as LE i64 cell at slot 5 (i32@40 + pad).
 * PLATFORM: SHARED LP64 little-endian.
 */
#[no_mangle]
export function shux_asm_codegen_elf_o_thread_fn_impl(arg: *u8): *u8 {
  if (arg == 0 as *u8) {
    return 0 as *u8;
  }
  let module: *u8 = pipe_load_ptr_slot(arg, 0);
  let arena: *u8 = pipe_load_ptr_slot(arg, 1);
  let ctx: *u8 = pipe_load_ptr_slot(arg, 2);
  let elf_ctx: *u8 = pipe_load_ptr_slot(arg, 3);
  let out_buf: *u8 = pipe_load_ptr_slot(arg, 4);
  let ec: i32 = 0;
  unsafe {
    ec = shux_asm_codegen_elf_o_product_emit(module, arena, ctx, elf_ctx, out_buf);
  }
  // result i32 lives at byte 40 = slot index 5; write full LE cell (pad ok).
  shux_size_slot_set(arg, 5, ec as i64);
  return 0 as *u8;
}

/**
 * Large-stack orch: pack AsmElfLargeArgs, run thread_fn via Cap-fn-ptr, fallback emit.
 * @param module *u8 — AST module (caller thin already null-checked)
 * @param arena *u8 — AST arena
 * @param ctx *u8 — PipelineDepCtx
 * @param elf_ctx *u8 — ElfCodegenCtx
 * @param out_buf *u8 — emit out buffer
 * @return i32 — emit ec; fallback path if result still sentinel -99
 * wave57 pure Cap residual orch; wave80 product_emit pure thin:
 *   stack args[48] zeroed; fill pack; result sentinel -99;
 *   Cap-fn-ptr shux_asm_codegen_elf_o_thread_fn_ptr + G.7 driver_run_thread_on_large_stack;
 *   if result still -99 → G.7 pure product_emit (pthread create failed / skipped).
 * PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function shux_asm_codegen_elf_o_large_stack_impl(module: *u8, arena: *u8, ctx: *u8, elf_ctx: *u8, out_buf: *u8): i32 {
  let args: u8[48] = [];
  let zi: i32 = 0;
  while (zi < 48) {
    args[zi] = 0;
    zi = zi + 1;
  }
  pipe_store_ptr_slot(&args[0], 0, module);
  pipe_store_ptr_slot(&args[0], 1, arena);
  pipe_store_ptr_slot(&args[0], 2, ctx);
  pipe_store_ptr_slot(&args[0], 3, elf_ctx);
  pipe_store_ptr_slot(&args[0], 4, out_buf);
  // Sentinel -99: thread_fn overwrites on success; unchanged → current-thread fallback.
  shux_size_slot_set(&args[0], 5, 0 - 99);
  let fn: *u8 = 0 as *u8;
  unsafe {
    fn = shux_asm_codegen_elf_o_thread_fn_ptr();
  }
  if (fn != 0 as *u8) {
    unsafe {
      driver_run_thread_on_large_stack(fn, &args[0]);
    }
  }
  let result: i64 = shux_size_slot_get(&args[0], 5);
  if (result == (0 - 99) as i64) {
    unsafe {
      return shux_asm_codegen_elf_o_product_emit(module, arena, ctx, elf_ctx, out_buf);
    }
  }
  return result as i32;
}

// See implementation.

export extern "C" function getenv(name: *u8): *u8;

/** Exported function `pipeline_asm_debug_enabled`.
 * Implements `pipeline_asm_debug_enabled`.
 * @return i32
 */
#[no_mangle]
export function pipeline_asm_debug_enabled(): i32 {
  unsafe {
    let e: *u8 = getenv("SHUX_ASM_DEBUG");
    if (e != 0) { return 1; }
  }
  return 0;
}

// pipeline_debug_body_func_match: see function docblock below.

/** Exported function `pipeline_debug_body_func_match`.
 * Implements `pipeline_debug_body_func_match`.
 * @param filter *u8
 * @param name *u8
 * @return i32
 */
#[no_mangle]
export function pipeline_debug_body_func_match(filter: *u8, name: *u8): i32 {
  if (filter == 0) { return 0; }
  if (filter[0] == 0) { return 0; }
  if (filter[0] == 48) { return 0; } // '0'
  if (name == 0) { return 0; }
  if (name[0] == 0) { return 0; }
  // name_len
  let name_len: i32 = 0;
  while (name_len < 512) {
    if (name[name_len] == 0) { break; }
    name_len = name_len + 1;
  }
  let p: i32 = 0;
  while (p < 4096) {
    let c: u8 = filter[p];
    if (c == 0) { break; }
    // skip spaces/tabs/commas
    while (p < 4096) {
      c = filter[p];
      if (c == 0) { break; }
      if (c == 32) { p = p + 1; continue; }
      if (c == 9) { p = p + 1; continue; }
      if (c == 44) { p = p + 1; continue; }
      break;
    }
    c = filter[p];
    if (c == 0) { break; }
    let start: i32 = p;
    while (p < 4096) {
      c = filter[p];
      if (c == 0) { break; }
      if (c == 44) { break; }
      p = p + 1;
    }
    let end: i32 = p;
    // trim trailing space/tab
    while (end > start) {
      let pc: u8 = filter[end - 1];
      if (pc == 32) { end = end - 1; continue; }
      if (pc == 9) { end = end - 1; continue; }
      break;
    }
    let tok_len: i32 = end - start;
    if (tok_len > 0) {
      if (tok_len == name_len) {
        let k: i32 = 0;
        let eq: i32 = 1;
        while (k < tok_len) {
          if (filter[start + k] != name[k]) { eq = 0; break; }
          k = k + 1;
        }
        if (eq != 0) { return 1; }
      }
    }
  }
  return 0;
}

