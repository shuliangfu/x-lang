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

// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
const ast = import("ast");
const lexer = import("lexer");
const parser = import("parser");
const typeck = import("typeck");
const codegen = import("codegen");
const asm_backend = import("asm.backend");

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
 * See implementation.
 */
export function pipeline_should_skip_x_typeck(ctx: *PipelineDepCtx): i32 {
  if (pipeline_driver_x_pipeline_skip_typeck() != 0) {
    return 1;
  }
  if (pipeline_dep_ctx_asm_entry_module_only(ctx) == 0) {
    return 0;
  }
  if (pipeline_driver_asm_build_skip_typeck() != 0) {
    return 1;
  }
  return 0;
}

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

/** Exported function `pipeline_parse_into_buf`.
 * Implements `pipeline_parse_into_buf`.
 * @param arena *ASTArena
 * @param module *Module
 * @param buf *u8
 * @param buf_len i32
 * @return i32
 */
export function pipeline_parse_into_buf(arena: *ASTArena, module: *Module, buf: *u8, buf_len: i32): i32 {
  return pipeline_parse_into_buf_c(arena, module, buf, buf_len);
}

/* See implementation. */
export extern function pipeline_path_append_from_buf_256_c(ctx: *PipelineDepCtx, off: i32, buf: *u8, len: i32): i32;
export extern function pipeline_path_append_from_buf_512_c(ctx: *PipelineDepCtx, off: i32, buf: *u8, len: i32): i32;
export extern function pipeline_path_append_import_path_c(ctx: *PipelineDepCtx, off: i32, import_path: *u8, path_len: i32): i32;

/** Exported function `path_append_from_buf_256`.
 * Implements `path_append_from_buf_256`.
 * @param ctx *PipelineDepCtx
 * @param off i32
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function path_append_from_buf_256(ctx: *PipelineDepCtx, off: i32, buf: *u8, len: i32): i32 {
  return pipeline_path_append_from_buf_256_c(ctx, off, buf, len);
}

/** Exported function `path_append_from_buf_512`.
 * Implements `path_append_from_buf_512`.
 * @param ctx *PipelineDepCtx
 * @param off i32
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function path_append_from_buf_512(ctx: *PipelineDepCtx, off: i32, buf: *u8, len: i32): i32 {
  return pipeline_path_append_from_buf_512_c(ctx, off, buf, len);
}

/** Exported function `path_append_import_path`.
 * Implements `path_append_import_path`.
 * @param ctx *PipelineDepCtx
 * @param off i32
 * @param import_path *u8
 * @param path_len i32
 * @return i32
 */
export function path_append_import_path(ctx: *PipelineDepCtx, off: i32, import_path: *u8, path_len: i32): i32 {
  return pipeline_path_append_import_path_c(ctx, off, import_path, path_len);
}

/** Exported function `resolve_path_import_has_dot`.
 * Implements `resolve_path_import_has_dot`.
 * @param import_path *u8
 * @param path_len i32
 * @return i32
 */
export function resolve_path_import_has_dot(import_path: *u8, path_len: i32): i32 {
  if (import_path == 0 as *u8 || path_len <= 0) {
    return 0;
  }
  let k: i32 = 0;
  while (k < path_len && k < 64) {
    if (import_path[k] == 46 as u8) {
      return 1;
    }
    k = k + 1;
  }
  return 0;
}

/**
 * See implementation.
 */
export extern function pipeline_resolve_path_probe_export_c(ctx: *PipelineDepCtx, off: i32): i32;

/** Exported function `resolve_path_probe_dot_x_and_mod`.
 * Implements `resolve_path_probe_dot_x_and_mod`.
 * @param ctx *PipelineDepCtx
 * @param off i32
 * @return i32
 */
export function resolve_path_probe_dot_x_and_mod(ctx: *PipelineDepCtx, off: i32): i32 {
  return pipeline_resolve_path_probe_export_c(ctx, off);
}

/**
 * See implementation.
 */
export function resolve_path_try_flat_import_under_lib(ctx: *PipelineDepCtx, lib_idx: i32, import_path: *u8, path_len: i32): i32 {
  if (ctx == 0 as *PipelineDepCtx || lib_idx < 0) {
    return -1;
  }
  if (pipeline_flat_import_build_path_c(ctx, lib_idx, import_path, path_len) != 0) {
    return -1;
  }
  if (pipeline_flat_import_probe_open_c(ctx) == 0) {
    return 0;
  }
  return -1;
}

/** Exported function `resolve_path_try_one_lib_root`.
 * Implements `resolve_path_try_one_lib_root`.
 * @param ctx *PipelineDepCtx
 * @param lib_idx i32
 * @param import_path *u8
 * @param path_len i32
 * @return i32
 */
export function resolve_path_try_one_lib_root(ctx: *PipelineDepCtx, lib_idx: i32, import_path: *u8, path_len: i32): i32 {
  if (ctx == 0 as *PipelineDepCtx || lib_idx < 0) {
    return -1;
  }
  if (pipeline_resolve_path_lib_root_prefix_off_c(ctx, lib_idx) < 0) {
    return -1;
  }
  if (pipeline_path_append_import_path_sidecar_c(ctx, pipeline_resolve_path_last_off_get_c(), import_path, path_len) < 0) {
    return -1;
  }
  if (resolve_path_probe_dot_x_and_mod(ctx, pipeline_resolve_path_last_off_get_c()) == 0) {
    return 0;
  }
  if (path_len > 0 && path_len < 64 && resolve_path_import_has_dot(import_path, path_len) == 0) {
    if (resolve_path_try_flat_import_under_lib(ctx, lib_idx, import_path, path_len) == 0) {
      return 0;
    }
  }
  return -1;
}

/** Exported function `resolve_path_try_entry_dir`.
 * Implements `resolve_path_try_entry_dir`.
 * @param ctx *PipelineDepCtx
 * @param import_path *u8
 * @param path_len i32
 * @return i32
 */
export function resolve_path_try_entry_dir(ctx: *PipelineDepCtx, import_path: *u8, path_len: i32): i32 {
  if (ctx == 0 as *PipelineDepCtx) {
    return -1;
  }
  if (pipeline_dep_ctx_entry_dir_len(ctx) <= 0 || resolve_path_import_has_dot(import_path, path_len) != 0) {
    return -1;
  }
  if (pipeline_resolve_path_entry_dir_prefix_off_c(ctx) < 0) {
    return -1;
  }
  if (pipeline_path_append_import_path_sidecar_c(ctx, pipeline_resolve_path_last_off_get_c(), import_path, path_len) < 0) {
    return -1;
  }
  return resolve_path_probe_dot_x_and_mod(ctx, pipeline_resolve_path_last_off_get_c());
}

/** Exported function `resolve_path_x`.
 * Implements `resolve_path_x`.
 * @param ctx *PipelineDepCtx
 * @param import_path *u8
 * @param path_len i32
 * @return i32
 */
export function resolve_path_x(ctx: *PipelineDepCtx, import_path: *u8, path_len: i32): i32 {
  if (ctx == 0 as *PipelineDepCtx || path_len <= 0) {
    return -1;
  }
  let lib_i: i32 = 0;
  while (1 == 1) {
    if (pipeline_loop_should_continue_lib_root_c(ctx, lib_i) == 0) {
      break;
    }
    if (resolve_path_try_one_lib_root(ctx, lib_i, import_path, path_len) == 0) {
      return 0;
    }
    lib_i = lib_i + 1;
  }
  if (resolve_path_try_entry_dir(ctx, import_path, path_len) == 0) {
    return 0;
  }
  return -1;
}

/** Exported function `pipeline_loaded_buf_cap`.
 * Implements `pipeline_loaded_buf_cap`.
 * @return usize
 */
export function pipeline_loaded_buf_cap(): usize {
  return 4194304 as usize;
}

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

/** Exported function `read_file_x`.
 * Read path helper `read_file_x`.
 * @param ctx *PipelineDepCtx
 * @return i32
 */
export function read_file_x(ctx: *PipelineDepCtx): i32 {
  return pipeline_read_file_x_impl_c(ctx);
}

/**
 * See implementation.
 */
export function parse_into_with_init_buf(arena: *ASTArena, module: *Module, data: *u8, len: i32): ParseIntoResult {
  return pipeline_parse_into_with_init_buf_impl_c(arena, module, data, len);
}

/**
 * See implementation.
 */
export function pipeline_parse_apply_main_from_scalars(module: *Module, arena: *ASTArena): i32 {
  return pipeline_parse_apply_main_from_scalars_c(module, arena);
}

/**
 * See implementation.
 */
/**
 * See implementation.
 */
export function pipeline_parse_set_main_from_buf(module: *Module, arena: *ASTArena, data: *u8, len: i32): i32 {
  return pipeline_parse_set_main_from_buf_c(module, arena, data, len);
}

/**
 * See implementation.
 */
export function pipeline_typeck_parsed_module(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx, fail_mapped: i32): i32 {
  return pipeline_typeck_parsed_module_c(module, arena, ctx, fail_mapped);
}

/**
 * See implementation.
 */
export function pipeline_typeck_entry_module(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32 {
  if (module == 0 as *Module || arena == 0 as *ASTArena || ctx == 0 as *PipelineDepCtx) {
    return -1;
  }
  return pipeline_typeck_parsed_module(module, arena, ctx, 0);
}

/**
 * See implementation.
 * See implementation.
 */
export extern function pipeline_try_bind_seeded_import(ctx: *PipelineDepCtx, import_idx: i32, global_slot: i32): i32;

/**
 * See implementation.
 */
export function pipeline_load_import_resolve_read(module: *Module, ctx: *PipelineDepCtx, import_idx: i32): i32 {
  return pipeline_load_import_resolve_read_c(module, ctx, import_idx);
}

/**
 * See implementation.
 * See implementation.
 */
export function pipeline_load_import_from_disk(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx, import_idx: i32): i32 {
  return pipeline_load_import_from_disk_impl_c(module, arena, ctx, import_idx);
}

/**
 * See implementation.
 */
export function pipeline_load_one_import_slot(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx, import_idx: i32): i32 {
  return pipeline_load_one_import_slot_c(module, arena, ctx, import_idx);
}

/* See implementation. */
export extern function pipeline_sync_one_dep_slot(module: *Module, ctx: *PipelineDepCtx, dep_i: i32): i32;

/**
 * See implementation.
 *
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * PLATFORM: SHARED.
 */
export function pipeline_sync_dep_slots_from_driver(module: *Module, ctx: *PipelineDepCtx): i32 {
  return pipeline_sync_dep_slots_from_driver_impl_c(module, ctx);
}

/**
 * See implementation.
 * See implementation.
 */
export function pipeline_load_and_sync_direct_import_deps(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32 {
  return pipeline_load_and_sync_direct_import_deps_c(module, arena, ctx);
}

/** Exported function `lsp_diag_parse_entry_buf`.
 * Implements `lsp_diag_parse_entry_buf`.
 * @param module *Module
 * @param arena *ASTArena
 * @param source_data *u8
 * @param source_len i32
 * @return i32
 */
export function lsp_diag_parse_entry_buf(module: *Module, arena: *ASTArena, source_data: *u8, source_len: i32): i32 {
  return pipeline_parse_set_main_from_buf(module, arena, source_data, source_len);
}

/**
 * See implementation.
 */
export function lsp_diag_typeck_after_load(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32 {
  if (module == 0 as *Module || arena == 0 as *ASTArena || ctx == 0 as *PipelineDepCtx) {
    return -1;
  }
  if (pipeline_load_and_sync_direct_import_deps(module, arena, ctx) != 0) {
    return -1;
  }
  if (run_x_pipeline_typecheck_entry(module, arena, ctx) != 0) {
    return -3;
  }
  return 0;
}

/**
 * See implementation.
 */
export function lsp_diag_parse_typeck_buf(module: *Module, arena: *ASTArena, source_data: *u8, source_len: i32, ctx: *PipelineDepCtx): i32 {
  if (module == 0 as *Module || arena == 0 as *ASTArena || ctx == 0 as *PipelineDepCtx || source_data == 0 as *u8) {
    return -1;
  }
  if (pipeline_parse_set_main_from_buf(module, arena, source_data, source_len) != 0) {
    return -2;
  }
  if (lsp_diag_typeck_after_load(module, arena, ctx) != 0) {
    return -3;
  }
  return 0;
}

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
 * See implementation.
 */
export function run_x_pipeline_parse_entry_do_parse(module: *Module, arena: *ASTArena, source_data: *u8, source_len: usize, ctx: *PipelineDepCtx): i32 {
  return run_x_pipeline_parse_entry_do_parse_c(module, arena, source_data, source_len, ctx);
}

/**
 * See implementation.
 */
export function run_x_pipeline_parse_entry_if_needed(module: *Module, arena: *ASTArena, source_data: *u8, source_len: usize, ctx: *PipelineDepCtx): i32 {
  if (module == 0 as *Module || arena == 0 as *ASTArena || ctx == 0 as *PipelineDepCtx) {
    return -1;
  }
  driver_diagnostic_entry_already(pipeline_dep_ctx_entry_already_parsed(ctx));
  if (pipeline_dep_ctx_entry_already_parsed(ctx) != 0) {
    driver_diagnostic_after_entry_parse(pipeline_module_num_funcs(module));
    driver_diagnostic_entry_module(module, arena);
    return 0;
  }
  return run_x_pipeline_parse_entry_do_parse(module, arena, source_data, source_len, ctx);
}

/**
 * See implementation.
 */
export function run_x_pipeline_load_deps_after_parse(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32 {
  if (module == 0 as *Module || arena == 0 as *ASTArena || ctx == 0 as *PipelineDepCtx) {
    run_x_pipeline_last_rc_store_c(-1);
    return run_x_pipeline_last_rc_get();
  }
  if (pipeline_load_and_sync_direct_import_deps(module, arena, ctx) != 0) {
    run_x_pipeline_last_rc_store_c(-1);
    return run_x_pipeline_last_rc_get();
  }
  run_x_pipeline_last_rc_store_c(0);
  return 0;
}

/**
 * See implementation.
 */
export function run_x_pipeline_typecheck_after_load(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32 {
  return run_x_pipeline_typecheck_after_load_c(module, arena, ctx);
}

/**
 * See implementation.
 */
export function run_x_pipeline_typecheck_entry(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32 {
  if (module == 0 as *Module || arena == 0 as *ASTArena || ctx == 0 as *PipelineDepCtx) {
    return -1;
  }
  if (pipeline_driver_x_pipeline_skip_typeck() != 0) {
    return run_x_pipeline_typecheck_entry_emit_c(module, arena, ctx);
  }
  if (pipeline_should_skip_x_typeck(ctx) != 0) {
    return 0;
  }
  return pipeline_typeck_entry_module(module, arena, ctx);
}

/**
 * See implementation.
 */
export function run_x_pipeline_fill_dep_import_path(module: *Module, ctx: *PipelineDepCtx, dep_j: i32): i32 {
  return run_x_pipeline_fill_dep_import_path_c(module, ctx, dep_j);
}

/**
 * See implementation.
 */
export function run_x_pipeline_codegen_one_dep(module: *Module, out_buf: *CodegenOutBuf, ctx: *PipelineDepCtx, dep_j: i32, skip_asm_dep_codegen: i32): i32 {
  if (module == 0 as *Module || out_buf == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx || dep_j < 0) {
    return -1;
  }
  if (dep_j == 0 && driver_skip_codegen_dep_0_get() != 0) {
    return 0;
  }
  if (run_x_pipeline_fill_dep_import_path(module, ctx, dep_j) != 0) {
    return -1;
  }
  if (run_x_pipeline_codegen_one_dep_prepare_c(ctx, dep_j) != 0) {
    return -1;
  }
  /* See implementation. */
  if (run_x_pipeline_codegen_one_dep_emit(pipeline_dep_ctx_module_at(ctx, dep_j), out_buf, ctx, dep_j, skip_asm_dep_codegen, pipeline_dep_ctx_use_asm_backend(ctx)) != 0) {
    driver_diagnostic_codegen_fail(dep_j, 1);
    return -6;
  }
  pipeline_finish_dep_codegen_diag(dep_j, out_buf);
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function run_x_pipeline_codegen_deps(module: *Module, arena: *ASTArena, out_buf: *CodegenOutBuf, ctx: *PipelineDepCtx, skip_asm_dep_codegen: i32): i32 {
  if (module == 0 as *Module || arena == 0 as *ASTArena || out_buf == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
    return -1;
  }
  let dep_codegen_i: i32 = 0;
  while (1 == 1) {
    if (pipeline_loop_should_continue_ndep_c(ctx, dep_codegen_i) == 0) {
      break;
    }
    if (run_x_pipeline_codegen_one_dep(module, out_buf, ctx, dep_codegen_i, skip_asm_dep_codegen) != 0) {
      return -6;
    }
    dep_codegen_i = dep_codegen_i + 1;
  }
  return 0;
}

/**
 * See implementation.
 */
export function pipeline_prepare_dep_codegen_path(ctx: *PipelineDepCtx, dep_j: i32, dst: *u8): i32 {
  pipeline_dep_ctx_import_path_copy64(ctx, dep_j, dst);
  driver_set_current_dep_path_for_codegen(dst);
  return 0;
}

/** Exported function `pipeline_finish_dep_codegen_diag`.
 * Implements `pipeline_finish_dep_codegen_diag`.
 * @param dep_j i32
 * @param out_buf *CodegenOutBuf
 * @return i32
 */
export function pipeline_finish_dep_codegen_diag(dep_j: i32, out_buf: *CodegenOutBuf): i32 {
  driver_diagnostic_after_dep_codegen(dep_j, codegen_out_buf_len(out_buf));
  driver_set_current_dep_path_for_codegen(0 as *u8);
  return 0;
}

/**
 * See implementation.
 */
export function run_x_pipeline_codegen_entry(module: *Module, arena: *ASTArena, out_buf: *CodegenOutBuf, ctx: *PipelineDepCtx): i32 {
  if (module == 0 as *Module || arena == 0 as *ASTArena || out_buf == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
    return -1;
  }
  driver_diagnostic_entry_module(module, arena);
  /* See implementation. */
  if (run_x_pipeline_codegen_entry_emit(module, arena, out_buf, ctx, pipeline_dep_ctx_use_asm_backend(ctx)) != 0) {
    driver_diagnostic_codegen_fail(0, 0);
    return -6;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function run_x_pipeline_impl(module: *Module, arena: *ASTArena, source_data: *u8, source_len: usize, out_buf: *CodegenOutBuf, ctx: *PipelineDepCtx): i32 {
  if (module == 0 as *Module || arena == 0 as *ASTArena || out_buf == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
    return -1;
  }
  driver_compile_phase_timing_begin(0);
  if (run_x_pipeline_parse_entry_if_needed(module, arena, source_data, source_len, ctx) != 0) {
    driver_compile_phase_timing_end(0);
    driver_compile_phase_timing_flush();
    return -2;
  }
  /* See implementation. */
  if (run_x_pipeline_load_deps_after_parse(module, arena, ctx) != 0) {
    driver_compile_phase_timing_end(0);
    driver_compile_phase_timing_flush();
    return run_x_pipeline_last_rc_get();
  }
  driver_compile_phase_timing_end(0);
  driver_compile_phase_timing_begin(1);
  if (run_x_pipeline_typecheck_after_load(module, arena, ctx) != 0) {
    driver_compile_phase_timing_end(1);
    driver_compile_phase_timing_flush();
    return run_x_pipeline_last_rc_get();
  }
  driver_compile_phase_timing_end(1);
  if (driver_check_only_get() != 0) {
    driver_compile_phase_timing_flush();
    return 0;
  }
  if (driver_x_pipeline_skip_codegen_get() != 0) {
    driver_compile_phase_timing_flush();
    return 0;
  }
  codegen_out_buf_set_len(out_buf, 0);
  driver_diagnostic_before_codegen(pipeline_module_num_funcs(module), 0);
  driver_compile_phase_timing_begin(2);
  /* See implementation. */
  if (run_x_pipeline_codegen_deps(module, arena, out_buf, ctx, pipeline_dep_ctx_asm_entry_module_only(ctx)) != 0) {
    driver_compile_phase_timing_end(2);
    driver_compile_phase_timing_flush();
    return -6;
  }
  if (run_x_pipeline_codegen_entry(module, arena, out_buf, ctx) != 0) {
    driver_compile_phase_timing_end(2);
    driver_compile_phase_timing_flush();
    return -6;
  }
  driver_compile_phase_timing_end(2);
  driver_compile_phase_timing_flush();
  return 0;
}
