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
/* See implementation. */
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
/* See implementation. */
export extern function pipeline_typeck_type_refs_equal_c(arena: *ASTArena, a: i32, b: i32): i32;
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
export extern function typeck_soa_array_storage_size_glue(module: *Module, arena: *ASTArena, elem_type_ref: i32,
  array_len: i32, depth: i32): i32;
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
export extern function pipeline_expr_field_access_is_enum_variant(arena: *ASTArena, expr_ref: i32): i32;
/* See implementation. */
export extern function pipeline_expr_set_field_access_enum_variant(arena: *ASTArena, expr_ref: i32,
tag: i32): void;
export extern function pipeline_expr_method_call_arg_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_match_arm_result_ref(arena: *ASTArena, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_match_arm_is_enum_variant(arena: *ASTArena, expr_ref: i32,
i: i32): i32;
export extern function pipeline_expr_match_arm_variant_index(arena: *ASTArena, expr_ref: i32, i: i32): i32;
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
    let type_name: u8[64] = [];
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
      if (alias_name_len == type_name_len && alias_name_len > 0 && alias_name_len <= 63) {
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
    let decl_name: u8[64] = [];
    let alias_name: u8[64] = [];
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
      if (alias_name_len == decl_name_len && alias_name_len > 0 && alias_name_len <= 63) {
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
    if (pl <= 0 || pl > 63) {
      return 0;
    }
    while (i < pl) {
      if (pipeline_module_import_path_byte_at(module, imp_ix, i) == 46) {
        start = i + 1;
      }
      i = i + 1;
    }
    seg_len = pl - start;
    if (seg_len <= 0 || seg_len > 63) {
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
    let path_buf: u8[64] = [];
    if (module == 0 as *Module || ctx == 0 as *PipelineDepCtx || imp_ix < 0 || imp_ix >= typeck_module_num_imports(module)) {
      return -1;
    }
    plen = pipeline_module_import_path_len(module, imp_ix);
    if (plen <= 0 || plen > 63) {
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
        let dep_buf: u8[64] = [];
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
      if (bl > 0 && bl <= 63) {
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
  if (nm == 0 as * u8 || nlen <= 0) {
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
    if (module == 0 as * Module || arena == 0 as * ASTArena || out_sz == 0 as * i32 || out_al == 0 as 
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
        if (fsize <= 0) {
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
      if (fsize <= 0) {
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
    if (ctx == 0 as * PipelineDepCtx) {
      return - 1;
    }
    /* See implementation. */
    let nd: i32 = pipeline_dep_ctx_ndep(ctx);
    let di: i32 = 0;
    while (di < nd) {
      let dm: *Module = pipeline_dep_ctx_module_at(ctx, di);
      if (dm != 0 as * Module) {
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
* See implementation.
* See implementation.
* See implementation.
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
    /* See implementation. */
    let lit_nm: *u8 = typeck_scratch64_slot(4);
    let layout_nm: *u8 = typeck_scratch64_slot(5);
    let field_nm: *u8 = typeck_scratch64_slot(6);
    let exist_nm: *u8 = typeck_scratch64_slot(7);
    if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    /* See implementation. */
    num_fields = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    if (num_fields <= 0 || num_fields > 8) {
      return 0;
    }
    name_len = pipeline_expr_struct_lit_type_name_len(arena, expr_ref);
    if (name_len <= 0 || name_len > 63) {
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
    /* See implementation. */
    if (found_idx >= 0) {
      idx_m = found_idx;
      jm = 0;
      while (jm < num_fields) {
        pipeline_expr_struct_lit_field_name_into(arena, expr_ref, jm, field_nm);
        fnlen_m = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, jm);
        exists_m = 0;
        tm = 0;
        nf_layout = pipeline_module_struct_layout_num_fields(module, idx_m);
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
      pipeline_module_struct_layout_set_field(module, idx, j, field_nm, fnlen_j, ftr, foff_j);
      j = j + 1;
    }
    return 0;
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
    if (a_len != b_len || a_len <= 0 || a_len > 63) {
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
    if (arena == 0 as * ASTArena || name == 0 as * u8 || name_len <= 0 || name_len > 63) {
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
    let bn: u8[64] = [];
    let bn_len: i32 = pipeline_type_named_name_into(arena, base_type_ref, &bn[0]);
    if (bn_len <= 0 || bn_len > 63) {
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
    if (arena == 0 as * ASTArena || kind_ord < 0 || kind_ord > 16) {
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
    if (a == 0 as * ASTArena || kind_ord < 0 || kind_ord > 16) {
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
    if (ctx == 0 as * PipelineDepCtx) {
      return 0;
    }
    /* See implementation. */
    let nd2: i32 = pipeline_dep_ctx_ndep(ctx);
    let di: i32 = 0;
    while (di < nd2) {
      let dm: *Module = pipeline_dep_ctx_module_at(ctx, di);
      if (dm != 0 as * Module) {
        r = get_field_type_ref_from_layout(dm, type_name, type_name_len, field_name, field_name_len);
        if (r != 0) {
          let da: *ASTArena = pipeline_dep_ctx_arena_at(ctx, di);
          if (da != 0 as * ASTArena) {
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
    let dm: *Module = 0 as * Module;
    let darena: *ASTArena = 0 as * ASTArena;
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
    if (ctx == 0 as * PipelineDepCtx) {
      return;
    }
    nd_merge = pipeline_dep_ctx_ndep(ctx);
    di = 0;
    while (di < nd_merge) {
      dm = pipeline_dep_ctx_module_at(ctx, di);
      darena = pipeline_dep_ctx_arena_at(ctx, di);
      if (dm == 0 as * Module || darena == 0 as * ASTArena) {
        di = di + 1;
        continue;
      }
      ndm_sl = pipeline_module_num_struct_layouts_at(dm);
      k = 0;
      while (k < ndm_sl) {
        nl = pipeline_module_struct_layout_name_len(dm, k);
        if (nl > 0 && nl <= 63) {
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
    let dm: *Module = 0 as * Module;
    let nsl: i32 = 0;
    let k: i32 = 0;
    let nl: i32 = 0;
    let any_soa: i32 = 0;
    let mj: i32 = 0;
    let dm2: *Module = 0 as * Module;
    let nsl2: i32 = 0;
    let k2: i32 = 0;
    let nl2: i32 = 0;
    let li: i32 = 0;
    let nm_buf: *u8 = typeck_scratch64_slot(11);
    let nm2: *u8 = typeck_scratch64_slot(12);
    if (entry == 0 as * Module || ctx == 0 as * PipelineDepCtx) {
      return;
    }
    nd = pipeline_dep_ctx_ndep(ctx);
    mi = -1;
    while (mi < nd) {
      dm = entry;
      if (mi >= 0) {
        dm = pipeline_dep_ctx_module_at(ctx, mi);
      }
      if (dm == 0 as * Module) {
        mi = mi + 1;
        continue;
      }
      nsl = pipeline_module_num_struct_layouts_at(dm);
      k = 0;
      while (k < nsl) {
        nl = pipeline_module_struct_layout_name_len(dm, k);
        if (nl > 0 && nl <= 63) {
          pipeline_module_struct_layout_name_into(dm, k, nm_buf);
          any_soa = pipeline_module_struct_layout_soa_at(dm, k);
          mj = -1;
          while (mj < nd && any_soa == 0) {
            dm2 = entry;
            if (mj >= 0) {
              dm2 = pipeline_dep_ctx_module_at(ctx, mj);
            }
            if (dm2 != 0 as * Module) {
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
              if (dm2 != 0 as * Module) {
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
    let dm: *Module = 0 as * Module;
    let ret: i32 = 0;
    let fn_slot: *i32 = typeck_call_resolve_func_idx_slot();
    if (dep_i >= imax) {
      return 0;
    }
    dm = pipeline_dep_ctx_module_at(ctx, dep_i);
    if (dm != 0 as * Module) {
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
        if (func_index_out != 0 as * i32) {
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
    if (name_len <= 0 || name_len > 63) {
      return 0;
    }
    let j: i32 = 0;
    while (j < mod.num_funcs) {
      if (pipeline_module_func_name_equal_at(mod, j, name, name_len) != 0) {
        if (from_dep_index >= 0 && pipeline_visibility_allow_func(mod, j, 1) == 0) {
          j = j + 1;
          continue;
        }
        if (func_index_out != 0 as * i32) {
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
    if (caller_arena == 0 as * ASTArena || call_expr_ref <= 0 || arg_i < 0) {
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
      if (pk_lit == 0 || pk_lit == 2 || pk_lit == 3 || pk_lit == 4 || pk_lit == 5 || pk_lit == 6
          || pk_lit == 7) {
        return 100;
      }
    }
    /* See implementation. */
    if (arg_ty > 0) {
      let ak: i32 = pipeline_type_kind_ord_at(caller_arena, arg_ty);
      let pk: i32 = pipeline_type_kind_ord_at(caller_arena, param_ty);
      /*
       * Integer widen (same rules as typeck_integer_widen_ok): i32→usize for
       * heap.alloc(al, capacity) so 2-arg Allocator+usize is not eliminated → first *u64.
       * Score 100 < exact 1000; expected-return is a separate tie-break (not in arg score).
       * PLATFORM: SHARED — keep strict_minimal arg score aligned.
       */
      if (typeck_integer_widen_ok(pk, ak)) {
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
    if (name_len <= 0 || name_len > 63 || mod == 0 as * Module) {
      return 0;
    }
    if (call_expr_ref <= 0 || caller_arena == 0 as * ASTArena ||
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
      if (func_index_out != 0 as * i32) {
        func_index_out[0] = best_idx;
      }
      if (from_dep_index < 0) {
        return best_ret;
      }
      return get_dep_return_type_in_caller_arena(from_dep_index, best_ret, caller_arena, ctx);
    }
    /* See implementation. */
    if (first_idx >= 0) {
      if (func_index_out != 0 as * i32) {
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
      if (func_index_out != 0 as * i32) {
        func_index_out[0] = best_idx;
      }
      if (from_dep_index < 0) {
        return best_ret;
      }
      return get_dep_return_type_in_caller_arena(from_dep_index, best_ret, caller_arena, ctx);
    }
    /* See implementation. */
    if (first_idx >= 0) {
      if (func_index_out != 0 as * i32) {
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
  if (path_len <= 0 || path == 0 as * u8) {
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
    if (module == 0 as * Module || imp_ix < 0 || imp_ix >= typeck_module_num_imports(module)) {
      return false;
    }
    let pl: i32 = pipeline_module_import_path_len(module, imp_ix);
    if (pl <= 0 || pl > 63) {
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
    if (ctx == 0 as * PipelineDepCtx) {
      return 0;
    }
    if (callee_expr_ref <= 0 || callee_expr_ref > arena.num_exprs || module == 0 as * Module) {
      return 0;
    }
    if (pipeline_expr_kind_ord_at(arena, callee_expr_ref) != ord_field) {
      return 0;
    }
    /* See implementation. */
    let layer_buf: u8[64] = [];
    asm_qual_sym_layer_reset();
    let nstack: i32 = 0;
    let cur_ref: i32 = callee_expr_ref;
    while (true) {
      if (cur_ref <= 0 || cur_ref > arena.num_exprs) {
        return 0;
      }
      let falen: i32 = pipeline_expr_field_access_name_len(arena, cur_ref);
      if (pipeline_expr_kind_ord_at(arena, cur_ref) != ord_field || falen <= 0 || falen > 63) {
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
    if (pipeline_expr_kind_ord_at(arena, cur_ref) != ord_var || vnlen <= 0 || vnlen > 63) {
      return 0;
    }
    let vname_buf: u8[64] = [];
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
      if (plen <= 0 || plen > 63) {
        dep_j = dep_j + 1;
        continue;
      }
      let path_cnt_buf: u8[64] = [];
      let pci: i32 = 0;
      while (pci < plen && pci < 64) {
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
      if (dm == 0 as * Module) {
        dep_j = dep_j + 1;
        continue;
      }
      asm_qual_sym_layer_copy(0, &layer_buf[0], 64);
      let ret_fn: i32 = find_func_return_type_in_module_by_name(dm, arena, &layer_buf[0],
      asm_qual_sym_layer_len(0), dep_slot, ctx, func_index_out);
      if (ret_fn != 0) {
        if (dep_index_out != 0 as * i32) {
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
    let dm: *Module = 0 as * Module;
    let import_kind: i32 = 0;
    let base_bind_nm: u8[64] = [];
    let field_nm: u8[64] = [];
    if (callee_expr_ref <= 0 || callee_expr_ref > arena.num_exprs || module == 0 as * Module || ctx == 
    0 as * PipelineDepCtx) {
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
    if (base_bind_len <= 0 || base_bind_len > 63) {
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
        if (dm != 0 as * Module) {
          ret_b = find_func_return_type_in_module_by_name_overload(dm, arena, &field_nm[0], field_len,
          call_expr_ref, dep_slot, ctx, func_index_out);
          if (ret_b != 0) {
            if (dep_index_out != 0 as * i32) {
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
    let base_nm: u8[64] = [];
    let method_nm: u8[64] = [];
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
    if (base_len <= 0 || base_len > 63 || method_len <= 0 || method_len > 63) {
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
    let dm: *Module = 0 as * Module;
    let cv_nm: u8[64] = [];
    if (module == 0 as * Module || ctx == 0 as * PipelineDepCtx) {
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
    if (dm == 0 as * Module) {
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
  let null_po: *i32 = 0 as * i32;
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
  let null_po: *i32 = 0 as * i32;
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
  ctx, 0 as * i32);
}

/**
* See implementation.
*/
export function resolve_call_callee_scan_dep(module: *Module, arena: *ASTArena, callee_expr_ref: i32,
callee_ord: i32, ctx: *PipelineDepCtx, dep_i: i32, imax: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let dm: *Module = 0 as * Module;
    let ret: i32 = 0;
    let null_po: *i32 = 0 as * i32;
    if (dep_i >= imax) {
      return 0;
    }
    dm = pipeline_dep_ctx_module_at(ctx, dep_i);
    if (dm != 0 as * Module) {
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
export function typeck_integer_widen_ok(dest_kind: i32, src_kind: i32): bool {
  let ord_i32: i32 = 0;
  let ord_u8: i32 = 2;
  let ord_u32: i32 = 3;
  let ord_u64: i32 = 4;
  let ord_i64: i32 = 5;
  let ord_usize: i32 = 6;
  if (dest_kind == src_kind) {
    if (dest_kind == ord_i32 || dest_kind == ord_i64 || dest_kind == ord_u8 ||
    dest_kind == ord_u32 || dest_kind == ord_u64 || dest_kind == ord_usize) {
      return true;
    }
    return false;
  }
  if (src_kind == ord_u8) {
    if (dest_kind == ord_u32 || dest_kind == ord_u64 || dest_kind == ord_usize || dest_kind == ord_i32) {
      return true;
    }
    return false;
  }
  if (src_kind == ord_i32) {
    if (dest_kind == ord_i64 || dest_kind == ord_u32 || dest_kind == ord_usize) {
      return true;
    }
    return false;
  }
  if (src_kind == ord_u32 && dest_kind == ord_u64) {
    return true;
  }
  return false;
}

/**
* See implementation.
* See implementation.
*/
export function typeck_return_operand_matches(arena: *ASTArena, op_ref: i32, expect_ref: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let got: i32 = expr_type_ref(arena, op_ref);
    let ord_i32: i32 = 0;
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
    if (typeck_integer_widen_ok(expect_kind, got_kind)) {
      return true;
    }
    /* See implementation. */
    let ord_linear: i32 = 12;
    if (pipeline_type_kind_ord_at(arena, got) == ord_linear) {
      let elem: i32 = pipeline_type_elem_ref_at(arena, got);
      if (!ast.ref_is_null(elem) && type_refs_equal(arena, elem, expect_ref)) {
        return true;
      }
    }
    /* See implementation. */
    if (pipeline_type_kind_ord_at(arena, expect_ref) != ord_i32 || !type_ref_is_bool(arena, got)) {
      return false;
    }
    let kop: i32 = pipeline_expr_kind_ord_at(arena, op_ref);
    if (kop == 2 || kop == 24) {
      return true;
    }
    return false;
  }
}

/**
* See implementation.
* See implementation.
*/
export function typeck_coerce_init_lit_to_decl(arena: *ASTArena, init_ref: i32, decl_ty_ref: i32,
decl_kind: i32, init_kind: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let int_val: i32 = 0;
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
    int_val = pipeline_expr_int_val_at(arena, init_ref);
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
    /* See implementation. */
    if (decl_kind == ord_u32) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    if (int_val >= 0 && (decl_kind == ord_usize || decl_kind == ord_u64)) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    /* See implementation. */
    if (decl_kind == ord_named) {
      let nm16: u8[64] = [];
      let nlen16: i32 = pipeline_type_named_name_into(arena, decl_ty_ref, &nm16[0]);
      if (nlen16 == 3 && nm16[0] == 117 && nm16[1] == 49 && nm16[2] == 54
          && int_val >= 0 && int_val <= 65535) {
        pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
        return 1;
      }
      if (nlen16 == 3 && nm16[0] == 105 && nm16[1] == 49 && nm16[2] == 54
          && int_val >= -32768 && int_val <= 32767) {
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

/* See implementation. */
export function typeck_coerce_init_float_lit_to_decl(arena: *ASTArena, init_ref: i32, decl_ty_ref: i32,
decl_kind: i32, init_kind: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_expr_float: i32 = 1;
    let ord_f32: i32 = 14;
    let ord_f64: i32 = 14;
    if (init_kind == ord_expr_float && (decl_kind == ord_f32 || decl_kind == ord_f64)) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
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

/* See implementation. */
export function typeck_coerce_array_lit_elem_types_to_decl(arena: *ASTArena, init_ref: i32,
decl_ty_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_type_array: i32 = 10;
    let ord_expr_array_lit: i32 = 46;
    let elem_decl_ref: i32 = 0;
    let elem_decl_kind: i32 = 0;
    let num_elems: i32 = 0;
    let i: i32 = 0;
    if (ast.ref_is_null(init_ref) || ast.ref_is_null(decl_ty_ref)) {
      return 0;
    }
    if (pipeline_expr_kind_ord_at(arena, init_ref) != ord_expr_array_lit
    || pipeline_type_kind_ord_at(arena, decl_ty_ref) != ord_type_array) {
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
        elem_ty = expr_type_ref(arena, elem_ref);
        if (!ast.ref_is_null(elem_ty)) {
          let got_kind: i32 = pipeline_type_kind_ord_at(arena, elem_ty);
          if (type_refs_equal(arena, elem_ty, elem_decl_ref)
          || typeck_integer_widen_ok(elem_decl_kind, got_kind)) {
            pipeline_expr_set_resolved_type_ref(arena, elem_ref, elem_decl_ref);
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
    let nm: u8[64] = [];
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

/* See implementation. */
export function typeck_coerce_init_array_vector_lit_to_decl(arena: *ASTArena, init_ref: i32,
decl_ty_ref: i32, decl_kind: i32, init_kind: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    /* See implementation. */
    let ord_type_array: i32 = 10;
    /* See implementation. */
    let ord_type_vector: i32 = 13;
    let ord_expr_array_lit: i32 = 46;
    let lanes: i32 = 0;
    if (decl_kind == ord_type_array && init_kind == ord_expr_array_lit) {
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
    if (typeck_coerce_init_array_vector_lit_to_decl(arena, init_ref, decl_ty_ref, decl_kind,
    init_kind) != 0) {
      return 1;
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
      return typeck_diag_append_lit(out, cur, cap, &qmk[0], 1);
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
    if (!typeck_integer_widen_ok(expect_kind, got_kind)) {
      return;
    }
    pipeline_expr_set_resolved_type_ref(arena, op_ref, expect_ref);
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
    if (arena == 0 as * ASTArena || ast.ref_is_null(op_ref) || ast.ref_is_null(expect_ref)) {
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
    if (module == 0 as * Module || arena == 0 as * ASTArena || ast.ref_is_null(op_ref)) {
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
    if (arena == 0 as * ASTArena || expr_ref <= 0 || expr_ref > arena.num_exprs) {
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
    if (check_expr(module, arena, cond_ref, return_type_ref, ctx) != 0) {
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
        if (typeck_integer_widen_ok(expect_kind, got_kind)) {
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
        if (typeck_integer_widen_ok(expect_kind, got_kind)) {
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
    let ord_lit: i32 = 0;
    let ord_var: i32 = 3;
    let ord_ternary: i32 = 27;
    let ord_add: i32 = 4;
    let ord_sub: i32 = 5;
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
    if (expr_kind == ord_assign) {
      compound_flag = 0;
    }
    if (check_expr(module, arena, left_ref, return_type_ref, ctx) != 0) {
      return - 1;
    }
    lt = expr_type_ref(arena, left_ref);
    rhs_ctx = return_type_ref;
    if (!ast.ref_is_null(lt)) {
      rhs_ctx = lt;
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
      if (rhs_kind == ord_expr_array_lit && lt_kind == ord_type_array) {
        if (typeck_coerce_array_lit_elem_types_to_decl(arena, right_ref, lt) < 0) {
          return - 1;
        }
        rt_after = expr_type_ref(arena, right_ref);
      }
      if (rhs_kind == ord_lit) {
        if (!type_refs_equal(arena, lt, rt_after)) {
          int_val = pipeline_expr_int_val_at(arena, right_ref);
          if (lt_kind == ord_u8 && int_val >= 0 && int_val <= 255) {
            pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
          } else if (expr_kind == ord_assign && lt_kind == ord_ptr && int_val == 0) {
            pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
          } else if (expr_kind == ord_assign && lt_kind == ord_u32) {
            /* See implementation. */
            pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
          } else if (expr_kind == ord_assign && int_val >= 0 &&
          (lt_kind == ord_usize || lt_kind == ord_u64)) {
            pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
          } else if (expr_kind == ord_assign && lt_kind == ord_i64) {
            pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
          } else if (expr_kind == ord_assign && lt_kind == ord_isize) {
            /* See implementation. */
            pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
          } else if (expr_kind == ord_assign && lt_kind == ord_named) {
            /* See implementation. */
            let nm16: u8[64] = [];
            let nlen16: i32 = pipeline_type_named_name_into(arena, lt, &nm16[0]);
            if (nlen16 == 3 && nm16[0] == 117 && nm16[1] == 49 && nm16[2] == 54
                && int_val >= 0 && int_val <= 65535) {
              pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
            } else if (nlen16 == 3 && nm16[0] == 105 && nm16[1] == 49 && nm16[2] == 54
                && int_val >= -32768 && int_val <= 32767) {
              pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
            }
          }
        }
      }
    }
    rt = expr_type_ref(arena, right_ref);
    if (!ast.ref_is_null(lt) && !ast.ref_is_null(rt) && !type_refs_equal(arena, lt, rt)) {
      lt_kind = pipeline_type_kind_ord_at(arena, lt);
      let rt_kind_assign: i32 = pipeline_type_kind_ord_at(arena, rt);
      /* See implementation. */
      if (typeck_integer_widen_ok(lt_kind, rt_kind_assign)) {
        pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
        rt = lt;
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
    if (!ast.ref_is_null(lt) && !ast.ref_is_null(rt)) {
      if (!type_refs_equal(arena, lt, rt)) {
        eb = driver_typeck_diag_scratch_expect();
        gb = driver_typeck_diag_scratch_found();
        el = typeck_diag_fmt_type_into(arena, lt, eb, 96);
        gl = typeck_diag_fmt_type_into(arena, rt, gb, 96);
        driver_diagnostic_typeck_assign_mismatch(compound_flag, line, col, eb, el, gb, gl);
        return - 1;
      }
      /* See implementation. */
      if (pipeline_typeck_check_slice_region_assign_c(arena, expr_ref, lt, rt) != 0) {
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
    let eb: *u8 = 0 as * u8;
    let gb: *u8 = 0 as * u8;
    let el: i32 = 0;
    let gl: i32 = 0;
    if (arena == 0 as * ASTArena || expr_ref <= 0 || expr_ref > arena.num_exprs) {
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
      if (typeck_coerce_init_enum_field_to_decl(module, arena, op_ref, return_type_ref, rk_ret, ok_ret) != 0) {
        /* stamped */
      }
    }
    if (!ast.ref_is_null(op_ref) && !ast.ref_is_null(return_type_ref)) {
      op_kind = pipeline_expr_kind_ord_at(arena, op_ref);
      if (op_kind == ord_lit) {
        rt_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
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
      }
    }
    if (!ast.ref_is_null(op_ref) && !ast.ref_is_null(return_type_ref)) {
      /* See implementation. */
      let ord_type_array: i32 = 10;
      let ord_type_vector: i32 = 13;
      let ord_expr_array_lit: i32 = 46;
      let ret_lanes: i32 = 0;
      op_kind = pipeline_expr_kind_ord_at(arena, op_ref);
      rt_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
      if (op_kind == ord_expr_array_lit && rt_kind == ord_type_array) {
        if (typeck_coerce_array_lit_elem_types_to_decl(arena, op_ref, return_type_ref) < 0) {
          return - 1;
        }
      }
      if (op_kind == ord_expr_array_lit) {
        ret_lanes = typeck_vector_lanes_of_type(arena, return_type_ref);
        if (ret_lanes > 0 && pipeline_expr_array_lit_num_elems_at(arena, op_ref) == ret_lanes) {
          pipeline_expr_set_resolved_type_ref(arena, op_ref, return_type_ref);
        } else if (rt_kind == ord_type_vector
        && pipeline_expr_array_lit_num_elems_at(arena, op_ref) == pipeline_type_array_size_at(arena,
        return_type_ref)) {
          pipeline_expr_set_resolved_type_ref(arena, op_ref, return_type_ref);
        }
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
          if (typeck_integer_widen_ok(expect_kind, got_kind)) {
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
    if (arena == 0 as * ASTArena || expr_ref <= 0 || expr_ref > arena.num_exprs) {
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
    let cnm: u8[64] = [];
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
* See implementation.
* Installs expected return (return_type_ref from let/assign/return) for zero-arg overload pick.
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
    typeck_i32_ptr_store(typeck_overload_expected_ret_slot(), 0);
    /* See implementation. */
    if (pipeline_typeck_check_call_slice_region_c(module, arena, expr_ref, ctx) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * See implementation.
 */
export function typeck_check_expr_binop_cmp(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let bop_l: i32 = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    let bop_r: i32 = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    let bt: i32 = 0;
    if (check_expr(module, arena, bop_l, return_type_ref, ctx) != 0) {
      return - 1;
    }
    if (check_expr(module, arena, bop_r, return_type_ref, ctx) != 0) {
      return - 1;
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
        } else if (lko == ord_f32 || rko == ord_f32) {
          out_ar = typeck_ensure_primitive_by_kind_ord(arena, ord_f32);
        } else if (lko == ord_f64 || rko == ord_f64) {
          out_ar = typeck_ensure_primitive_by_kind_ord(arena, ord_f64);
        } else if (type_refs_equal(arena, lt_ar, rt_ar)) {
          out_ar = lt_ar;
        } else if (typeck_integer_widen_ok(lko, rko)) {
          out_ar = lt_ar;
        } else if (typeck_integer_widen_ok(rko, lko)) {
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
      if (allow_i32_fallback != 0 && lko != ord_ptr && rko != ord_ptr
      && (pipeline_type_kind_ord_at(arena, lt_ar) == ord_bool
      || pipeline_type_kind_ord_at(arena, rt_ar) == ord_bool)) {
        out_ar = typeck_ensure_primitive_by_kind_ord(arena, ord_i32);
      }
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
 * See implementation.
 */
export function typeck_check_expr_unary(module: *Module, arena: *ASTArena, expr_ref: i32,
return_type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let ord_lognot: i32 = 24;
    let op_ref: i32 = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    let expr_kind: i32 = pipeline_expr_kind_ord_at(arena, expr_ref);
    let op_tr: i32 = 0;
    let bt: i32 = 0;
    if (check_expr(module, arena, op_ref, return_type_ref, ctx) != 0) {
      return - 1;
    }
    if (expr_kind == ord_lognot) {
      bt = ensure_bool_type_ref(arena);
      if (bt != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, bt);
      }
      return 0;
    }
    op_tr = expr_type_ref(arena, op_ref);
    if (!ast.ref_is_null(op_tr) && op_tr > 0 && op_tr <= arena.num_types) {
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
    if (arena == 0 as * ASTArena || module == 0 as * Module || ctx == 0 as * PipelineDepCtx
    || expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    vnlen = pipeline_expr_var_name_len(arena, expr_ref);
    if (vnlen <= 0 || vnlen > 63) {
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
 * See implementation.
 */
export function typeck_check_expr_as(module: *Module, arena: *ASTArena, expr_ref: i32,
ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let op_ref: i32 = pipeline_expr_as_operand_ref_at(arena, expr_ref);
    let tgt: i32 = pipeline_expr_as_target_type_ref_at(arena, expr_ref);
    if (!ast.ref_is_null(op_ref) && check_expr(module, arena, op_ref, 0, ctx) != 0) {
      return - 1;
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
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function typeck_coerce_struct_lit_field_inits_to_layout(module: *Module, arena: *ASTArena,
expr_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let num_fields: i32 = 0;
    let name_len: i32 = 0;
    let j: i32 = 0;
    let flen: i32 = 0;
    let init_r: i32 = 0;
    let ftr: i32 = 0;
    let name_buf: *u8 = typeck_scratch64_slot(4);
    let field_buf: *u8 = typeck_scratch64_slot(5);
    if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    num_fields = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    name_len = pipeline_expr_struct_lit_type_name_len(arena, expr_ref);
    if (num_fields <= 0 || name_len <= 0 || name_len > 63) {
      return 0;
    }
    pipeline_expr_struct_lit_type_name_into(arena, expr_ref, name_buf);
    while (j < num_fields) {
      flen = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, j);
      if (flen > 0 && flen <= 63) {
        pipeline_expr_struct_lit_field_name_into(arena, expr_ref, j, field_buf);
        ftr = get_field_type_ref_from_layout(module, name_buf, name_len, field_buf, flen);
        init_r = pipeline_expr_struct_lit_init_ref(arena, expr_ref, j);
        if (!ast.ref_is_null(init_r) && init_r > 0 && init_r <= arena.num_exprs
        && !ast.ref_is_null(ftr) && ftr > 0) {
          typeck_coerce_init_expr_to_decl(module, arena, init_r, ftr);
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
    let name_buf: u8[64] = [];
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
          let backfill_name: u8[64] = [];
          let backfill_len: i32 = pipeline_type_named_name_into(arena, resolved_ref, &backfill_name[0]);
          if (backfill_len > 0 && backfill_len <= 63) {
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
    /* See implementation. */
    typeck_coerce_struct_lit_field_inits_to_layout(module, arena, expr_ref);
    if (name_len > 63) {
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
    let nm: u8[64] = [];
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
 * See implementation.
 * Accepts TYPE_ARRAY / SLICE / PTR / VECTOR and TYPE_NAMED SIMD spellings (i32x4…).
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
    if (check_expr(module, arena, base_ref, return_type_ref, ctx) != 0) {
      return - 1;
    }
    if (check_expr(module, arena, index_ref, return_type_ref, ctx) != 0) {
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
 * See implementation.
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
    if (arena == 0 as * ASTArena || expr_ref <= 0 || expr_ref > arena.num_exprs) {
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
    if (arena == 0 as * ASTArena || expr_ref <= 0 || expr_ref > arena.num_exprs) {
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
  if (arena == 0 as * ASTArena || expr_ref <= 0 || expr_ref > arena.num_exprs) {
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
    /* See implementation. */
    if (!ast.ref_is_null(cd_ir)) {
      if (pipeline_typeck_block_const_init_is_const_c(arena, block_ref, idx) == 0) {
        let err_line: i32 = pipeline_expr_line_at(arena, cd_ir);
        let err_col: i32 = pipeline_expr_col_at(arena, cd_ir);
        pipeline_typeck_const_init_not_constant_c(err_line, err_col);
        return - 1;
      }
    }
    init_ctx = return_type_ref;
    if (!ast.ref_is_null(cd_tr)) {
      init_ctx = cd_tr;
    }
    if (check_expr(module, arena, cd_ir, init_ctx, ctx) != 0) {
      return - 1;
    }
    if (!ast.ref_is_null(cd_ir) && !ast.ref_is_null(cd_tr)) {
      typeck_coerce_init_expr_to_decl(module, arena, cd_ir, cd_tr);
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
    /* See implementation. */
    if (!ast.ref_is_null(ld_ir)) {
      init_ctx = return_type_ref;
      if (!ast.ref_is_null(ld_tr)) {
        init_ctx = ld_tr;
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
      typeck_coerce_init_expr_to_decl(module, arena, ld_ir, ld_tr);
      init_ty = expr_type_ref(arena, ld_ir);
      /* See implementation. */
      if (!ast.ref_is_null(init_ty) && !type_refs_equal(arena, ld_tr, init_ty)) {
        let decl_k: i32 = pipeline_type_kind_ord_at(arena, ld_tr);
        let init_k: i32 = pipeline_type_kind_ord_at(arena, init_ty);
        if (typeck_integer_widen_ok(decl_k, init_k)) {
          pipeline_expr_set_resolved_type_ref(arena, ld_ir, ld_tr);
          init_ty = ld_tr;
        }
      }
      if (!ast.ref_is_null(init_ty) && !type_refs_equal(arena, ld_tr, init_ty)
          && pipeline_typeck_linear_accepts_init_c(arena, ld_tr, init_ty) == 0) {
        eb = driver_typeck_diag_scratch_expect();
        gb = driver_typeck_diag_scratch_found();
        el = typeck_diag_fmt_type_into(arena, ld_tr, eb, 96);
        gl = typeck_diag_fmt_type_into(arena, init_ty, gb, 96);
        let err_line: i32 = pipeline_expr_line_at(arena, ld_ir);
        let err_col: i32 = pipeline_expr_col_at(arena, ld_ir);
        driver_diagnostic_typeck_assign_mismatch(0, err_line, err_col, eb, el, gb, gl);
        return - 1;
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
      if (check_expr(module, arena, wc, return_type_ref, ctx) != 0) {
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
      if (check_expr(module, arena, fc_cr, return_type_ref, ctx) != 0) {
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
      if (check_expr(module, arena, ic_cr, return_type_ref, ctx) != 0) {
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
 * See implementation.
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
        if (typeck_integer_widen_ok(ek_fin, gk_fin)) {
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
    if (arena == 0 as * ASTArena || ctx == 0 as * PipelineDepCtx || block_ref <= 0) {
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
  if (arena == 0 as * ASTArena || block_ref <= 0 || block_ref > arena.num_blocks) {
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
    if (module == 0 as * Module || arena == 0 as * ASTArena || ctx == 0 as * PipelineDepCtx) {
      return 0;
    }
    fn_name_len = pipeline_module_func_name_len_at(module, func_idx);
    pipeline_module_func_name_copy64(module, func_idx, typeck_scratch64_slot(0));
    driver_diagnostic_typeck_fn_enter(func_idx, typeck_scratch64_slot(0), fn_name_len);
    pipeline_typeck_linear_reset_c();
    num_generic_params = pipeline_module_func_num_generic_params_at(module, func_idx);
    if (num_generic_params > 0) {
      return 0;
    }
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
    num_generic_params = pipeline_module_func_num_generic_params_at(module, func_i);
    if (num_generic_params > 0) {
      pipeline_dep_ctx_set_current_func_index(ctx, no_func_ix);
      return typeck_x_ast_check_all_funcs_loop(module, arena, ctx, func_i + 1, num_funcs);
    }
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
    if (module == 0 as * Module || arena == 0 as * ASTArena || ctx == 0 as * PipelineDepCtx) {
      return -2;
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
    if (module == 0 as * Module || arena == 0 as * ASTArena || ctx == 0 as * PipelineDepCtx) {
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
    if (module == 0 as * Module) {
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
