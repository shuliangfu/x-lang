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
// See implementation.
// See implementation.
//
// Cap-T001 / LANG-007 S0 (M1→M2 typeck): functions that call export-extern
// pipeline_* / glue use whole-body unsafe FFI gates. Does not weaken user-code
// unsafe checks inside typeck. PLATFORM: SHARED — product still pins typeck seed until M2.
// See implementation.

const ast = import("ast");

/**
* See implementation.
* See implementation.
*/
export extern function typeck_float64_bits_lo(d: f64): i32;
export extern function typeck_float64_bits_hi(d: f64): i32;
/* See implementation. */
export extern function driver_diagnostic_typeck_func_fail(func_idx: i32, name: *u8, name_len: i32,
kind: i32): void;
/* See implementation. */
export extern function pipeline_typeck_loop_depth_set_c(ctx: *PipelineDepCtx, depth: i32): void;
/* See implementation. */
export extern function pipeline_dep_ctx_ndep(ctx: *PipelineDepCtx): i32;
export extern function pipeline_dep_ctx_module_at(ctx: *PipelineDepCtx, idx: i32): *Module;
export extern function pipeline_dep_ctx_import_path_len(ctx: *PipelineDepCtx, idx: i32): i32;
export extern function pipeline_dep_ctx_import_path_copy64(ctx: *PipelineDepCtx, idx: i32, dst: *u8): void;
export extern function parser_get_module_num_imports(module: *Module): i32;
export extern function pipeline_dep_ctx_arena_at(ctx: *PipelineDepCtx, idx: i32): *ASTArena;
/* See implementation. */
export extern function pipeline_dep_ctx_set_current_func_index(ctx: *PipelineDepCtx, ix: i32): void;
/* See implementation. */
export extern function pipeline_typeck_check_expr_impl_c(module: *Module, arena: *ASTArena, expr_ref: i32, return_type_ref: i32, ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function pipeline_typeck_check_expr_impl_mega_c(module: *Module, arena: *ASTArena, expr_ref: i32, return_type_ref: i32, ctx: *PipelineDepCtx): i32;
export extern function pipeline_typeck_check_expr_method_call_c(module: *Module, arena: *ASTArena, expr_ref: i32, return_type_ref: i32, ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function pipeline_typeck_check_expr_try_propagate_c(module: *Module, arena: *ASTArena, expr_ref: i32, return_type_ref: i32, ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function pipeline_typeck_check_expr_match_c(module: *Module, arena: *ASTArena, expr_ref: i32, return_type_ref: i32, ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function pipeline_typeck_check_expr_field_access_c(module: *Module, arena: *ASTArena, expr_ref: i32, return_type_ref: i32, ctx: *PipelineDepCtx): i32;
/**
 * wave682 Cap residual: mono free type-param field type against base Wrap<T>/Pair.
 * G.7 authority in pipeline_typeck_field_access.c (field access + STRUCT_LIT coerce).
 * @param module *Module — layout type-param registry
 * @param arena *ASTArena — type / type-arg sidecar
 * @param field_ty i32 — layout field type_ref (often free TYPE_NAMED T/U)
 * @param base_ty i32 — monomorphized base (`Wrap<i32>`, `*Wrap<i32>`)
 * @return i32 — mono concrete type_ref, or 0 if no substitution
 * PLATFORM: SHARED
 */
export extern function pipeline_typeck_mono_field_type_from_base_c(module: *Module, arena: *ASTArena,
field_ty: i32, base_ty: i32): i32;
/* R2 (8.3.3): prebind / known_ptr / layout_named / field_slice / name_fallback / lexer_fallback in typeck.x; C thin. */
export extern function pipeline_typeck_field_prebind_c(module: *Module, arena: *ASTArena, expr_ref: i32, ctx: *PipelineDepCtx): void;
export extern function pipeline_typeck_field_known_ptr_types_c(module: *Module, arena: *ASTArena, expr_ref: i32, base_ref: i32, num_layouts: i32): i32;
export extern function pipeline_typeck_field_layout_named_c(module: *Module, arena: *ASTArena, expr_ref: i32, base_ref: i32, ctx: *PipelineDepCtx): i32;
export extern function pipeline_typeck_field_slice_c(arena: *ASTArena, expr_ref: i32, base_ref: i32): void;
export extern function pipeline_typeck_field_name_fallback_c(arena: *ASTArena, expr_ref: i32, base_ref: i32): void;
export extern function pipeline_typeck_field_lexer_fallback_c(module: *Module, arena: *ASTArena, expr_ref: i32, base_ref: i32, ctx: *PipelineDepCtx): void;
/* See implementation. */
export extern function driver_diagnostic_typeck_ptr_field(bt_kind: i32, inner_kind: i32, inner_nlen: i32,
base_resolved_ref: i32, num_struct_layouts: i32): void;
/* See implementation. */
export extern function pipeline_type_named_name_into(arena: *ASTArena, type_ref: i32, out: *u8): i32;
/* See implementation. */
export extern function pipeline_type_kind_ord_at(arena: *ASTArena, type_ref: i32): i32;
/* See implementation. */
export extern function pipeline_type_array_size_at(arena: *ASTArena, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *ASTArena, type_ref: i32): i32;
/* wave686: NAMED type-pos args (Wrap<T>) for free-param tree walk / pattern match. */
export extern function pipeline_type_type_arg_ref_at(arena: *ASTArena, type_ref: i32, idx: i32): i32;
/* See implementation. */
export extern function pipeline_typeck_type_refs_equal_c(arena: *ASTArena, a: i32, b: i32): i32;
/**
 * wave703: 1 if *StructA arg may coerce to *StructB formal under #[repr(compatible)]
 * + same field shape. G.7 authority in pipeline_glue.c.
 * @param module *Module
 * @param arena *ASTArena
 * @param param_ref i32 — formal type_ref (must be TYPE_PTR to named struct)
 * @param arg_ref i32 — call argument expr
 * @return i32 — 1 ok coerce, 0 not applicable / reject
 * PLATFORM: SHARED
 */
export extern function pipeline_typeck_call_arg_repr_compatible_ok_c(module: *Module, arena: *ASTArena,
param_ref: i32, arg_ref: i32): i32;
/* See implementation. */
export extern function pipeline_typeck_resolve_type_alias_ref_c(arena: *ASTArena, type_ref: i32): i32;
export extern function pipeline_module_num_type_aliases_at(module: *Module): i32;
export extern function pipeline_module_type_alias_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_type_alias_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_type_alias_target_ref(module: *Module, idx: i32): i32;
export extern function pipeline_typeck_coerce_init_int_binop_to_decl_c(arena: *ASTArena, init_ref: i32,
decl_ty_ref: i32, decl_kind: i32, init_kind: i32): i32;
export extern function pipeline_typeck_func_body_has_implicit_return_tail_c(arena: *ASTArena, body_ref: i32): i32;
/* See implementation. */
export extern function pipeline_expr_binop_left_ref_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(arena: *ASTArena, expr_ref: i32): i32;
/* See implementation. */
export extern function driver_diagnostic_typeck_block_enter(func_idx: i32, block_ref: i32, n_const: i32,
n_let: i32, n_loop: i32, n_for: i32, n_expr: i32, final_ref: i32): void;
/* See implementation. */
export extern function driver_diagnostic_typeck_fn_enter(func_idx: i32, name: *u8, name_len: i32): void;
/* See implementation. */
export extern function driver_diagnostic_typeck_ret_fail(stage: i32, op_expr_ref: i32, expect_ty_ref: i32,
got_ty_ref: i32): void;
export extern function driver_diagnostic_typeck_binop_operands(expr_ref: i32, left_ref: i32, right_ref: i32,
left_kind: i32, right_kind: i32, left_block_ref: i32, right_block_ref: i32, left_ty_ref: i32, right_ty_ref: i32,
left_ty: *u8, left_ty_len: i32, right_ty: *u8, right_ty_len: i32): void;
/* See implementation. */
export extern function driver_diagnostic_typeck_return_mismatch(line: i32, col: i32,
expect_buf: *u8, expect_len: i32, found_buf: *u8, found_len: i32): void;
export extern function driver_diagnostic_typeck_return_unresolved(line: i32, col: i32,
expr_buf: *u8, expr_len: i32): void;
export extern function driver_diagnostic_typeck_return_subexpr(line: i32, col: i32,
expr_buf: *u8, expr_len: i32): void;
/* See implementation. */
export extern function driver_diagnostic_typeck_assign_mismatch(is_compound: i32, line: i32, col: i32,
expect_buf: *u8, expect_len: i32, found_buf: *u8, found_len: i32): void;
/* See implementation. */
export extern function driver_diagnostic_typeck_import_const_must_be_qualified(line: i32, col: i32,
name: *u8, name_len: i32, binding: *u8, binding_len: i32): void;
/* See implementation. */
export extern function driver_diagnostic_typeck_subscript_base(line: i32, col: i32): void;
/* See implementation. */
export extern function driver_diagnostic_typeck_break_continue_outside(line: i32, col: i32,
is_break: i32): void;
/**
 * Report illegal pointer arithmetic at a binary operator (wave285 Cap residual).
 * @param line i32 — 1-based source line of the binop
 * @param col i32 — 1-based source column of the binop
 * @return void
 * PLATFORM: SHARED — closes soft residual that formerly passed typeck then failed host-cc as BLD001.
 */
export extern function driver_diagnostic_typeck_invalid_ptr_binop(line: i32, col: i32): void;
/**
 * Report illegal float bitwise/mod/shift at a binary operator (wave286 Cap residual).
 * @param line i32 — 1-based source line of the binop
 * @param col i32 — 1-based source column of the binop
 * @return void
 * PLATFORM: SHARED — closes soft residual that formerly passed typeck then failed host-cc as BLD001.
 */
export extern function driver_diagnostic_typeck_invalid_float_binop(line: i32, col: i32): void;
/**
 * Report illegal aggregate ==/!=/relational (wave657 Cap residual).
 * @param line i32 — 1-based source line of the binop
 * @param col i32 — 1-based source column of the binop
 * @return void
 * PLATFORM: SHARED — closes soft residual: typeck stamped bool then host-cc BLD001 (struct/slice)
 * or silent pointer-identity false green (fixed array decay).
 */
export extern function driver_diagnostic_typeck_invalid_aggregate_cmp(line: i32, col: i32): void;
/**
 * Report illegal `as` cast (wave659 Cap residual).
 * @param line i32 — 1-based source line of the cast expr
 * @param col i32 — 1-based source column of the cast expr
 * @return void
 * PLATFORM: SHARED — closes soft residual: typeck stamped target then host-cc BLD001
 * (float→ptr) or silent false green (struct/array as scalar).
 */
export extern function driver_diagnostic_typeck_invalid_as_cast(line: i32, col: i32): void;
/**
 * Report free-function call arity mismatch (wave660 Cap residual).
 * @param line i32 — 1-based source line of the CALL expr
 * @param col i32 — 1-based source column of the CALL expr
 * @return void
 * PLATFORM: SHARED — closes soft residual: typeck bound first same-name func
 * ignoring arity → host-cc BLD001 (too few / too many arguments).
 */
export extern function driver_diagnostic_typeck_call_arity_mismatch(line: i32, col: i32): void;
export extern function driver_diagnostic_typeck_call_arg_type_mismatch(line: i32, col: i32): void;
export extern function driver_diagnostic_typeck_call_unresolved(line: i32, col: i32): void;
/**
 * Report non-integer array/slice/pointer subscript index (wave664 Cap residual).
 * @param line i32 — 1-based source line of the INDEX expr
 * @param col i32 — 1-based source column of the INDEX expr
 * @return void
 * PLATFORM: SHARED — closes soft residual: typeck accepted ptr/float/struct/bool
 * indices → host-cc BLD001 ("array subscript is not an integer") or freestanding
 * silent false green using pointer bits as index.
 */
export extern function driver_diagnostic_typeck_subscript_index(line: i32, col: i32): void;
/**
 * Report non-bool operand of LOGAND/LOGOR/LOGNOT (wave665 Cap residual).
 * @param line i32 — 1-based source line of the logical expr
 * @param col i32 — 1-based source column of the logical expr
 * @return void
 * PLATFORM: SHARED — docs/04: logical ops require bool; no implicit int-to-bool.
 * Closes soft residual: `i32 && i32` / `!i32` / `f32 && f32` passed typeck then
 * freestanding/host false green via C truthiness.
 */
export extern function driver_diagnostic_typeck_logical_operand_not_bool(line: i32, col: i32): void;
/**
 * Report incompatible comparison operand types (wave666 Cap residual).
 * @param line i32 — 1-based source line of the ==/!=/</>/<=/>= expr
 * @param col i32 — 1-based source column of the comparison expr
 * @return void
 * PLATFORM: SHARED — closes soft residual: typeck stamped bool for mixed
 * i32/f32/i64/bool/ptr-pointee pairs then freestanding/host false green.
 */
export extern function driver_diagnostic_typeck_comparison_type_mismatch(line: i32, col: i32): void;
/**
 * Report void used as arithmetic/unary operand (wave667 Cap residual).
 * @param line i32 — 1-based source line of the binop or unary expr
 * @param col i32 — 1-based source column of the op
 * @return void
 * PLATFORM: SHARED — closes soft residual: void call result in + - * / % bitops
 * or unary -/~ typeck OK then host-cc BLD001 invalid operands / argument type.
 */
export extern function driver_diagnostic_typeck_invalid_void_binop(line: i32, col: i32): void;
/**
 * Report bool used as arithmetic/bitop/shift/unary -/~ operand (wave677 Cap residual).
 * @param line i32 — 1-based source line of the op
 * @param col i32 — 1-based source column of the op
 * @return void
 * PLATFORM: SHARED — closes soft residual: binop bool→i32 promotion + unary -true
 * freestanding/host false green. LANG-006 let/const scalar bool→int retained.
 */
export extern function driver_diagnostic_typeck_invalid_bool_binop(line: i32, col: i32): void;
export extern function driver_diagnostic_typeck_assign_to_const(line: i32, col: i32): void;
/**
 * Report same-block let/const redecl or function-body param clash (wave680 Cap residual).
 * @param line i32 — 1-based source line of the second declaration
 * @param col i32 — 1-based source column of the second declaration
 * @return void
 * PLATFORM: SHARED — closes soft residual: host-C BLD001 redefinition of local.
 */
export extern function driver_diagnostic_typeck_duplicate_local(line: i32, col: i32): void;
export extern function pipeline_block_name_binding_kind(arena: *ASTArena, block_ref: i32, vname: *u8,
vlen: i32): i32;
export extern function pipeline_module_top_level_name_is_const(module: *Module, vname: *u8, vlen: i32): i32;
/**
 * wave680: 1 if name conflicts with another same-block let/const or function-body param.
 * @param arena *ASTArena
 * @param block_ref i32
 * @param vname *u8
 * @param vlen i32
 * @param kind i32 — 0=let at idx, 1=const at idx
 * @param idx i32
 * @param module *Module
 * @param func_index i32 — -1 skips param scan
 * @return i32 — 1 conflict, 0 ok
 * PLATFORM: SHARED — G.7 authority in ast_pool.c
 */
export extern function pipeline_block_local_name_redecl_c(arena: *ASTArena, block_ref: i32, vname: *u8,
vlen: i32, kind: i32, idx: i32, module: *Module, func_index: i32): i32;
export extern function pipeline_block_let_name_len(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_block_let_name_copy64(arena: *ASTArena, br: i32, li: i32, dst: *u8): void;
export extern function pipeline_block_const_name_len(arena: *ASTArena, br: i32, ci: i32): i32;
export extern function pipeline_block_const_name_copy64(arena: *ASTArena, br: i32, ci: i32, dst: *u8): void;
export extern function typeck_driver_diagnostic_pipe_marker(id: i32): void;
export extern function driver_diagnostic_typeck_if_condition_not_bool(line: i32, col: i32): void;
export extern function driver_diagnostic_typeck_while_condition_not_bool(line: i32, col: i32): void;
export extern function driver_diagnostic_typeck_for_condition_not_bool(line: i32, col: i32): void;
export extern function driver_typeck_diag_scratch_expect(): *u8;
export extern function driver_typeck_diag_scratch_found(): *u8;
/* See implementation. */
export extern function typeck_scratch64_slot(slot: i32): *u8;
/* See implementation. */
export extern function typeck_layout_metrics_sz_slot(): *i32;
export extern function typeck_layout_metrics_al_slot(): *i32;
export extern function typeck_layout_metrics_sz_slot_depth(depth: i32): *i32;
export extern function typeck_layout_metrics_al_slot_depth(depth: i32): *i32;
/* See implementation. */
export extern function typeck_i32_ptr_store(p: *i32, v: i32): void;
/* See implementation. */
export extern function typeck_i32_ptr_read(p: *i32): i32;
/* See implementation. */
export extern function typeck_call_resolve_dep_idx_slot(): *i32;
export extern function typeck_call_resolve_func_idx_slot(): *i32;
/** Expected return type for overload pick (let/assign/return context). 0 = none. PLATFORM: SHARED. */
export extern function typeck_overload_expected_ret_slot(): *i32;
export extern function typeck_overload_expected_ret_peek(): i32;
/* See implementation. */
export extern function typeck_call_resolve_dep_idx_peek(): i32;
export extern function typeck_call_resolve_func_idx_peek(): i32;
/* See implementation. */
export extern function typeck_binop_arith_infer_type_c(arena: *ASTArena, expr_ref: i32, bop_l: i32,
bop_r: i32, expr_kind: i32): void;
/* See implementation. */
export extern function pipeline_patch_block_parent_links(arena: *ASTArena, block_ref: i32, parent_ref: i32): void;
/* See implementation. */
export extern function typeck_layout_metrics_init_depth(depth: i32): void;
export extern function typeck_layout_metrics_al_read_depth(depth: i32): i32;
export extern function typeck_layout_metrics_sz_read_depth(depth: i32): i32;
export extern function typeck_layout_metrics_init_slot(): void;
/* See implementation. */
export extern function typeck_x_type_align_from_layout_glue(module: *Module, arena: *ASTArena, li: i32,
depth: i32): i32;
export extern function typeck_x_type_size_from_layout_glue(module: *Module, arena: *ASTArena, li: i32,
  depth: i32): i32;
/* R2 (8.3.3): typeck_soa_col_base / find_layout_* / field_soa_index /
 * fill_field_access_for_asm_emit migrated to .x authority below.
 * pipeline_typeck_soa.c keeps thin public surface + extern decls. */
/* WPO dep pipe for SoA layout cross-module lookup (emit context). */
export extern function pipeline_asm_emit_dep_pipe_c(): *PipelineDepCtx;
/* Current asm-emit function index (-1 unbound); VAR param fallback for SoA. */
export extern function pipeline_asm_emit_func_index_c(): i32;
/* Bind current emit func index (fill_soa func walk sets this for param fallback). */
export extern function pipeline_asm_emit_set_func_index(func_index: i32): void;
/* Stamp SoA column stride on FIELD_ACCESS (emit reads via field_access_soa_stride). */
export extern function pipeline_expr_set_field_access_soa_stride(arena: *ASTArena, expr_ref: i32,
stride: i32): void;
/* Read SoA stride stamped on FIELD_ACCESS; >0 means SoA path already filled. */
export extern function pipeline_expr_field_access_soa_stride(arena: *ASTArena, expr_ref: i32): i32;
/* Optional debug walk of named func bodies (XLANG_ASM_DEBUG / trace paths). */
export extern function pipeline_debug_trace_named_func_bodies(phase: *u8, module: *Module,
arena: *ASTArena): void;
/* Host-cc layout sync + skip-typeck var type backfill (link surfaces for fill_soa). */
export extern function glue_sync_struct_layout_field_offsets_c(module: *Module, arena: *ASTArena): void;
export extern function glue_fill_var_types_from_lets_in_block(arena: *ASTArena, block_ref: i32): void;
export extern function glue_fill_var_types_from_params_for_func(module: *Module, arena: *ASTArena,
func_index: i32): void;
export extern function glue_field_layout_offset_for_base_field(arena: *ASTArena, module: *Module,
base_ref: i32, field_name: *u8, flen: i32): i32;
/* See implementation. */
export extern function pipeline_get_dep_arena_slot(ix: i32): *ASTArena;
/* See implementation. */
export extern function pipeline_module_func_param_type_ref_for_name(module: *Module, func_index: i32,
vname: *u8, vname_len: i32): i32;
/* See implementation. */
export extern function pipeline_module_num_funcs(module: *Module): i32;
/* See implementation. */
export extern function pipeline_module_main_func_index(module: *Module): i32;
export extern function pipeline_module_func_is_extern_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_body_ref_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_body_expr_ref_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_return_type_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_name_len_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_name_copy64(module: *Module, fi: i32, dst: *u8): void;
export extern function pipeline_module_func_name_byte_at(module: *Module, fi: i32, i: i32): u8;
export extern function pipeline_module_func_name_equal_at(module: *Module, fi: i32, name: *u8,
name_len: i32): i32;
/* See implementation. */
export extern function pipeline_module_struct_layout_reset_slot(module: *Module, idx: i32): void;
export extern function pipeline_module_struct_layout_set_name(module: *Module, idx: i32, bytes: *u8,
len: i32): void;
export extern function pipeline_module_struct_layout_set_field(module: *Module, layout_idx: i32, j: i32,
fname: *u8, fname_len: i32, ftype_ref: i32, foff: i32): void;
/* See implementation. */
export extern function pipeline_struct_layout_next_field_offset(module: *Module, arena: *ASTArena,
layout_idx: i32, new_field_type_ref: i32): i32;
/* See implementation. */
export extern function pipeline_module_struct_layout_field_name_into(module: *Module, layout_idx: i32,
j: i32, out: *u8): void;
export extern function pipeline_module_struct_layout_field_name_len(module: *Module, layout_idx: i32,
j: i32): i32;
export extern function pipeline_module_struct_layout_name_into(module: *Module, idx: i32, out: *u8): void;
export extern function pipeline_module_struct_layout_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_num_fields(module: *Module, layout_idx: i32): i32;
export extern function pipeline_module_struct_layout_set_num_fields(module: *Module, layout_idx: i32,
nf: i32): void;
/* See implementation. */
export extern function pipeline_expr_struct_lit_num_fields(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_type_name_len(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_type_name_into(arena: *ASTArena, expr_ref: i32,
out: *u8): void;
/* Backfill struct_lit_struct_name on an anonymous struct literal from the
 * contextual return type (see pipeline_glue.c pipeline_expr_struct_lit_type_name_set).
 * PLATFORM: SHARED. */
export extern function pipeline_expr_struct_lit_type_name_set(arena: *ASTArena, expr_ref: i32,
name: *u8, name_len: i32): void;
export extern function pipeline_expr_struct_lit_field_name_len(arena: *ASTArena, expr_ref: i32,
j: i32): i32;
export extern function pipeline_expr_struct_lit_field_name_into(arena: *ASTArena, expr_ref: i32, j: i32,
out: *u8): void;
export extern function pipeline_expr_struct_lit_init_ref(arena: *ASTArena, expr_ref: i32, j: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *ASTArena, expr_ref: i32): i32;
/* See implementation. */
export extern function pipeline_expr_set_resolved_type_ref(arena: *ASTArena, expr_ref: i32,
type_ref: i32): void;
/* See implementation. */
export extern function pipeline_expr_typeck_set_float_bits_from_val(arena: *ASTArena, expr_ref: i32): void;
/* See implementation. */
export extern function pipeline_expr_line_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_col_at(arena: *ASTArena, expr_ref: i32): i32;
/* See implementation. */
export extern function pipeline_dep_ctx_typeck_loop_depth_at(ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function pipeline_dep_ctx_current_block_ref_at(ctx: *PipelineDepCtx): i32;
export extern function pipeline_dep_ctx_current_func_index(ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function pipeline_dep_ctx_typeck_unsafe_depth_at(ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function pipeline_typeck_block_impl_bind_ctx_c(ctx: *PipelineDepCtx, block_ref: i32): i32;
export extern function pipeline_typeck_block_impl_restore_ctx_c(ctx: *PipelineDepCtx, saved_block_ref: i32): void;
export extern function pipeline_typeck_block_impl_touch_ctx_block_c(ctx: *PipelineDepCtx, block_ref: i32): void;
/* See implementation. */
export extern function pipeline_expr_int_val_at(arena: *ASTArena, expr_ref: i32): i32;
/** Full i64 EXPR_LIT bits (wave307: u64/usize coerce must not use i32 truncation). */
export extern function pipeline_expr_int64_val_at(arena: *ASTArena, expr_ref: i32): i64;
export extern function pipeline_expr_field_access_is_enum_variant(arena: *ASTArena, expr_ref: i32): i32;
/* See implementation. */
export extern function pipeline_expr_set_field_access_enum_variant(arena: *ASTArena, expr_ref: i32,
tag: i32): void;
export extern function pipeline_expr_method_call_arg_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_match_arm_result_ref(arena: *ASTArena, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_match_arm_is_enum_variant(arena: *ASTArena, expr_ref: i32,
i: i32): i32;
export extern function pipeline_expr_match_arm_variant_index(arena: *ASTArena, expr_ref: i32, i: i32): i32;
/** wave700: optional match-arm guard expr (`pat if cond =>`); 0 = none. */
export extern function pipeline_expr_match_arm_guard_ref(arena: *ASTArena, expr_ref: i32, i: i32): i32;
/* See implementation. */
export extern function pipeline_expr_match_matched_ref_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_match_num_arms_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_module_enum_variant_tag_for_names(m: *Module, enum_name: *u8,
enum_len: i32, variant_name: *u8, variant_len: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
export extern function driver_diagnostic_typeck_enum_no_variant(line: i32, col: i32): void;
export extern function driver_diagnostic_typeck_var_resolution(expr_ref: i32, name: *u8, name_len: i32,
func_idx: i32, block_ref: i32, source: i32, type_ref: i32): void;
/* See implementation. */
export extern function pipeline_arena_type_alloc(arena: *ASTArena): i32;
/* See implementation. */
export extern function pipeline_type_init_primitive_kind_at(arena: *ASTArena, ref: i32, kind_ord: i32): i32;
/* See implementation. */
export extern function pipeline_type_init_named_at(arena: *ASTArena, ref: i32, name: *u8, name_len: i32): i32;
/* See implementation. */
export extern function pipeline_type_init_compound_kind_at(arena: *ASTArena, ref: i32, kind_ord: i32,
elem_ref: i32, array_size: i32): i32;
export extern function pipeline_type_ensure_by_kind_ord(arena: *ASTArena, kind_ord: i32): i32;
export extern function pipeline_type_find_or_alloc_named(arena: *ASTArena, name: *u8, name_len: i32): i32;
export extern function pipeline_type_find_or_alloc_compound(arena: *ASTArena, kind_ord: i32, elem_ref: i32,
array_size: i32): i32;
/* See implementation. */
export extern function pipeline_type_region_label_into(arena: *ASTArena, ref: i32, out64: *u8): i32;
export extern function pipeline_type_region_label_len_at(arena: *ASTArena, ref: i32): i32;
export extern function pipeline_type_set_region_label_at(arena: *ASTArena, ref: i32, label: *u8,
label_len: i32): i32;
export extern function pipeline_type_find_or_alloc_slice(arena: *ASTArena, elem_ref: i32, reg_label: *u8,
reg_label_len: i32): i32;
/* See implementation. */
export extern function pipeline_typeck_check_slice_region_assign_c(arena: *ASTArena, site_expr_ref: i32,
expect_ref: i32, src_ref: i32): i32;
export extern function pipeline_typeck_check_return_slice_region_c(arena: *ASTArena, ret_site_ref: i32,
op_ref: i32, func_return_ref: i32): i32;
/* See implementation. */
export extern function pipeline_typeck_check_return_slice_region_in_scope_c(arena: *ASTArena,
site_expr_ref: i32, return_type_ref: i32, ctx: *PipelineDepCtx): i32;
/* See implementation. */
/* See implementation. */
export extern function pipeline_typeck_check_extern_call_unsafe_boundary_c(module: *Module, arena: *ASTArena,
expr_ref: i32, ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function driver_diagnostic_typeck_deref_outside_unsafe(line: i32, col: i32): void;
export extern function pipeline_typeck_check_call_slice_region_c(module: *Module, arena: *ASTArena,
call_expr_ref: i32, ctx: *PipelineDepCtx): i32;
export extern function pipeline_type_stamp_block_let_region_c(arena: *ASTArena, block_ref: i32, let_idx: i32,
ctx: *PipelineDepCtx): i32;
export extern function pipeline_typeck_check_block_one_region_c(module: *Module, arena: *ASTArena,
block_ref: i32, region_idx: i32, return_type_ref: i32, ctx: *PipelineDepCtx): i32;
export extern function pipeline_block_region_is_unsafe(arena: *ASTArena, br: i32, ri: i32): i32;
/* See implementation. */
export extern function pipeline_typeck_linear_reset_c(): void;
export extern function pipeline_typeck_linear_use_var_c(arena: *ASTArena, type_ref: i32, expr_ref: i32,
name: *u8, name_len: i32): i32;
export extern function pipeline_typeck_linear_accepts_init_c(arena: *ASTArena, decl_ref: i32, init_ref: i32): i32;
/* See implementation. */
export extern function pipeline_typeck_reject_addr_of_linear_c(arena: *ASTArena, op_ref: i32,
addr_expr_ref: i32, module: *Module, ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function pipeline_typeck_ptr_for_addr_of_operand_c(arena: *ASTArena, op_ref: i32,
elem_ty: i32, module: *Module, ctx: *PipelineDepCtx): i32;
export extern function pipeline_typeck_check_struct_stack_escape_assign_c(module: *Module, arena: *ASTArena,
site_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function pipeline_typeck_check_scope_borrow_assign_c(module: *Module, arena: *ASTArena,
site_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function pipeline_typeck_check_allocator_region_assign_c(module: *Module, arena: *ASTArena,
site_expr_ref: i32, left_ref: i32, ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function pipeline_typeck_is_read_ptr_slice_callee_c(name: *u8, name_len: i32): i32;
export extern function pipeline_typeck_read_ptr_slice_return_ref_c(arena: *ASTArena): i32;
export extern function pipeline_module_func_param_type_ref_at(module: *Module, fi: i32, pi: i32): i32;
export extern function pipeline_module_func_num_params_at(module: *Module, fi: i32): i32;
export extern function pipeline_expr_call_resolved_func_index_at(arena: *ASTArena, expr_ref: i32): i32;
/**
 * Resolved dep module index for a CALL (-1 = local / entry module).
 * PLATFORM: SHARED — wave660 call arity gate needs dep module for num_params.
 */
export extern function pipeline_expr_call_resolved_dep_index_at(arena: *ASTArena, expr_ref: i32): i32;
/* See implementation. */
export extern function pipeline_expr_kind_ord_at(arena: *ASTArena, expr_ref: i32): i32;
/* See implementation. */
export extern function pipeline_typeck_block_const_init_is_const_c(arena: *ASTArena, block_ref: i32, const_idx: i32): i32;
export extern function pipeline_typeck_const_init_not_constant_c(line: i32, col: i32): void;
/**
 * PLATFORM: SHARED — typeck CTFE producer (write const_folded_*).
 * Authority for optim-level const fold is typeck/IR, not emit expansion.
 * fold_expr: pure lit trees; fold_block_const_init: const chain env;
 * fold_expr_in_block: let/return trees seeing block consts.
 */
export extern function pipeline_typeck_fold_expr_c(arena: *ASTArena, expr_ref: i32): void;
export extern function pipeline_typeck_fold_block_const_init_c(arena: *ASTArena, block_ref: i32,
const_idx: i32): void;
/**
 * wave423: stamp block const type_ref after inference from init.
 * @param arena *ASTArena
 * @param br i32 — block ref
 * @param ci i32 — const index in block
 * @param type_ref i32 — inferred type
 * @return i32 — 0 ok, -1 fail
 * PLATFORM: SHARED typeck/AST.
 */
export extern function pipeline_block_set_const_type_ref(arena: *ASTArena, br: i32, ci: i32,
type_ref: i32): i32;
export extern function pipeline_module_top_level_let_set_type_ref(module: *Module, idx: i32,
type_ref: i32): void;
export extern function pipeline_module_top_level_let_init_ref(module: *Module, idx: i32): i32;
export extern function pipeline_typeck_fold_expr_in_block_c(arena: *ASTArena, block_ref: i32,
expr_ref: i32): void;
/* See implementation. */
export extern function pipeline_expr_if_cond_ref_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_if_then_ref_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_if_else_ref_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_block_ref_at(arena: *ASTArena, expr_ref: i32): i32;
/* See implementation. */
export extern function pipeline_asm_block_final_expr_ref_at(arena: *ASTArena, block_ref: i32): i32;
export extern function pipeline_block_expr_stmt_ref(arena: *ASTArena, block_ref: i32, ei: i32): i32;
/** See implementation for details. */
export extern function pipeline_block_set_parent_if_zero(arena: *ASTArena, block_ref: i32, parent_ref: i32): i32;
/* See implementation. */
export extern function pipeline_expr_unary_operand_ref_at(arena: *ASTArena, expr_ref: i32): i32;
/* See implementation. */
export extern function pipeline_expr_call_callee_ref_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_call_num_args_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_call_arg_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
/* See implementation. */
export extern function pipeline_expr_index_base_ref(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_set_index_base_is_slice(arena: *ASTArena, expr_ref: i32,
v: i32): void;
export extern function pipeline_expr_set_index_proven_in_bounds(arena: *ASTArena, expr_ref: i32,
v: i32): void;
/* See implementation. */
export extern function pipeline_expr_as_operand_ref_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_as_target_type_ref_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_into(arena: *ASTArena, expr_ref: i32,
out: *u8): void;
export extern function pipeline_expr_field_access_name_len(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_set_field_access_offset(arena: *ASTArena, expr_ref: i32, offset: i32): void;
export extern function pipeline_expr_var_name_into(arena: *ASTArena, expr_ref: i32, out: *u8): void;
export extern function pipeline_expr_var_name_len(arena: *ASTArena, expr_ref: i32): i32;
/* See implementation. */
export extern function pipeline_block_resolve_var_type_ref(arena: *ASTArena, block_ref: i32, vname: *u8,
vlen: i32): i32;
export extern function pipeline_expr_method_call_base_ref_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_num_args_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_name_len(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_name_into(arena: *ASTArena, expr_ref: i32, out64: *u8): void;
/* See implementation. */
export extern function asm_qual_sym_layer_reset(): void;
export extern function asm_qual_sym_layer_push(bytes: *u8, len: i32): i32;
export extern function asm_qual_sym_layer_count(): i32;
export extern function asm_qual_sym_layer_len(i: i32): i32;
export extern function asm_qual_sym_layer_copy(i: i32, dst: *u8, cap: i32): void;
/* See implementation. */
export extern function driver_diagnostic_typeck_struct_padding_before(sname: *u8, sname_len: i32, gap: i32,
fname: *u8, fname_len: i32): void;
export extern function driver_diagnostic_typeck_struct_padding_trailing(sname: *u8, sname_len: i32,
gap: i32): void;
export extern function driver_diagnostic_typeck_struct_field_bad_size(sname: *u8, sname_len: i32,
fname: *u8, fname_len: i32): void;
/* See implementation. */
export extern function pipeline_module_num_struct_layouts_at(module: *Module): i32;
export extern function pipeline_module_struct_layout_alloc(module: *Module): i32;
export extern function pipeline_module_struct_layout_field_type_ref(module: *Module, layout_idx: i32,
j: i32): i32;
export extern function pipeline_module_struct_layout_field_offset_at(module: *Module, li: i32,
j: i32): i32;
export extern function pipeline_module_struct_layout_field_align_at(module: *Module, li: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_set_field_align(module: *Module, li: i32, j: i32, al: i32): void;
export extern function pipeline_struct_layout_next_field_offset_ex(module: *Module, arena: *ASTArena, layout_idx: i32,
new_field_type_ref: i32, field_align_req: i32): i32;
/* See implementation. */
export extern function pipeline_typeck_pad_fields_warn_layout(module: *Module, arena: *ASTArena, li: i32): void;
/* See implementation. */
export extern function pipeline_typeck_hot_reorder_warn_layout(module: *Module, arena: *ASTArena, li: i32): void;
export extern function pipeline_module_struct_layout_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_struct_layout_allow_padding_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_set_allow_padding(module: *Module, idx: i32,
  v: i32): void;
export extern function pipeline_module_struct_layout_packed_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_soa_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_set_soa(module: *Module, idx: i32, v: i32): void;
export extern function pipeline_module_import_path_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_path_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_import_kind_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_binding_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_binding_name_byte_at(module: *Module, idx: i32,
off: i32): u8;
export extern function pipeline_module_import_select_count_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_select_name_len(module: *Module, idx: i32, sel: i32): i32;
export extern function pipeline_module_import_select_name_byte_at(module: *Module, idx: i32, sel: i32,
off: i32): u8;
export extern function pipeline_module_top_level_let_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_top_level_let_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_top_level_let_type_ref(module: *Module, idx: i32): i32;
export extern function pipeline_module_top_level_let_is_const(module: *Module, idx: i32): i32;

/** Exported function `type_kind_ordinal`.
 * Implements `type_kind_ordinal`.
 * @param k TypeKind
 * @return i32
 */
export function type_kind_ordinal(k: TypeKind): i32 {
  let o: i32 = k as i32;
  let lo: i32 = TypeKind.TYPE_I32 as i32;
  let hi: i32 = TypeKind.TYPE_VOID as i32;
  if (o < lo) {
    return - 1;
  }
  if (o > hi) {
    return - 1;
  }
  return o;
}

/** Exported function `name_equal`.
 * Implements `name_equal`.
 * @param a *u8
 * @param a_len i32
 * @param b *u8
 * @param b_len i32
 * @return bool
 */
export function name_equal(a: *u8, a_len: i32, b: *u8, b_len: i32): bool {
  if (a_len != b_len || a_len <= 0) {
    return false;
  }
  let i: i32 = 0;
  while (i < a_len) {
    if (a[i] != b[i]) {
      return false;
    }
    i = i + 1;
  }
  return true;
}

/** Exported function `typeck_resolve_type_alias_ref_local`.
 * Implements `typeck_resolve_type_alias_ref_local`.
 * @param module *Module
 * @param arena *ASTArena
 * @param type_ref i32
 * @param depth i32
 * @return i32
 */
export function typeck_resolve_type_alias_ref_local(module: *Module, arena: *ASTArena, type_ref: i32, depth: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let type_name: u8[128] = [];
    let alias_count: i32 = 0;
    let alias_i: i32 = 0;
    let type_name_len: i32 = 0;
    let alias_name_len: i32 = 0;
    let alias_off: i32 = 0;
    let ord_named: i32 = 8;
    let alias_target_ref: i32 = 0;
    let max_depth: i32 = 32;
    if (module == 0 as *Module || arena == 0 as *ASTArena || ast.ref_is_null(type_ref) || depth > max_depth) {
      return type_ref;
    }
    if (pipeline_type_kind_ord_at(arena, type_ref) != ord_named) {
      return type_ref;
    }
    type_name_len = pipeline_type_named_name_into(arena, type_ref, &type_name[0]);
    if (type_name_len <= 0) {
      return type_ref;
    }
    alias_count = pipeline_module_num_type_aliases_at(module);
    while (alias_i < alias_count) {
      alias_name_len = pipeline_module_type_alias_name_len(module, alias_i);
      /* wave582 Cap residual: alias names may be up to 127 (TypeAliasEntry.name[128]). */
      if (alias_name_len == type_name_len && alias_name_len > 0 && alias_name_len <= 127) {
        alias_off = 0;
        while (alias_off < alias_name_len) {
          if (pipeline_module_type_alias_name_byte_at(module, alias_i, alias_off) != type_name[alias_off]) {
            break;
          }
          alias_off = alias_off + 1;
        }
        if (alias_off == alias_name_len) {
          alias_target_ref = pipeline_module_type_alias_target_ref(module, alias_i);
          if (ast.ref_is_null(alias_target_ref)) {
            return type_ref;
          }
          return typeck_resolve_type_alias_ref_local(module, arena, alias_target_ref, depth + 1);
        }
      }
      alias_i = alias_i + 1;
    }
    return type_ref;
  }
}

/** Function `typeck_named_type_matches_name_or_alias`.
 * Purpose: implements `typeck_named_type_matches_name_or_alias`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function typeck_named_type_matches_name_or_alias(module: *Module, arena: *ASTArena, decl_ty_ref: i32,
lit_name: *u8, lit_name_len: i32, depth: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let decl_name: u8[128] = [];
    let alias_name: u8[128] = [];
    let resolved_decl: i32 = 0;
    let decl_name_len: i32 = 0;
    let alias_count: i32 = 0;
    let alias_i: i32 = 0;
    let alias_name_len: i32 = 0;
    let alias_off: i32 = 0;
    let alias_target_ref: i32 = 0;
    let ord_named: i32 = 8;
    let max_depth: i32 = 32;
    if (module == 0 as *Module || arena == 0 as *ASTArena || ast.ref_is_null(decl_ty_ref)
    || lit_name == 0 as *u8 || lit_name_len <= 0 || depth > max_depth) {
      return false;
    }
    resolved_decl = typeck_resolve_type_alias_ref_local(module, arena, decl_ty_ref, 0);
    if (!ast.ref_is_null(resolved_decl) && pipeline_type_kind_ord_at(arena, resolved_decl) == ord_named) {
      decl_name_len = pipeline_type_named_name_into(arena, resolved_decl, &decl_name[0]);
      if (name_equal(&decl_name[0], decl_name_len, lit_name, lit_name_len)) {
        return true;
      }
    }
    if (pipeline_type_kind_ord_at(arena, decl_ty_ref) != ord_named) {
      return false;
    }
    decl_name_len = pipeline_type_named_name_into(arena, decl_ty_ref, &decl_name[0]);
    if (name_equal(&decl_name[0], decl_name_len, lit_name, lit_name_len)) {
      return true;
    }
    alias_count = pipeline_module_num_type_aliases_at(module);
    while (alias_i < alias_count) {
      alias_name_len = pipeline_module_type_alias_name_len(module, alias_i);
      /* wave582 Cap residual: alias names may be up to 127 (match resolve_type_alias). */
      if (alias_name_len == decl_name_len && alias_name_len > 0 && alias_name_len <= 127) {
        alias_off = 0;
        while (alias_off < alias_name_len) {
          alias_name[alias_off] = pipeline_module_type_alias_name_byte_at(module, alias_i, alias_off);
          alias_off = alias_off + 1;
        }
        if (name_equal(&alias_name[0], alias_name_len, &decl_name[0], decl_name_len)) {
          alias_target_ref = pipeline_module_type_alias_target_ref(module, alias_i);
          return typeck_named_type_matches_name_or_alias(module, arena, alias_target_ref, lit_name,
          lit_name_len, depth + 1);
        }
      }
      alias_i = alias_i + 1;
    }
    return false;
  }
}

/** Exported function `typeck_layout_name_equal`.
 * Implements `typeck_layout_name_equal`.
 * @param module *Module
 * @param k i32
 * @param nm *u8
 * @param nlen i32
 * @return bool
 */
export function typeck_layout_name_equal(module: *Module, k: i32, nm: *u8, nlen: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let buf: *u8 = typeck_scratch64_slot(0);
    let slen: i32 = pipeline_module_struct_layout_name_len(module, k);
    if (slen != nlen || nlen <= 0) {
      return false;
    }
    pipeline_module_struct_layout_name_into(module, k, buf);
    return name_equal(buf, slen, nm, nlen);
  }
}

/** Exported function `typeck_layout_field_name_equal`.
 * Implements `typeck_layout_field_name_equal`.
 * @param module *Module
 * @param k i32
 * @param j i32
 * @param nm *u8
 * @param nlen i32
 * @return bool
 */
export function typeck_layout_field_name_equal(module: *Module, k: i32, j: i32, nm: *u8, nlen: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let buf: *u8 = typeck_scratch64_slot(1);
    let fl: i32 = pipeline_module_struct_layout_field_name_len(module, k, j);
    if (fl != nlen || nlen <= 0) {
      return false;
    }
    pipeline_module_struct_layout_field_name_into(module, k, j, buf);
    return name_equal(buf, fl, nm, nlen);
  }
}

/** Exported function `typeck_layout_name_into`.
 * Implements `typeck_layout_name_into`.
 * @param module *Module
 * @param k i32
 * @param buf *u8
 * @return i32
 */
export function typeck_layout_name_into(module: *Module, k: i32, buf: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    pipeline_module_struct_layout_name_into(module, k, buf);
    return pipeline_module_struct_layout_name_len(module, k);
  }
}

/** Exported function `typeck_layout_field_name_into`.
 * Implements `typeck_layout_field_name_into`.
 * @param module *Module
 * @param k i32
 * @param j i32
 * @param buf *u8
 * @return i32
 */
export function typeck_layout_field_name_into(module: *Module, k: i32, j: i32, buf: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    pipeline_module_struct_layout_field_name_into(module, k, j, buf);
    return pipeline_module_struct_layout_field_name_len(module, k, j);
  }
}

/* See implementation. */
export function typeck_import_path_slice_equal(module: *Module, imp_ix: i32, off: i32, seg_len: i32,
nm: *u8, nm_len: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (seg_len != nm_len || seg_len <= 0) {
      return false;
    }
    let i: i32 = 0;
    while (i < seg_len) {
      if (pipeline_module_import_path_byte_at(module, imp_ix, off + i) != nm[i]) {
        return false;
      }
      i = i + 1;
    }
    return true;
  }
}

/* See implementation. */
export function typeck_import_binding_name_equal(module: *Module, imp_ix: i32, nm: *u8,
nm_len: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let bl: i32 = pipeline_module_import_binding_name_len(module, imp_ix);
    if (bl != nm_len || nm_len <= 0) {
      return false;
    }
    let i: i32 = 0;
    while (i < nm_len) {
      if (pipeline_module_import_binding_name_byte_at(module, imp_ix, i) != nm[i]) {
        return false;
      }
      i = i + 1;
    }
    return true;
  }
}

/** Exported function `typeck_module_num_imports`.
 * Implements `typeck_module_num_imports`.
 * @param module *Module
 * @return i32
 */
export function typeck_module_num_imports(module: *Module): i32 {
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

/** Exported function `typeck_var_is_import_visible_name`.
 * Implements `typeck_var_is_import_visible_name`.
 * @param module *Module
 * @param nm *u8
 * @param nlen i32
 * @return bool
 */
export function typeck_var_is_import_visible_name(module: *Module, nm: *u8, nlen: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ii: i32 = 0;
    let import_kind: i32 = 0;
    let seg_rel: i32 = 0;
    let seg_len: i32 = 0;
    if (module == 0 as *Module || nm == 0 as *u8 || nlen <= 0) {
      return false;
    }
    let n_imp: i32 = typeck_module_num_imports(module);
    while (ii < n_imp) {
      import_kind = pipeline_module_import_kind_at(module, ii);
      if (import_kind == 1 && typeck_import_binding_name_equal(module, ii, nm, nlen)) {
        return true;
      }
      if (typeck_import_segment_at(module, ii, 0, &seg_rel, &seg_len) &&
          typeck_import_path_slice_equal(module, ii, seg_rel, seg_len, nm, nlen)) {
        return true;
      }
      ii = ii + 1;
    }
    return false;
  }
}

/* See implementation. */
export function typeck_import_select_name_equal(module: *Module, imp_ix: i32, sel: i32, nm: *u8,
nm_len: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let sl: i32 = pipeline_module_import_select_name_len(module, imp_ix, sel);
    if (sl != nm_len || nm_len <= 0) {
      return false;
    }
    let i: i32 = 0;
    while (i < nm_len) {
      if (pipeline_module_import_select_name_byte_at(module, imp_ix, sel, i) != nm[i]) {
        return false;
      }
      i = i + 1;
    }
    return true;
  }
}

/** Exported function `typeck_top_level_let_name_equal`.
 * Implements `typeck_top_level_let_name_equal`.
 * @param module *Module
 * @param tl_ix i32
 * @param nm *u8
 * @param nm_len i32
 * @return bool
 */
export function typeck_top_level_let_name_equal(module: *Module, tl_ix: i32, nm: *u8, nm_len: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let tll: i32 = pipeline_module_top_level_let_name_len(module, tl_ix);
    if (tll != nm_len || nm_len <= 0) {
      return false;
    }
    let i: i32 = 0;
    while (i < nm_len) {
      if (pipeline_module_top_level_let_name_byte_at(module, tl_ix, i) != nm[i]) {
        return false;
      }
      i = i + 1;
    }
    return true;
  }
}

/** Exported function `typeck_dep_module_const_idx_named`.
 * Implements `typeck_dep_module_const_idx_named`.
 * @param module *Module
 * @param nm *u8
 * @param nlen i32
 * @param tl_ix i32
 * @return i32
 */
export function typeck_dep_module_const_idx_named(module: *Module, nm: *u8, nlen: i32, tl_ix: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (module == 0 as *Module || nm == 0 as *u8 || nlen <= 0) {
      return -1;
    }
    if (tl_ix >= module.num_top_level_lets) {
      return -1;
    }
    if (pipeline_module_top_level_let_is_const(module, tl_ix) != 0
    && typeck_top_level_let_name_equal(module, tl_ix, nm, nlen)) {
      return tl_ix;
    }
    return typeck_dep_module_const_idx_named(module, nm, nlen, tl_ix + 1);
  }
}

/* See implementation. */
export function typeck_find_import_const_dep_index(module: *Module, ctx: *PipelineDepCtx, nm: *u8, nlen: i32,
dep_ix: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let dm: *Module = 0 as *Module;
    if (module == 0 as *Module || ctx == 0 as *PipelineDepCtx || nm == 0 as *u8 || nlen <= 0) {
      return -1;
    }
    if (dep_ix >= typeck_module_num_imports(module)) {
      return -1;
    }
    dm = pipeline_dep_ctx_module_at(ctx, dep_ix);
    if (dm != 0 as *Module && typeck_dep_module_const_idx_named(dm, nm, nlen, 0) >= 0) {
      return dep_ix;
    }
    return typeck_find_import_const_dep_index(module, ctx, nm, nlen, dep_ix + 1);
  }
}

/** Exported function `typeck_import_last_segment_into`.
 * Implements `typeck_import_last_segment_into`.
 * @param module *Module
 * @param imp_ix i32
 * @param out *u8
 * @return i32
 */
export function typeck_import_last_segment_into(module: *Module, imp_ix: i32, out: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let pl: i32 = 0;
    let start: i32 = 0;
    let i: i32 = 0;
    let seg_len: i32 = 0;
    if (module == 0 as *Module || out == 0 as *u8 || imp_ix < 0 || imp_ix >= typeck_module_num_imports(module)) {
      return 0;
    }
    pl = pipeline_module_import_path_len(module, imp_ix);
    if (pl <= 0 || pl > 127) {
      return 0;
    }
    while (i < pl) {
      if (pipeline_module_import_path_byte_at(module, imp_ix, i) == 46) {
        start = i + 1;
      }
      i = i + 1;
    }
    seg_len = pl - start;
    if (seg_len <= 0 || seg_len > 127) {
      return 0;
    }
    i = 0;
    while (i < seg_len) {
      out[i] = pipeline_module_import_path_byte_at(module, imp_ix, start + i);
      i = i + 1;
    }
    return seg_len;
  }
}

/** Exported function `typeck_resolve_dep_index_for_import`.
 * Implements `typeck_resolve_dep_index_for_import`.
 * @param module *Module
 * @param ctx *PipelineDepCtx
 * @param imp_ix i32
 * @return i32
 */
export function typeck_resolve_dep_index_for_import(module: *Module, ctx: *PipelineDepCtx, imp_ix: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let plen: i32 = 0;
    let dep_i: i32 = 0;
    let nd: i32 = 0;
    let path_buf: u8[128] = [];
    if (module == 0 as *Module || ctx == 0 as *PipelineDepCtx || imp_ix < 0 || imp_ix >= typeck_module_num_imports(module)) {
      return -1;
    }
    plen = pipeline_module_import_path_len(module, imp_ix);
    if (plen <= 0 || plen > 127) {
      return -1;
    }
    while (dep_i < plen) {
      path_buf[dep_i] = pipeline_module_import_path_byte_at(module, imp_ix, dep_i);
      dep_i = dep_i + 1;
    }
    nd = pipeline_dep_ctx_ndep(ctx);
    dep_i = 0;
    while (dep_i < nd) {
      let dep_plen: i32 = pipeline_dep_ctx_import_path_len(ctx, dep_i);
      if (dep_plen == plen) {
        let dep_buf: u8[128] = [];
        let eq: bool = true;
        let k: i32 = 0;
        pipeline_dep_ctx_import_path_copy64(ctx, dep_i, &dep_buf[0]);
        while (k < plen) {
          if (dep_buf[k] != path_buf[k]) {
            eq = false;
            break;
          }
          k = k + 1;
        }
        if (eq) {
          return dep_i;
        }
      }
      dep_i = dep_i + 1;
    }
    return -1;
  }
}

/** Exported function `typeck_import_const_binding_hint_at`.
 * Implements `typeck_import_const_binding_hint_at`.
 * @param module *Module
 * @param dep_ix i32
 * @param out *u8
 * @return i32
 */
export function typeck_import_const_binding_hint_at(module: *Module, dep_ix: i32, out: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let import_kind: i32 = 0;
    let bl: i32 = 0;
    let i: i32 = 0;
    if (module == 0 as *Module || out == 0 as *u8 || dep_ix < 0 || dep_ix >= typeck_module_num_imports(module)) {
      return 0;
    }
    import_kind = pipeline_module_import_kind_at(module, dep_ix);
    if (import_kind == 1) {
      bl = pipeline_module_import_binding_name_len(module, dep_ix);
      /* wave584 Cap residual: binding hint content ≤127 (binding_name[128]). */
      if (bl > 0 && bl <= 127) {
        while (i < bl) {
          out[i] = pipeline_module_import_binding_name_byte_at(module, dep_ix, i);
          i = i + 1;
        }
        return bl;
      }
    }
    return typeck_import_last_segment_into(module, dep_ix, out);
  }
}

/**
* See implementation.
*/
export function typeck_find_layout_idx_by_type_name(module: *Module, nm: *u8, nlen: i32): i32 {
  let k: i32 = 0;
  while (k < module.num_struct_layouts) {
    if (typeck_layout_name_equal(module, k, nm, nlen)) {
      return k;
    }
    k = k + 1;
  }
  return - 1;
}

/** Exported function `typeck_x_named_builtin_align`.
 * Implements `typeck_x_named_builtin_align`.
 * @param nm *u8
 * @param nlen i32
 * @return i32
 */
export function typeck_x_named_builtin_align(nm: *u8, nlen: i32): i32 {
  if (nm == 0 as *u8 || nlen <= 0) {
    return 0;
  }
  if (nlen == 3 && nm[0] == 105 && nm[1] == 51 && nm[2] == 50) { return 4; }
  if (nlen == 3 && nm[0] == 117 && nm[1] == 51 && nm[2] == 50) { return 4; }
  if (nlen == 4 && nm[0] == 98 && nm[1] == 111 && nm[2] == 111 && nm[3] == 108) { return 4; }
  if (nlen == 2 && nm[0] == 117 && nm[1] == 56) { return 1; }
  if (nlen == 3 && nm[0] == 105 && nm[1] == 54 && nm[2] == 52) { return 8; }
  if (nlen == 3 && nm[0] == 117 && nm[1] == 54 && nm[2] == 52) { return 8; }
  if (nlen == 5 && nm[0] == 117 && nm[1] == 115 && nm[2] == 105 && nm[3] == 122 && nm[4] == 101) { 
  return 8; }
  if (nlen == 5 && nm[0] == 105 && nm[1] == 115 && nm[2] == 105 && nm[3] == 122 && nm[4] == 101) { 
  return 8; }
  if (nlen == 3 && nm[0] == 102 && nm[1] == 51 && nm[2] == 50) { return 4; }
  if (nlen == 3 && nm[0] == 102 && nm[1] == 54 && nm[2] == 52) { return 8; }
  return 0;
}

/** Exported function `typeck_x_named_builtin_size`.
 * Implements `typeck_x_named_builtin_size`.
 * @param nm *u8
 * @param nlen i32
 * @return i32
 */
export function typeck_x_named_builtin_size(nm: *u8, nlen: i32): i32 {
  let a: i32 = typeck_x_named_builtin_align(nm, nlen);
  if (a == 1 && nlen == 2 && nm[0] == 117 && nm[1] == 56) { return 1; }
  if (a == 4) { return 4; }
  if (a == 8) { return 8; }
  return 0;
}

/** Exported function `typeck_x_type_align`.
 * Implements `typeck_x_type_align`.
 * @param module *Module
 * @param arena *ASTArena
 * @param ty_ref i32
 * @param depth i32
 * @return i32
 */
export function typeck_x_type_align(module: *Module, arena: *ASTArena, ty_ref: i32, depth: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ko: i32 = 0;
    let er: i32 = 0;
    let nm_len: i32 = 0;
    let li: i32 = 0;
    let ba: i32 = 0;
    let nm_buf: *u8 = typeck_scratch64_slot(4);
    if (ast.ref_is_null(ty_ref) || ty_ref <= 0 || ty_ref > arena.num_types || depth > 64) {
      return 1;
    }
    ko = pipeline_type_kind_ord_at(arena, ty_ref);
    if (ko == 2) {
      return 1;
    }
    if (ko == 0 || ko == 3 || ko == 1 || ko == 14) {
      return 4;
    }
    if (ko == 5 || ko == 4 || ko == 6 || ko == 7 || ko == 15 || ko == 9) {
      return 8;
    }
    if (ko == 11) {
      return 8;
    }
    /* See implementation. */
    if (ko == 10 || ko == 12 || ko == 13) {
      er = pipeline_type_elem_ref_at(arena, ty_ref);
      if (ast.ref_is_null(er)) {
        return 1;
      }
      return typeck_x_type_align(module, arena, er, depth + 1);
    }
    if (ko == 8) {
      /* See implementation. */
      nm_len = pipeline_type_named_name_into(arena, ty_ref, nm_buf);
      li = typeck_find_layout_idx_by_type_name(module, nm_buf, nm_len);
      if (li >= 0) {
        return typeck_x_type_align_from_layout_glue(module, arena, li, depth + 1);
      }
      ba = typeck_x_named_builtin_align(nm_buf, nm_len);
      if (ba > 0) {
        return ba;
      }
      return 4;
    }
    return 1;
  }
}

/**
 * Return 1 when ty_ref is a TYPE_NAMED ZST layout: zero fields, or every field is
 * itself an empty struct (empty-of-empty nest). Host C sizeof Empty / NestEmpty is 0.
 * Layout metrics accept fsize==0 only when this returns 1; unknown types still fail.
 * @param module *Module — owning module for struct_layouts
 * @param arena *ASTArena — type pool for kind/name
 * @param ty_ref i32 — field or local type ref
 * @param depth i32 — recursion depth; >64 → 0 (cycle / absurd nest guard)
 * @return i32 — 1 empty named ZST layout, 0 otherwise
 * PLATFORM: SHARED — matches GCC empty-struct size 0 / A{e:Empty} nest ZST
 */
export function typeck_type_is_empty_struct(module: *Module, arena: *ASTArena, ty_ref: i32, depth: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ko: i32 = 0;
    let nm_len: i32 = 0;
    let li: i32 = 0;
    let nf: i32 = 0;
    let j: i32 = 0;
    let ftr: i32 = 0;
    let nm: *u8 = typeck_scratch64_slot(4);
    if (module == 0 as *Module || arena == 0 as *ASTArena || ty_ref <= 0) {
      return 0;
    }
    if (ty_ref > arena.num_types || depth > 64) {
      return 0;
    }
    ko = pipeline_type_kind_ord_at(arena, ty_ref);
    /* TYPE_NAMED ord == 8 */
    if (ko != 8) {
      return 0;
    }
    nm_len = pipeline_type_named_name_into(arena, ty_ref, nm);
    if (nm_len <= 0) {
      return 0;
    }
    li = typeck_find_layout_idx_by_type_name(module, nm, nm_len);
    if (li < 0) {
      return 0;
    }
    nf = pipeline_module_struct_layout_num_fields(module, li);
    /* wave366: nf==0 bare empty struct. */
    if (nf == 0) {
      return 1;
    }
    /* wave368: all fields empty ZSTs → nested empty-of-empty is also ZST. */
    j = 0;
    while (j < nf) {
      ftr = pipeline_module_struct_layout_field_type_ref(module, li, j);
      if (typeck_type_is_empty_struct(module, arena, ftr, depth + 1) == 0) {
        return 0;
      }
      j = j + 1;
    }
    return 1;
  }
}

/** Exported function `typeck_x_type_size`.
 * Implements `typeck_x_type_size`.
 * @param module *Module
 * @param arena *ASTArena
 * @param ty_ref i32
 * @param depth i32
 * @return i32
 */
export function typeck_x_type_size(module: *Module, arena: *ASTArena, ty_ref: i32, depth: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ko: i32 = 0;
    let er: i32 = 0;
    let asz: i32 = 0;
    let es: i32 = 0;
    let nm_len: i32 = 0;
    let li2: i32 = 0;
    let bsz: i32 = 0;
    let nm_buf_sz: *u8 = typeck_scratch64_slot(4);
    if (ast.ref_is_null(ty_ref) || ty_ref <= 0 || ty_ref > arena.num_types || depth > 64) {
      return 0;
    }
    ko = pipeline_type_kind_ord_at(arena, ty_ref);
    if (ko == 16) {
      return 0;
    }
    if (ko == 2) {
      return 1;
    }
    if (ko == 0 || ko == 3 || ko == 1 || ko == 14) {
      return 4;
    }
    if (ko == 5 || ko == 4 || ko == 6 || ko == 7 || ko == 15 || ko == 9) {
      return 8;
    }
    if (ko == 11) {
      return 16;
    }
    /* See implementation. */
    if (ko == 12) {
      er = pipeline_type_elem_ref_at(arena, ty_ref);
      if (ast.ref_is_null(er)) {
        return 0;
      }
      return typeck_x_type_size(module, arena, er, depth + 1);
    }
    if (ko == 10 || ko == 13) {
      er = pipeline_type_elem_ref_at(arena, ty_ref);
      asz = pipeline_type_array_size_at(arena, ty_ref);
      if (ast.ref_is_null(er) || asz <= 0) {
        return 0;
      }
      let soa_sz: i32 = typeck_soa_array_storage_size_glue(module, arena, er, asz, depth + 1);
      if (soa_sz > 0) {
        return soa_sz;
      }
      es = typeck_x_type_size(module, arena, er, depth + 1);
      if (es <= 0) {
        return 0;
      }
      return asz * es;
    }
    if (ko == 8) {
      nm_len = pipeline_type_named_name_into(arena, ty_ref, nm_buf_sz);
      li2 = typeck_find_layout_idx_by_type_name(module, nm_buf_sz, nm_len);
      if (li2 >= 0) {
        return typeck_x_type_size_from_layout_glue(module, arena, li2, depth + 1);
      }
      bsz = typeck_x_named_builtin_size(nm_buf_sz, nm_len);
      if (bsz > 0) {
        return bsz;
      }
      return 4;
    }
    return 0;
  }
}

/**
 * R2 (8.3.3): SoA layout 按名查索引 — migrated from C bypass (pipeline_typeck_soa.c)
 * to .x authority. 按名比对 module 的 struct_layouts，命中返回 idx，未命中 -1。
 * PLATFORM: SHARED — G.7 single authority; .x -> typeck_gen.c -> typeck_x.o.
 */
export function typeck_soa_find_layout_idx_by_name(module: *Module, name: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let k: i32 = 0;
    let j: i32 = 0;
    let ln: i32 = 0;
    let eq: i32 = 0;
    if (module == 0 as *Module || name == 0 as *u8 || name_len <= 0 || name_len > 127) {
      return -1;
    }
    k = 0;
    while (k < pipeline_module_num_struct_layouts_at(module)) {
      ln = pipeline_module_struct_layout_name_len(module, k);
      if (ln == name_len) {
        j = 0;
        eq = 1;
        while (j < name_len) {
          if (pipeline_module_struct_layout_name_byte_at(module, k, j) != name[j]) {
            eq = 0;
            break;
          }
          j = j + 1;
        }
        if (eq != 0) {
          return k;
        }
      }
      k = k + 1;
    }
    return -1;
  }
}

/**
 * R2 (8.3.3): Find SoA struct layout by name in the current module or the
 * WPO dep pool; on hit write the owning module into *out_layout_mod.
 *
 * Migrated from C static helper (pipeline_typeck_soa.c) to .x authority.
 * First probes the local module via typeck_soa_find_layout_idx_by_name; if
 * miss, walks pipeline_asm_emit_dep_pipe_c() deps with the same name probe.
 *
 * @param module *Module — primary module (also default *out_layout_mod)
 * @param name *u8 — layout / TYPE_NAMED bytes (not required to be NUL-terminated)
 * @param name_len i32 — byte count; must be > 0 (caller caps typically <= 127)
 * @param out_layout_mod **Module — optional out: module that owns the hit layout
 * @return i32 — layout index >= 0 on hit; -1 when not found / bad input
 * PLATFORM: SHARED — G.7 single authority; .x -> typeck_gen.c -> typeck_x.o.
 */
export function typeck_soa_find_layout_module_and_idx(module: *Module, name: *u8, name_len: i32,
  out_layout_mod: **Module): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let li: i32 = 0;
    let pipe: *PipelineDepCtx = 0 as *PipelineDepCtx;
    let nd: i32 = 0;
    let di: i32 = 0;
    let dm: *Module = 0 as *Module;
    let om_bytes: *u8 = out_layout_mod as *u8;
    /* Default out owner to primary module when out pointer is non-null. */
    if (om_bytes != 0 as *u8) {
      out_layout_mod[0] = module;
    }
    if (module == 0 as *Module || name == 0 as *u8 || name_len <= 0) {
      return -1;
    }
    li = typeck_soa_find_layout_idx_by_name(module, name, name_len);
    if (li >= 0) {
      return li;
    }
    pipe = pipeline_asm_emit_dep_pipe_c();
    if (pipe == 0 as *PipelineDepCtx) {
      return -1;
    }
    nd = pipeline_dep_ctx_ndep(pipe);
    di = 0;
    while (di < nd) {
      dm = pipeline_dep_ctx_module_at(pipe, di);
      if (dm != 0 as *Module) {
        li = typeck_soa_find_layout_idx_by_name(dm, name, name_len);
        if (li >= 0) {
          if (om_bytes != 0 as *u8) {
            out_layout_mod[0] = dm;
          }
          return li;
        }
      }
      di = di + 1;
    }
    return -1;
  }
}

/**
 * R2 (8.3.3): SoA column base for field fi — columns before fi occupy
 * N * sizeof(field) with per-column align padding.
 *
 * Migrated from C bypass (pipeline_typeck_soa.c) to .x authority.
 * Uses typeck_x_type_align / typeck_x_type_size (G.7 twins) instead of
 * C glue_type_align_simple / glue_type_size_simple so SoA sizing no longer
 * depends on host-cc glue residual for field stride math.
 *
 * @param module *Module — layout owner module
 * @param arena *ASTArena — type arena
 * @param li i32 — struct_layouts index
 * @param field_idx i32 — exclusive end field index (0..num_fields)
 * @param array_len i32 — SoA array length N
 * @param depth i32 — recursion depth (cap 64; forwarded to type size/align)
 * @return i32 — byte offset of column base for field_idx (0 on bad input)
 * PLATFORM: SHARED — G.7 single authority; .x -> typeck_gen.c -> typeck_x.o.
 */
export function typeck_soa_col_base_for_field(module: *Module, arena: *ASTArena, li: i32,
  field_idx: i32, array_len: i32, depth: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let col: i32 = 0;
    let j: i32 = 0;
    let nf: i32 = 0;
    let ftr: i32 = 0;
    let A: i32 = 0;
    let fsize: i32 = 0;
    let rem: i32 = 0;
    let gap: i32 = 0;
    if (module == 0 as *Module || arena == 0 as *ASTArena || li < 0 || field_idx < 0 || array_len <= 0 || depth > 64) {
      return 0;
    }
    col = 0;
    nf = pipeline_module_struct_layout_num_fields(module, li);
    j = 0;
    while (j < nf && j < field_idx) {
      ftr = pipeline_module_struct_layout_field_type_ref(module, li, j);
      if (ftr > 0) {
        A = typeck_x_type_align(module, arena, ftr, depth);
        fsize = typeck_x_type_size(module, arena, ftr, depth);
        if (A <= 0) {
          A = 1;
        }
        if (fsize <= 0) {
          fsize = 4;
        }
        rem = col % A;
        gap = A - rem;
        gap = gap % A;
        col = col + gap + array_len * fsize;
      }
      j = j + 1;
    }
    return col;
  }
}

/**
 * R2 (8.3.3): EXPR_FIELD_ACCESS with INDEX base — SoA `arr[i].field` stamps
 * col_base + stride on the field-access node.
 *
 * Migrated from C `pipeline_typeck_field_soa_index_c` (pipeline_typeck_soa.c)
 * to .x authority. Stride uses typeck_x_type_size (G.7 twin) instead of
 * host-cc glue_type_size_simple so column math no longer depends on glue residual.
 *
 * Contract:
 *  - Returns 1 when this is a SoA path and col_base/stride/type were written.
 *  - Returns 0 when not SoA / incomplete types / layout miss (caller falls back).
 *  - Skip-typeck VAR bases without resolved_type fall back to emit-func params
 *    then a full-module param scan (matches prior C behavior).
 *
 * @param module *Module — primary module (layouts may resolve via WPO deps)
 * @param arena *ASTArena — expr/type arena
 * @param expr_ref i32 — FIELD_ACCESS expr
 * @param base_ref i32 — field base; must be INDEX (kind ord 47) for SoA path
 * @return i32 — 1 handled SoA, 0 not handled
 * PLATFORM: SHARED — G.7 single authority; .x -> typeck_gen.c -> typeck_x.o.
 */
export function typeck_soa_field_soa_index(module: *Module, arena: *ASTArena, expr_ref: i32,
  base_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ix_base_ref: i32 = 0;
    let base_ty: i32 = 0;
    let bt_kind: i32 = 0;
    let elem_ty: i32 = 0;
    let array_sz: i32 = 0;
    let elem_nm: u8[128] = [];
    let elem_nlen: i32 = 0;
    let li: i32 = 0;
    let fl: i32 = 0;
    let fn_buf: u8[128] = [];
    let j: i32 = 0;
    let fnlen: i32 = 0;
    let ftr: i32 = 0;
    let col_base: i32 = 0;
    let stride: i32 = 0;
    let layout_mod: *Module = module;
    let fi: i32 = 0;
    let vname: u8[128] = [];
    let vlen: i32 = 0;
    let nfuncs: i32 = 0;
    let feq: i32 = 0;
    let bi: i32 = 0;
    let fb: u8[128] = [];
    if (module == 0 as *Module || arena == 0 as *ASTArena || expr_ref <= 0 || base_ref <= 0) {
      return 0;
    }
    /* INDEX kind ord == 47 */
    if (pipeline_expr_kind_ord_at(arena, base_ref) != 47) {
      return 0;
    }
    ix_base_ref = pipeline_expr_index_base_ref(arena, base_ref);
    if (ix_base_ref <= 0) {
      return 0;
    }
    base_ty = pipeline_expr_resolved_type_ref(arena, ix_base_ref);
    /* Skip-.x typeck: param VAR often lacks resolved_type; recover from emit func
     * formal table, then scan all module funcs (same as prior C path). */
    if (base_ty <= 0 && pipeline_expr_kind_ord_at(arena, ix_base_ref) == 3) {
      vlen = pipeline_expr_var_name_len(arena, ix_base_ref);
      if (vlen > 0 && vlen <= 127) {
        pipeline_expr_var_name_into(arena, ix_base_ref, &vname[0]);
        nfuncs = pipeline_module_num_funcs(module);
        fi = pipeline_asm_emit_func_index_c();
        if (fi >= 0 && fi < nfuncs) {
          base_ty = pipeline_module_func_param_type_ref_for_name(module, fi, &vname[0], vlen);
        }
        if (base_ty <= 0) {
          fi = 0;
          while (fi < nfuncs) {
            base_ty = pipeline_module_func_param_type_ref_for_name(module, fi, &vname[0], vlen);
            if (base_ty > 0) {
              break;
            }
            fi = fi + 1;
          }
        }
        if (base_ty > 0) {
          pipeline_expr_set_resolved_type_ref(arena, ix_base_ref, base_ty);
        }
      }
    }
    if (base_ty <= 0 || base_ty > arena.num_types) {
      return 0;
    }
    bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
    /* TYPE_ARRAY=10, TYPE_ARRAY_SLICE-like storage=13 (product uses both). */
    if (bt_kind != 10 && bt_kind != 13) {
      return 0;
    }
    elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
    array_sz = pipeline_type_array_size_at(arena, base_ty);
    if (elem_ty <= 0 || array_sz <= 0) {
      return 0;
    }
    /* TYPE_NAMED ord == 8 */
    if (pipeline_type_kind_ord_at(arena, elem_ty) != 8) {
      return 0;
    }
    elem_nlen = pipeline_type_named_name_into(arena, elem_ty, &elem_nm[0]);
    if (elem_nlen <= 0 || elem_nlen > 127) {
      return 0;
    }
    li = typeck_soa_find_layout_module_and_idx(module, &elem_nm[0], elem_nlen, &layout_mod);
    if (li < 0 || layout_mod == 0 as *Module || pipeline_module_struct_layout_soa_at(layout_mod, li) == 0) {
      return 0;
    }
    fl = pipeline_expr_field_access_name_len(arena, expr_ref);
    if (fl <= 0 || fl > 127) {
      return 0;
    }
    pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
    ftr = 0;
    stride = 0;
    col_base = 0;
    j = 0;
    while (j < pipeline_module_struct_layout_num_fields(layout_mod, li)) {
      fnlen = pipeline_module_struct_layout_field_name_len(layout_mod, li, j);
      if (fnlen == fl) {
        pipeline_module_struct_layout_field_name_into(layout_mod, li, j, &fb[0]);
        feq = 1;
        bi = 0;
        while (bi < fnlen) {
          if (fb[bi] != fn_buf[bi]) {
            feq = 0;
            break;
          }
          bi = bi + 1;
        }
        if (feq != 0) {
          ftr = pipeline_module_struct_layout_field_type_ref(layout_mod, li, j);
          /* G.7: stride from typeck_x_type_size authority (not glue_type_size_simple). */
          stride = typeck_x_type_size(layout_mod, arena, ftr, 0);
          if (stride <= 0) {
            stride = 4;
          }
          col_base = typeck_soa_col_base_for_field(layout_mod, arena, li, j, array_sz, 0);
          break;
        }
      }
      j = j + 1;
    }
    if (ftr <= 0) {
      return 0;
    }
    pipeline_expr_set_field_access_offset(arena, expr_ref, col_base);
    pipeline_expr_set_field_access_soa_stride(arena, expr_ref, stride);
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, ftr);
    return 1;
  }
}

/**
 * DOD-S1: SoAStruct[N] column-major total byte size; returns 0 when elem is
 * not SoA or layout not found.
 *
 * wave1219: migrated from C bypass (pipeline_typeck_soa.c) to .x authority.
 * Calls typeck_soa_find_layout_idx_by_name / typeck_soa_col_base_for_field
 * (.x authority after 8.3.3 R2). Uses typeck_x_type_align for the max-field-align
 * tail loop (G.7 twin, same semantics).
 *
 * @param module *Module
 * @param arena *ASTArena
 * @param elem_type_ref i32 — candidate SoA struct element type_ref
 * @param array_len i32 — SoA array length N
 * @param depth i32 — recursion depth (cap 64)
 * @return i32 — column-major total bytes, or 0 if not SoA / not found
 * PLATFORM: SHARED — G.7 single authority; .x -> typeck_gen.c -> typeck_x.o.
 */
export function typeck_soa_array_storage_size_glue(module: *Module, arena: *ASTArena, elem_type_ref: i32,
  array_len: i32, depth: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let nm: u8[128] = [];
    let nlen: i32 = 0;
    let li: i32 = 0;
    let nf: i32 = 0;
    let col: i32 = 0;
    let max_al: i32 = 0;
    let j: i32 = 0;
    let ftr: i32 = 0;
    let A: i32 = 0;
    if (module == 0 as *Module || arena == 0 as *ASTArena || elem_type_ref <= 0 || array_len <= 0 || depth > 64) {
      return 0;
    }
    /* TYPE_NAMED ord == 8 */
    if (pipeline_type_kind_ord_at(arena, elem_type_ref) != 8) {
      return 0;
    }
    nlen = pipeline_type_named_name_into(arena, elem_type_ref, &nm[0]);
    if (nlen <= 0 || nlen > 127) {
      return 0;
    }
    li = typeck_soa_find_layout_idx_by_name(module, &nm[0], nlen);
    if (li < 0 || pipeline_module_struct_layout_soa_at(module, li) == 0) {
      return 0;
    }
    /* Only when elem is a SoA struct: column-major size; non-SoA falls back to AoS. */
    nf = pipeline_module_struct_layout_num_fields(module, li);
    col = typeck_soa_col_base_for_field(module, arena, li, nf, array_len, depth + 1);
    max_al = 1;
    j = 0;
    while (j < nf) {
      ftr = pipeline_module_struct_layout_field_type_ref(module, li, j);
      if (ftr > 0) {
        A = typeck_x_type_align(module, arena, ftr, depth + 1);
        if (A > max_al) {
          max_al = A;
        }
      }
      j = j + 1;
    }
    if (max_al > 1 && (col % max_al) != 0) {
      col = col + (max_al - (col % max_al));
    }
    if (col > 0) {
      return col;
    }
    return 0;
  }
}

/**
* See implementation.
* See implementation.
*/
export function typeck_struct_layout_metrics(module: *Module, arena: *ASTArena, li: i32, depth: i32,
check_pad: i32, out_sz: *i32, out_al: *i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    /* See implementation. */
    let nf: i32 = 0;
    let allow: i32 = 0;
    let layout_nlen: i32 = 0;
    let current: i32 = 0;
    let max_align: i32 = 1;
    let j: i32 = 0;
    let ftr: i32 = 0;
    let flen: i32 = 0;
    let A: i32 = 0;
    let rem: i32 = 0;
    let gap: i32 = 0;
    let fsize: i32 = 0;
    let end_pad: i32 = 0;
    let fa: i32 = 0;
    /* See implementation. */
    let layout_nm: *u8 = typeck_scratch64_slot(2);
    let field_nm: *u8 = typeck_scratch64_slot(3);
    if (module == 0 as *Module || arena == 0 as *ASTArena || out_sz == 0 as *i32 || out_al == 0 as 
    *i32) {
      return - 1;
    }
    if (li < 0 || li >= pipeline_module_num_struct_layouts_at(module) || depth > 64) {
      return - 1;
    }
    nf = pipeline_module_struct_layout_num_fields(module, li);
    allow = pipeline_module_struct_layout_allow_padding_at(module, li);
    typeck_layout_name_into(module, li, layout_nm);
    layout_nlen = pipeline_module_struct_layout_name_len(module, li);
    current = 0;
    max_align = 1;
    /* See implementation. */
    if (pipeline_module_struct_layout_packed_at(module, li) != 0) {
      j = 0;
      while (j < nf) {
        ftr = pipeline_module_struct_layout_field_type_ref(module, li, j);
        fsize = typeck_x_type_size(module, arena, ftr, depth);
        /* wave366/368: fsize==0 OK for empty / empty-of-empty named ZST fields. */
        if (fsize < 0 || (fsize == 0 && typeck_type_is_empty_struct(module, arena, ftr, depth) == 0)) {
          /* See implementation. */
          if (check_pad != 0) {
            typeck_layout_field_name_into(module, li, j, field_nm);
            flen = pipeline_module_struct_layout_field_name_len(module, li, j);
            driver_diagnostic_typeck_struct_field_bad_size(layout_nm, layout_nlen, field_nm, flen);
          }
          return - 1;
        }
        current = current + fsize;
        j = j + 1;
      }
      typeck_i32_ptr_store(out_sz, current);
      typeck_i32_ptr_store(out_al, 1);
      return 0;
    }
    j = 0;
    while (j < nf) {
      ftr = pipeline_module_struct_layout_field_type_ref(module, li, j);
      typeck_layout_field_name_into(module, li, j, field_nm);
      flen = pipeline_module_struct_layout_field_name_len(module, li, j);
      fa = pipeline_module_struct_layout_field_align_at(module, li, j);
      A = typeck_x_type_align(module, arena, ftr, depth);
      if (A <= 0) {
        A = 1;
      }
      if (fa > A) {
        A = fa;
      }
      rem = current % A;
      gap = A - rem;
      gap = gap % A;
      if (check_pad != 0 && gap > 0 && allow == 0) {
        driver_diagnostic_typeck_struct_padding_before(layout_nm, layout_nlen, gap, field_nm, flen);
        return - 1;
      }
      current = current + gap;
      fsize = typeck_x_type_size(module, arena, ftr, depth);
      /* wave366/368: allow fsize==0 for empty / empty-of-empty named ZST fields. */
      if (fsize < 0 || (fsize == 0 && typeck_type_is_empty_struct(module, arena, ftr, depth) == 0)) {
        if (check_pad != 0) {
          driver_diagnostic_typeck_struct_field_bad_size(layout_nm, layout_nlen, field_nm, flen);
        }
        return - 1;
      }
      current = current + fsize;
      if (A > max_align) {
        max_align = A;
      }
      j = j + 1;
    }
    if (max_align > 0 && (current % max_align) != 0) {
      end_pad = max_align - (current % max_align);
      if (check_pad != 0 && end_pad > 0 && allow == 0) {
        driver_diagnostic_typeck_struct_padding_trailing(layout_nm, layout_nlen, end_pad);
        return - 1;
      }
      current = current + end_pad;
    }
    typeck_i32_ptr_store(out_sz, current);
    typeck_i32_ptr_store(out_al, max_align);
    return 0;
  }
}

/** Exported function `typeck_validate_struct_layouts_zero_padding`.
 * Implements `typeck_validate_struct_layouts_zero_padding`.
 * @param module *Module
 * @param arena *ASTArena
 * @return i32
 */
export function typeck_validate_struct_layouts_zero_padding(module: *Module, arena: *ASTArena): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let li: i32 = 0;
    let nsl: i32 = pipeline_module_num_struct_layouts_at(module);
    /* See implementation. */
    let sz_out: *i32 = typeck_layout_metrics_sz_slot();
    let al_out: *i32 = typeck_layout_metrics_al_slot();
    while (li < nsl) {
      typeck_layout_metrics_init_slot();
      if (typeck_struct_layout_metrics(module, arena, li, 0, 1, sz_out, al_out) != 0) {
        return - 1;
      }
      /* See implementation. */
      pipeline_typeck_pad_fields_warn_layout(module, arena, li);
      /* See implementation. */
      pipeline_typeck_hot_reorder_warn_layout(module, arena, li);
      li = li + 1;
    }
    return 0;
  }
}

/* See implementation. */
export function get_field_offset_from_layout(module: *Module, type_name: *u8, type_name_len: i32,
field_name: *u8, field_name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let k: i32 = 0;
    while (k < module.num_struct_layouts) {
      if (typeck_layout_name_equal(module, k, type_name, type_name_len)) {
        let j: i32 = 0;
        while (j < pipeline_module_struct_layout_num_fields(module, k)) {
          if (typeck_layout_field_name_equal(module, k, j, field_name, field_name_len)) {
            return pipeline_module_struct_layout_field_offset_at(module, k, j);
          }
          j = j + 1;
        }
      }
      k = k + 1;
    }
    return - 1;
  }
}

/* See implementation. */
export function get_field_type_ref_from_layout(module: *Module, type_name: *u8, type_name_len: i32,
field_name: *u8, field_name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let k: i32 = 0;
    while (k < module.num_struct_layouts) {
      if (typeck_layout_name_equal(module, k, type_name, type_name_len)) {
        let j: i32 = 0;
        while (j < pipeline_module_struct_layout_num_fields(module, k)) {
          if (typeck_layout_field_name_equal(module, k, j, field_name, field_name_len)) {
            return pipeline_module_struct_layout_field_type_ref(module, k, j);
          }
          j = j + 1;
        }
      }
      k = k + 1;
    }
    return 0;
  }
}

/* See implementation. */
export function get_field_offset_from_layout_deps(module: *Module, ctx: *PipelineDepCtx, type_name: *u8,
type_name_len: i32, field_name: *u8, field_name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let r: i32 = get_field_offset_from_layout(module, type_name, type_name_len, field_name,
    field_name_len);
    if (r >= 0) {
      return r;
    }
    if (ctx == 0 as *PipelineDepCtx) {
      return - 1;
    }
    /* See implementation. */
    let nd: i32 = pipeline_dep_ctx_ndep(ctx);
    let di: i32 = 0;
    while (di < nd) {
      let dm: *Module = pipeline_dep_ctx_module_at(ctx, di);
      if (dm != 0 as *Module) {
        r = get_field_offset_from_layout(dm, type_name, type_name_len, field_name, field_name_len);
        if (r >= 0) {
          return r;
        }
      }
      di = di + 1;
    }
    return - 1;
  }
}

/**
 * Ensure module.struct_layouts has an entry for STRUCT_LIT expr_ref's type name.
 * Parser usually registered the layout already; this backfills missing fields when
 * parser only recorded a placeholder head. Called from typeck and from asm fill_cl
 * (skip-typeck STRUCT_LIT merge).
 *
 * wave369 Cap residual pure (PLATFORM: SHARED freestanding · LINUX gold):
 *   Prior append path always pushed STRUCT_LIT fields when name lookup missed.
 *   Mid/last nested Nest lit (`Box { a, n: Nest{e:Empty{}}, b }`) left Box layout
 *   scrambled (nf=4 names n/b/b/a, ftr mostly 0) → metrics fail, invent sz=24,
 *   field loads garbage. Root: (1) do not append when layout already has >= lit
 *   field count (parser complete); (2) re-read field name after expr_type_ref /
 *   next_field_offset — shared typeck_scratch64 slots can clobber field_nm.
 *   G.7: single authority ensure_struct_layout_from_struct_lit; seed typeck_gen
 *   same commit when regen.
 *
 * @param module *Module — owning struct_layouts table
 * @param arena *ASTArena — STRUCT_LIT expr pool
 * @param expr_ref i32 — EXPR_STRUCT_LIT ref; empty nf==0 is no-op (wave366 ZST)
 * @return i32 — 0 ok, -1 alloc failure
 */
export function ensure_struct_layout_from_struct_lit(module: *Module, arena: *ASTArena,
expr_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let num_fields: i32 = 0;
    let name_len: i32 = 0;
    let k: i32 = 0;
    let found_idx: i32 = -1;
    let idx_m: i32 = 0;
    let jm: i32 = 0;
    let fnlen_m: i32 = 0;
    let exists_m: i32 = 0;
    let tm: i32 = 0;
    let nf_layout: i32 = 0;
    let flen_tm: i32 = 0;
    let nf_m: i32 = 0;
    let ftr_m: i32 = 0;
    let init_rm: i32 = 0;
    let fr_m: i32 = 0;
    let idx: i32 = 0;
    let j: i32 = 0;
    let fnlen_j: i32 = 0;
    let ftr: i32 = 0;
    let init_r: i32 = 0;
    let fr: i32 = 0;
    let foff_m: i32 = 0;
    let foff_j: i32 = 0;
    let nsl: i32 = 0;
    let sname_len: i32 = 0;
    let lit_nm: *u8 = typeck_scratch64_slot(4);
    let layout_nm: *u8 = typeck_scratch64_slot(5);
    let field_nm: *u8 = typeck_scratch64_slot(6);
    let exist_nm: *u8 = typeck_scratch64_slot(7);
    if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    num_fields = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    /* wave366: Empty {} nf==0 — no fields to merge. */
    if (num_fields <= 0 || num_fields > 8) {
      return 0;
    }
    name_len = pipeline_expr_struct_lit_type_name_len(arena, expr_ref);
    if (name_len <= 0 || name_len > 127) {
      return 0;
    }
    pipeline_expr_struct_lit_type_name_into(arena, expr_ref, lit_nm);
    nsl = pipeline_module_num_struct_layouts_at(module);
    k = 0;
    found_idx = -1;
    while (k < nsl) {
      pipeline_module_struct_layout_name_into(module, k, layout_nm);
      sname_len = pipeline_module_struct_layout_name_len(module, k);
      if (name_equal(layout_nm, sname_len, lit_nm, name_len)) {
        found_idx = k;
        break;
      }
      k = k + 1;
    }
    if (found_idx >= 0) {
      idx_m = found_idx;
      jm = 0;
      while (jm < num_fields) {
        pipeline_expr_struct_lit_field_name_into(arena, expr_ref, jm, field_nm);
        fnlen_m = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, jm);
        exists_m = 0;
        tm = 0;
        nf_layout = pipeline_module_struct_layout_num_fields(module, idx_m);
        /*
         * wave369: parser already registered a full field set (nf >= lit fields).
         * Do not append — mid Nest STRUCT_LIT merge previously grew Box to nf=4
         * with scrambled names. Name-match update of type_ref is enough.
         */
        if (nf_layout >= num_fields) {
          return 0;
        }
        while (tm < nf_layout) {
          pipeline_module_struct_layout_field_name_into(module, idx_m, tm, exist_nm);
          flen_tm = pipeline_module_struct_layout_field_name_len(module, idx_m, tm);
          if (name_equal(exist_nm, flen_tm, field_nm, fnlen_m)) {
            exists_m = 1;
          }
          tm = tm + 1;
        }
        if (exists_m == 0) {
          nf_m = nf_layout;
          ftr_m = 0;
          init_rm = pipeline_expr_struct_lit_init_ref(arena, expr_ref, jm);
          if (!ast.ref_is_null(init_rm) && init_rm > 0 && init_rm <= arena.num_exprs) {
            fr_m = expr_type_ref(arena, init_rm);
            if (!ast.ref_is_null(fr_m)) {
              ftr_m = fr_m;
            }
          }
          foff_m = pipeline_struct_layout_next_field_offset(module, arena, idx_m, ftr_m);
          /* Re-read field name after helpers that reuse typeck_scratch64 slots. */
          pipeline_expr_struct_lit_field_name_into(arena, expr_ref, jm, field_nm);
          fnlen_m = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, jm);
          pipeline_module_struct_layout_set_field(module, idx_m, nf_m, field_nm, fnlen_m, ftr_m,
          foff_m);
          pipeline_module_struct_layout_set_num_fields(module, idx_m, nf_m + 1);
        }
        jm = jm + 1;
      }
      return 0;
    }
    idx = pipeline_module_struct_layout_alloc(module);
    if (idx < 0) {
      return - 1;
    }
    pipeline_module_struct_layout_reset_slot(module, idx);
    pipeline_module_struct_layout_set_name(module, idx, lit_nm, name_len);
    pipeline_module_struct_layout_set_num_fields(module, idx, num_fields);
    j = 0;
    while (j < num_fields) {
      pipeline_expr_struct_lit_field_name_into(arena, expr_ref, j, field_nm);
      fnlen_j = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, j);
      ftr = 0;
      init_r = pipeline_expr_struct_lit_init_ref(arena, expr_ref, j);
      if (!ast.ref_is_null(init_r) && init_r > 0 && init_r <= arena.num_exprs) {
        fr = expr_type_ref(arena, init_r);
        if (!ast.ref_is_null(fr)) {
          ftr = fr;
        }
      }
      foff_j = pipeline_struct_layout_next_field_offset(module, arena, idx, ftr);
      /* Re-read name after type/offset helpers (scratch slot safety). */
      pipeline_expr_struct_lit_field_name_into(arena, expr_ref, j, field_nm);
      fnlen_j = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, j);
      pipeline_module_struct_layout_set_field(module, idx, j, field_nm, fnlen_j, ftr, foff_j);
      j = j + 1;
    }
    return 0;
  }
}

/**
 * R2 (8.3.3): Before asm emit, fill SoA col_base+stride and AoS layout
 * offsets for FIELD_ACCESS when C/X typeck was skipped or incomplete.
 *
 * Migrated from C `pipeline_fill_soa_field_access_for_asm_emit`
 * (pipeline_typeck_soa.c) to .x authority. Public surface name stays on a
 * thin C forwarder so runtime_pipeline_abi empty export / weak stubs do not
 * collide with a second no_mangle body.
 *
 * Steps (same as prior C):
 *  1. Merge STRUCT_LIT fields into module.struct_layouts
 *     (ensure_struct_layout_from_struct_lit authority).
 *  2. DOD-CL: inherit field_align from prior field when next is 0 and prior
 *     align >= 64 (align(N) column inheritance).
 *  3. Sync layout field offsets (glue_sync_struct_layout_field_offsets_c).
 *  4. Per non-extern func: bind emit func index, backfill VAR types from
 *     lets/params (skip-typeck INDEX base types).
 *  5. Per FIELD_ACCESS: SoA INDEX base → typeck_soa_field_soa_index; else
 *     stamp AoS layout offset unless soa_stride already set.
 *
 * @param module *Module — primary module (layouts + funcs)
 * @param arena *ASTArena — expr pool
 * @return void — no-op on null module/arena
 * PLATFORM: SHARED — G.7 single authority; .x -> typeck_gen.c -> typeck_x.o.
 */
export function typeck_soa_fill_field_access_for_asm_emit(module: *Module, arena: *ASTArena): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let fi: i32 = 0;
    let ei: i32 = 0;
    let saved_fi: i32 = 0;
    let li: i32 = 0;
    let nf2: i32 = 0;
    let j: i32 = 0;
    let fa0: i32 = 0;
    let br: i32 = 0;
    let base_ref: i32 = 0;
    let flen: i32 = 0;
    let fname: u8[128] = [];
    let layout_off: i32 = 0;
    let nfuncs: i32 = 0;
    let nlayouts: i32 = 0;
    let nexprs: i32 = 0;
    let ens_rc: i32 = 0;
    let soa_rc: i32 = 0;
    if (module == 0 as *Module || arena == 0 as *ASTArena) {
      return;
    }
    pipeline_debug_trace_named_func_bodies("fill_cl_pre", module, arena);
    /* skip typeck: merge STRUCT_LIT fields into module.struct_layouts. */
    nexprs = arena.num_exprs;
    ei = 1;
    while (ei <= nexprs) {
      /* EXPR_STRUCT_LIT kind ord == 45 */
      if (pipeline_expr_kind_ord_at(arena, ei) == 45) {
        /* Discard return: merge failure is soft for skip-typeck emit path. */
        ens_rc = ensure_struct_layout_from_struct_lit(module, arena, ei);
        if (ens_rc != 0) {
          /* keep walking other STRUCT_LIT nodes */
        }
      }
      ei = ei + 1;
    }
    /* DOD-CL: inherit align(N) from field j onto j+1 when next align is 0. */
    nlayouts = pipeline_module_num_struct_layouts_at(module);
    li = 0;
    while (li < nlayouts) {
      nf2 = pipeline_module_struct_layout_num_fields(module, li);
      j = 0;
      while (j + 1 < nf2) {
        fa0 = pipeline_module_struct_layout_field_align_at(module, li, j);
        if (fa0 >= 64 && pipeline_module_struct_layout_field_align_at(module, li, j + 1) == 0) {
          pipeline_module_struct_layout_set_field_align(module, li, j + 1, fa0);
        }
        j = j + 1;
      }
      li = li + 1;
    }
    /* DOD-CL-S1: recompute field offsets from field_align, then fill FA. */
    glue_sync_struct_layout_field_offsets_c(module, arena);
    saved_fi = pipeline_asm_emit_func_index_c();
    nfuncs = pipeline_module_num_funcs(module);
    fi = 0;
    while (fi < nfuncs) {
      /* EMIT_HEAVY extern slots have no body/params; fill would SIGSEGV. */
      if (pipeline_module_func_is_extern_at(module, fi) != 0) {
        fi = fi + 1;
        continue;
      }
      br = pipeline_module_func_body_ref_at(module, fi);
      if (br <= 0) {
        fi = fi + 1;
        continue;
      }
      pipeline_asm_emit_set_func_index(fi);
      glue_fill_var_types_from_lets_in_block(arena, br);
      glue_fill_var_types_from_params_for_func(module, arena, fi);
      fi = fi + 1;
    }
    ei = 1;
    while (ei <= nexprs) {
      /* EXPR_FIELD_ACCESS kind ord == 44 */
      if (pipeline_expr_kind_ord_at(arena, ei) != 44) {
        ei = ei + 1;
        continue;
      }
      base_ref = pipeline_expr_field_access_base_ref(arena, ei);
      if (base_ref <= 0) {
        ei = ei + 1;
        continue;
      }
      /* INDEX kind ord == 47 → SoA arr[i].field */
      if (pipeline_expr_kind_ord_at(arena, base_ref) == 47) {
        /* Discard return: 0 means not-SoA; AoS offset path still runs below. */
        soa_rc = typeck_soa_field_soa_index(module, arena, ei, base_ref);
        if (soa_rc != 0) {
          /* SoA stamps already written */
        }
      }
      flen = pipeline_expr_field_access_name_len(arena, ei);
      if (flen <= 0 || flen > 127) {
        ei = ei + 1;
        continue;
      }
      pipeline_expr_field_access_name_into(arena, ei, &fname[0]);
      /* SoA path already wrote col_base+stride; do not overwrite with AoS off. */
      if (pipeline_expr_field_access_soa_stride(arena, ei) > 0) {
        ei = ei + 1;
        continue;
      }
      layout_off = glue_field_layout_offset_for_base_field(arena, module, base_ref, &fname[0], flen);
      if (layout_off >= 0) {
        pipeline_expr_set_field_access_offset(arena, ei, layout_off);
      }
      ei = ei + 1;
    }
    pipeline_asm_emit_set_func_index(saved_fi);
    pipeline_debug_trace_named_func_bodies("fill_cl_post", module, arena);
  }
}

/**
 * R2 (8.3.3): EXPR_FIELD_ACCESS prebind for untyped VAR bases.
 *
 * Migrated from C `pipeline_typeck_field_prebind_c`
 * (pipeline_typeck_field_access.c) to .x authority. Public surface
 * `pipeline_typeck_field_prebind_c` remains a thin C forwarder for
 * field_access orchestration.
 *
 * When FIELD_ACCESS base is EXPR_VAR with null resolved_type_ref, and the name
 * is not a current-function formal, allocate/find a TYPE_NAMED with the same
 * spelling and stamp it on the base. This lets layout_named / known_ptr see a
 * type before full var resolution (self-host Lexer/Parser pattern: bare type
 * name used as temporary base).
 *
 * @param module *Module — param table for formal-name skip
 * @param arena *ASTArena — expr/type arena
 * @param expr_ref i32 — FIELD_ACCESS expr
 * @param ctx *PipelineDepCtx — current_func_index (null → skip formal check)
 * @return void
 * PLATFORM: SHARED — G.7; first knife in field_access orchestration order.
 */
export function typeck_field_prebind(module: *Module, arena: *ASTArena, expr_ref: i32,
ctx: *PipelineDepCtx): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let base_ref: i32 = 0;
    let vnlen: i32 = 0;
    let vbuf: u8[128] = [];
    let param_pre: i32 = 0;
    let nt_pre: i32 = 0;
    let fi: i32 = 0;
    if (arena == 0 as *ASTArena || module == 0 as *Module) {
      return;
    }
    base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
    if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
      return;
    }
    /* EXPR_VAR = 3 */
    if (pipeline_expr_kind_ord_at(arena, base_ref) != 3) {
      return;
    }
    if (!ast.ref_is_null(pipeline_expr_resolved_type_ref(arena, base_ref))) {
      return;
    }
    vnlen = pipeline_expr_var_name_len(arena, base_ref);
    if (vnlen <= 0 || vnlen > 127) {
      return;
    }
    pipeline_expr_var_name_into(arena, base_ref, &vbuf[0]);
    /* Skip prebind when name matches a formal (param already owns the type). */
    if (ctx != 0 as *PipelineDepCtx) {
      fi = pipeline_dep_ctx_current_func_index(ctx);
      if (fi >= 0 && fi < module.num_funcs) {
        param_pre = pipeline_module_func_param_type_ref_for_name(module, fi, &vbuf[0], vnlen);
        if (!ast.ref_is_null(param_pre)) {
          return;
        }
      }
    }
    nt_pre = find_or_alloc_named_type_ref(arena, &vbuf[0], vnlen);
    if (nt_pre != 0) {
      pipeline_expr_set_resolved_type_ref(arena, base_ref, nt_pre);
    }
  }
}

/**
 * R2 (8.3.3): EXPR_FIELD_ACCESS hard-coded fields on *ASTArena / *Module.
 *
 * Migrated from C `pipeline_typeck_field_known_ptr_types_c`
 * (pipeline_typeck_field_access.c) to .x authority. Public surface
 * `pipeline_typeck_field_known_ptr_types_c` remains a thin C forwarder for
 * field_access orchestration.
 *
 * When the field base type is TYPE_PTR to a TYPE_NAMED "ASTArena" or "Module",
 * stamp resolved_type_ref (and for ASTArena, hard-coded byte offsets matching
 * the self-host arena / module layouts) for known SoA pool fields:
 *   ASTArena: types/num_types, exprs/num_exprs, blocks/num_blocks, funcs/num_funcs
 *   Module:   funcs, struct_layouts, num_funcs, num_struct_layouts
 * Offsets and array bounds are product ABI constants used by the compiler when
 * typechecking its own ASTArena/Module field access (self-host path).
 *
 * @param module *Module — reserved for ABI parity with C surface (unused body)
 * @param arena *ASTArena — expr/type arena
 * @param expr_ref i32 — FIELD_ACCESS expr
 * @param base_ref i32 — field base expr (must be *Named with resolved type)
 * @param num_struct_layouts i32 — diagnostic only (driver_diagnostic_typeck_ptr_field)
 * @return i32 — 1 = matched and stamped; 0 = not a known ptr field (continue)
 * PLATFORM: SHARED — G.7; layout offsets are ABI constants, not platform forks.
 */
export function typeck_field_known_ptr(module: *Module, arena: *ASTArena, expr_ref: i32,
base_ref: i32, num_struct_layouts: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let base_ty: i32 = 0;
    let bt_kind: i32 = 0;
    let elem_ty: i32 = 0;
    let inner_nm_buf: u8[128] = [];
    let inner_nm_len: i32 = 0;
    let inner_ord: i32 = 0;
    let fl: i32 = 0;
    let fn_buf: u8[128] = [];
    /* "ASTArena" */
    let nm_astarena: u8[8] = [65, 83, 84, 65, 114, 101, 110, 97];
    /* "types" / "num_types" / "exprs" / "num_exprs" / "blocks" / "num_blocks" / "funcs" / "num_funcs" */
    let nm_types: u8[5] = [116, 121, 112, 101, 115];
    let nm_num_types: u8[9] = [110, 117, 109, 95, 116, 121, 112, 101, 115];
    let nm_exprs: u8[5] = [101, 120, 112, 114, 115];
    let nm_num_exprs: u8[9] = [110, 117, 109, 95, 101, 120, 112, 114, 115];
    let nm_blocks: u8[6] = [98, 108, 111, 99, 107, 115];
    let nm_num_blocks: u8[10] = [110, 117, 109, 95, 98, 108, 111, 99, 107, 115];
    let nm_funcs: u8[5] = [102, 117, 110, 99, 115];
    let nm_num_funcs: u8[9] = [110, 117, 109, 95, 102, 117, 110, 99, 115];
    /* array elem names: "Type" / "Expr" / "Block" / "Func" */
    let nm_ty: u8[4] = [84, 121, 112, 101];
    let nm_ex: u8[4] = [69, 120, 112, 114];
    let nm_bl: u8[5] = [66, 108, 111, 99, 107];
    let nm_fu: u8[4] = [70, 117, 110, 99];
    /* "Module" */
    let nm_module: u8[6] = [77, 111, 100, 117, 108, 101];
    /* Module fields reuse funcs/num_funcs; plus struct_layouts / num_struct_layouts */
    let nm_struct_layouts_m: u8[14] = [115, 116, 114, 117, 99, 116, 95, 108, 97, 121, 111, 117, 116, 115];
    /* "num_struct_layouts" (18) */
    let nm_num_struct_layouts_m: u8[18] = [110, 117, 109, 95, 115, 116, 114, 117, 99, 116, 95, 108, 97, 121, 111, 117, 116, 115];
    /* "StructLayout" */
    let nm_sl_m: u8[12] = [83, 116, 114, 117, 99, 116, 76, 97, 121, 111, 117, 116];
    let i32r_at: i32 = 0;
    let i32r_mod: i32 = 0;
    let matched: i32 = 0;
    let arr_ty: i32 = 0;
    /* `module` is ABI-only (C surface parity); body never dereferences it. */
    if (arena == 0 as *ASTArena) {
      return 0;
    }
    if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
      return 0;
    }
    base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
    if (ast.ref_is_null(base_ty) || base_ty <= 0 || base_ty > arena.num_types) {
      return 0;
    }
    /* TYPE_PTR = 9 */
    bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
    if (bt_kind != 9) {
      return 0;
    }
    elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
    if (ast.ref_is_null(elem_ty)) {
      return 0;
    }
    inner_nm_len = pipeline_type_named_name_into(arena, elem_ty, &inner_nm_buf[0]);
    inner_ord = pipeline_type_kind_ord_at(arena, elem_ty);
    driver_diagnostic_typeck_ptr_field(9, inner_ord, inner_nm_len, base_ty, num_struct_layouts);
    fl = pipeline_expr_field_access_name_len(arena, expr_ref);
    if (fl <= 0 || fl > 127) {
      return 0;
    }
    pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
    i32r_at = ensure_i32_type_ref(arena);
    i32r_mod = ensure_i32_type_ref(arena);
    matched = 0;
    /* TYPE_NAMED = 8; *ASTArena fields (hard-coded offsets). */
    if (inner_ord == 8 && inner_nm_len == 8 &&
    name_equal(&inner_nm_buf[0], inner_nm_len, &nm_astarena[0], 8)) {
      if (fl == 5 && name_equal(&fn_buf[0], fl, &nm_types[0], 5)) {
        pipeline_expr_set_field_access_offset(arena, expr_ref, 0);
        arr_ty = ensure_array_type_ref_named_elem(arena, &nm_ty[0], 4, 512);
        if (arr_ty != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_ty);
          matched = 1;
        }
      }
      if (matched == 0 && fl == 9 && name_equal(&fn_buf[0], fl, &nm_num_types[0], 9)) {
        pipeline_expr_set_field_access_offset(arena, expr_ref, 40960);
        if (i32r_at != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_at);
          matched = 1;
        }
      }
      if (matched == 0 && fl == 5 && name_equal(&fn_buf[0], fl, &nm_exprs[0], 5)) {
        pipeline_expr_set_field_access_offset(arena, expr_ref, 40968);
        arr_ty = ensure_array_type_ref_named_elem(arena, &nm_ex[0], 4, 32768);
        if (arr_ty != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_ty);
          matched = 1;
        }
      }
      if (matched == 0 && fl == 9 && name_equal(&fn_buf[0], fl, &nm_num_exprs[0], 9)) {
        pipeline_expr_set_field_access_offset(arena, expr_ref, 6234120);
        if (i32r_at != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_at);
          matched = 1;
        }
      }
      if (matched == 0 && fl == 6 && name_equal(&fn_buf[0], fl, &nm_blocks[0], 6)) {
        pipeline_expr_set_field_access_offset(arena, expr_ref, 6234124);
        arr_ty = ensure_array_type_ref_named_elem(arena, &nm_bl[0], 5, 8192);
        if (arr_ty != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_ty);
          matched = 1;
        }
      }
      if (matched == 0 && fl == 10 && name_equal(&fn_buf[0], fl, &nm_num_blocks[0], 10)) {
        pipeline_expr_set_field_access_offset(arena, expr_ref, 17184780);
        if (i32r_at != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_at);
          matched = 1;
        }
      }
      if (matched == 0 && fl == 5 && name_equal(&fn_buf[0], fl, &nm_funcs[0], 5)) {
        pipeline_expr_set_field_access_offset(arena, expr_ref, 17184784);
        arr_ty = ensure_array_type_ref_named_elem(arena, &nm_fu[0], 4, 256);
        if (arr_ty != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_ty);
          matched = 1;
        }
      }
      if (matched == 0 && fl == 9 && name_equal(&fn_buf[0], fl, &nm_num_funcs[0], 9)) {
        pipeline_expr_set_field_access_offset(arena, expr_ref, 17371152);
        if (i32r_at != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_at);
          matched = 1;
        }
      }
      if (matched != 0) {
        return 1;
      }
    }
    /* *Module fields (type only; offsets left for layout path). */
    if (inner_ord == 8 && inner_nm_len == 6 &&
    name_equal(&inner_nm_buf[0], inner_nm_len, &nm_module[0], 6)) {
      matched = 0;
      if (fl == 5 && name_equal(&fn_buf[0], fl, &nm_funcs[0], 5)) {
        arr_ty = ensure_array_type_ref_named_elem(arena, &nm_fu[0], 4, 256);
        if (arr_ty != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_ty);
          matched = 1;
        }
      }
      if (matched == 0 && fl == 14 && name_equal(&fn_buf[0], fl, &nm_struct_layouts_m[0], 14)) {
        arr_ty = ensure_array_type_ref_named_elem(arena, &nm_sl_m[0], 12, 32);
        if (arr_ty != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_ty);
          matched = 1;
        }
      }
      if (matched == 0 && fl == 9 && name_equal(&fn_buf[0], fl, &nm_num_funcs[0], 9)) {
        if (i32r_mod != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_mod);
          matched = 1;
        }
      }
      if (matched == 0 && fl == 18 && name_equal(&fn_buf[0], fl, &nm_num_struct_layouts_m[0], 18)) {
        if (i32r_mod != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_mod);
          matched = 1;
        }
      }
    }
    if (matched != 0) {
      return 1;
    }
    return 0;
  }
}

/**
 * R2 (8.3.3): EXPR_FIELD_ACCESS named-type layout / enum / TypeKind / TokenKind.
 *
 * Migrated from C `pipeline_typeck_field_layout_named_c`
 * (pipeline_typeck_field_access.c) to .x authority. Public surface
 * `pipeline_typeck_field_layout_named_c` remains a thin C forwarder for
 * field_access orchestration and strict_glue / seed call sites.
 *
 * Semantics (G.7 single authority):
 *  - Peel type aliases on base (and PTR pointee) before layout name lookup.
 *  - TYPE_PTR(*Named) or TYPE_NAMED → layout type name.
 *  - User enum variant: stamp enum_variant tag + resolved TYPE_NAMED(enum); return 2
 *    so the orchestrator short-circuits further fallbacks.
 *  - TypeKind.TYPE_* builtin variants: stamp tag + i32 type; skip struct layout.
 *  - Strip last `mod.` prefix on qualified type names so dep layouts match bare names.
 *  - Layout field offset + field type via get_field_*_from_layout_deps.
 *  - TokenKind.TOKEN_EOF residual special-case when layout miss.
 *
 * @param module *Module — entry + dep enum / layout tables
 * @param arena *ASTArena — expr/type arena
 * @param expr_ref i32 — FIELD_ACCESS expr
 * @param base_ref i32 — field base expr (resolved type required)
 * @param ctx *PipelineDepCtx — dep walk for cross-module layouts (null-safe)
 * @return i32 — 2 = user enum done (caller returns 0); 0 = continue field fallbacks
 * PLATFORM: SHARED — G.7; import-qualified type name strip at this single gate.
 */
export function typeck_field_layout_named(module: *Module, arena: *ASTArena, expr_ref: i32,
base_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let base_ty: i32 = 0;
    let bt_kind: i32 = 0;
    let layout_named_ref: i32 = 0;
    let layout_nm_buf: u8[128] = [];
    let layout_nm_len: i32 = 0;
    let fn_buf: u8[128] = [];
    let fl2: i32 = 0;
    let user_ev_tag: i32 = 0;
    /* "TypeKind" */
    let nm_type_kind_ty: u8[8] = [84, 121, 112, 101, 75, 105, 110, 100];
    let skip_layout_for_type_kind: i32 = 0;
    let vv: i32 = 0;
    let off: i32 = 0;
    let ftr: i32 = 0;
    let i32r_tk: i32 = 0;
    let i32r_eof: i32 = 0;
    /* "TokenKind" */
    let nm_tok_kind_ty: u8[9] = [84, 111, 107, 101, 110, 75, 105, 110, 100];
    /* "TOKEN_EOF" */
    let nm_eof_variant: u8[9] = [84, 79, 75, 69, 78, 95, 69, 79, 70];
    let elem_ty: i32 = 0;
    let peeled: i32 = 0;
    let peeled_e: i32 = 0;
    let dot_pos: i32 = 0;
    let si: i32 = 0;
    let suffix_len: i32 = 0;
    /* TypeKind variant spellings */
    let s_i32: u8[8] = [84, 121, 112, 101, 95, 73, 51, 50];
    let s_bool: u8[9] = [84, 121, 112, 101, 95, 66, 79, 79, 76];
    let s_u8: u8[7] = [84, 121, 112, 101, 95, 85, 56];
    let s_u32: u8[8] = [84, 121, 112, 101, 95, 85, 51, 50];
    let s_u64: u8[8] = [84, 121, 112, 101, 95, 85, 54, 52];
    let s_i64: u8[8] = [84, 121, 112, 101, 95, 73, 54, 52];
    let s_usize: u8[10] = [84, 121, 112, 101, 95, 85, 83, 73, 90, 69];
    let s_isize: u8[10] = [84, 121, 112, 101, 95, 73, 83, 73, 90, 69];
    let s_named: u8[10] = [84, 121, 112, 101, 95, 78, 65, 77, 69, 68];
    let s_ptr: u8[8] = [84, 121, 112, 101, 95, 80, 84, 82];
    let s_arr: u8[10] = [84, 121, 112, 101, 95, 65, 82, 82, 65, 89];
    let s_sli: u8[10] = [84, 121, 112, 101, 95, 83, 76, 73, 67, 69];
    let s_vec: u8[11] = [84, 121, 112, 101, 95, 86, 69, 67, 84, 79, 82];
    let s_f32: u8[8] = [84, 121, 112, 101, 95, 70, 51, 50];
    let s_f64: u8[8] = [84, 121, 112, 101, 95, 70, 54, 52];
    let s_void: u8[9] = [84, 121, 112, 101, 95, 86, 79, 73, 68];

    if (arena == 0 as *ASTArena || module == 0 as *Module) {
      return 0;
    }
    if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
      return 0;
    }
    base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
    if (ast.ref_is_null(base_ty) || base_ty <= 0 || base_ty > arena.num_types) {
      return 0;
    }
    /* Peel type aliases so `type P = Point; p.x` uses Point layout. */
    peeled = typeck_resolve_type_alias_ref_local(module, arena, base_ty, 0);
    if (!ast.ref_is_null(peeled) && peeled > 0 && peeled <= arena.num_types) {
      base_ty = peeled;
    }
    bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
    layout_named_ref = 0;
    /* TYPE_PTR = 9: peel pointee; TYPE_NAMED = 8. */
    if (bt_kind == 9) {
      elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
      if (!ast.ref_is_null(elem_ty) && elem_ty > 0) {
        peeled_e = typeck_resolve_type_alias_ref_local(module, arena, elem_ty, 0);
        if (!ast.ref_is_null(peeled_e) && peeled_e > 0 && peeled_e <= arena.num_types) {
          elem_ty = peeled_e;
        }
      }
      if (!ast.ref_is_null(elem_ty) && pipeline_type_kind_ord_at(arena, elem_ty) == 8) {
        layout_named_ref = elem_ty;
      }
    } else if (bt_kind == 8) {
      layout_named_ref = base_ty;
    }
    if (layout_named_ref == 0) {
      return 0;
    }
    layout_nm_len = pipeline_type_named_name_into(arena, layout_named_ref, &layout_nm_buf[0]);
    if (layout_nm_len <= 0 || pipeline_type_kind_ord_at(arena, layout_named_ref) != 8) {
      return 0;
    }
    fl2 = pipeline_expr_field_access_name_len(arena, expr_ref);
    if (fl2 <= 0 || fl2 > 127) {
      return 0;
    }
    pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
    user_ev_tag = pipeline_module_enum_variant_tag_for_names(module, &layout_nm_buf[0],
    layout_nm_len, &fn_buf[0], fl2);
    if (user_ev_tag >= 0) {
      /* User enum variant: resolved TYPE_NAMED(enum); codegen uses tag for discriminant. */
      pipeline_expr_set_field_access_enum_variant(arena, expr_ref, user_ev_tag);
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, layout_named_ref);
      return 2;
    }
    vv = -1;
    skip_layout_for_type_kind = 0;
    if (layout_nm_len == 8 && name_equal(&layout_nm_buf[0], layout_nm_len, &nm_type_kind_ty[0], 8)) {
      if (vv < 0 && fl2 == 8 && name_equal(&fn_buf[0], fl2, &s_i32[0], 8)) {
        vv = 0;
      }
      if (vv < 0 && fl2 == 9 && name_equal(&fn_buf[0], fl2, &s_bool[0], 9)) {
        vv = 1;
      }
      if (vv < 0 && fl2 == 7 && name_equal(&fn_buf[0], fl2, &s_u8[0], 7)) {
        vv = 2;
      }
      if (vv < 0 && fl2 == 8 && name_equal(&fn_buf[0], fl2, &s_u32[0], 8)) {
        vv = 3;
      }
      if (vv < 0 && fl2 == 8 && name_equal(&fn_buf[0], fl2, &s_u64[0], 8)) {
        vv = 4;
      }
      if (vv < 0 && fl2 == 8 && name_equal(&fn_buf[0], fl2, &s_i64[0], 8)) {
        vv = 5;
      }
      if (vv < 0 && fl2 == 10 && name_equal(&fn_buf[0], fl2, &s_usize[0], 10)) {
        vv = 6;
      }
      if (vv < 0 && fl2 == 10 && name_equal(&fn_buf[0], fl2, &s_isize[0], 10)) {
        vv = 7;
      }
      if (vv < 0 && fl2 == 10 && name_equal(&fn_buf[0], fl2, &s_named[0], 10)) {
        vv = 8;
      }
      if (vv < 0 && fl2 == 8 && name_equal(&fn_buf[0], fl2, &s_ptr[0], 8)) {
        vv = 9;
      }
      if (vv < 0 && fl2 == 10 && name_equal(&fn_buf[0], fl2, &s_arr[0], 10)) {
        vv = 10;
      }
      if (vv < 0 && fl2 == 10 && name_equal(&fn_buf[0], fl2, &s_sli[0], 10)) {
        vv = 11;
      }
      if (vv < 0 && fl2 == 11 && name_equal(&fn_buf[0], fl2, &s_vec[0], 11)) {
        vv = 12;
      }
      if (vv < 0 && fl2 == 8 && name_equal(&fn_buf[0], fl2, &s_f32[0], 8)) {
        vv = 13;
      }
      if (vv < 0 && fl2 == 8 && name_equal(&fn_buf[0], fl2, &s_f64[0], 8)) {
        vv = 14;
      }
      if (vv < 0 && fl2 == 9 && name_equal(&fn_buf[0], fl2, &s_void[0], 9)) {
        vv = 15;
      }
      if (vv >= 0) {
        i32r_tk = ensure_i32_type_ref(arena);
        if (i32r_tk != 0) {
          pipeline_expr_set_field_access_enum_variant(arena, expr_ref, vv);
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_tk);
        }
        skip_layout_for_type_kind = 1;
      }
    }
    off = -1;
    ftr = 0;
    if (skip_layout_for_type_kind == 0) {
      /*
       * Strip import-binding qualification: "lexer.Lexer" → "Lexer" so layout
       * tables registered under bare struct names match. Last '.' only.
       */
      dot_pos = -1;
      si = 0;
      while (si < layout_nm_len) {
        if (layout_nm_buf[si] == 46) {
          /* '.' */
          dot_pos = si;
        }
        si = si + 1;
      }
      if (dot_pos >= 0 && dot_pos + 1 < layout_nm_len) {
        suffix_len = layout_nm_len - (dot_pos + 1);
        si = 0;
        while (si < suffix_len) {
          layout_nm_buf[si] = layout_nm_buf[dot_pos + 1 + si];
          si = si + 1;
        }
        layout_nm_buf[suffix_len] = 0;
        layout_nm_len = suffix_len;
      }
      off = get_field_offset_from_layout_deps(module, ctx, &layout_nm_buf[0], layout_nm_len,
      &fn_buf[0], fl2);
      if (off >= 0) {
        pipeline_expr_set_field_access_offset(arena, expr_ref, off);
      }
      ftr = get_field_type_ref_from_layout_deps(module, arena, ctx, &layout_nm_buf[0],
      layout_nm_len, &fn_buf[0], fl2);
      if (ftr != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, ftr);
      }
    }
    if (off < 0 && ftr == 0 && layout_nm_len == 9 &&
    name_equal(&layout_nm_buf[0], layout_nm_len, &nm_tok_kind_ty[0], 9) && fl2 == 9 &&
    name_equal(&fn_buf[0], fl2, &nm_eof_variant[0], 9)) {
      i32r_eof = ensure_i32_type_ref(arena);
      if (i32r_eof != 0) {
        pipeline_expr_set_field_access_enum_variant(arena, expr_ref, 0);
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r_eof);
      }
    }
    return 0;
  }
}

/**
 * R2 (8.3.3): EXPR_FIELD_ACCESS built-in field typing for slices / fixed arrays /
 * SIMD vectors.
 *
 * Migrated from C `pipeline_typeck_field_slice_c` (pipeline_typeck_field_access.c)
 * to .x authority. Public surface `pipeline_typeck_field_slice_c` remains a thin
 * C forwarder so EMIT_HEAVY field_access orchestration keeps the same call name.
 *
 * Semantics (G.7 single authority; match asm emit fat layout):
 *  - TYPE_ARRAY / TYPE_VECTOR `.length` → usize when array_size > 0; no offset
 *    stamp (compile-time N; emit must not load from stack).
 *  - TYPE_SLICE `.length` → usize + field_access_offset = 8 (fat second word).
 *  - TYPE_SLICE `.data` → *elem + field_access_offset = 0.
 *
 * @param arena *ASTArena — expr/type arena (null → no-op)
 * @param expr_ref i32 — FIELD_ACCESS expr
 * @param base_ref i32 — field base expr (must have resolved_type_ref)
 * @return void
 * PLATFORM: SHARED — G.7; data@0 length@8 fat layout shared with asm emit.
 */
export function typeck_field_slice(arena: *ASTArena, expr_ref: i32, base_ref: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let base_ty: i32 = 0;
    let elem_ty: i32 = 0;
    let fl: i32 = 0;
    let bt_kind: i32 = 0;
    let fn_buf: u8[128] = [];
    /* "length" / "data" as byte arrays (no string lit dependence). */
    let len_nm: u8[6] = [108, 101, 110, 103, 116, 104];
    let dat_nm: u8[4] = [100, 97, 116, 97];
    let ut: i32 = 0;
    let ptr_ref: i32 = 0;
    if (arena == 0 as *ASTArena || base_ref <= 0 || base_ref > arena.num_exprs) {
      return;
    }
    base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
    if (base_ty <= 0 || base_ty > arena.num_types) {
      return;
    }
    bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
    fl = pipeline_expr_field_access_name_len(arena, expr_ref);
    if (fl <= 0 || fl > 127) {
      return;
    }
    pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
    /* TYPE_ARRAY=10, TYPE_VECTOR=13: fixed T[N] / SIMD lanes — .length is N. */
    if ((bt_kind == 10 || bt_kind == 13) && fl == 6 && name_equal(&fn_buf[0], fl, &len_nm[0], 6)) {
      if (pipeline_type_array_size_at(arena, base_ty) <= 0) {
        return;
      }
      ut = ensure_usize_type_ref(arena);
      if (ut != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, ut);
      }
      return;
    }
    /* TYPE_SLICE=11 */
    if (bt_kind != 11) {
      return;
    }
    elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
    if (elem_ty <= 0) {
      return;
    }
    if (fl == 6 && name_equal(&fn_buf[0], fl, &len_nm[0], 6)) {
      ut = ensure_usize_type_ref(arena);
      if (ut != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, ut);
      }
      /* G.7: fat pointer second word at +8 (layout half, not rbp-distance). */
      pipeline_expr_set_field_access_offset(arena, expr_ref, 8);
      return;
    }
    if (fl == 4 && name_equal(&fn_buf[0], fl, &dat_nm[0], 4)) {
      /* G.7: .data is *elem for every slice element kind. */
      pipeline_expr_set_field_access_offset(arena, expr_ref, 0);
      ptr_ref = find_or_alloc_ptr_type_ref(arena, elem_ty);
      if (ptr_ref != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, ptr_ref);
      }
    }
  }
}

/**
 * R2 (8.3.3): EXPR_FIELD_ACCESS name fallback when layout / known_ptr / slice miss.
 *
 * Migrated from C `pipeline_typeck_field_name_fallback_c`
 * (pipeline_typeck_field_access.c) to .x authority. Public surface
 * `pipeline_typeck_field_name_fallback_c` remains a thin C forwarder for
 * EMIT_HEAVY field_access orchestration.
 *
 * Order (no dual authority with layout path — only runs when field type still null):
 *  1. CodegenOutBuf.data → u8[8388608] (self-host CodegenOutBuf buffer field).
 *  2. Inline u8[64] field names (name / var_name / …).
 *  3. Inline i32[16] field names (call_arg_refs / match_arm_* / …).
 *  4. Scalar field-name heuristic (`expr_field_access_fallback_scalar_type_ref`).
 *
 * @param arena *ASTArena — expr/type arena (null → no-op)
 * @param expr_ref i32 — FIELD_ACCESS expr (must still have null resolved_type)
 * @param base_ref i32 — field base expr (used only for CodegenOutBuf.data path)
 * @return void
 * PLATFORM: SHARED — G.7 single authority; self-host + product field resolve.
 */
export function typeck_field_name_fallback(arena: *ASTArena, expr_ref: i32, base_ref: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let fl: i32 = 0;
    let fn_buf: u8[128] = [];
    let base_ty: i32 = 0;
    let bt_kind: i32 = 0;
    let named_ref: i32 = 0;
    let cob_nm: u8[128] = [];
    let cob_len: i32 = 0;
    let nm_dat: u8[4] = [100, 97, 116, 97];
    /* "CodegenOutBuf" */
    let nm_cob: u8[13] = [67, 111, 100, 101, 103, 101, 110, 79, 117, 116, 66, 117, 102];
    let u8r_cob: i32 = 0;
    let arr_cob: i32 = 0;
    let u8_fb: i32 = 0;
    let arr_fb: i32 = 0;
    let scalar_fb: i32 = 0;
    let elem_r: i32 = 0;
    if (arena == 0 as *ASTArena) {
      return;
    }
    /* Already stamped by layout / slice / known_ptr — do not overwrite. */
    if (!ast.ref_is_null(pipeline_expr_resolved_type_ref(arena, expr_ref))) {
      return;
    }
    fl = pipeline_expr_field_access_name_len(arena, expr_ref);
    if (fl <= 0 || fl > 127) {
      return;
    }
    pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
    /* CodegenOutBuf.data → large u8 array (self-host outbuf buffer). */
    if (fl == 4 && !ast.ref_is_null(base_ref) && base_ref > 0 && base_ref <= arena.num_exprs) {
      base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
      if (!ast.ref_is_null(base_ty) && base_ty > 0 && base_ty <= arena.num_types) {
        bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
        named_ref = 0;
        /* TYPE_PTR=9: peel to pointee TYPE_NAMED; TYPE_NAMED=8: use base. */
        if (bt_kind == 9) {
          elem_r = pipeline_type_elem_ref_at(arena, base_ty);
          if (!ast.ref_is_null(elem_r) && pipeline_type_kind_ord_at(arena, elem_r) == 8) {
            named_ref = elem_r;
          }
        } else if (bt_kind == 8) {
          named_ref = base_ty;
        }
        if (named_ref != 0 && name_equal(&fn_buf[0], fl, &nm_dat[0], 4)) {
          cob_len = pipeline_type_named_name_into(arena, named_ref, &cob_nm[0]);
          if (cob_len == 13 && name_equal(&cob_nm[0], cob_len, &nm_cob[0], 13)) {
            u8r_cob = ensure_u8_type_ref(arena);
            if (u8r_cob != 0) {
              arr_cob = find_or_alloc_array_type_ref(arena, u8r_cob, 8388608);
              if (arr_cob != 0) {
                pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_cob);
                return;
              }
            }
          }
        }
      }
    }
    if (!ast.ref_is_null(pipeline_expr_resolved_type_ref(arena, expr_ref))) {
      return;
    }
    u8_fb = typeck_inline_u8_64_array_field_type_ref(arena, &fn_buf[0], fl);
    if (u8_fb != 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, u8_fb);
      return;
    }
    arr_fb = typeck_expr_inline_array_field_type_ref(arena, &fn_buf[0], fl);
    if (arr_fb != 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_fb);
      return;
    }
    scalar_fb = expr_field_access_fallback_scalar_type_ref(arena, &fn_buf[0], fl);
    if (scalar_fb != 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, scalar_fb);
    }
  }
}

/**
 * R2 (8.3.3): EXPR_FIELD_ACCESS lexer-wrapper / param-type field fallback.
 *
 * Migrated from C `pipeline_typeck_field_lexer_fallback_c`
 * (pipeline_typeck_field_access.c) to .x authority. Public surface
 * `pipeline_typeck_field_lexer_fallback_c` remains a thin C forwarder.
 *
 * Uses existing authority `typeck_field_access_lexer_wrapper_fallback` for
 * Lexer / LexerResult / Parse*Result field names. Additional hop: when base is
 * EXPR_VAR and still untyped after resolved_type attempts, look up the current
 * function formal type by name and retry the same wrapper table.
 *
 * @param module *Module — current module (param table)
 * @param arena *ASTArena — expr/type arena
 * @param expr_ref i32 — FIELD_ACCESS expr (must still have null resolved_type)
 * @param base_ref i32 — field base expr
 * @param ctx *PipelineDepCtx — current_func_index for param lookup
 * @return void
 * PLATFORM: SHARED — G.7; self-host lexer.x / parser result field resolve.
 */
export function typeck_field_lexer_fallback(module: *Module, arena: *ASTArena, expr_ref: i32,
base_ref: i32, ctx: *PipelineDepCtx): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let base_ty: i32 = 0;
    let elem_ty: i32 = 0;
    let fl: i32 = 0;
    let fn_buf: u8[128] = [];
    let vbuf: u8[128] = [];
    let vnlen: i32 = 0;
    let pr_fb: i32 = 0;
    let lx_fb: i32 = 0;
    let fi: i32 = 0;
    if (arena == 0 as *ASTArena || module == 0 as *Module) {
      return;
    }
    if (!ast.ref_is_null(pipeline_expr_resolved_type_ref(arena, expr_ref))) {
      return;
    }
    if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
      return;
    }
    fl = pipeline_expr_field_access_name_len(arena, expr_ref);
    if (fl <= 0 || fl > 127) {
      return;
    }
    pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
    base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
    if (!ast.ref_is_null(base_ty) && base_ty > 0 && base_ty <= arena.num_types) {
      lx_fb = typeck_field_access_lexer_wrapper_fallback(arena, base_ty, &fn_buf[0], fl);
      if (lx_fb != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, lx_fb);
        return;
      }
      /* TYPE_PTR=9: peel and retry on pointee (e.g. *LexerResult). */
      if (pipeline_type_kind_ord_at(arena, base_ty) == 9) {
        elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
        if (!ast.ref_is_null(elem_ty)) {
          lx_fb = typeck_field_access_lexer_wrapper_fallback(arena, elem_ty, &fn_buf[0], fl);
          if (lx_fb != 0) {
            pipeline_expr_set_resolved_type_ref(arena, expr_ref, lx_fb);
            return;
          }
        }
      }
    }
    if (!ast.ref_is_null(pipeline_expr_resolved_type_ref(arena, expr_ref))) {
      return;
    }
    /* EXPR_VAR=3: formal-type hop when base resolved_type still missing. */
    if (pipeline_expr_kind_ord_at(arena, base_ref) != 3) {
      return;
    }
    vnlen = pipeline_expr_var_name_len(arena, base_ref);
    if (vnlen <= 0 || vnlen > 127) {
      return;
    }
    if (ctx == 0 as *PipelineDepCtx) {
      return;
    }
    fi = pipeline_dep_ctx_current_func_index(ctx);
    if (fi < 0 || fi >= module.num_funcs) {
      return;
    }
    pipeline_expr_var_name_into(arena, base_ref, &vbuf[0]);
    pr_fb = pipeline_module_func_param_type_ref_for_name(module, fi, &vbuf[0], vnlen);
    if (ast.ref_is_null(pr_fb)) {
      return;
    }
    lx_fb = typeck_field_access_lexer_wrapper_fallback(arena, pr_fb, &fn_buf[0], fl);
    if (lx_fb != 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, lx_fb);
    }
  }
}

/** See implementation for details. */
export function expr_var_name_equal_func(arena: *ASTArena, callee_expr_ref: i32, mod: *Module,
func_index: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let vbuf: *u8 = typeck_scratch64_slot(8);
    let b_len: i32 = 0;
    let a_len: i32 = 0;
    let i: i32 = 0;
    if (callee_expr_ref <= 0 || callee_expr_ref > arena.num_exprs) {
      return false;
    }
    if (pipeline_expr_kind_ord_at(arena, callee_expr_ref) != 3) {
      return false;
    }
    b_len = pipeline_expr_var_name_len(arena, callee_expr_ref);
    if (func_index < 0 || func_index >= mod.num_funcs) {
      return false;
    }
    a_len = pipeline_module_func_name_len_at(mod, func_index);
    if (a_len != b_len || a_len <= 0 || a_len > 127) {
      return false;
    }
    pipeline_expr_var_name_into(arena, callee_expr_ref, vbuf);
    while (i < a_len) {
      if (pipeline_module_func_name_byte_at(mod, func_index, i) != vbuf[i]) {
        return false;
      }
      i = i + 1;
    }
    return true;
  }
}

/** Exported function `find_or_alloc_named_type_ref`.
 * Memory management helper `find_or_alloc_named_type_ref`.
 * @param arena *ASTArena
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
export function find_or_alloc_named_type_ref(arena: *ASTArena, name: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let k: i32 = 0;
    let ko: i32 = 0;
    let exist_len: i32 = 0;
    let ord_named: i32 = 8;
    /* See implementation. */
    let nm_scr: *u8 = typeck_scratch64_slot(12);
    if (arena == 0 as *ASTArena || name == 0 as *u8 || name_len <= 0 || name_len > 127) {
      return 0;
    }
    k = 1;
    while (k <= arena.num_types) {
      ko = pipeline_type_kind_ord_at(arena, k);
      if (ko == ord_named) {
        exist_len = pipeline_type_named_name_into(arena, k, nm_scr);
        if (exist_len == name_len && name_equal(nm_scr, exist_len, name, name_len)) {
          return k;
        }
      }
      k = k + 1;
    }
    k = pipeline_arena_type_alloc(arena);
    if (k <= 0) {
      return 0;
    }
    if (pipeline_type_init_named_at(arena, k, name, name_len) == 0) {
      return 0;
    }
    return k;
  }
}

/**
* See implementation.
* See implementation.
* See implementation.
*/
export function typeck_field_access_lexer_wrapper_fallback(arena: *ASTArena, base_type_ref: i32,
field_name: *u8, field_name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (ast.ref_is_null(base_type_ref) || base_type_ref <= 0 || base_type_ref > arena.num_types) {
      return 0;
    }
    /* See implementation. */
    let bn: u8[128] = [];
    let bn_len: i32 = pipeline_type_named_name_into(arena, base_type_ref, &bn[0]);
    if (bn_len <= 0 || bn_len > 127) {
      return 0;
    }
    let nm_lexer: u8[5] = [76, 101, 120, 101, 114];
    let nm_next_lex: u8[8] = [110, 101, 120, 95, 108, 101, 120];
    let nm_token_start: u8[11] = [116, 111, 107, 101, 110, 95, 115, 116, 97, 114, 116];
    let nm_lex: u8[3] = [108, 101, 120];
    let nm_pos: u8[3] = [112, 111, 115];
    let nm_line: u8[4] = [108, 105, 110, 101];
    let nm_col: u8[3] = [99, 111, 108];
    let nm_lres: u8[11] = [76, 101, 120, 101, 114, 82, 101, 115, 117, 108, 116];
    let nm_cir: u8[21] = [67, 111, 108, 108, 101, 99, 116, 73, 109, 112, 111, 114, 116, 115, 82, 101,
    115, 117, 108, 116];
    let nm_tsar: u8[18] = [84, 114, 121, 83, 107, 105, 112, 65, 108, 108, 111, 119, 82, 101, 115, 117,
    108, 116];
    let nm_lpr: u8[19] = [76, 105, 98, 114, 97, 114, 121, 80, 97, 114, 115, 101, 82, 101, 115, 117,
    108, 116];
    let nm_per: u8[15] = [80, 97, 114, 115, 101, 69, 120, 112, 114, 82, 101, 115, 117, 108, 116];
    let nm_pbr: u8[16] = [80, 97, 114, 115, 101, 66, 108, 111, 99, 107, 82, 101, 115, 117, 108, 116];
    let nm_tlr: u8[17] = [84, 111, 112, 76, 101, 118, 101, 108, 76, 101, 116, 82, 101, 115, 117, 108,
    116];
    let lex_tr: i32 = find_or_alloc_named_type_ref(arena, &nm_lexer[0], 5);
    if (lex_tr == 0) {
      return 0;
    }
    if (field_name_len == 8 && name_equal(field_name, field_name_len, &nm_next_lex[0], 8)) {
      if (bn_len == 11 && name_equal(&bn[0], bn_len, &nm_lres[0], 11)) {
        return lex_tr;
      }
      if (bn_len == 19 && name_equal(&bn[0], bn_len, &nm_lpr[0], 19)) {
        return lex_tr;
      }
      if (bn_len == 15 && name_equal(&bn[0], bn_len, &nm_per[0], 15)) {
        return lex_tr;
      }
      if (bn_len == 16 && name_equal(&bn[0], bn_len, &nm_pbr[0], 16)) {
        return lex_tr;
      }
      if (bn_len == 17 && name_equal(&bn[0], bn_len, &nm_tlr[0], 17)) {
        return lex_tr;
      }
    }
    if (field_name_len == 11 && name_equal(field_name, field_name_len, &nm_token_start[0], 11)) {
      if (bn_len == 11 && name_equal(&bn[0], bn_len, &nm_lres[0], 11)) {
        return ensure_usize_type_ref(arena);
      }
    }
    if (field_name_len == 3 && name_equal(field_name, field_name_len, &nm_lex[0], 3)) {
      if (bn_len == 21 && name_equal(&bn[0], bn_len, &nm_cir[0], 21)) {
        return lex_tr;
      }
      if (bn_len == 18 && name_equal(&bn[0], bn_len, &nm_tsar[0], 18)) {
        return lex_tr;
      }
    }
    if (bn_len == 5 && name_equal(&bn[0], bn_len, &nm_lexer[0], 5)) {
      if (field_name_len == 3 && name_equal(field_name, field_name_len, &nm_pos[0], 3)) {
        return ensure_usize_type_ref(arena);
      }
      if (field_name_len == 4 && name_equal(field_name, field_name_len, &nm_line[0], 4)) {
        return ensure_i32_type_ref(arena);
      }
      if (field_name_len == 3 && name_equal(field_name, field_name_len, &nm_col[0], 3)) {
        return ensure_i32_type_ref(arena);
      }
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function typeck_ensure_primitive_by_kind_ord(arena: *ASTArena, kind_ord: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let k: i32 = 0;
    let ko: i32 = 0;
    let nlen: i32 = 0;
    let er: i32 = 0;
    let asz: i32 = 0;
    /* See implementation. */
    let nm_scr: *u8 = typeck_scratch64_slot(11);
    if (arena == 0 as *ASTArena || kind_ord < 0 || kind_ord > 16) {
      return 0;
    }
    k = 1;
    while (k <= arena.num_types) {
      ko = pipeline_type_kind_ord_at(arena, k);
      if (ko == kind_ord) {
        nlen = pipeline_type_named_name_into(arena, k, nm_scr);
        er = pipeline_type_elem_ref_at(arena, k);
        asz = pipeline_type_array_size_at(arena, k);
        if (nlen == 0 && er == 0 && asz == 0) {
          return k;
        }
      }
      k = k + 1;
    }
    k = pipeline_arena_type_alloc(arena);
    if (k <= 0) {
      return 0;
    }
    if (pipeline_type_init_primitive_kind_at(arena, k, kind_ord) == 0) {
      return 0;
    }
    return k;
  }
}

/** Exported function `ensure_i32_type_ref`.
 * Implements `ensure_i32_type_ref`.
 * @param arena *ASTArena
 * @return i32
 */
export function ensure_i32_type_ref(arena: *ASTArena): i32 {
  return typeck_ensure_primitive_by_kind_ord(arena, 0);
}

/** Exported function `ensure_u8_type_ref`.
 * Implements `ensure_u8_type_ref`.
 * @param arena *ASTArena
 * @return i32
 */
export function ensure_u8_type_ref(arena: *ASTArena): i32 {
  return typeck_ensure_primitive_by_kind_ord(arena, 2);
}

/** Exported function `ensure_bool_type_ref`.
 * Implements `ensure_bool_type_ref`.
 * @param arena *ASTArena
 * @return i32
 */
export function ensure_bool_type_ref(arena: *ASTArena): i32 {
  return typeck_ensure_primitive_by_kind_ord(arena, 1);
}

/** Exported function `ensure_f32_type_ref`.
 * Implements `ensure_f32_type_ref`.
 * @param arena *ASTArena
 * @return i32
 */
export function ensure_f32_type_ref(arena: *ASTArena): i32 {
  return typeck_ensure_primitive_by_kind_ord(arena, 14);
}

/** Exported function `ensure_f64_type_ref`.
 * Implements `ensure_f64_type_ref`.
 * @param arena *ASTArena
 * @return i32
 */
export function ensure_f64_type_ref(arena: *ASTArena): i32 {
  return typeck_ensure_primitive_by_kind_ord(arena, 15);
}

/** Exported function `ensure_usize_type_ref`.
 * Implements `ensure_usize_type_ref`.
 * @param arena *ASTArena
 * @return i32
 */
export function ensure_usize_type_ref(arena: *ASTArena): i32 {
  return typeck_ensure_primitive_by_kind_ord(arena, 6);
}

/** Exported function `ensure_void_type_ref`.
 * Implements `ensure_void_type_ref`.
 * @param a *ASTArena
 * @return i32
 */
export function ensure_void_type_ref(a: *ASTArena): i32 {
  return typeck_ensure_primitive_by_kind_ord(a, 16);
}

export extern function pipeline_typeck_get_dep_return_type_in_caller_arena_c(from_dep_index: i32,
dep_return_type_ref: i32, caller_arena: *ASTArena, ctx: *PipelineDepCtx): i32;
export extern function pipeline_typeck_set_entry_module_for_dep_map_c(module: *Module): void;

/* See implementation. */
export function get_dep_return_type_in_caller_arena(from_dep_index: i32, dep_return_type_ref: i32,
caller_arena: *ASTArena, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    return pipeline_typeck_get_dep_return_type_in_caller_arena_c(from_dep_index, dep_return_type_ref,
    caller_arena, ctx);
  }
}

/** Exported function `ensure_i64_type_ref`.
 * Implements `ensure_i64_type_ref`.
 * @param caller_arena *ASTArena
 * @return i32
 */
export function ensure_i64_type_ref(caller_arena: *ASTArena): i32 {
  return typeck_ensure_primitive_by_kind_ord(caller_arena, 5);
}

/**
 * See implementation.
 * See implementation.
 */
export function typeck_find_or_alloc_compound_type_ref(a: *ASTArena, kind_ord: i32, elem_ref: i32,
array_size: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let k: i32 = 0;
    let ko: i32 = 0;
    let er: i32 = 0;
    let asz: i32 = 0;
    let nlen: i32 = 0;
    let rlen: i32 = 0;
    let nm_scr: *u8 = typeck_scratch64_slot(13);
    if (a == 0 as *ASTArena || kind_ord < 0 || kind_ord > 16) {
      return 0;
    }
    k = 1;
    while (k <= a.num_types) {
      ko = pipeline_type_kind_ord_at(a, k);
      if (ko == kind_ord) {
        er = pipeline_type_elem_ref_at(a, k);
        asz = pipeline_type_array_size_at(a, k);
        nlen = pipeline_type_named_name_into(a, k, nm_scr);
        rlen = pipeline_type_region_label_len_at(a, k);
        if (er == elem_ref && asz == array_size && nlen == 0 && rlen == 0) {
          return k;
        }
      }
      k = k + 1;
    }
    k = pipeline_arena_type_alloc(a);
    if (k <= 0) {
      return 0;
    }
    if (pipeline_type_init_compound_kind_at(a, k, kind_ord, elem_ref, array_size) == 0) {
      return 0;
    }
    return k;
  }
}

/**
* See implementation.
*/
export function find_or_alloc_array_type_ref(a: *ASTArena, elem_ref: i32, array_size: i32): i32 {
  if (elem_ref == 0) {
    return 0;
  }
  return typeck_find_or_alloc_compound_type_ref(a, 10, elem_ref, array_size);
}

/**
* See implementation.
*/
export function ensure_array_type_ref_named_elem(a: *ASTArena, elem_nm: *u8, elem_nm_len: i32,
array_size: i32): i32 {
  let elem_ref: i32 = find_or_alloc_named_type_ref(a, elem_nm, elem_nm_len);
  if (elem_ref == 0) {
    return 0;
  }
  return find_or_alloc_array_type_ref(a, elem_ref, array_size);
}

/**
* See implementation.
* See implementation.
*/
export function ensure_kind_only_type_ref(w: *ASTArena, kind: TypeKind): i32 {
  /* See implementation. */
  return typeck_ensure_primitive_by_kind_ord(w, kind as i32);
}

/** Exported function `find_or_alloc_ptr_type_ref`.
 * Memory management helper `find_or_alloc_ptr_type_ref`.
 * @param w *ASTArena
 * @param elem_ref i32
 * @return i32
 */
export function find_or_alloc_ptr_type_ref(w: *ASTArena, elem_ref: i32): i32 {
  return typeck_find_or_alloc_compound_type_ref(w, 9, elem_ref, 0);
}

/** Exported function `find_or_alloc_slice_type_ref`.
 * Memory management helper `find_or_alloc_slice_type_ref`.
 * @param w *ASTArena
 * @param elem_ref i32
 * @return i32
 */
export function find_or_alloc_slice_type_ref(w: *ASTArena, elem_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    return pipeline_type_find_or_alloc_slice(w, elem_ref, 0 as *u8, 0);
  }
}

/** Exported function `find_or_alloc_linear_type_ref`.
 * Memory management helper `find_or_alloc_linear_type_ref`.
 * @param w *ASTArena
 * @param elem_ref i32
 * @return i32
 */
export function find_or_alloc_linear_type_ref(w: *ASTArena, elem_ref: i32): i32 {
  return typeck_find_or_alloc_compound_type_ref(w, 12, elem_ref, 0);
}

/** Exported function `find_or_alloc_vector_type_ref`.
 * Memory management helper `find_or_alloc_vector_type_ref`.
 * @param w *ASTArena
 * @param elem_ref i32
 * @param array_size i32
 * @return i32
 */
export function find_or_alloc_vector_type_ref(w: *ASTArena, elem_ref: i32, array_size: i32): i32 {
  return typeck_find_or_alloc_compound_type_ref(w, 13, elem_ref, array_size);
}

/**
* See implementation.
* See implementation.
*/
export function dep_return_type_to_caller_arena(dep_arena: *ASTArena, dep_return_type_ref: i32,
caller_arena: *ASTArena): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let kind: i32 = 0;
    let inner_mapped: i32 = 0;
    let elem_ref: i32 = 0;
    let array_size: i32 = 0;
    let nlen: i32 = 0;
    let nm_buf: *u8 = typeck_scratch64_slot(0);
    let ord_i32: i32 = 0;
    let ord_bool: i32 = 1;
    let ord_u8: i32 = 2;
    let ord_u32: i32 = 3;
    let ord_u64: i32 = 4;
    let ord_i64: i32 = 5;
    let ord_isize: i32 = 7;
    let ord_named: i32 = 8;
    let ord_ptr: i32 = 9;
    let ord_array: i32 = 10;
    let ord_slice: i32 = 11;
    let ord_linear: i32 = 12;
    let ord_vector: i32 = 13;
    let ord_f32: i32 = 14;
    let ord_f64: i32 = 15;
    let ord_usize: i32 = 6;
    let ord_void: i32 = 16;
    if (dep_return_type_ref <= 0) {
      return 0;
    }
    kind = pipeline_type_kind_ord_at(dep_arena, dep_return_type_ref);
    if (kind < 0) {
      return 0;
    }
    if (kind == ord_i32 || kind == ord_i64 || kind == ord_bool || kind == ord_f64 || kind == ord_u8 
    || kind == ord_u32
    || kind == ord_u64 || kind == ord_isize || kind == ord_f32 || kind == ord_usize || kind == 
    ord_void) {
      return typeck_ensure_primitive_by_kind_ord(caller_arena, kind);
    }
    if (kind == ord_named) {
      nlen = pipeline_type_named_name_into(dep_arena, dep_return_type_ref, nm_buf);
      if (nlen <= 0) {
        return 0;
      }
      return find_or_alloc_named_type_ref(caller_arena, nm_buf, nlen);
    }
    elem_ref = pipeline_type_elem_ref_at(dep_arena, dep_return_type_ref);
    inner_mapped = 0;
    if (!ast.ref_is_null(elem_ref)) {
      inner_mapped = dep_return_type_to_caller_arena(dep_arena, elem_ref, caller_arena);
      if (inner_mapped == 0) {
        return 0;
      }
    }
    array_size = pipeline_type_array_size_at(dep_arena, dep_return_type_ref);
    if (kind == ord_slice) {
      let rlen: i32 = pipeline_type_region_label_len_at(dep_arena, dep_return_type_ref);
      let rbuf: *u8 = typeck_scratch64_slot(14);
      if (rlen > 0) {
        pipeline_type_region_label_into(dep_arena, dep_return_type_ref, rbuf);
      }
      return pipeline_type_find_or_alloc_slice(caller_arena, inner_mapped, rbuf, rlen);
    }
    if (kind == ord_ptr) {
      return find_or_alloc_ptr_type_ref(caller_arena, inner_mapped);
    }
    if (kind == ord_linear) {
      return find_or_alloc_linear_type_ref(caller_arena, inner_mapped);
    }
    if (kind == ord_vector) {
      return find_or_alloc_vector_type_ref(caller_arena, inner_mapped, array_size);
    }
    if (kind == ord_array) {
      if (ast.ref_is_null(elem_ref) || array_size <= 0) {
        return 0;
      }
      return find_or_alloc_array_type_ref(caller_arena, inner_mapped, array_size);
    }
    if (!ast.ref_is_null(elem_ref) || array_size != 0) {
      return 0;
    }
    nlen = pipeline_type_named_name_into(dep_arena, dep_return_type_ref, nm_buf);
    if (nlen != 0) {
      return 0;
    }
    return typeck_ensure_primitive_by_kind_ord(caller_arena, kind);
  }
}

/**
* See implementation.
*/
export function expr_field_access_fallback_scalar_type_ref(arena: *ASTArena, field_name: *u8,
field_name_len: i32): i32 {
  /* See implementation. */
  if (field_name_len >= 4) {
    let br: i32 = field_name_len - 4;
    if (field_name[br] == 95 && field_name[br + 1] == 114 && field_name[br + 2] == 101 && 
    field_name[br + 3] == 102) {
      return ensure_i32_type_ref(arena);
    }
  }
  /* See implementation. */
  let nm_match_num_arms: u8[14] = [109, 97, 116, 99, 104, 95, 110, 117, 109, 95, 97, 114, 109, 115];
  let nm_field_access_is_enum_variant: u8[28] = [
  102, 105, 101, 108, 100, 95, 97, 99, 99, 101, 115, 115, 95, 105, 115, 95, 101, 110, 117, 109, 95,
  118, 97, 114, 105, 97, 110, 116
  ];
  let nm_field_access_field_len: u8[22] = [
  102, 105, 101, 108, 100, 95, 97, 99, 99, 101, 115, 115, 95, 102, 105, 101, 108, 100, 95, 108, 101,
  110
  ];
  let nm_field_access_offset: u8[19] = [102, 105, 101, 108, 100, 95, 97, 99, 99, 101, 115, 115, 95,
  111, 102, 102, 115, 101, 116];
  let nm_index_base_is_slice: u8[19] = [105, 110, 100, 101, 120, 95, 98, 97, 115, 101, 95, 105, 115,
  95, 115, 108, 105, 99, 101];
  let nm_call_num_args: u8[13] = [99, 97, 108, 108, 95, 110, 117, 109, 95, 97, 114, 103, 115];
  let nm_method_call_name_len: u8[20] = [
  109, 101, 116, 104, 111, 100, 95, 99, 97, 108, 108, 95, 110, 97, 109, 101, 95, 108, 101, 110
  ];
  let nm_method_call_num_args: u8[20] = [
  109, 101, 116, 104, 111, 100, 95, 99, 97, 108, 108, 95, 110, 117, 109, 95, 97, 114, 103, 115
  ];
  let nm_const_folded_val: u8[16] = [99, 111, 110, 115, 116, 95, 102, 111, 108, 100, 101, 100, 95,
  118, 97, 108];
  let nm_const_folded_valid: u8[18] = [99, 111, 110, 115, 116, 95, 102, 111, 108, 100, 101, 100, 95,
  118, 97, 108, 105, 100];
  let nm_index_proven_in_bounds: u8[22] = [
  105, 110, 100, 101, 120, 95, 112, 114, 111, 118, 101, 110, 95, 105, 110, 95, 98, 111, 117, 110,
  100, 115
  ];
  /* See implementation. */
  let nm_call_resolved_func_index: u8[24] = [
  99, 97, 108, 108, 95, 114, 101, 115, 111, 108, 118, 101, 100, 95, 102, 117, 110, 99, 95, 105, 110,
  100, 101, 120
  ];
  let nm_call_resolved_dep_index: u8[22] = [
  99, 97, 108, 108, 95, 114, 101, 115, 111, 108, 118, 101, 100, 95, 100, 101, 112, 95, 105, 110,
  100, 101, 120
  ];
  let nm_enum_variant_tag: u8[16] = [
  101, 110, 117, 109, 95, 118, 97, 114, 105, 97, 110, 116, 95, 116, 97, 103
  ];
  if (field_name_len == 14 && name_equal(field_name, field_name_len, &nm_match_num_arms[0], 14)) {
    return ensure_i32_type_ref(arena);
  }
  if (field_name_len == 28 && name_equal(field_name, field_name_len,
  &nm_field_access_is_enum_variant[0], 28)) {
    return ensure_i32_type_ref(arena);
  }
  if (field_name_len == 22 && name_equal(field_name, field_name_len, &nm_field_access_field_len[0],
  22)) {
    return ensure_i32_type_ref(arena);
  }
  if (field_name_len == 19 && name_equal(field_name, field_name_len, &nm_field_access_offset[0],
  19)) {
    return ensure_i32_type_ref(arena);
  }
  if (field_name_len == 19 && name_equal(field_name, field_name_len, &nm_index_base_is_slice[0],
  19)) {
    return ensure_i32_type_ref(arena);
  }
  if (field_name_len == 13 && name_equal(field_name, field_name_len, &nm_call_num_args[0], 13)) {
    return ensure_i32_type_ref(arena);
  }
  if (field_name_len == 20 && name_equal(field_name, field_name_len, &nm_method_call_name_len[0],
  20)) {
    return ensure_i32_type_ref(arena);
  }
  if (field_name_len == 20 && name_equal(field_name, field_name_len, &nm_method_call_num_args[0],
  20)) {
    return ensure_i32_type_ref(arena);
  }
  if (field_name_len == 16 && name_equal(field_name, field_name_len, &nm_const_folded_val[0], 16)) {
    return ensure_i32_type_ref(arena);
  }
  if (field_name_len == 18 && name_equal(field_name, field_name_len, &nm_const_folded_valid[0],
  18)) {
    return ensure_i32_type_ref(arena);
  }
  if (field_name_len == 22 && name_equal(field_name, field_name_len, &nm_index_proven_in_bounds[0],
  22)) {
    return ensure_i32_type_ref(arena);
  }
  if (field_name_len == 24 && name_equal(field_name, field_name_len,
  &nm_call_resolved_func_index[0], 24)) {
    return ensure_i32_type_ref(arena);
  }
  if (field_name_len == 22 && name_equal(field_name, field_name_len, &nm_call_resolved_dep_index[0],
  22)) {
    return ensure_i32_type_ref(arena);
  }
  if (field_name_len == 16 && name_equal(field_name, field_name_len, &nm_enum_variant_tag[0], 16)) {
    return ensure_i32_type_ref(arena);
  }
  return 0;
}

/* See implementation. */
export function get_field_type_ref_from_layout_deps(module: *Module, arena: *ASTArena,
ctx: *PipelineDepCtx, type_name: *u8, type_name_len: i32, field_name: *u8,
field_name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    /**
    * See implementation.
    * See implementation.
    */
    let nm_funcs_pool: u8[5] = [102, 117, 110, 99, 115];
    let nm_func_elem: u8[4] = [70, 117, 110, 99];
    if (field_name_len == 5 && name_equal(field_name, field_name_len, &nm_funcs_pool[0], 5)) {
      let arr_funcs_pool: i32 = ensure_array_type_ref_named_elem(arena, &nm_func_elem[0], 4, 256);
      if (arr_funcs_pool != 0) {
        return arr_funcs_pool;
      }
    }
    let nm_struct_layouts_pool: u8[14] = [115, 116, 114, 117, 99, 116, 95, 108, 97, 121, 111, 117,
    116, 115];
    let nm_sl_elem: u8[12] = [83, 116, 114, 117, 99, 116, 76, 97, 121, 111, 117, 116];
    if (field_name_len == 14 && name_equal(field_name, field_name_len, &nm_struct_layouts_pool[0],
    14)) {
      let arr_sl_pool: i32 = ensure_array_type_ref_named_elem(arena, &nm_sl_elem[0], 12, 32);
      if (arr_sl_pool != 0) {
        return arr_sl_pool;
      }
    }
    let nm_num_struct_layouts_pool: u8[18] = [110, 117, 109, 95, 115, 116, 114, 117, 99, 116, 95, 108,
    97, 121, 111, 117, 116, 115];
    if (field_name_len == 18 && name_equal(field_name, field_name_len, &nm_num_struct_layouts_pool[0],
    18)) {
      return ensure_i32_type_ref(arena);
    }
    let u8_inline: i32 = typeck_inline_u8_64_array_field_type_ref(arena, field_name, field_name_len);
    if (u8_inline != 0) {
      return u8_inline;
    }
    let i32_arr_inline: i32 = typeck_expr_inline_array_field_type_ref(arena, field_name,
    field_name_len);
    if (i32_arr_inline != 0) {
      return i32_arr_inline;
    }
    let r: i32 = get_field_type_ref_from_layout(module, type_name, type_name_len, field_name,
    field_name_len);
    if (r != 0) {
      return r;
    }
    if (ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    /* See implementation. */
    let nd2: i32 = pipeline_dep_ctx_ndep(ctx);
    let di: i32 = 0;
    while (di < nd2) {
      let dm: *Module = pipeline_dep_ctx_module_at(ctx, di);
      if (dm != 0 as *Module) {
        r = get_field_type_ref_from_layout(dm, type_name, type_name_len, field_name, field_name_len);
        if (r != 0) {
          let da: *ASTArena = pipeline_dep_ctx_arena_at(ctx, di);
          if (da != 0 as *ASTArena) {
            return dep_return_type_to_caller_arena(da, r, arena);
          }
          return r;
        }
      }
      di = di + 1;
    }
    /* See implementation. */
    if (type_name_len == 4 && type_name[0] == 69 && type_name[1] == 120 && type_name[2] == 112 && 
    type_name[3] == 114) {
      let u8_fb: i32 = typeck_inline_u8_64_array_field_type_ref(arena, field_name, field_name_len);
      if (u8_fb != 0) {
        return u8_fb;
      }
      let arr_fb: i32 = typeck_expr_inline_array_field_type_ref(arena, field_name, field_name_len);
      if (arr_fb != 0) {
        return arr_fb;
      }
      let fb: i32 = expr_field_access_fallback_scalar_type_ref(arena, field_name, field_name_len);
      if (fb != 0) {
        return fb;
      }
    }
    /* See implementation. */
    if (type_name_len == 4 && type_name[0] == 84 && type_name[1] == 121 && type_name[2] == 112 && 
    type_name[3] == 101) {
      let u8_ty: i32 = typeck_inline_u8_64_array_field_type_ref(arena, field_name, field_name_len);
      if (u8_ty != 0) {
        return u8_ty;
      }
    }
    /* See implementation. */
    if (type_name_len == 4 && type_name[0] == 70 && type_name[1] == 117 && type_name[2] == 110 && 
    type_name[3] == 99) {
      let u8_fn: i32 = typeck_inline_u8_64_array_field_type_ref(arena, field_name, field_name_len);
      if (u8_fn != 0) {
        return u8_fn;
      }
      let nm_params: u8[6] = [112, 97, 114, 97, 109, 115];
      let nm_pa: u8[5] = [80, 97, 114, 97, 109];
      if (field_name_len == 6 && name_equal(field_name, field_name_len, &nm_params[0], 6)) {
        return ensure_array_type_ref_named_elem(arena, &nm_pa[0], 5, 16);
      }
      let fb_fn: i32 = expr_field_access_fallback_scalar_type_ref(arena, field_name, field_name_len);
      if (fb_fn != 0) {
        return fb_fn;
      }
    }
    /* See implementation. */
    if (type_name_len == 5 && type_name[0] == 80 && type_name[1] == 97 && type_name[2] == 114 && 
    type_name[3] == 97 && type_name[4] == 109) {
      let nm_pname: u8[4] = [110, 97, 109, 101];
      if (field_name_len == 4 && name_equal(field_name, field_name_len, &nm_pname[0], 4)) {
        let u8r_p: i32 = ensure_u8_type_ref(arena);
        if (u8r_p != 0) {
          return find_or_alloc_array_type_ref(arena, u8r_p, 32);
        }
      }
    }
    /* See implementation. */
    if (type_name_len == 12 && type_name[0] == 83 && type_name[1] == 116 && type_name[2] == 114 && 
    type_name[3] == 117
    && type_name[4] == 99 && type_name[5] == 116 && type_name[6] == 76 && type_name[7] == 97
    && type_name[8] == 121 && type_name[9] == 111 && type_name[10] == 117 && type_name[11] == 116) {
      let u8r_sl: i32 = ensure_u8_type_ref(arena);
      let i32r_sl: i32 = ensure_i32_type_ref(arena);
      let nm_sl_name: u8[4] = [110, 97, 109, 101];
      let nm_sl_field_names: u8[11] = [102, 105, 101, 108, 100, 95, 110, 97, 109, 101, 115];
      let nm_sl_field_lens: u8[11] = [102, 105, 101, 108, 100, 95, 108, 101, 110, 115];
      let nm_sl_field_offsets: u8[13] = [102, 105, 101, 108, 100, 95, 111, 102, 102, 115, 101, 116,
      115];
      let nm_sl_field_type_refs: u8[15] = [102, 105, 101, 108, 100, 95, 116, 121, 112, 101, 95, 114,
      101, 102, 115];
      let nm_sl_num_fields: u8[10] = [110, 117, 109, 95, 102, 105, 101, 108, 100, 115];
      let nm_sl_allow_padding: u8[14] = [97, 108, 108, 111, 119, 95, 112, 97, 100, 100, 105, 110,
      103];
      if (field_name_len == 4 && name_equal(field_name, field_name_len, &nm_sl_name[0],
      4) && u8r_sl != 0) {
        return find_or_alloc_array_type_ref(arena, u8r_sl, 64);
      }
      if (field_name_len == 11 && name_equal(field_name, field_name_len, &nm_sl_field_names[0],
      11) && u8r_sl != 0) {
        let row_u8: i32 = find_or_alloc_array_type_ref(arena, u8r_sl, 64);
        if (row_u8 != 0) {
          return find_or_alloc_array_type_ref(arena, row_u8, 64);
        }
      }
      if (field_name_len == 11 && name_equal(field_name, field_name_len, &nm_sl_field_lens[0],
      11) && i32r_sl != 0) {
        return find_or_alloc_array_type_ref(arena, i32r_sl, 64);
      }
      if (field_name_len == 13 && name_equal(field_name, field_name_len, &nm_sl_field_offsets[0],
      13) && i32r_sl != 0) {
        return find_or_alloc_array_type_ref(arena, i32r_sl, 64);
      }
      if (field_name_len == 15 && name_equal(field_name, field_name_len, &nm_sl_field_type_refs[0],
      15) && i32r_sl != 0) {
        return find_or_alloc_array_type_ref(arena, i32r_sl, 64);
      }
      if (field_name_len == 10 && name_equal(field_name, field_name_len, &nm_sl_num_fields[0], 10)) {
        return i32r_sl;
      }
      if (field_name_len == 14 && name_equal(field_name, field_name_len, &nm_sl_allow_padding[0],
      14)) {
        return i32r_sl;
      }
      if (field_name_len == 8 && field_name[0] == 110 && field_name[1] == 97 && field_name[2] == 109 
      && field_name[3] == 101
      && field_name[4] == 95 && field_name[5] == 108 && field_name[6] == 101 && field_name[7] == 110) 
      {
        return i32r_sl;
      }
    }
    return 0;
  }
}

/**
* See implementation.
* See implementation.
*/
export function typeck_inline_u8_64_array_field_type_ref(arena: *ASTArena, field_name: *u8,
field_name_len: i32): i32 {
  let u8r: i32 = ensure_u8_type_ref(arena);
  if (u8r == 0) {
    return 0;
  }
  let nm_name: u8[4] = [110, 97, 109, 101];
  let nm_var_name: u8[8] = [118, 97, 114, 95, 110, 97, 109, 101];
  let nm_field_access_field_name: u8[22] = [
  102, 105, 101, 108, 100, 95, 97, 99, 99, 101, 115, 115, 95, 102, 105, 101, 108, 100, 95, 110, 97,
  109, 101
  ];
  let nm_method_call_name: u8[16] = [
  109, 101, 116, 104, 111, 100, 95, 99, 97, 108, 108, 95, 110, 97, 109, 101
  ];
  let nm_struct_lit_struct_name: u8[22] = [
  115, 116, 114, 117, 99, 116, 95, 108, 105, 116, 95, 115, 116, 114, 117, 99, 116, 95, 110, 97, 109,
  101
  ];
  if (field_name_len == 4 && name_equal(field_name, field_name_len, &nm_name[0], 4)) {
    return find_or_alloc_array_type_ref(arena, u8r, 64);
  }
  if (field_name_len == 8 && name_equal(field_name, field_name_len, &nm_var_name[0], 8)) {
    return find_or_alloc_array_type_ref(arena, u8r, 64);
  }
  if (field_name_len == 22 && name_equal(field_name, field_name_len, &nm_field_access_field_name[0],
  22)) {
    return find_or_alloc_array_type_ref(arena, u8r, 64);
  }
  if (field_name_len == 16 && name_equal(field_name, field_name_len, &nm_method_call_name[0], 16)) {
    return find_or_alloc_array_type_ref(arena, u8r, 64);
  }
  if (field_name_len == 22 && name_equal(field_name, field_name_len, &nm_struct_lit_struct_name[0],
  22)) {
    return find_or_alloc_array_type_ref(arena, u8r, 64);
  }
  return 0;
}

/* See implementation. */
export function typeck_expr_inline_array_field_type_ref(arena: *ASTArena, field_name: *u8,
field_name_len: i32): i32 {
  let i32r: i32 = ensure_i32_type_ref(arena);
  if (i32r == 0) {
    return 0;
  }
  let nm_call_arg_refs: u8[13] = [99, 97, 108, 108, 95, 97, 114, 103, 95, 114, 101, 102, 115];
  let nm_method_call_arg_refs: u8[20] = [
  109, 101, 116, 104, 111, 100, 95, 99, 97, 108, 108, 95, 97, 114, 103, 95, 114, 101, 102, 115
  ];
  let nm_match_arm_result_refs: u8[21] = [
  109, 97, 116, 99, 104, 95, 97, 114, 109, 95, 114, 101, 115, 117, 108, 116, 95, 114, 101, 102, 115
  ];
  let nm_array_lit_elem_refs: u8[19] = [
  97, 114, 114, 97, 121, 95, 108, 105, 116, 95, 101, 108, 101, 109, 95, 114, 101, 102, 115
  ];
  /* See implementation. */
  let nm_match_arm_is_wildcard: u8[21] = [
  109, 97, 116, 99, 104, 95, 97, 114, 109, 95, 105, 115, 95, 119, 105, 108, 100, 99, 97, 114, 100
  ];
  let nm_match_arm_lit_val: u8[17] = [
  109, 97, 116, 99, 104, 95, 97, 114, 109, 95, 108, 105, 116, 95, 118, 97, 108
  ];
  let nm_match_arm_is_enum_variant: u8[25] = [
  109, 97, 116, 99, 104, 95, 97, 114, 109, 95, 105, 115, 95, 101, 110, 117, 109, 95, 118, 97, 114,
  105, 97, 110, 116
  ];
  let nm_match_arm_variant_index: u8[23] = [
  109, 97, 116, 99, 104, 95, 97, 114, 109, 95, 118, 97, 114, 105, 97, 110, 116, 95, 105, 110, 100,
  101, 120
  ];
  if (field_name_len == 13 && name_equal(field_name, field_name_len, &nm_call_arg_refs[0], 13)) {
    return find_or_alloc_array_type_ref(arena, i32r, 16);
  }
  if (field_name_len == 20 && name_equal(field_name, field_name_len, &nm_method_call_arg_refs[0],
  20)) {
    return find_or_alloc_array_type_ref(arena, i32r, 16);
  }
  if (field_name_len == 21 && name_equal(field_name, field_name_len, &nm_match_arm_result_refs[0],
  21)) {
    return find_or_alloc_array_type_ref(arena, i32r, 16);
  }
  if (field_name_len == 19 && name_equal(field_name, field_name_len, &nm_array_lit_elem_refs[0],
  19)) {
    return find_or_alloc_array_type_ref(arena, i32r, 16);
  }
  if (field_name_len == 21 && name_equal(field_name, field_name_len, &nm_match_arm_is_wildcard[0],
  21)) {
    return find_or_alloc_array_type_ref(arena, i32r, 16);
  }
  if (field_name_len == 17 && name_equal(field_name, field_name_len, &nm_match_arm_lit_val[0],
  17)) {
    return find_or_alloc_array_type_ref(arena, i32r, 16);
  }
  if (field_name_len == 25 && name_equal(field_name, field_name_len,
  &nm_match_arm_is_enum_variant[0], 25)) {
    return find_or_alloc_array_type_ref(arena, i32r, 16);
  }
  if (field_name_len == 23 && name_equal(field_name, field_name_len, &nm_match_arm_variant_index[0],
  23)) {
    return find_or_alloc_array_type_ref(arena, i32r, 16);
  }
  return 0;
}

/** Exported function `entry_module_find_struct_layout_index`.
 * Implements `entry_module_find_struct_layout_index`.
 * @param mod *Module
 * @param nm *u8
 * @param nlen i32
 * @return i32
 */
export function entry_module_find_struct_layout_index(mod: *Module, nm: *u8, nlen: i32): i32 {
  return typeck_find_layout_idx_by_type_name(mod, nm, nlen);
}

/**
* See implementation.
*/
export function typeck_merge_dep_struct_layouts_into_entry(mod: *Module, arena: *ASTArena,
ctx: *PipelineDepCtx): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    /* See implementation. */
    let nd_merge: i32 = 0;
    let di: i32 = 0;
    let dm: *Module = 0 as *Module;
    let darena: *ASTArena = 0 as *ASTArena;
    let k: i32 = 0;
    let nl: i32 = 0;
    let nf_dep: i32 = 0;
    let ex: i32 = 0;
    let need: i32 = 0;
    let weak_entry: bool = false;
    let is_expr_nm: bool = false;
    let ni: i32 = 0;
    let j: i32 = 0;
    let raw_fr: i32 = 0;
    let mapped: i32 = 0;
    let fnlen: i32 = 0;
    let foff: i32 = 0;
    let ndm_sl: i32 = 0;
    /* See implementation. */
    let dep_nm_buf: *u8 = typeck_scratch64_slot(9);
    let fn_buf: *u8 = typeck_scratch64_slot(10);
    if (ctx == 0 as *PipelineDepCtx) {
      return;
    }
    nd_merge = pipeline_dep_ctx_ndep(ctx);
    di = 0;
    while (di < nd_merge) {
      dm = pipeline_dep_ctx_module_at(ctx, di);
      darena = pipeline_dep_ctx_arena_at(ctx, di);
      if (dm == 0 as *Module || darena == 0 as *ASTArena) {
        di = di + 1;
        continue;
      }
      ndm_sl = pipeline_module_num_struct_layouts_at(dm);
      k = 0;
      while (k < ndm_sl) {
        nl = pipeline_module_struct_layout_name_len(dm, k);
        /* wave583 Cap residual: merge layout names ≤127 (scratch64 slots are 128 bytes). */
        if (nl > 0 && nl <= 127) {
          nf_dep = pipeline_module_struct_layout_num_fields(dm, k);
          if (nf_dep > 64) {
            nf_dep = 64;
          }
          pipeline_module_struct_layout_name_into(dm, k, dep_nm_buf);
          ex = entry_module_find_struct_layout_index(mod, dep_nm_buf, nl);
          need = 0;
          if (ex < 0) {
            need = 1;
          } else {
            weak_entry = false;
            /* See implementation. */
            if (pipeline_module_struct_layout_num_fields(mod,
            ex) >= 2 && pipeline_module_struct_layout_field_type_ref(mod, ex, 1) == 0) {
              weak_entry = true;
            }
            /* See implementation. */
            is_expr_nm = false;
            if (nl == 4) {
              if (pipeline_module_struct_layout_name_byte_at(dm, k,
              0) == 69 && pipeline_module_struct_layout_name_byte_at(dm, k, 1) == 120
              && pipeline_module_struct_layout_name_byte_at(dm, k, 2) == 112
              && pipeline_module_struct_layout_name_byte_at(dm, k, 3) == 114) {
                is_expr_nm = true;
              }
            }
            if (nf_dep > pipeline_module_struct_layout_num_fields(mod,
            ex) || weak_entry || is_expr_nm) {
              need = 1;
            }
            // wave1220 P5: also re-copy when field counts match but types may differ.
            // Root cause: typeck_ensure_struct_layout_from_struct_lit creates layouts
            // from struct literal init expressions (e.g. token_start: 0 → I32 instead
            // of USIZE). When the dep module's authoritative layout has the same field
            // count, the old `>` condition skipped the re-copy, leaving wrong field
            // types. Using `>=` ensures dep authority always overwrites struct-lit
            // guesses. PLATFORM: SHARED — typeck only, no runtime impact.
            if (nf_dep > 0 && nf_dep >= pipeline_module_struct_layout_num_fields(mod,
            ex) && pipeline_module_struct_layout_num_fields(mod, ex) > 0) {
              need = 1;
            }
            /* See implementation. */
            if (pipeline_module_struct_layout_soa_at(dm, k) != 0
            && pipeline_module_struct_layout_soa_at(mod, ex) == 0) {
              need = 1;
            }
          }
          if (need != 0) {
            ni = ex;
            if (ex < 0) {
              ni = pipeline_module_struct_layout_alloc(mod);
              if (ni < 0) {
                k = k + 1;
                continue;
              }
            }
            pipeline_module_struct_layout_reset_slot(mod, ni);
            pipeline_module_struct_layout_set_name(mod, ni, dep_nm_buf, nl);
            j = 0;
            while (j < nf_dep) {
              raw_fr = pipeline_module_struct_layout_field_type_ref(dm, k, j);
              mapped = 0;
              if (raw_fr != 0) {
                mapped = dep_return_type_to_caller_arena(darena, raw_fr, arena);
              }
              fnlen = pipeline_module_struct_layout_field_name_len(dm, k, j);
              pipeline_module_struct_layout_field_name_into(dm, k, j, fn_buf);
              foff = pipeline_module_struct_layout_field_offset_at(dm, k, j);
              pipeline_module_struct_layout_set_field(mod, ni, j, fn_buf, fnlen, mapped, foff);
              pipeline_module_struct_layout_set_field_align(mod, ni, j,
              pipeline_module_struct_layout_field_align_at(dm, k, j));
              j = j + 1;
            }
            pipeline_module_struct_layout_set_num_fields(mod, ni, nf_dep);
            /* See implementation. */
            pipeline_module_struct_layout_set_allow_padding(mod, ni,
            pipeline_module_struct_layout_allow_padding_at(dm, k));
            pipeline_module_struct_layout_set_soa(mod, ni,
            pipeline_module_struct_layout_soa_at(dm, k));
            pipeline_module_struct_layout_set_packed(mod, ni,
            pipeline_module_struct_layout_packed_at(dm, k));
          }
        }
        k = k + 1;
      }
      di = di + 1;
    }
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function typeck_wpo_unify_soa_layouts(entry: *Module, ctx: *PipelineDepCtx): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let nd: i32 = 0;
    let mi: i32 = 0;
    let dm: *Module = 0 as *Module;
    let nsl: i32 = 0;
    let k: i32 = 0;
    let nl: i32 = 0;
    let any_soa: i32 = 0;
    let mj: i32 = 0;
    let dm2: *Module = 0 as *Module;
    let nsl2: i32 = 0;
    let k2: i32 = 0;
    let nl2: i32 = 0;
    let li: i32 = 0;
    let nm_buf: *u8 = typeck_scratch64_slot(11);
    let nm2: *u8 = typeck_scratch64_slot(12);
    if (entry == 0 as *Module || ctx == 0 as *PipelineDepCtx) {
      return;
    }
    nd = pipeline_dep_ctx_ndep(ctx);
    mi = -1;
    while (mi < nd) {
      dm = entry;
      if (mi >= 0) {
        dm = pipeline_dep_ctx_module_at(ctx, mi);
      }
      if (dm == 0 as *Module) {
        mi = mi + 1;
        continue;
      }
      nsl = pipeline_module_num_struct_layouts_at(dm);
      k = 0;
      while (k < nsl) {
        nl = pipeline_module_struct_layout_name_len(dm, k);
        /* wave583 Cap residual: WPO SoA unify layout names ≤127. */
        if (nl > 0 && nl <= 127) {
          pipeline_module_struct_layout_name_into(dm, k, nm_buf);
          any_soa = pipeline_module_struct_layout_soa_at(dm, k);
          mj = -1;
          while (mj < nd && any_soa == 0) {
            dm2 = entry;
            if (mj >= 0) {
              dm2 = pipeline_dep_ctx_module_at(ctx, mj);
            }
            if (dm2 != 0 as *Module) {
              nsl2 = pipeline_module_num_struct_layouts_at(dm2);
              k2 = 0;
              while (k2 < nsl2 && any_soa == 0) {
                nl2 = pipeline_module_struct_layout_name_len(dm2, k2);
                if (nl2 == nl) {
                  pipeline_module_struct_layout_name_into(dm2, k2, nm2);
                  if (name_equal(nm_buf, nl, nm2, nl2)
                  && pipeline_module_struct_layout_soa_at(dm2, k2) != 0) {
                    any_soa = 1;
                  }
                }
                k2 = k2 + 1;
              }
            }
            mj = mj + 1;
          }
          if (any_soa != 0) {
            mj = -1;
            while (mj < nd) {
              dm2 = entry;
              if (mj >= 0) {
                dm2 = pipeline_dep_ctx_module_at(ctx, mj);
              }
              if (dm2 != 0 as *Module) {
                li = typeck_find_layout_idx_by_type_name(dm2, nm_buf, nl);
                if (li >= 0 && pipeline_module_struct_layout_soa_at(dm2, li) == 0) {
                  pipeline_module_struct_layout_set_soa(dm2, li, 1);
                }
              }
              mj = mj + 1;
            }
          }
        }
        k = k + 1;
      }
      mi = mi + 1;
    }
  }
}

/**
* See implementation.
*/
export function typeck_resolve_scan_dep_with_apply(module: *Module, arena: *ASTArena, callee_expr_ref: i32,
callee_ord: i32, call_expr_ref: i32, ctx: *PipelineDepCtx, dep_i: i32, imax: i32,
want_apply: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let dm: *Module = 0 as *Module;
    let ret: i32 = 0;
    let fn_slot: *i32 = typeck_call_resolve_func_idx_slot();
    if (dep_i >= imax) {
      return 0;
    }
    dm = pipeline_dep_ctx_module_at(ctx, dep_i);
    if (dm != 0 as *Module) {
      typeck_i32_ptr_store(fn_slot, 0);
      ret = find_func_return_type_in_module(dm, arena, arena, arena, callee_expr_ref, dep_i, ctx,
      fn_slot);
      if (ret != 0) {
        if (want_apply != 0) {
          ast.ast_expr_apply_call_resolve(arena, call_expr_ref, dep_i, typeck_call_resolve_func_idx_peek());
        }
        return ret;
      }
      if (dep_i < typeck_module_num_imports(module)) {
        ret = resolve_call_select_import_return_type(module, arena, callee_expr_ref, callee_ord,
        dep_i, ctx, fn_slot);
        if (ret != 0) {
          if (want_apply != 0) {
            ast.ast_expr_apply_call_resolve(arena, call_expr_ref, dep_i, typeck_call_resolve_func_idx_peek());
          }
          return ret;
        }
      }
    }
    return typeck_resolve_scan_dep_with_apply(module, arena, callee_expr_ref, callee_ord,
    call_expr_ref, ctx, dep_i + 1, imax, want_apply);
  }
}

/* See implementation. */
export function find_func_return_type_in_module(mod: *Module, mod_arena: *ASTArena,
caller_arena: *ASTArena, callee_arena: *ASTArena, callee_expr_ref: i32, from_dep_index: i32,
ctx: *PipelineDepCtx, func_index_out: *i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let j: i32 = 0;
    while (j < mod.num_funcs) {
      if (expr_var_name_equal_func(callee_arena, callee_expr_ref, mod, j)) {
        if (func_index_out != 0 as *i32) {
          func_index_out[0] = j;
        }
        let ret_dep: i32 = pipeline_module_func_return_type_at(mod, j);
        if (from_dep_index < 0) {
          return ret_dep;
        }
        return get_dep_return_type_in_caller_arena(from_dep_index, ret_dep, caller_arena, ctx);
      }
      j = j + 1;
    }
    return 0;
  }
}

/* See implementation. */
export extern function pipeline_visibility_allow_func(mod: *Module, fi: i32, cross_module: i32): i32;

/** See implementation for details. */
export function find_func_return_type_in_module_by_name(mod: *Module, caller_arena: *ASTArena, name: *u8,
name_len: i32, from_dep_index: i32, ctx: *PipelineDepCtx, func_index_out: *i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (name_len <= 0 || name_len > 127) {
      return 0;
    }
    let j: i32 = 0;
    while (j < mod.num_funcs) {
      if (pipeline_module_func_name_equal_at(mod, j, name, name_len) != 0) {
        if (from_dep_index >= 0 && pipeline_visibility_allow_func(mod, j, 1) == 0) {
          j = j + 1;
          continue;
        }
        if (func_index_out != 0 as *i32) {
          func_index_out[0] = j;
        }
        let rtr: i32 = pipeline_module_func_return_type_at(mod, j);
        if (from_dep_index < 0) {
          return rtr;
        }
        return get_dep_return_type_in_caller_arena(from_dep_index, rtr, caller_arena, ctx);
      }
      j = j + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function typeck_overload_arg_param_score(caller_arena: *ASTArena, call_expr_ref: i32, arg_i: i32,
param_ty_raw: i32, from_dep_index: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let arg_ref: i32 = 0;
    let arg_ty: i32 = 0;
    let param_ty: i32 = 0;
    let ord_as: i32 = 54;
    let as_tgt: i32 = 0;
    if (caller_arena == 0 as *ASTArena || call_expr_ref <= 0 || arg_i < 0) {
      return -1;
    }
    arg_ref = pipeline_expr_call_arg_ref(caller_arena, call_expr_ref, arg_i);
    if (arg_ref <= 0) {
      return -1;
    }
    param_ty = param_ty_raw;
    if (from_dep_index >= 0) {
      param_ty = get_dep_return_type_in_caller_arena(from_dep_index, param_ty_raw, caller_arena, ctx);
      if (param_ty == 0) {
        return -1;
      }
    }
    if (param_ty <= 0) {
      return -1;
    }
    arg_ty = pipeline_expr_resolved_type_ref(caller_arena, arg_ref);
    if (arg_ty > 0 && pipeline_typeck_type_refs_equal_c(caller_arena, arg_ty, param_ty) != 0) {
      return 1000;
    }
    if (pipeline_expr_kind_ord_at(caller_arena, arg_ref) == ord_as) {
      as_tgt = pipeline_expr_as_target_type_ref_at(caller_arena, arg_ref);
      if (as_tgt > 0 && pipeline_typeck_type_refs_equal_c(caller_arena, as_tgt, param_ty) != 0) {
        return 1000;
      }
    }
    /*
     * PLATFORM: SHARED — string lit is *u8 by default (C interop) but also matches
     * u8[] (TYPE_SLICE of u8) for product single-arg print/println("…") and any
     * other u8[] param. Score 1000 so 1-arg slice overload wins over no-match.
     */
    if (pipeline_expr_kind_ord_at(caller_arena, arg_ref) == 59) {
      let pk_sl: i32 = pipeline_type_kind_ord_at(caller_arena, param_ty);
      let pe_sl: i32 = 0;
      let u8_ord: i32 = 2;
      if (pk_sl == 9 || pk_sl == 11) {
        pe_sl = pipeline_type_elem_ref_at(caller_arena, param_ty);
        if (pe_sl > 0 && pipeline_type_kind_ord_at(caller_arena, pe_sl) == u8_ord) {
          return 1000;
        }
      }
    }
    /*
     * See implementation.
     * See implementation.
     * See implementation.
     */
    if (pipeline_expr_kind_ord_at(caller_arena, arg_ref) == 0) {
      let pk_lit: i32 = pipeline_type_kind_ord_at(caller_arena, param_ty);
      /*
       * wave670 Cap residual: keyword `null` only scores for TYPE_PTR formals.
       * Bare INT 0 still weak-matches integers + ptr. G.7 single score path.
       * PLATFORM: SHARED — keep strict_minimal arg score aligned.
       */
      if (typeck_expr_is_null_keyword(caller_arena, arg_ref) != 0) {
        if (pk_lit == 9) {
          return 100;
        }
        return -1;
      }
      if (pk_lit == 0 || pk_lit == 2 || pk_lit == 3 || pk_lit == 4 || pk_lit == 5 || pk_lit == 6
          || pk_lit == 7) {
        return 100;
      }
      /*
       * wave668 Cap residual: bare EXPR_LIT 0 weak-matches TYPE_PTR formals —
       * same contract as let/return/cmp 0→*T coerce. Score 100 < exact 1000.
       * Non-zero lit to *T stays -1.
       */
      if (pk_lit == 9 && pipeline_expr_int_val_at(caller_arena, arg_ref) == 0) {
        return 100;
      }
    }
    /* See implementation. */
    if (arg_ty > 0) {
      let ak: i32 = pipeline_type_kind_ord_at(caller_arena, arg_ty);
      let pk: i32 = pipeline_type_kind_ord_at(caller_arena, param_ty);
      /*
       * Integer widen (typeck_integer_widen_ok_refs): first-class + NAMED i8/i16/u16.
       * i32→usize for heap.alloc(al, capacity) so 2-arg Allocator+usize is not eliminated.
       * Score 100 < exact 1000; expected-return is a separate tie-break (not in arg score).
       * PLATFORM: SHARED — keep strict_minimal arg score aligned (wave313).
       */
      if (typeck_integer_widen_ok_refs(caller_arena, param_ty, arg_ty)) {
        return 100;
      }
      /* wave314: f32→f64 IEEE promotion scores as widen (not exact). */
      if (typeck_float_widen_ok(pk, ak)) {
        return 100;
      }
      /* See implementation. */
      if (ak == 10 && pk == 9) {
        let ae: i32 = pipeline_type_elem_ref_at(caller_arena, arg_ty);
        let pe: i32 = pipeline_type_elem_ref_at(caller_arena, param_ty);
        if (ae > 0 && pe > 0 && pipeline_typeck_type_refs_equal_c(caller_arena, ae, pe) != 0) {
          return 1000;
        }
      }
      /*
       * See implementation.
       * See implementation.
       */
      if (ak == 9 && pk == 9) {
        let ae2: i32 = pipeline_type_elem_ref_at(caller_arena, arg_ty);
        let pe2: i32 = pipeline_type_elem_ref_at(caller_arena, param_ty);
        if (ae2 > 0 && pe2 > 0 && pipeline_typeck_type_refs_equal_c(caller_arena, ae2, pe2) != 0) {
          return 1000;
        }
        return -1;
      }
      /*
       * wave672 Cap residual: TYPE_ARRAY (10) / TYPE_SLICE (11) same-kind weak score
       * must require matching element types. Prior: `ak==pk` returned 1 for bool[2]
       * vs i32[2] → free-fn call `f([true,false])` false-green after resolve.
       * G.7: complete this score authority (PTR already checks pointee above).
       * PLATFORM: SHARED — keep strict_minimal arg score aligned.
       */
      if (ak == 10 && pk == 10) {
        let ae_a: i32 = pipeline_type_elem_ref_at(caller_arena, arg_ty);
        let pe_a: i32 = pipeline_type_elem_ref_at(caller_arena, param_ty);
        let asz: i32 = pipeline_type_array_size_at(caller_arena, arg_ty);
        let psz: i32 = pipeline_type_array_size_at(caller_arena, param_ty);
        if (ae_a > 0 && pe_a > 0
        && pipeline_typeck_type_refs_equal_c(caller_arena, ae_a, pe_a) != 0
        && (asz <= 0 || psz <= 0 || asz == psz)) {
          return 1000;
        }
        return -1;
      }
      if (ak == 11 && pk == 11) {
        let ae_s: i32 = pipeline_type_elem_ref_at(caller_arena, arg_ty);
        let pe_s: i32 = pipeline_type_elem_ref_at(caller_arena, param_ty);
        if (ae_s > 0 && pe_s > 0
        && pipeline_typeck_type_refs_equal_c(caller_arena, ae_s, pe_s) != 0) {
          return 1000;
        }
        return -1;
      }
      if (ak == pk && ak != 0) {
        return 1;
      }
      return -1;
    }
    return -1;
  }
}

/**
 * See implementation.
 * See implementation.
 * When args do not disambiguate (zero-arg new/Vec_i32 vs Vec_u8), also prefer expected
 * return type from typeck_overload_expected_ret_peek as a *tie-break only* (let/assign).
 * Never fold a huge bonus into arg score (polluted outer main i32 → wrong get overload).
 * PLATFORM: SHARED — authority: this function; keep strict_minimal pick in sync.
 */
export function find_func_return_type_in_module_by_name_overload(mod: *Module, caller_arena: *ASTArena,
name: *u8, name_len: i32, call_expr_ref: i32, from_dep_index: i32, ctx: *PipelineDepCtx,
func_index_out: *i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let j: i32 = 0;
    let num_args: i32 = 0;
    let best_idx: i32 = -1;
    let best_score: i32 = -1;
    /* expected_ret is tie-break only — must not override exact arg scores (vec_u16 get BLD001). */
    let best_expect_match: i32 = -1;
    let best_ret: i32 = 0;
    let first_idx: i32 = -1;
    let first_ret: i32 = 0;
    let expect_ty: i32 = 0;
    if (name_len <= 0 || name_len > 127 || mod == 0 as *Module) {
      return 0;
    }
    if (call_expr_ref <= 0 || caller_arena == 0 as *ASTArena ||
    call_expr_ref > caller_arena.num_exprs) {
      return find_func_return_type_in_module_by_name(mod, caller_arena, name, name_len, from_dep_index,
      ctx, func_index_out);
    }
    num_args = pipeline_expr_call_num_args_at(caller_arena, call_expr_ref);
    expect_ty = typeck_overload_expected_ret_peek();
    while (j < mod.num_funcs) {
      if (pipeline_module_func_name_equal_at(mod, j, name, name_len) != 0) {
        let rtr: i32 = pipeline_module_func_return_type_at(mod, j);
        if (first_idx < 0) {
          first_idx = j;
          first_ret = rtr;
        }
        let nparams: i32 = pipeline_module_func_num_params_at(mod, j);
        if (nparams == num_args) {
          let ai: i32 = 0;
          let score: i32 = 0;
          let matched: i32 = 1;
          let expect_match: i32 = 0;
          while (ai < num_args) {
            let param_raw: i32 = pipeline_module_func_param_type_ref_at(mod, j, ai);
            let sc: i32 = typeck_overload_arg_param_score(caller_arena, call_expr_ref, ai, param_raw,
            from_dep_index, ctx);
            if (sc < 0) {
              matched = 0;
              break;
            }
            score = score + sc;
            ai = ai + 1;
          }
          /*
           * Zero-arg / arg-tie only: prefer overload whose return matches expected
           * (e.g. let v: Vec_u8 = vec.new()). Do NOT add a huge bonus into score —
           * outer main i32 threaded through if/binop polluted get→Vec_i32 (BLD001).
           * Maps dep return via get_dep_return so vec.Vec_u8 equals bare Vec_u8.
           * PLATFORM: SHARED — keep strict_minimal pick lexicographic aligned.
           */
          if (matched != 0 && expect_ty > 0 && rtr > 0) {
            let mapped_ret: i32 = rtr;
            if (from_dep_index >= 0) {
              mapped_ret = get_dep_return_type_in_caller_arena(from_dep_index, rtr, caller_arena, ctx);
            }
            if (mapped_ret > 0
                && pipeline_typeck_type_refs_equal_c(caller_arena, mapped_ret, expect_ty) != 0) {
              expect_match = 1;
            }
          }
          if (matched != 0 && (score > best_score
              || (score == best_score && expect_match > best_expect_match))) {
            best_score = score;
            best_expect_match = expect_match;
            best_idx = j;
            best_ret = rtr;
          }
        }
      }
      j = j + 1;
    }
    if (best_idx >= 0) {
      if (func_index_out != 0 as *i32) {
        func_index_out[0] = best_idx;
      }
      if (from_dep_index < 0) {
        return best_ret;
      }
      return get_dep_return_type_in_caller_arena(from_dep_index, best_ret, caller_arena, ctx);
    }
    /*
     * wave660 Cap residual: do NOT bind first same-name func when no candidate has
     * matching arity (host-cc BLD001 too few/many args). first_idx fallback remains
     * only when some same-name func has nparams==num_args but arg type scores failed
     * (type-mismatch soft residual; not this wave).
     * PLATFORM: SHARED — G.7 single authority with module_overload twin below.
     */
    if (first_idx >= 0) {
      let any_arity: i32 = 0;
      let j2: i32 = 0;
      while (j2 < mod.num_funcs) {
        if (pipeline_module_func_name_equal_at(mod, j2, name, name_len) != 0) {
          if (pipeline_module_func_num_params_at(mod, j2) == num_args) {
            any_arity = 1;
            break;
          }
        }
        j2 = j2 + 1;
      }
      if (any_arity == 0) {
        return 0;
      }
      if (func_index_out != 0 as *i32) {
        func_index_out[0] = first_idx;
      }
      if (from_dep_index < 0) {
        return first_ret;
      }
      return get_dep_return_type_in_caller_arena(from_dep_index, first_ret, caller_arena, ctx);
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * Also scores expected return (typeck_overload_expected_ret_peek) for zero-arg / arg-tie cases.
 * See implementation.
 * PLATFORM: SHARED — keep typeck_gen seed + glue strict_minimal pick aligned.
 */
export function find_func_return_type_in_module_overload(mod: *Module, mod_arena: *ASTArena,
caller_arena: *ASTArena, callee_arena: *ASTArena, callee_expr_ref: i32,
call_expr_ref: i32, from_dep_index: i32, ctx: *PipelineDepCtx, func_index_out: *i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let j: i32 = 0;
    let first_idx: i32 = -1;
    let first_ret: i32 = 0;
    let num_args: i32 = 0;
    let has_call_info: i32 = 0;
    let best_idx: i32 = -1;
    let best_score: i32 = -1;
    let best_ret: i32 = 0;
    let expect_ty: i32 = 0;
    /* See implementation. */
    if (call_expr_ref > 0 && call_expr_ref <= caller_arena.num_exprs) {
      num_args = pipeline_expr_call_num_args_at(caller_arena, call_expr_ref);
      has_call_info = 1;
    }
    expect_ty = typeck_overload_expected_ret_peek();
    let best_expect_match2: i32 = -1;
    while (j < mod.num_funcs) {
      if (expr_var_name_equal_func(callee_arena, callee_expr_ref, mod, j)) {
        if (first_idx < 0) {
          first_idx = j;
          first_ret = pipeline_module_func_return_type_at(mod, j);
        }
        if (has_call_info != 0) {
          let nparams: i32 = pipeline_module_func_num_params_at(mod, j);
          if (nparams == num_args) {
            let ai: i32 = 0;
            let score: i32 = 0;
            let matched: i32 = 1;
            let expect_match2: i32 = 0;
            let rtr_cand: i32 = pipeline_module_func_return_type_at(mod, j);
            while (ai < num_args) {
              let param_raw: i32 = pipeline_module_func_param_type_ref_at(mod, j, ai);
              let sc: i32 = typeck_overload_arg_param_score(caller_arena, call_expr_ref, ai, param_raw,
              from_dep_index, ctx);
              if (sc < 0) {
                matched = 0;
                break;
              }
              score = score + sc;
              ai = ai + 1;
            }
            /* expected_ret: secondary key only (see by_name_overload; G.7 align strict_minimal). */
            if (matched != 0 && expect_ty > 0 && rtr_cand > 0) {
              let mapped_ret2: i32 = rtr_cand;
              if (from_dep_index >= 0) {
                mapped_ret2 =
                    get_dep_return_type_in_caller_arena(from_dep_index, rtr_cand, caller_arena, ctx);
              }
              if (mapped_ret2 > 0
                  && pipeline_typeck_type_refs_equal_c(caller_arena, mapped_ret2, expect_ty) != 0) {
                expect_match2 = 1;
              }
            }
            if (matched != 0 && (score > best_score
                || (score == best_score && expect_match2 > best_expect_match2))) {
              best_score = score;
              best_expect_match2 = expect_match2;
              best_idx = j;
              best_ret = rtr_cand;
            }
          }
        }
      }
      j = j + 1;
    }
    if (best_idx >= 0) {
      if (func_index_out != 0 as *i32) {
        func_index_out[0] = best_idx;
      }
      if (from_dep_index < 0) {
        return best_ret;
      }
      return get_dep_return_type_in_caller_arena(from_dep_index, best_ret, caller_arena, ctx);
    }
    /*
     * wave660 Cap residual: pure arity miss → return 0 (no first_idx bind).
     * first_idx only when has_call_info and some same-name nparams==num_args
     * (type-score soft residual). Without call info, keep legacy first_idx.
     * PLATFORM: SHARED — G.7 twin of by_name_overload.
     */
    if (first_idx >= 0) {
      if (has_call_info != 0) {
        let any_arity2: i32 = 0;
        let j3: i32 = 0;
        while (j3 < mod.num_funcs) {
          if (expr_var_name_equal_func(callee_arena, callee_expr_ref, mod, j3)) {
            if (pipeline_module_func_num_params_at(mod, j3) == num_args) {
              any_arity2 = 1;
              break;
            }
          }
          j3 = j3 + 1;
        }
        if (any_arity2 == 0) {
          return 0;
        }
      }
      if (func_index_out != 0 as *i32) {
        func_index_out[0] = first_idx;
      }
      if (from_dep_index < 0) {
        return first_ret;
      }
      return get_dep_return_type_in_caller_arena(from_dep_index, first_ret, caller_arena, ctx);
    }
    return 0;
  }
}

/** Exported function `typeck_import_path_segment_count`.
 * Implements `typeck_import_path_segment_count`.
 * @param path *u8
 * @param path_len i32
 * @return i32
 */
export function typeck_import_path_segment_count(path: *u8, path_len: i32): i32 {
  if (path_len <= 0 || path == 0 as *u8) {
    return 0;
  }
  let n: i32 = 1;
  let ii: i32 = 0;
  while (ii < path_len) {
    let ch_u8: u8 = path[ii];
    if (ch_u8 == 46) {
      /** '.' */
      n = n + 1;
    }
    ii = ii + 1;
  }
  return n;
}

/* See implementation. */
export function typeck_import_segment_at(module: *Module, imp_ix: i32, want_seg: i32,
ostr: *i32, olen: *i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (module == 0 as *Module || imp_ix < 0 || imp_ix >= typeck_module_num_imports(module)) {
      return false;
    }
    let pl: i32 = pipeline_module_import_path_len(module, imp_ix);
    if (pl <= 0 || pl > 127) {
      return false;
    }
    let ci: i32 = 0;
    let ss: i32 = 0;
    let k: i32 = 0;
    while (k <= pl) {
      let at_end_p: bool = k == pl;
      let dot_p: bool = false;
      if (!at_end_p && k < pl) {
        dot_p = pipeline_module_import_path_byte_at(module, imp_ix, k) == 46;
      }
      if (at_end_p || dot_p) {
        let seg_len_here: i32 = k - ss;
        if (seg_len_here <= 0) {
          return false;
        }
        if (ci == want_seg) {
          ostr[0] = ss;
          olen[0] = seg_len_here;
          return true;
        }
        if (dot_p) {
          ss = k + 1;
        }
        ci = ci + 1;
      }
      k = k + 1;
    }
    return false;
  }
}

/** See implementation for details. */
export function resolve_whole_import_qualified_call_return_type(module: *Module, arena: *ASTArena,
callee_expr_ref: i32, ctx: *PipelineDepCtx, dep_index_out: *i32, func_index_out: *i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_field: i32 = 44;
    let ord_var: i32 = 3;
    if (ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    if (callee_expr_ref <= 0 || callee_expr_ref > arena.num_exprs || module == 0 as *Module) {
      return 0;
    }
    if (pipeline_expr_kind_ord_at(arena, callee_expr_ref) != ord_field) {
      return 0;
    }
    /* See implementation. */
    let layer_buf: u8[128] = [];
    asm_qual_sym_layer_reset();
    let nstack: i32 = 0;
    let cur_ref: i32 = callee_expr_ref;
    while (true) {
      if (cur_ref <= 0 || cur_ref > arena.num_exprs) {
        return 0;
      }
      let falen: i32 = pipeline_expr_field_access_name_len(arena, cur_ref);
      if (pipeline_expr_kind_ord_at(arena, cur_ref) != ord_field || falen <= 0 || falen > 127) {
        break;
      }
      pipeline_expr_field_access_name_into(arena, cur_ref, &layer_buf[0]);
      if (asm_qual_sym_layer_push(&layer_buf[0], falen) < 0) {
        return 0;
      }
      nstack = nstack + 1;
      cur_ref = pipeline_expr_field_access_base_ref(arena, cur_ref);
    }
    nstack = asm_qual_sym_layer_count();
    if (cur_ref <= 0 || cur_ref > arena.num_exprs) {
      return 0;
    }
    let vnlen: i32 = pipeline_expr_var_name_len(arena, cur_ref);
    if (pipeline_expr_kind_ord_at(arena, cur_ref) != ord_var || vnlen <= 0 || vnlen > 127) {
      return 0;
    }
    let vname_buf: u8[128] = [];
    pipeline_expr_var_name_into(arena, cur_ref, &vname_buf[0]);
    /**
    * See implementation.
    * See implementation.
    */
    let dep_j: i32 = 0;
    /* See implementation. */
    let n_imp: i32 = typeck_module_num_imports(module);
    while (dep_j < n_imp) {
      let plen: i32 = pipeline_module_import_path_len(module, dep_j);
      if (plen <= 0 || plen > 127) {
        dep_j = dep_j + 1;
        continue;
      }
      let path_cnt_buf: u8[128] = [];
      let pci: i32 = 0;
      /* wave584 Cap residual: copy full path content ≤127 (was pci < 64 truncate). */
      while (pci < plen && pci < 127) {
        path_cnt_buf[pci] = pipeline_module_import_path_byte_at(module, dep_j, pci);
        pci = pci + 1;
      }
      let Pseg: i32 = typeck_import_path_segment_count(&path_cnt_buf[0], plen);
      if (Pseg <= 0 || nstack != Pseg) {
        dep_j = dep_j + 1;
        continue;
      }
      let s0_rel: i32 = 0;
      let s0_ln: i32 = 0;
      if (!typeck_import_segment_at(module, dep_j, 0, &s0_rel, &s0_ln)) {
        dep_j = dep_j + 1;
        continue;
      }
      if (!typeck_import_path_slice_equal(module, dep_j, s0_rel, s0_ln, &vname_buf[0], vnlen)) {
        dep_j = dep_j + 1;
        continue;
      }
      let bad_mid: bool = false;
      let sm: i32 = 1;
      while (sm <= Pseg - 1) {
        let srv: i32 = 0;
        let slv: i32 = 0;
        if (!typeck_import_segment_at(module, dep_j, sm, &srv, &slv)) {
          bad_mid = true;
        } else {
          let lay_ix: i32 = Pseg - sm;
          asm_qual_sym_layer_copy(lay_ix, &layer_buf[0], 64);
          if (!typeck_import_path_slice_equal(module, dep_j, srv, slv, &layer_buf[0],
          asm_qual_sym_layer_len(lay_ix))) {
            bad_mid = true;
          }
        }
        if (bad_mid) {
          break;
        }
        sm = sm + 1;
      }
      if (bad_mid) {
        dep_j = dep_j + 1;
        continue;
      }
      let dep_slot: i32 = typeck_resolve_dep_index_for_import(module, ctx, dep_j);
      let dm: *Module = 0 as *Module;
      if (dep_slot < 0) {
        dep_j = dep_j + 1;
        continue;
      }
      dm = pipeline_dep_ctx_module_at(ctx, dep_slot);
      if (dm == 0 as *Module) {
        dep_j = dep_j + 1;
        continue;
      }
      asm_qual_sym_layer_copy(0, &layer_buf[0], 64);
      let ret_fn: i32 = find_func_return_type_in_module_by_name(dm, arena, &layer_buf[0],
      asm_qual_sym_layer_len(0), dep_slot, ctx, func_index_out);
      if (ret_fn != 0) {
        if (dep_index_out != 0 as *i32) {
          typeck_i32_ptr_store(dep_index_out, dep_slot);
        }
      }
      return ret_fn;
    }
    return 0;
  }
}

/**
* See implementation.
* See implementation.
* See implementation.
*/
export function resolve_call_binding_import_return_type(module: *Module, arena: *ASTArena,
callee_expr_ref: i32, call_expr_ref: i32, ctx: *PipelineDepCtx, dep_index_out: *i32,
func_index_out: *i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_field: i32 = 44;
    let ord_var: i32 = 3;
    let ord_import_binding: i32 = 1;
    let base_bind_ref: i32 = 0;
    let base_bind_len: i32 = 0;
    let field_len: i32 = 0;
    let ii: i32 = 0;
    let ret_b: i32 = 0;
    let dm: *Module = 0 as *Module;
    let import_kind: i32 = 0;
    let base_bind_nm: u8[128] = [];
    let field_nm: u8[128] = [];
    if (callee_expr_ref <= 0 || callee_expr_ref > arena.num_exprs || module == 0 as *Module || ctx == 
    0 as *PipelineDepCtx) {
      return 0;
    }
    if (pipeline_expr_kind_ord_at(arena, callee_expr_ref) != ord_field) {
      return 0;
    }
    base_bind_ref = pipeline_expr_field_access_base_ref(arena, callee_expr_ref);
    if (base_bind_ref <= 0 || base_bind_ref > arena.num_exprs) {
      return 0;
    }
    if (pipeline_expr_kind_ord_at(arena, base_bind_ref) != ord_var) {
      return 0;
    }
    base_bind_len = pipeline_expr_var_name_len(arena, base_bind_ref);
    if (base_bind_len <= 0 || base_bind_len > 127) {
      return 0;
    }
    pipeline_expr_var_name_into(arena, base_bind_ref, &base_bind_nm[0]);
    field_len = pipeline_expr_field_access_name_len(arena, callee_expr_ref);
    pipeline_expr_field_access_name_into(arena, callee_expr_ref, &field_nm[0]);
    ii = 0;
    let n_imp: i32 = typeck_module_num_imports(module);
    while (ii < n_imp) {
      import_kind = pipeline_module_import_kind_at(module, ii);
      if (import_kind == ord_import_binding && typeck_import_binding_name_equal(module, ii,
      &base_bind_nm[0], base_bind_len)) {
        let dep_slot: i32 = typeck_resolve_dep_index_for_import(module, ctx, ii);
        if (dep_slot < 0) {
          break;
        }
        dm = pipeline_dep_ctx_module_at(ctx, dep_slot);
        if (dm != 0 as *Module) {
          ret_b = find_func_return_type_in_module_by_name_overload(dm, arena, &field_nm[0], field_len,
          call_expr_ref, dep_slot, ctx, func_index_out);
          if (ret_b != 0) {
            if (dep_index_out != 0 as *i32) {
              typeck_i32_ptr_store(dep_index_out, dep_slot);
            }
            return ret_b;
          }
        }
        break;
      }
      ii = ii + 1;
    }
    return 0;
  }
}

/* See implementation. */
export function resolve_method_call_binding_import_return_type(module: *Module, arena: *ASTArena,
expr_ref: i32, ctx: *PipelineDepCtx, dep_index_out: *i32, func_index_out: *i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_var: i32 = 3;
    let ord_import_binding: i32 = 1;
    let base_ref: i32 = 0;
    let base_len: i32 = 0;
    let method_len: i32 = 0;
    let ii: i32 = 0;
    let ret_b: i32 = 0;
    let dm: *Module = 0 as *Module;
    let import_kind: i32 = 0;
    let base_nm: u8[128] = [];
    let method_nm: u8[128] = [];
    if (expr_ref <= 0 || expr_ref > arena.num_exprs || module == 0 as *Module || ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    base_ref = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    if (base_ref <= 0 || base_ref > arena.num_exprs) {
      return 0;
    }
    if (pipeline_expr_kind_ord_at(arena, base_ref) != ord_var) {
      return 0;
    }
    base_len = pipeline_expr_var_name_len(arena, base_ref);
    method_len = pipeline_expr_method_call_name_len(arena, expr_ref);
    if (base_len <= 0 || base_len > 127 || method_len <= 0 || method_len > 127) {
      return 0;
    }
    pipeline_expr_var_name_into(arena, base_ref, &base_nm[0]);
    pipeline_expr_method_call_name_into(arena, expr_ref, &method_nm[0]);
    let n_imp: i32 = typeck_module_num_imports(module);
    while (ii < n_imp) {
      import_kind = pipeline_module_import_kind_at(module, ii);
      if (import_kind == ord_import_binding && typeck_import_binding_name_equal(module, ii, &base_nm[0], base_len)) {
        let dep_slot: i32 = typeck_resolve_dep_index_for_import(module, ctx, ii);
        if (dep_slot < 0) {
          break;
        }
        dm = pipeline_dep_ctx_module_at(ctx, dep_slot);
        if (dm != 0 as *Module) {
          ret_b = find_func_return_type_in_module_by_name(dm, arena, &method_nm[0], method_len, dep_slot, ctx,
            func_index_out);
          if (ret_b != 0) {
            if (dep_index_out != 0 as *i32) {
              typeck_i32_ptr_store(dep_index_out, dep_slot);
            }
            return ret_b;
          }
        }
        break;
      }
      ii = ii + 1;
    }
    return 0;
  }
}

/**
* See implementation.
* See implementation.
*/
export function resolve_call_select_import_return_type(module: *Module, arena: *ASTArena,
callee_expr_ref: i32, callee_ord: i32, dep_ix: i32, ctx: *PipelineDepCtx,
func_index_out: *i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_var: i32 = 3;
    let ord_import_select: i32 = 2;
    let cv_len: i32 = 0;
    let k: i32 = 0;
    let sel_cnt: i32 = 0;
    let import_kind: i32 = 0;
    let dm: *Module = 0 as *Module;
    let cv_nm: u8[128] = [];
    if (module == 0 as *Module || ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    if (dep_ix < 0 || dep_ix >= typeck_module_num_imports(module) || callee_ord != ord_var) {
      return 0;
    }
    import_kind = pipeline_module_import_kind_at(module, dep_ix);
    if (import_kind != ord_import_select) {
      return 0;
    }
    cv_len = pipeline_expr_var_name_len(arena, callee_expr_ref);
    if (cv_len <= 0) {
      return 0;
    }
    pipeline_expr_var_name_into(arena, callee_expr_ref, &cv_nm[0]);
    let dep_slot: i32 = typeck_resolve_dep_index_for_import(module, ctx, dep_ix);
    if (dep_slot < 0) {
      return 0;
    }
    dm = pipeline_dep_ctx_module_at(ctx, dep_slot);
    if (dm == 0 as *Module) {
      return 0;
    }
    sel_cnt = pipeline_module_import_select_count_at(module, dep_ix);
    k = 0;
    while (k < sel_cnt) {
      if (typeck_import_select_name_equal(module, dep_ix, k, &cv_nm[0], cv_len)) {
        return find_func_return_type_in_module_by_name(dm, arena, &cv_nm[0], cv_len, dep_slot, ctx,
        func_index_out);
      }
      k = k + 1;
    }
    return 0;
  }
}

/**
* See implementation.
*/
export function resolve_call_callee_try_whole_import(module: *Module, arena: *ASTArena,
callee_expr_ref: i32, ctx: *PipelineDepCtx, callee_ord: i32): i32 {
  let ord_field: i32 = 44;
  let null_po: *i32 = 0 as *i32;
  if (callee_ord != ord_field) {
    return 0;
  }
  return resolve_whole_import_qualified_call_return_type(module, arena, callee_expr_ref, ctx,
  null_po, null_po);
}

/**
* See implementation.
* See implementation.
*/
export function resolve_call_callee_try_binding_import(module: *Module, arena: *ASTArena,
callee_expr_ref: i32, call_expr_ref: i32, ctx: *PipelineDepCtx, callee_ord: i32): i32 {
  let ord_field: i32 = 44;
  let null_po: *i32 = 0 as *i32;
  if (callee_ord != ord_field) {
    return 0;
  }
  return resolve_call_binding_import_return_type(module, arena, callee_expr_ref, call_expr_ref, ctx,
  null_po, null_po);
}

/**
* See implementation.
*/
export function resolve_call_callee_local_module(module: *Module, arena: *ASTArena, callee_expr_ref: i32,
ctx: *PipelineDepCtx): i32 {
  /* See implementation. */
  let minus_one: i32 = -1;
  return find_func_return_type_in_module(module, arena, arena, arena, callee_expr_ref, minus_one,
  ctx, 0 as *i32);
}

/**
* See implementation.
*/
export function resolve_call_callee_scan_dep(module: *Module, arena: *ASTArena, callee_expr_ref: i32,
callee_ord: i32, ctx: *PipelineDepCtx, dep_i: i32, imax: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let dm: *Module = 0 as *Module;
    let ret: i32 = 0;
    let null_po: *i32 = 0 as *i32;
    if (dep_i >= imax) {
      return 0;
    }
    dm = pipeline_dep_ctx_module_at(ctx, dep_i);
    if (dm != 0 as *Module) {
      ret = find_func_return_type_in_module(dm, arena, arena, arena, callee_expr_ref, dep_i, ctx,
      null_po);
      if (ret != 0) {
        return ret;
      }
      if (dep_i < typeck_module_num_imports(module)) {
        ret = resolve_call_select_import_return_type(module, arena, callee_expr_ref, callee_ord,
        dep_i, ctx, null_po);
        if (ret != 0) {
          return ret;
        }
      }
    }
    return resolve_call_callee_scan_dep(module, arena, callee_expr_ref, callee_ord, ctx, dep_i + 1,
    imax);
  }
}

/** See implementation for details. */
export function resolve_call_callee_return_type(module: *Module, arena: *ASTArena, callee_expr_ref: i32,
call_expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let want_apply: i32 = 0;
    let callee_ord: i32 = 0;
    let ret: i32 = 0;
    let imax: i32 = 0;
    let nd_scan: i32 = 0;
    if (callee_expr_ref <= 0 || callee_expr_ref > arena.num_exprs) {
      return 0;
    }
    if (call_expr_ref > 0 && call_expr_ref <= arena.num_exprs) {
      want_apply = 1;
    }
    callee_ord = pipeline_expr_kind_ord_at(arena, callee_expr_ref);
    ret = resolve_call_callee_try_whole_import(module, arena, callee_expr_ref, ctx, callee_ord);
    if (ret != 0) {
      if (want_apply != 0) {
        /* See implementation. */
        typeck_i32_ptr_store(typeck_call_resolve_dep_idx_slot(), 0);
        typeck_i32_ptr_store(typeck_call_resolve_func_idx_slot(), 0);
        resolve_whole_import_qualified_call_return_type(module, arena, callee_expr_ref, ctx,
        typeck_call_resolve_dep_idx_slot(), typeck_call_resolve_func_idx_slot());
        ast.ast_expr_apply_call_resolve(arena, call_expr_ref, typeck_call_resolve_dep_idx_peek(),
        typeck_call_resolve_func_idx_peek());
      }
      return ret;
    }
    ret = resolve_call_callee_try_binding_import(module, arena, callee_expr_ref, call_expr_ref, ctx,
    callee_ord);
    if (ret != 0) {
      if (want_apply != 0) {
        /* See implementation. */
        typeck_i32_ptr_store(typeck_call_resolve_dep_idx_slot(), 0);
        typeck_i32_ptr_store(typeck_call_resolve_func_idx_slot(), 0);
        ret = resolve_call_binding_import_return_type(module, arena, callee_expr_ref, call_expr_ref, ctx,
        typeck_call_resolve_dep_idx_slot(), typeck_call_resolve_func_idx_slot());
        ast.ast_expr_apply_call_resolve(arena, call_expr_ref, typeck_call_resolve_dep_idx_peek(),
        typeck_call_resolve_func_idx_peek());
      }
      return ret;
    }
    ret = resolve_call_callee_local_module(module, arena, callee_expr_ref, ctx);
    if (ret != 0) {
      if (want_apply != 0) {
        /* See implementation. */
        let minus_one_lm: i32 = -1;
        typeck_i32_ptr_store(typeck_call_resolve_func_idx_slot(), 0);
        ret = find_func_return_type_in_module_overload(module, arena, arena, arena, callee_expr_ref,
        call_expr_ref, minus_one_lm, ctx, typeck_call_resolve_func_idx_slot());
        ast.ast_expr_apply_call_resolve(arena, call_expr_ref, minus_one_lm,
        typeck_call_resolve_func_idx_peek());
      }
      return ret;
    }
    imax = typeck_module_num_imports(module);
    nd_scan = pipeline_dep_ctx_ndep(ctx);
    if (nd_scan > imax) {
      imax = nd_scan;
    }
    return typeck_resolve_scan_dep_with_apply(module, arena, callee_expr_ref, callee_ord,
    call_expr_ref, ctx, 0, imax, want_apply);
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function expr_type_ref(arena: *ASTArena, expr_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (ast.ref_is_null(expr_ref)) {
      return 0;
    }
    if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    return pipeline_expr_resolved_type_ref(arena, expr_ref);
  }
}

/** Exported function `type_ref_is_bool_impl`.
 * Implements `type_ref_is_bool_impl`.
 * @param arena *ASTArena
 * @param type_ref i32
 * @return bool
 */
export function type_ref_is_bool_impl(arena: *ASTArena, type_ref: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    /* See implementation. */
    let ord_bool: i32 = 1;
    return pipeline_type_kind_ord_at(arena, type_ref) == ord_bool;
  }
}

/** Exported function `type_ref_is_bool`.
 * Implements `type_ref_is_bool`.
 * @param arena *ASTArena
 * @param type_ref i32
 * @return bool
 */
export function type_ref_is_bool(arena: *ASTArena, type_ref: i32): bool {
  if (ast.ref_is_null(type_ref)) {
    return false;
  }
  if (type_ref <= 0 || type_ref > arena.num_types) {
    return false;
  }
  return type_ref_is_bool_impl(arena, type_ref);
}

/**
* See implementation.
* See implementation.
*/
export function typeck_named_unqual_start(buf: *u8, len: i32): i32 {
  let i: i32 = len - 1;
  while (i > 0) {
    if (buf[i] == 46) {
      return i + 1;
    }
    i = i - 1;
  }
  return 0;
}

/**
* See implementation.
* See implementation.
*/
export function type_refs_equal_named(arena: *ASTArena, a: i32, b: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let buf_a: *u8 = typeck_scratch64_slot(0);
    let buf_b: *u8 = typeck_scratch64_slot(1);
    let na: i32 = pipeline_type_named_name_into(arena, a, buf_a);
    let nb: i32 = pipeline_type_named_name_into(arena, b, buf_b);
    let i: i32 = 0;
    let ta: i32 = 0;
    let tb: i32 = 0;
    let ua: i32 = 0;
    let ub: i32 = 0;
    if (na <= 0 || nb <= 0) {
      return false;
    }
    /* See implementation. */
    if (na == nb) {
      i = 0;
      while (i < na) {
        if (buf_a[i] != buf_b[i]) {
          break;
        }
        i = i + 1;
      }
      if (i == na) {
        return true;
      }
    }
    /* See implementation. */
    ta = typeck_named_unqual_start(buf_a, na);
    tb = typeck_named_unqual_start(buf_b, nb);
    ua = na - ta;
    ub = nb - tb;
    if (ua != ub || ua <= 0) {
      return false;
    }
    i = 0;
    while (i < ua) {
      if (buf_a[ta + i] != buf_b[tb + i]) {
        return false;
      }
      i = i + 1;
    }
    return true;
  }
}

/**
* See implementation.
* See implementation.
*/
export function type_refs_equal_same_kind(arena: *ASTArena, a: i32, b: i32, kind_ord: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ea: i32 = 0;
    let eb: i32 = 0;
    /* See implementation. */
    let ord_named: i32 = 8;
    let ord_ptr: i32 = 9;
    let ord_array: i32 = 10;
    let ord_slice: i32 = 11;
    let ord_linear: i32 = 12;
    let ord_vector: i32 = 13;
    if (kind_ord == ord_named) {
      return type_refs_equal_named(arena, a, b);
    }
    if (kind_ord == ord_ptr || kind_ord == ord_slice || kind_ord == ord_linear) {
      ea = pipeline_type_elem_ref_at(arena, a);
      eb = pipeline_type_elem_ref_at(arena, b);
      return type_refs_equal(arena, ea, eb);
    }
    if (kind_ord == ord_array || kind_ord == ord_vector) {
      if (pipeline_type_array_size_at(arena, a) != pipeline_type_array_size_at(arena, b)) {
        return false;
      }
      ea = pipeline_type_elem_ref_at(arena, a);
      eb = pipeline_type_elem_ref_at(arena, b);
      return type_refs_equal(arena, ea, eb);
    }
    return true;
  }
}

/**
* See implementation.
* See implementation.
*/
export function type_refs_equal_impl(arena: *ASTArena, a: i32, b: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ka: i32 = pipeline_type_kind_ord_at(arena, a);
    let kb: i32 = pipeline_type_kind_ord_at(arena, b);
    if (ka != kb) {
      return false;
    }
    return type_refs_equal_same_kind(arena, a, b, ka);
  }
}

/** Exported function `type_refs_equal`.
 * Implements `type_refs_equal`.
 * @param arena *ASTArena
 * @param a i32
 * @param b i32
 * @return bool
 */
export function type_refs_equal(arena: *ASTArena, a: i32, b: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (ast.ref_is_null(a) || ast.ref_is_null(b)) {
      return a == b;
    }
    return pipeline_typeck_type_refs_equal_c(arena, a, b) != 0;
  }
}

/**
* See implementation.
* See implementation.
*/
/**
 * Integer implicit widen gate for first-class TypeKind ordinals only
 * (let-init, assign, call arg, return when both sides are non-NAMED ints).
 * @param dest_kind i32 — TypeKind ordinal of the expected/declared type
 * @param src_kind i32 — TypeKind ordinal of the found/rhs type
 * @return bool — true if same integer kind or a documented widen is allowed
 * wave309 Cap residual: add TYPE_ISIZE identity + i32→isize (symmetric with
 * i32→usize; matches pipeline_typeck_integer_widen_ok_c — G.7 dual-authority).
 * Prior omit left `let a:isize = -1` / `a = -1` as found i32 (EXPR_NEG/binop).
 * wave311 Cap residual: i32→u64 (true widen; prior hole vs i32→usize on LP64)
 * and i32→u8 (narrow store of low 8 bits — var init/assign/return path verified
 * green wave712; lit coerce already green). Call single-candidate was lax.
 * wave312 Cap residual: complete first-class integer family —
 *   u8→i64/isize; u32→i64/usize/isize (plus prior u32→u64);
 *   isize↔i64 and usize↔u64 (LP64 same-width store / true widen on ILP32).
 * wave313: NAMED i8/i16/u16 use typeck_integer_widen_ok_refs (name-based).
 * PLATFORM: SHARED — seed typeck_gen + empty_surface + glue + strict_minimal same commit.
 */
export function typeck_integer_widen_ok(dest_kind: i32, src_kind: i32): bool {
  let ord_i32: i32 = 0;
  let ord_u8: i32 = 2;
  let ord_u32: i32 = 3;
  let ord_u64: i32 = 4;
  let ord_i64: i32 = 5;
  let ord_usize: i32 = 6;
  let ord_isize: i32 = 7;
  if (dest_kind == src_kind) {
    if (dest_kind == ord_i32 || dest_kind == ord_i64 || dest_kind == ord_u8 ||
    dest_kind == ord_u32 || dest_kind == ord_u64 || dest_kind == ord_usize ||
    dest_kind == ord_isize) {
      return true;
    }
    return false;
  }
  if (src_kind == ord_u8) {
    /* u8 → all wider first-class integers (wave312: +i64 +isize). */
    if (dest_kind == ord_u32 || dest_kind == ord_u64 || dest_kind == ord_usize ||
    dest_kind == ord_i32 || dest_kind == ord_i64 || dest_kind == ord_isize) {
      return true;
    }
    return false;
  }
  if (src_kind == ord_i32) {
    /* i32→isize/u64: pointer-width / fixed 64-bit; i32→u8: low-byte narrow store. */
    if (dest_kind == ord_i64 || dest_kind == ord_u32 || dest_kind == ord_u64 ||
    dest_kind == ord_usize || dest_kind == ord_isize || dest_kind == ord_u8) {
      return true;
    }
    return false;
  }
  if (src_kind == ord_u32) {
    /* wave312: u32→u64 (prior) + u32→i64/usize/isize true widen. */
    if (dest_kind == ord_u64 || dest_kind == ord_i64 || dest_kind == ord_usize ||
    dest_kind == ord_isize) {
      return true;
    }
    return false;
  }
  /* wave312: LP64 pointer-width ↔ fixed 64-bit (same bits; ILP32 true widen). */
  if (src_kind == ord_usize && dest_kind == ord_u64) {
    return true;
  }
  if (src_kind == ord_u64 && dest_kind == ord_usize) {
    return true;
  }
  if (src_kind == ord_isize && dest_kind == ord_i64) {
    return true;
  }
  if (src_kind == ord_i64 && dest_kind == ord_isize) {
    return true;
  }
  return false;
}

/**
 * Map a type_ref to an integer family tag for widen decisions.
 * @param arena *ASTArena — type pool
 * @param type_ref i32 — type ref (first-class int or TYPE_NAMED i8/i16/u16)
 * @return i32 — family id: TypeKind ord for first-class ints (0/2/3/4/5/6/7);
 *   10=i8, 11=i16, 12=u16 for TYPE_NAMED spellings; -1 if not an integer
 * wave313 Cap residual: i8/i16/u16 have no TypeKind — name-based path only.
 * PLATFORM: SHARED — seed/glue/empty_surface same commit.
 */
export function typeck_int_family_id(arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let k: i32 = 0;
    let nlen: i32 = 0;
    let buf: *u8 = typeck_scratch64_slot(15);
    if (ast.ref_is_null(type_ref) || type_ref <= 0) {
      return -1;
    }
    k = pipeline_type_kind_ord_at(arena, type_ref);
    /* First-class integer TypeKinds (match typeck_integer_widen_ok). */
    if (k == 0 || k == 2 || k == 3 || k == 4 || k == 5 || k == 6 || k == 7) {
      return k;
    }
    /* TYPE_NAMED=8: only i8 / i16 / u16 participate in integer widen. */
    if (k != 8) {
      return -1;
    }
    nlen = pipeline_type_named_name_into(arena, type_ref, buf);
    /* "i8" */
    if (nlen == 2 && buf[0] == 105 && buf[1] == 56) {
      return 10;
    }
    /* "i16" */
    if (nlen == 3 && buf[0] == 105 && buf[1] == 49 && buf[2] == 54) {
      return 11;
    }
    /* "u16" */
    if (nlen == 3 && buf[0] == 117 && buf[1] == 49 && buf[2] == 54) {
      return 12;
    }
    return -1;
  }
}

/**
 * Integer widen gate with TYPE_NAMED i8/i16/u16 (wave313).
 * Prefer this over typeck_integer_widen_ok whenever both type_refs are available.
 * @param arena *ASTArena — type pool
 * @param dest_ref i32 — expected/declared type ref
 * @param src_ref i32 — found/rhs type ref
 * @return bool — true if same integer family or documented widen/narrow store
 * Rules (G.7 single authority; mirrors first-class matrix + NAMED leaf):
 *   - first-class pairs via typeck_integer_widen_ok
 *   - i8 → i16/u16/u8/i32/u32/i64/u64/usize/isize
 *   - i16 → u16/u8/i32/u32/i64/u64/usize/isize
 *   - u16 → u8/i32/u32/i64/u64/usize/isize
 *   - u8/i32 → i8/i16/u16 (narrow store, same spirit as i32→u8)
 *   - u32 → i16/u16 (narrow store residual)
 * PLATFORM: SHARED — seed typeck_gen + empty_surface + glue + strict_minimal same commit.
 */
export function typeck_integer_widen_ok_refs(arena: *ASTArena, dest_ref: i32, src_ref: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let dest_f: i32 = 0;
    let src_f: i32 = 0;
    if (ast.ref_is_null(dest_ref) || ast.ref_is_null(src_ref)) {
      return false;
    }
    dest_f = typeck_int_family_id(arena, dest_ref);
    src_f = typeck_int_family_id(arena, src_ref);
    if (dest_f < 0 || src_f < 0) {
      return false;
    }
    /* Same family (includes NAMED i8/i16/u16 identity across distinct type_refs). */
    if (dest_f == src_f) {
      return true;
    }
    /* First-class TypeKind matrix (tags 0/2/3/4/5/6/7 only). */
    if (dest_f <= 7 && src_f <= 7) {
      if (typeck_integer_widen_ok(dest_f, src_f)) {
        return true;
      }
    }
    /* NAMED src → wider first-class / peer NAMED. */
    if (src_f == 10) {
      /* i8 → i16/u16/u8 + all wider first-class ints. */
      if (dest_f == 11 || dest_f == 12 || dest_f == 2 || dest_f == 0 || dest_f == 3 ||
      dest_f == 4 || dest_f == 5 || dest_f == 6 || dest_f == 7) {
        return true;
      }
      return false;
    }
    if (src_f == 11) {
      /* i16 → u16/u8 + wider first-class. */
      if (dest_f == 12 || dest_f == 2 || dest_f == 0 || dest_f == 3 || dest_f == 4 ||
      dest_f == 5 || dest_f == 6 || dest_f == 7) {
        return true;
      }
      return false;
    }
    if (src_f == 12) {
      /* u16 → u8 + wider first-class (u8 is low-byte narrow like i32→u8). */
      if (dest_f == 2 || dest_f == 0 || dest_f == 3 || dest_f == 4 || dest_f == 5 ||
      dest_f == 6 || dest_f == 7) {
        return true;
      }
      return false;
    }
    /* First-class src → NAMED dest (narrow / peer store). */
    if (dest_f == 10) {
      /* → i8 from u8/i32/i16/u16 (low-byte / narrow). */
      if (src_f == 2 || src_f == 0 || src_f == 11 || src_f == 12) {
        return true;
      }
      return false;
    }
    if (dest_f == 11) {
      /* → i16 from u8/i32/u16/u32. */
      if (src_f == 2 || src_f == 0 || src_f == 12 || src_f == 3) {
        return true;
      }
      return false;
    }
    if (dest_f == 12) {
      /* → u16 from u8/i32/i16/u32. */
      if (src_f == 2 || src_f == 0 || src_f == 11 || src_f == 3) {
        return true;
      }
      return false;
    }
    return false;
  }
}

/**
 * Float widen gate (wave314 Cap residual pure).
 * @param dest_kind i32 — TypeKind ordinal of expected/declared type
 * @param src_kind i32 — TypeKind ordinal of found/rhs type
 * @return bool — true if same float kind or f32→f64 IEEE promotion
 * Only true widen f32→f64 is implicit. Narrow f64→f32 requires explicit `as`.
 * TypeKind: TYPE_F32=14, TYPE_F64=15 (ast.x enum order).
 * PLATFORM: SHARED — seed typeck_gen + empty_surface + glue same commit.
 */
export function typeck_float_widen_ok(dest_kind: i32, src_kind: i32): bool {
  let ord_f32: i32 = 14;
  let ord_f64: i32 = 15;
  if (dest_kind == src_kind) {
    if (dest_kind == ord_f32 || dest_kind == ord_f64) {
      return true;
    }
    return false;
  }
  /* IEEE true widen only (host C promotes float→double the same way). */
  if (src_kind == ord_f32 && dest_kind == ord_f64) {
    return true;
  }
  return false;
}

/**
 * Whether a return operand type matches the function's declared return type.
 * Accepts equal types, integer widen (wave313), f32→f64 (wave314), linear unwrap,
 * and bare INT 0 → pointer (nullish lit). Does not widen bool to integer.
 * wave671 Cap residual: prior path accepted EXPR_BOOL_LIT / EXPR_LOGNOT when
 * expect was TYPE_I32 (`return true` / `return !x` false-green while
 * `return (1==1)` / `return bool_var` already mismatched). Align with wave666
 * no int↔bool and with EQ/LOGAND return mismatch. Explicit `as i32` still works
 * (EXPR_AS stamps target before match). LANG-006 bool→int on let/const init is
 * typeck_coerce_init_bool_to_int_decl only — not return.
 * @param arena *ASTArena — type/expr arena
 * @param op_ref i32 — return operand expr
 * @param expect_ref i32 — declared function return type
 * @return bool — true when operand may return as expect
 * PLATFORM: SHARED — G.7 single return match authority (typeck.x + seed twins).
 */
export function typeck_return_operand_matches(arena: *ASTArena, op_ref: i32, expect_ref: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let got: i32 = expr_type_ref(arena, op_ref);
    let expect_kind: i32 = 0;
    let got_kind: i32 = 0;
    if (ast.ref_is_null(op_ref) || ast.ref_is_null(expect_ref)) {
      return true;
    }
    if (ast.ref_is_null(got)) {
      let ord_lit: i32 = 0;
      let ord_ptr: i32 = 9;
      let kop: i32 = pipeline_expr_kind_ord_at(arena, op_ref);
      expect_kind = pipeline_type_kind_ord_at(arena, expect_ref);
      if (kop == ord_lit && expect_kind == ord_ptr && pipeline_expr_int_val_at(arena, op_ref) == 0) {
        pipeline_expr_set_resolved_type_ref(arena, op_ref, expect_ref);
        return true;
      }
      return false;
    }
    if (type_refs_equal(arena, got, expect_ref)) {
      return true;
    }
    expect_kind = pipeline_type_kind_ord_at(arena, expect_ref);
    got_kind = pipeline_type_kind_ord_at(arena, got);
    /* wave313: name-based refs so NAMED i8/i16/u16 widen participates on return. */
    if (typeck_integer_widen_ok_refs(arena, expect_ref, got)) {
      return true;
    }
    /* wave314: f32→f64 float widen on return. */
    if (typeck_float_widen_ok(expect_kind, got_kind)) {
      return true;
    }
    let ord_linear: i32 = 12;
    if (pipeline_type_kind_ord_at(arena, got) == ord_linear) {
      let elem: i32 = pipeline_type_elem_ref_at(arena, got);
      if (!ast.ref_is_null(elem) && type_refs_equal(arena, elem, expect_ref)) {
        return true;
      }
    }
    /*
     * wave671 Cap residual: hard-fail bool → non-bool return (no BOOL_LIT/LOGNOT
     * → i32 exception). Same mismatch path as EQ/LOGAND/bool VAR return.
     */
    return false;
  }
}

/**
* See implementation.
* See implementation.
*/
/**
 * True when expr is keyword `null` (wave668 EXPR_LIT 0 tagged var_name="null").
 * Bare INT_LIT 0 has var_name_len=0 (arena alloc zero). No new ExprKind.
 * @param arena *ASTArena — expr pool
 * @param expr_ref i32 — candidate lit ref
 * @return i32 — 1 if null keyword, 0 otherwise
 * PLATFORM: SHARED — wave670 Cap residual.
 * G.7: delegates to pipeline_expr_is_null_keyword_c (var_name_len is VAR-only).
 */
export extern function pipeline_expr_is_null_keyword_c(arena: *ASTArena, expr_ref: i32): i32;

export function typeck_expr_is_null_keyword(arena: *ASTArena, expr_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || expr_ref <= 0) {
      return 0;
    }
    return pipeline_expr_is_null_keyword_c(arena, expr_ref);
  }
}

/**
 * Coerce bare EXPR_LIT into a declared let/const type.
 * @param arena *ASTArena — type/expr arena
 * @param init_ref i32 — initializer EXPR_LIT ref
 * @param decl_ty_ref i32 — declared type ref to stamp onto the lit
 * @param decl_kind i32 — TypeKind ordinal of the declaration
 * @param init_kind i32 — ExprKind ordinal of the initializer
 * @return i32 — 1 if retyped, 0 if no coerce
 * PLATFORM: SHARED — wave307 Cap residual: use full i64 lit bits via
 * pipeline_expr_int64_val_at. Prior i32 truncation made u64max (stored as -1)
 * and i64max (low32 all-ones) fail `int_val >= 0` for u64/usize.
 * Unsuffixed lits in 2^63..2^64-1 wrap to negative i64 two's-complement but
 * remain valid u64/usize bit patterns; accept any EXPR_LIT for u64/usize
 * (mirrors u32 full-bit accept). Unary `-N` is EXPR_NEG, not bare LIT.
 * wave670: keyword `null` only coerces to TYPE_PTR (not i32/f32/array/…).
 */
export function typeck_coerce_init_lit_to_decl(arena: *ASTArena, init_ref: i32, decl_ty_ref: i32,
decl_kind: i32, init_kind: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let int_val: i64 = 0;
    let ord_expr_lit: i32 = 0;
    let ord_u8: i32 = 2;
    let ord_u32: i32 = 3;
    let ord_u64: i32 = 4;
    let ord_i64: i32 = 5;
    let ord_usize: i32 = 6;
    let ord_isize: i32 = 7;
    let ord_named: i32 = 8;
    let ord_ptr: i32 = 9;
    let ord_array: i32 = 10;
    let ord_vector: i32 = 13;
    let ord_f32: i32 = 14;
    let ord_f64: i32 = 15;
    if (init_kind != ord_expr_lit) {
      return 0;
    }
    /* Full i64: u64max/i64max must not pass through i32 truncation. */
    int_val = pipeline_expr_int64_val_at(arena, init_ref);
    /*
     * wave670 Cap residual: keyword `null` is pointer-context only.
     * Bare INT 0 still coerces to integers/floats/ptr (docs/06).
     * G.7: single coerce authority; reject non-ptr early before f32/array zero.
     */
    if (typeck_expr_is_null_keyword(arena, init_ref) != 0) {
      if (decl_kind == ord_ptr) {
        pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
        return 1;
      }
      return 0;
    }
    if (decl_kind == ord_ptr && int_val == 0) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    if (decl_kind == ord_array && int_val == 0) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    if (decl_kind == ord_u8 && int_val >= 0 && int_val <= 255) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    if (decl_kind == ord_i64) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    if (decl_kind == ord_isize) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    /* u32: accept full bit pattern of the i64-stored lit (low 32 used at emit). */
    if (decl_kind == ord_u32) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    /*
     * wave307: u64/usize accept any bare EXPR_LIT bit pattern.
     * Decimal/hex digits past i64max wrap in lexer to negative i64 (two's
     * complement) but are valid unsigned values (e.g. u64max → -1 bits).
     */
    if (decl_kind == ord_usize || decl_kind == ord_u64) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    if (decl_kind == ord_named) {
      let nm16: u8[128] = [];
      let nlen16: i32 = pipeline_type_named_name_into(arena, decl_ty_ref, &nm16[0]);
      if (nlen16 == 3 && nm16[0] == 117 && nm16[1] == 49 && nm16[2] == 54
          && int_val >= 0 && int_val <= 65535) {
        pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
        return 1;
      }
      if (nlen16 == 3 && nm16[0] == 105 && nm16[1] == 49 && nm16[2] == 54
          && int_val + 32768 >= 0 && int_val <= 32767) {
        pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
        return 1;
      }
    }
    /* Integer literal → f32/f64 (incl. non-zero): product gate run-float init_non_zero_int.
     * Zero-only would reject `let x: f32 = 1` after strict typeck stamps lit as i32. */
    if (decl_kind == ord_f32 || decl_kind == ord_f64) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    if (int_val == 0 && (decl_kind == ord_named || decl_kind == ord_vector)) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    return 0;
  }
}

/**
 * Coerce bare float literal (or unary `-` of a float literal) to a float decl type.
 * @param arena *ASTArena — expression pool
 * @param init_ref i32 — init/RHS/return operand expr ref
 * @param decl_ty_ref i32 — destination type ref (f32 or f64)
 * @param decl_kind i32 — TypeKind ordinal of decl_ty_ref
 * @param init_kind i32 — ExprKind ordinal of init_ref
 * @return i32 — 1 if stamped, 0 if not applicable
 * wave316 Cap residual: bare FLOAT_LIT already coerced on let-init; assign/return
 * and unary `-6.0` (EXPR_NEG of FLOAT_LIT) still resolved as default f64 → type mismatch
 * on f32. G.7 single authority — peel NEG once, stamp both NEG and operand.
 * PLATFORM: SHARED — seed typeck_gen + empty_surface + pipeline_glue twin.
 */
export function typeck_coerce_init_float_lit_to_decl(arena: *ASTArena, init_ref: i32, decl_ty_ref: i32,
decl_kind: i32, init_kind: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_expr_float: i32 = 1;
    let ord_neg: i32 = 22;
    let ord_f32: i32 = 14;
    let ord_f64: i32 = 15;
    let op_ref: i32 = 0;
    if (decl_kind != ord_f32 && decl_kind != ord_f64) {
      return 0;
    }
    if (init_kind == ord_expr_float) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    /* wave316: `let a: f32 = -6.0` / `return -6.0` / `a = -6.0` — EXPR_NEG of FLOAT_LIT. */
    if (init_kind == ord_neg) {
      op_ref = pipeline_expr_unary_operand_ref_at(arena, init_ref);
      if (!ast.ref_is_null(op_ref) && op_ref > 0 && op_ref <= arena.num_exprs) {
        if (pipeline_expr_kind_ord_at(arena, op_ref) == ord_expr_float) {
          pipeline_expr_set_resolved_type_ref(arena, op_ref, decl_ty_ref);
          pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
          return 1;
        }
      }
    }
    return 0;
  }
}

/**
* See implementation.
* See implementation.
*/
export function typeck_coerce_init_enum_field_to_decl(module: *Module, arena: *ASTArena, init_ref: i32,
decl_ty_ref: i32, decl_kind: i32, init_kind: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let base_ix: i32 = 0;
    let ord_named: i32 = 8;
    let ord_expr_var: i32 = 3;
    let ord_field_access: i32 = 44;
    if (decl_kind != ord_named || init_kind != ord_field_access) {
      return 0;
    }
    base_ix = pipeline_expr_field_access_base_ref(arena, init_ref);
    if (!ast.ref_is_null(base_ix) && base_ix > 0 && base_ix <= arena.num_exprs) {
      let decl_buf: *u8 = typeck_scratch64_slot(0);
      let vbuf: *u8 = typeck_scratch64_slot(1);
      let field_buf: *u8 = typeck_scratch64_slot(2);
      let decl_nlen: i32 = pipeline_type_named_name_into(arena, decl_ty_ref, decl_buf);
      let vnlen: i32 = pipeline_expr_var_name_len(arena, base_ix);
      let i_nm: i32 = 0;
      let eq_nm: bool = true;
      if (pipeline_expr_kind_ord_at(arena,
      base_ix) == ord_expr_var && decl_nlen == vnlen && decl_nlen > 0) {
        pipeline_expr_var_name_into(arena, base_ix, vbuf);
        while (i_nm < decl_nlen) {
          if (decl_buf[i_nm] != vbuf[i_nm]) {
            eq_nm = false;
          }
          i_nm = i_nm + 1;
        }
        if (eq_nm) {
          let field_nlen: i32 = pipeline_expr_field_access_name_len(arena, init_ref);
          pipeline_expr_field_access_name_into(arena, init_ref, field_buf);
          let ev_tag: i32 = pipeline_module_enum_variant_tag_for_names(module, decl_buf, decl_nlen,
          field_buf, field_nlen);
          if (ev_tag >= 0) {
            pipeline_expr_set_field_access_enum_variant(arena, init_ref, ev_tag);
            pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
            return 1;
          }
        }
      }
    }
    if (pipeline_expr_field_access_is_enum_variant(arena, init_ref) != 0) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    return 0;
  }
}

/* See implementation. */
export function typeck_coerce_init_named_call_to_decl(arena: *ASTArena, init_ref: i32, decl_ty_ref: i32,
decl_kind: i32, init_kind: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_type_named: i32 = 8;
    let ord_expr_call: i32 = 48;
    if (decl_kind == ord_type_named && init_kind == ord_expr_call
    && ast.ref_is_null(pipeline_expr_resolved_type_ref(arena, init_ref))) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    return 0;
  }
}

/* See implementation. */
export function typeck_coerce_init_resolved_alias_to_decl(module: *Module, arena: *ASTArena, init_ref: i32, decl_ty_ref: i32,
decl_kind: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_type_named: i32 = 8;
    let init_resolved: i32 = 0;
    let decl_resolved: i32 = 0;
    if (decl_kind != ord_type_named) {
      return 0;
    }
    init_resolved = pipeline_expr_resolved_type_ref(arena, init_ref);
    if (ast.ref_is_null(init_resolved)) {
      return 0;
    }
    decl_resolved = typeck_resolve_type_alias_ref_local(module, arena, decl_ty_ref, 0);
    if (ast.ref_is_null(decl_resolved)) {
      return 0;
    }
    if (!type_refs_equal(arena, decl_resolved, init_resolved)) {
      return 0;
    }
    pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
    return 1;
  }
}

/**
 * Coerce ARRAY_LIT elements to the element type of a fixed array or slice decl.
 * Stamps the literal's resolved_type_ref to decl_ty_ref (TYPE_ARRAY or TYPE_SLICE)
 * only when every known element matches (or widens into) the element decl type.
 * @param arena *ASTArena — expression/type pool
 * @param init_ref i32 — EXPR_ARRAY_LIT ref
 * @param decl_ty_ref i32 — TYPE_ARRAY (T[N]) or TYPE_SLICE (T[]) declaration type
 * @return i32 — 1 if handled, 0 if not applicable, -1 on nested failure or elem mismatch
 * PLATFORM: SHARED — wave328: TYPE_SLICE so host emit uses slice compound, not uint8_t[] fallback.
 *
 * wave617 Cap residual pure: also stamp bare FLOAT_LIT / `-float` elems to f32/f64.
 * Root: only typeck_coerce_init_lit_to_decl (integer EXPR_LIT) ran per elem; FLOAT_LIT
 * stayed default f64. Freestanding ARRAY_LIT store uses esz=4 for f32 but emit still
 * movabs full f64 bits → store low-32 of many finite doubles is 0 → INDEX cast run=0
 * (host-C braces hide; `as f32` cast elems already green via EXPR_AS force_ty).
 * G.7: reuse typeck_coerce_init_float_lit_to_decl (wave316 let/assign/return) — no second
 * float-coerce authority. PLATFORM: SHARED typeck · LINUX pure-asm gold.
 *
 * wave672 Cap residual: prior path stamped the outer ARRAY_LIT as decl even when an
 * element stayed bool/f32/struct after lit/float coerce → let/assign/call false-green
 * (`let a:i32[2]=[true,false]` run=1). Hard-fail known elem mismatch; do not stamp outer
 * on failure. Soft-skip still-unknown elem_ty (incomplete resolve). LANG-006 bool→int
 * is scalar let/const only — not array elems.
 */
export function typeck_coerce_array_lit_elem_types_to_decl(arena: *ASTArena, init_ref: i32,
decl_ty_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_type_array: i32 = 10;
    let ord_type_slice: i32 = 11;
    let ord_expr_array_lit: i32 = 46;
    let decl_kind_here: i32 = 0;
    let elem_decl_ref: i32 = 0;
    let elem_decl_kind: i32 = 0;
    let num_elems: i32 = 0;
    let i: i32 = 0;
    let eb: *u8 = 0 as *u8;
    let gb: *u8 = 0 as *u8;
    let el: i32 = 0;
    let gl: i32 = 0;
    let err_line: i32 = 0;
    let err_col: i32 = 0;
    if (ast.ref_is_null(init_ref) || ast.ref_is_null(decl_ty_ref)) {
      return 0;
    }
    if (pipeline_expr_kind_ord_at(arena, init_ref) != ord_expr_array_lit) {
      return 0;
    }
    decl_kind_here = pipeline_type_kind_ord_at(arena, decl_ty_ref);
    /* wave328 Cap residual: accept TYPE_SLICE (i32[] = [1,2,3]) as well as TYPE_ARRAY.
     * Prior: only TYPE_ARRAY → slice array-lit never stamped → host C (uint8_t[]){…}. */
    if (decl_kind_here != ord_type_array && decl_kind_here != ord_type_slice) {
      return 0;
    }
    elem_decl_ref = pipeline_type_elem_ref_at(arena, decl_ty_ref);
    if (ast.ref_is_null(elem_decl_ref)) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    elem_decl_kind = pipeline_type_kind_ord_at(arena, elem_decl_ref);
    num_elems = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
    while (i < num_elems) {
      let elem_ref: i32 = pipeline_expr_array_lit_elem_ref(arena, init_ref, i);
      let elem_kind: i32 = 0;
      let elem_ty: i32 = 0;
      let got_kind: i32 = 0;
      if (ast.ref_is_null(elem_ref)) {
        i = i + 1;
        continue;
      }
      elem_kind = pipeline_expr_kind_ord_at(arena, elem_ref);
      if (elem_kind == ord_expr_array_lit && elem_decl_kind == ord_type_array) {
        if (typeck_coerce_array_lit_elem_types_to_decl(arena, elem_ref, elem_decl_ref) < 0) {
          return - 1;
        }
      } else {
        typeck_coerce_init_lit_to_decl(arena, elem_ref, elem_decl_ref, elem_decl_kind, elem_kind);
        /* wave617: f32/f64 ARRAY_LIT elems — same stamp as scalar let f32 = 10.0. */
        typeck_coerce_init_float_lit_to_decl(arena, elem_ref, elem_decl_ref, elem_decl_kind, elem_kind);
        elem_ty = expr_type_ref(arena, elem_ref);
        if (!ast.ref_is_null(elem_ty) && elem_ty > 0) {
          got_kind = pipeline_type_kind_ord_at(arena, elem_ty);
          if (type_refs_equal(arena, elem_ty, elem_decl_ref)
          || typeck_integer_widen_ok_refs(arena, elem_decl_ref, elem_ty)
          || typeck_float_widen_ok(elem_decl_kind, got_kind)) {
            pipeline_expr_set_resolved_type_ref(arena, elem_ref, elem_decl_ref);
          } else {
            /*
             * wave672: known elem type does not match array/slice element decl.
             * Do not stamp outer ARRAY_LIT as decl (that was the false-green).
             */
            eb = driver_typeck_diag_scratch_expect();
            gb = driver_typeck_diag_scratch_found();
            el = typeck_diag_fmt_type_into(arena, elem_decl_ref, eb, 96);
            gl = typeck_diag_fmt_type_into(arena, elem_ty, gb, 96);
            err_line = pipeline_expr_line_at(arena, elem_ref);
            err_col = pipeline_expr_col_at(arena, elem_ref);
            driver_diagnostic_typeck_assign_mismatch(0, err_line, err_col, eb, el, gb, gl);
            return -1;
          }
        }
      }
      i = i + 1;
    }
    pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
    return 1;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function typeck_vector_lanes_of_type(arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_type_vector: i32 = 13;
    let ord_type_named: i32 = 8;
    let tk: i32 = 0;
    let asz: i32 = 0;
    let nm: u8[128] = [];
    let nlen: i32 = 0;
    let i: i32 = 0;
    let lanes: i32 = 0;
    if (ast.ref_is_null(type_ref) || type_ref <= 0) {
      return 0;
    }
    tk = pipeline_type_kind_ord_at(arena, type_ref);
    if (tk == ord_type_vector) {
      asz = pipeline_type_array_size_at(arena, type_ref);
      if (asz > 0) {
        return asz;
      }
      return 0;
    }
    if (tk != ord_type_named) {
      return 0;
    }
    nlen = pipeline_type_named_name_into(arena, type_ref, &nm[0]);
    /* See implementation. */
    i = 0;
    while (i < nlen) {
      if (nm[i] == 120) {
        i = i + 1;
        lanes = 0;
        while (i < nlen && nm[i] >= 48 && nm[i] <= 57) {
          lanes = lanes * 10 + (nm[i] as i32 - 48);
          i = i + 1;
        }
        if (lanes == 4 || lanes == 8 || lanes == 16) {
          return lanes;
        }
        return 0;
      }
      i = i + 1;
    }
    return 0;
  }
}

/**
 * Coerce ARRAY_LIT init to array / slice / vector declaration type.
 * @param arena *ASTArena — pool
 * @param init_ref i32 — init expression
 * @param decl_ty_ref i32 — declaration type
 * @param decl_kind i32 — type kind ordinal of decl
 * @param init_kind i32 — expr kind ordinal of init
 * @return i32 — 1 if coerced, 0 otherwise
 * PLATFORM: SHARED — wave328: TYPE_SLICE + ARRAY_LIT (same elem coerce as fixed array).
 */
export function typeck_coerce_init_array_vector_lit_to_decl(arena: *ASTArena, init_ref: i32,
decl_ty_ref: i32, decl_kind: i32, init_kind: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_type_array: i32 = 10;
    let ord_type_slice: i32 = 11;
    let ord_type_vector: i32 = 13;
    let ord_expr_array_lit: i32 = 46;
    let lanes: i32 = 0;
    /* Fixed array T[N] or open slice T[] ← [e0, e1, …] */
    if ((decl_kind == ord_type_array || decl_kind == ord_type_slice)
    && init_kind == ord_expr_array_lit) {
      return typeck_coerce_array_lit_elem_types_to_decl(arena, init_ref, decl_ty_ref);
    }
    if (init_kind == ord_expr_array_lit) {
      lanes = typeck_vector_lanes_of_type(arena, decl_ty_ref);
      if (lanes > 0 && pipeline_expr_array_lit_num_elems_at(arena, init_ref) == lanes) {
        pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
        return 1;
      }
      if (decl_kind == ord_type_vector
      && pipeline_expr_array_lit_num_elems_at(arena, init_ref) == pipeline_type_array_size_at(arena,
      decl_ty_ref)) {
        pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
        return 1;
      }
    }
    return 0;
  }
}

/* See implementation. */
export function typeck_coerce_init_vector_binop_to_decl(arena: *ASTArena, init_ref: i32, decl_ty_ref: i32,
decl_kind: i32, init_kind: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let lref_c: i32 = 0;
    let rref_c: i32 = 0;
    /* See implementation. */
    let ord_type_vector: i32 = 13;
    let ord_add: i32 = 4;
    let ord_sub: i32 = 5;
    let ord_mul: i32 = 6;
    let ord_div: i32 = 7;
    let ord_expr_array_lit: i32 = 46;
    let lanes: i32 = 0;
    lanes = typeck_vector_lanes_of_type(arena, decl_ty_ref);
    if (lanes <= 0 && decl_kind != ord_type_vector) {
      return 0;
    }
    if (lanes <= 0) {
      lanes = pipeline_type_array_size_at(arena, decl_ty_ref);
    }
    if (lanes <= 0) {
      return 0;
    }
    if (init_kind != ord_add && init_kind != ord_sub && init_kind != ord_mul && init_kind != ord_div) 
    {
      return 0;
    }
    lref_c = pipeline_expr_binop_left_ref_at(arena, init_ref);
    rref_c = pipeline_expr_binop_right_ref_at(arena, init_ref);
    if (!ast.ref_is_null(lref_c) && !ast.ref_is_null(rref_c)) {
      let lt_c: i32 = expr_type_ref(arena, lref_c);
      let rt_c: i32 = expr_type_ref(arena, rref_c);
      let lk_e: i32 = pipeline_expr_kind_ord_at(arena, lref_c);
      let rk_e: i32 = pipeline_expr_kind_ord_at(arena, rref_c);
      /* See implementation. */
      if (lk_e == ord_expr_array_lit && rk_e == ord_expr_array_lit
      && pipeline_expr_array_lit_num_elems_at(arena, lref_c) == lanes
      && pipeline_expr_array_lit_num_elems_at(arena, rref_c) == lanes) {
        pipeline_expr_set_resolved_type_ref(arena, lref_c, decl_ty_ref);
        pipeline_expr_set_resolved_type_ref(arena, rref_c, decl_ty_ref);
        pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
        return 1;
      }
      if (!ast.ref_is_null(lt_c) && !ast.ref_is_null(rt_c)
      && typeck_vector_lanes_of_type(arena, lt_c) == lanes
      && typeck_vector_lanes_of_type(arena, rt_c) == lanes
      && type_refs_equal(arena, pipeline_type_elem_ref_at(arena, lt_c),
      pipeline_type_elem_ref_at(arena, rt_c))) {
        pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
        return 1;
      }
    }
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function typeck_coerce_init_int_binop_to_decl(arena: *ASTArena, init_ref: i32, decl_ty_ref: i32,
decl_kind: i32, init_kind: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    return pipeline_typeck_coerce_init_int_binop_to_decl_c(arena, init_ref, decl_ty_ref,
    decl_kind, init_kind);
  }
}

/**
 * Coerce bool-typed const/let init into an integer declaration type.
 *
 * Purpose: LOGAND/LOGOR/EQ..GE/LOGNOT resolve to TYPE_BOOL, while product
 * code often writes `const V: i32 = (a && b) || c` (LANG-006 c_logical).
 * CTFE already folds those trees to 0/1 in const_folded_*; this only rewrites
 * resolved_type_ref so type_refs_equal accepts the declared integer.
 *
 * Parameters: init_ref must already be type-checked; decl_ty_ref is the
 * annotated const/let type; decl_kind is pipeline_type_kind_ord_at(decl).
 * Returns 1 if coercion applied, 0 if not applicable.
 * PLATFORM: SHARED — language coerce rule; verify with lang-const c_logical.
 */
export function typeck_coerce_init_bool_to_int_decl(arena: *ASTArena, init_ref: i32, decl_ty_ref: i32,
decl_kind: i32): i32 {
  // PLATFORM: SHARED — LANG-006 bool→integer init coerce (not emit-side fold).
  unsafe {
    let ord_bool: i32 = 1;
    let ord_i32: i32 = 0;
    let ord_u8: i32 = 2;
    let ord_u32: i32 = 3;
    let ord_u64: i32 = 4;
    let ord_i64: i32 = 5;
    let ord_usize: i32 = 6;
    let ord_isize: i32 = 7;
    let init_res: i32 = 0;
    let init_tk: i32 = 0;
    if (decl_kind != ord_i32 && decl_kind != ord_u8 && decl_kind != ord_u32 &&
        decl_kind != ord_u64 && decl_kind != ord_i64 && decl_kind != ord_usize &&
        decl_kind != ord_isize) {
      return 0;
    }
    init_res = pipeline_expr_resolved_type_ref(arena, init_ref);
    if (ast.ref_is_null(init_res)) {
      return 0;
    }
    init_tk = pipeline_type_kind_ord_at(arena, init_res);
    if (init_tk != ord_bool) {
      return 0;
    }
    pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
    return 1;
  }
}

/* See implementation. */
export function typeck_coerce_init_slice_from_array(arena: *ASTArena, init_ref: i32, decl_ty_ref: i32,
decl_kind: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_type_slice: i32 = 11;
    let ord_type_array: i32 = 10;
    let decl_elem: i32 = 0;
    let init_res: i32 = 0;
    let init_kind: i32 = 0;
    let init_elem: i32 = 0;
    if (decl_kind != ord_type_slice) {
      return 0;
    }
    decl_elem = pipeline_type_elem_ref_at(arena, decl_ty_ref);
    init_res = pipeline_expr_resolved_type_ref(arena, init_ref);
    if (ast.ref_is_null(decl_elem) || ast.ref_is_null(init_res)) {
      return 0;
    }
    init_kind = pipeline_type_kind_ord_at(arena, init_res);
    if (init_kind != ord_type_array) {
      return 0;
    }
    init_elem = pipeline_type_elem_ref_at(arena, init_res);
    if (ast.ref_is_null(init_elem)) {
      return 0;
    }
    if (!type_refs_equal(arena, init_elem, decl_elem)) {
      return 0;
    }
    pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
    return 1;
  }
}

/**
* See implementation.
* See implementation.
*/
export function typeck_coerce_init_expr_to_decl(module: *Module, arena: *ASTArena, init_ref: i32,
decl_ty_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let decl_kind: i32 = 0;
    let init_kind: i32 = 0;
    if (ast.ref_is_null(init_ref) || ast.ref_is_null(decl_ty_ref)) {
      return 0;
    }
    if (init_ref <= 0 || init_ref > arena.num_exprs || decl_ty_ref <= 0 || decl_ty_ref > 
    arena.num_types) {
      return 0;
    }
    decl_kind = pipeline_type_kind_ord_at(arena, decl_ty_ref);
    init_kind = pipeline_expr_kind_ord_at(arena, init_ref);
    if (typeck_coerce_init_lit_to_decl(arena, init_ref, decl_ty_ref, decl_kind, init_kind) != 0) {
      return 1;
    }
    if (typeck_coerce_init_float_lit_to_decl(arena, init_ref, decl_ty_ref, decl_kind,
    init_kind) != 0) {
      return 1;
    }
    if (typeck_coerce_init_enum_field_to_decl(module, arena, init_ref, decl_ty_ref, decl_kind,
    init_kind) != 0) {
      return 1;
    }
    if (typeck_coerce_init_named_call_to_decl(arena, init_ref, decl_ty_ref, decl_kind,
    init_kind) != 0) {
      return 1;
    }
    if (typeck_coerce_init_resolved_alias_to_decl(module, arena, init_ref, decl_ty_ref, decl_kind) != 0) {
      return 1;
    }
    /*
     * wave672: array-lit coerce returns -1 on known elem mismatch — propagate so
     * let/const do not soft-skip unstamped init_ty and false-green.
     */
    {
      let arr_c: i32 = typeck_coerce_init_array_vector_lit_to_decl(arena, init_ref, decl_ty_ref,
      decl_kind, init_kind);
      if (arr_c < 0) {
        return -1;
      }
      if (arr_c != 0) {
        return 1;
      }
    }
    if (typeck_coerce_init_vector_binop_to_decl(arena, init_ref, decl_ty_ref, decl_kind,
    init_kind) != 0) {
      return 1;
    }
    if (typeck_coerce_init_int_binop_to_decl(arena, init_ref, decl_ty_ref, decl_kind, init_kind) != 0) {
      return 1;
    }
    if (typeck_coerce_init_bool_to_int_decl(arena, init_ref, decl_ty_ref, decl_kind) != 0) {
      return 1;
    }
    if (typeck_coerce_init_slice_from_array(arena, init_ref, decl_ty_ref, decl_kind) != 0) {
      return 1;
    }
    return 0;
  }
}

/** Exported function `typeck_diag_append_lit`.
 * Implements `typeck_diag_append_lit`.
 * @param out *u8
 * @param pos i32
 * @param cap i32
 * @param lit *u8
 * @param lit_len i32
 * @return i32
 */
export function typeck_diag_append_lit(out: *u8, pos: i32, cap: i32, lit: *u8, lit_len: i32): i32 {
  let p: i32 = pos;
  let i: i32 = 0;
  while (i < lit_len && p >= 0 && p < cap) {
    out[p] = lit[i];
    p = p + 1;
    i = i + 1;
  }
  return p;
}

/** Exported function `typeck_diag_append_u32_dec`.
 * Implements `typeck_diag_append_u32_dec`.
 * @param out *u8
 * @param pos i32
 * @param cap i32
 * @param v i32
 * @return i32
 */
export function typeck_diag_append_u32_dec(out: *u8, pos: i32, cap: i32, v: i32): i32 {
  let p: i32 = pos;
  if (v < 0 || p < 0 || p >= cap) {
    return p;
  }
  if (v == 0) {
    let zd: u8[1] = [48];
    return typeck_diag_append_lit(out, p, cap, &zd[0], 1);
  }
  /* See implementation. */
  let cnt: i32 = 0;
  let tc: i32 = v;
  while (tc > 0) {
    cnt = cnt + 1;
    tc = tc / 10;
  }
  let k: i32 = cnt - 1;
  let tm: i32 = v;
  while (tm > 0) {
    let d: i32 = tm % 10;
    tm = tm / 10;
    if ((pos + k) < 0 || (pos + k) >= cap) {
      return p;
    }
    out[pos + k] = ((d + 48) as u8);
    k = k - 1;
  }
  return pos + cnt;
}

/** Exported function `typeck_diag_fmt_type_at`.
 * Implements `typeck_diag_fmt_type_at`.
 * @param arena *ASTArena
 * @param ref i32
 * @param out *u8
 * @param cur i32
 * @param cap i32
 * @return i32
 */
export function typeck_diag_fmt_type_at(arena: *ASTArena, ref: i32, out: *u8, cur: i32, cap: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let qmk: u8[1] = [63];
    let lit_i32: u8[3] = [105, 51, 50];
    let lit_bool: u8[4] = [98, 111, 111, 108];
    let lit_u8: u8[2] = [117, 56];
    let lit_u32: u8[3] = [117, 51, 50];
    let lit_u64: u8[3] = [117, 54, 52];
    let lit_i64: u8[3] = [105, 54, 52];
    let lit_usize: u8[5] = [117, 115, 105, 122, 101];
    let lit_isize: u8[5] = [105, 115, 105, 122, 101];
    let lit_f32: u8[3] = [102, 51, 50];
    let lit_f64: u8[3] = [102, 54, 52];
    /* wave663: format TYPE_VOID as "void" (was bare "?"). */
    let lit_void: u8[4] = [118, 111, 105, 100];
    let star: u8[1] = [42];
    let lbk: u8[1] = [91];
    let rbk: u8[1] = [93];
    let slo: u8[2] = [91, 93];
    let kind: i32 = 0;
    let nlen: i32 = 0;
    let elem_ref: i32 = 0;
    let asz: i32 = 0;
    let ord_i32: i32 = 0;
    let ord_bool: i32 = 1;
    let ord_u8: i32 = 2;
    let ord_u32: i32 = 3;
    let ord_u64: i32 = 4;
    let ord_i64: i32 = 5;
    let ord_usize: i32 = 6;
    let ord_isize: i32 = 7;
    let ord_named: i32 = 8;
    let ord_ptr: i32 = 9;
    let ord_array: i32 = 10;
    let ord_slice: i32 = 11;
    let ord_linear: i32 = 12;
    let ord_f32: i32 = 14;
    let ord_f64: i32 = 15;
    let ord_void: i32 = 16;
    let nm_buf: *u8 = typeck_scratch64_slot(0);
    if (cur < 0 || cap <= 0 || cur >= cap) {
      return cur;
    }
    if (ast.ref_is_null(ref) || ref <= 0 || ref > arena.num_types) {
      return typeck_diag_append_lit(out, cur, cap, &qmk[0], 1);
    }
    kind = pipeline_type_kind_ord_at(arena, ref);
    if (kind == ord_named) {
      nlen = pipeline_type_named_name_into(arena, ref, nm_buf);
      if (nlen > 0) {
        return typeck_diag_append_lit(out, cur, cap, nm_buf, nlen);
      }
    }
    if (kind == ord_i32) {
      return typeck_diag_append_lit(out, cur, cap, &lit_i32[0], 3);
    }
    if (kind == ord_bool) {
      return typeck_diag_append_lit(out, cur, cap, &lit_bool[0], 4);
    }
    if (kind == ord_u8) {
      return typeck_diag_append_lit(out, cur, cap, &lit_u8[0], 2);
    }
    if (kind == ord_u32) {
      return typeck_diag_append_lit(out, cur, cap, &lit_u32[0], 3);
    }
    if (kind == ord_u64) {
      return typeck_diag_append_lit(out, cur, cap, &lit_u64[0], 3);
    }
    if (kind == ord_i64) {
      return typeck_diag_append_lit(out, cur, cap, &lit_i64[0], 3);
    }
    if (kind == ord_usize) {
      return typeck_diag_append_lit(out, cur, cap, &lit_usize[0], 5);
    }
    if (kind == ord_isize) {
      return typeck_diag_append_lit(out, cur, cap, &lit_isize[0], 5);
    }
    if (kind == ord_f32) {
      return typeck_diag_append_lit(out, cur, cap, &lit_f32[0], 3);
    }
    if (kind == ord_f64) {
      return typeck_diag_append_lit(out, cur, cap, &lit_f64[0], 3);
    }
    if (kind == ord_void) {
      return typeck_diag_append_lit(out, cur, cap, &lit_void[0], 4);
    }
    if (kind == ord_ptr) {
      elem_ref = pipeline_type_elem_ref_at(arena, ref);
      let nex: i32 = typeck_diag_append_lit(out, cur, cap, &star[0], 1);
      return typeck_diag_fmt_type_at(arena, elem_ref, out, nex, cap);
    }
    if (kind == ord_slice) {
      let lt_ch: u8[1] = [60];
      let gt_ch: u8[1] = [62];
      let rlen: i32 = 0;
      let rbuf: *u8 = typeck_scratch64_slot(15);
      elem_ref = pipeline_type_elem_ref_at(arena, ref);
      let nex2: i32 = typeck_diag_append_lit(out, cur, cap, &slo[0], 2);
      nex2 = typeck_diag_fmt_type_at(arena, elem_ref, out, nex2, cap);
      rlen = pipeline_type_region_label_len_at(arena, ref);
      if (rlen > 0 && pipeline_type_region_label_into(arena, ref, rbuf) == rlen) {
        let p0: i32 = typeck_diag_append_lit(out, nex2, cap, &lt_ch[0], 1);
        let p1: i32 = typeck_diag_append_lit(out, p0, cap, rbuf, rlen);
        return typeck_diag_append_lit(out, p1, cap, &gt_ch[0], 1);
      }
      return nex2;
    }
    if (kind == ord_linear) {
      let lpar: u8[7] = [76, 105, 110, 101, 97, 114, 40];
      let rpar: u8[1] = [41];
      elem_ref = pipeline_type_elem_ref_at(arena, ref);
      let p0: i32 = typeck_diag_append_lit(out, cur, cap, &lpar[0], 7);
      let p1: i32 = typeck_diag_fmt_type_at(arena, elem_ref, out, p0, cap);
      return typeck_diag_append_lit(out, p1, cap, &rpar[0], 1);
    }
    if (kind == ord_array) {
      elem_ref = pipeline_type_elem_ref_at(arena, ref);
      asz = pipeline_type_array_size_at(arena, ref);
      if (!ast.ref_is_null(elem_ref) && asz > 0) {
        let p0: i32 = typeck_diag_append_lit(out, cur, cap, &lbk[0], 1);
        let p1: i32 = typeck_diag_append_u32_dec(out, p0, cap, asz);
        let p2: i32 = typeck_diag_append_lit(out, p1, cap, &rbk[0], 1);
        return typeck_diag_fmt_type_at(arena, elem_ref, out, p2, cap);
      }
    }
    return typeck_diag_append_lit(out, cur, cap, &qmk[0], 1);
  }
}

/** Exported function `typeck_diag_fmt_type_into`.
 * Implements `typeck_diag_fmt_type_into`.
 * @param arena *ASTArena
 * @param ref i32
 * @param out *u8
 * @param cap i32
 * @return i32
 */
export function typeck_diag_fmt_type_into(arena: *ASTArena, ref: i32, out: *u8, cap: i32): i32 {
  return typeck_diag_fmt_type_at(arena, ref, out, 0, cap);
}

/** Exported function `typeck_diag_fmt_type_or_question`.
 * Implements `typeck_diag_fmt_type_or_question`.
 * @param arena *ASTArena
 * @param ref i32
 * @param out *u8
 * @return i32
 */
export function typeck_diag_fmt_type_or_question(arena: *ASTArena, ref: i32, out: *u8): i32 {
  let qmk: u8[1] = [63];
  if (ast.ref_is_null(ref) || ref <= 0 || ref > arena.num_types) {
    return typeck_diag_append_lit(out, 0, 96, &qmk[0], 1);
  }
  return typeck_diag_fmt_type_into(arena, ref, out, 96);
}

/**
* See implementation.
* See implementation.
*/
export function typeck_ret_coerce_integral_to_expect_i32(arena: *ASTArena, op_ref: i32,
expect_ref: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_i32: i32 = 0;
    let ord_u8: i32 = 2;
    let ord_usize: i32 = 6;
    if (ast.ref_is_null(op_ref) || op_ref <= 0 || op_ref > arena.num_exprs || ast.ref_is_null(expect_ref)) {
      return;
    }
    if (expect_ref <= 0 || expect_ref > arena.num_types) {
      return;
    }
    /* See implementation. */
    if (pipeline_type_kind_ord_at(arena, expect_ref) != ord_i32) {
      return;
    }
    let got_ref: i32 = expr_type_ref(arena, op_ref);
    if (ast.ref_is_null(got_ref) || got_ref <= 0 || got_ref > arena.num_types) {
      return;
    }
    let got_kind: i32 = pipeline_type_kind_ord_at(arena, got_ref);
    /* See implementation. */
    if (got_kind != ord_u8 && got_kind != ord_usize) {
      return;
    }
    pipeline_expr_set_resolved_type_ref(arena, op_ref, expect_ref);
  }
}

/**
* See implementation.
* See implementation.
*/
export function typeck_ret_coerce_integral_widen(arena: *ASTArena, op_ref: i32, expect_ref: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let got_ref: i32 = 0;
    let expect_kind: i32 = 0;
    let got_kind: i32 = 0;
    if (ast.ref_is_null(op_ref) || op_ref <= 0 || op_ref > arena.num_exprs || ast.ref_is_null(expect_ref)) {
      return;
    }
    if (expect_ref <= 0 || expect_ref > arena.num_types) {
      return;
    }
    got_ref = expr_type_ref(arena, op_ref);
    if (ast.ref_is_null(got_ref) || got_ref <= 0 || got_ref > arena.num_types) {
      return;
    }
    expect_kind = pipeline_type_kind_ord_at(arena, expect_ref);
    got_kind = pipeline_type_kind_ord_at(arena, got_ref);
    /* wave313: refs path covers NAMED i8/i16/u16 as well as first-class. */
    if (typeck_integer_widen_ok_refs(arena, expect_ref, got_ref)) {
      pipeline_expr_set_resolved_type_ref(arena, op_ref, expect_ref);
      return;
    }
    /* wave314: f32-to-f64 return is accepted by return_operand_matches; do not stamp
     * (freestanding emit promotes with SSE convert using true float32 bits).
     * wave1218: avoid digit+letter glues in comments before (void) casts;
     * lparen rewind probes can land mid-comment and sticky-L009 the parse. */
    /* wave1219: removed (void)expect_kind / (void)got_kind — C-style cast not
     * supported in X (parsed as call to unresolved `void` function). Variables
     * are assigned-but-unused; safe to drop the cast-to-void suppression. */
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function typeck_ret_coerce_null_lit_to_expect(arena: *ASTArena, op_ref: i32, expect_ref: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_lit: i32 = 0;
    let ord_ptr: i32 = 9;
    let op_kind: i32 = 0;
    let expect_kind: i32 = 0;
    let int_val: i32 = 0;
    if (arena == 0 as *ASTArena || ast.ref_is_null(op_ref) || ast.ref_is_null(expect_ref)) {
      return;
    }
    op_kind = pipeline_expr_kind_ord_at(arena, op_ref);
    if (op_kind != ord_lit) {
      return;
    }
    expect_kind = pipeline_type_kind_ord_at(arena, expect_ref);
    int_val = pipeline_expr_int_val_at(arena, op_ref);
    if (expect_kind == ord_ptr && int_val == 0) {
      pipeline_expr_set_resolved_type_ref(arena, op_ref, expect_ref);
    }
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function typeck_ret_fixup_unresolved_call(module: *Module, arena: *ASTArena, op_ref: i32,
ctx: *PipelineDepCtx): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_call: i32 = 48;
    let op_kind: i32 = 0;
    if (module == 0 as *Module || arena == 0 as *ASTArena || ast.ref_is_null(op_ref)) {
      return;
    }
    if (!ast.ref_is_null(expr_type_ref(arena, op_ref))) {
      return;
    }
    op_kind = pipeline_expr_kind_ord_at(arena, op_ref);
    if (op_kind != ord_call) {
      return;
    }
    typeck_check_expr_call_resolve(module, arena, op_ref, ctx);
  }
}

/**
 * See implementation.
 */
export function typeck_return_breadcrumb_into(arena: *ASTArena, expr_ref: i32, out: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_var: i32 = 3;
    let ord_field: i32 = 44;
    let ord_call: i32 = 48;
    let ord_method_call: i32 = 49;
    let kind: i32 = 0;
    let base_ref: i32 = 0;
    let callee_ref: i32 = 0;
    let base_len: i32 = 0;
    let field_len: i32 = 0;
    let callee_len: i32 = 0;
    if (arena == 0 as *ASTArena || expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    kind = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (kind == ord_var) {
      base_len = pipeline_expr_var_name_len(arena, expr_ref);
      if (base_len <= 0 || base_len > 60) {
        return 0;
      }
      pipeline_expr_var_name_into(arena, expr_ref, out);
      out[base_len] = 0;
      return base_len;
    }
    if (kind == ord_field) {
      base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
      if (base_ref <= 0 || base_ref > arena.num_exprs) {
        return 0;
      }
      base_len = typeck_return_breadcrumb_into(arena, base_ref, out);
      field_len = pipeline_expr_field_access_name_len(arena, expr_ref);
      if (base_len <= 0 || field_len <= 0 || base_len + 1 + field_len > 60) {
        return 0;
      }
      out[base_len] = 46;
      pipeline_expr_field_access_name_into(arena, expr_ref, &out[base_len + 1]);
      out[base_len + 1 + field_len] = 0;
      return base_len + 1 + field_len;
    }
    if (kind == ord_call) {
      callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
      callee_len = typeck_return_breadcrumb_into(arena, callee_ref, out);
      if (callee_len <= 0 || callee_len + 2 > 60) {
        return 0;
      }
      out[callee_len] = 40;
      out[callee_len + 1] = 41;
      out[callee_len + 2] = 0;
      return callee_len + 2;
    }
    if (kind == ord_method_call) {
      base_ref = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
      base_len = typeck_return_breadcrumb_into(arena, base_ref, out);
      field_len = pipeline_expr_method_call_name_len(arena, expr_ref);
      if (base_len <= 0 || field_len <= 0 || base_len + 3 + field_len > 60) {
        return 0;
      }
      out[base_len] = 46;
      pipeline_expr_method_call_name_into(arena, expr_ref, &out[base_len + 1]);
      out[base_len + 1 + field_len] = 40;
      out[base_len + 2 + field_len] = 41;
      out[base_len + 3 + field_len] = 0;
      return base_len + 3 + field_len;
    }
    return 0;
  }
}

/** Function `typeck_emit_return_subexpr_breadcrumb`.
 * Purpose: implements `typeck_emit_return_subexpr_breadcrumb`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function typeck_emit_return_subexpr_breadcrumb(arena: *ASTArena, expr_ref: i32, line: i32,
col: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let buf: *u8 = typeck_scratch64_slot(2);
    let bl: i32 = typeck_return_breadcrumb_into(arena, expr_ref, buf);
    if (bl > 0) {
      driver_diagnostic_typeck_return_subexpr(line, col, buf, bl);
    }
  }
}

/** Function `typeck_emit_return_unresolved_breadcrumb`.
 * Purpose: implements `typeck_emit_return_unresolved_breadcrumb`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function typeck_emit_return_unresolved_breadcrumb(arena: *ASTArena, expr_ref: i32, line: i32,
col: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let buf: *u8 = typeck_scratch64_slot(2);
    let bl: i32 = typeck_return_breadcrumb_into(arena, expr_ref, buf);
    if (bl > 0) {
      driver_diagnostic_typeck_return_unresolved(line, col, buf, bl);
    }
  }
}

/** Exported function `typeck_check_expr_float_lit`.
 * Implements `typeck_check_expr_float_lit`.
 * @param arena *ASTArena
 * @param expr_ref i32
 * @return i32
 */
export function typeck_check_expr_float_lit(arena: *ASTArena, expr_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    pipeline_expr_typeck_set_float_bits_from_val(arena, expr_ref);
    let ft: i32 = ensure_f64_type_ref(arena);
    if (ft != 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, ft);
    }
    return 0;
  }
}

/* See implementation. */
export extern function pipeline_typeck_check_expr_int_lit_c(arena: *ASTArena, expr_ref: i32): i32;
/** Exported function `typeck_check_expr_int_lit`.
 * Implements `typeck_check_expr_int_lit`.
 * @param arena *ASTArena
 * @param expr_ref i32
 * @param return_type_ref i32
 * @return i32
 */
export function typeck_check_expr_int_lit(arena: *ASTArena, expr_ref: i32, return_type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    typeck_ret_coerce_null_lit_to_expect(arena, expr_ref, return_type_ref);
    return pipeline_typeck_check_expr_int_lit_c(arena, expr_ref);
  }
}

/** Exported function `typeck_check_expr_bool_lit`.
 * Implements `typeck_check_expr_bool_lit`.
 * @param arena *ASTArena
 * @param expr_ref i32
 * @return i32
 */
export function typeck_check_expr_bool_lit(arena: *ASTArena, expr_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let bt: i32 = ensure_bool_type_ref(arena);
    if (bt != 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, bt);
    }
    return 0;
  }
}

/** Exported function `typeck_check_expr_string_lit`.
 * Implements `typeck_check_expr_string_lit`.
 * @param arena *ASTArena
 * @param expr_ref i32
 * @return i32
 */
export function typeck_check_expr_string_lit(arena: *ASTArena, expr_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let u8r: i32 = ensure_u8_type_ref(arena);
    let ptr_u8: i32 = 0;
    if (ast.ref_is_null(u8r)) {
      return -1;
    }
    ptr_u8 = find_or_alloc_ptr_type_ref(arena, u8r);
    if (!ast.ref_is_null(ptr_u8)) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, ptr_u8);
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function typeck_check_expr_break_continue(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_break: i32 = 39;
    let ord_continue: i32 = 40;
    let line: i32 = 0;
    let col: i32 = 0;
    let kind: i32 = 0;
    let is_break: i32 = 1;
    if (pipeline_dep_ctx_typeck_loop_depth_at(ctx) > 0) {
      return 0;
    }
    line = pipeline_expr_line_at(arena, expr_ref);
    col = pipeline_expr_col_at(arena, expr_ref);
    kind = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (kind == ord_continue) {
      is_break = 0;
    }
    driver_diagnostic_typeck_break_continue_outside(line, col, is_break);
    return - 1;
  }
}

/** Exported function `typeck_check_expr_enum_variant`.
 * Implements `typeck_check_expr_enum_variant`.
 * @param arena *ASTArena
 * @param expr_ref i32
 * @return i32
 */
export function typeck_check_expr_enum_variant(arena: *ASTArena, expr_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let it: i32 = ensure_i32_type_ref(arena);
    if (it != 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, it);
    }
    return 0;
  }
}

/* See implementation. */
export function typeck_check_expr_if_ternary(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_ternary: i32 = 27;
    let ord_named: i32 = 8;
    let ord_lit: i32 = 0;
    let ord_i32: i32 = 0;
    let ord_u8: i32 = 2;
    let expr_kind: i32 = pipeline_expr_kind_ord_at(arena, expr_ref);
    let cond_ref: i32 = pipeline_expr_if_cond_ref_at(arena, expr_ref);
    let then_ref: i32 = pipeline_expr_if_then_ref_at(arena, expr_ref);
    let else_ref: i32 = pipeline_expr_if_else_ref_at(arena, expr_ref);
    let ty_t: i32 = 0;
    let ty_e: i32 = 0;
    let t_named: bool = false;
    let e_named: bool = false;
    let resolved: i32 = 0;
    let cond_ty: i32 = 0;
    let expect_kind: i32 = 0;
    let got_kind: i32 = 0;
    let then_k: i32 = 0;
    let else_k: i32 = 0;
    let tv: i32 = 0;
    let ev: i32 = 0;
    /*
     * wave704: if/ternary condition ambient must be 0 (bool), not fn return type.
     * `if (count <= 0)` in `*i32` fn ambient-stamped lit 0 as *i32 → T001.
     * PLATFORM: SHARED.
     */
    if (check_expr(module, arena, cond_ref, 0, ctx) != 0) {
      return - 1;
    }
    if (!ast.ref_is_null(cond_ref)) {
      cond_ty = expr_type_ref(arena, cond_ref);
      if (!type_ref_is_bool(arena, cond_ty)) {
        return - 1;
      }
    }
    if (check_expr(module, arena, then_ref, return_type_ref, ctx) != 0) {
      return - 1;
    }
    if (!ast.ref_is_null(else_ref)) {
      if (check_expr(module, arena, else_ref, return_type_ref, ctx) != 0) {
        return - 1;
      }
    }
    ty_t = expr_type_ref(arena, then_ref);
    ty_e = expr_type_ref(arena, else_ref);
    if (!ast.ref_is_null(ty_t) && ty_t > 0) {
      t_named = (pipeline_type_kind_ord_at(arena, ty_t) == ord_named);
    }
    if (!ast.ref_is_null(ty_e) && ty_e > 0) {
      e_named = (pipeline_type_kind_ord_at(arena, ty_e) == ord_named);
    }
    if (expr_kind == ord_ternary) {
      if (ast.ref_is_null(ty_t)) {
        return - 1;
      }
      if (ast.ref_is_null(ty_e)) {
        return - 1;
      }
      if (!type_refs_equal(arena, ty_t, ty_e)) {
        return - 1;
      }
      resolved = ty_t;
      if (!ast.ref_is_null(return_type_ref) && return_type_ref > 0 && return_type_ref <= arena.num_types) {
        expect_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
        got_kind = pipeline_type_kind_ord_at(arena, ty_t);
        if (typeck_integer_widen_ok_refs(arena, return_type_ref, ty_t)) {
          resolved = return_type_ref;
        } else if (typeck_float_widen_ok(expect_kind, got_kind)) {
          /* wave314: ternary arms f32 under f64 expect. */
          resolved = return_type_ref;
        } else if (expect_kind == ord_u8 && got_kind == ord_i32) {
          /* See implementation. */
          then_k = pipeline_expr_kind_ord_at(arena, then_ref);
          else_k = pipeline_expr_kind_ord_at(arena, else_ref);
          if (then_k == ord_lit && else_k == ord_lit) {
            tv = pipeline_expr_int_val_at(arena, then_ref);
            ev = pipeline_expr_int_val_at(arena, else_ref);
            if (tv >= 0 && tv <= 255 && ev >= 0 && ev <= 255) {
              resolved = return_type_ref;
              pipeline_expr_set_resolved_type_ref(arena, then_ref, return_type_ref);
              pipeline_expr_set_resolved_type_ref(arena, else_ref, return_type_ref);
            }
          }
        }
      }
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, resolved);
      return 0;
    }
    if (!ast.ref_is_null(ty_t) && !ast.ref_is_null(ty_e) && t_named && e_named) {
      if (!type_refs_equal(arena, ty_t, ty_e)) {
        return - 1;
      }
    }
    if (!ast.ref_is_null(ty_t) && !ast.ref_is_null(ty_e)) {
      if (e_named && !t_named) {
        resolved = ty_e;
      } else {
        resolved = ty_t;
      }
    } else if (!ast.ref_is_null(ty_t)) {
      resolved = ty_t;
    } else if (!ast.ref_is_null(ty_e)) {
      resolved = ty_e;
    }
    if (!ast.ref_is_null(resolved)) {
      /* See implementation. */
      if (!ast.ref_is_null(return_type_ref) && return_type_ref > 0 && return_type_ref <= arena.num_types) {
        expect_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
        got_kind = pipeline_type_kind_ord_at(arena, resolved);
        if (typeck_integer_widen_ok_refs(arena, return_type_ref, resolved)) {
          resolved = return_type_ref;
        } else if (typeck_float_widen_ok(expect_kind, got_kind)) {
          /* wave314: if-expr result f32 under f64 expect. */
          resolved = return_type_ref;
        }
      }
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, resolved);
    }
    return 0;
  }
}

/** Exported function `typeck_block_expr_value_ref`.
 * Implements `typeck_block_expr_value_ref`.
 * @param arena *ASTArena
 * @param block_ref i32
 * @return i32
 */
export function typeck_block_expr_value_ref(arena: *ASTArena, block_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let stmt_order_kind_region_c_parser: u8 = 5 as u8;
    let stmt_order_kind_region_x_parser: u8 = 6 as u8;
    let fin_ref: i32 = 0;
    let nso: i32 = 0;
    let last_k: u8 = 0 as u8;
    let ridx: i32 = 0;
    let nreg: i32 = 0;
    let inner_ref: i32 = 0;
    if (ast.ref_is_null(block_ref) || block_ref <= 0 || block_ref > arena.num_blocks) {
      return 0;
    }
    fin_ref = ast.ast_block_final_expr_ref(arena, block_ref);
    if (!ast.ref_is_null(fin_ref)) {
      return fin_ref;
    }
    nso = ast.ast_block_num_stmt_order(arena, block_ref);
    if (nso <= 0) {
      return 0;
    }
    last_k = ast.ast_block_stmt_order_kind(arena, block_ref, nso - 1);
    if (last_k != stmt_order_kind_region_c_parser && last_k != stmt_order_kind_region_x_parser) {
      return 0;
    }
    ridx = ast.ast_block_stmt_order_idx(arena, block_ref, nso - 1);
    nreg = ast.ast_block_num_regions(arena, block_ref);
    if (ridx < 0 || ridx >= nreg) {
      return 0;
    }
    if (pipeline_block_region_is_unsafe(arena, block_ref, ridx) == 0) {
      return 0;
    }
    inner_ref = ast.ast_block_region_body_ref(arena, block_ref, ridx);
    return typeck_block_expr_value_ref(arena, inner_ref);
  }
}

/** Function `typeck_check_expr_block`.
 * Purpose: implements `typeck_check_expr_block`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function typeck_check_expr_block(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_assign: i32 = 28;
    let block_ref: i32 = pipeline_expr_block_ref_at(arena, expr_ref);
    let fin_blk: i32 = 0;
    let ty_fin: i32 = 0;
    let nes: i32 = 0;
    let fst_es: i32 = 0;
    let st_kind: i32 = 0;
    let rhs_ref: i32 = 0;
    let ty_rhs: i32 = 0;
    if (check_block(module, arena, block_ref, return_type_ref, ctx) != 0) {
      return - 1;
    }
    if (ast.ref_is_null(block_ref) || block_ref <= 0) {
      return 0;
    }
    fin_blk = typeck_block_expr_value_ref(arena, block_ref);
    if (!ast.ref_is_null(fin_blk)) {
      ty_fin = expr_type_ref(arena, fin_blk);
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, ty_fin);
      return 0;
    }
    nes = ast.ast_block_num_expr_stmts(arena, block_ref);
    if (nes != 1) {
      return 0;
    }
    fst_es = pipeline_block_expr_stmt_ref(arena, block_ref, 0);
    if (fst_es <= 0) {
      return 0;
    }
    st_kind = pipeline_expr_kind_ord_at(arena, fst_es);
    if (st_kind != ord_assign && (st_kind < 29 || st_kind > 39)) {
      return 0;
    }
    rhs_ref = pipeline_expr_binop_right_ref_at(arena, fst_es);
    if (ast.ref_is_null(rhs_ref)) {
      return 0;
    }
    ty_rhs = expr_type_ref(arena, rhs_ref);
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, ty_rhs);
    return 0;
  }
}

/**
 * See implementation.
 */
export function typeck_check_expr_assign(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_assign: i32 = 28;
    let ord_add_assign: i32 = 29;
    let ord_sub_assign: i32 = 30;
    let ord_lit: i32 = 0;
    let ord_var: i32 = 3;
    let ord_ternary: i32 = 27;
    let ord_add: i32 = 4;
    let ord_sub: i32 = 5;
    let ord_i32: i32 = 0;
    let ord_u8: i32 = 2;
    let ord_u32: i32 = 3;
    let ord_u64: i32 = 4;
    let ord_i64: i32 = 5;
    let ord_usize: i32 = 6;
    let ord_isize: i32 = 7;
    let ord_named: i32 = 8;
    let ord_ptr: i32 = 9;
    let ord_type_array: i32 = 10;
    let ord_field: i32 = 44;
    let ord_index: i32 = 47;
    let ord_call: i32 = 48;
    let ord_expr_array_lit: i32 = 46;
    let ord_string_lit: i32 = 59;
    let expr_kind: i32 = pipeline_expr_kind_ord_at(arena, expr_ref);
    let left_ref: i32 = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    let right_ref: i32 = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    let line: i32 = pipeline_expr_line_at(arena, expr_ref);
    let col: i32 = pipeline_expr_col_at(arena, expr_ref);
    /* See implementation. */
    if (pipeline_typeck_check_struct_stack_escape_assign_c(module, arena, expr_ref, left_ref, right_ref, ctx) != 0) {
      return - 1;
    }
    if (pipeline_typeck_check_scope_borrow_assign_c(module, arena, expr_ref, left_ref, right_ref, ctx) != 0) {
      return - 1;
    }
    if (pipeline_typeck_check_allocator_region_assign_c(module, arena, expr_ref, left_ref, ctx) != 0) {
      return - 1;
    }
    let lt: i32 = 0;
    let rt: i32 = 0;
    let rt_after: i32 = 0;
    let rhs_ctx: i32 = 0;
    let compound_flag: i32 = 1;
    let lt_kind: i32 = 0;
    let rhs_kind: i32 = 0;
    let lhs_kind: i32 = 0;
    let int_val: i32 = 0;
    let ev: i32 = 0;
    let then_r: i32 = 0;
    let else_r: i32 = 0;
    let eb: *u8 = 0 as *u8;
    let gb: *u8 = 0 as *u8;
    let el: i32 = 0;
    let gl: i32 = 0;
    /*
     * wave643: 1 when compound *T +=/-= integer offset is accepted (C-like ≡ p = p ± n).
     * Do not stamp RHS to *T (emit wave642 scales integer offset by sizeof(*p)).
     */
    let ptr_compound_offset_ok: i32 = 0;
    if (expr_kind == ord_assign) {
      compound_flag = 0;
    }
    /*
     * Assign LHS must not inherit the *function* return ambient.
     * wave465 stamps unconstrained field results with ambient; when LHS is
     * FIELD_ACCESS (`out.method = m` / `s.c = c`), feeding return_type_ref
     * rewrote the field type to the function return (or void→`?`) and caused
     * "expected S/?, found Color|Method" on enum field stores that already
     * type as R-values. G.7: check left with expected 0; then use resolved
     * lt as RHS expected (below). PLATFORM: SHARED.
     */
    if (check_expr(module, arena, left_ref, 0, ctx) != 0) {
      return - 1;
    }
    /*
     * wave678 Cap residual: const is immutable (docs/06). VAR LHS only;
     * block parent chain then top-level const. G.7 twin of product
     * pipeline_typeck_check_expr_assign_c. PLATFORM: SHARED.
     */
    {
      let lhs_kind_c: i32 = pipeline_expr_kind_ord_at(arena, left_ref);
      if (lhs_kind_c == ord_var) {
        let vbuf_c: u8[128] = [];
        let vnlen_c: i32 = pipeline_expr_var_name_len(arena, left_ref);
        let bind_kind: i32 = -1;
        let br_c: i32 = 0;
        let bi: i32 = 0;
        if (vnlen_c > 0 && vnlen_c < 128) {
          pipeline_expr_var_name_into(arena, left_ref, &vbuf_c[0]);
          if (ctx != 0 as *PipelineDepCtx) {
            br_c = pipeline_dep_ctx_current_block_ref_at(ctx);
            if (br_c > 0) {
              bind_kind = pipeline_block_name_binding_kind(arena, br_c, &vbuf_c[0], vnlen_c);
            }
          }
          if (bind_kind < 0) {
            bi = pipeline_module_top_level_name_is_const(module, &vbuf_c[0], vnlen_c);
            if (bi != 0) {
              bind_kind = 1;
            }
          }
          if (bind_kind == 1) {
            driver_diagnostic_typeck_assign_to_const(line, col);
            return -1;
          }
        }
      }
    }
    lt = expr_type_ref(arena, left_ref);
    rhs_ctx = return_type_ref;
    if (!ast.ref_is_null(lt)) {
      rhs_ctx = lt;
    }
    /*
     * wave643 Cap residual: compound `p += n` / `p -= n` is C-like pointer
     * arithmetic (≡ `p = p ± n`). The compound RHS is an *integer offset*, not
     * *T. Prior path set rhs_ctx = lt (*T) then required type_refs_equal →
     * "expected *i32, found i32" while `p = p + 1` already greened (wave285
     * binop + wave642 freestanding scale). G.7: complete same assign authority
     * (no second compound-ptr path); offset kinds match wave285 (i32/usize/isize
     * plus common integer widths for typed offset vars). PLATFORM: SHARED —
     * seed typeck_gen same commit.
     */
    if (compound_flag != 0 && !ast.ref_is_null(lt)
    && (expr_kind == ord_add_assign || expr_kind == ord_sub_assign)) {
      lt_kind = pipeline_type_kind_ord_at(arena, lt);
      if (lt_kind == ord_ptr) {
        rhs_ctx = 0;
      }
    }
    if (check_expr(module, arena, right_ref, rhs_ctx, ctx) != 0) {
      return - 1;
    }
    if (ast.ref_is_null(left_ref) || ast.ref_is_null(right_ref)) {
      return 0;
    }
    if (ast.ref_is_null(lt)) {
      lt = expr_type_ref(arena, left_ref);
    }
    rt_after = expr_type_ref(arena, right_ref);
    if (!ast.ref_is_null(lt) && lt > 0) {
      rhs_kind = pipeline_expr_kind_ord_at(arena, right_ref);
      lt_kind = pipeline_type_kind_ord_at(arena, lt);
      /*
       * wave331: assign ARRAY_LIT → TYPE_ARRAY or TYPE_SLICE (G.7 reuse
       * typeck_coerce_array_lit_elem_types_to_decl; let-init wave328 already accepted
       * TYPE_SLICE — assign previously only TYPE_ARRAY → `a:i32[] = []` found `?`).
       */
      {
        let ord_type_slice: i32 = 11;
        if (rhs_kind == ord_expr_array_lit
        && (lt_kind == ord_type_array || lt_kind == ord_type_slice)) {
          if (typeck_coerce_array_lit_elem_types_to_decl(arena, right_ref, lt) < 0) {
            return - 1;
          }
          rt_after = expr_type_ref(arena, right_ref);
        }
      }
      /*
       * wave308: assign RHS bare EXPR_LIT — reuse typeck_coerce_init_lit_to_decl
       * (G.7 single authority; same full-i64 path as let-init / wave307).
       * Prior hand path used pipeline_expr_int_val_at (i32 truncate) +
       * `int_val >= 0` for u64/usize, so `a = u64max` / `a = i64max` failed.
       * wave310: assign RHS EXPR_NEG / int binop — reuse typeck_coerce_init_int_binop_to_decl
       * (closes `a:u8=-1` / `a:u16=-1` / `a:u64=-1` assign + `1-2`; let-init already had int_binop).
       * wave316: assign/compound RHS FLOAT_LIT / `-float` — reuse typeck_coerce_init_float_lit_to_decl
       * (closes `a:f32 = 6.0` / `a += 2.0` / `a = -6.0`; let-init already had float lit).
       * PLATFORM: SHARED — typeck lit/binop/float/array-lit assign coerce.
       */
      if (!type_refs_equal(arena, lt, rt_after)) {
        if (rhs_kind == ord_lit) {
          typeck_coerce_init_lit_to_decl(arena, right_ref, lt, lt_kind, rhs_kind);
        } else {
          typeck_coerce_init_float_lit_to_decl(arena, right_ref, lt, lt_kind, rhs_kind);
          typeck_coerce_init_int_binop_to_decl(arena, right_ref, lt, lt_kind, rhs_kind);
        }
      }
      /*
       * wave670: keyword `null` only for TYPE_PTR assign RHS. Unstamped null
       * would soft-skip the lt/rt equal check below.
       */
      if (typeck_expr_is_null_keyword(arena, right_ref) != 0 && lt_kind != ord_ptr) {
        eb = driver_typeck_diag_scratch_expect();
        gb = driver_typeck_diag_scratch_found();
        el = typeck_diag_fmt_type_into(arena, lt, eb, 96);
        gl = typeck_diag_append_lit(gb, 0, 96, "null", 4);
        driver_diagnostic_typeck_assign_mismatch(compound_flag, line, col, eb, el, gb, gl);
        return -1;
      }
    }
    rt = expr_type_ref(arena, right_ref);
    if (!ast.ref_is_null(lt) && !ast.ref_is_null(rt) && !type_refs_equal(arena, lt, rt)) {
      lt_kind = pipeline_type_kind_ord_at(arena, lt);
      let rt_kind_assign: i32 = pipeline_type_kind_ord_at(arena, rt);
      /* wave313: refs path so NAMED i8/i16/u16 assign widen is accepted. */
      if (typeck_integer_widen_ok_refs(arena, lt, rt)) {
        pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
        rt = lt;
      } else if (typeck_float_widen_ok(lt_kind, rt_kind_assign)) {
        /* wave314: f32→f64 assign accepted; do not stamp RHS (emit needs cvtss2sd). */
        /* leave rt as f32 so store path can promote. */
      }
    }
    if (!ast.ref_is_null(lt) && !ast.ref_is_null(rt) && !type_refs_equal(arena, lt, rt)) {
      rhs_kind = pipeline_expr_kind_ord_at(arena, right_ref);
      if (rhs_kind == ord_ternary) {
        lt_kind = pipeline_type_kind_ord_at(arena, lt);
        if (lt_kind == ord_u8) {
          then_r = pipeline_expr_if_then_ref_at(arena, right_ref);
          else_r = pipeline_expr_if_else_ref_at(arena, right_ref);
          if (pipeline_expr_kind_ord_at(arena, then_r) == ord_lit &&
          pipeline_expr_kind_ord_at(arena, else_r) == ord_lit) {
            int_val = pipeline_expr_int_val_at(arena, then_r);
            ev = pipeline_expr_int_val_at(arena, else_r);
            if (int_val >= 0 && int_val <= 255 && ev >= 0 && ev <= 255) {
              pipeline_expr_set_resolved_type_ref(arena, then_r, lt);
              pipeline_expr_set_resolved_type_ref(arena, else_r, lt);
              pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
              rt = lt;
            }
          }
        }
      }
    }
    if (!ast.ref_is_null(lt) && ast.ref_is_null(rt)) {
      rhs_kind = pipeline_expr_kind_ord_at(arena, right_ref);
      if (rhs_kind == ord_call) {
        pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
        rt = lt;
      }
/** See implementation for details. */
      if (rhs_kind == ord_string_lit) {
        pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
        rt = lt;
      }
/** See implementation for details. */
      if (rhs_kind == ord_field) {
        lt_kind = pipeline_type_kind_ord_at(arena, lt);
        if (typeck_coerce_init_enum_field_to_decl(module, arena, right_ref, lt, lt_kind, rhs_kind) != 0) {
          rt = expr_type_ref(arena, right_ref);
        }
      }
    }
    if (ast.ref_is_null(lt) && !ast.ref_is_null(rt)) {
      lhs_kind = pipeline_expr_kind_ord_at(arena, left_ref);
      if (lhs_kind == ord_var || lhs_kind == ord_field || lhs_kind == ord_index) {
        pipeline_expr_set_resolved_type_ref(arena, left_ref, rt);
        lt = rt;
      }
    }
    /*
     * wave643: *T +=/-= integer offset — accept without requiring lt==rt and
     * without stamping RHS to *T. Reject *T += *U (would type_refs_equal if
     * rhs_ctx stayed *T) and *T += float/struct etc. G.7 ≡ wave285 ptr±int.
     */
    if (compound_flag != 0 && !ast.ref_is_null(lt) && !ast.ref_is_null(rt)
    && (expr_kind == ord_add_assign || expr_kind == ord_sub_assign)) {
      lt_kind = pipeline_type_kind_ord_at(arena, lt);
      if (lt_kind == ord_ptr) {
        let rt_kind_pca: i32 = pipeline_type_kind_ord_at(arena, rt);
        if (rt_kind_pca == ord_i32 || rt_kind_pca == ord_usize || rt_kind_pca == ord_isize
        || rt_kind_pca == ord_u8 || rt_kind_pca == ord_u32 || rt_kind_pca == ord_u64
        || rt_kind_pca == ord_i64) {
          ptr_compound_offset_ok = 1;
        } else {
          eb = driver_typeck_diag_scratch_expect();
          gb = driver_typeck_diag_scratch_found();
          el = typeck_diag_fmt_type_into(arena, lt, eb, 96);
          gl = typeck_diag_fmt_type_into(arena, rt, gb, 96);
          driver_diagnostic_typeck_assign_mismatch(compound_flag, line, col, eb, el, gb, gl);
          return - 1;
        }
      }
    }
    if (!ast.ref_is_null(lt) && !ast.ref_is_null(rt)) {
      if (!type_refs_equal(arena, lt, rt) && ptr_compound_offset_ok == 0) {
        lt_kind = pipeline_type_kind_ord_at(arena, lt);
        let rt_kind_mis: i32 = pipeline_type_kind_ord_at(arena, rt);
        /* wave314: f32→f64 is not a mismatch (emit promotes with cvtss2sd). */
        if (!typeck_float_widen_ok(lt_kind, rt_kind_mis)) {
          eb = driver_typeck_diag_scratch_expect();
          gb = driver_typeck_diag_scratch_found();
          el = typeck_diag_fmt_type_into(arena, lt, eb, 96);
          gl = typeck_diag_fmt_type_into(arena, rt, gb, 96);
          driver_diagnostic_typeck_assign_mismatch(compound_flag, line, col, eb, el, gb, gl);
          return - 1;
        }
      }
      /* See implementation. */
      if (ptr_compound_offset_ok == 0
      && pipeline_typeck_check_slice_region_assign_c(arena, expr_ref, lt, rt) != 0) {
        return - 1;
      }
    }
    if (!ast.ref_is_null(lt) && ast.ref_is_null(rt)) {
      rhs_kind = pipeline_expr_kind_ord_at(arena, right_ref);
      if (rhs_kind == ord_sub || rhs_kind == ord_add) {
        lt_kind = pipeline_type_kind_ord_at(arena, lt);
        if (lt_kind == ord_usize) {
          pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
          rt = lt;
        }
      }
    }
    eb = driver_typeck_diag_scratch_expect();
    gb = driver_typeck_diag_scratch_found();
    if (ast.ref_is_null(lt) && !ast.ref_is_null(rt)) {
      el = typeck_diag_fmt_type_or_question(arena, lt, eb);
      gl = typeck_diag_fmt_type_or_question(arena, rt, gb);
      driver_diagnostic_typeck_assign_mismatch(compound_flag, line, col, eb, el, gb, gl);
      return - 1;
    }
    if (!ast.ref_is_null(lt) && ast.ref_is_null(rt)) {
      el = typeck_diag_fmt_type_or_question(arena, lt, eb);
      gl = typeck_diag_fmt_type_or_question(arena, rt, gb);
      driver_diagnostic_typeck_assign_mismatch(compound_flag, line, col, eb, el, gb, gl);
      return - 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function typeck_check_expr_return(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_void: i32 = 16;
    let ord_lit: i32 = 0;
    let ord_as: i32 = 54;
    let ord_u32: i32 = 3;
    let ord_u64: i32 = 4;
    let ord_i64: i32 = 5;
    let ord_usize: i32 = 6;
    let ord_ptr: i32 = 9;
    let op_ref: i32 = 0;
    let line: i32 = 0;
    let col: i32 = 0;
    let rt_kind: i32 = 0;
    let op_kind: i32 = 0;
    let int_val: i32 = 0;
    let as_tgt: i32 = 0;
    let got: i32 = 0;
    let eb: *u8 = 0 as *u8;
    let gb: *u8 = 0 as *u8;
    let el: i32 = 0;
    let gl: i32 = 0;
    if (arena == 0 as *ASTArena || expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    line = pipeline_expr_line_at(arena, expr_ref);
    col = pipeline_expr_col_at(arena, expr_ref);
    if (ast.ref_is_null(op_ref)) {
      if (!ast.ref_is_null(return_type_ref)) {
        rt_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
        if (rt_kind != ord_void) {
          driver_diagnostic_typeck_ret_fail(1, expr_ref, return_type_ref, 0);
          return - 1;
        }
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref);
      }
      return 0;
    }
    if (!ast.ref_is_null(return_type_ref)) {
      rt_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
      if (rt_kind == ord_void) {
        got = expr_type_ref(arena, op_ref);
        driver_diagnostic_typeck_ret_fail(2, op_ref, return_type_ref, got);
        return - 1;
      }
    }
    /* See implementation. */
    typeck_ret_fixup_unresolved_call(module, arena, op_ref, ctx);
    if (check_expr(module, arena, op_ref, return_type_ref, ctx) != 0) {
      if (ast.ref_is_null(expr_type_ref(arena, op_ref))) {
        typeck_emit_return_unresolved_breadcrumb(arena, op_ref, line, col);
      } else {
        typeck_emit_return_subexpr_breadcrumb(arena, op_ref, line, col);
      }
      driver_diagnostic_typeck_ret_fail(1, op_ref, return_type_ref, 0);
      return - 1;
    }
    typeck_ret_coerce_null_lit_to_expect(arena, op_ref, return_type_ref);
    /* See implementation. */
    if (!ast.ref_is_null(op_ref) && !ast.ref_is_null(return_type_ref)) {
      let rk_ret: i32 = pipeline_type_kind_ord_at(arena, return_type_ref);
      let ok_ret: i32 = pipeline_expr_kind_ord_at(arena, op_ref);
      /*
       * wave318: return bare int lit → f32/f64 (and other lit targets).
       * let/assign already call typeck_coerce_init_lit_to_decl; return only had
       * float_lit (wave316) + a partial hand-written i64/u32/u64/ptr0 path →
       * `function f(): f32 { return 6; }` reported expected f32 found i32.
       * wave319: return EXPR_NEG / int binop → f32/f64 — G.7 reuse
       * typeck_coerce_init_int_binop_to_decl (let/assign already call it).
       * PLATFORM: SHARED — seed typeck_gen + empty_surface + pipeline_glue twin.
       */
      typeck_coerce_init_lit_to_decl(arena, op_ref, return_type_ref, rk_ret, ok_ret);
      /* wave316: return float lit / `-float` to f32/f64 (G.7 reuse float_lit coerce). */
      typeck_coerce_init_float_lit_to_decl(arena, op_ref, return_type_ref, rk_ret, ok_ret);
      /* wave319: return `-6` / `1-7` int tree to f32/f64 (G.7 reuse int_binop). */
      typeck_coerce_init_int_binop_to_decl(arena, op_ref, return_type_ref, rk_ret, ok_ret);
      if (typeck_coerce_init_enum_field_to_decl(module, arena, op_ref, return_type_ref, rk_ret, ok_ret) != 0) {
        /* stamped */
      }
      /*
       * wave670: keyword `null` only valid when function returns TYPE_PTR.
       * Bare INT 0 still widens to i64/u32/u64 below.
       */
      if (typeck_expr_is_null_keyword(arena, op_ref) != 0 && rk_ret != 9) {
        got = expr_type_ref(arena, op_ref);
        driver_diagnostic_typeck_ret_fail(2, op_ref, return_type_ref, got);
        return -1;
      }
    }
    if (!ast.ref_is_null(op_ref) && !ast.ref_is_null(return_type_ref)) {
      op_kind = pipeline_expr_kind_ord_at(arena, op_ref);
      if (op_kind == ord_lit) {
        rt_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
        /* wave670: never widen keyword null via i64/unsigned lit path. */
        if (typeck_expr_is_null_keyword(arena, op_ref) == 0) {
          if (rt_kind == ord_i64) {
            pipeline_expr_set_resolved_type_ref(arena, op_ref, return_type_ref);
          } else {
            int_val = pipeline_expr_int_val_at(arena, op_ref);
            if (int_val == 0 && rt_kind == ord_ptr) {
              pipeline_expr_set_resolved_type_ref(arena, op_ref, return_type_ref);
            } else if (int_val >= 0) {
              if (rt_kind == ord_usize || rt_kind == ord_u32 || rt_kind == ord_u64) {
                pipeline_expr_set_resolved_type_ref(arena, op_ref, return_type_ref);
              }
            }
          }
        } else if (rt_kind == ord_ptr) {
          pipeline_expr_set_resolved_type_ref(arena, op_ref, return_type_ref);
        }
      }
    }
    if (!ast.ref_is_null(op_ref) && !ast.ref_is_null(return_type_ref)) {
      /*
       * wave333 Cap residual pure: return ARRAY_LIT → TYPE_SLICE / TYPE_ARRAY / VECTOR.
       * Prior: only TYPE_ARRAY + hand-written VECTOR lanes; `return [1,2,3]: i32[]`
       * found ?. G.7: reuse typeck_coerce_init_array_vector_lit_to_decl (let wave328 /
       * assign wave331). PLATFORM: SHARED — seed typeck_gen + glue return_c twin.
       */
      let crc_arr: i32 = 0;
      op_kind = pipeline_expr_kind_ord_at(arena, op_ref);
      rt_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
      crc_arr = typeck_coerce_init_array_vector_lit_to_decl(arena, op_ref, return_type_ref, rt_kind,
      op_kind);
      if (crc_arr < 0) {
        return - 1;
      }
    }
    if (!ast.ref_is_null(op_ref) && !ast.ref_is_null(return_type_ref)) {
      op_kind = pipeline_expr_kind_ord_at(arena, op_ref);
      if (op_kind == ord_as) {
        as_tgt = pipeline_expr_as_target_type_ref_at(arena, op_ref);
        if (!ast.ref_is_null(as_tgt) && type_refs_equal(arena, as_tgt, return_type_ref)) {
          pipeline_expr_set_resolved_type_ref(arena, op_ref, as_tgt);
        }
      }
    }
    if (!ast.ref_is_null(return_type_ref) && !ast.ref_is_null(op_ref)) {
      let expect_kind: i32 = 0;
      let got_kind: i32 = 0;
      /* See implementation. */
      if (pipeline_typeck_check_return_slice_region_in_scope_c(arena, expr_ref, return_type_ref, ctx) != 0) {
        return - 1;
      }
      typeck_ret_coerce_integral_to_expect_i32(arena, op_ref, return_type_ref);
      typeck_ret_coerce_integral_widen(arena, op_ref, return_type_ref);
      got = expr_type_ref(arena, op_ref);
      if (!typeck_return_operand_matches(arena, op_ref, return_type_ref)) {
        /* See implementation. */
        if (!ast.ref_is_null(got) && got > 0 && !ast.ref_is_null(return_type_ref)) {
          expect_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
          got_kind = pipeline_type_kind_ord_at(arena, got);
          if (typeck_integer_widen_ok_refs(arena, return_type_ref, got) ||
              typeck_float_widen_ok(expect_kind, got_kind)) {
            pipeline_expr_set_resolved_type_ref(arena, op_ref, return_type_ref);
            if (pipeline_typeck_check_return_slice_region_c(arena, expr_ref, op_ref, return_type_ref) != 0) {
              return - 1;
            }
            return 0;
          }
        }
        eb = driver_typeck_diag_scratch_expect();
        gb = driver_typeck_diag_scratch_found();
        el = typeck_diag_fmt_type_or_question(arena, return_type_ref, eb);
        gl = typeck_diag_fmt_type_or_question(arena, got, gb);
        driver_diagnostic_typeck_return_mismatch(line, col, eb, el, gb, gl);
        typeck_emit_return_subexpr_breadcrumb(arena, op_ref, line, col);
        driver_diagnostic_typeck_ret_fail(2, op_ref, return_type_ref, got);
        return - 1;
      }
      /* See implementation. */
      if (pipeline_typeck_check_return_slice_region_c(arena, expr_ref, op_ref, return_type_ref) != 0) {
        return - 1;
      }
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function typeck_check_expr_panic(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let op_ref: i32 = 0;
    if (arena == 0 as *ASTArena || expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    if (check_expr(module, arena, op_ref, return_type_ref, ctx) != 0) {
      return - 1;
    }
    if (!ast.ref_is_null(return_type_ref)) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref);
    }
    return 0;
  }
}

/**
* See implementation.
*/
export function typeck_check_expr_match_arm(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, arm_i: i32, num_arms: i32, line: i32, col: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let is_enum: i32 = 0;
    let var_ix: i32 = 0;
    let arm_res: i32 = 0;
    let guard_ref: i32 = 0;
    let bool_ty: i32 = 0;
    if (arm_i >= num_arms) {
      return 0;
    }
    is_enum = pipeline_expr_match_arm_is_enum_variant(arena, expr_ref, arm_i);
    if (is_enum != 0) {
      var_ix = pipeline_expr_match_arm_variant_index(arena, expr_ref, arm_i);
      if (var_ix < 0) {
        driver_diagnostic_typeck_enum_no_variant(line, col);
        return - 1;
      }
    }
    /* wave700: typecheck optional guard as bool ambient. */
    guard_ref = pipeline_expr_match_arm_guard_ref(arena, expr_ref, arm_i);
    if (!ast.ref_is_null(guard_ref) && guard_ref > 0) {
      bool_ty = ensure_bool_type_ref(arena);
      if (check_expr(module, arena, guard_ref, bool_ty, ctx) != 0) {
        return - 1;
      }
    }
    arm_res = pipeline_expr_match_arm_result_ref(arena, expr_ref, arm_i);
    if (check_expr(module, arena, arm_res, return_type_ref, ctx) != 0) {
      return - 1;
    }
    return typeck_check_expr_match_arm(module, arena, expr_ref, return_type_ref, ctx, arm_i + 1,
    num_arms, line, col);
  }
}

/**
* See implementation.
*/
export function typeck_check_expr_match(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let matched_ref: i32 = pipeline_expr_match_matched_ref_at(arena, expr_ref);
    let num_arms: i32 = pipeline_expr_match_num_arms_at(arena, expr_ref);
    let line: i32 = pipeline_expr_line_at(arena, expr_ref);
    let col: i32 = pipeline_expr_col_at(arena, expr_ref);
    if (check_expr(module, arena, matched_ref, return_type_ref, ctx) != 0) {
      return - 1;
    }
    if (typeck_check_expr_match_arm(module, arena, expr_ref, return_type_ref, ctx, 0, num_arms, line,
    col) != 0) {
      return - 1;
    }
    if (!ast.ref_is_null(return_type_ref)) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref);
    }
    return 0;
  }
}

/**
* See implementation.
*/
export function typeck_check_expr_call_arg(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, arg_i: i32, num_args: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let arg_ref: i32 = 0;
    if (arg_i >= num_args) {
      return 0;
    }
    arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, arg_i);
    if (check_expr(module, arena, arg_ref, return_type_ref, ctx) != 0) {
      return - 1;
    }
    return typeck_check_expr_call_arg(module, arena, expr_ref, return_type_ref, ctx, arg_i + 1,
    num_args);
  }
}

/**
* See implementation.
*/
export function typeck_check_expr_call_resolve(module: *Module, arena: *ASTArena, expr_ref: i32,
ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_addr_of: i32 = 51;
    let ord_var: i32 = 3;
    /* See implementation. */
    let minus_one: i32 = -1;
    let callee_ref: i32 = 0;
    let callee_eff: i32 = 0;
    let inner_c: i32 = 0;
    let ret_ty: i32 = 0;
    let cnml: i32 = 0;
    let cnm: u8[128] = [];
    callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    if (ast.ref_is_null(callee_ref)) {
      return 0;
    }
    callee_eff = callee_ref;
    if (pipeline_expr_kind_ord_at(arena, callee_eff) == ord_addr_of) {
      inner_c = pipeline_expr_unary_operand_ref_at(arena, callee_eff);
      if (!ast.ref_is_null(inner_c)) {
        callee_eff = inner_c;
      }
    }
    /* See implementation. */
    cnml = 0;
    if (pipeline_expr_kind_ord_at(arena, callee_eff) == ord_var) {
      cnml = pipeline_expr_var_name_len(arena, callee_eff);
      if (cnml > 0) {
        pipeline_expr_var_name_into(arena, callee_eff, &cnm[0]);
      }
    }
    ret_ty = resolve_call_callee_return_type(module, arena, callee_eff, expr_ref, ctx);
    if (ret_ty == 0 && cnml > 0) {
      typeck_i32_ptr_store(typeck_call_resolve_func_idx_slot(), 0);
      ret_ty = find_func_return_type_in_module_by_name(module, arena, &cnm[0], cnml, minus_one, ctx,
      typeck_call_resolve_func_idx_slot());
      if (ret_ty != 0) {
        ast.ast_expr_apply_call_resolve(arena, expr_ref, minus_one, typeck_call_resolve_func_idx_peek());
      }
    }
    /* See implementation. */
    if (cnml > 0 && pipeline_typeck_is_read_ptr_slice_callee_c(&cnm[0], cnml) != 0) {
      ret_ty = pipeline_typeck_read_ptr_slice_return_ref_c(arena);
    }
    if (ret_ty != 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, ret_ty);
    }
    return 0;
  }
}

/**
 * Hard-fail free-function CALL when argument count ≠ resolved (or name-matched) arity,
 * or when a bare VAR callee name resolves to no function at all.
 * wave660 Cap residual: overload pick used to bind first same-name func ignoring arity
 * → typeck OK then host-cc BLD001. Also covers pure miss after first_idx gate.
 * wave675 Cap residual: unresolved bare VAR callee (name_hits==0) was soft-skipped →
 * host BLD001 undeclared function (typos, silent parse-drop of bad formals + call).
 * Soft-skip: non-VAR callee (fn ptr / method path), special read_ptr_slice intrinsics.
 * @param module *Module — entry / local module
 * @param arena *ASTArena
 * @param expr_ref i32 — EXPR_CALL
 * @param ctx *PipelineDepCtx — for dep module when resolved_dep_index ≥ 0
 * @return i32 — 0 ok, -1 arity mismatch or unresolved (diagnostic emitted)
 * PLATFORM: SHARED — G.7 single gate; product path also invoked from
 * pipeline_typeck_check_expr_call_c after resolve (seed typeck_check_expr_call delegates).
 */
export function typeck_check_call_arity(module: *Module, arena: *ASTArena, expr_ref: i32,
ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let num_args: i32 = 0;
    let fi: i32 = 0;
    let dep: i32 = 0;
    let mod: *Module = 0 as *Module;
    let dm: *Module = 0 as *Module;
    let np: i32 = 0;
    let line_a: i32 = 0;
    let col_a: i32 = 0;
    let callee_ref: i32 = 0;
    let callee_eff: i32 = 0;
    let ord_addr_of: i32 = 51;
    let ord_var: i32 = 3;
    let inner_c: i32 = 0;
    let cnml: i32 = 0;
    let cnm: u8[128] = [];
    let j: i32 = 0;
    let name_hits: i32 = 0;
    let arity_hits: i32 = 0;
    if (module == 0 as *Module || arena == 0 as *ASTArena || expr_ref <= 0) {
      return 0;
    }
    num_args = pipeline_expr_call_num_args_at(arena, expr_ref);
    fi = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
    dep = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
    if (fi >= 0) {
      mod = module;
      if (dep >= 0 && ctx != 0 as *PipelineDepCtx) {
        dm = pipeline_dep_ctx_module_at(ctx, dep);
        if (dm != 0 as *Module) {
          mod = dm;
        }
      }
      np = pipeline_module_func_num_params_at(mod, fi);
      if (np != num_args) {
        line_a = pipeline_expr_line_at(arena, expr_ref);
        col_a = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_call_arity_mismatch(line_a, col_a);
        return -1;
      }
      return 0;
    }
    /*
     * Unresolved CALL (fi < 0 after resolve):
     * - name exists locally but no nparams==num_args → arity T001 (wave660)
     * - bare VAR name has zero local hits → unresolved T001 (wave675)
     * Special read_ptr_slice callees stamp ret without fi → soft-skip.
     * Non-VAR callee (fn pointer / complex) → soft (not this hard leaf).
     * Dep-resolved calls set fi ≥ 0 above; import-only names without import stay red.
     */
    callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    if (ast.ref_is_null(callee_ref)) {
      return 0;
    }
    callee_eff = callee_ref;
    if (pipeline_expr_kind_ord_at(arena, callee_eff) == ord_addr_of) {
      inner_c = pipeline_expr_unary_operand_ref_at(arena, callee_eff);
      if (!ast.ref_is_null(inner_c)) {
        callee_eff = inner_c;
      }
    }
    if (pipeline_expr_kind_ord_at(arena, callee_eff) != ord_var) {
      return 0;
    }
    cnml = pipeline_expr_var_name_len(arena, callee_eff);
    if (cnml <= 0 || cnml > 127) {
      return 0;
    }
    pipeline_expr_var_name_into(arena, callee_eff, &cnm[0]);
    /* PLATFORM: SHARED — product intrinsics that type without module fi. */
    if (pipeline_typeck_is_read_ptr_slice_callee_c(&cnm[0], cnml) != 0) {
      return 0;
    }
    name_hits = 0;
    arity_hits = 0;
    j = 0;
    while (j < module.num_funcs) {
      if (pipeline_module_func_name_equal_at(module, j, &cnm[0], cnml) != 0) {
        name_hits = name_hits + 1;
        if (pipeline_module_func_num_params_at(module, j) == num_args) {
          arity_hits = arity_hits + 1;
        }
      }
      j = j + 1;
    }
    if (name_hits > 0 && arity_hits == 0) {
      line_a = pipeline_expr_line_at(arena, expr_ref);
      col_a = pipeline_expr_col_at(arena, expr_ref);
      driver_diagnostic_typeck_call_arity_mismatch(line_a, col_a);
      return -1;
    }
    /* wave675: completely unknown bare name → hard-fail (was BLD001 undeclared). */
    if (name_hits == 0) {
      line_a = pipeline_expr_line_at(arena, expr_ref);
      col_a = pipeline_expr_col_at(arena, expr_ref);
      driver_diagnostic_typeck_call_unresolved(line_a, col_a);
      return -1;
    }
    return 0;
  }
}

/**
 * Return 1 when TYPE_NAMED ty is a free type-param (name is not a module
 * struct layout or type alias). Mirrors glue
 * `pipeline_typeck_named_is_module_type_c` inverted — G.7 twin for typeck.x.
 * Used by call arg gate so formals `x: T` on `id&lt;T&gt;` accept concrete args.
 * @param module *Module — callee module (layouts / aliases)
 * @param arena *ASTArena
 * @param ty_ref i32 — candidate formal type_ref
 * @return i32 — 1 free type-param, 0 concrete/unknown/non-named
 * PLATFORM: SHARED typeck helper.
 */
export function typeck_type_is_free_type_param(module: *Module, arena: *ASTArena, ty_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let nm: u8[128] = [];
    let nlen: i32 = 0;
    let nsl: i32 = 0;
    let si: i32 = 0;
    let snlen: i32 = 0;
    let snm: *u8 = 0 as *u8;
    let n_alias: i32 = 0;
    let ai: i32 = 0;
    let alen: i32 = 0;
    let off: i32 = 0;
    let same: i32 = 0;
    if (module == 0 as *Module || arena == 0 as *ASTArena || ty_ref <= 0) {
      return 0;
    }
    /* TYPE_NAMED ord == 8 */
    if (pipeline_type_kind_ord_at(arena, ty_ref) != 8) {
      return 0;
    }
    nlen = pipeline_type_named_name_into(arena, ty_ref, &nm[0]);
    if (nlen <= 0 || nlen > 127) {
      return 0;
    }
    nsl = pipeline_module_num_struct_layouts_at(module);
    si = 0;
    while (si < nsl) {
      snlen = pipeline_module_struct_layout_name_len(module, si);
      if (snlen == nlen && snlen > 0) {
        snm = typeck_scratch64_slot(2);
        pipeline_module_struct_layout_name_into(module, si, snm);
        if (name_equal(snm, snlen, &nm[0], nlen)) {
          return 0;
        }
      }
      si = si + 1;
    }
    n_alias = pipeline_module_num_type_aliases_at(module);
    ai = 0;
    while (ai < n_alias) {
      alen = pipeline_module_type_alias_name_len(module, ai);
      if (alen == nlen && alen > 0 && alen <= 127) {
        same = 1;
        off = 0;
        while (off < alen) {
          if (pipeline_module_type_alias_name_byte_at(module, ai, off) != nm[off]) {
            same = 0;
            break;
          }
          off = off + 1;
        }
        if (same != 0) {
          return 0;
        }
      }
      ai = ai + 1;
    }
    return 1;
  }
}

/**
 * Return 1 when the type tree contains a free type-param (TYPE_NAMED not a
 * module struct/alias), walking PTR/SLICE/ARRAY/VECTOR elems and NAMED type-args.
 * Mirrors glue `glue_typeck_type_tree_has_free_param_c` for typeck.x pre-score.
 * @param module *Module
 * @param arena *ASTArena
 * @param ty_ref i32 — formal type tree root
 * @param depth i32 — recursion depth (cap 12)
 * @return i32 — 1 if free type-param found, else 0
 * PLATFORM: SHARED typeck helper (wave686).
 */
export function typeck_type_tree_has_free_type_param(module: *Module, arena: *ASTArena, ty_ref: i32,
depth: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let kind: i32 = 0;
    let elem: i32 = 0;
    let n_ta: i32 = 0;
    let i: i32 = 0;
    let ta: i32 = 0;
    let asz: i32 = 0;
    if (module == 0 as *Module || arena == 0 as *ASTArena || ty_ref <= 0 || depth > 12) {
      return 0;
    }
    if (typeck_type_is_free_type_param(module, arena, ty_ref) != 0) {
      return 1;
    }
    kind = pipeline_type_kind_ord_at(arena, ty_ref);
    /* TYPE_PTR=9, TYPE_ARRAY=10, TYPE_SLICE=11, TYPE_VECTOR=13 */
    if (kind == 9 || kind == 10 || kind == 11 || kind == 13) {
      elem = pipeline_type_elem_ref_at(arena, ty_ref);
      if (elem > 0) {
        return typeck_type_tree_has_free_type_param(module, arena, elem, depth + 1);
      }
      return 0;
    }
    /* TYPE_NAMED=8 module type — walk type-pos args if present. */
    if (kind == 8) {
      asz = pipeline_type_array_size_at(arena, ty_ref);
      if (asz > 0 && asz <= 8) {
        n_ta = asz;
      } else {
        n_ta = 0;
        i = 0;
        while (i < 8) {
          ta = pipeline_type_type_arg_ref_at(arena, ty_ref, i);
          if (ta <= 0) {
            break;
          }
          n_ta = i + 1;
          i = i + 1;
        }
      }
      i = 0;
      while (i < n_ta) {
        ta = pipeline_type_type_arg_ref_at(arena, ty_ref, i);
        if (ta <= 0 && i == 0) {
          ta = pipeline_type_elem_ref_at(arena, ty_ref);
        }
        if (ta > 0 && typeck_type_tree_has_free_type_param(module, arena, ta, depth + 1) != 0) {
          return 1;
        }
        i = i + 1;
      }
    }
    return 0;
  }
}

/**
 * wave686 Cap residual: structural match of a generic formal type against a
 * concrete arg type for call_arg pre-score accept.
 * Bare free type-param T matches any arg_ty. Compound formals *T / []T / T[N]
 * (and nested) match same-kind arg with recursive elem match; free leaf accepts
 * any concrete elem; ARRAY sizes must agree when both known.
 * Shape mirrors glue `glue_typeck_pattern_unify_bind_c` without building a map —
 * call_arg gate only needs accept/reject; mono bind stays in try_infer / fixup.
 * @param module *Module — callee module (free-param vs layout names)
 * @param arena *ASTArena — formal and arg types share caller arena for product calls
 * @param formal_ty i32 — formal type_ref (may contain free T)
 * @param arg_ty i32 — concrete arg resolved type_ref
 * @param depth i32 — recursion depth (cap 12)
 * @return i32 — 1 match, 0 no match
 * PLATFORM: SHARED typeck helper.
 */
export function typeck_generic_formal_matches_arg_type(module: *Module, arena: *ASTArena,
formal_ty: i32, arg_ty: i32, depth: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let fk: i32 = 0;
    let ak: i32 = 0;
    let felem: i32 = 0;
    let aelem: i32 = 0;
    let fsz: i32 = 0;
    let asz: i32 = 0;
    let fnm: u8[128] = [];
    let anm: u8[128] = [];
    let fnlen: i32 = 0;
    let anlen: i32 = 0;
    let n_fta: i32 = 0;
    let n_ata: i32 = 0;
    let i: i32 = 0;
    let fta: i32 = 0;
    let ata: i32 = 0;
    if (module == 0 as *Module || arena == 0 as *ASTArena || formal_ty <= 0 || arg_ty <= 0
    || depth > 12) {
      return 0;
    }
    /* Free type-param leaf: accepts any concrete arg type. */
    if (typeck_type_is_free_type_param(module, arena, formal_ty) != 0) {
      return 1;
    }
    if (pipeline_typeck_type_refs_equal_c(arena, formal_ty, arg_ty) != 0) {
      return 1;
    }
    fk = pipeline_type_kind_ord_at(arena, formal_ty);
    ak = pipeline_type_kind_ord_at(arena, arg_ty);
    if (fk < 0 || ak < 0) {
      return 0;
    }
    /* Module TYPE_NAMED: same name + pairwise type-args (Wrap<T> vs Wrap<i32>). */
    if (fk == 8) {
      if (ak != 8) {
        return 0;
      }
      fnlen = pipeline_type_named_name_into(arena, formal_ty, &fnm[0]);
      anlen = pipeline_type_named_name_into(arena, arg_ty, &anm[0]);
      if (fnlen <= 0 || anlen <= 0 || !name_equal(&fnm[0], fnlen, &anm[0], anlen)) {
        return 0;
      }
      asz = pipeline_type_array_size_at(arena, formal_ty);
      if (asz > 0 && asz <= 8) {
        n_fta = asz;
      } else {
        n_fta = 0;
        i = 0;
        while (i < 8) {
          if (pipeline_type_type_arg_ref_at(arena, formal_ty, i) <= 0) {
            break;
          }
          n_fta = i + 1;
          i = i + 1;
        }
      }
      if (n_fta <= 0) {
        return 1;
      }
      asz = pipeline_type_array_size_at(arena, arg_ty);
      if (asz > 0 && asz <= 8) {
        n_ata = asz;
      } else {
        n_ata = 0;
        i = 0;
        while (i < 8) {
          if (pipeline_type_type_arg_ref_at(arena, arg_ty, i) <= 0) {
            break;
          }
          n_ata = i + 1;
          i = i + 1;
        }
      }
      if (n_ata <= 0) {
        aelem = pipeline_type_elem_ref_at(arena, arg_ty);
        if (aelem > 0) {
          n_ata = 1;
        }
      }
      if (n_ata < n_fta) {
        return 0;
      }
      i = 0;
      while (i < n_fta) {
        fta = pipeline_type_type_arg_ref_at(arena, formal_ty, i);
        if (fta <= 0 && i == 0) {
          fta = pipeline_type_elem_ref_at(arena, formal_ty);
        }
        ata = pipeline_type_type_arg_ref_at(arena, arg_ty, i);
        if (ata <= 0 && i == 0) {
          ata = pipeline_type_elem_ref_at(arena, arg_ty);
        }
        if (fta <= 0 || ata <= 0) {
          return 0;
        }
        if (typeck_generic_formal_matches_arg_type(module, arena, fta, ata, depth + 1) == 0) {
          return 0;
        }
        i = i + 1;
      }
      return 1;
    }
    /* Compound: PTR / ARRAY / SLICE / VECTOR — same kind + elem recurse. */
    if (fk == 9 || fk == 10 || fk == 11 || fk == 13) {
      if (ak != fk) {
        return 0;
      }
      felem = pipeline_type_elem_ref_at(arena, formal_ty);
      aelem = pipeline_type_elem_ref_at(arena, arg_ty);
      if (felem <= 0 || aelem <= 0) {
        return 0;
      }
      if (fk == 10 || fk == 13) {
        fsz = pipeline_type_array_size_at(arena, formal_ty);
        asz = pipeline_type_array_size_at(arena, arg_ty);
        if (fsz > 0 && asz > 0 && fsz != asz) {
          return 0;
        }
      }
      return typeck_generic_formal_matches_arg_type(module, arena, felem, aelem, depth + 1);
    }
    /* Builtin formal without free tree: kinds must agree. */
    if (fk == ak) {
      return 1;
    }
    return 0;
  }
}

/**
 * Hard-fail free-function CALL when an arg does not match the formal param.
 * wave661 Cap residual: after resolve+arity, typeck never scored arg vs param → host-cc
 * BLD001 (*u8/struct→i32) or silent C conversion false-green (f32/bool→i32).
 * wave673 Cap residual: score&lt;0 with unknown arg_ty (arg_ty&lt;=0) was soft-skipped →
 * host BLD001 false-green (e.g. f(s.nope), f(g(1)) when g unresolved). Hard-fail any
 * score miss when the formal is known; soft-skip only untyped formals (param_raw&lt;=0).
 * wave685 Cap residual: free type-param formals (`x: T` on `id&lt;T&gt;`) score as
 * TYPE_NAMED vs scalar/lit → -1 false-red (`id(42)` / `id&lt;i32&gt;(42)` / `id(n:i32)`).
 * Same-kind NAMED already weak-scored 1 (struct→T greens). Accept free type-param
 * formals for any present arg; same-name unify stays in try_infer (same(1,true) red).
 * wave686 Cap residual: compound free formals `*T` / `[]T` / `T[N]` still score-reject
 * concrete `*i32` / `i32[]` / `i32[N]` (elem equal fails on free T). Pre-score accept via
 * `typeck_generic_formal_matches_arg_type` when formal tree has free type-param (G.7 twin
 * of glue pattern-unify shape; not a second score matcher).
 * Authority score: typeck_overload_arg_param_score (exact / int-lit / string-lit / widen /
 * array→slice / null→*T); free-T is a pre-score accept, not a second matcher.
 * @param module *Module — entry / local module
 * @param arena *ASTArena
 * @param expr_ref i32 — EXPR_CALL
 * @param ctx *PipelineDepCtx — dep module when resolved_dep_index ≥ 0
 * @return i32 — 0 ok, -1 type mismatch (diagnostic emitted)
 * PLATFORM: SHARED — G.7 single gate; product path also from pipeline_typeck_check_expr_call_c.
 */
export function typeck_check_call_arg_types(module: *Module, arena: *ASTArena, expr_ref: i32,
ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let num_args: i32 = 0;
    let fi: i32 = 0;
    let dep: i32 = 0;
    let mod: *Module = 0 as *Module;
    let dm: *Module = 0 as *Module;
    let ai: i32 = 0;
    let param_raw: i32 = 0;
    let sc: i32 = 0;
    let arg_ref: i32 = 0;
    let line_a: i32 = 0;
    let col_a: i32 = 0;
    let n_gp: i32 = 0;
    let arg_ty: i32 = 0;
    if (module == 0 as *Module || arena == 0 as *ASTArena || expr_ref <= 0) {
      return 0;
    }
    fi = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
    if (fi < 0) {
      return 0;
    }
    num_args = pipeline_expr_call_num_args_at(arena, expr_ref);
    dep = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
    mod = module;
    if (dep >= 0 && ctx != 0 as *PipelineDepCtx) {
      dm = pipeline_dep_ctx_module_at(ctx, dep);
      if (dm != 0 as *Module) {
        mod = dm;
      }
    }
    n_gp = pipeline_module_func_num_generic_params_at(mod, fi);
    ai = 0;
    while (ai < num_args) {
      param_raw = pipeline_module_func_param_type_ref_at(mod, fi, ai);
      /*
       * Soft-skip untyped / missing formal (param_raw<=0): score would return -1 and
       * false-red; leave soft residual (not this hard leaf).
       */
      if (param_raw > 0) {
        arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, ai);
        /*
         * wave670: hard-fail keyword `null`→non-ptr BEFORE score.
         * Root: ambient check_expr may stamp lit as i32; score then returns 1000
         * exact match and never hits the lit/is_null branch → call false green.
         * G.7: same gate as let/assign; only TYPE_PTR formals accept null.
         * Free type-param formals are not TYPE_PTR — null still hard-fails here
         * (mono may later bind T=*U only with a typed non-null arg).
         */
        if (arg_ref > 0 && typeck_expr_is_null_keyword(arena, arg_ref) != 0
        && pipeline_type_kind_ord_at(arena, param_raw) != 9) {
          line_a = pipeline_expr_line_at(arena, expr_ref);
          col_a = pipeline_expr_col_at(arena, expr_ref);
          driver_diagnostic_typeck_call_arg_type_mismatch(line_a, col_a);
          return -1;
        }
        /*
         * wave685: free type-param formal on a generic callee (`x: T`) accepts any
         * present arg. Score treats T as TYPE_NAMED and rejects i32/bool/lit
         * (only same-kind NAMED weak-matches). Do not open a second score path —
         * pre-score accept only; concrete formals still use score below.
         * Requires n_gp>0 so a user type named like a param is not mis-accepted
         * on non-generic callees.
         */
        if (n_gp > 0 && typeck_type_is_free_type_param(mod, arena, param_raw) != 0) {
          if (arg_ref <= 0) {
            line_a = pipeline_expr_line_at(arena, expr_ref);
            col_a = pipeline_expr_col_at(arena, expr_ref);
            driver_diagnostic_typeck_call_arg_type_mismatch(line_a, col_a);
            return -1;
          }
          ai = ai + 1;
          continue;
        }
        /*
         * wave686: compound free formals (*T / []T / T[N] / Wrap<T>) on generic
         * callees. Score requires elem type_refs_equal → free T vs i32 fails.
         * Pre-score structural match when formal tree has free type-param and arg
         * has a resolved type (lit alone cannot pin *T). Requires n_gp>0.
         */
        if (n_gp > 0 && arg_ref > 0) {
          arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
          if (arg_ty > 0
          && typeck_type_tree_has_free_type_param(mod, arena, param_raw, 0) != 0
          && typeck_generic_formal_matches_arg_type(mod, arena, param_raw, arg_ty, 0) != 0) {
            ai = ai + 1;
            continue;
          }
        }
        /*
         * Score covers known arg_ty + lit paths (int/string/null→*T) without requiring
         * a stamped type. wave673: any sc<0 is hard-fail when formal is known — do not
         * soft-skip unknown arg_ty (that left f(s.missing)/f(unresolved_call()) as BLD001).
         * Soft residual remains only param_raw<=0 (untyped formals) above.
         */
        sc = typeck_overload_arg_param_score(arena, expr_ref, ai, param_raw, dep, ctx);
        if (sc < 0) {
          /*
           * wave703 Cap residual: #[repr(compatible)] *PairA → *PairB when same
           * field shape. Score treats distinct TYPE_NAMED pointees as mismatch.
           * G.7: pipeline_typeck_call_arg_repr_compatible_ok_c (single layout gate).
           * PLATFORM: SHARED.
           */
          if (arg_ref > 0 && pipeline_typeck_call_arg_repr_compatible_ok_c(mod, arena, param_raw, arg_ref) != 0) {
            ai = ai + 1;
            continue;
          }
          line_a = pipeline_expr_line_at(arena, expr_ref);
          col_a = pipeline_expr_col_at(arena, expr_ref);
          driver_diagnostic_typeck_call_arg_type_mismatch(line_a, col_a);
          return -1;
        }
      }
      ai = ai + 1;
    }
    return 0;
  }
}

/**
 * Type-check EXPR_CALL: args, resolve, arity (wave660), arg types (wave661), slice region.
 * Installs expected return (return_type_ref from let/assign/return) for zero-arg overload pick.
 * Note: product seed typeck_check_expr_call may delegate to pipeline_typeck_check_expr_call_c
 * which must call typeck_check_call_arity + typeck_check_call_arg_types after resolve (same commit).
 */
export function typeck_check_expr_call(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    /* See implementation. */
    if (pipeline_typeck_check_extern_call_unsafe_boundary_c(module, arena, expr_ref, ctx) != 0) {
      return -1;
    }
    let num_args: i32 = pipeline_expr_call_num_args_at(arena, expr_ref);
    let expect_store: i32 = 0;
    if (!ast.ref_is_null(return_type_ref) && return_type_ref > 0) {
      expect_store = return_type_ref;
    }
    typeck_i32_ptr_store(typeck_overload_expected_ret_slot(), expect_store);
    if (typeck_check_expr_call_arg(module, arena, expr_ref, return_type_ref, ctx, 0, num_args) != 0) {
      typeck_i32_ptr_store(typeck_overload_expected_ret_slot(), 0);
      return -1;
    }
    if (typeck_check_expr_call_resolve(module, arena, expr_ref, ctx) != 0) {
      typeck_i32_ptr_store(typeck_overload_expected_ret_slot(), 0);
      return -1;
    }
    /* wave660: hard-fail arity before slice region / codegen. */
    if (typeck_check_call_arity(module, arena, expr_ref, ctx) != 0) {
      typeck_i32_ptr_store(typeck_overload_expected_ret_slot(), 0);
      return -1;
    }
    /* wave661: hard-fail arg type vs formal after resolve+arity. */
    if (typeck_check_call_arg_types(module, arena, expr_ref, ctx) != 0) {
      typeck_i32_ptr_store(typeck_overload_expected_ret_slot(), 0);
      return -1;
    }
    typeck_i32_ptr_store(typeck_overload_expected_ret_slot(), 0);
    /* See implementation. */
    if (pipeline_typeck_check_call_slice_region_c(module, arena, expr_ref, ctx) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * Return 1 if ty cannot be an operand of scalar comparison or non-vector arithmetic.
 * Aggregates: TYPE_ARRAY/SLICE/LINEAR/VECTOR (host-C invalid; array cmp decay pointer-identity
 * false green; struct/array arith host-cc BLD001), and TYPE_NAMED that matches a struct layout
 * (enum/alias scalars still allowed for cmp; VECTOR same-size arith is allowed by caller).
 * @param module *Module — current module (struct layout table)
 * @param arena *ASTArena — type arena
 * @param ty_ref i32 — resolved type ref of a binop operand
 * @return i32 — 1 aggregate / non-scalar-binop, 0 scalar/ptr/enum/alias-ok or null/unknown
 * PLATFORM: SHARED — wave657 cmp + wave658 arith + wave662 unary; G.7 single helper.
 */
export function typeck_type_is_aggregate_cmp_operand(module: *Module, arena: *ASTArena, ty_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_named: i32 = 8;
    let ord_array: i32 = 10;
    let ord_slice: i32 = 11;
    let ord_linear: i32 = 12;
    let ord_vector: i32 = 13;
    let ko: i32 = 0;
    let rty: i32 = 0;
    let nm: u8[128] = [];
    let nlen: i32 = 0;
    let nlayouts: i32 = 0;
    let k: i32 = 0;
    if (module == 0 as *Module || arena == 0 as *ASTArena || ast.ref_is_null(ty_ref)) {
      return 0;
    }
    /* Peel type aliases so `type MyI32 = i32` stays scalar-comparable. */
    rty = typeck_resolve_type_alias_ref_local(module, arena, ty_ref, 0);
    if (ast.ref_is_null(rty)) {
      rty = ty_ref;
    }
    ko = pipeline_type_kind_ord_at(arena, rty);
    if (ko == ord_array || ko == ord_slice || ko == ord_linear || ko == ord_vector) {
      return 1;
    }
    if (ko != ord_named) {
      return 0;
    }
    /* TYPE_NAMED: reject only when it is a product struct layout (enum tags stay ok). */
    nlen = pipeline_type_named_name_into(arena, rty, &nm[0]);
    if (nlen <= 0 || nlen > 127) {
      return 0;
    }
    nlayouts = pipeline_module_num_struct_layouts_at(module);
    k = 0;
    while (k < nlayouts) {
      if (typeck_layout_name_equal(module, k, &nm[0], nlen)) {
        return 1;
      }
      k = k + 1;
    }
    return 0;
  }
}

/**
 * Type-check comparison binops (== != < <= > >=). Stamps result as bool.
 * wave317: f32 peer + bare FLOAT_LIT coerce. wave657: hard-fail aggregate operands.
 * wave665: LOGAND/LOGOR require bool. wave666: mixed operand types hard-fail.
 * @param module *Module
 * @param arena *ASTArena
 * @param expr_ref i32 — EQ/NE/LT/LE/GT/GE expr
 * @param return_type_ref i32 — ambient return type for subexpr
 * @param ctx *PipelineDepCtx
 * @return i32 — 0 ok, -1 hard fail
 * PLATFORM: SHARED — seed typeck_gen + empty_surface same commit.
 */
export function typeck_check_expr_binop_cmp(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let bop_l: i32 = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    let bop_r: i32 = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    let bt: i32 = 0;
    let lt_cmp: i32 = 0;
    let rt_cmp: i32 = 0;
    let lko_cmp: i32 = 0;
    let rko_cmp: i32 = 0;
    let lk_cmp: i32 = 0;
    let rk_cmp: i32 = 0;
    let ord_lit: i32 = 0;
    let ord_f32: i32 = 14;
    let ord_logand: i32 = 20;
    let ord_logor: i32 = 21;
    let expr_kind_cmp: i32 = 0;
    let line_ac: i32 = 0;
    let col_ac: i32 = 0;
    let is_logical: i32 = 0;
    if (check_expr(module, arena, bop_l, return_type_ref, ctx) != 0) {
      return - 1;
    }
    if (check_expr(module, arena, bop_r, return_type_ref, ctx) != 0) {
      return - 1;
    }
    /*
     * wave670 Cap residual: keyword `null` only compares with pointers (or null).
     * Runs immediately after operand check_expr — before LOGAND/typed gates —
     * so untyped null (type_ref 0) still hard-fails against non-ptr peers.
     * `null == null` both keyword → green; `null == p` / `p == null` peer ptr.
     * PLATFORM: SHARED — seed typeck_gen same commit.
     */
    if (typeck_expr_is_null_keyword(arena, bop_l) != 0
    && typeck_expr_is_null_keyword(arena, bop_r) == 0) {
      rt_cmp = pipeline_expr_resolved_type_ref(arena, bop_r);
      rko_cmp = 0;
      if (rt_cmp > 0) {
        rko_cmp = pipeline_type_kind_ord_at(arena, rt_cmp);
      }
      if (rt_cmp > 0 && rko_cmp != 9) {
        line_ac = pipeline_expr_line_at(arena, expr_ref);
        col_ac = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_comparison_type_mismatch(line_ac, col_ac);
        return -1;
      }
    } else if (typeck_expr_is_null_keyword(arena, bop_r) != 0
    && typeck_expr_is_null_keyword(arena, bop_l) == 0) {
      lt_cmp = pipeline_expr_resolved_type_ref(arena, bop_l);
      lko_cmp = 0;
      if (lt_cmp > 0) {
        lko_cmp = pipeline_type_kind_ord_at(arena, lt_cmp);
      }
      if (lt_cmp > 0 && lko_cmp != 9) {
        line_ac = pipeline_expr_line_at(arena, expr_ref);
        col_ac = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_comparison_type_mismatch(line_ac, col_ac);
        return -1;
      }
    }
    expr_kind_cmp = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (expr_kind_cmp == ord_logand || expr_kind_cmp == ord_logor) {
      is_logical = 1;
    }
    lt_cmp = pipeline_expr_resolved_type_ref(arena, bop_l);
    rt_cmp = pipeline_expr_resolved_type_ref(arena, bop_r);
    /*
     * wave665 Cap residual: LOGAND/LOGOR operands must be TYPE_BOOL (docs/04).
     * Root cause: binop_cmp stamped bool for any operands → `i32 && i32` / `f32 && f32`
     * typeck OK then freestanding/host C truthiness false green; if/while/for already
     * require bool, but nested `a && b` bypassed that gate.
     * Soft: unknown/null operand type (incomplete resolve) is not a hard leaf.
     * G.7: reuse type_ref_is_bool; diag logical_operand_not_bool.
     * PLATFORM: SHARED — seed typeck_gen + empty_surface + diagnostic twin same commit.
     */
    if (is_logical != 0) {
      if (!ast.ref_is_null(lt_cmp) && lt_cmp > 0 && lt_cmp <= arena.num_types) {
        if (!type_ref_is_bool(arena, lt_cmp)) {
          line_ac = pipeline_expr_line_at(arena, expr_ref);
          col_ac = pipeline_expr_col_at(arena, expr_ref);
          driver_diagnostic_typeck_logical_operand_not_bool(line_ac, col_ac);
          return -1;
        }
      }
      if (!ast.ref_is_null(rt_cmp) && rt_cmp > 0 && rt_cmp <= arena.num_types) {
        if (!type_ref_is_bool(arena, rt_cmp)) {
          line_ac = pipeline_expr_line_at(arena, expr_ref);
          col_ac = pipeline_expr_col_at(arena, expr_ref);
          driver_diagnostic_typeck_logical_operand_not_bool(line_ac, col_ac);
          return -1;
        }
      }
      bt = ensure_bool_type_ref(arena);
      if (bt != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, bt);
      }
      return 0;
    }
    /* wave317: f32 peer + bare FLOAT_LIT / `-float` in cmp — G.7 reuse float_lit coerce
     * (same as binop_arith). Else `a:f32 < 6.0` keeps lit as f64 and freestanding/host
     * may mis-compare (Ubuntu while a<6.0 never entered). True f32 vs f64 vars unchanged. */
    if (!ast.ref_is_null(lt_cmp) && !ast.ref_is_null(rt_cmp)) {
      lko_cmp = pipeline_type_kind_ord_at(arena, lt_cmp);
      rko_cmp = pipeline_type_kind_ord_at(arena, rt_cmp);
      lk_cmp = pipeline_expr_kind_ord_at(arena, bop_l);
      rk_cmp = pipeline_expr_kind_ord_at(arena, bop_r);
      if (lko_cmp == ord_f32) {
        typeck_coerce_init_float_lit_to_decl(arena, bop_r, lt_cmp, ord_f32, rk_cmp);
      } else if (rko_cmp == ord_f32) {
        typeck_coerce_init_float_lit_to_decl(arena, bop_l, rt_cmp, ord_f32, lk_cmp);
      }
      /*
       * wave657 Cap residual: hard-fail aggregate ==/!=/relational at typeck.
       * Root cause: binop_cmp always stamped bool without checking operand kinds →
       * struct/slice `a == b` host-cc BLD001 (invalid C); fixed array `a == b` silent
       * pointer-identity false green (always unequal for distinct stack arrays).
       * Allowed: scalar ints/floats/bool, TYPE_PTR, TYPE_NAMED enum/alias-of-scalar.
       * Rejected: TYPE_ARRAY/SLICE/LINEAR/VECTOR; TYPE_NAMED matching a struct layout.
       * PLATFORM: SHARED — seed typeck_gen + empty_surface + diagnostic twin same commit.
       */
      if (typeck_type_is_aggregate_cmp_operand(module, arena, lt_cmp) != 0
      || typeck_type_is_aggregate_cmp_operand(module, arena, rt_cmp) != 0) {
        line_ac = pipeline_expr_line_at(arena, expr_ref);
        col_ac = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_invalid_aggregate_cmp(line_ac, col_ac);
        return -1;
      }
      /*
       * wave666 Cap residual: hard-fail mixed-type comparison at typeck.
       * Root cause: after aggregate gate, binop_cmp still stamped bool for any
       * remaining operands → `i32 == f32` / `i32 == i64` / `i32 == bool` /
       * `*i32 == *u8` typeck OK then freestanding/host C promotion false green
       * (or host warning-only for distinct pointer types).
       * Policy (strict, Cap residual): operands must be equal after peer lit coerce
       * (G.7 reuse typeck_coerce_init_lit_to_decl for bare INT_LIT / 0→ptr; float lit
       * already coerced above). No integer widen, no float widen, no int↔bool.
       * Soft: unknown/null operand type (incomplete resolve) is not a hard leaf.
       * G.7: type_refs_equal; diag comparison_type_mismatch.
       * PLATFORM: SHARED — seed typeck_gen + empty_surface + diagnostic twin same commit.
       */
      lt_cmp = pipeline_expr_resolved_type_ref(arena, bop_l);
      rt_cmp = pipeline_expr_resolved_type_ref(arena, bop_r);
      if (!ast.ref_is_null(lt_cmp) && !ast.ref_is_null(rt_cmp)) {
        lko_cmp = pipeline_type_kind_ord_at(arena, lt_cmp);
        rko_cmp = pipeline_type_kind_ord_at(arena, rt_cmp);
        lk_cmp = pipeline_expr_kind_ord_at(arena, bop_l);
        rk_cmp = pipeline_expr_kind_ord_at(arena, bop_r);
        /* Peer integer/0-null lit coerce so `a:i32 == 1` and `p:*T == 0` stay green. */
        if (rk_cmp == ord_lit && typeck_coerce_init_lit_to_decl(arena, bop_r, lt_cmp, lko_cmp, rk_cmp) != 0) {
          rt_cmp = pipeline_expr_resolved_type_ref(arena, bop_r);
        } else if (lk_cmp == ord_lit
        && typeck_coerce_init_lit_to_decl(arena, bop_l, rt_cmp, rko_cmp, lk_cmp) != 0) {
          lt_cmp = pipeline_expr_resolved_type_ref(arena, bop_l);
        }
        if (lt_cmp > 0 && rt_cmp > 0 && lt_cmp <= arena.num_types && rt_cmp <= arena.num_types) {
          if (!type_refs_equal(arena, lt_cmp, rt_cmp)) {
            line_ac = pipeline_expr_line_at(arena, expr_ref);
            col_ac = pipeline_expr_col_at(arena, expr_ref);
            driver_diagnostic_typeck_comparison_type_mismatch(line_ac, col_ac);
            return -1;
          }
        }
      }
    }
    bt = ensure_bool_type_ref(arena);
    if (bt != 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, bt);
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function typeck_check_expr_binop_arith(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_lit: i32 = 0;
    let bop_l: i32 = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    let bop_r: i32 = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    let expr_kind: i32 = pipeline_expr_kind_ord_at(arena, expr_ref);
    let lk_expr: i32 = 0;
    let rk_expr: i32 = 0;
    let lt_ar: i32 = 0;
    let rt_ar: i32 = 0;
    let lko: i32 = 0;
    let rko: i32 = 0;
    let out_ar: i32 = 0;
    let allow_i32_fallback: i32 = 0;
    let dbg_left: *u8 = 0 as *u8;
    let dbg_right: *u8 = 0 as *u8;
    let dbg_left_len: i32 = 0;
    let dbg_right_len: i32 = 0;
    let ord_type_vector: i32 = 13;
    let ord_i64: i32 = 5;
    let ord_f32: i32 = 14;
    let ord_f64: i32 = 15;
    let ord_void: i32 = 16;
    let ord_bool: i32 = 1;
    let ord_i32: i32 = 0;
    let ord_ptr: i32 = 9;
    let ord_u8: i32 = 2;
    let ord_u32: i32 = 3;
    let ord_u64: i32 = 4;
    let ord_usize: i32 = 6;
    let ord_isize: i32 = 7;
    let ord_add: i32 = 4;
    let ord_sub: i32 = 5;
    let ord_mod: i32 = 8;
    let ord_shl: i32 = 9;
    let ord_shr: i32 = 10;
    let ord_bitand: i32 = 11;
    let ord_bitor: i32 = 12;
    let ord_bitxor: i32 = 13;
    if (check_expr(module, arena, bop_l, return_type_ref, ctx) != 0) {
      return - 1;
    }
    if (check_expr(module, arena, bop_r, return_type_ref, ctx) != 0) {
      return - 1;
    }
    lt_ar = pipeline_expr_resolved_type_ref(arena, bop_l);
    rt_ar = pipeline_expr_resolved_type_ref(arena, bop_r);
    if (!ast.ref_is_null(lt_ar) && !ast.ref_is_null(rt_ar)) {
      lk_expr = pipeline_expr_kind_ord_at(arena, bop_l);
      rk_expr = pipeline_expr_kind_ord_at(arena, bop_r);
      dbg_left = driver_typeck_diag_scratch_expect();
      dbg_right = driver_typeck_diag_scratch_found();
      dbg_left_len = typeck_diag_fmt_type_or_question(arena, lt_ar, dbg_left);
      dbg_right_len = typeck_diag_fmt_type_or_question(arena, rt_ar, dbg_right);
      driver_diagnostic_typeck_binop_operands(expr_ref, bop_l, bop_r, lk_expr, rk_expr,
      pipeline_expr_block_ref_at(arena, bop_l), pipeline_expr_block_ref_at(arena, bop_r), lt_ar, rt_ar,
      dbg_left, dbg_left_len, dbg_right, dbg_right_len);
      lko = pipeline_type_kind_ord_at(arena, lt_ar);
      rko = pipeline_type_kind_ord_at(arena, rt_ar);
      /*
       * wave667 Cap residual: hard-fail void arithmetic at typeck.
       * Root cause: type_refs_equal / left-type / i32-fallback fallthrough stamped a
       * result type when either operand was TYPE_VOID (void call result + int, etc.)
       * → typeck OK then host-cc BLD001 `invalid operands to binary expression
       * ('void' and 'int')`. Soft residual after wave663 void-return gate.
       * Reject any + - * / % << >> & | ^ with a void operand. Soft: null/unknown
       * types (incomplete resolve) not hard-failed here.
       * G.7: driver_diagnostic_typeck_invalid_void_binop; unary -/~ void same diag.
       * PLATFORM: SHARED — seed typeck_gen + empty_surface + diagnostic twin same commit.
       */
      if (lko == ord_void || rko == ord_void) {
        let line_vb: i32 = pipeline_expr_line_at(arena, expr_ref);
        let col_vb: i32 = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_invalid_void_binop(line_vb, col_vb);
        return -1;
      }
      /*
       * wave677 Cap residual: hard-fail bool arithmetic / bitops / shifts at typeck.
       * Root cause: allow_i32_fallback rewrote bool operands to i32 (`true+false`,
       * `x<<true`, `true&false`) → freestanding/host false green; contradicts
       * wave671 (return bool→i32 hard) and LANG-006 scope (let/const only).
       * Soft: null/unknown types not hard-failed. G.7: invalid_bool_binop;
       * remove bool→i32 promotion block below.
       * PLATFORM: SHARED — seed typeck_gen + empty_surface + diagnostic twin same commit.
       */
      if (lko == ord_bool || rko == ord_bool) {
        let line_bb: i32 = pipeline_expr_line_at(arena, expr_ref);
        let col_bb: i32 = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_invalid_bool_binop(line_bb, col_bb);
        return -1;
      }
      /* Pointer ± integer is the only legal pointer arithmetic (C-like). */
      if (expr_kind == ord_add || expr_kind == ord_sub) {
        if (lko == ord_ptr && (rko == ord_i32 || rko == ord_usize || rko == ord_isize)) {
          out_ar = lt_ar;
        } else if (expr_kind == ord_add && rko == ord_ptr
        && (lko == ord_i32 || lko == ord_usize || lko == ord_isize)) {
          out_ar = rt_ar;
        }
      }
      /*
       * wave285 Cap residual: hard-fail illegal pointer arithmetic at typeck.
       * Root cause: type_refs_equal fallthrough accepted ptr+ptr / ptr*ptr / … and
       * codegen emitted invalid C → soft residual BLD001 (host-cc).
       * Allowed: ptr+int / int+ptr (ADD→ptr), ptr-int (SUB→ptr), ptr-ptr (SUB→isize).
       * Rejected: ptr+ptr (runtime *u8 string concat leave-off; use std.string or
       * adjacent string lits wave282), mul/div/mod/bitops with ptr, int-ptr, etc.
       * PLATFORM: SHARED — seed typeck_gen + empty_surface + ast_pool infer twin same commit.
       */
      if (lko == ord_ptr || rko == ord_ptr) {
        let line_pb: i32 = pipeline_expr_line_at(arena, expr_ref);
        let col_pb: i32 = pipeline_expr_col_at(arena, expr_ref);
        if (expr_kind == ord_add) {
          if (!ast.ref_is_null(out_ar)) {
            pipeline_expr_set_resolved_type_ref(arena, expr_ref, out_ar);
            return 0;
          }
          driver_diagnostic_typeck_invalid_ptr_binop(line_pb, col_pb);
          return -1;
        }
        if (expr_kind == ord_sub) {
          if (lko == ord_ptr && rko == ord_ptr) {
            /* Pointer difference yields isize (not a pointer). */
            out_ar = typeck_ensure_primitive_by_kind_ord(arena, ord_isize);
            pipeline_expr_set_resolved_type_ref(arena, expr_ref, out_ar);
            return 0;
          }
          if (!ast.ref_is_null(out_ar)) {
            pipeline_expr_set_resolved_type_ref(arena, expr_ref, out_ar);
            return 0;
          }
          driver_diagnostic_typeck_invalid_ptr_binop(line_pb, col_pb);
          return -1;
        }
        driver_diagnostic_typeck_invalid_ptr_binop(line_pb, col_pb);
        return -1;
      }
      /*
       * wave286 Cap residual: hard-fail illegal float bitwise / mod / shift at typeck.
       * Root cause: f32/f64 promotion applied to ANY binop (incl. & | ^ << >> %) and
       * codegen emitted invalid C (`double a & b`) → soft residual BLD001 (host-cc).
       * Allowed on float: + - * / only (ADD/SUB/MUL/DIV). Rejected: MOD, SHL, SHR,
       * BITAND, BITOR, BITXOR with either operand f32/f64 (incl. float << int).
       * PLATFORM: SHARED — seed typeck_gen + empty_surface + ast_pool infer twin same commit.
       */
      if (lko == ord_f32 || lko == ord_f64 || rko == ord_f32 || rko == ord_f64) {
        if (expr_kind == ord_mod || expr_kind == ord_shl || expr_kind == ord_shr
        || expr_kind == ord_bitand || expr_kind == ord_bitor || expr_kind == ord_bitxor) {
          let line_fb: i32 = pipeline_expr_line_at(arena, expr_ref);
          let col_fb: i32 = pipeline_expr_col_at(arena, expr_ref);
          driver_diagnostic_typeck_invalid_float_binop(line_fb, col_fb);
          return -1;
        }
      }
      /*
       * wave658 Cap residual: hard-fail aggregate + - * / % bitops/shifts at typeck.
       * Root cause: type_refs_equal fallthrough stamped out_ar = lt for struct/array/slice
       * → host-cc BLD001 (`invalid operands to binary expression`).
       * G.7 reuse typeck_type_is_aggregate_cmp_operand (wave657). VECTOR same-size pair
       * still allowed below (SIMD-style path). enum/alias/scalar/ptr paths unchanged.
       * PLATFORM: SHARED — seed typeck_gen + empty_surface + ast_pool twin same commit.
       */
      if ((typeck_type_is_aggregate_cmp_operand(module, arena, lt_ar) != 0
      || typeck_type_is_aggregate_cmp_operand(module, arena, rt_ar) != 0)
      && !(lko == ord_type_vector && rko == ord_type_vector)) {
        let line_aa: i32 = pipeline_expr_line_at(arena, expr_ref);
        let col_aa: i32 = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_invalid_aggregate_cmp(line_aa, col_aa);
        return -1;
      }
      if (ast.ref_is_null(out_ar)) {
        if ((lko == ord_i32 || lko == ord_u8 || lko == ord_u32 || lko == ord_u64 || lko == ord_i64
        || lko == ord_usize || lko == ord_isize)
        && (rko == ord_i32 || rko == ord_u8 || rko == ord_u32 || rko == ord_u64 || rko == ord_i64
        || rko == ord_usize || rko == ord_isize)) {
          if (expr_kind == ord_shl || expr_kind == ord_shr) {
            out_ar = lt_ar;
          } else if (expr_kind == ord_bitand || expr_kind == ord_bitor || expr_kind == ord_bitxor
          || expr_kind == ord_mod) {
            if (rk_expr == ord_lit && typeck_coerce_init_lit_to_decl(arena, bop_r, lt_ar, lko, rk_expr) != 0) {
              out_ar = lt_ar;
            } else if (lk_expr == ord_lit
            && typeck_coerce_init_lit_to_decl(arena, bop_l, rt_ar, rko, lk_expr) != 0) {
              out_ar = rt_ar;
            }
          }
        }
      }
      if (ast.ref_is_null(out_ar)) {
        if (lko == ord_type_vector && rko == ord_type_vector
        && pipeline_type_array_size_at(arena, lt_ar) == pipeline_type_array_size_at(arena, rt_ar)
        && type_refs_equal(arena, pipeline_type_elem_ref_at(arena, lt_ar),
        pipeline_type_elem_ref_at(arena, rt_ar))) {
          out_ar = lt_ar;
        } else if (lko == ord_i64 || rko == ord_i64) {
          out_ar = typeck_ensure_primitive_by_kind_ord(arena, ord_i64);
        } else if (lko == ord_f32
        && typeck_coerce_init_float_lit_to_decl(arena, bop_r, lt_ar, ord_f32, rk_expr) != 0) {
          /* wave317 Cap residual pure: f32 + bare FLOAT_LIT / `-float` stays f32.
           * Root: FLOAT_LIT defaults to f64 (typeck_check_expr_float_lit); wave296
           * usual-arith then widens f32+1.0 → f64 → assign/let `expected f32, found f64`.
           * G.7 reuse typeck_coerce_init_float_lit_to_decl (wave316 let/assign/return).
           * Must run before f64-before-f32 widen. True f32*f64 vars still widen below.
           * PLATFORM: SHARED — seed typeck_gen + empty_surface + ast_pool twin same commit. */
          out_ar = lt_ar;
        } else if (rko == ord_f32
        && typeck_coerce_init_float_lit_to_decl(arena, bop_l, rt_ar, ord_f32, lk_expr) != 0) {
          out_ar = rt_ar;
        } else if (lko == ord_f64 || rko == ord_f64) {
          /* wave296: usual arithmetic conversion — any f64 operand widens the binop to f64
           * (f32*f64 / f64*f32 must not resolve as f32; freestanding cast/mul need mulsd bits).
           * PLATFORM: SHARED — seed typeck_gen + empty_surface + ast_pool twin same commit. */
          out_ar = typeck_ensure_primitive_by_kind_ord(arena, ord_f64);
        } else if (lko == ord_f32 || rko == ord_f32) {
          out_ar = typeck_ensure_primitive_by_kind_ord(arena, ord_f32);
        } else if (type_refs_equal(arena, lt_ar, rt_ar)) {
          out_ar = lt_ar;
        } else if (typeck_integer_widen_ok_refs(arena, lt_ar, rt_ar)) {
          out_ar = lt_ar;
        } else if (typeck_integer_widen_ok_refs(arena, rt_ar, lt_ar)) {
          out_ar = rt_ar;
        } else if (lk_expr == ord_lit && rk_expr != ord_lit) {
          out_ar = rt_ar;
        } else if (rk_expr == ord_lit && lk_expr != ord_lit) {
          out_ar = lt_ar;
        } else if (!ast.ref_is_null(lt_ar)) {
          out_ar = lt_ar;
        } else if (!ast.ref_is_null(rt_ar)) {
          out_ar = rt_ar;
        }
      }
      if (expr_kind >= 4 && expr_kind <= 13) {
        allow_i32_fallback = 1;
      }
      if (ast.ref_is_null(out_ar) && lko != ord_type_vector && rko != ord_type_vector && allow_i32_fallback != 0) {
        out_ar = typeck_ensure_primitive_by_kind_ord(arena, ord_i32);
      }
      /* wave677: bool→i32 arith promotion removed (hard-fail above). LANG-006 let/const only. */
      if (!ast.ref_is_null(out_ar)) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, out_ar);
      }
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function typeck_check_expr_binop(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_eq: i32 = 14;
    let ord_ne: i32 = 15;
    let ord_lt: i32 = 16;
    let ord_le: i32 = 17;
    let ord_gt: i32 = 18;
    let ord_ge: i32 = 19;
    let ord_logand: i32 = 20;
    let ord_logor: i32 = 21;
    let expr_kind: i32 = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (expr_kind == ord_eq || expr_kind == ord_ne || expr_kind == ord_lt || expr_kind == ord_le
    || expr_kind == ord_gt || expr_kind == ord_ge || expr_kind == ord_logand || expr_kind == ord_logor) {
      return typeck_check_expr_binop_cmp(module, arena, expr_ref, return_type_ref, ctx);
    }
    return typeck_check_expr_binop_arith(module, arena, expr_ref, return_type_ref, ctx);
  }
}

/**
 * See implementation.
 */
export function typeck_check_expr_field_access(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    return pipeline_typeck_check_expr_field_access_c(module, arena, expr_ref, return_type_ref, ctx);
  }
}

/**
 * Type-check unary NEG / BITNOT / LOGNOT.
 * @param module *Module — module under check
 * @param arena *ASTArena — AST arena
 * @param expr_ref i32 — unary expr ref
 * @param return_type_ref i32 — enclosing function return type (passed to operand)
 * @param ctx *PipelineDepCtx — dep/typeck context
 * @return i32 — 0 ok, -1 hard fail
 * wave289 Cap residual: hard-fail illegal unary ~ on float/ptr and unary - on ptr.
 * wave662 Cap residual: hard-fail unary -/~/! on aggregates (struct/array/slice).
 * wave665 Cap residual: hard-fail LOGNOT on non-bool (docs/04: logical requires bool).
 * wave667 Cap residual: hard-fail unary -/~ on void (void call result).
 * wave677 Cap residual: hard-fail unary -/~ on bool (no implicit bool→int).
 * Root cause (wave289): copied operand type without host-cc validity → BLD001 on
 * `~double`, `~uint8_t*`, `-uint8_t*`.
 * Root cause (wave662): LOGNOT always stamped bool; NEG/BITNOT stamped aggregate
 * type → host-cc BLD001 (`-struct`, `~struct`, `!slice`) without T001.
 * Root cause (wave665): LOGNOT still stamped bool for any non-aggregate scalar
 * (`!i32`, `!f32`) → C truthiness false green; if/while already require bool.
 * Root cause (wave677): unary -true stamped bool then host/fs treated as int
 * false green; ~true fell to return mismatch. G.7: invalid_bool_binop.
 * Allowed: ~int, -int, -float, !bool (LOGNOT→bool). Rejected: ~f32/f64, ~ptr,
 * -ptr, -bool, ~bool, aggregate -/~/!, and non-bool LOGNOT operands.
 * PLATFORM: SHARED — seed typeck_gen + empty_surface same commit (G.7).
 */
export function typeck_check_expr_unary(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_neg: i32 = 22;
    let ord_bitnot: i32 = 23;
    let ord_lognot: i32 = 24;
    let ord_ptr: i32 = 9;
    let ord_f32: i32 = 14;
    let ord_f64: i32 = 15;
    let op_ref: i32 = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    let expr_kind: i32 = pipeline_expr_kind_ord_at(arena, expr_ref);
    let op_tr: i32 = 0;
    let bt: i32 = 0;
    let op_ko: i32 = 0;
    let line_u: i32 = 0;
    let col_u: i32 = 0;
    if (check_expr(module, arena, op_ref, return_type_ref, ctx) != 0) {
      return - 1;
    }
    op_tr = expr_type_ref(arena, op_ref);
    /*
     * wave662 Cap residual: hard-fail unary -/~/! on aggregates at typeck.
     * LOGNOT previously stamped bool for any operand (including struct/slice) → BLD001;
     * NEG/BITNOT stamped the aggregate type → BLD001 on host-C. G.7: reuse aggregate
     * helper from wave657/658; diag invalid_aggregate_cmp (message covers unary).
     */
    if (!ast.ref_is_null(op_tr) && op_tr > 0 && op_tr <= arena.num_types) {
      if (typeck_type_is_aggregate_cmp_operand(module, arena, op_tr) != 0) {
        line_u = pipeline_expr_line_at(arena, expr_ref);
        col_u = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_invalid_aggregate_cmp(line_u, col_u);
        return -1;
      }
    }
    if (expr_kind == ord_lognot) {
      /*
       * wave665 Cap residual: LOGNOT operand must be TYPE_BOOL (docs/04).
       * Soft: unknown/null op type not hard-failed. G.7: type_ref_is_bool +
       * driver_diagnostic_typeck_logical_operand_not_bool.
       */
      if (!ast.ref_is_null(op_tr) && op_tr > 0 && op_tr <= arena.num_types) {
        if (!type_ref_is_bool(arena, op_tr)) {
          line_u = pipeline_expr_line_at(arena, expr_ref);
          col_u = pipeline_expr_col_at(arena, expr_ref);
          driver_diagnostic_typeck_logical_operand_not_bool(line_u, col_u);
          return -1;
        }
      }
      bt = ensure_bool_type_ref(arena);
      if (bt != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, bt);
      }
      return 0;
    }
    if (!ast.ref_is_null(op_tr) && op_tr > 0 && op_tr <= arena.num_types) {
      op_ko = pipeline_type_kind_ord_at(arena, op_tr);
      /*
       * wave667 Cap residual: hard-fail unary -/~ on void at typeck.
       * Root cause: stamped op type for void call result → host-cc BLD001
       * `invalid argument type 'void' to unary expression`. LOGNOT already
       * rejected via wave665 non-bool. G.7: invalid_void_binop (same as arith).
       * PLATFORM: SHARED — seed typeck_gen + empty_surface same commit.
       */
      if ((expr_kind == ord_neg || expr_kind == ord_bitnot) && op_ko == 16) {
        line_u = pipeline_expr_line_at(arena, expr_ref);
        col_u = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_invalid_void_binop(line_u, col_u);
        return -1;
      }
      /*
       * wave677 Cap residual: hard-fail unary -/~ on bool at typeck.
       * Soft residual: -true / ~true typeck OK (stamp bool) → host/fs int false green
       * or late return mismatch. G.7: invalid_bool_binop (same as arith).
       * PLATFORM: SHARED — seed typeck_gen + empty_surface same commit.
       */
      if ((expr_kind == ord_neg || expr_kind == ord_bitnot) && op_ko == 1) {
        line_u = pipeline_expr_line_at(arena, expr_ref);
        col_u = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_invalid_bool_binop(line_u, col_u);
        return -1;
      }
      /* wave289: reject ~float, ~ptr, -ptr at typeck (reuse wave285/286 diags — G.7). */
      if (expr_kind == ord_bitnot) {
        if (op_ko == ord_f32 || op_ko == ord_f64) {
          line_u = pipeline_expr_line_at(arena, expr_ref);
          col_u = pipeline_expr_col_at(arena, expr_ref);
          driver_diagnostic_typeck_invalid_float_binop(line_u, col_u);
          return -1;
        }
        if (op_ko == ord_ptr) {
          line_u = pipeline_expr_line_at(arena, expr_ref);
          col_u = pipeline_expr_col_at(arena, expr_ref);
          driver_diagnostic_typeck_invalid_ptr_binop(line_u, col_u);
          return -1;
        }
      }
      if (expr_kind == ord_neg && op_ko == ord_ptr) {
        line_u = pipeline_expr_line_at(arena, expr_ref);
        col_u = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_invalid_ptr_binop(line_u, col_u);
        return -1;
      }
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, op_tr);
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function typeck_check_expr_addr_of(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let op_ref: i32 = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    let op_ty: i32 = 0;
    let pt: i32 = 0;
    /* See implementation. */
    if (!ast.ref_is_null(op_ref)) {
      if (pipeline_typeck_reject_addr_of_linear_c(arena, op_ref, expr_ref, module, ctx) != 0) {
        return - 1;
      }
      if (check_expr(module, arena, op_ref, return_type_ref, ctx) != 0) {
        return - 1;
      }
    }
    op_ty = expr_type_ref(arena, op_ref);
    if (ast.ref_is_null(op_ty) || op_ty <= 0 || op_ty > arena.num_types) {
      return - 1;
    }
    /* See implementation. */
    pt = pipeline_typeck_ptr_for_addr_of_operand_c(arena, op_ref, op_ty, module, ctx);
    if (pt == 0) {
      pt = find_or_alloc_ptr_type_ref(arena, op_ty);
    }
    if (pt == 0) {
      return - 1;
    }
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, pt);
    return 0;
  }
}

/**
 * See implementation.
 */
export function typeck_check_expr_deref(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
/** See implementation for details. */
    if (pipeline_dep_ctx_typeck_unsafe_depth_at(ctx) <= 0) {
      let line: i32 = pipeline_expr_line_at(arena, expr_ref);
      let col: i32 = pipeline_expr_col_at(arena, expr_ref);
      driver_diagnostic_typeck_deref_outside_unsafe(line, col);
      return -1;
    }
    let ord_ptr: i32 = 9;
    let op_ref: i32 = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    let op_ptr: i32 = 0;
    let elem_ty: i32 = 0;
    if (!ast.ref_is_null(op_ref)) {
      if (check_expr(module, arena, op_ref, return_type_ref, ctx) != 0) {
        return - 1;
      }
    }
    op_ptr = expr_type_ref(arena, op_ref);
    if (ast.ref_is_null(op_ptr) || op_ptr <= 0 || op_ptr > arena.num_types) {
      return - 1;
    }
    if (pipeline_type_kind_ord_at(arena, op_ptr) != ord_ptr) {
      return - 1;
    }
    elem_ty = pipeline_type_elem_ref_at(arena, op_ptr);
    if (ast.ref_is_null(elem_ty)) {
      return - 1;
    }
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, elem_ty);
    return 0;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function typeck_check_expr_var_top_level(module: *Module, arena: *ASTArena, expr_ref: i32,
vbuf: *u8, vnlen: i32, tl: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let tl_tr: i32 = 0;
    if (tl >= module.num_top_level_lets) {
      return 0;
    }
    if (typeck_top_level_let_name_equal(module, tl, vbuf, vnlen)) {
      tl_tr = pipeline_module_top_level_let_type_ref(module, tl);
      if (!ast.ref_is_null(tl_tr)) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, tl_tr);
        return 1;
      }
    }
    return typeck_check_expr_var_top_level(module, arena, expr_ref, vbuf, vnlen, tl + 1);
  }
}

/**
 * See implementation.
 */
export function typeck_check_expr_var(module: *Module, arena: *ASTArena, expr_ref: i32,
ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let vnlen: i32 = 0;
    let vbuf: *u8 = typeck_scratch64_slot(0);
    let hint_buf: *u8 = typeck_scratch64_slot(13);
    let vd_tr: i32 = 0;
    let block_ref: i32 = 0;
    let func_ix: i32 = 0;
    let pr: i32 = 0;
    let tk_tr: i32 = 0;
    let tg_tr: i32 = 0;
    let const_dep_ix: i32 = -1;
    let hint_len: i32 = 0;
    let line: i32 = 0;
    let col: i32 = 0;
    let nm_tok_kind: u8[9] = [84, 111, 107, 101, 110, 75, 105, 110, 100];
    let nm_typ_kind: u8[8] = [84, 121, 112, 101, 75, 105, 110, 100];
    if (arena == 0 as *ASTArena || module == 0 as *Module || ctx == 0 as *PipelineDepCtx
    || expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    vnlen = pipeline_expr_var_name_len(arena, expr_ref);
    if (vnlen <= 0 || vnlen > 127) {
      return - 1;
    }
    pipeline_expr_var_name_into(arena, expr_ref, vbuf);
    block_ref = pipeline_dep_ctx_current_block_ref_at(ctx);
    driver_diagnostic_typeck_var_resolution(expr_ref, vbuf, vnlen, pipeline_dep_ctx_current_func_index(ctx),
    block_ref, 99, pipeline_expr_resolved_type_ref(arena, expr_ref));
    if (block_ref != 0 && block_ref <= arena.num_blocks) {
      vd_tr = pipeline_block_resolve_var_type_ref(arena, block_ref, vbuf, vnlen);
      if (vd_tr != 0) {
        driver_diagnostic_typeck_var_resolution(expr_ref, vbuf, vnlen, pipeline_dep_ctx_current_func_index(ctx),
        block_ref, 1, vd_tr);
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, vd_tr);
        if (pipeline_typeck_linear_use_var_c(arena, vd_tr, expr_ref, vbuf, vnlen) != 0) {
          return - 1;
        }
        return 0;
      }
    }
/** See implementation for details. */
    func_ix = pipeline_dep_ctx_current_func_index(ctx);
    if (func_ix >= 0 && func_ix < module.num_funcs) {
      pr = pipeline_module_func_param_type_ref_for_name(module, func_ix, vbuf, vnlen);
      if (pr != 0) {
        driver_diagnostic_typeck_var_resolution(expr_ref, vbuf, vnlen, func_ix, block_ref, 2, pr);
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, pr);
        if (pipeline_typeck_linear_use_var_c(arena, pr, expr_ref, vbuf, vnlen) != 0) {
          return - 1;
        }
        return 0;
      }
    }
    driver_diagnostic_typeck_var_resolution(expr_ref, vbuf, vnlen, pipeline_dep_ctx_current_func_index(ctx),
    block_ref, 100, pipeline_expr_resolved_type_ref(arena, expr_ref));
    if (module.num_top_level_lets > 0) {
      if (typeck_check_expr_var_top_level(module, arena, expr_ref, vbuf, vnlen, 0) != 0) {
        driver_diagnostic_typeck_var_resolution(expr_ref, vbuf, vnlen, pipeline_dep_ctx_current_func_index(ctx),
        block_ref, 101, pipeline_expr_resolved_type_ref(arena, expr_ref));
        return 0;
      }
    }
    driver_diagnostic_typeck_var_resolution(expr_ref, vbuf, vnlen, pipeline_dep_ctx_current_func_index(ctx),
    block_ref, 102, pipeline_expr_resolved_type_ref(arena, expr_ref));
    driver_diagnostic_typeck_var_resolution(expr_ref, vbuf, vnlen, func_ix, block_ref, 104,
    pipeline_expr_resolved_type_ref(arena, expr_ref));
    /* wave100 language residual: same-module function name as Cap-fn-ptr *u8.
     * PLATFORM: SHARED — product large-stack surfaces need bare fn as *u8
     * (g05 formerly held (uint8_t*)(void*)fn; .x could not form fn-pointer constants).
     * Locals/params/top-level lets already resolved above. CALL does not typecheck
     * the callee via this path (name-based resolve), so call sites stay unchanged.
     * First matching overload wins (C product surfaces are #[no_mangle] unique). */
    {
      let fi: i32 = 0;
      let nfuncs: i32 = module.num_funcs;
      while (fi < nfuncs) {
        if (pipeline_module_func_name_equal_at(module, fi, vbuf, vnlen) != 0) {
          let u8r: i32 = ensure_u8_type_ref(arena);
          let ptr_u8: i32 = 0;
          if (ast.ref_is_null(u8r)) {
            return -1;
          }
          ptr_u8 = find_or_alloc_ptr_type_ref(arena, u8r);
          if (ast.ref_is_null(ptr_u8) || ptr_u8 == 0) {
            return -1;
          }
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, ptr_u8);
          driver_diagnostic_typeck_var_resolution(expr_ref, vbuf, vnlen, func_ix, block_ref, 105, ptr_u8);
          return 0;
        }
        fi = fi + 1;
      }
    }
    if (vnlen == 9 && name_equal(vbuf, vnlen, &nm_tok_kind[0], 9)) {
      tk_tr = find_or_alloc_named_type_ref(arena, &nm_tok_kind[0], 9);
      if (tk_tr != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, tk_tr);
        return 0;
      }
    }
    if (vnlen == 8 && name_equal(vbuf, vnlen, &nm_typ_kind[0], 8)) {
      tg_tr = find_or_alloc_named_type_ref(arena, &nm_typ_kind[0], 8);
      if (tg_tr != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, tg_tr);
        return 0;
      }
    }
    if (typeck_var_is_import_visible_name(module, vbuf, vnlen)) {
      return 0;
    }
    const_dep_ix = typeck_find_import_const_dep_index(module, ctx, vbuf, vnlen, 0);
    if (const_dep_ix >= 0) {
      line = pipeline_expr_line_at(arena, expr_ref);
      col = pipeline_expr_col_at(arena, expr_ref);
      hint_len = typeck_import_const_binding_hint_at(module, const_dep_ix, hint_buf);
      driver_diagnostic_typeck_import_const_must_be_qualified(line, col, vbuf, vnlen, hint_buf, hint_len);
      return -1;
    }
    if (ast.ref_is_null(pipeline_expr_resolved_type_ref(arena, expr_ref))) {
      return - 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function typeck_check_expr_method_call_arg(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, arg_i: i32, num_args: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let arg_ref: i32 = 0;
    if (arg_i >= num_args) {
      return 0;
    }
    arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, arg_i);
    if (check_expr(module, arena, arg_ref, return_type_ref, ctx) != 0) {
      return - 1;
    }
    return typeck_check_expr_method_call_arg(module, arena, expr_ref, return_type_ref, ctx,
    arg_i + 1, num_args);
  }
}

/**
 * See implementation.
 */
export function typeck_check_expr_method_call(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    return pipeline_typeck_check_expr_method_call_c(module, arena, expr_ref, return_type_ref, ctx);
  }
}

/**
 * Return 1 when ty_ref is a cast-eligible class for `expr as T` (wave659).
 * Eligible: first-class integers/bool, floats, pointers, NAMED integer spellings
 * (i8/i16/u16 via int_family), and TYPE_NAMED enum/alias-of-scalar (non-struct).
 * Ineligible: ARRAY/SLICE/LINEAR/VECTOR/struct layouts (via aggregate helper).
 * @param module *Module — struct layout table for named aggregate detection
 * @param arena *ASTArena — type arena
 * @param ty_ref i32 — source or target type of an `as` cast
 * @return i32 — 1 ok class, 0 ineligible or null/unknown
 * PLATFORM: SHARED — G.7 helper for typeck_as_cast_allowed only.
 */
export function typeck_as_cast_type_class_ok(module: *Module, arena: *ASTArena, ty_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_bool: i32 = 1;
    let ord_named: i32 = 8;
    let ord_ptr: i32 = 9;
    let ord_f32: i32 = 14;
    let ord_f64: i32 = 15;
    let ord_void: i32 = 16;
    let ko: i32 = 0;
    let rty: i32 = 0;
    if (module == 0 as *Module || arena == 0 as *ASTArena || ast.ref_is_null(ty_ref)) {
      return 0;
    }
    /* Aggregate (struct/array/slice/vector/linear) never participates in `as`. */
    if (typeck_type_is_aggregate_cmp_operand(module, arena, ty_ref) != 0) {
      return 0;
    }
    rty = typeck_resolve_type_alias_ref_local(module, arena, ty_ref, 0);
    if (ast.ref_is_null(rty)) {
      rty = ty_ref;
    }
    ko = pipeline_type_kind_ord_at(arena, rty);
    if (ko == ord_void) {
      return 0;
    }
    /* First-class ints / bool / float / ptr. */
    if (ko == ord_bool || ko == ord_ptr || ko == ord_f32 || ko == ord_f64) {
      return 1;
    }
    if (typeck_int_family_id(arena, rty) >= 0) {
      return 1;
    }
    /* TYPE_NAMED non-struct (enum tags / non-layout names) stay castable like C enums. */
    if (ko == ord_named) {
      return 1;
    }
    return 0;
  }
}

/**
 * Return 1 when `src as tgt` is a legal cast (wave659 Cap residual).
 * Allowed: same type; numeric↔numeric (int/bool/float family); int↔ptr; ptr↔ptr;
 * enum-like NAMED↔integer. Rejected: any aggregate side; float↔ptr; void; other.
 * @param module *Module
 * @param arena *ASTArena
 * @param src_ty i32 — resolved type of cast operand
 * @param tgt_ty i32 — cast target type ref
 * @return i32 — 1 allowed, 0 illegal
 * PLATFORM: SHARED — single authority for typeck_check_expr_as.
 */
export function typeck_as_cast_allowed(module: *Module, arena: *ASTArena, src_ty: i32,
tgt_ty: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_bool: i32 = 1;
    let ord_named: i32 = 8;
    let ord_ptr: i32 = 9;
    let ord_f32: i32 = 14;
    let ord_f64: i32 = 15;
    let sk: i32 = 0;
    let tk: i32 = 0;
    let s_int: i32 = 0;
    let t_int: i32 = 0;
    let s_float: i32 = 0;
    let t_float: i32 = 0;
    let s_num: i32 = 0;
    let t_num: i32 = 0;
    let src_r: i32 = 0;
    let tgt_r: i32 = 0;
    if (module == 0 as *Module || arena == 0 as *ASTArena) {
      return 0;
    }
    if (ast.ref_is_null(src_ty) || ast.ref_is_null(tgt_ty)) {
      return 0;
    }
    if (typeck_as_cast_type_class_ok(module, arena, src_ty) == 0
    || typeck_as_cast_type_class_ok(module, arena, tgt_ty) == 0) {
      return 0;
    }
    src_r = typeck_resolve_type_alias_ref_local(module, arena, src_ty, 0);
    if (ast.ref_is_null(src_r)) {
      src_r = src_ty;
    }
    tgt_r = typeck_resolve_type_alias_ref_local(module, arena, tgt_ty, 0);
    if (ast.ref_is_null(tgt_r)) {
      tgt_r = tgt_ty;
    }
    if (type_refs_equal(arena, src_r, tgt_r)) {
      return 1;
    }
    sk = pipeline_type_kind_ord_at(arena, src_r);
    tk = pipeline_type_kind_ord_at(arena, tgt_r);
    s_int = 0;
    t_int = 0;
    if (typeck_int_family_id(arena, src_r) >= 0 || sk == ord_bool || sk == ord_named) {
      s_int = 1;
    }
    if (typeck_int_family_id(arena, tgt_r) >= 0 || tk == ord_bool || tk == ord_named) {
      t_int = 1;
    }
    s_float = 0;
    t_float = 0;
    if (sk == ord_f32 || sk == ord_f64) {
      s_float = 1;
    }
    if (tk == ord_f32 || tk == ord_f64) {
      t_float = 1;
    }
    /* float ↔ pointer is illegal in C and here (host-cc BLD001 soft residual). */
    if ((s_float != 0 && tk == ord_ptr) || (t_float != 0 && sk == ord_ptr)) {
      return 0;
    }
    s_num = 0;
    t_num = 0;
    if (s_int != 0 || s_float != 0) {
      s_num = 1;
    }
    if (t_int != 0 || t_float != 0) {
      t_num = 1;
    }
    /* numeric ↔ numeric (int/bool/float/enum-like). */
    if (s_num != 0 && t_num != 0) {
      return 1;
    }
    /* integer ↔ pointer (kernel MMIO / address casts). */
    if ((s_int != 0 && tk == ord_ptr) || (t_int != 0 && sk == ord_ptr)) {
      return 1;
    }
    /* pointer ↔ pointer (reinterpret pointee). */
    if (sk == ord_ptr && tk == ord_ptr) {
      return 1;
    }
    return 0;
  }
}

/**
 * Type-check `operand as TargetType`. Stamps resolved type to target on success.
 * wave659: hard-fail illegal casts (aggregate / float↔ptr / void) instead of stamping
 * target and leaving host-cc BLD001 or silent false green.
 * @param module *Module
 * @param arena *ASTArena
 * @param expr_ref i32 — EXPR_AS
 * @param ctx *PipelineDepCtx
 * @return i32 — 0 ok, -1 hard fail
 * PLATFORM: SHARED — seed typeck_gen + empty_surface same commit.
 */
export function typeck_check_expr_as(module: *Module, arena: *ASTArena, expr_ref: i32,
ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let op_ref: i32 = pipeline_expr_as_operand_ref_at(arena, expr_ref);
    let tgt: i32 = pipeline_expr_as_target_type_ref_at(arena, expr_ref);
    let src_ty: i32 = 0;
    let line_as: i32 = 0;
    let col_as: i32 = 0;
    if (!ast.ref_is_null(op_ref) && check_expr(module, arena, op_ref, 0, ctx) != 0) {
      return - 1;
    }
    /*
     * wave659 Cap residual: hard-fail illegal `as` at typeck.
     * Root cause: typeck_check_expr_as only checked the operand then stamped tgt →
     * struct/array `as i32` false green; float→ptr host-cc BLD001.
     * G.7: typeck_as_cast_allowed + typeck_type_is_aggregate_cmp_operand (wave657).
     * Legal: numeric↔numeric, int↔ptr, ptr↔ptr, enum-like NAMED↔int (docs MMIO).
     * PLATFORM: SHARED — seed typeck_gen + empty_surface + diagnostic twin same commit.
     */
    if (!ast.ref_is_null(op_ref) && !ast.ref_is_null(tgt)) {
      src_ty = pipeline_expr_resolved_type_ref(arena, op_ref);
      if (!ast.ref_is_null(src_ty) && typeck_as_cast_allowed(module, arena, src_ty, tgt) == 0) {
        line_as = pipeline_expr_line_at(arena, expr_ref);
        col_as = pipeline_expr_col_at(arena, expr_ref);
        driver_diagnostic_typeck_invalid_as_cast(line_as, col_as);
        return -1;
      }
    }
    if (!ast.ref_is_null(tgt)) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, tgt);
    }
    return 0;
  }
}

/**
 * EXPR_STRUCT_LIT field init check (recursive step; avoid while+check_expr EMIT_HEAVY SIGSEGV).
 * PLATFORM: SHARED — field inits must NOT inherit the outer function/return expected type.
 * Passing the callee return (e.g. Vec_i32) into heap.default_alloc() as expected ret polluted
 * overload pick (METHOD_CALL expected_ret slot) → soft XT001 on freestanding co-emit new().
 * Check with expected=0; layout coerce stamps field types after ensure_struct_layout.
 * return_type_ref param kept for call-site API stability; unused for field init expected.
 */
export function typeck_check_expr_struct_lit_field(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, field_i: i32, num_fields: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let init_sl: i32 = 0;
    let no_expected: i32 = 0;
    if (field_i >= num_fields) {
      return 0;
    }
    init_sl = pipeline_expr_struct_lit_init_ref(arena, expr_ref, field_i);
    /* expected=0: do not pass outer function return type into field METHOD_CALL/CALL. */
    if (!ast.ref_is_null(init_sl) && check_expr(module, arena, init_sl, no_expected, ctx) != 0) {
      return - 1;
    }
    return typeck_check_expr_struct_lit_field(module, arena, expr_ref, return_type_ref, ctx,
    field_i + 1, num_fields);
  }
}

/**
 * Coerce STRUCT_LIT field inits to layout field types and hard-fail mismatches.
 * wave672 Cap residual: prior path called typeck_coerce_init_expr_to_decl (incl.
 * LANG-006 bool→int) and never checked field types → `S { v: true }` / `v: 1.0 as f32`
 * for `v: i32` false-green. G.7: reuse lit/float/enum/array/int_binop/slice coerces
 * only — **not** bool→int (LANG-006 is scalar let/const only). Then require equal /
 * integer_widen / float_widen; emit assign_mismatch on known mismatch.
 * wave682 Cap residual: layout field types may be free type-params (`v: T`). When
 * expected/base is monomorphized (`Wrap<i32>`), substitute via
 * pipeline_typeck_mono_field_type_from_base_c before coerce (was expected T, found i32).
 * @param module *Module — layout table
 * @param arena *ASTArena
 * @param expr_ref i32 — EXPR_STRUCT_LIT
 * @param base_ty i32 — expected/mono base type (let/return `Wrap<i32>`), or 0
 * @return i32 — 0 ok, -1 field type mismatch (diagnostic emitted)
 * PLATFORM: SHARED typeck
 */
export function typeck_coerce_struct_lit_field_inits_to_layout(module: *Module, arena: *ASTArena,
expr_ref: i32, base_ty: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let num_fields: i32 = 0;
    let name_len: i32 = 0;
    let j: i32 = 0;
    let flen: i32 = 0;
    let init_r: i32 = 0;
    let ftr: i32 = 0;
    let ftr_mono: i32 = 0;
    let ftr_kind: i32 = 0;
    let init_kind: i32 = 0;
    let init_ty: i32 = 0;
    let got_kind: i32 = 0;
    let crc: i32 = 0;
    let mono_base: i32 = 0;
    let eb: *u8 = 0 as *u8;
    let gb: *u8 = 0 as *u8;
    let el: i32 = 0;
    let gl: i32 = 0;
    let err_line: i32 = 0;
    let err_col: i32 = 0;
    let name_buf: *u8 = typeck_scratch64_slot(4);
    let field_buf: *u8 = typeck_scratch64_slot(5);
    if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    num_fields = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    name_len = pipeline_expr_struct_lit_type_name_len(arena, expr_ref);
    if (num_fields <= 0 || name_len <= 0 || name_len > 127) {
      return 0;
    }
    pipeline_expr_struct_lit_type_name_into(arena, expr_ref, name_buf);
    /*
     * wave682: mono base from expected let/return type when it names the same
     * generic struct (Wrap / Pair). PTR peel is inside mono helper.
     */
    mono_base = 0;
    if (!ast.ref_is_null(base_ty) && base_ty > 0 && base_ty <= arena.num_types) {
      if (typeck_named_type_matches_name_or_alias(module, arena, base_ty, name_buf, name_len, 0)) {
        mono_base = base_ty;
      } else {
        let peel: i32 = pipeline_type_elem_ref_at(arena, base_ty);
        if (!ast.ref_is_null(peel) && peel > 0
        && typeck_named_type_matches_name_or_alias(module, arena, peel, name_buf, name_len, 0)) {
          mono_base = peel;
        }
      }
    }
    while (j < num_fields) {
      flen = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, j);
      /* wave583 Cap residual: struct-lit field name content ≤127. */
      if (flen > 0 && flen <= 127) {
        pipeline_expr_struct_lit_field_name_into(arena, expr_ref, j, field_buf);
        ftr = get_field_type_ref_from_layout(module, name_buf, name_len, field_buf, flen);
        init_r = pipeline_expr_struct_lit_init_ref(arena, expr_ref, j);
        if (!ast.ref_is_null(init_r) && init_r > 0 && init_r <= arena.num_exprs
        && !ast.ref_is_null(ftr) && ftr > 0) {
          /*
           * wave682: substitute free type-param field types (T/U) from mono base.
           * Layout stores `v: T`; expected Wrap<i32> → ftr becomes i32.
           */
          if (mono_base > 0) {
            ftr_mono = pipeline_typeck_mono_field_type_from_base_c(module, arena, ftr, mono_base);
            if (ftr_mono > 0) {
              ftr = ftr_mono;
            }
          }
          /*
           * wave672: field-level coerce without LANG-006 bool→int (scalar let/const only).
           * Reuse G.7 authorities per case; array-lit return -1 propagates.
           */
          ftr_kind = pipeline_type_kind_ord_at(arena, ftr);
          init_kind = pipeline_expr_kind_ord_at(arena, init_r);
          typeck_coerce_init_lit_to_decl(arena, init_r, ftr, ftr_kind, init_kind);
          typeck_coerce_init_float_lit_to_decl(arena, init_r, ftr, ftr_kind, init_kind);
          typeck_coerce_init_enum_field_to_decl(module, arena, init_r, ftr, ftr_kind, init_kind);
          typeck_coerce_init_named_call_to_decl(arena, init_r, ftr, ftr_kind, init_kind);
          typeck_coerce_init_resolved_alias_to_decl(module, arena, init_r, ftr, ftr_kind);
          crc = typeck_coerce_init_array_vector_lit_to_decl(arena, init_r, ftr, ftr_kind, init_kind);
          if (crc < 0) {
            return -1;
          }
          typeck_coerce_init_vector_binop_to_decl(arena, init_r, ftr, ftr_kind, init_kind);
          typeck_coerce_init_int_binop_to_decl(arena, init_r, ftr, ftr_kind, init_kind);
          typeck_coerce_init_slice_from_array(arena, init_r, ftr, ftr_kind);
          init_ty = expr_type_ref(arena, init_r);
          if (!ast.ref_is_null(init_ty) && init_ty > 0) {
            got_kind = pipeline_type_kind_ord_at(arena, init_ty);
            if (type_refs_equal(arena, ftr, init_ty)
            || typeck_integer_widen_ok_refs(arena, ftr, init_ty)
            || typeck_float_widen_ok(ftr_kind, got_kind)) {
              pipeline_expr_set_resolved_type_ref(arena, init_r, ftr);
            } else {
              eb = driver_typeck_diag_scratch_expect();
              gb = driver_typeck_diag_scratch_found();
              el = typeck_diag_fmt_type_into(arena, ftr, eb, 96);
              gl = typeck_diag_fmt_type_into(arena, init_ty, gb, 96);
              err_line = pipeline_expr_line_at(arena, init_r);
              err_col = pipeline_expr_col_at(arena, init_r);
              driver_diagnostic_typeck_assign_mismatch(0, err_line, err_col, eb, el, gb, gl);
              return -1;
            }
          }
        }
      }
      j = j + 1;
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function typeck_check_expr_struct_lit(
  module: *Module, 
  arena: *ASTArena, 
  expr_ref: i32,
  return_type_ref: i32, 
  ctx: *PipelineDepCtx): i32 
{
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let num_fields: i32 = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    let name_len: i32 = 0;
    let name_buf: u8[128] = [];
    let tr: i32 = 0;
    let ord_named: i32 = 8;
    if (typeck_check_expr_struct_lit_field(module, arena, expr_ref, return_type_ref, ctx, 0,
    num_fields) != 0) {
      return - 1;
    }
    name_len = pipeline_expr_struct_lit_type_name_len(arena, expr_ref);
    if (name_len <= 0) {
      /* Anonymous struct literal `{ field: expr, ... }`: backfill struct_lit_struct_name
       * from contextual return_type_ref so codegen emits `(struct <module>_Pair){...}`
       * instead of `(struct <module>_){...}` (incomplete type cc error). Resolve type
       * alias to reach the underlying NAMED struct type. PLATFORM: SHARED. */
      if (!ast.ref_is_null(return_type_ref)
      && pipeline_type_kind_ord_at(arena, return_type_ref) == ord_named) {
        let resolved_ref: i32 = typeck_resolve_type_alias_ref_local(module, arena, return_type_ref, 0);
        if (!ast.ref_is_null(resolved_ref)
        && pipeline_type_kind_ord_at(arena, resolved_ref) == ord_named) {
          let backfill_name: u8[128] = [];
          let backfill_len: i32 = pipeline_type_named_name_into(arena, resolved_ref, &backfill_name[0]);
          /* wave583 Cap residual: anonymous struct-lit type name backfill ≤127. */
          if (backfill_len > 0 && backfill_len <= 127) {
            /* Why setter (not get_copy/set_copy): avoids returning the ~400-byte ast.Expr
             * by value across the X-ABI boundary (sret mismatch → SIGBUS on arm64). */
            pipeline_expr_struct_lit_type_name_set(arena, expr_ref, &backfill_name[0], backfill_len);
          }
        }
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref);
      }
      return 0;
    }
    if (ensure_struct_layout_from_struct_lit(module, arena, expr_ref) != 0) {
      return - 1;
    }
    /* wave672/682: field coerce + mono type-param fields + hard-fail mismatch. */
    if (typeck_coerce_struct_lit_field_inits_to_layout(module, arena, expr_ref, return_type_ref) != 0) {
      return -1;
    }
    if (name_len > 127) {
      return 0;
    }
    pipeline_expr_struct_lit_type_name_into(arena, expr_ref, &name_buf[0]);
    tr = find_or_alloc_named_type_ref(arena, &name_buf[0], name_len);
    if (tr != 0) {
      if (!ast.ref_is_null(return_type_ref)
      && pipeline_type_kind_ord_at(arena, return_type_ref) == ord_named
      && typeck_named_type_matches_name_or_alias(module, arena, return_type_ref, &name_buf[0], name_len, 0)) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref);
      } else {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, tr);
      }
    }
    return 0;
  }
}

/**
 * Resolve element type of a SIMD vector type for INDEX `v[i]`.
 * TYPE_VECTOR uses elem_type_ref; TYPE_NAMED spellings (i32x4/u32x8/f32x4/…)
 * often have empty elem_ref — map prefix to a primitive via ensure_*.
 * Returns 0 if not a vector-like type.
 * PLATFORM: SHARED — pairs with typeck_vector_lanes_of_type (NAMED residual).
 */
export function typeck_vector_elem_type_ref(arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — vector lane element for INDEX / CTFE.
  unsafe {
    let ord_type_vector: i32 = 13;
    let ord_type_named: i32 = 8;
    let tk: i32 = 0;
    let er: i32 = 0;
    let nm: u8[128] = [];
    let nlen: i32 = 0;
    if (ast.ref_is_null(type_ref) || type_ref <= 0) {
      return 0;
    }
    if (typeck_vector_lanes_of_type(arena, type_ref) <= 0) {
      return 0;
    }
    tk = pipeline_type_kind_ord_at(arena, type_ref);
    er = pipeline_type_elem_ref_at(arena, type_ref);
    if (!ast.ref_is_null(er) && er > 0 && er <= arena.num_types) {
      return er;
    }
    if (tk == ord_type_vector) {
      /* No elem stamp: default i32 lane (i32xN product default). */
      return ensure_i32_type_ref(arena);
    }
    if (tk != ord_type_named) {
      return 0;
    }
    nlen = pipeline_type_named_name_into(arena, type_ref, &nm[0]);
    if (nlen <= 0) {
      return ensure_i32_type_ref(arena);
    }
    /* f32x* / f64x* first (overlap with *32 / *64 digit patterns). */
    if (nlen >= 3 && nm[0] == 102 && nm[1] == 51 && nm[2] == 50) {
      return ensure_f32_type_ref(arena);
    }
    if (nlen >= 3 && nm[0] == 102 && nm[1] == 54 && nm[2] == 52) {
      return ensure_f64_type_ref(arena);
    }
    if (nlen >= 3 && nm[0] == 105 && nm[1] == 54 && nm[2] == 52) {
      return ensure_i64_type_ref(arena);
    }
    if (nlen >= 3 && nm[0] == 117 && nm[1] == 54 && nm[2] == 52) {
      return typeck_ensure_primitive_by_kind_ord(arena, 4); /* TYPE_U64 */
    }
    if (nlen >= 3 && nm[0] == 117 && nm[1] == 51 && nm[2] == 50) {
      return typeck_ensure_primitive_by_kind_ord(arena, 3); /* TYPE_U32 */
    }
    if (nlen >= 2 && nm[0] == 117 && nm[1] == 56) {
      return ensure_u8_type_ref(arena);
    }
    /* i32x* / Vec* / residual → i32 */
    return ensure_i32_type_ref(arena);
  }
}

/**
 * True when ty_ref is a legal INDEX subscript (integer-like).
 * First-class ints (i32/u8/u32/u64/i64/usize/isize) and non-struct TYPE_NAMED
 * (i8/i16/u16 aliases, enum tags) are ok. Rejects bool/ptr/float/aggregate/void.
 * Soft: unknown/null ty_ref returns 1 so incomplete resolve is not a hard leaf.
 * @param module *Module — for struct-layout NAMED check (via aggregate helper)
 * @param arena *ASTArena — type pool
 * @param ty_ref i32 — resolved type of the index expression
 * @return i32 — 1 allowed (or soft-unknown), 0 hard-reject
 * PLATFORM: SHARED — wave664 Cap residual; G.7 single helper for INDEX index gate.
 */
export function typeck_type_is_valid_subscript_index(module: *Module, arena: *ASTArena, ty_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_i32: i32 = 0;
    let ord_bool: i32 = 1;
    let ord_u8: i32 = 2;
    let ord_u32: i32 = 3;
    let ord_u64: i32 = 4;
    let ord_i64: i32 = 5;
    let ord_usize: i32 = 6;
    let ord_isize: i32 = 7;
    let ord_named: i32 = 8;
    let rty: i32 = 0;
    let ko: i32 = 0;
    if (arena == 0 as *ASTArena || ast.ref_is_null(ty_ref) || ty_ref <= 0) {
      return 1;
    }
    /* Peel aliases so `type Idx = i32` stays integer-like. */
    rty = ty_ref;
    if (module != 0 as *Module) {
      rty = typeck_resolve_type_alias_ref_local(module, arena, ty_ref, 0);
      if (ast.ref_is_null(rty) || rty <= 0) {
        rty = ty_ref;
      }
    }
    ko = pipeline_type_kind_ord_at(arena, rty);
    if (ko == ord_i32 || ko == ord_u8 || ko == ord_u32 || ko == ord_u64 || ko == ord_i64
    || ko == ord_usize || ko == ord_isize) {
      return 1;
    }
    if (ko == ord_named) {
      /* Enum / i8/i16/u16 aliases: allow. Product struct layouts: reject. */
      if (typeck_type_is_aggregate_cmp_operand(module, arena, rty) != 0) {
        return 0;
      }
      return 1;
    }
    /* bool, ptr, float, array/slice/vector/linear, void, other: hard reject. */
    if (ko == ord_bool) {
      return 0;
    }
    return 0;
  }
}

/**
 * Type-check EXPR_INDEX: base must be array/slice/ptr/vector; index must be integer-like.
 * Accepts TYPE_ARRAY / SLICE / PTR / VECTOR and TYPE_NAMED SIMD spellings (i32x4…).
 * wave664 Cap residual: hard-fail non-integer index (ptr/float/struct/bool) that
 * formerly passed typeck then host-cc BLD001 or freestanding silent false green.
 * wave699: index ambient is i32, NOT outer return_type_ref. Outer *T (e.g. let p: *u8 =
 * &buf[0]) must not contextual-type the lit index as pointer — that false-T001
 * red'd ptr_arith_i32 and all &arr[lit] under L4 cold product.
 * @param module *Module — current module
 * @param arena *ASTArena — expr/type pool
 * @param expr_ref i32 — EXPR_INDEX
 * @param return_type_ref i32 — ambient for base only (INDEX result type is elem)
 * @param ctx *PipelineDepCtx — typeck context
 * @return i32 — 0 ok, -1 hard fail
 * PLATFORM: SHARED — product INDEX path for vector lane extract (WPO-S2 lane0).
 */
export function typeck_check_expr_index(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_lit: i32 = 0;
    let ord_ptr: i32 = 9;
    let ord_array: i32 = 10;
    let ord_slice: i32 = 11;
    let ord_vector: i32 = 13;
    let base_ref: i32 = pipeline_expr_index_base_ref(arena, expr_ref);
    let index_ref: i32 = pipeline_expr_index_index_ref(arena, expr_ref);
    let line: i32 = pipeline_expr_line_at(arena, expr_ref);
    let col: i32 = pipeline_expr_col_at(arena, expr_ref);
    let base_ty: i32 = 0;
    let bt_kind: i32 = 0;
    let elem_ty: i32 = 0;
    let array_sz: i32 = 0;
    let vec_lanes: i32 = 0;
    let is_vec_base: i32 = 0;
    let index_ty: i32 = 0;
    // Index ambient: always integer-like (i32). Do not pass outer return_type_ref.
    let idx_ambient: i32 = ensure_i32_type_ref(arena);
    if (check_expr(module, arena, base_ref, return_type_ref, ctx) != 0) {
      return - 1;
    }
    if (check_expr(module, arena, index_ref, idx_ambient, ctx) != 0) {
      return - 1;
    }
    if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
      return 0;
    }
    base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
    if (ast.ref_is_null(base_ty) || base_ty <= 0 || base_ty > arena.num_types) {
      driver_diagnostic_typeck_subscript_base(line, col);
      return - 1;
    }
    bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
    vec_lanes = typeck_vector_lanes_of_type(arena, base_ty);
    is_vec_base = 0;
    if (bt_kind == ord_vector || vec_lanes > 0) {
      is_vec_base = 1;
    }
    if (bt_kind != ord_array && bt_kind != ord_slice && bt_kind != ord_ptr && is_vec_base == 0) {
      driver_diagnostic_typeck_subscript_base(line, col);
      return - 1;
    }
    /*
     * wave664: hard-fail non-integer index after index expr is type-checked.
     * Soft-skip unknown index_ty (<=0) inside helper; known bad kinds → T001.
     */
    if (!ast.ref_is_null(index_ref) && index_ref > 0 && index_ref <= arena.num_exprs) {
      index_ty = pipeline_expr_resolved_type_ref(arena, index_ref);
      if (typeck_type_is_valid_subscript_index(module, arena, index_ty) == 0) {
        driver_diagnostic_typeck_subscript_index(line, col);
        return - 1;
      }
    }
    if (is_vec_base != 0) {
      elem_ty = typeck_vector_elem_type_ref(arena, base_ty);
    } else {
      elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
    }
    if (ast.ref_is_null(elem_ty) || elem_ty <= 0) {
      driver_diagnostic_typeck_subscript_base(line, col);
      return - 1;
    }
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, elem_ty);
    if (bt_kind == ord_slice) {
      pipeline_expr_set_index_base_is_slice(arena, expr_ref, 1);
    } else {
      pipeline_expr_set_index_base_is_slice(arena, expr_ref, 0);
    }
    if (!ast.ref_is_null(index_ref) && index_ref > 0 && index_ref <= arena.num_exprs) {
      if (pipeline_expr_kind_ord_at(arena, index_ref) == ord_lit &&
      pipeline_expr_int_val_at(arena, index_ref) == 0 && (bt_kind == ord_array || is_vec_base != 0)) {
        array_sz = pipeline_type_array_size_at(arena, base_ty);
        if (array_sz < 1 && vec_lanes > 0) {
          array_sz = vec_lanes;
        }
        if (array_sz >= 1) {
          pipeline_expr_set_index_proven_in_bounds(arena, expr_ref, 1);
        }
      }
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function typeck_expr_is_any_assign_kind(kind_ord: i32): bool {
  let ord_assign: i32 = 28;
  let ord_add_assign: i32 = 29;
  let ord_shr_assign: i32 = 38;
  if (kind_ord == ord_assign) {
    return true;
  }
  if (kind_ord >= ord_add_assign && kind_ord <= ord_shr_assign) {
    return true;
  }
  return false;
}

/**
 * Recursively type-check every element of an ARRAY_LIT.
 * Prior: check_expr fell through for kind=46 without visiting children, so nested
 * INDEX never ran typeck_check_expr_index → index_base_is_slice stayed 0 and host-C
 * emitted `(slice_var)[i]` (invalid for by-value fat) instead of `.data[i]`.
 * wave611: when the literal still has no resolved type after elems (no let/return
 * ambient), infer TYPE_ARRAY from homogeneous element types so rvalues like
 * `[10, 32][1]` pass typeck_check_expr_index. Let/return still overwrite via
 * typeck_coerce_array_lit_elem_types_to_decl (wave328/333).
 * @param module *Module — current module
 * @param arena *ASTArena — expr/type pool
 * @param expr_ref i32 — EXPR_ARRAY_LIT (kind 46); other kinds return 0
 * @param return_type_ref i32 — ambient expected type passed to nested check_expr
 * @param ctx *PipelineDepCtx — typeck context
 * @return i32 — 0 on success, -1 if any element fails typeck
 * PLATFORM: SHARED — wave407 Cap residual pure; wave611 untyped ARRAY_LIT infer
 */
export function typeck_check_expr_array_lit(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_expr_array_lit: i32 = 46;
    let num_elems: i32 = 0;
    let i: i32 = 0;
    let elem_ref: i32 = 0;
    let already: i32 = 0;
    let elem_ty: i32 = 0;
    let ok_inf: i32 = 1;
    let j: i32 = 0;
    let er: i32 = 0;
    let et: i32 = 0;
    let arr_ty: i32 = 0;
    if (arena == 0 as *ASTArena || expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    if (pipeline_expr_kind_ord_at(arena, expr_ref) != ord_expr_array_lit) {
      return 0;
    }
    num_elems = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
    /*
     * wave705: ambient SIMD/VECTOR stamps the array lit; elems use ambient 0.
     * PLATFORM: SHARED — unblocks `let c: i32x4 = [1,2,3,4] + [10,…]`.
     */
    if (return_type_ref > 0 && num_elems > 0) {
      let amb_lanes: i32 = typeck_vector_lanes_of_type(arena, return_type_ref);
      let amb_kind: i32 = pipeline_type_kind_ord_at(arena, return_type_ref);
      if (amb_lanes <= 0 && amb_kind == 13) {
        amb_lanes = pipeline_type_array_size_at(arena, return_type_ref);
      }
      if (amb_lanes > 0 && amb_lanes == num_elems) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref);
      }
    }
    while (i < num_elems) {
      elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, i);
      if (!ast.ref_is_null(elem_ref) && elem_ref > 0) {
        if (check_expr(module, arena, elem_ref, 0, ctx) != 0) {
          return -1;
        }
      }
      i = i + 1;
    }
    /*
     * wave611 / PLATFORM: SHARED — untyped ARRAY_LIT rvalue type inference.
     * G.7: complete this authority (no second INDEX-only path). Empty lit leaves
     * type unset (no size-0 array stamp). Coerce paths may still overwrite.
     */
    already = pipeline_expr_resolved_type_ref(arena, expr_ref);
    if ((ast.ref_is_null(already) || already <= 0) && num_elems > 0) {
      elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, 0);
      elem_ty = 0;
      ok_inf = 1;
      if (!ast.ref_is_null(elem_ref) && elem_ref > 0) {
        elem_ty = pipeline_expr_resolved_type_ref(arena, elem_ref);
      }
      if (ast.ref_is_null(elem_ty) || elem_ty <= 0) {
        ok_inf = 0;
      }
      j = 1;
      while (ok_inf != 0 && j < num_elems) {
        er = pipeline_expr_array_lit_elem_ref(arena, expr_ref, j);
        et = 0;
        if (!ast.ref_is_null(er) && er > 0) {
          et = pipeline_expr_resolved_type_ref(arena, er);
        }
        if (ast.ref_is_null(et) || et <= 0) {
          ok_inf = 0;
        } else if (!type_refs_equal(arena, et, elem_ty)
        && !typeck_integer_widen_ok_refs(arena, elem_ty, et)
        && !typeck_integer_widen_ok_refs(arena, et, elem_ty)) {
          ok_inf = 0;
        } else if (!type_refs_equal(arena, et, elem_ty)
        && typeck_integer_widen_ok_refs(arena, et, elem_ty)) {
          /* wider element type wins (e.g. i32 then i64 → i64[N]). */
          elem_ty = et;
        }
        j = j + 1;
      }
      if (ok_inf != 0) {
        arr_ty = find_or_alloc_array_type_ref(arena, elem_ty, num_elems);
        if (!ast.ref_is_null(arr_ty) && arr_ty > 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, arr_ty);
        }
      }
    }
    return 0;
  }
}

/**
 * Dispatch non-primary expression kinds for typeck (method/call/index/binop/…).
 * wave407: ARRAY_LIT (46) routes to typeck_check_expr_array_lit so nested INDEX/CALL
 * get full typeck (see that helper).
 * @param module *Module
 * @param arena *ASTArena
 * @param expr_ref i32
 * @param return_type_ref i32
 * @param ctx *PipelineDepCtx
 * @return i32 — 0 ok, -1 fail
 * PLATFORM: SHARED
 */
export function check_expr_impl_mega(module: *Module, arena: *ASTArena, expr_ref: i32, return_type_ref: i32,
ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_return: i32 = 41;
    let ord_panic: i32 = 42;
    let ord_match: i32 = 43;
    let ord_field: i32 = 44;
    let ord_struct_lit: i32 = 45;
    let ord_array_lit: i32 = 46;
    let ord_index: i32 = 47;
    let ord_call: i32 = 48;
    let ord_method_call: i32 = 49;
    let ord_add: i32 = 4;
    let ord_logor: i32 = 21;
    let ord_neg: i32 = 22;
    let ord_bitnot: i32 = 23;
    let ord_lognot: i32 = 24;
    let ord_addr_of: i32 = 51;
    let ord_deref: i32 = 52;
    let ord_var: i32 = 3;
    let ord_as: i32 = 54;
    /* See implementation. */
    let ord_try_propagate: i32 = ExprKind.EXPR_TRY_PROPAGATE as i32;
    let kind: i32 = 0;
    if (arena == 0 as *ASTArena || expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    kind = pipeline_expr_kind_ord_at(arena, expr_ref);
    /* See implementation. */
    if (typeck_expr_is_any_assign_kind(kind)) {
      return pipeline_typeck_check_expr_impl_mega_c(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == ord_return) {
      return pipeline_typeck_check_expr_impl_mega_c(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == ord_panic) {
      return typeck_check_expr_panic(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == ord_match) {
      return pipeline_typeck_check_expr_match_c(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == ord_field) {
      return typeck_check_expr_field_access(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == ord_array_lit) {
      return typeck_check_expr_array_lit(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == ord_index) {
      return typeck_check_expr_index(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == ord_call) {
      return typeck_check_expr_call(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == ord_method_call) {
      return typeck_check_expr_method_call(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind >= ord_add && kind <= ord_logor) {
      return typeck_check_expr_binop(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == ord_neg || kind == ord_bitnot || kind == ord_lognot) {
      return typeck_check_expr_unary(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == ord_addr_of) {
      return typeck_check_expr_addr_of(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == ord_deref) {
      return typeck_check_expr_deref(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == ord_var) {
      return typeck_check_expr_var(module, arena, expr_ref, ctx);
    }
    if (kind == ord_as) {
      return typeck_check_expr_as(module, arena, expr_ref, ctx);
    }
    if (kind == ord_struct_lit) {
      return typeck_check_expr_struct_lit(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == ord_try_propagate) {
      return pipeline_typeck_check_expr_try_propagate_c(module, arena, expr_ref, return_type_ref, ctx);
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function check_expr_impl(module: *Module, arena: *ASTArena, expr_ref: i32, return_type_ref: i32,
ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_lit: i32 = 0;
    let ord_float: i32 = 1;
    let ord_bool: i32 = 2;
    let ord_string_lit: i32 = 59;
    let ord_if: i32 = 25;
    let ord_block: i32 = 26;
    let ord_ternary: i32 = 27;
    let ord_break: i32 = 39;
    let ord_continue: i32 = 40;
    let ord_enum_var: i32 = 50;
    let kind: i32 = 0;
    if (arena == 0 as *ASTArena || expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    kind = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (kind == ord_float) {
      return typeck_check_expr_float_lit(arena, expr_ref);
    }
    if (kind == ord_lit) {
      return typeck_check_expr_int_lit(arena, expr_ref, return_type_ref);
    }
    if (kind == ord_bool) {
      return typeck_check_expr_bool_lit(arena, expr_ref);
    }
    if (kind == ord_string_lit) {
      return typeck_check_expr_string_lit(arena, expr_ref);
    }
    if (kind == ord_break || kind == ord_continue) {
      return typeck_check_expr_break_continue(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == ord_enum_var) {
      return typeck_check_expr_enum_variant(arena, expr_ref);
    }
    if (kind == ord_if || kind == ord_ternary) {
      return typeck_check_expr_if_ternary(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == ord_block) {
      return typeck_check_expr_block(module, arena, expr_ref, return_type_ref, ctx);
    }
    return check_expr_impl_mega(module, arena, expr_ref, return_type_ref, ctx);
  }
}

/**
 * See implementation.
 */
export function check_expr(module: *Module, arena: *ASTArena, expr_ref: i32, return_type_ref: i32,
ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — post-check CTFE write of const_folded_* (not emit fold).
  let rc: i32 = 0;
  if (ast.ref_is_null(expr_ref)) {
    return 0;
  }
  if (arena == 0 as *ASTArena || expr_ref <= 0 || expr_ref > arena.num_exprs) {
    return 0;
  }
  rc = check_expr_impl(module, arena, expr_ref, return_type_ref, ctx);
  if (rc == 0) {
    unsafe {
      pipeline_typeck_fold_expr_c(arena, expr_ref);
    }
  }
  return rc;
}

/**
* See implementation.
*
* See implementation.
* See implementation.
* See implementation.
* See implementation.
* See implementation.
* See implementation.
*/
export function func_body_tail_expr_ref_for_implicit_rule(arena: *ASTArena, body_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let stmt_order_kind_expr_stmt: u8 = (2 as u8);
    let stmt_order_kind_region_c_parser: u8 = (5 as u8);
    let stmt_order_kind_region_x_parser: u8 = (6 as u8);
    let ord_break: i32 = 39;
    let ord_continue: i32 = 40;
    let ord_return: i32 = 41;
    let ord_panic: i32 = 42;
    let fin_ref: i32 = ast.ast_block_final_expr_ref(arena, body_ref);
    let fin_kind: i32 = 0;
    let nso: i32 = ast.ast_block_num_stmt_order(arena, body_ref);
    if (!ast.ref_is_null(fin_ref)) {
      fin_kind = pipeline_expr_kind_ord_at(arena, fin_ref);
      if (fin_kind == ord_return || fin_kind == ord_panic || fin_kind == ord_break ||
          fin_kind == ord_continue) {
        return fin_ref;
      }
    }
    if (nso > 0) {
      let last_k: u8 = ast.ast_block_stmt_order_kind(arena, body_ref, nso - 1);
      if (last_k == stmt_order_kind_region_c_parser || last_k == stmt_order_kind_region_x_parser) {
        let ridx: i32 = ast.ast_block_stmt_order_idx(arena, body_ref, nso - 1);
        let nreg: i32 = ast.ast_block_num_regions(arena, body_ref);
        if (ridx >= 0 && ridx < nreg) {
          let unsafe_region: i32 = pipeline_block_region_is_unsafe(arena, body_ref, ridx);
          if (unsafe_region != 0) {
            let inner_ref: i32 = ast.ast_block_region_body_ref(arena, body_ref, ridx);
            if (!ast.ref_is_null(inner_ref)) {
              return func_body_tail_expr_ref_for_implicit_rule(arena, inner_ref);
            }
          }
        }
      }
    }
    if (!ast.ref_is_null(fin_ref)) {
      return fin_ref;
    }
    if (nso > 0) {
      let last_k2: u8 = ast.ast_block_stmt_order_kind(arena, body_ref, nso - 1);
      if (last_k2 == stmt_order_kind_expr_stmt) {
        let idx: i32 = ast.ast_block_stmt_order_idx(arena, body_ref, nso - 1);
        let nes: i32 = ast.ast_block_num_expr_stmts(arena, body_ref);
        if (idx >= 0 && idx < nes) {
          return ast.ast_block_expr_stmt_ref(arena, body_ref, idx);
        }
      }
      return 0;
    }
    let nes2: i32 = ast.ast_block_num_expr_stmts(arena, body_ref);
    if (nes2 > 0) {
      return ast.ast_block_expr_stmt_ref(arena, body_ref, nes2 - 1);
    }
    return 0;
  }
}

/**
* See implementation.
* See implementation.
*/
export function func_body_has_implicit_return_tail(arena: *ASTArena, body_ref: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (ast.ref_is_null(body_ref) || body_ref <= 0 || body_ref > arena.num_blocks) {
      return false;
    }
    return pipeline_typeck_func_body_has_implicit_return_tail_c(arena, body_ref) != 0;
  }
}

/**
 * See implementation.
 */
export function typeck_loop_depth_push(ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let saved: i32 = pipeline_dep_ctx_typeck_loop_depth_at(ctx);
    pipeline_typeck_loop_depth_set_c(ctx, saved + 1);
    return saved;
  }
}

/**
 * See implementation.
 */
export function typeck_loop_depth_pop(ctx: *PipelineDepCtx, saved: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    pipeline_typeck_loop_depth_set_c(ctx, saved);
  }
}

/**
 * See implementation.
 */
export function check_block_as_loop_body(module: *Module, arena: *ASTArena, body_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  let saved_ld: i32 = 0;
  let rc: i32 = 0;
  if (ctx == 0 as *PipelineDepCtx) {
    return -1;
  }
  saved_ld = typeck_loop_depth_push(ctx);
  rc = check_block(module, arena, body_ref, return_type_ref, ctx);
  typeck_loop_depth_pop(ctx, saved_ld);
  return rc;
}

/**
 * See implementation.
 */
export function typeck_check_block_one_const(module: *Module, arena: *ASTArena, block_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, idx: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let cd_ir: i32 = ast.ast_block_const_init_ref(arena, block_ref, idx);
    let cd_tr: i32 = ast.ast_block_const_type_ref(arena, block_ref, idx);
    let init_ty: i32 = 0;
    let init_ctx: i32 = 0;
    let cname_buf: u8[128];
    let cname_len: i32 = 0;
    let func_ix: i32 = 0;
    /*
     * wave680 Cap residual: same-block const redecl / clash with let / body-param.
     * Host-C BLD001 redefinition soft residual. Nested shadow OK.
     * G.7: pipeline_block_local_name_redecl_c + diag duplicate_local.
     */
    cname_len = pipeline_block_const_name_len(arena, block_ref, idx);
    if (cname_len > 0 && cname_len < 128) {
      pipeline_block_const_name_copy64(arena, block_ref, idx, &cname_buf[0]);
      func_ix = pipeline_dep_ctx_current_func_index(ctx);
      if (pipeline_block_local_name_redecl_c(arena, block_ref, &cname_buf[0], cname_len, 1, idx, module,
          func_ix) != 0) {
        let err_line: i32 = 0;
        let err_col: i32 = 0;
        if (!ast.ref_is_null(cd_ir)) {
          err_line = pipeline_expr_line_at(arena, cd_ir);
          err_col = pipeline_expr_col_at(arena, cd_ir);
        }
        driver_diagnostic_typeck_duplicate_local(err_line, err_col);
        return -1;
      }
    }
    /* See implementation. */
    if (!ast.ref_is_null(cd_ir)) {
      if (pipeline_typeck_block_const_init_is_const_c(arena, block_ref, idx) == 0) {
        let err_line: i32 = pipeline_expr_line_at(arena, cd_ir);
        let err_col: i32 = pipeline_expr_col_at(arena, cd_ir);
        pipeline_typeck_const_init_not_constant_c(err_line, err_col);
        return - 1;
      }
    }
    /*
     * wave423 Cap residual pure: const type inference.
     * Untyped `const name = init` (parser left type_ref null): check init with no
     * expected type, then stamp decl type from init via pipeline_block_set_const_type_ref.
     * Typed const still uses decl type as expected context + coerce.
     * G.7: typeck_check_block_one_const; twin typeck_gen + set_const_type_ref.
     * PLATFORM: SHARED typeck. return_type_ref unused for untyped path (kept in signature).
     */
    if (!ast.ref_is_null(cd_tr)) {
      init_ctx = cd_tr;
    } else {
      init_ctx = 0;
    }
    if (check_expr(module, arena, cd_ir, init_ctx, ctx) != 0) {
      return - 1;
    }
    if (!ast.ref_is_null(cd_ir) && ast.ref_is_null(cd_tr)) {
      init_ty = expr_type_ref(arena, cd_ir);
      if (ast.ref_is_null(init_ty)) {
        return - 1;
      }
      if (pipeline_block_set_const_type_ref(arena, block_ref, idx, init_ty) != 0) {
        return - 1;
      }
    } else if (!ast.ref_is_null(cd_ir) && !ast.ref_is_null(cd_tr)) {
      /* wave672: coerce may hard-fail ARRAY_LIT elem mismatch (-1). */
      if (typeck_coerce_init_expr_to_decl(module, arena, cd_ir, cd_tr) < 0) {
        return -1;
      }
      init_ty = expr_type_ref(arena, cd_ir);
      if (!ast.ref_is_null(init_ty) && !type_refs_equal(arena, cd_tr, init_ty)) {
        return - 1;
      }
    }
    /** CTFE: fold const init with prior block consts (A=3; B=A+2). */
    if (!ast.ref_is_null(cd_ir)) {
      pipeline_typeck_fold_block_const_init_c(arena, block_ref, idx);
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function typeck_check_block_one_let(module: *Module, arena: *ASTArena, block_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, idx: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ld_ir: i32 = ast.ast_block_let_init_ref(arena, block_ref, idx);
    let ld_tr: i32 = ast.ast_block_let_type_ref(arena, block_ref, idx);
    let init_ty: i32 = 0;
    let init_ctx: i32 = 0;
    let eb: *u8 = 0 as *u8;
    let gb: *u8 = 0 as *u8;
    let el: i32 = 0;
    let gl: i32 = 0;
    let lname_buf: u8[128];
    let lname_len: i32 = 0;
    let func_ix_l: i32 = 0;
    /*
     * wave680 Cap residual: same-block let redecl / clash with const / body-param.
     * Host-C BLD001 redefinition soft residual. Nested shadow OK.
     * G.7: pipeline_block_local_name_redecl_c + diag duplicate_local.
     */
    lname_len = pipeline_block_let_name_len(arena, block_ref, idx);
    if (lname_len > 0 && lname_len < 128) {
      pipeline_block_let_name_copy64(arena, block_ref, idx, &lname_buf[0]);
      func_ix_l = pipeline_dep_ctx_current_func_index(ctx);
      if (pipeline_block_local_name_redecl_c(arena, block_ref, &lname_buf[0], lname_len, 0, idx, module,
          func_ix_l) != 0) {
        let err_line: i32 = 0;
        let err_col: i32 = 0;
        if (!ast.ref_is_null(ld_ir)) {
          err_line = pipeline_expr_line_at(arena, ld_ir);
          err_col = pipeline_expr_col_at(arena, ld_ir);
        }
        driver_diagnostic_typeck_duplicate_local(err_line, err_col);
        return -1;
      }
    }
    /* See implementation. */
    if (!ast.ref_is_null(ld_ir)) {
      init_ctx = return_type_ref;
      if (!ast.ref_is_null(ld_tr)) {
        init_ctx = ld_tr;
      }
      /*
       * wave314: do not pass f64 expected when checking a bare f32 VAR init.
       * check_expr with expected f64 stamps VAR resolved as f64 → freestanding
       * load looks like f64 and skips cvtss2sd. Check with no expected type; let
       * widen gate below accepts f32→f64 without stamping.
       */
      if (!ast.ref_is_null(ld_tr) && pipeline_expr_kind_ord_at(arena, ld_ir) == 3) {
        let decl_k0: i32 = pipeline_type_kind_ord_at(arena, ld_tr);
        if (decl_k0 == 15) {
          init_ctx = 0;
        }
      }
      if (check_expr(module, arena, ld_ir, init_ctx, ctx) != 0) {
        return - 1;
      }
    }
    /* See implementation. */
    pipeline_type_stamp_block_let_region_c(arena, block_ref, idx, ctx);
    /* See implementation. */
    ld_tr = ast.ast_block_let_type_ref(arena, block_ref, idx);
    if (!ast.ref_is_null(ld_ir) && !ast.ref_is_null(ld_tr)) {
      /* wave672: coerce may hard-fail ARRAY_LIT elem mismatch (-1). */
      if (typeck_coerce_init_expr_to_decl(module, arena, ld_ir, ld_tr) < 0) {
        return -1;
      }
      init_ty = expr_type_ref(arena, ld_ir);
      /*
       * wave670 Cap residual: keyword `null` only for TYPE_PTR let-init.
       * Coerce leaves untyped null when decl is non-ptr → must hard-fail (init_ty=0
       * would soft-skip the equal check below). Bare INT 0 still coerces.
       */
      if (typeck_expr_is_null_keyword(arena, ld_ir) != 0
      && pipeline_type_kind_ord_at(arena, ld_tr) != 9) {
        eb = driver_typeck_diag_scratch_expect();
        gb = driver_typeck_diag_scratch_found();
        el = typeck_diag_fmt_type_into(arena, ld_tr, eb, 96);
        gl = typeck_diag_append_lit(gb, 0, 96, "null", 4);
        {
          let err_line: i32 = pipeline_expr_line_at(arena, ld_ir);
          let err_col: i32 = pipeline_expr_col_at(arena, ld_ir);
          driver_diagnostic_typeck_assign_mismatch(0, err_line, err_col, eb, el, gb, gl);
        }
        return -1;
      }
      /* See implementation. */
      if (!ast.ref_is_null(init_ty) && !type_refs_equal(arena, ld_tr, init_ty)) {
        /* wave313: refs path closes NAMED i8/i16/u16 let-init widen (e.g. i16→i32). */
        if (typeck_integer_widen_ok_refs(arena, ld_tr, init_ty)) {
          pipeline_expr_set_resolved_type_ref(arena, ld_ir, ld_tr);
          init_ty = ld_tr;
        }
        /* wave314: f32→f64 accepted without stamping resolved type.
         * Freestanding emit needs true f32 bits then cvtss2sd; stamping VAR as f64
         * zero-extends IEEE f32 bits and yields run=0 (Ubuntu gold). */
      }
      if (!ast.ref_is_null(init_ty) && !type_refs_equal(arena, ld_tr, init_ty)
          && pipeline_typeck_linear_accepts_init_c(arena, ld_tr, init_ty) == 0) {
        let decl_k2: i32 = pipeline_type_kind_ord_at(arena, ld_tr);
        let init_k2: i32 = pipeline_type_kind_ord_at(arena, init_ty);
        if (!typeck_float_widen_ok(decl_k2, init_k2)) {
          eb = driver_typeck_diag_scratch_expect();
          gb = driver_typeck_diag_scratch_found();
          el = typeck_diag_fmt_type_into(arena, ld_tr, eb, 96);
          gl = typeck_diag_fmt_type_into(arena, init_ty, gb, 96);
          let err_line: i32 = pipeline_expr_line_at(arena, ld_ir);
          let err_col: i32 = pipeline_expr_col_at(arena, ld_ir);
          driver_diagnostic_typeck_assign_mismatch(0, err_line, err_col, eb, el, gb, gl);
          return - 1;
        }
        /* match via f32→f64; leave init_ty as f32 for freestanding cvtss2sd. */
      }
      /* See implementation. */
      if (!ast.ref_is_null(init_ty) && pipeline_typeck_check_slice_region_assign_c(arena, ld_ir, ld_tr, init_ty) != 0) {
        return - 1;
      }
    }
    /** CTFE: re-fold let init with block const env (e.g. let x = B * 2). */
    if (!ast.ref_is_null(ld_ir)) {
      pipeline_typeck_fold_expr_in_block_c(arena, block_ref, ld_ir);
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function typeck_check_block_one_while(module: *Module, arena: *ASTArena, block_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, idx: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let wc: i32 = ast.ast_block_while_cond_ref(arena, block_ref, idx);
    let wb: i32 = ast.ast_block_while_body_ref(arena, block_ref, idx);
    if (!ast.ref_is_null(wc)) {
      /* wave704: while cond ambient = 0 (bool). */
      if (check_expr(module, arena, wc, 0, ctx) != 0) {
        return - 1;
      }
      if (!type_ref_is_bool(arena, expr_type_ref(arena, wc))) {
        driver_diagnostic_typeck_while_condition_not_bool(pipeline_expr_line_at(arena, wc),
        pipeline_expr_col_at(arena, wc));
        return - 1;
      }
    }
    return check_block_as_loop_body(module, arena, wb, return_type_ref, ctx);
  }
}

/**
 * See implementation.
 */
export function typeck_check_block_one_for(module: *Module, arena: *ASTArena, block_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, idx: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let fi_ir: i32 = ast.ast_block_for_init_ref(arena, block_ref, idx);
    let fc_cr: i32 = ast.ast_block_for_cond_ref(arena, block_ref, idx);
    let fs_sr: i32 = ast.ast_block_for_step_ref(arena, block_ref, idx);
    let fb_br: i32 = ast.ast_block_for_body_ref(arena, block_ref, idx);
    if (check_expr(module, arena, fi_ir, return_type_ref, ctx) != 0) {
      return - 1;
    }
    if (!ast.ref_is_null(fc_cr)) {
      /* wave704: for cond ambient = 0 (bool). */
      if (check_expr(module, arena, fc_cr, 0, ctx) != 0) {
        return - 1;
      }
      if (!type_ref_is_bool(arena, expr_type_ref(arena, fc_cr))) {
        driver_diagnostic_typeck_for_condition_not_bool(pipeline_expr_line_at(arena, fc_cr),
        pipeline_expr_col_at(arena, fc_cr));
        return - 1;
      }
    }
    if (check_expr(module, arena, fs_sr, return_type_ref, ctx) != 0) {
      return - 1;
    }
    return check_block_as_loop_body(module, arena, fb_br, return_type_ref, ctx);
  }
}

/**
 * See implementation.
 */
export function typeck_check_block_one_if(module: *Module, arena: *ASTArena, block_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, idx: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ic_cr: i32 = ast.ast_block_if_cond_ref(arena, block_ref, idx);
    let ib_tr: i32 = ast.ast_block_if_then_body_ref(arena, block_ref, idx);
    let ib_er: i32 = 0;
    if (!ast.ref_is_null(ic_cr)) {
      /* wave704: block-if cond ambient = 0 (bool). */
      if (check_expr(module, arena, ic_cr, 0, ctx) != 0) {
        return - 1;
      }
      if (!type_ref_is_bool(arena, expr_type_ref(arena, ic_cr))) {
        typeck_driver_diagnostic_pipe_marker(pipeline_expr_kind_ord_at(arena, ic_cr));
        typeck_driver_diagnostic_pipe_marker(pipeline_type_kind_ord_at(arena, expr_type_ref(arena, ic_cr)));
        driver_diagnostic_typeck_if_condition_not_bool(pipeline_expr_line_at(arena, ic_cr),
        pipeline_expr_col_at(arena, ic_cr));
        return - 1;
      }
    }
    if (check_block(module, arena, ib_tr, return_type_ref, ctx) != 0) {
      return - 1;
    }
    ib_er = ast.ast_block_if_else_body_ref(arena, block_ref, idx);
    if (!ast.ref_is_null(ib_er)) {
      return check_block(module, arena, ib_er, return_type_ref, ctx);
    }
    return 0;
  }
}

/**
 * wave663 Cap residual: hard-fail a value-producing expression used as a statement
 * or final_expr inside a void function.
 *
 * Parser often lowers `return e` / bare `e` in void functions to a non-RETURN
 * expr_stmt or final_expr; host-C then emits `(void)(e)` without typeck error.
 * Allow statement-like kinds: bare RETURN, CALL, METHOD_CALL, ASSIGN*,
 * BREAK, CONTINUE, PANIC, IF, BLOCK, MATCH.
 *
 * wave1227 root fix: if the expression already resolved to TYPE_VOID, it is not a
 * value-producing rvalue — accept it. Prior allowlist missed EXPR_IF/EXPR_BLOCK/
 * EXPR_MATCH as statements, which produced the false positive
 * "return expression type mismatch: expected void, found void" (same type ref on
 * both sides; e.g. `driver_parsed_work_cleanup` with nested `if` expr_stmts).
 *
 * @param arena *ASTArena — holds expr_ref and return_type_ref
 * @param expr_ref i32 — candidate expression (final or expr_stmt)
 * @param return_type_ref i32 — enclosing function return type
 * @return i32 — 0 ok (not void, or statement-like / void-typed), -1 void value rejected
 * PLATFORM: SHARED — typeck.x + typeck_gen + empty_surface same commit.
 */
export function typeck_void_reject_value_expr(arena: *ASTArena, expr_ref: i32,
return_type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let void_ord: i32 = 16;
    let rt_k: i32 = 0;
    let ek: i32 = 0;
    let void_stmt_ok: i32 = 0;
    let got: i32 = 0;
    let got_k: i32 = 0;
    let eb: *u8 = 0 as *u8;
    let gb: *u8 = 0 as *u8;
    let el: i32 = 0;
    let gl: i32 = 0;
    let line: i32 = 0;
    let col: i32 = 0;
    if (arena == 0 as *ASTArena || expr_ref <= 0 || ast.ref_is_null(return_type_ref)) {
      return 0;
    }
    rt_k = pipeline_type_kind_ord_at(arena, return_type_ref);
    if (rt_k != void_ord) {
      return 0;
    }
    ek = pipeline_expr_kind_ord_at(arena, expr_ref);
    /* ExprKind ordinals: IF=25 BLOCK=26 ASSIGN..=28..38 BREAK=39 CONTINUE=40
     * RETURN=41 PANIC=42 MATCH=43 CALL=48 METHOD_CALL=49. */
    if (ek == 41) {
      if (ast.ref_is_null(pipeline_expr_unary_operand_ref_at(arena, expr_ref))) {
        void_stmt_ok = 1;
      }
    } else if (ek == 48 || ek == 49 || ek == 39 || ek == 40 || ek == 42) {
      void_stmt_ok = 1;
    } else if (ek >= 28 && ek <= 38) {
      void_stmt_ok = 1;
    } else if (ek == 25 || ek == 26 || ek == 43) {
      void_stmt_ok = 1;
    }
    if (void_stmt_ok != 0) {
      return 0;
    }
    got = expr_type_ref(arena, expr_ref);
    /*
     * wave1227: void-typed expression is statement-shaped, not a value rvalue.
     * Closes expected-void/found-void FP when kind allowlist lags (if/block/match).
     */
    if (!ast.ref_is_null(got)) {
      got_k = pipeline_type_kind_ord_at(arena, got);
      if (got_k == void_ord) {
        return 0;
      }
    }
    eb = driver_typeck_diag_scratch_expect();
    gb = driver_typeck_diag_scratch_found();
    el = typeck_diag_fmt_type_or_question(arena, return_type_ref, eb);
    gl = typeck_diag_fmt_type_or_question(arena, got, gb);
    line = pipeline_expr_line_at(arena, expr_ref);
    col = pipeline_expr_col_at(arena, expr_ref);
    driver_diagnostic_typeck_return_mismatch(line, col, eb, el, gb, gl);
    typeck_emit_return_subexpr_breadcrumb(arena, expr_ref, line, col);
    driver_diagnostic_typeck_ret_fail(2, expr_ref, return_type_ref, got);
    return - 1;
  }
}

/**
 * Type-check a block's final expression against the enclosing function return type.
 * @param module *Module — current module (unused except via check_expr callees)
 * @param arena *ASTArena — expression/type arena; must hold fin0
 * @param block_ref i32 — block owning the final (diagnostics / parent links)
 * @param return_type_ref i32 — function return type; 0 skips match
 * @param ctx *PipelineDepCtx — typeck context (unsafe depth, current func)
 * @param fin0 i32 — final_expr ref; null → no-op
 * @return i32 — 0 ok, -1 type error
 * wave663: also rejects void value finals via typeck_void_reject_value_expr.
 * PLATFORM: SHARED — typeck.x + typeck_gen + empty_surface same commit.
 */
export function typeck_check_block_final(module: *Module, arena: *ASTArena, block_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, fin0: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let skip_tail_ty_cmp: bool = false;
    let fin_k_tail: i32 = 0;
    let got: i32 = 0;
    let fin_op: i32 = 0;
    let fin_k_ret: i32 = 0;
    let eb_fin: *u8 = 0 as *u8;
    let gb_fin: *u8 = 0 as *u8;
    let el_fin: i32 = 0;
    let gl_fin: i32 = 0;
    if (ast.ref_is_null(fin0)) {
      return 0;
    }
    if (check_expr(module, arena, fin0, return_type_ref, ctx) != 0) {
      return - 1;
    }
    if (typeck_void_reject_value_expr(arena, fin0, return_type_ref) != 0) {
      return - 1;
    }
    fin_k_tail = pipeline_expr_kind_ord_at(arena, fin0);
/** See implementation for details. */
    if (fin_k_tail != 41) {
      skip_tail_ty_cmp = true;
    } else if (ast.ref_is_null(pipeline_expr_unary_operand_ref_at(arena, fin0))) {
      skip_tail_ty_cmp = true;
    }
    if (ast.ref_is_null(return_type_ref) || skip_tail_ty_cmp) {
      return 0;
    }
    got = expr_type_ref(arena, fin0);
    fin_op = fin0;
    fin_k_ret = pipeline_expr_kind_ord_at(arena, fin0);
    if (fin_k_ret == 41) {
      fin_op = pipeline_expr_unary_operand_ref_at(arena, fin0);
    }
    /* See implementation. */
    if (!ast.ref_is_null(fin_op) && fin_op > 0 && !ast.ref_is_null(return_type_ref)) {
      typeck_ret_coerce_integral_to_expect_i32(arena, fin_op, return_type_ref);
      typeck_ret_coerce_integral_widen(arena, fin_op, return_type_ref);
    }
    if (typeck_return_operand_matches(arena, fin_op, return_type_ref)) {
      return 0;
    }
    /* See implementation. */
    if (!ast.ref_is_null(fin_op) && fin_op > 0 && !ast.ref_is_null(return_type_ref)) {
      let fin_got: i32 = expr_type_ref(arena, fin_op);
      let ek_fin: i32 = 0;
      let gk_fin: i32 = 0;
      if (!ast.ref_is_null(fin_got) && fin_got > 0) {
        ek_fin = pipeline_type_kind_ord_at(arena, return_type_ref);
        gk_fin = pipeline_type_kind_ord_at(arena, fin_got);
        if (typeck_integer_widen_ok_refs(arena, return_type_ref, fin_got) ||
            typeck_float_widen_ok(ek_fin, gk_fin)) {
          pipeline_expr_set_resolved_type_ref(arena, fin_op, return_type_ref);
          return 0;
        }
      }
    }
    eb_fin = driver_typeck_diag_scratch_expect();
    gb_fin = driver_typeck_diag_scratch_found();
    el_fin = typeck_diag_fmt_type_or_question(arena, return_type_ref, eb_fin);
    gl_fin = typeck_diag_fmt_type_or_question(arena, got, gb_fin);
    let err_line: i32 = pipeline_expr_line_at(arena, fin0);
    let err_col: i32 = pipeline_expr_col_at(arena, fin0);
    driver_diagnostic_typeck_return_mismatch(err_line, err_col, eb_fin, el_fin, gb_fin, gl_fin);
    typeck_emit_return_subexpr_breadcrumb(arena, fin0, err_line, err_col);
    return - 1;
  }
}

/**
 * See implementation.
 */
export function typeck_check_block_one_region(module: *Module, arena: *ASTArena, block_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, idx: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    return pipeline_typeck_check_block_one_region_c(module, arena, block_ref, idx, return_type_ref, ctx);
  }
}

/**
 * See implementation.
 */
export function typeck_check_block_stmt_order_one(module: *Module, arena: *ASTArena, block_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, si: i32, nso: i32, nc: i32, nl: i32, nes: i32,
nlp: i32, nfp: i32, nif: i32, nreg: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let sk: u8 = (0 as u8);
    let idx: i32 = 0;
    let es_ref: i32 = 0;
    if (si >= nso || si >= 96) {
      return 0;
    }
    pipeline_typeck_block_impl_touch_ctx_block_c(ctx, block_ref);
    sk = ast.ast_block_stmt_order_kind(arena, block_ref, si);
    idx = ast.ast_block_stmt_order_idx(arena, block_ref, si);
    if (sk == (0 as u8)) {
      if (idx >= 0 && idx < nc && idx < 128) {
        if (typeck_check_block_one_const(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {
          return - 1;
        }
      }
    } else if (sk == (1 as u8)) {
      if (idx >= 0 && idx < nl && idx < 128) {
        if (typeck_check_block_one_let(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {
          return - 1;
        }
      }
    } else if (sk == (2 as u8)) {
      if (idx >= 0 && idx < nes) {
        es_ref = ast.ast_block_expr_stmt_ref(arena, block_ref, idx);
        if (check_expr(module, arena, es_ref, return_type_ref, ctx) != 0) {
          return - 1;
        }
        /* wave663: void function expr_stmt value (return e lowered to e). */
        if (typeck_void_reject_value_expr(arena, es_ref, return_type_ref) != 0) {
          return - 1;
        }
      }
    } else if (sk == (3 as u8)) {
      if (idx >= 0 && idx < nlp) {
        if (typeck_check_block_one_while(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {
          return - 1;
        }
      }
    } else if (sk == (4 as u8)) {
      if (idx >= 0 && idx < nfp) {
        if (typeck_check_block_one_for(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {
          return - 1;
        }
      }
    } else if (sk == (5 as u8)) {
      if (idx >= 0 && idx < nif) {
        if (typeck_check_block_one_if(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {
          return - 1;
        }
      }
    } else if (sk == (6 as u8)) {
      if (idx >= 0 && idx < nreg) {
        if (typeck_check_block_one_region(module, arena, block_ref, return_type_ref, ctx, idx) != 0) {
          return - 1;
        }
      }
    }
    return typeck_check_block_stmt_order_one(module, arena, block_ref, return_type_ref, ctx, si + 1, nso,
    nc, nl, nes, nlp, nfp, nif, nreg);
  }
}

/* See implementation. */
export function typeck_check_block_legacy_consts(module: *Module, arena: *ASTArena, block_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, i: i32, nc: i32): i32 {
  if (i >= nc) {
    return 0;
  }
  if (typeck_check_block_one_const(module, arena, block_ref, return_type_ref, ctx, i) != 0) {
    return - 1;
  }
  return typeck_check_block_legacy_consts(module, arena, block_ref, return_type_ref, ctx, i + 1, nc);
}

/* See implementation. */
export function typeck_check_block_legacy_lets(module: *Module, arena: *ASTArena, block_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, i: i32, nl: i32): i32 {
  if (i >= nl) {
    return 0;
  }
  if (typeck_check_block_one_let(module, arena, block_ref, return_type_ref, ctx, i) != 0) {
    return - 1;
  }
  return typeck_check_block_legacy_lets(module, arena, block_ref, return_type_ref, ctx, i + 1, nl);
}

/* See implementation. */
export function typeck_check_block_legacy_whiles(module: *Module, arena: *ASTArena, block_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, i: i32, nlp: i32): i32 {
  if (i >= nlp) {
    return 0;
  }
  if (typeck_check_block_one_while(module, arena, block_ref, return_type_ref, ctx, i) != 0) {
    return - 1;
  }
  return typeck_check_block_legacy_whiles(module, arena, block_ref, return_type_ref, ctx, i + 1, nlp);
}

/* See implementation. */
export function typeck_check_block_legacy_fors(module: *Module, arena: *ASTArena, block_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, i: i32, nfp: i32): i32 {
  if (i >= nfp) {
    return 0;
  }
  if (typeck_check_block_one_for(module, arena, block_ref, return_type_ref, ctx, i) != 0) {
    return - 1;
  }
  return typeck_check_block_legacy_fors(module, arena, block_ref, return_type_ref, ctx, i + 1, nfp);
}

/* See implementation. */
export function typeck_check_block_legacy_ifs(module: *Module, arena: *ASTArena, block_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, i: i32, nif: i32): i32 {
  if (i >= nif) {
    return 0;
  }
  if (typeck_check_block_one_if(module, arena, block_ref, return_type_ref, ctx, i) != 0) {
    return - 1;
  }
  return typeck_check_block_legacy_ifs(module, arena, block_ref, return_type_ref, ctx, i + 1, nif);
}

/* See implementation. */
export function typeck_check_block_legacy_expr_stmts(module: *Module, arena: *ASTArena, block_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx, i: i32, nes: i32): i32 {
  let es_ref: i32 = 0;
  if (i >= nes || i >= 32) {
    return 0;
  }
  es_ref = ast.ast_block_expr_stmt_ref(arena, block_ref, i);
  if (check_expr(module, arena, es_ref, return_type_ref, ctx) != 0) {
    return - 1;
  }
  /* wave663: void function expr_stmt value (return e lowered to e). */
  if (typeck_void_reject_value_expr(arena, es_ref, return_type_ref) != 0) {
    return - 1;
  }
  return typeck_check_block_legacy_expr_stmts(module, arena, block_ref, return_type_ref, ctx, i + 1, nes);
}

/**
 * See implementation.
 */
export function check_block_impl(module: *Module, arena: *ASTArena, block_ref: i32, return_type_ref: i32,
ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let saved_block_ref: i32 = 0;
    let nc: i32 = 0;
    let nl: i32 = 0;
    let nlp: i32 = 0;
    let nfp: i32 = 0;
    let nif: i32 = 0;
    let nreg: i32 = 0;
    let nes: i32 = 0;
    let nso: i32 = 0;
    let fin0: i32 = 0;
    let func_ix: i32 = 0;
    if (arena == 0 as *ASTArena || ctx == 0 as *PipelineDepCtx || block_ref <= 0) {
      return - 1;
    }
    saved_block_ref = pipeline_typeck_block_impl_bind_ctx_c(ctx, block_ref);
    /* parent_block_ref: pipeline_patch_block_parent_links covers while/for/if/region bodies,
       but not block-expr cases (blocks tied via pipeline_expr_block_ref_at).
       saved_block_ref is current_block_ref before entering this block = direct parent. */
    pipeline_block_set_parent_if_zero(arena, block_ref, saved_block_ref);
    nc = ast.ast_block_num_consts(arena, block_ref);
    nl = ast.ast_block_num_lets(arena, block_ref);
    nlp = ast.ast_block_num_loops(arena, block_ref);
    nfp = ast.ast_block_num_for_loops(arena, block_ref);
    nif = ast.ast_block_num_if_stmts(arena, block_ref);
    nreg = ast.ast_block_num_regions(arena, block_ref);
    nes = ast.ast_block_num_expr_stmts(arena, block_ref);
    nso = ast.ast_block_num_stmt_order(arena, block_ref);
    fin0 = ast.ast_block_final_expr_ref(arena, block_ref);
    func_ix = pipeline_dep_ctx_current_func_index(ctx);
    driver_diagnostic_typeck_block_enter(func_ix, block_ref, nc, nl, nlp, nfp, nes, fin0);
    if (nso > 0) {
      if (typeck_check_block_stmt_order_one(module, arena, block_ref, return_type_ref, ctx, 0, nso, nc, nl,
      nes, nlp, nfp, nif, nreg) != 0) {
        pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
        return - 1;
      }
    } else {
      if (typeck_check_block_legacy_consts(module, arena, block_ref, return_type_ref, ctx, 0, nc) != 0) {
        pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
        return - 1;
      }
      if (typeck_check_block_legacy_lets(module, arena, block_ref, return_type_ref, ctx, 0, nl) != 0) {
        pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
        return - 1;
      }
      if (typeck_check_block_legacy_whiles(module, arena, block_ref, return_type_ref, ctx, 0, nlp) != 0) {
        pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
        return - 1;
      }
      if (typeck_check_block_legacy_fors(module, arena, block_ref, return_type_ref, ctx, 0, nfp) != 0) {
        pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
        return - 1;
      }
      if (typeck_check_block_legacy_ifs(module, arena, block_ref, return_type_ref, ctx, 0, nif) != 0) {
        pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
        return - 1;
      }
      if (typeck_check_block_legacy_expr_stmts(module, arena, block_ref, return_type_ref, ctx, 0, nes) != 0) {
        pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
        return - 1;
      }
    }
    if (typeck_check_block_final(module, arena, block_ref, return_type_ref, ctx, fin0) != 0) {
      pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
      return - 1;
    }
    pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
    return 0;
  }
}

/**
 * See implementation.
 */
export function check_block(module: *Module, arena: *ASTArena, block_ref: i32, return_type_ref: i32,
ctx: *PipelineDepCtx): i32 {
  if (ast.ref_is_null(block_ref)) {
    return 0;
  }
  if (arena == 0 as *ASTArena || block_ref <= 0 || block_ref > arena.num_blocks) {
    return 0;
  }
  return check_block_impl(module, arena, block_ref, return_type_ref, ctx);
}

/**
 * See implementation.
 */
export function typeck_x_ast_check_one_func(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx, func_idx: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let body_ref: i32 = 0;
    let ret_ty_ref: i32 = 0;
    let fn_name_len: i32 = 0;
    let num_generic_params: i32 = 0;
    let ord_void: i32 = 16;
    let rt_kind: i32 = 0;
    let err_check_block: i32 = 5;
    let err_implicit_tail: i32 = 6;
    if (module == 0 as *Module || arena == 0 as *ASTArena || ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    fn_name_len = pipeline_module_func_name_len_at(module, func_idx);
    pipeline_module_func_name_copy64(module, func_idx, typeck_scratch64_slot(0));
    driver_diagnostic_typeck_fn_enter(func_idx, typeck_scratch64_slot(0), fn_name_len);
    pipeline_typeck_linear_reset_c();
    /* wave684 Cap residual: typecheck generic function bodies too.
     * Prior skip (num_generic_params > 0 → return 0) left free-T / Wrap<T>
     * bodies unchecked: unknown fields, concrete S.nope, and other typeck
     * errors soft-greened until (if ever) monomorphized. Free type-params
     * stay TYPE_NAMED without layout; field gate hard-fails them (wave684).
     * Keep checking: id/geta/return of T, Wrap.val mono, concrete layouts. */
    num_generic_params = pipeline_module_func_num_generic_params_at(module, func_idx);
    /* wave1219: removed (void)num_generic_params — C-style cast unsupported in X. */
    body_ref = pipeline_module_func_body_ref_at(module, func_idx);
    if (ast.ref_is_null(body_ref) || pipeline_module_func_is_extern_at(module, func_idx) != 0) {
      return 0;
    }
    ret_ty_ref = pipeline_module_func_return_type_at(module, func_idx);
    if (check_block(module, arena, body_ref, ret_ty_ref, ctx) != 0) {
      fn_name_len = pipeline_module_func_name_len_at(module, func_idx);
      pipeline_module_func_name_copy64(module, func_idx, typeck_scratch64_slot(0));
      /* See implementation. */
      let fail_kind_cb: i32 = -5;
      driver_diagnostic_typeck_func_fail(func_idx, typeck_scratch64_slot(0), fn_name_len, fail_kind_cb);
      return fail_kind_cb;
    }
    if (!ast.ref_is_null(ret_ty_ref)) {
      rt_kind = pipeline_type_kind_ord_at(arena, ret_ty_ref);
      if (rt_kind != ord_void && func_body_has_implicit_return_tail(arena, body_ref)) {
        fn_name_len = pipeline_module_func_name_len_at(module, func_idx);
        pipeline_module_func_name_copy64(module, func_idx, typeck_scratch64_slot(0));
        let fail_kind_tail: i32 = -6;
        driver_diagnostic_typeck_func_fail(func_idx, typeck_scratch64_slot(0), fn_name_len, fail_kind_tail);
        return fail_kind_tail;
      }
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function typeck_x_ast_check_all_funcs_loop(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx,
func_i: i32, num_funcs: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let body_ref: i32 = 0;
    let ret_ty_ref: i32 = 0;
    let fn_name_len: i32 = 0;
    let num_generic_params: i32 = 0;
    let ord_void: i32 = 16;
    let rt_kind: i32 = 0;
    let rc: i32 = 0;
    let err_check_block: i32 = 5;
    let err_implicit_tail: i32 = 6;
    /* See implementation. */
    let no_func_ix: i32 = -1;
    if (func_i >= num_funcs) {
      pipeline_dep_ctx_set_current_func_index(ctx, no_func_ix);
      return 0;
    }
    if (func_i == 0) {
      pipeline_typeck_set_entry_module_for_dep_map_c(module);
    }
    pipeline_dep_ctx_set_current_func_index(ctx, func_i);
    fn_name_len = pipeline_module_func_name_len_at(module, func_i);
    pipeline_module_func_name_copy64(module, func_i, typeck_scratch64_slot(0));
    driver_diagnostic_typeck_fn_enter(func_i, typeck_scratch64_slot(0), fn_name_len);
    /* wave684: do not skip generic bodies (see typeck_x_ast_check_one_func). */
    num_generic_params = pipeline_module_func_num_generic_params_at(module, func_i);
    /* wave1219: removed (void)num_generic_params — C-style cast unsupported in X. */
    body_ref = pipeline_module_func_body_ref_at(module, func_i);
    if (!ast.ref_is_null(body_ref) && pipeline_module_func_is_extern_at(module, func_i) == 0) {
      ret_ty_ref = pipeline_module_func_return_type_at(module, func_i);
      if (check_block(module, arena, body_ref, ret_ty_ref, ctx) != 0) {
        fn_name_len = pipeline_module_func_name_len_at(module, func_i);
        pipeline_module_func_name_copy64(module, func_i, typeck_scratch64_slot(0));
        let fail_kind_cb: i32 = -5;
        driver_diagnostic_typeck_func_fail(func_i, typeck_scratch64_slot(0), fn_name_len, fail_kind_cb);
        pipeline_dep_ctx_set_current_func_index(ctx, no_func_ix);
        return fail_kind_cb;
      }
      if (!ast.ref_is_null(ret_ty_ref)) {
        rt_kind = pipeline_type_kind_ord_at(arena, ret_ty_ref);
        if (rt_kind != ord_void && func_body_has_implicit_return_tail(arena, body_ref)) {
          fn_name_len = pipeline_module_func_name_len_at(module, func_i);
          pipeline_module_func_name_copy64(module, func_i, typeck_scratch64_slot(0));
          let fail_kind_tail: i32 = -6;
          driver_diagnostic_typeck_func_fail(func_i, typeck_scratch64_slot(0), fn_name_len, fail_kind_tail);
          pipeline_dep_ctx_set_current_func_index(ctx, no_func_ix);
          return fail_kind_tail;
        }
      }
    }
    pipeline_dep_ctx_set_current_func_index(ctx, no_func_ix);
    rc = typeck_x_ast_check_all_funcs_loop(module, arena, ctx, func_i + 1, num_funcs);
    return rc;
  }
}

/**
 * See implementation.
 */
export function typeck_patch_all_body_parent_links(module: *Module, arena: *ASTArena): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let i: i32 = 0;
    let num: i32 = 0;
    let br: i32 = 0;
    if (module == 0 as *Module || arena == 0 as *ASTArena) {
      return;
    }
    num = pipeline_module_num_funcs(module);
    while (i < num) {
      br = pipeline_module_func_body_ref_at(module, i);
      if (!ast.ref_is_null(br)) {
        pipeline_patch_block_parent_links(arena, br, 0);
      }
      i = i + 1;
    }
  }
}

/**
 * See implementation.
 */
/**
 * wave421: product-path trait completeness (skip_tl registry filled at parse).
 * @param module *Module — entry module after parse_into
 * @return i32 — 0 ok; -1 missing method (diagnostic emitted)
 * PLATFORM: SHARED typeck
 */
export extern function xlang_trait_check_impls_complete_c(module: *Module): i32;

export function typeck_x_ast_impl(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let mi: i32 = 0;
    let ret_kind: i32 = 0;
    let ord_i32: i32 = 0;
    let ord_i64: i32 = 5;
    let ord_void: i32 = 16;
    let main_num_generic_params: i32 = 0;
    let body_ref: i32 = 0;
    let body_expr_ref: i32 = 0;
    let ret_ty: i32 = 0;
    let num_funcs: i32 = 0;
    let pipe_marker_ret_ty_ready: i32 = 301;
    let pipe_marker_main_generic_checked: i32 = 302;
    let pipe_marker_layout_validated: i32 = 303;
    let pipe_marker_parent_links_patched: i32 = 304;
    let pipe_marker_main_generic_base: i32 = 320;
    if (module == 0 as *Module || arena == 0 as *ASTArena || ctx == 0 as *PipelineDepCtx) {
      return -2;
    }
    /* wave421 Cap residual pure — missing method before per-func check_block.
     * Root: incomplete impl Trait for T was false-green (only free-fn hoist).
     * G.7: xlang_trait_check_impls_complete_c (skip_tl registry). Soft: bounds/dyn. */
    if (xlang_trait_check_impls_complete_c(module) != 0) {
      return -1;
    }
    mi = pipeline_module_main_func_index(module);
    if (pipeline_module_func_is_extern_at(module, mi) != 0
    && ast.ref_is_null(pipeline_module_func_body_ref_at(module, mi))) {
      return -1;
    }
    body_ref = pipeline_module_func_body_ref_at(module, mi);
    body_expr_ref = pipeline_module_func_body_expr_ref_at(module, mi);
    if (ast.ref_is_null(body_ref) && ast.ref_is_null(body_expr_ref)) {
      return -2;
    }
    ret_ty = pipeline_module_func_return_type_at(module, mi);
    if (ast.ref_is_null(ret_ty)) {
      return -3;
    }
    typeck_driver_diagnostic_pipe_marker(pipe_marker_ret_ty_ready);
    main_num_generic_params = pipeline_module_func_num_generic_params_at(module, mi);
    typeck_driver_diagnostic_pipe_marker(pipe_marker_main_generic_base + main_num_generic_params);
    if (main_num_generic_params > 0) {
      return -12;
    }
    typeck_driver_diagnostic_pipe_marker(pipe_marker_main_generic_checked);
    /* PLATFORM: SHARED — process entry may be i32/i64 (exit code) or void (Zig-like
     * implicit exit 0). Codegen maps void main → C int32_t main + return 0. */
    ret_kind = pipeline_type_kind_ord_at(arena, ret_ty);
    if (ret_kind != ord_i32 && ret_kind != ord_i64 && ret_kind != ord_void) {
      return -4;
    }
    if (typeck_validate_struct_layouts_zero_padding(module, arena) != 0) {
      return -7;
    }
    typeck_driver_diagnostic_pipe_marker(pipe_marker_layout_validated);
    typeck_patch_all_body_parent_links(module, arena);
    typeck_driver_diagnostic_pipe_marker(pipe_marker_parent_links_patched);
    num_funcs = pipeline_module_num_funcs(module);
    return typeck_x_ast_check_all_funcs_loop(module, arena, ctx, 0, num_funcs);
  }
}

/**
 * See implementation.
 */
export function typeck_x_ast_library(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let num_funcs: i32 = 0;
    if (module == 0 as *Module || arena == 0 as *ASTArena || ctx == 0 as *PipelineDepCtx) {
      return -5;
    }
    if (typeck_validate_struct_layouts_zero_padding(module, arena) != 0) {
      return -7;
    }
    typeck_patch_all_body_parent_links(module, arena);
    num_funcs = pipeline_module_num_funcs(module);
    return typeck_x_ast_check_all_funcs_loop(module, arena, ctx, 0, num_funcs);
  }
}

/**
 * See implementation.
 */
export function typeck_x_ast(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let mi: i32 = 0;
    let num_funcs: i32 = 0;
    if (module == 0 as *Module) {
      return -10;
    }
    mi = pipeline_module_main_func_index(module);
    num_funcs = pipeline_module_num_funcs(module);
    if (mi < 0) {
      return -10;
    }
    if (mi >= num_funcs) {
      return -11;
    }
    return typeck_x_ast_impl(module, arena, ctx);
  }
}
