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

/* See implementation. */
export enum TypeKind {
  TYPE_I32,
  TYPE_BOOL,
  TYPE_U8,
  TYPE_U32,
  TYPE_U64,
  TYPE_I64,
  TYPE_USIZE,
  TYPE_ISIZE,
  TYPE_NAMED,
  TYPE_PTR,
  TYPE_ARRAY,
  TYPE_SLICE,
  /* See implementation. */
  TYPE_LINEAR,
  TYPE_VECTOR,
  TYPE_F32,
  TYPE_F64,
  TYPE_VOID
}

/* See implementation. */
export enum ExprKind {
  EXPR_LIT,
  EXPR_FLOAT_LIT,
  EXPR_BOOL_LIT,
  EXPR_VAR,
  EXPR_ADD,
  EXPR_SUB,
  EXPR_MUL,
  EXPR_DIV,
  EXPR_MOD,
  EXPR_SHL,
  EXPR_SHR,
  EXPR_BITAND,
  EXPR_BITOR,
  EXPR_BITXOR,
  EXPR_EQ,
  EXPR_NE,
  EXPR_LT,
  EXPR_LE,
  EXPR_GT,
  EXPR_GE,
  EXPR_LOGAND,
  EXPR_LOGOR,
  EXPR_NEG,
  EXPR_BITNOT,
  EXPR_LOGNOT,
  EXPR_IF,
  EXPR_BLOCK,
  EXPR_TERNARY,
  EXPR_ASSIGN,
  /* See implementation. */
  EXPR_ADD_ASSIGN,
  EXPR_SUB_ASSIGN,
  EXPR_MUL_ASSIGN,
  EXPR_DIV_ASSIGN,
  EXPR_MOD_ASSIGN,
  EXPR_BITAND_ASSIGN,
  EXPR_BITOR_ASSIGN,
  EXPR_BITXOR_ASSIGN,
  EXPR_SHL_ASSIGN,
  EXPR_SHR_ASSIGN,
  EXPR_BREAK,
  EXPR_CONTINUE,
  EXPR_RETURN,
  EXPR_PANIC,
  EXPR_MATCH,
  EXPR_FIELD_ACCESS,
  EXPR_STRUCT_LIT,
  EXPR_ARRAY_LIT,
  EXPR_INDEX,
  EXPR_CALL,
  EXPR_METHOD_CALL,
  EXPR_ENUM_VARIANT,
  /* See implementation. */
  EXPR_ADDR_OF,
  /* See implementation. */
  EXPR_DEREF,
  /* See implementation. */
  EXPR_BINOP,
  /* See implementation. */
  EXPR_AS,
  /* See implementation. */
  EXPR_AWAIT,
  /* See implementation. */
  EXPR_RUN,
  /* See implementation. */
  EXPR_SPAWN,
  /* See implementation. */
  EXPR_TRY_PROPAGATE,
  /* See implementation. */
  EXPR_STRING_LIT
}

/* See implementation. */
export struct Type {
  kind: TypeKind;
  name: u8[64];
  name_len: i32;
  elem_type_ref: i32;
  array_size: i32;
  /* See implementation. */
  region_label: u8[64];
  region_label_len: i32;
}

/* See implementation. */
allow(padding) struct Expr {
  kind: ExprKind;
  resolved_type_ref: i32;
  line: i32;
  col: i32;
  /* See implementation. */
  int_val: i64;
  float_val: f64;
  var_name: u8[64];
  var_name_len: i32;
  binop_left_ref: i32;
  binop_right_ref: i32;
  unary_operand_ref: i32;
  if_cond_ref: i32;
  if_then_ref: i32;
  if_else_ref: i32;
  block_ref: i32;
  match_matched_ref: i32;
  /* See implementation. */
  match_arm_base: i32;
  match_num_arms: i32;
  field_access_base_ref: i32;
  field_access_field_name: u8[64];
  field_access_field_len: i32;
  field_access_is_enum_variant: i32;
  /* See implementation. */
  field_access_offset: i32;
  /* See implementation. */
  field_access_soa_stride: i32;
  index_base_ref: i32;
  index_index_ref: i32;
  index_base_is_slice: i32;
  call_callee_ref: i32;
  /* See implementation. */
  call_arg_base: i32;
  call_num_args: i32;
  /* See implementation. */
  call_num_type_args: i32;
  method_call_base_ref: i32;
  method_call_name: u8[64];
  method_call_name_len: i32;
  /* See implementation. */
  method_call_arg_base: i32;
  method_call_num_args: i32;
  const_folded_val: i32;
  const_folded_valid: i32;
  index_proven_in_bounds: i32;
  /* See implementation. */
  struct_lit_struct_name: u8[64];
  struct_lit_struct_name_len: i32;
  struct_lit_field_base: i32;
  struct_lit_num_fields: i32;
  /* See implementation. */
  array_lit_elem_base: i32;
  array_lit_num_elems: i32;
  /* See implementation. */
  float_bits_lo: i32;
  float_bits_hi: i32;
  /* See implementation. */
  enum_variant_tag: i32;
  /* See implementation. */
  as_operand_ref: i32;
  as_target_type_ref: i32;
  /* See implementation. */
  call_resolved_func_index: i32;
  /* See implementation. */
  call_resolved_dep_index: i32;
}

/* See implementation. */
export struct ConstDecl {
  name: u8[64];
  name_len: i32;
  type_ref: i32;
  init_ref: i32;
}

/* See implementation. */
export struct LetDecl {
  name: u8[64];
  name_len: i32;
  type_ref: i32;
  init_ref: i32;
}

/* See implementation. */
export struct WhileLoop {
  cond_ref: i32;
  body_ref: i32;
}

/* See implementation. */
export struct ForLoop {
  init_ref: i32;
  cond_ref: i32;
  step_ref: i32;
  body_ref: i32;
}

/* See implementation. */
export struct IfStmt {
  cond_ref: i32;
  then_body_ref: i32;
  /* See implementation. */
  else_body_ref: i32;
}

/* See implementation. */
allow(padding) struct StmtOrderItem {
  kind: u8;
  idx: i32;
}

/* See implementation. */
export struct LabeledStmt {
  label: u8[32];
  label_len: i32;
  is_goto: i32;
  goto_target: u8[32];
  goto_target_len: i32;
  return_expr_ref: i32;
}

/* See implementation. */
export struct Block {
  /* See implementation. */
  const_base: i32;
  num_consts: i32;
  let_base: i32;
  num_lets: i32;
  num_early_lets: i32;
  loop_base: i32;
  num_loops: i32;
  for_loop_base: i32;
  num_for_loops: i32;
  if_base: i32;
  num_if_stmts: i32;
  /* See implementation. */
  region_base: i32;
  num_regions: i32;
  defer_base: i32;
  num_defers: i32;
  labeled_base: i32;
  num_labeled_stmts: i32;
  expr_stmt_base: i32;
  num_expr_stmts: i32;
  final_expr_ref: i32;
  stmt_order_base: i32;
  num_stmt_order: i32;
  /* See implementation. */
  parent_block_ref: i32;
}

/* See implementation. */
export struct Param {
  name: u8[32];
  name_len: i32;
  type_ref: i32;
}

/* See implementation. */
export struct Func {
  name: u8[64];
  name_len: i32;
  /* See implementation. */
  param_base: i32;
  num_params: i32;
  /* See implementation. */
  num_generic_params: i32;
  return_type_ref: i32;
  body_ref: i32;
  /* See implementation. */
  body_expr_ref: i32;
  is_extern: i32;
  /* See implementation. */
  is_async: i32;
  /* See implementation. */
  is_used: i32;
  /* See implementation. */
  is_naked: i32;
  /* See implementation. */
  is_entry: i32;
  /* See implementation. */
  is_no_mangle: i32;
  /* See implementation. */
  is_interrupt: i32;
/** See implementation for details. */
  abi_kind: i32;
/** See implementation for details. */
  is_variadic: i32;
/** See implementation for details. */
  is_export: i32;
}

/* See implementation. */
export struct StructLayout {
  name: u8[64];
  name_len: i32;
  /* See implementation. */
  field_base: i32;
  num_fields: i32;
  /* See implementation. */
  allow_padding: i32;
  /* See implementation. */
  soa: i32;
  /* See implementation. */
  packed: i32;
  repr_compatible: i32;
  /* See implementation. */
  is_export: i32;
}

/* See implementation. */
export enum ImportKind { IMPORT_WHOLE, IMPORT_BINDING, IMPORT_SELECT }

/* See implementation. */
export struct Module {
  num_funcs: i32;
  main_func_index: i32;
  num_imports: i32;
  num_top_level_lets: i32;
  num_struct_layouts: i32;
  /* See implementation. */
  pending_allow_padding: i32;
  /* See implementation. */
  pending_soa_struct: i32;
  /* See implementation. */
  pending_cfg_skip: i32;
  /* See implementation. */
  pending_repr_c_struct: i32;
  /* See implementation. */
  pending_repr_compatible_struct: i32;
  /* See implementation. */
  pending_used: i32;
  /* See implementation. */
  pending_naked: i32;
  /* See implementation. */
  pending_entry: i32;
  /* See implementation. */
  pending_no_mangle: i32;
  /* See implementation. */
  pending_interrupt: i32;
  /* See implementation. */
  pending_export: i32;
  num_module_enums: i32;
}

/* See implementation. */
allow(padding) struct ASTArena {
  num_types: i32;
  num_exprs: i32;
  num_blocks: i32;
  num_funcs: i32;
}

/** See implementation for details. */
allow(padding) struct PipelineDepCtx {
  ndep: i32;
  /* See implementation. */
  entry_dir_buf: u8[512];
  entry_dir_len: i32;
  num_lib_roots: i32;
  /* See implementation. */
  path_buf: u8[512];
  /* See implementation. */
  loaded_buf: u8[4194304];
  loaded_len: isize;
  preprocess_buf: u8[4194304];
  preprocess_len: i32;
  /* See implementation. */
  use_asm_backend: i32;
  /* See implementation. */
  target_arch: i32;
  /* See implementation. */
  target_cpu_features: i32;
  /* See implementation. */
  use_macho_o: i32;
  /* See implementation. */
  use_coff_o: i32;
  /* See implementation. */
  current_block_ref: i32;
  /* See implementation. */
  typeck_loop_depth: i32;
  /* See implementation. */
  current_func_index: i32;
  /* See implementation. */
  skip_codegen_dep_0: i32;
  /* See implementation. */
  entry_already_parsed: i32;
  /* See implementation. */
  current_func_single_empty_param_index: i32;
  /* See implementation. */
  current_func_empty_param_count: i32;
  /* See implementation. */
  current_emit_empty_var_next_index: i32;
  /* See implementation. */
  emit_expr_as_callee: i32;
  /* See implementation. */
  current_codegen_module: *Module;
  current_codegen_arena: *ASTArena;
  /* See implementation. */
  current_codegen_dep_index: i32;
  /* See implementation. */
  current_codegen_prefix_mirror: u8[64];
  current_codegen_prefix_len: i32;
  /* See implementation. */
  asm_entry_module_only: i32;
  /* See implementation. */
  entry_module_import_path_mirror: u8[64];
  entry_module_import_path_len: i32;
  /* See implementation. */
  typeck_scope_region_len: i32;
  typeck_scope_region_label: u8[64];
}

/* See implementation. */
export extern function ast_pool_block_on_alloc(arena: *ASTArena, block_ref: i32): void;
/* See implementation. */
export extern function pipeline_arena_type_alloc(arena: *ASTArena): i32;
export extern function pipeline_arena_expr_alloc(arena: *ASTArena): i32;
export extern function pipeline_arena_block_alloc(arena: *ASTArena): i32;
export extern function pipeline_arena_func_alloc(arena: *ASTArena): i32;
export extern function pipeline_arena_type_get_copy(arena: *ASTArena, ref: i32): Type;
export extern function pipeline_arena_type_set_copy(arena: *ASTArena, ref: i32, t: Type): void;
export extern function pipeline_arena_expr_get_copy(arena: *ASTArena, ref: i32): Expr;
export extern function pipeline_arena_expr_set_copy(arena: *ASTArena, ref: i32, e: Expr): void;
export extern function pipeline_arena_block_get_copy(arena: *ASTArena, ref: i32): Block;
export extern function pipeline_arena_block_set_copy(arena: *ASTArena, ref: i32, b: Block): void;
export extern function pipeline_arena_func_get_copy(arena: *ASTArena, ref: i32): Func;
export extern function pipeline_arena_func_set_copy(arena: *ASTArena, ref: i32, f: Func): void;
/* See implementation. */
export extern function pipeline_arena_type_cap(): i32;
export extern function pipeline_arena_expr_cap(): i32;
export extern function pipeline_arena_block_cap(): i32;
export extern function pipeline_arena_func_cap(): i32;

/* See implementation. */
export extern function pipeline_module_import_alloc(module: *Module): i32;
export extern function pipeline_module_import_set_path(module: *Module, idx: i32, bytes: *u8, len: i32): void;
export extern function pipeline_module_import_path_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_path_copy(module: *Module, idx: i32, dst: *u8, dst_cap: i32): void;
export extern function pipeline_module_import_path_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_import_set_kind(module: *Module, idx: i32, kind: i32): void;
export extern function pipeline_module_import_kind_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_set_binding_name(module: *Module, idx: i32, bytes: *u8, len: i32): void;
export extern function pipeline_module_import_binding_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_binding_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_import_set_select_count(module: *Module, idx: i32, n: i32): void;
export extern function pipeline_module_import_append_select_name(module: *Module, idx: i32, bytes: *u8, len: i32): i32;
export extern function pipeline_module_import_select_count_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_set_select_name(module: *Module, idx: i32, sel: i32, bytes: *u8, len: i32): void;
export extern function pipeline_module_import_select_name_len(module: *Module, idx: i32, sel: i32): i32;
export extern function pipeline_module_import_select_name_byte_at(module: *Module, idx: i32, sel: i32, off: i32): u8;
export extern function pipeline_module_struct_layout_alloc(module: *Module): i32;
export extern function pipeline_module_struct_layout_reset_slot(module: *Module, idx: i32): void;
export extern function pipeline_module_struct_layout_set_name(module: *Module, idx: i32, bytes: *u8, len: i32): void;
export extern function pipeline_module_struct_layout_set_field(module: *Module, li: i32, j: i32, fname_bytes: *u8, fname_len: i32, ftype_ref: i32, foff: i32): void;
export extern function pipeline_module_struct_layout_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_name_into(module: *Module, idx: i32, out64: *u8): void;
export extern function pipeline_module_struct_layout_field_name_into(module: *Module, li: i32, j: i32, out64: *u8): void;
export extern function pipeline_module_struct_layout_num_fields(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_set_num_fields(module: *Module, idx: i32, nf: i32): void;
export extern function pipeline_module_struct_layout_field_type_ref(module: *Module, li: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_field_name_len(module: *Module, li: i32, j: i32): i32;
export extern function pipeline_module_top_level_let_alloc(module: *Module): i32;
export extern function pipeline_module_top_level_let_set(module: *Module, idx: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32, is_const: i32): void;
export extern function pipeline_module_top_level_let_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_top_level_let_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_top_level_let_type_ref(module: *Module, idx: i32): i32;
export extern function pipeline_module_top_level_let_init_ref(module: *Module, idx: i32): i32;
export extern function pipeline_module_top_level_let_is_const(module: *Module, idx: i32): i32;
export extern function pipeline_module_enum_alloc(module: *Module): i32;
export extern function pipeline_module_enum_set_name(module: *Module, idx: i32, bytes: *u8, len: i32): void;
export extern function pipeline_module_enum_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_enum_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_struct_layout_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_struct_layout_set_allow_padding(module: *Module, idx: i32, v: i32): void;
export extern function pipeline_module_struct_layout_allow_padding_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_set_soa(module: *Module, idx: i32, v: i32): void;
export extern function pipeline_module_struct_layout_set_packed(module: *Module, idx: i32, v: i32): void;
export extern function pipeline_module_struct_layout_packed_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_soa_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_field_offset_at(module: *Module, li: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_set_field_offset(module: *Module, li: i32, j: i32, foff: i32): void;

/* See implementation. */
export extern function pipeline_onefunc_append_const_name(out: *u8, name: *u8, name_len: i32, init_val: i32): i32;
export extern function pipeline_onefunc_const_name_len(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_const_name_byte_at(out: *u8, i: i32, off: i32): u8;
export extern function pipeline_onefunc_const_init_val(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_num_consts(out: *u8): i32;
export extern function pipeline_onefunc_append_let(out: *u8, name: *u8, name_len: i32, init_val: i32, init_ref: i32, type_ref: i32): i32;
export extern function pipeline_onefunc_let_name_len(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_let_name_byte_at(out: *u8, i: i32, off: i32): u8;
export extern function pipeline_onefunc_let_init_val(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_let_init_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_let_type_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_num_lets(out: *u8): i32;
export extern function pipeline_onefunc_const_name_copy64(out: *u8, i: i32, dst: *u8): void;
export extern function pipeline_onefunc_let_name_copy64(out: *u8, i: i32, dst: *u8): void;
export extern function pipeline_onefunc_copy_sidecar(dst: *u8, src: *u8): void;
export extern function ast_pool_onefunc_reset(out: *u8): void;

/* See implementation. */
export extern function pipeline_block_append_const(arena: *ASTArena, br: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32): i32;
export extern function pipeline_block_append_let(arena: *ASTArena, br: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32): i32;
export extern function pipeline_block_append_if(arena: *ASTArena, br: i32, cond_ref: i32, then_ref: i32, else_ref: i32): i32;
/* See implementation. */
export extern function pipeline_block_append_region(arena: *ASTArena, br: i32, label: *u8, label_len: i32,
body_ref: i32): i32;
/* See implementation. */
export extern function pipeline_block_append_unsafe(arena: *ASTArena, br: i32, body_ref: i32): i32;
export extern function pipeline_block_region_body_ref(arena: *ASTArena, br: i32, ri: i32): i32;
export extern function pipeline_block_append_expr_stmt(arena: *ASTArena, br: i32, expr_ref: i32): i32;
export extern function pipeline_block_append_stmt_order(arena: *ASTArena, br: i32, kind: u8, idx: i32): i32;
export extern function pipeline_block_const_init_ref(arena: *ASTArena, br: i32, ci: i32): i32;
export extern function pipeline_block_const_type_ref(arena: *ASTArena, br: i32, ci: i32): i32;
export extern function pipeline_block_const_name_len(arena: *ASTArena, br: i32, ci: i32): i32;
export extern function pipeline_block_const_name_copy64(arena: *ASTArena, br: i32, ci: i32, dst: *u8): void;
export extern function pipeline_block_let_init_ref(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_block_let_type_ref(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_block_let_name_len(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_block_let_name_copy64(arena: *ASTArena, br: i32, li: i32, dst: *u8): void;
export extern function pipeline_block_expr_stmt_ref(arena: *ASTArena, br: i32, ei: i32): i32;
export extern function pipeline_block_stmt_order_kind(arena: *ASTArena, br: i32, si: i32): u8;
export extern function pipeline_block_stmt_order_idx(arena: *ASTArena, br: i32, si: i32): i32;
export extern function pipeline_block_if_cond_ref(arena: *ASTArena, br: i32, ii: i32): i32;
export extern function pipeline_block_if_then_body_ref(arena: *ASTArena, br: i32, ii: i32): i32;
export extern function pipeline_block_if_else_body_ref(arena: *ASTArena, br: i32, ii: i32): i32;
export extern function pipeline_block_resolve_var_type_ref(arena: *ASTArena, block_ref: i32, vname: *u8, vlen: i32): i32;
export extern function pipeline_block_fill_ifs_from_onefunc(arena: *ASTArena, br: i32, out: *u8, count: i32): void;
export extern function pipeline_block_fill_stmt_order_from_onefunc(arena: *ASTArena, br: i32, out: *u8, count: i32): void;
export extern function pipeline_block_fill_expr_stmts_from_onefunc(arena: *ASTArena, br: i32, out: *u8, count: i32): void;
export extern function pipeline_block_append_while(arena: *ASTArena, br: i32, cond_ref: i32, body_ref: i32): i32;
export extern function pipeline_block_append_for(arena: *ASTArena, br: i32, init_ref: i32, cond_ref: i32, step_ref: i32, body_ref: i32): i32;
export extern function pipeline_block_while_cond_ref(arena: *ASTArena, br: i32, wi: i32): i32;
export extern function pipeline_block_while_body_ref(arena: *ASTArena, br: i32, wi: i32): i32;
export extern function pipeline_block_for_init_ref(arena: *ASTArena, br: i32, fi: i32): i32;
export extern function pipeline_block_for_cond_ref(arena: *ASTArena, br: i32, fi: i32): i32;
export extern function pipeline_block_for_step_ref(arena: *ASTArena, br: i32, fi: i32): i32;
export extern function pipeline_block_for_body_ref(arena: *ASTArena, br: i32, fi: i32): i32;
export extern function pipeline_block_fill_whiles_from_onefunc(arena: *ASTArena, br: i32, out: *u8, count: i32): void;
export extern function pipeline_block_fill_fors_from_onefunc(arena: *ASTArena, br: i32, out: *u8, count: i32): void;
export extern function pipeline_block_append_labeled(arena: *ASTArena, br: i32, label_len: i32, is_goto: i32, goto_target_len: i32, return_expr_ref: i32): i32;
export extern function pipeline_block_labeled_return_expr_ref(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_onefunc_append_while(out: *u8, cond_ref: i32, body_ref: i32): i32;
export extern function pipeline_onefunc_while_cond_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_while_body_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_num_whiles(out: *u8): i32;
export extern function pipeline_onefunc_append_for(out: *u8, init_ref: i32, cond_ref: i32, step_ref: i32, body_ref: i32): i32;
export extern function pipeline_onefunc_for_init_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_for_cond_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_for_step_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_for_body_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_num_fors(out: *u8): i32;

/* See implementation. */
export extern function pipeline_dep_ctx_set_module(ctx: *PipelineDepCtx, idx: i32, m: *Module): void;
export extern function pipeline_dep_ctx_set_arena(ctx: *PipelineDepCtx, idx: i32, a: *ASTArena): void;
export extern function pipeline_dep_ctx_module_at(ctx: *PipelineDepCtx, idx: i32): *Module;
export extern function pipeline_dep_ctx_arena_at(ctx: *PipelineDepCtx, idx: i32): *ASTArena;
export extern function pipeline_dep_ctx_set_import_path(ctx: *PipelineDepCtx, idx: i32, bytes: *u8, len: i32): void;
export extern function pipeline_dep_ctx_import_path_len(ctx: *PipelineDepCtx, idx: i32): i32;
export extern function pipeline_dep_ctx_import_path_byte_at(ctx: *PipelineDepCtx, idx: i32, off: i32): u8;
export extern function pipeline_dep_ctx_import_path_copy64(ctx: *PipelineDepCtx, idx: i32, dst: *u8): void;
export extern function pipeline_dep_ctx_ndep(ctx: *PipelineDepCtx): i32;
export extern function pipeline_dep_ctx_set_ndep(ctx: *PipelineDepCtx, n: i32): void;
export extern function pipeline_ctx_append_lib_root(ctx: *PipelineDepCtx, path: *u8, len: i32): i32;
export extern function pipeline_ctx_lib_root_count(ctx: *PipelineDepCtx): i32;
export extern function pipeline_ctx_lib_root_len(ctx: *PipelineDepCtx, i: i32): i32;
export extern function pipeline_ctx_lib_root_copy(ctx: *PipelineDepCtx, i: i32, dst: *u8, cap: i32): void;

/* See implementation. */
export extern function pipeline_module_func_alloc_slot(module: *Module): i32;
export extern function pipeline_module_func_ref_at(module: *Module, func_index: i32): i32;
export extern function pipeline_module_func_ref_set(module: *Module, func_index: i32, func_ref: i32): void;
export extern function pipeline_module_func_set_return_type(module: *Module, fi: i32, type_ref: i32): void;
export extern function pipeline_module_func_set_body_ref(module: *Module, fi: i32, body_ref: i32): void;
export extern function pipeline_module_func_set_body_expr_ref(module: *Module, fi: i32, body_expr_ref: i32): void;
export extern function pipeline_module_func_set_is_extern(module: *Module, fi: i32, is_extern: i32): void;
export extern function pipeline_module_func_set_is_variadic(module: *Module, fi: i32, is_variadic: i32): void;
export extern function pipeline_module_func_is_variadic_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_set_num_params(module: *Module, fi: i32, n: i32): void;
export extern function pipeline_module_func_set_num_generic_params(module: *Module, fi: i32, n: i32): void;
export extern function pipeline_module_func_return_type_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_num_generic_params_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_name_equal_at(module: *Module, fi: i32, name: *u8, name_len: i32): i32;
export extern function pipeline_module_func_name_byte_at(module: *Module, fi: i32, i: i32): u8;
export extern function pipeline_module_func_body_expr_ref_at(module: *Module, fi: i32): i32;

/** Exported function `ref_is_null`.
 * Implements `ref_is_null`.
 * @param ref i32
 * @return bool
 */
export function ref_is_null(ref: i32): bool {
  return ref == 0;
}

/** Exported function `ast_placeholder`.
 * Implements `ast_placeholder`.
 * @return i32
 */
export function ast_placeholder(): i32 {
  return 0;
}

/**
 * See implementation.
 */
export function expr_layout_prime_call_resolved(): void {
  let _tail: Expr = Expr {
    kind: ExprKind.EXPR_LIT,
    resolved_type_ref: 0,
    line: 0,
    col: 0,
    as_operand_ref: 0,
    as_target_type_ref: 0,
    call_resolved_func_index: -1,
    call_resolved_dep_index: -1
  };
  _tail.call_num_type_args = 0;
  _tail.call_resolved_func_index = -1;
}

/** Exported function `func_layout_prime_generic_params`.
 * Implements `func_layout_prime_generic_params`.
 * @return void
 */
export function func_layout_prime_generic_params(): void {
  let name0: u8[64] = [];
  let f0: Func = Func {
    name: name0,
    name_len: 0,
    param_base: 0,
    num_params: 0,
    num_generic_params: 0,
    return_type_ref: 0,
    body_ref: 0,
    body_expr_ref: 0,
    is_extern: false,
    is_async: false
  };
  f0.num_generic_params = 0;
}

/** Exported function `ast_arena_init`.
 * Implements `ast_arena_init`.
 * @param arena *ASTArena
 * @return void
 */
export function ast_arena_init(arena: *ASTArena): void {
  expr_layout_prime_call_resolved();
  func_layout_prime_generic_params();
  arena.num_types = 0;
  arena.num_exprs = 0;
  arena.num_blocks = 0;
  arena.num_funcs = 0;
}

/** Exported function `ast_arena_type_alloc`.
 * Memory management helper `ast_arena_type_alloc`.
 * @param arena *ASTArena
 * @return i32
 */
export function ast_arena_type_alloc(arena: *ASTArena): i32 {
  let ref: i32 = 0;
  unsafe {
    ref = pipeline_arena_type_alloc(arena);
  }
  if (ref <= 0) {
    return 0;
  }
  return ref;
}

/** Exported function `ast_arena_expr_alloc`.
 * Memory management helper `ast_arena_expr_alloc`.
 * @param arena *ASTArena
 * @return i32
 */
export function ast_arena_expr_alloc(arena: *ASTArena): i32 {
  let ref: i32 = 0;
  unsafe {
    ref = pipeline_arena_expr_alloc(arena);
  }
  if (ref <= 0) {
    return 0;
  }
  return ref;
}

/** Exported function `ast_arena_block_alloc`.
 * Memory management helper `ast_arena_block_alloc`.
 * @param arena *ASTArena
 * @return i32
 */
export function ast_arena_block_alloc(arena: *ASTArena): i32 {
  let ref: i32 = 0;
  unsafe {
    ref = pipeline_arena_block_alloc(arena);
  }
  if (ref <= 0) {
    return 0;
  }
  return ref;
}

/* See implementation. */
export extern function ast_arena_type_get(arena: *ASTArena, ref: i32): Type;

/* See implementation. */
export extern function ast_arena_type_set(arena: *ASTArena, ref: i32, t: Type): void;

/** Exported function `expr_init_match_enum`.
 * Implements `expr_init_match_enum`.
 * @param e *Expr
 * @return void
 */
export function expr_init_match_enum(e: *Expr): void {
  e.match_arm_base = 0;
  e.enum_variant_tag = 0;
}

/* See implementation. */
export extern function pipeline_expr_append_call_arg(arena: *ASTArena, expr_ref: i32, arg_ref: i32): i32;
export extern function pipeline_expr_call_arg_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_call_num_args_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_call_num_type_args_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_append_method_call_arg(arena: *ASTArena, expr_ref: i32, arg_ref: i32): i32;
export extern function pipeline_expr_method_call_arg_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_append_match_arm(arena: *ASTArena, expr_ref: i32, result_ref: i32, is_wildcard: i32, lit_val: i32, is_enum_variant: i32, variant_index: i32): i32;
export extern function pipeline_expr_match_num_arms_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_match_arm_result_ref(arena: *ASTArena, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_match_arm_is_wildcard(arena: *ASTArena, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_match_arm_lit_val(arena: *ASTArena, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_match_arm_is_enum_variant(arena: *ASTArena, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_match_arm_variant_index(arena: *ASTArena, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_match_arm_set_wildcard(arena: *ASTArena, expr_ref: i32, i: i32, v: i32): void;
export extern function pipeline_expr_match_arm_set_lit_val(arena: *ASTArena, expr_ref: i32, i: i32, v: i32): void;
export extern function pipeline_expr_match_arm_set_enum_variant(arena: *ASTArena, expr_ref: i32, i: i32, is_var: i32, variant_index: i32): void;
export extern function pipeline_expr_append_struct_lit_field(arena: *ASTArena, expr_ref: i32, name_bytes: *u8, name_len: i32, init_ref: i32): i32;
export extern function pipeline_expr_append_array_lit_elem(arena: *ASTArena, expr_ref: i32, elem_ref: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *ASTArena, expr_ref: i32): i32;

/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function pipeline_expr_init_call_resolve_at_ref(arena: *ASTArena, expr_ref: i32): void;

/* See implementation. */
export extern function pipeline_expr_apply_call_resolve(arena: *ASTArena, call_expr_ref: i32, dep_ix: i32, func_ix: i32): void;

/** Exported function `expr_init_call_resolve`.
 * Implements `expr_init_call_resolve`.
 * @param arena *ASTArena
 * @param expr_ref i32
 * @return void
 */
export function expr_init_call_resolve(arena: *ASTArena, expr_ref: i32): void {
  unsafe {
    pipeline_expr_init_call_resolve_at_ref(arena, expr_ref);
  }
}

/** Exported function `ast_expr_apply_call_resolve`.
 * Implements `ast_expr_apply_call_resolve`.
 * @param arena *ASTArena
 * @param call_expr_ref i32
 * @param dep_ix i32
 * @param func_ix i32
 * @return void
 */
export function ast_expr_apply_call_resolve(arena: *ASTArena, call_expr_ref: i32, dep_ix: i32, func_ix: i32): void {
  unsafe {
    pipeline_expr_apply_call_resolve(arena, call_expr_ref, dep_ix, func_ix);
  }
}

/* See implementation. */
export extern function ast_arena_expr_get(arena: *ASTArena, ref: i32): Expr;

/* See implementation. */
export extern function ast_arena_expr_set(arena: *ASTArena, ref: i32, e: Expr): void;

/* See implementation. */
export extern function ast_arena_block_get(arena: *ASTArena, ref: i32): Block;

/** Exported function `ast_name_bytes_equal`.
 * Implements `ast_name_bytes_equal`.
 * @param a_nm *u8
 * @param a_len i32
 * @param b_nm *u8
 * @param b_len i32
 * @return bool
 */
export function ast_name_bytes_equal(a_nm: *u8, a_len: i32, b_nm: *u8, b_len: i32): bool {
  if (a_len != b_len || a_len <= 0) {
    return false;
  }
  let j: i32 = 0;
  while (j < a_len) {
    if (a_nm[j] != b_nm[j]) {
      return false;
    }
    j = j + 1;
  }
  return true;
}

/** Exported function `ast_block_final_expr_ref`.
 * Implements `ast_block_final_expr_ref`.
 * @param a *ASTArena
 * @param body_ref i32
 * @return i32
 */
export function ast_block_final_expr_ref(a: *ASTArena, body_ref: i32): i32 {
  if (body_ref <= 0 || body_ref > a.num_blocks) {
    return 0;
  }
  let blk: Block;
  unsafe {
    blk = ast_arena_block_get(a, body_ref);
  }
  return blk.final_expr_ref;
}

/**
 * See implementation.
 * See implementation.
 */
export extern function implicit_tail_expr_disallowed_by_glue(a: *ASTArena, expr_ref: i32): bool;

/** Exported function `ast_expr_disallows_implicit_tail`.
 * Implements `ast_expr_disallows_implicit_tail`.
 * @param a *ASTArena
 * @param expr_ref i32
 * @return bool
 */
export function ast_expr_disallows_implicit_tail(a: *ASTArena, expr_ref: i32): bool {
  unsafe {
    return implicit_tail_expr_disallowed_by_glue(a, expr_ref);
  }
}

/** Exported function `ast_block_num_consts`.
 * Implements `ast_block_num_consts`.
 * @param a *ASTArena
 * @param br i32
 * @return i32
 */
export function ast_block_num_consts(a: *ASTArena, br: i32): i32 {
  if (br <= 0 || br > a.num_blocks) {
    return 0;
  }
  /* See implementation. */
  let blk_nc: Block;
  unsafe {
    blk_nc = ast_arena_block_get(a, br);
  }
  return blk_nc.num_consts;
}

/** Exported function `ast_block_num_lets`.
 * Implements `ast_block_num_lets`.
 * @param a *ASTArena
 * @param br i32
 * @return i32
 */
export function ast_block_num_lets(a: *ASTArena, br: i32): i32 {
  if (br <= 0 || br > a.num_blocks) {
    return 0;
  }
  let blk_nl: Block;
  unsafe {
    blk_nl = ast_arena_block_get(a, br);
  }
  return blk_nl.num_lets;
}

/** Exported function `ast_block_num_loops`.
 * Implements `ast_block_num_loops`.
 * @param a *ASTArena
 * @param br i32
 * @return i32
 */
export function ast_block_num_loops(a: *ASTArena, br: i32): i32 {
  if (br <= 0 || br > a.num_blocks) {
    return 0;
  }
  let blk_nlp: Block;
  unsafe {
    blk_nlp = ast_arena_block_get(a, br);
  }
  return blk_nlp.num_loops;
}

/** Exported function `ast_block_num_for_loops`.
 * Implements `ast_block_num_for_loops`.
 * @param a *ASTArena
 * @param br i32
 * @return i32
 */
export function ast_block_num_for_loops(a: *ASTArena, br: i32): i32 {
  if (br <= 0 || br > a.num_blocks) {
    return 0;
  }
  let blk_nfp: Block;
  unsafe {
    blk_nfp = ast_arena_block_get(a, br);
  }
  return blk_nfp.num_for_loops;
}

/** Exported function `ast_block_num_if_stmts`.
 * Implements `ast_block_num_if_stmts`.
 * @param a *ASTArena
 * @param br i32
 * @return i32
 */
export function ast_block_num_if_stmts(a: *ASTArena, br: i32): i32 {
  if (br <= 0 || br > a.num_blocks) {
    return 0;
  }
  let blk_nif: Block;
  unsafe {
    blk_nif = ast_arena_block_get(a, br);
  }
  return blk_nif.num_if_stmts;
}

/** Exported function `ast_block_num_regions`.
 * Implements `ast_block_num_regions`.
 * @param a *ASTArena
 * @param br i32
 * @return i32
 */
export function ast_block_num_regions(a: *ASTArena, br: i32): i32 {
  if (br <= 0 || br > a.num_blocks) {
    return 0;
  }
  let blk_nr: Block;
  unsafe {
    blk_nr = ast_arena_block_get(a, br);
  }
  return blk_nr.num_regions;
}

/** Exported function `ast_block_region_body_ref`.
 * Implements `ast_block_region_body_ref`.
 * @param a *ASTArena
 * @param br i32
 * @param ri i32
 * @return i32
 */
export function ast_block_region_body_ref(a: *ASTArena, br: i32, ri: i32): i32 {
  unsafe {
    return pipeline_block_region_body_ref(a, br, ri);
  }
}

/** Exported function `ast_block_num_expr_stmts`.
 * Implements `ast_block_num_expr_stmts`.
 * @param a *ASTArena
 * @param br i32
 * @return i32
 */
export function ast_block_num_expr_stmts(a: *ASTArena, br: i32): i32 {
  if (br <= 0 || br > a.num_blocks) {
    return 0;
  }
  let blk_nes: Block;
  unsafe {
    blk_nes = ast_arena_block_get(a, br);
  }
  return blk_nes.num_expr_stmts;
}

/** Exported function `ast_block_num_stmt_order`.
 * Implements `ast_block_num_stmt_order`.
 * @param a *ASTArena
 * @param br i32
 * @return i32
 */
export function ast_block_num_stmt_order(a: *ASTArena, br: i32): i32 {
  if (br <= 0 || br > a.num_blocks) {
    return 0;
  }
  let blk_nso: Block;
  unsafe {
    blk_nso = ast_arena_block_get(a, br);
  }
  return blk_nso.num_stmt_order;
}

/** Exported function `ast_block_stmt_order_kind`.
 * Implements `ast_block_stmt_order_kind`.
 * @param a *ASTArena
 * @param br i32
 * @param si i32
 * @return u8
 */
export function ast_block_stmt_order_kind(a: *ASTArena, br: i32, si: i32): u8 {
  unsafe {
    return pipeline_block_stmt_order_kind(a, br, si);
  }
}

/** Exported function `ast_block_stmt_order_idx`.
 * Implements `ast_block_stmt_order_idx`.
 * @param a *ASTArena
 * @param br i32
 * @param si i32
 * @return i32
 */
export function ast_block_stmt_order_idx(a: *ASTArena, br: i32, si: i32): i32 {
  unsafe {
    return pipeline_block_stmt_order_idx(a, br, si);
  }
}

/** Exported function `ast_block_const_init_ref`.
 * Implements `ast_block_const_init_ref`.
 * @param a *ASTArena
 * @param br i32
 * @param ci i32
 * @return i32
 */
export function ast_block_const_init_ref(a: *ASTArena, br: i32, ci: i32): i32 {
  unsafe {
    return pipeline_block_const_init_ref(a, br, ci);
  }
}

/** Exported function `ast_block_const_type_ref`.
 * Implements `ast_block_const_type_ref`.
 * @param a *ASTArena
 * @param br i32
 * @param ci i32
 * @return i32
 */
export function ast_block_const_type_ref(a: *ASTArena, br: i32, ci: i32): i32 {
  unsafe {
    return pipeline_block_const_type_ref(a, br, ci);
  }
}

/** Exported function `ast_block_let_init_ref`.
 * Implements `ast_block_let_init_ref`.
 * @param a *ASTArena
 * @param br i32
 * @param li i32
 * @return i32
 */
export function ast_block_let_init_ref(a: *ASTArena, br: i32, li: i32): i32 {
  unsafe {
    return pipeline_block_let_init_ref(a, br, li);
  }
}

/** Exported function `ast_block_let_type_ref`.
 * Implements `ast_block_let_type_ref`.
 * @param a *ASTArena
 * @param br i32
 * @param li i32
 * @return i32
 */
export function ast_block_let_type_ref(a: *ASTArena, br: i32, li: i32): i32 {
  unsafe {
    return pipeline_block_let_type_ref(a, br, li);
  }
}

/** Exported function `ast_block_expr_stmt_ref`.
 * Implements `ast_block_expr_stmt_ref`.
 * @param a *ASTArena
 * @param br i32
 * @param ei i32
 * @return i32
 */
export function ast_block_expr_stmt_ref(a: *ASTArena, br: i32, ei: i32): i32 {
  unsafe {
    return pipeline_block_expr_stmt_ref(a, br, ei);
  }
}

/** Exported function `ast_block_while_cond_ref`.
 * Implements `ast_block_while_cond_ref`.
 * @param a *ASTArena
 * @param br i32
 * @param wi i32
 * @return i32
 */
export function ast_block_while_cond_ref(a: *ASTArena, br: i32, wi: i32): i32 {
  unsafe {
    return pipeline_block_while_cond_ref(a, br, wi);
  }
}

/** Exported function `ast_block_while_body_ref`.
 * Implements `ast_block_while_body_ref`.
 * @param a *ASTArena
 * @param br i32
 * @param wi i32
 * @return i32
 */
export function ast_block_while_body_ref(a: *ASTArena, br: i32, wi: i32): i32 {
  unsafe {
    return pipeline_block_while_body_ref(a, br, wi);
  }
}

/** Exported function `ast_block_for_init_ref`.
 * Implements `ast_block_for_init_ref`.
 * @param a *ASTArena
 * @param br i32
 * @param fi i32
 * @return i32
 */
export function ast_block_for_init_ref(a: *ASTArena, br: i32, fi: i32): i32 {
  unsafe {
    return pipeline_block_for_init_ref(a, br, fi);
  }
}

/** Exported function `ast_block_for_cond_ref`.
 * Implements `ast_block_for_cond_ref`.
 * @param a *ASTArena
 * @param br i32
 * @param fi i32
 * @return i32
 */
export function ast_block_for_cond_ref(a: *ASTArena, br: i32, fi: i32): i32 {
  unsafe {
    return pipeline_block_for_cond_ref(a, br, fi);
  }
}

/** Exported function `ast_block_for_step_ref`.
 * Implements `ast_block_for_step_ref`.
 * @param a *ASTArena
 * @param br i32
 * @param fi i32
 * @return i32
 */
export function ast_block_for_step_ref(a: *ASTArena, br: i32, fi: i32): i32 {
  unsafe {
    return pipeline_block_for_step_ref(a, br, fi);
  }
}

/** Exported function `ast_block_for_body_ref`.
 * Implements `ast_block_for_body_ref`.
 * @param a *ASTArena
 * @param br i32
 * @param fi i32
 * @return i32
 */
export function ast_block_for_body_ref(a: *ASTArena, br: i32, fi: i32): i32 {
  unsafe {
    return pipeline_block_for_body_ref(a, br, fi);
  }
}

/** Exported function `ast_block_if_cond_ref`.
 * Implements `ast_block_if_cond_ref`.
 * @param a *ASTArena
 * @param br i32
 * @param ii i32
 * @return i32
 */
export function ast_block_if_cond_ref(a: *ASTArena, br: i32, ii: i32): i32 {
  unsafe {
    return pipeline_block_if_cond_ref(a, br, ii);
  }
}

/** Exported function `ast_block_if_then_body_ref`.
 * Implements `ast_block_if_then_body_ref`.
 * @param a *ASTArena
 * @param br i32
 * @param ii i32
 * @return i32
 */
export function ast_block_if_then_body_ref(a: *ASTArena, br: i32, ii: i32): i32 {
  unsafe {
    return pipeline_block_if_then_body_ref(a, br, ii);
  }
}

/** Exported function `ast_block_if_else_body_ref`.
 * Implements `ast_block_if_else_body_ref`.
 * @param a *ASTArena
 * @param br i32
 * @param ii i32
 * @return i32
 */
export function ast_block_if_else_body_ref(a: *ASTArena, br: i32, ii: i32): i32 {
  unsafe {
    return pipeline_block_if_else_body_ref(a, br, ii);
  }
}

/**
 * See implementation.
 */
export function ast_block_resolve_var_to_type_ref(a: *ASTArena, block_ref: i32, vname: *u8, vlen: i32): i32 {
  unsafe {
    return pipeline_block_resolve_var_type_ref(a, block_ref, vname, vlen);
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function ast_arena_patch_block_parent_links(arena: *ASTArena, block_ref: i32, parent_ref: i32): void {
  let stack_blk: i32[256] = [];
  let stack_par: i32[256] = [];
  let sp: i32 = 0;
  let cur: i32 = 0;
  let par: i32 = 0;
  let wb: i32 = 0;
  let fb: i32 = 0;
  let tb: i32 = 0;
  let eb: i32 = 0;
  let rgb: i32 = 0;
  let i: i32 = 0;
  if (block_ref <= 0 || block_ref > arena.num_blocks) {
    return;
  }
  stack_blk[sp] = block_ref;
  stack_par[sp] = parent_ref;
  sp = sp + 1;
  while (sp > 0) {
    sp = sp - 1;
    cur = stack_blk[sp];
    par = stack_par[sp];
    if (cur <= 0 || cur > arena.num_blocks) {
      continue;
    }
    if (par != 0) {
      let b_head: Block;
      unsafe {
        b_head = ast_arena_block_get(arena, cur);
      }
      if (b_head.parent_block_ref == 0) {
        b_head.parent_block_ref = par;
        unsafe {
          ast_arena_block_set(arena, cur, b_head);
        }
      }
    }
    let b: Block;
    unsafe {
      b = ast_arena_block_get(arena, cur);
    }
    i = 0;
    while (i < b.num_loops) {
      wb = ast_block_while_body_ref(arena, cur, i);
      if (wb > 0 && sp < 256) {
        stack_blk[sp] = wb;
        stack_par[sp] = cur;
        sp = sp + 1;
      }
      i = i + 1;
    }
    i = 0;
    while (i < b.num_for_loops) {
      fb = ast_block_for_body_ref(arena, cur, i);
      if (fb > 0 && sp < 256) {
        stack_blk[sp] = fb;
        stack_par[sp] = cur;
        sp = sp + 1;
      }
      i = i + 1;
    }
    i = 0;
    while (i < b.num_if_stmts) {
      tb = ast_block_if_then_body_ref(arena, cur, i);
      if (tb > 0 && sp < 256) {
        stack_blk[sp] = tb;
        stack_par[sp] = cur;
        sp = sp + 1;
      }
      eb = ast_block_if_else_body_ref(arena, cur, i);
      if (eb > 0 && sp < 256) {
        stack_blk[sp] = eb;
        stack_par[sp] = cur;
        sp = sp + 1;
      }
      i = i + 1;
    }
    /* See implementation. */
    i = 0;
    while (i < b.num_regions) {
      rgb = ast_block_region_body_ref(arena, cur, i);
      if (rgb > 0 && sp < 256) {
        stack_blk[sp] = rgb;
        stack_par[sp] = cur;
        sp = sp + 1;
      }
      i = i + 1;
    }
  }
}

/* See implementation. */
export extern function ast_arena_block_set(arena: *ASTArena, ref: i32, b: Block): void;

/** Exported function `ast_arena_func_alloc`.
 * Memory management helper `ast_arena_func_alloc`.
 * @param arena *ASTArena
 * @return i32
 */
export function ast_arena_func_alloc(arena: *ASTArena): i32 {
  let ref: i32 = 0;
  unsafe {
    ref = pipeline_arena_func_alloc(arena);
  }
  if (ref <= 0) {
    return 0;
  }
  return ref;
}

/* See implementation. */
export extern function ast_arena_func_get(arena: *ASTArena, ref: i32): Func;

/* See implementation. */
export extern function ast_arena_func_set(arena: *ASTArena, ref: i32, f: Func): void;
