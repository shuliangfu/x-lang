/* seeds/runtime_driver_diagnostic_thin_surface.from_x.c
 * G-02f diagnostic R2 thin full surface — isomorphic with src/runtime_driver_diagnostic_thin.x
 * Product PREFER_X_O: g05_try_x_to_o(thin.x) + full seed rest (-DSHUX_L2_RDD_THIN_FROM_X) ld -r
 * Prove: thin.x vs this seed → nm IDENTICAL (79 public gates; _impl are U)
 * Cap residual: *_impl / va_list / snprintf bodies in seeds/runtime_driver_diagnostic.from_x.c rest
 * Regen: copy from thin.from_x.c or ./shux -E ... thin.x | filter DBG + polish externs
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
extern void driver_diagnostic_parse_fail(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types);
extern void driver_diagnostic_parse_skip_function(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, uint8_t * name);
extern void driver_diagnostic_typeck_func_fail(int32_t func_idx, uint8_t * name, int32_t name_len, int32_t kind);
extern void driver_diagnostic_typeck_ptr_field(int32_t bt_kind, int32_t inner_kind, int32_t inner_nlen, int32_t base_resolved_ref, int32_t num_struct_layouts);
extern void driver_diagnostic_typeck_ret_fail(int32_t stage, int32_t op_expr_ref, int32_t expect_ty_ref, int32_t got_ty_ref);
extern void driver_diagnostic_typeck_binop_operands(int32_t expr_ref, int32_t left_ref, int32_t right_ref, int32_t left_kind, int32_t right_kind, int32_t left_block_ref, int32_t right_block_ref, int32_t left_ty_ref, int32_t right_ty_ref, uint8_t * left_ty, int32_t left_ty_len, uint8_t * right_ty, int32_t right_ty_len);
extern void driver_diagnostic_parser_onefunc_param_ref(uint8_t * func_name, int32_t func_name_len, uint8_t * param_name, int32_t param_name_len, int32_t stage, int32_t param_idx, int32_t type_ref);
extern void driver_diagnostic_typeck_import_const_must_be_qualified(int32_t line, int32_t col, uint8_t * name, int32_t name_len, uint8_t * binding, int32_t binding_len);
extern void driver_diagnostic_typeck_block_enter(int32_t func_idx, int32_t block_ref, int32_t n_const, int32_t n_let, int32_t n_loop, int32_t n_for, int32_t n_expr, int32_t final_ref);
extern void driver_diagnostic_typeck_fn_enter(int32_t func_idx, uint8_t * name, int32_t name_len);
extern void driver_diagnostic_typeck_var_resolution(int32_t expr_ref, uint8_t * name, int32_t name_len, int32_t func_idx, int32_t block_ref, int32_t source, int32_t type_ref);
extern void driver_diagnostic_parse_commit_fail(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, uint8_t * name);
extern void driver_diagnostic_parse_func_generic(int32_t byte_pos, int32_t num_funcs_so_far, uint8_t * name, int32_t name_len, int32_t num_generic_params, int32_t is_main);
extern void driver_diagnostic_parse_commit_shape(int32_t byte_pos, int32_t num_funcs_so_far, uint8_t * name, int32_t name_len, int32_t phase, int32_t block_ref, int32_t pool_num_consts, int32_t pool_num_lets, int32_t pool_num_ifs, int32_t pool_num_regions, int32_t pool_num_stmt_order, int32_t block_num_consts, int32_t block_num_lets, int32_t block_num_ifs, int32_t block_num_regions, int32_t block_num_stmt_order, int32_t final_expr_ref);
extern void parser_diagnostic_parse_commit_shape(int32_t byte_pos, int32_t num_funcs_so_far, uint8_t * name, int32_t name_len, int32_t phase, int32_t block_ref, int32_t pool_num_consts, int32_t pool_num_lets, int32_t pool_num_ifs, int32_t pool_num_regions, int32_t pool_num_stmt_order, int32_t block_num_consts, int32_t block_num_lets, int32_t block_num_ifs, int32_t block_num_regions, int32_t block_num_stmt_order, int32_t final_expr_ref);
extern void driver_diagnostic_after_entry_parse_module(uint8_t * module);
extern void driver_diagnostic_codegen_fail(int32_t dep_index, int32_t is_dep);
extern void driver_diagnostic_codegen_emit_func_fail(uint8_t * module, int32_t func_index);
extern void driver_diagnostic_asm_print_current_func(void);
extern void driver_diagnostic_asm_var_not_found(uint8_t * name, int32_t len, int32_t num_locals, uint8_t * first_slot, int32_t first_len);
extern void driver_diagnostic_asm_fail_at(int32_t loc);
extern void driver_debug_log(int32_t step);
extern void parser_diag_tok_kind(int32_t k);
extern void parser_diag_ident_len(int32_t len);
extern void parser_diag_scan_fail(int32_t step);
extern void driver_diagnostic_warn_pad_fields_same_cache_line(uint8_t * sname, int32_t sname_len, uint8_t * f0, int32_t f0_len, uint8_t * f1, int32_t f1_len);
extern void driver_diagnostic_warn_hot_reorder_field(uint8_t * sname, int32_t sname_len, uint8_t * hot, int32_t hot_len, uint8_t * cold, int32_t cold_len);
extern void driver_diagnostic_hint_unused_binding(int32_t line, int32_t col, uint8_t * name, int32_t name_len);
extern void driver_diagnostic_entry_already(int32_t v);
extern void driver_diagnostic_after_dep_codegen(int32_t j, int32_t out_len);
extern void driver_diagnostic_typeck_fail(void);
extern void driver_diagnostic_asm_last_expr_kind_set(int32_t k);
extern void driver_diagnostic_asm_current_func_store(uint8_t * name, int32_t len);
extern void driver_diagnostic_asm_current_func_maybe_trace(void);
extern void driver_diag_pipe_note(int32_t kind, int32_t a, int32_t b);
extern void driver_diagnostic_asm_set_last_expr_kind(int32_t k);
extern void driver_diagnostic_asm_set_current_func(uint8_t * name, int32_t len);
extern int32_t driver_diag_append_cstr(uint8_t * dst, int32_t cap, int32_t at, uint8_t * src);
extern int32_t driver_diag_append_name(uint8_t * dst, int32_t cap, int32_t at, uint8_t * name, int32_t name_len);
extern int32_t driver_diag_append_i32(uint8_t * dst, int32_t cap, int32_t at, int32_t val);
extern int32_t driver_diag_copy_bytes(uint8_t * dst, int64_t dst_size, uint8_t * src, int32_t src_len);
extern void driver_diagnostic_before_codegen(int32_t num_funcs, int32_t out_len);
extern void driver_diagnostic_source_len(int32_t len);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_pipe_marker(int32_t id);
extern void driver_diagnostic_typeck_if_condition_not_bool(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_while_condition_not_bool(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_for_condition_not_bool(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_deref_outside_unsafe(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_extern_call_outside_unsafe(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_linear_addr_of(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_subscript_base(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_enum_no_variant(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_try_propagate_bad_enclosing(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_break_continue_outside(int32_t line, int32_t col, int32_t is_break);
extern int32_t parser_is_ident_allow(uint8_t * ident, int32_t len);
extern int32_t driver_parse_strict_enabled(void);
extern void driver_diag_report_prefixed(int32_t line, int32_t col, uint8_t * msg);
extern void driver_diag_note(uint8_t * msg);
extern uint8_t * driver_typeck_diag_scratch_expect(void);
extern uint8_t * driver_typeck_diag_scratch_found(void);
extern void driver_diagnostic_typeck_return_unresolved(int32_t line, int32_t col, uint8_t * expr_buf, int32_t expr_len);
extern void driver_diagnostic_typeck_return_subexpr(int32_t line, int32_t col, uint8_t * expr_buf, int32_t expr_len);
extern void driver_diagnostic_typeck_return_mismatch(int32_t line, int32_t col, uint8_t * expect_buf, int32_t expect_len, uint8_t * found_buf, int32_t found_len);
extern void driver_diagnostic_typeck_assign_mismatch(int32_t is_compound, int32_t line, int32_t col, uint8_t * expect_buf, int32_t expect_len, uint8_t * found_buf, int32_t found_len);
extern void driver_diagnostic_typeck_call_not_generic(int32_t line, int32_t col, uint8_t * name, int32_t name_len);
extern void driver_diagnostic_typeck_call_wrong_num_type_args(int32_t line, int32_t col, uint8_t * name, int32_t name_len, int32_t expect_n, int32_t got_n);
extern void driver_diagnostic_typeck_call_requires_type_args(int32_t line, int32_t col, uint8_t * name, int32_t name_len);
extern void driver_diagnostic_typeck_struct_padding_before(uint8_t * sname, int32_t sname_len, int32_t gap, uint8_t * fname, int32_t fname_len);
extern void driver_diagnostic_typeck_struct_padding_trailing(uint8_t * sname, int32_t sname_len, int32_t gap);
extern void driver_diagnostic_typeck_struct_field_bad_size(uint8_t * sname, int32_t sname_len, uint8_t * fname, int32_t fname_len);
extern void driver_diagnostic_asm_unsupported_expr(int32_t kind);
extern void driver_diagnostic_asm_elf_unresolved_patch(uint8_t * name, int32_t len);
extern void driver_diagnostic_asm_macho_empty_reloc(int32_t reloc_idx);
extern void driver_diagnostic_asm_macho_missing_und_reloc(int32_t reloc_idx);
extern void driver_diag_fill_expr_part(uint8_t * dst, int32_t cap, uint8_t * expr_buf, int32_t expr_len);
extern void driver_diag_build_expected_found(uint8_t * msg, int32_t msg_cap, uint8_t * pref, uint8_t * epart, uint8_t * fpart);
extern int32_t driver_diag_env_debug_pipe(void);
extern int32_t lsp_diag_get_enabled(void);
extern void driver_debug_log_impl(int32_t step);
extern void driver_diagnostic_after_entry_parse_module_impl(uint8_t * module);
extern void driver_diagnostic_asm_fail_at_impl(int32_t loc);
extern void driver_diagnostic_asm_print_current_func_impl(void);
extern void driver_diagnostic_asm_var_not_found_impl(uint8_t * name, int32_t len, int32_t num_locals, uint8_t * first_slot, int32_t first_len);
extern void driver_diagnostic_codegen_emit_func_fail_impl(uint8_t * module, int32_t func_index);
extern void driver_diagnostic_codegen_fail_impl(int32_t dep_index, int32_t is_dep);
extern void driver_diagnostic_hint_unused_binding_impl(int32_t line, int32_t col, uint8_t * name, int32_t name_len);
extern void driver_diagnostic_parse_commit_fail_impl(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, uint8_t * name);
extern void driver_diagnostic_parse_commit_shape_impl(int32_t byte_pos, int32_t num_funcs_so_far, uint8_t * name, int32_t name_len, int32_t phase, int32_t block_ref, int32_t pool_num_consts, int32_t pool_num_lets, int32_t pool_num_ifs, int32_t pool_num_regions, int32_t pool_num_stmt_order, int32_t block_num_consts, int32_t block_num_lets, int32_t block_num_ifs, int32_t block_num_regions, int32_t block_num_stmt_order, int32_t final_expr_ref);
extern void driver_diagnostic_parse_fail_impl(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types);
extern void driver_diagnostic_parse_func_generic_impl(int32_t byte_pos, int32_t num_funcs_so_far, uint8_t * name, int32_t name_len, int32_t num_generic_params, int32_t is_main);
extern void driver_diagnostic_parse_skip_function_impl(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, uint8_t * name);
extern void driver_diagnostic_parser_onefunc_param_ref_impl(uint8_t * func_name, int32_t func_name_len, uint8_t * param_name, int32_t param_name_len, int32_t stage, int32_t param_idx, int32_t type_ref);
extern void driver_diagnostic_typeck_binop_operands_impl(int32_t expr_ref, int32_t left_ref, int32_t right_ref, int32_t left_kind, int32_t right_kind, int32_t left_block_ref, int32_t right_block_ref, int32_t left_ty_ref, int32_t right_ty_ref, uint8_t * left_ty, int32_t left_ty_len, uint8_t * right_ty, int32_t right_ty_len);
extern void driver_diagnostic_typeck_block_enter_impl(int32_t func_idx, int32_t block_ref, int32_t n_const, int32_t n_let, int32_t n_loop, int32_t n_for, int32_t n_expr, int32_t final_ref);
extern void driver_diagnostic_typeck_fn_enter_impl(int32_t func_idx, uint8_t * name, int32_t name_len);
extern void driver_diagnostic_typeck_func_fail_impl(int32_t func_idx, uint8_t * name, int32_t name_len, int32_t kind);
extern void driver_diagnostic_typeck_import_const_must_be_qualified_impl(int32_t line, int32_t col, uint8_t * name, int32_t name_len, uint8_t * binding, int32_t binding_len);
extern void driver_diagnostic_typeck_ptr_field_impl(int32_t bt_kind, int32_t inner_kind, int32_t inner_nlen, int32_t base_resolved_ref, int32_t num_struct_layouts);
extern void driver_diagnostic_typeck_ret_fail_impl(int32_t stage, int32_t op_expr_ref, int32_t expect_ty_ref, int32_t got_ty_ref);
extern void driver_diagnostic_typeck_var_resolution_impl(int32_t expr_ref, uint8_t * name, int32_t name_len, int32_t func_idx, int32_t block_ref, int32_t source, int32_t type_ref);
extern void driver_diagnostic_warn_hot_reorder_field_impl(uint8_t * sname, int32_t sname_len, uint8_t * hot, int32_t hot_len, uint8_t * cold, int32_t cold_len);
extern void driver_diagnostic_warn_pad_fields_same_cache_line_impl(uint8_t * sname, int32_t sname_len, uint8_t * f0, int32_t f0_len, uint8_t * f1, int32_t f1_len);
extern void parser_diag_ident_len_impl(int32_t len);
extern void parser_diag_scan_fail_impl(int32_t step);
extern void parser_diag_tok_kind_impl(int32_t k);
extern void parser_diagnostic_parse_commit_shape_impl(int32_t byte_pos, int32_t num_funcs_so_far, uint8_t * name, int32_t name_len, int32_t phase, int32_t block_ref, int32_t pool_num_consts, int32_t pool_num_lets, int32_t pool_num_ifs, int32_t pool_num_regions, int32_t pool_num_stmt_order, int32_t block_num_consts, int32_t block_num_lets, int32_t block_num_ifs, int32_t block_num_regions, int32_t block_num_stmt_order, int32_t final_expr_ref);
void driver_diagnostic_parse_fail(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types) {
  {
    (void)(driver_diagnostic_parse_fail_impl(main_idx, num_funcs, arena_num_types));
  }
  (void)(0);
  return;
}
void driver_diagnostic_parse_skip_function(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, uint8_t * name) {
  {
    (void)(driver_diagnostic_parse_skip_function_impl(byte_pos, num_funcs_so_far, name_len, name));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_func_fail(int32_t func_idx, uint8_t * name, int32_t name_len, int32_t kind) {
  {
    (void)(driver_diagnostic_typeck_func_fail_impl(func_idx, name, name_len, kind));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_ptr_field(int32_t bt_kind, int32_t inner_kind, int32_t inner_nlen, int32_t base_resolved_ref, int32_t num_struct_layouts) {
  {
    (void)(driver_diagnostic_typeck_ptr_field_impl(bt_kind, inner_kind, inner_nlen, base_resolved_ref, num_struct_layouts));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_ret_fail(int32_t stage, int32_t op_expr_ref, int32_t expect_ty_ref, int32_t got_ty_ref) {
  {
    (void)(driver_diagnostic_typeck_ret_fail_impl(stage, op_expr_ref, expect_ty_ref, got_ty_ref));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_binop_operands(int32_t expr_ref, int32_t left_ref, int32_t right_ref, int32_t left_kind, int32_t right_kind, int32_t left_block_ref, int32_t right_block_ref, int32_t left_ty_ref, int32_t right_ty_ref, uint8_t * left_ty, int32_t left_ty_len, uint8_t * right_ty, int32_t right_ty_len) {
  {
    (void)(driver_diagnostic_typeck_binop_operands_impl(expr_ref, left_ref, right_ref, left_kind, right_kind, left_block_ref, right_block_ref, left_ty_ref, right_ty_ref, left_ty, left_ty_len, right_ty, right_ty_len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_parser_onefunc_param_ref(uint8_t * func_name, int32_t func_name_len, uint8_t * param_name, int32_t param_name_len, int32_t stage, int32_t param_idx, int32_t type_ref) {
  {
    (void)(driver_diagnostic_parser_onefunc_param_ref_impl(func_name, func_name_len, param_name, param_name_len, stage, param_idx, type_ref));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_import_const_must_be_qualified(int32_t line, int32_t col, uint8_t * name, int32_t name_len, uint8_t * binding, int32_t binding_len) {
  {
    (void)(driver_diagnostic_typeck_import_const_must_be_qualified_impl(line, col, name, name_len, binding, binding_len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_block_enter(int32_t func_idx, int32_t block_ref, int32_t n_const, int32_t n_let, int32_t n_loop, int32_t n_for, int32_t n_expr, int32_t final_ref) {
  {
    (void)(driver_diagnostic_typeck_block_enter_impl(func_idx, block_ref, n_const, n_let, n_loop, n_for, n_expr, final_ref));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_fn_enter(int32_t func_idx, uint8_t * name, int32_t name_len) {
  {
    (void)(driver_diagnostic_typeck_fn_enter_impl(func_idx, name, name_len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_var_resolution(int32_t expr_ref, uint8_t * name, int32_t name_len, int32_t func_idx, int32_t block_ref, int32_t source, int32_t type_ref) {
  {
    (void)(driver_diagnostic_typeck_var_resolution_impl(expr_ref, name, name_len, func_idx, block_ref, source, type_ref));
  }
  (void)(0);
  return;
}
void driver_diagnostic_parse_commit_fail(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, uint8_t * name) {
  {
    (void)(driver_diagnostic_parse_commit_fail_impl(byte_pos, num_funcs_so_far, name_len, name));
  }
  (void)(0);
  return;
}
void driver_diagnostic_parse_func_generic(int32_t byte_pos, int32_t num_funcs_so_far, uint8_t * name, int32_t name_len, int32_t num_generic_params, int32_t is_main) {
  {
    (void)(driver_diagnostic_parse_func_generic_impl(byte_pos, num_funcs_so_far, name, name_len, num_generic_params, is_main));
  }
  (void)(0);
  return;
}
void driver_diagnostic_parse_commit_shape(int32_t byte_pos, int32_t num_funcs_so_far, uint8_t * name, int32_t name_len, int32_t phase, int32_t block_ref, int32_t pool_num_consts, int32_t pool_num_lets, int32_t pool_num_ifs, int32_t pool_num_regions, int32_t pool_num_stmt_order, int32_t block_num_consts, int32_t block_num_lets, int32_t block_num_ifs, int32_t block_num_regions, int32_t block_num_stmt_order, int32_t final_expr_ref) {
  {
    (void)(driver_diagnostic_parse_commit_shape_impl(byte_pos, num_funcs_so_far, name, name_len, phase, block_ref, pool_num_consts, pool_num_lets, pool_num_ifs, pool_num_regions, pool_num_stmt_order, block_num_consts, block_num_lets, block_num_ifs, block_num_regions, block_num_stmt_order, final_expr_ref));
  }
  (void)(0);
  return;
}
void parser_diagnostic_parse_commit_shape(int32_t byte_pos, int32_t num_funcs_so_far, uint8_t * name, int32_t name_len, int32_t phase, int32_t block_ref, int32_t pool_num_consts, int32_t pool_num_lets, int32_t pool_num_ifs, int32_t pool_num_regions, int32_t pool_num_stmt_order, int32_t block_num_consts, int32_t block_num_lets, int32_t block_num_ifs, int32_t block_num_regions, int32_t block_num_stmt_order, int32_t final_expr_ref) {
  {
    (void)(parser_diagnostic_parse_commit_shape_impl(byte_pos, num_funcs_so_far, name, name_len, phase, block_ref, pool_num_consts, pool_num_lets, pool_num_ifs, pool_num_regions, pool_num_stmt_order, block_num_consts, block_num_lets, block_num_ifs, block_num_regions, block_num_stmt_order, final_expr_ref));
  }
  (void)(0);
  return;
}
void driver_diagnostic_after_entry_parse_module(uint8_t * module) {
  {
    (void)(driver_diagnostic_after_entry_parse_module_impl(module));
  }
  (void)(0);
  return;
}
void driver_diagnostic_codegen_fail(int32_t dep_index, int32_t is_dep) {
  {
    (void)(driver_diagnostic_codegen_fail_impl(dep_index, is_dep));
  }
  (void)(0);
  return;
}
void driver_diagnostic_codegen_emit_func_fail(uint8_t * module, int32_t func_index) {
  {
    (void)(driver_diagnostic_codegen_emit_func_fail_impl(module, func_index));
  }
  (void)(0);
  return;
}
void driver_diagnostic_asm_print_current_func(void) {
  {
    (void)(driver_diagnostic_asm_print_current_func_impl());
  }
  (void)(0);
  return;
}
void driver_diagnostic_asm_var_not_found(uint8_t * name, int32_t len, int32_t num_locals, uint8_t * first_slot, int32_t first_len) {
  {
    (void)(driver_diagnostic_asm_var_not_found_impl(name, len, num_locals, first_slot, first_len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_asm_fail_at(int32_t loc) {
  {
    (void)(driver_diagnostic_asm_fail_at_impl(loc));
  }
  (void)(0);
  return;
}
void driver_debug_log(int32_t step) {
  {
    (void)(driver_debug_log_impl(step));
  }
  (void)(0);
  return;
}
void parser_diag_tok_kind(int32_t k) {
  {
    (void)(parser_diag_tok_kind_impl(k));
  }
  (void)(0);
  return;
}
void parser_diag_ident_len(int32_t len) {
  {
    (void)(parser_diag_ident_len_impl(len));
  }
  (void)(0);
  return;
}
void parser_diag_scan_fail(int32_t step) {
  {
    (void)(parser_diag_scan_fail_impl(step));
  }
  (void)(0);
  return;
}
void driver_diagnostic_warn_pad_fields_same_cache_line(uint8_t * sname, int32_t sname_len, uint8_t * f0, int32_t f0_len, uint8_t * f1, int32_t f1_len) {
  {
    (void)(driver_diagnostic_warn_pad_fields_same_cache_line_impl(sname, sname_len, f0, f0_len, f1, f1_len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_warn_hot_reorder_field(uint8_t * sname, int32_t sname_len, uint8_t * hot, int32_t hot_len, uint8_t * cold, int32_t cold_len) {
  {
    (void)(driver_diagnostic_warn_hot_reorder_field_impl(sname, sname_len, hot, hot_len, cold, cold_len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_hint_unused_binding(int32_t line, int32_t col, uint8_t * name, int32_t name_len) {
  {
    (void)(driver_diagnostic_hint_unused_binding_impl(line, col, name, name_len));
  }
  (void)(0);
  return;
}
extern int32_t driver_check_only_get(void);
extern int32_t driver_check_diag_emitted_get(void);
extern void driver_diagnostic_asm_last_expr_kind_set_impl(int32_t k);
extern void driver_diagnostic_asm_current_func_store_impl(uint8_t * name, int32_t len);
extern void driver_diagnostic_asm_current_func_maybe_trace_impl(void);
extern void driver_diag_pipe_note_impl(int32_t kind, int32_t a, int32_t b);
void driver_diagnostic_entry_already(int32_t v) {
  (void)(0);
}
void driver_diagnostic_after_dep_codegen(int32_t j, int32_t out_len) {
  (void)(0);
}
void driver_diagnostic_typeck_fail(void) {
  {
    int32_t _a = driver_check_only_get();
    int32_t _b = driver_check_diag_emitted_get();
  }
  (void)(0);
  return;
}
void driver_diagnostic_asm_last_expr_kind_set(int32_t k) {
  {
    (void)(driver_diagnostic_asm_last_expr_kind_set_impl(k));
  }
  (void)(0);
  return;
}
void driver_diagnostic_asm_current_func_store(uint8_t * name, int32_t len) {
  {
    (void)(driver_diagnostic_asm_current_func_store_impl(name, len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_asm_current_func_maybe_trace(void) {
  {
    (void)(driver_diagnostic_asm_current_func_maybe_trace_impl());
  }
  (void)(0);
  return;
}
void driver_diag_pipe_note(int32_t kind, int32_t a, int32_t b) {
  {
    (void)(driver_diag_pipe_note_impl(kind, a, b));
  }
  (void)(0);
  return;
}
void driver_diagnostic_asm_set_last_expr_kind(int32_t k) {
  {
    (void)(driver_diagnostic_asm_last_expr_kind_set_impl(k));
  }
  (void)(0);
  return;
}
void driver_diagnostic_asm_set_current_func(uint8_t * name, int32_t len) {
  {
    (void)(driver_diagnostic_asm_current_func_store_impl(name, len));
    (void)(driver_diagnostic_asm_current_func_maybe_trace_impl());
  }
  (void)(0);
  return;
}
int32_t driver_diag_append_cstr(uint8_t * dst, int32_t cap, int32_t at, uint8_t * src) {
  if ((dst ==0)) {
    return at;
  }
  if ((src ==0)) {
    return at;
  }
  int32_t j = at;
  int32_t i = 0;
  while (((j + 1) < cap)) {
    uint8_t c = (src)[i];
    if ((c ==0)) {
      break;
    }
    (void)(((dst)[j] = c));
    (void)((j = (j + 1)));
    (void)((i = (i + 1)));
  }
  (void)(((dst)[j] = 0));
  return j;
}
int32_t driver_diag_append_name(uint8_t * dst, int32_t cap, int32_t at, uint8_t * name, int32_t name_len) {
  if ((name ==0)) {
    return at;
  }
  if ((name_len <=0)) {
    return at;
  }
  int32_t n = 0;
  while ((n < name_len)) {
    if (((at + 1) >=cap)) {
      break;
    }
    (void)(((dst)[at] = (name)[n]));
    (void)((at = (at + 1)));
    (void)((n = (n + 1)));
  }
  (void)(((dst)[at] = 0));
  return at;
}
int32_t driver_diag_append_i32(uint8_t * dst, int32_t cap, int32_t at, int32_t val) {
  if ((dst ==0)) {
    return at;
  }
  if (((at + 1) >=cap)) {
    return at;
  }
  int32_t v = val;
  if ((v < 0)) {
    (void)(((dst)[at] = 45));
    (void)((at = (at + 1)));
    (void)((v = (0 - v)));
  }
  int32_t d0 = 0;
  int32_t d1 = 0;
  int32_t d2 = 0;
  int32_t d3 = 0;
  int32_t d4 = 0;
  int32_t d5 = 0;
  int32_t d6 = 0;
  int32_t d7 = 0;
  int32_t d8 = 0;
  int32_t d9 = 0;
  int32_t dn = 0;
  if ((v ==0)) {
    (void)((d0 = 0));
    (void)((dn = 1));
  } else {
    int32_t t = v;
    while ((t > 0)) {
      int32_t dig = (t % 10);
      if ((dn >=10)) {
        break;
      }
      if ((dn ==0)) {
        (void)((d0 = dig));
      }
      if ((dn ==1)) {
        (void)((d1 = dig));
      }
      if ((dn ==2)) {
        (void)((d2 = dig));
      }
      if ((dn ==3)) {
        (void)((d3 = dig));
      }
      if ((dn ==4)) {
        (void)((d4 = dig));
      }
      if ((dn ==5)) {
        (void)((d5 = dig));
      }
      if ((dn ==6)) {
        (void)((d6 = dig));
      }
      if ((dn ==7)) {
        (void)((d7 = dig));
      }
      if ((dn ==8)) {
        (void)((d8 = dig));
      }
      if ((dn ==9)) {
        (void)((d9 = dig));
      }
      (void)((t = (t / 10)));
      (void)((dn = (dn + 1)));
    }
  }
  int32_t i = (dn - 1);
  while ((i >=0)) {
    int32_t dig = 0;
    if (((at + 1) >=cap)) {
      break;
    }
    if ((i ==0)) {
      (void)((dig = d0));
    }
    if ((i ==1)) {
      (void)((dig = d1));
    }
    if ((i ==2)) {
      (void)((dig = d2));
    }
    if ((i ==3)) {
      (void)((dig = d3));
    }
    if ((i ==4)) {
      (void)((dig = d4));
    }
    if ((i ==5)) {
      (void)((dig = d5));
    }
    if ((i ==6)) {
      (void)((dig = d6));
    }
    if ((i ==7)) {
      (void)((dig = d7));
    }
    if ((i ==8)) {
      (void)((dig = d8));
    }
    if ((i ==9)) {
      (void)((dig = d9));
    }
    (void)(((dst)[at] = ((uint8_t)((dig + 48)))));
    (void)((at = (at + 1)));
    (void)((i = (i - 1)));
  }
  (void)(((dst)[at] = 0));
  return at;
}
int32_t driver_diag_copy_bytes(uint8_t * dst, int64_t dst_size, uint8_t * src, int32_t src_len) {
  if ((dst ==0)) {
    return 0;
  }
  if ((dst_size ==0)) {
    return 0;
  }
  int32_t n = 0;
  if ((src !=0)) {
    if ((src_len > 0)) {
      while ((n < src_len)) {
        if (((((int64_t)(n)) + 1) >=dst_size)) {
          break;
        }
        (void)(((dst)[n] = (src)[n]));
        (void)((n = (n + 1)));
      }
    }
  }
  (void)(((dst)[n] = 0));
  return n;
}
extern void driver_diagnostic_before_codegen_impl(int32_t num_funcs, int32_t out_len);
extern void driver_diagnostic_source_len_impl(int32_t len);
extern void driver_diagnostic_after_entry_parse_impl(int32_t num_funcs);
extern void driver_diagnostic_pipe_marker_impl(int32_t id);
extern void driver_diag_fill_expr_part_impl(uint8_t * dst, int32_t cap, uint8_t * expr_buf, int32_t expr_len);
extern void driver_diagnostic_typeck_if_condition_not_bool_impl(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_while_condition_not_bool_impl(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_for_condition_not_bool_impl(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_deref_outside_unsafe_impl(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_extern_call_outside_unsafe_impl(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_linear_addr_of_impl(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_subscript_base_impl(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_enum_no_variant_impl(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_try_propagate_bad_enclosing_impl(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_break_continue_outside_impl(int32_t line, int32_t col, int32_t is_break);
void driver_diagnostic_before_codegen(int32_t num_funcs, int32_t out_len) {
  {
    (void)(driver_diagnostic_before_codegen_impl(num_funcs, out_len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_source_len(int32_t len) {
  {
    (void)(driver_diagnostic_source_len_impl(len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_after_entry_parse(int32_t num_funcs) {
  {
    (void)(driver_diagnostic_after_entry_parse_impl(num_funcs));
  }
  (void)(0);
  return;
}
void driver_diagnostic_pipe_marker(int32_t id) {
  {
    (void)(driver_diagnostic_pipe_marker_impl(id));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_if_condition_not_bool(int32_t line, int32_t col) {
  {
    (void)(driver_diagnostic_typeck_if_condition_not_bool_impl(line, col));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_while_condition_not_bool(int32_t line, int32_t col) {
  {
    (void)(driver_diagnostic_typeck_while_condition_not_bool_impl(line, col));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_for_condition_not_bool(int32_t line, int32_t col) {
  {
    (void)(driver_diagnostic_typeck_for_condition_not_bool_impl(line, col));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_deref_outside_unsafe(int32_t line, int32_t col) {
  {
    (void)(driver_diagnostic_typeck_deref_outside_unsafe_impl(line, col));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_extern_call_outside_unsafe(int32_t line, int32_t col) {
  {
    (void)(driver_diagnostic_typeck_extern_call_outside_unsafe_impl(line, col));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_linear_addr_of(int32_t line, int32_t col) {
  {
    (void)(driver_diagnostic_typeck_linear_addr_of_impl(line, col));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_subscript_base(int32_t line, int32_t col) {
  {
    (void)(driver_diagnostic_typeck_subscript_base_impl(line, col));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_enum_no_variant(int32_t line, int32_t col) {
  {
    (void)(driver_diagnostic_typeck_enum_no_variant_impl(line, col));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_try_propagate_bad_enclosing(int32_t line, int32_t col) {
  {
    (void)(driver_diagnostic_typeck_try_propagate_bad_enclosing_impl(line, col));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_break_continue_outside(int32_t line, int32_t col, int32_t is_break) {
  {
    (void)(driver_diagnostic_typeck_break_continue_outside_impl(line, col, is_break));
  }
  (void)(0);
  return;
}
int32_t parser_is_ident_allow(uint8_t * ident, int32_t len) {
  if ((ident ==0)) {
    return 0;
  }
  if ((len !=5)) {
    return 0;
  }
  if (((((((ident)[0] ==97) && ((ident)[1] ==108)) && ((ident)[2] ==108)) && ((ident)[3] ==111)) && ((ident)[4] ==119))) {
    return 1;
  }
  return 0;
}
extern void driver_diag_build_expected_found_impl(uint8_t * msg, int32_t msg_cap, uint8_t * pref, uint8_t * epart, uint8_t * fpart);
extern int32_t driver_parse_strict_enabled_impl(void);
extern void driver_diag_report_prefixed_impl(int32_t line, int32_t col, uint8_t * msg);
extern void driver_diag_note_impl(uint8_t * msg);
extern void driver_diagnostic_typeck_return_unresolved_impl(int32_t line, int32_t col, uint8_t * expr_buf, int32_t expr_len);
extern void driver_diagnostic_typeck_return_subexpr_impl(int32_t line, int32_t col, uint8_t * expr_buf, int32_t expr_len);
extern void driver_diagnostic_typeck_return_mismatch_impl(int32_t line, int32_t col, uint8_t * expect_buf, int32_t expect_len, uint8_t * found_buf, int32_t found_len);
extern void driver_diagnostic_typeck_assign_mismatch_impl(int32_t is_compound, int32_t line, int32_t col, uint8_t * expect_buf, int32_t expect_len, uint8_t * found_buf, int32_t found_len);
extern void driver_diagnostic_typeck_call_not_generic_impl(int32_t line, int32_t col, uint8_t * name, int32_t name_len);
extern void driver_diagnostic_typeck_call_wrong_num_type_args_impl(int32_t line, int32_t col, uint8_t * name, int32_t name_len, int32_t expect_n, int32_t got_n);
extern void driver_diagnostic_typeck_call_requires_type_args_impl(int32_t line, int32_t col, uint8_t * name, int32_t name_len);
extern void driver_diagnostic_typeck_struct_padding_before_impl(uint8_t * sname, int32_t sname_len, int32_t gap, uint8_t * fname, int32_t fname_len);
extern void driver_diagnostic_typeck_struct_padding_trailing_impl(uint8_t * sname, int32_t sname_len, int32_t gap);
extern void driver_diagnostic_typeck_struct_field_bad_size_impl(uint8_t * sname, int32_t sname_len, uint8_t * fname, int32_t fname_len);
extern void driver_diagnostic_asm_unsupported_expr_impl(int32_t kind);
extern void driver_diagnostic_asm_elf_unresolved_patch_impl(uint8_t * name, int32_t len);
extern void driver_diagnostic_asm_macho_empty_reloc_impl(int32_t reloc_idx);
extern void driver_diagnostic_asm_macho_missing_und_reloc_impl(int32_t reloc_idx);
extern uint8_t * driver_typeck_diag_scratch_expect_impl(void);
extern uint8_t * driver_typeck_diag_scratch_found_impl(void);
int32_t driver_parse_strict_enabled(void) {
  {
    return driver_parse_strict_enabled_impl();
  }
  return 0;
}
void driver_diag_report_prefixed(int32_t line, int32_t col, uint8_t * msg) {
  {
    (void)(driver_diag_report_prefixed_impl(line, col, msg));
  }
  (void)(0);
  return;
}
void driver_diag_note(uint8_t * msg) {
  {
    (void)(driver_diag_note_impl(msg));
  }
  (void)(0);
  return;
}
uint8_t * driver_typeck_diag_scratch_expect(void) {
  {
    return driver_typeck_diag_scratch_expect_impl();
  }
  return ((uint8_t *)(0));
}
uint8_t * driver_typeck_diag_scratch_found(void) {
  {
    return driver_typeck_diag_scratch_found_impl();
  }
  return ((uint8_t *)(0));
}
void driver_diagnostic_typeck_return_unresolved(int32_t line, int32_t col, uint8_t * expr_buf, int32_t expr_len) {
  {
    (void)(driver_diagnostic_typeck_return_unresolved_impl(line, col, expr_buf, expr_len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_return_subexpr(int32_t line, int32_t col, uint8_t * expr_buf, int32_t expr_len) {
  {
    (void)(driver_diagnostic_typeck_return_subexpr_impl(line, col, expr_buf, expr_len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_return_mismatch(int32_t line, int32_t col, uint8_t * expect_buf, int32_t expect_len, uint8_t * found_buf, int32_t found_len) {
  {
    (void)(driver_diagnostic_typeck_return_mismatch_impl(line, col, expect_buf, expect_len, found_buf, found_len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_assign_mismatch(int32_t is_compound, int32_t line, int32_t col, uint8_t * expect_buf, int32_t expect_len, uint8_t * found_buf, int32_t found_len) {
  {
    (void)(driver_diagnostic_typeck_assign_mismatch_impl(is_compound, line, col, expect_buf, expect_len, found_buf, found_len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_call_not_generic(int32_t line, int32_t col, uint8_t * name, int32_t name_len) {
  {
    (void)(driver_diagnostic_typeck_call_not_generic_impl(line, col, name, name_len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_call_wrong_num_type_args(int32_t line, int32_t col, uint8_t * name, int32_t name_len, int32_t expect_n, int32_t got_n) {
  {
    (void)(driver_diagnostic_typeck_call_wrong_num_type_args_impl(line, col, name, name_len, expect_n, got_n));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_call_requires_type_args(int32_t line, int32_t col, uint8_t * name, int32_t name_len) {
  {
    (void)(driver_diagnostic_typeck_call_requires_type_args_impl(line, col, name, name_len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_struct_padding_before(uint8_t * sname, int32_t sname_len, int32_t gap, uint8_t * fname, int32_t fname_len) {
  {
    (void)(driver_diagnostic_typeck_struct_padding_before_impl(sname, sname_len, gap, fname, fname_len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_struct_padding_trailing(uint8_t * sname, int32_t sname_len, int32_t gap) {
  {
    (void)(driver_diagnostic_typeck_struct_padding_trailing_impl(sname, sname_len, gap));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_struct_field_bad_size(uint8_t * sname, int32_t sname_len, uint8_t * fname, int32_t fname_len) {
  {
    (void)(driver_diagnostic_typeck_struct_field_bad_size_impl(sname, sname_len, fname, fname_len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_asm_unsupported_expr(int32_t kind) {
  {
    (void)(driver_diagnostic_asm_unsupported_expr_impl(kind));
  }
  (void)(0);
  return;
}
void driver_diagnostic_asm_elf_unresolved_patch(uint8_t * name, int32_t len) {
  {
    (void)(driver_diagnostic_asm_elf_unresolved_patch_impl(name, len));
  }
  (void)(0);
  return;
}
void driver_diagnostic_asm_macho_empty_reloc(int32_t reloc_idx) {
  {
    (void)(driver_diagnostic_asm_macho_empty_reloc_impl(reloc_idx));
  }
  (void)(0);
  return;
}
void driver_diagnostic_asm_macho_missing_und_reloc(int32_t reloc_idx) {
  {
    (void)(driver_diagnostic_asm_macho_missing_und_reloc_impl(reloc_idx));
  }
  (void)(0);
  return;
}
void driver_diag_fill_expr_part(uint8_t * dst, int32_t cap, uint8_t * expr_buf, int32_t expr_len) {
  {
    (void)(driver_diag_fill_expr_part_impl(dst, cap, expr_buf, expr_len));
  }
  (void)(0);
  return;
}
void driver_diag_build_expected_found(uint8_t * msg, int32_t msg_cap, uint8_t * pref, uint8_t * epart, uint8_t * fpart) {
  {
    (void)(driver_diag_build_expected_found_impl(msg, msg_cap, pref, epart, fpart));
  }
  (void)(0);
  return;
}
extern int32_t driver_diag_env_debug_pipe_impl(void);
int32_t driver_diag_env_debug_pipe(void) {
  {
    return driver_diag_env_debug_pipe_impl();
  }
  return 0;
}
extern int32_t lsp_diag_get_enabled_impl(void);
int32_t lsp_diag_get_enabled(void) {
  {
    return lsp_diag_get_enabled_impl();
  }
  return 0;
}
