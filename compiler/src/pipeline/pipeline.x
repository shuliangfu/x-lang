// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// Historical pipeline.x was a pure-extern-signature declaration module — 162
// export extern function signatures with ZERO function bodies; all
// implementations live in runtime_pipeline_abi.x (pipeline_gen.x chain).
// Before wave335, six DEAD import() statements were left-over placeholders:
//   import("ast"/"lexer"/"parser"/"typeck"/"codegen"/"asm.backend")
// The imported modules were NEVER referenced (grep word-count == 1 per
// module — only the import line itself; typeck had 2 more matches inside
// docblock comments; preprocess had 0 functional refs). These dead imports
// caused severe -E expansion pathological cost: 658 LOC pipeline.x → 46.62s
// / 795 KB output because -E transitively expanded parser (12176 LOC) + typeck
// (19542) + codegen (21922) + asm_backend + their dependencies → 50K+ LOC
// extra with O(n²) transitive-module-declaration-duplication cost.
//
// G.7 SINGLE AUTHORITY FIX (root cause, not symptom): REMOVE ALL DEAD IMPORTS
// (0 imports remain). Pure extern signature modules MUST NOT depend on
// front-end heavy modules (they declare FFI signatures only; actual symbols
// resolve at link-time against runtime_pipeline_abi). Semantically,
// removing dead imports is behaviour-preserving — import() produces a value
// that is never assigned nor dereferenced.
//
// Verified baseline: 6 dead imports → -E 46.62s / 795 KB output
// After fix (0 imports):   -E 5.85s / 96 KB output (≈ 8× faster & smaller).
//
// PLATFORM: SHARED (freestanding extern header; no platform deps).

/* See implementation. */
export extern function driver_dep_arena_buf(i: i32): *u8;
export extern function driver_dep_module_buf(i: i32): *u8;
/* See implementation. */
export extern function driver_dep_seeded_get(i: i32): i32;
/* See implementation. */
export extern function driver_dep_slot_for_path(path: *u8): i32;
/* See implementation. */
export extern function get_ndep(): i32;
/* See implementation. */
export extern function pipeline_driver_asm_build_skip_typeck(): i32;
/* See implementation. */
export extern function pipeline_driver_x_pipeline_skip_typeck(): i32;

/**
 * Skip .x typeck gate — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_should_skip_x_typeck`
 * (thin→should_skip_x_typeck_c). Historical pipeline.x body was XLANG_LIB_WEAK residual.
 * G.7 dual-export ban.
 * @param ctx *PipelineDepCtx — dep ctx
 * @return i32 — 1 skip; 0 run
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function pipeline_should_skip_x_typeck(ctx: *PipelineDepCtx): i32;

/* See implementation. */
export extern function parser_parse_one_function_ok_for_pipeline_buf_glue(arena: *ASTArena, data: *u8, len: i32): i32;
export extern function ast_ast_arena_init(arena: *ASTArena): void;
export extern function asm_asm_codegen_ast(module: *Module, arena: *ASTArena, out_buf: *CodegenOutBuf, ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function pipeline_copy_lib_root_to_buf256(ctx: *PipelineDepCtx, lib_idx: i32, dst: *u8): i32;
/* See implementation. */
export extern function preprocess_x_buf(source_buf: *u8, source_len: isize, out_buf: *u8, out_cap: i32): i32;
/* See implementation. */
export extern function pipeline_dep_ctx_set_path_buf_byte(ctx: *PipelineDepCtx, off: i32, b: u8): void;
export extern function pipeline_dep_ctx_path_buf_ptr(ctx: *PipelineDepCtx): *u8;
export extern function pipeline_dep_ctx_entry_dir_len(ctx: *PipelineDepCtx): i32;
export extern function pipeline_dep_ctx_entry_dir_copy(ctx: *PipelineDepCtx, dst: *u8, cap: i32): void;
export extern function pipeline_dep_ctx_asm_entry_module_only(ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function pipeline_dep_ctx_use_asm_backend(ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function pipeline_dep_ctx_loaded_buf_ptr(ctx: *PipelineDepCtx): *u8;
export extern function pipeline_dep_ctx_set_loaded_len(ctx: *PipelineDepCtx, n: isize): void;
/* See implementation. */
export extern function pipeline_ctx_lib_root_count(ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern "C" function fs_posix_read_c(fd: i32, buf: *u8, count: usize): isize;
export extern "C" function fs_posix_close_c(fd: i32): i32;
/* See implementation. */
export extern function run_x_pipeline_last_rc_get(): i32;
export extern function run_x_pipeline_last_rc_store_c(rc: i32): void;
export extern function pipeline_typeck_fail_return_c(fail_mapped: i32): i32;
export extern function pipeline_typeck_null_fail_return_c(fail_mapped: i32): i32;
export extern function run_x_pipeline_load_deps_after_parse_c(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32;
export extern function run_x_pipeline_typecheck_after_load_c(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32;

/* See implementation. */
export extern function pipeline_module_set_main_func_index(module: *Module, main_idx: i32): void;
export extern function pipeline_module_main_func_index(module: *Module): i32;

/* See implementation. */
export extern function pipeline_arena_num_types(arena: *ASTArena): i32;

/* See implementation. */
export extern function pipeline_parse_into_with_init_buf_scalars_sidecar(arena: *ASTArena, module: *Module, data: *u8, len: i32): i32;
export extern function pipeline_parse_scalars_ok_get(): i32;
export extern function pipeline_parse_scalars_main_idx_get(): i32;
/* See implementation. */
export extern function pipeline_parse_fail_diag_scalars_c(module: *Module, arena: *ASTArena): void;
export extern function pipeline_parse_apply_main_from_scalars_c(module: *Module, arena: *ASTArena): i32;
export extern function pipeline_parse_set_main_from_buf_c(module: *Module, arena: *ASTArena, data: *u8, len: i32): i32;
export extern function pipeline_typeck_parsed_module_c(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx, fail_mapped: i32): i32;
export extern function pipeline_typeck_entry_module_c(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32;
export extern function pipeline_typeck_after_parse_ok_buf_impl_c(arena: *ASTArena, module: *Module, data: *u8, len: i32, ctx: *PipelineDepCtx): i32;
export extern function pipeline_load_import_resolve_read_c(module: *Module, ctx: *PipelineDepCtx, import_idx: i32): i32;
export extern function pipeline_load_import_from_disk_impl_c(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx, import_idx: i32): i32;
export extern function pipeline_load_one_import_slot_c(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx, import_idx: i32): i32;
export extern function pipeline_sync_dep_slots_from_driver_impl_c(module: *Module, ctx: *PipelineDepCtx): i32;
export extern function pipeline_dep_ctx_realign_ndep_for_entry_c(module: *Module, ctx: *PipelineDepCtx): void;
export extern function pipeline_load_and_sync_direct_import_deps_c(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32;
export extern function lsp_diag_typeck_after_load_c(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32;
export extern function lsp_diag_parse_typeck_buf_c(module: *Module, arena: *ASTArena, source_data: *u8, source_len: i32, ctx: *PipelineDepCtx): i32;
export extern function pipeline_parse_into_with_init_result_c(): ParseIntoResult;
/* See implementation. */
export extern function pipeline_parse_into_with_init_buf_impl_c(arena: *ASTArena, module: *Module, data: *u8, len: i32): ParseIntoResult;
/* See implementation. */
export extern function run_x_pipeline_parse_entry_do_parse_c(module: *Module, arena: *ASTArena, source_data: *u8, source_len: usize, ctx: *PipelineDepCtx): i32;
export extern function run_x_pipeline_parse_entry_if_needed_c(module: *Module, arena: *ASTArena, source_data: *u8, source_len: usize, ctx: *PipelineDepCtx): i32;
export extern function run_x_pipeline_typecheck_entry_emit_c(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32;
export extern function run_x_pipeline_fill_dep_import_path_c(module: *Module, ctx: *PipelineDepCtx, dep_j: i32): i32;
/* See implementation. */
export extern function pipeline_fill_dep_import_path_from_buf_c(ctx: *PipelineDepCtx, dep_j: i32, path_buf: *u8): i32;
/* See implementation. */
export extern function pipeline_resolve_path_x_from_buf64_c(ctx: *PipelineDepCtx, path_buf: *u8): i32;
export extern function pipeline_prepare_dep_codegen_path_c(ctx: *PipelineDepCtx, dep_j: i32, dst: *u8): i32;
export extern function pipeline_finish_dep_codegen_diag_c(dep_j: i32, out_buf: *CodegenOutBuf): i32;
export extern function run_x_pipeline_codegen_one_dep_prepare_c(ctx: *PipelineDepCtx, dep_j: i32): i32;
/* See implementation. */
export extern function pipeline_loop_should_continue_ndep_c(ctx: *PipelineDepCtx, idx: i32): i32;
export extern function pipeline_loop_should_continue_imports_c(module: *Module, idx: i32): i32;
/* See implementation. */
export extern function pipeline_loop_should_continue_lib_root_c(ctx: *PipelineDepCtx, idx: i32): i32;
/* See implementation. */
export extern function pipeline_resolve_path_last_off_get_c(): i32;
export extern function pipeline_resolve_path_lib_root_prefix_off_c(ctx: *PipelineDepCtx, lib_idx: i32): i32;
export extern function pipeline_path_append_import_path_sidecar_c(ctx: *PipelineDepCtx, off: i32, import_path: *u8, path_len: i32): i32;
export extern function pipeline_resolve_path_entry_dir_prefix_off_c(ctx: *PipelineDepCtx): i32;
export extern function pipeline_flat_import_build_path_c(ctx: *PipelineDepCtx, lib_idx: i32, import_path: *u8, path_len: i32): i32;
export extern function pipeline_flat_import_probe_open_c(ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function pipeline_loop_index_at_or_beyond_ndep_c(ctx: *PipelineDepCtx, idx: i32): i32;
export extern function pipeline_loop_index_at_or_beyond_imports_c(module: *Module, idx: i32): i32;
export extern function pipeline_load_and_sync_set_ndep_from_module_c(module: *Module, ctx: *PipelineDepCtx): void;
export extern function run_x_pipeline_codegen_deps_c(module: *Module, arena: *ASTArena, out_buf: *CodegenOutBuf, ctx: *PipelineDepCtx, skip_asm_dep_codegen: i32): i32;
export extern function run_x_pipeline_codegen_entry_c(module: *Module, arena: *ASTArena, out_buf: *CodegenOutBuf, ctx: *PipelineDepCtx): i32;

/* See implementation. */
export extern function pipeline_strict_parse_into_init(arena: *ASTArena, module: *Module): void;

/* See implementation. */
export extern function parser_parse_into_init(module: *Module, arena: *ASTArena): void;
export extern function parser_parse_into_buf(arena: *ASTArena, module: *Module, data: *u8, len: i32): ParseIntoResult;
export extern function pipeline_parse_into_buf_c(arena: *ASTArena, module: *Module, buf: *u8, buf_len: i32): i32;

/**
 * Parse buffer into module — dual-export leave wave305.
 * Live authority: runtime_pipeline_abi pure `pipeline_parse_into_buf` (full body;
 * trait reset + parse_into_init + driver_parse_into_buf_rc + stmt_order fixup).
 * Historical pipeline.x body was XLANG_LIB_WEAK thin→pipeline_parse_into_buf_c only;
 * product link already preferred pure/seed. G.7 dual-export ban: no second T/W.
 * @param arena *ASTArena — AST arena; null rejected by pure
 * @param module *Module — destination module; null rejected by pure
 * @param buf *u8 — source bytes
 * @param buf_len i32 — length; <=0 → -1 on pure
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding 8.3 pipeline.x thin residual dual leave.
 */
export extern function pipeline_parse_into_buf(arena: *ASTArena, module: *Module, buf: *u8, buf_len: i32): i32;

/* See implementation. */
export extern function pipeline_path_append_from_buf_256_c(ctx: *PipelineDepCtx, off: i32, buf: *u8, len: i32): i32;
export extern function pipeline_path_append_from_buf_512_c(ctx: *PipelineDepCtx, off: i32, buf: *u8, len: i32): i32;
export extern function pipeline_path_append_import_path_c(ctx: *PipelineDepCtx, off: i32, import_path: *u8, path_len: i32): i32;

/**
 * Append buf into path_buf — pure leave wave306.
 * Live authority: runtime_pipeline_abi pure `pipeline_path_append_from_buf_256`
 * (thin→path_append_from_buf_256_c). Historical pipeline.x body was XLANG_LIB_WEAK
 * thin residual. G.7 dual-export ban.
 * @param ctx *PipelineDepCtx
 * @param off i32
 * @param buf *u8
 * @param len i32
 * @return i32 — new off
 * PLATFORM: SHARED freestanding 8.3 pipeline.x resolve residual pure leave.
 */
export extern function path_append_from_buf_256(ctx: *PipelineDepCtx, off: i32, buf: *u8, len: i32): i32;

/**
 * Append buf (512 path) into path_buf — pure leave wave306.
 * Live authority: runtime_pipeline_abi pure `pipeline_path_append_from_buf_512`.
 * @param ctx *PipelineDepCtx
 * @param off i32
 * @param buf *u8
 * @param len i32
 * @return i32 — new off
 * PLATFORM: SHARED freestanding 8.3 pipeline.x resolve residual pure leave.
 */
export extern function path_append_from_buf_512(ctx: *PipelineDepCtx, off: i32, buf: *u8, len: i32): i32;

/**
 * Append import_path (dot→slash) into path_buf — pure leave wave306.
 * Live authority: runtime_pipeline_abi pure `pipeline_path_append_import_path`.
 * @param ctx *PipelineDepCtx
 * @param off i32
 * @param import_path *u8
 * @param path_len i32
 * @return i32 — new off
 * PLATFORM: SHARED freestanding 8.3 pipeline.x resolve residual pure leave.
 */
export extern function path_append_import_path(ctx: *PipelineDepCtx, off: i32, import_path: *u8, path_len: i32): i32;

/**
 * Detect '.' in import path — pure leave wave306.
 * Live authority: runtime_pipeline_abi pure `pipeline_resolve_path_import_has_dot`
 * (thin→import_has_dot_c). Historical pipeline.x body was XLANG_LIB_WEAK residual.
 * G.7 dual-export ban.
 * @param import_path *u8
 * @param path_len i32
 * @return i32 — 1 has dot; 0 otherwise
 * PLATFORM: SHARED freestanding 8.3 pipeline.x resolve residual pure leave.
 */
export extern function resolve_path_import_has_dot(import_path: *u8, path_len: i32): i32;

/**
 * See implementation.
 */
export extern function pipeline_resolve_path_probe_export_c(ctx: *PipelineDepCtx, off: i32): i32;

/**
 * Probe `.x` / mod path at path_buf offset — dual-export leave wave305.
 * Live authority: runtime_pipeline_abi pure `pipeline_resolve_path_probe_dot_x_and_mod`.
 * Historical pipeline.x body was XLANG_LIB_WEAK thin→pipeline_resolve_path_probe_export_c.
 * try_one_lib_root / try_entry_dir still call this face (U → pure).
 * @param ctx *PipelineDepCtx — dep ctx with path_buf
 * @param off i32 — byte offset into path_buf
 * @return i32 — 0 hit; non-zero miss/fail
 * PLATFORM: SHARED freestanding 8.3 pipeline.x thin residual dual leave.
 */
export extern function resolve_path_probe_dot_x_and_mod(ctx: *PipelineDepCtx, off: i32): i32;

/**
 * Try flat lib_root/name/name.x import — pure leave wave306.
 * Live authority: runtime_pipeline_abi pure
 * `pipeline_resolve_path_try_flat_import_under_lib` (build_path_c + probe_open_c).
 * Historical pipeline.x body was XLANG_LIB_WEAK residual. G.7 dual-export ban.
 * @param ctx *PipelineDepCtx
 * @param lib_idx i32
 * @param import_path *u8
 * @param path_len i32
 * @return i32 — 0 hit; -1 miss
 * PLATFORM: SHARED freestanding 8.3 pipeline.x resolve residual pure leave.
 */
export extern function resolve_path_try_flat_import_under_lib(ctx: *PipelineDepCtx, lib_idx: i32, import_path: *u8, path_len: i32): i32;

/**
 * Try one lib_root prefix + probe — pure leave wave306.
 * Live authority: runtime_pipeline_abi pure `pipeline_resolve_path_try_one_lib_root`
 * (Cap prefix/sidecar/probe + flat fallback). Historical pipeline.x WEAK residual.
 * G.7 dual-export ban.
 * @param ctx *PipelineDepCtx
 * @param lib_idx i32
 * @param import_path *u8
 * @param path_len i32
 * @return i32 — 0 hit; -1 miss
 * PLATFORM: SHARED freestanding 8.3 pipeline.x resolve residual pure leave.
 */
export extern function resolve_path_try_one_lib_root(ctx: *PipelineDepCtx, lib_idx: i32, import_path: *u8, path_len: i32): i32;

/**
 * Try entry_dir prefix + probe — pure leave wave306.
 * Live authority: runtime_pipeline_abi pure `pipeline_resolve_path_try_entry_dir`.
 * Historical pipeline.x WEAK residual. G.7 dual-export ban.
 * @param ctx *PipelineDepCtx
 * @param import_path *u8
 * @param path_len i32
 * @return i32 — 0 hit; -1 miss
 * PLATFORM: SHARED freestanding 8.3 pipeline.x resolve residual pure leave.
 */
export extern function resolve_path_try_entry_dir(ctx: *PipelineDepCtx, import_path: *u8, path_len: i32): i32;

/**
 * Resolve import path under lib roots then entry_dir — dual-export leave wave305.
 * Live authority: runtime_pipeline_abi pure `pipeline_resolve_path_x` (lib loop +
 * try_one_lib_root + try_entry_dir; wave306 pure-owned try_* same-TU).
 * Historical pipeline.x body was a parallel XLANG_LIB_WEAK orchestrator.
 * G.7 dual-export ban.
 * @param ctx *PipelineDepCtx — dep ctx
 * @param import_path *u8 — import path bytes
 * @param path_len i32 — length; <=0 → -1 on pure
 * @return i32 — 0 resolved; -1 fail
 * PLATFORM: SHARED freestanding 8.3 pipeline.x thin residual dual leave.
 */
export extern function resolve_path_x(ctx: *PipelineDepCtx, import_path: *u8, path_len: i32): i32;

/**
 * Loaded import buffer capacity — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_loaded_buf_cap` (4194304).
 * G.7 dual-export ban.
 * @return usize — 4194304
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function pipeline_loaded_buf_cap(): usize;

/**
 * See implementation.
 * See implementation.
 */
export extern function pipeline_read_fd_into_loaded_buf(ctx: *PipelineDepCtx, fd: i32): i32;
/* See implementation. */
export extern function parser_copy_module_import_path64(module: *Module, i: i32, out: *u8): i32;
/* See implementation. */
export extern function parser_get_module_num_imports(module: *Module): i32;
export extern function pipeline_dep_ctx_preprocess_buf_ptr(ctx: *PipelineDepCtx): *u8;
export extern function pipeline_dep_ctx_preprocess_len_get(ctx: *PipelineDepCtx): i32;
export extern function pipeline_dep_ctx_arena_at(ctx: *PipelineDepCtx, idx: i32): *ASTArena;
export extern function pipeline_dep_ctx_module_at(ctx: *PipelineDepCtx, idx: i32): *Module;
export extern function pipeline_dep_ctx_ndep(ctx: *PipelineDepCtx): i32;
export extern function pipeline_dep_ctx_set_ndep(ctx: *PipelineDepCtx, n: i32): void;
export extern function pipeline_dep_ctx_import_path_len(ctx: *PipelineDepCtx, idx: i32): i32;
export extern function pipeline_dep_ctx_set_import_path(ctx: *PipelineDepCtx, idx: i32, bytes: *u8, len: i32): void;
export extern function pipeline_dep_ctx_import_path_copy64(ctx: *PipelineDepCtx, idx: i32, dst: *u8): void;
/* See implementation. */
export extern function typeck_typeck_x_ast(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32;
export extern function typeck_typeck_x_ast_library(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function pipeline_typeck_scan_module_struct_stack_escape_c(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function typeck_typeck_merge_dep_struct_layouts_into_entry(mod: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): void;
/* See implementation. */
export extern function typeck_typeck_wpo_unify_soa_layouts(entry: *Module, ctx: *PipelineDepCtx): void;
/* See implementation. */
export extern function pipeline_preprocess_loaded_into_ctx(ctx: *PipelineDepCtx): i32;
export extern function pipeline_bind_import_dep_buffers(ctx: *PipelineDepCtx, import_idx: i32): void;

/* See implementation. */
export extern function pipeline_read_file_x_impl_c(ctx: *PipelineDepCtx): i32;

/**
 * Read path_buf into loaded_buf — dual-export leave wave305.
 * Live authority: runtime_pipeline_abi pure `pipeline_read_file_x` (xlang_read_file_into_path;
 * cap 4194304). Historical pipeline.x body was XLANG_LIB_WEAK thin→pipeline_read_file_x_impl_c
 * (pure also owns impl_c as alias). G.7 dual-export ban.
 * @param ctx *PipelineDepCtx — dep ctx with path_buf + loaded_buf
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding 8.3 pipeline.x thin residual dual leave.
 */
export extern function read_file_x(ctx: *PipelineDepCtx): i32;

/**
 * Cap-struct-return leave wave308: parse with strict init (ParseIntoResult).
 * Live authority: runtime_pipeline_abi seed ALWAYS `pipeline_parse_into_with_init_buf`
 * (thin→pipeline_parse_into_with_init_buf_impl_c). Pure freestanding owns scalars/impl_rc
 * only (avoids by-value Cap); product Cap face is seed Cap residual class (wave284 pattern).
 * Historical pipeline.x body was XLANG_LIB_WEAK thin residual. G.7 dual-export ban.
 * @param arena *ASTArena — AST arena; null rejected by impl_c fail result
 * @param module *Module — destination module; null rejected by impl_c
 * @param data *u8 — source bytes
 * @param len i32 — byte length; <=0 → fail result
 * @return ParseIntoResult — ok + main_idx (Cap-struct product face)
 * PLATFORM: SHARED freestanding 8.3 Cap-struct residual leave.
 */
export extern function parse_into_with_init_buf(arena: *ASTArena, module: *Module, data: *u8, len: i32): ParseIntoResult;

/**
 * parse_apply_main_from_scalars — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_parse_apply_main_from_scalars`.
 * G.7 dual-export ban.
 * @param module *Module
 * @param arena *ASTArena
 * @return i32
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function pipeline_parse_apply_main_from_scalars(module: *Module, arena: *ASTArena): i32;

/**
 * parse_set_main_from_buf — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_parse_set_main_from_buf`.
 * G.7 dual-export ban.
 * @param module *Module
 * @param arena *ASTArena
 * @param data *u8
 * @param len i32
 * @return i32
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function pipeline_parse_set_main_from_buf(module: *Module, arena: *ASTArena, data: *u8, len: i32): i32;

/**
 * typeck_parsed_module — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_typeck_parsed_module`.
 * G.7 dual-export ban.
 * @param module *Module
 * @param arena *ASTArena
 * @param ctx *PipelineDepCtx
 * @param fail_mapped i32
 * @return i32
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function pipeline_typeck_parsed_module(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx, fail_mapped: i32): i32;

/**
 * typeck_entry_module — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_typeck_entry_module`.
 * G.7 dual-export ban.
 * @param module *Module
 * @param arena *ASTArena
 * @param ctx *PipelineDepCtx
 * @return i32
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function pipeline_typeck_entry_module(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32;

/**
 * See implementation.
 * See implementation.
 */
export extern function pipeline_try_bind_seeded_import(ctx: *PipelineDepCtx, import_idx: i32, global_slot: i32): i32;

/**
 * load_import_resolve_read — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_load_import_resolve_read`.
 * G.7 dual-export ban.
 * @param module *Module
 * @param ctx *PipelineDepCtx
 * @param import_idx i32
 * @return i32
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function pipeline_load_import_resolve_read(module: *Module, ctx: *PipelineDepCtx, import_idx: i32): i32;

/**
 * load_import_from_disk — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_load_import_from_disk`.
 * G.7 dual-export ban.
 * @param module *Module
 * @param arena *ASTArena
 * @param ctx *PipelineDepCtx
 * @param import_idx i32
 * @return i32
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function pipeline_load_import_from_disk(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx, import_idx: i32): i32;

/**
 * load_one_import_slot — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_load_one_import_slot`.
 * G.7 dual-export ban.
 * @param module *Module
 * @param arena *ASTArena
 * @param ctx *PipelineDepCtx
 * @param import_idx i32
 * @return i32
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function pipeline_load_one_import_slot(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx, import_idx: i32): i32;

/* See implementation. */
export extern function pipeline_sync_one_dep_slot(module: *Module, ctx: *PipelineDepCtx, dep_i: i32): i32;

/**
 * sync_dep_slots_from_driver — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_sync_dep_slots_from_driver`.
 * G.7 dual-export ban.
 * @param module *Module
 * @param ctx *PipelineDepCtx
 * @return i32
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function pipeline_sync_dep_slots_from_driver(module: *Module, ctx: *PipelineDepCtx): i32;

/**
 * load_and_sync_direct_import_deps — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_load_and_sync_direct_import_deps`.
 * G.7 dual-export ban.
 * @param module *Module
 * @param arena *ASTArena
 * @param ctx *PipelineDepCtx
 * @return i32
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function pipeline_load_and_sync_direct_import_deps(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32;

/**
 * lsp_diag_parse_entry_buf — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_lsp_diag_parse_entry_buf`.
 * G.7 dual-export ban.
 * @param module *Module
 * @param arena *ASTArena
 * @param source_data *u8
 * @param source_len i32
 * @return i32
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function lsp_diag_parse_entry_buf(module: *Module, arena: *ASTArena, source_data: *u8, source_len: i32): i32;

/**
 * lsp_diag_typeck_after_load — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_lsp_diag_typeck_after_load`.
 * G.7 dual-export ban.
 * @param module *Module
 * @param arena *ASTArena
 * @param ctx *PipelineDepCtx
 * @return i32
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function lsp_diag_typeck_after_load(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32;

/**
 * LSP parse + typeck buffer — dual-export leave wave305.
 * Live authority: runtime_pipeline_abi pure/seed `pipeline_lsp_diag_parse_typeck_buf`
 * (STRONG external on pipeline_abi.o). Historical pipeline.x body was XLANG_LIB_WEAK
 * orchestrator (parse_set_main + typeck_after_load); product link preferred pure.
 * G.7 dual-export ban.
 * @param module *Module — destination module
 * @param arena *ASTArena — AST arena
 * @param source_data *u8 — source bytes
 * @param source_len i32 — length
 * @param ctx *PipelineDepCtx — dep ctx
 * @return i32 — 0 ok; -1/-2/-3 fail stages
 * PLATFORM: SHARED freestanding 8.3 pipeline.x thin residual dual leave.
 */
export extern function lsp_diag_parse_typeck_buf(module: *Module, arena: *ASTArena, source_data: *u8, source_len: i32, ctx: *PipelineDepCtx): i32;

/* See implementation. */
export extern function driver_diagnostic_parse_fail(main_idx: i32, num_funcs: i32, arena_num_types: i32): void;
/* See implementation. */
export extern function driver_diagnostic_typeck_fail(): void;
/* See implementation. */
export extern function driver_diagnostic_before_codegen(num_funcs: i32, out_len: i32): void;
/* See implementation. */
export extern function driver_compile_phase_timing_begin(phase: i32): void;
export extern function driver_compile_phase_timing_end(phase: i32): void;
export extern function driver_compile_phase_timing_flush(): void;
/* See implementation. */
export extern function pipeline_module_num_funcs(module: *Module): i32;
/* See implementation. */
export extern function codegen_out_buf_len(out_buf: *CodegenOutBuf): i32;
export extern function codegen_out_buf_set_len(out_buf: *CodegenOutBuf, n: i32): void;
/* See implementation. */
export extern function driver_diagnostic_after_dep_codegen(j: i32, out_len: i32): void;
export extern function driver_diagnostic_codegen_fail(dep_index: i32, is_dep: i32): void;
/* See implementation. */
export extern function driver_skip_codegen_dep_0_get(): i32;
/* See implementation. */
export extern function driver_check_only_get(): i32;
/* See implementation. */
export extern function driver_x_pipeline_skip_codegen_get(): i32;
/* See implementation. */
export extern function driver_diagnostic_entry_already(v: i32): void;
/* See implementation. */
export extern function driver_diagnostic_source_len(len: i32): void;
/* See implementation. */
export extern function driver_diagnostic_after_entry_parse(num_funcs: i32): void;
/* See implementation. */
export extern function driver_diagnostic_entry_module(module: *Module, arena: *ASTArena): void;
/* See implementation. */
export extern function driver_set_current_dep_path_for_codegen(path: *u8): void;
export extern function pipeline_dep_ctx_entry_already_parsed(ctx: *PipelineDepCtx): i32;

/* See implementation. */
export extern function run_x_pipeline_codegen_one_dep_emit(dep_mod: *Module, out_buf: *CodegenOutBuf, ctx: *PipelineDepCtx, dep_j: i32, skip_asm_dep_codegen: i32, use_asm_backend: i32): i32;
export extern function run_x_pipeline_codegen_entry_emit(module: *Module, arena: *ASTArena, out_buf: *CodegenOutBuf, ctx: *PipelineDepCtx, use_asm_backend: i32): i32;

/**
 * run_x parse_entry_do_parse — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_run_x_pipeline_parse_entry_do_parse`.
 * G.7 dual-export ban.
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function run_x_pipeline_parse_entry_do_parse(module: *Module, arena: *ASTArena, source_data: *u8, source_len: usize, ctx: *PipelineDepCtx): i32;

/**
 * run_x parse_entry_if_needed — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_run_x_pipeline_parse_entry_if_needed`.
 * G.7 dual-export ban.
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function run_x_pipeline_parse_entry_if_needed(module: *Module, arena: *ASTArena, source_data: *u8, source_len: usize, ctx: *PipelineDepCtx): i32;

/**
 * run_x load_deps_after_parse — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_run_x_pipeline_load_deps_after_parse`.
 * G.7 dual-export ban.
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function run_x_pipeline_load_deps_after_parse(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32;

/**
 * run_x typecheck_after_load — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_run_x_pipeline_typecheck_after_load`.
 * G.7 dual-export ban.
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function run_x_pipeline_typecheck_after_load(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32;

/**
 * run_x typecheck_entry — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_run_x_pipeline_typecheck_entry`.
 * G.7 dual-export ban.
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function run_x_pipeline_typecheck_entry(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32;

/**
 * run_x fill_dep_import_path — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_run_x_pipeline_fill_dep_import_path`.
 * G.7 dual-export ban.
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function run_x_pipeline_fill_dep_import_path(module: *Module, ctx: *PipelineDepCtx, dep_j: i32): i32;

/**
 * run_x codegen_one_dep — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_run_x_pipeline_codegen_one_dep`.
 * G.7 dual-export ban.
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function run_x_pipeline_codegen_one_dep(module: *Module, out_buf: *CodegenOutBuf, ctx: *PipelineDepCtx, dep_j: i32, skip_asm_dep_codegen: i32): i32;

/**
 * run_x codegen_deps — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_run_x_pipeline_codegen_deps`.
 * G.7 dual-export ban.
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function run_x_pipeline_codegen_deps(module: *Module, arena: *ASTArena, out_buf: *CodegenOutBuf, ctx: *PipelineDepCtx, skip_asm_dep_codegen: i32): i32;

/**
 * prepare_dep_codegen_path — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_prepare_dep_codegen_path`.
 * G.7 dual-export ban.
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function pipeline_prepare_dep_codegen_path(ctx: *PipelineDepCtx, dep_j: i32, dst: *u8): i32;

/**
 * finish_dep_codegen_diag — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_finish_dep_codegen_diag`.
 * G.7 dual-export ban.
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function pipeline_finish_dep_codegen_diag(dep_j: i32, out_buf: *CodegenOutBuf): i32;

/**
 * run_x codegen_entry — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_run_x_pipeline_codegen_entry`.
 * G.7 dual-export ban.
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function run_x_pipeline_codegen_entry(module: *Module, arena: *ASTArena, out_buf: *CodegenOutBuf, ctx: *PipelineDepCtx): i32;

/**
 * run_x_pipeline_impl orch — pure leave wave307.
 * Live authority: runtime_pipeline_abi pure `pipeline_run_x_pipeline_impl`.
 * G.7 dual-export ban.
 * PLATFORM: SHARED freestanding 8.3 pipeline.x residual pure leave.
 */
export extern function run_x_pipeline_impl(module: *Module, arena: *ASTArena, source_data: *u8, source_len: usize, out_buf: *CodegenOutBuf, ctx: *PipelineDepCtx): i32;
