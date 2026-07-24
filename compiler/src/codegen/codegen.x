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
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.

// Cap-T001 / LANG-007 S0 (M1→M2 codegen): functions that call export-extern
// pipeline_* / driver_* / glue use whole-body unsafe FFI gates.
// Residual (not Cap-T001): after wrap, first fail is XT001 — collect parse dep=ast
// pr_ok=-2 (parser state after entry parse of mega codegen.x). Product seed pin unchanged.
// PLATFORM: SHARED — product still pins codegen seed until M2.

const ast = import("ast");

/* See implementation. */
export extern function pipeline_dep_ctx_import_path_len(ctx: *PipelineDepCtx, idx: i32): i32;
export extern function pipeline_dep_ctx_import_path_copy64(ctx: *PipelineDepCtx, idx: i32, dst: *u8): void;
export extern function pipeline_dep_ctx_module_at(ctx: *PipelineDepCtx, idx: i32): *Module;
export extern function pipeline_dep_ctx_arena_at(ctx: *PipelineDepCtx, idx: i32): *ASTArena;
export extern function pipeline_dep_ctx_ndep(ctx: *PipelineDepCtx): i32;

/* See implementation. */
export extern function pipeline_type_named_name_into(arena: *ASTArena, ref: i32, out64: *u8): i32;
export extern function pipeline_type_kind_ord_at(arena: *ASTArena, ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *ASTArena, ref: i32): i32;
export extern function pipeline_type_array_size_at(arena: *ASTArena, ref: i32): i32;
/* See implementation. */
export extern function pipeline_codegen_type_to_c_repr(arena: *ASTArena, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
/* See implementation. */
export extern function pipeline_codegen_c_file_prologue_done_get(): i32;
export extern function pipeline_codegen_c_file_prologue_done_set(v: i32): void;
export extern function pipeline_codegen_c_file_prologue_done_reset(): void;
/* See implementation. */
export extern function pipeline_codegen_struct_tag_try_claim(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32;
/* See implementation. */
export extern function pipeline_codegen_emit_struct_field_type(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
/* See implementation. */
export extern function pipeline_codegen_emit_struct_field_decl(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, field_name: *u8, field_name_len: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
/* See implementation. */
export extern function pipeline_codegen_emit_seed_mega_enabled(): i32;
/** C-backend float literal emit (host snprintf; float_val + float_bits fallback).
 * Authority: pipeline_glue.c pipeline_codegen_emit_float_lit_c; product Darwin also exports
 * the same symbol from seeds/pipeline_glue_strict_minimal.from_x.c (same semantics, same commit).
 * PLATFORM: SHARED — required by force-regen codegen M2 (EXPR_FLOAT_LIT). */
export extern function pipeline_codegen_emit_float_lit_c(out: *CodegenOutBuf, float_val: f64, bits_lo: i32, bits_hi: i32): i32;
/* See implementation. */
export extern function driver_diagnostic_codegen_emit_func_fail(module: *Module, func_index: i32): void;
/* See implementation. */
export extern function pipeline_module_struct_layout_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_name_into(module: *Module, idx: i32, out64: *u8): void;
export extern function pipeline_module_struct_layout_num_fields(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_field_type_ref(module: *Module, layout_idx: i32, field_idx: i32): i32;
export extern function pipeline_module_struct_layout_field_name_len(module: *Module, layout_idx: i32, field_idx: i32): i32;
export extern function pipeline_module_struct_layout_field_name_into(module: *Module, layout_idx: i32, field_idx: i32, out64: *u8): void;
/* See implementation. */
export extern function pipeline_module_struct_layout_is_export_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_kind_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_binding_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_binding_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_import_select_count_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_select_name_len(module: *Module, idx: i32, sel: i32): i32;
export extern function pipeline_module_import_select_name_byte_at(module: *Module, idx: i32, sel: i32, off: i32): u8;
export extern function pipeline_module_import_path_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_path_copy(module: *Module, idx: i32, dst: *u8, dst_cap: i32): void;
export extern function parser_get_module_num_imports(module: *Module): i32;
export extern function driver_dep_arena_buf(i: i32): *u8;
export extern function driver_dep_module_buf(i: i32): *u8;
export extern function driver_dep_seeded_get(i: i32): i32;
export extern function driver_dep_slot_for_path(path: *u8): i32;
/* See implementation. */
export extern function driver_get_current_dep_path_for_codegen(): *u8;
/* See implementation. */
export extern function pipeline_expr_kind_ord_at(arena: *ASTArena, expr_ref: i32): i32;
/** True if expr is a C static-initializer constant (pure lit tree; no free VAR).
 * PLATFORM: SHARED — gates mutable top-level let decl-site init vs init_globals. */
export extern function pipeline_expr_is_c_static_const_init(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_as_target_type_ref_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_call_arg_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_call_resolved_dep_index_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_call_resolved_func_index_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_arg_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_match_arm_result_ref(arena: *ASTArena, expr_ref: i32, i: i32): i32;
/** True if match arm i is the `_` wildcard (ends nested-ternary chain). */
export extern function pipeline_expr_match_arm_is_wildcard(arena: *ASTArena, expr_ref: i32, i: i32): i32;
/** Integer literal pattern value for match arm i (non-enum, non-wildcard). */
export extern function pipeline_expr_match_arm_lit_val(arena: *ASTArena, expr_ref: i32, i: i32): i32;
/** True if match arm i compares against an enum variant tag. */
export extern function pipeline_expr_match_arm_is_enum_variant(arena: *ASTArena, expr_ref: i32, i: i32): i32;
/** Enum variant index used as compare value for match arm i. */
export extern function pipeline_expr_match_arm_variant_index(arena: *ASTArena, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_field_name_len(arena: *ASTArena, expr_ref: i32, j: i32): i32;
export extern function pipeline_expr_struct_lit_field_name_into(arena: *ASTArena, expr_ref: i32, j: i32, out: *u8): void;
export extern function pipeline_expr_struct_lit_init_ref(arena: *ASTArena, expr_ref: i32, j: i32): i32;
export extern function pipeline_expr_struct_lit_num_fields(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_module_enum_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_enum_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_enum_num_variants(module: *Module, idx: i32): i32;
export extern function pipeline_module_enum_variant_name_len(module: *Module, idx: i32, variant_idx: i32): i32;
export extern function pipeline_module_enum_variant_name_byte_at(module: *Module, idx: i32, variant_idx: i32, off: i32): u8;
/** Codegen-time: mark Enum.Variant / import.Enum.Variant (sets is_enum_variant + tag). */
export extern function pipeline_codegen_try_mark_enum_field_access(module: *Module, arena: *ASTArena, expr_ref: i32, dep_ctx: *PipelineDepCtx): void;
export extern function pipeline_module_top_level_let_is_const(module: *Module, idx: i32): i32;
export extern function pipeline_module_top_level_let_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_top_level_let_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_top_level_let_type_ref(module: *Module, idx: i32): i32;
export extern function pipeline_module_top_level_let_init_ref(module: *Module, idx: i32): i32;
export extern function pipeline_codegen_dep_skip_x_bootstrap_partial(path: *u8): i32;
/* See implementation. */
export extern function pipeline_module_func_name_copy64(module: *Module, fi: i32, dst: *u8): void;
export extern function pipeline_module_func_param_name_copy32(module: *Module, fi: i32, pi: i32, dst: *u8): void;
/* See implementation. */
export extern function pipeline_module_func_num_params_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_param_name_len_at(module: *Module, fi: i32, pi: i32): i32;
export extern function pipeline_module_func_name_len_at(module: *Module, fi: i32): i32;
/* See implementation. */
export extern function pipeline_module_func_num_generic_params_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_return_type_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_body_ref_at(module: *Module, fi: i32): i32;
/* See implementation. */
export extern function pipeline_dep_ctx_empty_param_reset(ctx: *PipelineDepCtx): void;
export extern function pipeline_dep_ctx_empty_param_append(ctx: *PipelineDepCtx, pi: i32): i32;
export extern function pipeline_dep_ctx_empty_param_at(ctx: *PipelineDepCtx, i: i32): i32;
export extern function pipeline_dep_ctx_empty_param_backup(ctx: *PipelineDepCtx): void;
export extern function pipeline_dep_ctx_empty_param_restore(ctx: *PipelineDepCtx): void;
export extern function pipeline_module_func_body_expr_ref_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_extern_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_used_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_naked_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_entry_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_no_mangle_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_interrupt_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_variadic_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_param_type_ref_at(module: *Module, fi: i32, pi: i32): i32;
/* See implementation. */
export extern function pipeline_block_const_name_copy64(arena: *ASTArena, br: i32, ci: i32, dst: *u8): void;
export extern function pipeline_block_const_name_len(arena: *ASTArena, br: i32, ci: i32): i32;
export extern function pipeline_block_const_type_ref(arena: *ASTArena, br: i32, ci: i32): i32;
export extern function pipeline_block_const_init_ref(arena: *ASTArena, br: i32, ci: i32): i32;
export extern function pipeline_block_let_name_copy64(arena: *ASTArena, br: i32, li: i32, dst: *u8): void;
export extern function pipeline_block_let_name_len(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_block_let_type_ref(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_block_let_init_ref(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_block_if_cond_ref(arena: *ASTArena, br: i32, ii: i32): i32;
export extern function pipeline_block_if_then_body_ref(arena: *ASTArena, br: i32, ii: i32): i32;
export extern function pipeline_block_if_else_body_ref(arena: *ASTArena, br: i32, ii: i32): i32;
/* See implementation. */
export extern function pipeline_block_defer_body_ref(arena: *ASTArena, br: i32, di: i32): i32;
export extern function pipeline_module_func_ref_at(module: *Module, func_index: i32): i32;
/* See implementation. */
export extern function pipeline_asm_resolve_whole_import_qualified_symbol_c(arena: *ASTArena, cur_mod: *Module, callee_expr_ref: i32, sym_flat: *u8, out_match_imp_j: *i32): i32;
export extern function pipeline_block_stmt_order_kind(arena: *ASTArena, br: i32, si: i32): u8;
export extern function pipeline_block_stmt_order_idx(arena: *ASTArena, br: i32, si: i32): i32;

/**
 * See implementation.
 */
/** Exported function `codegen_path_is_std_io_driver_bytes`.
 * Implements `codegen_path_is_std_io_driver_bytes`.
 * @param path *u8
 * @return i32
 */
export function codegen_path_is_std_io_driver_bytes(path: *u8): i32 {
  let expect: u8[14] = [115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0];
  let i: i32 = 0;
  if (path == 0 as *u8) {
    return 0;
  }
  while (i < 14) {
    if (path[i] != expect[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/** Exported function `codegen_path_is_std_io_core_bytes`.
 * Implements `codegen_path_is_std_io_core_bytes`.
 * @param path *u8
 * @return i32
 */
export function codegen_path_is_std_io_core_bytes(path: *u8): i32 {
  let expect: u8[12] = [115, 116, 100, 46, 105, 111, 46, 99, 111, 114, 101, 0];
  let i: i32 = 0;
  /* See implementation. */
  let pi: i32 = 0;
  let ei: i32 = 0;
  if (path == 0 as *u8) {
    return 0;
  }
  while (i < 12) {
    pi = path[i] as i32;
    ei = expect[i] as i32;
    if (pi != ei) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_import_path_to_c_prefix_into(path: *u8, buf: *u8, buf_cap: i32): void {
  if (buf == 0 as *u8 || buf_cap <= 0) {
    return;
  }
  let off: i32 = 0;
  let pi: i32 = 0;
  while (path != 0 as *u8) {
    let ch: u8 = path[pi];
    if (ch == 0 as u8) {
      break;
    }
    if (off + 2 >= buf_cap) {
      break;
    }
    if (ch == 46 as u8) {
      buf[off] = 95 as u8;
    } else {
      buf[off] = ch;
    }
    off = off + 1;
    pi = pi + 1;
  }
  if (off + 1 < buf_cap) {
    buf[off] = 95 as u8;
    off = off + 1;
  }
  buf[off] = 0 as u8;
}

/**
 * See implementation.
 */
export function codegen_dep_import_path_len_at(ctx: *PipelineDepCtx, idx: i32, dst: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let plen: i32 = pipeline_dep_ctx_import_path_len(ctx, idx);
    if (plen <= 0) {
      return 0;
    }
    pipeline_dep_ctx_import_path_copy64(ctx, idx, dst);
    return plen;
  }
}

/**
 * See implementation.
 */
export function codegen_ctx_dep_path_for_current_codegen_module_into(ctx: *PipelineDepCtx, dst: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    let nd: i32 = pipeline_dep_ctx_ndep(ctx);
    let j: i32 = 0;
    while (j < nd) {
      if (pipeline_dep_ctx_module_at(ctx, j) == ctx.current_codegen_module) {
        return codegen_dep_import_path_len_at(ctx, j, dst);
      }
      j = j + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_module_import_path_len_at(module: *Module, import_idx: i32, dst: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (module == 0 as *Module || dst == 0 as *u8 || import_idx < 0) {
      return 0;
    }
    let plen: i32 = pipeline_module_import_path_len(module, import_idx);
    if (plen <= 0) {
      return 0;
    }
    pipeline_module_import_path_copy(module, import_idx, dst, 64);
    return plen;
  }
}

/**
 * See implementation.
 */
export function codegen_find_dep_index_by_path(ctx: *PipelineDepCtx, path: *u8, path_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || path == 0 as *u8 || path_len <= 0) {
      return -1;
    }
    let di: i32 = 0;
    let nd: i32 = pipeline_dep_ctx_ndep(ctx);
    while (di < nd) {
      let dep_path: u8[64] = [];
      let dep_len: i32 = codegen_dep_import_path_len_at(ctx, di, &dep_path[0]);
      if (dep_len == path_len) {
        let eq: bool = true;
        let k: i32 = 0;
        while (k < path_len && k < 64) {
          if (dep_path[k] != path[k]) {
            eq = false;
            break;
          }
          k = k + 1;
        }
        if (eq) {
          return di;
        }
      }
      di = di + 1;
    }
    return -1;
  }
}

/** Exported function `codegen_find_seeded_global_dep_slot_by_path`.
 * Implements `codegen_find_seeded_global_dep_slot_by_path`.
 * @param path *u8
 * @param path_len i32
 * @return i32
 */
export function codegen_find_seeded_global_dep_slot_by_path(path: *u8, path_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (path == 0 as *u8 || path_len <= 0 || path_len > 63) {
      return -1;
    }
    let path_buf: u8[64] = [];
    let i: i32 = 0;
    while (i < path_len && i < 63) {
      path_buf[i] = path[i];
      i = i + 1;
    }
    path_buf[i] = 0 as u8;
    let gs: i32 = driver_dep_slot_for_path(&path_buf[0]);
    if (gs >= 0 && driver_dep_seeded_get(gs) != 0) {
      return gs;
    }
    return -1;
  }
}

/** Exported function `codegen_module_num_imports`.
 * Implements `codegen_module_num_imports`.
 * @param module *Module
 * @return i32
 */
export function codegen_module_num_imports(module: *Module): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (module == 0 as *Module) {
      return 0;
    }
    let n_imp: i32 = parser_get_module_num_imports(module);
    if (n_imp > 0) {
      return n_imp;
    }
    return module.num_imports;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_emit_prefix_len_from_ctx(ctx: *PipelineDepCtx, buf: *u8, buf_cap: i32): i32 {
  if (buf == 0 as *u8 || buf_cap <= 0 || ctx == 0 as *PipelineDepCtx) {
    return 0;
  }
  buf[0] = 0 as u8;
  /*
   * See implementation.
   * See implementation.
   */
  if (ctx.current_codegen_dep_index < 0 && ctx.entry_module_import_path_len > 0) {
    let pi: i32 = 0;
    while (pi < ctx.entry_module_import_path_len && pi < buf_cap - 1) {
      buf[pi] = ctx.entry_module_import_path_mirror[pi];
      pi = pi + 1;
    }
    buf[pi] = 0 as u8;
    return pi;
  }
  if (ctx.current_codegen_prefix_len > 0) {
    let pi: i32 = 0;
    while (pi < ctx.current_codegen_prefix_len && pi < buf_cap - 1) {
      buf[pi] = ctx.current_codegen_prefix_mirror[pi];
      pi = pi + 1;
    }
    buf[pi] = 0 as u8;
    return pi;
  }
  let path_buf: u8[64] = [];
  let path_len: i32 = 0;
  if (ctx.current_codegen_dep_index >= 0) {
    path_len = codegen_dep_import_path_len_at(ctx, ctx.current_codegen_dep_index, &path_buf[0]);
  }
  if (path_len == 0) {
    path_len = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &path_buf[0]);
  }
  if (path_len == 0) {
    return 0;
  }
  if (codegen_path_is_std_io_core_bytes(&path_buf[0]) != 0) {
    return 0;
  }
  codegen_import_path_to_c_prefix_into(&path_buf[0], buf, buf_cap);
  let i: i32 = 0;
  while (i < buf_cap && buf[i] != 0 as u8) {
    i = i + 1;
  }
  return i;
}

/** Exported function `codegen_emit_async_run_seed_push_name`.
 * Implements `codegen_emit_async_run_seed_push_name`.
 * @param out *CodegenOutBuf
 * @param arena *ASTArena
 * @param type_ref i32
 * @return i32
 */
export function codegen_emit_async_run_seed_push_name(out: *CodegenOutBuf, arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let push_i32: u8[29] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 105, 51, 50];
    let push_u32: u8[29] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 117, 51, 50];
    let push_i64: u8[29] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 105, 54, 52];
    let push_usize: u8[31] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 117, 115, 105, 122, 101];
    let kind_ord: i32 = TypeKind.TYPE_I32 as i32;
    if (arena != 0 as *ASTArena && !ast.ref_is_null(type_ref)) {
      kind_ord = pipeline_type_kind_ord_at(arena, type_ref);
    }
    if (kind_ord == (TypeKind.TYPE_U32 as i32)) {
      return emit_bytes_from_ptr(out, &push_u32[0], 28);
    }
    if (kind_ord == (TypeKind.TYPE_I64 as i32)) {
      return emit_bytes_from_ptr(out, &push_i64[0], 28);
    }
    if (kind_ord == (TypeKind.TYPE_USIZE as i32)) {
      return emit_bytes_from_ptr(out, &push_usize[0], 30);
    }
    return emit_bytes_from_ptr(out, &push_i32[0], 28);
  }
}

/** Exported function `codegen_emit_async_sched_call`.
 * Implements `codegen_emit_async_sched_call`.
 * @param out *CodegenOutBuf
 * @param module *Module
 * @param func_index i32
 * @return i32
 */
export function codegen_emit_async_sched_call(out: *CodegenOutBuf, module: *Module, func_index: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let sched_prefix: u8[18] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 115, 99, 104, 101, 100, 95];
    let fn_name: u8[64] = [];
    let fn_len: i32 = 0;
    if (module == 0 as *Module || func_index < 0 || func_index >= module.num_funcs) {
      return -1;
    }
    fn_len = pipeline_module_func_name_len_at(module, func_index);
    if (fn_len <= 0) {
      return -1;
    }
    pipeline_module_func_name_copy64(module, func_index, &fn_name[0]);
    if (emit_bytes_from_ptr(out, &sched_prefix[0], 17) != 0) {
      return -1;
    }
    if (emit_bytes_from_ptr(out, &fn_name[0], fn_len) != 0) {
      return -1;
    }
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
}

/** Exported function `codegen_emit_async_sched_call_by_name`.
 * Implements `codegen_emit_async_sched_call_by_name`.
 * @param out *CodegenOutBuf
 * @param fn_name *u8
 * @param fn_len i32
 * @return i32
 */
export function codegen_emit_async_sched_call_by_name(out: *CodegenOutBuf, fn_name: *u8, fn_len: i32): i32 {
  let sched_prefix: u8[18] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 115, 99, 104, 101, 100, 95];
  if (out == 0 as *CodegenOutBuf || fn_name == 0 as *u8 || fn_len <= 0) {
    return -1;
  }
  if (emit_bytes_from_ptr(out, &sched_prefix[0], 17) != 0) {
    return -1;
  }
  if (emit_bytes_from_ptr(out, fn_name, fn_len) != 0) {
    return -1;
  }
  if (append_byte(out, 40) != 0) {
    return -1;
  }
  return append_byte(out, 41);
}

/** Exported function `codegen_emit_async_task_submit_call`.
 * Implements `codegen_emit_async_task_submit_call`.
 * @param out *CodegenOutBuf
 * @param module *Module
 * @param func_index i32
 * @return i32
 */
export function codegen_emit_async_task_submit_call(out: *CodegenOutBuf, module: *Module, func_index: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let submit_name: u8[23] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 116, 97, 115, 107, 95, 115, 117, 98, 109, 105, 116];
    let cast_prefix: u8[19] = [40, 105, 110, 116, 51, 50, 95, 116, 32, 40, 42, 41, 40, 118, 111, 105, 100, 41, 41];
    let fn_name: u8[64] = [];
    let fn_len: i32 = 0;
    if (module == 0 as *Module || func_index < 0 || func_index >= module.num_funcs) {
      return -1;
    }
    fn_len = pipeline_module_func_name_len_at(module, func_index);
    if (fn_len <= 0) {
      return -1;
    }
    pipeline_module_func_name_copy64(module, func_index, &fn_name[0]);
    if (emit_bytes_from_ptr(out, &submit_name[0], 22) != 0) {
      return -1;
    }
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_bytes_from_ptr(out, &cast_prefix[0], 19) != 0) {
      return -1;
    }
    if (emit_bytes_from_ptr(out, &fn_name[0], fn_len) != 0) {
      return -1;
    }
    if (append_byte(out, 41) != 0) {
      return -1;
    }
    return 0;
  }
}

/** Exported function `codegen_emit_async_task_submit_call_by_symbol`.
 * Implements `codegen_emit_async_task_submit_call_by_symbol`.
 * @param out *CodegenOutBuf
 * @param prefix *u8
 * @param prefix_len i32
 * @param fn_name *u8
 * @param fn_len i32
 * @return i32
 */
export function codegen_emit_async_task_submit_call_by_symbol(out: *CodegenOutBuf, prefix: *u8, prefix_len: i32, fn_name: *u8, fn_len: i32): i32 {
  let submit_name: u8[23] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 116, 97, 115, 107, 95, 115, 117, 98, 109, 105, 116];
  let cast_prefix: u8[19] = [40, 105, 110, 116, 51, 50, 95, 116, 32, 40, 42, 41, 40, 118, 111, 105, 100, 41, 41];
  if (out == 0 as *CodegenOutBuf || fn_name == 0 as *u8 || fn_len <= 0) {
    return -1;
  }
  if (emit_bytes_from_ptr(out, &submit_name[0], 22) != 0) {
    return -1;
  }
  if (append_byte(out, 40) != 0) {
    return -1;
  }
  if (emit_bytes_from_ptr(out, &cast_prefix[0], 19) != 0) {
    return -1;
  }
  if (prefix != 0 as *u8 && prefix_len > 0 && codegen_c_prefix_redundant_with_name(prefix, prefix_len, fn_name, fn_len) == 0 && emit_bytes_from_ptr(out, prefix, prefix_len) != 0) {
    return -1;
  }
  if (emit_bytes_from_ptr(out, fn_name, fn_len) != 0) {
    return -1;
  }
  if (append_byte(out, 41) != 0) {
    return -1;
  }
  return 0;
}

/** Exported function `codegen_emit_async_binding_import_call`.
 * Implements `codegen_emit_async_binding_import_call`.
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param call_expr_ref i32
 * @param ctx *PipelineDepCtx
 * @param is_spawn i32
 * @return i32
 */
export function codegen_emit_async_binding_import_call(arena: *ASTArena, out: *CodegenOutBuf, call_expr_ref: i32, ctx: *PipelineDepCtx, is_spawn: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let reset_name: u8[26] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 114, 101, 115, 101, 116];
    let comma: u8[3] = [44, 32, 0];
    let dep_path: u8[64] = [];
    let prefix_buf: u8[128] = [];
    let dep_ix: i32 = -1;
    let n_args: i32 = 0;
    let ai: i32 = 0;
    let prefix_len: i32 = 0;
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
      return -1;
    }
    if (ast.ref_is_null(call_expr_ref) || call_expr_ref <= 0 || call_expr_ref > arena.num_exprs) {
      return -1;
    }
    let call_e: Expr = ast.ast_arena_expr_get(arena, call_expr_ref);
    if (call_e.kind != ExprKind.EXPR_CALL || ast.ref_is_null(call_e.call_callee_ref) || call_e.call_callee_ref <= 0 || call_e.call_callee_ref > arena.num_exprs) {
      return -1;
    }
    let callee_e: Expr = ast.ast_arena_expr_get(arena, call_e.call_callee_ref);
    if (callee_e.kind != ExprKind.EXPR_FIELD_ACCESS || callee_e.field_access_field_len <= 0) {
      return -1;
    }
    n_args = call_e.call_num_args;
    if (n_args < 0) {
      return -1;
    }
    if (is_spawn == 0) {
      if (n_args > 0) {
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        if (emit_bytes_from_ptr(out, &reset_name[0], 25) != 0) {
          return -1;
        }
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        if (append_byte(out, 41) != 0) {
          return -1;
        }
        ai = 0;
        while (ai < n_args) {
          let arg_ref: i32 = pipeline_expr_call_arg_ref(arena, call_expr_ref, ai);
          let arg_type_ref: i32 = 0;
          if (emit_bytes_3(out, comma, 2) != 0) {
            return -1;
          }
          if (!ast.ref_is_null(arg_ref)) {
            arg_type_ref = pipeline_expr_resolved_type_ref(arena, arg_ref);
          }
          if (codegen_emit_async_run_seed_push_name(out, arena, arg_type_ref) != 0) {
            return -1;
          }
          if (append_byte(out, 40) != 0) {
            return -1;
          }
          if (!ast.ref_is_null(arg_ref) && emit_expr(arena, out, arg_ref, ctx) != 0) {
            return -1;
          }
          if (append_byte(out, 41) != 0) {
            return -1;
          }
          ai = ai + 1;
        }
        if (emit_bytes_3(out, comma, 2) != 0) {
          return -1;
        }
        if (codegen_emit_async_sched_call_by_name(out, &callee_e.field_access_field_name[0], callee_e.field_access_field_len) != 0) {
          return -1;
        }
        return append_byte(out, 41);
      }
      return codegen_emit_async_sched_call_by_name(out, &callee_e.field_access_field_name[0], callee_e.field_access_field_len);
    }
    dep_ix = codegen_resolve_binding_import_dep_index(ctx, arena, call_e.call_callee_ref);
    if (dep_ix < 0 || dep_ix >= pipeline_dep_ctx_ndep(ctx)) {
      return -1;
    }
    pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, &dep_path[0]);
    codegen_import_path_to_c_prefix_into(&dep_path[0], &prefix_buf[0], 128);
    while (prefix_len < 128 && prefix_buf[prefix_len] != 0) {
      prefix_len = prefix_len + 1;
    }
    if (n_args > 0) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      ai = 0;
      while (ai < n_args) {
        let arg_ref2: i32 = pipeline_expr_call_arg_ref(arena, call_expr_ref, ai);
        let arg_type_ref2: i32 = 0;
        if (ai > 0 && emit_bytes_3(out, comma, 2) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(arg_ref2)) {
          arg_type_ref2 = pipeline_expr_resolved_type_ref(arena, arg_ref2);
        }
        if (codegen_emit_async_run_seed_push_name(out, arena, arg_type_ref2) != 0) {
          return -1;
        }
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(arg_ref2) && emit_expr(arena, out, arg_ref2, ctx) != 0) {
          return -1;
        }
        if (append_byte(out, 41) != 0) {
          return -1;
        }
        ai = ai + 1;
      }
      if (emit_bytes_3(out, comma, 2) != 0) {
        return -1;
      }
      if (codegen_emit_async_task_submit_call_by_symbol(out, &prefix_buf[0], prefix_len, &callee_e.field_access_field_name[0], callee_e.field_access_field_len) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    return codegen_emit_async_task_submit_call_by_symbol(out, &prefix_buf[0], prefix_len, &callee_e.field_access_field_name[0], callee_e.field_access_field_len);
  }
}

/** Exported function `codegen_emit_async_method_call_run`.
 * Implements `codegen_emit_async_method_call_run`.
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param method_expr_ref i32
 * @param ctx *PipelineDepCtx
 * @return i32
 */
export function codegen_emit_async_method_call_run(arena: *ASTArena, out: *CodegenOutBuf, method_expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let reset_name: u8[26] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 114, 101, 115, 101, 116];
    let comma: u8[3] = [44, 32, 0];
    let ai: i32 = 0;
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
      return -1;
    }
    if (ast.ref_is_null(method_expr_ref) || method_expr_ref <= 0 || method_expr_ref > arena.num_exprs) {
      return -1;
    }
    let method_e: Expr = ast.ast_arena_expr_get(arena, method_expr_ref);
    if (method_e.kind != ExprKind.EXPR_METHOD_CALL || method_e.method_call_name_len <= 0) {
      return -1;
    }
    if (method_e.method_call_num_args > 0) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_bytes_from_ptr(out, &reset_name[0], 25) != 0) {
        return -1;
      }
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (append_byte(out, 41) != 0) {
        return -1;
      }
      while (ai < method_e.method_call_num_args) {
        let arg_ref: i32 = pipeline_expr_method_call_arg_ref(arena, method_expr_ref, ai);
        let arg_type_ref: i32 = 0;
        if (emit_bytes_3(out, comma, 2) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(arg_ref)) {
          arg_type_ref = pipeline_expr_resolved_type_ref(arena, arg_ref);
        }
        if (codegen_emit_async_run_seed_push_name(out, arena, arg_type_ref) != 0) {
          return -1;
        }
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(arg_ref) && emit_expr(arena, out, arg_ref, ctx) != 0) {
          return -1;
        }
        if (append_byte(out, 41) != 0) {
          return -1;
        }
        ai = ai + 1;
      }
      if (emit_bytes_3(out, comma, 2) != 0) {
        return -1;
      }
      if (codegen_emit_async_sched_call_by_name(out, &method_e.method_call_name[0], method_e.method_call_name_len) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    return codegen_emit_async_sched_call_by_name(out, &method_e.method_call_name[0], method_e.method_call_name_len);
  }
}

/** Exported function `codegen_find_module_func_index_by_name`.
 * Implements `codegen_find_module_func_index_by_name`.
 * @param module *Module
 * @param nm *u8
 * @param nm_len i32
 * @return i32
 */
export function codegen_find_module_func_index_by_name(module: *Module, nm: *u8, nm_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (module == 0 as *Module || nm == 0 as *u8 || nm_len <= 0) {
      return -1;
    }
    let fi: i32 = 0;
    while (fi < module.num_funcs) {
      let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
      if (fn_len == nm_len && fn_len > 0) {
        let fn_name: u8[64] = [];
        let matched: i32 = 1;
        let bi: i32 = 0;
        pipeline_module_func_name_copy64(module, fi, &fn_name[0]);
        while (bi < fn_len) {
          if (fn_name[bi] != nm[bi]) {
            matched = 0;
            bi = fn_len;
          } else {
            bi = bi + 1;
          }
        }
        if (matched != 0) {
          return fi;
        }
      }
      fi = fi + 1;
    }
    return -1;
  }
}

/** Exported function `codegen_resolve_binding_import_dep_index`.
 * Implements `codegen_resolve_binding_import_dep_index`.
 * @param ctx *PipelineDepCtx
 * @param arena *ASTArena
 * @param callee_expr_ref i32
 * @return i32
 */
export function codegen_resolve_binding_import_dep_index(ctx: *PipelineDepCtx, arena: *ASTArena, callee_expr_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || arena == 0 as *ASTArena || ctx.current_codegen_module == 0 as *Module) {
      return -1;
    }
    if (ast.ref_is_null(callee_expr_ref) || callee_expr_ref <= 0 || callee_expr_ref > arena.num_exprs) {
      return -1;
    }
    let callee_e: Expr = ast.ast_arena_expr_get(arena, callee_expr_ref);
    if (callee_e.kind != ExprKind.EXPR_FIELD_ACCESS || callee_e.field_access_base_ref <= 0 || callee_e.field_access_base_ref > arena.num_exprs) {
      return -1;
    }
    let base_e: Expr = ast.ast_arena_expr_get(arena, callee_e.field_access_base_ref);
    if (base_e.kind != ExprKind.EXPR_VAR || base_e.var_name_len <= 0 || base_e.var_name_len > 63) {
      return -1;
    }
    let cur_mod: *Module = ctx.current_codegen_module;
    let nd: i32 = pipeline_dep_ctx_ndep(ctx);
    let j: i32 = 0;
    let n_imp: i32 = codegen_module_num_imports(cur_mod);
    while (j < n_imp && j < nd) {
      if (pipeline_module_import_kind_at(cur_mod, j) == 1) {
        let bind_len: i32 = pipeline_module_import_binding_name_len(cur_mod, j);
        if (bind_len == base_e.var_name_len) {
          let matched: i32 = 1;
          let kk: i32 = 0;
          while (kk < bind_len) {
            if (base_e.var_name[kk] != pipeline_module_import_binding_name_byte_at(cur_mod, j, kk)) {
              matched = 0;
              kk = bind_len;
            } else {
              kk = kk + 1;
            }
          }
          if (matched != 0) {
            let import_path: u8[64] = [];
            let import_path_len: i32 = codegen_module_import_path_len_at(cur_mod, j, &import_path[0]);
            if (import_path_len <= 0) {
              return -1;
            }
            return codegen_find_dep_index_by_path(ctx, &import_path[0], import_path_len);
          }
        }
      }
      j = j + 1;
    }
    return -1;
  }
}

/** Exported function `codegen_find_module_func_index_by_name_overload`.
 * Implements `codegen_find_module_func_index_by_name_overload`.
 * Overload-aware fallback: when typeck did not set call_resolved_func_index (e.g. dep
 * module body not typeck'd), score same-name funcs by arg resolved_type vs param type
 * and pick the best. Falls back to first-match when no args or all scores tie.
 * Why: codegen_find_module_func_index_by_name returns the FIRST match by name, which is
 * wrong when a module has same-name overloads (std_simd mul Vec8i vs Vec4f). Without this,
 * dot(a:Vec4f,b:Vec4f) { return hsum(mul(a,b)); } emits the Vec8i mul (first) -> cc
 * "conflicting types". PLATFORM: SHARED.
 * @param arena *ASTArena
 * @param module *Module
 * @param call_expr_ref i32
 * @param nm *u8
 * @param nm_len i32
 * @return i32
 */
export function codegen_find_module_func_index_by_name_overload(arena: *ASTArena, module: *Module,
call_expr_ref: i32, nm: *u8, nm_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let fi: i32 = 0;
    let first_idx: i32 = -1;
    let best_idx: i32 = -1;
    let best_score: i32 = -1;
    let num_args: i32 = 0;
    if (module == 0 as *Module || nm == 0 as *u8 || nm_len <= 0) {
      return -1;
    }
    if (call_expr_ref > 0 && call_expr_ref <= arena.num_exprs) {
      num_args = pipeline_expr_call_num_args_at(arena, call_expr_ref);
    }
    while (fi < module.num_funcs) {
      let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
      if (fn_len == nm_len && fn_len > 0) {
        let fn_name: u8[64] = [];
        let matched: i32 = 1;
        let bi: i32 = 0;
        pipeline_module_func_name_copy64(module, fi, &fn_name[0]);
        while (bi < fn_len) {
          if (fn_name[bi] != nm[bi]) {
            matched = 0;
            bi = fn_len;
          } else {
            bi = bi + 1;
          }
        }
        if (matched != 0) {
          if (first_idx < 0) {
            first_idx = fi;
          }
          if (num_args > 0) {
            let np: i32 = pipeline_module_func_num_params_at(module, fi);
            if (np == num_args) {
              let ai: i32 = 0;
              let score: i32 = 0;
              let ok: i32 = 1;
              while (ai < num_args) {
                let arg_ref: i32 = pipeline_expr_call_arg_ref(arena, call_expr_ref, ai);
                let param_ty: i32 = pipeline_module_func_param_type_ref_at(module, fi, ai);
                let arg_ty: i32 = 0;
                let sc: i32 = 0;
                if (arg_ref <= 0) {
                  ok = 0;
                  break;
                }
                arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
                if (arg_ty > 0 && param_ty > 0 && pipeline_typeck_type_refs_equal_c(arena, arg_ty, param_ty) != 0) {
                  sc = 1000;
                } else if (arg_ty > 0 && param_ty > 0) {
                  let ak: i32 = pipeline_type_kind_ord_at(arena, arg_ty);
                  let pk: i32 = pipeline_type_kind_ord_at(arena, param_ty);
                  if (ak == pk && ak != 0) {
                    sc = 1;
                  } else {
                    sc = -1;
                  }
                } else {
                  sc = 0;
                }
                if (sc < 0) {
                  ok = 0;
                  break;
                }
                score = score + sc;
                ai = ai + 1;
              }
              if (ok != 0 && score > best_score) {
                best_score = score;
                best_idx = fi;
              }
            }
          }
        }
      }
      fi = fi + 1;
    }
    if (best_idx >= 0) {
      return best_idx;
    }
    return first_idx;
  }
}

/** Exported function `codegen_resolve_call_target_func_index`.
 * Implements `codegen_resolve_call_target_func_index`.
 * @param arena *ASTArena
 * @param module *Module
 * @param call_expr_ref i32
 * @return i32
 */
export function codegen_resolve_call_target_func_index(arena: *ASTArena, module: *Module, call_expr_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let func_ix: i32 = -1;
    if (module == 0 as *Module || arena == 0 as *ASTArena) {
      return -1;
    }
    func_ix = pipeline_expr_call_resolved_func_index_at(arena, call_expr_ref);
    if (func_ix >= 0 && func_ix < module.num_funcs) {
      return func_ix;
    }
    if (ast.ref_is_null(call_expr_ref) || call_expr_ref <= 0 || call_expr_ref > arena.num_exprs) {
      return -1;
    }
    let call_e: Expr = ast.ast_arena_expr_get(arena, call_expr_ref);
    if (call_e.kind == ExprKind.EXPR_CALL) {
      if (ast.ref_is_null(call_e.call_callee_ref) || call_e.call_callee_ref <= 0 || call_e.call_callee_ref > arena.num_exprs) {
        return -1;
      }
      let callee_e: Expr = ast.ast_arena_expr_get(arena, call_e.call_callee_ref);
      if (callee_e.kind == ExprKind.EXPR_VAR && callee_e.var_name_len > 0) {
        return codegen_find_module_func_index_by_name_overload(arena, module, call_expr_ref, &callee_e.var_name[0], callee_e.var_name_len);
      }
      if (callee_e.kind == ExprKind.EXPR_FIELD_ACCESS && callee_e.field_access_field_len > 0) {
        return codegen_find_module_func_index_by_name_overload(arena, module, call_expr_ref, &callee_e.field_access_field_name[0], callee_e.field_access_field_len);
      }
      return -1;
    }
    if (call_e.kind == ExprKind.EXPR_METHOD_CALL && call_e.method_call_name_len > 0) {
      return codegen_find_module_func_index_by_name_overload(arena, module, call_expr_ref, &call_e.method_call_name[0], call_e.method_call_name_len);
    }
    return -1;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function expr_var_matches_func_param_index(arena: *ASTArena, var_ref: i32, mod: *Module, func_index: i32, param_idx: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ast.ref_is_null(var_ref) || var_ref <= 0 || var_ref > arena.num_exprs) {
      return 0;
    }
    if (func_index < 0 || func_index >= mod.num_funcs) {
      return 0;
    }
    /* See implementation. */
    let np: i32 = pipeline_module_func_num_params_at(mod, func_index);
    if (param_idx < 0 || param_idx >= np) {
      return 0;
    }
    let base: Expr = ast.ast_arena_expr_get(arena, var_ref);
    if (base.kind != ExprKind.EXPR_VAR) {
      return 0;
    }
    let p_name_len: i32 = pipeline_module_func_param_name_len_at(mod, func_index, param_idx);
    if (p_name_len > 0) {
      let pname_buf: u8[32] = [];
      pipeline_module_func_param_name_copy32(mod, func_index, param_idx, &pname_buf[0]);
      if (pname_buf[0] > 32) {
        if (base.var_name_len != p_name_len) {
          return 0;
        }
        if (base.var_name_len <= 0 || (base.var_name[0] <= 32)) {
          return 0;
        }
        let j: i32 = 0;
        while (j < p_name_len) {
          if (base.var_name[j] != pname_buf[j]) {
            return 0;
          }
          j = j + 1;
        }
        return 1;
      }
    }
    if (ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    if (ctx.current_func_single_empty_param_index != param_idx) {
      return 0;
    }
    if (base.var_name_len <= 0 || (base.var_name[0] <= 32)) {
      return 1;
    }
    return 0;
  }
}

/** Exported function `codegen_symbuf_bytes_eq`.
 * Implements `codegen_symbuf_bytes_eq`.
 * @param buf *u8
 * @param buf_len i32
 * @param lit *u8
 * @param lit_len i32
 * @return i32
 */
export function codegen_symbuf_bytes_eq(buf: *u8, buf_len: i32, lit: *u8, lit_len: i32): i32 {
  if (buf == 0 as *u8 || lit == 0 as *u8 || buf_len != lit_len) {
    return 0;
  }
  let i: i32 = 0;
  while (i < lit_len) {
    if (buf[i] != lit[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_call_num_args_override(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, num_args: i32): i32 {
  if (num_args <= 0) {
    return num_args;
  }
  let buf: u8[96] = [];
  let full: i32 = 0;
  let i: i32 = 0;
  if (prefix != 0 as *u8 && prefix_len > 0) {
    i = 0;
    while (i < prefix_len && full < 96) {
      buf[full] = prefix[i];
      full = full + 1;
      i = i + 1;
    }
  }
  if (name != 0 as *u8 && name_len > 0) {
    i = 0;
    while (i < name_len && full < 96) {
      buf[full] = name[i];
      full = full + 1;
      i = i + 1;
    }
  }
  let z0: u8[13] = [118,101,99,95,108,101,110,95,101,109,112,116,121];
  let z1: u8[21] = [115,116,100,95,118,101,99,95,118,101,99,95,108,101,110,95,101,109,112,116,121];
  let z2: u8[15] = [97,108,108,111,99,95,115,105,122,101,95,122,101,114,111];
  let z3: u8[24] = [115,116,100,95,104,101,97,112,95,97,108,108,111,99,95,115,105,122,101,95,122,101,114,111];
  let z4: u8[13] = [114,117,110,116,105,109,101,95,114,101,97,100,121];
  let z5: u8[25] = [115,116,100,95,114,117,110,116,105,109,101,95,114,117,110,116,105,109,101,95,114,101,97,100,121];
  let z6: u8[10] = [115,116,114,105,110,103,95,110,101,119];
  let z7: u8[21] = [115,116,100,95,115,116,114,105,110,103,95,115,116,114,105,110,103,95,110,101,119];
  let z8: u8[11] = [112,108,97,99,101,104,111,108,100,101,114];
  let z9: u8[22] = [115,116,100,95,115,116,114,105,110,103,95,112,108,97,99,101,104,111,108,100,101,114];
  let z10: u8[11] = [116,104,114,101,97,100,95,115,101,108,102];
  let z11: u8[22] = [115,116,100,95,116,104,114,101,97,100,95,116,104,114,101,97,100,95,115,101,108,102];
  let z12: u8[22] = [116,104,114,101,97,100,95,100,117,109,109,121,95,101,110,116,114,121,95,112,116,114];
  let z13: u8[33] = [115,116,100,95,116,104,114,101,97,100,95,116,104,114,101,97,100,95,100,117,109,109,121,95,101,110,116,114,121,95,112,116,114];
  let z14: u8[16] = [110,111,119,95,109,111,110,111,116,111,110,105,99,95,110,115];
  let z15: u8[25] = [115,116,100,95,116,105,109,101,95,110,111,119,95,109,111,110,111,116,111,110,105,99,95,110,115];
  let z16: u8[16] = [110,111,119,95,109,111,110,111,116,111,110,105,99,95,109,115];
  let z17: u8[25] = [115,116,100,95,116,105,109,101,95,110,111,119,95,109,111,110,111,116,111,110,105,99,95,109,115];
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z0[0], 13) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z1[0], 21) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z2[0], 15) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z3[0], 24) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z4[0], 13) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z5[0], 25) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z6[0], 10) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z7[0], 21) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z8[0], 11) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z9[0], 22) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z10[0], 11) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z11[0], 22) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z12[0], 22) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z13[0], 33) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z14[0], 16) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z15[0], 25) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z16[0], 16) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z17[0], 25) != 0) {
    return 0;
  }
  if (num_args >= 1) {
    let o0: u8[7] = [102,109,116,95,105,51,50];
    let o1: u8[16] = [99,111,114,101,95,102,109,116,95,102,109,116,95,105,51,50];
    let o2: u8[9] = [112,114,105,110,116,95,105,51,50];
    let o3: u8[16] = [115,116,100,95,105,111,95,112,114,105,110,116,95,105,51,50];
    let o4: u8[9] = [112,114,105,110,116,95,117,51,50];
    let o5: u8[16] = [115,116,100,95,105,111,95,112,114,105,110,116,95,117,51,50];
    let o6: u8[9] = [112,114,105,110,116,95,105,54,52];
    let o7: u8[16] = [115,116,100,95,105,111,95,112,114,105,110,116,95,105,54,52];
    let o8: u8[6] = [111,107,95,105,51,50];
    let o9: u8[18] = [99,111,114,101,95,114,101,115,117,108,116,95,111,107,95,105,51,50];
    let o10: u8[7] = [101,114,114,95,105,51,50];
    let o11: u8[19] = [99,111,114,101,95,114,101,115,117,108,116,95,101,114,114,95,105,51,50];
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o0[0], 7) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o1[0], 16) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o2[0], 9) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o3[0], 16) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o4[0], 9) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o5[0], 16) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o6[0], 9) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o7[0], 16) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o8[0], 6) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o9[0], 18) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o10[0], 7) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o11[0], 19) != 0) {
      return 1;
    }
  }
  return num_args;
}

/**
 * See implementation.
 */
export function codegen_name_bytes_prefix_eq(name: *u8, name_len: i32, expect: *u8, exp_len: i32): i32 {
  if (name == 0 as *u8 || expect == 0 as *u8 || name_len < exp_len) {
    return 0;
  }
  let i: i32 = 0;
  while (i < exp_len) {
    if (name[i] != expect[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_is_std_io_driver_bridge_name(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8) {
    return 0;
  }
  /* register — 8 */
  let nm8: u8[8] = [114, 101, 103, 105, 115, 116, 101, 114];
  if ((name_len == 8 || name_len == 9) && codegen_name_bytes_prefix_eq(name, name_len, &nm8[0], 8) != 0) {
    return 1;
  }
  /* submit_read — 11 */
  let nm11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  if ((name_len == 11 || name_len == 12) && codegen_name_bytes_prefix_eq(name, name_len, &nm11[0], 11) != 0) {
    return 1;
  }
  /* submit_write — 12 */
  let nm12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  if ((name_len == 12 || name_len == 13) && codegen_name_bytes_prefix_eq(name, name_len, &nm12[0], 12) != 0) {
    return 1;
  }
  /* wait_readable — 13 */
  let nm13: u8[13] = [119, 97, 105, 116, 95, 114, 101, 97, 100, 97, 98, 108, 101];
  if ((name_len == 13 || name_len == 14) && codegen_name_bytes_prefix_eq(name, name_len, &nm13[0], 13) != 0) {
    return 1;
  }
  /* register_fixed_buffers — 22 */
  let nm22: u8[22] = [114, 101, 103, 105, 115, 116, 101, 114, 95, 102, 105, 120, 101, 100, 95, 98, 117, 102, 102, 101, 114, 115];
  if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, &nm22[0], 22) != 0) {
    return 1;
  }
  /* See implementation. */
  return 0;
}

/**
 * Skip emitting std.io.core bodies that duplicate runtime/io.o strong symbols.
 *
 * Purpose: when product C co-emits std.io.core, do not redefine xlang_io_read_fixed
 * (and siblings) that product preamble already provides as weak stubs / io.o.
 *
 * Parameters:
 *   dep_path  — module path bytes; must start with "std.io.core" (11 bytes).
 *   name      — bare function name (no module prefix).
 *   name_len  — name length; allow exact or exact+1 (historical trailing-NUL window).
 *
 * Returns 1 to skip emit, 0 to emit.
 *
 * Contract: match tables use full "xlang_io_*" (with 'x'), never historic "shu_io_*" brand.
 * Batch names are checked before short submit_read/write prefixes.
 * PLATFORM: SHARED — link-name contract; Cap force + pin product matrix.
 */
export function codegen_should_skip_emit_std_io_core_io_dup(dep_path: *u8, name: *u8, name_len: i32): i32 {
  let path_core: u8[11] = [115, 116, 100, 46, 105, 111, 46, 99, 111, 114, 101];
  /* xlang_io_read_fixed — 18 (preamble weak returns -1; avoid redef with weak). */
  let n_rf: u8[19] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 97, 100, 95, 102, 105, 120, 101, 100];
  /* xlang_io_write_fixed — 19 */
  let n_wf: u8[20] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 119, 114, 105, 116, 101, 95, 102, 105, 120, 101, 100];
  /*
   * See implementation.
   * See implementation.
   * See implementation.
   * See implementation.
   * See implementation.
   * Do NOT skip xlang_io_submit_write either (no weak; Cap force hello residual).
   * PLATFORM: SHARED — product C path; Cap force + pin seed.
   */
  let di: i32 = 0;
  if (dep_path == 0 as *u8 || name == 0 as *u8) {
    return 0;
  }
  while (di < 11) {
    if (dep_path[di] != path_core[di]) {
      return 0;
    }
    di = di + 1;
  }
  if ((name_len == 18 || name_len == 19) && codegen_name_bytes_prefix_eq(name, name_len, &n_rf[0], 18) != 0) {
    return 1;
  }
  if ((name_len == 19 || name_len == 20) && codegen_name_bytes_prefix_eq(name, name_len, &n_wf[0], 19) != 0) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_should_skip_emit_std_io_trivial_handle(dep_path: *u8, name: *u8, name_len: i32): i32 {
  let path_io: u8[7] = [115, 116, 100, 46, 105, 111, 0];
  let h_stdin: u8[12] = [104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 105, 110];
  let h_stdout: u8[13] = [104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 111, 117, 116];
  let h_stderr: u8[13] = [104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 101, 114, 114];
  let h_from_fd: u8[15] = [104, 97, 110, 100, 108, 101, 95, 102, 114, 111, 109, 95, 102, 100, 0];
  let di: i32 = 0;
  if (name == 0 as *u8) {
    return 0;
  }
  if (dep_path != 0 as *u8) {
    while (di < 7) {
      if (dep_path[di] != path_io[di]) {
        return 0;
      }
      di = di + 1;
    }
  }
  if ((name_len == 12 || name_len == 13) && codegen_name_bytes_prefix_eq(name, name_len, &h_stdin[0], 12) != 0) {
    return 1;
  }
  if ((name_len == 13 || name_len == 14) && codegen_name_bytes_prefix_eq(name, name_len, &h_stdout[0], 13) != 0) {
    return 1;
  }
  if ((name_len == 13 || name_len == 14) && codegen_name_bytes_prefix_eq(name, name_len, &h_stderr[0], 13) != 0) {
    return 1;
  }
  if ((name_len == 15 || name_len == 16) && codegen_name_bytes_prefix_eq(name, name_len, &h_from_fd[0], 15) != 0) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_should_skip_emit_func(dep_path: *u8, prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  /* See implementation. */
  let full33: u8[33] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110];
  let full29: u8[29] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114];
  /* See implementation. */
  let path_driver: u8[14] = [115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0];
  let path_io: u8[7] = [115, 116, 100, 46, 105, 111, 0];
  /* See implementation. */
  let nm_len19: u8[19] = [100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110];
  let nm_len15: u8[15] = [100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114];
  /* driver_read_ptr_gen — 19 (same length as ptr_len; distinct suffix) */
  let nm_gen19: u8[19] = [100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 103, 101, 110];
  let pi: i32 = 0;
  let ni: i32 = 0;
  let ok_path: i32 = 0;
  let di: i32 = 0;
  /* full33_gen: std_io_driver_driver_read_ptr_gen (33) — same length as ptr_len; must not early-return 0 on mismatch. */
  let full33_gen: u8[33] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 103, 101, 110];
  if (prefix != 0 as *u8 && prefix_len > 0 && name != 0 as *u8 && name_len > 0) {
    let total_len: i32 = prefix_len + name_len;
    if (total_len == 33) {
      let match_len: i32 = 1;
      let match_gen: i32 = 1;
      pi = 0;
      while (pi < prefix_len) {
        if (prefix[pi] != full33[pi]) {
          match_len = 0;
        }
        if (prefix[pi] != full33_gen[pi]) {
          match_gen = 0;
        }
        pi = pi + 1;
      }
      ni = 0;
      while (ni < name_len) {
        if (name[ni] != full33[prefix_len + ni]) {
          match_len = 0;
        }
        if (name[ni] != full33_gen[prefix_len + ni]) {
          match_gen = 0;
        }
        ni = ni + 1;
      }
      if (match_len != 0 || match_gen != 0) {
        return 1;
      }
      /* fall through — other total-33 names are not auto-skipped */
    }
    if (total_len == 29) {
      pi = 0;
      while (pi < prefix_len) {
        if (prefix[pi] != full29[pi]) {
          /* fall through on mismatch (do not abort whole skip) */
          pi = prefix_len + 1;
          break;
        }
        pi = pi + 1;
      }
      if (pi == prefix_len) {
        ni = 0;
        while (ni < name_len) {
          if (name[ni] != full29[prefix_len + ni]) {
            ni = name_len + 1;
            break;
          }
          ni = ni + 1;
        }
        if (ni == name_len) {
          return 1;
        }
      }
    }
  }
  if (dep_path != 0 as *u8) {
    ok_path = 0;
    di = 0;
    while (di < 14) {
      if (dep_path[di] != path_driver[di]) {
        ok_path = 0;
        break;
      }
      di = di + 1;
    }
    if (di == 14) {
      ok_path = 1;
    }
    if (ok_path == 0) {
      di = 0;
      while (di < 7) {
        if (dep_path[di] != path_io[di]) {
          ok_path = 0;
          break;
        }
        di = di + 1;
      }
      if (di == 7) {
        ok_path = 1;
      }
    }
    if (ok_path != 0 && name != 0 as *u8) {
      if ((name_len == 19 || name_len == 20) && codegen_name_bytes_prefix_eq(name, name_len, &nm_len19[0], 19) != 0) {
        return 1;
      }
      if ((name_len == 19 || name_len == 20) && codegen_name_bytes_prefix_eq(name, name_len, &nm_gen19[0], 19) != 0) {
        return 1;
      }
      if ((name_len == 15 || name_len == 16) && codegen_name_bytes_prefix_eq(name, name_len, &nm_len15[0], 15) != 0) {
        return 1;
      }
    }
  }
  /* See implementation. */
  let pref_abi14: u8[14] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95];
  if (prefix != 0 as *u8 && prefix_len == 14 && name != 0 as *u8 && codegen_name_bytes_prefix_eq(prefix, prefix_len, &pref_abi14[0], 14) != 0) {
    if (codegen_is_std_io_driver_bridge_name(name, name_len) != 0) {
      return 1;
    }
  }
  if (dep_path != 0 as *u8 && name != 0 as *u8) {
    let ok_drv_only: i32 = 0;
    di = 0;
    while (di < 14) {
      if (dep_path[di] != path_driver[di]) {
        ok_drv_only = 0;
        break;
      }
      di = di + 1;
    }
    if (di == 14) {
      ok_drv_only = 1;
    }
    if (ok_drv_only != 0 && codegen_is_std_io_driver_bridge_name(name, name_len) != 0) {
      return 1;
    }
  }
  /* See implementation. */
  if (prefix != 0 as *u8 && prefix_len == 14 && name != 0 as *u8
      && codegen_name_bytes_prefix_eq(prefix, prefix_len, &pref_abi14[0], 14) != 0) {
    if (codegen_should_skip_emit_std_io_trivial_handle(0 as *u8, name, name_len) != 0) {
      return 1;
    }
  }
  if (dep_path != 0 as *u8 && name != 0 as *u8) {
    if (codegen_should_skip_emit_std_io_core_io_dup(dep_path, name, name_len) != 0) {
      return 1;
    }
    let path_driver: u8[14] = [115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0];
    let di2: i32 = 0;
    while (di2 < 14) {
      if (dep_path[di2] != path_driver[di2]) {
        break;
      }
      di2 = di2 + 1;
    }
    if (di2 == 14 && codegen_should_skip_emit_std_io_trivial_handle(0 as *u8, name, name_len) != 0) {
      return 1;
    }
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_force_param_std_io_driver_prefix_ok(prefix: *u8, prefix_len: i32): i32 {
  let exp13: u8[13] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114];
  if (prefix == 0 as *u8 || prefix_len < 13) {
    return 0;
  }
  let i: i32 = 0;
  while (i < 13) {
    if (prefix[i] != exp13[i]) {
      return 0;
    }
    i = i + 1;
  }
  if (prefix_len > 13) {
    let b14: u8 = prefix[13];
    if (b14 != 0 as u8 && b14 != 95 as u8) {
      return 0;
    }
  }
  return 1;
}

/**
 * See implementation.
 */
export function codegen_force_param_size_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  let rd_batch: u8[21] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  let wr_batch: u8[22] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  if (param_index != 0) {
    return 0;
  }
  if (codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len == 21 && codegen_name_bytes_prefix_eq(name, name_len, &rd_batch[0], 21) != 0) {
    return 1;
  }
  if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, &wr_batch[0], 22) != 0) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_force_param_size_t_std_io_print_str_second(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  if (param_index != 1) {
    return 0;
  }
  if (name == 0 as *u8 || name_len != 5) {
    return 0;
  }
  /* "print" */
  if (name[0] != 112 || name[1] != 114 || name[2] != 105 || name[3] != 110 || name[4] != 116) {
    return 0;
  }
  let exp7: u8[7] = [115, 116, 100, 95, 105, 111, 95];
  if (prefix == 0 as *u8 || prefix_len < 7) {
    return 0;
  }
  let i: i32 = 0;
  while (i < 7) {
    if (prefix[i] != exp7[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * See implementation.
 */
export function codegen_force_param_ptrdiff_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  let reg8: u8[8] = [114, 101, 103, 105, 115, 116, 101, 114];
  let rd11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  let wr12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  if (param_index != 0) {
    return 0;
  }
  if (codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len == 8 && codegen_name_bytes_prefix_eq(name, name_len, &reg8[0], 8) != 0) {
    return 1;
  }
  if (name_len == 11 && codegen_name_bytes_prefix_eq(name, name_len, &rd11[0], 11) != 0) {
    return 1;
  }
  if (name_len == 12 && codegen_name_bytes_prefix_eq(name, name_len, &wr12[0], 12) != 0) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 */
export function codegen_force_param_uint32_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  let rd11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  let wr12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  let reg_fixed_buf: u8[33] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 102, 105, 120, 101, 100, 95, 98, 117, 102, 102, 101, 114, 115, 95, 98, 117, 102];
  let rd_batch: u8[21] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  let wr_batch: u8[22] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  if (codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (param_index == 1) {
    if (name_len == 11 && codegen_name_bytes_prefix_eq(name, name_len, &rd11[0], 11) != 0) {
      return 1;
    }
    if (name_len == 12 && codegen_name_bytes_prefix_eq(name, name_len, &wr12[0], 12) != 0) {
      return 1;
    }
    if (name_len == 33 && codegen_name_bytes_prefix_eq(name, name_len, &reg_fixed_buf[0], 33) != 0) {
      return 1;
    }
    return 0;
  }
  if (param_index == 3) {
    if (name_len == 21 && codegen_name_bytes_prefix_eq(name, name_len, &rd_batch[0], 21) != 0) {
      return 1;
    }
    if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, &wr_batch[0], 22) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/**
 * See implementation.
 */
export function codegen_use_buf_wrapper(name: *u8, name_len: i32, num_args: i32): i32 {
  let reg15: u8[15] = [115, 104, 117, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114];
  let rd18: u8[18] = [115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  let wr19: u8[19] = [115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  if (name == 0 as *u8 || name_len <= 0) {
    return 0;
  }
  if (num_args == 1 && name_len == 15 && codegen_name_bytes_prefix_eq(name, name_len, &reg15[0], 15) != 0) {
    return 1;
  }
  if (num_args == 2 && name_len == 18 && codegen_name_bytes_prefix_eq(name, name_len, &rd18[0], 18) != 0) {
    return 1;
  }
  if (num_args == 2 && name_len == 19 && codegen_name_bytes_prefix_eq(name, name_len, &wr19[0], 19) != 0) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_emit_io_driver_buf_call_name(out: *CodegenOutBuf, name: *u8, name_len: i32, num_args: i32): i32 {
  let reg8: u8[8] = [114, 101, 103, 105, 115, 116, 101, 114];
  let rd11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  let wr12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  /* See implementation. */
  let sym_reg: u8[21] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102];
  let sym_rd: u8[24] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 117, 102];
  let sym_wr: u8[25] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 117, 102];
  if (name == 0 as *u8 || name_len <= 0) {
    return 0;
  }
  if (num_args == 1 && name_len == 8 && codegen_name_bytes_prefix_eq(name, name_len, &reg8[0], 8) != 0) {
    if (emit_bytes_from_ptr(out, &sym_reg[0], 20) != 0) {
      return -1;
    }
    return 1;
  }
  if (num_args == 2 && name_len == 11 && codegen_name_bytes_prefix_eq(name, name_len, &rd11[0], 11) != 0) {
    if (emit_bytes_from_ptr(out, &sym_rd[0], 23) != 0) {
      return -1;
    }
    return 1;
  }
  if (num_args == 2 && name_len == 12 && codegen_name_bytes_prefix_eq(name, name_len, &wr12[0], 12) != 0) {
    if (emit_bytes_from_ptr(out, &sym_wr[0], 24) != 0) {
      return -1;
    }
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_try_emit_std_io_driver_buf_body(out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let fn_local: u8[64] = [];
    let fn_len: i32 = 0;
    let nparams: i32 = 0;
    let p0: u8[32] = [98, 117, 102, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let p1: u8[32] = [116, 105, 109, 101, 111, 117, 116, 95, 109, 115, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let reg8: u8[8] = [114, 101, 103, 105, 115, 116, 101, 114];
    let rd11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
    let wr12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
    let sym_reg: u8[21] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102];
    let sym_rd: u8[24] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 117, 102];
    let sym_wr: u8[25] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 117, 102];
    let ret_kw: u8[8] = [32, 32, 114, 101, 116, 117, 114, 110];
    let close_b: u8[3] = [10, 125, 0];
    if (codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {
      return 0;
    }
    let p0_len: i32 = 3;
    let p1_len: i32 = 10;
    pipeline_module_func_name_copy64(module, fi, &fn_local[0]);
    fn_len = pipeline_module_func_name_len_at(module, fi);
    nparams = pipeline_module_func_num_params_at(module, fi);
    if (pipeline_module_func_param_name_len_at(module, fi, 0) > 0) {
      pipeline_module_func_param_name_copy32(module, fi, 0, &p0[0]);
      p0_len = pipeline_module_func_param_name_len_at(module, fi, 0);
    }
    if (nparams > 1 && pipeline_module_func_param_name_len_at(module, fi, 1) > 0) {
      pipeline_module_func_param_name_copy32(module, fi, 1, &p1[0]);
      p1_len = pipeline_module_func_param_name_len_at(module, fi, 1);
    }
    if (fn_len == 8 && codegen_name_bytes_prefix_eq(&fn_local[0], fn_len, &reg8[0], 8) != 0 && nparams == 1) {
      if (emit_indent(out, 2) != 0) { return -1; }
      if (emit_bytes_from_ptr(out, &ret_kw[0], 8) != 0) { return -1; }
      if (emit_bytes_from_ptr(out, &sym_reg[0], 20) != 0) { return -1; }
      if (append_byte(out, 40) != 0) { return -1; }
      if (emit_bytes_from_ptr(out, &p0[0], p0_len) != 0) { return -1; }
      if (append_byte(out, 41) != 0) { return -1; }
      if (append_byte(out, 59) != 0) { return -1; }
      if (emit_bytes_from_ptr(out, &close_b[0], 2) != 0) { return -1; }
      return 1;
    }
    if (fn_len == 11 && codegen_name_bytes_prefix_eq(&fn_local[0], fn_len, &rd11[0], 11) != 0 && nparams == 2) {
      if (emit_indent(out, 2) != 0) { return -1; }
      if (emit_bytes_from_ptr(out, &ret_kw[0], 8) != 0) { return -1; }
      if (emit_bytes_from_ptr(out, &sym_rd[0], 23) != 0) { return -1; }
      if (append_byte(out, 40) != 0) { return -1; }
      if (emit_bytes_from_ptr(out, &p0[0], p0_len) != 0) { return -1; }
      let comma: u8[3] = [44, 32, 0];
      if (emit_bytes_3(out, comma, 2) != 0) { return -1; }
      if (emit_bytes_from_ptr(out, &p1[0], p1_len) != 0) { return -1; }
      if (append_byte(out, 41) != 0) { return -1; }
      if (append_byte(out, 59) != 0) { return -1; }
      if (emit_bytes_from_ptr(out, &close_b[0], 2) != 0) { return -1; }
      return 1;
    }
    if (fn_len == 12 && codegen_name_bytes_prefix_eq(&fn_local[0], fn_len, &wr12[0], 12) != 0 && nparams == 2) {
      if (emit_indent(out, 2) != 0) { return -1; }
      if (emit_bytes_from_ptr(out, &ret_kw[0], 8) != 0) { return -1; }
      if (emit_bytes_from_ptr(out, &sym_wr[0], 24) != 0) { return -1; }
      if (append_byte(out, 40) != 0) { return -1; }
      if (emit_bytes_from_ptr(out, &p0[0], p0_len) != 0) { return -1; }
      let comma2: u8[3] = [44, 32, 0];
      if (emit_bytes_3(out, comma2, 2) != 0) { return -1; }
      if (emit_bytes_from_ptr(out, &p1[0], p1_len) != 0) { return -1; }
      if (append_byte(out, 41) != 0) { return -1; }
      if (append_byte(out, 59) != 0) { return -1; }
      if (emit_bytes_from_ptr(out, &close_b[0], 2) != 0) { return -1; }
      return 1;
    }
    return 0;
  }
}

/** Exported function `field_access_base_is_pointer_ref`.
 * Implements `field_access_base_is_pointer_ref`.
 * @param arena *ASTArena
 * @param base_ref i32
 * @return i32
 */
export function field_access_base_is_pointer_ref(arena: *ASTArena, base_ref: i32): i32 {
  if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
    return 0;
  }
  let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
  if (ast.ref_is_null(base.resolved_type_ref) || base.resolved_type_ref <= 0 || base.resolved_type_ref > arena.num_types) {
    return 0;
  }
  let ty: Type = ast.ast_arena_type_get(arena, base.resolved_type_ref);
  if (ty.kind == TypeKind.TYPE_PTR) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function field_access_base_type_resolved(arena: *ASTArena, base_ref: i32): i32 {
  if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
    return 0;
  }
  let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
  if (ast.ref_is_null(base.resolved_type_ref) || base.resolved_type_ref <= 0 || base.resolved_type_ref > arena.num_types) {
    return 0;
  }
  return 1;
}

/**
 * PLATFORM: SHARED — C mirror of asm glue_asm_try_emit_fmt_string_lit_import_call.
 *
 * Product contract (std.fmt README): `print("…")` / `println("…")` single string
 * literal is a compiler specialization → call print/println(ptr, len) with the
 * literal length. Asm backend already does this; C must not fall through to the
 * bare `std_fmt_println(u8[]*)` overload with a raw pointer (empty stdout / UB).
 *
 * Returns: 1 if this call was fully emitted; 0 if not applicable; -1 on emit error.
 */
export function codegen_try_emit_fmt_string_lit_call(arena: *ASTArena, out: *CodegenOutBuf,
expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    let callee_ref: i32 = 0;
    let callee: Expr = e;
    let path: u8[64] = [];
    let path_len: i32 = 0;
    let pre: u8[128] = [];
    let pre_len: i32 = 0;
    let name_ptr: *u8 = 0 as *u8;
    let name_len: i32 = 0;
    let arg_ref: i32 = 0;
    let arg: Expr = e;
    let slen: i32 = 0;
    let mid: u8[12] = [95, 117, 56, 95, 112, 116, 114, 95, 105, 51, 50, 0]; /* _u8_ptr_i32 */
    let comma: u8[3] = [44, 32, 0];
    let is_method: i32 = 0;
    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    e = ast.ast_arena_expr_get(arena, expr_ref);
    /*
     * Product surface is binding.print/println("…"):
     * - METHOD_CALL: fmt.println("…")  (parser default)
     * - CALL + FIELD_ACCESS callee: fmt.println as callee (alt shape)
     */
    if (e.kind == ExprKind.EXPR_METHOD_CALL && e.method_call_num_args == 1
        && e.method_call_name_len > 0) {
      is_method = 1;
      name_len = e.method_call_name_len;
      name_ptr = &e.method_call_name[0];
      path_len = codegen_resolve_binding_import_path_for_method_call(ctx, arena, expr_ref, &path[0]);
      arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, 0);
    } else if (e.kind == ExprKind.EXPR_CALL && e.call_num_args == 1) {
      callee_ref = e.call_callee_ref;
      if (callee_ref <= 0 || callee_ref > arena.num_exprs) {
        return 0;
      }
      callee = ast.ast_arena_expr_get(arena, callee_ref);
      if (callee.kind != ExprKind.EXPR_FIELD_ACCESS || callee.field_access_field_len <= 0) {
        return 0;
      }
      name_len = callee.field_access_field_len;
      name_ptr = &callee.field_access_field_name[0];
      path_len = codegen_resolve_binding_import_path_for_field_access(ctx, arena, callee_ref, &path[0]);
      arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    } else {
      return 0;
    }
    /* println / print */
    if (name_len == 7 && name_ptr[0] == 112 && name_ptr[1] == 114 && name_ptr[2] == 105
        && name_ptr[3] == 110 && name_ptr[4] == 116 && name_ptr[5] == 108 && name_ptr[6] == 110) {
      /* println */
    } else if (name_len == 5 && name_ptr[0] == 112 && name_ptr[1] == 114 && name_ptr[2] == 105
        && name_ptr[3] == 110 && name_ptr[4] == 116) {
      /* print */
    } else {
      return 0;
    }
    if (path_len <= 0) {
      return 0;
    }
    /* std.fmt (7) or std.debug (9) */
    if (path_len == 7 && path[0] == 115 && path[1] == 116 && path[2] == 100 && path[3] == 46
        && path[4] == 102 && path[5] == 109 && path[6] == 116) {
      /* ok */
    } else if (path_len == 9 && path[0] == 115 && path[1] == 116 && path[2] == 100 && path[3] == 46
        && path[4] == 100 && path[5] == 101 && path[6] == 98 && path[7] == 117 && path[8] == 103) {
      /* ok */
    } else {
      return 0;
    }
    if (arg_ref <= 0 || arg_ref > arena.num_exprs) {
      return 0;
    }
    if (pipeline_expr_kind_ord_at(arena, arg_ref) != 59) {
      return 0;
    }
    arg = ast.ast_arena_expr_get(arena, arg_ref);
    slen = arg.var_name_len;
    if (slen < 0) {
      slen = 0;
    }
    if (slen > 64) {
      slen = 64;
    }
    codegen_import_path_to_c_prefix_into(&path[0], &pre[0], 128);
    pre_len = 0;
    while (pre_len < 128 && pre[pre_len] != 0 as u8) {
      pre_len = pre_len + 1;
    }
    if (pre_len <= 0) {
      return 0;
    }
    /* std_fmt_println_u8_ptr_i32( (uint8_t*)"…", N ) */
    if (emit_bytes_from_ptr(out, &pre[0], pre_len) != 0) {
      return -1;
    }
    if (emit_bytes_from_ptr(out, name_ptr, name_len) != 0) {
      return -1;
    }
    if (emit_bytes_from_ptr(out, &mid[0], 11) != 0) {
      return -1;
    }
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, arg_ref, ctx) != 0) {
      return -1;
    }
    if (emit_bytes_3(out, comma, 2) != 0) {
      return -1;
    }
    if (format_int(out, slen as i64) != 0) {
      return -1;
    }
    if (append_byte(out, 41) != 0) {
      return -1;
    }
    /* is_method is assigned but not read; XLANG has no unused-warning, so no
     * `(void)is_method;` C-style cast needed (such syntax hangs the parser). */
    return 1;
  }
}

/**
 * Emit one call argument under seed/glue slice ABI (PLATFORM: SHARED).
 *
 * Why: TYPE_SLICE params lower as `struct xlang_slice_* *`. Locals stay by-value
 * structs, so call sites must pass `&local` (seed: `&(slice)`). Slice params are
 * already pointers — pass through. ADDR_OF is left unchanged.
 *
 * Invariant: only for call/method arg positions; never for general emit_expr.
 */
export function emit_call_arg_slice_abi(arena: *ASTArena, out: *CodegenOutBuf, arg_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (ast.ref_is_null(arg_ref)) {
      return append_byte(out, 48);
    }
    let arg: Expr = ast.ast_arena_expr_get(arena, arg_ref);
    if (arg.kind == ExprKind.EXPR_ADDR_OF) {
      return emit_expr(arena, out, arg_ref, ctx);
    }
    /* Already a slice param of the current function → C pointer; do not add &. */
    if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
      if (field_access_base_is_pointer_param(arena, arg_ref, ctx.current_codegen_module, ctx.current_func_index) != 0) {
        /* pointer_param now treats TYPE_SLICE params as pointers */
        let is_slice_param: i32 = 0;
        let base: Expr = arg;
        if (base.kind == ExprKind.EXPR_VAR && base.var_name_len > 0) {
          let mod: *Module = ctx.current_codegen_module;
          let fi: i32 = ctx.current_func_index;
          let np: i32 = pipeline_module_func_num_params_at(mod, fi);
          let pi: i32 = 0;
          while (pi < np) {
            let p_name_len: i32 = pipeline_module_func_param_name_len_at(mod, fi, pi);
            if (p_name_len > 0 && p_name_len == base.var_name_len) {
              let pname_buf: u8[32] = [];
              pipeline_module_func_param_name_copy32(mod, fi, pi, &pname_buf[0]);
              let matched: bool = true;
              let j: i32 = 0;
              while (j < p_name_len && j < 32) {
                if (pname_buf[j] != base.var_name[j]) {
                  matched = false;
                  break;
                }
                j = j + 1;
              }
              if (matched) {
                let param_ty_ref: i32 = pipeline_module_func_param_type_ref_at(mod, fi, pi);
                if (pipeline_type_kind_ord_at(arena, param_ty_ref) == (TypeKind.TYPE_SLICE as i32)) {
                  is_slice_param = 1;
                }
              }
            }
            pi = pi + 1;
          }
        }
        if (is_slice_param != 0) {
          return emit_expr(arena, out, arg_ref, ctx);
        }
      }
    }
    /* Local / rvalue slice → &(arg) for pointer param ABI. */
    let need_addr: i32 = 0;
    if (!ast.ref_is_null(arg.resolved_type_ref) && arg.resolved_type_ref > 0 && arg.resolved_type_ref <= arena.num_types) {
      let aty: Type = ast.ast_arena_type_get(arena, arg.resolved_type_ref);
      if (aty.kind == TypeKind.TYPE_SLICE) {
        need_addr = 1;
      }
    }
    if (need_addr == 0 && arg.kind == ExprKind.EXPR_VAR && ctx != 0 as *PipelineDepCtx) {
      /* Local let annotated as TYPE_SLICE */
      if (field_access_base_is_pointer_local(arena, arg_ref, ctx) == 0) {
        let br: i32 = 0;
        if (ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
          br = pipeline_module_func_body_ref_at(ctx.current_codegen_module, ctx.current_func_index);
        }
        if (ast.ref_is_null(br) || br <= 0 || br > arena.num_blocks) {
          br = ctx.current_block_ref;
        }
        if (!ast.ref_is_null(br) && br > 0 && br <= arena.num_blocks) {
          let nlets: i32 = ast.ast_block_num_lets(arena, br);
          let li: i32 = 0;
          while (li < nlets) {
            let nl: i32 = pipeline_block_let_name_len(arena, br, li);
            if (nl == arg.var_name_len && nl > 0) {
              let nb: u8[64] = [];
              pipeline_block_let_name_copy64(arena, br, li, &nb[0]);
              let eq: bool = true;
              let j2: i32 = 0;
              while (j2 < nl && j2 < 64) {
                if (nb[j2] != arg.var_name[j2]) {
                  eq = false;
                  break;
                }
                j2 = j2 + 1;
              }
              if (eq) {
                let tr: i32 = pipeline_block_let_type_ref(arena, br, li);
                if (pipeline_type_kind_ord_at(arena, tr) == (TypeKind.TYPE_SLICE as i32)) {
                  need_addr = 1;
                }
              }
            }
            li = li + 1;
          }
        }
      }
    }
    if (need_addr != 0) {
      let pre: u8[3] = [38, 40, 0];
      if (emit_bytes_3(out, pre, 2) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, arg_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    return emit_expr(arena, out, arg_ref, ctx);
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function field_access_base_is_pointer_param(arena: *ASTArena, base_ref: i32, mod: *Module, func_index: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
      return 0;
    }
    if (mod == 0 as *Module || func_index < 0 || func_index >= mod.num_funcs) {
      return 0;
    }
    let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
    if (base.kind != ExprKind.EXPR_VAR || base.var_name_len <= 0) {
      return 0;
    }
    let np: i32 = pipeline_module_func_num_params_at(mod, func_index);
    let pi: i32 = 0;
    while (pi < np) {
      let p_name_len: i32 = pipeline_module_func_param_name_len_at(mod, func_index, pi);
      if (p_name_len > 0 && p_name_len == base.var_name_len) {
        let pname_buf: u8[32] = [];
        pipeline_module_func_param_name_copy32(mod, func_index, pi, &pname_buf[0]);
        let matched: bool = true;
        let j: i32 = 0;
        while (j < p_name_len && j < 32) {
          if (pname_buf[j] != base.var_name[j]) {
            matched = false;
            break;
          }
          j = j + 1;
        }
        if (matched) {
          let param_ty_ref: i32 = pipeline_module_func_param_type_ref_at(mod, func_index, pi);
          if (!ast.ref_is_null(param_ty_ref) && param_ty_ref > 0 && param_ty_ref <= arena.num_types) {
            let pty: Type = ast.ast_arena_type_get(arena, param_ty_ref);
            /* PLATFORM: SHARED — C ABI: *T and u8[] (TYPE_SLICE) params are pointers.
             * Seed/glue pass slices as struct xlang_slice_* *; field access must use ->. */
            if (pty.kind == TypeKind.TYPE_PTR || pty.kind == TypeKind.TYPE_SLICE) {
              return 1;
            }
          }
        }
      }
      pi = pi + 1;
    }
    return 0;
  }
}

/* See implementation. */
export function field_access_base_is_pointer_local(arena: *ASTArena, base_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (arena == 0 as *ASTArena || ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
      return 0;
    }
    let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
    if (base.kind != ExprKind.EXPR_VAR || base.var_name_len <= 0) {
      return 0;
    }
    let br: i32 = 0;
    if (ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
      br = pipeline_module_func_body_ref_at(ctx.current_codegen_module, ctx.current_func_index);
    }
    if (ast.ref_is_null(br) || br <= 0 || br > arena.num_blocks) {
      br = ctx.current_block_ref;
    }
    if (ast.ref_is_null(br) || br <= 0 || br > arena.num_blocks) {
      return 0;
    }
    let nlets: i32 = ast.ast_block_num_lets(arena, br);
    let li: i32 = 0;
    while (li < nlets) {
      let nl: i32 = pipeline_block_let_name_len(arena, br, li);
      if (nl == base.var_name_len && nl > 0) {
        let nb: u8[64] = [];
        pipeline_block_let_name_copy64(arena, br, li, &nb[0]);
        let eq: bool = true;
        let j: i32 = 0;
        while (j < nl && j < 64) {
          if (nb[j] != base.var_name[j]) {
            eq = false;
            break;
          }
          j = j + 1;
        }
        if (eq) {
          let tr: i32 = pipeline_block_let_type_ref(arena, br, li);
          if (!ast.ref_is_null(tr) && tr > 0 && tr <= arena.num_types) {
            let lty: Type = ast.ast_arena_type_get(arena, tr);
            if (lty.kind == TypeKind.TYPE_PTR) {
              return 1;
            }
          }
        }
      }
      li = li + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function field_access_base_param_type_known(arena: *ASTArena, base_ref: i32, mod: *Module, func_index: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
      return 0;
    }
    if (mod == 0 as *Module || func_index < 0 || func_index >= mod.num_funcs) {
      return 0;
    }
    let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
    if (base.kind != ExprKind.EXPR_VAR || base.var_name_len <= 0) {
      return 0;
    }
    let np: i32 = pipeline_module_func_num_params_at(mod, func_index);
    let pi: i32 = 0;
    while (pi < np) {
      let p_name_len: i32 = pipeline_module_func_param_name_len_at(mod, func_index, pi);
      if (p_name_len > 0 && p_name_len == base.var_name_len) {
        let pname_buf: u8[32] = [];
        pipeline_module_func_param_name_copy32(mod, func_index, pi, &pname_buf[0]);
        let matched: bool = true;
        let j: i32 = 0;
        while (j < p_name_len && j < 32) {
          if (pname_buf[j] != base.var_name[j]) {
            matched = false;
            break;
          }
          j = j + 1;
        }
        if (matched) {
          let param_ty_ref: i32 = pipeline_module_func_param_type_ref_at(mod, func_index, pi);
          if (!ast.ref_is_null(param_ty_ref) && param_ty_ref > 0 && param_ty_ref <= arena.num_types) {
            return 1;
          }
        }
      }
      pi = pi + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function field_access_base_is_slice_param_name(arena: *ASTArena, base_ref: i32): i32 {
  if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
    return 0;
  }
  let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
  if (base.kind != ExprKind.EXPR_VAR || base.var_name_len <= 0) {
    return 0;
  }
  /* See implementation. */
  if (base.var_name_len == 6) {
    if (base.var_name[0] == 115 && base.var_name[1] == 111 && base.var_name[2] == 117 && base.var_name[3] == 114 && base.var_name[4] == 99 && base.var_name[5] == 101) {
      return 1;
    }
  }
  /* See implementation. */
  if (base.var_name_len == 7) {
    if (base.var_name[0] == 111 && base.var_name[1] == 117 && base.var_name[2] == 116 && base.var_name[3] == 95 && base.var_name[4] == 98 && base.var_name[5] == 117 && base.var_name[6] == 102) {
      return 1;
    }
  }
  /* See implementation. */
  if (base.var_name_len == 6 && base.var_name[0] == 109 && base.var_name[1] == 111 && base.var_name[2] == 100 && base.var_name[3] == 117 && base.var_name[4] == 108 && base.var_name[5] == 101) {
    return 1;
  }
  if (base.var_name_len == 5 && base.var_name[0] == 97 && base.var_name[1] == 114 && base.var_name[2] == 101 && base.var_name[3] == 110 && base.var_name[4] == 97) {
    return 1;
  }
  if (base.var_name_len == 8 && base.var_name[0] == 101 && base.var_name[1] == 108 && base.var_name[2] == 102 && base.var_name[3] == 95 && base.var_name[4] == 99 && base.var_name[5] == 116 && base.var_name[6] == 120 && base.var_name[7] == 120) {
    return 1;
  }
  if (base.var_name_len == 7 && base.var_name[0] == 99 && base.var_name[1] == 117 && base.var_name[2] == 114 && base.var_name[3] == 95 && base.var_name[4] == 109 && base.var_name[5] == 111 && base.var_name[6] == 100) {
    return 1;
  }
  if (base.var_name_len == 3 && base.var_name[0] == 99 && base.var_name[1] == 116 && base.var_name[2] == 120) {
    return 1;
  }
  /* See implementation. */
  if (base.var_name_len == 7 && base.var_name[0] == 99 && base.var_name[1] == 117 && base.var_name[2] == 114 && base.var_name[3] == 95 && base.var_name[4] == 109 && base.var_name[5] == 111 && base.var_name[6] == 100) {
    return 1;
  }
  return 0;
}

/** Exported function `block_stmt_order_has_let`.
 * Implements `block_stmt_order_has_let`.
 * @param arena *ASTArena
 * @param block_ref i32
 * @param let_idx i32
 * @return i32
 */
export function block_stmt_order_has_let(arena: *ASTArena, block_ref: i32, let_idx: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let nso: i32 = ast.ast_block_num_stmt_order(arena, block_ref);
    let si: i32 = 0;
    while (si < nso) {
      if (pipeline_block_stmt_order_kind(arena, block_ref, si) == 1 && pipeline_block_stmt_order_idx(arena, block_ref, si) == let_idx) {
        return 1;
      }
      si = si + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_c_prefix_redundant_with_name(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  if (prefix == 0 as *u8 || name == 0 as *u8) {
    return 0;
  }
  if (prefix_len <= 0 || name_len < prefix_len) {
    return 0;
  }
  /* See implementation. */
  if (prefix_len == 4 && prefix[0] == 97 && prefix[1] == 115 && prefix[2] == 116 && prefix[3] == 95) {
    return 0;
  }
  let i: i32 = 0;
  while (i < prefix_len) {
    if (name[i] != prefix[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/* See implementation. */
/* See implementation. */
export struct CodegenOutBuf {
  data: u8[9437184];
  len: i32;
}

/** Exported function `append_byte`.
 * Implements `append_byte`.
 * @param out *CodegenOutBuf
 * @param b i32
 * @return i32
 */
export function append_byte(out: *CodegenOutBuf, b: i32): i32 {
  if (out.len >= 9437184) {
    return -1;
  }
  /* See implementation. */
  out.data[out.len] = (b & 255) as u8;
  out.len = out.len + 1;
  return 0;
}

/** Exported function `append_byte_u8`.
 * Implements `append_byte_u8`.
 * @param out *CodegenOutBuf
 * @param b u8
 * @return i32
 */
export function append_byte_u8(out: *CodegenOutBuf, b: u8): i32 {
  return append_byte(out, b as i32);
}

/** Exported function `emit_bytes_from_ptr`.
 * Implements `emit_bytes_from_ptr`.
 * @param out *CodegenOutBuf
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function emit_bytes_from_ptr(out: *CodegenOutBuf, ptr: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, ptr[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}

/**
 * See implementation.
 */
export function emit_bytes_64(out: *CodegenOutBuf, ptr: *u8, len: i32): i32 {
  return emit_bytes_from_ptr(out, ptr, len);
}
/** Exported function `emit_bytes_32`.
 * Implements `emit_bytes_32`.
 * @param out *CodegenOutBuf
 * @param buf u8[32]
 * @param len i32
 * @return i32
 */
export function emit_bytes_32(out: *CodegenOutBuf, buf: u8[32], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
/** Exported function `emit_bytes_22`.
 * Implements `emit_bytes_22`.
 * @param out *CodegenOutBuf
 * @param buf u8[22]
 * @param len i32
 * @return i32
 */
export function emit_bytes_22(out: *CodegenOutBuf, buf: u8[22], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
/** Exported function `emit_bytes_9`.
 * Implements `emit_bytes_9`.
 * @param out *CodegenOutBuf
 * @param buf u8[9]
 * @param len i32
 * @return i32
 */
export function emit_bytes_9(out: *CodegenOutBuf, buf: u8[9], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
/** Exported function `emit_bytes_8`.
 * Implements `emit_bytes_8`.
 * @param out *CodegenOutBuf
 * @param buf u8[8]
 * @param len i32
 * @return i32
 */
export function emit_bytes_8(out: *CodegenOutBuf, buf: u8[8], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
/** Exported function `emit_bytes_7`.
 * Implements `emit_bytes_7`.
 * @param out *CodegenOutBuf
 * @param buf u8[7]
 * @param len i32
 * @return i32
 */
export function emit_bytes_7(out: *CodegenOutBuf, buf: u8[7], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
/** Exported function `emit_bytes_6`.
 * Implements `emit_bytes_6`.
 * @param out *CodegenOutBuf
 * @param buf u8[6]
 * @param len i32
 * @return i32
 */
export function emit_bytes_6(out: *CodegenOutBuf, buf: u8[6], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
/** Exported function `emit_bytes_5`.
 * Implements `emit_bytes_5`.
 * @param out *CodegenOutBuf
 * @param buf u8[5]
 * @param len i32
 * @return i32
 */
export function emit_bytes_5(out: *CodegenOutBuf, buf: u8[5], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
/** Exported function `emit_bytes_4`.
 * Implements `emit_bytes_4`.
 * @param out *CodegenOutBuf
 * @param buf u8[4]
 * @param len i32
 * @return i32
 */
export function emit_bytes_4(out: *CodegenOutBuf, buf: u8[4], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
/** Exported function `emit_bytes_3`.
 * Implements `emit_bytes_3`.
 * @param out *CodegenOutBuf
 * @param buf u8[3]
 * @param len i32
 * @return i32
 */
export function emit_bytes_3(out: *CodegenOutBuf, buf: u8[3], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
/** Exported function `emit_bytes_2`.
 * Implements `emit_bytes_2`.
 * @param out *CodegenOutBuf
 * @param buf u8[2]
 * @param len i32
 * @return i32
 */
export function emit_bytes_2(out: *CodegenOutBuf, buf: u8[2], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `format_uint`.
 * Implements `format_uint`.
 * @param out *CodegenOutBuf
 * @param val i32
 * @return i32
 */
export function format_uint(out: *CodegenOutBuf, val: i32): i32 {
  if (val >= 10) {
    let q: i32 = val / 10;
    let r: i32 = val % 10;
    if (format_uint(out, q) != 0) {
      return -1;
    }
    if (append_byte(out, 48 + r) != 0) {
      return -1;
    }
    return 0;
  }
  if (append_byte(out, 48 + val) != 0) {
    return -1;
  }
  return 0;
}

/** Exported function `format_uint64`.
 * Implements `format_uint64`.
 * @param out *CodegenOutBuf
 * @param val u64
 * @return i32
 */
export function format_uint64(out: *CodegenOutBuf, val: u64): i32 {
  if (val >= (10 as u64)) {
    let q: u64 = val / (10 as u64);
    let r: u64 = val % (10 as u64);
    if (format_uint64(out, q) != 0) {
      return -1;
    }
    if (append_byte(out, 48 + (r as i32)) != 0) {
      return -1;
    }
    return 0;
  }
  if (append_byte(out, 48 + (val as i32)) != 0) {
    return -1;
  }
  return 0;
}

/** Exported function `format_int`.
 * Implements `format_int`.
 * @param out *CodegenOutBuf
 * @param val i64
 * @return i32
 */
export function format_int(out: *CodegenOutBuf, val: i64): i32 {
  if (val >= 0) {
    return format_uint64(out, val as u64);
  }
  let u: i64 = 0 - val;
  if (u < 0) {
    /* See implementation. */
    if (append_byte(out, 45) != 0) {
      return -1;
    }
    let d: u8[20] = [57, 50, 50, 51, 51, 55, 50, 48, 51, 54, 56, 53, 52, 55, 55, 53, 56, 48, 56, 0];
    let i: i32 = 0;
    while (i < 19) {
      if (append_byte_u8(out, d[i]) != 0) {
        return -1;
      }
      i = i + 1;
    }
    return 0;
  }
  if (append_byte(out, 45) != 0) {
    return -1;
  }
  return format_uint64(out, u as u64);
}

/** Exported function `emit_indent`.
 * Implements `emit_indent`.
 * @param out *CodegenOutBuf
 * @param indent i32
 * @return i32
 */
export function emit_indent(out: *CodegenOutBuf, indent: i32): i32 {
  let i: i32 = 0;
  while (i < indent) {
    if (append_byte(out, 32) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `emit_break_stmt`.
 * Implements `emit_break_stmt`.
 * @param out *CodegenOutBuf
 * @param indent i32
 * @return i32
 */
export function emit_break_stmt(out: *CodegenOutBuf, indent: i32): i32 {
  if (emit_indent(out, indent) != 0) {
    return -1;
  }
  let br: u8[8] = [98, 114, 101, 97, 107, 59, 10, 0];
  return emit_bytes_8(out, br, 7);
}

/** Exported function `emit_continue_stmt`.
 * Implements `emit_continue_stmt`.
 * @param out *CodegenOutBuf
 * @param indent i32
 * @return i32
 */
export function emit_continue_stmt(out: *CodegenOutBuf, indent: i32): i32 {
  if (emit_indent(out, indent) != 0) {
    return -1;
  }
  let co: u8[11] = [99, 111, 110, 116, 105, 110, 117, 101, 59, 10, 0];
  return emit_bytes_from_ptr(out, &co[0], 10);
}

/** Exported function `emit_type_kind_ord`.
 * Implements `emit_type_kind_ord`.
 * @param out *CodegenOutBuf
 * @param tk i32
 * @return i32
 */
export function emit_type_kind_ord(out: *CodegenOutBuf, tk: i32): i32 {
  return emit_type_kind(out, tk);
}

/** Exported function `emit_type_kind`.
 * Implements `emit_type_kind`.
 * @param out *CodegenOutBuf
 * @param kind_ord i32
 * @return i32
 */
export function emit_type_kind(out: *CodegenOutBuf, kind_ord: i32): i32 {
  if (kind_ord == (TypeKind.TYPE_I32 as i32)) {
    let s: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
    return emit_bytes_8(out, s, 7);
  }
  if (kind_ord == (TypeKind.TYPE_I64 as i32)) {
    let s: u8[8] = [105, 110, 116, 54, 52, 95, 116, 0];
    return emit_bytes_8(out, s, 7);
  }
  if (kind_ord == (TypeKind.TYPE_BOOL as i32)) {
    let s: u8[4] = [105, 110, 116, 0];
    return emit_bytes_4(out, s, 3);
  }
  if (kind_ord == (TypeKind.TYPE_U8 as i32)) {
    let s: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
    return emit_bytes_9(out, s, 7);
  }
  if (kind_ord == (TypeKind.TYPE_U32 as i32)) {
    let s: u8[9] = [117, 105, 110, 116, 51, 50, 95, 116, 0];
    return emit_bytes_9(out, s, 8);
  }
  if (kind_ord == (TypeKind.TYPE_U64 as i32)) {
    let s: u8[9] = [117, 105, 110, 116, 54, 52, 95, 116, 0];
    return emit_bytes_9(out, s, 8);
  }
  if (kind_ord == (TypeKind.TYPE_F32 as i32)) {
    let s: u8[6] = [102, 108, 111, 97, 116, 0];
    return emit_bytes_6(out, s, 5);
  }
  if (kind_ord == (TypeKind.TYPE_F64 as i32)) {
    let s: u8[7] = [100, 111, 117, 98, 108, 101, 0];
    return emit_bytes_7(out, s, 6);
  }
  if (kind_ord == (TypeKind.TYPE_VOID as i32)) {
    let s: u8[5] = [118, 111, 105, 100, 0];
    return emit_bytes_5(out, s, 4);
  }
  if (kind_ord == (TypeKind.TYPE_USIZE as i32)) {
    let s: u8[7] = [115, 105, 122, 101, 95, 116, 0];
    return emit_bytes_7(out, s, 6);
  }
  if (kind_ord == (TypeKind.TYPE_ISIZE as i32)) {
    let s: u8[8] = [115, 115, 105, 122, 101, 95, 116, 0];
    return emit_bytes_8(out, s, 7);
  }
  return -1;
}

/** Exported function `type_kind_append_to_scratch`.
 * Implements `type_kind_append_to_scratch`.
 * @param scratch *u8
 * @param cap i32
 * @param w i32
 * @param kind_ord i32
 * @return i32
 */
export function type_kind_append_to_scratch(scratch: *u8, cap: i32, w: i32, kind_ord: i32): i32 {
  if (kind_ord == (TypeKind.TYPE_I32 as i32)) {
    let s: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
    let i: i32 = 0;
    while (i < 7) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_I64 as i32)) {
    let s: u8[8] = [105, 110, 116, 54, 52, 95, 116, 0];
    let i: i32 = 0;
    while (i < 7) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_BOOL as i32)) {
    let s: u8[4] = [105, 110, 116, 0];
    let i: i32 = 0;
    while (i < 3) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_U8 as i32)) {
    let s: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
    let i: i32 = 0;
    while (i < 7) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_U32 as i32)) {
    let s: u8[9] = [117, 105, 110, 116, 51, 50, 95, 116, 0];
    let i: i32 = 0;
    while (i < 8) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_U64 as i32)) {
    let s: u8[9] = [117, 105, 110, 116, 54, 52, 95, 116, 0];
    let i: i32 = 0;
    while (i < 8) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_F32 as i32)) {
    let s: u8[6] = [102, 108, 111, 97, 116, 0];
    let i: i32 = 0;
    while (i < 5) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_F64 as i32)) {
    let s: u8[7] = [100, 111, 117, 98, 108, 101, 0];
    let i: i32 = 0;
    while (i < 6) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_VOID as i32)) {
    let s: u8[5] = [118, 111, 105, 100, 0];
    let i: i32 = 0;
    while (i < 4) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_USIZE as i32)) {
    let s: u8[7] = [115, 105, 122, 101, 95, 116, 0];
    let i: i32 = 0;
    while (i < 6) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_ISIZE as i32)) {
    let s: u8[8] = [115, 115, 105, 122, 101, 95, 116, 0];
    let i: i32 = 0;
    while (i < 7) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  return -1;
}

/** Exported function `emit_vector_c_type_out`.
 * Implements `emit_vector_c_type_out`.
 * Emits the C type name (i32x4_t / u32x8_t / f32x4_t ...) for a VECTOR type
 * given its element TypeKind ord and lane count. The emitted names must match
 * the typedefs in seeds/rt_preamble.from_x.c (§10 vector block).
 * PLATFORM: SHARED — used by both C and asm codegen paths.
 * @param out *CodegenOutBuf
 * @param elem_kind_ord i32 — TypeKind ord of the vector element (I32/U32/F32)
 * @param lanes i32 — 4 / 8 / 16
 * @return i32
 */
export function emit_vector_c_type_out(out: *CodegenOutBuf, elem_kind_ord: i32, lanes: i32): i32 {
  if (elem_kind_ord == (TypeKind.TYPE_I32 as i32)) {
    if (lanes == 4) {
      let s: u8[8] = [105, 51, 50, 120, 52, 95, 116, 0];
      return emit_bytes_from_ptr(out, &s[0], 7);
    }
    if (lanes == 8) {
      let s: u8[8] = [105, 51, 50, 120, 56, 95, 116, 0];
      return emit_bytes_from_ptr(out, &s[0], 7);
    }
    if (lanes == 16) {
      let sa: u8[9] = [105, 51, 50, 120, 49, 54, 95, 116, 0];
      return emit_bytes_from_ptr(out, &sa[0], 8);
    }
  }
  if (elem_kind_ord == (TypeKind.TYPE_U32 as i32)) {
    if (lanes == 4) {
      let s: u8[8] = [117, 51, 50, 120, 52, 95, 116, 0];
      return emit_bytes_from_ptr(out, &s[0], 7);
    }
    if (lanes == 8) {
      let s: u8[8] = [117, 51, 50, 120, 56, 95, 116, 0];
      return emit_bytes_from_ptr(out, &s[0], 7);
    }
    if (lanes == 16) {
      let sa: u8[9] = [117, 51, 50, 120, 49, 54, 95, 116, 0];
      return emit_bytes_from_ptr(out, &sa[0], 8);
    }
  }
  /* F32 vector: "f32x4_t" / "f32x8_t" / "f32x16_t". Without this branch, Vec4f
   * falls through to the int32_t default and collides with Vec8i overloads. */
  if (elem_kind_ord == (TypeKind.TYPE_F32 as i32)) {
    if (lanes == 4) {
      let s: u8[8] = [102, 51, 50, 120, 52, 95, 116, 0];
      return emit_bytes_from_ptr(out, &s[0], 7);
    }
    if (lanes == 8) {
      let s: u8[8] = [102, 51, 50, 120, 56, 95, 116, 0];
      return emit_bytes_from_ptr(out, &s[0], 7);
    }
    if (lanes == 16) {
      let sa: u8[9] = [102, 51, 50, 120, 49, 54, 95, 116, 0];
      return emit_bytes_from_ptr(out, &sa[0], 8);
    }
  }
  let df: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
  return emit_bytes_from_ptr(out, &df[0], 7);
}

/** Exported function `type_kind_append_to_scratch_ord`.
 * Implements `type_kind_append_to_scratch_ord`.
 * @param scratch *u8
 * @param cap i32
 * @param w i32
 * @param tk i32
 * @return i32
 */
export function type_kind_append_to_scratch_ord(scratch: *u8, cap: i32, w: i32, tk: i32): i32 {
  let w2: i32 = type_kind_append_to_scratch(scratch, cap, w, tk);
  if (w2 < 0) {
    return type_kind_append_to_scratch(scratch, cap, w, TypeKind.TYPE_I32 as i32);
  }
  return w2;
}

/** Exported function `type_to_c_repr`.
 * Implements `type_to_c_repr`.
 * @param arena *ASTArena
 * @param scratch *u8
 * @param cap i32
 * @param type_ref i32
 * @param struct_prefix *u8
 * @param struct_prefix_len i32
 * @return i32
 */
export function type_to_c_repr(arena: *ASTArena, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    return pipeline_codegen_type_to_c_repr(arena, scratch, cap, type_ref, struct_prefix, struct_prefix_len);
  }
}

/** Exported function `emit_type`.
 * Implements `emit_type`.
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param type_ref i32
 * @param struct_prefix *u8
 * @param struct_prefix_len i32
 * @param ctx *PipelineDepCtx
 * @return i32
 */
export function emit_type(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let tk: i32 = 0;
    let elem_ref: i32 = 0;
    let arr_sz: i32 = 0;
    let elem_kind: i32 = 0;
    let name_len: i32 = 0;
    let nm: u8[64] = [];

    if (ast.ref_is_null(type_ref)) {
      let s: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
      return emit_bytes_8(out, s, 7);
    }
    tk = pipeline_type_kind_ord_at(arena, type_ref);
    elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
    arr_sz = pipeline_type_array_size_at(arena, type_ref);
    if (tk == TypeKind.TYPE_PTR && !ast.ref_is_null(elem_ref)) {
      if (emit_type(arena, out, elem_ref, struct_prefix, struct_prefix_len, ctx) != 0) {
        return -1;
      }
      if (append_byte(out, 32) != 0) {
        return -1;
      }
      return append_byte(out, 42);
    }
    name_len = pipeline_type_named_name_into(arena, type_ref, &nm[0]);
    if (tk == TypeKind.TYPE_NAMED && name_len > 0) {
      let dep_prefix_buf: u8[128] = [];
      let dep_prefix_len: i32 = 0;
      /* See implementation. */
      if (name_len == 6 && nm[0] == 66 && nm[1] == 117 && nm[2] == 102 && nm[3] == 102
          && nm[4] == 101 && nm[5] == 114) {
        let io_buf: u8[22] = [115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 105, 111, 95, 66, 117, 102, 102, 101, 114, 0, 0];
        return emit_bytes_from_ptr(out, &io_buf[0], 20);
      }
      /*
       * See implementation.
       * See implementation.
       * See implementation.
       * See implementation.
       * See implementation.
       */
      if (name_len >= 8 && nm[0] == 79 && nm[1] == 112 && nm[2] == 116 && nm[3] == 105
          && nm[4] == 111 && nm[5] == 110 && nm[6] == 95) {
        let opt_head: u8[20] = [115, 116, 114, 117, 99, 116, 32, 99, 111, 114, 101, 95, 111, 112, 116, 105, 111, 110, 95, 0];
        if (emit_bytes_from_ptr(out, &opt_head[0], 19) != 0) {
          return -1;
        }
        let oi: i32 = 0;
        while (oi < name_len && oi < 64) {
          if (append_byte_u8(out, nm[oi]) != 0) {
            return -1;
          }
          oi = oi + 1;
        }
        return 0;
      }
      /* See implementation. */
      if (name_len == 3 && nm[0] == 117 && nm[1] == 49 && nm[2] == 54) {
        let u16_t: u8[9] = [117, 105, 110, 116, 49, 54, 95, 116, 0];
        return emit_bytes_8(out, u16_t, 8);
      }
      if (name_len == 3 && nm[0] == 105 && nm[1] == 49 && nm[2] == 54) {
        let i16_t: u8[8] = [105, 110, 116, 49, 54, 95, 116, 0];
        return emit_bytes_8(out, i16_t, 7);
      }
      if (name_len == 2 && nm[0] == 105 && nm[1] == 56) {
        let i8_t: u8[7] = [105, 110, 116, 56, 95, 116, 0];
        return emit_bytes_8(out, i8_t, 6);
      }
      /*
       * See implementation.
       * See implementation.
       */
      if (name_len == 5 && nm[0] == 105 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 52) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_I32 as i32, 4);
      }
      if (name_len == 5 && nm[0] == 105 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 56) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_I32 as i32, 8);
      }
      if (name_len == 5 && nm[0] == 117 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 52) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_U32 as i32, 4);
      }
      if (name_len == 5 && nm[0] == 117 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 56) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_U32 as i32, 8);
      }
      if (name_len == 6 && nm[0] == 105 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 49 && nm[5] == 54) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_I32 as i32, 16);
      }
      if (name_len == 6 && nm[0] == 117 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 49 && nm[5] == 54) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_U32 as i32, 16);
      }
      /* See implementation. */
      if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module
          && codegen_type_is_module_user_enum(ctx.current_codegen_module, arena, type_ref) != 0) {
        let i32_enum: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
        return emit_bytes_8(out, i32_enum, 7);
      }
      /* See implementation. */
      if (ctx != 0 as *PipelineDepCtx) {
        let dep_enum_prefix: u8[128] = [];
        let dep_enum_prefix_len: i32 = codegen_type_dep_enum_prefix_into(ctx, arena, type_ref, &dep_enum_prefix[0], 128);
        if (dep_enum_prefix_len > 0) {
          let e: u8[8] = [101, 110, 117, 109, 32, 0, 0, 0];
          if (emit_bytes_8(out, e, 5) != 0) {
            return -1;
          }
          if (emit_bytes_from_ptr(out, &dep_enum_prefix[0], dep_enum_prefix_len) != 0) {
            return -1;
          }
          let bare_off2: i32 = 0;
          let bi2: i32 = 0;
          while (bi2 < name_len && bi2 < 64) {
            if (nm[bi2] == 46) {
              bare_off2 = bi2 + 1;
            }
            bi2 = bi2 + 1;
          }
          let ci2: i32 = bare_off2;
          while (ci2 < name_len && ci2 < 64) {
            if (append_byte_u8(out, nm[ci2]) != 0) {
              return -1;
            }
            ci2 = ci2 + 1;
          }
          return 0;
        }
      }
      let s: u8[8] = [115, 116, 114, 117, 99, 116, 32, 0];
      if (emit_bytes_8(out, s, 7) != 0) {
        return -1;
      }
      dep_prefix_len = codegen_type_dep_struct_prefix_into(ctx, arena, type_ref, &dep_prefix_buf[0], 128);
      /* See implementation. */
      if (dep_prefix_len == 0) {
        let qmod_end: i32 = 0;
        let qhas_dot: bool = false;
        let qi: i32 = 0;
        while (qi < name_len && qi < 64) {
          if (nm[qi] == 46) {
            qhas_dot = true;
            qmod_end = qi;
          }
          qi = qi + 1;
        }
        if (qhas_dot && qmod_end > 0 && qmod_end < 64) {
          let mod_path: u8[64] = [];
          let mi: i32 = 0;
          while (mi < qmod_end) {
            mod_path[mi] = nm[mi];
            mi = mi + 1;
          }
          mod_path[mi] = 0 as u8;
          codegen_import_path_to_c_prefix_into(&mod_path[0], &dep_prefix_buf[0], 128);
          dep_prefix_len = 0;
          while (dep_prefix_len < 128 && dep_prefix_buf[dep_prefix_len] != 0 as u8) {
            dep_prefix_len = dep_prefix_len + 1;
          }
        }
      }
      /* See implementation. */
      if (dep_prefix_len > 0) {
        if (emit_bytes_from_ptr(out, &dep_prefix_buf[0], dep_prefix_len) != 0) {
          return -1;
        }
      } else if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
        if (emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) != 0) {
          return -1;
        }
      } else if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module
          && codegen_type_is_module_user_struct(ctx.current_codegen_module, arena, type_ref) != 0) {
        /* See implementation. */
        let cur_pre: u8[128] = [];
        let cur_pre_len: i32 = codegen_emit_prefix_len_from_ctx(ctx, &cur_pre[0], 128);
        if (cur_pre_len > 0 && emit_bytes_from_ptr(out, &cur_pre[0], cur_pre_len) != 0) {
          return -1;
        }
      } else {
        /* See implementation. */
        let ast_p: u8[4] = [97, 115, 116, 95];
        if (emit_bytes_4(out, ast_p, 4) != 0) {
          return -1;
        }
      }
      /* See implementation. */
      let bare_off: i32 = 0;
      let bi: i32 = 0;
      while (bi < name_len && bi < 64) {
        if (nm[bi] == 46) {
          bare_off = bi + 1;
        }
        bi = bi + 1;
      }
      let ci: i32 = bare_off;
      while (ci < name_len && ci < 64) {
        if (append_byte_u8(out, nm[ci]) != 0) {
          return -1;
        }
        ci = ci + 1;
      }
      return 0;
    }
    /* See implementation. */
    if (tk == TypeKind.TYPE_ARRAY && !ast.ref_is_null(elem_ref)) {
      if (emit_type(arena, out, elem_ref, struct_prefix, struct_prefix_len, ctx) != 0) {
        return -1;
      }
      if (append_byte(out, 32) != 0) {
        return -1;
      }
      return append_byte(out, 42);
    }
    /* See implementation. */
    if (tk == TypeKind.TYPE_SLICE && !ast.ref_is_null(elem_ref)) {
      let slb: u8[256] = [];
      let nl: i32 = type_to_c_repr(arena, &slb[0], 256, type_ref, struct_prefix, struct_prefix_len);
      if (nl <= 0) {
        return -1;
      }
      let si: i32 = 0;
      while (si < nl) {
        if (append_byte_u8(out, slb[si]) != 0) {
          return -1;
        }
        si = si + 1;
      }
      return 0;
    }
    /* See implementation. */
    if (tk == TypeKind.TYPE_VECTOR && !ast.ref_is_null(elem_ref)) {
      elem_kind = pipeline_type_kind_ord_at(arena, elem_ref);
      return emit_vector_c_type_out(out, elem_kind, arr_sz);
    }
    /* See implementation. */
    if (tk == TypeKind.TYPE_LINEAR && !ast.ref_is_null(elem_ref)) {
      return emit_type(arena, out, elem_ref, struct_prefix, struct_prefix_len, ctx);
    }
    return emit_type_kind_ord(out, tk);
  }
}

/**
 * Pick defining-module dep index for a bare struct name across the dep pool.
 *
 * Why: co-emit can leave the same bare name in several modules (merge, struct-lit
 * pollution). Wrong owner → dual C tags (lexer_Token vs token_Token) and incomplete
 * by-value fields (LexerResult before Token).
 *
 * Ranking (PLATFORM: SHARED):
 *  1) Prefer layouts with num_fields > 0 over empty placeholders.
 *  2) Prefer is_export=1 (true `export struct`) over non-export copies.
 *  3) When both candidates are export: prefer current_codegen_dep_index so dual real
 *     types (std_context_Error vs std_error_Error) each emit under their own prefix.
 *  4) When both are non-export (pollution competition, e.g. Token in lexer+token with
 *     is_export still 0 on product parser pin): prefer the **latest** dep index — leaf
 *     imports are registered after parents (token after lexer), so the defining file wins.
 *
 * Returns -1 if no dep has the bare name; otherwise a pipeline_dep_ctx index.
 */
export function codegen_type_dep_struct_owner_index(ctx: *PipelineDepCtx, bare_nm: *u8, bare_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let best_di: i32 = -1;
    let best_export: i32 = 0;
    let best_nf: i32 = 0;
    let cur: i32 = -1;
    let di: i32 = 0;
    let nd: i32 = 0;
    if (ctx == 0 as *PipelineDepCtx || bare_nm == 0 as *u8 || bare_len <= 0) {
      return -1;
    }
    cur = ctx.current_codegen_dep_index;
    nd = pipeline_dep_ctx_ndep(ctx);
    while (di < nd) {
      let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, di);
      if (dep_mod != 0 as *Module) {
        let li: i32 = 0;
        let hit: i32 = 0;
        let hit_export: i32 = 0;
        let hit_nf: i32 = 0;
        while (li < dep_mod.num_struct_layouts) {
          let dep_name_len: i32 = pipeline_module_struct_layout_name_len(dep_mod, li);
          if (dep_name_len == bare_len) {
            let dep_nm: u8[64] = [];
            let eq: bool = true;
            let j: i32 = 0;
            pipeline_module_struct_layout_name_into(dep_mod, li, &dep_nm[0]);
            while (j < bare_len && j < 64) {
              if (dep_nm[j] != bare_nm[j]) {
                eq = false;
                break;
              }
              j = j + 1;
            }
            if (eq) {
              hit = 1;
              hit_nf = pipeline_module_struct_layout_num_fields(dep_mod, li);
              if (pipeline_module_struct_layout_is_export_at(dep_mod, li) != 0) {
                hit_export = 1;
              }
              break;
            }
          }
          li = li + 1;
        }
        if (hit != 0) {
          /* Empty same-name layouts must not steal ownership (incomplete type). */
          if (best_di < 0) {
            best_di = di;
            best_export = hit_export;
            best_nf = hit_nf;
          } else if (hit_nf > 0 && best_nf <= 0) {
            best_di = di;
            best_export = hit_export;
            best_nf = hit_nf;
          } else if (hit_nf > 0 && best_nf > 0 && hit_export != 0 && best_export == 0) {
            best_di = di;
            best_export = 1;
            best_nf = hit_nf;
          } else if (hit_export != 0 && best_export == 0 && hit_nf >= best_nf) {
            best_di = di;
            best_export = 1;
            best_nf = hit_nf;
          } else if (hit_nf > 0 && best_nf > 0 && hit_export != 0 && best_export != 0 && di == cur) {
            /* Dual true exports (Error): current module owns its own tag. */
            best_di = di;
            best_nf = hit_nf;
          } else if (hit_nf > 0 && best_nf > 0 && hit_export == 0 && best_export == 0 && di > best_di) {
            /*
             * Non-export competition: prefer later dep (leaf import after parent).
             * Token: lexer di=0 pollution vs token di=1 definition → token wins.
             * Do not apply cur preference here — that re-emitted lexer_Token and
             * broke LexerResult by-value field completeness (parser M1 host-cc).
             */
            best_di = di;
            best_nf = hit_nf;
          }
        }
      }
      di = di + 1;
    }
    return best_di;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_type_dep_struct_prefix_into(ctx: *PipelineDepCtx, arena: *ASTArena, type_ref: i32, dst: *u8, dst_cap: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let name_len: i32 = 0;
    let ty_nm: u8[64] = [];
    let owner: i32 = -1;
    if (ctx == 0 as *PipelineDepCtx || arena == 0 as *ASTArena || dst == 0 as *u8 || dst_cap <= 0 || ast.ref_is_null(type_ref)) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, type_ref) != TypeKind.TYPE_NAMED) {
      return 0;
    }
    name_len = pipeline_type_named_name_into(arena, type_ref, &ty_nm[0]);
    if (name_len <= 0) {
      return 0;
    }
    /* See implementation. */
    let bare_off: i32 = 0;
    let bi: i32 = 0;
    while (bi < name_len && bi < 64) {
      if (ty_nm[bi] == 46) {
        bare_off = bi + 1;
      }
      bi = bi + 1;
    }
    let bare_len: i32 = name_len - bare_off;
    owner = codegen_type_dep_struct_owner_index(ctx, &ty_nm[bare_off], bare_len);
    if (owner >= 0) {
      let dep_path: u8[64] = [];
      let plen: i32 = codegen_dep_import_path_len_at(ctx, owner, &dep_path[0]);
      if (plen > 0) {
        codegen_import_path_to_c_prefix_into(&dep_path[0], dst, dst_cap);
        let out_len: i32 = 0;
        while (out_len < dst_cap && dst[out_len] != 0 as u8) {
          out_len = out_len + 1;
        }
        return out_len;
      }
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function type_array_elem_is_u8(arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let inner: i32 = 0;
    if (ast.ref_is_null(type_ref) || type_ref <= 0 || type_ref > arena.num_types) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, type_ref) != TypeKind.TYPE_ARRAY) {
      return 0;
    }
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    if (ast.ref_is_null(inner) || inner <= 0 || inner > arena.num_types) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, inner) == TypeKind.TYPE_U8) {
      return 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function emit_local_fixed_array_elem_type(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let inner: i32 = pipeline_type_elem_ref_at(arena, type_ref);
    if (ast.ref_is_null(inner) || emit_type(arena, out, inner, 0 as *u8, 0, ctx) != 0) {
      let fb: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
      return emit_bytes_8(out, fb, 7);
    }
    return 0;
  }
}

/** Exported function `emit_local_fixed_array_suffix`.
 * Implements `emit_local_fixed_array_suffix`.
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param type_ref i32
 * @return i32
 */
export function emit_local_fixed_array_suffix(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let asz: i32 = pipeline_type_array_size_at(arena, type_ref);
    if (append_byte(out, 91) != 0) {
      return -1;
    }
    if (format_int(out, asz) != 0) {
      return -1;
    }
    return append_byte(out, 93);
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function try_emit_slice_init_from_array_var(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, let_idx: i32, let_type_ref: i32, linit_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    /* See implementation. */
    if (ast.ref_is_null(let_type_ref) || pipeline_type_kind_ord_at(arena, let_type_ref) != 11) {
      return 0;
    }
    if (ast.ref_is_null(linit_ref) || linit_ref <= 0 || linit_ref > arena.num_exprs) {
      return 0;
    }
    let init_e: Expr = ast.ast_arena_expr_get(arena, linit_ref);
    if (init_e.kind != ExprKind.EXPR_VAR || init_e.var_name_len <= 0) {
      return 0;
    }
    let arr_sz: i32 = 0;
    let li: i32 = 0;
    while (li < let_idx) {
      let nlen: i32 = pipeline_block_let_name_len(arena, block_ref, li);
      if (nlen == init_e.var_name_len && nlen > 0) {
        let matched: i32 = 1;
        let nb: u8[64] = [];
        pipeline_block_let_name_copy64(arena, block_ref, li, &nb[0]);
        let ci: i32 = 0;
        while (ci < nlen) {
          if (nb[ci] != init_e.var_name[ci]) {
            matched = 0;
            ci = nlen;
          } else {
            ci = ci + 1;
          }
        }
        if (matched != 0) {
          let tr: i32 = pipeline_block_let_type_ref(arena, block_ref, li);
          if (pipeline_type_kind_ord_at(arena, tr) == 10) {
            arr_sz = pipeline_type_array_size_at(arena, tr);
            li = let_idx;
          }
        }
      }
      li = li + 1;
    }
    if (arr_sz <= 0 && !ast.ref_is_null(init_e.resolved_type_ref) && init_e.resolved_type_ref > 0) {
      if (pipeline_type_kind_ord_at(arena, init_e.resolved_type_ref) == 10) {
        arr_sz = pipeline_type_array_size_at(arena, init_e.resolved_type_ref);
      }
    }
    if (arr_sz <= 0) {
      return 0;
    }
    if (append_byte(out, 123) != 0) {
      return -1;
    }
    let d1: u8[9] = [32, 46, 100, 97, 116, 97, 32, 61, 32];
    if (emit_bytes_from_ptr(out, &d1[0], 9) != 0) {
      return -1;
    }
    if (emit_bytes_64(out, &init_e.var_name[0], init_e.var_name_len) != 0) {
      return -1;
    }
    let d2: u8[12] = [44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32];
    if (emit_bytes_from_ptr(out, &d2[0], 12) != 0) {
      return -1;
    }
    if (format_int(out, arr_sz) != 0) {
      return -1;
    }
    let d3: u8[4] = [32, 125, 0, 0];
    /* See implementation. */
    if (emit_bytes_4(out, d3, 2) != 0) {
      return -1;
    }
    return 1;
  }
}

/**
 * See implementation.
 */
export function emit_braced_array_lit_init(arena: *ASTArena, out: *CodegenOutBuf, init_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ast.ref_is_null(init_ref) || init_ref <= 0 || init_ref > arena.num_exprs) {
      let z: u8[4] = [123, 32, 48, 0];
      if (emit_bytes_4(out, z, 3) != 0) {
        return -1;
      }
      return 0;
    }
    /* See implementation. */
    if (pipeline_expr_kind_ord_at(arena, init_ref) != (46 as i32)) {
      if (emit_expr(arena, out, init_ref, ctx) != 0) {
        return -1;
      }
      return 0;
    }
    if (append_byte(out, 123) != 0) {
      return -1;
    }
    let n: i32 = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
    let ai: i32 = 0;
    while (ai < n) {
      if (ai > 0) {
        let comma: u8[3] = [44, 32, 0];
        if (emit_bytes_3(out, comma, 2) == 0) {
          ai = ai;
        } else {
          return -1;
        }
      }
      /* See implementation. */
      if (emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, init_ref, ai), ctx) == 0) {
        ai = ai + 1;
      } else {
        return -1;
      }
    }
    if (append_byte(out, 125) == 0) {
      return 0;
    }
    return -1;
  }
}

/**
 * See implementation.
 */
export function emit_struct_field_type_via_pipeline(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    return pipeline_codegen_emit_struct_field_type(arena, out, type_ref, struct_prefix, struct_prefix_len);
  }
}

/**
 * Look up the type_ref of `struct_name.field_name` in the entry module then deps.
 *
 * Purpose: STRUCT_LIT array-field emit must know the field is TYPE_ARRAY so it can
 * expand `.name = src` (illegal in C) into `.name = { src[0], …, src[N-1] }`.
 * Parameters: arena unused (layout lives on Module); ctx may be null → 0.
 * struct_name may be bare (`OneFuncResult`) or dotted; bare tail is matched.
 * Returns: field type_ref, or 0 if not found.
 * PLATFORM: SHARED — co-emit C TU; verify parser.x host-cc array-init residual.
 */
export function codegen_lookup_struct_field_type_ref(
  arena: *ASTArena,
  ctx: *PipelineDepCtx,
  struct_name: *u8,
  struct_name_len: i32,
  field_name: *u8,
  field_name_len: i32
): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    /* arena unused (layout lives on Module); XLANG has no unused-warning, so no
     * `(void)(arena);` C-style cast needed (such syntax hangs the parser). */
    if (struct_name == 0 as *u8 || struct_name_len <= 0 || field_name == 0 as *u8 || field_name_len <= 0) {
      return 0;
    }
    let bare_off: i32 = 0;
    let bi: i32 = 0;
    while (bi < struct_name_len && bi < 64) {
      if (struct_name[bi] == 46) {
        bare_off = bi + 1;
      }
      bi = bi + 1;
    }
    let bare_len: i32 = struct_name_len - bare_off;
    if (bare_len <= 0) {
      return 0;
    }
    let flen_use: i32 = field_name_len;
    if (flen_use > 64) {
      flen_use = 64;
    }
    let try_mod: *Module = 0 as *Module;
    let pass: i32 = 0;
    while (pass < 2) {
      let nmod: i32 = 1;
      if (pass == 1) {
        if (ctx == 0 as *PipelineDepCtx) {
          break;
        }
        nmod = pipeline_dep_ctx_ndep(ctx);
      }
      let mi: i32 = 0;
      while (mi < nmod) {
        if (pass == 0) {
          if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
            mi = mi + 1;
            continue;
          }
          try_mod = ctx.current_codegen_module;
        } else {
          try_mod = pipeline_dep_ctx_module_at(ctx, mi);
        }
        if (try_mod != 0 as *Module) {
          let k: i32 = 0;
          while (k < try_mod.num_struct_layouts) {
            let snl: i32 = pipeline_module_struct_layout_name_len(try_mod, k);
            if (snl == bare_len && snl > 0) {
              let snm: u8[64] = [];
              pipeline_module_struct_layout_name_into(try_mod, k, &snm[0]);
              let eq: bool = true;
              let sj: i32 = 0;
              while (sj < snl && sj < 64) {
                if (snm[sj] != struct_name[bare_off + sj]) {
                  eq = false;
                  break;
                }
                sj = sj + 1;
              }
              if (eq) {
                let nf: i32 = pipeline_module_struct_layout_num_fields(try_mod, k);
                let j: i32 = 0;
                while (j < nf) {
                  let fnl: i32 = pipeline_module_struct_layout_field_name_len(try_mod, k, j);
                  if (fnl == flen_use && fnl > 0) {
                    let fnm: u8[64] = [];
                    pipeline_module_struct_layout_field_name_into(try_mod, k, j, &fnm[0]);
                    let feq: bool = true;
                    let fj: i32 = 0;
                    while (fj < fnl && fj < 64) {
                      if (fnm[fj] != field_name[fj]) {
                        feq = false;
                        break;
                      }
                      fj = fj + 1;
                    }
                    if (feq) {
                      return pipeline_module_struct_layout_field_type_ref(try_mod, k, j);
                    }
                  }
                  j = j + 1;
                }
              }
            }
            k = k + 1;
          }
        }
        mi = mi + 1;
        if (pass == 0) {
          break;
        }
      }
      pass = pass + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_should_skip_emit_struct_layout_for_abi_dup(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8 || name_len <= 0) {
    return 0;
  }
  let nm_buffer: u8[7] = [66, 117, 102, 102, 101, 114, 0];
  let nm_completion: u8[11] = [67, 111, 109, 112, 108, 101, 116, 105, 111, 110, 0];
  let nm_async_ctx: u8[13] = [65, 115, 121, 110, 99, 67, 111, 110, 116, 101, 120, 116, 0];
  /* See implementation. */
  let nm_error: u8[6] = [69, 114, 114, 111, 114, 0];
  let nm_error_chain: u8[11] = [69, 114, 114, 111, 114, 67, 104, 97, 105, 110, 0];
  /*
   * See implementation.
   * See implementation.
   * PLATFORM: SHARED — seed pin and .x must agree (dual-authority ban).
   */
  let nm_option_us: u8[8] = [79, 112, 116, 105, 111, 110, 95, 0];
  /* See implementation. */
  let nm_option: u8[7] = [79, 112, 116, 105, 111, 110, 0];
  /*
   * rt_preamble one-liner also owns Result_i32 / Result_u8 (core_result_* tags).
   * Co-emit full layout → redefinition of 'core_result_Result_*' (hello / fmt path).
   * 【Invariant】bare Result_i32 / Result_u8 skip — same authority as seed pin.
   */
  let nm_result_i32: u8[11] = [82, 101, 115, 117, 108, 116, 95, 105, 51, 50, 0];
  let nm_result_u8: u8[10] = [82, 101, 115, 117, 108, 116, 95, 117, 56, 0];
  /*
   * See implementation.
   *   struct std_string_String { ... }; typedef ... String;
   *   struct std_string_StrView { ... };
   * See implementation.
   * See implementation.
   */
  let nm_string: u8[7] = [83, 116, 114, 105, 110, 103, 0];
  let nm_str_view: u8[8] = [83, 116, 114, 86, 105, 101, 119, 0];
  /*
   * See implementation.
   *   std_net_TcpStream/Listener/UdpSocket/Ipv4Addr/Ipv6Addr
   * See implementation.
   */
  let nm_tcp_stream: u8[10] = [84, 99, 112, 83, 116, 114, 101, 97, 109, 0];
  let nm_tcp_listener: u8[12] = [84, 99, 112, 76, 105, 115, 116, 101, 110, 101, 114, 0];
  let nm_udp_socket: u8[10] = [85, 100, 112, 83, 111, 99, 107, 101, 116, 0];
  let nm_ipv4: u8[9] = [73, 112, 118, 52, 65, 100, 100, 114, 0];
  let nm_ipv6: u8[9] = [73, 112, 118, 54, 65, 100, 100, 114, 0];
  let nm_sock_v4: u8[13] = [83, 111, 99, 107, 101, 116, 65, 100, 100, 114, 86, 52, 0];
  if (name_len == 6 && codegen_symbuf_bytes_eq(name, name_len, &nm_buffer[0], 6) != 0) {
    return 1;
  }
  if (name_len == 10 && codegen_symbuf_bytes_eq(name, name_len, &nm_completion[0], 10) != 0) {
    return 1;
  }
  if (name_len == 12 && codegen_symbuf_bytes_eq(name, name_len, &nm_async_ctx[0], 12) != 0) {
    return 1;
  }
  if (name_len == 5 && codegen_symbuf_bytes_eq(name, name_len, &nm_error[0], 5) != 0) {
    return 1;
  }
  if (name_len == 10 && codegen_symbuf_bytes_eq(name, name_len, &nm_error_chain[0], 10) != 0) {
    return 1;
  }
  /* See implementation. */
  if (name_len > 7 && codegen_symbuf_bytes_eq(name, 7, &nm_option_us[0], 7) != 0) {
    return 1;
  }
  if (name_len == 6 && codegen_symbuf_bytes_eq(name, name_len, &nm_option[0], 6) != 0) {
    return 1;
  }
  /* Result_i32 / Result_u8 — preamble owns complete core_result_* layouts. */
  if (name_len == 10 && codegen_symbuf_bytes_eq(name, name_len, &nm_result_i32[0], 10) != 0) {
    return 1;
  }
  if (name_len == 9 && codegen_symbuf_bytes_eq(name, name_len, &nm_result_u8[0], 9) != 0) {
    return 1;
  }
  if (name_len == 6 && codegen_symbuf_bytes_eq(name, name_len, &nm_string[0], 6) != 0) {
    return 1;
  }
  if (name_len == 7 && codegen_symbuf_bytes_eq(name, name_len, &nm_str_view[0], 7) != 0) {
    return 1;
  }
  if (name_len == 9 && codegen_symbuf_bytes_eq(name, name_len, &nm_tcp_stream[0], 9) != 0) {
    return 1;
  }
  if (name_len == 11 && codegen_symbuf_bytes_eq(name, name_len, &nm_tcp_listener[0], 11) != 0) {
    return 1;
  }
  if (name_len == 9 && codegen_symbuf_bytes_eq(name, name_len, &nm_udp_socket[0], 9) != 0) {
    return 1;
  }
  if (name_len == 8 && codegen_symbuf_bytes_eq(name, name_len, &nm_ipv4[0], 8) != 0) {
    return 1;
  }
  if (name_len == 8 && codegen_symbuf_bytes_eq(name, name_len, &nm_ipv6[0], 8) != 0) {
    return 1;
  }
  if (name_len == 12 && codegen_symbuf_bytes_eq(name, name_len, &nm_sock_v4[0], 12) != 0) {
    return 1;
  }
  /* Preamble owns Allocator/Arena64/FsIovecBuf/Iovec — skip co-emit redefinition.
   * PLATFORM: SHARED — keep lets flat at function scope. Nested `{ let ... }` anon
   * blocks are parse-skipped by the current product parser (residual body then
   * mis-ingested as top-level lets → illegal static/init_globals in force-regen). */
  let nm_allocator: u8[10] = [65, 108, 108, 111, 99, 97, 116, 111, 114, 0];
  let nm_arena64: u8[8] = [65, 114, 101, 110, 97, 54, 52, 0];
  let nm_fs_iovec: u8[11] = [70, 115, 73, 111, 118, 101, 99, 66, 117, 102, 0];
  let nm_iovec: u8[6] = [73, 111, 118, 101, 99, 0];
  if (name_len == 9 && codegen_symbuf_bytes_eq(name, name_len, &nm_allocator[0], 9) != 0) {
    return 1;
  }
  if (name_len == 7 && codegen_symbuf_bytes_eq(name, name_len, &nm_arena64[0], 7) != 0) {
    return 1;
  }
  if (name_len == 10 && codegen_symbuf_bytes_eq(name, name_len, &nm_fs_iovec[0], 10) != 0) {
    return 1;
  }
  if (name_len == 5 && codegen_symbuf_bytes_eq(name, name_len, &nm_iovec[0], 5) != 0) {
    return 1;
  }
  return 0;
}

/** Exported function `codegen_type_is_module_user_struct`.
 * Implements `codegen_type_is_module_user_struct`.
 * @param module *Module
 * @param arena *ASTArena
 * @param type_ref i32
 * @return i32
 */
export function codegen_type_is_module_user_struct(module: *Module, arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let name_len: i32 = 0;
    let ty_nm: u8[64] = [];
    if (module == 0 as *Module || arena == 0 as *ASTArena || ast.ref_is_null(type_ref)) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, type_ref) != TypeKind.TYPE_NAMED) {
      return 0;
    }
    name_len = pipeline_type_named_name_into(arena, type_ref, &ty_nm[0]);
    if (name_len <= 0) {
      return 0;
    }
    let k: i32 = 0;
    while (k < module.num_struct_layouts) {
      let nl: i32 = pipeline_module_struct_layout_name_len(module, k);
      if (nl == name_len) {
        let lay_nm: u8[64] = [];
        pipeline_module_struct_layout_name_into(module, k, &lay_nm[0]);
        let eq: bool = true;
        let j: i32 = 0;
        while (j < nl && j < 64) {
          if (lay_nm[j] != ty_nm[j]) {
            eq = false;
            break;
          }
          j = j + 1;
        }
        if (eq) {
          return 1;
        }
      }
      k = k + 1;
    }
    return 0;
  }
}

/** Exported function `codegen_type_is_module_user_enum`.
 * Implements `codegen_type_is_module_user_enum`.
 * @param module *Module
 * @param arena *ASTArena
 * @param type_ref i32
 * @return i32
 */
export function codegen_type_is_module_user_enum(module: *Module, arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let name_len: i32 = 0;
    let ty_nm: u8[64] = [];
    if (module == 0 as *Module || arena == 0 as *ASTArena || ast.ref_is_null(type_ref)) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, type_ref) != TypeKind.TYPE_NAMED) {
      return 0;
    }
    name_len = pipeline_type_named_name_into(arena, type_ref, &ty_nm[0]);
    if (name_len <= 0) {
      return 0;
    }
    let ei: i32 = 0;
    while (ei < module.num_module_enums) {
      let enl: i32 = pipeline_module_enum_name_len(module, ei);
      if (enl == name_len) {
        let eq: bool = true;
        let j: i32 = 0;
        while (j < name_len && j < 64) {
          if (pipeline_module_enum_name_byte_at(module, ei, j) != ty_nm[j]) {
            eq = false;
            break;
          }
          j = j + 1;
        }
        if (eq) {
          return 1;
        }
      }
      ei = ei + 1;
    }
    return 0;
  }
}

/** Exported function `codegen_type_dep_enum_prefix_into`.
 * Implements `codegen_type_dep_enum_prefix_into`.
 * @param ctx *PipelineDepCtx
 * @param arena *ASTArena
 * @param type_ref i32
 * @param dst *u8
 * @param dst_cap i32
 * @return i32
 */
export function codegen_type_dep_enum_prefix_into(ctx: *PipelineDepCtx, arena: *ASTArena, type_ref: i32, dst: *u8, dst_cap: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let name_len: i32 = 0;
    let ty_nm: u8[64] = [];
    let di: i32 = 0;
    if (ctx == 0 as *PipelineDepCtx || arena == 0 as *ASTArena || dst == 0 as *u8 || dst_cap <= 0 || ast.ref_is_null(type_ref)) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, type_ref) != TypeKind.TYPE_NAMED) {
      return 0;
    }
    name_len = pipeline_type_named_name_into(arena, type_ref, &ty_nm[0]);
    if (name_len <= 0) {
      return 0;
    }
    let bare_off: i32 = 0;
    let bi: i32 = 0;
    while (bi < name_len && bi < 64) {
      if (ty_nm[bi] == 46) {
        bare_off = bi + 1;
      }
      bi = bi + 1;
    }
    let bare_len: i32 = name_len - bare_off;
    di = 0;
    while (di < pipeline_dep_ctx_ndep(ctx)) {
      let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, di);
      if (dep_mod != 0 as *Module) {
        let ei: i32 = 0;
        while (ei < dep_mod.num_module_enums) {
          let dep_name_len: i32 = pipeline_module_enum_name_len(dep_mod, ei);
          if (dep_name_len == bare_len) {
            let eq: bool = true;
            let j: i32 = 0;
            while (j < bare_len && j < 64) {
              if (pipeline_module_enum_name_byte_at(dep_mod, ei, j) != ty_nm[bare_off + j]) {
                eq = false;
                break;
              }
              j = j + 1;
            }
            if (eq) {
              let dep_path: u8[64] = [];
              let plen: i32 = codegen_dep_import_path_len_at(ctx, di, &dep_path[0]);
              if (plen > 0) {
                codegen_import_path_to_c_prefix_into(&dep_path[0], dst, dst_cap);
                let out_len: i32 = 0;
                while (out_len < dst_cap && dst[out_len] != 0 as u8) {
                  out_len = out_len + 1;
                }
                return out_len;
              }
            }
          }
          ei = ei + 1;
        }
      }
      di = di + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_emit_struct_field_decl_x(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, field_name: *u8, field_name_len: i32, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let base_ref: i32 = type_ref;
    if (ast.ref_is_null(type_ref) || field_name == 0 as *u8 || field_name_len <= 0) {
      return -1;
    }
    while (!ast.ref_is_null(base_ref) && pipeline_type_kind_ord_at(arena, base_ref) == TypeKind.TYPE_ARRAY) {
      let inner: i32 = pipeline_type_elem_ref_at(arena, base_ref);
      if (ast.ref_is_null(inner)) {
        break;
      }
      base_ref = inner;
    }
    if (emit_type(arena, out, base_ref, struct_prefix, struct_prefix_len, ctx) != 0) {
      return -1;
    }
    if (append_byte(out, 32) != 0) {
      return -1;
    }
    if (emit_bytes_from_ptr(out, field_name, field_name_len) != 0) {
      return -1;
    }
    let dims_ref: i32 = type_ref;
    while (!ast.ref_is_null(dims_ref) && pipeline_type_kind_ord_at(arena, dims_ref) == TypeKind.TYPE_ARRAY) {
      let lbr: u8[2] = [91, 0];
      let rbr: u8[2] = [93, 0];
      if (emit_bytes_2(out, lbr, 1) != 0) {
        return -1;
      }
      if (format_int(out, pipeline_type_array_size_at(arena, dims_ref)) != 0) {
        return -1;
      }
      if (emit_bytes_2(out, rbr, 1) != 0) {
        return -1;
      }
      dims_ref = pipeline_type_elem_ref_at(arena, dims_ref);
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_emit_module_struct_definitions(module: *Module, arena: *ASTArena, out: *CodegenOutBuf, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let k: i32 = 0;
    let cur_di: i32 = -1;
    if (ctx != 0 as *PipelineDepCtx) {
      cur_di = ctx.current_codegen_dep_index;
    }
    while (k < module.num_struct_layouts) {
      let nf: i32 = pipeline_module_struct_layout_num_fields(module, k);
      let nl: i32 = pipeline_module_struct_layout_name_len(module, k);
      if (nf <= 0 || nl <= 0) {
        k = k + 1;
        continue;
      }
      let ty_nm: u8[64] = [];
      pipeline_module_struct_layout_name_into(module, k, &ty_nm[0]);
      /*
       * PLATFORM: SHARED — only the defining owner emits full C layout.
       * Entry (cur_di < 0) must also skip dep-owned names (e.g. Lexer from lexer.x).
       * Otherwise co-emit re-emits as parser_Lexer; entry prime/merge layouts may have
       * field_type_ref=0 on later fields → field_decl fail mid-struct (parser M1 residual).
       * Authority: codegen_type_dep_struct_owner_index (export-first); seed pin same commit.
       */
      if (ctx != 0 as *PipelineDepCtx) {
        let owner: i32 = codegen_type_dep_struct_owner_index(ctx, &ty_nm[0], nl);
        if (owner >= 0 && owner != cur_di) {
          k = k + 1;
          continue;
        }
      }
      if (codegen_should_skip_emit_struct_layout_for_abi_dup(&ty_nm[0], nl) != 0) {
        k = k + 1;
        continue;
      }
      /* See implementation. */
      let claim_pfx: u8[128] = [];
      let claim_plen: i32 = 0;
      if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
        claim_plen = struct_prefix_len;
        if (claim_plen > 127) {
          claim_plen = 127;
        }
        let ci: i32 = 0;
        while (ci < claim_plen) {
          claim_pfx[ci] = struct_prefix[ci];
          ci = ci + 1;
        }
      } else if (!(ctx != 0 as *PipelineDepCtx && ctx.current_codegen_dep_index < 0)) {
        claim_pfx[0] = 97;
        claim_pfx[1] = 115;
        claim_pfx[2] = 116;
        claim_pfx[3] = 95;
        claim_plen = 4;
      }
      if (pipeline_codegen_struct_tag_try_claim(&claim_pfx[0], claim_plen, &ty_nm[0], nl) == 0) {
        k = k + 1;
        continue;
      }
      let hdr_top: u8[8] = [115, 116, 114, 117, 99, 116, 32, 0];
      if (emit_bytes_8(out, hdr_top, 7) != 0) {
        return -1;
      }
      if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
        if (emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) != 0) {
          return -1;
        }
      } else if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_dep_index < 0) {
        /* See implementation. */
      } else {
        let ast_top: u8[4] = [97, 115, 116, 95];
        if (emit_bytes_4(out, ast_top, 4) != 0) {
          return -1;
        }
      }
      if (emit_bytes_from_ptr(out, &ty_nm[0], nl) != 0) {
        return -1;
      }
      let br1: u8[4] = [32, 123, 10, 0];
      if (emit_bytes_4(out, br1, 3) != 0) {
        return -1;
      }
      let j: i32 = 0;
      while (j < nf) {
        let flen: i32 = pipeline_module_struct_layout_field_name_len(module, k, j);
        let ftr: i32 = pipeline_module_struct_layout_field_type_ref(module, k, j);
        if (flen <= 0) {
          j = j + 1;
          continue;
        }
        if (emit_indent(out, 2) != 0) {
          return -1;
        }
        let fnm: u8[64] = [];
        pipeline_module_struct_layout_field_name_into(module, k, j, &fnm[0]);
        if (codegen_emit_struct_field_decl_x(arena, out, ftr, &fnm[0], flen, 0 as *u8, 0, ctx) != 0) {
          return -1;
        }
        let semi_nl: u8[3] = [59, 10, 0];
        if (emit_bytes_3(out, semi_nl, 2) != 0) {
          return -1;
        }
        j = j + 1;
      }
      let close_ty: u8[4] = [125, 59, 10, 10];
      if (emit_bytes_4(out, close_ty, 4) != 0) {
        return -1;
      }
      k = k + 1;
    }
    return 0;
  }
}

/** Exported function `codegen_emit_module_struct_forward_declarations`.
 * Implements `codegen_emit_module_struct_forward_declarations`.
 * @param module *Module
 * @param out *CodegenOutBuf
 * @param struct_prefix *u8
 * @param struct_prefix_len i32
 * @return i32
 */
export function codegen_emit_module_struct_forward_declarations(module: *Module, out: *CodegenOutBuf, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  return codegen_emit_module_struct_forward_declarations_ctx(module, out, struct_prefix, struct_prefix_len, 0 as *PipelineDepCtx);
}

/** Exported function `codegen_emit_module_struct_forward_declarations_ctx`.
 * Implements `codegen_emit_module_struct_forward_declarations_ctx`.
 * @param module *Module
 * @param out *CodegenOutBuf
 * @param struct_prefix *u8
 * @param struct_prefix_len i32
 * @param ctx *PipelineDepCtx
 * @return i32
 */
export function codegen_emit_module_struct_forward_declarations_ctx(module: *Module, out: *CodegenOutBuf, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let k: i32 = 0;
    let cur_di: i32 = -1;
    if (ctx != 0 as *PipelineDepCtx) {
      cur_di = ctx.current_codegen_dep_index;
    }
    while (k < module.num_struct_layouts) {
      let nf: i32 = pipeline_module_struct_layout_num_fields(module, k);
      let nl: i32 = pipeline_module_struct_layout_name_len(module, k);
      if (nf <= 0 || nl <= 0) {
        k = k + 1;
        continue;
      }
      let ty_nm: u8[64] = [];
      pipeline_module_struct_layout_name_into(module, k, &ty_nm[0]);
      /* PLATFORM: SHARED — same owner skip as codegen_emit_module_struct_definitions (entry + dep). */
      if (ctx != 0 as *PipelineDepCtx) {
        let owner: i32 = codegen_type_dep_struct_owner_index(ctx, &ty_nm[0], nl);
        if (owner >= 0 && owner != cur_di) {
          k = k + 1;
          continue;
        }
      }
      /* "struct " */
      let hdr: u8[8] = [115, 116, 114, 117, 99, 116, 32, 0];
      if (emit_bytes_from_ptr(out, &hdr[0], 7) != 0) {
        return -1;
      }
      if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
        if (emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) != 0) {
          return -1;
        }
      }
      if (emit_bytes_from_ptr(out, &ty_nm[0], nl) != 0) {
        return -1;
      }
      /* ";\n" */
      let semi_nl: u8[2] = [59, 10];
      if (emit_bytes_from_ptr(out, &semi_nl[0], 2) != 0) {
        return -1;
      }
      k = k + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_emit_module_enum_definitions(module: *Module, out: *CodegenOutBuf, enum_prefix: *u8, enum_prefix_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let ei: i32 = 0;
    while (ei < module.num_module_enums) {
      let enl: i32 = pipeline_module_enum_name_len(module, ei);
      if (enl <= 0) {
        ei = ei + 1;
        continue;
      }
      let enm: u8[64] = [];
      let hdr: u8[8] = [101, 110, 117, 109, 32, 0, 0, 0];
      let open: u8[4] = [32, 123, 32, 0];
      let close: u8[6] = [32, 125, 59, 10, 0, 0];
      let comma: u8[3] = [44, 32, 0];
      pipeline_module_enum_name_byte_at(module, ei, 0);
      let nk: i32 = 0;
      while (nk < enl && nk < 64) {
        enm[nk] = pipeline_module_enum_name_byte_at(module, ei, nk);
        nk = nk + 1;
      }
      /* See implementation. */
      let claim_pfx: u8[128] = [];
      let claim_plen: i32 = 0;
      claim_pfx[0] = 101;
      claim_plen = 1;
      if (enum_prefix != 0 as *u8 && enum_prefix_len > 0) {
        let ep: i32 = enum_prefix_len;
        if (ep > 126) {
          ep = 126;
        }
        let ei2: i32 = 0;
        while (ei2 < ep) {
          claim_pfx[1 + ei2] = enum_prefix[ei2];
          ei2 = ei2 + 1;
        }
        claim_plen = 1 + ep;
      }
      if (pipeline_codegen_struct_tag_try_claim(&claim_pfx[0], claim_plen, &enm[0], enl) == 0) {
        ei = ei + 1;
        continue;
      }
      if (emit_bytes_from_ptr(out, &hdr[0], 5) != 0) {
        return -1;
      }
      if (enum_prefix != 0 as *u8 && enum_prefix_len > 0) {
        if (emit_bytes_from_ptr(out, enum_prefix, enum_prefix_len) != 0) {
          return -1;
        }
      }
      if (emit_bytes_from_ptr(out, &enm[0], enl) != 0) {
        return -1;
      }
      if (emit_bytes_4(out, open, 3) != 0) {
        return -1;
      }
      let nv: i32 = pipeline_module_enum_num_variants(module, ei);
      let vi: i32 = 0;
      while (vi < nv) {
        let vlen: i32 = pipeline_module_enum_variant_name_len(module, ei, vi);
        let vnm: u8[64] = [];
        let vk: i32 = 0;
        if (vi > 0) {
          if (emit_bytes_3(out, comma, 2) != 0) {
            return -1;
          }
        }
        while (vk < vlen && vk < 64) {
          vnm[vk] = pipeline_module_enum_variant_name_byte_at(module, ei, vi, vk);
          vk = vk + 1;
        }
        if (enum_prefix != 0 as *u8 && enum_prefix_len > 0) {
          if (emit_bytes_from_ptr(out, enum_prefix, enum_prefix_len) != 0) {
            return -1;
          }
        }
        if (emit_bytes_from_ptr(out, &enm[0], enl) != 0) {
          return -1;
        }
        if (append_byte(out, 95) != 0) {
          return -1;
        }
        if (vlen > 0 && emit_bytes_from_ptr(out, &vnm[0], vlen) != 0) {
          return -1;
        }
        vi = vi + 1;
      }
      if (emit_bytes_from_ptr(out, &close[0], 4) != 0) {
        return -1;
      }
      ei = ei + 1;
    }
    return 0;
  }
}

/**
 * Emit enum/struct type definitions for every dep module in import-first order.
 *
 * Why: flat di order registers parents before leaf imports (lexer before token).
 * LexerResult embeds token.Token by value → host C needs token_Token complete before
 * lexer_LexerResult (parser M1 host-cc residual).
 *
 * Algorithm (PLATFORM: SHARED): Kahn-style multi-pass over dep indices — a dep is
 * emitted only when every import path that resolves to another dep slot is already
 * emitted (or not in the pool). Caps at nd+2 passes; remainder emitted in di order.
 * Path de-dupe still applies. Restores current_codegen_* after work.
 */
export function codegen_emit_skipped_dep_type_definitions(ctx: *PipelineDepCtx, out: *CodegenOutBuf): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || out == 0 as *CodegenOutBuf) {
      return 0;
    }
    let saved_module: *Module = ctx.current_codegen_module;
    let saved_arena: *ASTArena = ctx.current_codegen_arena;
    let saved_dep_index: i32 = ctx.current_codegen_dep_index;
    let saved_prefix_len: i32 = ctx.current_codegen_prefix_len;
    let saved_prefix: u8[64] = [];
    let sp: i32 = 0;
    while (sp < 64) {
      saved_prefix[sp] = ctx.current_codegen_prefix_mirror[sp];
      sp = sp + 1;
    }
    let nd: i32 = pipeline_dep_ctx_ndep(ctx);
    /* Cap 64 dep slots for emit-done flags (product graphs are far smaller). */
    let done: i32[64] = [];
    let di_init: i32 = 0;
    while (di_init < 64) {
      done[di_init] = 0;
      di_init = di_init + 1;
    }
    let remaining: i32 = 0;
    let di_count: i32 = 0;
    while (di_count < nd) {
      let dep_mod0: *Module = pipeline_dep_ctx_module_at(ctx, di_count);
      let dep_arena0: *ASTArena = pipeline_dep_ctx_arena_at(ctx, di_count);
      let dep_path0: u8[64] = [];
      let plen0: i32 = codegen_dep_import_path_len_at(ctx, di_count, &dep_path0[0]);
      if (dep_mod0 != 0 as *Module && dep_arena0 != 0 as *ASTArena && plen0 > 0) {
        remaining = remaining + 1;
      } else {
        done[di_count] = 1;
      }
      di_count = di_count + 1;
    }
    let pass: i32 = 0;
    let max_pass: i32 = nd + 2;
    while (remaining > 0 && pass < max_pass) {
      let progressed: i32 = 0;
      let di: i32 = 0;
      while (di < nd) {
        if (done[di] != 0) {
          di = di + 1;
          continue;
        }
        let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, di);
        let dep_arena: *ASTArena = pipeline_dep_ctx_arena_at(ctx, di);
        let dep_path: u8[64] = [];
        let dep_path_len: i32 = codegen_dep_import_path_len_at(ctx, di, &dep_path[0]);
        if (dep_mod == 0 as *Module || dep_arena == 0 as *ASTArena || dep_path_len <= 0) {
          done[di] = 1;
          di = di + 1;
          continue;
        }
        /* Ready iff every resolved import dep is already emitted. */
        let ready: i32 = 1;
        let n_imp: i32 = codegen_module_num_imports(dep_mod);
        let ii: i32 = 0;
        while (ii < n_imp) {
          let ipath: u8[64] = [];
          let ilen: i32 = codegen_module_import_path_len_at(dep_mod, ii, &ipath[0]);
          if (ilen > 0) {
            let idi: i32 = codegen_find_dep_index_by_path(ctx, &ipath[0], ilen);
            if (idi >= 0 && idi < nd && idi != di && done[idi] == 0) {
              ready = 0;
              break;
            }
          }
          ii = ii + 1;
        }
        if (ready == 0) {
          di = di + 1;
          continue;
        }
        /* Path de-dupe: first *non-empty* registration (lower di) is authority.
         * Why: an earlier same-path slot with num_struct_layouts==0 (failed/partial load)
         * must not suppress a later real module (parser M1: missing struct ast_* full
         * layouts → dual-extern incomplete tags). Later empty re-regs still suppressed
         * once a non-empty slot for the path was seen.
         * PLATFORM: SHARED — co-emit C TU; verify parser.x -E host-cc + typeck -E. */
        let seen_before: i32 = 0;
        let pj: i32 = 0;
        while (pj < di) {
          let prev_path: u8[64] = [];
          let prev_len: i32 = codegen_dep_import_path_len_at(ctx, pj, &prev_path[0]);
          if (prev_len == dep_path_len) {
            let eq_prev: bool = true;
            let pk: i32 = 0;
            while (pk < dep_path_len && pk < 64) {
              if (prev_path[pk] != dep_path[pk]) {
                eq_prev = false;
                break;
              }
              pk = pk + 1;
            }
            if (eq_prev) {
              let prev_mod: *Module = pipeline_dep_ctx_module_at(ctx, pj);
              if (prev_mod != 0 as *Module && prev_mod.num_struct_layouts > 0) {
                seen_before = 1;
                break;
              }
            }
          }
          pj = pj + 1;
        }
        if (seen_before == 0) {
          let prefix_buf: u8[128] = [];
          let prefix_len: i32 = 0;
          if (codegen_path_is_std_io_core_bytes(&dep_path[0]) == 0) {
            codegen_import_path_to_c_prefix_into(&dep_path[0], &prefix_buf[0], 128);
            while (prefix_len < 128 && prefix_buf[prefix_len] != 0 as u8) {
              prefix_len = prefix_len + 1;
            }
          }
          ctx.current_codegen_module = dep_mod;
          ctx.current_codegen_arena = dep_arena;
          ctx.current_codegen_dep_index = di;
          ctx.current_codegen_prefix_len = 0;
          let px: i32 = 0;
          while (px < prefix_len && px < 63) {
            ctx.current_codegen_prefix_mirror[px] = prefix_buf[px];
            px = px + 1;
          }
          ctx.current_codegen_prefix_mirror[px] = 0 as u8;
          ctx.current_codegen_prefix_len = px;
          if (codegen_emit_module_enum_definitions(dep_mod, out, &prefix_buf[0], prefix_len) != 0) {
            return -1;
          }
          if (codegen_emit_module_struct_definitions(dep_mod, dep_arena, out, &prefix_buf[0], prefix_len, ctx) != 0) {
            return -1;
          }
        }
        done[di] = 1;
        remaining = remaining - 1;
        progressed = 1;
        di = di + 1;
      }
      if (progressed == 0) {
        /* Cycle / unresolved: emit remaining in di order. */
        let dj: i32 = 0;
        while (dj < nd) {
          if (done[dj] == 0) {
            let dep_mod2: *Module = pipeline_dep_ctx_module_at(ctx, dj);
            let dep_arena2: *ASTArena = pipeline_dep_ctx_arena_at(ctx, dj);
            let dep_path2: u8[64] = [];
            let plen2: i32 = codegen_dep_import_path_len_at(ctx, dj, &dep_path2[0]);
            if (dep_mod2 != 0 as *Module && dep_arena2 != 0 as *ASTArena && plen2 > 0) {
              let prefix_buf2: u8[128] = [];
              let prefix_len2: i32 = 0;
              if (codegen_path_is_std_io_core_bytes(&dep_path2[0]) == 0) {
                codegen_import_path_to_c_prefix_into(&dep_path2[0], &prefix_buf2[0], 128);
                while (prefix_len2 < 128 && prefix_buf2[prefix_len2] != 0 as u8) {
                  prefix_len2 = prefix_len2 + 1;
                }
              }
              ctx.current_codegen_module = dep_mod2;
              ctx.current_codegen_arena = dep_arena2;
              ctx.current_codegen_dep_index = dj;
              let px2: i32 = 0;
              while (px2 < prefix_len2 && px2 < 63) {
                ctx.current_codegen_prefix_mirror[px2] = prefix_buf2[px2];
                px2 = px2 + 1;
              }
              ctx.current_codegen_prefix_mirror[px2] = 0 as u8;
              ctx.current_codegen_prefix_len = px2;
              if (codegen_emit_module_enum_definitions(dep_mod2, out, &prefix_buf2[0], prefix_len2) != 0) {
                return -1;
              }
              if (codegen_emit_module_struct_definitions(dep_mod2, dep_arena2, out, &prefix_buf2[0], prefix_len2, ctx) != 0) {
                return -1;
              }
            }
            done[dj] = 1;
            remaining = remaining - 1;
          }
          dj = dj + 1;
        }
      }
      pass = pass + 1;
    }
    ctx.current_codegen_module = saved_module;
    ctx.current_codegen_arena = saved_arena;
    ctx.current_codegen_dep_index = saved_dep_index;
    ctx.current_codegen_prefix_len = saved_prefix_len;
    sp = 0;
    while (sp < 64) {
      ctx.current_codegen_prefix_mirror[sp] = saved_prefix[sp];
      sp = sp + 1;
    }
    return 0;
  }
}

/** Exported function `codegen_emit_dep_struct_forward_declarations`.
 * Implements `codegen_emit_dep_struct_forward_declarations`.
 * @param ctx *PipelineDepCtx
 * @param out *CodegenOutBuf
 * @return i32
 */
export function codegen_emit_dep_struct_forward_declarations(ctx: *PipelineDepCtx, out: *CodegenOutBuf): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || out == 0 as *CodegenOutBuf) {
      return 0;
    }
    let saved_dep_index: i32 = ctx.current_codegen_dep_index;
    let nd: i32 = pipeline_dep_ctx_ndep(ctx);
    let di: i32 = 0;
    while (di < nd) {
      let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, di);
      if (dep_mod != 0 as *Module) {
        let dep_path: u8[64] = [];
        let dep_path_len: i32 = codegen_dep_import_path_len_at(ctx, di, &dep_path[0]);
        let prefix_buf: u8[128] = [];
        let prefix_len: i32 = 0;
        if (dep_path_len > 0 && codegen_path_is_std_io_core_bytes(&dep_path[0]) == 0) {
          codegen_import_path_to_c_prefix_into(&dep_path[0], &prefix_buf[0], 128);
          while (prefix_len < 128 && prefix_buf[prefix_len] != 0 as u8) {
            prefix_len = prefix_len + 1;
          }
        }
        ctx.current_codegen_dep_index = di;
        if (codegen_emit_module_struct_forward_declarations_ctx(dep_mod, out, &prefix_buf[0], prefix_len, ctx) != 0) {
          ctx.current_codegen_dep_index = saved_dep_index;
          return -1;
        }
      }
      di = di + 1;
    }
    /* Owner-prefixed file-scope forwards (dedupe by claim of mangled tag). */
    di = 0;
    while (di < nd) {
      let dep_mod2: *Module = pipeline_dep_ctx_module_at(ctx, di);
      if (dep_mod2 != 0 as *Module) {
        let k: i32 = 0;
        while (k < dep_mod2.num_struct_layouts) {
          let nl: i32 = pipeline_module_struct_layout_name_len(dep_mod2, k);
          let nf: i32 = pipeline_module_struct_layout_num_fields(dep_mod2, k);
          if (nl > 0 && nf > 0) {
            let ty_nm: u8[64] = [];
            pipeline_module_struct_layout_name_into(dep_mod2, k, &ty_nm[0]);
            let owner: i32 = codegen_type_dep_struct_owner_index(ctx, &ty_nm[0], nl);
            if (owner >= 0) {
              let opath: u8[64] = [];
              let oplen: i32 = codegen_dep_import_path_len_at(ctx, owner, &opath[0]);
              let opfx: u8[128] = [];
              let opfx_len: i32 = 0;
              if (oplen > 0 && codegen_path_is_std_io_core_bytes(&opath[0]) == 0) {
                codegen_import_path_to_c_prefix_into(&opath[0], &opfx[0], 128);
                while (opfx_len < 128 && opfx[opfx_len] != 0 as u8) {
                  opfx_len = opfx_len + 1;
                }
              }
              /* C allows redundant `struct Tag;` — emit owner-prefixed forward always.
               * Do not try_claim: that would block later full layout emit of the same tag. */
              let hdr: u8[8] = [115, 116, 114, 117, 99, 116, 32, 0];
              if (emit_bytes_from_ptr(out, &hdr[0], 7) != 0) {
                ctx.current_codegen_dep_index = saved_dep_index;
                return -1;
              }
              if (opfx_len > 0 && emit_bytes_from_ptr(out, &opfx[0], opfx_len) != 0) {
                ctx.current_codegen_dep_index = saved_dep_index;
                return -1;
              }
              if (emit_bytes_from_ptr(out, &ty_nm[0], nl) != 0) {
                ctx.current_codegen_dep_index = saved_dep_index;
                return -1;
              }
              let semi_nl: u8[2] = [59, 10];
              if (emit_bytes_from_ptr(out, &semi_nl[0], 2) != 0) {
                ctx.current_codegen_dep_index = saved_dep_index;
                return -1;
              }
            }
          }
          k = k + 1;
        }
      }
      di = di + 1;
    }
    ctx.current_codegen_dep_index = saved_dep_index;
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_resolve_binding_import_path_for_field_access(ctx: *PipelineDepCtx, arena: *ASTArena, expr_ref: i32, dst: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
      return 0;
    }
    if (arena == 0 as *ASTArena || dst == 0 as *u8 || expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    if (e.kind != ExprKind.EXPR_FIELD_ACCESS) {
      return 0;
    }
    if (e.field_access_base_ref <= 0 || e.field_access_base_ref > arena.num_exprs) {
      return 0;
    }
    let base: Expr = ast.ast_arena_expr_get(arena, e.field_access_base_ref);
    if (base.kind != ExprKind.EXPR_VAR || base.var_name_len <= 0) {
      return 0;
    }
    let cur_mod: *Module = ctx.current_codegen_module;
    let j: i32 = 0;
    let n_imp: i32 = codegen_module_num_imports(cur_mod);
    while (j < n_imp) {
      if (pipeline_module_import_kind_at(cur_mod, j) != 1) {
        j = j + 1;
        continue;
      }
      let bind_len: i32 = pipeline_module_import_binding_name_len(cur_mod, j);
      if (bind_len != base.var_name_len) {
        j = j + 1;
        continue;
      }
      let eq: bool = true;
      let kk: i32 = 0;
      while (kk < base.var_name_len) {
        if (base.var_name[kk] != pipeline_module_import_binding_name_byte_at(cur_mod, j, kk)) {
          eq = false;
          break;
        }
        kk = kk + 1;
      }
      if (!eq) {
        j = j + 1;
        continue;
      }
      return codegen_module_import_path_len_at(cur_mod, j, dst);
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_resolve_binding_import_path_for_method_call(ctx: *PipelineDepCtx, arena: *ASTArena, expr_ref: i32, dst: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
      return 0;
    }
    if (arena == 0 as *ASTArena || dst == 0 as *u8 || expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    if (e.kind != ExprKind.EXPR_METHOD_CALL) {
      return 0;
    }
    if (e.method_call_base_ref <= 0 || e.method_call_base_ref > arena.num_exprs) {
      return 0;
    }
    let base: Expr = ast.ast_arena_expr_get(arena, e.method_call_base_ref);
    if (base.kind != ExprKind.EXPR_VAR || base.var_name_len <= 0) {
      return 0;
    }
    let cur_mod: *Module = ctx.current_codegen_module;
    let j: i32 = 0;
    let n_imp: i32 = codegen_module_num_imports(cur_mod);
    while (j < n_imp) {
      if (pipeline_module_import_kind_at(cur_mod, j) != 1) {
        j = j + 1;
        continue;
      }
      let bind_len: i32 = pipeline_module_import_binding_name_len(cur_mod, j);
      if (bind_len != base.var_name_len) {
        j = j + 1;
        continue;
      }
      let eq: bool = true;
      let kk: i32 = 0;
      while (kk < base.var_name_len) {
        if (base.var_name[kk] != pipeline_module_import_binding_name_byte_at(cur_mod, j, kk)) {
          eq = false;
          break;
        }
        kk = kk + 1;
      }
      if (!eq) {
        j = j + 1;
        continue;
      }
      return codegen_module_import_path_len_at(cur_mod, j, dst);
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function emit_import_module_field_symbol(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  if (ctx == 0 as *PipelineDepCtx || arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf) {
    return -1;
  }
  if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
    return -1;
  }
  let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
  let dep_path: u8[64] = [];
  let dep_path_len: i32 = codegen_resolve_binding_import_path_for_field_access(ctx, arena, expr_ref, &dep_path[0]);
  if (e.kind != ExprKind.EXPR_FIELD_ACCESS || dep_path_len <= 0) {
    return -1;
  }
  let pre: u8[128] = [];
  codegen_import_path_to_c_prefix_into(&dep_path[0], &pre[0], 128);
  let plen: i32 = 0;
  while (plen < 128 && pre[plen] != 0) {
    plen = plen + 1;
  }
  if (plen > 0 && codegen_c_prefix_redundant_with_name(&pre[0], plen, &e.field_access_field_name[0], e.field_access_field_len) == 0 && emit_bytes_from_ptr(out, &pre[0], plen) != 0) {
    return -1;
  }
  if (e.field_access_field_len > 0 && emit_bytes_from_ptr(out, &e.field_access_field_name[0], e.field_access_field_len) != 0) {
    return -1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function emit_import_module_const_field(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
      return -1;
    }
    if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return -1;
    }
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    let dep_path: u8[64] = [];
    let dep_path_len: i32 = codegen_resolve_binding_import_path_for_field_access(ctx, arena, expr_ref, &dep_path[0]);
    if (e.kind != ExprKind.EXPR_FIELD_ACCESS || dep_path_len <= 0) {
      return -1;
    }
    let dep_ix: i32 = codegen_find_dep_index_by_path(ctx, &dep_path[0], dep_path_len);
    if (dep_ix < 0 || dep_ix >= pipeline_dep_ctx_ndep(ctx)) {
      return -1;
    }
    let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix);
    if (dep_mod == 0 as *Module) {
      return -1;
    }
    let ti: i32 = 0;
    while (ti < dep_mod.num_top_level_lets) {
      if (pipeline_module_top_level_let_is_const(dep_mod, ti) == 0) {
        ti = ti + 1;
        continue;
      }
      let nlen: i32 = pipeline_module_top_level_let_name_len(dep_mod, ti);
      if (nlen != e.field_access_field_len) {
        ti = ti + 1;
        continue;
      }
      let nm_eq: bool = true;
      let ni: i32 = 0;
      while (ni < nlen) {
        if (pipeline_module_top_level_let_name_byte_at(dep_mod, ti, ni) != e.field_access_field_name[ni]) {
          nm_eq = false;
          break;
        }
        ni = ni + 1;
      }
      if (!nm_eq) {
        ti = ti + 1;
        continue;
      }
      return emit_import_module_field_symbol(arena, out, expr_ref, ctx);
    }
    return -1;
  }
}

/**
 * Host-C emit for EXPR_MATCH arms[arm_i..): nested ternary chain.
 * @param arena *ASTArena — expression arena
 * @param out *CodegenOutBuf — C text sink
 * @param expr_ref i32 — EXPR_MATCH node
 * @param ctx *PipelineDepCtx — emit context (may be null)
 * @param arm_i i32 — current arm index (0-based)
 * @return i32 — 0 on success, -1 on emit failure
 * PLATFORM: SHARED — mirrors freestanding pipeline_asm_emit_match_elf_c semantics
 * (first match wins; wildcard ends chain). Host C re-emits the subject per arm
 * (subjects are typically VAR/param). G.7: completes arm-0 residual that only
 * emitted the first arm result without comparing.
 */
function codegen_emit_match_from_arm(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32,
    ctx: *PipelineDepCtx, arm_i: i32): i32 {
  // PLATFORM: SHARED — host-C match nested ternary; seed twin same commit.
  unsafe {
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    let n: i32 = e.match_num_arms;
    let matched: i32 = e.match_matched_ref;
    let res: i32 = 0;
    let cmp_val: i32 = 0;
    let eq: u8[3] = [61, 61, 0];
    if (arm_i >= n) {
      return append_byte(out, 48);
    }
    if (pipeline_expr_match_arm_is_wildcard(arena, expr_ref, arm_i) != 0) {
      res = pipeline_expr_match_arm_result_ref(arena, expr_ref, arm_i);
      if (ast.ref_is_null(res)) {
        return append_byte(out, 48);
      }
      return emit_expr(arena, out, res, ctx);
    }
    /* (matched==val?(result):(rest)) */
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (ast.ref_is_null(matched) || emit_expr(arena, out, matched, ctx) != 0) {
      return -1;
    }
    if (emit_bytes_2(out, eq, 2) != 0) {
      return -1;
    }
    if (pipeline_expr_match_arm_is_enum_variant(arena, expr_ref, arm_i) != 0) {
      cmp_val = pipeline_expr_match_arm_variant_index(arena, expr_ref, arm_i);
    } else {
      cmp_val = pipeline_expr_match_arm_lit_val(arena, expr_ref, arm_i);
    }
    if (format_int(out, cmp_val as i64) != 0) {
      return -1;
    }
    if (append_byte(out, 63) != 0) {
      return -1;
    }
    res = pipeline_expr_match_arm_result_ref(arena, expr_ref, arm_i);
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (ast.ref_is_null(res) || emit_expr(arena, out, res, ctx) != 0) {
      return -1;
    }
    if (append_byte(out, 41) != 0) {
      return -1;
    }
    if (append_byte(out, 58) != 0) {
      return -1;
    }
    if (codegen_emit_match_from_arm(arena, out, expr_ref, ctx, arm_i + 1) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
}

/**
 * Emit a single expression as C source text into out.
 * @param arena *ASTArena — expression arena
 * @param out *CodegenOutBuf — C text sink
 * @param expr_ref i32 — expression ref
 * @param ctx *PipelineDepCtx — emit context (may be null)
 * @return i32 — 0 on success, -1 on failure
 */
export function emit_expr(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ast.ref_is_null(expr_ref)) {
      return 0;
    }
    if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    /**
     * PLATFORM: SHARED — consume typeck CTFE (const_folded_*). Authority is typeck fold,
     * not emit-side optim; C path mirrors asm mov-imm when typeck folded the tree.
     * Skip VAR (ord 3): pool field may be stale; VAR names resolve via const/let slots.
     * Skip FLOAT_LIT (ord 1): wave287 — i32 fold truncates fractions; emit via
     * pipeline_codegen_emit_float_lit_c on float_val (seed codegen twin same commit).
     */
    if (e.const_folded_valid != 0 && pipeline_expr_kind_ord_at(arena, expr_ref) != 3
    && pipeline_expr_kind_ord_at(arena, expr_ref) != 1) {
      if (format_int(out, e.const_folded_val as i64) != 0) {
        return -1;
      }
      return 0;
    }
    /* STRING_LIT(kind 59)。
     * See implementation.
     * See implementation.
     * See implementation.
     * See implementation.
     * See implementation.
     * See implementation.
     * See implementation.
    if (pipeline_expr_kind_ord_at(arena, expr_ref) == 59) {
      let slen: i32 = e.var_name_len;
      let emit_slice: bool = false;
      if (slen < 0) {
        slen = 0;
      }
      if (slen > 64) {
        slen = 64;
      }
      if (!ast.ref_is_null(e.resolved_type_ref) && e.resolved_type_ref > 0 && e.resolved_type_ref <= arena.num_types) {
        let sty: Type = ast.ast_arena_type_get(arena, e.resolved_type_ref);
        if (sty.kind == TypeKind.TYPE_SLICE) {
          emit_slice = true;
        }
      }
      /* See implementation. */
      let cast_open: u8[14] = [40, 40, 117, 105, 110, 116, 56, 95, 116, 32, 42, 41, 34, 0];
      if (emit_slice) {
        let slice_mid: u8[13] = [41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 40, 0];
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        if (emit_type(arena, out, e.resolved_type_ref, 0 as *u8, 0, ctx) != 0) {
          return -1;
        }
        if (emit_bytes_from_ptr(out, &slice_mid[0], 12) != 0) {
          return -1;
        }
      }
      if (emit_bytes_from_ptr(out, &cast_open[0], 13) != 0) {
        return -1;
      }
      let si: i32 = 0;
      while (si < slen) {
        let b: i32 = e.var_name[si] as i32;
        if (b < 0) {
          b = b + 256;
        }
        if (b > 255) {
          b = b & 255;
        }
        /* \xHH */
        if (append_byte(out, 92) != 0) {
          return -1;
        }
        if (append_byte(out, 120) != 0) {
          return -1;
        }
        let hi: i32 = b / 16;
        let lo: i32 = b - hi * 16;
        let hex: u8[17] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102, 0];
        if (append_byte(out, hex[hi]) != 0) {
          return -1;
        }
        if (append_byte(out, hex[lo]) != 0) {
          return -1;
        }
        si = si + 1;
      }
      /* Close the C string quote and cast paren; slice path adds .length = N. */
      if (append_byte(out, 34) != 0) {
        return -1;
      }
      if (append_byte(out, 41) != 0) {
        return -1;
      }
      if (emit_slice) {
        let slice_tail: u8[18] = [32, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0, 0, 0];
        if (emit_bytes_from_ptr(out, &slice_tail[0], 13) != 0) {
          return -1;
        }
        if (format_int(out, slen) != 0) {
          return -1;
        }
        if (append_byte(out, 32) != 0) {
          return -1;
        }
        if (append_byte(out, 125) != 0) {
          return -1;
        }
        return 0;
      }
      return 0;
    }
    if (e.kind == ExprKind.EXPR_LIT) {
      return format_int(out, e.int_val);
    }
    if (e.kind == ExprKind.EXPR_BOOL_LIT) {
      if (e.int_val != 0) {
        return append_byte(out, 49);
      }
      return append_byte(out, 48);
    }
    if (e.kind == ExprKind.EXPR_VAR) {
      /* See implementation. */
      if (e.var_name_len > 0 && (e.var_name[0] > 32)) {
        /* See implementation. */
        if (e.var_name_len == 3 && e.var_name[0] == 109 && e.var_name[1] == 115 && e.var_name[2] == 103 && ctx != 0 as *PipelineDepCtx) {
          let use_l0: bool = false;
          if (ctx.current_block_ref != 0 && ctx.current_block_ref <= arena.num_blocks) {
            if (ast.ast_block_num_lets(arena, ctx.current_block_ref) >= 1 && pipeline_block_let_name_len(arena, ctx.current_block_ref, 0) == 0) {
              use_l0 = true;
            }
          }
          if (use_l0) {
            let l0: u8[4] = [95, 108, 48, 0];
            return emit_bytes_4(out, l0, 3);
          }
        }
        /*
         * wave101 soft residual: same-module bare function used as value (e.g. cast
         * `(f as *u8)`) must emit G.7 link symbol (module prefix + overload mangle),
         * not the bare source name. Locals keep bare emit via name_is_local_binding.
         * PLATFORM: SHARED — def/call/extern already use codegen_emit_func_link_name.
         */
        let fn_val: i32 = codegen_try_emit_fn_as_value(out, arena, ctx, &e.var_name[0], e.var_name_len);
        if (fn_val == 0) {
          return 0;
        }
        if (fn_val < 0) {
          return 0 - 1;
        }
        return emit_bytes_64(out, &e.var_name[0], e.var_name_len);
      }
      if (ctx != 0 as *PipelineDepCtx && ctx.emit_expr_as_callee != 0) {
        let fallback: u8[3] = [95, 48, 0];
        return emit_bytes_3(out, fallback, 2);
      }
      if (ctx != 0 as *PipelineDepCtx) {
        if (ctx.current_func_single_empty_param_index >= 0) {
          let place: u8[4] = [95, 112, 48, 0];
          if (emit_bytes_4(out, place, 2) != 0) {
            return -1;
          }
          return format_int(out, ctx.current_func_single_empty_param_index);
        }
        if (ctx.current_func_empty_param_count >= 2 && ctx.current_emit_empty_var_next_index < ctx.current_func_empty_param_count) {
          let param_idx: i32 = pipeline_dep_ctx_empty_param_at(ctx, ctx.current_emit_empty_var_next_index);
          let place: u8[4] = [95, 112, 48, 0];
          if (emit_bytes_4(out, place, 2) != 0) {
            return -1;
          }
          if (format_int(out, param_idx) != 0) {
            return -1;
          }
          ctx.current_emit_empty_var_next_index = ctx.current_emit_empty_var_next_index + 1;
          return 0;
        }
      }
      let fallback: u8[3] = [95, 48, 0];
      return emit_bytes_3(out, fallback, 2);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_AS) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_type(arena, out, e.as_target_type_ref, 0 as *u8, 0, ctx) != 0) {
        return -1;
      }
      if (append_byte(out, 41) != 0) {
        return -1;
      }
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.as_operand_ref) && emit_expr(arena, out, e.as_operand_ref, ctx) != 0) {
        return -1;
      }
      if (append_byte(out, 41) != 0) {
        return -1;
      }
      if (append_byte(out, 41) != 0) {
        return -1;
      }
      return 0;
    }
    if (e.kind == ExprKind.EXPR_RETURN) {
      let op: u8[9] = [114, 101, 116, 117, 114, 110, 32, 0, 0];
      if (emit_bytes_9(out, op, 7) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.unary_operand_ref) && emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
        return -1;
      }
      return 0;
    }
    if (e.kind == ExprKind.EXPR_BLOCK) {
      let open: u8[4] = [40, 123, 32, 0];
      if (emit_bytes_4(out, open, 3) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.block_ref) && emit_block(arena, out, e.block_ref, 2, ctx) != 0) {
        return -1;
      }
      let tail: u8[8] = [32, 125, 41, 0, 0, 0, 0, 0];
      return emit_bytes_8(out, tail, 3);
    }
    if (e.kind == ExprKind.EXPR_ADD) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 43, 32, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_SUB) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 45, 32, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_ASSIGN) {
      /*
       * wave334 Cap residual pure: fixed TYPE_ARRAY whole-array assign.
       * Root: C arrays are not assignable — host gcc rejects
       *   `int32_t a[3] = {…}; (void)((a = (int32_t[]){…}));`
       * Emit memcpy into the array storage instead.
       * Form: (memcpy((void*)(lhs), (const void*)(rhs), sizeof(lhs)))
       * G.7 single host-C authority; freestanding uses direct slot write in glue.
       * PLATFORM: SHARED host-C emit.
       */
      let lt_ref: i32 = pipeline_expr_resolved_type_ref(arena, e.binop_left_ref);
      let is_fa: i32 = 0;
      if (lt_ref > 0 && pipeline_type_kind_ord_at(arena, lt_ref) == (TypeKind.TYPE_ARRAY as i32)) {
        is_fa = 1;
      }
      if (is_fa != 0) {
        let pref: u8[16] = [109, 101, 109, 99, 112, 121, 40, 40, 118, 111, 105, 100, 42, 41, 40, 0];
        let mid: u8[20] = [41, 44, 32, 40, 99, 111, 110, 115, 116, 32, 118, 111, 105, 100, 42, 41, 40, 0, 0, 0];
        let mid_sz: u8[12] = [41, 44, 32, 115, 105, 122, 101, 111, 102, 40, 0, 0];
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        if (emit_bytes_from_ptr(out, &pref[0], 15) != 0) {
          return -1;
        }
        if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
          return -1;
        }
        if (emit_bytes_from_ptr(out, &mid[0], 17) != 0) {
          return -1;
        }
        if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
          return -1;
        }
        if (emit_bytes_from_ptr(out, &mid_sz[0], 10) != 0) {
          return -1;
        }
        if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
          return -1;
        }
        if (append_byte(out, 41) != 0) {
          return -1;
        }
        if (append_byte(out, 41) != 0) {
          return -1;
        }
        return append_byte(out, 41);
      }
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 61, 32, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_ADD_ASSIGN || e.kind == ExprKind.EXPR_SUB_ASSIGN || e.kind == ExprKind.EXPR_MUL_ASSIGN || e.kind == ExprKind.EXPR_DIV_ASSIGN || e.kind == ExprKind.EXPR_MOD_ASSIGN
        || e.kind == ExprKind.EXPR_BITAND_ASSIGN || e.kind == ExprKind.EXPR_BITOR_ASSIGN || e.kind == ExprKind.EXPR_BITXOR_ASSIGN || e.kind == ExprKind.EXPR_SHL_ASSIGN || e.kind == ExprKind.EXPR_SHR_ASSIGN) {
      let op_buf: u8[8] = [32, 43, 61, 32, 0, 0, 0, 0];
      let op_len: i32 = 4;
      if (e.kind == ExprKind.EXPR_ADD_ASSIGN) {
        op_buf[1] = 43;
        op_buf[2] = 61;
        op_len = 4;
      }
      if (e.kind == ExprKind.EXPR_SUB_ASSIGN) {
        op_buf[1] = 45;
        op_buf[2] = 61;
        op_len = 4;
      }
      if (e.kind == ExprKind.EXPR_MUL_ASSIGN) {
        op_buf[1] = 42;
        op_buf[2] = 61;
        op_len = 4;
      }
      if (e.kind == ExprKind.EXPR_DIV_ASSIGN) {
        op_buf[1] = 47;
        op_buf[2] = 61;
        op_len = 4;
      }
      if (e.kind == ExprKind.EXPR_MOD_ASSIGN) {
        op_buf[1] = 37;
        op_buf[2] = 61;
        op_len = 4;
      }
      if (e.kind == ExprKind.EXPR_BITAND_ASSIGN) {
        op_buf[1] = 38;
        op_buf[2] = 61;
        op_len = 4;
      }
      if (e.kind == ExprKind.EXPR_BITOR_ASSIGN) {
        op_buf[1] = 124;
        op_buf[2] = 61;
        op_len = 4;
      }
      if (e.kind == ExprKind.EXPR_BITXOR_ASSIGN) {
        op_buf[1] = 94;
        op_buf[2] = 61;
        op_len = 4;
      }
      if (e.kind == ExprKind.EXPR_SHL_ASSIGN) {
        op_buf[1] = 60;
        op_buf[2] = 60;
        op_buf[3] = 61;
        op_buf[4] = 32;
        op_len = 5;
      }
      if (e.kind == ExprKind.EXPR_SHR_ASSIGN) {
        op_buf[1] = 62;
        op_buf[2] = 62;
        op_buf[3] = 61;
        op_buf[4] = 32;
        op_len = 5;
      }
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      /* See implementation. */
      if (emit_bytes_8(out, op_buf, op_len) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_NEG) {
      let pre: u8[3] = [45, 40, 0];
      if (emit_bytes_3(out, pre, 2) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_ADDR_OF) {
      let pre_a: u8[3] = [38, 40, 0];
      if (emit_bytes_3(out, pre_a, 2) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_DEREF) {
      let pre_d: u8[3] = [42, 40, 0];
      if (emit_bytes_3(out, pre_d, 2) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    /* See implementation. */
     * ({ Result_T tmp = op; if (tmp.err != 0) { return tmp; } tmp.value; })
     */
    if (e.kind == ExprKind.EXPR_TRY_PROPAGATE) {
      let op_ref: i32 = e.unary_operand_ref;
      let op_ty_ref: i32 = 0;
      let open: u8[4] = [40, 123, 32, 0];
      let tmp_name: u8[16] = [95, 95, 120, 108, 97, 110, 103, 95, 116, 114, 121, 95, 116, 109, 112, 0];
      let assign_mid: u8[5] = [32, 61, 32, 0, 0];
      let if_open: u8[38] = [59, 32, 105, 102, 32, 40, 40, 95, 95, 120, 108, 97, 110, 103, 95, 116, 114, 121, 95, 116, 109, 112, 41, 46, 101, 114, 114, 32, 33, 61, 32, 48, 41, 32, 123, 32, 114, 101];
      let turn_mid: u8[41] = [116, 117, 114, 110, 32, 95, 95, 120, 108, 97, 110, 103, 95, 116, 114, 121, 95, 116, 109, 112, 59, 32, 125, 32, 40, 95, 95, 120, 108, 97, 110, 103, 95, 116, 114, 121, 95, 116, 109, 112, 0];
      let value_tail: u8[7] = [41, 46, 118, 97, 108, 117, 101];
      let close_tail: u8[4] = [59, 32, 125, 41];
      if (ast.ref_is_null(op_ref) || op_ref <= 0 || op_ref > arena.num_exprs) {
        return -1;
      }
      op_ty_ref = pipeline_expr_resolved_type_ref(arena, op_ref);
      if (ast.ref_is_null(op_ty_ref)) {
        return -1;
      }
      if (emit_bytes_4(out, open, 3) != 0) {
        return -1;
      }
      if (emit_type(arena, out, op_ty_ref, 0 as *u8, 0, ctx) != 0) {
        return -1;
      }
      if (append_byte(out, 32) != 0) {
        return -1;
      }
      if (emit_bytes_from_ptr(out, &tmp_name[0], 14) != 0) {
        return -1;
      }
      if (emit_bytes_5(out, assign_mid, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, op_ref, ctx) != 0) {
        return -1;
      }
      if (emit_bytes_from_ptr(out, &if_open[0], 37) != 0) {
        return -1;
      }
      if (emit_bytes_from_ptr(out, &turn_mid[0], 38) != 0) {
        return -1;
      }
      if (emit_bytes_from_ptr(out, &value_tail[0], 7) != 0) {
        return -1;
      }
      if (emit_bytes_4(out, close_tail, 4) != 0) {
        return -1;
      }
      return 0;
    }
    if (e.kind == ExprKind.EXPR_AWAIT) {
      if (!ast.ref_is_null(e.unary_operand_ref) && emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
        return -1;
      }
      return 0;
    }
    if (e.kind == ExprKind.EXPR_RUN || e.kind == ExprKind.EXPR_SPAWN) {
      let op_ref: i32 = e.unary_operand_ref;
      let dep_ix: i32 = -1;
      let func_ix: i32 = -1;
      let target_mod: *Module = 0 as *Module;
      let n_args: i32 = 0;
      let num_params: i32 = 0;
      let ai: i32 = 0;
      let op_is_call: i32 = 0;
      let reset_name: u8[26] = [120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 114, 101, 115, 101, 116];
      let comma: u8[3] = [44, 32, 0];
      if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
        return -1;
      }
      if (ast.ref_is_null(op_ref) || op_ref <= 0 || op_ref > arena.num_exprs) {
        return -1;
      }
      let op: Expr = ast.ast_arena_expr_get(arena, op_ref);
      if (op.kind == ExprKind.EXPR_CALL) {
        op_is_call = 1;
      } else if (op.kind != ExprKind.EXPR_METHOD_CALL) {
        return -1;
      }
      if (e.kind == ExprKind.EXPR_RUN && op.kind == ExprKind.EXPR_METHOD_CALL && codegen_emit_async_method_call_run(arena, out, op_ref, ctx) == 0) {
        return 0;
      }
      if (op_is_call != 0 && op.call_callee_ref > 0 && op.call_callee_ref <= arena.num_exprs) {
        let fast_callee: Expr = ast.ast_arena_expr_get(arena, op.call_callee_ref);
        if (fast_callee.kind == ExprKind.EXPR_FIELD_ACCESS && codegen_emit_async_binding_import_call(arena, out, op_ref, ctx, if (e.kind == ExprKind.EXPR_SPAWN) { 1 } else { 0 }) == 0) {
          return 0;
        }
      }
      dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, op_ref);
      if (dep_ix < 0 && op_is_call != 0) {
        dep_ix = codegen_resolve_binding_import_dep_index(ctx, arena, op.call_callee_ref);
      }
      if (dep_ix >= 0) {
        if (dep_ix >= pipeline_dep_ctx_ndep(ctx)) {
          return -1;
        }
        target_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
      } else {
        target_mod = ctx.current_codegen_module;
      }
      if (target_mod != 0 as *Module) {
        func_ix = codegen_resolve_call_target_func_index(arena, target_mod, op_ref);
      }
      if (dep_ix >= 0 && (target_mod == 0 as *Module || func_ix < 0 || func_ix >= target_mod.num_funcs)) {
        return codegen_emit_async_binding_import_call(arena, out, op_ref, ctx, if (e.kind == ExprKind.EXPR_SPAWN) { 1 } else { 0 });
      }
      if (target_mod == 0 as *Module) {
        return -1;
      }
      if (func_ix < 0 || func_ix >= target_mod.num_funcs) {
        return -1;
      }
      if (op_is_call != 0) {
        n_args = op.call_num_args;
      } else {
        n_args = op.method_call_num_args;
      }
      if (n_args < 0) {
        return -1;
      }
      num_params = pipeline_module_func_num_params_at(target_mod, func_ix);
      if (e.kind == ExprKind.EXPR_RUN) {
        if (n_args > 0) {
          if (append_byte(out, 40) != 0) {
            return -1;
          }
          if (emit_bytes_from_ptr(out, &reset_name[0], 25) != 0) {
            return -1;
          }
          if (append_byte(out, 40) != 0) {
            return -1;
          }
          if (append_byte(out, 41) != 0) {
            return -1;
          }
          ai = 0;
          while (ai < n_args) {
            let arg_ref: i32 = 0;
            let param_type_ref: i32 = 0;
            if (emit_bytes_3(out, comma, 2) != 0) {
              return -1;
            }
            if (op_is_call != 0) {
              arg_ref = pipeline_expr_call_arg_ref(arena, op_ref, ai);
            } else {
              arg_ref = pipeline_expr_method_call_arg_ref(arena, op_ref, ai);
            }
            if (ai < num_params) {
              param_type_ref = pipeline_module_func_param_type_ref_at(target_mod, func_ix, ai);
            }
            if (codegen_emit_async_run_seed_push_name(out, arena, param_type_ref) != 0) {
              return -1;
            }
            if (append_byte(out, 40) != 0) {
              return -1;
            }
            if (!ast.ref_is_null(arg_ref) && emit_expr(arena, out, arg_ref, ctx) != 0) {
              return -1;
            }
            if (append_byte(out, 41) != 0) {
              return -1;
            }
            ai = ai + 1;
          }
          if (emit_bytes_3(out, comma, 2) != 0) {
            return -1;
          }
          if (codegen_emit_async_sched_call(out, target_mod, func_ix) != 0) {
            return -1;
          }
          return append_byte(out, 41);
        }
        return codegen_emit_async_sched_call(out, target_mod, func_ix);
      }
      if (n_args > 0) {
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        ai = 0;
        while (ai < n_args) {
          let arg_ref2: i32 = 0;
          let param_type_ref2: i32 = 0;
          if (ai > 0 && emit_bytes_3(out, comma, 2) != 0) {
            return -1;
          }
          if (op_is_call != 0) {
            arg_ref2 = pipeline_expr_call_arg_ref(arena, op_ref, ai);
          } else {
            arg_ref2 = pipeline_expr_method_call_arg_ref(arena, op_ref, ai);
          }
          if (ai < num_params) {
            param_type_ref2 = pipeline_module_func_param_type_ref_at(target_mod, func_ix, ai);
          }
          if (codegen_emit_async_run_seed_push_name(out, arena, param_type_ref2) != 0) {
            return -1;
          }
          if (append_byte(out, 40) != 0) {
            return -1;
          }
          if (!ast.ref_is_null(arg_ref2) && emit_expr(arena, out, arg_ref2, ctx) != 0) {
            return -1;
          }
          if (append_byte(out, 41) != 0) {
            return -1;
          }
          ai = ai + 1;
        }
        if (emit_bytes_3(out, comma, 2) != 0) {
          return -1;
        }
        if (codegen_emit_async_task_submit_call(out, target_mod, func_ix) != 0) {
          return -1;
        }
        return append_byte(out, 41);
      }
      return codegen_emit_async_task_submit_call(out, target_mod, func_ix);
    }
    if (e.kind == ExprKind.EXPR_IF) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.if_cond_ref) && emit_expr(arena, out, e.if_cond_ref, ctx) != 0) {
        return -1;
      }
      let q: u8[4] = [32, 63, 32, 0];
      if (emit_bytes_4(out, q, 3) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.if_then_ref) && emit_expr(arena, out, e.if_then_ref, ctx) != 0) {
        return -1;
      }
      let colon: u8[4] = [32, 58, 32, 0];
      if (emit_bytes_4(out, colon, 3) != 0) {
        return -1;
      }
      /* See implementation. */
      if (!ast.ref_is_null(e.if_else_ref)) {
        if (emit_expr(arena, out, e.if_else_ref, ctx) != 0) {
          return -1;
        }
      } else {
        if (append_byte(out, 48) != 0) {
          return -1;
        }
      }
      return append_byte(out, 41);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_CALL) {
      let callee_ref: i32 = e.call_callee_ref;
      /* PLATFORM: SHARED — fmt/debug println("…") single-arg string-lit specialization. */
      if (ctx != 0 as *PipelineDepCtx) {
        let fmt_lit_rc: i32 = codegen_try_emit_fmt_string_lit_call(arena, out, expr_ref, ctx);
        if (fmt_lit_rc < 0) {
          return -1;
        }
        if (fmt_lit_rc > 0) {
          return 0;
        }
      }
      /* See implementation. */
      if (!ast.ref_is_null(callee_ref) && callee_ref > 0 && callee_ref <= arena.num_exprs && ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module) {
        let sym_buf: u8[128] = [];
        let imp_j: i32 = -1;
        let sym_len: i32 = pipeline_asm_resolve_whole_import_qualified_symbol_c(arena, ctx.current_codegen_module, callee_ref, &sym_buf[0], &imp_j);
        if (sym_len > 0 && sym_len < 128) {
          /* Why: sym_buf holds "prefix_funcname". Split into prefix + funcname and mangle
             funcname for overloads. Invariant: callee must be FIELD_ACCESS or VAR; imp_j maps
             to dep module; if dep_mod_q is NULL fall back to whole-symbol emit. */
          let callee_q: Expr = ast.ast_arena_expr_get(arena, callee_ref);
          let fn_ptr_q: *u8 = 0 as *u8;
          let fn_len_q: i32 = 0;
          if (callee_q.kind == ExprKind.EXPR_FIELD_ACCESS && callee_q.field_access_field_len > 0) {
            fn_ptr_q = &callee_q.field_access_field_name[0];
            fn_len_q = callee_q.field_access_field_len;
          } else if (callee_q.kind == ExprKind.EXPR_VAR && callee_q.var_name_len > 0) {
            fn_ptr_q = &callee_q.var_name[0];
            fn_len_q = callee_q.var_name_len;
          }
          let dep_mod_q: *Module = 0 as *Module;
          if (imp_j >= 0 && imp_j < pipeline_dep_ctx_ndep(ctx)) {
            dep_mod_q = pipeline_dep_ctx_module_at(ctx, imp_j);
          }
          let mangled_emitted: i32 = 0;
          if (fn_len_q > 0 && fn_len_q <= sym_len && dep_mod_q != 0 as *Module) {
            let pre_len_q: i32 = sym_len - fn_len_q;
            if (pre_len_q > 0) {
              if (emit_bytes_from_ptr(out, &sym_buf[0], pre_len_q) != 0) {
                return -1;
              }
            }
            if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, dep_mod_q, fn_ptr_q, fn_len_q) != 0) {
              return -1;
            }
            mangled_emitted = 1;
          }
          if (mangled_emitted == 0) {
            if (emit_bytes_from_ptr(out, &sym_buf[0], sym_len) != 0) {
              return -1;
            }
          }
          if (append_byte(out, 40) != 0) {
            return -1;
          }
          let n_q: i32 = e.call_num_args;
          let ai_q: i32 = 0;
          while (ai_q < n_q) {
            if (ai_q > 0) {
              let comma_q: u8[3] = [44, 32, 0];
              if (emit_bytes_3(out, comma_q, 2) != 0) {
                return -1;
              }
            }
            if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai_q))) {
              if (append_byte(out, 48) != 0) {
                return -1;
              }
            } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai_q), ctx) != 0) {
              return -1;
            }
            ai_q = ai_q + 1;
          }
          if (append_byte(out, 41) != 0) {
            return -1;
          }
          return 0;
        }
      }
      /* See implementation. */
      if (!ast.ref_is_null(callee_ref) && callee_ref > 0 && callee_ref <= arena.num_exprs && ctx != 0 as *PipelineDepCtx && pipeline_dep_ctx_ndep(ctx) > 0) {
        let dep_ix_fast: i32 = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
        let callee_fast: Expr = ast.ast_arena_expr_get(arena, callee_ref);
        if (dep_ix_fast >= 0 && dep_ix_fast < pipeline_dep_ctx_ndep(ctx) && callee_fast.kind == ExprKind.EXPR_FIELD_ACCESS && callee_fast.field_access_field_len > 0) {
          let dep_mod_chk: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix_fast);
          let field_in_dep: i32 = 0;
          if (dep_mod_chk != 0 as *Module) {
            let fi_c: i32 = 0;
            while (fi_c < dep_mod_chk.num_funcs) {
              let fl: i32 = pipeline_module_func_name_len_at(dep_mod_chk, fi_c);
              if (fl == callee_fast.field_access_field_len && fl > 0) {
                let fnc: u8[64] = [];
                pipeline_module_func_name_copy64(dep_mod_chk, fi_c, &fnc[0]);
                let eqc: i32 = 1;
                let ic: i32 = 0;
                while (ic < fl) {
                  if (fnc[ic] != callee_fast.field_access_field_name[ic]) {
                    eqc = 0;
                    ic = fl;
                  } else {
                    ic = ic + 1;
                  }
                }
                if (eqc != 0) {
                  field_in_dep = 1;
                  fi_c = dep_mod_chk.num_funcs;
                } else {
                  fi_c = fi_c + 1;
                }
              } else {
                fi_c = fi_c + 1;
              }
            }
          }
          if (field_in_dep != 0) {
          let dep_path_fast: u8[64] = [];
          pipeline_dep_ctx_import_path_copy64(ctx, dep_ix_fast, &dep_path_fast[0]);
          let pre_fast: u8[128] = [];
          codegen_import_path_to_c_prefix_into(&dep_path_fast[0], &pre_fast[0], 128);
          let pre_fast_len: i32 = 0;
          while (pre_fast_len < 128 && pre_fast[pre_fast_len] != 0) {
            pre_fast_len = pre_fast_len + 1;
          }
          /* See implementation. */
          let drv_buf_fast: i32 = 0;
          if (codegen_path_is_std_io_driver_bytes(&dep_path_fast[0]) != 0) {
            drv_buf_fast = codegen_emit_io_driver_buf_call_name(out, &callee_fast.field_access_field_name[0], callee_fast.field_access_field_len, e.call_num_args);
            if (drv_buf_fast < 0) {
              return -1;
            }
          }
          if (drv_buf_fast == 0) {
            if (pre_fast_len > 0 && codegen_c_prefix_redundant_with_name(&pre_fast[0], pre_fast_len, &callee_fast.field_access_field_name[0], callee_fast.field_access_field_len) == 0 && emit_bytes_from_ptr(out, &pre_fast[0], pre_fast_len) != 0) {
              return -1;
            }
            /* See implementation. */
            let dep_mod_fast: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix_fast);
            if (dep_mod_fast == 0 as *Module) {
              dep_mod_fast = ctx.current_codegen_module;
            }
            if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, dep_mod_fast, &callee_fast.field_access_field_name[0], callee_fast.field_access_field_len) != 0) {
              return -1;
            }
          }
          if (append_byte(out, 40) != 0) {
            return -1;
          }
          let ai_fast: i32 = 0;
          while (ai_fast < e.call_num_args) {
            if (ai_fast > 0) {
              let comma_fast: u8[3] = [44, 32, 0];
              if (emit_bytes_3(out, comma_fast, 2) != 0) {
                return -1;
              }
            }
            if (drv_buf_fast != 0 && ai_fast == 0) {
              let cast_buf: u8[19] = [40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0];
              if (emit_bytes_from_ptr(out, &cast_buf[0], 18) != 0) {
                return -1;
              }
            }
            if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai_fast))) {
              if (append_byte(out, 48) != 0) {
                return -1;
              }
            } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai_fast), ctx) != 0) {
              return -1;
            }
            ai_fast = ai_fast + 1;
          }
          if (append_byte(out, 41) != 0) {
            return -1;
          }
          return 0;
          }
        }
      }
      if (!ast.ref_is_null(callee_ref) && callee_ref > 0 && callee_ref <= arena.num_exprs && ctx != 0 as *PipelineDepCtx && pipeline_dep_ctx_ndep(ctx) > 0 && ctx.current_codegen_module != 0 as *Module) {
        let callee: Expr = ast.ast_arena_expr_get(arena, callee_ref);
        let cur_mod: *Module = ctx.current_codegen_module;
        /* See implementation. */
        if (callee.kind == ExprKind.EXPR_FIELD_ACCESS && callee.field_access_base_ref > 0 && callee.field_access_base_ref <= arena.num_exprs) {
          let base: Expr = ast.ast_arena_expr_get(arena, callee.field_access_base_ref);
          if (base.kind == ExprKind.EXPR_VAR && base.var_name_len > 0 && base.var_name_len <= 63) {
            let j: i32 = 0;
            let nd_bind: i32 = pipeline_dep_ctx_ndep(ctx);
            let n_imp: i32 = codegen_module_num_imports(cur_mod);
            while (j < n_imp && j < nd_bind) {
              if (pipeline_module_import_kind_at(cur_mod, j) == 1) {
                let bind_len: i32 = pipeline_module_import_binding_name_len(cur_mod, j);
                if (bind_len != base.var_name_len) {
                  j = j + 1;
                  continue;
                }
                let eq: bool = true;
                let kk: i32 = 0;
                while (kk < base.var_name_len && kk < 64) {
                  if (base.var_name[kk] != pipeline_module_import_binding_name_byte_at(cur_mod, j, kk)) {
                    eq = false;
                    break;
                  }
                  kk = kk + 1;
                }
                if (eq) {
                  let dep_path_bind: u8[64] = [];
                  let dep_path_bind_len: i32 = codegen_module_import_path_len_at(cur_mod, j, &dep_path_bind[0]);
                  if (dep_path_bind_len <= 0) {
                    j = j + 1;
                    continue;
                  }
                  /* Why: use dep_mod not cur_mod; passing cur_mod misses free/bump overloads on main.
                     Invariant: dep_path_bind from cur_mod import table; dep_ix path-matched into dep_ctx.
                     Asm/Perf: codegen_find_dep_index_by_path is O(ndep); only when binding hits. */
                  let dep_ix_bind: i32 = codegen_find_dep_index_by_path(ctx, &dep_path_bind[0], dep_path_bind_len);
                  let dep_mod_bind: *Module = cur_mod;
                  if (dep_ix_bind >= 0 && dep_ix_bind < pipeline_dep_ctx_ndep(ctx)) {
                    dep_mod_bind = pipeline_dep_ctx_module_at(ctx, dep_ix_bind);
                  }
                  let pre_buf: u8[128] = [];
                  codegen_import_path_to_c_prefix_into(&dep_path_bind[0], &pre_buf[0], 128);
                  let pre_len: i32 = 0;
                  while (pre_len < 128 && pre_buf[pre_len] != 0) {
                    pre_len = pre_len + 1;
                  }
                  /* See implementation. */
                  let drv_buf_bind: i32 = 0;
                  if (codegen_path_is_std_io_driver_bytes(&dep_path_bind[0]) != 0) {
                    drv_buf_bind = codegen_emit_io_driver_buf_call_name(out, &callee.field_access_field_name[0], callee.field_access_field_len, e.call_num_args);
                    if (drv_buf_bind < 0) {
                      return -1;
                    }
                  }
                  if (drv_buf_bind == 0) {
                    /* See implementation. */
                    let bind_pre: i32 = pre_len;
                    if (dep_mod_bind != 0 as *Module && callee.field_access_field_len > 0) {
                      let fi_b: i32 = 0;
                      while (fi_b < dep_mod_bind.num_funcs) {
                        let fl: i32 = pipeline_module_func_name_len_at(dep_mod_bind, fi_b);
                        if (fl == callee.field_access_field_len && fl > 0) {
                          let fnb: u8[64] = [];
                          pipeline_module_func_name_copy64(dep_mod_bind, fi_b, &fnb[0]);
                          let eqb: i32 = 1;
                          let bi_b: i32 = 0;
                          while (bi_b < fl) {
                            if (fnb[bi_b] != callee.field_access_field_name[bi_b]) {
                              eqb = 0;
                              bi_b = fl;
                            } else {
                              bi_b = bi_b + 1;
                            }
                          }
                          if (eqb != 0) {
                            bind_pre = codegen_func_c_symbol_prefix_len(dep_mod_bind, fi_b, pre_len);
                            fi_b = dep_mod_bind.num_funcs;
                          } else {
                            fi_b = fi_b + 1;
                          }
                        } else {
                          fi_b = fi_b + 1;
                        }
                      }
                    }
                    if (bind_pre > 0 && codegen_c_prefix_redundant_with_name(&pre_buf[0], bind_pre, &callee.field_access_field_name[0], callee.field_access_field_len) == 0 && emit_bytes_from_ptr(out, &pre_buf[0], bind_pre) != 0) {
                      return -1;
                    }
                    if (callee.field_access_field_len > 0 && codegen_emit_call_func_name(out, arena, ctx, expr_ref, dep_mod_bind, &callee.field_access_field_name[0], callee.field_access_field_len) != 0) {
                      return -1;
                    }
                  }
                  if (append_byte(out, 40) != 0) {
                    return -1;
                  }
                  let n_dep: i32 = codegen_call_num_args_override(&pre_buf[0], pre_len, &callee.field_access_field_name[0], callee.field_access_field_len, e.call_num_args);
                  let ai: i32 = 0;
                  while (ai < n_dep) {
                    if (ai > 0) {
                      let comma: u8[3] = [44, 32, 0];
                      if (emit_bytes_3(out, comma, 2) != 0) {
                        return -1;
                      }
                    }
                    if (drv_buf_bind != 0 && ai == 0) {
                      let cast_buf: u8[19] = [40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0];
                      if (emit_bytes_from_ptr(out, &cast_buf[0], 18) != 0) {
                        return -1;
                      }
                    }
                    if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
                      if (append_byte(out, 48) != 0) {
                        return -1;
                      }
                    } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) != 0) {
                      return -1;
                    }
                    ai = ai + 1;
                  }
                  if (append_byte(out, 41) != 0) {
                    return -1;
                  }
                  return 0;
                }
              }
              j = j + 1;
            }
          }
        }
        if (callee.kind == ExprKind.EXPR_VAR && callee.var_name_len > 0) {
          /* See implementation. */
          let j: i32 = 0;
          let nd_sel: i32 = pipeline_dep_ctx_ndep(ctx);
          let n_imp: i32 = codegen_module_num_imports(cur_mod);
          while (j < n_imp && j < nd_sel) {
            if (pipeline_module_import_kind_at(cur_mod, j) == 2) {
              let k: i32 = 0;
              let sel_cnt: i32 = pipeline_module_import_select_count_at(cur_mod, j);
              while (k < sel_cnt) {
                let sel_len: i32 = pipeline_module_import_select_name_len(cur_mod, j, k);
                if (sel_len == callee.var_name_len) {
                  let eq: bool = true;
                  let kk: i32 = 0;
                  while (kk < callee.var_name_len && kk < 64) {
                    if (callee.var_name[kk] != pipeline_module_import_select_name_byte_at(cur_mod, j, k, kk)) {
                      eq = false;
                      break;
                    }
                    kk = kk + 1;
                  }
                  if (eq) {
                    let dep_path_sel: u8[64] = [];
                    let dep_path_sel_len: i32 = codegen_module_import_path_len_at(cur_mod, j, &dep_path_sel[0]);
                    if (dep_path_sel_len <= 0) {
                      k = k + 1;
                      continue;
                    }
                    let pre_buf: u8[128] = [];
                    codegen_import_path_to_c_prefix_into(&dep_path_sel[0], &pre_buf[0], 128);
                    let pre_len: i32 = 0;
                    while (pre_len < 128 && pre_buf[pre_len] != 0) {
                      pre_len = pre_len + 1;
                    }
                    if (pre_len > 0 && codegen_c_prefix_redundant_with_name(&pre_buf[0], pre_len, callee.var_name, callee.var_name_len) == 0 && emit_bytes_from_ptr(out, &pre_buf[0], pre_len) != 0) {
                      return -1;
                    }
                    if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, cur_mod, &callee.var_name[0], callee.var_name_len) != 0) {
                      return -1;
                    }
                    if (append_byte(out, 40) != 0) {
                      return -1;
                    }
                    let n_dep: i32 = codegen_call_num_args_override(&pre_buf[0], pre_len, &callee.var_name[0], callee.var_name_len, e.call_num_args);
                    let ai: i32 = 0;
                    while (ai < n_dep) {
                      if (ai > 0) {
                        let comma: u8[3] = [44, 32, 0];
                        if (emit_bytes_3(out, comma, 2) != 0) {
                          return -1;
                        }
                      }
                      if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
                        if (append_byte(out, 48) != 0) {
                          return -1;
                        }
                      } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) != 0) {
                        return -1;
                      }
                      ai = ai + 1;
                    }
                    if (append_byte(out, 41) != 0) {
                      return -1;
                    }
                    return 0;
                  }
                }
                k = k + 1;
              }
            }
            j = j + 1;
          }
          j = 0;
          let nd_call: i32 = pipeline_dep_ctx_ndep(ctx);
          /*
           * Local-first bare-name CALL (align pin seed).
           * Purpose: if current_codegen_module already defines the bare name
           *   (e.g. core.result.unwrap_or), do not scan earlier deps and steal
           *   a same-named symbol (core.option.unwrap_or → core_option_unwrap_or).
           * Authority: seeds/codegen_gen.linux.x86_64.c local_has_name before
           *   while (j < nd_call && local_has_name == 0).
           * Uses pipeline_module_func_name_* (not arena Func) — reliable for slim modules.
           * PLATFORM: SHARED — Cap force si co-emit matrix.
           */
          let local_has_name: i32 = 0;
          if (cur_mod != 0 as *Module && callee.var_name_len > 0) {
            let lfi: i32 = 0;
            while (lfi < cur_mod.num_funcs) {
              let lnl: i32 = pipeline_module_func_name_len_at(cur_mod, lfi);
              if (lnl == callee.var_name_len) {
                let lnm: u8[64] = [];
                pipeline_module_func_name_copy64(cur_mod, lfi, &lnm[0]);
                let leq: i32 = 1;
                let li: i32 = 0;
                while (li < lnl && li < 64) {
                  if (lnm[li] != callee.var_name[li]) {
                    leq = 0;
                    break;
                  }
                  li = li + 1;
                }
                if (leq != 0) {
                  local_has_name = 1;
                  break;
                }
              }
              lfi = lfi + 1;
            }
          }
          while (j < nd_call && local_has_name == 0) {
            let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, j);
            let dep_arena: *ASTArena = pipeline_dep_ctx_arena_at(ctx, j);
            if (dep_mod != 0 as *Module && dep_arena != 0 as *ASTArena && dep_mod.num_funcs > 0) {
              let fi: i32 = 0;
              while (fi < dep_mod.num_funcs) {
                let func_ref: i32 = pipeline_module_func_ref_at(dep_mod, fi);
                if (ast.ref_is_null(func_ref) || func_ref <= 0 || func_ref > dep_arena.num_funcs) {
                  fi = fi + 1;
                  continue;
                }
                let df: Func = ast.ast_arena_func_get(dep_arena, func_ref);
                if (df.name_len == callee.var_name_len) {
                  let eq: bool = true;
                  let k: i32 = 0;
                  while (k < callee.var_name_len && k < 64) {
                    if (callee.var_name[k] != df.name[k]) {
                      eq = false;
                      break;
                    }
                    k = k + 1;
                  }
                  if (eq && pipeline_dep_ctx_import_path_len(ctx, j) > 0) {
                    /* Why extern: dep extern symbols must match emit_func_extern_declaration or the linker fails. */
                    let callee_is_extern: i32 = pipeline_module_func_is_extern_at(dep_mod, fi);
                    let dep_path_call: u8[64] = [];
                    pipeline_dep_ctx_import_path_copy64(ctx, j, &dep_path_call[0]);
                    let pre_buf: u8[128] = [];
                    codegen_import_path_to_c_prefix_into(&dep_path_call[0], &pre_buf[0], 128);
                    let pre_len: i32 = 0;
                    while (pre_len < 128 && pre_buf[pre_len] != 0) {
                      pre_len = pre_len + 1;
                    }
                    /* See implementation. */
                    if (callee_is_extern != 0 || pipeline_module_func_is_no_mangle_at(dep_mod, fi) != 0) {
                      pre_len = 0;
                    }
                    let drv_buf_call: i32 = 0;
                    if (codegen_path_is_std_io_driver_bytes(&dep_path_call[0]) != 0) {
                      drv_buf_call = codegen_emit_io_driver_buf_call_name(out, &callee.var_name[0], callee.var_name_len, e.call_num_args);
                      if (drv_buf_call < 0) {
                        return -1;
                      }
                    }
                    if (drv_buf_call == 0) {
                      if (pre_len > 0 && codegen_c_prefix_redundant_with_name(&pre_buf[0], pre_len, callee.var_name, callee.var_name_len) == 0 && emit_bytes_from_ptr(out, &pre_buf[0], pre_len) != 0) {
                        return -1;
                      }
                      if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, cur_mod, &callee.var_name[0], callee.var_name_len) != 0) {
                        return -1;
                      }
                      if (codegen_path_is_std_io_core_bytes(&dep_path_call[0]) != 0 && codegen_use_buf_wrapper(&callee.var_name[0], callee.var_name_len, e.call_num_args) != 0) {
                        let suf_buf: u8[8] = [95, 98, 117, 102, 0, 0, 0, 0];
                        if (emit_bytes_from_ptr(out, &suf_buf[0], 4) != 0) {
                          return -1;
                        }
                      }
                    }
                    if (append_byte(out, 40) != 0) {
                      return -1;
                    }
                    let n_dep: i32 = codegen_call_num_args_override(&pre_buf[0], pre_len, callee.var_name, callee.var_name_len, e.call_num_args);
                    let fmt_i32_second_dep: i32 = 0;
                    if (e.call_num_args == 2 && n_dep == 1 && callee.var_name_len == 7 && callee.var_name[0] == 102 && callee.var_name[1] == 109 && callee.var_name[2] == 116 && callee.var_name[3] == 95 && callee.var_name[4] == 105 && callee.var_name[5] == 51 && callee.var_name[6] == 50) {
                      if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0))) {
                        fmt_i32_second_dep = 1;
                      }
                    }
                    let cast_buf0: i32 = drv_buf_call;
                    let ai: i32 = 0;
                    while (ai < n_dep) {
                      if (ai > 0) {
                        let comma: u8[3] = [44, 32, 0];
                        if (emit_bytes_3(out, comma, 2) != 0) {
                          return -1;
                        }
                      }
                      let arg_idx_dep: i32 = ai;
                      if (fmt_i32_second_dep != 0 && ai == 0) {
                        arg_idx_dep = 1;
                      }
                      if (cast_buf0 != 0 && ai == 0) {
                        let cast_buf: u8[19] = [40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0];
                        if (emit_bytes_from_ptr(out, &cast_buf[0], 18) != 0) {
                          return -1;
                        }
                      }
                      if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_dep))) {
                        if (append_byte(out, 48) != 0) {
                          return -1;
                        }
                      } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_dep), ctx) != 0) {
                        return -1;
                      }
                      ai = ai + 1;
                    }
                    if (codegen_is_submit_batch_buf_call(callee.var_name, callee.var_name_len) != 0 && e.call_num_args == 3) {
                      let comma0: u8[4] = [44, 32, 48, 0];
                      if (emit_bytes_4(out, comma0, 3) != 0) {
                        return -1;
                      }
                    }
                    if (append_byte(out, 41) != 0) {
                      return -1;
                    }
                    return 0;
                  }
                }
                fi = fi + 1;
              }
            }
            j = j + 1;
          }
        }
      }
      /* See implementation. */
      if (ctx != 0 as *PipelineDepCtx && ctx.ndep > 0 && !ast.ref_is_null(callee_ref) && callee_ref > 0 && callee_ref <= arena.num_exprs) {
        let callee_fb: Expr = ast.ast_arena_expr_get(arena, callee_ref);
        if (callee_fb.kind == ExprKind.EXPR_VAR && callee_fb.var_name_len == 9
            && callee_fb.var_name[0] == 112 && callee_fb.var_name[1] == 114 && callee_fb.var_name[2] == 105 && callee_fb.var_name[3] == 110
            && callee_fb.var_name[4] == 116 && callee_fb.var_name[5] == 95 && callee_fb.var_name[6] == 115 && callee_fb.var_name[7] == 116 && callee_fb.var_name[8] == 114) {
          let std_io: u8[8] = [115, 116, 100, 95, 105, 111, 95, 0];
          if (emit_bytes_from_ptr(out, &std_io[0], 7) != 0) {
            return -1;
          }
          if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, ctx.current_codegen_module, &callee_fb.var_name[0], callee_fb.var_name_len) != 0) {
            return -1;
          }
          if (append_byte(out, 40) != 0) {
            return -1;
          }
          let ai: i32 = 0;
          while (ai < e.call_num_args) {
            if (ai > 0) {
              let comma: u8[3] = [44, 32, 0];
              if (emit_bytes_3(out, comma, 2) != 0) {
                return -1;
              }
            }
            if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
              if (append_byte(out, 48) != 0) {
                return -1;
              }
            } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) != 0) {
              return -1;
            }
            ai = ai + 1;
          }
          if (append_byte(out, 41) != 0) {
            return -1;
          }
          return 0;
        }
      }
      /* See implementation. */
      if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module && ctx.current_codegen_arena != 0 as *ASTArena && !ast.ref_is_null(callee_ref) && callee_ref > 0 && callee_ref <= arena.num_exprs) {
        let callee2: Expr = ast.ast_arena_expr_get(arena, callee_ref);
        if (callee2.kind == ExprKind.EXPR_VAR && callee2.var_name_len > 0) {
          let cur_mod: *Module = ctx.current_codegen_module;
          let cur_arena: *ASTArena = ctx.current_codegen_arena;
          let fi: i32 = 0;
          while (fi < cur_mod.num_funcs) {
            let func_ref: i32 = pipeline_module_func_ref_at(cur_mod, fi);
            if (!ast.ref_is_null(func_ref) && func_ref > 0 && func_ref <= cur_arena.num_funcs) {
              let df: Func = ast.ast_arena_func_get(cur_arena, func_ref);
              if (df.name_len == callee2.var_name_len) {
                let eq: bool = true;
                let k: i32 = 0;
                while (k < callee2.var_name_len && k < 64) {
                  if (callee2.var_name[k] != df.name[k]) {
                    eq = false;
                    break;
                  }
                  k = k + 1;
                }
                if (eq) {
                  let cur_pre: u8[128] = [];
                  /*
                   * Same-module bare call prefix (align pin seed CALL callee2 path).
                   * Purpose: prefer path of current_codegen_module in the dep pool
                   *   (core_result_ while emitting result), then entry pin / mirror.
                   *   Do NOT only use codegen_emit_prefix_len_from_ctx: it prefers
                   *   current_codegen_prefix_mirror which import/dep walks can leave
                   *   on a prior dep (e.g. core_option_ → bare unwrap_or mis-prefixed).
                   * Authority: seeds/codegen_gen.linux.x86_64.c same-module VAR CALL.
                   * PLATFORM: SHARED — Cap force si (result→result, not option).
                   */
                  let cur_dep_path_buf: u8[128] = [];
                  let cur_dep_plen: i32 = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &cur_dep_path_buf[0]);
                  let pl: i32 = 0;
                  if (cur_dep_plen > 0) {
                    codegen_import_path_to_c_prefix_into(&cur_dep_path_buf[0], &cur_pre[0], 128);
                    while (pl < 128 && cur_pre[pl] != 0 as u8) {
                      pl = pl + 1;
                    }
                  } else if (ctx.current_codegen_prefix_len > 0) {
                    let _cpl: i32 = ctx.current_codegen_prefix_len;
                    let pi: i32 = 0;
                    while (pi < _cpl && pi < 127) {
                      cur_pre[pi] = ctx.current_codegen_prefix_mirror[pi];
                      pi = pi + 1;
                    }
                    cur_pre[pi] = 0 as u8;
                    pl = pi;
                  } else {
                    cur_pre[0] = 0 as u8;
                    pl = 0;
                  }
                  /* See implementation. */
                  if (pipeline_module_func_is_extern_at(cur_mod, fi) != 0
                      || pipeline_module_func_is_no_mangle_at(cur_mod, fi) != 0) {
                    pl = 0;
                  }
                  if (pl > 0 && codegen_c_prefix_redundant_with_name(&cur_pre[0], pl, callee2.var_name, callee2.var_name_len) == 0 && emit_bytes_from_ptr(out, &cur_pre[0], pl) != 0) {
                    return -1;
                  }
                  if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, cur_mod, &callee2.var_name[0], callee2.var_name_len) != 0) {
                    return -1;
                  }
                  if (append_byte(out, 40) != 0) {
                    return -1;
                  }
                  let n_cur: i32 = codegen_call_num_args_override(&cur_pre[0], pl, callee2.var_name, callee2.var_name_len, e.call_num_args);
                  let fmt_i32_second_cur: i32 = 0;
                  if (e.call_num_args == 2 && n_cur == 1 && callee2.var_name_len == 7 && callee2.var_name[0] == 102 && callee2.var_name[1] == 109 && callee2.var_name[2] == 116 && callee2.var_name[3] == 95 && callee2.var_name[4] == 105 && callee2.var_name[5] == 51 && callee2.var_name[6] == 50) {
                    if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0))) {
                      fmt_i32_second_cur = 1;
                    }
                  }
                  let ai: i32 = 0;
                  while (ai < n_cur) {
                    if (ai > 0) {
                      let comma: u8[3] = [44, 32, 0];
                      if (emit_bytes_3(out, comma, 2) != 0) {
                        return -1;
                      }
                    }
                    let arg_idx_cur: i32 = ai;
                    if (fmt_i32_second_cur != 0 && ai == 0) {
                      arg_idx_cur = 1;
                    }
                    if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_cur))) {
                      if (append_byte(out, 48) != 0) {
                        return -1;
                      }
                    } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_cur), ctx) != 0) {
                      return -1;
                    }
                    ai = ai + 1;
                  }
                  if (codegen_is_submit_batch_buf_call(callee2.var_name, callee2.var_name_len) != 0 && e.call_num_args == 3) {
                    let comma0: u8[4] = [44, 32, 48, 0];
                    if (emit_bytes_4(out, comma0, 3) != 0) {
                      return -1;
                    }
                  }
                  if (append_byte(out, 41) != 0) {
                    return -1;
                  }
                  return 0;
                }
              }
            }
            fi = fi + 1;
          }
        }
      }
      /* See implementation. */
      if (!ast.ref_is_null(e.call_callee_ref) && e.call_num_args == 2 && e.call_callee_ref > 0 && e.call_callee_ref <= arena.num_exprs) {
        let callee_fb: Expr = ast.ast_arena_expr_get(arena, e.call_callee_ref);
        if (callee_fb.kind == ExprKind.EXPR_VAR && callee_fb.var_name_len >= 10) {
          let prefix_ok: bool = callee_fb.var_name[0] == 109 && callee_fb.var_name[1] == 97 && callee_fb.var_name[2] == 112 && callee_fb.var_name[3] == 95;
          let off: i32 = callee_fb.var_name_len - 6;
          let suffix_ok: bool = off >= 0 && callee_fb.var_name[off] == 102 && callee_fb.var_name[off + 1] == 105 && callee_fb.var_name[off + 2] == 110 && callee_fb.var_name[off + 3] == 100 && callee_fb.var_name[off + 4] == 95 && callee_fb.var_name[off + 5] == 99;
          if (prefix_ok && suffix_ok) {
            if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, ctx.current_codegen_module, &callee_fb.var_name[0], callee_fb.var_name_len) != 0) {
              return -1;
            }
            let open: u8[3] = [40, 40, 0];
            if (emit_bytes_3(out, open, 2) != 0) {
              return -1;
            }
            if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) != 0) {
              return -1;
            }
            /* See implementation. */
            let mid1: u8[10] = [41, 46, 107, 101, 121, 115, 44, 32, 40, 0];
            if (emit_bytes_from_ptr(out, &mid1[0], 9) != 0) {
              return -1;
            }
            if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) != 0) {
              return -1;
            }
            /* See implementation. */
            let mid2: u8[14] = [41, 46, 111, 99, 99, 117, 112, 105, 101, 100, 44, 32, 40, 0];
            if (emit_bytes_from_ptr(out, &mid2[0], 13) != 0) {
              return -1;
            }
            if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) != 0) {
              return -1;
            }
            /* See implementation. */
            let mid3: u8[8] = [41, 46, 99, 97, 112, 44, 32, 0];
            if (emit_bytes_8(out, mid3, 7) != 0) {
              return -1;
            }
            if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 1), ctx) != 0) {
              return -1;
            }
            if (append_byte(out, 41) != 0) {
              return -1;
            }
            return 0;
          }
        }
      }
      let need_4th: i32 = 0;
      if (!ast.ref_is_null(e.call_callee_ref) && e.call_callee_ref > 0 && e.call_callee_ref <= arena.num_exprs && e.call_num_args == 3) {
        let callee_f4: Expr = ast.ast_arena_expr_get(arena, e.call_callee_ref);
        if (callee_f4.kind == ExprKind.EXPR_VAR && codegen_is_submit_batch_buf_call(callee_f4.var_name, callee_f4.var_name_len) != 0) {
          need_4th = 1;
        }
      }
      let saved_callee_flag: i32 = 0;
      if (ctx != 0 as *PipelineDepCtx) {
        saved_callee_flag = ctx.emit_expr_as_callee;
        ctx.emit_expr_as_callee = 1;
      }
      if (!ast.ref_is_null(e.call_callee_ref) && emit_expr(arena, out, e.call_callee_ref, ctx) != 0) {
        if (ctx != 0 as *PipelineDepCtx) {
          ctx.emit_expr_as_callee = saved_callee_flag;
        }
        return -1;
      }
      if (ctx != 0 as *PipelineDepCtx) {
        ctx.emit_expr_as_callee = saved_callee_flag;
      }
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      let fallback_pre: u8[64] = [];
      let fallback_pl: i32 = 0;
      if (ctx != 0 as *PipelineDepCtx) {
        let fb_dep_path_buf: u8[128] = [];
        let fb_dep_plen: i32 = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &fb_dep_path_buf[0]);
        if (fb_dep_plen > 0) {
          codegen_import_path_to_c_prefix_into(&fb_dep_path_buf[0], &fallback_pre[0], 64);
        } else {
          fallback_pre[0] = 0 as u8;
        }
        while (fallback_pl < 64 && fallback_pre[fallback_pl] != 0) {
          fallback_pl = fallback_pl + 1;
        }
      }
      let n_fb: i32 = e.call_num_args;
      /* See implementation. */
      let use_second_arg: i32 = 0;
      if (!ast.ref_is_null(e.call_callee_ref) && e.call_callee_ref > 0 && e.call_callee_ref <= arena.num_exprs) {
        let callee_expr: Expr = ast.ast_arena_expr_get(arena, e.call_callee_ref);
        if (callee_expr.kind == ExprKind.EXPR_VAR) {
          n_fb = codegen_call_num_args_override(&fallback_pre[0], fallback_pl, callee_expr.var_name, callee_expr.var_name_len, e.call_num_args);
          if (e.call_num_args == 2 && n_fb == 1 && ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0)) != 0) {
            use_second_arg = 1;
          }
        }
      }
      let ai: i32 = 0;
      while (ai < n_fb) {
        if (ai > 0) {
          let comma: u8[3] = [44, 32, 0];
          if (emit_bytes_3(out, comma, 2) != 0) {
            return -1;
          }
        }
        let arg_idx: i32 = ai;
        if (use_second_arg != 0 && ai == 0) {
          arg_idx = 1;
        }
        if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx))) {
          if (append_byte(out, 48) != 0) {
            return -1;
          }
        } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx), ctx) != 0) {
          return -1;
        }
        ai = ai + 1;
      }
      if (need_4th != 0) {
        let comma0: u8[4] = [44, 32, 48, 0];
        if (emit_bytes_4(out, comma0, 3) != 0) {
          return -1;
        }
      }
      if (append_byte(out, 41) != 0) {
        return -1;
      }
      return 0;
    }
    /* FLOAT_LIT: emit real value via C helper (old seed stub always wrote 0.0).
     * Authority: pipeline_codegen_emit_float_lit_c in pipeline_glue.c / strict_minimal seed. */
    if (e.kind == ExprKind.EXPR_FLOAT_LIT) {
      return pipeline_codegen_emit_float_lit_c(out, e.float_val, e.float_bits_lo, e.float_bits_hi);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_MUL) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 42, 32, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_DIV) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 47, 32, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_MOD) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 37, 32, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_EQ) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 61, 61, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_NE) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 33, 61, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_LT) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 60, 32, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_LE) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 60, 61, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_GT) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 62, 32, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_GE) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 62, 61, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_LOGAND) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[5] = [32, 38, 38, 32, 0];
      if (emit_bytes_5(out, op, 4) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_LOGOR) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[5] = [32, 124, 124, 32, 0];
      if (emit_bytes_5(out, op, 4) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_SHL) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 60, 60, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_SHR) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 62, 62, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_BITAND) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 38, 32, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_BITOR) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 124, 32, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_BITXOR) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
        return -1;
      }
      let op: u8[4] = [32, 94, 32, 0];
      if (emit_bytes_4(out, op, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_BITNOT) {
      let pre: u8[3] = [126, 40, 0];
      if (emit_bytes_3(out, pre, 2) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    if (e.kind == ExprKind.EXPR_LOGNOT) {
      let pre: u8[3] = [33, 40, 0];
      if (emit_bytes_3(out, pre, 2) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_TERNARY) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.if_cond_ref) && emit_expr(arena, out, e.if_cond_ref, ctx) != 0) {
        return -1;
      }
      let q: u8[4] = [32, 63, 32, 0];
      if (emit_bytes_4(out, q, 3) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.if_then_ref) && emit_expr(arena, out, e.if_then_ref, ctx) != 0) {
        return -1;
      }
      let colon: u8[4] = [32, 58, 32, 0];
      if (emit_bytes_4(out, colon, 3) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.if_else_ref)) {
        if (emit_expr(arena, out, e.if_else_ref, ctx) != 0) {
          return -1;
        }
      } else {
        if (append_byte(out, 48) != 0) {
          return -1;
        }
      }
      return append_byte(out, 41);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_INDEX) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.index_base_ref) && emit_expr(arena, out, e.index_base_ref, ctx) != 0) {
        return -1;
      }
      if (append_byte(out, 41) != 0) {
        return -1;
      }
      /*
       * See implementation.
       * See implementation.
       */
      let need_slice_data: i32 = e.index_base_is_slice;
      if (need_slice_data == 0 && !ast.ref_is_null(e.index_base_ref)) {
        let base_ty: i32 = pipeline_expr_resolved_type_ref(arena, e.index_base_ref);
        if (!ast.ref_is_null(base_ty) && base_ty > 0 && base_ty <= arena.num_types) {
          if (pipeline_type_kind_ord_at(arena, base_ty) == 11) {
            need_slice_data = 1;
          }
        }
      }
      if (need_slice_data != 0) {
        /* PLATFORM: SHARED — slice params are pointers: use ->data not .data.
         * Why: Cap by-value→pointer param ABI; INDEX used to hardcode `.data` → host-cc error. */
        let use_arrow: i32 = 0;
        if (!ast.ref_is_null(e.index_base_ref)) {
          if (field_access_base_is_pointer_ref(arena, e.index_base_ref) != 0) {
            use_arrow = 1;
          }
          if (use_arrow == 0 && ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
            if (field_access_base_is_pointer_param(arena, e.index_base_ref, ctx.current_codegen_module, ctx.current_func_index) != 0) {
              use_arrow = 1;
            }
          }
        }
        if (use_arrow != 0) {
          let arrow_data: u8[8] = [45, 62, 100, 97, 116, 97, 0, 0];
          if (emit_bytes_from_ptr(out, &arrow_data[0], 6) != 0) {
            return -1;
          }
        } else {
          let dot: u8[6] = [46, 100, 97, 116, 97, 0];
          if (emit_bytes_6(out, dot, 5) != 0) {
            return -1;
          }
        }
      }
      if (append_byte(out, 91) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.index_index_ref) && emit_expr(arena, out, e.index_index_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 93);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_FIELD_ACCESS) {
      /* PLATFORM: SHARED — mark Enum.Variant / import.Enum.Variant on this arena
       * before re-reading e (seed call site must pass emit_expr arena, not a
       * possibly-stale current_codegen_arena). */
      if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module) {
        pipeline_codegen_try_mark_enum_field_access(ctx.current_codegen_module, arena, expr_ref, ctx);
        e = ast.ast_arena_expr_get(arena, expr_ref);
      }
      if (e.field_access_is_enum_variant != 0) {
        /* See implementation. */
        return format_int(out, e.enum_variant_tag);
      }
      /* See implementation. */
      if (ctx != 0 as *PipelineDepCtx && ctx.emit_expr_as_callee != 0 && emit_import_module_field_symbol(arena, out, expr_ref, ctx) == 0) {
        return 0;
      }
      /* See implementation. */
      if (emit_import_module_const_field(arena, out, expr_ref, ctx) == 0) {
        return 0;
      }
      /*
       * See implementation.
       * See implementation.
       */
      if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module && ctx.current_codegen_arena == arena && ctx.current_func_index >= 0) {
        let mod: *Module = ctx.current_codegen_module;
        if (ctx.current_func_index < mod.num_funcs) {
          let cfi: i32 = ctx.current_func_index;
          let pref: u8[128] = [];
          let plen: i32 = codegen_emit_prefix_len_from_ctx(ctx, &pref[0], 128);
          let cfn: u8[64] = [];
          pipeline_module_func_name_copy64(mod, cfi, &cfn[0]);
          let cfn_len: i32 = pipeline_module_func_name_len_at(mod, cfi);
          if (codegen_force_param_ptrdiff_t(&pref[0], plen, &cfn[0], cfn_len, 0) != 0) {
            if (expr_var_matches_func_param_index(arena, e.field_access_base_ref, mod, cfi, 0, ctx) != 0) {
              return emit_expr(arena, out, e.field_access_base_ref, ctx);
            }
          }
        }
      }
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.field_access_base_ref) && emit_expr(arena, out, e.field_access_base_ref, ctx) != 0) {
        return -1;
      }
      /* See implementation. */
      let is_ptr_base: i32 = field_access_base_is_pointer_ref(arena, e.field_access_base_ref);
      let param_type_known: i32 = 0;
      if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
        if (is_ptr_base == 0) {
          is_ptr_base = field_access_base_is_pointer_param(arena, e.field_access_base_ref, ctx.current_codegen_module, ctx.current_func_index);
        }
        if (is_ptr_base == 0) {
          is_ptr_base = field_access_base_is_pointer_local(arena, e.field_access_base_ref, ctx);
        }
        param_type_known = field_access_base_param_type_known(arena, e.field_access_base_ref, ctx.current_codegen_module, ctx.current_func_index);
      }
      if (is_ptr_base == 0 && param_type_known == 0 && field_access_base_type_resolved(arena, e.field_access_base_ref) == 0) {
        if (field_access_base_is_slice_param_name(arena, e.field_access_base_ref) != 0) {
          is_ptr_base = 1;
        }
      }
      if (is_ptr_base != 0) {
        let arrow: u8[3] = [45, 62, 0];
        if (emit_bytes_3(out, arrow, 2) != 0) {
          return -1;
        }
      } else {
        let dot: u8[2] = [46, 0];
        if (emit_bytes_2(out, dot, 1) != 0) {
          return -1;
        }
      }
      if (emit_bytes_64(out, &e.field_access_field_name[0], e.field_access_field_len) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_PANIC) {
      let p: u8[23] = [120, 108, 97, 110, 103, 95, 112, 97, 110, 105, 99, 95, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      if (emit_bytes_22(out, p, 13) != 0) {
        return -1;
      }
      if (ast.ref_is_null(e.unary_operand_ref)) {
        if (append_byte(out, 48) != 0) {
          return -1;
        }
        if (append_byte(out, 44) != 0) {
          return -1;
        }
        if (append_byte(out, 48) != 0) {
          return -1;
        }
      } else {
        if (append_byte(out, 49) != 0) {
          return -1;
        }
        if (append_byte(out, 44) != 0) {
          return -1;
        }
        if (emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
          return -1;
        }
      }
      return append_byte(out, 41);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_BREAK) {
      return append_byte(out, 48);
    }
    if (e.kind == ExprKind.EXPR_CONTINUE) {
      return append_byte(out, 48);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_METHOD_CALL) {
      /* PLATFORM: SHARED — fmt/debug println("…") (METHOD_CALL form). */
      if (ctx != 0 as *PipelineDepCtx) {
        let fmt_mc_rc: i32 = codegen_try_emit_fmt_string_lit_call(arena, out, expr_ref, ctx);
        if (fmt_mc_rc < 0) {
          return -1;
        }
        if (fmt_mc_rc > 0) {
          return 0;
        }
      }
      if (ctx != 0 as *PipelineDepCtx) {
        let dep_ix: i32 = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
        let func_ix: i32 = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
        /*
         * See implementation.
         * See implementation.
         * See implementation.
         * See implementation.
         * See implementation.
         */
        let mc_resolved_ok: i32 = 0;
        if (dep_ix >= 0 && func_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx)) {
          let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix);
          if (dep_mod != 0 as *Module && func_ix < dep_mod.num_funcs) {
            let fn_name: u8[64] = [];
            let fn_len: i32 = pipeline_module_func_name_len_at(dep_mod, func_ix);
            let name_ok: i32 = 0;
            if (fn_len > 0) {
              pipeline_module_func_name_copy64(dep_mod, func_ix, &fn_name[0]);
            }
            if (fn_len > 0 && fn_len == e.method_call_name_len && e.method_call_name_len > 0) {
              name_ok = 1;
              let mi: i32 = 0;
              while (mi < fn_len) {
                if (fn_name[mi] != e.method_call_name[mi]) {
                  name_ok = 0;
                  mi = fn_len;
                } else {
                  mi = mi + 1;
                }
              }
            }
            if (name_ok != 0 && pipeline_module_func_num_params_at(dep_mod, func_ix) == e.method_call_num_args) {
              mc_resolved_ok = 1;
            }
            /*
             * PLATFORM: SHARED — multi-import closure can leave call_resolved dep_ix on a
             * transitive dep (e.g. std.heap.libc) while the binding is std.heap. Name+arity
             * alone then emits std_heap_libc_free instead of std_heap_free_u8_ptr.
             * Trust resolved only when dep path matches the import binding path.
             * When path matches, keep typeck's overload pick (do not force re-search).
             */
            if (mc_resolved_ok != 0) {
              let bind_path: u8[64] = [];
              let bind_plen: i32 = codegen_resolve_binding_import_path_for_method_call(ctx, arena, expr_ref, &bind_path[0]);
              let dep_path_chk: u8[64] = [];
              pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, &dep_path_chk[0]);
              let dep_plen_chk: i32 = pipeline_dep_ctx_import_path_len(ctx, dep_ix);
              if (bind_plen > 0) {
                if (bind_plen != dep_plen_chk) {
                  mc_resolved_ok = 0;
                } else {
                  let bp: i32 = 0;
                  while (bp < bind_plen) {
                    if (bind_path[bp] != dep_path_chk[bp]) {
                      mc_resolved_ok = 0;
                      bp = bind_plen;
                    } else {
                      bp = bp + 1;
                    }
                  }
                }
              }
            }
            if (mc_resolved_ok != 0) {
            let dep_path: u8[64] = [];
            pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, &dep_path[0]);
            let pre_buf: u8[128] = [];
            codegen_import_path_to_c_prefix_into(&dep_path[0], &pre_buf[0], 128);
            let pre_len: i32 = 0;
            while (pre_len < 128 && pre_buf[pre_len] != 0) {
              pre_len = pre_len + 1;
            }
            /* See implementation. */
            let drv_buf_mc: i32 = 0;
            if (codegen_path_is_std_io_driver_bytes(&dep_path[0]) != 0 && fn_len > 0) {
              drv_buf_mc = codegen_emit_io_driver_buf_call_name(out, &fn_name[0], fn_len, e.method_call_num_args);
              if (drv_buf_mc < 0) {
                return -1;
              }
            }
            if (drv_buf_mc == 0) {
              /* See implementation. */
              let call_pre: i32 = codegen_func_c_symbol_prefix_len(dep_mod, func_ix, pre_len);
              if (call_pre > 0 && fn_len > 0 && codegen_c_prefix_redundant_with_name(&pre_buf[0], call_pre, &fn_name[0], fn_len) == 0 && emit_bytes_from_ptr(out, &pre_buf[0], call_pre) != 0) {
                return -1;
              }
              /* Why: typeck/parse mangle must match emit path; overloads (e.g. heap.free x6)
                 mismatch define-side mangled names -> link errors.
                 dep param type_ref lives in that module's arena — prefer dep_ctx arena,
                 else codegen_arena_for_module (null arena → empty suffixes → bare free).
                 Invariant: fn_len>0 guarantees a name; codegen_emit_func_link_name checks overload_count. */
              /* Prefer module→arena map (stable); dep_ix arena can be stale/null on Linux. */
              let dep_arena: *ASTArena = codegen_arena_for_module(ctx, dep_mod, arena);
              if (dep_arena == 0 as *ASTArena) {
                dep_arena = pipeline_dep_ctx_arena_at(ctx, dep_ix);
              }
              if (fn_len > 0 && codegen_emit_func_link_name(out, dep_arena, dep_mod, func_ix) != 0) {
                return -1;
              }
            }
            if (append_byte(out, 40) != 0) {
              return -1;
            }
            let n_dep: i32 = codegen_call_num_args_override(&pre_buf[0], pre_len, &fn_name[0], fn_len, e.method_call_num_args);
            let ai: i32 = 0;
            while (ai < n_dep) {
              if (ai > 0) {
                let comma_dep: u8[3] = [44, 32, 0];
                if (emit_bytes_3(out, comma_dep, 2) != 0) {
                  return -1;
                }
              }
              if (drv_buf_mc != 0 && ai == 0) {
                let cast_buf: u8[19] = [40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0];
                if (emit_bytes_from_ptr(out, &cast_buf[0], 18) != 0) {
                  return -1;
                }
              }
              let dep_arg: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai);
              if (ast.ref_is_null(dep_arg)) {
                if (append_byte(out, 48) != 0) {
                  return -1;
                }
              /* PLATFORM: SHARED — method dep args use same slice pointer ABI as CALL. */
              } else if (emit_call_arg_slice_abi(arena, out, dep_arg, ctx) != 0) {
                return -1;
              }
              ai = ai + 1;
            }
            return append_byte(out, 41);
            }
          }
        }
        let dep_path_fb: u8[64] = [];
        let dep_path_fb_len: i32 = codegen_resolve_binding_import_path_for_method_call(ctx, arena, expr_ref, &dep_path_fb[0]);
        if (dep_path_fb_len > 0) {
          let pre_fb: u8[128] = [];
          codegen_import_path_to_c_prefix_into(&dep_path_fb[0], &pre_fb[0], 128);
          let pre_fb_len: i32 = 0;
          while (pre_fb_len < 128 && pre_fb[pre_fb_len] != 0) {
            pre_fb_len = pre_fb_len + 1;
          }
          /* See implementation. */
          let drv_buf_fb: i32 = 0;
          if (codegen_path_is_std_io_driver_bytes(&dep_path_fb[0]) != 0) {
            drv_buf_fb = codegen_emit_io_driver_buf_call_name(out, &e.method_call_name[0], e.method_call_name_len, e.method_call_num_args);
            if (drv_buf_fb < 0) {
              return -1;
            }
          }
          if (drv_buf_fb == 0) {
            if (pre_fb_len > 0 && codegen_c_prefix_redundant_with_name(&pre_fb[0], pre_fb_len, &e.method_call_name[0], e.method_call_name_len) == 0 && emit_bytes_from_ptr(out, &pre_fb[0], pre_fb_len) != 0) {
              return -1;
            }
            /* Why: import path → dep module for mangling.
               Invariant: dep_path_fb is compared bytewise to each dep import_path; search on unique match. */
            let fb_dep_mod: *Module = 0 as *Module;
            let dj: i32 = 0;
            while (dj < pipeline_dep_ctx_ndep(ctx)) {
              let dj_path: u8[64] = [];
              pipeline_dep_ctx_import_path_copy64(ctx, dj, &dj_path[0]);
              let dj_plen: i32 = pipeline_dep_ctx_import_path_len(ctx, dj);
              if (dj_plen == dep_path_fb_len && dj_plen > 0) {
                let dj_eq: i32 = 1;
                let dk: i32 = 0;
                while (dk < dj_plen) {
                  if (dj_path[dk] != dep_path_fb[dk]) {
                    dj_eq = 0;
                    dk = dj_plen;
                  } else {
                    dk = dk + 1;
                  }
                }
                if (dj_eq != 0) {
                  fb_dep_mod = pipeline_dep_ctx_module_at(ctx, dj);
                  dj = pipeline_dep_ctx_ndep(ctx);
                }
              }
              dj = dj + 1;
            }
            if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, fb_dep_mod, &e.method_call_name[0], e.method_call_name_len) != 0) {
              return -1;
            }
          }
          if (append_byte(out, 40) != 0) {
            return -1;
          }
          let n_fb: i32 = codegen_call_num_args_override(&pre_fb[0], pre_fb_len, &e.method_call_name[0], e.method_call_name_len, e.method_call_num_args);
          let ai_fb: i32 = 0;
          while (ai_fb < n_fb) {
            if (ai_fb > 0) {
              let comma_fb: u8[3] = [44, 32, 0];
              if (emit_bytes_3(out, comma_fb, 2) != 0) {
                return -1;
              }
            }
            if (drv_buf_fb != 0 && ai_fb == 0) {
              let cast_buf: u8[19] = [40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0];
              if (emit_bytes_from_ptr(out, &cast_buf[0], 18) != 0) {
                return -1;
              }
            }
            let arg_fb: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai_fb);
            if (ast.ref_is_null(arg_fb)) {
              if (append_byte(out, 48) != 0) {
                return -1;
              }
            /* PLATFORM: SHARED — method fallback args: slice locals → &(s). */
            } else if (emit_call_arg_slice_abi(arena, out, arg_fb, ctx) != 0) {
              return -1;
            }
            ai_fb = ai_fb + 1;
          }
          return append_byte(out, 41);
        }
      }
      /*
       * See implementation.
       * See implementation.
       * See implementation.
       * See implementation.
       */
      if (e.method_call_name_len == 6
          && e.method_call_name[0] == 100 && e.method_call_name[1] == 111
          && e.method_call_name[2] == 117 && e.method_call_name[3] == 98
          && e.method_call_name[4] == 108 && e.method_call_name[5] == 101
          && e.method_call_num_args == 0
          && !ast.ref_is_null(e.method_call_base_ref)) {
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        if (emit_expr(arena, out, e.method_call_base_ref, ctx) != 0) {
          return -1;
        }
        let mul2: u8[6] = [32, 42, 32, 50, 41, 0];
        if (emit_bytes_from_ptr(out, &mul2[0], 5) != 0) {
          return -1;
        }
        return 0;
      }
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(e.method_call_base_ref) && emit_expr(arena, out, e.method_call_base_ref, ctx) != 0) {
        return -1;
      }
      let dot: u8[2] = [46, 0];
      if (emit_bytes_2(out, dot, 1) != 0) {
        return -1;
      }
      if (emit_bytes_64(out, &e.method_call_name[0], e.method_call_name_len) != 0) {
        return -1;
      }
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      let mi: i32 = 0;
      while (mi < e.method_call_num_args) {
        if (mi > 0) {
          let comma: u8[3] = [44, 32, 0];
          if (emit_bytes_3(out, comma, 2) != 0) {
            return -1;
          }
        }
        let m_arg: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, mi);
        if (ast.ref_is_null(m_arg)) {
          if (append_byte(out, 48) != 0) {
            return -1;
          }
        /* PLATFORM: SHARED — residual method_call args: slice pointer ABI. */
        } else if (emit_call_arg_slice_abi(arena, out, m_arg, ctx) != 0) {
          return -1;
        }
        mi = mi + 1;
      }
      if (append_byte(out, 41) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    /**
     * PLATFORM: SHARED — host-C EXPR_MATCH nested ternary (wave326).
     * Residual: arm 0 only → always first result (e.g. match x {1=>40;2=>42;_=>7}
     * with x=2 returned 40). Freestanding ELF already complete via
     * pipeline_asm_emit_match_elf_c; host path must compare subject.
     * G.7: complete this emit authority; seed codegen_gen twin same commit.
     */
    if (e.kind == ExprKind.EXPR_MATCH) {
      if (e.match_num_arms <= 0) {
        return append_byte(out, 48);
      }
      return codegen_emit_match_from_arm(arena, out, expr_ref, ctx, 0);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_STRUCT_LIT) {
      let sl_pfx: u8[128] = [];
      let sl_plen: i32 = codegen_emit_prefix_len_from_ctx(ctx, &sl_pfx[0], 128);
      let bare_user_lit: i32 = 0;
      /*
       * PLATFORM: SHARED — compound lit must use defining-module C tag.
       * Entry/ctx prefix alone yields parser_Token while the full def is token_Token
       * (or lexer_Token pollution) → incomplete type (parser M1 host-cc residual).
       * Authority: codegen_type_dep_struct_owner_index (same as emit_type).
       */
      if (ctx != 0 as *PipelineDepCtx && e.struct_lit_struct_name_len > 0) {
        let lit_bare_off: i32 = 0;
        let lit_bi: i32 = 0;
        while (lit_bi < e.struct_lit_struct_name_len && lit_bi < 64) {
          if (e.struct_lit_struct_name[lit_bi] == 46) {
            lit_bare_off = lit_bi + 1;
          }
          lit_bi = lit_bi + 1;
        }
        let lit_bare_len: i32 = e.struct_lit_struct_name_len - lit_bare_off;
        if (lit_bare_len > 0) {
          let lit_owner: i32 = codegen_type_dep_struct_owner_index(ctx, &e.struct_lit_struct_name[lit_bare_off], lit_bare_len);
          if (lit_owner >= 0) {
            let lit_path: u8[64] = [];
            let lit_plen: i32 = codegen_dep_import_path_len_at(ctx, lit_owner, &lit_path[0]);
            if (lit_plen > 0) {
              codegen_import_path_to_c_prefix_into(&lit_path[0], &sl_pfx[0], 128);
              sl_plen = 0;
              while (sl_plen < 128 && sl_pfx[sl_plen] != 0 as u8) {
                sl_plen = sl_plen + 1;
              }
            }
          }
        }
      }
      if (sl_plen == 0 && ctx != 0 as *PipelineDepCtx && ctx.current_codegen_dep_index < 0 && ctx.current_codegen_module != 0 as *Module) {
        let modu: *Module = ctx.current_codegen_module;
        let sk: i32 = 0;
        while (sk < modu.num_struct_layouts) {
          let snl: i32 = pipeline_module_struct_layout_name_len(modu, sk);
          if (snl == e.struct_lit_struct_name_len && snl > 0) {
            let snm: u8[64] = [];
            pipeline_module_struct_layout_name_into(modu, sk, &snm[0]);
            let eq2: bool = true;
            let sj: i32 = 0;
            while (sj < snl && sj < 64) {
              if (snm[sj] != e.struct_lit_struct_name[sj]) {
                eq2 = false;
                break;
              }
              sj = sj + 1;
            }
            if (eq2) {
              bare_user_lit = 1;
              break;
            }
          }
          sk = sk + 1;
        }
      }
      /*
       * Preamble ABI types: compound lit must use the defining-module C tag, not the
       * entry-module prefix. Catch-all std_net_ was wrong for Option_* → incomplete
       * std_net_Option_i32 (option/si matrix red under force-regen).
       * PLATFORM: SHARED — align with seed pin + emit_type Option_/Result_ authority.
       */
      if (codegen_should_skip_emit_struct_layout_for_abi_dup(&e.struct_lit_struct_name[0], e.struct_lit_struct_name_len) != 0) {
        bare_user_lit = 0;
        if (e.struct_lit_struct_name_len == 6 && e.struct_lit_struct_name[0] == 66) {
          /* Buffer → std_io_driver_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 105; sl_pfx[5] = 111; sl_pfx[6] = 95; sl_pfx[7] = 100;
          sl_pfx[8] = 114; sl_pfx[9] = 105; sl_pfx[10] = 118; sl_pfx[11] = 101;
          sl_pfx[12] = 114; sl_pfx[13] = 95; sl_pfx[14] = 0;
          sl_plen = 14;
        } else if (e.struct_lit_struct_name_len == 5 && e.struct_lit_struct_name[0] == 69) {
          /* Error → std_error_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 101; sl_pfx[5] = 114; sl_pfx[6] = 114; sl_pfx[7] = 111;
          sl_pfx[8] = 114; sl_pfx[9] = 95; sl_pfx[10] = 0;
          sl_plen = 10;
        } else if (e.struct_lit_struct_name_len >= 8 && e.struct_lit_struct_name[0] == 79
            && e.struct_lit_struct_name[1] == 112 && e.struct_lit_struct_name[2] == 116
            && e.struct_lit_struct_name[3] == 105 && e.struct_lit_struct_name[4] == 111
            && e.struct_lit_struct_name[5] == 110 && e.struct_lit_struct_name[6] == 95) {
          /* Option_* → core_option_ (same invariant as emit_type monomorph path) */
          sl_pfx[0] = 99; sl_pfx[1] = 111; sl_pfx[2] = 114; sl_pfx[3] = 101;
          sl_pfx[4] = 95; sl_pfx[5] = 111; sl_pfx[6] = 112; sl_pfx[7] = 116;
          sl_pfx[8] = 105; sl_pfx[9] = 111; sl_pfx[10] = 110; sl_pfx[11] = 95;
          sl_pfx[12] = 0;
          sl_plen = 12;
        } else if (e.struct_lit_struct_name_len == 9 && e.struct_lit_struct_name[0] == 82) {
          /* Result_u8 → core_result_ */
          sl_pfx[0] = 99; sl_pfx[1] = 111; sl_pfx[2] = 114; sl_pfx[3] = 101;
          sl_pfx[4] = 95; sl_pfx[5] = 114; sl_pfx[6] = 101; sl_pfx[7] = 115;
          sl_pfx[8] = 117; sl_pfx[9] = 108; sl_pfx[10] = 116; sl_pfx[11] = 95;
          sl_pfx[12] = 0;
          sl_plen = 12;
        } else if (e.struct_lit_struct_name_len == 10 && e.struct_lit_struct_name[0] == 82
            && e.struct_lit_struct_name[7] == 105) {
          /* Result_i32 → core_result_ */
          sl_pfx[0] = 99; sl_pfx[1] = 111; sl_pfx[2] = 114; sl_pfx[3] = 101;
          sl_pfx[4] = 95; sl_pfx[5] = 114; sl_pfx[6] = 101; sl_pfx[7] = 115;
          sl_pfx[8] = 117; sl_pfx[9] = 108; sl_pfx[10] = 116; sl_pfx[11] = 95;
          sl_pfx[12] = 0;
          sl_plen = 12;
        } else if (e.struct_lit_struct_name_len == 6 && e.struct_lit_struct_name[0] == 83 && e.struct_lit_struct_name[1] == 116 && e.struct_lit_struct_name[2] == 114 && e.struct_lit_struct_name[3] == 105) {
          /* String → std_string_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 115; sl_pfx[5] = 116; sl_pfx[6] = 114; sl_pfx[7] = 105;
          sl_pfx[8] = 110; sl_pfx[9] = 103; sl_pfx[10] = 95; sl_pfx[11] = 0;
          sl_plen = 11;
        } else if (e.struct_lit_struct_name_len == 7 && e.struct_lit_struct_name[0] == 83 && e.struct_lit_struct_name[3] == 86) {
          /* StrView → std_string_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 115; sl_pfx[5] = 116; sl_pfx[6] = 114; sl_pfx[7] = 105;
          sl_pfx[8] = 110; sl_pfx[9] = 103; sl_pfx[10] = 95; sl_pfx[11] = 0;
          sl_plen = 11;
        } else if (e.struct_lit_struct_name_len == 9 && e.struct_lit_struct_name[0] == 84) {
          /* TcpStream → std_net_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 110; sl_pfx[5] = 101; sl_pfx[6] = 116; sl_pfx[7] = 95;
          sl_pfx[8] = 0;
          sl_plen = 8;
        } else if (e.struct_lit_struct_name_len == 11 && e.struct_lit_struct_name[0] == 84) {
          /* TcpListener → std_net_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 110; sl_pfx[5] = 101; sl_pfx[6] = 116; sl_pfx[7] = 95;
          sl_pfx[8] = 0;
          sl_plen = 8;
        } else if (e.struct_lit_struct_name_len == 10 && e.struct_lit_struct_name[0] == 70 && e.struct_lit_struct_name[1] == 115) {
          /* FsIovecBuf → std_fs_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 102; sl_pfx[5] = 115; sl_pfx[6] = 95; sl_pfx[7] = 0;
          sl_plen = 7;
        } else if (e.struct_lit_struct_name_len == 5 && e.struct_lit_struct_name[0] == 73 && e.struct_lit_struct_name[1] == 111) {
          /* Iovec → std_io_sync_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 105; sl_pfx[5] = 111; sl_pfx[6] = 95;
          sl_pfx[7] = 115; sl_pfx[8] = 121; sl_pfx[9] = 110; sl_pfx[10] = 99;
          sl_pfx[11] = 95; sl_pfx[12] = 0;
          sl_plen = 12;
        }
        /* other abi_dup names: keep sl_pfx from ctx (do not force std_net_) */
      }
      let open: u8[9] = [40, 115, 116, 114, 117, 99, 116, 32, 0];
      if (emit_bytes_9(out, open, 8) != 0) {
        return -1;
      }
      if (bare_user_lit == 0 && sl_plen > 0 && emit_bytes_from_ptr(out, &sl_pfx[0], sl_plen) != 0) {
        return -1;
      }
      if (emit_bytes_64(out, &e.struct_lit_struct_name[0], e.struct_lit_struct_name_len) != 0) {
        return -1;
      }
      let open2: u8[5] = [41, 123, 32, 0, 0];
      if (emit_bytes_5(out, open2, 3) != 0) {
        return -1;
      }
      let fi: i32 = 0;
      let nf_codegen: i32 = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
      while (fi < nf_codegen) {
        if (fi > 0) {
          let comma: u8[3] = [44, 32, 0];
          if (emit_bytes_3(out, comma, 2) != 0) {
            return -1;
          }
        }
        if (append_byte(out, 46) != 0) {
          return -1;
        }
        let sl_fnbuf: u8[64] = [];
        pipeline_expr_struct_lit_field_name_into(arena, expr_ref, fi, &sl_fnbuf[0]);
        let flen: i32 = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, fi);
        if (flen > 64) {
          if (emit_bytes_64(out, &sl_fnbuf[0], 64) != 0) {
            return -1;
          }
        } else {
          if (emit_bytes_64(out, &sl_fnbuf[0], flen) != 0) {
            return -1;
          }
        }
        let eq: u8[4] = [32, 61, 32, 0];
        if (emit_bytes_4(out, eq, 3) != 0) {
          return -1;
        }
        /* STRUCT_LIT array fields: C designated init cannot take an array/pointer RHS.
         * - EXPR_ARRAY_LIT empty → `{ 0 }`; non-empty → emit_braced_array_lit_init
         * - VAR/param (u8[N] or decayed *u8) → expand `.name = { src[0], …, src[N-1] }`
         *   (parser M1 host-cc residual: `.name = z64` / `.name = name64` illegal).
         * Do NOT emit_expr alone for TYPE_ARRAY fields (pointer-to-integer on first elem).
         * PLATFORM: SHARED — seed pin same commit; verify parser.x -E host-cc. */
        let init_ref: i32 = pipeline_expr_struct_lit_init_ref(arena, expr_ref, fi);
        if (!ast.ref_is_null(init_ref)) {
          let init_e: Expr = ast.ast_arena_expr_get(arena, init_ref);
          if (init_e.kind == ExprKind.EXPR_ARRAY_LIT) {
            if (init_e.array_lit_num_elems == 0) {
              let zero_init: u8[6] = [123, 32, 48, 32, 125, 0];
              if (emit_bytes_6(out, zero_init, 5) != 0) {
                return -1;
              }
            } else {
              if (emit_braced_array_lit_init(arena, out, init_ref, ctx) != 0) {
                return -1;
              }
            }
          } else {
            let use_elem_expand: i32 = 0;
            let arr_sz: i32 = 0;
            let flen_lk: i32 = flen;
            if (flen_lk > 64) {
              flen_lk = 64;
            }
            let ftr: i32 = codegen_lookup_struct_field_type_ref(
              arena, ctx, &e.struct_lit_struct_name[0], e.struct_lit_struct_name_len, &sl_fnbuf[0], flen_lk);
            if (!ast.ref_is_null(ftr)
                && pipeline_type_kind_ord_at(arena, ftr) == (TypeKind.TYPE_ARRAY as i32)) {
              arr_sz = pipeline_type_array_size_at(arena, ftr);
              if (arr_sz > 0 && arr_sz <= 512) {
                use_elem_expand = 1;
              }
            } else if (!ast.ref_is_null(init_e.resolved_type_ref)
                && pipeline_type_kind_ord_at(arena, init_e.resolved_type_ref) == (TypeKind.TYPE_ARRAY as i32)) {
              arr_sz = pipeline_type_array_size_at(arena, init_e.resolved_type_ref);
              if (arr_sz > 0 && arr_sz <= 512) {
                use_elem_expand = 1;
              }
            }
            if (use_elem_expand != 0) {
              if (append_byte(out, 123) != 0) {
                return -1;
              }
              let ai: i32 = 0;
              while (ai < arr_sz) {
                if (ai > 0) {
                  let cm: u8[3] = [44, 32, 0];
                  if (emit_bytes_3(out, cm, 2) != 0) {
                    return -1;
                  }
                }
                if (emit_expr(arena, out, init_ref, ctx) != 0) {
                  return -1;
                }
                if (append_byte(out, 91) != 0) {
                  return -1;
                }
                if (format_int(out, ai as i64) != 0) {
                  return -1;
                }
                if (append_byte(out, 93) != 0) {
                  return -1;
                }
                ai = ai + 1;
              }
              if (append_byte(out, 125) != 0) {
                return -1;
              }
            } else {
              if (emit_expr(arena, out, init_ref, ctx) != 0) {
                return -1;
              }
            }
          }
        }
        fi = fi + 1;
      }
      let close: u8[4] = [32, 125, 0, 0];
      return emit_bytes_4(out, close, 2);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_ARRAY_LIT) {
      let n: i32 = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
      let elem_type_ref: i32 = 0;
      let is_slice: i32 = 0;
      let is_vector: i32 = 0;
      if (!ast.ref_is_null(e.resolved_type_ref) && e.resolved_type_ref > 0 && e.resolved_type_ref <= arena.num_types) {
        let ty: Type = ast.ast_arena_type_get(arena, e.resolved_type_ref);
        if (ty.kind == TypeKind.TYPE_SLICE) {
          is_slice = 1;
          elem_type_ref = ty.elem_type_ref;
        } else if (ty.kind == TypeKind.TYPE_ARRAY) {
          elem_type_ref = ty.elem_type_ref;
        } else if (ty.kind == TypeKind.TYPE_VECTOR) {
          /* See implementation. */
          is_vector = 1;
        } else if (ty.kind == TypeKind.TYPE_NAMED && ty.name_len >= 5) {
          /* See implementation. */
          let ni: i32 = 0;
          while (ni < ty.name_len) {
            if (ty.name[ni] == 120) {
              is_vector = 1;
              ni = ty.name_len;
            } else {
              ni = ni + 1;
            }
          }
        }
      }
      if (is_vector != 0) {
        /* (vec_ty){ e0, e1, ... } compound literal */
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        if (emit_type(arena, out, e.resolved_type_ref, 0 as *u8, 0, ctx) != 0) {
          return -1;
        }
        if (append_byte(out, 41) != 0) {
          return -1;
        }
        if (append_byte(out, 123) != 0) {
          return -1;
        }
        let vai: i32 = 0;
        while (vai < n) {
          if (vai > 0) {
            let comma: u8[3] = [44, 32, 0];
            if (emit_bytes_3(out, comma, 2) != 0) {
              return -1;
            }
          }
          if (!ast.ref_is_null(pipeline_expr_array_lit_elem_ref(arena, expr_ref, vai))
              && emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, expr_ref, vai), ctx) != 0) {
            return -1;
          }
          vai = vai + 1;
        }
        let vclose: u8[4] = [32, 125, 0, 0];
        return emit_bytes_4(out, vclose, 2);
      }
      if (elem_type_ref == 0 && n > 0) {
        let first_ref: i32 = pipeline_expr_array_lit_elem_ref(arena, expr_ref, 0);
        if (!ast.ref_is_null(first_ref)) {
          let first_e: Expr = ast.ast_arena_expr_get(arena, first_ref);
          elem_type_ref = first_e.resolved_type_ref;
        }
      }
      if (is_slice != 0) {
        /*
         * wave335 Cap residual pure: TYPE_SLICE + ARRAY_LIT must use static storage.
         * Root: `(E[]){…}` has automatic duration → return/let-then-return dangles
         * (same class as pre-12c675d71 string stack compounds).
         * G.7: GNU statement expr + block-scope static array (host gcc/clang):
         *   ({ static E __xlang_al[] = {…}; (struct slice){ .data = __xlang_al, .length = N }; })
         * PLATFORM: SHARED host-C emit.
         */
        if (n == 0) {
          /* Empty: null data is durable; no static needed. */
          if (append_byte(out, 40) != 0) {
            return -1;
          }
          if (emit_type(arena, out, e.resolved_type_ref, 0 as *u8, 0, ctx) != 0) {
            let fallback: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
            if (emit_bytes_9(out, fallback, 7) != 0) {
              return -1;
            }
          }
          let empty_tail: u8[40] = [41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 40, 118, 111, 105, 100, 32, 42, 41, 48, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 48, 32, 125, 0, 0, 0, 0, 0];
          /* ){ .data = (void *)0, .length = 0 } */
          if (emit_bytes_from_ptr(out, &empty_tail[0], 35) != 0) {
            return -1;
          }
          return 0;
        }
        /* ({ static  */
        let open_stmt: u8[12] = [40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0];
        if (emit_bytes_from_ptr(out, &open_stmt[0], 10) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(elem_type_ref) && emit_type(arena, out, elem_type_ref, 0 as *u8, 0, ctx) != 0) {
          let fallback: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
          if (emit_bytes_9(out, fallback, 7) != 0) {
            return -1;
          }
        }
        /*  __xlang_al[] = { */
        let al_head: u8[18] = [32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 108, 91, 93, 32, 61, 32, 123, 0];
        if (emit_bytes_from_ptr(out, &al_head[0], 17) != 0) {
          return -1;
        }
        let ai: i32 = 0;
        while (ai < n) {
          if (ai > 0) {
            let comma: u8[3] = [44, 32, 0];
            if (emit_bytes_3(out, comma, 2) != 0) {
              return -1;
            }
          }
          if (!ast.ref_is_null(pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai)) && emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai), ctx) != 0) {
            return -1;
          }
          ai = ai + 1;
        }
        /* }; ( */
        let mid: u8[6] = [125, 59, 32, 40, 0, 0];
        if (emit_bytes_from_ptr(out, &mid[0], 4) != 0) {
          return -1;
        }
        if (emit_type(arena, out, e.resolved_type_ref, 0 as *u8, 0, ctx) != 0) {
          let fallback: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
          if (emit_bytes_9(out, fallback, 7) != 0) {
            return -1;
          }
        }
        /* ){ .data = __xlang_al, .length =  */
        let slice_mid: u8[36] = [41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 108, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0];
        if (emit_bytes_from_ptr(out, &slice_mid[0], 33) != 0) {
          return -1;
        }
        if (format_int(out, ai) != 0) {
          return -1;
        }
        /*  }; }) */
        let slice_end: u8[8] = [32, 125, 59, 32, 125, 41, 0, 0];
        if (emit_bytes_from_ptr(out, &slice_end[0], 6) != 0) {
          return -1;
        }
        return 0;
      } else {
        /* See implementation. */
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        if (ast.ref_is_null(elem_type_ref) || emit_type(arena, out, elem_type_ref, 0 as *u8, 0, ctx) != 0) {
          let fallback: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
          if (emit_bytes_9(out, fallback, 7) != 0) {
            return -1;
          }
        }
        let arr: u8[5] = [91, 93, 41, 123, 0];
        if (emit_bytes_5(out, arr, 4) != 0) {
          return -1;
        }
      }
      let ai: i32 = 0;
      while (ai < n) {
        if (ai > 0) {
          let comma: u8[3] = [44, 32, 0];
          if (emit_bytes_3(out, comma, 2) != 0) {
            return -1;
          }
        }
        if (!ast.ref_is_null(pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai)) && emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai), ctx) != 0) {
          return -1;
        }
        ai = ai + 1;
      }
      let close: u8[4] = [32, 125, 0, 0];
      return emit_bytes_4(out, close, 2);
    }
    /* See implementation. */
    if (e.kind == ExprKind.EXPR_ENUM_VARIANT) {
      return append_byte(out, 48);
    }
    return -1;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_callee_var_is_string_new(e: Expr): i32 {
  if (e.kind != ExprKind.EXPR_VAR) {
    return 0;
  }
  if (e.var_name_len == 10) {
    let expect_sn: u8[10] = [115, 116, 114, 105, 110, 95, 110, 101, 119, 0];
    let i_sn: i32 = 0;
    while (i_sn < 9) {
      if (e.var_name[i_sn] != expect_sn[i_sn]) {
        return 0;
      }
      i_sn = i_sn + 1;
    }
    return 1;
  }
  if (e.var_name_len == 22) {
    let expect_ssn: u8[22] = [115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 115, 116, 114, 105, 110, 95, 110, 101, 119, 0, 0];
    let i_ssn: i32 = 0;
    while (i_ssn < 20) {
      if (e.var_name[i_ssn] != expect_ssn[i_ssn]) {
        return 0;
      }
      i_ssn = i_ssn + 1;
    }
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 */
export function emit_run_defers(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, indent: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let ndef: i32 = 0;
    while (ndef < 256) {
      if (pipeline_block_defer_body_ref(arena, block_ref, ndef) <= 0) {
        break;
      }
      ndef = ndef + 1;
    }
    let di: i32 = ndef - 1;
    while (di >= 0) {
      let dbody: i32 = pipeline_block_defer_body_ref(arena, block_ref, di);
      if (dbody > 0) {
        if (emit_block(arena, out, dbody, indent, ctx) != 0) {
          return -1;
        }
      }
      di = di - 1;
    }
    return 0;
  }
}

/** Exported function `codegen_current_func_returns_void`.
 * Implements `codegen_current_func_returns_void`.
 * @param arena *ASTArena
 * @param ctx *PipelineDepCtx
 * @return i32
 */
export function codegen_current_func_returns_void(arena: *ASTArena, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module || ctx.current_codegen_arena != arena || ctx.current_func_index < 0) {
      return 0;
    }
    let mod: *Module = ctx.current_codegen_module;
    if (ctx.current_func_index >= mod.num_funcs) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(mod, ctx.current_func_index)) == (TypeKind.TYPE_VOID as i32)) {
      return 1;
    }
    return 0;
  }
}

/** Return 1 when the current function is named the four bytes `main`.
 * Purpose: Zig-like void main maps to process exit 0 on the C entry symbol.
 * Parameters: ctx — dep context with current_codegen_module / current_func_index.
 * Returns: 1 if name is main, else 0.
 * PLATFORM: SHARED — language entry contract; dual-end product matrix.
 */
export function codegen_current_func_is_named_main(ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module || ctx.current_func_index < 0) {
      return 0;
    }
    let mod: *Module = ctx.current_codegen_module;
    if (ctx.current_func_index >= mod.num_funcs) {
      return 0;
    }
    let nlen: i32 = pipeline_module_func_name_len_at(mod, ctx.current_func_index);
    if (nlen != 4) {
      return 0;
    }
    let nm: u8[64] = [];
    codegen_copy_func_name64_from_module(mod, ctx.current_func_index, &nm[0]);
    if (nm[0] == 109 && nm[1] == 97 && nm[2] == 105 && nm[3] == 110) {
      return 1;
    }
    return 0;
  }
}

/**
 * Emit a C `return` statement with Cap-T001 / host-cc awareness.
 *
 * Why: Cap-T001 wrappers often end with typeck filler `return 0` after a real
 * `return glue(...)`. Bare `return 0` is illegal when the function returns a
 * struct by value (Lexer, OneFuncResult, …) → host-cc "returning 'int' from …".
 * For TYPE_NAMED returns, int-lit/empty `return 0` becomes
 * `return (struct Tag){0};` (valid C dead code).
 * PLATFORM: SHARED — seed pin same commit; verify parser.x host-cc.
 */
export function emit_return_stmt_with_context(arena: *ASTArena, out: *CodegenOutBuf, indent: i32, operand_ref: i32, ctx: *PipelineDepCtx, fn_ret_void: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (fn_ret_void != 0) {
      if (!ast.ref_is_null(operand_ref)) {
        if (emit_indent(out, indent) != 0) {
          return -1;
        }
        let v: u8[9] = [40, 118, 111, 105, 100, 41, 40, 0, 0];
        if (emit_bytes_9(out, v, 7) != 0) {
          return -1;
        }
        if (emit_expr(arena, out, operand_ref, ctx) != 0) {
          return -1;
        }
        let scv: u8[4] = [41, 59, 10, 0];
        if (emit_bytes_4(out, scv, 3) != 0) {
          return -1;
        }
      }
      if (emit_indent(out, indent) != 0) {
        return -1;
      }
      /* PLATFORM: SHARED — Zig-like void main: process entry is C int32_t main, so
       * bare `return;` becomes `return 0;` (implicit exit code 0). Non-main void
       * functions keep a bare `return;`. */
      if (codegen_current_func_is_named_main(ctx) != 0) {
        let ret0: u8[12] = [114, 101, 116, 117, 114, 110, 32, 48, 59, 10, 0, 0];
        return emit_bytes_from_ptr(out, &ret0[0], 10);
      }
      let retv: u8[9] = [114, 101, 116, 117, 114, 110, 59, 10, 0];
      return emit_bytes_9(out, retv, 8);
    }
    /* See implementation. */
    if (!ast.ref_is_null(operand_ref)) {
      if (pipeline_expr_kind_ord_at(arena, operand_ref) == (42 as i32)) {
        if (emit_indent(out, indent) != 0) {
          return -1;
        }
        if (emit_expr(arena, out, operand_ref, ctx) != 0) {
          return -1;
        }
        let sc_panic: u8[4] = [59, 10, 0, 0];
        return emit_bytes_4(out, sc_panic, 2);
      }
    }
    /*
     * By-value struct + Cap-T001 filler `return 0`: host C rejects `return 0` for
     * incomplete/struct return types. Emit compound zero instead.
     */
    if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module
        && ctx.current_func_index >= 0 && ctx.current_func_index < ctx.current_codegen_module.num_funcs) {
      let rty: i32 = pipeline_module_func_return_type_at(ctx.current_codegen_module, ctx.current_func_index);
      if (!ast.ref_is_null(rty) && pipeline_type_kind_ord_at(arena, rty) == (TypeKind.TYPE_NAMED as i32)) {
        let use_struct_zero: i32 = 0;
        if (ast.ref_is_null(operand_ref)) {
          use_struct_zero = 1;
        } else if (pipeline_expr_kind_ord_at(arena, operand_ref) == (ExprKind.EXPR_LIT as i32)) {
          let lit: Expr = ast.ast_arena_expr_get(arena, operand_ref);
          if (lit.int_val == 0) {
            use_struct_zero = 1;
          }
        }
        if (use_struct_zero != 0) {
          if (emit_indent(out, indent) != 0) {
            return -1;
          }
          /* return ( */
          let ret_open: u8[8] = [114, 101, 116, 117, 114, 110, 32, 40];
          if (emit_bytes_from_ptr(out, &ret_open[0], 8) != 0) {
            return -1;
          }
          if (emit_type(arena, out, rty, 0 as *u8, 0, ctx) != 0) {
            return -1;
          }
          /* ){0};\n */
          let ret_close: u8[8] = [41, 123, 48, 125, 59, 10, 0, 0];
          if (emit_bytes_from_ptr(out, &ret_close[0], 6) != 0) {
            return -1;
          }
          return 0;
        }
      }
    }
    if (emit_indent(out, indent) != 0) {
      return -1;
    }
    let ret: u8[8] = [114, 101, 116, 117, 114, 110, 32, 0];
    if (emit_bytes_8(out, ret, 7) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(operand_ref) && emit_expr(arena, out, operand_ref, ctx) != 0) {
      return -1;
    }
    let sc: u8[4] = [59, 10, 0, 0];
    return emit_bytes_4(out, sc, 2);
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function emit_block_final_expr(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, final_ref: i32, indent: i32, ctx: *PipelineDepCtx, fn_ret_void: i32): i32 {
  if (ast.ref_is_null(final_ref)) {
    return 0;
  }
  let fe: Expr = ast.ast_arena_expr_get(arena, final_ref);
  if (fe.kind == ExprKind.EXPR_BREAK) {
    return emit_break_stmt(out, indent);
  }
  if (fe.kind == ExprKind.EXPR_CONTINUE) {
    return emit_continue_stmt(out, indent);
  }
  if (fe.kind == ExprKind.EXPR_RETURN) {
    return emit_return_stmt_with_context(arena, out, indent, fe.unary_operand_ref, ctx, fn_ret_void);
  }
  let parent_br: i32 = 0;
  if (block_ref > 0 && block_ref <= arena.num_blocks) {
    let blk: Block = ast.ast_arena_block_get(arena, block_ref);
    parent_br = blk.parent_block_ref;
  }
  /*
   * Nested / non-function-body final: emit `expr;` not return.
   * PLATFORM: SHARED — GNU statement expr `({ ... })` (EXPR_BLOCK as value, e.g.
   * `if (a==b){1}else{0}` as call arg) must end with a value expression.
   * `return 1;` makes the statement-expr void → host-cc "void to int32_t".
   * Only the real function body block may use return for final_expr.
   */
  let is_func_body: i32 = 0;
  if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module
      && ctx.current_func_index >= 0) {
    let fbody: i32 = pipeline_module_func_body_ref_at(ctx.current_codegen_module, ctx.current_func_index);
    if (!ast.ref_is_null(fbody) && fbody == block_ref) {
      is_func_body = 1;
    }
  }
  if (parent_br > 0 || is_func_body == 0) {
    if (emit_indent(out, indent) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, final_ref, ctx) != 0) {
      return -1;
    }
    let end: u8[4] = [59, 10, 0, 0];
    return emit_bytes_from_ptr(out, &end[0], 2);
  }
  return emit_return_stmt_with_context(arena, out, indent, final_ref, ctx, fn_ret_void);
}

/**
 * See implementation.
 * See implementation.
 */
export function emit_block(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, indent: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let blk_prefix: u8[128] = [];
    let blk_prefix_len: i32 = codegen_emit_prefix_len_from_ctx(ctx, &blk_prefix[0], 128);
    let fn_ret_void: i32 = codegen_current_func_returns_void(arena, ctx);
    if (ast.ref_is_null(block_ref)) {
      return 0;
    }
    if (block_ref <= 0 || block_ref > arena.num_blocks) {
      return 0;
    }
    if (ast.ast_block_num_stmt_order(arena, block_ref) > 0) {
      /* See implementation. */
      let pre_li: i32 = 0;
      while (pre_li < ast.ast_block_num_lets(arena, block_ref)) {
        if (block_stmt_order_has_let(arena, block_ref, pre_li) == 0) {
          let lname_pre: u8[64] = [];
          pipeline_block_let_name_copy64(arena, block_ref, pre_li, &lname_pre[0]);
          let lname_len_pre: i32 = pipeline_block_let_name_len(arena, block_ref, pre_li);
          let let_type_pre: i32 = pipeline_block_let_type_ref(arena, block_ref, pre_li);
          let linit_pre: i32 = pipeline_block_let_init_ref(arena, block_ref, pre_li);
          if (emit_indent(out, indent) != 0) {
            return -1;
          }
          let type_emitted_pre: i32 = 0;
          let use_local_array_pre: i32 = 0;
          if (!ast.ref_is_null(let_type_pre) && pipeline_type_kind_ord_at(arena, let_type_pre) == 10) {
            use_local_array_pre = 1;
          }
          if (use_local_array_pre != 0) {
            if (emit_local_fixed_array_elem_type(arena, out, let_type_pre, ctx) != 0) {
              return -1;
            }
            type_emitted_pre = 1;
          }
          if (type_emitted_pre == 0) {
            if (emit_type(arena, out, let_type_pre, 0 as *u8, 0, ctx) != 0) {
              return -1;
            }
          }
          if (append_byte(out, 32) != 0) {
            return -1;
          }
          if (lname_len_pre > 0 && (lname_pre[0] > 32)) {
            if (emit_bytes_64(out, &lname_pre[0], lname_len_pre) != 0) {
              return -1;
            }
          } else {
            let place_pre: u8[4] = [95, 108, 48, 0];
            if (emit_bytes_4(out, place_pre, 2) != 0) {
              return -1;
            }
            if (format_int(out, pre_li) != 0) {
              return -1;
            }
          }
          if (use_local_array_pre != 0) {
            if (emit_local_fixed_array_suffix(arena, out, let_type_pre) != 0) {
              return -1;
            }
          }
          let eq_pre: u8[4] = [32, 61, 32, 0];
          if (emit_bytes_4(out, eq_pre, 3) != 0) {
            return -1;
          }
          if (emit_expr(arena, out, linit_pre, ctx) != 0) {
            return -1;
          }
          let sc_pre: u8[3] = [59, 10, 0];
          if (emit_bytes_3(out, sc_pre, 2) != 0) {
            return -1;
          }
        }
        pre_li = pre_li + 1;
      }
      let si: i32 = 0;
      while (si < ast.ast_block_num_stmt_order(arena, block_ref)) {
        let k: u8 = ast.ast_block_stmt_order_kind(arena, block_ref, si);
        let idx: i32 = ast.ast_block_stmt_order_idx(arena, block_ref, si);
        if (k == 0) {
          if (idx >= 0 && idx < ast.ast_block_num_consts(arena, block_ref)) {
            let cname_buf: u8[64] = [];
            pipeline_block_const_name_copy64(arena, block_ref, idx, &cname_buf[0]);
            let cname_len: i32 = pipeline_block_const_name_len(arena, block_ref, idx);
            let ctype_ref: i32 = pipeline_block_const_type_ref(arena, block_ref, idx);
            let cinit_ref: i32 = pipeline_block_const_init_ref(arena, block_ref, idx);
            if (emit_indent(out, indent) != 0) {
              return -1;
            }
            if (emit_type(arena, out, ctype_ref, 0 as *u8, 0, ctx) != 0) {
              return -1;
            }
            let sp: u8[3] = [32, 0, 0];
            if (emit_bytes_3(out, sp, 1) != 0) {
              return -1;
            }
            /* See implementation. */
            if (cname_len > 0 && (cname_buf[0] > 32)) {
              if (emit_bytes_64(out, &cname_buf[0], cname_len) != 0) {
                return -1;
              }
            } else {
              let place: u8[4] = [95, 99, 48, 0];
              if (emit_bytes_4(out, place, 2) != 0) {
                return -1;
              }
              if (format_int(out, idx) != 0) {
                return -1;
              }
            }
            let eq: u8[4] = [32, 61, 32, 0];
            if (emit_bytes_4(out, eq, 3) != 0) {
              return -1;
            }
            if (emit_expr(arena, out, cinit_ref, ctx) != 0) {
              return -1;
            }
            let sc: u8[3] = [59, 10, 0];
            if (emit_bytes_3(out, sc, 2) != 0) {
              return -1;
            }
          }
        } else if (k == 1) {
          if (idx >= 0 && idx < ast.ast_block_num_lets(arena, block_ref)) {
            let lname_buf: u8[64] = [];
            pipeline_block_let_name_copy64(arena, block_ref, idx, &lname_buf[0]);
            let lname_len: i32 = pipeline_block_let_name_len(arena, block_ref, idx);
            let let_type_ref: i32 = pipeline_block_let_type_ref(arena, block_ref, idx);
            let linit_ref: i32 = pipeline_block_let_init_ref(arena, block_ref, idx);
            if (emit_indent(out, indent) != 0) {
              return -1;
            }
            /* See implementation. */
            let type_emitted: i32 = 0;
            let use_local_array: i32 = 0;
            if (!ast.ref_is_null(let_type_ref) && pipeline_type_kind_ord_at(arena, let_type_ref) == 10) {
              use_local_array = 1;
            }
            if (use_local_array != 0) {
              if (emit_local_fixed_array_elem_type(arena, out, let_type_ref, ctx) != 0) {
                return -1;
              }
              type_emitted = 1;
            }
            if (!ast.ref_is_null(linit_ref) && linit_ref > 0 && linit_ref <= arena.num_exprs) {
              let init_e: Expr = ast.ast_arena_expr_get(arena, linit_ref);
              if (type_emitted == 0 && init_e.kind == ExprKind.EXPR_ARRAY_LIT && type_array_elem_is_u8(arena, let_type_ref) != 0) {
                let u8ptr: u8[9] = [117, 105, 110, 116, 56, 95, 116, 32, 0];
                if (emit_bytes_9(out, u8ptr, 7) != 0) {
                  return -1;
                }
                if (append_byte(out, 42) != 0) {
                  return -1;
                }
                type_emitted = 1;
              }
              /*
               * See implementation.
               * See implementation.
               * See implementation.
               * See implementation.
               */
              if (type_emitted == 0 && !ast.ref_is_null(init_e.resolved_type_ref) && init_e.resolved_type_ref > 0 && init_e.resolved_type_ref <= arena.num_types) {
                let rt: Type = ast.ast_arena_type_get(arena, init_e.resolved_type_ref);
                if (rt.kind == TypeKind.TYPE_NAMED && rt.name_len >= 6) {
                  let n0: i32 = rt.name_len - 6;
                  if (rt.name[n0] == 83 && rt.name[n0 + 1] == 116 && rt.name[n0 + 2] == 114 && rt.name[n0 + 3] == 105 && rt.name[n0 + 4] == 110 && rt.name[n0 + 5] == 103) {
                    let str_ty: u8[7] = [83, 116, 114, 105, 110, 103, 0];
                    if (emit_bytes_from_ptr(out, &str_ty[0], 6) != 0) {
                      return -1;
                    }
                    if (append_byte(out, 32) != 0) {
                      return -1;
                    }
                    type_emitted = 1;
                  }
                }
              }
              if (type_emitted == 0 && init_e.kind == ExprKind.EXPR_CALL && !ast.ref_is_null(init_e.call_callee_ref) && init_e.call_callee_ref > 0 && init_e.call_callee_ref <= arena.num_exprs) {
                let callee_let: Expr = ast.ast_arena_expr_get(arena, init_e.call_callee_ref);
                if (callee_let.kind == ExprKind.EXPR_VAR) {
                  if (codegen_callee_var_is_string_new(callee_let) != 0) {
                    let str_ty: u8[7] = [83, 116, 114, 105, 110, 103, 0];
                    if (emit_bytes_from_ptr(out, &str_ty[0], 6) != 0) {
                      return -1;
                    }
                    if (append_byte(out, 32) != 0) {
                      return -1;
                    }
                    type_emitted = 1;
                  }
                }
              }
            }
            if (type_emitted == 0) {
              if (ast.ref_is_null(let_type_ref) && !ast.ref_is_null(linit_ref) && linit_ref > 0 && linit_ref <= arena.num_exprs) {
                let init_e: Expr = ast.ast_arena_expr_get(arena, linit_ref);
                if (!ast.ref_is_null(init_e.resolved_type_ref)) {
                  let_type_ref = init_e.resolved_type_ref;
                }
              }
              if (emit_type(arena, out, let_type_ref, 0 as *u8, 0, ctx) != 0) {
                return -1;
              }
            }
            if (append_byte(out, 32) != 0) {
              return -1;
            }
            /* See implementation. */
            if (lname_len > 0 && (lname_buf[0] > 32)) {
              if (emit_bytes_64(out, &lname_buf[0], lname_len) != 0) {
                return -1;
              }
            } else {
              let place: u8[4] = [95, 108, 48, 0];
              if (emit_bytes_4(out, place, 2) != 0) {
                return -1;
              }
              if (format_int(out, idx) != 0) {
                return -1;
              }
            }
            if (use_local_array != 0) {
              if (emit_local_fixed_array_suffix(arena, out, let_type_ref) != 0) {
                return -1;
              }
            }
            let eq: u8[4] = [32, 61, 32, 0];
            if (emit_bytes_4(out, eq, 3) != 0) {
              return -1;
            }
            let slice_init: i32 = 0;
            if (!ast.ref_is_null(linit_ref)) {
              slice_init = try_emit_slice_init_from_array_var(arena, out, block_ref, idx, let_type_ref, linit_ref);
            }
            /* See implementation. */
            if (ast.ref_is_null(linit_ref)) {
              let zinit_omit2: u8[6] = [123, 32, 48, 32, 125, 0];
              if (emit_bytes_6(out, zinit_omit2, 5) != 0) {
                return -1;
              }
            } else if (slice_init == 1) {
              /* See implementation. */
            } else if (slice_init < 0) {
              return -1;
            } else if (use_local_array != 0 && !ast.ref_is_null(linit_ref) && linit_ref > 0 && linit_ref <= arena.num_exprs) {
              let init_e2: Expr = ast.ast_arena_expr_get(arena, linit_ref);
              if (init_e2.kind == ExprKind.EXPR_ARRAY_LIT) {
                if (emit_braced_array_lit_init(arena, out, linit_ref, ctx) != 0) {
                  return -1;
                }
              } else if (init_e2.kind == ExprKind.EXPR_LIT && init_e2.int_val == 0) {
                let zinit: u8[6] = [123, 32, 48, 32, 125, 0];
                if (emit_bytes_6(out, zinit, 5) != 0) {
                  return -1;
                }
              } else {
                if (emit_expr(arena, out, linit_ref, ctx) != 0) {
                  return -1;
                }
              }
            } else {
              /* See implementation. */
              let use_vec_z: i32 = 0;
              let use_vec_braced: i32 = 0;
              if (!ast.ref_is_null(linit_ref) && linit_ref > 0 && linit_ref <= arena.num_exprs
                  && !ast.ref_is_null(let_type_ref)) {
                let init_ez: Expr = ast.ast_arena_expr_get(arena, linit_ref);
                let tk_z: i32 = pipeline_type_kind_ord_at(arena, let_type_ref);
                let is_vec_ty: i32 = 0;
                if (tk_z == TypeKind.TYPE_VECTOR) {
                  is_vec_ty = 1;
                } else if (tk_z == TypeKind.TYPE_NAMED) {
                  let vzn: u8[64] = [];
                  let vzn_l: i32 = pipeline_type_named_name_into(arena, let_type_ref, &vzn[0]);
                  let vi: i32 = 0;
                  while (vi < vzn_l) {
                    if (vzn[vi] == 120) {
                      is_vec_ty = 1;
                      vi = vzn_l;
                    } else {
                      vi = vi + 1;
                    }
                  }
                }
                if (is_vec_ty != 0) {
                  if (init_ez.kind == ExprKind.EXPR_LIT && init_ez.int_val == 0) {
                    use_vec_z = 1;
                  } else if (init_ez.kind == ExprKind.EXPR_ARRAY_LIT) {
                    use_vec_braced = 1;
                  }
                }
              }
              if (use_vec_z != 0) {
                let vz: u8[6] = [123, 32, 48, 32, 125, 0];
                if (emit_bytes_6(out, vz, 5) != 0) {
                  return -1;
                }
              } else if (use_vec_braced != 0) {
                if (emit_braced_array_lit_init(arena, out, linit_ref, ctx) != 0) {
                  return -1;
                }
              } else if (emit_expr(arena, out, linit_ref, ctx) != 0) {
                return -1;
              }
            }
            let sc: u8[3] = [59, 10, 0];
            if (emit_bytes_3(out, sc, 2) != 0) {
              return -1;
            }
          }
        } else if (k == 2) {
          if (idx >= 0 && idx < ast.ast_block_num_expr_stmts(arena, block_ref)) {
            let ex_ref: i32 = ast.ast_block_expr_stmt_ref(arena, block_ref, idx);
            let st: Expr = ast.ast_arena_expr_get(arena, ex_ref);
            if (st.kind == ExprKind.EXPR_RETURN) {
              if (emit_return_stmt_with_context(arena, out, indent, st.unary_operand_ref, ctx, fn_ret_void) != 0) {
                return -1;
              }
            } else if (st.kind == ExprKind.EXPR_BREAK) {
              if (emit_break_stmt(out, indent) != 0) {
                return -1;
              }
            } else if (st.kind == ExprKind.EXPR_CONTINUE) {
              if (emit_continue_stmt(out, indent) != 0) {
                return -1;
              }
            } else {
              if (emit_indent(out, indent) != 0) {
                return -1;
              }
              let v: u8[9] = [40, 118, 111, 105, 100, 41, 40, 0, 0];
              if (emit_bytes_9(out, v, 7) != 0) {
                return -1;
              }
              if (emit_expr(arena, out, ex_ref, ctx) != 0) {
                return -1;
              }
              let sc: u8[4] = [41, 59, 10, 0];
              if (emit_bytes_4(out, sc, 3) != 0) {
                return -1;
              }
            }
          }
        } else if (k == 3) {
          if (idx >= 0 && idx < ast.ast_block_num_loops(arena, block_ref)) {
            let w_cr: i32 = ast.ast_block_while_cond_ref(arena, block_ref, idx);
            let w_br: i32 = ast.ast_block_while_body_ref(arena, block_ref, idx);
            if (emit_indent(out, indent) != 0) {
              return -1;
            }
            let wh: u8[8] = [119, 104, 105, 108, 101, 32, 40, 0];
            if (emit_bytes_8(out, wh, 7) != 0) {
              return -1;
            }
            if (emit_expr(arena, out, w_cr, ctx) != 0) {
              return -1;
            }
            let paren: u8[5] = [41, 32, 123, 10, 0];
            if (emit_bytes_5(out, paren, 4) != 0) {
              return -1;
            }
            if (emit_block(arena, out, w_br, indent + 2, ctx) != 0) {
              return -1;
            }
            if (emit_indent(out, indent) != 0) {
              return -1;
            }
            let close: u8[3] = [125, 10, 0];
            if (emit_bytes_3(out, close, 2) != 0) {
              return -1;
            }
          }
        } else if (k == 4) {
          if (idx >= 0 && idx < ast.ast_block_num_for_loops(arena, block_ref)) {
            let fl_ir: i32 = ast.ast_block_for_init_ref(arena, block_ref, idx);
            let fl_cr: i32 = ast.ast_block_for_cond_ref(arena, block_ref, idx);
            let fl_sr: i32 = ast.ast_block_for_step_ref(arena, block_ref, idx);
            let fl_br: i32 = ast.ast_block_for_body_ref(arena, block_ref, idx);
            if (emit_indent(out, indent) != 0) {
              return -1;
            }
            let fk: u8[6] = [102, 111, 114, 32, 40, 0];
            if (emit_bytes_6(out, fk, 5) != 0) {
              return -1;
            }
            if (!ast.ref_is_null(fl_ir)) {
              if (emit_expr(arena, out, fl_ir, ctx) != 0) {
                return -1;
              }
            }
            let sc1: u8[3] = [59, 32, 0];
            if (emit_bytes_3(out, sc1, 2) != 0) {
              return -1;
            }
            if (!ast.ref_is_null(fl_cr)) {
              if (emit_expr(arena, out, fl_cr, ctx) != 0) {
                return -1;
              }
            }
            let sc2: u8[3] = [59, 32, 0];
            if (emit_bytes_3(out, sc2, 2) != 0) {
              return -1;
            }
            if (!ast.ref_is_null(fl_sr)) {
              if (emit_expr(arena, out, fl_sr, ctx) != 0) {
                return -1;
              }
            }
            let paren: u8[5] = [41, 32, 123, 10, 0];
            if (emit_bytes_5(out, paren, 4) != 0) {
              return -1;
            }
            if (!ast.ref_is_null(fl_br) && emit_block(arena, out, fl_br, indent + 2, ctx) != 0) {
              return -1;
            }
            if (emit_indent(out, indent) != 0) {
              return -1;
            }
            let close: u8[3] = [125, 10, 0];
            if (emit_bytes_3(out, close, 2) != 0) {
              return -1;
            }
          }
        } else if (k == 5) {
          if (idx >= 0 && idx < ast.ast_block_num_if_stmts(arena, block_ref)) {
            let if_cond_r: i32 = ast.ast_block_if_cond_ref(arena, block_ref, idx);
            let if_then_r: i32 = ast.ast_block_if_then_body_ref(arena, block_ref, idx);
            let if_else_r: i32 = ast.ast_block_if_else_body_ref(arena, block_ref, idx);
            if (emit_indent(out, indent) != 0) {
              return -1;
            }
            let ikw: u8[5] = [105, 102, 32, 40, 0];
            if (emit_bytes_5(out, ikw, 4) != 0) {
              return -1;
            }
            if (emit_expr(arena, out, if_cond_r, ctx) != 0) {
              return -1;
            }
            let paren_if: u8[5] = [41, 32, 123, 10, 0];
            if (emit_bytes_5(out, paren_if, 4) != 0) {
              return -1;
            }
            if (emit_block(arena, out, if_then_r, indent + 2, ctx) != 0) {
              return -1;
            }
            if (emit_indent(out, indent) != 0) {
              return -1;
            }
            if (if_else_r != 0) {
              /* See implementation. */
              let else_brace: u8[9] = [125, 32, 101, 108, 115, 101, 32, 123, 10];
              if (emit_bytes_9(out, else_brace, 9) != 0) {
                return -1;
              }
              if (emit_block(arena, out, if_else_r, indent + 2, ctx) != 0) {
                return -1;
              }
              if (emit_indent(out, indent) != 0) {
                return -1;
              }
            }
            let cif: u8[3] = [125, 10, 0];
            if (emit_bytes_3(out, cif, 2) != 0) {
              return -1;
            }
          }
        } else if (k == 6) {
          /**
           * See implementation.
           * See implementation.
           * See implementation.
           * See implementation.
           * See implementation.
           */
          if (idx >= 0 && idx < ast.ast_block_num_regions(arena, block_ref)) {
            let reg_body: i32 = ast.ast_block_region_body_ref(arena, block_ref, idx);
            let need_scope: i32 = 0;
            if (!ast.ref_is_null(reg_body) && reg_body > 0 && reg_body <= arena.num_blocks) {
              if (ast.ast_block_num_lets(arena, reg_body) > 0
                  || ast.ast_block_num_consts(arena, reg_body) > 0) {
                need_scope = 1;
              }
            }
            if (need_scope != 0) {
              if (emit_indent(out, indent) != 0) {
                return -1;
              }
              let ob: u8[2] = [123, 10];
              if (emit_bytes_2(out, ob, 2) != 0) {
                return -1;
              }
              if (emit_block(arena, out, reg_body, indent + 2, ctx) != 0) {
                return -1;
              }
              if (emit_indent(out, indent) != 0) {
                return -1;
              }
              let cb: u8[3] = [125, 10, 0];
              if (emit_bytes_3(out, cb, 2) != 0) {
                return -1;
              }
            } else {
              if (emit_block(arena, out, reg_body, indent, ctx) != 0) {
                return -1;
              }
            }
          }
        }
        si = si + 1;
      }
      if (emit_run_defers(arena, out, block_ref, indent, ctx) != 0) {
        return -1;
      }
      let final_ref: i32 = ast.ast_block_final_expr_ref(arena, block_ref);
      if (emit_block_final_expr(arena, out, block_ref, final_ref, indent, ctx, fn_ret_void) != 0) {
        return -1;
      }
      return 0;
    }
    /* See implementation. */
    let i: i32 = 0;
    while (i < ast.ast_block_num_consts(arena, block_ref)) {
      let cname_fb: u8[64] = [];
      pipeline_block_const_name_copy64(arena, block_ref, i, &cname_fb[0]);
      let cname_len_fb: i32 = pipeline_block_const_name_len(arena, block_ref, i);
      let ctype_fb: i32 = pipeline_block_const_type_ref(arena, block_ref, i);
      let cinit_fb: i32 = pipeline_block_const_init_ref(arena, block_ref, i);
      if (emit_indent(out, indent) != 0) {
        return -1;
      }
      if (emit_type(arena, out, ctype_fb, &blk_prefix[0], blk_prefix_len, ctx) != 0) {
        return -1;
      }
      let sp: u8[3] = [32, 0, 0];
      if (emit_bytes_3(out, sp, 1) != 0) {
        return -1;
      }
      /* See implementation. */
      if (cname_len_fb > 0 && (cname_fb[0] > 32)) {
        if (emit_bytes_64(out, &cname_fb[0], cname_len_fb) != 0) {
          return -1;
        }
      } else {
        let place: u8[4] = [95, 99, 48, 0];
        if (emit_bytes_4(out, place, 2) != 0) {
          return -1;
        }
        if (format_int(out, i) != 0) {
          return -1;
        }
      }
      let eq: u8[4] = [32, 61, 32, 0];
      if (emit_bytes_4(out, eq, 3) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, cinit_fb, ctx) != 0) {
        return -1;
      }
      let sc: u8[3] = [59, 10, 0];
      if (emit_bytes_3(out, sc, 2) != 0) {
        return -1;
      }
      i = i + 1;
    }
    i = 0;
    while (i < ast.ast_block_num_lets(arena, block_ref)) {
      let lname_fb: u8[64] = [];
      pipeline_block_let_name_copy64(arena, block_ref, i, &lname_fb[0]);
      let lname_len_fb: i32 = pipeline_block_let_name_len(arena, block_ref, i);
      let let_type_ref: i32 = pipeline_block_let_type_ref(arena, block_ref, i);
      let linit_fb: i32 = pipeline_block_let_init_ref(arena, block_ref, i);
      if (emit_indent(out, indent) != 0) {
        return -1;
      }
      /* See implementation. */
      let type_emitted: i32 = 0;
      let use_local_array: i32 = 0;
      if (!ast.ref_is_null(let_type_ref) && pipeline_type_kind_ord_at(arena, let_type_ref) == 10) {
        use_local_array = 1;
      }
      if (use_local_array != 0) {
        if (emit_local_fixed_array_elem_type(arena, out, let_type_ref, ctx) != 0) {
          return -1;
        }
        type_emitted = 1;
      }
      if (!ast.ref_is_null(linit_fb) && linit_fb > 0 && linit_fb <= arena.num_exprs) {
        let init_e: Expr = ast.ast_arena_expr_get(arena, linit_fb);
        if (type_emitted == 0 && init_e.kind == ExprKind.EXPR_ARRAY_LIT && type_array_elem_is_u8(arena, let_type_ref) != 0) {
          let u8ptr: u8[9] = [117, 105, 110, 116, 56, 95, 116, 32, 0];
          if (emit_bytes_9(out, u8ptr, 7) != 0) {
            return -1;
          }
          if (append_byte(out, 42) != 0) {
            return -1;
          }
          type_emitted = 1;
        }
        if (type_emitted == 0 && !ast.ref_is_null(init_e.resolved_type_ref) && init_e.resolved_type_ref > 0 && init_e.resolved_type_ref <= arena.num_types) {
          let rt2: Type = ast.ast_arena_type_get(arena, init_e.resolved_type_ref);
          if (rt2.kind == TypeKind.TYPE_NAMED && rt2.name_len >= 6) {
            let n02: i32 = rt2.name_len - 6;
            if (rt2.name[n02] == 83 && rt2.name[n02 + 1] == 116 && rt2.name[n02 + 2] == 114 && rt2.name[n02 + 3] == 105 && rt2.name[n02 + 4] == 110 && rt2.name[n02 + 5] == 103) {
              /* See implementation. */
              let str_ty2a: u8[7] = [83, 116, 114, 105, 110, 103, 0];
              if (emit_bytes_from_ptr(out, &str_ty2a[0], 6) != 0) {
                return -1;
              }
              if (append_byte(out, 32) != 0) {
                return -1;
              }
              type_emitted = 1;
            }
          }
        }
        if (type_emitted == 0 && init_e.kind == ExprKind.EXPR_CALL && !ast.ref_is_null(init_e.call_callee_ref) && init_e.call_callee_ref > 0 && init_e.call_callee_ref <= arena.num_exprs) {
          let callee_let2: Expr = ast.ast_arena_expr_get(arena, init_e.call_callee_ref);
          if (callee_let2.kind == ExprKind.EXPR_VAR) {
            if (codegen_callee_var_is_string_new(callee_let2) != 0) {
              let str_ty2: u8[7] = [83, 116, 114, 105, 110, 103, 0];
              if (emit_bytes_from_ptr(out, &str_ty2[0], 6) != 0) {
                return -1;
              }
              if (append_byte(out, 32) != 0) {
                return -1;
              }
              type_emitted = 1;
            }
          }
        }
      }
      if (type_emitted == 0) {
        if (ast.ref_is_null(let_type_ref) && !ast.ref_is_null(linit_fb) && linit_fb > 0 && linit_fb <= arena.num_exprs) {
          let init_e: Expr = ast.ast_arena_expr_get(arena, linit_fb);
          if (!ast.ref_is_null(init_e.resolved_type_ref)) {
            let_type_ref = init_e.resolved_type_ref;
          }
        }
        if (emit_type(arena, out, let_type_ref, &blk_prefix[0], blk_prefix_len, ctx) != 0) {
          return -1;
        }
      }
      if (append_byte(out, 32) != 0) {
        return -1;
      }
      /* See implementation. */
      if (lname_len_fb > 0 && (lname_fb[0] > 32)) {
        if (emit_bytes_64(out, &lname_fb[0], lname_len_fb) != 0) {
          return -1;
        }
      } else {
        let place: u8[4] = [95, 108, 48, 0];
        if (emit_bytes_4(out, place, 2) != 0) {
          return -1;
        }
        if (format_int(out, i) != 0) {
          return -1;
        }
      }
      if (use_local_array != 0) {
        if (emit_local_fixed_array_suffix(arena, out, let_type_ref) != 0) {
          return -1;
        }
      }
      let eq: u8[4] = [32, 61, 32, 0];
      if (emit_bytes_4(out, eq, 3) != 0) {
        return -1;
      }
      /* See implementation. */
      if (ast.ref_is_null(linit_fb)) {
        let zinit_omit: u8[6] = [123, 32, 48, 32, 125, 0];
        if (emit_bytes_6(out, zinit_omit, 5) != 0) {
          return -1;
        }
      } else if (use_local_array != 0 && !ast.ref_is_null(linit_fb) && linit_fb > 0 && linit_fb <= arena.num_exprs) {
        let init_e3: Expr = ast.ast_arena_expr_get(arena, linit_fb);
        if (init_e3.kind == ExprKind.EXPR_ARRAY_LIT) {
          if (emit_braced_array_lit_init(arena, out, linit_fb, ctx) != 0) {
            return -1;
          }
        } else if (init_e3.kind == ExprKind.EXPR_LIT && init_e3.int_val == 0) {
          let zinit2: u8[6] = [123, 32, 48, 32, 125, 0];
          if (emit_bytes_6(out, zinit2, 5) != 0) {
            return -1;
          }
        } else {
          if (emit_expr(arena, out, linit_fb, ctx) != 0) {
            return -1;
          }
        }
      } else {
        if (emit_expr(arena, out, linit_fb, ctx) != 0) {
          return -1;
        }
      }
      let sc: u8[3] = [59, 10, 0];
      if (emit_bytes_3(out, sc, 2) != 0) {
        return -1;
      }
      i = i + 1;
    }
    /* See implementation. */
    i = 0;
    while (i < ast.ast_block_num_expr_stmts(arena, block_ref)) {
      let ex_fb: i32 = ast.ast_block_expr_stmt_ref(arena, block_ref, i);
      let st: Expr = ast.ast_arena_expr_get(arena, ex_fb);
      if (st.kind == ExprKind.EXPR_RETURN) {
        if (emit_return_stmt_with_context(arena, out, indent, st.unary_operand_ref, ctx, fn_ret_void) != 0) {
          return -1;
        }
      } else if (st.kind == ExprKind.EXPR_BREAK) {
        if (emit_indent(out, indent) != 0) {
          return -1;
        }
        let br: u8[8] = [98, 114, 101, 97, 107, 59, 10, 0];
        if (emit_bytes_8(out, br, 7) != 0) {
          return -1;
        }
      } else if (st.kind == ExprKind.EXPR_CONTINUE) {
        if (emit_indent(out, indent) != 0) {
          return -1;
        }
        let co: u8[11] = [99, 111, 110, 116, 105, 110, 117, 101, 59, 10, 0];
        if (emit_bytes_from_ptr(out, &co[0], 10) != 0) {
          return -1;
        }
      } else {
        if (emit_indent(out, indent) != 0) {
          return -1;
        }
        let v: u8[9] = [40, 118, 111, 105, 100, 41, 40, 0, 0];
        if (emit_bytes_9(out, v, 7) != 0) {
          return -1;
        }
        if (emit_expr(arena, out, ex_fb, ctx) != 0) {
          return -1;
        }
        let sc: u8[4] = [41, 59, 10, 0];
        if (emit_bytes_4(out, sc, 3) != 0) {
          return -1;
        }
      }
      i = i + 1;
    }
    i = 0;
    while (i < ast.ast_block_num_loops(arena, block_ref)) {
      let w_cr: i32 = ast.ast_block_while_cond_ref(arena, block_ref, i);
      let w_br: i32 = ast.ast_block_while_body_ref(arena, block_ref, i);
      if (emit_indent(out, indent) != 0) {
        return -1;
      }
      let wh: u8[8] = [119, 104, 105, 108, 101, 32, 40, 0];
      if (emit_bytes_8(out, wh, 7) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, w_cr, ctx) != 0) {
        return -1;
      }
      let paren: u8[5] = [41, 32, 123, 10, 0];
      if (emit_bytes_5(out, paren, 4) != 0) {
        return -1;
      }
      if (emit_block(arena, out, w_br, indent + 2, ctx) != 0) {
        return -1;
      }
      if (emit_indent(out, indent) != 0) {
        return -1;
      }
      let close: u8[3] = [125, 10, 0];
      if (emit_bytes_3(out, close, 2) != 0) {
        return -1;
      }
      i = i + 1;
    }
    i = 0;
    while (i < ast.ast_block_num_for_loops(arena, block_ref)) {
      let fl_ir: i32 = ast.ast_block_for_init_ref(arena, block_ref, i);
      let fl_cr: i32 = ast.ast_block_for_cond_ref(arena, block_ref, i);
      let fl_sr: i32 = ast.ast_block_for_step_ref(arena, block_ref, i);
      let fl_br: i32 = ast.ast_block_for_body_ref(arena, block_ref, i);
      if (emit_indent(out, indent) != 0) {
        return -1;
      }
      let fk: u8[6] = [102, 111, 114, 32, 40, 0];
      if (emit_bytes_6(out, fk, 5) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(fl_ir)) {
        if (emit_expr(arena, out, fl_ir, ctx) != 0) {
          return -1;
        }
      }
      let sc1: u8[3] = [59, 32, 0];
      if (emit_bytes_3(out, sc1, 2) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(fl_cr)) {
        if (emit_expr(arena, out, fl_cr, ctx) != 0) {
          return -1;
        }
      }
      let sc2: u8[3] = [59, 32, 0];
      if (emit_bytes_3(out, sc2, 2) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(fl_sr)) {
        if (emit_expr(arena, out, fl_sr, ctx) != 0) {
          return -1;
        }
      }
      let paren: u8[5] = [41, 32, 123, 10, 0];
      if (emit_bytes_5(out, paren, 4) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(fl_br) && emit_block(arena, out, fl_br, indent + 2, ctx) != 0) {
        return -1;
      }
      if (emit_indent(out, indent) != 0) {
        return -1;
      }
      let close: u8[3] = [125, 10, 0];
      if (emit_bytes_3(out, close, 2) != 0) {
        return -1;
      }
      i = i + 1;
    }
    if (emit_run_defers(arena, out, block_ref, indent, ctx) != 0) {
      return -1;
    }
    /* See implementation. */
    let final_ref_plain: i32 = ast.ast_block_final_expr_ref(arena, block_ref);
    if (emit_block_final_expr(arena, out, block_ref, final_ref_plain, indent, ctx, fn_ret_void) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function emit_suffix_bytes(dst: *u8, src: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    dst[i] = src[i];
    i = i + 1;
  }
  return len;
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_type_ref_to_suffix(arena: *ASTArena, type_ref: i32, buf: *u8, buf_cap: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (type_ref <= 0 || buf == 0 as *u8 || buf_cap <= 0) {
      return 0;
    }
    let tk: i32 = pipeline_type_kind_ord_at(arena, type_ref);
    /* See implementation. */
    if (tk == (TypeKind.TYPE_PTR as i32)) {
      let elem_ref: i32 = pipeline_type_elem_ref_at(arena, type_ref);
      let n: i32 = codegen_type_ref_to_suffix(arena, elem_ref, buf, buf_cap);
      if (n > 0 && n + 4 < buf_cap) {
        buf[n] = 95;
        buf[n + 1] = 112;
        buf[n + 2] = 116;
        buf[n + 3] = 114;
        return n + 4;
      }
      return n;
    }
    /* See implementation. */
    if (tk == (TypeKind.TYPE_NAMED as i32)) {
      let nl: i32 = pipeline_type_named_name_into(arena, type_ref, buf);
      let si: i32 = 0;
      while (si < nl && si < buf_cap) {
        if (buf[si] == 46) { buf[si] = 95; }
        si = si + 1;
      }
      if (nl > 0 && nl < buf_cap) {
        return nl;
      }
      return 0;
    }
    /* See implementation. */
    if (tk == (TypeKind.TYPE_I32 as i32)) {
      let s: u8[4] = [105, 51, 50, 0];
      return emit_suffix_bytes(buf, &s[0], 3);
    }
    if (tk == (TypeKind.TYPE_I64 as i32)) {
      let s: u8[4] = [105, 54, 52, 0];
      return emit_suffix_bytes(buf, &s[0], 3);
    }
    if (tk == (TypeKind.TYPE_U8 as i32)) {
      let s: u8[3] = [117, 56, 0];
      return emit_suffix_bytes(buf, &s[0], 2);
    }
    if (tk == (TypeKind.TYPE_U32 as i32)) {
      let s: u8[4] = [117, 51, 50, 0];
      return emit_suffix_bytes(buf, &s[0], 3);
    }
    if (tk == (TypeKind.TYPE_U64 as i32)) {
      let s: u8[4] = [117, 54, 52, 0];
      return emit_suffix_bytes(buf, &s[0], 3);
    }
    if (tk == (TypeKind.TYPE_F32 as i32)) {
      let s: u8[4] = [102, 51, 50, 0];
      return emit_suffix_bytes(buf, &s[0], 3);
    }
    if (tk == (TypeKind.TYPE_F64 as i32)) {
      let s: u8[4] = [102, 54, 52, 0];
      return emit_suffix_bytes(buf, &s[0], 3);
    }
    /* TYPE_VECTOR: mangle suffix as <elem>x<lanes> (e.g. i32x4 / f32x4 / i32x8) so
     * same-name vector overloads (std_simd_add Vec8i vs Vec4f) get distinct C link
     * symbols. Without this, two vector overloads both emit a bare name and cc reports
     * "conflicting types". PLATFORM: SHARED — mirrors emit_vector_c_type_out spelling. */
    if (tk == (TypeKind.TYPE_VECTOR as i32)) {
      let elem_ref: i32 = pipeline_type_elem_ref_at(arena, type_ref);
      let lanes: i32 = pipeline_type_array_size_at(arena, type_ref);
      let ek: i32 = 0;
      let pos: i32 = 0;
      if (elem_ref <= 0 || lanes <= 0) {
        return 0;
      }
      ek = pipeline_type_kind_ord_at(arena, elem_ref);
      /* element prefix: i32->"i32", u32->"u32", f32->"f32" */
      if (ek == (TypeKind.TYPE_I32 as i32)) {
        let pre: u8[4] = [105, 51, 50, 0];
        pos = emit_suffix_bytes(buf, &pre[0], 3);
      } else if (ek == (TypeKind.TYPE_U32 as i32)) {
        let pre: u8[4] = [117, 51, 50, 0];
        pos = emit_suffix_bytes(buf, &pre[0], 3);
      } else if (ek == (TypeKind.TYPE_F32 as i32)) {
        let pre: u8[4] = [102, 51, 50, 0];
        pos = emit_suffix_bytes(buf, &pre[0], 3);
      } else {
        return 0;
      }
      if (pos <= 0) {
        return 0;
      }
      /* 'x' separator */
      if (pos < buf_cap) {
        buf[pos] = 120;
        pos = pos + 1;
      } else {
        return pos;
      }
      /* lanes decimal: 4 / 8 / 16 */
      if (lanes == 4 && pos < buf_cap) {
        buf[pos] = 52;
        return pos + 1;
      } else if (lanes == 8 && pos < buf_cap) {
        buf[pos] = 56;
        return pos + 1;
      } else if (lanes == 16 && pos + 1 < buf_cap) {
        buf[pos] = 49;
        buf[pos + 1] = 54;
        return pos + 2;
      }
      return pos;
    }
    if (tk == (TypeKind.TYPE_BOOL as i32)) {
      let s: u8[5] = [98, 111, 111, 108, 0];
      return emit_suffix_bytes(buf, &s[0], 4);
    }
    if (tk == (TypeKind.TYPE_USIZE as i32)) {
      let s: u8[6] = [117, 115, 105, 122, 101, 0];
      return emit_suffix_bytes(buf, &s[0], 5);
    }
    if (tk == (TypeKind.TYPE_ISIZE as i32)) {
      let s: u8[6] = [105, 115, 105, 122, 101, 0];
      return emit_suffix_bytes(buf, &s[0], 5);
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_module_func_overload_count(module: *Module, name_ptr: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let c: i32 = 0;
    if (module == 0 as *Module || name_ptr == 0 as *u8 || name_len <= 0) {
      return 0;
    }
    let i: i32 = 0;
    while (i < module.num_funcs) {
      let fn_len: i32 = pipeline_module_func_name_len_at(module, i);
      if (fn_len == name_len && fn_len > 0) {
        let fn_name: u8[64] = [];
        let matched: i32 = 1;
        let bi: i32 = 0;
        pipeline_module_func_name_copy64(module, i, &fn_name[0]);
        while (bi < fn_len) {
          if (fn_name[bi] != name_ptr[bi]) {
            matched = 0;
            bi = fn_len;
          } else {
            bi = bi + 1;
          }
        }
        if (matched != 0) {
          c = c + 1;
        }
      }
      i = i + 1;
    }
    return c;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_func_param_sig_equal(arena: *ASTArena, mod_a: *Module, fi_a: i32, mod_b: *Module, fi_b: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let np_a: i32 = pipeline_module_func_num_params_at(mod_a, fi_a);
    let np_b: i32 = pipeline_module_func_num_params_at(mod_b, fi_b);
    if (np_a != np_b) {
      return 0;
    }
    let pi: i32 = 0;
    while (pi < np_a) {
      let sa: u8[64] = [];
      let sb: u8[64] = [];
      let na: i32 = codegen_type_ref_to_suffix(arena, pipeline_module_func_param_type_ref_at(mod_a, fi_a, pi), &sa[0], 64);
      let nb: i32 = codegen_type_ref_to_suffix(arena, pipeline_module_func_param_type_ref_at(mod_b, fi_b, pi), &sb[0], 64);
      if (na != nb) {
        return 0;
      }
      let k: i32 = 0;
      while (k < na) {
        if (sa[k] != sb[k]) {
          return 0;
        }
        k = k + 1;
      }
      pi = pi + 1;
    }
    return 1;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_module_overload_param_sig_count(arena: *ASTArena, module: *Module, fi: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let c: i32 = 0;
    if (module == 0 as *Module || fi < 0 || fi >= module.num_funcs) {
      return 0;
    }
    let fn_local: u8[64] = [];
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
    if (fn_len <= 0) {
      return 0;
    }
    let i: i32 = 0;
    while (i < module.num_funcs) {
      let g_len: i32 = pipeline_module_func_name_len_at(module, i);
      if (g_len == fn_len && g_len > 0) {
        let g_name: u8[64] = [];
        let matched: i32 = 1;
        let bi: i32 = 0;
        pipeline_module_func_name_copy64(module, i, &g_name[0]);
        while (bi < g_len) {
          if (g_name[bi] != fn_local[bi]) {
            matched = 0;
            bi = g_len;
          } else {
            bi = bi + 1;
          }
        }
        if (matched != 0) {
          if (codegen_func_param_sig_equal(arena, module, fi, module, i) != 0) {
            c = c + 1;
          }
        }
      }
      i = i + 1;
    }
    return c;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_func_c_symbol_prefix_len(module: *Module, fi: i32, prefix_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (prefix_len <= 0) {
      return 0;
    }
    if (module != 0 as *Module && fi >= 0 && pipeline_module_func_is_no_mangle_at(module, fi) != 0) {
      return 0;
    }
    return prefix_len;
  }
}

/**
 * Emit the C link symbol for function fi: bare name, or mangled name_t1_t2 when overloaded.
 * Aligns with seed pin / historical codegen.c func_link_name. #[no_mangle] always bare.
 *
 * Why zero-init + assign (not let x = f(name)): product pin X→C hoists all `let` inits
 * to the top of the block. `let overload_count = count(fn_local, …)` ran before
 * codegen_copy_func_name64, so overload_count was always 0/1 and extern decls collided
 * (hello: core_fmt_fmt_scalar_to_buf / std_io_print unmangled).
 * PLATFORM: SHARED — definition / extern decl / CALL must all call this helper.
 */
export function codegen_emit_func_link_name(out: *CodegenOutBuf, arena: *ASTArena, module: *Module, fi: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    /* Hoist-safe: zero locals first; fill via statements after the early-return gate. */
    let fn_local: u8[64] = [];
    let fn_len: i32 = 0;
    let overload_count: i32 = 0;
    let np: i32 = 0;
    let pi: i32 = 0;
    let sig_count: i32 = 0;
    if (module == 0 as *Module || fi < 0 || fi >= module.num_funcs) {
      return -1;
    }
    fn_len = pipeline_module_func_name_len_at(module, fi);
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    if (fn_len <= 0) {
      return -1;
    }
    /* See implementation. */
    if (pipeline_module_func_is_no_mangle_at(module, fi) != 0) {
      return emit_bytes_64(out, &fn_local[0], fn_len);
    }
    /* Count overloads only after name is copied (let-hoist safe). */
    overload_count = codegen_module_func_overload_count(module, &fn_local[0], fn_len);
    if (overload_count <= 1) {
      return emit_bytes_64(out, &fn_local[0], fn_len);
    }
    /* See implementation. */
    if (emit_bytes_64(out, &fn_local[0], fn_len) != 0) {
      return -1;
    }
    np = pipeline_module_func_num_params_at(module, fi);
    pi = 0;
    while (pi < np) {
      let suf: u8[64] = [];
      let param_ty: i32 = pipeline_module_func_param_type_ref_at(module, fi, pi);
      /*
       * PLATFORM: SHARED — param type_ref is indexed in the function's module arena.
       * Callers must pass that arena; if null/wrong, suffix is empty → bare free
       * (Ubuntu multi-import heap.free). Prefer non-null arena; never silent bare mangle.
       */
      let sl: i32 = 0;
      if (arena != 0 as *ASTArena) {
        sl = codegen_type_ref_to_suffix(arena, param_ty, &suf[0], 64);
      }
      if (sl > 0) {
        if (append_byte(out, 95) != 0) {
          return -1;
        }
        if (emit_bytes_from_ptr(out, &suf[0], sl) != 0) {
          return -1;
        }
      }
      pi = pi + 1;
    }
    /* See implementation. */
    sig_count = codegen_module_overload_param_sig_count(arena, module, fi);
    if (sig_count > 1) {
      let ret_ref: i32 = pipeline_module_func_return_type_at(module, fi);
      let rs: u8[64] = [];
      let rsl: i32 = codegen_type_ref_to_suffix(arena, ret_ref, &rs[0], 64);
      if (rsl > 0) {
        /* "_ret_" */
        let ret_kw: u8[5] = [95, 114, 101, 116, 0];
        if (emit_bytes_from_ptr(out, &ret_kw[0], 4) != 0) {
          return -1;
        }
        if (emit_bytes_from_ptr(out, &rs[0], rsl) != 0) {
          return -1;
        }
      }
    }
    return 0;
  }
}

/**
 * True when `name` is a local binding that must stay bare in C (param / let / const).
 * Used so EXPR_VAR fn-as-value only mangles real function values, not locals that
 * happen to share a name with a module function.
 * @param arena *ASTArena — active emit arena (block let/const pool)
 * @param ctx *PipelineDepCtx — current_func_index + current_block_ref + module
 * @param name *u8 — identifier bytes
 * @param name_len i32 — byte length; <=0 → not local
 * @return i32 — 1 if param/let/const matches; 0 otherwise
 * PLATFORM: SHARED — scope scan for emit; not a second typeck.
 */
export function codegen_name_is_local_binding(arena: *ASTArena, ctx: *PipelineDepCtx, name: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || ctx == 0 as *PipelineDepCtx || name == 0 as *u8 || name_len <= 0) {
      return 0;
    }
    let mod: *Module = ctx.current_codegen_module;
    // Current function params shadow free functions for bare identifiers.
    if (mod != 0 as *Module && ctx.current_func_index >= 0 && ctx.current_func_index < mod.num_funcs) {
      let fi: i32 = ctx.current_func_index;
      let np: i32 = pipeline_module_func_num_params_at(mod, fi);
      let pi: i32 = 0;
      while (pi < np) {
        let pl: i32 = pipeline_module_func_param_name_len_at(mod, fi, pi);
        if (pl == name_len && pl > 0) {
          let pb: u8[32] = [];
          let ok: i32 = 1;
          let j: i32 = 0;
          pipeline_module_func_param_name_copy32(mod, fi, pi, &pb[0]);
          while (j < pl) {
            if (pb[j] != name[j]) {
              ok = 0;
              j = pl;
            } else {
              j = j + 1;
            }
          }
          if (ok != 0) {
            return 1;
          }
        }
        pi = pi + 1;
      }
    }
    // Current block lets / consts (shallow: emit uses current_block_ref).
    if (ctx.current_block_ref > 0 && ctx.current_block_ref <= arena.num_blocks) {
      let br: i32 = ctx.current_block_ref;
      let li: i32 = 0;
      let nlets: i32 = ast.ast_block_num_lets(arena, br);
      while (li < nlets) {
        let nl: i32 = pipeline_block_let_name_len(arena, br, li);
        if (nl == name_len && nl > 0) {
          let nb: u8[64] = [];
          let ok2: i32 = 1;
          let j2: i32 = 0;
          pipeline_block_let_name_copy64(arena, br, li, &nb[0]);
          while (j2 < nl) {
            if (nb[j2] != name[j2]) {
              ok2 = 0;
              j2 = nl;
            } else {
              j2 = j2 + 1;
            }
          }
          if (ok2 != 0) {
            return 1;
          }
        }
        li = li + 1;
      }
      let ci: i32 = 0;
      let nconsts: i32 = ast.ast_block_num_consts(arena, br);
      while (ci < nconsts) {
        let cl: i32 = pipeline_block_const_name_len(arena, br, ci);
        if (cl == name_len && cl > 0) {
          let cb: u8[64] = [];
          let ok3: i32 = 1;
          let j3: i32 = 0;
          pipeline_block_const_name_copy64(arena, br, ci, &cb[0]);
          while (j3 < cl) {
            if (cb[j3] != name[j3]) {
              ok3 = 0;
              j3 = cl;
            } else {
              j3 = j3 + 1;
            }
          }
          if (ok3 != 0) {
            return 1;
          }
        }
        ci = ci + 1;
      }
    }
    return 0;
  }
}

/**
 * Emit C symbol for EXPR_VAR that names a same-module function value (fn-as-value).
 * G.7 single path: same module prefix + codegen_emit_func_link_name as def/call/extern.
 * wave101 soft residual: non-#[no_mangle] `(f as *u8)` must not emit bare source name
 * (def is prefix_f / overload-mangled → undeclared C identifier).
 * @param out *CodegenOutBuf — C text sink
 * @param arena *ASTArena — module arena for overload suffixes
 * @param ctx *PipelineDepCtx — current_codegen_module + prefix mirror
 * @param name *u8 — bare source identifier
 * @param name_len i32 — length
 * @return i32 — 0 emitted function link; 1 not a free function (caller emits bare);
 *               -1 emit error
 * PLATFORM: SHARED — link-name contract; verify mac + Ubuntu.
 */
export function codegen_try_emit_fn_as_value(out: *CodegenOutBuf, arena: *ASTArena, ctx: *PipelineDepCtx, name: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (out == 0 as *CodegenOutBuf || name == 0 as *u8 || name_len <= 0) {
      return 1;
    }
    if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
      return 1;
    }
    if (codegen_name_is_local_binding(arena, ctx, name, name_len) != 0) {
      return 1;
    }
    let mod: *Module = ctx.current_codegen_module;
    let fi: i32 = codegen_find_module_func_index_by_name(mod, name, name_len);
    if (fi < 0) {
      return 1;
    }
    // Same-module value: emit arena is the function module arena (no forward dep on
    // codegen_arena_for_module — defined later in this TU).
    // Module C prefix (entry stem / import path) unless #[no_mangle].
    let pre_len: i32 = ctx.current_codegen_prefix_len;
    let sym_pre: i32 = codegen_func_c_symbol_prefix_len(mod, fi, pre_len);
    if (sym_pre > 0) {
      if (codegen_c_prefix_redundant_with_name(&ctx.current_codegen_prefix_mirror[0], sym_pre, name, name_len) == 0) {
        if (emit_bytes_from_ptr(out, &ctx.current_codegen_prefix_mirror[0], sym_pre) != 0) {
          return 0 - 1;
        }
      }
    }
    if (codegen_emit_func_link_name(out, arena, mod, fi) != 0) {
      return 0 - 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_arena_for_module(ctx: *PipelineDepCtx, module: *Module, fallback: *ASTArena): *ASTArena {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || module == 0 as *Module) {
      return fallback;
    }
    let di: i32 = 0;
    let nd: i32 = pipeline_dep_ctx_ndep(ctx);
    while (di < nd) {
      if (pipeline_dep_ctx_module_at(ctx, di) == module) {
        let da: *ASTArena = pipeline_dep_ctx_arena_at(ctx, di);
        if (da != 0 as *ASTArena) {
          return da;
        }
        return fallback;
      }
      di = di + 1;
    }
    return fallback;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_emit_call_func_name(out: *CodegenOutBuf, arena: *ASTArena, ctx: *PipelineDepCtx, expr_ref: i32, current_module: *Module, fallback_name: *u8, fallback_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx != 0 as *PipelineDepCtx && arena != 0 as *ASTArena) {
      let func_ix: i32 = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
      let dep_ix: i32 = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
      let call_e0: Expr = ast.ast_arena_expr_get(arena, expr_ref);
      let is_m0: i32 = 0;
      if (call_e0.kind == ExprKind.EXPR_METHOD_CALL) {
        is_m0 = 1;
      }
      let nargs0: i32 = 0;
      if (is_m0 != 0) {
        nargs0 = call_e0.method_call_num_args;
      } else {
        nargs0 = call_e0.call_num_args;
      }
      /* See implementation. */
      if (func_ix >= 0) {
        let res_mod: *Module = 0 as *Module;
        if (dep_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx)) {
          res_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
        } else {
          res_mod = current_module;
        }
        if (res_mod != 0 as *Module && func_ix < res_mod.num_funcs) {
          let ok_res: i32 = 1;
          if (pipeline_module_func_num_params_at(res_mod, func_ix) != nargs0) {
            ok_res = 0;
          }
          if (ok_res != 0 && fallback_len > 0) {
            let rlen: i32 = pipeline_module_func_name_len_at(res_mod, func_ix);
            if (rlen != fallback_len) {
              ok_res = 0;
            } else {
              let rnm: u8[64] = [];
              pipeline_module_func_name_copy64(res_mod, func_ix, &rnm[0]);
              let ri: i32 = 0;
              while (ri < rlen) {
                if (rnm[ri] != fallback_name[ri]) {
                  ok_res = 0;
                  ri = rlen;
                } else {
                  ri = ri + 1;
                }
              }
            }
          }
          /*
           * PLATFORM: SHARED — trust typeck call_resolved_func_index for overloads.
           * Typeck already scores args + expected return (let v: Vec_u8 = new() →
           * new_retVec_u8). Rejecting all overloads here forced re-search that lost
           * the return-type pick and emitted bare std_vec_new() while defs used _ret_.
           * Keep arity/name checks above; only cross-module resolved still rejected below.
           */
          /*
           * PLATFORM: SHARED — when METHOD_CALL fallback passes binding current_module,
           * reject call_resolved that points at a different dep module (e.g. heap.free →
           * libc free after multi-import index confusion). Prefer re-search in binding.
           */
          if (ok_res != 0 && current_module != 0 as *Module && res_mod != current_module) {
            ok_res = 0;
          }
          if (ok_res != 0) {
            let res_arena: *ASTArena = codegen_arena_for_module(ctx, res_mod, arena);
            return codegen_emit_func_link_name(out, res_arena, res_mod, func_ix);
          }
        }
        func_ix = -1;
      }
      /*
       * Target module for re-search: prefer binding current_module when provided.
       * PLATFORM: SHARED — call_resolved dep_ix may point at a transitive dep after
       * multi-import closure (heap.free → libc free); binding module is the authority.
       */
      let search_mod: *Module = 0 as *Module;
      let search_arena: *ASTArena = arena;
      if (current_module != 0 as *Module) {
        search_mod = current_module;
        search_arena = codegen_arena_for_module(ctx, search_mod, arena);
      } else if (dep_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx)) {
        search_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
        search_arena = pipeline_dep_ctx_arena_at(ctx, dep_ix);
        if (search_arena == 0 as *ASTArena) {
          search_arena = arena;
        }
      } else {
        search_mod = current_module;
        search_arena = codegen_arena_for_module(ctx, search_mod, arena);
      }
      if (search_mod != 0 as *Module && fallback_len > 0) {
        let call_e: Expr = call_e0;
        let is_method: i32 = is_m0;
        let call_nargs: i32 = nargs0;
        let found_fi: i32 = -1;
        let found_count: i32 = 0;
        let fi_s: i32 = 0;
        while (fi_s < search_mod.num_funcs) {
          let fn_len: i32 = pipeline_module_func_name_len_at(search_mod, fi_s);
          if (fn_len == fallback_len && fn_len > 0) {
            let fn_name: u8[64] = [];
            pipeline_module_func_name_copy64(search_mod, fi_s, &fn_name[0]);
            let matched: i32 = 1;
            let bi: i32 = 0;
            while (bi < fn_len) {
              if (fn_name[bi] != fallback_name[bi]) {
                matched = 0;
                bi = fn_len;
              } else {
                bi = bi + 1;
              }
            }
            if (matched != 0) {
              let np: i32 = pipeline_module_func_num_params_at(search_mod, fi_s);
              if (np == call_nargs) {
                let types_match: i32 = 1;
                let pi: i32 = 0;
                while (pi < np && types_match != 0) {
                  let arg_ref: i32 = 0;
                  if (is_method != 0) {
                    arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, pi);
                  } else {
                    arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, pi);
                  }
                  if (ast.ref_is_null(arg_ref)) {
                    types_match = 0;
                  } else {
                    let arg_ty: i32 = pipeline_expr_resolved_type_ref(arena, arg_ref);
                    /*
                     * PLATFORM: SHARED — dep module bodies are not typeck'd, so param VAR
                     * args have resolved_type=0. When the arg is a VAR that names a param of
                     * the CURRENTLY emitted function, use that param's declared type as arg_ty.
                     * Without this, dot(a:Vec4f) { hsum(mul(a,b)); } emits Vec8i mul (first
                     * arity match) instead of Vec4f mul → cc "conflicting types".
                     */
                    if (arg_ty <= 0 && ctx != 0 as *PipelineDepCtx
                        && ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0
                        && pipeline_expr_kind_ord_at(arena, arg_ref) == 3) {
                      let av_len: i32 = pipeline_expr_var_name_len(arena, arg_ref);
                      if (av_len > 0 && av_len <= 63) {
                        let av_buf: u8[64] = [];
                        pipeline_expr_var_name_into(arena, arg_ref, &av_buf[0]);
                        let apt: i32 = pipeline_module_func_param_type_ref_for_name(
                            ctx.current_codegen_module, ctx.current_func_index, &av_buf[0], av_len);
                        if (apt > 0) {
                          arg_ty = apt;
                        }
                      }
                    }
                    /* See implementation. */
                    if (arg_ty <= 0 && pipeline_expr_kind_ord_at(arena, arg_ref) == 54) {
                      let as_tgt: i32 = pipeline_expr_as_target_type_ref_at(arena, arg_ref);
                      if (as_tgt > 0) {
                        arg_ty = as_tgt;
                      }
                    }
                    /* See implementation. */
                    let is_str_lit: i32 = 0;
                    if (arg_ty <= 0 && pipeline_expr_kind_ord_at(arena, arg_ref) == 59) {
                      is_str_lit = 1;
                    }
                    let param_ty: i32 = pipeline_module_func_param_type_ref_at(search_mod, fi_s, pi);
                    let sa: u8[64] = [];
                    let sb: u8[64] = [];
                    let na: i32 = 0;
                    let nb: i32 = 0;
                    /* See implementation. */
                    if (is_str_lit == 0 && arg_ty > 0
                        && pipeline_type_kind_ord_at(arena, arg_ty) == 10
                        && pipeline_type_kind_ord_at(search_arena, param_ty) == 9) {
                      let ae: i32 = pipeline_type_elem_ref_at(arena, arg_ty);
                      let pe: i32 = pipeline_type_elem_ref_at(search_arena, param_ty);
                      na = codegen_type_ref_to_suffix(arena, ae, &sa[0], 64);
                      nb = codegen_type_ref_to_suffix(search_arena, pe, &sb[0], 64);
                    } else if (is_str_lit != 0) {
                      sa[0] = 117;
                      sa[1] = 56;
                      sa[2] = 95;
                      sa[3] = 112;
                      sa[4] = 116;
                      sa[5] = 114;
                      na = 6;
                      nb = codegen_type_ref_to_suffix(search_arena, param_ty, &sb[0], 64);
                    } else {
                      na = codegen_type_ref_to_suffix(arena, arg_ty, &sa[0], 64);
                      nb = codegen_type_ref_to_suffix(search_arena, param_ty, &sb[0], 64);
                    }
                    if (na != nb) {
                      types_match = 0;
                    } else {
                      if (na <= 0) {
                        types_match = 0;
                      } else {
                        let k: i32 = 0;
                        while (k < na) {
                          if (sa[k] != sb[k]) {
                            types_match = 0;
                            k = na;
                          } else {
                            k = k + 1;
                          }
                        }
                      }
                    }
                  }
                  pi = pi + 1;
                }
                if (types_match != 0) {
                  found_fi = fi_s;
                  found_count = found_count + 1;
                }
              }
            }
          }
          fi_s = fi_s + 1;
        }
        if (found_count == 1 && found_fi >= 0) {
          return codegen_emit_func_link_name(out, search_arena, search_mod, found_fi);
        }
        /*
         * PLATFORM: SHARED — PTR overload (heap.free *u8 vs *i32): suffix compare can
         * fail across arenas; fall back to kind+elem kind match so we never emit bare free.
         */
        if (found_count != 1 && call_nargs == 1 && is_method != 0 && search_mod != 0 as *Module) {
          let arg0: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, 0);
          let arg0_ty: i32 = 0;
          if (arg0 > 0) {
            arg0_ty = pipeline_expr_resolved_type_ref(arena, arg0);
          }
          if (arg0_ty > 0 && pipeline_type_kind_ord_at(arena, arg0_ty) == 9) {
            let ae_k: i32 = 0;
            let ae: i32 = pipeline_type_elem_ref_at(arena, arg0_ty);
            if (ae > 0) {
              ae_k = pipeline_type_kind_ord_at(arena, ae);
            }
            let fi_p: i32 = 0;
            let best_p: i32 = -1;
            let n_p: i32 = 0;
            while (fi_p < search_mod.num_funcs) {
              let fl: i32 = pipeline_module_func_name_len_at(search_mod, fi_p);
              if (fl == fallback_len && fl > 0 && pipeline_module_func_num_params_at(search_mod, fi_p) == 1) {
                let fnm_p: u8[64] = [];
                pipeline_module_func_name_copy64(search_mod, fi_p, &fnm_p[0]);
                let me: i32 = 1;
                let bi: i32 = 0;
                while (bi < fl) {
                  if (fnm_p[bi] != fallback_name[bi]) {
                    me = 0;
                    bi = fl;
                  } else {
                    bi = bi + 1;
                  }
                }
                if (me != 0) {
                  let pt: i32 = pipeline_module_func_param_type_ref_at(search_mod, fi_p, 0);
                  if (pt > 0 && pipeline_type_kind_ord_at(search_arena, pt) == 9) {
                    let pe: i32 = pipeline_type_elem_ref_at(search_arena, pt);
                    if (pe > 0 && pipeline_type_kind_ord_at(search_arena, pe) == ae_k) {
                      best_p = fi_p;
                      n_p = n_p + 1;
                    }
                  }
                }
              }
              fi_p = fi_p + 1;
            }
            if (n_p == 1 && best_p >= 0) {
              return codegen_emit_func_link_name(out, search_arena, search_mod, best_p);
            }
          }
        }
        /* See implementation. */
        if (found_count != 1 && call_nargs >= 0) {
          let arity_fi: i32 = -1;
          let arity_count: i32 = 0;
          let ext_fi: i32 = -1;
          let ext_count: i32 = 0;
          let fi_a: i32 = 0;
          while (fi_a < search_mod.num_funcs) {
            let fn_len_a: i32 = pipeline_module_func_name_len_at(search_mod, fi_a);
            if (fn_len_a == fallback_len && fn_len_a > 0) {
              let fn_name_a: u8[64] = [];
              pipeline_module_func_name_copy64(search_mod, fi_a, &fn_name_a[0]);
              let matched_a: i32 = 1;
              let bi_a: i32 = 0;
              while (bi_a < fn_len_a) {
                if (fn_name_a[bi_a] != fallback_name[bi_a]) {
                  matched_a = 0;
                  bi_a = fn_len_a;
                } else {
                  bi_a = bi_a + 1;
                }
              }
              if (matched_a != 0) {
                let np_a: i32 = pipeline_module_func_num_params_at(search_mod, fi_a);
                if (np_a == call_nargs) {
                  arity_fi = fi_a;
                  arity_count = arity_count + 1;
                  if (pipeline_module_func_is_extern_at(search_mod, fi_a) != 0 || pipeline_module_func_is_no_mangle_at(search_mod, fi_a) != 0) {
                    ext_fi = fi_a;
                    ext_count = ext_count + 1;
                  }
                }
              }
            }
            fi_a = fi_a + 1;
          }
          if (ext_count == 1 && ext_fi >= 0) {
            return codegen_emit_func_link_name(out, search_arena, search_mod, ext_fi);
          }
          if (arity_count == 1 && arity_fi >= 0) {
            return codegen_emit_func_link_name(out, search_arena, search_mod, arity_fi);
          }
        }
      }
    }
    /* See implementation. */
    if (ctx != 0 as *PipelineDepCtx && fallback_len > 0 && arena != 0 as *ASTArena) {
      let mc_e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
      let mc_nargs: i32 = 0;
      if (mc_e.kind == ExprKind.EXPR_METHOD_CALL) {
        mc_nargs = mc_e.method_call_num_args;
      } else {
        mc_nargs = mc_e.call_num_args;
      }
      let dep_di: i32 = 0;
      let nd: i32 = pipeline_dep_ctx_ndep(ctx);
      while (dep_di < nd) {
        let dm: *Module = pipeline_dep_ctx_module_at(ctx, dep_di);
        let da: *ASTArena = pipeline_dep_ctx_arena_at(ctx, dep_di);
        if (dm != 0 as *Module && da != 0 as *ASTArena) {
          let fi_x: i32 = 0;
          let found_x: i32 = -1;
          while (fi_x < dm.num_funcs) {
            let fn_x: i32 = pipeline_module_func_name_len_at(dm, fi_x);
            if (fn_x == fallback_len && fn_x > 0) {
              let fnm: u8[64] = [];
              pipeline_module_func_name_copy64(dm, fi_x, &fnm[0]);
              let mx: i32 = 1;
              let bx: i32 = 0;
              while (bx < fn_x) {
                if (fnm[bx] != fallback_name[bx]) {
                  mx = 0;
                  bx = fn_x;
                } else {
                  bx = bx + 1;
                }
              }
              if (mx != 0 && pipeline_module_func_num_params_at(dm, fi_x) == mc_nargs) {
                found_x = fi_x;
                fi_x = dm.num_funcs;
              } else {
                fi_x = fi_x + 1;
              }
            } else {
              fi_x = fi_x + 1;
            }
          }
          if (found_x >= 0) {
            return codegen_emit_func_link_name(out, da, dm, found_x);
          }
        }
        dep_di = dep_di + 1;
      }
    }
    /* See implementation. */
    return emit_bytes_from_ptr(out, fallback_name, fallback_len);
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_copy_func_name64_from_module(module: *Module, fi: i32, dst: *u8): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    pipeline_module_func_name_copy64(module, fi, dst);
  }
}

/**
 * See implementation.
 */
export function codegen_copy_param_name32_from_module(module: *Module, fi: i32, pi: i32, dst: *u8): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    pipeline_module_func_param_name_copy32(module, fi, pi, dst);
  }
}

/**
 * Emit one function: return type + name + (params) + { body }.
 * When call_init_globals != 0 and is_entry main, body starts with init_globals();
 *
 * Why name_is_main is assigned after copy (not `let x = name_eq`): pin X→C hoists
 * all let inits to block top, so `let name_is_main = (fn_local[0]=='m'…)` ran on a
 * still-zero buffer → never emitted C `main` (rv matrix: undefined _main).
 * PLATFORM: SHARED — entry main symbol contract.
 */
/**
 * True if this block (or nested region bodies, e.g. Cap-T001 `unsafe { return … }`)
 * contains a return statement or a final expression (treated as the function return path).
 *
 * Purpose: emit_func fallback `return 0` must not fire when the only return lives inside
 * an unsafe/region body — otherwise by-value struct functions get illegal `return 0`.
 * Parameters: arena + block_ref (1-based pool ref); null/invalid → 0.
 * Returns: 1 if a return path is present, 0 otherwise.
 * PLATFORM: SHARED — C TU ordering / host-cc; seed pin same commit.
 */
export function codegen_block_contains_return(arena: *ASTArena, block_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || ast.ref_is_null(block_ref)) {
      return 0;
    }
    /* final_expr on the block is the implicit return path for expression-bodied blocks. */
    if (!ast.ref_is_null(ast.ast_block_final_expr_ref(arena, block_ref))) {
      return 1;
    }
    let ji: i32 = 0;
    let nes: i32 = ast.ast_block_num_expr_stmts(arena, block_ref);
    while (ji < nes) {
      let se: Expr = ast.ast_arena_expr_get(arena, ast.ast_block_expr_stmt_ref(arena, block_ref, ji));
      if (se.kind == ExprKind.EXPR_RETURN) {
        return 1;
      }
      ji = ji + 1;
    }
    /* Cap-T001: return often sits only inside unsafe / region body blocks. */
    let ri: i32 = 0;
    let nr: i32 = ast.ast_block_num_regions(arena, block_ref);
    while (ri < nr) {
      let rb: i32 = ast.ast_block_region_body_ref(arena, block_ref, ri);
      if (codegen_block_contains_return(arena, rb) != 0) {
        return 1;
      }
      ri = ri + 1;
    }
    return 0;
  }
}

/** Exported function `emit_func`.
 * Implements `emit_func`.
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param module *Module
 * @param fi i32
 * @param is_entry bool
 * @param prefix *u8
 * @param prefix_len i32
 * @param ctx *PipelineDepCtx
 * @param call_init_globals i32
 * @return i32
 */
export function emit_func(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, is_entry: bool, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx, call_init_globals: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    /* Hoist-safe name locals: fill via statements before any name-dependent test. */
    let fn_local: u8[64] = [];
    let fn_len: i32 = 0;
    let name_is_main: bool = false;
    let force_entry_main: bool = false;
    let emit_c_main_symbol: bool = false;
    let main_name: u8[4] = [109, 97, 105, 110];
    /* See implementation. */
    if (fi < 0 || fi >= module.num_funcs) {
      return -1;
    }
    fn_len = pipeline_module_func_name_len_at(module, fi);
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    /* See implementation. */
    if (pipeline_module_func_is_used_at(module, fi) != 0) {
      let used_attr: u8[27] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 115, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0];
      if (emit_bytes_from_ptr(out, &used_attr[0], 22) != 0) { return -1; }
    }
    /* See implementation. */
    if (pipeline_module_func_is_naked_at(module, fi) != 0) {
      let naked_attr: u8[29] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 97, 107, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0, 0];
      if (emit_bytes_from_ptr(out, &naked_attr[0], 23) != 0) { return -1; }
    }
    /* See implementation. */
    if (pipeline_module_func_is_entry_at(module, fi) != 0) {
      let entry_attr: u8[30] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 111, 114, 101, 116, 117, 114, 110, 41, 41, 32, 0, 0, 0, 0];
      if (emit_bytes_from_ptr(out, &entry_attr[0], 26) != 0) { return -1; }
    }
    /* See implementation. */
    if (pipeline_module_func_is_interrupt_at(module, fi) != 0) {
      let int_attr: u8[31] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 105, 110, 116, 101, 114, 114, 117, 112, 116, 41, 41, 32, 0, 0, 0, 0];
      if (emit_bytes_from_ptr(out, &int_attr[0], 27) != 0) { return -1; }
    }
    /*
     * Emit C symbol "main" only when the function name is the four bytes main.
     * Assign name_is_main after copy (let-hoist safe) — see function docblock.
     * Single-function entry with empty name still forces main (bootstrap path).
     * Do not write (is_entry && a) || b — X→C may drop parens.
     * Must compute emit_c_main_symbol before return-type emit: void main becomes
     * C int32_t main (Zig-like implicit exit 0), not host `void main`.
     */
    if (fn_len == 4 && fn_local[0] == 109 && fn_local[1] == 97 && fn_local[2] == 105 && fn_local[3] == 110) {
      name_is_main = true;
    }
    if (is_entry && module.num_funcs == 1) {
      if (fn_len <= 0) {
        force_entry_main = true;
      }
      if (fn_local[0] == 0) {
        force_entry_main = true;
      }
    }
    if (is_entry) {
      if (name_is_main) {
        emit_c_main_symbol = true;
      }
    }
    if (force_entry_main) {
      emit_c_main_symbol = true;
    }
    /* PLATFORM: SHARED — process entry ABI: void main → int32_t main + exit 0. */
    let ret_ty_ref: i32 = pipeline_module_func_return_type_at(module, fi);
    let fn_ret_void_pre: bool = pipeline_type_kind_ord_at(arena, ret_ty_ref) == (TypeKind.TYPE_VOID as i32);
    if (emit_c_main_symbol && fn_ret_void_pre) {
      let i32_ty: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
      if (emit_bytes_8(out, i32_ty, 7) != 0) {
        return -1;
      }
    } else if (emit_type(arena, out, ret_ty_ref, prefix, prefix_len, ctx) != 0) {
      return -1;
    }
    if (append_byte(out, 32) != 0) {
      return -1;
    }
    if (emit_c_main_symbol) {
      if (emit_bytes_4(out, main_name, 4) != 0) {
        return -1;
      }
    } else {
      /* See implementation. */
      let sym_pre: i32 = codegen_func_c_symbol_prefix_len(module, fi, prefix_len);
      if (sym_pre > 0 && codegen_c_prefix_redundant_with_name(prefix, sym_pre, &fn_local[0], fn_len) == 0 && emit_bytes_from_ptr(out, prefix, sym_pre) != 0) {
        return -1;
      }
      /* See implementation. */
      if (codegen_emit_func_link_name(out, arena, module, fi) != 0) {
        return -1;
      }
      if (codegen_std_io_fixed_fd_emit_impl(prefix, prefix_len, &fn_local[0], fn_len) != 0) {
        let impl_suffix: u8[6] = [95, 105, 109, 112, 108, 0];
        if (emit_bytes_from_ptr(out, &impl_suffix[0], 5) != 0) {
          return -1;
        }
      }
    }
    let lpar: u8[2] = [40, 0];
    if (emit_bytes_2(out, lpar, 1) != 0) {
      return -1;
    }
    if (pipeline_module_func_num_params_at(module, fi) == 0) {
      let v: u8[7] = [118, 111, 105, 100, 0, 0, 0];
      if (emit_bytes_7(out, v, 4) != 0) {
        return -1;
      }
    } else {
      let p: i32 = 0;
      while (p < pipeline_module_func_num_params_at(module, fi)) {
        if (p > 0) {
          let comma: u8[3] = [44, 32, 0];
          if (emit_bytes_3(out, comma, 2) != 0) {
            return -1;
          }
        }
        /* See implementation. */
        if (codegen_force_param_size_t_std_io_print_str_second(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let size_t_ps: u8[32] = [115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          if (emit_bytes_32(out, size_t_ps, 7) != 0) {
            return -1;
          }
        } else if (codegen_force_param_size_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let size_t_buf: u8[32] = [115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          if (emit_bytes_32(out, size_t_buf, 7) != 0) {
            return -1;
          }
        } else if (codegen_force_param_ptrdiff_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let ptrdiff_t_buf: u8[32] = [112, 116, 114, 100, 105, 102, 102, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          if (emit_bytes_32(out, ptrdiff_t_buf, 10) != 0) {
            return -1;
          }
        } else if (codegen_force_param_uint32_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let u32_buf: u8[32] = [117, 105, 110, 116, 51, 50, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          if (emit_bytes_32(out, u32_buf, 9) != 0) {
            return -1;
          }
        } else if (codegen_force_param_i32(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let i32_str: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
          if (emit_bytes_8(out, i32_str, 7) != 0) {
            return -1;
          }
        } else if (emit_type(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p), prefix, prefix_len, ctx) != 0) {
          return -1;
        }
        /* PLATFORM: SHARED — lower TYPE_SLICE params as pointers (seed/glue ABI).
         * Why: Cap by-value slice + pointer glue → SIGSEGV (string bytes as ptr).
         * Emit: `struct xlang_slice_T * name` so field access uses -> and calls pass &local. */
        if (pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) == (TypeKind.TYPE_SLICE as i32)) {
          if (append_byte(out, 32) != 0) {
            return -1;
          }
          if (append_byte(out, 42) != 0) {
            return -1;
          }
        }
        if (append_byte(out, 32) != 0) {
          return -1;
        }
        /* See implementation. */
        if (pipeline_module_func_param_name_len_at(module, fi, p) > 0) {
          let plocal: u8[32] = [];
          codegen_copy_param_name32_from_module(module, fi, p, &plocal[0]);
          if (plocal[0] > 32 && emit_bytes_32(out, plocal, pipeline_module_func_param_name_len_at(module, fi, p)) != 0) {
            return -1;
          }
        } else {
          let place: u8[4] = [95, 112, 48, 0];
          if (emit_bytes_4(out, place, 2) != 0) {
            return -1;
          }
          if (format_int(out, p) != 0) {
            return -1;
          }
        }
        p = p + 1;
      }
    }
    let rpar: u8[3] = [41, 32, 0];
    if (emit_bytes_3(out, rpar, 2) != 0) {
      return -1;
    }
    let brace: u8[3] = [123, 10, 0];
    if (emit_bytes_3(out, brace, 2) != 0) {
      return -1;
    }
    /* See implementation. */
    if (codegen_try_emit_std_io_driver_buf_body(out, module, fi, prefix, prefix_len) != 0) {
      return 0;
    }
    /* See implementation. */
    let fn_ret_void: bool = pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, fi)) == (TypeKind.TYPE_VOID as i32);
    /* See implementation. */
    if (call_init_globals != 0) {
      if (is_entry) {
        if (emit_c_main_symbol) {
          if (emit_indent(out, 2) != 0) {
            return -1;
          }
          let init_globals_call: u8[22] = [105, 110, 105, 116, 95, 103, 108, 111, 98, 97, 108, 115, 40, 41, 59, 10, 0, 0, 0, 0, 0, 0];
          if (emit_bytes_from_ptr(out, &init_globals_call[0], 16) != 0) {
            return -1;
          }
        }
      }
    }
    /* See implementation. */
    let saved_empty: i32 = -1;
    let saved_count: i32 = 0;
    let saved_next: i32 = 0;
    if (ctx != 0 as *PipelineDepCtx) {
      pipeline_dep_ctx_empty_param_backup(ctx);
      saved_empty = ctx.current_func_single_empty_param_index;
      saved_count = ctx.current_func_empty_param_count;
      saved_next = ctx.current_emit_empty_var_next_index;
      let empty_count: i32 = 0;
      let empty_idx: i32 = -1;
      let pi: i32 = 0;
      while (pi < pipeline_module_func_num_params_at(module, fi)) {
        if (pipeline_module_func_param_name_len_at(module, fi, pi) <= 0) {
          empty_count = empty_count + 1;
          empty_idx = pi;
        }
        pi = pi + 1;
      }
      if (empty_count == 1) {
        ctx.current_func_single_empty_param_index = empty_idx;
        ctx.current_func_empty_param_count = 0;
        ctx.current_emit_empty_var_next_index = 0;
      } else if (empty_count >= 2) {
        ctx.current_func_single_empty_param_index = -1;
        pipeline_dep_ctx_empty_param_reset(ctx);
        ctx.current_func_empty_param_count = empty_count;
        let ei: i32 = 0;
        pi = 0;
        while (pi < pipeline_module_func_num_params_at(module, fi)) {
          if (pipeline_module_func_param_name_len_at(module, fi, pi) <= 0) {
            pipeline_dep_ctx_empty_param_append(ctx, pi);
            ei = ei + 1;
          }
          pi = pi + 1;
        }
        ctx.current_emit_empty_var_next_index = 0;
      } else {
        ctx.current_func_single_empty_param_index = -1;
        ctx.current_func_empty_param_count = 0;
        ctx.current_emit_empty_var_next_index = 0;
      }
    }
    if (!ast.ref_is_null(pipeline_module_func_body_ref_at(module, fi))) {
      let saved_block: i32 = 0;
      if (ctx != 0 as *PipelineDepCtx) {
        saved_block = ctx.current_block_ref;
        ctx.current_block_ref = pipeline_module_func_body_ref_at(module, fi);
      }
      if (emit_block(arena, out, pipeline_module_func_body_ref_at(module, fi), 2, ctx) != 0) {
        if (ctx != 0 as *PipelineDepCtx) {
          ctx.current_block_ref = saved_block;
        }
        return -1;
      }
      if (ctx != 0 as *PipelineDepCtx) {
        ctx.current_block_ref = saved_block;
      }
    } else if (!ast.ref_is_null(pipeline_module_func_body_expr_ref_at(module, fi))) {
      /* See implementation. */
      if (fn_ret_void) {
        if (emit_indent(out, 2) != 0) {
          return -1;
        }
        if (emit_expr(arena, out, pipeline_module_func_body_expr_ref_at(module, fi), ctx) != 0) {
          return -1;
        }
        if (append_byte(out, 59) != 0) {
          return -1;
        }
        if (append_byte(out, 10) != 0) {
          return -1;
        }
      } else {
        if (emit_indent(out, 2) != 0) {
          return -1;
        }
        let ret_keyword: u8[9] = [114, 101, 116, 117, 114, 110, 32, 0, 0];
        if (emit_bytes_9(out, ret_keyword, 7) != 0) {
          return -1;
        }
        /* See implementation. */
        let body_e: Expr = ast.ast_arena_expr_get(arena, pipeline_module_func_body_expr_ref_at(module, fi));
        if (body_e.kind == ExprKind.EXPR_RETURN) {
          if (!ast.ref_is_null(body_e.unary_operand_ref) && emit_expr(arena, out, body_e.unary_operand_ref, ctx) != 0) {
            return -1;
          }
        } else {
          if (emit_expr(arena, out, pipeline_module_func_body_expr_ref_at(module, fi), ctx) != 0) {
            return -1;
          }
        }
        if (append_byte(out, 59) != 0) {
          return -1;
        }
        if (append_byte(out, 10) != 0) {
          return -1;
        }
      }
    }
    if (ctx != 0 as *PipelineDepCtx) {
      ctx.current_func_single_empty_param_index = saved_empty;
      ctx.current_func_empty_param_count = saved_count;
      ctx.current_emit_empty_var_next_index = saved_next;
      pipeline_dep_ctx_empty_param_restore(ctx);
    }
    /*
     * Fallback `return 0;` — default OFF when a body block was emitted.
     * Why (parser M1 host-cc): Cap-T001 `unsafe { return glue(...); }` nests return in a
     * region; old top-level-only scan still appended `return 0` → illegal for by-value
     * struct (Lexer / OneFuncResult). Scalar fallback only if no return path found.
     * PLATFORM: SHARED — seed pin same commit; verify parser.x host-cc + product matrix.
     * Authority: codegen_block_contains_return + integer/pointer kind gate.
     */
    let need_fallback_return: bool = false;
    if (fn_ret_void) {
      /* PLATFORM: SHARED — void main (C process entry): fall off body → exit 0. */
      if (emit_c_main_symbol) {
        if (!ast.ref_is_null(pipeline_module_func_body_ref_at(module, fi))) {
          if (codegen_block_contains_return(arena, pipeline_module_func_body_ref_at(module, fi)) == 0) {
            need_fallback_return = true;
          }
        } else {
          need_fallback_return = true;
        }
      } else {
        need_fallback_return = false;
      }
    } else if (!ast.ref_is_null(pipeline_module_func_body_expr_ref_at(module, fi))) {
      need_fallback_return = false;
    } else if (!ast.ref_is_null(pipeline_module_func_body_ref_at(module, fi))) {
      let body_br: i32 = pipeline_module_func_body_ref_at(module, fi);
      if (codegen_block_contains_return(arena, body_br) == 0) {
        let ret_ord: i32 = pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, fi));
        /* Integer-like 0..7 and TYPE_PTR only. */
        if ((ret_ord >= 0 && ret_ord <= 7) || ret_ord == (TypeKind.TYPE_PTR as i32)) {
          need_fallback_return = true;
        }
      }
    } else {
      let ret_ord2: i32 = pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, fi));
      if ((ret_ord2 >= 0 && ret_ord2 <= 7) || ret_ord2 == (TypeKind.TYPE_PTR as i32)) {
        need_fallback_return = true;
      }
    }
    if (need_fallback_return) {
      if (emit_indent(out, 2) != 0) {
        return -1;
      }
      let ret0: u8[9] = [114, 101, 116, 117, 114, 110, 32, 48, 59];
      if (emit_bytes_9(out, ret0, 9) != 0) {
        return -1;
      }
      if (append_byte(out, 10) != 0) {
        return -1;
      }
    }
    let close: u8[3] = [125, 10, 0];
    if (emit_bytes_3(out, close, 2) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * Return 1 if `name` is a libc symbol that must NOT be re-declared by
 * `emit_func_extern_declaration`.
 *
 * Why: XLANG maps `*u8` → `uint8_t *` (and integers → `int32_t`), while system
 * headers use `char *` / `void *` / `int` / `size_t`. Re-emitting those externs
 * conflicts with `#include <stdlib.h>` / `<string.h>` / unistd (g05 historically
 * sed-deleted the bad redecls). Authority for "skip emit" is this single
 * predicate; seed must stay in sync.
 *
 * Covered (historical g05 sed + read/write + wave30 mkstemp/rename): libc I/O,
 * alloc (incl. realloc / posix_memalign), string, env, path (unlink/mkstemp/
 * rename/access). g05 sed remains a defense layer for harness helpers and
 * #include strip; libc name authority is this predicate only (G.7).
 * PLATFORM: SHARED — product C prologue MUST include stdlib.h + string.h
 * (rt_preamble io_net lines). Skipping without those headers → implicit int.
 */
export function codegen_is_libc_conflicting_extern_name(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8 || name_len <= 0) {
    return 0;
  }
  /* read 4 */
  if (name_len == 4 && name[0] == 114 && name[1] == 101 && name[2] == 97 && name[3] == 100) {
    return 1;
  }
  /* write 5 */
  if (name_len == 5 && name[0] == 119 && name[1] == 114 && name[2] == 105 && name[3] == 116 && name[4] == 101) {
    return 1;
  }
  /* open 4 */
  if (name_len == 4 && name[0] == 111 && name[1] == 112 && name[2] == 101 && name[3] == 110) {
    return 1;
  }
  /* close 5 */
  if (name_len == 5 && name[0] == 99 && name[1] == 108 && name[2] == 111 && name[3] == 115 && name[4] == 101) {
    return 1;
  }
  /* fcntl 5 */
  if (name_len == 5 && name[0] == 102 && name[1] == 99 && name[2] == 110 && name[3] == 116 && name[4] == 108) {
    return 1;
  }
  /* free 4 */
  if (name_len == 4 && name[0] == 102 && name[1] == 114 && name[2] == 101 && name[3] == 101) {
    return 1;
  }
  /* malloc 6 */
  if (name_len == 6 && name[0] == 109 && name[1] == 97 && name[2] == 108 && name[3] == 108 && name[4] == 111 && name[5] == 99) {
    return 1;
  }
  /* calloc 6 */
  if (name_len == 6 && name[0] == 99 && name[1] == 97 && name[2] == 108 && name[3] == 108 && name[4] == 111 && name[5] == 99) {
    return 1;
  }
  /* realloc 7 — void* vs uint8_t* clash with stdlib.h */
  if (name_len == 7 && name[0] == 114 && name[1] == 101 && name[2] == 97 && name[3] == 108 && name[4] == 108 && name[5] == 111 && name[6] == 99) {
    return 1;
  }
  /* posix_memalign 14 — stdlib/POSIX prototype; skip XLANG redecl */
  if (name_len == 14 && name[0] == 112 && name[1] == 111 && name[2] == 115 && name[3] == 105 && name[4] == 120 && name[5] == 95 && name[6] == 109 && name[7] == 101 && name[8] == 109 && name[9] == 97 && name[10] == 108 && name[11] == 105 && name[12] == 103 && name[13] == 110) {
    return 1;
  }
  /* strtoul 7 — *u8 vs char* / u32 vs unsigned long (std/test) */
  if (name_len == 7 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 116 && name[4] == 111 && name[5] == 117 && name[6] == 108) {
    return 1;
  }
  /* strtol 6 */
  if (name_len == 6 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 116 && name[4] == 111 && name[5] == 108) {
    return 1;
  }
  /* strtoull 8 */
  if (name_len == 8 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 116 && name[4] == 111 && name[5] == 117 && name[6] == 108 && name[7] == 108) {
    return 1;
  }
  /* strtoll 7 */
  if (name_len == 7 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 116 && name[4] == 111 && name[5] == 108 && name[6] == 108) {
    return 1;
  }
  /* memcpy 6 */
  if (name_len == 6 && name[0] == 109 && name[1] == 101 && name[2] == 109 && name[3] == 99 && name[4] == 112 && name[5] == 121) {
    return 1;
  }
  /* memcmp 6 */
  if (name_len == 6 && name[0] == 109 && name[1] == 101 && name[2] == 109 && name[3] == 99 && name[4] == 109 && name[5] == 112) {
    return 1;
  }
  /* memset 6 */
  if (name_len == 6 && name[0] == 109 && name[1] == 101 && name[2] == 109 && name[3] == 115 && name[4] == 101 && name[5] == 116) {
    return 1;
  }
  /* memchr 6 — glibc string.h may macro to _Generic; *u8 clash */
  if (name_len == 6 && name[0] == 109 && name[1] == 101 && name[2] == 109 && name[3] == 99 && name[4] == 104 && name[5] == 114) {
    return 1;
  }
  /* memrchr 7 */
  if (name_len == 7 && name[0] == 109 && name[1] == 101 && name[2] == 109 && name[3] == 114 && name[4] == 99 && name[5] == 104 && name[6] == 114) {
    return 1;
  }
  /* memmem 6 */
  if (name_len == 6 && name[0] == 109 && name[1] == 101 && name[2] == 109 && name[3] == 109 && name[4] == 101 && name[5] == 109) {
    return 1;
  }
  /* strchr 6 — string.h macro / char* clash (std/path) */
  if (name_len == 6 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 99 && name[4] == 104 && name[5] == 114) {
    return 1;
  }
  /* strrchr 7 */
  if (name_len == 7 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 114 && name[4] == 99 && name[5] == 104 && name[6] == 114) {
    return 1;
  }
  /* strcpy 6 */
  if (name_len == 6 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 99 && name[4] == 112 && name[5] == 121) {
    return 1;
  }
  /* strncpy 7 */
  if (name_len == 7 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 110 && name[4] == 99 && name[5] == 112 && name[6] == 121) {
    return 1;
  }
  /* getenv 6 — *u8 → uint8_t* conflicts with char *getenv(const char *) */
  if (name_len == 6 && name[0] == 103 && name[1] == 101 && name[2] == 116 && name[3] == 101 && name[4] == 110 && name[5] == 118) {
    return 1;
  }
  /* getcwd 6 */
  if (name_len == 6 && name[0] == 103 && name[1] == 101 && name[2] == 116 && name[3] == 99 && name[4] == 119 && name[5] == 100) {
    return 1;
  }
  /* unlink 6 */
  if (name_len == 6 && name[0] == 117 && name[1] == 110 && name[2] == 108 && name[3] == 105 && name[4] == 110 && name[5] == 107) {
    return 1;
  }
  /* strlen 6 */
  if (name_len == 6 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 108 && name[4] == 101 && name[5] == 110) {
    return 1;
  }
  /* strcmp 6 */
  if (name_len == 6 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 99 && name[4] == 109 && name[5] == 112) {
    return 1;
  }
  /* strncmp 7 */
  if (name_len == 7 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 110 && name[4] == 99 && name[5] == 109 && name[6] == 112) {
    return 1;
  }
  /* strstr 6 */
  if (name_len == 6 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 115 && name[4] == 116 && name[5] == 114) {
    return 1;
  }
  /* setenv 6 */
  if (name_len == 6 && name[0] == 115 && name[1] == 101 && name[2] == 116 && name[3] == 101 && name[4] == 110 && name[5] == 118) {
    return 1;
  }
  /* system 6 */
  if (name_len == 6 && name[0] == 115 && name[1] == 121 && name[2] == 115 && name[3] == 116 && name[4] == 101 && name[5] == 109) {
    return 1;
  }
  /* fputs 5 */
  if (name_len == 5 && name[0] == 102 && name[1] == 112 && name[2] == 117 && name[3] == 116 && name[4] == 115) {
    return 1;
  }
  /* strerror 8 */
  if (name_len == 8 && name[0] == 115 && name[1] == 116 && name[2] == 114 && name[3] == 101 && name[4] == 114 && name[5] == 114 && name[6] == 111 && name[7] == 114) {
    return 1;
  }
  /* opendir/closedir/readdir: DO NOT skip — std.fs models DIR* as *u8 opaque;
   * system dirent.h DIR* prototypes are incompatible (return/arg type). Emit
   * XLANG extern uint8_t *opendir(...) instead of including dirent.h.
   * PLATFORM: POSIX opaque DIR. */
  /* access 6 */
  if (name_len == 6 && name[0] == 97 && name[1] == 99 && name[2] == 99 && name[3] == 101 && name[4] == 115 && name[5] == 115) {
    return 1;
  }
  /* mkstemp 7 — i32 vs int; *u8 path vs char* (runtime_driver_abi_thin.x).
   * wave30: was g05-sed-only dual-auth; product -E must skip redecl at source. */
  if (name_len == 7 && name[0] == 109 && name[1] == 107 && name[2] == 115 && name[3] == 116 && name[4] == 101 && name[5] == 109 && name[6] == 112) {
    return 1;
  }
  /* rename 6 — i32 vs int; *u8 paths vs char* (open_out close-before-rename). */
  if (name_len == 6 && name[0] == 114 && name[1] == 101 && name[2] == 110 && name[3] == 97 && name[4] == 109 && name[5] == 101) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_find_mono_type_for_generic_func(arena: *ASTArena, module: *Module, fi: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (arena == 0 as *ASTArena || module == 0 as *Module || fi < 0 || fi >= module.num_funcs) {
      return 0;
    }
    let fn_local: u8[64] = [];
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
    if (fn_len <= 0) {
      return 0;
    }
    let ei: i32 = 1;
    while (ei <= arena.num_exprs) {
      let e: Expr = ast.ast_arena_expr_get(arena, ei);
      if (e.kind == ExprKind.EXPR_CALL) {
        let matched: i32 = 0;
        if (e.call_resolved_func_index == fi) {
          matched = 1;
        } else if (!ast.ref_is_null(e.call_callee_ref) && e.call_callee_ref > 0 && e.call_callee_ref <= arena.num_exprs) {
          let cal: Expr = ast.ast_arena_expr_get(arena, e.call_callee_ref);
          if (cal.kind == ExprKind.EXPR_VAR && cal.var_name_len == fn_len) {
            let eq: i32 = 1;
            let k: i32 = 0;
            while (k < fn_len) {
              if (cal.var_name[k] != fn_local[k]) {
                eq = 0;
                k = fn_len;
              } else {
                k = k + 1;
              }
            }
            matched = eq;
          }
        }
        if (matched != 0) {
          let ty: i32 = e.resolved_type_ref;
          if (ty <= 0 && e.call_num_args > 0) {
            let a0: i32 = pipeline_expr_call_arg_ref(arena, ei, 0);
            if (a0 > 0) {
              ty = pipeline_expr_resolved_type_ref(arena, a0);
            }
          }
          if (ty > 0) {
            return ty;
          }
        }
      }
      ei = ei + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function codegen_try_emit_generic_identity_mono(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || module == 0 as *Module) {
      return 0;
    }
    if (fi < 0 || fi >= module.num_funcs) {
      return 0;
    }
    if (pipeline_module_func_num_generic_params_at(module, fi) <= 0) {
      return 0;
    }
    if (pipeline_module_func_is_extern_at(module, fi) != 0) {
      return 0;
    }
    if (pipeline_module_func_num_params_at(module, fi) != 1) {
      return 0;
    }
    let ret_ty: i32 = pipeline_module_func_return_type_at(module, fi);
    let p0_ty: i32 = pipeline_module_func_param_type_ref_at(module, fi, 0);
    if (ret_ty <= 0 || p0_ty <= 0) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, ret_ty) != TypeKind.TYPE_NAMED) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, p0_ty) != TypeKind.TYPE_NAMED) {
      return 0;
    }
    let ret_nm: u8[64] = [];
    let p0_nm: u8[64] = [];
    let ret_nl: i32 = pipeline_type_named_name_into(arena, ret_ty, &ret_nm[0]);
    let p0_nl: i32 = pipeline_type_named_name_into(arena, p0_ty, &p0_nm[0]);
    if (ret_nl <= 0 || ret_nl != p0_nl) {
      return 0;
    }
    let bi: i32 = 0;
    while (bi < ret_nl) {
      if (ret_nm[bi] != p0_nm[bi]) {
        return 0;
      }
      bi = bi + 1;
    }
    let mono_ty: i32 = codegen_find_mono_type_for_generic_func(arena, module, fi);
    if (mono_ty <= 0) {
      return 0;
    }
    let pn_len: i32 = pipeline_module_func_param_name_len_at(module, fi, 0);
    let pn: u8[32] = [];
    pipeline_module_func_param_name_copy32(module, fi, 0, &pn[0]);
    if (pn_len <= 0) {
      /* See implementation. */
      pn[0] = 120;
      pn_len = 1;
    }
    /* See implementation. */
    if (emit_type(arena, out, mono_ty, prefix, prefix_len, ctx) != 0) {
      return -1;
    }
    if (append_byte(out, 32) != 0) {
      return -1;
    }
    let fn_local: u8[64] = [];
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
    let mono_sym_pre: i32 = codegen_func_c_symbol_prefix_len(module, fi, prefix_len);
    if (mono_sym_pre > 0 && codegen_c_prefix_redundant_with_name(prefix, mono_sym_pre, &fn_local[0], fn_len) == 0) {
      if (emit_bytes_from_ptr(out, prefix, mono_sym_pre) != 0) {
        return -1;
      }
    }
    if (codegen_emit_func_link_name(out, arena, module, fi) != 0) {
      return -1;
    }
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_type(arena, out, mono_ty, prefix, prefix_len, ctx) != 0) {
      return -1;
    }
    if (append_byte(out, 32) != 0) {
      return -1;
    }
    if (emit_bytes_from_ptr(out, &pn[0], pn_len) != 0) {
      return -1;
    }
    let open_body: u8[4] = [41, 32, 123, 10];
    if (emit_bytes_from_ptr(out, &open_body[0], 4) != 0) {
      return -1;
    }
    if (emit_indent(out, 2) != 0) {
      return -1;
    }
    let ret_kw: u8[8] = [114, 101, 116, 117, 114, 110, 32, 0];
    if (emit_bytes_from_ptr(out, &ret_kw[0], 7) != 0) {
      return -1;
    }
    if (emit_bytes_from_ptr(out, &pn[0], pn_len) != 0) {
      return -1;
    }
    let end: u8[3] = [59, 10, 125];
    if (emit_bytes_from_ptr(out, &end[0], 3) != 0) {
      return -1;
    }
    if (append_byte(out, 10) != 0) {
      return -1;
    }
    return 1;
  }
}

/** Exported function `emit_func_extern_declaration`.
 * Implements `emit_func_extern_declaration`.
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param module *Module
 * @param fi i32
 * @param prefix *u8
 * @param prefix_len i32
 * @param ctx *PipelineDepCtx
 * @return i32
 */
export function emit_func_extern_declaration(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    /* See implementation. */
    if (fi < 0 || fi >= module.num_funcs) {
      return -1;
    }
    /* See implementation. */
    if (pipeline_module_func_num_generic_params_at(module, fi) > 0) {
      return 0;
    }
    let fn_local: u8[64] = [];
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
    /* See implementation. */
    if (pipeline_module_func_is_extern_at(module, fi) != 0 && codegen_is_libc_conflicting_extern_name(&fn_local[0], fn_len) != 0) {
      return 0;
    }
    /* "extern " */
    let kw: u8[8] = [101, 120, 116, 101, 114, 110, 32, 0];
    if (emit_bytes_from_ptr(out, &kw[0], 7) != 0) {
      return -1;
    }
    /* See implementation. */
    if (pipeline_module_func_is_used_at(module, fi) != 0) {
      let used_attr: u8[27] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 115, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0];
      if (emit_bytes_from_ptr(out, &used_attr[0], 22) != 0) { return -1; }
    }
    /* See implementation. */
    if (pipeline_module_func_is_naked_at(module, fi) != 0) {
      let naked_attr: u8[29] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 97, 107, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0, 0];
      if (emit_bytes_from_ptr(out, &naked_attr[0], 23) != 0) { return -1; }
    }
    /* See implementation. */
    if (pipeline_module_func_is_entry_at(module, fi) != 0) {
      let entry_attr: u8[30] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 111, 114, 101, 116, 117, 114, 110, 41, 41, 32, 0, 0, 0, 0];
      if (emit_bytes_from_ptr(out, &entry_attr[0], 26) != 0) { return -1; }
    }
    /* See implementation. */
    if (pipeline_module_func_is_interrupt_at(module, fi) != 0) {
      let int_attr: u8[31] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 105, 110, 116, 101, 114, 114, 117, 112, 116, 41, 41, 32, 0, 0, 0, 0];
      if (emit_bytes_from_ptr(out, &int_attr[0], 27) != 0) { return -1; }
    }
    if (emit_type(arena, out, pipeline_module_func_return_type_at(module, fi), prefix, prefix_len, ctx) != 0) {
      return -1;
    }
    if (append_byte(out, 32) != 0) {
      return -1;
    }
    /* Why extern: external-link symbols need bare names (xlang_sys_mmap), not dep-prefixed
       (std_sys_linux_xlang_sys_mmap fails to link). Type emit still uses prefix_len for dep
       custom type params. Invariant: name_prefix_len only affects function-name emit. */
    let name_prefix_len: i32 = prefix_len;
    if (pipeline_module_func_is_extern_at(module, fi) != 0) {
      /* See implementation. */
      let _starts_with_prefix: bool = false;
      if (prefix_len > 0 && fn_len >= prefix_len) {
        let _k: i32 = 0;
        _starts_with_prefix = true;
        while (_k < prefix_len) {
          if (fn_local[_k] != prefix[_k]) {
            _starts_with_prefix = false;
            break;
          }
          _k = _k + 1;
        }
      }
      if (!_starts_with_prefix) {
        name_prefix_len = 0;
      }
    }
    /* See implementation. */
    name_prefix_len = codegen_func_c_symbol_prefix_len(module, fi, name_prefix_len);
    if (name_prefix_len > 0 && codegen_c_prefix_redundant_with_name(prefix, name_prefix_len, &fn_local[0], fn_len) == 0 && emit_bytes_from_ptr(out, prefix, name_prefix_len) != 0) {
      return -1;
    }
    /* See implementation. */
    if (codegen_emit_func_link_name(out, arena, module, fi) != 0) {
      return -1;
    }
    if (codegen_std_io_fixed_fd_emit_impl(prefix, prefix_len, &fn_local[0], fn_len) != 0) {
      let impl_suffix: u8[6] = [95, 105, 109, 112, 108, 0];
      if (emit_bytes_from_ptr(out, &impl_suffix[0], 5) != 0) {
        return -1;
      }
    }
    let lpar: u8[2] = [40, 0];
    if (emit_bytes_2(out, lpar, 1) != 0) {
      return -1;
    }
    if (pipeline_module_func_num_params_at(module, fi) == 0) {
      let v: u8[7] = [118, 111, 105, 100, 0, 0, 0];
      if (emit_bytes_7(out, v, 4) != 0) {
        return -1;
      }
    } else {
      let p: i32 = 0;
      while (p < pipeline_module_func_num_params_at(module, fi)) {
        if (p > 0) {
          let comma: u8[3] = [44, 32, 0];
          if (emit_bytes_3(out, comma, 2) != 0) {
            return -1;
          }
        }
        if (codegen_force_param_size_t_std_io_print_str_second(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let size_t_buf2: u8[32] = [115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          if (emit_bytes_32(out, size_t_buf2, 7) != 0) {
            return -1;
          }
        } else if (codegen_force_param_size_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let size_t_buf: u8[32] = [115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          if (emit_bytes_32(out, size_t_buf, 7) != 0) {
            return -1;
          }
        } else if (codegen_force_param_ptrdiff_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let ptrdiff_t_buf: u8[32] = [112, 116, 114, 100, 105, 102, 102, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          if (emit_bytes_32(out, ptrdiff_t_buf, 10) != 0) {
            return -1;
          }
        } else if (codegen_force_param_uint32_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let u32_buf: u8[32] = [117, 105, 110, 116, 51, 50, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          if (emit_bytes_32(out, u32_buf, 9) != 0) {
            return -1;
          }
        } else if (codegen_force_param_i32(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
          let i32_str: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
          if (emit_bytes_8(out, i32_str, 7) != 0) {
            return -1;
          }
        } else if (emit_type(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p), prefix, prefix_len, ctx) != 0) {
          return -1;
        }
        /* PLATFORM: SHARED — TYPE_SLICE params as pointers (mirror emit_func body; seed/glue ABI). */
        if (pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) == (TypeKind.TYPE_SLICE as i32)) {
          if (append_byte(out, 32) != 0) {
            return -1;
          }
          if (append_byte(out, 42) != 0) {
            return -1;
          }
        }
        if (append_byte(out, 32) != 0) {
          return -1;
        }
        if (pipeline_module_func_param_name_len_at(module, fi, p) > 0) {
          let plocal: u8[32] = [];
          codegen_copy_param_name32_from_module(module, fi, p, &plocal[0]);
          if (plocal[0] > 32 && emit_bytes_32(out, plocal, pipeline_module_func_param_name_len_at(module, fi, p)) != 0) {
            return -1;
          }
        } else {
          let place: u8[4] = [95, 112, 48, 0];
          if (emit_bytes_4(out, place, 2) != 0) {
            return -1;
          }
          if (format_int(out, p) != 0) {
            return -1;
          }
        }
        p = p + 1;
      }
    }
    /* See implementation. */
    if (pipeline_module_func_is_variadic_at(module, fi) != 0 && pipeline_module_func_num_params_at(module, fi) > 0) {
      let ellipsis: u8[5] = [44, 32, 46, 46, 46];
      if (emit_bytes_from_ptr(out, &ellipsis[0], 5) != 0) {
        return -1;
      }
    }
    let end_proto: u8[3] = [41, 59, 10];
    if (emit_bytes_from_ptr(out, &end_proto[0], 3) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function codegen_emit_import_dep_function_declarations(module: *Module, out: *CodegenOutBuf, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (module == 0 as *Module || out == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    let saved_module: *Module = ctx.current_codegen_module;
    let saved_arena: *ASTArena = ctx.current_codegen_arena;
    let saved_dep_index: i32 = ctx.current_codegen_dep_index;
    let saved_prefix_len: i32 = ctx.current_codegen_prefix_len;
    let saved_prefix: u8[64] = [];
    let sp: i32 = 0;
    while (sp < 64) {
      saved_prefix[sp] = ctx.current_codegen_prefix_mirror[sp];
      sp = sp + 1;
    }
    let n_imp: i32 = codegen_module_num_imports(module);
    let imp_i: i32 = 0;
    while (imp_i < n_imp) {
      let dep_path: u8[64] = [];
      let dep_path_len: i32 = codegen_module_import_path_len_at(module, imp_i, &dep_path[0]);
      if (dep_path_len > 0) {
        let seen_before: i32 = 0;
        let prev_i: i32 = 0;
        while (prev_i < imp_i) {
          let prev_path: u8[64] = [];
          let prev_len: i32 = codegen_module_import_path_len_at(module, prev_i, &prev_path[0]);
          if (prev_len == dep_path_len) {
            let eq_prev: bool = true;
            let pk: i32 = 0;
            while (pk < dep_path_len && pk < 64) {
              if (prev_path[pk] != dep_path[pk]) {
                eq_prev = false;
                break;
              }
              pk = pk + 1;
            }
            if (eq_prev) {
              seen_before = 1;
              break;
            }
          }
          prev_i = prev_i + 1;
        }
        if (seen_before == 0) {
          let dep_ix: i32 = codegen_find_dep_index_by_path(ctx, &dep_path[0], dep_path_len);
          let dep_mod: *Module = 0 as *Module;
          let dep_arena: *ASTArena = 0 as *ASTArena;
          let dep_ctx_ix: i32 = dep_ix;
          if (dep_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx)) {
            dep_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
            dep_arena = pipeline_dep_ctx_arena_at(ctx, dep_ix);
          }
          if ((dep_mod == 0 as *Module || dep_arena == 0 as *ASTArena) && dep_path_len > 0) {
            let global_slot: i32 = codegen_find_seeded_global_dep_slot_by_path(&dep_path[0], dep_path_len);
            if (global_slot >= 0) {
              dep_mod = driver_dep_module_buf(global_slot) as *Module;
              dep_arena = driver_dep_arena_buf(global_slot) as *ASTArena;
              dep_ctx_ix = -1;
            }
          }
          if (dep_mod != 0 as *Module && dep_arena != 0 as *ASTArena && dep_mod.num_funcs > 0) {
              let prefix_buf: u8[128] = [];
              let prefix_len: i32 = 0;
              if (codegen_path_is_std_io_core_bytes(&dep_path[0]) == 0) {
                codegen_import_path_to_c_prefix_into(&dep_path[0], &prefix_buf[0], 128);
                while (prefix_len < 128 && prefix_buf[prefix_len] != 0 as u8) {
                  prefix_len = prefix_len + 1;
                }
              }
              ctx.current_codegen_module = dep_mod;
              ctx.current_codegen_arena = dep_arena;
              ctx.current_codegen_dep_index = dep_ctx_ix;
              ctx.current_codegen_prefix_len = 0;
              let px: i32 = 0;
              while (px < prefix_len && px < 63) {
                ctx.current_codegen_prefix_mirror[px] = prefix_buf[px];
                px = px + 1;
              }
              ctx.current_codegen_prefix_mirror[px] = 0 as u8;
              ctx.current_codegen_prefix_len = px;
              let fi: i32 = 0;
              while (fi < dep_mod.num_funcs) {
                if (emit_func_extern_declaration(dep_arena, out, dep_mod, fi, &prefix_buf[0], prefix_len, ctx) != 0) {
                  return -1;
                }
                fi = fi + 1;
              }
          }
        }
      }
      imp_i = imp_i + 1;
    }
    ctx.current_codegen_module = saved_module;
    ctx.current_codegen_arena = saved_arena;
    ctx.current_codegen_dep_index = saved_dep_index;
    ctx.current_codegen_prefix_len = saved_prefix_len;
    sp = 0;
    while (sp < 64) {
      ctx.current_codegen_prefix_mirror[sp] = saved_prefix[sp];
      sp = sp + 1;
    }
    return 0;
  }
}

/** Exported function `codegen_x_ast_emit_header`.
 * Implements `codegen_x_ast_emit_header`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function codegen_x_ast_emit_header(out: *CodegenOutBuf): i32 {
  let h: u8[64] = [35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 116, 100, 105, 110, 116, 46, 104, 62, 10,
    35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 116, 100, 100, 101, 102, 46, 104, 62, 10,
    35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 121, 115, 47, 116, 121, 112, 101, 115, 46, 104, 62, 10,
    0];
  return emit_bytes_64(out, &h[0], 63);
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
export extern function pipeline_codegen_std_dep_link_only(path: *u8): i32;

/** Exported function `codegen_x_ast`.
 * Implements `codegen_x_ast`.
 * @param module *Module
 * @param arena *ASTArena
 * @param out *CodegenOutBuf
 * @param ctx *PipelineDepCtx
 * @param dep_index i32
 * @return i32
 */
export function codegen_x_ast(module: *Module, arena: *ASTArena, out: *CodegenOutBuf, ctx: *PipelineDepCtx, dep_index: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    /* See implementation. */
    if (ctx != 0 as *PipelineDepCtx) {
      ctx.current_codegen_module = module;
      ctx.current_codegen_arena = arena;
      ctx.current_codegen_dep_index = dep_index;
    }
    /* See implementation. */
    let prefix_buf: u8[128] = [];
    let prefix_len: i32 = 0;
    let dep_path_prefix: u8[64] = [];
    let dep_path_prefix_len: i32 = 0;
    if (dep_index >= 0 && ctx != 0 as *PipelineDepCtx) {
      dep_path_prefix_len = codegen_dep_import_path_len_at(ctx, dep_index, &dep_path_prefix[0]);
      /* See implementation. */
      if (dep_path_prefix_len > 0 && pipeline_codegen_std_dep_link_only(&dep_path_prefix[0]) != 0) {
        return 0;
      }
    }
    if (dep_index >= 0 && ctx != 0 as *PipelineDepCtx && dep_path_prefix_len > 0) {
      /* See implementation. */
      if (codegen_path_is_std_io_core_bytes(&dep_path_prefix[0]) == 0) {
        codegen_import_path_to_c_prefix_into(&dep_path_prefix[0], &prefix_buf[0], 128);
        while (prefix_len < 128 && prefix_buf[prefix_len] != 0) {
          prefix_len = prefix_len + 1;
        }
      }
    }
    /* See implementation. */
    if (prefix_len == 0 && (dep_index < 0 || dep_path_prefix_len == 0 || codegen_path_is_std_io_core_bytes(&dep_path_prefix[0]) == 0)) {
      prefix_len = 0;
      prefix_buf[0] = 0 as u8;
      if (dep_path_prefix_len > 0) {
        codegen_import_path_to_c_prefix_into(&dep_path_prefix[0], &prefix_buf[0], 128);
        while (prefix_len < 128 && prefix_buf[prefix_len] != 0) {
          prefix_len = prefix_len + 1;
        }
      }
    }
    /*
     * See implementation.
     * See implementation.
     * See implementation.
     * See implementation.
     *   incomplete struct String）。
     * See implementation.
     * See implementation.
     */
    if (prefix_len == 0 && dep_index < 0 && ctx != 0 as *PipelineDepCtx) {
      if (ctx.entry_module_import_path_len > 0) {
        let pi: i32 = 0;
        while (pi < ctx.entry_module_import_path_len && pi < 127) {
          prefix_buf[pi] = ctx.entry_module_import_path_mirror[pi];
          pi = pi + 1;
        }
        prefix_buf[pi] = 0 as u8;
        prefix_len = pi;
      }
    }
    if (ctx != 0 as *PipelineDepCtx) {
      ctx.current_codegen_prefix_len = 0;
      let px: i32 = 0;
      while (px < prefix_len && px < 63) {
        ctx.current_codegen_prefix_mirror[px] = prefix_buf[px];
        px = px + 1;
      }
      ctx.current_codegen_prefix_mirror[px] = 0 as u8;
      ctx.current_codegen_prefix_len = px;
    }
    /* See implementation. */
    let call_init_globals: i32 = 0;
    if (module.num_top_level_lets > 0) {
      let ti: i32 = 0;
      while (ti < module.num_top_level_lets) {
        if (pipeline_module_top_level_let_is_const(module, ti) == 0) {
          call_init_globals = 1;
          break;
        }
        ti = ti + 1;
      }
    }
    let i: i32 = 0;
    while (i < module.num_funcs) {
      if (i == 0) {
        /*
         * See implementation.
         * See implementation.
         * See implementation.
         * See implementation.
         * See implementation.
         */
        if (pipeline_codegen_c_file_prologue_done_get() == 0) {
          if (codegen_x_ast_emit_header(out) != 0) {
            return -1;
          }
          if (codegen_emit_skipped_dep_type_definitions(ctx, out) != 0) {
            return -1;
          }
          /*
           * Restore current_codegen_module after dep type walk.
           * Purpose: skipped_dep_type_definitions may leave ctx pointing at the last
           *   dep visited; CALL binding resolution (fmt.fmt_*) and same-module bare
           *   names (unwrap_or) then mangle with the wrong prefix.
           * Authority: seeds/codegen_gen.linux.x86_64.c codegen_x_ast after
           *   codegen_emit_skipped_dep_type_definitions.
           * PLATFORM: SHARED — multi-dep co-emit C TU; verify Cap force hello/si.
           */
          if (ctx != 0 as *PipelineDepCtx) {
            ctx.current_codegen_module = module;
            ctx.current_codegen_arena = arena;
          }
          if (codegen_emit_dep_struct_forward_declarations(ctx, out) != 0) {
            return -1;
          }
          pipeline_codegen_c_file_prologue_done_set(1);
        }
        /* See implementation. */
        if (codegen_emit_import_dep_function_declarations(module, out, ctx) != 0) {
          return -1;
        }
        /* See implementation. */
        if (dep_index < 0) {
          if (codegen_emit_module_enum_definitions(module, out, &prefix_buf[0], prefix_len) != 0) {
            return -1;
          }
          if (codegen_emit_module_struct_definitions(module, arena, out, &prefix_buf[0], prefix_len, ctx) != 0) {
            return -1;
          }
        }
        /*
         * Same-module forward prototypes (body-front extern wall).
         * Purpose: co-emitted TU may call later functions in the same module (e.g.
         *   core_option_map_ptr_u8 → core_option_is_some_ptr_u8). Without prototypes,
         *   host C99 rejects implicit declarations even when the definition follows.
         * Authority: same loop as seeds/codegen_gen.linux.x86_64.c codegen_x_ast
         *   (emit_func_extern_declaration for every non-extern func before bodies).
         * PLATFORM: SHARED — C TU ordering; verify mac + Ubuntu option force-regen.
         * Does not re-pin seed: seed already has this wall; Cap was missing it in .x.
         */
        let fwd_fi: i32 = 0;
        while (fwd_fi < module.num_funcs) {
          if (pipeline_module_func_is_extern_at(module, fwd_fi) == 0) {
            if (emit_func_extern_declaration(arena, out, module, fwd_fi, &prefix_buf[0], prefix_len, ctx) != 0) {
              return -1;
            }
          }
          fwd_fi = fwd_fi + 1;
        }
        /* See implementation. */
        if (module.num_top_level_lets > 0) {
          let ti: i32 = 0;
          while (ti < module.num_top_level_lets) {
            let is_const: i32 = pipeline_module_top_level_let_is_const(module, ti);
            let name_len: i32 = pipeline_module_top_level_let_name_len(module, ti);
            if (name_len <= 0 || name_len > 63) {
              ti = ti + 1;
              continue;
            }
            let tl_name_buf: u8[64] = [];
            let tni: i32 = 0;
            while (tni < name_len && tni < 64) {
              tl_name_buf[tni] = pipeline_module_top_level_let_name_byte_at(module, ti, tni);
              tni = tni + 1;
            }
            let tl_ty: i32 = pipeline_module_top_level_let_type_ref(module, ti);
            let tl_init: i32 = pipeline_module_top_level_let_init_ref(module, ti);
            let is_fixed_arr: i32 = 0;
            if (!ast.ref_is_null(tl_ty) && pipeline_type_kind_ord_at(arena, tl_ty) == TypeKind.TYPE_ARRAY) {
              is_fixed_arr = 1;
            }
            /* PLATFORM: SHARED — product preamble may #define O_CREAT/MAP_FAILED/S_IFMT for
             * bare EXPR_VAR use when dep export const was historically not co-emitted. Now
             * that top-level const/let are emitted as C objects, redeclaring the same name
             * under an active macro is illegal (e.g. static const MAP_FAILED expands to
             * static const ((int64_t)-1)). #undef first so the object is the single C
             * authority; values still match std/fs/posix.x + preamble. */
            let undef_kw: u8[8] = [35, 117, 110, 100, 101, 102, 32, 0]; /* "#undef " */
            if (emit_bytes_from_ptr(out, &undef_kw[0], 7) != 0) {
              return -1;
            }
            if (emit_bytes_from_ptr(out, &tl_name_buf[0], name_len) != 0) {
              return -1;
            }
            if (append_byte(out, 10) != 0) {
              return -1;
            }
            if (is_const != 0) {
              let static_const: u8[15] = [115, 116, 97, 116, 105, 99, 32, 99, 111, 110, 115, 116, 32, 0, 0];
              if (emit_bytes_from_ptr(out, &static_const[0], 13) != 0) {
                return -1;
              }
            } else {
              let static_: u8[9] = [115, 116, 97, 116, 105, 99, 32, 0, 0];
              if (emit_bytes_from_ptr(out, &static_[0], 7) != 0) {
                return -1;
              }
            }
            if (is_fixed_arr != 0) {
              if (emit_local_fixed_array_elem_type(arena, out, tl_ty, ctx) != 0) {
                return -1;
              }
            } else {
              if (emit_type(arena, out, tl_ty, &prefix_buf[0], 0, ctx) != 0) {
                return -1;
              }
            }
            if (append_byte(out, 32) != 0) {
              return -1;
            }
            if (emit_bytes_from_ptr(out, &tl_name_buf[0], name_len) != 0) {
              return -1;
            }
            if (is_fixed_arr != 0) {
              if (emit_local_fixed_array_suffix(arena, out, tl_ty) != 0) {
                return -1;
              }
            }
            /* Declaration-site init policy (C static storage):
             * - Fixed arrays: write init at decl (empty [] → BSS zeros; no compound-lit pointer).
             * - Non-array const: keep `= init` at decl.
             * - Non-array mutable let: decl-site ONLY when init is C static-const
             *   (pipeline_expr_is_c_static_const_init: pure lit trees, e.g. -1).
             *   Why: library/dep TUs have no main, so init_globals never runs; BSS zero-init
             *   would wipe sentinels like xlang_heap_trace_on = -1 (heap_trace never enables).
             *   VAR-dependent inits (e.g. let b = a + 2) are illegal as C static initializers
             *   and must remain init_globals-only (two_lets / run-toplevel-let).
             *   init_globals may still re-assign pure lits on entry co-emit (idempotent).
             * PLATFORM: SHARED — C .data vs .bss; non-zero static init must not become BSS 0. */
            let want_decl_init: i32 = 0;
            if (is_fixed_arr != 0 && !ast.ref_is_null(tl_init)) {
              if (pipeline_expr_kind_ord_at(arena, tl_init) == (46 as i32)) {
                if (pipeline_expr_array_lit_num_elems_at(arena, tl_init) > 0) {
                  want_decl_init = 1;
                }
              } else {
                want_decl_init = 1;
              }
            }
            if (is_const != 0 && is_fixed_arr == 0 && !ast.ref_is_null(tl_init)) {
              want_decl_init = 1;
            }
            /* Mutable scalar let: lit/const-expr only (not free-VAR trees). */
            if (is_const == 0 && is_fixed_arr == 0 && !ast.ref_is_null(tl_init)) {
              if (pipeline_expr_is_c_static_const_init(arena, tl_init) != 0) {
                want_decl_init = 1;
              }
            }
            if (want_decl_init != 0) {
              let eq: u8[4] = [32, 61, 32, 0];
              if (emit_bytes_4(out, eq, 3) != 0) {
                return -1;
              }
              if (is_fixed_arr != 0) {
                if (emit_braced_array_lit_init(arena, out, tl_init, ctx) != 0) {
                  return -1;
                }
              } else {
                if (emit_expr(arena, out, tl_init, ctx) != 0) {
                  return -1;
                }
              }
            }
            let sc: u8[3] = [59, 10, 0];
            if (emit_bytes_3(out, sc, 2) != 0) {
              return -1;
            }
            ti = ti + 1;
          }
          let any_let: i32 = 0;
          ti = 0;
          while (ti < module.num_top_level_lets) {
            if (pipeline_module_top_level_let_is_const(module, ti) == 0) {
              any_let = 1;
              break;
            }
            ti = ti + 1;
          }
          /*
           * See implementation.
           * See implementation.
           * See implementation.
           * See implementation.
           * See implementation.
           */
          if (dep_index < 0 && any_let == 0 && module.main_func_index >= 0) {
            let dep_scan_i: i32 = 0;
            let dep_ndep: i32 = pipeline_dep_ctx_ndep(ctx);
            while (dep_scan_i < dep_ndep) {
              let scan_path: u8[64] = [];
              let scan_plen: i32 = codegen_dep_import_path_len_at(ctx, dep_scan_i, &scan_path[0]);
              if (scan_plen > 0 && pipeline_codegen_std_dep_link_only(&scan_path[0]) != 0) {
                dep_scan_i = dep_scan_i + 1;
                continue;
              }
              let dep_scan_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_scan_i);
              if (dep_scan_mod != 0 as *Module) {
                let dep_ti: i32 = 0;
                while (dep_ti < dep_scan_mod.num_top_level_lets) {
                  if (pipeline_module_top_level_let_is_const(dep_scan_mod, dep_ti) == 0) {
                    any_let = 1;
                    break;
                  }
                  dep_ti = dep_ti + 1;
                }
              }
              if (any_let != 0) {
                break;
              }
              dep_scan_i = dep_scan_i + 1;
            }
          }
          if (any_let != 0 && dep_index < 0) {
            /* See implementation. */
            let init_globals_def: u8[32] = [115, 116, 97, 116, 105, 99, 32, 118, 111, 105, 100, 32, 105, 110, 105, 116, 95, 103, 108, 111, 98, 97, 108, 115, 40, 118, 111, 105, 100, 41, 32, 0];
            /* See implementation. */
            if (emit_bytes_from_ptr(out, &init_globals_def[0], 31) != 0) {
              return -1;
            }
            let brace3: u8[3] = [123, 10, 0];
            if (emit_bytes_3(out, brace3, 2) != 0) {
              return -1;
            }
            ti = 0;
            while (ti < module.num_top_level_lets) {
              if (pipeline_module_top_level_let_is_const(module, ti) != 0) {
                ti = ti + 1;
                continue;
              }
              /* See implementation. */
              let ig_ty: i32 = pipeline_module_top_level_let_type_ref(module, ti);
              if (!ast.ref_is_null(ig_ty) && pipeline_type_kind_ord_at(arena, ig_ty) == TypeKind.TYPE_ARRAY) {
                ti = ti + 1;
                continue;
              }
              if (emit_indent(out, 2) != 0) {
                return -1;
              }
              let nlen: i32 = pipeline_module_top_level_let_name_len(module, ti);
              if (nlen > 0 && nlen <= 63) {
                let tl_init_name: u8[64] = [];
                let tni2: i32 = 0;
                while (tni2 < nlen && tni2 < 64) {
                  tl_init_name[tni2] = pipeline_module_top_level_let_name_byte_at(module, ti, tni2);
                  tni2 = tni2 + 1;
                }
                if (emit_bytes_from_ptr(out, &tl_init_name[0], nlen) != 0) {
                  return -1;
                }
              }
              let eq2: u8[4] = [32, 61, 32, 0];
              if (emit_bytes_4(out, eq2, 3) != 0) {
                return -1;
              }
              if (!ast.ref_is_null(pipeline_module_top_level_let_init_ref(module, ti)) && emit_expr(arena, out, pipeline_module_top_level_let_init_ref(module, ti), ctx) != 0) {
                return -1;
              }
              let sc2: u8[3] = [59, 10, 0];
              if (emit_bytes_3(out, sc2, 2) != 0) {
                return -1;
              }
              ti = ti + 1;
            }
            /* See implementation. */
            let dep_i: i32 = 0;
            let ndep: i32 = 0;
            if (module.main_func_index >= 0) {
              ndep = pipeline_dep_ctx_ndep(ctx);
            }
            while (dep_i < ndep) {
              let lo_path: u8[64] = [];
              let lo_plen: i32 = codegen_dep_import_path_len_at(ctx, dep_i, &lo_path[0]);
              if (lo_plen > 0 && pipeline_codegen_std_dep_link_only(&lo_path[0]) != 0) {
                dep_i = dep_i + 1;
                continue;
              }
              let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_i);
              if (dep_mod != 0 as *Module) {
                let dep_arena: *ASTArena = pipeline_dep_ctx_arena_at(ctx, dep_i);
                let dti: i32 = 0;
                while (dti < dep_mod.num_top_level_lets) {
                  if (pipeline_module_top_level_let_is_const(dep_mod, dti) == 0) {
                    let dig_ty: i32 = pipeline_module_top_level_let_type_ref(dep_mod, dti);
                    if (dep_arena != 0 as *ASTArena && !ast.ref_is_null(dig_ty)
                        && pipeline_type_kind_ord_at(dep_arena, dig_ty) == TypeKind.TYPE_ARRAY) {
                      dti = dti + 1;
                      continue;
                    }
                    if (emit_indent(out, 2) != 0) {
                      return -1;
                    }
                    let dnlen: i32 = pipeline_module_top_level_let_name_len(dep_mod, dti);
                    if (dnlen > 0 && dnlen <= 63) {
                      let dtl_name: u8[64] = [];
                      let dtni: i32 = 0;
                      while (dtni < dnlen && dtni < 64) {
                        dtl_name[dtni] = pipeline_module_top_level_let_name_byte_at(dep_mod, dti, dtni);
                        dtni = dtni + 1;
                      }
                      if (emit_bytes_from_ptr(out, &dtl_name[0], dnlen) != 0) {
                        return -1;
                      }
                    }
                    let deq: u8[4] = [32, 61, 32, 0];
                    if (emit_bytes_4(out, deq, 3) != 0) {
                      return -1;
                    }
                    if (!ast.ref_is_null(pipeline_module_top_level_let_init_ref(dep_mod, dti)) && emit_expr(dep_arena, out, pipeline_module_top_level_let_init_ref(dep_mod, dti), ctx) != 0) {
                      return -1;
                    }
                    let dsc: u8[3] = [59, 10, 0];
                    if (emit_bytes_3(out, dsc, 2) != 0) {
                      return -1;
                    }
                  }
                  dti = dti + 1;
                }
              }
              dep_i = dep_i + 1;
            }
            let close_brace: u8[3] = [125, 10, 0];
            if (emit_bytes_3(out, close_brace, 2) != 0) {
              return -1;
            }
          }
        }
      }
      /* See implementation. */
      let skip_name: u8[64] = [];
      codegen_copy_func_name64_from_module(module, i, &skip_name[0]);
      let skip_nl: i32 = pipeline_module_func_name_len_at(module, i);
      /* See implementation. */
      if (pipeline_module_func_num_generic_params_at(module, i) > 0) {
        let mono_rc: i32 = codegen_try_emit_generic_identity_mono(arena, out, module, i, &prefix_buf[0], prefix_len, ctx);
        if (mono_rc < 0) {
          return -1;
        }
        i = i + 1;
        continue;
      }
      /* See implementation. */
      if (pipeline_module_func_is_extern_at(module, i) != 0) {
        if (emit_func_extern_declaration(arena, out, module, i, &prefix_buf[0], prefix_len, ctx) != 0) {
          return -1;
        }
        i = i + 1;
        continue;
      }
      /* See implementation. */
      let skip: i32 = 0;
      let asm_backend: i32 = 0;
      if (ctx != 0 as *PipelineDepCtx && ctx.use_asm_backend != 0) {
        asm_backend = 1;
      }
      skip = codegen_should_skip_emit_func_by_name(&skip_name[0], skip_nl);
      /*
       * See implementation.
       * See implementation.
       * See implementation.
       */
      if (skip == 0 && asm_backend == 0) {
        let is_prelinked_dep: i32 = 0;
        if (dep_index >= 0 && dep_path_prefix_len >= 10) {
          /* std.string or std/string */
          if (dep_path_prefix[0] == 115 && dep_path_prefix[1] == 116 && dep_path_prefix[2] == 100
              && (dep_path_prefix[3] == 46 || dep_path_prefix[3] == 47)
              && dep_path_prefix[4] == 115 && dep_path_prefix[5] == 116 && dep_path_prefix[6] == 114
              && dep_path_prefix[7] == 105 && dep_path_prefix[8] == 110 && dep_path_prefix[9] == 103) {
            is_prelinked_dep = 1;
          }
        }
        if (is_prelinked_dep == 0 && dep_index >= 0 && dep_path_prefix_len >= 9) {
          /* std.error or std/error */
          if (dep_path_prefix[0] == 115 && dep_path_prefix[1] == 116 && dep_path_prefix[2] == 100
              && (dep_path_prefix[3] == 46 || dep_path_prefix[3] == 47)
              && dep_path_prefix[4] == 101 && dep_path_prefix[5] == 114 && dep_path_prefix[6] == 114
              && dep_path_prefix[7] == 111 && dep_path_prefix[8] == 114) {
            is_prelinked_dep = 1;
          }
        }
        if (is_prelinked_dep == 0 && dep_index >= 0 && dep_path_prefix_len >= 11) {
          /* std.context or std/context */
          if (dep_path_prefix[0] == 115 && dep_path_prefix[1] == 116 && dep_path_prefix[2] == 100
              && (dep_path_prefix[3] == 46 || dep_path_prefix[3] == 47)
              && dep_path_prefix[4] == 99 && dep_path_prefix[5] == 111 && dep_path_prefix[6] == 110
              && dep_path_prefix[7] == 116 && dep_path_prefix[8] == 101 && dep_path_prefix[9] == 120
              && dep_path_prefix[10] == 116) {
            is_prelinked_dep = 1;
          }
        }
        if (is_prelinked_dep == 0 && prefix_len >= 11
            && prefix_buf[0] == 115 && prefix_buf[1] == 116 && prefix_buf[2] == 100
            && prefix_buf[3] == 95 && prefix_buf[4] == 115 && prefix_buf[5] == 116
            && prefix_buf[6] == 114 && prefix_buf[7] == 105 && prefix_buf[8] == 110
            && prefix_buf[9] == 103 && prefix_buf[10] == 95
            && dep_index >= 0) {
          is_prelinked_dep = 1;
        }
        if (is_prelinked_dep == 0 && prefix_len >= 10
            && prefix_buf[0] == 115 && prefix_buf[1] == 116 && prefix_buf[2] == 100
            && prefix_buf[3] == 95 && prefix_buf[4] == 101 && prefix_buf[5] == 114
            && prefix_buf[6] == 114 && prefix_buf[7] == 111 && prefix_buf[8] == 114
            && prefix_buf[9] == 95
            && dep_index >= 0) {
          is_prelinked_dep = 1;
        }
        if (is_prelinked_dep == 0 && prefix_len >= 12
            && prefix_buf[0] == 115 && prefix_buf[1] == 116 && prefix_buf[2] == 100
            && prefix_buf[3] == 95 && prefix_buf[4] == 99 && prefix_buf[5] == 111
            && prefix_buf[6] == 110 && prefix_buf[7] == 116 && prefix_buf[8] == 101
            && prefix_buf[9] == 120 && prefix_buf[10] == 116 && prefix_buf[11] == 95
            && dep_index >= 0) {
          is_prelinked_dep = 1;
        }
        if (is_prelinked_dep != 0) {
          skip = 1;
        }
      }
      /*
       * Legacy belt: if an older by_name still skipped bare placeholder/string_new,
       * un-skip when this module has a real C prefix (core_mem_ / core_types_ / …).
       * Current by_name no longer skips those names (seed-aligned); this remains a
       * no-op safety net. Product preamble only externs core_types_placeholder —
       * co-emit must produce the strong body or si links UNDEF.
       * PLATFORM: SHARED — Cap force multi-dep co-emit (stdlib-import).
       */
      if (skip != 0 && prefix_len > 0 && (skip_nl == 11 || skip_nl == 10)) {
        skip = 0;
      }
      if (skip == 0 && prefix_len == 0 && asm_backend == 0) {
        skip = codegen_should_skip_emit_func_core_read_ptr(&skip_name[0], skip_nl);
      }
      if (skip == 0 && prefix_len > 0 && asm_backend == 0) {
        skip = codegen_should_skip_emit_func(0 as *u8, &prefix_buf[0], prefix_len, &skip_name[0], skip_nl);
      }
      if (skip == 0 && dep_index >= 0 && ctx != 0 as *PipelineDepCtx && dep_path_prefix_len > 0 && asm_backend == 0) {
        skip = codegen_should_skip_emit_func(&dep_path_prefix[0], 0 as *u8, 0, &skip_name[0], skip_nl);
      }
      if (skip == 0 && asm_backend == 0) {
        let skip_dep: *u8 = 0 as *u8;
        if (dep_index >= 0 && ctx != 0 as *PipelineDepCtx && dep_path_prefix_len > 0) {
          skip_dep = &dep_path_prefix[0];
        }
        if (skip_dep == 0 as *u8) {
          skip_dep = driver_get_current_dep_path_for_codegen();
        }
        skip = codegen_should_skip_emit_func(skip_dep, 0 as *u8, 0, &skip_name[0], skip_nl);
      }
      if (skip != 0) {
        i = i + 1;
        continue;
      }
      /* See implementation. */
      let is_entry: bool = (i == module.main_func_index) || (module.num_funcs == 1);
      let saved_func_idx: i32 = -1;
      if (ctx != 0 as *PipelineDepCtx) {
        saved_func_idx = ctx.current_func_index;
        ctx.current_func_index = i;
      }
      /*
       * Restore module identity + C prefix before each function body.
       * Purpose: prior emit_func / import-extern walks may leave
       *   current_codegen_module or prefix_mirror on another dep (e.g. core.option
       *   while emitting core.result → bare unwrap_or becomes core_option_unwrap_or;
       *   or entry while emitting std.fmt → fmt.fmt_i32 not core_fmt_fmt_i32).
       * Authority: seeds/codegen_gen.linux.x86_64.c before codegen_emit_func
       *   (module/arena/dep_index); prefix_mirror re-pin matches this module's
       *   prefix_buf computed at codegen_x_ast entry (Cap residual root).
       * PLATFORM: SHARED — Cap force multi-dep co-emit matrix (hello/si).
       */
      if (ctx != 0 as *PipelineDepCtx) {
        ctx.current_codegen_module = module;
        ctx.current_codegen_arena = arena;
        ctx.current_codegen_dep_index = dep_index;
        let px: i32 = 0;
        while (px < prefix_len && px < 63) {
          ctx.current_codegen_prefix_mirror[px] = prefix_buf[px];
          px = px + 1;
        }
        ctx.current_codegen_prefix_mirror[px] = 0 as u8;
        ctx.current_codegen_prefix_len = px;
      }
      if (emit_func(arena, out, module, i, is_entry, &prefix_buf[0], prefix_len, ctx, call_init_globals) != 0) {
        driver_diagnostic_codegen_emit_func_fail(module, i);
        if (ctx != 0 as *PipelineDepCtx) {
          ctx.current_func_index = saved_func_idx;
        }
        return -1;
      }
      if (ctx != 0 as *PipelineDepCtx) {
        ctx.current_func_index = saved_func_idx;
      }
      i = i + 1;
    }
    return 0;
  }
  // PLATFORM: SHARED — Cap-T001 whole-body unsafe close. Extra matching `}` required so
  // product parser does not parse-skip this mega function (XLANG_DEBUG_PARSE: skip at
  // codegen_x_ast entry → residual body mis-ingested as top-level lets / fake init_globals).
  }
}

/**
 * See implementation.
 */
/**
 * Decide whether to skip emitting a function solely by bare name.
 * Purpose: gate oversized bootstrap mega bodies (and historically bare
 *   placeholder/string_new that collided with preamble #define macros).
 * Parameters: name/name_len — function bare name (not C-mangled).
 * Returns: 1 = skip emit, 0 = emit normally.
 * Authority: seeds/codegen_gen.linux.x86_64.c codegen_should_skip_emit_func_by_name.
 * Why: product preamble no longer #define-aliases placeholder/string_new; those
 *   are real exports (core_types_placeholder, core_mem_placeholder, and peers).
 *   Cap still skipped bare "placeholder" so multi-dep co-emit of core.types
 *   emitted every size_of body but dropped placeholder → si -o UNDEF.
 * Invariant: only asm_codegen_ast_seed_mega / to_elf mega remain name-skips
 *   unless XLANG_EMIT_SEED_MEGA is set; do not re-add placeholder skip.
 * PLATFORM: SHARED — Cap force stdlib-import / core.* co-emit link.
 * Note: never write star-slash inside this block comment (truncates C emit).
 */
function codegen_should_skip_emit_func_by_name(name: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let asm_seed_mega: u8[25] = [97, 115, 109, 95, 99, 111, 100, 101, 103, 101, 110, 95, 97, 115, 116, 95, 115, 101, 101, 100, 95, 109, 101, 103, 97];
    let asm_to_elf_seed_mega: u8[32] = [97, 115, 109, 95, 99, 111, 100, 101, 103, 101, 110, 95, 97, 115, 116, 95, 116, 111, 95, 101, 108, 102, 95, 115, 101, 101, 100, 95, 109, 101, 103, 97];
    if (name == 0 as *u8) {
      return 0;
    }
    // placeholder and string_new skip removed (seed-aligned; real core/std exports).
    // bootstrap -E: seed_mega bodies are huge; XLANG_EMIT_SEED_MEGA=1 still tries emit.
    if (pipeline_codegen_emit_seed_mega_enabled() == 0) {
      if (name_len == 25 && codegen_name_bytes_prefix_eq(name, name_len, &asm_seed_mega[0], 25) != 0) {
        return 1;
      }
      if (name_len == 32 && codegen_name_bytes_prefix_eq(name, name_len, &asm_to_elf_seed_mega[0], 32) != 0) {
        return 1;
      }
    }
    return 0;
  }
}

/**
 * See implementation.
 */
function codegen_is_submit_batch_buf_call(name: *u8, name_len: i32): i32 {
  let rd_batch: u8[21] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  let wr_batch: u8[22] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len == 21 && codegen_name_bytes_prefix_eq(name, name_len, &rd_batch[0], 21) != 0) {
    return 1;
  }
  if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, &wr_batch[0], 22) != 0) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 */
function codegen_force_param_i32(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  /* See implementation. */
  return 0;
}

/**
 * Skip std.io.core ABI bridge names supplied by runtime preamble / io backend.
 *
 * Purpose: do not emit C bodies for xlang_io_read_ptr(_len), register*, wait_readable
 * when the C backend already maps them via preamble macros/weak stubs.
 *
 * Parameters:
 *   name / name_len — bare identifier; must use full "xlang_io_*" spelling (with 'x').
 *
 * Returns 1 to skip, 0 to emit.
 * read_ptr_len allows name_len >= 20 (prefix match); others require exact length.
 * PLATFORM: SHARED — Cap force hello co-emit must not redefine preamble bridges.
 */
function codegen_should_skip_emit_func_core_read_ptr(name: *u8, name_len: i32): i32 {
  /* xlang_io_read_ptr_len — 20 */
  let xlang_rpl20: u8[21] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110];
  /* xlang_io_read_ptr — 16 */
  let xlang_rp16: u8[17] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114];
  /*
   * See implementation.
   * See implementation.
   * See implementation.
   * See implementation.
   * See implementation.
   * PLATFORM: SHARED.
   */
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len >= 20 && codegen_name_bytes_prefix_eq(name, name_len, &xlang_rpl20[0], 20) != 0) {
    return 1;
  }
  if (name_len == 16 && codegen_name_bytes_prefix_eq(name, name_len, &xlang_rp16[0], 16) != 0) {
    return 1;
  }
  /* xlang_io_read_ptr_backend — 24 (preamble weak stub) */
  let xlang_rpb24: u8[25] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 98, 97, 99, 107, 101, 110, 100];
  if ((name_len == 24 || name_len == 25) && codegen_name_bytes_prefix_eq(name, name_len, &xlang_rpb24[0], 24) != 0) {
    return 1;
  }
  /* xlang_io_submit_read_async — 25 (preamble weak stub) */
  let xlang_sra25: u8[26] = [120, 108, 97, 110, 103, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 97, 115, 121, 110, 99];
  if ((name_len == 25 || name_len == 26) && codegen_name_bytes_prefix_eq(name, name_len, &xlang_sra25[0], 25) != 0) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 */
function codegen_std_io_fixed_fd_emit_impl(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  let pre7: u8[7] = [115, 116, 100, 95, 105, 111, 95];
  /* See implementation. */
  let rd13: u8[13] = [114, 101, 97, 100, 95, 102, 105, 120, 101, 100, 95, 102, 100];
  let wr14: u8[14] = [119, 114, 105, 116, 101, 95, 102, 105, 120, 101, 100, 95, 102, 100];
  if (prefix == 0 as *u8 || name == 0 as *u8 || prefix_len < 7 || name_len <= 0) {
    return 0;
  }
  if (codegen_name_bytes_prefix_eq(prefix, prefix_len, &pre7[0], 7) == 0) {
    return 0;
  }
  if (name_len >= 13 && codegen_name_bytes_prefix_eq(name, name_len, &rd13[0], 13) != 0) {
    return 1;
  }
  if (name_len >= 14 && codegen_name_bytes_prefix_eq(name, name_len, &wr14[0], 14) != 0) {
    return 1;
  }
  return 0;
}
