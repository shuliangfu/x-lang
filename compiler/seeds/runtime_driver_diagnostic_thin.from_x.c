/* seeds/runtime_driver_diagnostic_thin.from_x.c
 * intermediate -E of runtime_driver_diagnostic_thin.x (g05 polish); not prove surface.
 * Track-L (2026-07-16): drop driver_env_flag_truthy body (same as surface / thin.x extern-only).
 */
/* g05_try_x_to_o prologue (G-02f-332/334) */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#ifndef _WIN32
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#endif
extern int32_t driver_env_flag_truthy(uint8_t * name);
extern void driver_diagnostic_parse_fail(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types);
extern void driver_diagnostic_parse_skip_function(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, uint8_t * name);
extern void driver_diagnostic_typeck_func_fail(int32_t func_idx, uint8_t * name, int32_t name_len, int32_t kind);
extern void driver_diagnostic_typeck_ptr_field(int32_t bt_kind, int32_t inner_kind, int32_t inner_nlen, int32_t base_resolved_ref, int32_t num_struct_layouts);
extern void driver_diagnostic_typeck_ret_fail(int32_t stage, int32_t op_expr_ref, int32_t expect_ty_ref, int32_t got_ty_ref);
extern void driver_diagnostic_typeck_binop_operands(int32_t expr_ref, int32_t left_ref, int32_t right_ref, int32_t left_kind, int32_t right_kind, int32_t left_block_ref, int32_t right_block_ref, int32_t left_ty_ref, int32_t right_ty_ref, uint8_t * left_ty, int32_t left_ty_len, uint8_t * right_ty, int32_t right_ty_len);
extern void driver_diagnostic_parser_onefunc_param_ref(uint8_t * func_name, int32_t func_name_len, uint8_t * param_name, int32_t param_name_len, int32_t stage, int32_t param_idx, int32_t type_ref);
extern void driver_diagnostic_typeck_import_const_must_be_qualified(int32_t line, int32_t col, uint8_t * name, int32_t name_len, uint8_t * binding, int32_t binding_len);
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
extern void driver_diagnostic_warn_pad_fields_same_cache_line(uint8_t * sname, int32_t sname_len, uint8_t * f0, int32_t f0_len, uint8_t * f1, int32_t f1_len);
extern void driver_diagnostic_warn_hot_reorder_field(uint8_t * sname, int32_t sname_len, uint8_t * hot, int32_t hot_len, uint8_t * cold, int32_t cold_len);
extern void driver_diagnostic_hint_unused_binding(int32_t line, int32_t col, uint8_t * name, int32_t name_len);
extern void driver_diagnostic_entry_already(int32_t v);
extern void driver_diagnostic_after_dep_codegen(int32_t j, int32_t out_len);
extern void driver_diagnostic_typeck_fail(void);
extern void driver_diagnostic_asm_last_expr_kind_set(int32_t k);
extern void driver_diagnostic_asm_current_func_store(uint8_t * name, int32_t len);
extern void driver_diagnostic_asm_current_func_maybe_trace(void);
extern void driver_diagnostic_asm_set_last_expr_kind(int32_t k);
extern void driver_diagnostic_asm_set_current_func(uint8_t * name, int32_t len);
extern int32_t driver_diag_append_cstr(uint8_t * dst, int32_t cap, int32_t at, uint8_t * src);
extern int32_t driver_diag_append_name(uint8_t * dst, int32_t cap, int32_t at, uint8_t * name, int32_t name_len);
extern int32_t driver_diag_append_i32(uint8_t * dst, int32_t cap, int32_t at, int32_t val);
extern int32_t driver_diag_copy_bytes(uint8_t * dst, int64_t dst_size, uint8_t * src, int32_t src_len);
extern int32_t driver_diag_env_debug_pipe(void);
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
extern void driver_diag_note(uint8_t * msg);
extern void driver_diag_report_prefixed(int32_t line, int32_t col, uint8_t * msg);
extern void driver_diag_pipe_note(int32_t kind, int32_t a, int32_t b);
extern int32_t driver_diag_parse_debug_enabled(void);
extern void driver_debug_log(int32_t step);
extern void parser_diag_tok_kind(int32_t k);
extern void parser_diag_ident_len(int32_t len);
extern void parser_diag_scan_fail(int32_t step);
extern void driver_diagnostic_typeck_block_enter(int32_t func_idx, int32_t block_ref, int32_t n_const, int32_t n_let, int32_t n_loop, int32_t n_for, int32_t n_expr, int32_t final_ref);
extern void driver_diagnostic_typeck_fn_enter(int32_t func_idx, uint8_t * name, int32_t name_len);
extern void driver_diagnostic_typeck_var_resolution(int32_t expr_ref, uint8_t * name, int32_t name_len, int32_t func_idx, int32_t block_ref, int32_t source, int32_t type_ref);
extern uint8_t * driver_typeck_diag_scratch_expect(void);
extern uint8_t * driver_typeck_diag_scratch_found(void);
extern void driver_diag_fill_expr_part(uint8_t * dst, int32_t cap, uint8_t * expr_buf, int32_t expr_len);
extern void driver_diag_build_expected_found(uint8_t * msg, int32_t msg_cap, uint8_t * pref, uint8_t * epart, uint8_t * fpart);
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
extern int32_t lsp_diag_get_enabled(void);
static uint8_t * g_type_diag_scratch_expect;
static uint8_t * g_type_diag_scratch_found;
static void init_globals(void) {
  g_type_diag_scratch_expect = (uint8_t[]){ };
  g_type_diag_scratch_found = (uint8_t[]){ };
}
/* driver_env_flag_truthy: extern-only; authority is runtime_driver_abi_thin. */
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
extern void driver_diagnostic_typeck_func_fail_impl(int32_t func_idx, uint8_t * name, int32_t name_len, int32_t kind);
extern void driver_diagnostic_typeck_import_const_must_be_qualified_impl(int32_t line, int32_t col, uint8_t * name, int32_t name_len, uint8_t * binding, int32_t binding_len);
extern void driver_diagnostic_typeck_ptr_field_impl(int32_t bt_kind, int32_t inner_kind, int32_t inner_nlen, int32_t base_resolved_ref, int32_t num_struct_layouts);
extern void driver_diagnostic_typeck_ret_fail_impl(int32_t stage, int32_t op_expr_ref, int32_t expect_ty_ref, int32_t got_ty_ref);
extern void driver_diagnostic_warn_hot_reorder_field_impl(uint8_t * sname, int32_t sname_len, uint8_t * hot, int32_t hot_len, uint8_t * cold, int32_t cold_len);
extern void driver_diagnostic_warn_pad_fields_same_cache_line_impl(uint8_t * sname, int32_t sname_len, uint8_t * f0, int32_t f0_len, uint8_t * f1, int32_t f1_len);
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
extern void lsp_diag_report_typeck(int32_t line, int32_t col, uint8_t * msg);
int32_t driver_diag_env_debug_pipe(void) {
  return driver_env_flag_truthy((uint8_t[]){83, 72, 85, 88, 95, 68, 69, 66, 85, 71, 95, 80, 73, 80, 69, 0 });
}
void driver_diagnostic_before_codegen(int32_t num_funcs, int32_t out_len) {
  {
    if ((driver_diag_env_debug_pipe() !=0)) {
      (void)(driver_diag_pipe_note(0, num_funcs, out_len));
    }
  }
  (void)(0);
  return;
}
void driver_diagnostic_source_len(int32_t len) {
  {
    if ((driver_diag_env_debug_pipe() !=0)) {
      (void)(driver_diag_pipe_note(1, len, 0));
    }
  }
  (void)(0);
  return;
}
void driver_diagnostic_after_entry_parse(int32_t num_funcs) {
  {
    if ((driver_diag_env_debug_pipe() !=0)) {
      (void)(driver_diag_pipe_note(2, num_funcs, 0));
    }
  }
  (void)(0);
  return;
}
void driver_diagnostic_pipe_marker(int32_t id) {
  {
    if ((driver_diag_env_debug_pipe() !=0)) {
      (void)(driver_diag_pipe_note(3, id, 0));
    }
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_if_condition_not_bool(int32_t line, int32_t col) {
  {
    (void)(lsp_diag_report_typeck(line, col, (uint8_t[]){105, 102, 32, 99, 111, 110, 100, 105, 116, 105, 111, 110, 32, 109, 117, 115, 116, 32, 98, 101, 32, 98, 111, 111, 108, 32, 40, 110, 111, 32, 105, 109, 112, 108, 105, 99, 105, 116, 32, 105, 110, 116, 45, 116, 111, 45, 98, 111, 111, 108, 41, 0 }));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_while_condition_not_bool(int32_t line, int32_t col) {
  {
    (void)(lsp_diag_report_typeck(line, col, (uint8_t[]){119, 104, 105, 108, 101, 32, 99, 111, 110, 100, 105, 116, 105, 111, 110, 32, 109, 117, 115, 116, 32, 98, 101, 32, 98, 111, 111, 108, 32, 40, 110, 111, 32, 105, 109, 112, 108, 105, 99, 105, 116, 32, 105, 110, 116, 45, 116, 111, 45, 98, 111, 111, 108, 41, 0 }));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_for_condition_not_bool(int32_t line, int32_t col) {
  {
    (void)(lsp_diag_report_typeck(line, col, (uint8_t[]){102, 111, 114, 32, 99, 111, 110, 100, 105, 116, 105, 111, 110, 32, 109, 117, 115, 116, 32, 98, 101, 32, 98, 111, 111, 108, 32, 40, 110, 111, 32, 105, 109, 112, 108, 105, 99, 105, 116, 32, 105, 110, 116, 45, 116, 111, 45, 98, 111, 111, 108, 41, 0 }));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_deref_outside_unsafe(int32_t line, int32_t col) {
  {
    (void)(lsp_diag_report_typeck(line, col, (uint8_t[]){112, 111, 105, 110, 116, 101, 114, 32, 100, 101, 114, 101, 102, 101, 114, 101, 110, 99, 101, 32, 114, 101, 113, 117, 105, 114, 101, 115, 32, 117, 110, 115, 97, 102, 101, 32, 98, 108, 111, 99, 107, 0 }));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_extern_call_outside_unsafe(int32_t line, int32_t col) {
  {
    (void)(lsp_diag_report_typeck(line, col, (uint8_t[]){101, 120, 116, 101, 114, 110, 32, 99, 97, 108, 108, 32, 114, 101, 113, 117, 105, 114, 101, 115, 32, 117, 110, 115, 97, 102, 101, 32, 98, 108, 111, 99, 107, 0 }));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_linear_addr_of(int32_t line, int32_t col) {
  {
    (void)(lsp_diag_report_typeck(line, col, (uint8_t[]){99, 97, 110, 110, 111, 116, 32, 116, 97, 107, 101, 32, 97, 100, 100, 114, 101, 115, 115, 32, 111, 102, 32, 108, 105, 110, 101, 97, 114, 32, 118, 97, 108, 117, 101, 0 }));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_subscript_base(int32_t line, int32_t col) {
  {
    (void)(lsp_diag_report_typeck(line, col, (uint8_t[]){115, 117, 98, 115, 99, 114, 105, 112, 116, 32, 98, 97, 115, 101, 32, 109, 117, 115, 116, 32, 98, 101, 32, 97, 114, 114, 97, 121, 44, 32, 115, 108, 105, 99, 101, 32, 111, 114, 32, 112, 111, 105, 110, 116, 101, 114, 0 }));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_enum_no_variant(int32_t line, int32_t col) {
  {
    (void)(lsp_diag_report_typeck(line, col, (uint8_t[]){101, 110, 117, 109, 32, 104, 97, 115, 32, 110, 111, 32, 118, 97, 114, 105, 97, 110, 116, 0 }));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_try_propagate_bad_enclosing(int32_t line, int32_t col) {
  {
    (void)(lsp_diag_report_typeck(line, col, (uint8_t[]){96, 63, 96, 32, 114, 101, 113, 117, 105, 114, 101, 115, 32, 116, 104, 101, 32, 101, 110, 99, 108, 111, 115, 105, 110, 103, 32, 102, 117, 110, 99, 116, 105, 111, 110, 32, 116, 111, 32, 114, 101, 116, 117, 114, 110, 32, 116, 104, 101, 32, 115, 97, 109, 101, 32, 82, 101, 115, 117, 108, 116, 32, 116, 0 }));
  }
  (void)(0);
  return;
}
void driver_diagnostic_typeck_break_continue_outside(int32_t line, int32_t col, int32_t is_break) {
  {
    if ((is_break !=0)) {
      (void)(lsp_diag_report_typeck(line, col, (uint8_t[]){98, 114, 101, 97, 107, 32, 111, 110, 108, 121, 32, 97, 108, 108, 111, 119, 101, 100, 32, 105, 110, 115, 105, 100, 101, 32, 97, 32, 108, 111, 111, 112, 0 }));
    } else {
      (void)(lsp_diag_report_typeck(line, col, (uint8_t[]){99, 111, 110, 116, 105, 110, 117, 101, 32, 111, 110, 108, 121, 32, 97, 108, 108, 111, 119, 101, 100, 32, 105, 110, 115, 105, 100, 101, 32, 97, 32, 108, 111, 111, 112, 0 }));
    }
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
extern void diag_report(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * msg, uint8_t * detail);
extern void lsp_diag_add(int32_t line, int32_t col, int32_t severity, uint8_t * msg);
extern void driver_check_diag_emitted_note(void);
int32_t driver_parse_strict_enabled(void) {
  return driver_env_flag_truthy((uint8_t[]){83, 72, 85, 88, 95, 80, 65, 82, 83, 69, 95, 83, 84, 82, 73, 67, 84, 0 });
}
void driver_diag_note(uint8_t * msg) {
  {
    uint8_t * m = msg;
    if ((m ==0)) {
      (void)((m = (uint8_t[]){0 }));
    }
    (void)(diag_report(((uint8_t *)(0)), 0, 0, (uint8_t[]){110, 111, 116, 101, 0 }, m, ((uint8_t *)(0))));
  }
  (void)(0);
  return;
}
void driver_diag_report_prefixed(int32_t line, int32_t col, uint8_t * msg) {
  {
    uint8_t * m2 = msg;
    if ((lsp_diag_get_enabled() !=0)) {
      int32_t ln = line;
      int32_t cl = col;
      if ((ln <=0)) {
        (void)((ln = 1));
      }
      if ((cl <=0)) {
        (void)((cl = 1));
      }
      uint8_t * m = msg;
      if ((m ==((uint8_t *)(0)))) {
        (void)((m = (uint8_t[]){0 }));
      }
      (void)(lsp_diag_add(ln, cl, 1, m));
      return;
    }
    if ((driver_check_only_get() !=0)) {
      (void)(driver_check_diag_emitted_note());
    }
    if ((m2 ==((uint8_t *)(0)))) {
      (void)((m2 = (uint8_t[]){0 }));
    }
    (void)(diag_report(((uint8_t *)(0)), line, col, ((uint8_t *)(0)), m2, m2));
  }
  (void)(0);
  return;
}
void driver_diag_pipe_note(int32_t kind, int32_t a, int32_t b) {
  uint8_t msg[128] = {};
  if ((kind ==0)) {
    int32_t at = driver_diag_append_cstr(&((msg)[0]), 128, 0, (uint8_t[]){112, 105, 112, 101, 108, 105, 110, 101, 32, 100, 101, 98, 117, 103, 58, 32, 98, 101, 102, 111, 114, 101, 95, 99, 111, 100, 101, 103, 101, 110, 32, 110, 117, 109, 95, 102, 117, 110, 99, 115, 61, 0 });
    (void)((at = driver_diag_append_i32(&((msg)[0]), 128, at, a)));
    (void)((at = driver_diag_append_cstr(&((msg)[0]), 128, at, (uint8_t[]){32, 111, 117, 116, 95, 108, 101, 110, 61, 0 })));
    (void)((at = driver_diag_append_i32(&((msg)[0]), 128, at, b)));
    (void)(driver_diag_note(&((msg)[0])));
    return;
  }
  if ((kind ==1)) {
    int32_t at1 = driver_diag_append_cstr(&((msg)[0]), 128, 0, (uint8_t[]){112, 105, 112, 101, 108, 105, 110, 101, 32, 100, 101, 98, 117, 103, 58, 32, 101, 110, 116, 114, 121, 95, 115, 111, 117, 114, 99, 101, 95, 108, 101, 110, 61, 0 });
    (void)((at1 = driver_diag_append_i32(&((msg)[0]), 128, at1, a)));
    (void)(driver_diag_note(&((msg)[0])));
    return;
  }
  if ((kind ==2)) {
    int32_t at2 = driver_diag_append_cstr(&((msg)[0]), 128, 0, (uint8_t[]){112, 105, 112, 101, 108, 105, 110, 101, 32, 100, 101, 98, 117, 103, 58, 32, 97, 102, 116, 101, 114, 95, 101, 110, 116, 114, 121, 95, 112, 97, 114, 115, 101, 32, 110, 117, 109, 95, 102, 117, 110, 99, 115, 61, 0 });
    (void)((at2 = driver_diag_append_i32(&((msg)[0]), 128, at2, a)));
    (void)(driver_diag_note(&((msg)[0])));
    return;
  }
  if ((kind ==3)) {
    int32_t at3 = driver_diag_append_cstr(&((msg)[0]), 128, 0, (uint8_t[]){112, 105, 112, 101, 108, 105, 110, 101, 32, 100, 101, 98, 117, 103, 58, 32, 112, 105, 112, 101, 95, 109, 97, 114, 107, 101, 114, 61, 0 });
    (void)((at3 = driver_diag_append_i32(&((msg)[0]), 128, at3, a)));
    (void)(driver_diag_note(&((msg)[0])));
    return;
  }
  (void)(0);
  return;
}
int32_t driver_diag_parse_debug_enabled(void) {
  {
    if ((getenv((uint8_t[]){83, 72, 85, 88, 95, 68, 69, 66, 85, 71, 95, 80, 65, 82, 83, 69, 0 }) !=((uint8_t *)(0)))) {
      return 1;
    }
  }
  return driver_parse_strict_enabled();
}
void driver_debug_log(int32_t step) {
  if ((driver_diag_parse_debug_enabled() ==0)) {
    return;
  }
  uint8_t msg[128] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 128, 0, (uint8_t[]){112, 97, 114, 115, 101, 32, 100, 101, 98, 117, 103, 58, 32, 115, 116, 101, 112, 61, 0 });
  (void)((at = driver_diag_append_i32(&((msg)[0]), 128, at, step)));
  (void)(driver_diag_note(&((msg)[0])));
}
void parser_diag_tok_kind(int32_t k) {
  if ((driver_diag_parse_debug_enabled() ==0)) {
    return;
  }
  uint8_t msg[128] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 128, 0, (uint8_t[]){112, 97, 114, 115, 101, 32, 100, 101, 98, 117, 103, 58, 32, 114, 46, 116, 111, 107, 46, 107, 105, 110, 100, 61, 0 });
  (void)((at = driver_diag_append_i32(&((msg)[0]), 128, at, k)));
  (void)(driver_diag_note(&((msg)[0])));
}
void parser_diag_ident_len(int32_t len) {
  if ((driver_diag_parse_debug_enabled() ==0)) {
    return;
  }
  uint8_t msg[128] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 128, 0, (uint8_t[]){112, 97, 114, 115, 101, 32, 100, 101, 98, 117, 103, 58, 32, 102, 105, 114, 115, 116, 32, 105, 100, 101, 110, 116, 95, 108, 101, 110, 61, 0 });
  (void)((at = driver_diag_append_i32(&((msg)[0]), 128, at, len)));
  (void)(driver_diag_note(&((msg)[0])));
}
void parser_diag_scan_fail(int32_t step) {
  if ((driver_diag_parse_debug_enabled() ==0)) {
    return;
  }
  uint8_t msg[128] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 128, 0, (uint8_t[]){108, 105, 98, 114, 97, 114, 121, 32, 115, 99, 97, 110, 32, 102, 97, 105, 108, 101, 100, 32, 97, 116, 32, 115, 116, 101, 112, 61, 0 });
  (void)((at = driver_diag_append_i32(&((msg)[0]), 128, at, step)));
  (void)(driver_diag_note(&((msg)[0])));
}
void driver_diagnostic_typeck_block_enter(int32_t func_idx, int32_t block_ref, int32_t n_const, int32_t n_let, int32_t n_loop, int32_t n_for, int32_t n_expr, int32_t final_ref) {
  {
    if ((getenv((uint8_t[]){83, 72, 85, 88, 95, 84, 89, 80, 69, 67, 75, 95, 66, 76, 79, 67, 75, 0 }) ==((uint8_t *)(0)))) {
      return;
    }
  }
  uint8_t msg[240] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 240, 0, (uint8_t[]){116, 121, 112, 101, 99, 107, 32, 98, 108, 111, 99, 107, 32, 100, 101, 98, 117, 103, 58, 32, 102, 117, 110, 99, 95, 105, 100, 120, 61, 0 });
  (void)((at = driver_diag_append_i32(&((msg)[0]), 240, at, func_idx)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 240, at, (uint8_t[]){32, 98, 108, 111, 99, 107, 95, 114, 101, 102, 61, 0 })));
  (void)((at = driver_diag_append_i32(&((msg)[0]), 240, at, block_ref)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 240, at, (uint8_t[]){32, 99, 111, 110, 115, 116, 61, 0 })));
  (void)((at = driver_diag_append_i32(&((msg)[0]), 240, at, n_const)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 240, at, (uint8_t[]){32, 108, 101, 116, 61, 0 })));
  (void)((at = driver_diag_append_i32(&((msg)[0]), 240, at, n_let)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 240, at, (uint8_t[]){32, 119, 104, 105, 108, 101, 61, 0 })));
  (void)((at = driver_diag_append_i32(&((msg)[0]), 240, at, n_loop)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 240, at, (uint8_t[]){32, 102, 111, 114, 61, 0 })));
  (void)((at = driver_diag_append_i32(&((msg)[0]), 240, at, n_for)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 240, at, (uint8_t[]){32, 101, 120, 112, 114, 95, 115, 116, 109, 116, 61, 0 })));
  (void)((at = driver_diag_append_i32(&((msg)[0]), 240, at, n_expr)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 240, at, (uint8_t[]){32, 102, 105, 110, 97, 108, 95, 101, 120, 112, 114, 61, 0 })));
  (void)((at = driver_diag_append_i32(&((msg)[0]), 240, at, final_ref)));
  (void)(driver_diag_note(&((msg)[0])));
}
void driver_diagnostic_typeck_fn_enter(int32_t func_idx, uint8_t * name, int32_t name_len) {
  {
    if ((getenv((uint8_t[]){83, 72, 85, 88, 95, 84, 89, 80, 69, 67, 75, 95, 70, 78, 0 }) ==((uint8_t *)(0)))) {
      return;
    }
  }
  uint8_t msg[160] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 160, 0, (uint8_t[]){116, 121, 112, 101, 99, 107, 32, 102, 117, 110, 99, 116, 105, 111, 110, 32, 100, 101, 98, 117, 103, 58, 32, 102, 117, 110, 99, 95, 105, 100, 120, 61, 0 });
  (void)((at = driver_diag_append_i32(&((msg)[0]), 160, at, func_idx)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 160, at, (uint8_t[]){32, 110, 97, 109, 101, 61, 0 })));
  if (((name !=((uint8_t *)(0))) && (name_len > 0))) {
    (void)((at = driver_diag_append_name(&((msg)[0]), 160, at, name, name_len)));
  } else {
    (void)((at = driver_diag_append_cstr(&((msg)[0]), 160, at, (uint8_t[]){40, 117, 110, 107, 110, 111, 119, 110, 41, 0 })));
  }
  (void)(driver_diag_note(&((msg)[0])));
}
void driver_diagnostic_typeck_var_resolution(int32_t expr_ref, uint8_t * name, int32_t name_len, int32_t func_idx, int32_t block_ref, int32_t source, int32_t type_ref) {
  {
    if ((getenv((uint8_t[]){83, 72, 85, 88, 95, 84, 89, 80, 69, 67, 75, 95, 86, 65, 82, 0 }) ==((uint8_t *)(0)))) {
      return;
    }
  }
  uint8_t msg[200] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 200, 0, (uint8_t[]){116, 121, 112, 101, 99, 107, 32, 118, 97, 114, 32, 100, 101, 98, 117, 103, 58, 32, 101, 120, 112, 114, 61, 0 });
  (void)((at = driver_diag_append_i32(&((msg)[0]), 200, at, expr_ref)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 200, at, (uint8_t[]){32, 110, 97, 109, 101, 61, 0 })));
  if (((name !=((uint8_t *)(0))) && (name_len > 0))) {
    (void)((at = driver_diag_append_name(&((msg)[0]), 200, at, name, name_len)));
  } else {
    (void)((at = driver_diag_append_cstr(&((msg)[0]), 200, at, (uint8_t[]){63, 0 })));
  }
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 200, at, (uint8_t[]){32, 102, 117, 110, 99, 61, 0 })));
  (void)((at = driver_diag_append_i32(&((msg)[0]), 200, at, func_idx)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 200, at, (uint8_t[]){32, 98, 108, 111, 99, 107, 61, 0 })));
  (void)((at = driver_diag_append_i32(&((msg)[0]), 200, at, block_ref)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 200, at, (uint8_t[]){32, 115, 111, 117, 114, 99, 101, 61, 0 })));
  (void)((at = driver_diag_append_i32(&((msg)[0]), 200, at, source)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 200, at, (uint8_t[]){32, 116, 121, 112, 101, 95, 114, 101, 102, 61, 0 })));
  (void)((at = driver_diag_append_i32(&((msg)[0]), 200, at, type_ref)));
  (void)(driver_diag_note(&((msg)[0])));
}
uint8_t * driver_typeck_diag_scratch_expect(void) {
  return &((g_type_diag_scratch_expect)[0]);
}
uint8_t * driver_typeck_diag_scratch_found(void) {
  return &((g_type_diag_scratch_found)[0]);
}
void driver_diag_fill_expr_part(uint8_t * dst, int32_t cap, uint8_t * expr_buf, int32_t expr_len) {
  if ((dst ==0)) {
    return;
  }
  if ((cap <=0)) {
    return;
  }
  int32_t el = 0;
  if ((expr_buf !=0)) {
    if ((expr_len > 0)) {
      (void)((el = expr_len));
    }
  }
  if ((el > 0)) {
    if ((el < cap)) {
      int32_t n = driver_diag_copy_bytes(dst, ((int64_t)(cap)), expr_buf, el);
      return;
    }
  }
  (void)(((dst)[0] = 63));
  if ((cap > 1)) {
    (void)(((dst)[1] = 0));
  }
}
void driver_diag_build_expected_found(uint8_t * msg, int32_t msg_cap, uint8_t * pref, uint8_t * epart, uint8_t * fpart) {
  uint8_t * mid = (uint8_t[]){44, 32, 102, 111, 117, 110, 100, 32, 0 };
  int32_t at = driver_diag_append_cstr(msg, msg_cap, 0, pref);
  (void)((at = driver_diag_append_cstr(msg, msg_cap, at, epart)));
  (void)((at = driver_diag_append_cstr(msg, msg_cap, at, mid)));
  (void)((at = driver_diag_append_cstr(msg, msg_cap, at, fpart)));
}
void driver_diagnostic_typeck_return_unresolved(int32_t line, int32_t col, uint8_t * expr_buf, int32_t expr_len) {
  uint8_t expr_part[128] = {};
  uint8_t msg[240] = {};
  (void)(driver_diag_fill_expr_part(&((expr_part)[0]), 128, expr_buf, expr_len));
  uint8_t * pref = (uint8_t[]){116, 121, 112, 101, 99, 107, 32, 101, 114, 114, 111, 114, 58, 32, 99, 97, 110, 110, 111, 116, 32, 114, 101, 115, 111, 108, 118, 101, 32, 114, 101, 116, 117, 114, 110, 32, 115, 117, 98, 101, 120, 112, 114, 101, 115, 115, 105, 111, 110, 58, 32, 0 };
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 240, 0, pref);
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 240, at, &((expr_part)[0]))));
  (void)(driver_diag_report_prefixed(line, col, &((msg)[0])));
}
void driver_diagnostic_typeck_return_subexpr(int32_t line, int32_t col, uint8_t * expr_buf, int32_t expr_len) {
  uint8_t expr_part[128] = {};
  uint8_t msg[240] = {};
  (void)(driver_diag_fill_expr_part(&((expr_part)[0]), 128, expr_buf, expr_len));
  uint8_t * pref = (uint8_t[]){116, 121, 112, 101, 99, 107, 32, 110, 111, 116, 101, 58, 32, 114, 101, 116, 117, 114, 110, 32, 115, 117, 98, 101, 120, 112, 114, 101, 115, 115, 105, 111, 110, 58, 32, 0 };
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 240, 0, pref);
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 240, at, &((expr_part)[0]))));
  (void)(driver_diag_report_prefixed(line, col, &((msg)[0])));
}
void driver_diagnostic_typeck_return_mismatch(int32_t line, int32_t col, uint8_t * expect_buf, int32_t expect_len, uint8_t * found_buf, int32_t found_len) {
  uint8_t epart[112] = {};
  uint8_t fpart[112] = {};
  uint8_t msg[240] = {};
  (void)(driver_diag_fill_expr_part(&((epart)[0]), 112, expect_buf, expect_len));
  (void)(driver_diag_fill_expr_part(&((fpart)[0]), 112, found_buf, found_len));
  uint8_t * pref = (uint8_t[]){116, 121, 112, 101, 99, 107, 32, 101, 114, 114, 111, 114, 58, 32, 114, 101, 116, 117, 114, 110, 32, 101, 120, 112, 114, 101, 115, 115, 105, 111, 110, 32, 116, 121, 112, 101, 32, 109, 105, 115, 109, 97, 116, 99, 104, 58, 32, 101, 120, 112, 101, 99, 116, 101, 100, 32, 0 };
  (void)(driver_diag_build_expected_found(&((msg)[0]), 240, pref, &((epart)[0]), &((fpart)[0])));
  (void)(driver_diag_report_prefixed(line, col, &((msg)[0])));
}
void driver_diagnostic_typeck_assign_mismatch(int32_t is_compound, int32_t line, int32_t col, uint8_t * expect_buf, int32_t expect_len, uint8_t * found_buf, int32_t found_len) {
  uint8_t epart[112] = {};
  uint8_t fpart[112] = {};
  uint8_t msg[240] = {};
  (void)(driver_diag_fill_expr_part(&((epart)[0]), 112, expect_buf, expect_len));
  (void)(driver_diag_fill_expr_part(&((fpart)[0]), 112, found_buf, found_len));
  uint8_t * pref = (uint8_t[]){116, 121, 112, 101, 99, 107, 32, 101, 114, 114, 111, 114, 58, 32, 97, 115, 115, 105, 103, 110, 109, 101, 110, 116, 32, 116, 121, 112, 101, 32, 109, 105, 115, 109, 97, 116, 99, 104, 58, 32, 101, 120, 112, 101, 99, 116, 101, 100, 32, 0 };
  if ((is_compound !=0)) {
    (void)((pref = (uint8_t[]){116, 121, 112, 101, 99, 107, 32, 101, 114, 114, 111, 114, 58, 32, 99, 111, 109, 112, 111, 117, 110, 100, 32, 97, 115, 115, 105, 103, 110, 109, 101, 110, 116, 32, 116, 121, 112, 101, 32, 109, 105, 115, 109, 97, 116, 99, 104, 58, 32, 101, 120, 112, 101, 99, 116, 101, 100, 32, 0 }));
  }
  (void)(driver_diag_build_expected_found(&((msg)[0]), 240, pref, &((epart)[0]), &((fpart)[0])));
  (void)(driver_diag_report_prefixed(line, col, &((msg)[0])));
}
void driver_diagnostic_typeck_call_not_generic(int32_t line, int32_t col, uint8_t * name, int32_t name_len) {
  uint8_t msg[240] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 240, 0, (uint8_t[]){102, 117, 110, 99, 116, 105, 111, 110, 32, 39, 0 });
  (void)((at = driver_diag_append_name(&((msg)[0]), 240, at, name, name_len)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 240, at, (uint8_t[]){39, 32, 105, 115, 32, 110, 111, 116, 32, 103, 101, 110, 101, 114, 105, 99, 32, 98, 117, 116, 32, 116, 121, 112, 101, 32, 97, 114, 103, 117, 109, 101, 110, 116, 115, 32, 119, 101, 114, 101, 32, 112, 114, 111, 118, 105, 100, 101, 100, 0 })));
  {
    (void)(lsp_diag_report_typeck(line, col, &((msg)[0])));
  }
}
void driver_diagnostic_typeck_call_wrong_num_type_args(int32_t line, int32_t col, uint8_t * name, int32_t name_len, int32_t expect_n, int32_t got_n) {
  uint8_t msg[240] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 240, 0, (uint8_t[]){103, 101, 110, 101, 114, 105, 99, 32, 102, 117, 110, 99, 116, 105, 111, 110, 32, 39, 0 });
  (void)((at = driver_diag_append_name(&((msg)[0]), 240, at, name, name_len)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 240, at, (uint8_t[]){39, 32, 101, 120, 112, 101, 99, 116, 115, 32, 0 })));
  (void)((at = driver_diag_append_i32(&((msg)[0]), 240, at, expect_n)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 240, at, (uint8_t[]){32, 116, 121, 112, 101, 32, 97, 114, 103, 117, 109, 101, 110, 116, 115, 44, 32, 103, 111, 116, 32, 0 })));
  (void)((at = driver_diag_append_i32(&((msg)[0]), 240, at, got_n)));
  {
    (void)(lsp_diag_report_typeck(line, col, &((msg)[0])));
  }
}
void driver_diagnostic_typeck_call_requires_type_args(int32_t line, int32_t col, uint8_t * name, int32_t name_len) {
  uint8_t msg[280] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 280, 0, (uint8_t[]){103, 101, 110, 101, 114, 105, 99, 32, 102, 117, 110, 99, 116, 105, 111, 110, 32, 39, 0 });
  (void)((at = driver_diag_append_name(&((msg)[0]), 280, at, name, name_len)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 280, at, (uint8_t[]){39, 32, 114, 101, 113, 117, 105, 114, 101, 115, 32, 116, 121, 112, 101, 32, 97, 114, 103, 117, 109, 101, 110, 116, 115, 32, 40, 101, 46, 103, 46, 32, 0 })));
  (void)((at = driver_diag_append_name(&((msg)[0]), 280, at, name, name_len)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 280, at, (uint8_t[]){60, 84, 121, 112, 101, 62, 40, 46, 46, 46, 41, 41, 0 })));
  {
    (void)(lsp_diag_report_typeck(line, col, &((msg)[0])));
  }
}
void driver_diagnostic_typeck_struct_padding_before(uint8_t * sname, int32_t sname_len, int32_t gap, uint8_t * fname, int32_t fname_len) {
  uint8_t msg[320] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 320, 0, (uint8_t[]){115, 116, 114, 117, 99, 116, 32, 39, 0 });
  (void)((at = driver_diag_append_name(&((msg)[0]), 320, at, sname, sname_len)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 320, at, (uint8_t[]){39, 32, 104, 97, 115, 32, 0 })));
  (void)((at = driver_diag_append_i32(&((msg)[0]), 320, at, gap)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 320, at, (uint8_t[]){32, 98, 121, 116, 101, 40, 115, 41, 32, 105, 109, 112, 108, 105, 99, 105, 116, 32, 112, 97, 100, 100, 105, 110, 103, 32, 98, 101, 102, 111, 114, 101, 32, 102, 105, 101, 108, 100, 32, 39, 0 })));
  (void)((at = driver_diag_append_name(&((msg)[0]), 320, at, fname, fname_len)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 320, at, (uint8_t[]){39, 59, 32, 97, 100, 100, 32, 101, 120, 112, 108, 105, 99, 105, 116, 32, 112, 97, 100, 100, 105, 110, 103, 32, 102, 105, 101, 108, 100, 32, 111, 114, 32, 97, 108, 108, 111, 119, 40, 112, 97, 100, 100, 105, 110, 103, 41, 0 })));
  {
    (void)(lsp_diag_report_typeck(0, 0, &((msg)[0])));
  }
}
void driver_diagnostic_typeck_struct_padding_trailing(uint8_t * sname, int32_t sname_len, int32_t gap) {
  uint8_t msg[320] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 320, 0, (uint8_t[]){115, 116, 114, 117, 99, 116, 32, 39, 0 });
  (void)((at = driver_diag_append_name(&((msg)[0]), 320, at, sname, sname_len)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 320, at, (uint8_t[]){39, 32, 104, 97, 115, 32, 0 })));
  (void)((at = driver_diag_append_i32(&((msg)[0]), 320, at, gap)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 320, at, (uint8_t[]){32, 98, 121, 116, 101, 40, 115, 41, 32, 105, 109, 112, 108, 105, 99, 105, 116, 32, 116, 114, 97, 105, 108, 105, 110, 103, 32, 112, 97, 100, 100, 105, 110, 103, 59, 32, 97, 100, 100, 32, 101, 120, 112, 108, 105, 99, 105, 116, 32, 112, 97, 100, 100, 105, 110, 103, 32, 102, 105, 101, 108, 100, 32, 0 })));
  {
    (void)(lsp_diag_report_typeck(0, 0, &((msg)[0])));
  }
}
void driver_diagnostic_typeck_struct_field_bad_size(uint8_t * sname, int32_t sname_len, uint8_t * fname, int32_t fname_len) {
  uint8_t msg[280] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 280, 0, (uint8_t[]){115, 116, 114, 117, 99, 116, 32, 39, 0 });
  (void)((at = driver_diag_append_name(&((msg)[0]), 280, at, sname, sname_len)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 280, at, (uint8_t[]){39, 32, 102, 105, 101, 108, 100, 32, 39, 0 })));
  (void)((at = driver_diag_append_name(&((msg)[0]), 280, at, fname, fname_len)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 280, at, (uint8_t[]){39, 32, 104, 97, 115, 32, 117, 110, 107, 110, 111, 119, 110, 32, 111, 114, 32, 105, 110, 118, 97, 108, 105, 100, 32, 116, 121, 112, 101, 32, 115, 105, 122, 101, 0 })));
  {
    (void)(lsp_diag_report_typeck(0, 0, &((msg)[0])));
  }
}
void driver_diagnostic_asm_unsupported_expr(int32_t kind) {
  uint8_t msg[96] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 96, 0, (uint8_t[]){97, 115, 109, 32, 99, 111, 100, 101, 103, 101, 110, 32, 117, 110, 115, 117, 112, 112, 111, 114, 116, 101, 100, 32, 69, 120, 112, 114, 75, 105, 110, 100, 61, 0 });
  (void)((at = driver_diag_append_i32(&((msg)[0]), 96, at, kind)));
  (void)(driver_diag_note(&((msg)[0])));
}
void driver_diagnostic_asm_elf_unresolved_patch(uint8_t * name, int32_t len) {
  uint8_t namebuf[65] = {};
  (void)(driver_diag_fill_expr_part(&((namebuf)[0]), 65, name, len));
  uint8_t msg[160] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 160, 0, (uint8_t[]){101, 108, 102, 32, 117, 110, 114, 101, 115, 111, 108, 118, 101, 100, 32, 112, 97, 116, 99, 104, 32, 108, 97, 98, 101, 108, 32, 110, 97, 109, 101, 95, 108, 101, 110, 61, 0 });
  (void)((at = driver_diag_append_i32(&((msg)[0]), 160, at, len)));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 160, at, (uint8_t[]){32, 110, 97, 109, 101, 61, 39, 0 })));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 160, at, &((namebuf)[0]))));
  (void)((at = driver_diag_append_cstr(&((msg)[0]), 160, at, (uint8_t[]){39, 0 })));
  (void)(driver_diag_note(&((msg)[0])));
}
void driver_diagnostic_asm_macho_empty_reloc(int32_t reloc_idx) {
  uint8_t msg[96] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 96, 0, (uint8_t[]){109, 97, 99, 104, 111, 32, 101, 109, 112, 116, 121, 32, 114, 101, 108, 111, 99, 32, 115, 121, 109, 98, 111, 108, 32, 97, 116, 32, 105, 100, 120, 61, 0 });
  (void)((at = driver_diag_append_i32(&((msg)[0]), 96, at, reloc_idx)));
  (void)(driver_diag_note(&((msg)[0])));
}
void driver_diagnostic_asm_macho_missing_und_reloc(int32_t reloc_idx) {
  uint8_t msg[96] = {};
  int32_t at = driver_diag_append_cstr(&((msg)[0]), 96, 0, (uint8_t[]){109, 97, 99, 104, 111, 32, 117, 110, 100, 101, 102, 32, 114, 101, 108, 111, 99, 32, 110, 111, 116, 32, 105, 110, 32, 117, 110, 100, 32, 112, 111, 111, 108, 32, 97, 116, 32, 105, 100, 120, 61, 0 });
  (void)((at = driver_diag_append_i32(&((msg)[0]), 96, at, reloc_idx)));
  (void)(driver_diag_note(&((msg)[0])));
}
extern int32_t lsp_diag_get_enabled_impl(void);
int32_t lsp_diag_get_enabled(void) {
  {
    return lsp_diag_get_enabled_impl();
  }
  return 0;
}
