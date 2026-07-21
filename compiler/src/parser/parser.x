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
// See implementation.
// See implementation.
// See implementation.
//
// Cap-T001 / LANG-007 S0 (M1 T KPI): FFI wrappers that call export-extern glue use
// whole-body unsafe. TokenKind/Token uses token.* qualify. Arena heap uses bare
// libc calloc/free (no std.heap import) to keep mega typeck off that dep graph.
// PLATFORM: SHARED — product still pins parser seed until M2.

const lexer = import("lexer");
const token = import("token");
const ast = import("ast");
/** Arena heap for non-literal parse paths: hosted libc via bare extern (no std.heap import).
 * PLATFORM: SHARED — Cap-T001 whole-body callers wrap these; M1 T typeck avoids std.heap dep graph. */
extern "C" function calloc(nmemb: usize, size: usize): *u8;
extern "C" function free(ptr: *u8): void;

/* See implementation. */
export extern "C" function std_fs_open(path: *u8): i32;
export extern "C" function std_fs_read(fd: i32, buf: *u8, count: usize): isize;
export extern "C" function std_fs_close(fd: i32): i32;

/* See implementation. */
/* See implementation. */
export extern function parser_parse_peek_function_name_buf_glue(lex: Lexer, data: *u8, len: i32, out: *u8): i32;
/** Exported function `parse_peek_function_name_buf`.
 * Implements `parse_peek_function_name_buf`.
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *u8
 * @return i32
 */
export function parse_peek_function_name_buf(lex: Lexer, data: *u8, len: i32, out: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_parse_peek_function_name_buf_glue(lex, data, len, out);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/* See implementation. */
export extern function parser_slice_from_buf(data: *u8, len: i32): u8[];
/* See implementation. */
export extern function parser_diagnostic_parse_skip(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void;
/* See implementation. */
export extern function parser_skip_generic_angle_list_into_glue(out: *Lexer, lex: Lexer, source: u8[]): void;
/* See implementation. */
export extern function parser_skip_generic_angle_list_count_into_glue(out: *Lexer, count: *i32, lex: Lexer, source: u8[]): void;
/* See implementation. */
export extern function parser_diagnostic_parse_commit_fail(byte_pos: i32, num_funcs_so_far: i32, name_len: i32, name: *u8): void;
/* See implementation. */
export extern function parser_diagnostic_parse_func_generic(byte_pos: i32, num_funcs_so_far: i32, name: *u8, name_len: i32,
  num_generic_params: i32, is_main: i32): void;
/* See implementation. */
export extern function parser_diagnostic_parse_commit_pre(arena: *ASTArena, name: *u8, name_len: i32, block_ref: i32, pool: *u8, final_expr_ref: i32): void;
export extern function parser_diagnostic_parse_commit_post(arena: *ASTArena, name: *u8, name_len: i32, block_ref: i32, pool: *u8): void;
/* See implementation. */
export extern function pipeline_module_struct_layout_reset_slot(module: *Module, idx: i32): void;
export extern function pipeline_module_struct_layout_set_name(module: *Module, idx: i32, bytes: *u8, len: i32): void;
/* See implementation. */
export extern function pipeline_module_struct_layout_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_struct_layout_set_field(module: *Module, layout_idx: i32, j: i32, fname: *u8, fname_len: i32,
  ftype_ref: i32, foff: i32): void;
/* See implementation. */
export extern function pipeline_struct_layout_next_field_offset(module: *Module, arena: *ASTArena, layout_idx: i32, new_field_type_ref: i32): i32;
/* See implementation. */
export extern function pipeline_struct_layout_next_field_offset_ex(module: *Module, arena: *ASTArena, layout_idx: i32, new_field_type_ref: i32, field_align_req: i32): i32;
export extern function pipeline_module_struct_layout_set_field_align(module: *Module, li: i32, j: i32, al: i32): void;
export extern function pipeline_module_struct_layout_field_align_at(module: *Module, li: i32, j: i32): i32;
/* See implementation. */
export extern function pipeline_module_func_param_write(module: *Module, func_index: i32, param_index: i32, name_bytes: *u8, name_len: i32, type_ref: i32): void;
/* See implementation. */
export extern function pipeline_module_func_name_write(module: *Module, func_index: i32, name_bytes: *u8, name_len: i32): void;
/* See implementation. */
export extern function pipeline_arena_func_param_write(arena: *ASTArena, func_ref: i32, param_index: i32, name_bytes: *u8, name_len: i32, type_ref: i32): void;
/* See implementation. */
export extern function pipeline_arena_func_copy_slot_from_module(arena: *ASTArena, func_ref: i32, module: *Module, fi: i32): void;
/**
 * See implementation.
 * See implementation.
 */
export extern function pipeline_module_reset_parse_counters_c(module: *Module): void;

/** Exported function `pipeline_module_reset_parse_counters`.
 * Implements `pipeline_module_reset_parse_counters`.
 * @param module *Module
 * @return void
 */
export function pipeline_module_reset_parse_counters(module: *Module): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  pipeline_module_reset_parse_counters_c(module);
  }
}
/* See implementation. */
export extern function pipeline_sizeof_arena(): usize;
/* See implementation. */
export extern function pipeline_sizeof_onefunc_result(): usize;

/* See implementation. */
export extern function ast_pool_onefunc_reset(out: *u8): void;
export extern function ast_pool_onefunc_release(out: *u8): void;
export extern function driver_diagnostic_parser_onefunc_param_ref(func_name: *u8, func_name_len: i32,
param_name: *u8, param_name_len: i32, stage: i32, param_idx: i32, type_ref: i32): void;
/* See implementation. */
export extern function ast_pool_module_reset(module: *Module): void;
export extern function ast_pool_arena_reset(arena: *ASTArena): void;
export extern function pipeline_module_func_alloc_slot(module: *Module): i32;
export extern function pipeline_module_func_ref_set(module: *Module, func_index: i32, func_ref: i32): void;
export extern function pipeline_module_func_set_return_type(module: *Module, fi: i32, type_ref: i32): void;
export extern function pipeline_module_func_set_body_ref(module: *Module, fi: i32, body_ref: i32): void;
export extern function pipeline_module_func_set_body_expr_ref(module: *Module, fi: i32, body_expr_ref: i32): void;
export extern function pipeline_module_func_set_is_extern(module: *Module, fi: i32, is_extern: i32): void;
export extern function pipeline_module_func_is_extern_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_set_is_async(module: *Module, fi: i32, is_async: i32): void;
export extern function pipeline_module_func_set_is_export(module: *Module, fi: i32, is_export: i32): void;
export extern function pipeline_module_func_set_is_used(module: *Module, fi: i32, is_used: i32): void;
export extern function pipeline_module_func_set_is_naked(module: *Module, fi: i32, is_naked: i32): void;
export extern function pipeline_module_func_set_is_entry(module: *Module, fi: i32, is_entry: i32): void;
export extern function pipeline_module_func_set_is_no_mangle(module: *Module, fi: i32, is_no_mangle: i32): void;
export extern function pipeline_module_func_set_is_interrupt(module: *Module, fi: i32, is_interrupt: i32): void;
export extern function pipeline_module_func_set_is_variadic(module: *Module, fi: i32, is_variadic: i32): void;
export extern function pipeline_module_func_is_variadic_at(module: *Module, fi: i32): i32;
export extern function pipeline_struct_layout_set_is_send(module: *Module, idx: i32, is_send: i32): void;
export extern function pipeline_struct_layout_set_is_sync(module: *Module, idx: i32, is_sync: i32): void;
export extern function pipeline_module_struct_layout_set_is_export(module: *Module, idx: i32, is_export: i32): void;
export extern function pipeline_module_enum_set_is_export(module: *Module, idx: i32, is_export: i32): void;
export extern function pipeline_module_top_level_let_set_is_export(module: *Module, idx: i32, is_export: i32): void;
export extern function pipeline_module_func_set_num_params(module: *Module, fi: i32, n: i32): void;
export extern function pipeline_module_func_set_num_generic_params(module: *Module, fi: i32, n: i32): void;
export extern function pipeline_block_append_const(arena: *ASTArena, br: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32): i32;
export extern function pipeline_block_append_let(arena: *ASTArena, br: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32): i32;
export extern function pipeline_block_append_if(arena: *ASTArena, br: i32, cond_ref: i32, then_ref: i32, else_ref: i32): i32;
/* See implementation. */
export extern function pipeline_block_append_region(arena: *ASTArena, br: i32, label: *u8, label_len: i32, body_ref: i32): i32;
/* See implementation. */
export extern function pipeline_block_append_unsafe(arena: *ASTArena, br: i32, body_ref: i32): i32;
/* See implementation. */
export extern function pipeline_block_append_with_arena(arena: *ASTArena, br: i32, cap_ref: i32, body_ref: i32): i32;
export extern function pipeline_block_append_expr_stmt(arena: *ASTArena, br: i32, expr_ref: i32): i32;
export extern function pipeline_block_append_stmt_order(arena: *ASTArena, br: i32, kind: u8, idx: i32): i32;
/* See implementation. */
export extern function pipeline_block_stmt_order_fix_prefix_lets(arena: *ASTArena, br: i32, prefix_n: i32): void;
/* See implementation. */
export extern function pipeline_block_with_arena_fixup_stmt_order(arena: *ASTArena, br: i32): void;
export extern function pipeline_block_fill_ifs_from_onefunc(arena: *ASTArena, br: i32, out: *u8, count: i32): void;
export extern function pipeline_block_fill_stmt_order_from_onefunc(arena: *ASTArena, br: i32, out: *u8, count: i32): void;
export extern function pipeline_block_fill_expr_stmts_from_onefunc(arena: *ASTArena, br: i32, out: *u8, count: i32): void;
export extern function pipeline_onefunc_append_if(out: *u8, cond: i32, then_ref: i32, else_ref: i32): i32;
export extern function pipeline_onefunc_if_cond_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_if_then_body_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_if_else_body_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_num_if_stmts(out: *u8): i32;
export extern function pipeline_onefunc_append_region(out: *u8, label: *u8, label_len: i32, body_ref: i32): i32;
export extern function pipeline_onefunc_append_with_arena(out: *u8, cap_ref: i32, body_ref: i32): i32;
export extern function pipeline_onefunc_append_unsafe(out: *u8, body_ref: i32): i32;
export extern function pipeline_onefunc_num_regions(out: *u8): i32;
export extern function pipeline_block_fill_regions_from_onefunc(arena: *ASTArena, br: i32, out: *u8, count: i32): void;
/* See implementation. */
export extern function pipeline_block_append_defer(arena: *ASTArena, br: i32, body_ref: i32): i32;
export extern function pipeline_block_defer_body_ref(arena: *ASTArena, br: i32, di: i32): i32;
export extern function pipeline_onefunc_append_defer(out: *u8, body_ref: i32): i32;
export extern function pipeline_onefunc_num_defers(out: *u8): i32;
export extern function pipeline_block_fill_defers_from_onefunc(arena: *ASTArena, br: i32, out: *u8, count: i32): void;
export extern function pipeline_onefunc_append_const_name(out: *u8, name: *u8, name_len: i32, init_val: i32): i32;
/* See implementation. */
export extern function pipeline_onefunc_append_const(out: *u8, name: *u8, name_len: i32, init_val: i32, init_ref: i32, type_ref: i32): i32;
export extern function pipeline_onefunc_const_name_len(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_const_init_val(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_num_consts(out: *u8): i32;
export extern function pipeline_onefunc_const_name_copy64(out: *u8, i: i32, dst: *u8): void;
export extern function pipeline_onefunc_append_let(out: *u8, name: *u8, name_len: i32, init_val: i32, init_ref: i32, type_ref: i32): i32;
export extern function pipeline_onefunc_let_name_len(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_let_init_val(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_let_init_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_let_type_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_num_lets(out: *u8): i32;
export extern function pipeline_onefunc_let_name_copy64(out: *u8, i: i32, dst: *u8): void;
export extern function pipeline_onefunc_copy_sidecar(dst: *u8, src: *u8): void;
export extern function pipeline_onefunc_push_stmt_order(out: *u8, kind: u8, idx: i32): i32;
export extern function pipeline_onefunc_num_src_stmt_order(out: *u8): i32;
export extern function pipeline_onefunc_src_stmt_kind(out: *u8, i: i32): u8;
export extern function pipeline_onefunc_src_stmt_idx(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_push_body_expr_stmt(out: *u8, expr_ref: i32): i32;
export extern function pipeline_onefunc_body_expr_stmt_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_num_body_expr_stmts(out: *u8): i32;
/* See implementation. */
export extern function pipeline_onefunc_append_param(out: *u8, name: *u8, name_len: i32, type_ref: i32): i32;
export extern function pipeline_onefunc_set_param_type_ref(out: *u8, i: i32, type_ref: i32): void;
export extern function pipeline_onefunc_param_name_len(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_param_name_byte_at(out: *u8, i: i32, off: i32): u8;
export extern function pipeline_onefunc_param_name_copy32(out: *u8, i: i32, dst: *u8): void;
export extern function pipeline_onefunc_param_type_ref(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_call_arg_val_at(out: *u8, i: i32): i32;
export extern function pipeline_onefunc_reset_call_args(out: *u8): void;
/* See implementation. */
export extern function pipeline_block_append_while(arena: *ASTArena, br: i32, cond_ref: i32, body_ref: i32): i32;
export extern function pipeline_block_append_for(arena: *ASTArena, br: i32, init_ref: i32, cond_ref: i32, step_ref: i32, body_ref: i32): i32;
export extern function pipeline_block_fill_whiles_from_onefunc(arena: *ASTArena, br: i32, out: *u8, count: i32): void;
export extern function pipeline_block_fill_fors_from_onefunc(arena: *ASTArena, br: i32, out: *u8, count: i32): void;
export extern function pipeline_onefunc_append_while(out: *u8, cond_ref: i32, body_ref: i32): i32;
export extern function pipeline_onefunc_num_whiles(out: *u8): i32;
export extern function pipeline_onefunc_append_for(out: *u8, init_ref: i32, cond_ref: i32, step_ref: i32, body_ref: i32): i32;
export extern function pipeline_onefunc_num_fors(out: *u8): i32;
/* See implementation. */
export extern function pipeline_parser_set_match_module(m: *Module): void;
export extern function pipeline_parser_get_match_module(): *Module;
export extern function pipeline_module_enum_variant_tag_for_names(m: *Module, enum_name: *u8, enum_len: i32, variant_name: *u8, variant_len: i32): i32;
export extern function pipeline_expr_append_match_arm(arena: *ASTArena, expr_ref: i32, result_ref: i32, is_wildcard: i32, lit_val: i32, is_enum_variant: i32, variant_index: i32): i32;
export extern function pipeline_expr_append_array_lit_elem(arena: *ASTArena, expr_ref: i32, elem_ref: i32): i32;
export extern function pipeline_expr_append_call_arg(arena: *ASTArena, expr_ref: i32, arg_ref: i32): i32;

/* See implementation. */
export extern function lexer_next_buf_into(out: *LexerResult, lex: Lexer, data: *u8, len: i32): void;
export extern function ast_block_expr_stmt_ref(arena: *ASTArena, block_ref: i32, ei: i32): i32;
export extern function pipeline_block_append_labeled(arena: *ASTArena, br: i32, label_len: i32, is_goto: i32, goto_target_len: i32, return_expr_ref: i32): i32;
export extern function pipeline_block_labeled_set_names(arena: *ASTArena, br: i32, li: i32, label: *u8, label_len: i32, goto_target: *u8, goto_target_len: i32): void;
export extern function pipeline_module_struct_layout_alloc(module: *Module): i32;
export extern function pipeline_module_struct_layout_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_num_fields(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_set_num_fields(module: *Module, idx: i32, nf: i32): void;
export extern function pipeline_module_struct_layout_field_name_len(module: *Module, li: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_field_type_ref(module: *Module, li: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_set_allow_padding(module: *Module, idx: i32, v: i32): void;
export extern function pipeline_module_struct_layout_set_soa(module: *Module, idx: i32, v: i32): void;
export extern function pipeline_module_import_alloc(module: *Module): i32;
export extern function pipeline_module_import_set_path(module: *Module, idx: i32, bytes: *u8, len: i32): void;
export extern function pipeline_module_import_set_kind(module: *Module, idx: i32, kind: i32): void;
export extern function pipeline_module_import_set_binding_name(module: *Module, idx: i32, bytes: *u8, len: i32): void;
export extern function pipeline_module_import_set_select_count(module: *Module, idx: i32, n: i32): void;
export extern function pipeline_module_import_append_select_name(module: *Module, idx: i32, bytes: *u8, len: i32): i32;
export extern function pipeline_module_import_path_copy(module: *Module, idx: i32, dst: *u8, dst_cap: i32): void;
export extern function pipeline_module_enum_alloc(module: *Module): i32;
export extern function pipeline_module_enum_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_enum_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_enum_set_name(module: *Module, idx: i32, bytes: *u8, len: i32): void;
export extern function pipeline_module_enum_append_variant(module: *Module, idx: i32, bytes: *u8, len: i32): i32;
export extern function pipeline_type_ensure_by_kind_ord(arena: *ASTArena, kind_ord: i32): i32;
export extern function pipeline_module_top_level_let_alloc(module: *Module): i32;
export extern function pipeline_module_top_level_let_set(module: *Module, idx: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32, is_const: i32): void;

/** Exported function `onefunc_result_pool_ptr`.
 * Implements `onefunc_result_pool_ptr`.
 * @param res *OneFuncResult
 * @return *u8
 */
export function onefunc_result_pool_ptr(res: *OneFuncResult): *u8 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return res as *u8;
  }
}


/* See implementation. */
allow(padding) struct OneFuncResult {
  ok: bool;
  next_lex: Lexer;
  name: u8[64];
  name_len: i32;
  num_params: i32;
  num_generic_params: i32;
  num_consts: i32;
  num_lets: i32;
  has_if_expr: bool;
  if_cond_true: bool;
  if_then_val: i32;
  if_else_val: i32;
  /* See implementation. */
  if_cond_expr_ref: i32;
  has_mul: bool;
  mul_right_val: i32;
  has_binop: bool;
  binop_right_val: i32;
  /* See implementation. */
  binop_left_param_idx: i32;
  binop_right_param_idx: i32;
  has_unary_neg: bool;
  return_val: i32;
  /* See implementation. */
  has_call_expr: bool;
  call_callee_name: u8[64];
  call_callee_len: i32;
  /* See implementation. */
  return_var_name: u8[64];
  return_var_name_len: i32;
  /* See implementation. */
  return_expr_ref: i32;
  /* See implementation. */
  has_final_expr: bool;
  /* See implementation. */
  has_explicit_return_kw: bool;
  /* See implementation. */
  call_num_args: i32;
  /* See implementation. */
  num_loops: i32;
  /* See implementation. */
  num_for_loops: i32;
  /* See implementation. */
  num_if_stmts: i32;
  /**
   * See implementation.
   * See implementation.
   * See implementation.
   */
  num_src_stmt_order: i32;
  /* See implementation. */
  num_src_body_expr_stmts: i32;
  /* See implementation. */
  func_return_type_ref: i32;
}

/* See implementation. */
export struct ParseResult {
  ok: bool;
  return_val: i32;
}

/* See implementation. */
export struct ParseIntoResult {
  ok: i32;
  main_idx: i32;
}

/* See implementation. */
allow(padding) struct TopLevelLetResult {
  ok: bool;
  next_lex: Lexer;
}

/* See implementation. */
allow(padding) struct TypeAliasResult {
  ok: bool;
  next_lex: Lexer;
}

/* See implementation. */
export struct CollectImportsResult {
  lex: Lexer;
}
/* See implementation. */
export extern function parser_lex_copy_from_collect_imports(out: *Lexer, res: CollectImportsResult): void;
/** Exported function `copy_lex_from_import_into`.
 * Implements `copy_lex_from_import_into`.
 * @param out *Lexer
 * @param res CollectImportsResult
 * @return void
 */
export function copy_lex_from_import_into(out: *Lexer, res: CollectImportsResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_lex_copy_from_collect_imports(out, res);
  }
}

/* See implementation. */
export extern function parser_lex_from_lexer_result_val_into(out: *Lexer, r: LexerResult): void;
/* See implementation. */
export extern function parser_lex_from_next_into_glue(out: *Lexer, r: LexerResult): void;
/** Exported function `lex_from_next_into`.
 * Implements `lex_from_next_into`.
 * @param out *Lexer
 * @param r LexerResult
 * @return void
 */
export function lex_from_next_into(out: *Lexer, r: LexerResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_lex_from_next_into_glue(out, r);
  }
}

/* See implementation. */
export extern function parser_lex_from_lexer_result_ptr_into(out: *Lexer, r: *LexerResult): void;
/* See implementation. */
export extern function parser_lex_from_result_ptr_into_glue(out_lex: *Lexer, r: *LexerResult): void;
/** Exported function `lex_from_result_ptr_into`.
 * Implements `lex_from_result_ptr_into`.
 * @param out_lex *Lexer
 * @param r *LexerResult
 * @return void
 */
export function lex_from_result_ptr_into(out_lex: *Lexer, r: *LexerResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_lex_from_result_ptr_into_glue(out_lex, r);
  }
}

/** Exported function `lexer_copy_into`.
 * Implements `lexer_copy_into`.
 * @param out_lex *Lexer
 * @param src_lex Lexer
 * @return void
 */
export function lexer_copy_into(out_lex: *Lexer, src_lex: Lexer): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  out_lex.pos = src_lex.pos;
  out_lex.line = src_lex.line;
  out_lex.col = src_lex.col;
  }
}

/** Exported function `lexer_copy_from_parse_expr_result_into`.
 * Implements `lexer_copy_from_parse_expr_result_into`.
 * @param out_lex *Lexer
 * @param res *ParseExprResult
 * @return void
 */
export function lexer_copy_from_parse_expr_result_into(out_lex: *Lexer, res: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  out_lex.pos = res.next_lex.pos;
  out_lex.line = res.next_lex.line;
  out_lex.col = res.next_lex.col;
  }
}

/** Exported function `parse_expr_result_reset`.
 * Implements `parse_expr_result_reset`.
 * @param out_res *ParseExprResult
 * @param next_lex Lexer
 * @return void
 */
export function parse_expr_result_reset(out_res: *ParseExprResult, next_lex: Lexer): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  out_res.ok = false;
  out_res.expr_ref = 0;
  out_res.next_lex.pos = next_lex.pos;
  out_res.next_lex.line = next_lex.line;
  out_res.next_lex.col = next_lex.col;
  }
}

/** Exported function `parser_rewind_lex_for_following_stmt_into`.
 * Implements `parser_rewind_lex_for_following_stmt_into`.
 * @param out_lex *Lexer
 * @param lex_in Lexer
 * @param r LexerResult
 * @return void
 */
export function parser_rewind_lex_for_following_stmt_into(out_lex: *Lexer, lex_in: Lexer, r: LexerResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let rewound: Lexer = parser_rewind_lex_for_following_stmt(lex_in, r);
  lexer_copy_into(out_lex, rewound);
  }
}

/* See implementation. */
export extern function parser_lex_from_onefunc_result_ptr_into(out: *Lexer, res: *OneFuncResult): void;
/* See implementation. */
export extern function parser_lex_from_onefunc_next_into_glue(out: *Lexer, res: *OneFuncResult): void;
/** Exported function `lex_from_onefunc_next_into`.
 * Implements `lex_from_onefunc_next_into`.
 * @param out *Lexer
 * @param res *OneFuncResult
 * @return void
 */
export function lex_from_onefunc_next_into(out: *Lexer, res: *OneFuncResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_lex_from_onefunc_next_into_glue(out, res);
  }
}


/** Exported function `lexer_pos_before_run`.
 * Implements `lexer_pos_before_run`.
 * @param end_pos usize
 * @param run_len i32
 * @return usize
 */
export function lexer_pos_before_run(end_pos: usize, run_len: i32): usize {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let rl: i32 = run_len;
  let start: usize = end_pos - (rl as usize);
  return start;
  }
}


/**
 * See implementation.
 * See implementation.
 */
/**
 * See implementation.
 * See implementation.
 */
export function lexer_token_run_len(kind: token.TokenKind): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  if (kind == token.TokenKind.TOKEN_RETURN) {
    return 6;
  }
  if (kind == token.TokenKind.TOKEN_FUNCTION) {
    return 8;
  }
  if (kind == token.TokenKind.TOKEN_CONST) {
    return 5;
  }
  if (kind == token.TokenKind.TOKEN_WHILE) {
    return 5;
  }
  if (kind == token.TokenKind.TOKEN_FALSE) {
    return 5;
  }
  if (kind == token.TokenKind.TOKEN_STRUCT) {
    return 6;
  }
  if (kind == token.TokenKind.TOKEN_IMPORT) {
    return 6;
  }
  if (kind == token.TokenKind.TOKEN_EXTERN) {
    return 6;
  }
  if (kind == token.TokenKind.TOKEN_EXPORT) {
    return 6;
  }
  let ko: i32 = kind as i32;
  if (ko == 29) {
    return 5;
  }
  if (kind == token.TokenKind.TOKEN_LET) {
    return 3;
  }
  if (kind == token.TokenKind.TOKEN_IF) {
    return 2;
  }
  if (kind == token.TokenKind.TOKEN_FOR) {
    return 3;
  }
  if (kind == token.TokenKind.TOKEN_ELSE) {
    return 4;
  }
  if (kind == token.TokenKind.TOKEN_TRUE) {
    return 4;
  }
  if (kind == token.TokenKind.TOKEN_ENUM) {
    return 4;
  }
  if (kind == token.TokenKind.TOKEN_MATCH) {
    return 5;
  }
  return 1;
  }
}



/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_lex_at_token_from_result_glue(r: LexerResult): Lexer;
/** Exported function `lex_at_token_from_result`.
 * Implements `lex_at_token_from_result`.
 * @param r LexerResult
 * @return Lexer
 */
export function lex_at_token_from_result(r: LexerResult): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_lex_at_token_from_result_glue(r);
  }
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_parser_rewind_lex_for_following_stmt_glue(lex_in: Lexer, r: LexerResult): Lexer;
/* See implementation. */
export extern function parser_asm_parse_block_return_end_tail_glue(r: *LexerResult, lex_cur: *Lexer, source: u8[], stmt_tok_ready: *bool, block_break: *i32): void;
/** Exported function `parser_rewind_lex_for_following_stmt`.
 * Implements `parser_rewind_lex_for_following_stmt`.
 * @param lex_in Lexer
 * @param r LexerResult
 * @return Lexer
 */
export function parser_rewind_lex_for_following_stmt(lex_in: Lexer, r: LexerResult): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_parser_rewind_lex_for_following_stmt_glue(lex_in, r);
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function parser_realign_lex_after_compound_stmt(lex_in: Lexer, r_in: LexerResult, source: u8[]): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let lex_out: Lexer = parser_rewind_lex_for_following_stmt(lex_in, r_in);
  lex_out = parser_rewind_lex_for_lparen_control_stmt(lex_out, r_in, source);
  return lex_out;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function parser_rewind_lex_for_lparen_control_stmt(lex_in: Lexer, r_in: LexerResult, source: u8[]): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  if (r_in.tok.kind == token.TokenKind.TOKEN_LPAREN) {
    let lp_base: Lexer = lex_at_token_from_result(r_in);
    let back_lp: i32 = 2;
    while (back_lp <= 128) {
      let lex_lp: Lexer = Lexer { pos: lexer_pos_before_run(lp_base.pos, back_lp), line: r_in.tok.line, col: r_in.tok.col };
      let r_lp: LexerResult = LexerResult {
        next_lex: lex_lp,
        tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 },
        token_start: 0
      };
      lexer.lexer_next_into(&r_lp, lex_lp, source);
      if (r_lp.tok.kind == token.TokenKind.TOKEN_IF || r_lp.tok.kind == token.TokenKind.TOKEN_WHILE
      || r_lp.tok.kind == token.TokenKind.TOKEN_FOR) {
        return parser_rewind_lex_for_following_stmt(lex_in, r_lp);
      }
      back_lp = back_lp + 1;
    }
  }
  return lex_in;
  }
}


/**
 * See implementation.
 * See implementation.
 */
export function parser_match_kw_immediately_before(source: u8[], ident_start: usize): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  if (ident_start < 6) {
    return false;
  }
  let p: usize = ident_start - 6;
  return source[p] == 109 && source[p + 1] == 97 && source[p + 2] == 116 && source[p + 3] == 99
      && source[p + 4] == 104 && source[p + 5] == 32;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function parser_return_kw_immediately_before(source: u8[], ident_start: usize): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  if (ident_start < 7) {
    return false;
  }
  let p: usize = ident_start - 7;
  if (source[p] != 114 || source[p + 1] != 101 || source[p + 2] != 116 || source[p + 3] != 117
      || source[p + 4] != 114 || source[p + 5] != 110) {
    return false;
  }
  let sep: u8 = source[p + 6];
  return sep == 32 || sep == 9 || sep == 10 || sep == 13;
  }
}

/** Exported function `parser_match_kw_immediately_before_buf`.
 * Implements `parser_match_kw_immediately_before_buf`.
 * @param data *u8
 * @param len i32
 * @param ident_start usize
 * @return bool
 */
export function parser_match_kw_immediately_before_buf(data: *u8, len: i32, ident_start: usize): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return parser_match_kw_immediately_before(slice, ident_start);
  }
  return false;  // unreachable — typeck after unsafe block
}


/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_advance_past_stmt_semicolon_into_glue(r_out: *LexerResult, lex: Lexer, source: u8[]): i32;
/** Exported function `advance_past_stmt_semicolon_into`.
 * Implements `advance_past_stmt_semicolon_into`.
 * @param r_out *LexerResult
 * @param lex Lexer
 * @param source u8[]
 * @return i32
 */
export function advance_past_stmt_semicolon_into(r_out: *LexerResult, lex: Lexer, source: u8[]): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_advance_past_stmt_semicolon_into_glue(r_out, lex, source);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/** Exported function `advance_past_stmt_semicolon_into_buf`.
 * Implements `advance_past_stmt_semicolon_into_buf`.
 * @param r_out *LexerResult
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return i32
 */
export function advance_past_stmt_semicolon_into_buf(r_out: *LexerResult, lex: Lexer, data: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return advance_past_stmt_semicolon_into(r_out, lex, slice);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_advance_past_cond_rparen_into_glue(r_out: *LexerResult, lex: Lexer, source: u8[]): i32;
/** Exported function `advance_past_cond_rparen_into`.
 * Implements `advance_past_cond_rparen_into`.
 * @param r_out *LexerResult
 * @param lex Lexer
 * @param source u8[]
 * @return i32
 */
export function advance_past_cond_rparen_into(r_out: *LexerResult, lex: Lexer, source: u8[]): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_advance_past_cond_rparen_into_glue(r_out, lex, source);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/** Exported function `advance_past_cond_rparen_into_buf`.
 * Implements `advance_past_cond_rparen_into_buf`.
 * @param r_out *LexerResult
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return i32
 */
export function advance_past_cond_rparen_into_buf(r_out: *LexerResult, lex: Lexer, data: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return advance_past_cond_rparen_into(r_out, lex, slice);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/**
 * See implementation.
 * See implementation.
 */
export function onefunc_result_layout_prime(): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let z64: u8[64] = [];
  /* See implementation. */
  let _prime: OneFuncResult = OneFuncResult {
    ok: false,
    next_lex: lexer.lexer_init(),
    name: z64,
    name_len: 0,
    num_params: 0
  };
  /*
   * See implementation.
   */
  _prime.name_len = 0;
  }
}

/** Exported function `set_onefunc_fail`.
 * Implements `set_onefunc_fail`.
 * @param out *OneFuncResult
 * @param next_lex Lexer
 * @return void
 */
export function set_onefunc_fail(out: *OneFuncResult, next_lex: Lexer): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_diagnostic_parse_skip((next_lex.pos) as i32, -1, out.name_len, &out.name[0]);
  out.ok = false;
  out.next_lex = next_lex;
  }
}

/** Function `onefunc_finish_after_return_lex`.
 * Purpose: implements `onefunc_finish_after_return_lex`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function onefunc_finish_after_return_lex(out: *OneFuncResult, impl_snap: *OneFuncResult, source: u8[],
lex_after_expr: Lexer, func_name: *u8, func_name_len: i32, return_expr_ref: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let r_tail: LexerResult = LexerResult { next_lex: lex_after_expr, tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 }, token_start: 0 };
  let lex_tail: Lexer = lex_after_expr;
  if (advance_past_stmt_semicolon_into(&r_tail, lex_after_expr, source) == 0) {
    return false;
  }
  if (r_tail.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
    lex_from_result_ptr_into(&lex_tail, &r_tail);
    lexer.lexer_next_into(&r_tail, lex_tail, source);
  }
  if (r_tail.tok.kind != token.TokenKind.TOKEN_RBRACE) {
    return false;
  }
  lex_from_next_into(&lex_tail, r_tail);
  onefunc_finish_impl_to_out(out, impl_snap, lex_tail, func_name, func_name_len, return_expr_ref);
  return true;
  }
}


/**
 * See implementation.
 */
export function onefunc_result_layout_prime_b(): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let _q2: OneFuncResult = OneFuncResult {
    num_consts: 0,
    num_lets: 0
  };
  _q2.num_consts = 0;
  }
}

/**
 * See implementation.
 */
export function onefunc_result_layout_prime_c(): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let _q3: OneFuncResult = OneFuncResult {
    has_if_expr: false,
    if_cond_true: false,
    if_then_val: 0,
    if_else_val: 0,
    if_cond_expr_ref: 0,
    has_mul: false,
    mul_right_val: 0
  };
  _q3.if_cond_expr_ref = 0;
  }
}

/**
 * See implementation.
 */
export function onefunc_result_layout_prime_d(): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let ccn: u8[64] = [];
  let _q4: OneFuncResult = OneFuncResult {
    has_binop: false,
    binop_right_val: 0,
    binop_left_param_idx: -1,
    binop_right_param_idx: -1,
    has_unary_neg: false,
    return_val: 0,
    has_call_expr: false,
    call_callee_name: ccn
  };
  _q4.binop_left_param_idx = -1;
  }
}

/**
 * See implementation.
 */
export function onefunc_result_layout_prime_d_b(): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let rvn: u8[64] = [];
  let _q4b: OneFuncResult = OneFuncResult {
    call_callee_len: 0,
    return_var_name: rvn,
    return_var_name_len: 0,
    return_expr_ref: 0,
    call_num_args: 0,
    num_loops: 0
  };
  _q4b.call_num_args = 0;
  }
}

/**
 * See implementation.
 */
export function onefunc_result_layout_prime_e(): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let _q5: OneFuncResult = OneFuncResult {
    num_for_loops: 0,
    num_if_stmts: 0
  };
  _q5.num_if_stmts = 0;
  }
}

/**
 * See implementation.
 */
export function onefunc_result_layout_prime_f(): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let _q6: OneFuncResult = OneFuncResult {
    num_src_stmt_order: 0,
    num_src_body_expr_stmts: 0,
    func_return_type_ref: 0
  };
  _q6.func_return_type_ref = 0;
  }
}

/** Exported function `copy_onefunc_into`.
 * Implements `copy_onefunc_into`.
 * @param dst *OneFuncResult
 * @param src *OneFuncResult
 * @return void
 */
export function copy_onefunc_into(dst: *OneFuncResult, src: *OneFuncResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  /* See implementation. */
  let preserved_func_ret_ty: i32 = dst.func_return_type_ref;
  /* See implementation. */
  pipeline_onefunc_copy_sidecar(onefunc_result_pool_ptr(dst), onefunc_result_pool_ptr(src));
  dst.ok = src.ok;
  dst.next_lex = src.next_lex;
  dst.name_len = src.name_len;
  let ni: i32 = 0;
  while (ni < 64) {
    if (ni < src.name_len) { dst.name[ni] = src.name[ni]; }
    ni = ni + 1;
  }
  dst.num_params = src.num_params;
  dst.num_generic_params = src.num_generic_params;
  dst.num_consts = pipeline_onefunc_num_consts(onefunc_result_pool_ptr(dst));
  dst.num_lets = pipeline_onefunc_num_lets(onefunc_result_pool_ptr(dst));
  dst.has_if_expr = src.has_if_expr;
  dst.if_cond_true = src.if_cond_true;
  dst.if_then_val = src.if_then_val;
  dst.if_else_val = src.if_else_val;
  dst.if_cond_expr_ref = src.if_cond_expr_ref;
  dst.has_mul = src.has_mul;
  dst.mul_right_val = src.mul_right_val;
  dst.has_binop = src.has_binop;
  dst.binop_right_val = src.binop_right_val;
  dst.binop_left_param_idx = src.binop_left_param_idx;
  dst.binop_right_param_idx = src.binop_right_param_idx;
  dst.has_unary_neg = src.has_unary_neg;
  dst.return_val = src.return_val;
  /* See implementation. */
  dst.return_var_name_len = src.return_var_name_len;
  let rvni: i32 = 0;
  while (rvni < 64) {
    dst.return_var_name[rvni] = src.return_var_name[rvni];
    rvni = rvni + 1;
  }
  dst.return_expr_ref = src.return_expr_ref;
  dst.has_final_expr = src.has_final_expr;
  dst.has_explicit_return_kw = src.has_explicit_return_kw;
  dst.has_call_expr = src.has_call_expr;
  dst.call_callee_len = src.call_callee_len;
  let cci: i32 = 0;
  while (cci < 64) { dst.call_callee_name[cci] = src.call_callee_name[cci]; cci = cci + 1; }
  dst.call_num_args = src.call_num_args;
  /* See implementation. */
  dst.num_loops = pipeline_onefunc_num_whiles(onefunc_result_pool_ptr(dst));
  dst.num_for_loops = pipeline_onefunc_num_fors(onefunc_result_pool_ptr(dst));
  dst.num_if_stmts = pipeline_onefunc_num_if_stmts(onefunc_result_pool_ptr(dst));
  dst.num_src_stmt_order = pipeline_onefunc_num_src_stmt_order(onefunc_result_pool_ptr(dst));
  dst.num_src_body_expr_stmts = pipeline_onefunc_num_body_expr_stmts(onefunc_result_pool_ptr(dst));
  if (src.func_return_type_ref != 0) {
    dst.func_return_type_ref = src.func_return_type_ref;
  } else {
    dst.func_return_type_ref = preserved_func_ret_ty;
  }
  /* See implementation. */
  }
}

/** Exported function `onefunc_scratch_empty`.
 * Implements `onefunc_scratch_empty`.
 * @return OneFuncResult
 */
export function onefunc_scratch_empty(): OneFuncResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let z64: u8[64] = [];
  return OneFuncResult {
    ok: false,
    next_lex: lexer.lexer_init(),
    name: z64,
    name_len: 0,
    num_params: 0
  };
  }
}

/**
 * See implementation.
 */
export function onefunc_merge_pool_out_to_snap(snap: *OneFuncResult, out: *OneFuncResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  pipeline_onefunc_copy_sidecar(onefunc_result_pool_ptr(snap), onefunc_result_pool_ptr(out));
  snap.num_params = out.num_params;
  snap.num_generic_params = out.num_generic_params;
  if (out.func_return_type_ref != 0) {
    snap.func_return_type_ref = out.func_return_type_ref;
  }
  snap.num_consts = pipeline_onefunc_num_consts(onefunc_result_pool_ptr(snap));
  snap.num_lets = pipeline_onefunc_num_lets(onefunc_result_pool_ptr(snap));
  snap.num_if_stmts = pipeline_onefunc_num_if_stmts(onefunc_result_pool_ptr(snap));
  snap.num_src_stmt_order = pipeline_onefunc_num_src_stmt_order(onefunc_result_pool_ptr(snap));
  snap.num_src_body_expr_stmts = pipeline_onefunc_num_body_expr_stmts(onefunc_result_pool_ptr(snap));
  /* See implementation. */
  snap.num_loops = pipeline_onefunc_num_whiles(onefunc_result_pool_ptr(snap));
  snap.num_for_loops = pipeline_onefunc_num_fors(onefunc_result_pool_ptr(snap));
  }
}

/**
 * See implementation.
 */
export function onefunc_finish_impl_to_out(
  out: *OneFuncResult,
  snap: *OneFuncResult,
  lex: Lexer,
  name: *u8,
  name_len: i32,
  ret_expr_storage: i32
): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  /* See implementation. */
  onefunc_merge_pool_out_to_snap(snap, out);
  snap.return_expr_ref = ret_expr_storage;
  snap.ok = true;
  snap.next_lex = lex;
  snap.name_len = name_len;
  let ni: i32 = 0;
  while (ni < 64) {
    snap.name[ni] = name[ni];
    ni = ni + 1;
  }
  copy_onefunc_into(out, snap);
  }
}
/** Exported function `onefunc_res_wire_dummy_head`.
 * Implements `onefunc_res_wire_dummy_head`.
 * @param res *OneFuncResult
 * @param lex Lexer
 * @param name64 u8[64]
 * @return void
 */
export function onefunc_res_wire_dummy_head(res: *OneFuncResult, lex: Lexer, name64: u8[64]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let _w: OneFuncResult = OneFuncResult { ok: false, next_lex: lex, name: name64, name_len: 0, num_params: 0 };
  ast_pool_onefunc_reset(onefunc_result_pool_ptr(&_w));
  copy_onefunc_into(res, &_w);
  }
}

/** Exported function `onefunc_res_wire_dummy_const_let`.
 * Implements `onefunc_res_wire_dummy_const_let`.
 * @param res *OneFuncResult
 * @return void
 */
export function onefunc_res_wire_dummy_const_let(res: *OneFuncResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let _w: OneFuncResult = OneFuncResult { num_consts: 0, num_lets: 0 };
  ast_pool_onefunc_reset(onefunc_result_pool_ptr(&_w));
  copy_onefunc_into(res, &_w);
  }
}

/** Exported function `onefunc_res_wire_dummy_if_mul`.
 * Implements `onefunc_res_wire_dummy_if_mul`.
 * @param res *OneFuncResult
 * @return void
 */
export function onefunc_res_wire_dummy_if_mul(res: *OneFuncResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let _w: OneFuncResult = OneFuncResult { has_if_expr: false, if_cond_true: false, if_then_val: 0, if_else_val: 0, if_cond_expr_ref: 0, has_mul: false, mul_right_val: 0 };
  ast_pool_onefunc_reset(onefunc_result_pool_ptr(&_w));
  copy_onefunc_into(res, &_w);
  }
}

/** Exported function `onefunc_res_wire_dummy_call_binop`.
 * Implements `onefunc_res_wire_dummy_call_binop`.
 * @param res *OneFuncResult
 * @param name64 u8[64]
 * @return void
 */
export function onefunc_res_wire_dummy_call_binop(res: *OneFuncResult, name64: u8[64]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let _w: OneFuncResult = OneFuncResult { has_binop: false, binop_right_val: 0, binop_left_param_idx: -1, binop_right_param_idx: -1, has_unary_neg: false, return_val: 0, has_call_expr: false, call_callee_name: name64 };
  ast_pool_onefunc_reset(onefunc_result_pool_ptr(&_w));
  copy_onefunc_into(res, &_w);
  }
}

/** Exported function `onefunc_res_wire_dummy_loop_call`.
 * Implements `onefunc_res_wire_dummy_loop_call`.
 * @param res *OneFuncResult
 * @return void
 */
export function onefunc_res_wire_dummy_loop_call(res: *OneFuncResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let _w: OneFuncResult = OneFuncResult { call_callee_len: 0, return_var_name_len: 0, return_expr_ref: 0, call_num_args: 0, num_loops: 0 };
  ast_pool_onefunc_reset(onefunc_result_pool_ptr(&_w));
  copy_onefunc_into(res, &_w);
  }
}

/** Exported function `onefunc_res_wire_dummy_for_if`.
 * Implements `onefunc_res_wire_dummy_for_if`.
 * @param res *OneFuncResult
 * @return void
 */
export function onefunc_res_wire_dummy_for_if(res: *OneFuncResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let _w: OneFuncResult = OneFuncResult { num_for_loops: 0, num_if_stmts: 0 };
  ast_pool_onefunc_reset(onefunc_result_pool_ptr(&_w));
  copy_onefunc_into(res, &_w);
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function onefunc_alloc_wired_for_parse(lex: Lexer): OneFuncResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let dummy_name: u8[64] = [];
  let res: OneFuncResult = onefunc_scratch_empty();
  ast_pool_onefunc_reset(onefunc_result_pool_ptr(&res));
  onefunc_res_wire_dummy_head(&res, lex, dummy_name);
  onefunc_res_wire_dummy_const_let(&res);
  onefunc_res_wire_dummy_if_mul(&res);
  onefunc_res_wire_dummy_call_binop(&res, dummy_name);
  onefunc_res_wire_dummy_loop_call(&res);
  onefunc_res_wire_dummy_for_if(&res);
  return res;
  }
}

/* See implementation. */
export function onefunc_snap_set_return_path(
  snap: *OneFuncResult,
  has_call: bool,
  ret_var: u8[64],
  ret_var_len: i32,
  ret_expr_ref: i32
): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  snap.has_call_expr = has_call;
  snap.return_var_name_len = ret_var_len;
  snap.return_expr_ref = ret_expr_ref;
  snap.has_explicit_return_kw = true;
  let rvni: i32 = 0;
  while (rvni < 64) {
    snap.return_var_name[rvni] = ret_var[rvni];
    rvni = rvni + 1;
  }
  }
}

/**
 * See implementation.
 */
export function onefunc_push_src_stmt(out: *OneFuncResult, kind: u8, idx: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  /* See implementation. */
  let _so: i32 = pipeline_onefunc_push_stmt_order(onefunc_result_pool_ptr(out), kind, idx);
  if (_so >= 0) {
    out.num_src_stmt_order = pipeline_onefunc_num_src_stmt_order(onefunc_result_pool_ptr(out));
  }
  }
}

/* See implementation. */
export struct ParseExprResult {
  ok: bool;
  expr_ref: i32;
  next_lex: Lexer;
}

/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
/* See implementation. */
export extern function parser_expr_set_common_zeros_glue(e: *ast.Expr): void;
/** Exported function `expr_set_common_zeros`.
 * Implements `expr_set_common_zeros`.
 * @param e *ast.Expr
 * @return void
 */
export function expr_set_common_zeros(e: *ast.Expr): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_expr_set_common_zeros_glue(e);
  }
}


/**
 * See implementation.
 */
export function parser_alloc_true_bool_lit(arena: *ASTArena): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let ref: i32 = ast.ast_arena_expr_alloc(arena);
  if (ref == 0) {
    return 0;
  }
  let e: Expr = ast.ast_arena_expr_get(arena, ref);
  e.kind = ExprKind.EXPR_BOOL_LIT;
  e.int_val = 1;
  e.line = 0;
  e.col = 0;
  expr_set_common_zeros(&e);
  ast.ast_arena_expr_set(arena, ref, e);
  return ref;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function parser_alloc_float_lit(arena: *ASTArena, fval: f64): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let ref: i32 = ast.ast_arena_expr_alloc(arena);
  if (ref == 0) {
    return 0;
  }
  let e: Expr = ast.ast_arena_expr_get(arena, ref);
  e.kind = ExprKind.EXPR_FLOAT_LIT;
  e.float_val = fval;
  e.line = 0;
  e.col = 0;
  expr_set_common_zeros(&e);
  ast.ast_arena_expr_set(arena, ref, e);
  return ref;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function parser_expr_wrap_in_return(arena: *ASTArena, type_ref: i32, inner_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  if (ast.ref_is_null(inner_ref)) {
    return 0;
  }
  let inner: Expr = ast.ast_arena_expr_get(arena, inner_ref);
  if (inner.kind == ExprKind.EXPR_RETURN) {
    return inner_ref;
  }
  let wrap: i32 = ast.ast_arena_expr_alloc(arena);
  if (wrap == 0) {
    return 0;
  }
  let rwe: Expr = ast.ast_arena_expr_get(arena, wrap);
  rwe.kind = ExprKind.EXPR_RETURN;
  rwe.line = 0;
  rwe.col = 0;
  rwe.int_val = 0;
  expr_set_common_zeros(&rwe);
  rwe.resolved_type_ref = type_ref;
  rwe.unary_operand_ref = inner_ref;
  ast.ast_arena_expr_set(arena, wrap, rwe);
  return wrap;
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function parser_should_wrap_func_tail_in_return(arena: *ASTArena, res: *OneFuncResult, type_ref: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  if (ast.ref_is_null(type_ref)) {
    return false;
  }
  let rtw: Type = ast.ast_arena_type_get(arena, type_ref);
  if (rtw.kind == TypeKind.TYPE_VOID) {
    return false;
  }
  return res.has_explicit_return_kw;
  }
}

/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_match_subject_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_match_subject_into`.
 * Implements `parse_match_subject_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_match_subject_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_match_subject_into_glue(arena, lex, source, out);
  }
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_match_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_match_into`.
 * Implements `parse_match_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_match_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_match_into_glue(arena, lex, source, out);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_at_simd_builtin_into_glue(arena: *ASTArena, r0: LexerResult, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_at_simd_builtin_into`.
 * Implements `parse_at_simd_builtin_into`.
 * @param arena *ASTArena
 * @param r0 LexerResult
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_at_simd_builtin_into(arena: *ASTArena, r0: LexerResult, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_at_simd_builtin_into_glue(arena, r0, source, out);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_primary_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_primary_into`.
 * Implements `parse_primary_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_primary_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_primary_into_glue(arena, lex, source, out);
  }
}

/* See implementation. */
export extern function parser_parse_as_suffix_into_glue(arena: *ASTArena, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_as_suffix_into`.
 * Implements `parse_as_suffix_into`.
 * @param arena *ASTArena
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_as_suffix_into(arena: *ASTArena, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_as_suffix_into_glue(arena, source, out);
  }
}


/**
 * See implementation.
 * PLATFORM: SHARED — `~` → EXPR_BITNOT (LANG-006); authority is parser_asm_unary_slice.inc.
 */
/* See implementation. */
export extern function parser_parse_unary_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_unary_into`.
 * Implements `parse_unary_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_unary_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_unary_into_glue(arena, lex, source, out);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_cast_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_cast_into`.
 * Implements `parse_cast_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_cast_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_cast_into_glue(arena, lex, source, out);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_term_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_term_into`.
 * Implements `parse_term_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_term_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_term_into_glue(arena, lex, source, out);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_addsub_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_addsub_into`.
 * Implements `parse_addsub_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_addsub_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_addsub_into_glue(arena, lex, source, out);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_shift_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_shift_into`.
 * Implements `parse_shift_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_shift_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_shift_into_glue(arena, lex, source, out);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_relcompare_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_relcompare_into`.
 * Implements `parse_relcompare_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_relcompare_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_relcompare_into_glue(arena, lex, source, out);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_compare_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_compare_into`.
 * Implements `parse_compare_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_compare_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_compare_into_glue(arena, lex, source, out);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_bitand_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_bitand_into`.
 * Implements `parse_bitand_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_bitand_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_bitand_into_glue(arena, lex, source, out);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_bitxor_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_bitxor_into`.
 * Implements `parse_bitxor_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_bitxor_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_bitxor_into_glue(arena, lex, source, out);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_bitor_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_bitor_into`.
 * Implements `parse_bitor_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_bitor_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_bitor_into_glue(arena, lex, source, out);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_logand_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_logand_into`.
 * Implements `parse_logand_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_logand_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_logand_into_glue(arena, lex, source, out);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_logor_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_logor_into`.
 * Implements `parse_logor_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_logor_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_logor_into_glue(arena, lex, source, out);
  }
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_ternary_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_ternary_into`.
 * Implements `parse_ternary_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_ternary_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_ternary_into_glue(arena, lex, source, out);
  }
}


/** Exported function `is_compound_assign_token`.
 * Query helper `is_compound_assign_token`.
 * @param kind token.TokenKind
 * @return bool
 */
export function is_compound_assign_token(kind: token.TokenKind): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  if (kind == token.TokenKind.TOKEN_PLUS_EQ) {
    return true;
  }
  if (kind == token.TokenKind.TOKEN_MINUS_EQ) {
    return true;
  }
  if (kind == token.TokenKind.TOKEN_STAR_EQ) {
    return true;
  }
  if (kind == token.TokenKind.TOKEN_SLASH_EQ) {
    return true;
  }
  if (kind == token.TokenKind.TOKEN_PERCENT_EQ) {
    return true;
  }
  if (kind == token.TokenKind.TOKEN_AMP_EQ) {
    return true;
  }
  if (kind == token.TokenKind.TOKEN_PIPE_EQ) {
    return true;
  }
  if (kind == token.TokenKind.TOKEN_CARET_EQ) {
    return true;
  }
  if (kind == token.TokenKind.TOKEN_LSHIFT_EQ) {
    return true;
  }
  if (kind == token.TokenKind.TOKEN_RSHIFT_EQ) {
    return true;
  }
  return false;
  }
}

/* See implementation. */
export extern function compound_assign_token_to_expr_kind_from_glue(kind: token.TokenKind): ExprKind;

/** Exported function `compound_assign_token_to_expr_kind`.
 * Implements `compound_assign_token_to_expr_kind`.
 * @param kind token.TokenKind
 * @return ExprKind
 */
export function compound_assign_token_to_expr_kind(kind: token.TokenKind): ExprKind {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return compound_assign_token_to_expr_kind_from_glue(kind);
  }
}



/* See implementation. */
export extern function pipeline_expr_ref_is_assign_lvalue(arena: *ASTArena, expr_ref: i32): bool;

/**
 * See implementation.
 * See implementation.
 */
export function expr_ref_is_assign_lvalue(arena: *ASTArena, expr_ref: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return pipeline_expr_ref_is_assign_lvalue(arena, expr_ref);
  }
  return false;  // unreachable — typeck after unsafe block
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_assign_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void;
/** Exported function `parse_assign_into`.
 * Implements `parse_assign_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_assign_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_assign_into_glue(arena, lex, source, out);
  }
}


/** Exported function `parse_expr_into`.
 * Implements `parse_expr_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
export function parse_expr_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parse_assign_into(arena, lex, source, out);
  }
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
/* See implementation. */
extern function parser_finish_struct_lit_from_type_ident_into_glue(arena: *ASTArena, lit_ref: i32, lex_in_brace: Lexer, source: u8[], out: *ParseExprResult): void;
/** Internal function `finish_struct_lit_from_type_ident_into`.
 * Implements `finish_struct_lit_from_type_ident_into`.
 * @param arena *ASTArena
 * @param lit_ref i32
 * @param lex_in_brace Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
function finish_struct_lit_from_type_ident_into(arena: *ASTArena, lit_ref: i32, lex_in_brace: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_finish_struct_lit_from_type_ident_into_glue(arena, lit_ref, lex_in_brace, source, out);
  }
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
extern function parser_parse_cond_expr_into_glue(arena: *ASTArena, lex_start: Lexer, source: u8[], out: *ParseExprResult): void;
/** Internal function `parse_cond_expr_into`.
 * Implements `parse_cond_expr_into`.
 * @param arena *ASTArena
 * @param lex_start Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
function parse_cond_expr_into(arena: *ASTArena, lex_start: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_cond_expr_into_glue(arena, lex_start, source, out);
  }
}


/** Internal function `parse_expr_with_leading_int_as_into`.
 * Implements `parse_expr_with_leading_int_as_into`.
 * @param arena *ASTArena
 * @param lex_start Lexer
 * @param source u8[]
 * @param out *ParseExprResult
 * @return void
 */
function parse_expr_with_leading_int_as_into(arena: *ASTArena, lex_start: Lexer, source: u8[], out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parse_cond_expr_into(arena, lex_start, source, out);
  }
}


/** Internal function `parse_expr_with_leading_int_as_into_buf`.
 * Implements `parse_expr_with_leading_int_as_into_buf`.
 * @param arena *ASTArena
 * @param lex_start Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
function parse_expr_with_leading_int_as_into_buf(arena: *ASTArena, lex_start: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_expr_with_leading_int_as_into(arena, lex_start, slice, out);
  }
}


/* See implementation. */
struct ParseBlockResult {
  ok: bool;
  block_ref: i32;
  next_lex: Lexer;
}

/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
extern function parser_fill_block_const_let_from_res_glue(arena: *ASTArena, block_ref: i32, res: *OneFuncResult, type_ref: i32): bool;
/** Internal function `fill_block_const_let_from_res`.
 * Implements `fill_block_const_let_from_res`.
 * @param arena *ASTArena
 * @param block_ref i32
 * @param res *OneFuncResult
 * @param type_ref i32
 * @return bool
 */
function fill_block_const_let_from_res(arena: *ASTArena, block_ref: i32, res: *OneFuncResult, type_ref: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_fill_block_const_let_from_res_glue(arena, block_ref, res, type_ref);
  }
  return false;  // unreachable — typeck after unsafe block
}


/**
 * See implementation.
 */
/* See implementation. */
extern function parser_append_block_lets_from_res_glue(arena: *ASTArena, block_ref: i32, res: *OneFuncResult, let_base: i32, type_ref: i32): bool;
/** Internal function `append_block_lets_from_res`.
 * Implements `append_block_lets_from_res`.
 * @param arena *ASTArena
 * @param block_ref i32
 * @param res *OneFuncResult
 * @param let_base i32
 * @param type_ref i32
 * @return bool
 */
function append_block_lets_from_res(arena: *ASTArena, block_ref: i32, res: *OneFuncResult, let_base: i32, type_ref: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_append_block_lets_from_res_glue(arena, block_ref, res, let_base, type_ref);
  }
  return false;  // unreachable — typeck after unsafe block
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
extern function parser_parse_if_stmt_into_glue(arena: *ASTArena, lex_at_if: Lexer, source: u8[], type_ref: i32, out_cond: *i32, out_then: *i32, out_else: *i32, lex_out: *Lexer): bool;
/* See implementation. */
extern function parser_realign_lex_after_if_stmt_onefunc_glue(lex: *Lexer, source: u8[]): void;
/** Internal function `parse_if_stmt_into`.
 * Implements `parse_if_stmt_into`.
 * @param arena *ASTArena
 * @param lex_at_if Lexer
 * @param source u8[]
 * @param type_ref i32
 * @param out_cond *i32
 * @param out_then *i32
 * @param out_else *i32
 * @param lex_out *Lexer
 * @return bool
 */
function parse_if_stmt_into(arena: *ASTArena, lex_at_if: Lexer, source: u8[], type_ref: i32, out_cond: *i32, out_then: *i32, out_else: *i32, lex_out: *Lexer): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_parse_if_stmt_into_glue(arena, lex_at_if, source, type_ref, out_cond, out_then, out_else, lex_out);
  }
  return false;  // unreachable — typeck after unsafe block
}


/**
 * See implementation.
 * See implementation.
 */
export function parse_block_into(arena: *ASTArena, lex_after_lbrace: Lexer, source: u8[], type_ref: i32, out: *ParseBlockResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  /* See implementation. */
  let scratch_sz: usize = pipeline_sizeof_onefunc_result();
  let scratch_raw: *u8 = calloc(1, scratch_sz);
  if (scratch_raw == 0 as *u8) {
    out.ok = false;
    return;
  }
  let temp: *OneFuncResult = scratch_raw as *OneFuncResult;
  ast_pool_onefunc_reset(onefunc_result_pool_ptr(temp));
  temp.ok = true;
  temp.next_lex = lex_after_lbrace;
  temp.return_var_name_len = 0;
  temp.return_expr_ref = 0;
  temp.num_src_stmt_order = 0;
  temp.num_src_body_expr_stmts = 0;
  temp.func_return_type_ref = 0;
  let lex_cur: Lexer = lex_after_lbrace;
  if (!parse_body_lets_into(arena, lex_after_lbrace, source, temp, &lex_cur)) {
    out.ok = false;
    return;
  }
  let block_ref: i32 = ast.ast_arena_block_alloc(arena);
  if (block_ref == 0) {
    out.ok = false;
    return;
  }
  let b: Block = ast.ast_arena_block_get(arena, block_ref);
  b.num_consts = 0;
  b.num_lets = 0;
  b.num_early_lets = 0;
  b.num_loops = 0;
  b.num_for_loops = 0;
  b.num_if_stmts = 0;
  b.num_regions = 0;
  b.num_defers = 0;
  b.num_labeled_stmts = 0;
  b.num_expr_stmts = 0;
  b.final_expr_ref = 0;
  b.num_stmt_order = 0;
  b.parent_block_ref = 0;
  ast.ast_arena_block_set(arena, block_ref, b);
  if (!fill_block_const_let_from_res(arena, block_ref, temp, type_ref)) {
    out.ok = false;
    return;
  }
  b = ast.ast_arena_block_get(arena, block_ref);
  /* See implementation. */
  let block_prefix_lets: i32 = b.num_lets;
  let ci: i32 = 0;
  while (ci < b.num_consts) {
    if (pipeline_block_append_stmt_order(arena, block_ref, 0, ci) < 0) {
      out.ok = false;
      return;
    }
    ci = ci + 1;
  }
  let li: i32 = 0;
  while (li < b.num_lets) {
    if (pipeline_block_append_stmt_order(arena, block_ref, 1, li) < 0) {
      out.ok = false;
      return;
    }
    li = li + 1;
  }
  let r_peek_blk: LexerResult = LexerResult { next_lex: lex_cur, tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 }, token_start: 0 };
  /*
   * See implementation.
   * See implementation.
   * See implementation.
   * See implementation.
   * See implementation.
   */
  lexer.lexer_next_into(&r_peek_blk, lex_cur, source);
  let r: LexerResult = r_peek_blk;
  lex_cur = parser_rewind_lex_for_following_stmt(lex_cur, r_peek_blk);
  let stmt_tok_ready: bool = true;
  let pb_break: i32 = 0;
  /**
   * Hoist-safe expr_stmt path (pin X→C has no stmt_order).
   * PLATFORM: SHARED — Cap force lifts `let stmt_start / expr_stmt_res / rpeek_fe /
   * ex_pool_i = append_expr_stmt(expr_ref=0)` to the top of every while iteration, so each
   * stmt (return/if/...) appends an empty expr_stmt; after return sets pb_break, the next
   * iteration appends a second empty before break → host-cc `(void)(); (void)();` in if bodies
   * (force option residual after param-name fix). Zero here; assign + append only on the
   * real expr_stmt path after parse_expr_into succeeds.
   */
  let stmt_start: Lexer = Lexer { pos: 0 as usize, line: 0, col: 0 };
  let expr_stmt_res: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: stmt_start };
  let rpeek_fe: LexerResult = LexerResult { next_lex: lex_cur, tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 }, token_start: 0 };
  let ex_pool_i: i32 = 0;
  while (1 == 1) {
    if (pb_break != 0) {
      break;
    }
    if (!stmt_tok_ready) {
      lexer.lexer_next_into(&r, lex_cur, source);
    }
    stmt_tok_ready = false;
    /*
     * See implementation.
     * See implementation.
     * See implementation.
     * See implementation.
     */
    if (r.tok.kind == token.TokenKind.TOKEN_RBRACE) {
      break;
    }
    /*
     * See implementation.
     * See implementation.
     * See implementation.
     */
    if (r.tok.kind == token.TokenKind.TOKEN_EOF) {
      out.ok = false;
      return;
    }
    /**
     * See implementation.
     * See implementation.
     */
    if (r.tok.kind == token.TokenKind.TOKEN_LPAREN) {
      lex_cur = parser_rewind_lex_for_lparen_control_stmt(lex_cur, r, source);
      lexer.lexer_next_into(&r, lex_cur, source);
    }
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_LET || r.tok.kind == token.TokenKind.TOKEN_CONST) {
      let let_base_mid: i32 = b.num_lets;
      /* See implementation. */
      ast_pool_onefunc_reset(onefunc_result_pool_ptr(temp));
      temp.num_lets = 0;
      temp.num_consts = 0;
      let kw_back_mid: i32 = 3;
      if (r.tok.kind == token.TokenKind.TOKEN_CONST) {
        kw_back_mid = 5;
      }
      let lex_mid_let: Lexer = Lexer { pos: lexer_pos_before_run(r.next_lex.pos, kw_back_mid), line: r.tok.line, col: r.tok.col };
      if (!parse_body_lets_into(arena, lex_mid_let, source, temp, &lex_cur)) {
        out.ok = false;
        return;
      }
      /* See implementation. */
      if (!append_block_lets_from_res(arena, block_ref, temp, 0, type_ref)) {
        out.ok = false;
        return;
      }
      b = ast.ast_arena_block_get(arena, block_ref);
      let pi_mid: i32 = let_base_mid;
      while (pi_mid < b.num_lets) {
        if (pipeline_block_append_stmt_order(arena, block_ref, 1, pi_mid) < 0) {
          out.ok = false;
          return;
        }
        pi_mid = pi_mid + 1;
      }
      lexer.lexer_next_into(&r, lex_cur, source);
      stmt_tok_ready = true;
      continue;
    }
    /**
     * See implementation.
     * See implementation.
     */
    if (parser_token_is_label_start(r, source)) {
      let label_len_blk: i32 = r.tok.ident_len;
      let label_start_blk: usize = r.token_start;
      if (label_start_blk == 0) {
        label_start_blk = lexer_pos_before_run(r.next_lex.pos, label_len_blk);
      }
      let colon_blk: LexerResult = LexerResult {
        next_lex: r.next_lex,
        tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 },
        token_start: 0
      };
      lexer.lexer_next_into(&colon_blk, r.next_lex, source);
      lex_cur = colon_blk.next_lex;
      lexer.lexer_next_into(&r, lex_cur, source);
      if (r.tok.kind == token.TokenKind.TOKEN_GOTO) {
        lex_from_next_into(&lex_cur, r);
        lexer.lexer_next_into(&r, lex_cur, source);
        if (r.tok.kind != token.TokenKind.TOKEN_IDENT) {
          out.ok = false;
          return;
        }
        let goto_len_blk: i32 = r.tok.ident_len;
        let goto_start_blk: usize = r.token_start;
        if (goto_start_blk == 0) {
          goto_start_blk = lexer_pos_before_run(r.next_lex.pos, goto_len_blk);
        }
        let goto_row_blk: u8[32] = [];
        copy_slice_to_param32(source, goto_start_blk, goto_len_blk, &goto_row_blk[0]);
        lex_from_next_into(&lex_cur, r);
        lexer.lexer_next_into(&r, lex_cur, source);
        if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
          lex_cur = r.next_lex;
          lexer.lexer_next_into(&r, lex_cur, source);
        }
        let label_row_blk: u8[32] = [];
        copy_slice_to_param32(source, label_start_blk, label_len_blk, &label_row_blk[0]);
        let li_goto: i32 = pipeline_block_append_labeled(arena, block_ref, label_len_blk, 1, goto_len_blk, 0);
        if (li_goto < 0) {
          out.ok = false;
          return;
        }
        pipeline_block_labeled_set_names(arena, block_ref, li_goto, &label_row_blk[0], label_len_blk, &goto_row_blk[0], goto_len_blk);
        continue;
      }
      if (r.tok.kind != token.TokenKind.TOKEN_RETURN) {
        out.ok = false;
        return;
      }
      lex_from_next_into(&lex_cur, r);
      let ret_val_lbl: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex_cur };
      lexer.lexer_next_into(&r, lex_cur, source);
      if (r.tok.kind != token.TokenKind.TOKEN_SEMICOLON && r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
        parse_expr_into(arena, lex_cur, source, &ret_val_lbl);
        if (!ret_val_lbl.ok) {
          out.ok = false;
          return;
        }
        lex_cur = ret_val_lbl.next_lex;
        lexer.lexer_next_into(&r, lex_cur, source);
      }
      if (r.tok.kind != token.TokenKind.TOKEN_SEMICOLON && r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
        out.ok = false;
        return;
      }
      if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
        lex_cur = r.next_lex;
        lexer.lexer_next_into(&r, lex_cur, source);
      }
      let label_row_ret: u8[32] = [];
      copy_slice_to_param32(source, label_start_blk, label_len_blk, &label_row_ret[0]);
      let ret_operand: i32 = 0;
      if (ret_val_lbl.ok) {
        ret_operand = ret_val_lbl.expr_ref;
      }
      let li_ret: i32 = pipeline_block_append_labeled(arena, block_ref, label_len_blk, 0, 0, ret_operand);
      if (li_ret < 0) {
        out.ok = false;
        return;
      }
      pipeline_block_labeled_set_names(arena, block_ref, li_ret, &label_row_ret[0], label_len_blk, 0 as *u8, 0);
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_RETURN) {
      lex_from_next_into(&lex_cur, r);
      let ret_val_res: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex_cur };
      let return_ends_block: bool = false;
      lexer.lexer_next_into(&r, lex_cur, source);
      if (r.tok.kind != token.TokenKind.TOKEN_SEMICOLON) {
        parse_expr_into(arena, lex_cur, source, &ret_val_res);
        if (!ret_val_res.ok) {
          out.ok = false;
          return;
        }
        lex_cur = ret_val_res.next_lex;
        lexer.lexer_next_into(&r, lex_cur, source);
      }
      /* See implementation. */
      if (r.tok.kind != token.TokenKind.TOKEN_SEMICOLON && r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
        out.ok = false;
        return;
      }
      if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
        lex_cur = r.next_lex;
        lexer.lexer_next_into(&r, lex_cur, source);
      }
      let ret_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (ret_ref == 0) {
        out.ok = false;
        return;
      }
      let re: Expr = ast.ast_arena_expr_get(arena, ret_ref);
      re.kind = ExprKind.EXPR_RETURN;
      re.line = 0;
      re.col = 0;
      expr_set_common_zeros(&re);
      if (ret_val_res.ok) {
        re.unary_operand_ref = ret_val_res.expr_ref;
      }
      ast.ast_arena_expr_set(arena, ret_ref, re);
      b = ast.ast_arena_block_get(arena, block_ref);
      return_ends_block = r.tok.kind == token.TokenKind.TOKEN_RBRACE;
      if (return_ends_block) {
        b.final_expr_ref = ret_ref;
        ast.ast_arena_block_set(arena, block_ref, b);
      } else {
        let ret_ex_i: i32 = pipeline_block_append_expr_stmt(arena, block_ref, ret_ref);
        if (ret_ex_i < 0) {
          out.ok = false;
          return;
        }
        if (pipeline_block_append_stmt_order(arena, block_ref, 2, ret_ex_i) < 0) {
          out.ok = false;
          return;
        }
        b = ast.ast_arena_block_get(arena, block_ref);
      }
      /* See implementation. */
      parser_asm_parse_block_return_end_tail_glue(&r, &lex_cur, source, &stmt_tok_ready, &pb_break);
      /* See implementation. */
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_LOOP) {
      /**
       * Hoist-safe for pin X→C (no stmt_order): zero-init + assign after parse.
       * `let while_idx_blk = append_while(...)` at mid-path is hoisted to the if-top and
       * registers an empty while before the body is parsed — force `loop`/`while` residual.
       * PLATFORM: SHARED — product force parser path; seed pin does not hoist the same way.
       */
      let cond_ref_blk: i32 = 0;
      let block_res_blk: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex_cur };
      let while_idx_blk: i32 = 0;
      lex_from_next_into(&lex_cur, r);
      lexer.lexer_next_into(&r, lex_cur, source);
      if (r.tok.kind != token.TokenKind.TOKEN_LBRACE) {
        out.ok = false;
        return;
      }
      lex_cur = r.next_lex;
      cond_ref_blk = parser_alloc_true_bool_lit(arena);
      if (cond_ref_blk == 0) {
        out.ok = false;
        return;
      }
      block_res_blk = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex_cur };
      parse_block_into(arena, lex_cur, source, type_ref, &block_res_blk);
      if (!block_res_blk.ok) {
        out.ok = false;
        return;
      }
      while_idx_blk = pipeline_block_append_while(arena, block_ref, cond_ref_blk, block_res_blk.block_ref);
      if (while_idx_blk < 0) {
        out.ok = false;
        return;
      }
      if (pipeline_block_append_stmt_order(arena, block_ref, 3, while_idx_blk) < 0) {
        out.ok = false;
        return;
      }
      b = ast.ast_arena_block_get(arena, block_ref);
      lex_cur = block_res_blk.next_lex;
      /**
       * parse_block_into() already returned the next stmt head after loop;
       * do not realign again or body-tail expr_stmt leaks to the outer block.
       */
      stmt_tok_ready = false;
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_WHILE) {
      /**
       * Hoist-safe while (block path): pin X→C hoists mid-path lets to if-top.
       * Bad hoist was: loop_cond_start=lex before advancing past WHILE; cond_ref=expr_ref
       * before parse_cond; while_idx=append_while(0,0) before body — force while XP003,
       * hello missing core_fmt_fmt_*_to_buf co-emit.
       * PLATFORM: SHARED.
       */
      let loop_cond_start: Lexer = lex_cur;
      let expr_res: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex_cur };
      let cond_ref: i32 = 0;
      let block_res: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex_cur };
      let while_idx: i32 = 0;
      lex_from_next_into(&lex_cur, r);
      lexer.lexer_next_into(&r, lex_cur, source);
      if (r.tok.kind != token.TokenKind.TOKEN_LPAREN) {
        out.ok = false;
        return;
      }
      lex_cur = r.next_lex;
      loop_cond_start = lex_cur;
      expr_res = ParseExprResult { ok: false, expr_ref: 0, next_lex: loop_cond_start };
      parse_cond_expr_into(arena, loop_cond_start, source, &expr_res);
      if (!expr_res.ok) {
        out.ok = false;
        return;
      }
      cond_ref = expr_res.expr_ref;
      lex_cur = expr_res.next_lex;
      if (advance_past_cond_rparen_into(&r, lex_cur, source) == 0) {
        out.ok = false;
        return;
      }
      /* advance_past already wrote r; do not lexer_next again (if-nested while needs `{`). */
      if (r.tok.kind != token.TokenKind.TOKEN_LBRACE) {
        out.ok = false;
        return;
      }
      lex_cur = r.next_lex;
      block_res = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex_cur };
      parse_block_into(arena, lex_cur, source, type_ref, &block_res);
      if (!block_res.ok) {
        out.ok = false;
        return;
      }
      while_idx = pipeline_block_append_while(arena, block_ref, cond_ref, block_res.block_ref);
      if (while_idx < 0) {
        out.ok = false;
        return;
      }
      if (pipeline_block_append_stmt_order(arena, block_ref, 3, while_idx) < 0) {
        out.ok = false;
        return;
      }
      b = ast.ast_arena_block_get(arena, block_ref);
      lex_cur = block_res.next_lex;
      /* while body sync complete; no second compound realign. */
      stmt_tok_ready = false;
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_FOR) {
      /**
       * Hoist-safe for (block path): same pin X→C rule as while — append_for only after
       * init/cond/step/body parse success. PLATFORM: SHARED.
       */
      let init_ref: i32 = 0;
      let cond_ref: i32 = 0;
      let step_ref: i32 = 0;
      let block_res: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex_cur };
      let for_idx: i32 = 0;
      let expr_res_fi: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex_cur };
      let expr_res_fc: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex_cur };
      let expr_res_fs: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex_cur };
      let cond_expr_ref: i32 = 0;
      lex_from_next_into(&lex_cur, r);
      lexer.lexer_next_into(&r, lex_cur, source);
      if (r.tok.kind != token.TokenKind.TOKEN_LPAREN) {
        out.ok = false;
        return;
      }
      lex_cur = r.next_lex;
      lexer.lexer_next_into(&r, lex_cur, source);
      if (r.tok.kind != token.TokenKind.TOKEN_SEMICOLON) {
        expr_res_fi = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex_cur };
        parse_expr_into(arena, lex_cur, source, &expr_res_fi);
        if (!expr_res_fi.ok) {
          out.ok = false;
          return;
        }
        init_ref = expr_res_fi.expr_ref;
        lex_cur = expr_res_fi.next_lex;
        lexer.lexer_next_into(&r, lex_cur, source);
      }
      if (r.tok.kind != token.TokenKind.TOKEN_SEMICOLON) {
        out.ok = false;
        return;
      }
      lex_cur = r.next_lex;
      lexer.lexer_next_into(&r, lex_cur, source);
      if (r.tok.kind != token.TokenKind.TOKEN_SEMICOLON) {
        expr_res_fc = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex_cur };
        parse_expr_into(arena, lex_cur, source, &expr_res_fc);
        if (!expr_res_fc.ok) {
          out.ok = false;
          return;
        }
        cond_ref = expr_res_fc.expr_ref;
        lex_cur = expr_res_fc.next_lex;
        lexer.lexer_next_into(&r, lex_cur, source);
      }
      if (r.tok.kind != token.TokenKind.TOKEN_SEMICOLON) {
        out.ok = false;
        return;
      }
      lex_cur = r.next_lex;
      lexer.lexer_next_into(&r, lex_cur, source);
      if (r.tok.kind != token.TokenKind.TOKEN_RPAREN) {
        expr_res_fs = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex_cur };
        parse_expr_into(arena, lex_cur, source, &expr_res_fs);
        if (!expr_res_fs.ok) {
          out.ok = false;
          return;
        }
        step_ref = expr_res_fs.expr_ref;
        lex_cur = expr_res_fs.next_lex;
        lexer.lexer_next_into(&r, lex_cur, source);
      }
      if (r.tok.kind != token.TokenKind.TOKEN_RPAREN) {
        out.ok = false;
        return;
      }
      lex_cur = r.next_lex;
      lexer.lexer_next_into(&r, lex_cur, source);
      if (r.tok.kind != token.TokenKind.TOKEN_LBRACE) {
        out.ok = false;
        return;
      }
      lex_cur = r.next_lex;
      block_res = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex_cur };
      parse_block_into(arena, lex_cur, source, type_ref, &block_res);
      if (!block_res.ok) {
        out.ok = false;
        return;
      }
      if (cond_ref == 0) {
        cond_expr_ref = ast.ast_arena_expr_alloc(arena);
        if (cond_expr_ref != 0) {
          let ce: Expr = ast.ast_arena_expr_get(arena, cond_expr_ref);
          ce.kind = ExprKind.EXPR_BOOL_LIT;
          ce.int_val = 1;
          ce.line = 0;
          ce.col = 0;
          expr_set_common_zeros(&ce);
          ast.ast_arena_expr_set(arena, cond_expr_ref, ce);
          cond_ref = cond_expr_ref;
        }
      }
      for_idx = pipeline_block_append_for(arena, block_ref, init_ref, cond_ref, step_ref, block_res.block_ref);
      if (for_idx < 0) {
        out.ok = false;
        return;
      }
      if (pipeline_block_append_stmt_order(arena, block_ref, 4, for_idx) < 0) {
        out.ok = false;
        return;
      }
      b = ast.ast_arena_block_get(arena, block_ref);
      lex_cur = block_res.next_lex;
      stmt_tok_ready = false;
      continue;
    }
    /**
     * MEM-B0: defer { body } — LIFO at block exit (align parser.c parse_defer_start).
     * Hoist-safe (block path): pin X→C otherwise does
     * append_defer(body_ref=0) before parse_block_into — force drops defer body.
     * PLATFORM: SHARED — same mid-path let hoist class as unsafe/while.
     */
    if (r.tok.kind == token.TokenKind.TOKEN_DEFER) {
      let block_res_def: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex_cur };
      let def_i: i32 = 0;
      lex_from_next_into(&lex_cur, r);
      lexer.lexer_next_into(&r, lex_cur, source);
      if (r.tok.kind != token.TokenKind.TOKEN_LBRACE) {
        out.ok = false;
        return;
      }
      /* parse_block_into wants lex_after_lbrace (same as while/loop/for). */
      lex_cur = r.next_lex;
      block_res_def = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex_cur };
      parse_block_into(arena, lex_cur, source, type_ref, &block_res_def);
      if (!block_res_def.ok) {
        out.ok = false;
        return;
      }
      def_i = pipeline_block_append_defer(arena, block_ref, block_res_def.block_ref);
      if (def_i < 0) {
        out.ok = false;
        return;
      }
      b = ast.ast_arena_block_get(arena, block_ref);
      lex_cur = block_res_def.next_lex;
      /* Body already synced the full defer stmt; no compound realign (leaks body expr). */
      stmt_tok_ready = false;
      continue;
    }
    /**
     * MEM-C1: with_arena(cap) { body }; X stmt_order kind=6 (shared region idx pool; cap_ref>0).
     * Hoist-safe: zero-init + assign after parse; mid-path let append_with_arena(0,0)
     * before body would register empty region (force with_arena residual).
     * PLATFORM: SHARED.
     */
    if (r.tok.kind == token.TokenKind.TOKEN_WITH_ARENA) {
      let cap_ref: i32 = 0;
      let cap_res: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex_cur };
      let block_res_wa: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex_cur };
      let wa_pool_i: i32 = 0;
      lex_from_next_into(&lex_cur, r);
      lexer.lexer_next_into(&r, lex_cur, source);
      if (r.tok.kind != token.TokenKind.TOKEN_LPAREN) {
        out.ok = false;
        return;
      }
      lex_from_next_into(&lex_cur, r);
      cap_res = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex_cur };
      parse_expr_into(arena, lex_cur, source, &cap_res);
      if (!cap_res.ok || cap_res.expr_ref == 0) {
        out.ok = false;
        return;
      }
      cap_ref = cap_res.expr_ref;
      lex_cur = cap_res.next_lex;
      lexer.lexer_next_into(&r, lex_cur, source);
      if (r.tok.kind != token.TokenKind.TOKEN_RPAREN) {
        out.ok = false;
        return;
      }
      lex_from_next_into(&lex_cur, r);
      lexer.lexer_next_into(&r, lex_cur, source);
      if (r.tok.kind != token.TokenKind.TOKEN_LBRACE) {
        out.ok = false;
        return;
      }
      lex_from_next_into(&lex_cur, r);
      block_res_wa = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex_cur };
      parse_block_into(arena, lex_cur, source, type_ref, &block_res_wa);
      if (!block_res_wa.ok) {
        out.ok = false;
        return;
      }
      wa_pool_i = pipeline_block_append_with_arena(arena, block_ref, cap_ref, block_res_wa.block_ref);
      if (wa_pool_i < 0) {
        out.ok = false;
        return;
      }
      if (pipeline_block_append_stmt_order(arena, block_ref, 6, wa_pool_i) < 0) {
        out.ok = false;
        return;
      }
      b = ast.ast_arena_block_get(arena, block_ref);
      lex_cur = block_res_wa.next_lex;
      lexer.lexer_next_into(&r, lex_cur, source);
      lex_cur = parser_realign_lex_after_compound_stmt(lex_cur, r, source);
      stmt_tok_ready = false;
      continue;
    }
    /**
     * M-3: region label { body }; X stmt_order kind=6.
     * Hoist-safe: append_region only after body parse (same class as unsafe/defer).
     * PLATFORM: SHARED.
     */
    if (r.tok.kind == token.TokenKind.TOKEN_REGION) {
      let reg_label_blk: u8[64] = [];
      let reg_label_len_blk: i32 = 0;
      let block_res_reg: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex_cur };
      let reg_pool_i: i32 = 0;
      lex_from_next_into(&lex_cur, r);
      lexer.lexer_next_into(&r, lex_cur, source);
      if (r.tok.kind != token.TokenKind.TOKEN_IDENT) {
        out.ok = false;
        return;
      }
      copy_slice_to_name64(source, r.token_start, r.tok.ident_len, &reg_label_blk[0]);
      reg_label_len_blk = r.tok.ident_len;
      lex_from_next_into(&lex_cur, r);
      lexer.lexer_next_into(&r, lex_cur, source);
      if (r.tok.kind != token.TokenKind.TOKEN_LBRACE) {
        out.ok = false;
        return;
      }
      /* parse_block_into wants lex after `{` (same as while/for). */
      lex_from_next_into(&lex_cur, r);
      block_res_reg = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex_cur };
      parse_block_into(arena, lex_cur, source, type_ref, &block_res_reg);
      if (!block_res_reg.ok) {
        out.ok = false;
        return;
      }
      reg_pool_i = pipeline_block_append_region(arena, block_ref, &reg_label_blk[0], reg_label_len_blk, block_res_reg.block_ref);
      if (reg_pool_i < 0) {
        out.ok = false;
        return;
      }
      if (pipeline_block_append_stmt_order(arena, block_ref, 6, reg_pool_i) < 0) {
        out.ok = false;
        return;
      }
      b = ast.ast_arena_block_get(arena, block_ref);
      lex_cur = block_res_reg.next_lex;
      lexer.lexer_next_into(&r, lex_cur, source);
      lex_cur = parser_realign_lex_after_compound_stmt(lex_cur, r, source);
      stmt_tok_ready = false;
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_IDENT && r.tok.ident_len == 6) {
      /* See implementation. */
      let unsafe_nm: u8[64] = [];
      copy_slice_to_name64(source, r.token_start, r.tok.ident_len, &unsafe_nm[0]);
      if (unsafe_nm[0] == 117 && unsafe_nm[1] == 110 && unsafe_nm[2] == 115 && unsafe_nm[3] == 97
      && unsafe_nm[4] == 102 && unsafe_nm[5] == 101) {
        /**
         * Hoist-safe unsafe (block path): pin X→C otherwise does
         * append_unsafe(body_ref=0) before parse_block_into — force drops
         * `unsafe { return shux_sys_*; }` (hello io_libc_* residual).
         * PLATFORM: SHARED.
         */
        let block_res_unsafe: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex_cur };
        let unsafe_pool_i: i32 = 0;
        lex_from_next_into(&lex_cur, r);
        lexer.lexer_next_into(&r, lex_cur, source);
        if (r.tok.kind != token.TokenKind.TOKEN_LBRACE) {
          out.ok = false;
          return;
        }
        lex_from_next_into(&lex_cur, r);
        block_res_unsafe = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex_cur };
        parse_block_into(arena, lex_cur, source, type_ref, &block_res_unsafe);
        if (!block_res_unsafe.ok) {
          out.ok = false;
          return;
        }
        unsafe_pool_i = pipeline_block_append_unsafe(arena, block_ref, block_res_unsafe.block_ref);
        if (unsafe_pool_i < 0) {
          out.ok = false;
          return;
        }
        if (pipeline_block_append_stmt_order(arena, block_ref, 6, unsafe_pool_i) < 0) {
          out.ok = false;
          return;
        }
        b = ast.ast_arena_block_get(arena, block_ref);
        lex_cur = block_res_unsafe.next_lex;
        /* parse_block already returned next stmt head; no second realign. */
        stmt_tok_ready = false;
        continue;
      }
    }
    if (r.tok.kind == token.TokenKind.TOKEN_IF) {
      let if_start: Lexer = lex_at_token_from_result(r);
      let if_cond: i32 = 0;
      let if_then: i32 = 0;
      let if_else: i32 = 0;
      if (!parse_if_stmt_into(arena, if_start, source, type_ref, &if_cond, &if_then, &if_else, &lex_cur)) {
        out.ok = false;
        return;
      }
      let if_pool_i: i32 = pipeline_block_append_if(arena, block_ref, if_cond, if_then, if_else);
      if (if_pool_i < 0) {
        out.ok = false;
        return;
      }
      if (pipeline_block_append_stmt_order(arena, block_ref, 5, if_pool_i) < 0) {
        out.ok = false;
        return;
      }
      b = ast.ast_arena_block_get(arena, block_ref);
      /**
       * See implementation.
       * See implementation.
       * See implementation.
       */
      stmt_tok_ready = false;
      continue;
    }
    /**
     * Bare block statement `{ stmts }` at statement position (C compound statement).
     * PLATFORM: SHARED — not a block-expression that requires a trailing `;`.
     * Why: mega parse_into uses `{ let try_cfg_allow = ...; ... } module.pending_cfg_skip = 0;`
     * inside `if (pending_cfg_skip)`. Treating `{` as parse_expr + require `;` fails the whole
     * function (parse-skip of parse_into / parse_into_buf). Represent as expr_stmt of EXPR_BLOCK
     * so codegen emits nested `{ ... }` without requiring a semicolon after the closing brace.
     */
    if (r.tok.kind == token.TokenKind.TOKEN_LBRACE) {
      /**
       * Hoist-safe bare block: wrap/append only after parse_block_into succeeds.
       * Pin X→C otherwise pushes empty expr_stmt before the nested body is parsed.
       * PLATFORM: SHARED.
       */
      let block_res_bare: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex_cur };
      let bare_expr: i32 = 0;
      let bare_ex_i: i32 = 0;
      lex_from_next_into(&lex_cur, r);
      block_res_bare = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex_cur };
      parse_block_into(arena, lex_cur, source, type_ref, &block_res_bare);
      if (!block_res_bare.ok) {
        out.ok = false;
        return;
      }
      bare_expr = wrap_block_ref_as_expr(arena, block_res_bare.block_ref, type_ref);
      if (bare_expr == 0) {
        out.ok = false;
        return;
      }
      bare_ex_i = pipeline_block_append_expr_stmt(arena, block_ref, bare_expr);
      if (bare_ex_i < 0) {
        out.ok = false;
        return;
      }
      if (pipeline_block_append_stmt_order(arena, block_ref, 2, bare_ex_i) < 0) {
        out.ok = false;
        return;
      }
      b = ast.ast_arena_block_get(arena, block_ref);
      lex_cur = block_res_bare.next_lex;
      stmt_tok_ready = false;
      continue;
    }
    /* expr; — hoist-safe: reset then parse; append only after success (not loop-top let). */
    stmt_start = lex_at_token_from_result(r);
    parse_expr_result_reset(&expr_stmt_res, stmt_start);
    /*
     * See implementation.
     * See implementation.
     */
    parse_expr_into(arena, stmt_start, source, &expr_stmt_res);
    if (!expr_stmt_res.ok) {
      out.ok = false;
      return;
    }
    lex_cur = expr_stmt_res.next_lex;
    /* See implementation. */
    rpeek_fe = LexerResult { next_lex: lex_cur, tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 }, token_start: 0 };
    lexer.lexer_next_into(&rpeek_fe, lex_cur, source);
    if (rpeek_fe.tok.kind == token.TokenKind.TOKEN_RBRACE) {
      b.final_expr_ref = expr_stmt_res.expr_ref;
      ast.ast_arena_block_set(arena, block_ref, b);
      /* See implementation. */
      r = rpeek_fe;
      break;
    }
    /* See implementation. */
    if (advance_past_stmt_semicolon_into(&r, lex_cur, source) == 0) {
      if (r.tok.kind == token.TokenKind.TOKEN_RBRACE) {
        b.final_expr_ref = expr_stmt_res.expr_ref;
        ast.ast_arena_block_set(arena, block_ref, b);
        break;
      }
      out.ok = false;
      return;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_RBRACE) {
      b.final_expr_ref = expr_stmt_res.expr_ref;
      ast.ast_arena_block_set(arena, block_ref, b);
      break;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
      lex_from_result_ptr_into(&lex_cur, &r);
      let after_semi_blk: LexerResult = LexerResult { next_lex: lex_cur, tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 }, token_start: 0 };
      lexer.lexer_next_into(&after_semi_blk, lex_cur, source);
      r = after_semi_blk;
    }
    ex_pool_i = pipeline_block_append_expr_stmt(arena, block_ref, expr_stmt_res.expr_ref);
    if (ex_pool_i < 0) {
      out.ok = false;
      return;
    }
    if (pipeline_block_append_stmt_order(arena, block_ref, 2, ex_pool_i) < 0) {
      out.ok = false;
      return;
    }
    b = ast.ast_arena_block_get(arena, block_ref);
    stmt_tok_ready = true;
    continue;
  }
  b = ast.ast_arena_block_get(arena, block_ref);
  /*
   * See implementation.
   * See implementation.
   */
  if (b.num_lets > 0 && b.num_stmt_order == 0) {
    let li_fix: i32 = 0;
    while (li_fix < b.num_lets) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 1, li_fix) < 0) {
        out.ok = false;
        return;
      }
      li_fix = li_fix + 1;
    }
    b = ast.ast_arena_block_get(arena, block_ref);
  }
  /* See implementation. */
  if (block_prefix_lets > 0) {
    pipeline_block_stmt_order_fix_prefix_lets(arena, block_ref, block_prefix_lets);
    b = ast.ast_arena_block_get(arena, block_ref);
  }
  ast.ast_arena_block_set(arena, block_ref, b);
  out.ok = true;
  out.block_ref = block_ref;
  out.next_lex = r.next_lex;
  }
}

/**
 * See implementation.
 */
export function wrap_block_ref_as_expr(arena: *ASTArena, block_ref: i32, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  if (block_ref == 0) {
    return 0;
  }
  let ref: i32 = ast.ast_arena_expr_alloc(arena);
  if (ref == 0) {
    return 0;
  }
  let e: Expr = ast.ast_arena_expr_get(arena, ref);
  expr_set_common_zeros(&e);
  e.kind = ExprKind.EXPR_BLOCK;
  e.block_ref = block_ref;
  e.resolved_type_ref = type_ref;
  e.line = 0;
  e.col = 0;
  ast.ast_arena_expr_set(arena, ref, e);
  return ref;
  }
}

/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_if_expr_into_glue(arena: *ASTArena, lex_at_if: Lexer, source: u8[], type_ref: i32, out: *ParseExprResult): void;
/** Exported function `parse_if_expr_into`.
 * Implements `parse_if_expr_into`.
 * @param arena *ASTArena
 * @param lex_at_if Lexer
 * @param source u8[]
 * @param type_ref i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_if_expr_into(arena: *ASTArena, lex_at_if: Lexer, source: u8[], type_ref: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_if_expr_into_glue(arena, lex_at_if, source, type_ref, out);
  }
}


/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function parse(source: u8[]): ParseResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let arena_heap_bytes: usize = pipeline_sizeof_arena();
  let lex: Lexer = lexer.lexer_init();
  let r: LexerResult = LexerResult { next_lex: lex, tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 }, token_start: 0 };
  lexer.lexer_next_into(&r, lex, source);
  if (r.tok.kind != token.TokenKind.TOKEN_FUNCTION) {
    return ParseResult { ok: false, return_val: 0 }
  }
  lex_from_next_into(&lex, r);
  lexer.lexer_next_into(&r, lex, source);
  if (r.tok.kind != token.TokenKind.TOKEN_IDENT) {
    return ParseResult { ok: false, return_val: 0 }
  }
  lex_from_next_into(&lex, r);
  lexer.lexer_next_into(&r, lex, source);
  if (r.tok.kind != token.TokenKind.TOKEN_LPAREN) {
    return ParseResult { ok: false, return_val: 0 }
  }
  lex_from_next_into(&lex, r);
  lexer.lexer_next_into(&r, lex, source);
  if (r.tok.kind != token.TokenKind.TOKEN_RPAREN) {
    return ParseResult { ok: false, return_val: 0 }
  }
  lex_from_next_into(&lex, r);
  lexer.lexer_next_into(&r, lex, source);
  if (r.tok.kind != token.TokenKind.TOKEN_COLON) {
    return ParseResult { ok: false, return_val: 0 }
  }
  lex_from_next_into(&lex, r);
  lexer.lexer_next_into(&r, lex, source);
  if (r.tok.kind != token.TokenKind.TOKEN_I32) {
    return ParseResult { ok: false, return_val: 0 }
  }
  lex_from_next_into(&lex, r);
  lexer.lexer_next_into(&r, lex, source);
  if (r.tok.kind != token.TokenKind.TOKEN_LBRACE) {
    return ParseResult { ok: false, return_val: 0 }
  }
  lex_from_next_into(&lex, r);
  lexer.lexer_next_into(&r, lex, source);
  if (r.tok.kind != token.TokenKind.TOKEN_RETURN) {
    return ParseResult { ok: false, return_val: 0 }
  }
  lex_from_next_into(&lex, r);
  let lex_at_expr_start: Lexer = lex;
  lexer.lexer_next_into(&r, lex, source);
  let ret_val: i32 = 0;
  if (r.tok.kind == token.TokenKind.TOKEN_INT) {
    ret_val = r.tok.int_val;
    lex_from_next_into(&lex, r);
  } else {
    let raw_arena: *u8 = calloc(1, arena_heap_bytes);
    if (raw_arena == 0 as *u8) {
      return ParseResult { ok: false, return_val: 0 }
    }
    let heap_arena: *ASTArena = raw_arena as *ASTArena;
    ast.ast_arena_init(heap_arena);
    let expr_out: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex };
    parse_expr_into(heap_arena, lex_at_expr_start, source, &expr_out);
    if (!expr_out.ok || expr_out.expr_ref <= 0) {
      free(raw_arena);
      return ParseResult { ok: false, return_val: 0 }
    }
    let e_read: Expr = ast.ast_arena_expr_get(heap_arena, expr_out.expr_ref);
    if (e_read.const_folded_valid != 0) {
      ret_val = e_read.const_folded_val;
    }
    lex = expr_out.next_lex;
    free(raw_arena);
  }
  lexer.lexer_next_into(&r, lex, source);
  if (r.tok.kind != token.TokenKind.TOKEN_SEMICOLON) {
    return ParseResult { ok: false, return_val: 0 }
  }
  lex_from_next_into(&lex, r);
  lexer.lexer_next_into(&r, lex, source);
  if (r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
    return ParseResult { ok: false, return_val: 0 }
  }
  lex_from_next_into(&lex, r);
  lexer.lexer_next_into(&r, lex, source);
  if (r.tok.kind != token.TokenKind.TOKEN_EOF) {
    return ParseResult { ok: false, return_val: 0 }
  }
  return ParseResult { ok: true, return_val: ret_val }
  }
}

/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_first_token_kind_glue(source: u8[]): i32;
/** Exported function `first_token_kind`.
 * Implements `first_token_kind`.
 * @param source u8[]
 * @return i32
 */
export function first_token_kind(source: u8[]): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_first_token_kind_glue(source);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/** Exported function `first_token_kind_buf`.
 * Implements `first_token_kind_buf`.
 * @param data *u8
 * @param len i32
 * @return i32
 */
export function first_token_kind_buf(data: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return first_token_kind(slice);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_diag_first_ident_len_glue(source: u8[]): i32;
/** Exported function `diag_first_ident_len`.
 * Query helper `diag_first_ident_len`.
 * @param source u8[]
 * @return i32
 */
export function diag_first_ident_len(source: u8[]): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_diag_first_ident_len_glue(source);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/** Exported function `diag_first_ident_len_buf`.
 * Implements `diag_first_ident_len_buf`.
 * @param data *u8
 * @param len i32
 * @return i32
 */
export function diag_first_ident_len_buf(data: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return diag_first_ident_len(slice);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_diag_skip_let_const_into_glue(out: *LexerResult, lex: Lexer, source: u8[]): void;
/** Exported function `diag_skip_let_const_into`.
 * Implements `diag_skip_let_const_into`.
 * @param out *LexerResult
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
export function diag_skip_let_const_into(out: *LexerResult, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_diag_skip_let_const_into_glue(out, lex, source);
  }
}


/* See implementation. */
/* See implementation. */
export extern function parser_diag_skip_let_const_glue(lex: Lexer, source: u8[]): LexerResult;
/** Exported function `diag_skip_let_const`.
 * Implements `diag_skip_let_const`.
 * @param lex Lexer
 * @param source u8[]
 * @return LexerResult
 */
export function diag_skip_let_const(lex: Lexer, source: u8[]): LexerResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_diag_skip_let_const_glue(lex, source);
  }
}


/** Exported function `diag_skip_let_const_buf`.
 * Implements `diag_skip_let_const_buf`.
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return LexerResult
 */
export function diag_skip_let_const_buf(lex: Lexer, data: *u8, len: i32): LexerResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return diag_skip_let_const(lex, slice);
  }
}


/** Exported function `diag_skip_let_const_into_buf`.
 * Implements `diag_skip_let_const_into_buf`.
 * @param out *LexerResult
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
export function diag_skip_let_const_into_buf(out: *LexerResult, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  diag_skip_let_const_into(out, lex, slice);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_body_skip_let_const_then_if_into_glue(out: *LexerResult, lex: Lexer, source: u8[]): void;
/** Exported function `body_skip_let_const_then_if_into`.
 * Implements `body_skip_let_const_then_if_into`.
 * @param out *LexerResult
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
export function body_skip_let_const_then_if_into(out: *LexerResult, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_body_skip_let_const_then_if_into_glue(out, lex, source);
  }
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_body_let_bracket_compound_init_ref_glue(arena: *ASTArena, bracket_start: usize, lex: Lexer, source: u8[],
                                                  lex_out: *Lexer, r_out: *LexerResult): i32;
/** Function `parse_body_let_bracket_compound_init_ref`.
 * Purpose: implements `parse_body_let_bracket_compound_init_ref`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function parse_body_let_bracket_compound_init_ref(arena: *ASTArena, bracket_start: usize, lex: Lexer, source: u8[],
                                                  lex_out: *Lexer, r_out: *LexerResult): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_parse_body_let_bracket_compound_init_ref_glue(arena, bracket_start, lex, source, lex_out, r_out);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_type_ref_for_arena_into_glue(arena: *ASTArena, lex: Lexer, source: u8[], out_lex: *Lexer): i32;
/** Exported function `parse_type_ref_for_arena_into`.
 * Implements `parse_type_ref_for_arena_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out_lex *Lexer
 * @return i32
 */
export function parse_type_ref_for_arena_into(arena: *ASTArena, lex: Lexer, source: u8[], out_lex: *Lexer): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_parse_type_ref_for_arena_into_glue(arena, lex, source, out_lex);
  }
  return 0;  // unreachable — typeck after unsafe block
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
/** Internal function `parse_body_lets_into`.
 * Implements `parse_body_lets_into`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @param out *OneFuncResult
 * @param lex_out *Lexer
 * @return bool
 */
function parse_body_lets_into(arena: *ASTArena, lex: Lexer, source: u8[], out: *OneFuncResult, lex_out: *Lexer): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let pool: *u8 = onefunc_result_pool_ptr(out);
  let r: LexerResult = LexerResult { next_lex: lex, tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 }, token_start: 0 };
  let expr_tmp: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex };
  lexer.lexer_next_into(&r, lex, source);
  /* See implementation. */
  if (r.tok.kind != token.TokenKind.TOKEN_LET && r.tok.kind != token.TokenKind.TOKEN_CONST) {
    lex = lex_at_token_from_result(r);
    lex_out.pos = lex.pos;
    lex_out.line = lex.line;
    lex_out.col = lex.col;
    return true;
  }
  while (1 == 1) {
    if (r.tok.kind != token.TokenKind.TOKEN_LET && r.tok.kind != token.TokenKind.TOKEN_CONST) {
      break;
    }
    /*
     * let-hoist safe (product pin X→C, no stmt_order):
     * While-body `let x = r.tok...` is moved to the loop top before lexer_next on the
     * binding name. Capture name_len/name_start only AFTER next; zero-pad with zi=ni
     * only AFTER the name bytes are copied (else name_len stays LET's 0 → P001, or
     * zi=0 wipes the just-copied name_row).
     * PLATFORM: SHARED — force M2 residual body let; seed parser already correct.
     */
    let is_let: bool = r.tok.kind == token.TokenKind.TOKEN_LET;
    /** Current let slot init/type; append to sidecar pool after parse (no 256 cap). */
    let let_init_val: i32 = 0;
    let let_init_ref: i32 = 0;
    let let_ty_ref: i32 = 0;
    let is_discard_name: i32 = 0;
    let name_len: i32 = 0;
    let name_start: usize = 0;
    let name_row: u8[64] = [];
    let ni: i32 = 0;
    let zi: i32 = 0;
    lex_from_result_ptr_into(&lex, &r);
    lexer.lexer_next_into(&r, lex, source);
    /* discard binding `let _`: lexer emits TOKEN_UNDERSCORE (ident_len=0) as name "_".
     * Rejecting would abort parse_body_lets; skip may mis-parse body lets as top-level static.
     * `let self`: TOKEN_SELF (keyword, ident_len=0) is a valid binding name "self" (phase 7.2
     * receiver spelling re-used as ordinary local); same silent-drop class as param list. */
    if (r.tok.kind == token.TokenKind.TOKEN_UNDERSCORE) {
      is_discard_name = 1;
    } else if (r.tok.kind != token.TokenKind.TOKEN_IDENT && r.tok.kind != token.TokenKind.TOKEN_SELF) {
      lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
    }
    /* Assign after name token: hoist must not use LET/CONST token's ident_len/start. */
    name_len = r.tok.ident_len;
    if (is_discard_name != 0) {
      name_len = 1;
    } else if (r.tok.kind == token.TokenKind.TOKEN_SELF) {
      name_len = 4;
    }
    if (name_len <= 0 || name_len > 63) {
      lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
    }
    /* token_start is real offset in slice; 0 is legal (do not use token_start!=0 as sentinel). */
    name_start = r.token_start;
    if (is_discard_name != 0) {
      name_row[0] = 95;
      ni = 1;
    } else {
      while (ni < name_len && ni < 64) {
        if (name_start + ni < source.length) {
          name_row[ni] = source[name_start + ni];
        }
        ni = ni + 1;
      }
    }
    /* Pad NUL after name only: zi must start at ni, not 0 (hoist would wipe name_row). */
    zi = ni;
    while (zi < 64) {
      name_row[zi] = 0;
      zi = zi + 1;
    }
    if (is_let) {
      /* See implementation. */
    }
    lex_from_result_ptr_into(&lex, &r);
    lexer.lexer_next_into(&r, lex, source);
    if (r.tok.kind != token.TokenKind.TOKEN_COLON) {
      lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
    }
    lex_from_result_ptr_into(&lex, &r);
    /* See implementation. */
    let_ty_ref = parse_type_ref_for_arena_into(arena, lex, source, &lex);
    if (let_ty_ref == 0) {
      lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
    }
    lexer.lexer_next_into(&r, lex, source);
    /* See implementation. */
    let let_omit_init: bool = false;
    if (r.tok.kind != token.TokenKind.TOKEN_ASSIGN) {
      if (!is_let) {
        lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
      }
      if (r.tok.kind != token.TokenKind.TOKEN_SEMICOLON && r.tok.kind != token.TokenKind.TOKEN_LET
          && r.tok.kind != token.TokenKind.TOKEN_CONST && r.tok.kind != token.TokenKind.TOKEN_RETURN
          && r.tok.kind != token.TokenKind.TOKEN_IF && r.tok.kind != token.TokenKind.TOKEN_WHILE
          && r.tok.kind != token.TokenKind.TOKEN_FOR && r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
        lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
      }
      let_omit_init = true;
      let_init_ref = -1;
      let_init_val = 0;
    } else {
      lex_from_result_ptr_into(&lex, &r);
      lexer.lexer_next_into(&r, lex, source);
      /* See implementation. */
      let_init_ref = 0;
      let_init_val = 0;
    }
    let cast_init_semi_done: bool = false;
    let init_handled: i32 = 0;
    if (!let_omit_init && r.tok.kind == token.TokenKind.TOKEN_LBRACKET) {
      /* See implementation. */
      let bracket_start: usize = r.token_start;
      if (bracket_start == 0) {
        bracket_start = lex.pos;
      }
      /* See implementation. */
      lex_from_result_ptr_into(&lex, &r);
      lexer.lexer_next_into(&r, lex, source);
      let arr_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (arr_ref != 0) {
        let ae0: Expr = ast.ast_arena_expr_get(arena, arr_ref);
        ae0.kind = ExprKind.EXPR_ARRAY_LIT;
        ae0.resolved_type_ref = 0;
        ae0.line = 0;
        ae0.col = 0;
        expr_set_common_zeros(&ae0);
        ast.ast_arena_expr_set(arena, arr_ref, ae0);
        while (r.tok.kind != token.TokenKind.TOKEN_RBRACKET) {
          if (r.tok.kind == token.TokenKind.TOKEN_INT) {
            let er: i32 = ast.ast_arena_expr_alloc(arena);
            if (er != 0) {
              let ee: Expr = ast.ast_arena_expr_get(arena, er);
              ee.kind = ExprKind.EXPR_LIT;
              ee.resolved_type_ref = 0;
              ee.line = 0;
              ee.col = 0;
              ee.int_val = r.tok.int_val;
              expr_set_common_zeros(&ee);
              ast.ast_arena_expr_set(arena, er, ee);
              pipeline_expr_append_array_lit_elem(arena, arr_ref, er);
            }
            lex_from_result_ptr_into(&lex, &r);
            lexer.lexer_next_into(&r, lex, source);
          } else if (r.tok.kind == token.TokenKind.TOKEN_FLOAT) {
            /* See implementation. */
            let er: i32 = parser_alloc_float_lit(arena, r.tok.float_val);
            if (er != 0) {
              pipeline_expr_append_array_lit_elem(arena, arr_ref, er);
            }
            lex_from_result_ptr_into(&lex, &r);
            lexer.lexer_next_into(&r, lex, source);
          } else if (r.tok.kind == token.TokenKind.TOKEN_COMMA) {
            lex_from_result_ptr_into(&lex, &r);
            lexer.lexer_next_into(&r, lex, source);
            /* See implementation. */
            if (r.tok.kind == token.TokenKind.TOKEN_RBRACKET) {
              break;
            }
          } else if (r.tok.kind == token.TokenKind.TOKEN_RBRACKET) {
            break;
          } else {
            break;
          }
        }
        /* See implementation. */
        if (r.tok.kind == token.TokenKind.TOKEN_RBRACKET) {
          let_init_ref = arr_ref;
          lex_from_result_ptr_into(&lex, &r);
          lexer.lexer_next_into(&r, lex, source);
        }
      }
      /*
       * See implementation.
       * See implementation.
       */
      let arr_init_plain: bool = r.tok.kind == token.TokenKind.TOKEN_SEMICOLON || r.tok.kind == token.TokenKind.TOKEN_LET
          || r.tok.kind == token.TokenKind.TOKEN_CONST || r.tok.kind == token.TokenKind.TOKEN_RETURN
          || r.tok.kind == token.TokenKind.TOKEN_IF || r.tok.kind == token.TokenKind.TOKEN_WHILE
          || r.tok.kind == token.TokenKind.TOKEN_FOR || r.tok.kind == token.TokenKind.TOKEN_RBRACE;
      if (is_let && (r.tok.kind == token.TokenKind.TOKEN_AS || !arr_init_plain)) {
        let reparsed_ref: i32 =
            parse_body_let_bracket_compound_init_ref(arena, bracket_start, lex, source, &lex, &r);
        if (reparsed_ref == 0) {
          lex_out.pos = lex.pos;
          lex_out.line = lex.line;
          lex_out.col = lex.col;
          return false;
        }
        let_init_ref = reparsed_ref;
      }
      init_handled = 1;
    }
    if (init_handled == 0) {
      if (r.tok.kind == token.TokenKind.TOKEN_IDENT) {
        /* See implementation. */
        let rhs_ilen: i32 = r.tok.ident_len;
        /* See implementation. */
        let rhs_ident_start: usize = r.token_start;
        lex_from_result_ptr_into(&lex, &r);
        let expr_lex: Lexer = Lexer { pos: rhs_ident_start, line: r.tok.line, col: r.tok.col };
        parse_expr_result_reset(&expr_tmp, expr_lex);
        parse_expr_into(arena, expr_lex, source, &expr_tmp);
        if (!expr_tmp.ok) {
          lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
        }
        let_init_ref = expr_tmp.expr_ref;
        lexer_copy_from_parse_expr_result_into(&lex, &expr_tmp);
        lexer.lexer_next_into(&r, lex, source);
        /* See implementation. */
        parser_rewind_lex_for_following_stmt_into(&lex, lex, r);
        init_handled = 1;
      }
    }
    /* LBRACE let-init handler (C3=C4 root fix, 2026-07-19).
     * Before this, bare `{ a: 0 }` struct-lit as a body-let init matched NO init handler
     * (the chain covered LBRACKET/IDENT/STRING/TRUE/FALSE/FLOAT/INT/MINUS/AMP/IF/MATCH/AWAIT
     * but NOT LBRACE), so the let was silently dropped. A following unsafe/while/for then
     * hit the abandoned `{...}` lexer state and failed the whole function (P001).
     * Root cause: parse_body_lets_into had no LBRACE branch; bare `{` never reached
     * parse_expr_into, whose primary layer already disambiguates struct-lit vs block-expr
     * (parser_asm_primary_lbrace_looks_like_block_c in parser_asm_primary_slice.inc).
     * Fix: handle LBRACE exactly like the IDENT path — parse_expr_into from the `{` start,
     * finish lexer state the same way (copy + next + rewind). PLATFORM: SHARED. */
    if (init_handled == 0) {
      if (r.tok.kind == token.TokenKind.TOKEN_LBRACE) {
        let lbrace_start: usize = r.token_start;
        if (lbrace_start == 0) {
          lbrace_start = lex.pos;
        }
        lex_from_result_ptr_into(&lex, &r);
        let lbrace_lex: Lexer = Lexer { pos: lbrace_start, line: r.tok.line, col: r.tok.col };
        parse_expr_result_reset(&expr_tmp, lbrace_lex);
        parse_expr_into(arena, lbrace_lex, source, &expr_tmp);
        if (!expr_tmp.ok) {
          lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
        }
        let_init_ref = expr_tmp.expr_ref;
        lexer_copy_from_parse_expr_result_into(&lex, &expr_tmp);
        lexer.lexer_next_into(&r, lex, source);
        parser_rewind_lex_for_following_stmt_into(&lex, lex, r);
        init_handled = 1;
      }
    }
    if (init_handled == 0) {
      if (r.tok.kind == token.TokenKind.TOKEN_STRING) {
        /**
         * See implementation.
         * See implementation.
         * See implementation.
         * See implementation.
         * See implementation.
         */
        let str_ref: i32 = ast.ast_arena_expr_alloc(arena);
        if (str_ref != 0) {
          let se: Expr = ast.ast_arena_expr_get(arena, str_ref);
          se.kind = ExprKind.EXPR_STRING_LIT;
          se.resolved_type_ref = 0;
          se.line = r.tok.line;
          se.col = r.tok.col;
          expr_set_common_zeros(&se);
          let nlen: i32 = r.tok.ident_len;
          if (nlen > 63) {
            nlen = 63;
          }
          if (nlen < 0) {
            nlen = 0;
          }
          /* Decode escapes so AST holds semantic bytes (\n→0x0A), not raw source. */
          let q0: usize = r.token_start;
          let ri: i32 = 0;
          let wi: i32 = 0;
          while (ri < nlen && wi < 63) {
            let c: u8 = 0;
            if (q0 + (ri as usize) < source.length) {
              c = source[q0 + (ri as usize)];
            }
            if (c == 92 && (ri + 1) < nlen) {
              let n: u8 = 0;
              if (q0 + ((ri + 1) as usize) < source.length) {
                n = source[q0 + ((ri + 1) as usize)];
              }
              if (n == 110) { se.var_name[wi] = 10; wi = wi + 1; ri = ri + 2; continue; }
              if (n == 116) { se.var_name[wi] = 9; wi = wi + 1; ri = ri + 2; continue; }
              if (n == 114) { se.var_name[wi] = 13; wi = wi + 1; ri = ri + 2; continue; }
              if (n == 48) { se.var_name[wi] = 0; wi = wi + 1; ri = ri + 2; continue; }
              if (n == 92 || n == 34) { se.var_name[wi] = n; wi = wi + 1; ri = ri + 2; continue; }
              se.var_name[wi] = n; wi = wi + 1; ri = ri + 2; continue;
            }
            se.var_name[wi] = c;
            wi = wi + 1;
            ri = ri + 1;
          }
          se.var_name_len = wi;
          while (wi < 64) {
            se.var_name[wi] = 0;
            wi = wi + 1;
          }
          ast.ast_arena_expr_set(arena, str_ref, se);
          let_init_ref = str_ref;
        }
        lex_from_result_ptr_into(&lex, &r);
        lexer.lexer_next_into(&r, lex, source);
        parser_rewind_lex_for_following_stmt_into(&lex, lex, r);
        if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
          let after_semi_str: LexerResult = LexerResult {
            next_lex: r.next_lex,
            tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 },
            token_start: 0
          };
          lexer.lexer_next_into(&after_semi_str, r.next_lex, source);
          lexer_copy_into(&lex, lex_at_token_from_result(after_semi_str));
          lexer.lexer_next_into(&r, lex, source);
          cast_init_semi_done = true;
        }
        init_handled = 1;
      }
    }
    if (init_handled == 0) {
      if (r.tok.kind == token.TokenKind.TOKEN_TRUE || r.tok.kind == token.TokenKind.TOKEN_FALSE) {
        /* See implementation. */
        let bool_ref: i32 = ast.ast_arena_expr_alloc(arena);
        if (bool_ref != 0) {
          let be: Expr = ast.ast_arena_expr_get(arena, bool_ref);
          be.kind = ExprKind.EXPR_BOOL_LIT;
          be.resolved_type_ref = 0;
          be.line = 0;
          be.col = 0;
          be.int_val = 0;
          if (r.tok.kind == token.TokenKind.TOKEN_TRUE) {
            be.int_val = 1;
          }
          ast.expr_init_match_enum(&be);
          be.binop_left_ref = 0;
          be.binop_right_ref = 0;
          be.unary_operand_ref = 0;
          be.if_cond_ref = 0;
          be.if_then_ref = 0;
          be.if_else_ref = 0;
          be.block_ref = 0;
          be.field_access_base_ref = 0;
          be.field_access_field_len = 0;
          be.field_access_is_enum_variant = 0;
          be.field_access_offset = 0;
          be.index_base_ref = 0;
          be.index_index_ref = 0;
          be.index_base_is_slice = 0;
          be.call_callee_ref = 0;
          be.call_num_args = 0;
          be.method_call_base_ref = 0;
          be.method_call_name_len = 0;
          be.method_call_num_args = 0;
          be.const_folded_val = 0;
          be.const_folded_valid = 0;
          be.index_proven_in_bounds = 0;
          ast.ast_arena_expr_set(arena, bool_ref, be);
          let_init_ref = bool_ref;
        }
        lex_from_result_ptr_into(&lex, &r);
        lexer.lexer_next_into(&r, lex, source);
        init_handled = 1;
      }
    }
    if (init_handled == 0) {
      if (r.tok.kind == token.TokenKind.TOKEN_FLOAT) {
        /*
         * f32/f64 init: plain float lit OR compound (`0.0 - 1.5`, `1.0 + 2.5`, `x as f64`).
         * G.7: same compound reparse as TOKEN_INT (`0 - val`); bare lit keeps alloc_float_lit.
         * Bug: taking only the first FLOAT left `let x: f64 = 0.0 - 1.5` as init=0.0 plus a
         * dangling expr_stmt `-(1.5)` (C -E and asm store-then-neg).
         * PLATFORM: SHARED — parser AST for body/mid-block lets.
         */
        let float_val_saved: f64 = r.tok.float_val;
        let float_start: usize = r.token_start;
        if (float_start == 0) {
          float_start = r.next_lex.pos - 1;
        }
        let float_lex: Lexer = Lexer { pos: float_start, line: r.tok.line, col: r.tok.col };
        lex_from_result_ptr_into(&lex, &r);
        lexer.lexer_next_into(&r, lex, source);
        let float_init_plain: bool = r.tok.kind == token.TokenKind.TOKEN_SEMICOLON || r.tok.kind == token.TokenKind.TOKEN_LET
            || r.tok.kind == token.TokenKind.TOKEN_CONST || r.tok.kind == token.TokenKind.TOKEN_RETURN
            || r.tok.kind == token.TokenKind.TOKEN_IF || r.tok.kind == token.TokenKind.TOKEN_WHILE
            || r.tok.kind == token.TokenKind.TOKEN_FOR || r.tok.kind == token.TokenKind.TOKEN_RBRACE;
        if (r.tok.kind == token.TokenKind.TOKEN_AS || !float_init_plain) {
          parse_expr_result_reset(&expr_tmp, float_lex);
          parse_expr_into(arena, float_lex, source, &expr_tmp);
          if (!expr_tmp.ok) {
            lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
          }
          let_init_ref = expr_tmp.expr_ref;
          lexer_copy_from_parse_expr_result_into(&lex, &expr_tmp);
          lexer.lexer_next_into(&r, lex, source);
        } else {
          let_init_ref = parser_alloc_float_lit(arena, float_val_saved);
        }
        init_handled = 1;
      }
    }
    if (init_handled == 0) {
      if (r.tok.kind == token.TokenKind.TOKEN_INT) {
        /*
         * See implementation.
         * See implementation.
         */
        let int_val_saved: i32 = r.tok.int_val;
        let int_start: usize = r.token_start;
        if (int_start == 0) {
          int_start = r.next_lex.pos - 1;
        }
        let int_lex: Lexer = Lexer { pos: int_start, line: lex.line, col: lex.col };
        lex_from_result_ptr_into(&lex, &r);
        lexer.lexer_next_into(&r, lex, source);
        let int_init_plain: bool = r.tok.kind == token.TokenKind.TOKEN_SEMICOLON || r.tok.kind == token.TokenKind.TOKEN_LET
            || r.tok.kind == token.TokenKind.TOKEN_CONST || r.tok.kind == token.TokenKind.TOKEN_RETURN
            || r.tok.kind == token.TokenKind.TOKEN_IF || r.tok.kind == token.TokenKind.TOKEN_WHILE
            || r.tok.kind == token.TokenKind.TOKEN_FOR || r.tok.kind == token.TokenKind.TOKEN_RBRACE;
        if (r.tok.kind == token.TokenKind.TOKEN_AS || !int_init_plain) {
          parse_expr_result_reset(&expr_tmp, int_lex);
          parse_expr_into(arena, int_lex, source, &expr_tmp);
          if (!expr_tmp.ok) {
            lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
          }
          let_init_ref = expr_tmp.expr_ref;
          lexer_copy_from_parse_expr_result_into(&lex, &expr_tmp);
          lexer.lexer_next_into(&r, lex, source);
        } else {
          let_init_val = int_val_saved;
        }
        init_handled = 1;
      }
    }
    if (init_handled == 0) {
      if (r.tok.kind == token.TokenKind.TOKEN_MINUS || r.tok.kind == token.TokenKind.TOKEN_BANG
          || r.tok.kind == token.TokenKind.TOKEN_LPAREN || r.tok.kind == token.TokenKind.TOKEN_TILDE) {
        /*
         * See implementation.
         * See implementation.
         */
        let rhs_unary_start: usize = r.token_start;
        if (rhs_unary_start == 0) {
          rhs_unary_start = lex.pos;
        }
        let unary_lex: Lexer = Lexer { pos: rhs_unary_start, line: r.tok.line, col: r.tok.col };
        lex_from_result_ptr_into(&lex, &r);
        parse_expr_result_reset(&expr_tmp, unary_lex);
        parse_expr_into(arena, unary_lex, source, &expr_tmp);
        if (!expr_tmp.ok) {
          lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
        }
        let_init_ref = expr_tmp.expr_ref;
        lexer_copy_from_parse_expr_result_into(&lex, &expr_tmp);
        lexer.lexer_next_into(&r, lex, source);
        init_handled = 1;
      }
    }
    if (init_handled == 0) {
      if (r.tok.kind == token.TokenKind.TOKEN_AMP) {
        /*
         * See implementation.
         */
        let amp_start: usize = r.token_start;
        if (amp_start == 0) {
          amp_start = lex.pos;
        }
        let amp_lex: Lexer = Lexer { pos: amp_start, line: r.tok.line, col: r.tok.col };
        lex_from_result_ptr_into(&lex, &r);
        parse_expr_result_reset(&expr_tmp, amp_lex);
        parse_expr_into(arena, amp_lex, source, &expr_tmp);
        if (!expr_tmp.ok) {
          lex_out.pos = lex.pos;
          lex_out.line = lex.line;
          lex_out.col = lex.col;
          return false;
        }
        let_init_ref = expr_tmp.expr_ref;
        lexer_copy_from_parse_expr_result_into(&lex, &expr_tmp);
        lexer.lexer_next_into(&r, lex, source);
        init_handled = 1;
      }
    }
    if (init_handled == 0) {
      if (r.tok.kind == token.TokenKind.TOKEN_IF) {
        /* See implementation. */
        let if_lex: Lexer = lex_at_token_from_result(r);
        parse_expr_result_reset(&expr_tmp, if_lex);
        parse_if_expr_into(arena, if_lex, source, let_ty_ref, &expr_tmp);
        if (!expr_tmp.ok) {
          lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
        }
        let_init_ref = expr_tmp.expr_ref;
        lexer_copy_from_parse_expr_result_into(&lex, &expr_tmp);
        lexer.lexer_next_into(&r, lex, source);
        parser_rewind_lex_for_following_stmt_into(&lex, lex, r);
        init_handled = 1;
      }
    }
    if (init_handled == 0) {
      if (r.tok.kind == token.TokenKind.TOKEN_MATCH) {
        /* See implementation. */
        let match_lex: Lexer = lex_at_token_from_result(r);
        parse_expr_result_reset(&expr_tmp, match_lex);
        parse_match_into(arena, match_lex, source, &expr_tmp);
        if (!expr_tmp.ok) {
          lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
        }
        let_init_ref = expr_tmp.expr_ref;
        lexer_copy_from_parse_expr_result_into(&lex, &expr_tmp);
        lexer.lexer_next_into(&r, lex, source);
        parser_rewind_lex_for_following_stmt_into(&lex, lex, r);
        init_handled = 1;
      }
    }
    if (init_handled == 0) {
      if (r.tok.kind == token.TokenKind.TOKEN_AWAIT || r.tok.kind == token.TokenKind.TOKEN_RUN
          || r.tok.kind == token.TokenKind.TOKEN_SPAWN) {
        /**
         * See implementation.
         * See implementation.
         */
        let async_start: usize = r.token_start;
        if (async_start == 0) {
          async_start = lex.pos;
        }
        let async_lex: Lexer = Lexer { pos: async_start, line: r.tok.line, col: r.tok.col };
        lex_from_result_ptr_into(&lex, &r);
        parse_expr_result_reset(&expr_tmp, async_lex);
        parse_expr_into(arena, async_lex, source, &expr_tmp);
        if (!expr_tmp.ok) {
          lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
        }
        let_init_ref = expr_tmp.expr_ref;
        lexer_copy_from_parse_expr_result_into(&lex, &expr_tmp);
        lexer.lexer_next_into(&r, lex, source);
        init_handled = 1;
      }
    }
    /* See implementation. */
    if (!cast_init_semi_done) {
      if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
        /*
         * After `;`, peek next stmt: lex must land on that token's first byte for
         * parse_block_into / parse_one_function_impl (expr;/let/return…).
         * let-hoist safe (product pin X→C): do NOT `let lex_after_semi = lex_at_token_from_result(after_semi)`
         * after next — pin hoists that let to the if-block top and computes from empty after_semi
         * (wipes correct pos → following return skipped → whole function P001 on body let).
         * Inline lex_at_token_from_result like the STRING init semi path.
         * PLATFORM: SHARED — force M2 body-let residual.
         */
        lex_from_result_ptr_into(&lex, &r);
        let after_semi: LexerResult = LexerResult { next_lex: lex, tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 }, token_start: 0 };
        lexer.lexer_next_into(&after_semi, lex, source);
        lexer_copy_into(&lex, lex_at_token_from_result(after_semi));
        lexer.lexer_next_into(&r, lex, source);
      } else if (r.tok.kind != token.TokenKind.TOKEN_LET && r.tok.kind != token.TokenKind.TOKEN_CONST
          && r.tok.kind != token.TokenKind.TOKEN_RETURN && r.tok.kind != token.TokenKind.TOKEN_IF
          && r.tok.kind != token.TokenKind.TOKEN_WHILE && r.tok.kind != token.TokenKind.TOKEN_FOR
          && r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
        /*
         * Init already an expression (e.g. `token.Token { … }`) and next is another stmt/expr
         * (common: IDENT struct lit). Do not return here — append first, else `t` missing in ctx.
         * Inline lex_at_token_from_result (hoist-safe; no intermediate let).
         */
        if (is_let) {
          if (!(let_init_ref != 0 || let_init_val != 0 || let_init_ref == -1)) {
            lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
          }
        } else if (let_init_ref == 0 && let_init_val == 0) {
          lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
        }
        lexer_copy_into(&lex, lex_at_token_from_result(r));
      }
    }
    if (is_let) {
      if (pipeline_onefunc_append_let(pool, &name_row[0], name_len, let_init_val, let_init_ref, let_ty_ref) < 0) {
        lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
      }
      out.num_lets = pipeline_onefunc_num_lets(pool);
    } else {
      /* See implementation. */
      if (pipeline_onefunc_append_const(pool, &name_row[0], name_len, let_init_val, let_init_ref, let_ty_ref) < 0) {
        lex_out.pos = lex.pos; lex_out.line = lex.line; lex_out.col = lex.col; return false;
      }
      out.num_consts = pipeline_onefunc_num_consts(pool);
    }
  }
  /*
   * Success path MUST sit inside unsafe after the while: the loop breaks on
   * non-let/const, so a following `return false` is reachable (product pin X→C
   * does not delete it). That made every body-let parse return false → force
   * P001; buf_into glue could still recover bare `return N` but not `return x`.
   * PLATFORM: SHARED — force M2 residual body let / return-var.
   */
  lex_out.pos = lex.pos;
  lex_out.line = lex.line;
  lex_out.col = lex.col;
  return true;
  }
  return false;
}

/* See implementation. */
/* See implementation. */
export extern function parser_body_skip_let_const_then_if_glue(lex: Lexer, source: u8[]): LexerResult;
/** Exported function `body_skip_let_const_then_if`.
 * Implements `body_skip_let_const_then_if`.
 * @param lex Lexer
 * @param source u8[]
 * @return LexerResult
 */
export function body_skip_let_const_then_if(lex: Lexer, source: u8[]): LexerResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_body_skip_let_const_then_if_glue(lex, source);
  }
}


/** Exported function `body_skip_let_const_then_if_buf`.
 * Implements `body_skip_let_const_then_if_buf`.
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return LexerResult
 */
export function body_skip_let_const_then_if_buf(lex: Lexer, data: *u8, len: i32): LexerResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return body_skip_let_const_then_if(lex, slice);
  }
}


/** Exported function `body_skip_let_const_then_if_into_buf`.
 * Implements `body_skip_let_const_then_if_into_buf`.
 * @param out *LexerResult
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
export function body_skip_let_const_then_if_into_buf(out: *LexerResult, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  body_skip_let_const_then_if_into(out, lex, slice);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_skip_balanced_parens_glue(lex: Lexer, source: u8[]): Lexer;
/** Exported function `skip_balanced_parens`.
 * Implements `skip_balanced_parens`.
 * @param lex Lexer
 * @param source u8[]
 * @return Lexer
 */
export function skip_balanced_parens(lex: Lexer, source: u8[]): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_skip_balanced_parens_glue(lex, source);
  }
}


/* See implementation. */
/* See implementation. */
export extern function parser_skip_balanced_parens_into_glue(out: *Lexer, lex: Lexer, source: u8[]): void;
/** Exported function `skip_balanced_parens_into`.
 * Implements `skip_balanced_parens_into`.
 * @param out *Lexer
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
export function skip_balanced_parens_into(out: *Lexer, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_skip_balanced_parens_into_glue(out, lex, source);
  }
}


/* See implementation. */
/** Exported function `skip_balanced_parens_into_buf`.
 * Implements `skip_balanced_parens_into_buf`.
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
export function skip_balanced_parens_into_buf(out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let depth: i32 = 1;
  while (depth > 0) {
    let r: LexerResult = lexer.lexer_next_buf(lex, data, len);
    if (r.tok.kind == token.TokenKind.TOKEN_LPAREN) { depth = depth + 1; }
    else if (r.tok.kind == token.TokenKind.TOKEN_RPAREN) {
      depth = depth - 1;
      if (depth == 0) { out.pos = r.next_lex.pos; out.line = r.next_lex.line; out.col = r.next_lex.col; return; }
    }
    if (r.tok.kind == token.TokenKind.TOKEN_EOF) { out.pos = lex.pos; out.line = lex.line; out.col = lex.col; return; }
    lex_from_next_into(&lex, r);
  }
  out.pos = lex.pos; out.line = lex.line; out.col = lex.col;
  }
}



/** skip_balanced_parens_buf：parser_slice_from_buf + bl skip_balanced_parens。 */
export function skip_balanced_parens_buf(lex: Lexer, data: *u8, len: i32): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return skip_balanced_parens(lex, slice);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_skip_balanced_braces_glue(lex: Lexer, source: u8[]): Lexer;
/** Exported function `skip_balanced_braces`.
 * Implements `skip_balanced_braces`.
 * @param lex Lexer
 * @param source u8[]
 * @return Lexer
 */
export function skip_balanced_braces(lex: Lexer, source: u8[]): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_skip_balanced_braces_glue(lex, source);
  }
}


/* See implementation. */
/* See implementation. */
export extern function parser_skip_balanced_braces_into_glue(out: *Lexer, lex: Lexer, source: u8[]): void;
/** Exported function `skip_balanced_braces_into`.
 * Implements `skip_balanced_braces_into`.
 * @param out *Lexer
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
export function skip_balanced_braces_into(out: *Lexer, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_skip_balanced_braces_into_glue(out, lex, source);
  }
}


/** Exported function `skip_balanced_braces_into_buf`.
 * Implements `skip_balanced_braces_into_buf`.
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
export function skip_balanced_braces_into_buf(out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let depth: i32 = 1;
  while (depth > 0) {
    let r: LexerResult = lexer.lexer_next_buf(lex, data, len);
    if (r.tok.kind == token.TokenKind.TOKEN_LBRACE) { depth = depth + 1; }
    else if (r.tok.kind == token.TokenKind.TOKEN_RBRACE) {
      depth = depth - 1;
      if (depth == 0) { out.pos = r.next_lex.pos; out.line = r.next_lex.line; out.col = r.next_lex.col; return; }
    }
    if (r.tok.kind == token.TokenKind.TOKEN_EOF) { out.pos = lex.pos; out.line = lex.line; out.col = lex.col; return; }
    lex_from_next_into(&lex, r);
  }
  out.pos = lex.pos; out.line = lex.line; out.col = lex.col;
  }
}



/* See implementation. */
/** skip_balanced_braces_buf：parser_slice_from_buf + bl skip_balanced_braces。 */
export function skip_balanced_braces_buf(lex: Lexer, data: *u8, len: i32): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return skip_balanced_braces(lex, slice);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
/* See implementation. */
export extern function parser_skip_one_function_full_into_glue(out: *Lexer, lex: Lexer, source: u8[]): void;
/** Exported function `skip_one_function_full_into`.
 * Implements `skip_one_function_full_into`.
 * @param out *Lexer
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
export function skip_one_function_full_into(out: *Lexer, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_skip_one_function_full_into_glue(out, lex, source);
  }
}

/* See implementation. */
export extern function parser_skip_one_top_level_const_into_glue(out: *Lexer, lex: Lexer, source: u8[]): void;
/** Exported function `skip_one_top_level_const_into`.
 * Implements `skip_one_top_level_const_into`.
 * @param out *Lexer
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
export function skip_one_top_level_const_into(out: *Lexer, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_skip_one_top_level_const_into_glue(out, lex, source);
  }
}

/* See implementation. */
export extern function parser_skip_one_top_level_const_into_buf_glue(out: *Lexer, lex: Lexer, data: *u8, len: i32): void;
/** Exported function `skip_one_top_level_const_into_buf`.
 * Implements `skip_one_top_level_const_into_buf`.
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
export function skip_one_top_level_const_into_buf(out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_skip_one_top_level_const_into_buf_glue(out, lex, data, len);
  }
}

/** See implementation for details. */
export extern function parser_skip_one_top_level_let_into_glue(out: *Lexer, lex: Lexer, source: u8[]): void;
/** Exported function `skip_one_top_level_let_into`.
 * Implements `skip_one_top_level_let_into`.
 * @param out *Lexer
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
export function skip_one_top_level_let_into(out: *Lexer, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_skip_one_top_level_let_into_glue(out, lex, source);
  }
}

/* See implementation. */
export extern function parser_skip_one_top_level_let_into_buf_glue(out: *Lexer, lex: Lexer, data: *u8, len: i32): void;
/** Exported function `skip_one_top_level_let_into_buf`.
 * Implements `skip_one_top_level_let_into_buf`.
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
export function skip_one_top_level_let_into_buf(out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_skip_one_top_level_let_into_buf_glue(out, lex, data, len);
  }
}

/* See implementation. */
export extern function parser_skip_one_function_full_glue(lex: Lexer, source: u8[]): Lexer;
/** Exported function `skip_one_function_full`.
 * Implements `skip_one_function_full`.
 * @param lex Lexer
 * @param source u8[]
 * @return Lexer
 */
export function skip_one_function_full(lex: Lexer, source: u8[]): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_skip_one_function_full_glue(lex, source);
  }
}


/** Exported function `skip_one_function_full_into_buf`.
 * Implements `skip_one_function_full_into_buf`.
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
export function skip_one_function_full_into_buf(out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  skip_one_function_full_into(out, lex, slice);
  }
}


/* See implementation. */
/** skip_one_function_full_buf：parser_slice_from_buf + bl skip_one_function_full。 */
export function skip_one_function_full_buf(lex: Lexer, data: *u8, len: i32): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return skip_one_function_full(lex, slice);
  }
}


/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_skip_one_if_core_glue(lex: Lexer, source: u8[]): LexerResult;
/** Exported function `skip_one_if_core`.
 * Implements `skip_one_if_core`.
 * @param lex Lexer
 * @param source u8[]
 * @return LexerResult
 */
export function skip_one_if_core(lex: Lexer, source: u8[]): LexerResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_skip_one_if_core_glue(lex, source);
  }
}


/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_skip_one_if_statement_glue(lex: Lexer, source: u8[]): LexerResult;
/** Exported function `skip_one_if_statement`.
 * Implements `skip_one_if_statement`.
 * @param lex Lexer
 * @param source u8[]
 * @return LexerResult
 */
export function skip_one_if_statement(lex: Lexer, source: u8[]): LexerResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_skip_one_if_statement_glue(lex, source);
  }
}


/* See implementation. */
/* See implementation. */
export extern function parser_skip_one_if_statement_into_glue(out: *LexerResult, lex: Lexer, source: u8[]): void;
/** Exported function `skip_one_if_statement_into`.
 * Implements `skip_one_if_statement_into`.
 * @param out *LexerResult
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
export function skip_one_if_statement_into(out: *LexerResult, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_skip_one_if_statement_into_glue(out, lex, source);
  }
}


/* See implementation. */
/* See implementation. */
export extern function parser_skip_one_if_core_into_glue(out: *LexerResult, lex: Lexer, source: u8[]): void;
/** Exported function `skip_one_if_core_into`.
 * Implements `skip_one_if_core_into`.
 * @param out *LexerResult
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
export function skip_one_if_core_into(out: *LexerResult, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_skip_one_if_core_into_glue(out, lex, source);
  }
}


/* See implementation. */
/** skip_one_if_core_buf：parser_slice_from_buf + bl skip_one_if_core。 */
export function skip_one_if_core_buf(lex: Lexer, data: *u8, len: i32): LexerResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return skip_one_if_core(lex, slice);
  }
}


/** skip_one_if_statement_buf：parser_slice_from_buf + bl skip_one_if_statement。 */
export function skip_one_if_statement_buf(lex: Lexer, data: *u8, len: i32): LexerResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return skip_one_if_statement(lex, slice);
  }
}


/** Exported function `skip_one_if_core_into_buf`.
 * Implements `skip_one_if_core_into_buf`.
 * @param out *LexerResult
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
export function skip_one_if_core_into_buf(out: *LexerResult, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  skip_one_if_core_into(out, lex, slice);
  }
}


/** Exported function `skip_one_if_statement_into_buf`.
 * Implements `skip_one_if_statement_into_buf`.
 * @param out *LexerResult
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
export function skip_one_if_statement_into_buf(out: *LexerResult, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  skip_one_if_statement_into(out, lex, slice);
  }
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
/* See implementation. */
export extern function parser_diag_lex_after_imports_glue(source: u8[]): Lexer;
/** Exported function `diag_lex_after_imports`.
 * Implements `diag_lex_after_imports`.
 * @param source u8[]
 * @return Lexer
 */
export function diag_lex_after_imports(source: u8[]): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_diag_lex_after_imports_glue(source);
  }
}


/** Exported function `diag_lex_after_imports_buf`.
 * Implements `diag_lex_after_imports_buf`.
 * @param data *u8
 * @param len i32
 * @return Lexer
 */
export function diag_lex_after_imports_buf(data: *u8, len: i32): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return diag_lex_after_imports(slice);
  }
}


/* See implementation. */
/* See implementation. */
export extern function parser_diag_after_imports_then_structs_glue(lex: Lexer, source: u8[]): LexerResult;
/** Exported function `diag_after_imports_then_structs`.
 * Implements `diag_after_imports_then_structs`.
 * @param lex Lexer
 * @param source u8[]
 * @return LexerResult
 */
export function diag_after_imports_then_structs(lex: Lexer, source: u8[]): LexerResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_diag_after_imports_then_structs_glue(lex, source);
  }
}


/** Exported function `diag_after_imports_then_structs_buf`.
 * Implements `diag_after_imports_then_structs_buf`.
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return LexerResult
 */
export function diag_after_imports_then_structs_buf(lex: Lexer, data: *u8, len: i32): LexerResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return diag_after_imports_then_structs(lex, slice);
  }
}


/* See implementation. */
export extern function parser_diag_fail_at_token_kind_glue(source: u8[]): i32;
/** Exported function `diag_fail_at_token_kind`.
 * Implements `diag_fail_at_token_kind`.
 * @param source u8[]
 * @return i32
 */
export function diag_fail_at_token_kind(source: u8[]): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_diag_fail_at_token_kind_glue(source);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/** Exported function `diag_fail_at_token_kind_buf`.
 * Implements `diag_fail_at_token_kind_buf`.
 * @param data *u8
 * @param len i32
 * @return i32
 */
export function diag_fail_at_token_kind_buf(data: *u8, len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return diag_fail_at_token_kind(slice);
  }
  return 0;  // unreachable — typeck after unsafe block
}

/** Exported function `parse_into_result_empty_module_or_fail_tok`.
 * Implements `parse_into_result_empty_module_or_fail_tok`.
 * @param fail_tok i32
 * @return ParseIntoResult
 */
export function parse_into_result_empty_module_or_fail_tok(fail_tok: i32): ParseIntoResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  if (fail_tok == (token.TokenKind.TOKEN_STRING as i32)) {
    return ParseIntoResult { ok: -2, main_idx: -1 }
  }
  return ParseIntoResult { ok: 0, main_idx: -1 }
  }
}


/**
 * See implementation.
 * See implementation.
 */
export function copy_slice_to_name64(source: u8[], start: usize, nlen: i32, out: *u8): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let i: i32 = 0;
  while (i < nlen) {
    if (start + (i as usize) < source.length) {
      out[i] = source[start + (i as usize)];
    }
    i = i + 1;
  }
  }
}


/** Exported function `copy_slice_to_name64_at_end`.
 * Implements `copy_slice_to_name64_at_end`.
 * @param source u8[]
 * @param end_pos usize
 * @param nlen i32
 * @param out *u8
 * @return void
 */
export function copy_slice_to_name64_at_end(source: u8[], end_pos: usize, nlen: i32, out: *u8): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let start: usize = end_pos - (nlen as usize);
  copy_slice_to_name64(source, start, nlen, out);
  }
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_struct_field_name_from_tok_glue(r: LexerResult, source: u8[], out: *u8): i32;
/** Exported function `struct_field_name_from_tok`.
 * Implements `struct_field_name_from_tok`.
 * @param r LexerResult
 * @param source u8[]
 * @param out *u8
 * @return i32
 */
export function struct_field_name_from_tok(r: LexerResult, source: u8[], out: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_struct_field_name_from_tok_glue(r, source, out);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/** Exported function `struct_field_name_from_tok_buf`.
 * Implements `struct_field_name_from_tok_buf`.
 * @param r LexerResult
 * @param data *u8
 * @param len i32
 * @param out *u8
 * @return i32
 */
export function struct_field_name_from_tok_buf(r: LexerResult, data: *u8, len: i32, out: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return struct_field_name_from_tok(r, slice, out);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/** Exported function `struct_field_name_tok_kind`.
 * Implements `struct_field_name_tok_kind`.
 * @param k token.TokenKind
 * @return bool
 */
export function struct_field_name_tok_kind(k: token.TokenKind): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  if (k == token.TokenKind.TOKEN_IDENT) {
    return true;
  }
  let ko: i32 = k as i32;
  if (ko == 18) {
    return true;
  }
  if (ko == 17) {
    return true;
  }
  return false;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function struct_field_continues_tok_kind(k: token.TokenKind): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  if (struct_field_name_tok_kind(k)) {
    return true;
  }
  let ko: i32 = k as i32;
  if (ko == 20) {
    return true;
  }
  return false;
  }
}


/**
 * See implementation.
 * See implementation.
 */
export function parser_token_is_label_start(r: LexerResult, source: u8[]): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  if (r.tok.kind != token.TokenKind.TOKEN_IDENT) {
    return false;
  }
  let nx: LexerResult = LexerResult {
    next_lex: r.next_lex,
    tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 },
    token_start: 0
  };
  lexer.lexer_next_into(&nx, r.next_lex, source);
  return nx.tok.kind == token.TokenKind.TOKEN_COLON;
  }
}

/** Exported function `copy_slice_to_param32`.
 * Implements `copy_slice_to_param32`.
 * @param source u8[]
 * @param start usize
 * @param nlen i32
 * @param out *u8
 * @return void
 */
export function copy_slice_to_param32(source: u8[], start: usize, nlen: i32, out: *u8): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let i: i32 = 0;
  while (i < 32) {
    if (i < nlen && start + (i as usize) < source.length) {
      out[i] = source[start + (i as usize)];
    } else {
      out[i] = 0;
    }
    i = i + 1;
  }
  }
}


/** Exported function `copy_slice_to_param32_at_end`.
 * Implements `copy_slice_to_param32_at_end`.
 * @param source u8[]
 * @param end_pos usize
 * @param nlen i32
 * @param out *u8
 * @return void
 */
export function copy_slice_to_param32_at_end(source: u8[], end_pos: usize, nlen: i32, out: *u8): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let start: usize = end_pos - (nlen as usize);
  copy_slice_to_param32(source, start, nlen, out);
  }
}


/** Exported function `copy_slice_to_name64_buf`.
 * Implements `copy_slice_to_name64_buf`.
 * @param source *u8
 * @param source_len i32
 * @param start usize
 * @param nlen i32
 * @param out *u8
 * @return void
 */
export function copy_slice_to_name64_buf(source: *u8, source_len: i32, start: usize, nlen: i32, out: *u8): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let i: i32 = 0;
  while (i < nlen) {
    if (start + (i as usize) < (source_len as usize)) {
      out[i] = source[start + (i as usize)];
    }
    i = i + 1;
  }
  }
}


/** Exported function `copy_slice_to_name64_at_end_buf`.
 * Implements `copy_slice_to_name64_at_end_buf`.
 * @param source *u8
 * @param source_len i32
 * @param end_pos usize
 * @param nlen i32
 * @param out *u8
 * @return void
 */
export function copy_slice_to_name64_at_end_buf(source: *u8, source_len: i32, end_pos: usize, nlen: i32, out: *u8): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let start: usize = end_pos - (nlen as usize);
  copy_slice_to_name64_buf(source, source_len, start, nlen, out);
  }
}


/** Exported function `copy_slice_to_param32_at_end_buf`.
 * Implements `copy_slice_to_param32_at_end_buf`.
 * @param source *u8
 * @param source_len i32
 * @param end_pos usize
 * @param nlen i32
 * @param out *u8
 * @return void
 */
export function copy_slice_to_param32_at_end_buf(source: *u8, source_len: i32, end_pos: usize, nlen: i32, out: *u8): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let start: usize = end_pos - (nlen as usize);
  let i: i32 = 0;
  while (i < 32) {
    if (i < nlen && start + (i as usize) < (source_len as usize)) {
      out[i] = source[start + (i as usize)];
    } else {
      out[i] = 0;
    }
    i = i + 1;
  }
  }
}


/** Exported function `copy_slice_to_param32_buf`.
 * Implements `copy_slice_to_param32_buf`.
 * @param source *u8
 * @param source_len i32
 * @param start usize
 * @param nlen i32
 * @param out *u8
 * @return void
 */
export function copy_slice_to_param32_buf(source: *u8, source_len: i32, start: usize, nlen: i32, out: *u8): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let i: i32 = 0;
  while (i < 32) {
    if (i < nlen && start + (i as usize) < (source_len as usize)) {
      out[i] = source[start + (i as usize)];
    } else {
      out[i] = 0;
    }
    i = i + 1;
  }
  }
}


/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function parse_one_function_impl(out: *OneFuncResult, arena: *ASTArena, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  /* See implementation. */
  ast_pool_onefunc_reset(onefunc_result_pool_ptr(out));
  /* See implementation. */
  let out_clean: OneFuncResult = onefunc_alloc_wired_for_parse(lex);
  copy_onefunc_into(out, &out_clean);
  let out_ref: *OneFuncResult = out;
  let dummy_name: u8[64] = [];
  /* See implementation. */
  let impl_snap: OneFuncResult = onefunc_scratch_empty();
  ast_pool_onefunc_reset(onefunc_result_pool_ptr(&impl_snap));
  onefunc_res_wire_dummy_head(&impl_snap, lex, dummy_name);
  onefunc_res_wire_dummy_const_let(&impl_snap);
  onefunc_res_wire_dummy_if_mul(&impl_snap);
  onefunc_res_wire_dummy_call_binop(&impl_snap, dummy_name);
  onefunc_res_wire_dummy_loop_call(&impl_snap);
  onefunc_res_wire_dummy_for_if(&impl_snap);
  /* See implementation. */
  let return_type_is_bool: bool = false;
  /* See implementation. */
  let return_expr_ref_storage: i32 = 0;
  /* See implementation. */
  let name_start: usize = (0 as usize);
  let func_name_len_storage: i32[1] = [];
  /**
   * Hoist-safe zeros for return/param type parse (pin X→C has no stmt_order).
   * PLATFORM: SHARED — product pin hoists `let x = parse_type_ref...` to function top and
   * mutates `lex` before the function name is read (force FAIL at `(`; only glue fallback
   * saves bare `return N`). Assign only after `):` / param `:` so force parse_one_function_impl
   * can own binop/unary/paren returns without relying on buf_into glue.
   */
  let lex_before_ret: Lexer = Lexer { pos: 0 as usize, line: 0, col: 0 };
  let ret_type_ref: i32 = 0;
  let lex_before_type: Lexer = Lexer { pos: 0 as usize, line: 0, col: 0 };
  let type_ref_param: i32 = 0;
  /**
   * Hoist-safe param-name capture (pin X→C has no stmt_order).
   * PLATFORM: SHARED — Cap force used to lift `let plen / pname_row / param_idx = append_param(...)`
   * before IDENT check and before `copy_slice_to_param32`, so the sidecar got empty names
   * (`int32_t )` / undeclared `x`/`opt` on option host-cc). Zero at function top; assign only
   * after IDENT+copy; never bind append as a loop-local `let` initializer.
   */
  let plen_param: i32 = 0;
  let param_idx: i32 = 0;
  let param_pool: *u8 = 0 as *u8;
  let pname_row: u8[32] = [];
  let zi_param: i32 = 0;
  /* See implementation. */
  let r: LexerResult = LexerResult { next_lex: lex, tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 }, token_start: 0 };
  lexer.lexer_next_into(&r, lex, source);
  /* See implementation. */
  if (r.tok.kind == token.TokenKind.TOKEN_IDENT) {
    /* See implementation. */
  } else if (r.tok.kind == token.TokenKind.TOKEN_SPAWN) {
    /* See implementation. */
    func_name_len_storage[0] = 5;
    dummy_name[0] = 115;
    dummy_name[1] = 112;
    dummy_name[2] = 97;
    dummy_name[3] = 119;
    dummy_name[4] = 110;
    lex_from_next_into(&lex, r);
    /* See implementation. */
  } else {
    if (r.tok.kind != token.TokenKind.TOKEN_FUNCTION) {
      set_onefunc_fail(out, lex); return;
    }
    lex_from_next_into(&lex, r);
    lexer.lexer_next_into(&r, lex, source);
    if (r.tok.kind == token.TokenKind.TOKEN_SPAWN) {
      func_name_len_storage[0] = 5;
      dummy_name[0] = 115;
      dummy_name[1] = 112;
      dummy_name[2] = 97;
      dummy_name[3] = 119;
      dummy_name[4] = 110;
      lex_from_next_into(&lex, r);
    } else if (r.tok.kind != token.TokenKind.TOKEN_IDENT) {
      set_onefunc_fail(out, lex); return;
    } else {
      func_name_len_storage[0] = r.tok.ident_len;
      if (func_name_len_storage[0] <= 0 || func_name_len_storage[0] > 63) {
        set_onefunc_fail(out, lex); return;
      }
      name_start = r.next_lex.pos - func_name_len_storage[0];
      copy_slice_to_name64(source, name_start, func_name_len_storage[0], &dummy_name[0]);
      lex_from_next_into(&lex, r);
    }
  }
  if (func_name_len_storage[0] == 0) {
    if (r.tok.kind != token.TokenKind.TOKEN_IDENT) {
      set_onefunc_fail(out, lex); return;
    }
    func_name_len_storage[0] = r.tok.ident_len;
    if (func_name_len_storage[0] <= 0 || func_name_len_storage[0] > 63) {
      set_onefunc_fail(out, lex); return;
    }
    name_start = r.next_lex.pos - func_name_len_storage[0];
    copy_slice_to_name64(source, name_start, func_name_len_storage[0], &dummy_name[0]);
    lex_from_next_into(&lex, r);
  }
  lexer.lexer_next_into(&r, lex, source);
  /* See implementation. */
  if (r.tok.kind == token.TokenKind.TOKEN_LT) {
    let generic_n: i32 = 0;
    parser_skip_generic_angle_list_count_into_glue(&lex, &generic_n, lex, source);
    out.num_generic_params = generic_n;
    lexer.lexer_next_into(&r, lex, source);
  }
  if (r.tok.kind != token.TokenKind.TOKEN_LPAREN) {
    set_onefunc_fail(out, lex); return;
  }
  lex_from_next_into(&lex, r);
  lexer.lexer_next_into(&r, lex, source);
  if (r.tok.kind == token.TokenKind.TOKEN_RPAREN) {
    lex_from_next_into(&lex, r);
  } else {
    /* Param list: IDENT or TOKEN_SELF (method/receiver keyword used as binding name).
     * Root fix: lexer keywords `self` as TOKEN_SELF (ident_len=0); requiring IDENT only
     * silently set_onefunc_fail → whole function dropped from AST (wave43).
     * PLATFORM: SHARED — bind name "self" via token_start copy (len 4). */
    while (1 == 1) {
      if (r.tok.kind != token.TokenKind.TOKEN_IDENT && r.tok.kind != token.TokenKind.TOKEN_SELF) {
        set_onefunc_fail(out_ref, lex); return;
      }
      // TOKEN_SELF has ident_len=0 in lexer; spelling is always 4 bytes "self".
      if (r.tok.kind == token.TokenKind.TOKEN_SELF) {
        plen_param = 4;
      } else {
        plen_param = r.tok.ident_len;
      }
      if (plen_param <= 0 || plen_param > 31) {
        set_onefunc_fail(out_ref, lex); return;
      }
      /* Clear row then copy binding-name bytes from token_start before append into sidecar pool. */
      zi_param = 0;
      while (zi_param < 32) {
        pname_row[zi_param] = 0;
        zi_param = zi_param + 1;
      }
      copy_slice_to_param32(source, r.token_start, plen_param, &pname_row[0]);
      /* Names/types go to out sidecar (not impl_snap — merge_pool resets snap). */
      param_pool = onefunc_result_pool_ptr(out);
      param_idx = pipeline_onefunc_append_param(param_pool, &pname_row[0], plen_param, 0);
      if (param_idx < 0) {
        set_onefunc_fail(out_ref, lex); return;
      }
      out.num_params = param_idx + 1;
      lex_from_next_into(&lex, r);
      lexer.lexer_next_into(&r, lex, source);
      if (r.tok.kind != token.TokenKind.TOKEN_COLON) {
        set_onefunc_fail(out_ref, lex); return;
      }
      lex_from_next_into(&lex, r);
      /* Param type: assign after `:`; zeros declared at function top (hoist-safe). */
      lex_before_type = lex;
      type_ref_param = parse_type_ref_for_arena_into(arena, lex_before_type, source, &lex);
      if (type_ref_param == 0) {
        set_onefunc_fail(out_ref, lex); return;
      }
      pipeline_onefunc_set_param_type_ref(param_pool, param_idx, type_ref_param);
      driver_diagnostic_parser_onefunc_param_ref(&dummy_name[0], func_name_len_storage[0], &pname_row[0], plen_param,
      0, param_idx, type_ref_param);
      lexer.lexer_next_into(&r, lex, source);
      /* See implementation. */
      if (r.tok.kind == token.TokenKind.TOKEN_RPAREN) {
        lex_from_next_into(&lex, r);
        break;
      }
      if (r.tok.kind != token.TokenKind.TOKEN_COMMA) {
        set_onefunc_fail(out_ref, lex); return;
      }
      lex_from_next_into(&lex, r);
      lexer.lexer_next_into(&r, lex, source);
      /* See implementation. */
      if (r.tok.kind == token.TokenKind.TOKEN_RPAREN) {
        lex_from_next_into(&lex, r);
        break;
      }
    }
  }
  lexer.lexer_next_into(&r, lex, source);
  if (r.tok.kind != token.TokenKind.TOKEN_COLON) {
    set_onefunc_fail(out_ref, lex); return;
  }
  lex_from_next_into(&lex, r);
  /* Return type after `):`; zeros at function top so pin cannot pre-parse from entry lex. */
  lex_before_ret = lex;
  ret_type_ref = parse_type_ref_for_arena_into(arena, lex_before_ret, source, &lex);
  if (ret_type_ref == 0) {
    set_onefunc_fail(out, lex); return;
  }
  /* See implementation. */
  out.func_return_type_ref = ret_type_ref;
  if (ret_type_ref != 0) {
    let rt: Type = ast.ast_arena_type_get(arena, ret_type_ref);
    if (rt.kind == TypeKind.TYPE_BOOL) {
      return_type_is_bool = true;
    }
  }
  lexer.lexer_next_into(&r, lex, source);
  if (r.tok.kind != token.TokenKind.TOKEN_LBRACE) {
    set_onefunc_fail(out, lex); return;
  }
  /* See implementation. */
  if (r.tok.kind == token.TokenKind.TOKEN_LBRACE) {
    lex_from_next_into(&lex, r);
    /* See implementation. */
    out.num_src_stmt_order = 0;
    out.num_src_body_expr_stmts = 0;
    if (!parse_body_lets_into(arena, lex, source, out, &lex)) {
      set_onefunc_fail(out, lex);
      return;
    }
    out.num_lets = pipeline_onefunc_num_lets(onefunc_result_pool_ptr(out));
    out.num_consts = pipeline_onefunc_num_consts(onefunc_result_pool_ptr(out));
    /* See implementation. */
    let csr0: i32 = 0;
    while (csr0 < out.num_consts) {
      onefunc_push_src_stmt(out, 0, csr0);
      csr0 = csr0 + 1;
    }
    let lsr: i32 = 0;
    while (lsr < out.num_lets) {
      onefunc_push_src_stmt(out, 1, lsr);
      lsr = lsr + 1;
    }
    /*
     * See implementation.
     * See implementation.
     */
    let r_peek: LexerResult = LexerResult { next_lex: lex, tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 }, token_start: 0 };
    lexer.lexer_next_into(&r_peek, lex, source);
    r = r_peek;
    lex = parser_rewind_lex_for_following_stmt(lex, r_peek);
    let stmt_tok_ready: bool = true;
    /**
     * Hoist-safe onefunc expr_stmt path (pin X→C has no stmt_order).
     * PLATFORM: SHARED — Cap force lifts
     *   `let stmt_start / expr_stmt_res / ex_i = push_body_expr_stmt(expr_ref=0)`
     * to the top of every while iteration, so each stmt appends an empty body expr_stmt
     * before parse; assign-after-if then fails (force hello residual: missing
     * fmt_bool_to_buf / fmt_f64_to_buf_prec). Zero here; assign + push only after
     * parse_expr_into succeeds on the real expr_stmt path.
     */
    let stmt_start: Lexer = Lexer { pos: 0 as usize, line: 0, col: 0 };
    let expr_stmt_res: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: stmt_start };
    let ex_i: i32 = 0;
    /* See implementation. */
    while (1 == 1) {
      if (!stmt_tok_ready) {
        lexer.lexer_next_into(&r, lex, source);
      }
      stmt_tok_ready = false;
      /*
       * See implementation.
       * See implementation.
       */
      if (r.tok.kind == token.TokenKind.TOKEN_IDENT) {
        let ret_id_start: usize = r.token_start;
        if (ret_id_start == 0) {
          ret_id_start = lexer_pos_before_run(r.next_lex.pos, r.tok.ident_len);
        }
        if (parser_return_kw_immediately_before(source, ret_id_start)) {
          let ret_kw_lex: Lexer = Lexer { pos: ret_id_start - 7, line: r.tok.line, col: r.tok.col };
          let r_ret_kw: LexerResult = LexerResult {
            next_lex: ret_kw_lex,
            tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 },
            token_start: 0
          };
          lexer.lexer_next_into(&r_ret_kw, ret_kw_lex, source);
          r = r_ret_kw;
          lex = ret_kw_lex;
        }
      }
      /* See implementation. */
      if (r.tok.kind == token.TokenKind.TOKEN_RETURN || r.tok.kind == token.TokenKind.TOKEN_RBRACE
          || r.tok.kind == token.TokenKind.TOKEN_MATCH || r.tok.kind == token.TokenKind.TOKEN_EOF) {
        break;
      }
      /* See implementation. */
      if (r.tok.kind == token.TokenKind.TOKEN_LET || r.tok.kind == token.TokenKind.TOKEN_CONST) {
        let n_before_mid: i32 = pipeline_onefunc_num_lets(onefunc_result_pool_ptr(out));
        /* See implementation. */
        let kw_back: i32 = 3;
        if (r.tok.kind == token.TokenKind.TOKEN_CONST) {
          kw_back = 5;
        }
        let lex_mid_let: Lexer = Lexer { pos: lexer_pos_before_run(r.next_lex.pos, kw_back), line: r.tok.line, col: r.tok.col };
        if (!parse_body_lets_into(arena, lex_mid_let, source, out, &lex)) {
          set_onefunc_fail(out, lex);
          return;
        }
        out.num_lets = pipeline_onefunc_num_lets(onefunc_result_pool_ptr(out));
        let push_mi: i32 = n_before_mid;
        while (push_mi < out.num_lets) {
          onefunc_push_src_stmt(out, 1, push_mi);
          push_mi = push_mi + 1;
        }
        lexer.lexer_next_into(&r, lex, source);
        continue;
      }
      /**
       * defer { block }: align parse_defer_start; OneFunc sidecar → fill_defers on Block.
       * Hoist-safe (onefunc): append_defer only after body parse.
       * PLATFORM: SHARED.
       */
      if (r.tok.kind == token.TokenKind.TOKEN_DEFER) {
        let block_res_def_fn: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex };
        let def_idx_fn: i32 = 0;
        lex_from_next_into(&lex, r);
        lexer.lexer_next_into(&r, lex, source);
        if (r.tok.kind != token.TokenKind.TOKEN_LBRACE) {
          set_onefunc_fail(out, lex); return;
        }
        /* parse_block_into wants lex_after_lbrace (same as while/loop). */
        lex = r.next_lex;
        block_res_def_fn = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex };
        parse_block_into(arena, lex, source, ret_type_ref, &block_res_def_fn);
        if (!block_res_def_fn.ok) {
          set_onefunc_fail(out, lex); return;
        }
        def_idx_fn = pipeline_onefunc_append_defer(onefunc_result_pool_ptr(out), block_res_def_fn.block_ref);
        if (def_idx_fn < 0) {
          set_onefunc_fail(out, lex); return;
        }
        lex = block_res_def_fn.next_lex;
        stmt_tok_ready = false;
        continue;
      }
      /**
       * MEM-C1: with_arena(cap) { body } — OneFunc sidecar, fill_regions on Block.
       * Hoist-safe: zero-init + assign after parse (no mid-path append_with_arena(0,0)).
       * PLATFORM: SHARED.
       */
      if (r.tok.kind == token.TokenKind.TOKEN_WITH_ARENA) {
        let cap_res_fn: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex };
        let block_res_wa_fn: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex };
        let wa_idx_fn: i32 = 0;
        lex_from_next_into(&lex, r);
        lexer.lexer_next_into(&r, lex, source);
        if (r.tok.kind != token.TokenKind.TOKEN_LPAREN) {
          set_onefunc_fail(out, lex); return;
        }
        lex_from_next_into(&lex, r);
        cap_res_fn = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex };
        parse_expr_into(arena, lex, source, &cap_res_fn);
        if (!cap_res_fn.ok || cap_res_fn.expr_ref == 0) {
          set_onefunc_fail(out, lex); return;
        }
        lex = cap_res_fn.next_lex;
        lexer.lexer_next_into(&r, lex, source);
        if (r.tok.kind != token.TokenKind.TOKEN_RPAREN) {
          set_onefunc_fail(out, lex); return;
        }
        lex_from_next_into(&lex, r);
        lexer.lexer_next_into(&r, lex, source);
        if (r.tok.kind != token.TokenKind.TOKEN_LBRACE) {
          set_onefunc_fail(out, lex); return;
        }
        lex_from_next_into(&lex, r);
        block_res_wa_fn = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex };
        parse_block_into(arena, lex, source, ret_type_ref, &block_res_wa_fn);
        if (!block_res_wa_fn.ok) {
          set_onefunc_fail(out, lex); return;
        }
        wa_idx_fn = pipeline_onefunc_append_with_arena(onefunc_result_pool_ptr(out), cap_res_fn.expr_ref, block_res_wa_fn.block_ref);
        if (wa_idx_fn < 0) {
          set_onefunc_fail(out, lex); return;
        }
        onefunc_push_src_stmt(out, 6, wa_idx_fn);
        lex = block_res_wa_fn.next_lex;
        lexer.lexer_next_into(&r, lex, source);
        stmt_tok_ready = true;
        continue;
      }
      /**
       * M-3: region label { body } — OneFunc sidecar → fill_regions on Block.
       * Hoist-safe: append_region only after body parse.
       * PLATFORM: SHARED.
       */
      if (r.tok.kind == token.TokenKind.TOKEN_REGION) {
        let reg_nm_fn: u8[64] = [];
        let reg_nlen_fn: i32 = 0;
        let block_res_reg_fn: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex };
        let reg_idx_fn: i32 = 0;
        lex_from_next_into(&lex, r);
        lexer.lexer_next_into(&r, lex, source);
        if (r.tok.kind != token.TokenKind.TOKEN_IDENT) {
          set_onefunc_fail(out, lex); return;
        }
        copy_slice_to_name64(source, r.token_start, r.tok.ident_len, &reg_nm_fn[0]);
        reg_nlen_fn = r.tok.ident_len;
        lex_from_next_into(&lex, r);
        lexer.lexer_next_into(&r, lex, source);
        if (r.tok.kind != token.TokenKind.TOKEN_LBRACE) {
          set_onefunc_fail(out, lex); return;
        }
        /* parse_block_into wants lex after `{` (same as while). */
        lex_from_next_into(&lex, r);
        block_res_reg_fn = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex };
        parse_block_into(arena, lex, source, ret_type_ref, &block_res_reg_fn);
        if (!block_res_reg_fn.ok) {
          set_onefunc_fail(out, lex); return;
        }
        reg_idx_fn = pipeline_onefunc_append_region(onefunc_result_pool_ptr(out), &reg_nm_fn[0], reg_nlen_fn, block_res_reg_fn.block_ref);
        if (reg_idx_fn < 0) {
          set_onefunc_fail(out, lex); return;
        }
        onefunc_push_src_stmt(out, 6, reg_idx_fn);
        lex = block_res_reg_fn.next_lex;
        lexer.lexer_next_into(&r, lex, source);
        stmt_tok_ready = true;
        continue;
      }
      /* See implementation. */
      if (r.tok.kind == token.TokenKind.TOKEN_IDENT && r.tok.ident_len == 6) {
        let unsafe_nm_fn: u8[64] = [];
        copy_slice_to_name64(source, r.token_start, r.tok.ident_len, &unsafe_nm_fn[0]);
        if (unsafe_nm_fn[0] == 117 && unsafe_nm_fn[1] == 110 && unsafe_nm_fn[2] == 115 && unsafe_nm_fn[3] == 97
        && unsafe_nm_fn[4] == 102 && unsafe_nm_fn[5] == 101) {
          /**
           * Hoist-safe unsafe (onefunc): append_unsafe only after body parse.
           * PLATFORM: SHARED — force hello needs co-emit of std_io_sync_io_libc_*.
           */
          let block_res_unsafe_fn: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex };
          let unsafe_idx_fn: i32 = 0;
          lex_from_next_into(&lex, r);
          lexer.lexer_next_into(&r, lex, source);
          if (r.tok.kind != token.TokenKind.TOKEN_LBRACE) {
            set_onefunc_fail(out, lex); return;
          }
          /* parse_block_into wants lex after `{`. */
          lex_from_next_into(&lex, r);
          block_res_unsafe_fn = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex };
          parse_block_into(arena, lex, source, ret_type_ref, &block_res_unsafe_fn);
          if (!block_res_unsafe_fn.ok) {
            set_onefunc_fail(out, lex); return;
          }
          unsafe_idx_fn = pipeline_onefunc_append_unsafe(onefunc_result_pool_ptr(out), block_res_unsafe_fn.block_ref);
          if (unsafe_idx_fn < 0) {
            set_onefunc_fail(out, lex); return;
          }
          onefunc_push_src_stmt(out, 6, unsafe_idx_fn);
          lex = block_res_unsafe_fn.next_lex;
          stmt_tok_ready = false;
          continue;
        }
      }
      /**
       * See implementation.
       * See implementation.
       */
      if (parser_token_is_label_start(r, source)) {
        let colon_fn: LexerResult = LexerResult {
          next_lex: r.next_lex,
          tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 },
          token_start: 0
        };
        lexer.lexer_next_into(&colon_fn, r.next_lex, source);
        lex = colon_fn.next_lex;
        lexer.lexer_next_into(&r, lex, source);
        if (r.tok.kind == token.TokenKind.TOKEN_RETURN) {
          break;
        }
        if (r.tok.kind == token.TokenKind.TOKEN_GOTO) {
          lex_from_next_into(&lex, r);
          lexer.lexer_next_into(&r, lex, source);
          if (r.tok.kind != token.TokenKind.TOKEN_IDENT) {
            set_onefunc_fail(out, lex); return;
          }
          lex_from_next_into(&lex, r);
          lexer.lexer_next_into(&r, lex, source);
          if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
            lex_from_next_into(&lex, r);
            lexer.lexer_next_into(&r, lex, source);
          }
          stmt_tok_ready = true;
          continue;
        }
        set_onefunc_fail(out, lex); return;
      }
      if (r.tok.kind == token.TokenKind.TOKEN_LOOP) {
        /**
         * Hoist-safe loop (onefunc path): append_while only after body parse.
         * PLATFORM: SHARED — pin X→C must not hoist append before parse.
         */
        let cond_ref_loop: i32 = 0;
        let block_res_loop: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex };
        let while_idx_loop: i32 = 0;
        lex_from_next_into(&lex, r);
        lexer.lexer_next_into(&r, lex, source);
        if (r.tok.kind != token.TokenKind.TOKEN_LBRACE) {
          set_onefunc_fail(out, lex); return;
        }
        lex = r.next_lex;
        cond_ref_loop = parser_alloc_true_bool_lit(arena);
        if (cond_ref_loop == 0) {
          set_onefunc_fail(out, lex); return;
        }
        block_res_loop = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex };
        parse_block_into(arena, lex, source, ret_type_ref, &block_res_loop);
        if (!block_res_loop.ok) {
          set_onefunc_fail(out, lex); return;
        }
        while_idx_loop = pipeline_onefunc_append_while(onefunc_result_pool_ptr(out), cond_ref_loop, block_res_loop.block_ref);
        if (while_idx_loop < 0) {
          set_onefunc_fail(out, lex); return;
        }
        impl_snap.num_loops = pipeline_onefunc_num_whiles(onefunc_result_pool_ptr(out));
        onefunc_push_src_stmt(out, 3, while_idx_loop);
        lex = block_res_loop.next_lex;
        stmt_tok_ready = false;
        continue;
      }
      if (r.tok.kind == token.TokenKind.TOKEN_WHILE) {
        /**
         * Hoist-safe while (onefunc path): zero-init at top; assign cond_start after
         * advance past WHILE/(; append_while only after cond+body success.
         * PLATFORM: SHARED — fixes force hello core_fmt co-emit residual.
         */
        let while_cond_start: Lexer = lex;
        let expr_res: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex };
        let cond_ref: i32 = 0;
        let block_res: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex };
        let while_idx: i32 = 0;
        lex_from_next_into(&lex, r);
        lexer.lexer_next_into(&r, lex, source);
        if (r.tok.kind != token.TokenKind.TOKEN_LPAREN) {
          set_onefunc_fail(out, lex); return;
        }
        lex = r.next_lex;
        while_cond_start = lex;
        expr_res = ParseExprResult { ok: false, expr_ref: 0, next_lex: while_cond_start };
        parse_cond_expr_into(arena, while_cond_start, source, &expr_res);
        if (!expr_res.ok) {
          set_onefunc_fail(out, lex); return;
        }
        cond_ref = expr_res.expr_ref;
        lex = expr_res.next_lex;
        if (advance_past_cond_rparen_into(&r, lex, source) == 0) {
          set_onefunc_fail(out, lex); return;
        }
        if (r.tok.kind != token.TokenKind.TOKEN_LBRACE) {
          set_onefunc_fail(out, lex); return;
        }
        lex = r.next_lex;
        block_res = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex };
        parse_block_into(arena, lex, source, ret_type_ref, &block_res);
        if (!block_res.ok) {
          set_onefunc_fail(out, lex); return;
        }
        while_idx = pipeline_onefunc_append_while(onefunc_result_pool_ptr(out), cond_ref, block_res.block_ref);
        if (while_idx < 0) {
          set_onefunc_fail(out, lex); return;
        }
        impl_snap.num_loops = pipeline_onefunc_num_whiles(onefunc_result_pool_ptr(out));
        onefunc_push_src_stmt(out, 3, while_idx);
        lex = block_res.next_lex;
        stmt_tok_ready = false;
        continue;
      }
      if (r.tok.kind == token.TokenKind.TOKEN_FOR) {
        /**
         * Hoist-safe for (onefunc path): append_for only after full header+body parse.
         * PLATFORM: SHARED.
         */
        let init_ref: i32 = 0;
        let for_cond_ref: i32 = 0;
        let step_ref: i32 = 0;
        let block_res_f: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex };
        let for_idx: i32 = 0;
        let expr_res_fi: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex };
        let expr_res_fc: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex };
        let expr_res_fs: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex };
        let cond_expr_ref: i32 = 0;
        lex_from_next_into(&lex, r);
        lexer.lexer_next_into(&r, lex, source);
        if (r.tok.kind != token.TokenKind.TOKEN_LPAREN) {
          set_onefunc_fail(out, lex); return;
        }
        lex = r.next_lex;
        lexer.lexer_next_into(&r, lex, source);
        if (r.tok.kind != token.TokenKind.TOKEN_SEMICOLON) {
          expr_res_fi = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex };
          parse_expr_into(arena, lex, source, &expr_res_fi);
          /* Full expr required (incl. assign); empty step breaks typeck vs shux-c. */
          if (!expr_res_fi.ok) {
            set_onefunc_fail(out, lex); return;
          }
          init_ref = expr_res_fi.expr_ref;
          lex = expr_res_fi.next_lex;
          lexer.lexer_next_into(&r, lex, source);
        }
        if (r.tok.kind != token.TokenKind.TOKEN_SEMICOLON) {
          set_onefunc_fail(out, lex); return;
        }
        lex = r.next_lex;
        lexer.lexer_next_into(&r, lex, source);
        if (r.tok.kind != token.TokenKind.TOKEN_SEMICOLON) {
          expr_res_fc = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex };
          parse_expr_into(arena, lex, source, &expr_res_fc);
          if (!expr_res_fc.ok) {
            set_onefunc_fail(out, lex); return;
          }
          for_cond_ref = expr_res_fc.expr_ref;
          lex = expr_res_fc.next_lex;
          lexer.lexer_next_into(&r, lex, source);
        }
        if (r.tok.kind != token.TokenKind.TOKEN_SEMICOLON) {
          set_onefunc_fail(out, lex); return;
        }
        lex = r.next_lex;
        lexer.lexer_next_into(&r, lex, source);
        if (r.tok.kind != token.TokenKind.TOKEN_RPAREN) {
          expr_res_fs = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex };
          parse_expr_into(arena, lex, source, &expr_res_fs);
          if (!expr_res_fs.ok) {
            set_onefunc_fail(out, lex); return;
          }
          step_ref = expr_res_fs.expr_ref;
          lex = expr_res_fs.next_lex;
          lexer.lexer_next_into(&r, lex, source);
        }
        if (r.tok.kind != token.TokenKind.TOKEN_RPAREN) {
          set_onefunc_fail(out, lex); return;
        }
        lex = r.next_lex;
        lexer.lexer_next_into(&r, lex, source);
        if (r.tok.kind != token.TokenKind.TOKEN_LBRACE) {
          set_onefunc_fail(out, lex); return;
        }
        lex = r.next_lex;
        block_res_f = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex };
        parse_block_into(arena, lex, source, ret_type_ref, &block_res_f);
        if (!block_res_f.ok) {
          set_onefunc_fail(out, lex); return;
        }
        if (for_cond_ref == 0) {
          cond_expr_ref = ast.ast_arena_expr_alloc(arena);
          if (cond_expr_ref != 0) {
            let ce: Expr = ast.ast_arena_expr_get(arena, cond_expr_ref);
            ce.kind = ExprKind.EXPR_BOOL_LIT;
            ce.int_val = 1;
            ce.line = 0;
            ce.col = 0;
            expr_set_common_zeros(&ce);
            ast.ast_arena_expr_set(arena, cond_expr_ref, ce);
            for_cond_ref = cond_expr_ref;
          }
        }
        for_idx = pipeline_onefunc_append_for(onefunc_result_pool_ptr(out), init_ref, for_cond_ref, step_ref, block_res_f.block_ref);
        if (for_idx < 0) {
          set_onefunc_fail(out, lex); return;
        }
        impl_snap.num_for_loops = pipeline_onefunc_num_fors(onefunc_result_pool_ptr(out));
        onefunc_push_src_stmt(out, 4, for_idx);
        lex = block_res_f.next_lex;
        stmt_tok_ready = false;
        continue;
      }
      /**
       * See implementation.
       * See implementation.
       */
      if (r.tok.kind == token.TokenKind.TOKEN_LPAREN) {
        lex = parser_rewind_lex_for_lparen_control_stmt(lex, r, source);
        lexer.lexer_next_into(&r, lex, source);
      }
      if (r.tok.kind == token.TokenKind.TOKEN_IF) {
        let if_start_fn: Lexer = lex_at_token_from_result(r);
        let if_cref: i32 = 0;
        let if_then_ref: i32 = 0;
        let if_else_ref: i32 = 0;
        if (!parse_if_stmt_into(arena, if_start_fn, source, 0, &if_cref, &if_then_ref, &if_else_ref, &lex)) {
          set_onefunc_fail(out, lex); return;
        }
        let if_pool_idx: i32 = pipeline_onefunc_append_if(onefunc_result_pool_ptr(out), if_cref, if_then_ref, if_else_ref);
        if (if_pool_idx < 0) {
          set_onefunc_fail(out, lex); return;
        }
        onefunc_push_src_stmt(out, 5, if_pool_idx);
        /**
         * See implementation.
         * See implementation.
         */
        stmt_tok_ready = false;
        continue;
      }
      /**
       * Bare block statement `{ stmts }` at function-body statement position.
       * PLATFORM: SHARED — same contract as parse_block_into (no trailing `;`).
       * Mirrors seed parser_parse_block_into bare-block arm so mega parse_into* parse.
       */
      if (r.tok.kind == token.TokenKind.TOKEN_LBRACE) {
        /** Hoist-safe bare block (onefunc): wrap/push only after nested parse succeeds. */
        let block_res_bare_fn: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex };
        let bare_expr_fn: i32 = 0;
        let bare_ex_fn: i32 = 0;
        lex_from_next_into(&lex, r);
        block_res_bare_fn = ParseBlockResult { ok: false, block_ref: 0, next_lex: lex };
        parse_block_into(arena, lex, source, ret_type_ref, &block_res_bare_fn);
        if (!block_res_bare_fn.ok) {
          set_onefunc_fail(out, lex); return;
        }
        bare_expr_fn = wrap_block_ref_as_expr(arena, block_res_bare_fn.block_ref, ret_type_ref);
        if (bare_expr_fn == 0) {
          set_onefunc_fail(out, lex); return;
        }
        bare_ex_fn = pipeline_onefunc_push_body_expr_stmt(onefunc_result_pool_ptr(out), bare_expr_fn);
        if (bare_ex_fn < 0) {
          set_onefunc_fail(out, lex); return;
        }
        out.num_src_body_expr_stmts = pipeline_onefunc_num_body_expr_stmts(onefunc_result_pool_ptr(out));
        onefunc_push_src_stmt(out, 2, bare_ex_fn);
        lex = block_res_bare_fn.next_lex;
        stmt_tok_ready = false;
        continue;
      }
      /* expr; — hoist-safe: rebind stmt_start from r; push only after parse success. */
      lex_from_result_ptr_into(&lex, &r);
      stmt_start = lex_at_token_from_result(r);
      parse_expr_result_reset(&expr_stmt_res, stmt_start);
      if (r.tok.kind == token.TokenKind.TOKEN_INT) {
        parse_cond_expr_into(arena, stmt_start, source, &expr_stmt_res);
      } else {
        parse_expr_into(arena, stmt_start, source, &expr_stmt_res);
      }
      if (!expr_stmt_res.ok) {
        set_onefunc_fail(out, lex); return;
      }
      lex = expr_stmt_res.next_lex;
      /* Non-void returns require `return expr;`; bare block-tail is not a return value. */
      if (advance_past_stmt_semicolon_into(&r, lex, source) == 0) {
        set_onefunc_fail(out, lex); return;
      }
      /* Keep r.tok after expr; so next loop head does not swallow return/let/if. */
      if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
        lex_from_result_ptr_into(&lex, &r);
        let after_semi: LexerResult = LexerResult { next_lex: lex, tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 }, token_start: 0 };
        lexer.lexer_next_into(&after_semi, lex, source);
        r = after_semi;
      }
      ex_i = pipeline_onefunc_push_body_expr_stmt(onefunc_result_pool_ptr(out), expr_stmt_res.expr_ref);
      if (ex_i < 0) {
        set_onefunc_fail(out, lex); return;
      }
      out.num_src_body_expr_stmts = pipeline_onefunc_num_body_expr_stmts(onefunc_result_pool_ptr(out));
      onefunc_push_src_stmt(out, 2, ex_i);
      if (r.tok.kind == token.TokenKind.TOKEN_RETURN || r.tok.kind == token.TokenKind.TOKEN_RBRACE
          || r.tok.kind == token.TokenKind.TOKEN_MATCH || r.tok.kind == token.TokenKind.TOKEN_EOF) {
        break;
      }
      lex = lex_at_token_from_result(r);
      stmt_tok_ready = true;
      continue;
    }
  } else {
    set_onefunc_fail(out, lex); return;
  }
  if (r.tok.kind == token.TokenKind.TOKEN_RBRACE) {
    /* See implementation. */
    lex_from_next_into(&lex, r);
    onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
    return;
  }
  /* See implementation. */
  impl_snap.has_final_expr = true;
  /*
   * See implementation.
   * See implementation.
   */
  if (r.tok.kind == token.TokenKind.TOKEN_MATCH) {
    impl_snap.has_explicit_return_kw = true;
    let match_tail_lex: Lexer = lex_at_token_from_result(r);
    let match_tail_res: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: match_tail_lex };
    parse_match_into(arena, match_tail_lex, source, &match_tail_res);
    if (!match_tail_res.ok) {
      set_onefunc_fail(out, lex); return;
    }
    return_expr_ref_storage = match_tail_res.expr_ref;
    lex = match_tail_res.next_lex;
    lexer.lexer_next_into(&r, lex, source);
    if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
      lex_from_next_into(&lex, r);
      lexer.lexer_next_into(&r, lex, source);
    }
    if (r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
      set_onefunc_fail(out, lex); return;
    }
    lex_from_next_into(&lex, r);
    onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
    return;
  }
  /*
   * See implementation.
   * See implementation.
   */
  if (r.tok.kind == token.TokenKind.TOKEN_IDENT) {
    let subj_start: usize = r.token_start;
    if (subj_start == 0) {
      subj_start = lexer_pos_before_run(r.next_lex.pos, r.tok.ident_len);
    }
    if (parser_match_kw_immediately_before(source, subj_start)) {
      impl_snap.has_explicit_return_kw = true;
      let match_subj_lex: Lexer = Lexer { pos: subj_start - 6, line: r.tok.line, col: r.tok.col };
      let match_subj_res: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: match_subj_lex };
      parse_match_into(arena, match_subj_lex, source, &match_subj_res);
      if (!match_subj_res.ok) {
        set_onefunc_fail(out, lex); return;
      }
      return_expr_ref_storage = match_subj_res.expr_ref;
      lex = match_subj_res.next_lex;
      lexer.lexer_next_into(&r, lex, source);
      if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
        lex_from_next_into(&lex, r);
        lexer.lexer_next_into(&r, lex, source);
      }
      if (r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
        set_onefunc_fail(out, lex); return;
      }
      lex_from_next_into(&lex, r);
      onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
      return;
    }
  }
  if (r.tok.kind == token.TokenKind.TOKEN_RETURN) {
  impl_snap.has_explicit_return_kw = true;
  lex_from_next_into(&lex, r);
  lexer.lexer_next_into(&r, lex, source);
  /* See implementation. */
  if (r.tok.kind == token.TokenKind.TOKEN_MATCH) {
    let match_ret_lex: Lexer = lex_at_token_from_result(r);
    let match_ret_res: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: match_ret_lex };
    parse_match_into(arena, match_ret_lex, source, &match_ret_res);
    if (!match_ret_res.ok) {
      set_onefunc_fail(out, lex); return;
    }
    return_expr_ref_storage = match_ret_res.expr_ref;
    lex = match_ret_res.next_lex;
    lexer.lexer_next_into(&r, lex, source);
    if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
      lex_from_next_into(&lex, r);
      lexer.lexer_next_into(&r, lex, source);
    }
    if (r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
      set_onefunc_fail(out, lex); return;
    }
    lex_from_next_into(&lex, r);
    onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
    return;
  }
  /* See implementation. */
  if (!return_type_is_bool && r.tok.kind != token.TokenKind.TOKEN_IF) {
    let rex_u_lex: Lexer = lex_at_token_from_result(r);
    let rex_u_res: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: rex_u_lex };
    parse_cond_expr_into(arena, rex_u_lex, source, &rex_u_res);
    if (rex_u_res.ok) {
      return_expr_ref_storage = rex_u_res.expr_ref;
      lex = rex_u_res.next_lex;
      lexer.lexer_next_into(&r, lex, source);
      if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
        lex_from_next_into(&lex, r);
        lexer.lexer_next_into(&r, lex, source);
      }
      if (r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
        set_onefunc_fail(out, lex); return;
      }
      lex_from_next_into(&lex, r);
      onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
      return;
    }
  }
  /* See implementation. */
  if (r.tok.kind == token.TokenKind.TOKEN_IF) {
    let if_lex: Lexer = lex_at_token_from_result(r);
    let if_res: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: if_lex };
    parse_if_expr_into(arena, if_lex, source, 0, &if_res);
    if (if_res.ok) {
      return_expr_ref_storage = if_res.expr_ref;
      lex = if_res.next_lex;
      lexer.lexer_next_into(&r, lex, source);
      if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
        lex_from_next_into(&lex, r);
        lexer.lexer_next_into(&r, lex, source);
      }
      if (r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
        set_onefunc_fail(out, lex); return;
      }
      lex_from_next_into(&lex, r);
      onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
      return;
    }
    lex = if_lex;
    lexer.lexer_next_into(&r, lex, source);
  }
  /**
   * bool return: parse condition/expression after `return`.
   * PLATFORM: SHARED — use parse_cond_expr_into (same as non-bool scalar return path), not
   * parse_expr_into/assign layer only. Cap force: `return !opt.is_some` via parse_expr left
   * return_val=0 (is_none host-cc wrong); parse_cond builds `!((opt.is_some))` correctly
   * (matches seed product and force i32 bang+field). return if still uses legacy below.
   */
  if (return_type_is_bool && r.tok.kind != token.TokenKind.TOKEN_IF) {
    let rex_lex: Lexer = lex_at_token_from_result(r);
    let rex_out: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: rex_lex };
    parse_cond_expr_into(arena, rex_lex, source, &rex_out);
    if (!rex_out.ok) {
      set_onefunc_fail(out, lex); return;
    }
    return_expr_ref_storage = rex_out.expr_ref;
    lex = rex_out.next_lex;
    lexer.lexer_next_into(&r, lex, source);
    if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
      lex_from_next_into(&lex, r);
      lexer.lexer_next_into(&r, lex, source);
    }
    if (r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
      set_onefunc_fail(out, lex); return;
    }
    lex_from_next_into(&lex, r);
    onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
    return;
  }
  if (r.tok.kind == token.TokenKind.TOKEN_IF) {
    lex_from_next_into(&lex, r);
    lexer.lexer_next_into(&r, lex, source);
    if (r.tok.kind != token.TokenKind.TOKEN_LPAREN) {
      set_onefunc_fail(out, lex); return;
    }
    lex_from_next_into(&lex, r);
    let lex_cond_start: Lexer = lex;
    lexer.lexer_next_into(&r, lex, source);
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_TRUE || r.tok.kind == token.TokenKind.TOKEN_FALSE) {
      impl_snap.if_cond_true = r.tok.kind == token.TokenKind.TOKEN_TRUE;
      impl_snap.if_cond_expr_ref = 0;
      lex_from_next_into(&lex, r);
      lexer.lexer_next_into(&r, lex, source);
    } else {
      let cond_res: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: lex_cond_start };
      parse_expr_into(arena, lex_cond_start, source, &cond_res);
      if (!cond_res.ok) {
        set_onefunc_fail(out, lex); return;
      }
      impl_snap.if_cond_expr_ref = cond_res.expr_ref;
      impl_snap.if_cond_true = false;
      lex = cond_res.next_lex;
      lexer.lexer_next_into(&r, lex, source);
    }
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_RPAREN) {
      lex_from_next_into(&lex, r);
      lexer.lexer_next_into(&r, lex, source);
    }
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_LBRACE) {
      lex_from_next_into(&lex, r);
      lexer.lexer_next_into(&r, lex, source);
    }
    if (r.tok.kind != token.TokenKind.TOKEN_INT) {
      set_onefunc_fail(out, lex); return;
    }
    impl_snap.if_then_val = r.tok.int_val;
    lex_from_next_into(&lex, r);
    lexer.lexer_next_into(&r, lex, source);
    if (r.tok.kind == token.TokenKind.TOKEN_RBRACE) {
      lex_from_next_into(&lex, r);
      lexer.lexer_next_into(&r, lex, source);
    }
    if (r.tok.kind != token.TokenKind.TOKEN_ELSE) {
      set_onefunc_fail(out, lex); return;
    }
    lex_from_next_into(&lex, r);
    lexer.lexer_next_into(&r, lex, source);
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_LBRACE) {
      lex_from_next_into(&lex, r);
      lexer.lexer_next_into(&r, lex, source);
    }
    if (r.tok.kind != token.TokenKind.TOKEN_INT) {
      set_onefunc_fail(out, lex); return;
    }
    impl_snap.if_else_val = r.tok.int_val;
    impl_snap.has_if_expr = true;
    lex_from_next_into(&lex, r);
    lexer.lexer_next_into(&r, lex, source);
    if (r.tok.kind == token.TokenKind.TOKEN_RBRACE) {
      lex_from_next_into(&lex, r);
      lexer.lexer_next_into(&r, lex, source);
    }
    /* See implementation. */
    onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
    return;
  } else if (r.tok.kind == token.TokenKind.TOKEN_MINUS) {
    lex_from_next_into(&lex, r);
    lexer.lexer_next_into(&r, lex, source);
    if (r.tok.kind != token.TokenKind.TOKEN_INT) {
      set_onefunc_fail(out, lex); return;
    }
    impl_snap.return_val = r.tok.int_val;
    impl_snap.has_unary_neg = true;
    lex_from_next_into(&lex, r);
    lexer.lexer_next_into(&r, lex, source);
  } else if (r.tok.kind == token.TokenKind.TOKEN_INT) {
    let ret_int_val: i32 = r.tok.int_val;
    let ret_int_start: usize = r.token_start;
    if (ret_int_start == 0) {
      ret_int_start = r.next_lex.pos - 1;
    }
    let ret_int_lex: Lexer = Lexer { pos: ret_int_start, line: lex.line, col: lex.col };
    lex_from_next_into(&lex, r);
    lexer.lexer_next_into(&r, lex, source);
    if (r.tok.kind == token.TokenKind.TOKEN_AS) {
      let ret_expr_res: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: ret_int_lex };
      parse_expr_into(arena, ret_int_lex, source, &ret_expr_res);
      if (!ret_expr_res.ok) {
        set_onefunc_fail(out, lex); return;
      }
      return_expr_ref_storage = ret_expr_res.expr_ref;
      lex = ret_expr_res.next_lex;
      if (!onefunc_finish_after_return_lex(out, &impl_snap, source, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage)) {
        set_onefunc_fail(out, lex); return;
      }
      return;
    }
    impl_snap.return_val = ret_int_val;
    /*
     * See implementation.
     * See implementation.
     */
    if (r.tok.kind != token.TokenKind.TOKEN_SEMICOLON && r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
      let rex_add: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: ret_int_lex };
      parse_expr_into(arena, ret_int_lex, source, &rex_add);
      if (!rex_add.ok) {
        set_onefunc_fail(out, lex); return;
      }
      return_expr_ref_storage = rex_add.expr_ref;
      lex = rex_add.next_lex;
      if (!onefunc_finish_after_return_lex(out, &impl_snap, source, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage)) {
        set_onefunc_fail(out, lex); return;
      }
      return;
    }
    /* See implementation. */
    if (!onefunc_finish_after_return_lex(out, &impl_snap, source, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage)) {
      set_onefunc_fail(out, lex); return;
    }
    return;
  } else {
    /*
     * See implementation.
     * See implementation.
     */
    if (r.tok.kind != token.TokenKind.TOKEN_IDENT) {
      let rex_lex_ni: Lexer = lex_at_token_from_result(r);
      let rex_out_ni: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: rex_lex_ni };
      parse_expr_into(arena, rex_lex_ni, source, &rex_out_ni);
      if (!rex_out_ni.ok) {
        set_onefunc_fail(out, lex); return;
      }
      return_expr_ref_storage = rex_out_ni.expr_ref;
      lex = rex_out_ni.next_lex;
      lexer.lexer_next_into(&r, lex, source);
      if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
        lex_from_next_into(&lex, r);
        lexer.lexer_next_into(&r, lex, source);
      }
      if (r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
        set_onefunc_fail(out, lex); return;
      }
      lex_from_next_into(&lex, r);
      onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
      return;
    }
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_IDENT) {
      let clen: i32 = r.tok.ident_len;
      if (clen > 0 && clen <= 63) {
        let cstart: usize = r.next_lex.pos - clen;
        copy_slice_to_name64(source, cstart, clen, &impl_snap.call_callee_name[0]);
        impl_snap.call_callee_len = clen;
        lex_from_next_into(&lex, r);
        lexer.lexer_next_into(&r, lex, source);
        /* See implementation. */
        if (r.tok.kind == token.TokenKind.TOKEN_PLUS && out.num_params >= 2) {
          lex_from_next_into(&lex, r);
          lexer.lexer_next_into(&r, lex, source);
          if (r.tok.kind == token.TokenKind.TOKEN_IDENT) {
            let binop_pool: *u8 = onefunc_result_pool_ptr(out);
            let left_ok: bool = (impl_snap.call_callee_len == pipeline_onefunc_param_name_len(binop_pool, 0));
            if (left_ok) {
              let ii: i32 = 0;
              while (ii < impl_snap.call_callee_len) {
                if (impl_snap.call_callee_name[ii] != pipeline_onefunc_param_name_byte_at(binop_pool, 0, ii)) { left_ok = false; }
                ii = ii + 1;
              }
            }
            /* See implementation. */
            let right_ok: bool = (r.tok.ident_len == pipeline_onefunc_param_name_len(binop_pool, 1));
            if (left_ok && right_ok) {
              impl_snap.has_binop = true;
              impl_snap.binop_left_param_idx = 0;
              impl_snap.binop_right_param_idx = 1;
              impl_snap.return_val = 0;
              lex_from_next_into(&lex, r);
              lexer.lexer_next_into(&r, lex, source);
              if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
                lex_from_next_into(&lex, r);
                lexer.lexer_next_into(&r, lex, source);
                if (r.tok.kind == token.TokenKind.TOKEN_RBRACE) {
                  lex_from_next_into(&lex, r);
    onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
    return;
                }
              }
            }
          }
        }
        /*
         * See implementation.
         * See implementation.
         */
        if (r.tok.kind == token.TokenKind.TOKEN_LBRACE && parser_match_kw_immediately_before(source, cstart)) {
          let match_back: usize = cstart - 6;
          let match_lex_fix: Lexer = Lexer { pos: match_back, line: r.tok.line, col: r.tok.col };
          let match_fix_res: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: match_lex_fix };
          parse_match_into(arena, match_lex_fix, source, &match_fix_res);
          if (!match_fix_res.ok) {
            set_onefunc_fail(out, lex); return;
          }
          return_expr_ref_storage = match_fix_res.expr_ref;
          lex = match_fix_res.next_lex;
          lexer.lexer_next_into(&r, lex, source);
          if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
            lex_from_next_into(&lex, r);
            lexer.lexer_next_into(&r, lex, source);
          }
          if (r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
            set_onefunc_fail(out, lex); return;
          }
          lex_from_next_into(&lex, r);
          onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
          return;
        }
        /* See implementation. */
        if (r.tok.kind == token.TokenKind.TOKEN_RBRACE || r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
          impl_snap.has_call_expr = false;
          impl_snap.return_val = 0;
          onefunc_snap_set_return_path(&impl_snap, false, impl_snap.call_callee_name, impl_snap.call_callee_len, 0);
          if (r.tok.kind == token.TokenKind.TOKEN_RBRACE) {
            lex_from_next_into(&lex, r);
            lexer.lexer_next_into(&r, lex, source);
          } else {
            lex_from_next_into(&lex, r);
            lexer.lexer_next_into(&r, lex, source);
            if (r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
              set_onefunc_fail(out, lex); return;
            }
            lex_from_next_into(&lex, r);
            lexer.lexer_next_into(&r, lex, source);
          }
          onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
          return;
        }
        if (r.tok.kind == token.TokenKind.TOKEN_LPAREN) {
          /* See implementation. */
          let ret_expr_lex: Lexer = Lexer { pos: cstart, line: 1, col: 1 };
          let ret_expr_res: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: ret_expr_lex };
          parse_expr_into(arena, ret_expr_lex, source, &ret_expr_res);
          if (!ret_expr_res.ok) {
            set_onefunc_fail(out, lex); return;
          }
          return_expr_ref_storage = ret_expr_res.expr_ref;
          impl_snap.has_call_expr = false;
          impl_snap.call_callee_len = 0;
          impl_snap.call_num_args = 0;
          lex = ret_expr_res.next_lex;
          lexer.lexer_next_into(&r, lex, source);
          if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
            lex_from_next_into(&lex, r);
            lexer.lexer_next_into(&r, lex, source);
          }
          if (r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
            set_onefunc_fail(out, lex); return;
          }
          lex_from_next_into(&lex, r);
          onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
          return;
        }
        /*
         * See implementation.
         * See implementation.
         */
        let ret_expr_lex_member: Lexer = Lexer { pos: cstart, line: 1, col: 1 };
        let ret_expr_res_member: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: ret_expr_lex_member };
        parse_expr_into(arena, ret_expr_lex_member, source, &ret_expr_res_member);
        if (!ret_expr_res_member.ok) {
          set_onefunc_fail(out, lex); return;
        }
        return_expr_ref_storage = ret_expr_res_member.expr_ref;
        impl_snap.has_call_expr = false;
        impl_snap.call_callee_len = 0;
        impl_snap.call_num_args = 0;
        lex = ret_expr_res_member.next_lex;
        lexer.lexer_next_into(&r, lex, source);
        if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
          lex_from_next_into(&lex, r);
          lexer.lexer_next_into(&r, lex, source);
        }
        if (r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
          set_onefunc_fail(out, lex); return;
        }
        lex_from_next_into(&lex, r);
        onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
        return;
      } else {
        /* See implementation. */
        let ret_id_badlen_lex: Lexer = lex_at_token_from_result(r);
        let ret_id_badlen_res: ParseExprResult = ParseExprResult { ok: false, expr_ref: 0, next_lex: ret_id_badlen_lex };
        parse_expr_into(arena, ret_id_badlen_lex, source, &ret_id_badlen_res);
        if (!ret_id_badlen_res.ok) {
          set_onefunc_fail(out, lex); return;
        }
        return_expr_ref_storage = ret_id_badlen_res.expr_ref;
        impl_snap.has_call_expr = false;
        impl_snap.call_callee_len = 0;
        impl_snap.call_num_args = 0;
        lex = ret_id_badlen_res.next_lex;
        lexer.lexer_next_into(&r, lex, source);
        if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
          lex_from_next_into(&lex, r);
          lexer.lexer_next_into(&r, lex, source);
        }
        if (r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
          set_onefunc_fail(out, lex); return;
        }
        lex_from_next_into(&lex, r);
        onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
        return;
      }
    }
    /* See implementation. */
    while (1 == 1) {
      if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON || r.tok.kind == token.TokenKind.TOKEN_EOF) {
        break;
      }
      lex_from_next_into(&lex, r);
      lexer.lexer_next_into(&r, lex, source);
    }
    if (r.tok.kind != token.TokenKind.TOKEN_SEMICOLON) {
      set_onefunc_fail(out, lex); return;
    }
    lex_from_next_into(&lex, r);
    lexer.lexer_next_into(&r, lex, source);
    impl_snap.return_val = 0;
    if (r.tok.kind == token.TokenKind.TOKEN_RBRACE) {
      lex_from_next_into(&lex, r);
    } else {
      set_onefunc_fail(out, lex); return;
    }
    onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
    return;
  }
  /* See implementation. */
  if (r.tok.kind == token.TokenKind.TOKEN_RBRACE) {
    lex_from_next_into(&lex, r);
  } else if (r.tok.kind == token.TokenKind.TOKEN_SEMICOLON) {
    lex_from_next_into(&lex, r);
    lexer.lexer_next_into(&r, lex, source);
    if (r.tok.kind != token.TokenKind.TOKEN_RBRACE) {
      set_onefunc_fail(out, lex); return;
    }
    lex_from_next_into(&lex, r);
  } else {
    set_onefunc_fail(out, lex); return;
  }
  onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
  return;
  } else {
    /* See implementation. */
    lex = skip_balanced_braces(lex, source);
    /* See implementation. */
    onefunc_finish_impl_to_out(out, &impl_snap, lex, &dummy_name[0], func_name_len_storage[0], return_expr_ref_storage);
    return;
  }
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function import_path_dot_segment_len(kind: token.TokenKind, ident_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  if (kind == token.TokenKind.TOKEN_IDENT && ident_len > 0) {
    return ident_len;
  }
  if (kind == token.TokenKind.TOKEN_I32) {
    return 3;
  }
  let ko: i32 = kind as i32;
  if (ko == 29) {
    return 5;
  }
  return -1;
  }
}



/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_import_path_dot_segment_copy_glue(source: u8[], token_start: usize, seg_len: i32, path_buf: *u8, path_len: i32): void;
/**
 * See implementation.
 */
export function import_path_dot_segment_copy(source: u8[], token_start: usize, seg_len: i32, path_buf: *u8, path_len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let i: i32 = 0;
  while (i < seg_len) {
    if (token_start + (i as usize) < source.length) {
      path_buf[path_len + i] = source[token_start + (i as usize)];
    }
    i = i + 1;
  }
  }
}


/** Exported function `import_path_dot_segment_copy_buf`.
 * Implements `import_path_dot_segment_copy_buf`.
 * @param data *u8
 * @param len i32
 * @param token_start usize
 * @param seg_len i32
 * @param path_buf *u8
 * @param path_len i32
 * @return void
 */
export function import_path_dot_segment_copy_buf(data: *u8, len: i32, token_start: usize, seg_len: i32, path_buf: *u8, path_len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  import_path_dot_segment_copy(slice, token_start, seg_len, path_buf, path_len);
  }
}



/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function parse_into_init(module: *Module, arena: *ASTArena): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  ast.ast_arena_init(arena);
  /* See implementation. */
  ast_pool_module_reset(module);
  ast_pool_arena_reset(arena);
  /* See implementation. */
  onefunc_result_layout_prime();
  onefunc_result_layout_prime_b();
  onefunc_result_layout_prime_c();
  onefunc_result_layout_prime_d();
  onefunc_result_layout_prime_d_b();
  onefunc_result_layout_prime_e();
  onefunc_result_layout_prime_f();
  pipeline_module_reset_parse_counters(module);
  pipeline_parser_set_match_module(module);
  }
}



/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_skip_imports_glue(lex: Lexer, source: u8[]): Lexer;
/** Exported function `skip_imports`.
 * Implements `skip_imports`.
 * @param lex Lexer
 * @param source u8[]
 * @return Lexer
 */
export function skip_imports(lex: Lexer, source: u8[]): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_skip_imports_glue(lex, source);
  }
}


/** Exported function `skip_imports_buf`.
 * Implements `skip_imports_buf`.
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return Lexer
 */
export function skip_imports_buf(lex: Lexer, data: *u8, len: i32): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return skip_imports(lex, slice);
  }
}


/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_collect_imports_glue(lex: Lexer, source: u8[], module: *Module, out: *CollectImportsResult): void;
/** Exported function `collect_imports`.
 * Implements `collect_imports`.
 * @param lex Lexer
 * @param source u8[]
 * @param module *Module
 * @param out *CollectImportsResult
 * @return void
 */
export function collect_imports(lex: Lexer, source: u8[], module: *Module, out: *CollectImportsResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_collect_imports_glue(lex, source, module, out);
  }
}


/**
 * See implementation.
 */
export function collect_imports_buf(lex: Lexer, data: *u8, len: i32, module: *Module, out: *CollectImportsResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  collect_imports(lex, slice, module, out);
  }
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
/* See implementation. */
export extern function parser_skip_one_struct_into_glue(out: *Lexer, lex: Lexer, source: u8[]): void;
/** Exported function `skip_one_struct_into`.
 * Implements `skip_one_struct_into`.
 * @param out *Lexer
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
export function skip_one_struct_into(out: *Lexer, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_skip_one_struct_into_glue(out, lex, source);
  }
}


/* See implementation. */
export extern function parser_skip_one_struct_glue(lex: Lexer, source: u8[]): Lexer;
/** Exported function `skip_one_struct`.
 * Implements `skip_one_struct`.
 * @param lex Lexer
 * @param source u8[]
 * @return Lexer
 */
export function skip_one_struct(lex: Lexer, source: u8[]): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_skip_one_struct_glue(lex, source);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
export extern function parser_module_try_register_enum_name_glue(module: *Module, name: *u8, name_len: i32): i32;
/**
 * See implementation.
 */
export function module_try_register_enum_name(module: *Module, name: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  if (module == 0 as *Module || name == 0 as *u8 || name_len <= 0 || name_len > 63) {
    return -1;
  }
  let ei: i32 = 0;
  while (ei < module.num_module_enums) {
    if (pipeline_module_enum_name_len(module, ei) == name_len) {
      let eq: bool = true;
      let j: i32 = 0;
      while (j < name_len) {
        if (pipeline_module_enum_name_byte_at(module, ei, j) != name[j]) {
          eq = false;
          break;
        }
        j = j + 1;
      }
      if (eq) {
        return ei;
      }
    }
    ei = ei + 1;
  }
  let slot: i32 = pipeline_module_enum_alloc(module);
  if (slot < 0) {
    return -1;
  }
  pipeline_module_enum_set_name(module, slot, name, name_len);
  return slot;
  }
  return 0;  // unreachable — typeck after unsafe block
}



/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
extern function parser_module_append_enum_variants_and_skip_body_into_glue(module: *Module, enum_idx: i32, out: *Lexer, lex: Lexer, source: u8[]): void;
/** Internal function `module_append_enum_variants_and_skip_body_into`.
 * Implements `module_append_enum_variants_and_skip_body_into`.
 * @param module *Module
 * @param enum_idx i32
 * @param out *Lexer
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
function module_append_enum_variants_and_skip_body_into(module: *Module, enum_idx: i32, out: *Lexer, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_module_append_enum_variants_and_skip_body_into_glue(module, enum_idx, out, lex, source);
  }
}


/** Internal function `module_append_enum_variants_and_skip_body_into_buf`.
 * Implements `module_append_enum_variants_and_skip_body_into_buf`.
 * @param module *Module
 * @param enum_idx i32
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
function module_append_enum_variants_and_skip_body_into_buf(module: *Module, enum_idx: i32, out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let depth: i32 = 1;
  let slen: usize = len as usize;
  while (depth > 0) {
    let r: LexerResult = lexer.lexer_next_buf(lex, data, len);
    if (r.tok.kind == token.TokenKind.TOKEN_RBRACE) {
      depth = depth - 1;
      if (depth == 0) {
        lex_from_next_into(&lex, r);
        break;
      }
    } else if (r.tok.kind == token.TokenKind.TOKEN_LBRACE) {
      depth = depth + 1;
    } else if (depth == 1 && enum_idx >= 0 && r.tok.kind == token.TokenKind.TOKEN_IDENT) {
      let vlen: i32 = r.tok.ident_len;
      if (vlen > 63) {
        vlen = 63;
      }
      let vstart: usize = r.token_start;
      let vb: u8[64] = [];
      let nk: i32 = 0;
      while (nk < vlen && nk < 64) {
        let ix: usize = vstart + (nk as usize);
        if (ix >= slen) {
          break;
        }
        vb[nk] = data[ix];
        nk = nk + 1;
      }
      if (nk == vlen && vlen > 0) {
        pipeline_module_enum_append_variant(module, enum_idx, &vb[0], vlen);
      }
    }
    lex_from_next_into(&lex, r);
  }
  out.pos = lex.pos;
  out.line = lex.line;
  out.col = lex.col;
  }
}



/* See implementation. */
/* See implementation. */
extern function parser_skip_one_enum_register_into_glue(module: *Module, out: *Lexer, lex: Lexer, source: u8[]): void;
/** Internal function `skip_one_enum_register_into`.
 * Registration helper `skip_one_enum_register_into`.
 * @param module *Module
 * @param out *Lexer
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
function skip_one_enum_register_into(module: *Module, out: *Lexer, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_skip_one_enum_register_into_glue(module, out, lex, source);
  }
}


/** Internal function `skip_one_enum_register_into_buf`.
 * Registration helper `skip_one_enum_register_into_buf`.
 * @param module *Module
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
function skip_one_enum_register_into_buf(module: *Module, out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  skip_one_enum_register_into(module, out, lex, slice);
  }
}


/** Internal function `skip_one_enum_register_buf`.
 * Registration helper `skip_one_enum_register_buf`.
 * @param module *Module
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
function skip_one_enum_register_buf(module: *Module, out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  skip_one_enum_register_into_buf(module, out, lex, data, len);
  }
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
/* See implementation. */
extern function parser_skip_one_enum_into_glue(out: *Lexer, lex: Lexer, source: u8[]): void;
/** Internal function `skip_one_enum_into`.
 * Implements `skip_one_enum_into`.
 * @param out *Lexer
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
function skip_one_enum_into(out: *Lexer, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_skip_one_enum_into_glue(out, lex, source);
  }
}

/* See implementation. */
extern function parser_skip_one_enum_glue(lex: Lexer, source: u8[]): Lexer;
/** Internal function `skip_one_enum`.
 * Implements `skip_one_enum`.
 * @param lex Lexer
 * @param source u8[]
 * @return Lexer
 */
function skip_one_enum(lex: Lexer, source: u8[]): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_skip_one_enum_glue(lex, source);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
/* See implementation. */
extern function parser_skip_one_trait_into_glue(out: *Lexer, lex: Lexer, source: u8[]): void;
/** Internal function `skip_one_trait_into`.
 * Implements `skip_one_trait_into`.
 * @param out *Lexer
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
function skip_one_trait_into(out: *Lexer, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_skip_one_trait_into_glue(out, lex, source);
  }
}

/* See implementation. */
extern function parser_skip_one_trait_glue(lex: Lexer, source: u8[]): Lexer;
/** Internal function `skip_one_trait`.
 * Implements `skip_one_trait`.
 * @param lex Lexer
 * @param source u8[]
 * @return Lexer
 */
function skip_one_trait(lex: Lexer, source: u8[]): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_skip_one_trait_glue(lex, source);
  }
}


/**
 * See implementation.
 */
/* See implementation. */
/* See implementation. */
extern function parser_skip_one_impl_into_glue(out: *Lexer, lex: Lexer, source: u8[]): void;
/** Internal function `skip_one_impl_into`.
 * Implements `skip_one_impl_into`.
 * @param out *Lexer
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
function skip_one_impl_into(out: *Lexer, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_skip_one_impl_into_glue(out, lex, source);
  }
}

/* See implementation. */
extern function parser_skip_one_impl_glue(lex: Lexer, source: u8[]): Lexer;
/** Internal function `skip_one_impl`.
 * Implements `skip_one_impl`.
 * @param lex Lexer
 * @param source u8[]
 * @return Lexer
 */
function skip_one_impl(lex: Lexer, source: u8[]): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_skip_one_impl_glue(lex, source);
  }
}
/** Internal function `skip_one_enum_into_buf`.
 * Implements `skip_one_enum_into_buf`.
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
function skip_one_enum_into_buf(out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  skip_one_enum_into(out, lex, slice);
  }
}


/** skip_one_enum_buf：parser_slice_from_buf + bl skip_one_enum。 */
function skip_one_enum_buf(lex: Lexer, data: *u8, len: i32): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return skip_one_enum(lex, slice);
  }
}


/** Internal function `skip_one_trait_into_buf`.
 * Implements `skip_one_trait_into_buf`.
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
function skip_one_trait_into_buf(out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  skip_one_trait_into(out, lex, slice);
  }
}

/** skip_one_trait_buf：parser_slice_from_buf + bl skip_one_trait。 */
function skip_one_trait_buf(lex: Lexer, data: *u8, len: i32): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return skip_one_trait(lex, slice);
  }
}


/** Internal function `skip_one_impl_into_buf`.
 * Implements `skip_one_impl_into_buf`.
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
function skip_one_impl_into_buf(out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  skip_one_impl_into(out, lex, slice);
  }
}

/** skip_one_impl_buf：parser_slice_from_buf + bl skip_one_impl。 */
function skip_one_impl_buf(lex: Lexer, data: *u8, len: i32): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return skip_one_impl(lex, slice);
  }
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
/* See implementation. */
extern function parser_skip_one_extern_into_glue(out: *Lexer, lex: Lexer, source: u8[]): void;
/** Internal function `skip_one_extern_into`.
 * Implements `skip_one_extern_into`.
 * @param out *Lexer
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
function skip_one_extern_into(out: *Lexer, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_skip_one_extern_into_glue(out, lex, source);
  }
}

/* See implementation. */
extern function parser_skip_one_extern_glue(lex: Lexer, source: u8[]): Lexer;
/** Internal function `skip_one_extern`.
 * Implements `skip_one_extern`.
 * @param lex Lexer
 * @param source u8[]
 * @return Lexer
 */
function skip_one_extern(lex: Lexer, source: u8[]): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_skip_one_extern_glue(lex, source);
  }
}


/**
 * See implementation.
 * See implementation.
 */
allow(padding) struct ExternParseResult {
  next_lex: Lexer;
  name: u8[64];
  name_len: i32;
  /* See implementation. */
  return_ty_ref: i32;
  /* See implementation. */
  num_params: i32;
  /* See implementation. */
  abi_kind: i32;
  /* See implementation. */
  is_variadic: i32;
  /* 1 when extern "C" function ... { body } is detected (body-bearing extern);
   * 0 for pure declaration. Drives is_extern=0 + body parse in caller. */
  has_body: i32;
}

/** Internal function `extern_parse_pool_ptr`.
 * Implements `extern_parse_pool_ptr`.
 * @param res *ExternParseResult
 * @return *u8
 */
function extern_parse_pool_ptr(res: *ExternParseResult): *u8 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return res as *u8;
  }
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
extern function parser_write_extern_params_to_pools_glue(arena: *ASTArena, module: *Module, func_ref: i32, fi: i32, res: *ExternParseResult): void;
/**
 * See implementation.
 * See implementation.
 */
function write_extern_params_to_pools(arena: *ASTArena, module: *Module, func_ref: i32, fi: i32, res: *ExternParseResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let pool: *u8 = extern_parse_pool_ptr(res);
  let p: i32 = 0;
  while (p < res.num_params) {
    let pname32: u8[32] = [];
    pipeline_onefunc_param_name_copy32(pool, p, &pname32[0]);
    let plen: i32 = pipeline_onefunc_param_name_len(pool, p);
    let pty: i32 = pipeline_onefunc_param_type_ref(pool, p);
    pipeline_arena_func_param_write(arena, func_ref, p, &pname32[0], plen, pty);
    pipeline_module_func_param_write(module, fi, p, &pname32[0], plen, pty);
    p = p + 1;
  }
  }
}



/** Internal function `extern_parse_set_fail`.
 * Implements `extern_parse_set_fail`.
 * @param out *ExternParseResult
 * @param lex Lexer
 * @return void
 */
function extern_parse_set_fail(out: *ExternParseResult, lex: Lexer): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let empty64: u8[64] = [];
  out.next_lex = lex;
  out.name_len = -1;
  out.return_ty_ref = 0;
  out.num_params = 0;
  out.abi_kind = 0;
  out.is_variadic = 0;
  out.has_body = 0;
  let ni: i32 = 0;
  while (ni < 64) {
    out.name[ni] = empty64[ni];
    ni = ni + 1;
  }
  }
}


/* See implementation. */
/* See implementation. */
extern function parser_parse_one_extern_skip_into_glue(out: *ExternParseResult, arena: *ASTArena, lex: Lexer, source: u8[]): void;
/** Internal function `parse_one_extern_skip_into`.
 * Implements `parse_one_extern_skip_into`.
 * @param out *ExternParseResult
 * @param arena *ASTArena
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
function parse_one_extern_skip_into(out: *ExternParseResult, arena: *ASTArena, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_one_extern_skip_into_glue(out, arena, lex, source);
  }
}


/** Internal function `parse_one_extern_skip_into_buf`.
 * Implements `parse_one_extern_skip_into_buf`.
 * @param out *ExternParseResult
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
function parse_one_extern_skip_into_buf(out: *ExternParseResult, arena: *ASTArena, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_one_extern_skip_into(out, arena, lex, slice);
  }
}


/**
 * See implementation.
 * See implementation.
 */

/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
/** Internal function `module_register_arena_func`.
 * Registration helper `module_register_arena_func`.
 * @param module *Module
 * @param func_ref i32
 * @param f Func
 * @return i32
 */
function module_register_arena_func(module: *Module, func_ref: i32, f: Func): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let fi: i32 = pipeline_module_func_alloc_slot(module);
  if (fi < 0) {
    return -1;
  }
  pipeline_module_func_name_write(module, fi, &f.name[0], f.name_len);
  pipeline_module_func_set_num_params(module, fi, f.num_params);
  pipeline_module_func_set_num_generic_params(module, fi, f.num_generic_params);
  pipeline_module_func_set_return_type(module, fi, f.return_type_ref);
  pipeline_module_func_set_body_ref(module, fi, f.body_ref);
  pipeline_module_func_set_body_expr_ref(module, fi, f.body_expr_ref);
  pipeline_module_func_set_is_extern(module, fi, f.is_extern);
  pipeline_module_func_set_is_async(module, fi, f.is_async);
  pipeline_module_func_set_is_export(module, fi, module.pending_export);
  module.pending_export = 0;
      pipeline_module_func_set_is_used(module, fi, module.pending_used);
      module.pending_used = 0;
      pipeline_module_func_set_is_naked(module, fi, module.pending_naked);
      module.pending_naked = 0;
      pipeline_module_func_set_is_entry(module, fi, module.pending_entry);
      module.pending_entry = 0;
      pipeline_module_func_set_is_no_mangle(module, fi, module.pending_no_mangle);
      module.pending_no_mangle = 0;
      pipeline_module_func_set_is_interrupt(module, fi, module.pending_interrupt);
      module.pending_interrupt = 0;
  pipeline_module_func_ref_set(module, fi, func_ref);
  return fi;
  }
  return 0;  // unreachable — typeck after unsafe block
}



/* See implementation. */
/* See implementation. */
extern function parser_parse_one_extern_and_add_into_glue(arena: *ASTArena, module: *Module, lex: Lexer, source: u8[], lex_out: *Lexer): void;
/** Internal function `parse_one_extern_and_add_into`.
 * Implements `parse_one_extern_and_add_into`.
 * @param arena *ASTArena
 * @param module *Module
 * @param lex Lexer
 * @param source u8[]
 * @param lex_out *Lexer
 * @return void
 */
function parse_one_extern_and_add_into(arena: *ASTArena, module: *Module, lex: Lexer, source: u8[], lex_out: *Lexer): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_one_extern_and_add_into_glue(arena, module, lex, source, lex_out);
  }
}


/* See implementation. */
/** Internal function `skip_one_extern_into_buf`.
 * Implements `skip_one_extern_into_buf`.
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
function skip_one_extern_into_buf(out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  skip_one_extern_into(out, lex, slice);
  }
}

/** skip_one_extern_buf：parser_slice_from_buf + bl skip_one_extern。 */
function skip_one_extern_buf(lex: Lexer, data: *u8, len: i32): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return skip_one_extern(lex, slice);
  }
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
extern function parser_parse_one_extern_and_add_into_buf_glue(arena: *ASTArena, module: *Module, lex: Lexer, data: *u8, len: i32, lex_out: *Lexer): void;
/** Internal function `parse_one_extern_and_add_into_buf`.
 * Implements `parse_one_extern_and_add_into_buf`.
 * @param arena *ASTArena
 * @param module *Module
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param lex_out *Lexer
 * @return void
 */
function parse_one_extern_and_add_into_buf(arena: *ASTArena, module: *Module, lex: Lexer, data: *u8, len: i32, lex_out: *Lexer): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_one_extern_and_add_into_buf_glue(arena, module, lex, data, len, lex_out);
  }
}


/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
/* See implementation. */
allow(padding) struct TrySkipAllowResult {
  lex: Lexer;
  skipped: i32;
  _pad: u8[4];
}

/* See implementation. */
allow(padding) struct LibraryParseResult {
  ok: bool;
  _pad: u8[4];
  next_lex: Lexer;
  name: u8[64];
  name_len: i32;
  _pad_tail: u8[4];
}
/* See implementation. */
/* See implementation. */
extern function parser_lex_from_try_skip_into_glue(out: *Lexer, t: TrySkipAllowResult): void;
/** Internal function `lex_from_try_skip_into`.
 * Implements `lex_from_try_skip_into`.
 * @param out *Lexer
 * @param t TrySkipAllowResult
 * @return void
 */
function lex_from_try_skip_into(out: *Lexer, t: TrySkipAllowResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_lex_from_try_skip_into_glue(out, t);
  }
}

/* See implementation. */
/* See implementation. */
extern function parser_lex_from_library_into_glue(out: *Lexer, lib: LibraryParseResult): void;
/** Internal function `lex_from_library_into`.
 * Implements `lex_from_library_into`.
 * @param out *Lexer
 * @param lib LibraryParseResult
 * @return void
 */
function lex_from_library_into(out: *Lexer, lib: LibraryParseResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_lex_from_library_into_glue(out, lib);
  }
}

/* See implementation. */
/* See implementation. */
extern function parser_lex_from_try_skip_glue(t: TrySkipAllowResult): Lexer;
/** Internal function `lex_from_try_skip`.
 * Implements `lex_from_try_skip`.
 * @param t TrySkipAllowResult
 * @return Lexer
 */
function lex_from_try_skip(t: TrySkipAllowResult): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_lex_from_try_skip_glue(t);
  }
}

/* See implementation. */
/* See implementation. */
extern function parser_lex_from_library_glue(lib: LibraryParseResult): Lexer;
/** Internal function `lex_from_library`.
 * Implements `lex_from_library`.
 * @param lib LibraryParseResult
 * @return Lexer
 */
function lex_from_library(lib: LibraryParseResult): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_lex_from_library_glue(lib);
  }
}


/* See implementation. */
struct LibraryParseScanResult {
  ok: bool;
  _pad: u8[4];
  next_lex: Lexer;
  name: u8[64];
  name_len: i32;
  param_name: u8[32];
  param_name_len: i32;
  param_type_name: u8[64];
  param_type_len: i32;
  field_name: u8[64];
  field_len: i32;
  _pad_tail: u8[4];
  _pad_tail2: u8[4];
}

/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
extern function parser_parse_one_function_library_scan_glue(lex: Lexer, source: u8[], result: *LibraryParseScanResult): bool;
/** Internal function `parse_one_function_library_scan`.
 * Implements `parse_one_function_library_scan`.
 * @param lex Lexer
 * @param source u8[]
 * @param result *LibraryParseScanResult
 * @return bool
 */
function parse_one_function_library_scan(lex: Lexer, source: u8[], result: *LibraryParseScanResult): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_parse_one_function_library_scan_glue(lex, source, result);
  }
  return false;  // unreachable — typeck after unsafe block
}

/* See implementation. */
/* See implementation. */
extern function parser_struct_layout_name_exists_arr_glue(module: *Module, nm: u8[64], nlen: i32): bool;
/** Internal function `struct_layout_name_exists_arr`.
 * Implements `struct_layout_name_exists_arr`.
 * @param module *Module
 * @param nm u8[64]
 * @param nlen i32
 * @return bool
 */
function struct_layout_name_exists_arr(module: *Module, nm: u8[64], nlen: i32): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let k: i32 = 0;
  while (k < module.num_struct_layouts) {
    if (pipeline_module_struct_layout_name_len(module, k) == nlen && nlen > 0) {
      let ii: i32 = 0;
      let same: bool = true;
      while (ii < nlen && ii < 64) {
        if (pipeline_module_struct_layout_name_byte_at(module, k, ii) != nm[ii]) {
          same = false;
        }
        ii = ii + 1;
      }
      if (same) {
        return true;
      }
    }
    k = k + 1;
  }
  return false;
  }
  return false;  // unreachable — typeck after unsafe block
}



/* See implementation. */
/* See implementation. */
extern function parser_struct_layout_first_name_match_idx_glue(module: *Module, nm: u8[64], nlen: i32): i32;
/** Internal function `struct_layout_first_name_match_idx`.
 * Implements `struct_layout_first_name_match_idx`.
 * @param module *Module
 * @param nm u8[64]
 * @param nlen i32
 * @return i32
 */
function struct_layout_first_name_match_idx(module: *Module, nm: u8[64], nlen: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let k: i32 = 0;
  while (k < module.num_struct_layouts) {
    if (pipeline_module_struct_layout_name_len(module, k) == nlen && nlen > 0) {
      let ii: i32 = 0;
      let same: bool = true;
      while (ii < nlen && ii < 64) {
        if (pipeline_module_struct_layout_name_byte_at(module, k, ii) != nm[ii]) {
          same = false;
        }
        ii = ii + 1;
      }
      if (same) {
        return k;
      }
    }
    k = k + 1;
  }
  return -1;
  }
  return 0;  // unreachable — typeck after unsafe block
}



/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
extern function parser_struct_layout_placeholder_idx_glue(module: *Module, nm: u8[64], nlen: i32): i32;
/**
 * See implementation.
 * See implementation.
 */
function struct_layout_placeholder_idx(module: *Module, nm: u8[64], nlen: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let k: i32 = 0;
  while (k < module.num_struct_layouts) {
    if (pipeline_module_struct_layout_name_len(module, k) == nlen && nlen > 0) {
      let ii: i32 = 0;
      let same: bool = true;
      while (ii < nlen && ii < 64) {
        if (pipeline_module_struct_layout_name_byte_at(module, k, ii) != nm[ii]) {
          same = false;
        }
        ii = ii + 1;
      }
      if (same) {
        let nf: i32 = pipeline_module_struct_layout_num_fields(module, k);
        if (nf == 0) {
          return k;
        }
        if (nf == 1 && pipeline_module_struct_layout_field_name_len(module, k, 0) == 0) {
          return k;
        }
        if (nf == 1 && pipeline_module_struct_layout_field_type_ref(module, k, 0) == 0) {
          return k;
        }
      }
    }
    k = k + 1;
  }
  return -1;
  }
  return 0;  // unreachable — typeck after unsafe block
}



/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
extern function parser_parse_one_function_library_glue(arena: *ASTArena, module: *Module, lex: Lexer, source: u8[]): LibraryParseResult;
/** Internal function `parse_one_function_library`.
 * Implements `parse_one_function_library`.
 * @param arena *ASTArena
 * @param module *Module
 * @param lex Lexer
 * @param source u8[]
 * @return LibraryParseResult
 */
function parse_one_function_library(arena: *ASTArena, module: *Module, lex: Lexer, source: u8[]): LibraryParseResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_parse_one_function_library_glue(arena, module, lex, source);
  }
}


/**
 * See implementation.
 * See implementation.
 */
function parse_one_function_library_buf(arena: *ASTArena, module: *Module, lex: Lexer, data: *u8, len: i32): LibraryParseResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return parse_one_function_library(arena, module, lex, slice);
  }
}



/* See implementation. */
/* See implementation. */
extern function parser_parse_into_try_skip_allow_glue(lex: Lexer, r: LexerResult, source: u8[]): TrySkipAllowResult;
/** Internal function `parse_into_try_skip_allow`.
 * Implements `parse_into_try_skip_allow`.
 * @param lex Lexer
 * @param r LexerResult
 * @param source u8[]
 * @return TrySkipAllowResult
 */
function parse_into_try_skip_allow(lex: Lexer, r: LexerResult, source: u8[]): TrySkipAllowResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_parse_into_try_skip_allow_glue(lex, r, source);
  }
}


/** parse_into_try_skip_allow_buf：parser_slice_from_buf + bl parse_into_try_skip_allow。 */
function parse_into_try_skip_allow_buf(lex: Lexer, r: LexerResult, data: *u8, len: i32): TrySkipAllowResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return parse_into_try_skip_allow(lex, r, slice);
  }
}


/* See implementation. */
extern function parser_try_skip_allow_padding_struct_glue(lex: Lexer, source: u8[]): TrySkipAllowResult;
/** Internal function `try_skip_allow_padding_struct`.
 * Implements `try_skip_allow_padding_struct`.
 * @param lex Lexer
 * @param source u8[]
 * @return TrySkipAllowResult
 */
function try_skip_allow_padding_struct(lex: Lexer, source: u8[]): TrySkipAllowResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_try_skip_allow_padding_struct_glue(lex, source);
  }
}


/** try_skip_allow_padding_struct_buf：parser_slice_from_buf + bl try_skip_allow_padding_struct。 */
function try_skip_allow_padding_struct_buf(lex: Lexer, data: *u8, len: i32): TrySkipAllowResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return try_skip_allow_padding_struct(lex, slice);
  }
}


/** Internal function `skip_one_struct_into_buf`.
 * Implements `skip_one_struct_into_buf`.
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
function skip_one_struct_into_buf(out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  skip_one_struct_into(out, lex, slice);
  }
}

/** skip_one_struct_buf：parser_slice_from_buf + bl skip_one_struct。 */
function skip_one_struct_buf(lex: Lexer, data: *u8, len: i32): Lexer {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return skip_one_struct(lex, slice);
  }
}


/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
/* See implementation. */
extern function parser_consume_qualified_type_ident_name_glue(source: u8[], r: *LexerResult, out: *u8, out_len: *i32): i32;
/** Internal function `consume_qualified_type_ident_name`.
 * Implements `consume_qualified_type_ident_name`.
 * @param source u8[]
 * @param r *LexerResult
 * @param out *u8
 * @param out_len *i32
 * @return i32
 */
function consume_qualified_type_ident_name(source: u8[], r: *LexerResult, out: *u8, out_len: *i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_consume_qualified_type_ident_name_glue(source, r, out, out_len);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/** Internal function `consume_qualified_type_ident_name_buf`.
 * Implements `consume_qualified_type_ident_name_buf`.
 * @param data *u8
 * @param len i32
 * @param r *LexerResult
 * @param out *u8
 * @param out_len *i32
 * @return i32
 */
function consume_qualified_type_ident_name_buf(data: *u8, len: i32, r: *LexerResult, out: *u8, out_len: *i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return consume_qualified_type_ident_name(slice, r, out, out_len);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/**
 * See implementation.
 * See implementation.
 */
function is_pointee_type_token(kind: token.TokenKind): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  if (kind == token.TokenKind.TOKEN_IDENT) {
    return true;
  }
  if (kind == token.TokenKind.TOKEN_I32 || kind == token.TokenKind.TOKEN_I64 || kind == token.TokenKind.TOKEN_BOOL) {
    return true;
  }
  if (kind == token.TokenKind.TOKEN_U8 || kind == token.TokenKind.TOKEN_U32 || kind == token.TokenKind.TOKEN_U64) {
    return true;
  }
  if (kind == token.TokenKind.TOKEN_USIZE || kind == token.TokenKind.TOKEN_ISIZE || kind == token.TokenKind.TOKEN_VOID) {
    return true;
  }
  if (kind == token.TokenKind.TOKEN_F32 || kind == token.TokenKind.TOKEN_F64) {
    return true;
  }
  return false;
  }
}



/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
extern function parser_alloc_pointee_type_ref_from_tok_glue(arena: *ASTArena, source: u8[], r: *LexerResult): i32;
/** Internal function `alloc_pointee_type_ref_from_tok`.
 * Memory management helper `alloc_pointee_type_ref_from_tok`.
 * @param arena *ASTArena
 * @param source u8[]
 * @param r *LexerResult
 * @return i32
 */
function alloc_pointee_type_ref_from_tok(arena: *ASTArena, source: u8[], r: *LexerResult): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_alloc_pointee_type_ref_from_tok_glue(arena, source, r);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/**
 * See implementation.
 */
/* See implementation. */
extern function parser_parser_alloc_vector_type_ref_glue(arena: *ASTArena, elem_ord: i32, lanes: i32): i32;
/**
 * See implementation.
 */
function parser_alloc_vector_type_ref(arena: *ASTArena, elem_ord: i32, lanes: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let elem_tr_v: i32 = pipeline_type_ensure_by_kind_ord(arena, elem_ord);
  let vec_ref: i32 = 0;
  if (elem_tr_v == 0) {
    return 0;
  }
  vec_ref = ast.ast_arena_type_alloc(arena);
  if (vec_ref != 0) {
    let tv: Type = ast.ast_arena_type_get(arena, vec_ref);
    tv.kind = TypeKind.TYPE_VECTOR;
    tv.elem_type_ref = elem_tr_v;
    tv.array_size = lanes;
    tv.name_len = 0;
    ast.ast_arena_type_set(arena, vec_ref, tv);
  }
  return vec_ref;
  }
  return 0;  // unreachable — typeck after unsafe block
}



/**
 * See implementation.
 */
/* See implementation. */
extern function parser_parser_vector_type_ref_from_ident_spelling_glue(arena: *ASTArena, source: u8[], r: LexerResult): i32;
/** Internal function `parser_vector_type_ref_from_ident_spelling`.
 * Implements `parser_vector_type_ref_from_ident_spelling`.
 * @param arena *ASTArena
 * @param source u8[]
 * @param r LexerResult
 * @return i32
 */
function parser_vector_type_ref_from_ident_spelling(arena: *ASTArena, source: u8[], r: LexerResult): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_parser_vector_type_ref_from_ident_spelling_glue(arena, source, r);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_struct_record_layout_into_glue(arena: *ASTArena, module: *Module, lex: Lexer, source: u8[], out_lex: *Lexer, allow_pad: i32, force_soa: i32, repr_compat: i32): i32;
/** Exported function `parse_struct_record_layout_into`.
 * Implements `parse_struct_record_layout_into`.
 * @param arena *ASTArena
 * @param module *Module
 * @param lex Lexer
 * @param source u8[]
 * @param out_lex *Lexer
 * @param allow_pad i32
 * @param force_soa i32
 * @param repr_compat i32
 * @return i32
 */
export function parse_struct_record_layout_into(arena: *ASTArena, module: *Module, lex: Lexer, source: u8[], out_lex: *Lexer, allow_pad: i32, force_soa: i32, repr_compat: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_parse_struct_record_layout_into_glue(arena, module, lex, source, out_lex, allow_pad, force_soa, repr_compat);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
/* See implementation. */
/* See implementation. */
export extern function parser_parse_one_function_buf_into_glue(out: *OneFuncResult, arena: *ASTArena, lex: Lexer, data: *u8, len: i32): void;
/** Exported function `parse_one_function_buf_into`.
 * Implements `parse_one_function_buf_into`.
 * @param out *OneFuncResult
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
export function parse_one_function_buf_into(out: *OneFuncResult, arena: *ASTArena, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_one_function_buf_into_glue(out, arena, lex, data, len);
  }
}


/* See implementation. */
/* See implementation. */
export extern function parser_parse_one_function_library_into_glue(out: *LibraryParseResult, arena: *ASTArena, module: *Module, lex: Lexer, source: u8[]): void;
/** Exported function `parse_one_function_library_into`.
 * Implements `parse_one_function_library_into`.
 * @param out *LibraryParseResult
 * @param arena *ASTArena
 * @param module *Module
 * @param lex Lexer
 * @param source u8[]
 * @return void
 */
export function parse_one_function_library_into(out: *LibraryParseResult, arena: *ASTArena, module: *Module, lex: Lexer, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_one_function_library_into_glue(out, arena, module, lex, source);
  }
}


/**
 * See implementation.
 */
export function parse_one_function_library_into_buf(out: *LibraryParseResult, arena: *ASTArena, module: *Module, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_one_function_library_into(out, arena, module, lex, slice);
  }
}


/* See implementation. */
/* See implementation. */
export extern function parser_parse_into_try_skip_allow_into_glue(out: *TrySkipAllowResult, lex: Lexer, r: LexerResult, source: u8[]): void;
/** Exported function `parse_into_try_skip_allow_into`.
 * Implements `parse_into_try_skip_allow_into`.
 * @param out *TrySkipAllowResult
 * @param lex Lexer
 * @param r LexerResult
 * @param source u8[]
 * @return void
 */
export function parse_into_try_skip_allow_into(out: *TrySkipAllowResult, lex: Lexer, r: LexerResult, source: u8[]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_into_try_skip_allow_into_glue(out, lex, r, source);
  }
}


/** Exported function `parse_into_try_skip_allow_into_buf`.
 * Implements `parse_into_try_skip_allow_into_buf`.
 * @param out *TrySkipAllowResult
 * @param lex Lexer
 * @param r LexerResult
 * @param data *u8
 * @param len i32
 * @return void
 */
export function parse_into_try_skip_allow_into_buf(out: *TrySkipAllowResult, lex: Lexer, r: LexerResult, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_into_try_skip_allow_into(out, lex, r, slice);
  }
}


/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function parse_into(arena: *ASTArena, module: *Module, source: u8[]): ParseIntoResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  /* See implementation. */
  let lex: Lexer = lexer.lexer_init();
  let main_idx: i32 = -1;
  /* See implementation. */
  let import_res: CollectImportsResult = CollectImportsResult { lex: lex };
  collect_imports(lex, source, module, &import_res);
  copy_lex_from_import_into(&lex, import_res);
  let loop_count: i32 = 0;
  while (1 == 1) {
    /* See implementation. */
    if (loop_count >= 131072) {
      return ParseIntoResult { ok: -1, main_idx: -1003 }
    }
    loop_count = loop_count + 1;
    let iter_start: Lexer = lex;
    /* See implementation. */
    let r: LexerResult = LexerResult { next_lex: lex, tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 }, token_start: 0 };
    let current_tok_lex: Lexer = lex;
    lexer.lexer_next_into(&r, lex, source);
    lex_from_next_into(&lex, r);
    let func_is_async_storage: i32[1] = [];
    func_is_async_storage[0] = 0;
    if (r.tok.kind == token.TokenKind.TOKEN_ASYNC) {
      func_is_async_storage[0] = 1;
      lex_from_next_into(&lex, r);
      current_tok_lex = lex;
      lexer.lexer_next_into(&r, lex, source);
      lex_from_next_into(&lex, r);
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_SOA) {
      module.pending_soa_struct = 1;
      lex_from_next_into(&lex, r);
      if (lex.pos == iter_start.pos && lex.pos < source.length) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_CFG) {
      if (r.tok.int_val == 0) { module.pending_cfg_skip = 1; }
      lex_from_next_into(&lex, r);
      if (lex.pos == iter_start.pos && lex.pos < source.length) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_REPR_C) {
      module.pending_repr_c_struct = 1;
      lex_from_next_into(&lex, r);
      if (lex.pos == iter_start.pos && lex.pos < source.length) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_REPR_COMPATIBLE) {
      module.pending_repr_compatible_struct = 1;
      lex_from_next_into(&lex, r);
      if (lex.pos == iter_start.pos && lex.pos < source.length) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_ALLOC) {
      lex_from_next_into(&lex, r);
      if (lex.pos == iter_start.pos && lex.pos < source.length) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_USED) {
      module.pending_used = 1;
      lex_from_next_into(&lex, r);
      if (lex.pos == iter_start.pos && lex.pos < source.length) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_NAKED) {
      module.pending_naked = 1; lex_from_next_into(&lex, r);
      if (lex.pos == iter_start.pos && lex.pos < source.length) { lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 }; }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_ENTRY) {
      module.pending_entry = 1; lex_from_next_into(&lex, r);
      if (lex.pos == iter_start.pos && lex.pos < source.length) { lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 }; }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_NO_MANGLE) {
      module.pending_no_mangle = 1; lex_from_next_into(&lex, r);
      if (lex.pos == iter_start.pos && lex.pos < source.length) { lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 }; }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_INTERRUPT) {
      module.pending_interrupt = 1; lex_from_next_into(&lex, r);
      if (lex.pos == iter_start.pos && lex.pos < source.length) { lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 }; }
      continue;
    }
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_EXPORT) {
      module.pending_export = 1;
      lex_from_next_into(&lex, r);
      if (lex.pos == iter_start.pos && lex.pos < source.length) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (module.pending_cfg_skip != 0) {
      if (r.tok.kind == token.TokenKind.TOKEN_STRUCT) {
        skip_one_struct_into(&lex, iter_start, source);
        module.pending_cfg_skip = 0;
        module.pending_export = 0;
        if (lex.pos == iter_start.pos && lex.pos < source.length) {
          lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
        }
        continue;
      }
      if (r.tok.kind == token.TokenKind.TOKEN_CONST) {
        skip_one_top_level_const_into(&lex, iter_start, source);
        module.pending_cfg_skip = 0;
        module.pending_export = 0;
        if (lex.pos == iter_start.pos && lex.pos < source.length) {
          lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
        }
        continue;
      }
      if (r.tok.kind == token.TokenKind.TOKEN_LET) {
        skip_one_top_level_let_into(&lex, iter_start, source);
        module.pending_cfg_skip = 0;
        module.pending_export = 0;
        if (lex.pos == iter_start.pos && lex.pos < source.length) {
          lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
        }
        continue;
      }
      if (r.tok.kind == token.TokenKind.TOKEN_FUNCTION || func_is_async_storage[0] != 0 ||
          r.tok.kind == token.TokenKind.TOKEN_EXTERN) {
        skip_one_function_full_into(&lex, iter_start, source);
        module.pending_cfg_skip = 0;
        module.pending_export = 0;
        func_is_async_storage[0] = 0;
        if (lex.pos == iter_start.pos && lex.pos < source.length) {
          lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
        }
        continue;
      }
      /*
       * See implementation.
       * See implementation.
       * See implementation.
       * See implementation.
       */
      {
        let try_cfg_allow: TrySkipAllowResult = TrySkipAllowResult { lex: lex, skipped: 0, _pad: [] };
        parse_into_try_skip_allow_into(&try_cfg_allow, lex, r, source);
        if (try_cfg_allow.skipped != 0) {
          lex_from_try_skip_into(&lex, try_cfg_allow);
          if (lex.pos == iter_start.pos && lex.pos < source.length) {
            lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
          }
          continue;
        }
      }
      module.pending_cfg_skip = 0;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_STRUCT) {
      let ap_struct: i32 = module.pending_allow_padding;
      let ps_struct: i32 = module.pending_soa_struct;
      let pr_struct: i32 = module.pending_repr_c_struct;
      let pc_struct: i32 = module.pending_repr_compatible_struct;
      let pe_struct: i32 = module.pending_export;
      module.pending_allow_padding = 0;
      module.pending_soa_struct = 0;
      module.pending_repr_c_struct = 0;
      module.pending_repr_compatible_struct = 0;
      module.pending_export = 0;
      let allow_for_repr: i32 = ap_struct;
      if (pr_struct != 0) {
        allow_for_repr = 1;
      }
      let nsl_before: i32 = module.num_struct_layouts;
      if (parse_struct_record_layout_into(arena, module, lex, source, &lex, allow_for_repr, ps_struct, pc_struct) != 0) {
        skip_one_struct_into(&lex, iter_start, source);
      } else if (pe_struct != 0 && module.num_struct_layouts > nsl_before) {
        pipeline_module_struct_layout_set_is_export(module, module.num_struct_layouts - 1, 1);
      }
      if (lex.pos == iter_start.pos && lex.pos < source.length) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ENUM) {
      let pe_enum: i32 = module.pending_export;
      module.pending_export = 0;
      let nen_before: i32 = module.num_module_enums;
      skip_one_enum_register_into(module, &lex, iter_start, source);
      if (pe_enum != 0 && module.num_module_enums > nen_before) {
        pipeline_module_enum_set_is_export(module, module.num_module_enums - 1, 1);
      }
      if (lex.pos == iter_start.pos && lex.pos < source.length) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_EXTERN) {
      let num_funcs_before_extern: i32 = module.num_funcs;
      parse_one_extern_and_add_into(arena, module, iter_start, source, &lex);
      /* Body-bearing extern (`extern "C" function ... { body }`): C seed set is_extern=0
       * and left lex BEFORE '{'. Parse body via parse_block_into and set body_ref so
       * codegen emits the body. Pure decl (is_extern=1) skips this branch. */
      if (module.num_funcs > num_funcs_before_extern) {
        let fi_ext: i32 = num_funcs_before_extern;
        if (pipeline_module_func_is_extern_at(module, fi_ext) == 0) {
          let r_brace: LexerResult = LexerResult { next_lex: lex, tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 }, token_start: 0 };
          lexer.lexer_next_into(&r_brace, lex, source);
          if (r_brace.tok.kind == token.TokenKind.TOKEN_LBRACE) {
            let type_ref_extern: i32 = pipeline_module_func_return_type_at(module, fi_ext);
            let block_res_extern: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: r_brace.next_lex };
            parse_block_into(arena, r_brace.next_lex, source, type_ref_extern, &block_res_extern);
            if (block_res_extern.ok) {
              pipeline_module_func_set_body_ref(module, fi_ext, block_res_extern.block_ref);
              lex = block_res_extern.next_lex;
            } else {
              skip_balanced_braces_into(&lex, lex, source);
            }
          }
        }
      }
      if (lex.pos == iter_start.pos && lex.pos < source.length) {
        skip_one_extern_into(&lex, lex, source);
      }
      if (lex.pos == iter_start.pos && lex.pos < source.length) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_TRAIT) {
      skip_one_trait_into(&lex, iter_start, source);
      if (lex.pos == iter_start.pos && lex.pos < source.length) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_IMPL) {
      skip_one_impl_into(&lex, iter_start, source);
      if (lex.pos == iter_start.pos && lex.pos < source.length) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (r.tok.kind != token.TokenKind.TOKEN_FUNCTION) {
      let try_res: TrySkipAllowResult = TrySkipAllowResult { lex: lex, skipped: 0, _pad: [] };
      parse_into_try_skip_allow_into(&try_res, lex, r, source);
      if (try_res.skipped != 0) {
        module.pending_allow_padding = 1;
        lex_from_try_skip_into(&lex, try_res);
        if (lex.pos == iter_start.pos && lex.pos < source.length) {
          lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
        }
        continue;
      }
      /* See implementation. */
      if (r.tok.kind == token.TokenKind.TOKEN_EOF) {
        break;
      }
      lex_from_next_into(&lex, r);
      continue;
    }
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_EOF) {
      if (module.num_funcs == 0) {
        return parse_into_result_empty_module_or_fail_tok(diag_fail_at_token_kind(source));
      }
      let out_idx_storage: i32[1] = [];
      out_idx_storage[0] = main_idx;
      return ParseIntoResult { ok: 0, main_idx: out_idx_storage[0] }
    }
    /*
     * See implementation.
     * PLATFORM: SHARED
     */
    let lex_at_function: Lexer = lexer.lexer_init();
    lex_at_function = current_tok_lex;
    lex_from_next_into(&lex, r);
    let parse_into_empty64: u8[64] = [];
    let res: OneFuncResult = onefunc_scratch_empty();
    res = onefunc_scratch_empty();
    onefunc_res_wire_dummy_head(&res, lex, parse_into_empty64);
    onefunc_res_wire_dummy_const_let(&res);
    onefunc_res_wire_dummy_if_mul(&res);
    onefunc_res_wire_dummy_call_binop(&res, parse_into_empty64);
    onefunc_res_wire_dummy_loop_call(&res);
    onefunc_res_wire_dummy_for_if(&res);
    /* See implementation. */
    let empty64_lib_first: u8[64] = [];
    let lib_first: LibraryParseResult = LibraryParseResult { ok: false, _pad: [], next_lex: lex_at_function, name: empty64_lib_first, name_len: 0, _pad_tail: [] };
    lib_first = LibraryParseResult { ok: false, _pad: [], next_lex: lex_at_function, name: empty64_lib_first, name_len: 0, _pad_tail: [] };
    parse_one_function_library_into(&lib_first, arena, module, lex_at_function, source);
    if (lib_first.ok) {
      lex_from_library_into(&lex, lib_first);
      if (lex.pos == lex_at_function.pos && lex.pos < source.length) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    parse_one_function_impl(&res, arena, lex, source);
    if (!res.ok) {
      return ParseIntoResult { ok: -2, main_idx: -1 };
    }
    /* See implementation. */
    let is_main_storage: i32[1] = [];
    if (res.name_len == 4 && res.name[0] == 109 && res.name[1] == 97 && res.name[2] == 105 && res.name[3] == 110) {
      is_main_storage[0] = 1;
    }
    parser_diagnostic_parse_func_generic((lex_at_function.pos) as i32, module.num_funcs, &res.name[0], res.name_len,
      res.num_generic_params, is_main_storage[0]);
    /* See implementation. */
    let type_ref: i32 = 0;
    type_ref = res.func_return_type_ref;
    if (type_ref == 0) {
      type_ref = ast.ast_arena_type_alloc(arena);
      if (type_ref == 0 && module.num_funcs == 0) {
        ast.ast_arena_init(arena);
        type_ref = ast.ast_arena_type_alloc(arena);
      }
      if (type_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1001 }
      }
      let t_fb: Type = ast.ast_arena_type_get(arena, type_ref);
      t_fb.kind = TypeKind.TYPE_I32;
      t_fb.name_len = 0;
      t_fb.elem_type_ref = 0;
      t_fb.array_size = 0;
      ast.ast_arena_type_set(arena, type_ref, t_fb);
    }

    let expr_ref: i32 = 0;
    expr_ref = ast.ast_arena_expr_alloc(arena);
    if (expr_ref == 0) {
      return ParseIntoResult { ok: -1, main_idx: -1002 }
    }
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    e = ast.ast_arena_expr_get(arena, expr_ref);
    /* See implementation. */
    if (res.return_var_name_len > 0) {
      e.kind = ExprKind.EXPR_VAR;
      e.var_name_len = res.return_var_name_len;
      let rvi: i32 = 0;
      while (rvi < res.return_var_name_len && rvi < 64) {
        e.var_name[rvi] = res.return_var_name[rvi];
        rvi = rvi + 1;
      }
      let rvz: u8 = (0 as u8);
      while (rvi < 64) { e.var_name[rvi] = rvz; rvi = rvi + 1; }
      e.int_val = 0;
      e.resolved_type_ref = 0;
    } else {
      e.kind = ExprKind.EXPR_LIT;
      e.resolved_type_ref = type_ref;
      e.int_val = res.return_val;
    }
    e.line = 0;
    e.col = 0;
    e.binop_left_ref = 0;
    e.binop_right_ref = 0;
    e.unary_operand_ref = 0;
    e.if_cond_ref = 0;
    e.if_then_ref = 0;
    e.if_else_ref = 0;
    e.block_ref = 0;
    e.match_matched_ref = 0;
    e.match_num_arms = 0;
    ast.expr_init_match_enum(&e);
    e.field_access_base_ref = 0;
    e.field_access_field_len = 0;
    e.field_access_is_enum_variant = 0;
    e.field_access_offset = 0;
    e.index_base_ref = 0;
    e.index_index_ref = 0;
    e.index_base_is_slice = 0;
    e.call_callee_ref = 0;
    e.call_num_args = 0;
    e.method_call_base_ref = 0;
    e.method_call_name_len = 0;
    e.method_call_num_args = 0;
    e.const_folded_val = 0;
    e.const_folded_valid = 0;
    e.index_proven_in_bounds = 0;
    ast.ast_arena_expr_set(arena, expr_ref, e);

    /* See implementation. */
    let allow_legacy_tail_expr: bool = false;
    allow_legacy_tail_expr = res.has_final_expr || res.has_explicit_return_kw
      || res.return_expr_ref != 0 || res.return_var_name_len > 0;
    let final_expr_ref: i32 = 0;
    if (allow_legacy_tail_expr) {
      final_expr_ref = expr_ref;
    }
    if (res.return_expr_ref != 0) {
      final_expr_ref = res.return_expr_ref;
    }
    /* See implementation. */
    if (res.return_var_name_len > 0 && res.return_expr_ref == 0) {
      let var_wrapped: i32 = parser_expr_wrap_in_return(arena, type_ref, final_expr_ref);
      if (var_wrapped == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1003 }
      }
      final_expr_ref = var_wrapped;
    }
    if (res.has_mul && !res.has_binop) {
      let mul_right_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (mul_right_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      let mre: Expr = ast.ast_arena_expr_get(arena, mul_right_ref);
      mre.kind = ExprKind.EXPR_LIT;
      mre.resolved_type_ref = type_ref;
      mre.line = 0;
      mre.col = 0;
      mre.int_val = res.mul_right_val;
      mre.binop_left_ref = 0;
      mre.binop_right_ref = 0;
      mre.unary_operand_ref = 0;
      mre.if_cond_ref = 0;
      mre.if_then_ref = 0;
      mre.if_else_ref = 0;
      mre.block_ref = 0;
      mre.match_matched_ref = 0;
      mre.match_num_arms = 0;
      ast.expr_init_match_enum(&mre);
      mre.field_access_base_ref = 0;
      mre.field_access_field_len = 0;
      mre.field_access_is_enum_variant = 0;
      mre.field_access_offset = 0;
      mre.index_base_ref = 0;
      mre.index_index_ref = 0;
      mre.index_base_is_slice = 0;
      mre.call_callee_ref = 0;
      mre.call_num_args = 0;
      mre.method_call_base_ref = 0;
      mre.method_call_name_len = 0;
      mre.method_call_num_args = 0;
      mre.const_folded_val = 0;
      mre.const_folded_valid = 0;
      mre.index_proven_in_bounds = 0;
      ast.ast_arena_expr_set(arena, mul_right_ref, mre);
      let mul_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (mul_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      let me: Expr = ast.ast_arena_expr_get(arena, mul_ref);
      me.kind = ExprKind.EXPR_MUL;
      me.resolved_type_ref = type_ref;
      me.line = 0;
      me.col = 0;
      me.int_val = 0;
      me.binop_left_ref = final_expr_ref;
      me.binop_right_ref = mul_right_ref;
      me.unary_operand_ref = 0;
      me.if_cond_ref = 0;
      me.if_then_ref = 0;
      me.if_else_ref = 0;
      me.block_ref = 0;
      me.match_matched_ref = 0;
      me.match_num_arms = 0;
      ast.expr_init_match_enum(&me);
      me.field_access_base_ref = 0;
      me.field_access_field_len = 0;
      me.field_access_is_enum_variant = 0;
      me.field_access_offset = 0;
      me.index_base_ref = 0;
      me.index_index_ref = 0;
      me.index_base_is_slice = 0;
      me.call_callee_ref = 0;
      me.call_num_args = 0;
      me.method_call_base_ref = 0;
      me.method_call_name_len = 0;
      me.method_call_num_args = 0;
      me.const_folded_val = 0;
      me.const_folded_valid = 0;
      me.index_proven_in_bounds = 0;
      ast.ast_arena_expr_set(arena, mul_ref, me);
      final_expr_ref = mul_ref;
    }
    if (res.has_if_expr) {
      let cond_ref: i32 = 0;
      if (res.if_cond_expr_ref != 0) {
        cond_ref = res.if_cond_expr_ref;
      } else {
      let bool_type_ref: i32 = ast.ast_arena_type_alloc(arena);
      if (bool_type_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1005 }
      }
      let bt: Type = ast.ast_arena_type_get(arena, bool_type_ref);
      bt.kind = TypeKind.TYPE_BOOL;
      bt.name_len = 0;
      bt.elem_type_ref = 0;
      bt.array_size = 0;
      ast.ast_arena_type_set(arena, bool_type_ref, bt);
      cond_ref = ast.ast_arena_expr_alloc(arena);
      if (cond_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      let ce: Expr = ast.ast_arena_expr_get(arena, cond_ref);
      ce.kind = ExprKind.EXPR_BOOL_LIT;
      ce.resolved_type_ref = bool_type_ref;
      ce.line = 0;
      ce.col = 0;
      if (res.if_cond_true) {
        ce.int_val = 1;
      } else {
        ce.int_val = 0;
      }
      ce.binop_left_ref = 0;
      ce.binop_right_ref = 0;
      ce.unary_operand_ref = 0;
      ce.if_cond_ref = 0;
      ce.if_then_ref = 0;
      ce.if_else_ref = 0;
      ce.block_ref = 0;
      ce.match_matched_ref = 0;
      ce.match_num_arms = 0;
      ast.expr_init_match_enum(&ce);
      ce.field_access_base_ref = 0;
      ce.field_access_field_len = 0;
      ce.field_access_is_enum_variant = 0;
      ce.field_access_offset = 0;
      ce.index_base_ref = 0;
      ce.index_index_ref = 0;
      ce.index_base_is_slice = 0;
      ce.call_callee_ref = 0;
      ce.call_num_args = 0;
      ce.method_call_base_ref = 0;
      ce.method_call_name_len = 0;
      ce.method_call_num_args = 0;
      ce.const_folded_val = 0;
      ce.const_folded_valid = 0;
      ce.index_proven_in_bounds = 0;
      ast.ast_arena_expr_set(arena, cond_ref, ce);
      }
      let then_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (then_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      let te: Expr = ast.ast_arena_expr_get(arena, then_ref);
      te.kind = ExprKind.EXPR_LIT;
      te.resolved_type_ref = type_ref;
      te.line = 0;
      te.col = 0;
      te.int_val = res.if_then_val;
      te.binop_left_ref = 0;
      te.binop_right_ref = 0;
      te.unary_operand_ref = 0;
      te.if_cond_ref = 0;
      te.if_then_ref = 0;
      te.if_else_ref = 0;
      te.block_ref = 0;
      te.match_matched_ref = 0;
      te.match_num_arms = 0;
      ast.expr_init_match_enum(&te);
      te.field_access_base_ref = 0;
      te.field_access_field_len = 0;
      te.field_access_is_enum_variant = 0;
      te.field_access_offset = 0;
      te.index_base_ref = 0;
      te.index_index_ref = 0;
      te.index_base_is_slice = 0;
      te.call_callee_ref = 0;
      te.call_num_args = 0;
      te.method_call_base_ref = 0;
      te.method_call_name_len = 0;
      te.method_call_num_args = 0;
      te.const_folded_val = 0;
      te.const_folded_valid = 0;
      te.index_proven_in_bounds = 0;
      ast.ast_arena_expr_set(arena, then_ref, te);
      let else_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (else_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      let ee: Expr = ast.ast_arena_expr_get(arena, else_ref);
      ee.kind = ExprKind.EXPR_LIT;
      ee.resolved_type_ref = type_ref;
      ee.line = 0;
      ee.col = 0;
      ee.int_val = res.if_else_val;
      ee.binop_left_ref = 0;
      ee.binop_right_ref = 0;
      ee.unary_operand_ref = 0;
      ee.if_cond_ref = 0;
      ee.if_then_ref = 0;
      ee.if_else_ref = 0;
      ee.block_ref = 0;
      ee.match_matched_ref = 0;
      ee.match_num_arms = 0;
      ast.expr_init_match_enum(&ee);
      ee.field_access_base_ref = 0;
      ee.field_access_field_len = 0;
      ee.field_access_is_enum_variant = 0;
      ee.field_access_offset = 0;
      ee.index_base_ref = 0;
      ee.index_index_ref = 0;
      ee.index_base_is_slice = 0;
      ee.call_callee_ref = 0;
      ee.call_num_args = 0;
      ee.method_call_base_ref = 0;
      ee.method_call_name_len = 0;
      ee.method_call_num_args = 0;
      ee.const_folded_val = 0;
      ee.const_folded_valid = 0;
      ee.index_proven_in_bounds = 0;
      ast.ast_arena_expr_set(arena, else_ref, ee);
      let if_expr_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (if_expr_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      let ie: Expr = ast.ast_arena_expr_get(arena, if_expr_ref);
      ie.kind = ExprKind.EXPR_IF;
      ie.resolved_type_ref = type_ref;
      ie.line = 0;
      ie.col = 0;
      ie.int_val = 0;
      ie.binop_left_ref = 0;
      ie.binop_right_ref = 0;
      ie.unary_operand_ref = 0;
      ie.if_cond_ref = cond_ref;
      ie.if_then_ref = then_ref;
      ie.if_else_ref = else_ref;
      ie.block_ref = 0;
      ie.match_matched_ref = 0;
      ie.match_num_arms = 0;
      ast.expr_init_match_enum(&ie);
      ie.field_access_base_ref = 0;
      ie.field_access_field_len = 0;
      ie.field_access_is_enum_variant = 0;
      ie.field_access_offset = 0;
      ie.index_base_ref = 0;
      ie.index_index_ref = 0;
      ie.index_base_is_slice = 0;
      ie.call_callee_ref = 0;
      ie.call_num_args = 0;
      ie.method_call_base_ref = 0;
      ie.method_call_name_len = 0;
      ie.method_call_num_args = 0;
      ie.const_folded_val = 0;
      ie.const_folded_valid = 0;
      ie.index_proven_in_bounds = 0;
      ast.ast_arena_expr_set(arena, if_expr_ref, ie);
      final_expr_ref = if_expr_ref;
    }
    /*
     * See implementation.
     * See implementation.
     * See implementation.
     */
    if (res.return_expr_ref == 0) {
      if (res.has_binop || res.binop_right_val != 0) {
      let res_pool: *u8 = onefunc_result_pool_ptr(&res);
      let left_ref: i32 = final_expr_ref;
      if (res.binop_left_param_idx >= 0 && res.binop_left_param_idx < res.num_params) {
        let left_param_type_ref: i32 = pipeline_onefunc_param_type_ref(res_pool, res.binop_left_param_idx);
        let lpr: i32 = ast.ast_arena_expr_alloc(arena);
        if (lpr != 0) {
          let lpe: Expr = ast.ast_arena_expr_get(arena, lpr);
          lpe.kind = ExprKind.EXPR_VAR;
          lpe.resolved_type_ref = left_param_type_ref;
          lpe.line = 0;
          lpe.col = 0;
          lpe.var_name_len = pipeline_onefunc_param_name_len(res_pool, res.binop_left_param_idx);
          let lk: i32 = 0;
          while (lk < lpe.var_name_len && lk < 64) {
            lpe.var_name[lk] = pipeline_onefunc_param_name_byte_at(res_pool, res.binop_left_param_idx, lk);
            lk = lk + 1;
          }
          let lz: u8 = (0 as u8);
          while (lk < 64) { lpe.var_name[lk] = lz; lk = lk + 1; }
          driver_diagnostic_parser_onefunc_param_ref(&res.name[0], res.name_len, &lpe.var_name[0], lpe.var_name_len,
          1, res.binop_left_param_idx, left_param_type_ref);
          lpe.binop_left_ref = 0;
          lpe.binop_right_ref = 0;
          lpe.unary_operand_ref = 0;
          lpe.if_cond_ref = 0;
          lpe.if_then_ref = 0;
          lpe.if_else_ref = 0;
          lpe.block_ref = 0;
          lpe.match_matched_ref = 0;
          lpe.match_num_arms = 0;
          ast.expr_init_match_enum(&lpe);
          lpe.field_access_base_ref = 0;
          lpe.field_access_field_len = 0;
          lpe.field_access_is_enum_variant = 0;
          lpe.field_access_offset = 0;
          lpe.index_base_ref = 0;
          lpe.index_index_ref = 0;
          lpe.index_base_is_slice = 0;
          lpe.call_callee_ref = 0;
          lpe.call_num_args = 0;
          lpe.method_call_base_ref = 0;
          lpe.method_call_name_len = 0;
          lpe.method_call_num_args = 0;
          lpe.const_folded_val = 0;
          lpe.const_folded_valid = 0;
          lpe.index_proven_in_bounds = 0;
          ast.ast_arena_expr_set(arena, lpr, lpe);
          left_ref = lpr;
        }
      }
      let right_ref: i32 = 0;
      if (res.binop_right_param_idx >= 0 && res.binop_right_param_idx < res.num_params) {
        let right_param_type_ref: i32 = pipeline_onefunc_param_type_ref(res_pool, res.binop_right_param_idx);
        let rpr: i32 = ast.ast_arena_expr_alloc(arena);
        if (rpr != 0) {
          let rpe: Expr = ast.ast_arena_expr_get(arena, rpr);
          rpe.kind = ExprKind.EXPR_VAR;
          rpe.resolved_type_ref = right_param_type_ref;
          rpe.line = 0;
          rpe.col = 0;
          rpe.var_name_len = pipeline_onefunc_param_name_len(res_pool, res.binop_right_param_idx);
          let rk: i32 = 0;
          while (rk < rpe.var_name_len && rk < 64) {
            rpe.var_name[rk] = pipeline_onefunc_param_name_byte_at(res_pool, res.binop_right_param_idx, rk);
            rk = rk + 1;
          }
          let rz: u8 = (0 as u8);
          while (rk < 64) { rpe.var_name[rk] = rz; rk = rk + 1; }
          driver_diagnostic_parser_onefunc_param_ref(&res.name[0], res.name_len, &rpe.var_name[0], rpe.var_name_len,
          2, res.binop_right_param_idx, right_param_type_ref);
          rpe.binop_left_ref = 0;
          rpe.binop_right_ref = 0;
          rpe.unary_operand_ref = 0;
          rpe.if_cond_ref = 0;
          rpe.if_then_ref = 0;
          rpe.if_else_ref = 0;
          rpe.block_ref = 0;
          rpe.match_matched_ref = 0;
          rpe.match_num_arms = 0;
          ast.expr_init_match_enum(&rpe);
          rpe.field_access_base_ref = 0;
          rpe.field_access_field_len = 0;
          rpe.field_access_is_enum_variant = 0;
          rpe.field_access_offset = 0;
          rpe.index_base_ref = 0;
          rpe.index_index_ref = 0;
          rpe.index_base_is_slice = 0;
          rpe.call_callee_ref = 0;
          rpe.call_num_args = 0;
          rpe.method_call_base_ref = 0;
          rpe.method_call_name_len = 0;
          rpe.method_call_num_args = 0;
          rpe.const_folded_val = 0;
          rpe.const_folded_valid = 0;
          rpe.index_proven_in_bounds = 0;
          ast.ast_arena_expr_set(arena, rpr, rpe);
          right_ref = rpr;
        }
      } else if (res.has_mul) {
        let mul_left_ref: i32 = ast.ast_arena_expr_alloc(arena);
        if (mul_left_ref == 0) {
          return ParseIntoResult { ok: -1, main_idx: -1 }
        }
        let mle: Expr = ast.ast_arena_expr_get(arena, mul_left_ref);
        mle.kind = ExprKind.EXPR_LIT;
        mle.resolved_type_ref = type_ref;
        mle.line = 0;
        mle.col = 0;
        mle.int_val = res.binop_right_val;
        mle.binop_left_ref = 0;
        mle.binop_right_ref = 0;
        mle.unary_operand_ref = 0;
        mle.if_cond_ref = 0;
        mle.if_then_ref = 0;
        mle.if_else_ref = 0;
        mle.block_ref = 0;
        mle.match_matched_ref = 0;
        mle.match_num_arms = 0;
        ast.expr_init_match_enum(&mle);
        mle.field_access_base_ref = 0;
        mle.field_access_field_len = 0;
        mle.field_access_is_enum_variant = 0;
        mle.field_access_offset = 0;
        mle.index_base_ref = 0;
        mle.index_index_ref = 0;
        mle.index_base_is_slice = 0;
        mle.call_callee_ref = 0;
        mle.call_num_args = 0;
        mle.method_call_base_ref = 0;
        mle.method_call_name_len = 0;
        mle.method_call_num_args = 0;
        mle.const_folded_val = 0;
        mle.const_folded_valid = 0;
        mle.index_proven_in_bounds = 0;
        ast.ast_arena_expr_set(arena, mul_left_ref, mle);
        let mul_r_ref: i32 = ast.ast_arena_expr_alloc(arena);
        if (mul_r_ref == 0) {
          return ParseIntoResult { ok: -1, main_idx: -1 }
        }
        let mre: Expr = ast.ast_arena_expr_get(arena, mul_r_ref);
        mre.kind = ExprKind.EXPR_LIT;
        mre.resolved_type_ref = type_ref;
        mre.line = 0;
        mre.col = 0;
        mre.int_val = res.mul_right_val;
        mre.binop_left_ref = 0;
        mre.binop_right_ref = 0;
        mre.unary_operand_ref = 0;
        mre.if_cond_ref = 0;
        mre.if_then_ref = 0;
        mre.if_else_ref = 0;
        mre.block_ref = 0;
        mre.match_matched_ref = 0;
        mre.match_num_arms = 0;
        ast.expr_init_match_enum(&mre);
        mre.field_access_base_ref = 0;
        mre.field_access_field_len = 0;
        mre.field_access_is_enum_variant = 0;
        mre.field_access_offset = 0;
        mre.index_base_ref = 0;
        mre.index_index_ref = 0;
        mre.index_base_is_slice = 0;
        mre.call_callee_ref = 0;
        mre.call_num_args = 0;
        mre.method_call_base_ref = 0;
        mre.method_call_name_len = 0;
        mre.method_call_num_args = 0;
        mre.const_folded_val = 0;
        mre.const_folded_valid = 0;
        mre.index_proven_in_bounds = 0;
        ast.ast_arena_expr_set(arena, mul_r_ref, mre);
        let mul_ref: i32 = ast.ast_arena_expr_alloc(arena);
        if (mul_ref == 0) {
          return ParseIntoResult { ok: -1, main_idx: -1 }
        }
        let me: Expr = ast.ast_arena_expr_get(arena, mul_ref);
        me.kind = ExprKind.EXPR_MUL;
        me.resolved_type_ref = type_ref;
        me.line = 0;
        me.col = 0;
        me.int_val = 0;
        me.binop_left_ref = mul_left_ref;
        me.binop_right_ref = mul_r_ref;
        me.unary_operand_ref = 0;
        me.if_cond_ref = 0;
        me.if_then_ref = 0;
        me.if_else_ref = 0;
        me.block_ref = 0;
        me.match_matched_ref = 0;
        me.match_num_arms = 0;
        ast.expr_init_match_enum(&me);
        me.field_access_base_ref = 0;
        me.field_access_field_len = 0;
        me.field_access_is_enum_variant = 0;
        me.field_access_offset = 0;
        me.index_base_ref = 0;
        me.index_index_ref = 0;
        me.index_base_is_slice = 0;
        me.call_callee_ref = 0;
        me.call_num_args = 0;
        me.method_call_base_ref = 0;
        me.method_call_name_len = 0;
        me.method_call_num_args = 0;
        me.const_folded_val = 0;
        me.const_folded_valid = 0;
        me.index_proven_in_bounds = 0;
        ast.ast_arena_expr_set(arena, mul_ref, me);
        right_ref = mul_ref;
      } else {
        right_ref = ast.ast_arena_expr_alloc(arena);
        if (right_ref == 0) {
          return ParseIntoResult { ok: -1, main_idx: -1 }
        }
        let re: Expr = ast.ast_arena_expr_get(arena, right_ref);
        re.kind = ExprKind.EXPR_LIT;
        re.resolved_type_ref = type_ref;
        re.line = 0;
        re.col = 0;
        re.int_val = res.binop_right_val;
        re.binop_left_ref = 0;
        re.binop_right_ref = 0;
        re.unary_operand_ref = 0;
        re.if_cond_ref = 0;
        re.if_then_ref = 0;
        re.if_else_ref = 0;
        re.block_ref = 0;
        re.match_matched_ref = 0;
        re.match_num_arms = 0;
        ast.expr_init_match_enum(&re);
        re.field_access_base_ref = 0;
        re.field_access_field_len = 0;
        re.field_access_is_enum_variant = 0;
        re.field_access_offset = 0;
        re.index_base_ref = 0;
        re.index_index_ref = 0;
        re.index_base_is_slice = 0;
        re.call_callee_ref = 0;
        re.call_num_args = 0;
        re.method_call_base_ref = 0;
        re.method_call_name_len = 0;
        re.method_call_num_args = 0;
        re.const_folded_val = 0;
        re.const_folded_valid = 0;
        re.index_proven_in_bounds = 0;
        ast.ast_arena_expr_set(arena, right_ref, re);
      }
      let add_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (add_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      let ae: Expr = ast.ast_arena_expr_get(arena, add_ref);
      ae.kind = ExprKind.EXPR_ADD;
      ae.resolved_type_ref = type_ref;
      ae.line = 0;
      ae.col = 0;
      ae.int_val = 0;
      ae.binop_left_ref = left_ref;
      ae.binop_right_ref = right_ref;
      ae.unary_operand_ref = 0;
      ae.if_cond_ref = 0;
      ae.if_then_ref = 0;
      ae.if_else_ref = 0;
      ae.block_ref = 0;
      ae.match_matched_ref = 0;
      ae.match_num_arms = 0;
      ast.expr_init_match_enum(&ae);
      ae.field_access_base_ref = 0;
      ae.field_access_field_len = 0;
      ae.field_access_is_enum_variant = 0;
      ae.field_access_offset = 0;
      ae.index_base_ref = 0;
      ae.index_index_ref = 0;
      ae.index_base_is_slice = 0;
      ae.call_callee_ref = 0;
      ae.call_num_args = 0;
      ae.method_call_base_ref = 0;
      ae.method_call_name_len = 0;
      ae.method_call_num_args = 0;
      ae.const_folded_val = 0;
      ae.const_folded_valid = 0;
      ae.index_proven_in_bounds = 0;
      ast.ast_arena_expr_set(arena, add_ref, ae);
      final_expr_ref = add_ref;
      }
    }
    if (res.has_unary_neg) {
      let operand_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (operand_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      let oe: Expr = ast.ast_arena_expr_get(arena, operand_ref);
      oe.kind = ExprKind.EXPR_LIT;
      oe.resolved_type_ref = type_ref;
      oe.line = 0;
      oe.col = 0;
      oe.int_val = res.return_val;
      oe.binop_left_ref = 0;
      oe.binop_right_ref = 0;
      oe.unary_operand_ref = 0;
      oe.if_cond_ref = 0;
      oe.if_then_ref = 0;
      oe.if_else_ref = 0;
      oe.block_ref = 0;
      oe.match_matched_ref = 0;
      oe.match_num_arms = 0;
      ast.expr_init_match_enum(&oe);
      oe.field_access_base_ref = 0;
      oe.field_access_field_len = 0;
      oe.field_access_is_enum_variant = 0;
      oe.field_access_offset = 0;
      oe.index_base_ref = 0;
      oe.index_index_ref = 0;
      oe.index_base_is_slice = 0;
      oe.call_callee_ref = 0;
      oe.call_num_args = 0;
      oe.method_call_base_ref = 0;
      oe.method_call_name_len = 0;
      oe.method_call_num_args = 0;
      oe.const_folded_val = 0;
      oe.const_folded_valid = 0;
      oe.index_proven_in_bounds = 0;
      ast.ast_arena_expr_set(arena, operand_ref, oe);
      let neg_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (neg_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      let ne: Expr = ast.ast_arena_expr_get(arena, neg_ref);
      ne.kind = ExprKind.EXPR_NEG;
      ne.resolved_type_ref = type_ref;
      ne.line = 0;
      ne.col = 0;
      ne.int_val = 0;
      ne.binop_left_ref = 0;
      ne.binop_right_ref = 0;
      ne.unary_operand_ref = operand_ref;
      ne.if_cond_ref = 0;
      ne.if_then_ref = 0;
      ne.if_else_ref = 0;
      ne.block_ref = 0;
      ne.match_matched_ref = 0;
      ne.match_num_arms = 0;
      ast.expr_init_match_enum(&ne);
      ne.field_access_base_ref = 0;
      ne.field_access_field_len = 0;
      ne.field_access_is_enum_variant = 0;
      ne.field_access_offset = 0;
      ne.index_base_ref = 0;
      ne.index_index_ref = 0;
      ne.index_base_is_slice = 0;
      ne.call_callee_ref = 0;
      ne.call_num_args = 0;
      ne.method_call_base_ref = 0;
      ne.method_call_name_len = 0;
      ne.method_call_num_args = 0;
      ne.const_folded_val = 0;
      ne.const_folded_valid = 0;
      ne.index_proven_in_bounds = 0;
      ast.ast_arena_expr_set(arena, neg_ref, ne);
      final_expr_ref = neg_ref;
    }
    /* See implementation. */
    if (res.has_call_expr && res.return_expr_ref == 0 && res.call_callee_len > 0 && res.call_callee_len <= 63) {
      let call_pool: *u8 = onefunc_result_pool_ptr(&res);
      let callee_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (callee_ref != 0) {
        let ve: Expr = ast.ast_arena_expr_get(arena, callee_ref);
        ve.kind = ExprKind.EXPR_VAR;
        ve.resolved_type_ref = 0;
        ve.line = 0;
        ve.col = 0;
        ve.var_name_len = res.call_callee_len;
        let ck: i32 = 0;
        while (ck < res.call_callee_len && ck < 64) {
          ve.var_name[ck] = res.call_callee_name[ck];
          ck = ck + 1;
        }
        let z: u8 = (0 as u8);
        while (ck < 64) {
          ve.var_name[ck] = z;
          ck = ck + 1;
        }
        ve.binop_left_ref = 0;
        ve.binop_right_ref = 0;
        ve.unary_operand_ref = 0;
        ve.if_cond_ref = 0;
        ve.if_then_ref = 0;
        ve.if_else_ref = 0;
        ve.block_ref = 0;
        ve.match_matched_ref = 0;
        ve.match_num_arms = 0;
        ast.expr_init_match_enum(&ve);
        ve.field_access_base_ref = 0;
        ve.field_access_field_len = 0;
        ve.field_access_is_enum_variant = 0;
        ve.field_access_offset = 0;
        ve.index_base_ref = 0;
        ve.index_index_ref = 0;
        ve.index_base_is_slice = 0;
        ve.call_callee_ref = 0;
        ve.call_num_args = 0;
        ve.method_call_base_ref = 0;
        ve.method_call_name_len = 0;
        ve.method_call_num_args = 0;
        ve.const_folded_val = 0;
        ve.const_folded_valid = 0;
        ve.index_proven_in_bounds = 0;
        ast.ast_arena_expr_set(arena, callee_ref, ve);
        let call_ref: i32 = ast.ast_arena_expr_alloc(arena);
        if (call_ref != 0) {
          let ce: Expr = ast.ast_arena_expr_get(arena, call_ref);
          expr_set_common_zeros(&ce);
          ce.kind = ExprKind.EXPR_CALL;
          ce.resolved_type_ref = type_ref;
          ce.line = 0;
          ce.col = 0;
          ce.call_callee_ref = callee_ref;
          /* See implementation. */
          if (res.call_num_args > 0) {
            ce.call_num_args = res.call_num_args;
          } else {
            ce.call_num_args = res.num_params;
          }
          ast.ast_arena_expr_set(arena, call_ref, ce);
          let arg_i: i32 = 0;
          while (arg_i < ce.call_num_args) {
            let arg_ref: i32 = ast.ast_arena_expr_alloc(arena);
            if (arg_ref != 0) {
              let ae: Expr = ast.ast_arena_expr_get(arena, arg_ref);
              ae.resolved_type_ref = 0;
              ae.line = 0;
              ae.col = 0;
              if (res.call_num_args > 0 && arg_i < res.call_num_args) {
                ae.kind = ExprKind.EXPR_LIT;
                ae.int_val = pipeline_onefunc_call_arg_val_at(call_pool, arg_i);
              } else {
                ae.kind = ExprKind.EXPR_VAR;
                ae.var_name_len = pipeline_onefunc_param_name_len(call_pool, arg_i);
                let k: i32 = 0;
                while (k < ae.var_name_len && k < 64) {
                  ae.var_name[k] = pipeline_onefunc_param_name_byte_at(call_pool, arg_i, k);
                  k = k + 1;
                }
                let z: u8 = (0 as u8);
                while (k < 64) {
                  ae.var_name[k] = z;
                  k = k + 1;
                }
              }
              expr_set_common_zeros(&ae);
              ast.ast_arena_expr_set(arena, arg_ref, ae);
              pipeline_expr_append_call_arg(arena, call_ref, arg_ref);
            }
            arg_i = arg_i + 1;
          }
          final_expr_ref = call_ref;
        }
      }
    }

    /* See implementation. */
    let block_ref: i32 = 0;
    block_ref = ast.ast_arena_block_alloc(arena);
    if (block_ref == 0) {
      return ParseIntoResult { ok: -1, main_idx: -1010 }
    }
    let b: Block = ast.ast_arena_block_get(arena, block_ref);
    b = ast.ast_arena_block_get(arena, block_ref);
    /* See implementation. */
    b.num_consts = 0;
    b.num_lets = 0;
    b.num_early_lets = 0;
    /* See implementation. */
    b.num_loops = 0;
    b.num_for_loops = 0;
    b.num_if_stmts = 0;
    b.num_regions = 0;
    b.num_defers = 0;
    b.num_labeled_stmts = 0;
    b.num_expr_stmts = 0;
    b.final_expr_ref = 0;
    b.num_stmt_order = 0;
    b.parent_block_ref = 0;
    ast.ast_arena_block_set(arena, block_ref, b);
    /* See implementation. */
    if (parser_should_wrap_func_tail_in_return(arena, &res, type_ref)) {
      let wrapped_fe: i32 = parser_expr_wrap_in_return(arena, type_ref, final_expr_ref);
      if (wrapped_fe == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1011 }
      }
      final_expr_ref = wrapped_fe;
    }
    parser_diagnostic_parse_commit_pre(arena, &res.name[0], res.name_len, block_ref, onefunc_result_pool_ptr(&res), final_expr_ref);
    if (!fill_block_const_let_from_res(arena, block_ref, &res, type_ref)) {
      return ParseIntoResult { ok: -1, main_idx: -1 }
    }
    b = ast.ast_arena_block_get(arena, block_ref);
    /* See implementation. */
    let n_while_pool: i32 = 0;
    n_while_pool = pipeline_onefunc_num_whiles(onefunc_result_pool_ptr(&res));
    res.num_loops = n_while_pool;
    pipeline_block_fill_whiles_from_onefunc(arena, block_ref, onefunc_result_pool_ptr(&res), n_while_pool);
    let n_for_pool: i32 = 0;
    n_for_pool = pipeline_onefunc_num_fors(onefunc_result_pool_ptr(&res));
    res.num_for_loops = n_for_pool;
    pipeline_block_fill_fors_from_onefunc(arena, block_ref, onefunc_result_pool_ptr(&res), n_for_pool);
    b = ast.ast_arena_block_get(arena, block_ref);
    let n_if_pool: i32 = 0;
    n_if_pool = pipeline_onefunc_num_if_stmts(onefunc_result_pool_ptr(&res));
    res.num_if_stmts = n_if_pool;
    pipeline_block_fill_ifs_from_onefunc(arena, block_ref, onefunc_result_pool_ptr(&res), n_if_pool);
    let n_reg_pool: i32 = 0;
    n_reg_pool = pipeline_onefunc_num_regions(onefunc_result_pool_ptr(&res));
    pipeline_block_fill_regions_from_onefunc(arena, block_ref, onefunc_result_pool_ptr(&res), n_reg_pool);
    let n_def_pool: i32 = 0;
    n_def_pool = pipeline_onefunc_num_defers(onefunc_result_pool_ptr(&res));
    pipeline_block_fill_defers_from_onefunc(arena, block_ref, onefunc_result_pool_ptr(&res), n_def_pool);
    b = ast.ast_arena_block_get(arena, block_ref);
    /* See implementation. */
    if (res.num_src_stmt_order > 0) {
      pipeline_block_fill_expr_stmts_from_onefunc(arena, block_ref, onefunc_result_pool_ptr(&res), pipeline_onefunc_num_body_expr_stmts(onefunc_result_pool_ptr(&res)));
      pipeline_block_fill_stmt_order_from_onefunc(arena, block_ref, onefunc_result_pool_ptr(&res), pipeline_onefunc_num_src_stmt_order(onefunc_result_pool_ptr(&res)));
      b = ast.ast_arena_block_get(arena, block_ref);
    } else {
    let ci2: i32 = 0;
    while (ci2 < b.num_consts) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 0, ci2) < 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      ci2 = ci2 + 1;
    }
    let li2: i32 = 0;
    while (li2 < b.num_lets) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 1, li2) < 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      li2 = li2 + 1;
    }
    let loop_i: i32 = 0;
    while (loop_i < b.num_loops) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 3, loop_i) < 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      loop_i = loop_i + 1;
    }
    let for_i: i32 = 0;
    while (for_i < b.num_for_loops) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 4, for_i) < 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      for_i = for_i + 1;
    }
    let if_oi: i32 = 0;
    while (if_oi < b.num_if_stmts) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 5, if_oi) < 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      if_oi = if_oi + 1;
    }
    /* See implementation. */
    let reg_oi: i32 = 0;
    while (reg_oi < pipeline_onefunc_num_regions(onefunc_result_pool_ptr(&res))) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 6, reg_oi) < 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      reg_oi = reg_oi + 1;
    }
    /* See implementation. */
    if (!ast.ref_is_null(final_expr_ref) && b.num_expr_stmts == 0) {
      let fin_ex: i32 = pipeline_block_append_expr_stmt(arena, block_ref, final_expr_ref);
      if (fin_ex < 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      b.final_expr_ref = 0;
      final_expr_ref = 0;
      if (pipeline_block_append_stmt_order(arena, block_ref, 2, fin_ex) < 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      b = ast.ast_arena_block_get(arena, block_ref);
    }
    }
    /*
     * See implementation.
     * See implementation.
     * See implementation.
     */
    b = ast.ast_arena_block_get(arena, block_ref);
    b.final_expr_ref = final_expr_ref;
    if (b.num_expr_stmts > 0 && !ast.ref_is_null(final_expr_ref)) {
      let fe_dedup: Expr = ast.ast_arena_expr_get(arena, final_expr_ref);
      /* See implementation. */
      if (fe_dedup.kind != ExprKind.EXPR_RETURN) {
        b.final_expr_ref = 0;
      }
    }
    ast.ast_arena_block_set(arena, block_ref, b);
    /* See implementation. */
    pipeline_block_with_arena_fixup_stmt_order(arena, block_ref);
    b = ast.ast_arena_block_get(arena, block_ref);
    parser_diagnostic_parse_commit_post(arena, &res.name[0], res.name_len, block_ref, onefunc_result_pool_ptr(&res));

    /*
     * See implementation.
     * See implementation.
     * See implementation.
     */
    let fi: i32 = -1;
    fi = pipeline_module_func_alloc_slot(module);
    if (fi < 0) {
      return ParseIntoResult { ok: -1, main_idx: -1000 }
    }
    pipeline_module_func_name_write(module, fi, &res.name[0], res.name_len);
    pipeline_module_func_set_num_params(module, fi, res.num_params);
    pipeline_module_func_set_num_generic_params(module, fi, res.num_generic_params);
    /* See implementation. */
    let mod_pool: *u8 = onefunc_result_pool_ptr(&res);
    let p: i32 = 0;
    while (p < res.num_params) {
      let pname32: u8[32] = [];
      pipeline_onefunc_param_name_copy32(mod_pool, p, &pname32[0]);
      pipeline_module_func_param_write(module, fi, p, &pname32[0], pipeline_onefunc_param_name_len(mod_pool, p), pipeline_onefunc_param_type_ref(mod_pool, p));
      p = p + 1;
    }
    pipeline_module_func_set_return_type(module, fi, type_ref);
    pipeline_module_func_set_body_ref(module, fi, block_ref);
    pipeline_module_func_set_is_extern(module, fi, 0);
    pipeline_module_func_set_is_async(module, fi, func_is_async_storage[0]);
    pipeline_module_func_set_is_export(module, fi, module.pending_export);
    module.pending_export = 0;
      pipeline_module_func_set_is_used(module, fi, module.pending_used);
      module.pending_used = 0;
      pipeline_module_func_set_is_naked(module, fi, module.pending_naked);
      module.pending_naked = 0;
      pipeline_module_func_set_is_entry(module, fi, module.pending_entry);
      module.pending_entry = 0;
      pipeline_module_func_set_is_no_mangle(module, fi, module.pending_no_mangle);
      module.pending_no_mangle = 0;
      pipeline_module_func_set_is_interrupt(module, fi, module.pending_interrupt);
      module.pending_interrupt = 0;
    if (is_main_storage[0] != 0) {
      main_idx = fi;
    }
    lex_from_onefunc_next_into(&lex, &res);
    ast_pool_onefunc_release(onefunc_result_pool_ptr(&res));
  }
  /* See implementation. */
  if (module.num_funcs == 0) {
    return parse_into_result_empty_module_or_fail_tok(diag_fail_at_token_kind(source));
  }
  /* See implementation. */
  let out_idx_storage: i32[1] = [];
  out_idx_storage[0] = main_idx;
  return ParseIntoResult { ok: 0, main_idx: out_idx_storage[0] }
  }
}

/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_one_top_level_let_into_glue(arena: *ASTArena, module: *Module, lex: Lexer, source: u8[], is_const: bool, out: *TopLevelLetResult): void;
/** Exported function `parse_one_top_level_let_into`.
 * Implements `parse_one_top_level_let_into`.
 * @param arena *ASTArena
 * @param module *Module
 * @param lex Lexer
 * @param source u8[]
 * @param is_const bool
 * @param out *TopLevelLetResult
 * @return void
 */
export function parse_one_top_level_let_into(arena: *ASTArena, module: *Module, lex: Lexer, source: u8[], is_const: bool, out: *TopLevelLetResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_one_top_level_let_into_glue(arena, module, lex, source, is_const, out);
  }
}

/* See implementation. */
export extern function parser_parse_one_type_alias_into_glue(arena: *ASTArena, module: *Module, lex: Lexer, source: u8[], out: *TypeAliasResult): void;
/** Exported function `parse_one_type_alias_into`.
 * Implements `parse_one_type_alias_into`.
 * @param arena *ASTArena
 * @param module *Module
 * @param lex Lexer
 * @param source u8[]
 * @param out *TypeAliasResult
 * @return void
 */
export function parse_one_type_alias_into(arena: *ASTArena, module: *Module, lex: Lexer, source: u8[], out: *TypeAliasResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_one_type_alias_into_glue(arena, module, lex, source, out);
  }
}


/**
 * See implementation.
 * See implementation.
 */

/** Exported function `parse_primary_into_buf`.
 * Implements `parse_primary_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_primary_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_primary_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_unary_into_buf`.
 * Implements `parse_unary_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_unary_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_unary_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_cast_into_buf`.
 * Implements `parse_cast_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_cast_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_cast_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_term_into_buf`.
 * Implements `parse_term_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_term_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_term_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_addsub_into_buf`.
 * Implements `parse_addsub_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_addsub_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_addsub_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_shift_into_buf`.
 * Implements `parse_shift_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_shift_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_shift_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_relcompare_into_buf`.
 * Implements `parse_relcompare_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_relcompare_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_relcompare_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_compare_into_buf`.
 * Implements `parse_compare_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_compare_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_compare_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_bitand_into_buf`.
 * Implements `parse_bitand_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_bitand_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_bitand_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_bitxor_into_buf`.
 * Implements `parse_bitxor_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_bitxor_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_bitxor_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_bitor_into_buf`.
 * Implements `parse_bitor_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_bitor_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_bitor_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_logand_into_buf`.
 * Implements `parse_logand_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_logand_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_logand_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_logor_into_buf`.
 * Implements `parse_logor_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_logor_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_logor_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_ternary_into_buf`.
 * Implements `parse_ternary_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_ternary_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_ternary_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_assign_into_buf`.
 * Implements `parse_assign_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_assign_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_assign_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_expr_into_buf`.
 * Implements `parse_expr_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_expr_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_expr_into(arena, lex, slice, out);
  }
}


/** Exported function `finish_struct_lit_from_type_ident_into_buf`.
 * Implements `finish_struct_lit_from_type_ident_into_buf`.
 * @param arena *ASTArena
 * @param lit_ref i32
 * @param lex_in_brace Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function finish_struct_lit_from_type_ident_into_buf(arena: *ASTArena, lit_ref: i32, lex_in_brace: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  finish_struct_lit_from_type_ident_into(arena, lit_ref, lex_in_brace, slice, out);
  }
}


/** Exported function `parse_cond_expr_into_buf`.
 * Implements `parse_cond_expr_into_buf`.
 * @param arena *ASTArena
 * @param lex_start Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_cond_expr_into_buf(arena: *ASTArena, lex_start: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_cond_expr_into(arena, lex_start, slice, out);
  }
}


/** Exported function `parse_if_stmt_into_buf`.
 * Implements `parse_if_stmt_into_buf`.
 * @param arena *ASTArena
 * @param lex_at_if Lexer
 * @param data *u8
 * @param len i32
 * @param type_ref i32
 * @param out_cond *i32
 * @param out_then *i32
 * @param out_else *i32
 * @param lex_out *Lexer
 * @return bool
 */
export function parse_if_stmt_into_buf(arena: *ASTArena, lex_at_if: Lexer, data: *u8, len: i32, type_ref: i32, out_cond: *i32, out_then: *i32, out_else: *i32, lex_out: *Lexer): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return parse_if_stmt_into(arena, lex_at_if, slice, type_ref, out_cond, out_then, out_else, lex_out);
  }
  return false;  // unreachable — typeck after unsafe block
}


/** Exported function `parse_block_into_buf`.
 * Implements `parse_block_into_buf`.
 * @param arena *ASTArena
 * @param lex_after_lbrace Lexer
 * @param data *u8
 * @param len i32
 * @param type_ref i32
 * @param out *ParseBlockResult
 * @return void
 */
export function parse_block_into_buf(arena: *ASTArena, lex_after_lbrace: Lexer, data: *u8, len: i32, type_ref: i32, out: *ParseBlockResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_block_into(arena, lex_after_lbrace, slice, type_ref, out);
  }
}


/** Exported function `parse_if_expr_into_buf`.
 * Implements `parse_if_expr_into_buf`.
 * @param arena *ASTArena
 * @param lex_at_if Lexer
 * @param data *u8
 * @param len i32
 * @param type_ref i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_if_expr_into_buf(arena: *ASTArena, lex_at_if: Lexer, data: *u8, len: i32, type_ref: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_if_expr_into(arena, lex_at_if, slice, type_ref, out);
  }
}


/** Exported function `parse_match_subject_into_buf`.
 * Implements `parse_match_subject_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_match_subject_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_match_subject_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_match_into_buf`.
 * Implements `parse_match_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_match_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_match_into(arena, lex, slice, out);
  }
}


/** Exported function `parse_at_simd_builtin_into_buf`.
 * Implements `parse_at_simd_builtin_into_buf`.
 * @param arena *ASTArena
 * @param r0 LexerResult
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_at_simd_builtin_into_buf(arena: *ASTArena, r0: LexerResult, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_at_simd_builtin_into(arena, r0, slice, out);
  }
}


/** Exported function `parse_as_suffix_into_buf`.
 * Implements `parse_as_suffix_into_buf`.
 * @param arena *ASTArena
 * @param data *u8
 * @param len i32
 * @param out *ParseExprResult
 * @return void
 */
export function parse_as_suffix_into_buf(arena: *ASTArena, data: *u8, len: i32, out: *ParseExprResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_as_suffix_into(arena, slice, out);
  }
}


/** Exported function `parse_type_ref_for_arena_into_buf`.
 * Implements `parse_type_ref_for_arena_into_buf`.
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out_lex *Lexer
 * @return i32
 */
export function parse_type_ref_for_arena_into_buf(arena: *ASTArena, lex: Lexer, data: *u8, len: i32, out_lex: *Lexer): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return parse_type_ref_for_arena_into(arena, lex, slice, out_lex);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/** Exported function `parse_body_let_bracket_compound_init_ref_buf`.
 * Implements `parse_body_let_bracket_compound_init_ref_buf`.
 * @param arena *ASTArena
 * @param bracket_start usize
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param lex_out *Lexer
 * @param r_out *LexerResult
 * @return i32
 */
export function parse_body_let_bracket_compound_init_ref_buf(arena: *ASTArena, bracket_start: usize, lex: Lexer, data: *u8, len: i32, lex_out: *Lexer, r_out: *LexerResult): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return parse_body_let_bracket_compound_init_ref(arena, bracket_start, lex, slice, lex_out, r_out);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/** Exported function `parse_struct_record_layout_into_buf`.
 * Implements `parse_struct_record_layout_into_buf`.
 * @param arena *ASTArena
 * @param module *Module
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out_lex *Lexer
 * @param allow_pad i32
 * @param force_soa i32
 * @param repr_compat i32
 * @return i32
 */
export function parse_struct_record_layout_into_buf(arena: *ASTArena, module: *Module, lex: Lexer, data: *u8, len: i32, out_lex: *Lexer, allow_pad: i32, force_soa: i32, repr_compat: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return parse_struct_record_layout_into(arena, module, lex, slice, out_lex, allow_pad, force_soa, repr_compat);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/** Exported function `parse_one_function_library_scan_buf`.
 * Implements `parse_one_function_library_scan_buf`.
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param result *LibraryParseScanResult
 * @return bool
 */
export function parse_one_function_library_scan_buf(lex: Lexer, data: *u8, len: i32, result: *LibraryParseScanResult): bool {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return parse_one_function_library_scan(lex, slice, result);
  }
  return false;  // unreachable — typeck after unsafe block
}


/** Exported function `alloc_pointee_type_ref_from_tok_buf`.
 * Memory management helper `alloc_pointee_type_ref_from_tok_buf`.
 * @param arena *ASTArena
 * @param data *u8
 * @param len i32
 * @param r *LexerResult
 * @return i32
 */
export function alloc_pointee_type_ref_from_tok_buf(arena: *ASTArena, data: *u8, len: i32, r: *LexerResult): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return alloc_pointee_type_ref_from_tok(arena, slice, r);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/** Exported function `parser_vector_type_ref_from_ident_spelling_buf`.
 * Implements `parser_vector_type_ref_from_ident_spelling_buf`.
 * @param arena *ASTArena
 * @param data *u8
 * @param len i32
 * @param r LexerResult
 * @return i32
 */
export function parser_vector_type_ref_from_ident_spelling_buf(arena: *ASTArena, data: *u8, len: i32, r: LexerResult): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  return parser_vector_type_ref_from_ident_spelling(arena, slice, r);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/** Exported function `parse_one_top_level_let_into_buf`.
 * Implements `parse_one_top_level_let_into_buf`.
 * @param arena *ASTArena
 * @param module *Module
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param is_const bool
 * @param out *TopLevelLetResult
 * @return void
 */
export function parse_one_top_level_let_into_buf(arena: *ASTArena, module: *Module, lex: Lexer, data: *u8, len: i32, is_const: bool, out: *TopLevelLetResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_one_top_level_let_into(arena, module, lex, slice, is_const, out);
  }
}

/** Exported function `parse_one_type_alias_into_buf`.
 * Implements `parse_one_type_alias_into_buf`.
 * @param arena *ASTArena
 * @param module *Module
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *TypeAliasResult
 * @return void
 */
export function parse_one_type_alias_into_buf(arena: *ASTArena, module: *Module, lex: Lexer, data: *u8, len: i32, out: *TypeAliasResult): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_one_type_alias_into(arena, module, lex, slice, out);
  }
}


/** Exported function `skip_balanced_parens_slice_into_buf`.
 * Implements `skip_balanced_parens_slice_into_buf`.
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
export function skip_balanced_parens_slice_into_buf(out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  skip_balanced_parens_into(out, lex, slice);
  }
}


/** Exported function `skip_balanced_braces_slice_into_buf`.
 * Implements `skip_balanced_braces_slice_into_buf`.
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
export function skip_balanced_braces_slice_into_buf(out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  skip_balanced_braces_into(out, lex, slice);
  }
}


/** Exported function `module_append_enum_variants_and_skip_body_slice_into_buf`.
 * Implements `module_append_enum_variants_and_skip_body_slice_into_buf`.
 * @param module *Module
 * @param enum_idx i32
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
export function module_append_enum_variants_and_skip_body_slice_into_buf(module: *Module, enum_idx: i32, out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let slice: u8[] = parser_slice_from_buf(data, len);
  module_append_enum_variants_and_skip_body_into(module, enum_idx, out, lex, slice);
  }
}


/** Exported function `parse_one_extern_skip_buf`.
 * Implements `parse_one_extern_skip_buf`.
 * @param out *ExternParseResult
 * @param arena *ASTArena
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
export function parse_one_extern_skip_buf(out: *ExternParseResult, arena: *ASTArena, lex: Lexer, data: *u8, len: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parse_one_extern_skip_into_buf(out, arena, lex, data, len);
  }
}


/** Exported function `parse_one_extern_and_add_buf`.
 * Implements `parse_one_extern_and_add_buf`.
 * @param arena *ASTArena
 * @param module *Module
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param lex_out *Lexer
 * @return void
 */
export function parse_one_extern_and_add_buf(arena: *ASTArena, module: *Module, lex: Lexer, data: *u8, len: i32, lex_out: *Lexer): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parse_one_extern_and_add_into_buf(arena, module, lex, data, len, lex_out);
  }
}


/** Exported function `parse_one_function_library_from_buf`.
 * Implements `parse_one_function_library_from_buf`.
 * @param arena *ASTArena
 * @param module *Module
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return LibraryParseResult
 */
export function parse_one_function_library_from_buf(arena: *ASTArena, module: *Module, lex: Lexer, data: *u8, len: i32): LibraryParseResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parse_one_function_library_buf(arena, module, lex, data, len);
  }
}


/** Exported function `parse_into_try_skip_allow_from_buf`.
 * Implements `parse_into_try_skip_allow_from_buf`.
 * @param lex Lexer
 * @param r LexerResult
 * @param data *u8
 * @param len i32
 * @return TrySkipAllowResult
 */
export function parse_into_try_skip_allow_from_buf(lex: Lexer, r: LexerResult, data: *u8, len: i32): TrySkipAllowResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parse_into_try_skip_allow_buf(lex, r, data, len);
  }
}


/**
 * See implementation.
 */
export function parse_into_buf(arena: *ASTArena, module: *Module, data: *u8, len: i32): ParseIntoResult {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let lex: Lexer = lexer.lexer_init();
  let main_idx: i32 = -1;
  let import_res: CollectImportsResult = CollectImportsResult { lex: lex };
  collect_imports_buf(lex, data, len, module, &import_res);
  copy_lex_from_import_into(&lex, import_res);
  let loop_count_buf: i32 = 0;
  while (1 == 1) {
    /* See implementation. */
    if (loop_count_buf >= 131072) {
      return ParseIntoResult { ok: -1, main_idx: -1003 }
    }
    loop_count_buf = loop_count_buf + 1;
    let iter_start_buf: Lexer = lex;
    let r: LexerResult = LexerResult { next_lex: lex, tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 }, token_start: 0 };
    let current_tok_lex_buf: Lexer = lex;
    lexer_next_buf_into(&r, lex, data, len);
    lex_from_next_into(&lex, r);
    let func_is_async_buf: i32[1] = [];
    func_is_async_buf[0] = 0;
    if (r.tok.kind == token.TokenKind.TOKEN_ASYNC) {
      func_is_async_buf[0] = 1;
      lex_from_next_into(&lex, r);
      current_tok_lex_buf = lex;
      lexer_next_buf_into(&r, lex, data, len);
      lex_from_next_into(&lex, r);
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_SOA) {
      module.pending_soa_struct = 1;
      lex_from_next_into(&lex, r);
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_CFG) {
      if (r.tok.int_val == 0) { module.pending_cfg_skip = 1; }
      lex_from_next_into(&lex, r);
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_REPR_C) {
      module.pending_repr_c_struct = 1;
      lex_from_next_into(&lex, r);
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_REPR_COMPATIBLE) {
      module.pending_repr_compatible_struct = 1;
      lex_from_next_into(&lex, r);
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_ALLOC) {
      lex_from_next_into(&lex, r);
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_USED) {
      module.pending_used = 1;
      lex_from_next_into(&lex, r);
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_NAKED) {
      module.pending_naked = 1; lex_from_next_into(&lex, r);
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) { lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 }; }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_ENTRY) {
      module.pending_entry = 1; lex_from_next_into(&lex, r);
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) { lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 }; }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_NO_MANGLE) {
      module.pending_no_mangle = 1; lex_from_next_into(&lex, r);
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) { lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 }; }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ATTR_INTERRUPT) {
      module.pending_interrupt = 1; lex_from_next_into(&lex, r);
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) { lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 }; }
      continue;
    }
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_EXPORT) {
      module.pending_export = 1;
      lex_from_next_into(&lex, r);
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (module.pending_cfg_skip != 0) {
      if (r.tok.kind == token.TokenKind.TOKEN_STRUCT) {
        skip_one_struct_into_buf(&lex, iter_start_buf, data, len);
        module.pending_cfg_skip = 0;
        module.pending_export = 0;
        if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
          lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
        }
        continue;
      }
      if (r.tok.kind == token.TokenKind.TOKEN_CONST) {
        skip_one_top_level_const_into_buf(&lex, iter_start_buf, data, len);
        module.pending_cfg_skip = 0;
        module.pending_export = 0;
        if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
          lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
        }
        continue;
      }
      if (r.tok.kind == token.TokenKind.TOKEN_LET) {
        skip_one_top_level_let_into_buf(&lex, iter_start_buf, data, len);
        module.pending_cfg_skip = 0;
        module.pending_export = 0;
        if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
          lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
        }
        continue;
      }
      if (r.tok.kind == token.TokenKind.TOKEN_FUNCTION || func_is_async_buf[0] != 0 ||
          r.tok.kind == token.TokenKind.TOKEN_EXTERN) {
        skip_one_function_full_into_buf(&lex, iter_start_buf, data, len);
        module.pending_cfg_skip = 0;
        module.pending_export = 0;
        func_is_async_buf[0] = 0;
        if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
          lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
        }
        continue;
      }
      /* See implementation. */
      {
        let try_cfg_allow_buf: TrySkipAllowResult = TrySkipAllowResult { lex: lex, skipped: 0, _pad: [] };
        parse_into_try_skip_allow_into_buf(&try_cfg_allow_buf, lex, r, data, len);
        if (try_cfg_allow_buf.skipped != 0) {
          lex_from_try_skip_into(&lex, try_cfg_allow_buf);
          if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
            lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
          }
          continue;
        }
      }
      module.pending_cfg_skip = 0;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_STRUCT) {
      let lex_kw: Lexer = iter_start_buf;
      let ap_sb: i32 = module.pending_allow_padding;
      let ps_sb: i32 = module.pending_soa_struct;
      let pr_sb: i32 = module.pending_repr_c_struct;
      let pc_sb: i32 = module.pending_repr_compatible_struct;
      let pe_sb: i32 = module.pending_export;
      module.pending_allow_padding = 0;
      module.pending_soa_struct = 0;
      module.pending_repr_c_struct = 0;
      module.pending_repr_compatible_struct = 0;
      module.pending_export = 0;
      let allow_for_repr_buf: i32 = ap_sb;
      if (pr_sb != 0) {
        allow_for_repr_buf = 1;
      }
      let nsl_before_buf: i32 = module.num_struct_layouts;
      if (parse_struct_record_layout_into_buf(arena, module, lex, data, len, &lex, allow_for_repr_buf, ps_sb, pc_sb) != 0) {
        skip_one_struct_into_buf(&lex, lex_kw, data, len);
      } else if (pe_sb != 0 && module.num_struct_layouts > nsl_before_buf) {
        pipeline_module_struct_layout_set_is_export(module, module.num_struct_layouts - 1, 1);
      }
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_ENUM) {
      let pe_enum_buf: i32 = module.pending_export;
      module.pending_export = 0;
      let nen_before_buf: i32 = module.num_module_enums;
      skip_one_enum_register_into_buf(module, &lex, iter_start_buf, data, len);
      if (pe_enum_buf != 0 && module.num_module_enums > nen_before_buf) {
        pipeline_module_enum_set_is_export(module, module.num_module_enums - 1, 1);
      }
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_TRAIT) {
      skip_one_trait_into_buf(&lex, iter_start_buf, data, len);
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_IMPL) {
      skip_one_impl_into_buf(&lex, iter_start_buf, data, len);
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    if (r.tok.kind == token.TokenKind.TOKEN_EXTERN) {
      let num_funcs_before_extern_buf: i32 = module.num_funcs;
      parse_one_extern_and_add_into_buf(arena, module, iter_start_buf, data, len, &lex);
      /* Body-bearing extern (`extern "C" function ... { body }`): C seed set is_extern=0
       * and left lex BEFORE '{'. Parse body via parse_block_into and set body_ref so
       * codegen emits the body. Pure decl (is_extern=1) skips this branch. */
      if (module.num_funcs > num_funcs_before_extern_buf) {
        let fi_ext_buf: i32 = num_funcs_before_extern_buf;
        if (pipeline_module_func_is_extern_at(module, fi_ext_buf) == 0) {
          let slice_ext_buf: u8[] = parser_slice_from_buf(data, len);
          let r_brace_buf: LexerResult = LexerResult { next_lex: lex, tok: token.Token { kind: token.TokenKind.TOKEN_EOF, line: 0, col: 0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 }, token_start: 0 };
          lexer.lexer_next_into(&r_brace_buf, lex, slice_ext_buf);
          if (r_brace_buf.tok.kind == token.TokenKind.TOKEN_LBRACE) {
            let type_ref_extern_buf: i32 = pipeline_module_func_return_type_at(module, fi_ext_buf);
            let block_res_extern_buf: ParseBlockResult = ParseBlockResult { ok: false, block_ref: 0, next_lex: r_brace_buf.next_lex };
            parse_block_into(arena, r_brace_buf.next_lex, slice_ext_buf, type_ref_extern_buf, &block_res_extern_buf);
            if (block_res_extern_buf.ok) {
              pipeline_module_func_set_body_ref(module, fi_ext_buf, block_res_extern_buf.block_ref);
              lex = block_res_extern_buf.next_lex;
            } else {
              skip_balanced_braces_into(&lex, lex, slice_ext_buf);
            }
          }
        }
      }
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
        skip_one_extern_into_buf(&lex, iter_start_buf, data, len);
      }
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_TYPE) {
      let alias_res: TypeAliasResult = TypeAliasResult { ok: false, next_lex: lex };
      parse_one_type_alias_into_buf(arena, module, r.next_lex, data, len, &alias_res);
      if (alias_res.ok) {
        lex = alias_res.next_lex;
        continue;
      }
    }
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_LET || r.tok.kind == token.TokenKind.TOKEN_CONST) {
      let pe_tl: i32 = module.pending_export;
      module.pending_export = 0;
      let ntl_before: i32 = module.num_top_level_lets;
      let toplevel_res: TopLevelLetResult = TopLevelLetResult { ok: false, next_lex: lex };
      parse_one_top_level_let_into_buf(arena, module, r.next_lex, data, len, r.tok.kind == token.TokenKind.TOKEN_CONST, &toplevel_res);
      if (toplevel_res.ok) {
        if (pe_tl != 0 && module.num_top_level_lets > ntl_before) {
          pipeline_module_top_level_let_set_is_export(module, module.num_top_level_lets - 1, 1);
        }
        lex = toplevel_res.next_lex;
        continue;
      }
    }
    if (r.tok.kind != token.TokenKind.TOKEN_FUNCTION) {
      let try_res: TrySkipAllowResult = TrySkipAllowResult { lex: lex, skipped: 0, _pad: [] };
      parse_into_try_skip_allow_into_buf(&try_res, lex, r, data, len);
      if (try_res.skipped != 0) {
        module.pending_allow_padding = 1;
        lex_from_try_skip_into(&lex, try_res);
        if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
          lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
        }
        continue;
      }
      /* See implementation. */
      if (r.tok.kind == token.TokenKind.TOKEN_EOF) {
        break;
      }
      if (lex.pos == iter_start_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    /* See implementation. */
    if (r.tok.kind == token.TokenKind.TOKEN_EOF) {
      if (module.num_funcs == 0) {
        return parse_into_result_empty_module_or_fail_tok(diag_fail_at_token_kind_buf(data, len));
      }
      let out_idx_storage: i32[1] = [];
      out_idx_storage[0] = main_idx;
      return ParseIntoResult { ok: 0, main_idx: out_idx_storage[0] }
    }
    /*
     * See implementation.
     * See implementation.
     * See implementation.
     * PLATFORM: SHARED
     */
    let lex_at_function_buf: Lexer = lexer.lexer_init();
    lex_at_function_buf = current_tok_lex_buf;
    lex_from_next_into(&lex, r);
    /* See implementation. */
    /* See implementation. */
    let empty64_buf: u8[64] = [];
    let res: OneFuncResult = onefunc_scratch_empty();
    res = onefunc_scratch_empty();
    onefunc_res_wire_dummy_head(&res, lex, empty64_buf);
    onefunc_res_wire_dummy_const_let(&res);
    onefunc_res_wire_dummy_if_mul(&res);
    onefunc_res_wire_dummy_call_binop(&res, empty64_buf);
    onefunc_res_wire_dummy_loop_call(&res);
    onefunc_res_wire_dummy_for_if(&res);
    let slice_for_impl: u8[] = parser_slice_from_buf(data, len);
    slice_for_impl = parser_slice_from_buf(data, len);
    /* See implementation. */
    let empty64_lib_buf_first: u8[64] = [];
    let lib_buf_first: LibraryParseResult = LibraryParseResult {
      ok: false,
      _pad: [],
      next_lex: lex_at_function_buf,
      name: empty64_lib_buf_first,
      name_len: 0,
      _pad_tail: []
    };
    lib_buf_first = LibraryParseResult {
      ok: false,
      _pad: [],
      next_lex: lex_at_function_buf,
      name: empty64_lib_buf_first,
      name_len: 0,
      _pad_tail: []
    };
    parse_one_function_library_into_buf(&lib_buf_first, arena, module, lex_at_function_buf, data, len);
    if (lib_buf_first.ok) {
      lex_from_library_into(&lex, lib_buf_first);
      continue;
    }
    parse_one_function_impl(&res, arena, lex, slice_for_impl);
    if (!res.ok) {
      parse_one_function_buf_into(&res, arena, lex_at_function_buf, data, len);
    }
    if (!res.ok) {
      let skip_name: u8[64] = [0];
      let skip_nlen: i32 = parse_peek_function_name_buf(lex_at_function_buf, data, len, &skip_name[0]);
      parser_diagnostic_parse_skip((lex_at_function_buf.pos) as i32, module.num_funcs, skip_nlen, &skip_name[0]);
      skip_one_function_full_into_buf(&lex, lex_at_function_buf, data, len);
      ast_pool_onefunc_release(onefunc_result_pool_ptr(&res));
      if (lex.pos == lex_at_function_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    let is_main_storage: i32[1] = [];
    if (res.name_len == 4 && res.name[0] == 109 && res.name[1] == 97 && res.name[2] == 105 && res.name[3] == 110) {
      is_main_storage[0] = 1;
    }
    parser_diagnostic_parse_func_generic((lex_at_function_buf.pos) as i32, module.num_funcs, &res.name[0], res.name_len,
      res.num_generic_params, is_main_storage[0]);
    /* See implementation. */
    let type_ref: i32 = 0;
    type_ref = res.func_return_type_ref;
    if (type_ref == 0) {
      type_ref = ast.ast_arena_type_alloc(arena);
      if (type_ref == 0) {
        parser_diagnostic_parse_skip((lex_at_function_buf.pos) as i32, module.num_funcs, res.name_len, &res.name[0]);
        skip_one_function_full_into_buf(&lex, lex_at_function_buf, data, len);
        ast_pool_onefunc_release(onefunc_result_pool_ptr(&res));
        if (lex.pos == lex_at_function_buf.pos && lex.pos < (len as usize)) {
          lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
        }
        continue;
      }
      let t_fb: Type = ast.ast_arena_type_get(arena, type_ref);
      t_fb.kind = TypeKind.TYPE_I32;
      t_fb.name_len = 0;
      t_fb.elem_type_ref = 0;
      t_fb.array_size = 0;
      ast.ast_arena_type_set(arena, type_ref, t_fb);
    }

    /* See implementation. */
    let expr_ref: i32 = 0;
    expr_ref = ast.ast_arena_expr_alloc(arena);
    if (expr_ref == 0) {
      parser_diagnostic_parse_commit_fail((lex_at_function_buf.pos) as i32, module.num_funcs, res.name_len, &res.name[0]);
      skip_one_function_full_into_buf(&lex, lex_at_function_buf, data, len);
      ast_pool_onefunc_release(onefunc_result_pool_ptr(&res));
      if (lex.pos == lex_at_function_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    e = ast.ast_arena_expr_get(arena, expr_ref);
    if (res.return_var_name_len > 0) {
      /* See implementation. */
      e.kind = ExprKind.EXPR_VAR;
      e.var_name_len = res.return_var_name_len;
      let rvi: i32 = 0;
      while (rvi < res.return_var_name_len && rvi < 64) {
        e.var_name[rvi] = res.return_var_name[rvi];
        rvi = rvi + 1;
      }
      let rvz: u8 = (0 as u8);
      while (rvi < 64) { e.var_name[rvi] = rvz; rvi = rvi + 1; }
      e.int_val = 0;
      e.resolved_type_ref = 0;
    } else {
      e.kind = ExprKind.EXPR_LIT;
      e.int_val = res.return_val;
      e.resolved_type_ref = type_ref;
    }
    e.line = 0;
    e.col = 0;
    e.binop_left_ref = 0;
    e.binop_right_ref = 0;
    e.unary_operand_ref = 0;
    e.if_cond_ref = 0;
    e.if_then_ref = 0;
    e.if_else_ref = 0;
    e.block_ref = 0;
    e.match_matched_ref = 0;
    e.match_num_arms = 0;
    ast.expr_init_match_enum(&e);
    e.field_access_base_ref = 0;
    e.field_access_field_len = 0;
    e.field_access_is_enum_variant = 0;
    e.field_access_offset = 0;
    e.index_base_ref = 0;
    e.index_index_ref = 0;
    e.index_base_is_slice = 0;
    e.call_callee_ref = 0;
    e.call_num_args = 0;
    e.method_call_base_ref = 0;
    e.method_call_name_len = 0;
    e.method_call_num_args = 0;
    e.const_folded_val = 0;
    e.const_folded_valid = 0;
    e.index_proven_in_bounds = 0;
    ast.ast_arena_expr_set(arena, expr_ref, e);

    /* See implementation. */
    let allow_legacy_tail_expr2: bool = false;
    allow_legacy_tail_expr2 = res.has_final_expr || res.has_explicit_return_kw
      || res.return_expr_ref != 0 || res.return_var_name_len > 0;
    let final_expr_ref: i32 = 0;
    if (allow_legacy_tail_expr2) {
      final_expr_ref = expr_ref;
    }
    if (res.return_expr_ref != 0) {
      final_expr_ref = res.return_expr_ref;
    }
    /* See implementation. */
    if (res.return_var_name_len > 0 && res.return_expr_ref == 0) {
      let var_wrapped: i32 = parser_expr_wrap_in_return(arena, type_ref, final_expr_ref);
      if (var_wrapped == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1003 }
      }
      final_expr_ref = var_wrapped;
    }
    if (res.has_mul && !res.has_binop) {
      let mul_right_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (mul_right_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      let mre: Expr = ast.ast_arena_expr_get(arena, mul_right_ref);
      mre.kind = ExprKind.EXPR_LIT;
      mre.resolved_type_ref = type_ref;
      mre.line = 0;
      mre.col = 0;
      mre.int_val = res.mul_right_val;
      mre.binop_left_ref = 0;
      mre.binop_right_ref = 0;
      mre.unary_operand_ref = 0;
      mre.if_cond_ref = 0;
      mre.if_then_ref = 0;
      mre.if_else_ref = 0;
      mre.block_ref = 0;
      mre.match_matched_ref = 0;
      mre.match_num_arms = 0;
      ast.expr_init_match_enum(&mre);
      mre.field_access_base_ref = 0;
      mre.field_access_field_len = 0;
      mre.field_access_is_enum_variant = 0;
      mre.field_access_offset = 0;
      mre.index_base_ref = 0;
      mre.index_index_ref = 0;
      mre.index_base_is_slice = 0;
      mre.call_callee_ref = 0;
      mre.call_num_args = 0;
      mre.method_call_base_ref = 0;
      mre.method_call_name_len = 0;
      mre.method_call_num_args = 0;
      mre.const_folded_val = 0;
      mre.const_folded_valid = 0;
      mre.index_proven_in_bounds = 0;
      ast.ast_arena_expr_set(arena, mul_right_ref, mre);
      let mul_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (mul_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      let me: Expr = ast.ast_arena_expr_get(arena, mul_ref);
      me.kind = ExprKind.EXPR_BINOP;
      me.resolved_type_ref = type_ref;
      me.line = 0;
      me.col = 0;
      me.int_val = 0;
      me.binop_left_ref = expr_ref;
      me.binop_right_ref = mul_right_ref;
      me.unary_operand_ref = 0;
      me.if_cond_ref = 0;
      me.if_then_ref = 0;
      me.if_else_ref = 0;
      me.block_ref = 0;
      me.match_matched_ref = 0;
      me.match_num_arms = 0;
      ast.expr_init_match_enum(&me);
      me.field_access_base_ref = 0;
      me.field_access_field_len = 0;
      me.field_access_is_enum_variant = 0;
      me.field_access_offset = 0;
      me.index_base_ref = 0;
      me.index_index_ref = 0;
      me.index_base_is_slice = 0;
      me.call_callee_ref = 0;
      me.call_num_args = 0;
      me.method_call_base_ref = 0;
      me.method_call_name_len = 0;
      me.method_call_num_args = 0;
      me.const_folded_val = 0;
      me.const_folded_valid = 0;
      me.index_proven_in_bounds = 0;
      ast.ast_arena_expr_set(arena, mul_ref, me);
      ast.ast_arena_expr_set(arena, expr_ref, e);
    }
    /* See implementation. */
    if (res.has_if_expr) {
      let cond_ref: i32 = 0;
      if (res.if_cond_expr_ref != 0) {
        cond_ref = res.if_cond_expr_ref;
      } else {
      let bool_type_ref: i32 = ast.ast_arena_type_alloc(arena);
      if (bool_type_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1005 }
      }
      let bt: Type = ast.ast_arena_type_get(arena, bool_type_ref);
      bt.kind = TypeKind.TYPE_BOOL;
      bt.name_len = 0;
      bt.elem_type_ref = 0;
      bt.array_size = 0;
      ast.ast_arena_type_set(arena, bool_type_ref, bt);
      cond_ref = ast.ast_arena_expr_alloc(arena);
      if (cond_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      let ce: Expr = ast.ast_arena_expr_get(arena, cond_ref);
      ce.kind = ExprKind.EXPR_BOOL_LIT;
      ce.resolved_type_ref = bool_type_ref;
      ce.line = 0;
      ce.col = 0;
      if (res.if_cond_true) {
        ce.int_val = 1;
      } else {
        ce.int_val = 0;
      }
      ce.binop_left_ref = 0;
      ce.binop_right_ref = 0;
      ce.unary_operand_ref = 0;
      ce.if_cond_ref = 0;
      ce.if_then_ref = 0;
      ce.if_else_ref = 0;
      ce.block_ref = 0;
      ce.match_matched_ref = 0;
      ce.match_num_arms = 0;
      ast.expr_init_match_enum(&ce);
      ce.field_access_base_ref = 0;
      ce.field_access_field_len = 0;
      ce.field_access_is_enum_variant = 0;
      ce.field_access_offset = 0;
      ce.index_base_ref = 0;
      ce.index_index_ref = 0;
      ce.index_base_is_slice = 0;
      ce.call_callee_ref = 0;
      ce.call_num_args = 0;
      ce.method_call_base_ref = 0;
      ce.method_call_name_len = 0;
      ce.method_call_num_args = 0;
      ce.const_folded_val = 0;
      ce.const_folded_valid = 0;
      ce.index_proven_in_bounds = 0;
      ast.ast_arena_expr_set(arena, cond_ref, ce);
      }
      let then_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (then_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      let te: Expr = ast.ast_arena_expr_get(arena, then_ref);
      te.kind = ExprKind.EXPR_LIT;
      te.resolved_type_ref = type_ref;
      te.line = 0;
      te.col = 0;
      te.int_val = res.if_then_val;
      te.binop_left_ref = 0;
      te.binop_right_ref = 0;
      te.unary_operand_ref = 0;
      te.if_cond_ref = 0;
      te.if_then_ref = 0;
      te.if_else_ref = 0;
      te.block_ref = 0;
      te.match_matched_ref = 0;
      te.match_num_arms = 0;
      ast.expr_init_match_enum(&te);
      te.field_access_base_ref = 0;
      te.field_access_field_len = 0;
      te.field_access_is_enum_variant = 0;
      te.field_access_offset = 0;
      te.index_base_ref = 0;
      te.index_index_ref = 0;
      te.index_base_is_slice = 0;
      te.call_callee_ref = 0;
      te.call_num_args = 0;
      te.method_call_base_ref = 0;
      te.method_call_name_len = 0;
      te.method_call_num_args = 0;
      te.const_folded_val = 0;
      te.const_folded_valid = 0;
      te.index_proven_in_bounds = 0;
      ast.ast_arena_expr_set(arena, then_ref, te);
      let else_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (else_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      let ee: Expr = ast.ast_arena_expr_get(arena, else_ref);
      ee.kind = ExprKind.EXPR_LIT;
      ee.resolved_type_ref = type_ref;
      ee.line = 0;
      ee.col = 0;
      ee.int_val = res.if_else_val;
      ee.binop_left_ref = 0;
      ee.binop_right_ref = 0;
      ee.unary_operand_ref = 0;
      ee.if_cond_ref = 0;
      ee.if_then_ref = 0;
      ee.if_else_ref = 0;
      ee.block_ref = 0;
      ee.match_matched_ref = 0;
      ee.match_num_arms = 0;
      ast.expr_init_match_enum(&ee);
      ee.field_access_base_ref = 0;
      ee.field_access_field_len = 0;
      ee.field_access_is_enum_variant = 0;
      ee.field_access_offset = 0;
      ee.index_base_ref = 0;
      ee.index_index_ref = 0;
      ee.index_base_is_slice = 0;
      ee.call_callee_ref = 0;
      ee.call_num_args = 0;
      ee.method_call_base_ref = 0;
      ee.method_call_name_len = 0;
      ee.method_call_num_args = 0;
      ee.const_folded_val = 0;
      ee.const_folded_valid = 0;
      ee.index_proven_in_bounds = 0;
      ast.ast_arena_expr_set(arena, else_ref, ee);
      let if_expr_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (if_expr_ref == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      let ie: Expr = ast.ast_arena_expr_get(arena, if_expr_ref);
      ie.kind = ExprKind.EXPR_IF;
      ie.resolved_type_ref = type_ref;
      ie.line = 0;
      ie.col = 0;
      ie.int_val = 0;
      ie.binop_left_ref = 0;
      ie.binop_right_ref = 0;
      ie.unary_operand_ref = 0;
      ie.if_cond_ref = cond_ref;
      ie.if_then_ref = then_ref;
      ie.if_else_ref = else_ref;
      ie.block_ref = 0;
      ie.match_matched_ref = 0;
      ie.match_num_arms = 0;
      ast.expr_init_match_enum(&ie);
      ie.field_access_base_ref = 0;
      ie.field_access_field_len = 0;
      ie.field_access_is_enum_variant = 0;
      ie.field_access_offset = 0;
      ie.index_base_ref = 0;
      ie.index_index_ref = 0;
      ie.index_base_is_slice = 0;
      ie.call_callee_ref = 0;
      ie.call_num_args = 0;
      ie.method_call_base_ref = 0;
      ie.method_call_name_len = 0;
      ie.method_call_num_args = 0;
      ie.const_folded_val = 0;
      ie.const_folded_valid = 0;
      ie.index_proven_in_bounds = 0;
      ast.ast_arena_expr_set(arena, if_expr_ref, ie);
      final_expr_ref = if_expr_ref;
    }
    /*
     * See implementation.
     * See implementation.
     * See implementation.
     */
    if (res.return_expr_ref == 0) {
      if (res.has_binop || res.binop_right_val != 0) {
      let res_pool_buf: *u8 = onefunc_result_pool_ptr(&res);
      let left_ref_buf: i32 = final_expr_ref;
      if (res.binop_left_param_idx >= 0 && res.binop_left_param_idx < res.num_params) {
        let left_param_type_ref_buf: i32 = pipeline_onefunc_param_type_ref(res_pool_buf, res.binop_left_param_idx);
        let lpr_buf: i32 = ast.ast_arena_expr_alloc(arena);
        if (lpr_buf != 0) {
          let lpe_buf: Expr = ast.ast_arena_expr_get(arena, lpr_buf);
          lpe_buf.kind = ExprKind.EXPR_VAR;
          lpe_buf.resolved_type_ref = left_param_type_ref_buf;
          lpe_buf.line = 0;
          lpe_buf.col = 0;
          lpe_buf.var_name_len = pipeline_onefunc_param_name_len(res_pool_buf, res.binop_left_param_idx);
          let lk_buf: i32 = 0;
          while (lk_buf < lpe_buf.var_name_len && lk_buf < 64) {
            lpe_buf.var_name[lk_buf] = pipeline_onefunc_param_name_byte_at(res_pool_buf, res.binop_left_param_idx, lk_buf);
            lk_buf = lk_buf + 1;
          }
          let lz_buf: u8 = (0 as u8);
          while (lk_buf < 64) { lpe_buf.var_name[lk_buf] = lz_buf; lk_buf = lk_buf + 1; }
          lpe_buf.binop_left_ref = 0;
          lpe_buf.binop_right_ref = 0;
          lpe_buf.unary_operand_ref = 0;
          lpe_buf.if_cond_ref = 0;
          lpe_buf.if_then_ref = 0;
          lpe_buf.if_else_ref = 0;
          lpe_buf.block_ref = 0;
          lpe_buf.match_matched_ref = 0;
          lpe_buf.match_num_arms = 0;
          ast.expr_init_match_enum(&lpe_buf);
          lpe_buf.field_access_base_ref = 0;
          lpe_buf.field_access_field_len = 0;
          lpe_buf.field_access_is_enum_variant = 0;
          lpe_buf.field_access_offset = 0;
          lpe_buf.index_base_ref = 0;
          lpe_buf.index_index_ref = 0;
          lpe_buf.index_base_is_slice = 0;
          lpe_buf.call_callee_ref = 0;
          lpe_buf.call_num_args = 0;
          lpe_buf.method_call_base_ref = 0;
          lpe_buf.method_call_name_len = 0;
          lpe_buf.method_call_num_args = 0;
          lpe_buf.const_folded_val = 0;
          lpe_buf.const_folded_valid = 0;
          lpe_buf.index_proven_in_bounds = 0;
          ast.ast_arena_expr_set(arena, lpr_buf, lpe_buf);
          left_ref_buf = lpr_buf;
        }
      }
      let right_ref_buf: i32 = 0;
      if (res.binop_right_param_idx >= 0 && res.binop_right_param_idx < res.num_params) {
        let right_param_type_ref_buf: i32 = pipeline_onefunc_param_type_ref(res_pool_buf, res.binop_right_param_idx);
        let rpr_buf: i32 = ast.ast_arena_expr_alloc(arena);
        if (rpr_buf != 0) {
          let rpe_buf: Expr = ast.ast_arena_expr_get(arena, rpr_buf);
          rpe_buf.kind = ExprKind.EXPR_VAR;
          rpe_buf.resolved_type_ref = right_param_type_ref_buf;
          rpe_buf.line = 0;
          rpe_buf.col = 0;
          rpe_buf.var_name_len = pipeline_onefunc_param_name_len(res_pool_buf, res.binop_right_param_idx);
          let rk_buf: i32 = 0;
          while (rk_buf < rpe_buf.var_name_len && rk_buf < 64) {
            rpe_buf.var_name[rk_buf] = pipeline_onefunc_param_name_byte_at(res_pool_buf, res.binop_right_param_idx, rk_buf);
            rk_buf = rk_buf + 1;
          }
          let rz_buf: u8 = (0 as u8);
          while (rk_buf < 64) { rpe_buf.var_name[rk_buf] = rz_buf; rk_buf = rk_buf + 1; }
          rpe_buf.binop_left_ref = 0;
          rpe_buf.binop_right_ref = 0;
          rpe_buf.unary_operand_ref = 0;
          rpe_buf.if_cond_ref = 0;
          rpe_buf.if_then_ref = 0;
          rpe_buf.if_else_ref = 0;
          rpe_buf.block_ref = 0;
          rpe_buf.match_matched_ref = 0;
          rpe_buf.match_num_arms = 0;
          ast.expr_init_match_enum(&rpe_buf);
          rpe_buf.field_access_base_ref = 0;
          rpe_buf.field_access_field_len = 0;
          rpe_buf.field_access_is_enum_variant = 0;
          rpe_buf.field_access_offset = 0;
          rpe_buf.index_base_ref = 0;
          rpe_buf.index_index_ref = 0;
          rpe_buf.index_base_is_slice = 0;
          rpe_buf.call_callee_ref = 0;
          rpe_buf.call_num_args = 0;
          rpe_buf.method_call_base_ref = 0;
          rpe_buf.method_call_name_len = 0;
          rpe_buf.method_call_num_args = 0;
          rpe_buf.const_folded_val = 0;
          rpe_buf.const_folded_valid = 0;
          rpe_buf.index_proven_in_bounds = 0;
          ast.ast_arena_expr_set(arena, rpr_buf, rpe_buf);
          right_ref_buf = rpr_buf;
        }
      } else {
        right_ref_buf = ast.ast_arena_expr_alloc(arena);
        if (right_ref_buf == 0) {
          return ParseIntoResult { ok: -1, main_idx: -1 }
        }
        let re_buf: Expr = ast.ast_arena_expr_get(arena, right_ref_buf);
        re_buf.kind = ExprKind.EXPR_LIT;
        re_buf.resolved_type_ref = type_ref;
        re_buf.line = 0;
        re_buf.col = 0;
        re_buf.int_val = res.binop_right_val;
        re_buf.binop_left_ref = 0;
        re_buf.binop_right_ref = 0;
        re_buf.unary_operand_ref = 0;
        re_buf.if_cond_ref = 0;
        re_buf.if_then_ref = 0;
        re_buf.if_else_ref = 0;
        re_buf.block_ref = 0;
        re_buf.match_matched_ref = 0;
        re_buf.match_num_arms = 0;
        ast.expr_init_match_enum(&re_buf);
        re_buf.field_access_base_ref = 0;
        re_buf.field_access_field_len = 0;
        re_buf.field_access_is_enum_variant = 0;
        re_buf.field_access_offset = 0;
        re_buf.index_base_ref = 0;
        re_buf.index_index_ref = 0;
        re_buf.index_base_is_slice = 0;
        re_buf.call_callee_ref = 0;
        re_buf.call_num_args = 0;
        re_buf.method_call_base_ref = 0;
        re_buf.method_call_name_len = 0;
        re_buf.method_call_num_args = 0;
        re_buf.const_folded_val = 0;
        re_buf.const_folded_valid = 0;
        re_buf.index_proven_in_bounds = 0;
        ast.ast_arena_expr_set(arena, right_ref_buf, re_buf);
      }
      let add_ref_buf: i32 = ast.ast_arena_expr_alloc(arena);
      if (add_ref_buf == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      let ae_buf: Expr = ast.ast_arena_expr_get(arena, add_ref_buf);
      ae_buf.kind = ExprKind.EXPR_ADD;
      ae_buf.resolved_type_ref = type_ref;
      ae_buf.line = 0;
      ae_buf.col = 0;
      ae_buf.int_val = 0;
      ae_buf.binop_left_ref = left_ref_buf;
      ae_buf.binop_right_ref = right_ref_buf;
      ae_buf.unary_operand_ref = 0;
      ae_buf.if_cond_ref = 0;
      ae_buf.if_then_ref = 0;
      ae_buf.if_else_ref = 0;
      ae_buf.block_ref = 0;
      ae_buf.match_matched_ref = 0;
      ae_buf.match_num_arms = 0;
      ast.expr_init_match_enum(&ae_buf);
      ae_buf.field_access_base_ref = 0;
      ae_buf.field_access_field_len = 0;
      ae_buf.field_access_is_enum_variant = 0;
      ae_buf.field_access_offset = 0;
      ae_buf.index_base_ref = 0;
      ae_buf.index_index_ref = 0;
      ae_buf.index_base_is_slice = 0;
      ae_buf.call_callee_ref = 0;
      ae_buf.call_num_args = 0;
      ae_buf.method_call_base_ref = 0;
      ae_buf.method_call_name_len = 0;
      ae_buf.method_call_num_args = 0;
      ae_buf.const_folded_val = 0;
      ae_buf.const_folded_valid = 0;
      ae_buf.index_proven_in_bounds = 0;
      ast.ast_arena_expr_set(arena, add_ref_buf, ae_buf);
      final_expr_ref = add_ref_buf;
      }
    }
    /* See implementation. */
    if (res.has_call_expr && res.return_expr_ref == 0 && res.call_callee_len > 0 && res.call_callee_len <= 63) {
      let call_pool_buf: *u8 = onefunc_result_pool_ptr(&res);
      let callee_ref: i32 = ast.ast_arena_expr_alloc(arena);
      if (callee_ref != 0) {
        let ve: Expr = ast.ast_arena_expr_get(arena, callee_ref);
        ve.kind = ExprKind.EXPR_VAR;
        ve.resolved_type_ref = 0;
        ve.line = 0;
        ve.col = 0;
        ve.var_name_len = res.call_callee_len;
        let ck: i32 = 0;
        while (ck < res.call_callee_len && ck < 64) {
          ve.var_name[ck] = res.call_callee_name[ck];
          ck = ck + 1;
        }
        let z: u8 = (0 as u8);
        while (ck < 64) {
          ve.var_name[ck] = z;
          ck = ck + 1;
        }
        ve.binop_left_ref = 0;
        ve.binop_right_ref = 0;
        ve.unary_operand_ref = 0;
        ve.if_cond_ref = 0;
        ve.if_then_ref = 0;
        ve.if_else_ref = 0;
        ve.block_ref = 0;
        ve.match_matched_ref = 0;
        ve.match_num_arms = 0;
        ast.expr_init_match_enum(&ve);
        ve.field_access_base_ref = 0;
        ve.field_access_field_len = 0;
        ve.field_access_is_enum_variant = 0;
        ve.field_access_offset = 0;
        ve.index_base_ref = 0;
        ve.index_index_ref = 0;
        ve.index_base_is_slice = 0;
        ve.call_callee_ref = 0;
        ve.call_num_args = 0;
        ve.method_call_base_ref = 0;
        ve.method_call_name_len = 0;
        ve.method_call_num_args = 0;
        ve.const_folded_val = 0;
        ve.const_folded_valid = 0;
        ve.index_proven_in_bounds = 0;
        ast.ast_arena_expr_set(arena, callee_ref, ve);
        let call_ref: i32 = ast.ast_arena_expr_alloc(arena);
        if (call_ref != 0) {
          let ce: Expr = ast.ast_arena_expr_get(arena, call_ref);
          expr_set_common_zeros(&ce);
          ce.kind = ExprKind.EXPR_CALL;
          ce.resolved_type_ref = type_ref;
          ce.line = 0;
          ce.col = 0;
          ce.call_callee_ref = callee_ref;
          if (res.call_num_args > 0) {
            ce.call_num_args = res.call_num_args;
          } else {
            ce.call_num_args = res.num_params;
          }
          ast.ast_arena_expr_set(arena, call_ref, ce);
          let arg_i: i32 = 0;
          while (arg_i < ce.call_num_args) {
            let arg_ref: i32 = ast.ast_arena_expr_alloc(arena);
            if (arg_ref != 0) {
              let ae: Expr = ast.ast_arena_expr_get(arena, arg_ref);
              ae.resolved_type_ref = 0;
              ae.line = 0;
              ae.col = 0;
              if (res.call_num_args > 0 && arg_i < res.call_num_args) {
                ae.kind = ExprKind.EXPR_LIT;
                ae.int_val = pipeline_onefunc_call_arg_val_at(call_pool_buf, arg_i);
              } else {
                ae.kind = ExprKind.EXPR_VAR;
                ae.var_name_len = pipeline_onefunc_param_name_len(call_pool_buf, arg_i);
                let k: i32 = 0;
                while (k < ae.var_name_len && k < 64) {
                  ae.var_name[k] = pipeline_onefunc_param_name_byte_at(call_pool_buf, arg_i, k);
                  k = k + 1;
                }
                let z: u8 = (0 as u8);
                while (k < 64) {
                  ae.var_name[k] = z;
                  k = k + 1;
                }
              }
              expr_set_common_zeros(&ae);
              ast.ast_arena_expr_set(arena, arg_ref, ae);
              pipeline_expr_append_call_arg(arena, call_ref, arg_ref);
            }
            arg_i = arg_i + 1;
          }
          res.return_expr_ref = call_ref;
          final_expr_ref = call_ref;
        }
      }
    }
    /* See implementation. */
    let block_ref: i32 = 0;
    block_ref = ast.ast_arena_block_alloc(arena);
    if (block_ref == 0) {
      return ParseIntoResult { ok: -1, main_idx: -1 }
    }
    let b: Block = ast.ast_arena_block_get(arena, block_ref);
    b = ast.ast_arena_block_get(arena, block_ref);
    /* See implementation. */
    b.num_consts = 0;
    b.num_lets = 0;
    b.num_early_lets = 0;
    /* See implementation. */
    b.num_loops = 0;
    b.num_for_loops = 0;
    b.num_if_stmts = 0;
    b.num_regions = 0;
    b.num_defers = 0;
    b.num_labeled_stmts = 0;
    b.num_expr_stmts = 0;
    b.final_expr_ref = 0;
    b.num_stmt_order = 0;
    b.parent_block_ref = 0;
    ast.ast_arena_block_set(arena, block_ref, b);
    /* See implementation. */
    if (parser_should_wrap_func_tail_in_return(arena, &res, type_ref)) {
      let wrapped_tail2: i32 = parser_expr_wrap_in_return(arena, type_ref, final_expr_ref);
      if (wrapped_tail2 == 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      final_expr_ref = wrapped_tail2;
    }
    parser_diagnostic_parse_commit_pre(arena, &res.name[0], res.name_len, block_ref, onefunc_result_pool_ptr(&res), final_expr_ref);
    if (!fill_block_const_let_from_res(arena, block_ref, &res, type_ref)) {
      return ParseIntoResult { ok: -1, main_idx: -1 }
    }
    b = ast.ast_arena_block_get(arena, block_ref);
    /* See implementation. */
    let n_while_pool2: i32 = 0;
    n_while_pool2 = pipeline_onefunc_num_whiles(onefunc_result_pool_ptr(&res));
    res.num_loops = n_while_pool2;
    pipeline_block_fill_whiles_from_onefunc(arena, block_ref, onefunc_result_pool_ptr(&res), n_while_pool2);
    let n_for_pool2: i32 = 0;
    n_for_pool2 = pipeline_onefunc_num_fors(onefunc_result_pool_ptr(&res));
    res.num_for_loops = n_for_pool2;
    pipeline_block_fill_fors_from_onefunc(arena, block_ref, onefunc_result_pool_ptr(&res), n_for_pool2);
    b = ast.ast_arena_block_get(arena, block_ref);
    let n_if_pool2: i32 = 0;
    n_if_pool2 = pipeline_onefunc_num_if_stmts(onefunc_result_pool_ptr(&res));
    res.num_if_stmts = n_if_pool2;
    pipeline_block_fill_ifs_from_onefunc(arena, block_ref, onefunc_result_pool_ptr(&res), n_if_pool2);
    let n_reg_pool2: i32 = 0;
    n_reg_pool2 = pipeline_onefunc_num_regions(onefunc_result_pool_ptr(&res));
    pipeline_block_fill_regions_from_onefunc(arena, block_ref, onefunc_result_pool_ptr(&res), n_reg_pool2);
    let n_def_pool2: i32 = 0;
    n_def_pool2 = pipeline_onefunc_num_defers(onefunc_result_pool_ptr(&res));
    pipeline_block_fill_defers_from_onefunc(arena, block_ref, onefunc_result_pool_ptr(&res), n_def_pool2);
    b = ast.ast_arena_block_get(arena, block_ref);
    if (res.num_src_stmt_order > 0) {
      pipeline_block_fill_expr_stmts_from_onefunc(arena, block_ref, onefunc_result_pool_ptr(&res), pipeline_onefunc_num_body_expr_stmts(onefunc_result_pool_ptr(&res)));
      pipeline_block_fill_stmt_order_from_onefunc(arena, block_ref, onefunc_result_pool_ptr(&res), pipeline_onefunc_num_src_stmt_order(onefunc_result_pool_ptr(&res)));
      b = ast.ast_arena_block_get(arena, block_ref);
    } else {
    let ci2b: i32 = 0;
    while (ci2b < b.num_consts) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 0, ci2b) < 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      ci2b = ci2b + 1;
    }
    let li2b: i32 = 0;
    while (li2b < b.num_lets) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 1, li2b) < 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      li2b = li2b + 1;
    }
    let loop_ib: i32 = 0;
    while (loop_ib < b.num_loops) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 3, loop_ib) < 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      loop_ib = loop_ib + 1;
    }
    let for_ib: i32 = 0;
    while (for_ib < b.num_for_loops) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 4, for_ib) < 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      for_ib = for_ib + 1;
    }
    let if_oib: i32 = 0;
    while (if_oib < b.num_if_stmts) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 5, if_oib) < 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      if_oib = if_oib + 1;
    }
    let reg_oib: i32 = 0;
    while (reg_oib < pipeline_onefunc_num_regions(onefunc_result_pool_ptr(&res))) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 6, reg_oib) < 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      reg_oib = reg_oib + 1;
    }
    /* See implementation. */
    if (!ast.ref_is_null(final_expr_ref) && b.num_expr_stmts == 0) {
      let fin_ex2: i32 = pipeline_block_append_expr_stmt(arena, block_ref, final_expr_ref);
      if (fin_ex2 < 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      b.final_expr_ref = 0;
      final_expr_ref = 0;
      if (pipeline_block_append_stmt_order(arena, block_ref, 2, fin_ex2) < 0) {
        return ParseIntoResult { ok: -1, main_idx: -1 }
      }
      b = ast.ast_arena_block_get(arena, block_ref);
    }
    }
    b = ast.ast_arena_block_get(arena, block_ref);
    b.final_expr_ref = final_expr_ref;
    if (b.num_expr_stmts > 0 && !ast.ref_is_null(final_expr_ref)) {
      let fe_dedup2: Expr = ast.ast_arena_expr_get(arena, final_expr_ref);
      if (fe_dedup2.kind != ExprKind.EXPR_RETURN) {
        b.final_expr_ref = 0;
      }
    }
    ast.ast_arena_block_set(arena, block_ref, b);
    pipeline_block_with_arena_fixup_stmt_order(arena, block_ref);
    b = ast.ast_arena_block_get(arena, block_ref);
    parser_diagnostic_parse_commit_post(arena, &res.name[0], res.name_len, block_ref, onefunc_result_pool_ptr(&res));

    /* See implementation. */
    let func_ref: i32 = 0;
    func_ref = ast.ast_arena_func_alloc(arena);
    if (func_ref == 0) {
      parser_diagnostic_parse_commit_fail((lex_at_function_buf.pos) as i32, module.num_funcs, res.name_len, &res.name[0]);
      skip_one_function_full_into_buf(&lex, lex_at_function_buf, data, len);
      ast_pool_onefunc_release(onefunc_result_pool_ptr(&res));
      if (lex.pos == lex_at_function_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    let fi_mod: i32 = -1;
    fi_mod = pipeline_module_func_alloc_slot(module);
    if (fi_mod < 0) {
      parser_diagnostic_parse_commit_fail((lex_at_function_buf.pos) as i32, module.num_funcs, res.name_len, &res.name[0]);
      skip_one_function_full_into_buf(&lex, lex_at_function_buf, data, len);
      ast_pool_onefunc_release(onefunc_result_pool_ptr(&res));
      if (lex.pos == lex_at_function_buf.pos && lex.pos < (len as usize)) {
        lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
      }
      continue;
    }
    pipeline_module_func_name_write(module, fi_mod, &res.name[0], res.name_len);
    pipeline_module_func_set_num_params(module, fi_mod, res.num_params);
    pipeline_module_func_set_num_generic_params(module, fi_mod, res.num_generic_params);
    pipeline_module_func_set_return_type(module, fi_mod, type_ref);
    pipeline_module_func_set_body_ref(module, fi_mod, block_ref);
    pipeline_module_func_set_body_expr_ref(module, fi_mod, 0);
    pipeline_module_func_set_is_extern(module, fi_mod, 0);
    pipeline_module_func_set_is_async(module, fi_mod, func_is_async_buf[0]);
    pipeline_module_func_set_is_export(module, fi_mod, module.pending_export);
    module.pending_export = 0;
      pipeline_module_func_set_is_used(module, fi_mod, module.pending_used);
      module.pending_used = 0;
      pipeline_module_func_set_is_naked(module, fi_mod, module.pending_naked);
      module.pending_naked = 0;
      pipeline_module_func_set_is_entry(module, fi_mod, module.pending_entry);
      module.pending_entry = 0;
      pipeline_module_func_set_is_no_mangle(module, fi_mod, module.pending_no_mangle);
      module.pending_no_mangle = 0;
      pipeline_module_func_set_is_interrupt(module, fi_mod, module.pending_interrupt);
      module.pending_interrupt = 0;
    let p_copy: i32 = 0;
    let mod_pool_buf: *u8 = onefunc_result_pool_ptr(&res);
    while (p_copy < res.num_params) {
      let pname32b: u8[32] = [];
      pipeline_onefunc_param_name_copy32(mod_pool_buf, p_copy, &pname32b[0]);
      pipeline_module_func_param_write(module, fi_mod, p_copy, &pname32b[0], pipeline_onefunc_param_name_len(mod_pool_buf, p_copy), pipeline_onefunc_param_type_ref(mod_pool_buf, p_copy));
      p_copy = p_copy + 1;
    }
    pipeline_module_func_ref_set(module, fi_mod, func_ref);
    pipeline_arena_func_copy_slot_from_module(arena, func_ref, module, fi_mod);
    if (is_main_storage[0] != 0) {
      main_idx = fi_mod;
    }
    let parse_into_guard_pos: usize = lex.pos;
    lex_from_onefunc_next_into(&lex, &res);
    ast_pool_onefunc_release(onefunc_result_pool_ptr(&res));
    /* See implementation. */
    if (lex.pos == parse_into_guard_pos) {
      lex = Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
    }
  }
  if (module.num_funcs == 0) {
    return parse_into_result_empty_module_or_fail_tok(diag_fail_at_token_kind_buf(data, len));
  }
  let out_idx: i32 = main_idx;
  let out_idx_storage: i32[1] = [];
  out_idx_storage[0] = out_idx;
  return ParseIntoResult { ok: 0, main_idx: out_idx_storage[0] }
  }
}

/* See implementation. */
/* See implementation. */
export extern function parser_parse_into_set_main_index_glue(module: *Module, main_idx: i32): void;
/** Exported function `parse_into_set_main_index`.
 * Implements `parse_into_set_main_index`.
 * @param module *Module
 * @param main_idx i32
 * @return void
 */
export function parse_into_set_main_index(module: *Module, main_idx: i32): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  parser_parse_into_set_main_index_glue(module, main_idx);
  }
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_diag_token_after_collect_imports_glue(source: u8[], module: *Module): i32;
/** Exported function `diag_token_after_collect_imports`.
 * Implements `diag_token_after_collect_imports`.
 * @param source u8[]
 * @param module *Module
 * @return i32
 */
export function diag_token_after_collect_imports(source: u8[], module: *Module): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_diag_token_after_collect_imports_glue(source, module);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_diag_parse_one_after_collect_imports_glue(source: u8[], module: *Module, arena: *ASTArena): i32;
/** Exported function `diag_parse_one_after_collect_imports`.
 * Implements `diag_parse_one_after_collect_imports`.
 * @param source u8[]
 * @param module *Module
 * @param arena *ASTArena
 * @return i32
 */
export function diag_parse_one_after_collect_imports(source: u8[], module: *Module, arena: *ASTArena): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_diag_parse_one_after_collect_imports_glue(source, module, arena);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/**
 * See implementation.
 * See implementation.
 */
/* See implementation. */
export extern function parser_parse_one_function_ok_for_pipeline_glue(arena: *ASTArena, source: u8[]): i32;
/** Exported function `parse_one_function_ok_for_pipeline`.
 * Implements `parse_one_function_ok_for_pipeline`.
 * @param arena *ASTArena
 * @param source u8[]
 * @return i32
 */
export function parse_one_function_ok_for_pipeline(arena: *ASTArena, source: u8[]): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return parser_parse_one_function_ok_for_pipeline_glue(arena, source);
  }
  return 0;  // unreachable — typeck after unsafe block
}


/** Exported function `get_module_num_imports`.
 * Query helper `get_module_num_imports`.
 * @param module *Module
 * @return i32
 */
export function get_module_num_imports(module: *Module): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  return module.num_imports;
  }
}

/** Exported function `get_module_import_path`.
 * Query helper `get_module_import_path`.
 * @param module *Module
 * @param i i32
 * @param out u8[64]
 * @return void
 */
export function get_module_import_path(module: *Module, i: i32, out: u8[64]): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  if (i < 0 || i >= module.num_imports) {
    let z: u8 = (0 as u8);
    out[0] = z;
    return;
  }
  pipeline_module_import_path_copy(module, i, &out[0], 64);
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function copy_module_import_path64(module: *Module, i: i32, out: u8[64]): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  get_module_import_path(module, i, out);
  let path_len: i32 = 0;
  while (path_len < 64 && out[path_len] != 0) {
    path_len = path_len + 1;
  }
  return path_len;
  }
}

/** Exported function `main`.
 * Program/test entry point.
 * @return i32
 */
export function main(): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
  let path: u8[32] = [
    47, 116, 109, 112, 47, 115, 104, 117, 95, 112, 97, 114, 115, 101, 95, 116,
    101, 115, 116, 46, 115, 117, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  ];
  let fd: i32 = std_fs_open(path);
  if (fd >= 0) {
    let buf: u8[128] = [];
    let n: isize = std_fs_read(fd, buf, 128);
    std_fs_close(fd);
    if (n > 0) {
      /* See implementation. */
      let sl: u8[] = parser_slice_from_buf(&buf[0], (n as i32));
      let res: ParseResult = parse(sl);
      if (res.ok) {
        return 0;
      }
      return 1;
    }
  }
  // See implementation.
  let src: u8[64] = [
    102, 117, 110, 99, 116, 105, 111, 110, 32, 109, 97, 105, 110, 40, 41, 58,
    32, 105, 51, 50, 32, 123, 32, 114, 101, 116, 117, 114, 110, 32, 48, 59,
    32, 125, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  ];
  /* See implementation. */
  let sl: u8[] = parser_slice_from_buf(&src[0], 35);
  let res: ParseResult = parse(sl);
  if (!res.ok) {
    return 1;
  }
  if (res.return_val != 0) {
    return 2;
  }
  return 0;
  }
  return 0;  // unreachable — typeck after unsafe block
}
