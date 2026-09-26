/* AUTO: strong Win link stubs for PE-egg phase1.
 * Merge LAST with ld -r --allow-multiple-definition so real bodies win.
 * PE/COFF weak attrs do not satisfy final EXE undefs.
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>

/* Class Z: was return -1 (false error). Twin FROM_X. */
extern int32_t asm_module_is_parser_emit_heavy(void *m);
extern int32_t pipeline_module_func_name_equal_at(void *m, int32_t func_index, const uint8_t *name, int32_t nlen);

int32_t asm_parser_emit_heavy_safe_helper(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_SAFE_EQ(n, l) \
  do { \
    if (pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)(n), (l))) \
      return 1; \
  } while (0)
  PARSER_SAFE_EQ("get_module_num_imports", 22);
  PARSER_SAFE_EQ("expr_ref_is_assign_lvalue", 25);
  PARSER_SAFE_EQ("copy_slice_to_name64", 20);
  PARSER_SAFE_EQ("copy_slice_to_name64_at_end", 27);
  PARSER_SAFE_EQ("copy_slice_to_param32", 21);
  PARSER_SAFE_EQ("copy_slice_to_param32_at_end", 28);
  PARSER_SAFE_EQ("copy_slice_to_name64_buf", 24);
  PARSER_SAFE_EQ("copy_slice_to_name64_at_end_buf", 31);
  PARSER_SAFE_EQ("copy_slice_to_param32_at_end_buf", 32);
  PARSER_SAFE_EQ("copy_slice_to_param32_buf", 25);
  PARSER_SAFE_EQ("get_module_import_path", 22);
  PARSER_SAFE_EQ("copy_module_import_path64", 25);
  PARSER_SAFE_EQ("parse_one_function_library_buf", 30);
  PARSER_SAFE_EQ("parse_one_function_library_into_buf", 35);
  PARSER_SAFE_EQ("parse_one_function_buf_into", 27);
  PARSER_SAFE_EQ("parse_into_init", 15);
  PARSER_SAFE_EQ("parse_one_function_library_into", 31);
  PARSER_SAFE_EQ("pipeline_module_reset_parse_counters", 36);
  PARSER_SAFE_EQ("extern_parse_set_fail", 21);
  PARSER_SAFE_EQ("extern_parse_pool_ptr", 21);
  PARSER_SAFE_EQ("onefunc_result_pool_ptr", 23);
  PARSER_SAFE_EQ("set_onefunc_fail", 16);
  PARSER_SAFE_EQ("copy_lex_from_import_into", 25);
  PARSER_SAFE_EQ("lex_from_next_into", 18);
  PARSER_SAFE_EQ("lex_from_result_ptr_into", 24);
  PARSER_SAFE_EQ("lex_from_onefunc_next_into", 26);
  PARSER_SAFE_EQ("write_extern_params_to_pools", 28);
  PARSER_SAFE_EQ("module_register_arena_func", 26);
  PARSER_SAFE_EQ("is_pointee_type_token", 21);
  PARSER_SAFE_EQ("compound_assign_token_to_expr_kind", 34);
  PARSER_SAFE_EQ("import_path_dot_segment_copy", 28);
  PARSER_SAFE_EQ("parser_alloc_vector_type_ref", 28);
  PARSER_SAFE_EQ("parse_peek_function_name_buf", 28);
  PARSER_SAFE_EQ("lexer_pos_before_run", 20);
  PARSER_SAFE_EQ("parser_match_kw_immediately_before", 34);
  PARSER_SAFE_EQ("import_path_dot_segment_len", 27);
  PARSER_SAFE_EQ("is_compound_assign_token", 24);
  PARSER_SAFE_EQ("struct_field_name_tok_kind", 26);
  PARSER_SAFE_EQ("struct_field_continues_tok_kind", 31);
  PARSER_SAFE_EQ("module_try_register_enum_name", 29);
  PARSER_SAFE_EQ("struct_layout_name_exists_arr", 29);
  PARSER_SAFE_EQ("struct_layout_first_name_match_idx", 34);
  PARSER_SAFE_EQ("struct_layout_placeholder_idx", 29);
  PARSER_SAFE_EQ("lexer_token_run_len", 19);
  PARSER_SAFE_EQ("module_append_enum_variants_and_skip_body_into_buf", 50);
  PARSER_SAFE_EQ("skip_balanced_parens_into_buf", 29);
  PARSER_SAFE_EQ("skip_balanced_braces_into_buf", 29);
  PARSER_SAFE_EQ("skip_one_enum_into_buf", 22);
  PARSER_SAFE_EQ("skip_one_struct_into_buf", 24);
  PARSER_SAFE_EQ("skip_one_trait_into_buf", 23);
  PARSER_SAFE_EQ("skip_one_impl_into_buf", 22);
  PARSER_SAFE_EQ("skip_one_extern_into_buf", 24);
  PARSER_SAFE_EQ("skip_one_function_full_into_buf", 31);
  PARSER_SAFE_EQ("skip_one_enum_register_into_buf", 31);
  PARSER_SAFE_EQ("parse_one_extern_and_add_into_buf", 33);
  PARSER_SAFE_EQ("diag_skip_let_const_buf", 23);
  PARSER_SAFE_EQ("body_skip_let_const_then_if_buf", 31);
  PARSER_SAFE_EQ("skip_balanced_parens_buf", 24);
  PARSER_SAFE_EQ("skip_balanced_braces_buf", 24);
  PARSER_SAFE_EQ("skip_one_function_full_buf", 26);
  PARSER_SAFE_EQ("skip_one_if_core_buf", 20);
  PARSER_SAFE_EQ("skip_one_if_statement_buf", 25);
  PARSER_SAFE_EQ("skip_one_enum_buf", 17);
  PARSER_SAFE_EQ("skip_one_trait_buf", 18);
  PARSER_SAFE_EQ("skip_one_impl_buf", 17);
  PARSER_SAFE_EQ("skip_one_extern_buf", 19);
  PARSER_SAFE_EQ("skip_one_struct_buf", 19);
  PARSER_SAFE_EQ("parse_into_try_skip_allow_buf", 29);
  PARSER_SAFE_EQ("try_skip_allow_padding_struct_buf", 33);
  PARSER_SAFE_EQ("lex_from_library_into", 21);
  PARSER_SAFE_EQ("lex_from_try_skip_into", 22);
  PARSER_SAFE_EQ("lex_from_library", 16);
  PARSER_SAFE_EQ("lex_from_try_skip", 17);
  PARSER_SAFE_EQ("advance_past_stmt_semicolon_into", 32);
  PARSER_SAFE_EQ("advance_past_cond_rparen_into", 29);
  PARSER_SAFE_EQ("first_token_kind", 16);
  PARSER_SAFE_EQ("diag_first_ident_len", 20);
  PARSER_SAFE_EQ("parser_rewind_lex_for_following_stmt", 36);
  PARSER_SAFE_EQ("lex_at_token_from_result", 24);
  PARSER_SAFE_EQ("struct_field_name_from_tok", 26);
  PARSER_SAFE_EQ("diag_skip_let_const_into", 24);
  PARSER_SAFE_EQ("diag_skip_let_const", 19);
  PARSER_SAFE_EQ("body_skip_let_const_then_if_into", 32);
  PARSER_SAFE_EQ("body_skip_let_const_then_if", 27);
  PARSER_SAFE_EQ("skip_one_if_statement_into", 26);
  PARSER_SAFE_EQ("skip_one_if_core_into", 21);
  PARSER_SAFE_EQ("skip_one_if_statement", 21);
  PARSER_SAFE_EQ("skip_one_if_core", 16);
  PARSER_SAFE_EQ("skip_one_enum_into", 18);
  PARSER_SAFE_EQ("skip_one_impl_into", 18);
  PARSER_SAFE_EQ("skip_one_trait_into", 19);
  PARSER_SAFE_EQ("skip_one_extern_into", 20);
  PARSER_SAFE_EQ("parse_into_try_skip_allow_into", 30);
  PARSER_SAFE_EQ("parse_into_try_skip_allow_into_buf", 34);
  PARSER_SAFE_EQ("parse_into_set_main_index", 25);
  PARSER_SAFE_EQ("diag_token_after_collect_imports", 32);
  PARSER_SAFE_EQ("diag_parse_one_after_collect_imports", 36);
  PARSER_SAFE_EQ("parse_one_function_ok_for_pipeline", 34);
  PARSER_SAFE_EQ("skip_imports", 12);
  PARSER_SAFE_EQ("skip_one_struct", 15);
  PARSER_SAFE_EQ("skip_one_struct_into", 20);
  PARSER_SAFE_EQ("parse_one_extern_skip_into", 26);
  PARSER_SAFE_EQ("skip_one_enum", 13);
  PARSER_SAFE_EQ("skip_one_trait", 14);
  PARSER_SAFE_EQ("skip_one_impl", 13);
  PARSER_SAFE_EQ("skip_one_extern", 15);
  PARSER_SAFE_EQ("skip_one_function_full", 22);
  PARSER_SAFE_EQ("collect_imports", 15);
  PARSER_SAFE_EQ("consume_qualified_type_ident_name", 33);
  PARSER_SAFE_EQ("expr_set_common_zeros", 21);
  PARSER_SAFE_EQ("fill_block_const_let_from_res", 29);
  PARSER_SAFE_EQ("append_block_lets_from_res", 26);
  PARSER_SAFE_EQ("diag_after_imports_then_structs", 31);
  PARSER_SAFE_EQ("diag_fail_at_token_kind", 23);
  PARSER_SAFE_EQ("diag_lex_after_imports", 22);
  PARSER_SAFE_EQ("skip_balanced_parens", 20);
  PARSER_SAFE_EQ("skip_balanced_parens_into", 25);
  PARSER_SAFE_EQ("skip_balanced_braces", 20);
  PARSER_SAFE_EQ("skip_balanced_braces_into", 25);
  PARSER_SAFE_EQ("parse_primary_into", 18);
  PARSER_SAFE_EQ("parse_unary_into", 16);
  PARSER_SAFE_EQ("parse_cast_into", 15);
  PARSER_SAFE_EQ("parse_term_into", 15);
  PARSER_SAFE_EQ("parse_addsub_into", 17);
  PARSER_SAFE_EQ("parse_shift_into", 16);
  PARSER_SAFE_EQ("parse_relcompare_into", 21);
  PARSER_SAFE_EQ("parse_compare_into", 18);
  PARSER_SAFE_EQ("parse_bitand_into", 17);
  PARSER_SAFE_EQ("parse_bitor_into", 16);
  PARSER_SAFE_EQ("parse_bitxor_into", 17);
  PARSER_SAFE_EQ("parse_logand_into", 17);
  PARSER_SAFE_EQ("parse_logor_into", 16);
  PARSER_SAFE_EQ("parse_ternary_into", 18);
  PARSER_SAFE_EQ("parse_assign_into", 17);
  PARSER_SAFE_EQ("parse_as_suffix_into", 20);
  PARSER_SAFE_EQ("parse_one_function_library", 26);
  PARSER_SAFE_EQ("parse_one_function_library_scan", 31);
  PARSER_SAFE_EQ("parse_into_try_skip_allow", 25);
  PARSER_SAFE_EQ("parse_one_extern_and_add_into", 29);
  PARSER_SAFE_EQ("parse_one_top_level_let_into", 28);
  PARSER_SAFE_EQ("parser_should_wrap_func_tail_in_return", 38);
  PARSER_SAFE_EQ("skip_one_enum_register_into", 27);
  PARSER_SAFE_EQ("skip_one_function_full_into", 27);
  PARSER_SAFE_EQ("alloc_pointee_type_ref_from_tok", 31);
  PARSER_SAFE_EQ("parse_struct_record_layout_into", 31);
  PARSER_SAFE_EQ("parse_type_ref_for_arena_into", 29);
  PARSER_SAFE_EQ("parse_cond_expr_into", 20);
  PARSER_SAFE_EQ("module_append_enum_variants_and_skip_body_into", 46);
  PARSER_SAFE_EQ("parse_body_let_bracket_compound_init_ref", 40);
  PARSER_SAFE_EQ("parser_vector_type_ref_from_ident_spelling", 42);
  PARSER_SAFE_EQ("collect_imports_buf", 19);
  PARSER_SAFE_EQ("skip_imports_buf", 16);
  PARSER_SAFE_EQ("diag_skip_let_const_into_buf", 28);
  PARSER_SAFE_EQ("body_skip_let_const_then_if_into_buf", 36);
  PARSER_SAFE_EQ("skip_one_if_core_into_buf", 25);
  PARSER_SAFE_EQ("skip_one_if_statement_into_buf", 30);
  PARSER_SAFE_EQ("first_token_kind_buf", 20);
  PARSER_SAFE_EQ("diag_first_ident_len_buf", 24);
  PARSER_SAFE_EQ("diag_lex_after_imports_buf", 26);
  PARSER_SAFE_EQ("diag_after_imports_then_structs_buf", 35);
  PARSER_SAFE_EQ("diag_fail_at_token_kind_buf", 27);
  PARSER_SAFE_EQ("parse_one_extern_skip_into_buf", 30);
  PARSER_SAFE_EQ("consume_qualified_type_ident_name_buf", 37);
  PARSER_SAFE_EQ("advance_past_stmt_semicolon_into_buf", 36);
  PARSER_SAFE_EQ("advance_past_cond_rparen_into_buf", 33);
  PARSER_SAFE_EQ("parse_primary_into_buf", 22);
  PARSER_SAFE_EQ("parse_unary_into_buf", 20);
  PARSER_SAFE_EQ("parse_cast_into_buf", 19);
  PARSER_SAFE_EQ("parse_term_into_buf", 19);
  PARSER_SAFE_EQ("parse_addsub_into_buf", 21);
  PARSER_SAFE_EQ("parse_shift_into_buf", 20);
  PARSER_SAFE_EQ("parse_relcompare_into_buf", 25);
  PARSER_SAFE_EQ("parse_compare_into_buf", 22);
  PARSER_SAFE_EQ("parse_bitand_into_buf", 21);
  PARSER_SAFE_EQ("parse_bitxor_into_buf", 21);
  PARSER_SAFE_EQ("parse_bitor_into_buf", 20);
  PARSER_SAFE_EQ("parse_logand_into_buf", 21);
  PARSER_SAFE_EQ("parse_logor_into_buf", 20);
  PARSER_SAFE_EQ("parse_ternary_into_buf", 22);
  PARSER_SAFE_EQ("parse_assign_into_buf", 21);
  PARSER_SAFE_EQ("parse_expr_into_buf", 19);
  PARSER_SAFE_EQ("finish_struct_lit_from_type_ident_into_buf", 42);
  PARSER_SAFE_EQ("parse_cond_expr_into_buf", 24);
  PARSER_SAFE_EQ("parse_if_stmt_into_buf", 22);
  PARSER_SAFE_EQ("parse_if_stmt_into", 18);
  PARSER_SAFE_EQ("parse_if_expr_into", 18);
  PARSER_SAFE_EQ("parse_match_into", 16);
  PARSER_SAFE_EQ("parse_match_subject_into", 24);
  PARSER_SAFE_EQ("parse_at_simd_builtin_into", 26);
  PARSER_SAFE_EQ("finish_struct_lit_from_type_ident_into", 38);
  PARSER_SAFE_EQ("parse_expr_with_leading_int_as_into", 35);
  PARSER_SAFE_EQ("parse_block_into_buf", 20);
  PARSER_SAFE_EQ("parse_if_expr_into_buf", 22);
  PARSER_SAFE_EQ("parse_match_subject_into_buf", 28);
  PARSER_SAFE_EQ("parse_match_into_buf", 20);
  PARSER_SAFE_EQ("parse_at_simd_builtin_into_buf", 30);
  PARSER_SAFE_EQ("parse_as_suffix_into_buf", 24);
  PARSER_SAFE_EQ("parse_type_ref_for_arena_into_buf", 33);
  PARSER_SAFE_EQ("parse_body_let_bracket_compound_init_ref_buf", 44);
  PARSER_SAFE_EQ("parse_struct_record_layout_into_buf", 35);
  PARSER_SAFE_EQ("parse_one_function_library_scan_buf", 35);
  PARSER_SAFE_EQ("alloc_pointee_type_ref_from_tok_buf", 35);
  PARSER_SAFE_EQ("parser_vector_type_ref_from_ident_spelling_buf", 46);
  PARSER_SAFE_EQ("parse_one_top_level_let_into_buf", 32);
  PARSER_SAFE_EQ("import_path_dot_segment_copy_buf", 32);
  PARSER_SAFE_EQ("parser_match_kw_immediately_before_buf", 38);
  PARSER_SAFE_EQ("struct_field_name_from_tok_buf", 30);
  PARSER_SAFE_EQ("parse_expr_with_leading_int_as_into_buf", 39);
  PARSER_SAFE_EQ("skip_one_enum_register_buf", 26);
  PARSER_SAFE_EQ("skip_balanced_parens_slice_into_buf", 35);
  PARSER_SAFE_EQ("skip_balanced_braces_slice_into_buf", 35);
  PARSER_SAFE_EQ("module_append_enum_variants_and_skip_body_slice_into_buf", 56);
  PARSER_SAFE_EQ("parse_one_extern_skip_buf", 25);
  PARSER_SAFE_EQ("parse_one_extern_and_add_buf", 28);
  PARSER_SAFE_EQ("parse_one_function_library_from_buf", 35);
  PARSER_SAFE_EQ("parse_into_try_skip_allow_from_buf", 34);
#undef PARSER_SAFE_EQ
  return 0;
}

typedef struct {
  const char *x_name;
  int32_t x_len;
  const char *c_name;
  int32_t c_len;
} wave120_thin_row_t;

static const wave120_thin_row_t k_wave120_parser_thin_delegate[] = {
    {"collect_imports_buf", 19, "parser_collect_imports_buf_glue", 31},
    {"advance_past_cond_rparen_into", 29, "parser_advance_past_cond_rparen_into_glue", 41},
    {"advance_past_stmt_semicolon_into", 32, "parser_advance_past_stmt_semicolon_into_glue", 44},
    {"alloc_pointee_type_ref_from_tok", 31, "parser_alloc_pointee_type_ref_from_tok_glue", 43},
    {"append_block_lets_from_res", 26, "parser_append_block_lets_from_res_glue", 38},
    {"body_skip_let_const_then_if_buf", 31, "parser_body_skip_let_const_then_if_buf_glue", 43},
    {"body_skip_let_const_then_if", 27, "parser_body_skip_let_const_then_if_glue", 39},
    {"body_skip_let_const_then_if_into", 32, "parser_body_skip_let_const_then_if_into_glue", 44},
    {"collect_imports", 15, "parser_collect_imports_glue", 27},
    {"copy_lex_from_import_into", 25, "parser_lex_copy_from_import_into_glue", 37},
    {"consume_qualified_type_ident_name", 33, "parser_consume_qualified_type_ident_name_glue", 45},
    {"diag_after_imports_then_structs", 31, "parser_diag_after_imports_then_structs_glue", 43},
    {"diag_fail_at_token_kind", 23, "parser_diag_fail_at_token_kind_glue", 35},
    {"diag_first_ident_len", 20, "parser_diag_first_ident_len_glue", 32},
    {"diag_lex_after_imports", 22, "parser_diag_lex_after_imports_glue", 34},
    {"diag_skip_let_const_buf", 23, "parser_diag_skip_let_const_buf_glue", 35},
    {"diag_skip_let_const", 19, "parser_diag_skip_let_const_glue", 31},
    {"diag_skip_let_const_into", 24, "parser_diag_skip_let_const_into_glue", 36},
    {"expr_set_common_zeros", 21, "parser_expr_set_common_zeros_glue", 33},
    {"fill_block_const_let_from_res", 29, "parser_fill_block_const_let_from_res_glue", 41},
    {"finish_struct_lit_from_type_ident_into", 38, "parser_finish_struct_lit_from_type_ident_into_glue", 50},
    {"first_token_kind", 16, "parser_first_token_kind_glue", 28},
    {"lex_at_token_from_result", 24, "parser_lex_at_token_from_result_glue", 36},
    {"lex_from_library", 16, "parser_lex_from_library_glue", 28},
    {"lex_from_library_into", 21, "parser_lex_from_library_into_glue", 33},
    {"lex_from_onefunc_next_into", 26, "parser_lex_from_onefunc_next_into_glue", 38},
    {"lex_from_next_into", 18, "parser_lex_from_next_into_glue", 30},
    {"lex_from_result_ptr_into", 24, "parser_lex_from_result_ptr_into_glue", 36},
    {"lex_from_try_skip", 17, "parser_lex_from_try_skip_glue", 29},
    {"lex_from_try_skip_into", 22, "parser_lex_from_try_skip_into_glue", 34},
    {"module_append_enum_variants_and_skip_body_into", 46, "parser_module_append_enum_variants_and_skip_body_into_glue", 58},
    {"parse_addsub_into", 17, "parser_parse_addsub_into_glue", 29},
    {"parse_as_suffix_into", 20, "parser_parse_as_suffix_into_glue", 32},
    {"parse_assign_into", 17, "parser_parse_assign_into_glue", 29},
    {"parse_at_simd_builtin_into", 26, "parser_parse_at_simd_builtin_into_glue", 38},
    {"parse_bitand_into", 17, "parser_parse_bitand_into_glue", 29},
    {"parse_bitor_into", 16, "parser_parse_bitor_into_glue", 28},
    {"parse_bitxor_into", 17, "parser_parse_bitxor_into_glue", 29},
    {"parse_body_let_bracket_compound_init_ref", 40, "parser_parse_body_let_bracket_compound_init_ref_glue", 52},
    {"parse_cast_into", 15, "parser_parse_cast_into_glue", 27},
    {"parse_compare_into", 18, "parser_parse_compare_into_glue", 30},
    {"parse_cond_expr_into", 20, "parser_parse_cond_expr_into_glue", 32},
    {"parse_if_expr_into", 18, "parser_parse_if_expr_into_glue", 30},
    {"parse_if_stmt_into", 18, "parser_parse_if_stmt_into_glue", 30},
    {"parse_into_try_skip_allow_buf", 29, "parser_parse_into_try_skip_allow_buf_glue", 41},
    {"parse_into_try_skip_allow", 25, "parser_parse_into_try_skip_allow_glue", 37},
    {"parse_into_try_skip_allow_into_buf", 34, "parser_parse_into_try_skip_allow_into_buf_glue", 46},
    {"parse_into_try_skip_allow_into", 30, "parser_parse_into_try_skip_allow_into_glue", 42},
    {"parse_into_set_main_index", 25, "parser_parse_into_set_main_index_glue", 37},
    {"parse_logand_into", 17, "parser_parse_logand_into_glue", 29},
    {"parse_logor_into", 16, "parser_parse_logor_into_glue", 28},
    {"parse_match_into", 16, "parser_parse_match_into_glue", 28},
    {"parse_match_subject_into", 24, "parser_parse_match_subject_into_glue", 36},
    {"parse_one_extern_and_add_into_buf", 33, "parser_parse_one_extern_and_add_into_buf_glue", 45},
    {"parse_one_extern_and_add_into", 29, "parser_parse_one_extern_and_add_into_glue", 41},
    {"parse_one_extern_skip_into", 26, "parser_parse_one_extern_skip_into_glue", 38},
    {"parse_one_function_buf_into", 27, "parser_parse_one_function_buf_into_glue", 39},
    {"parse_one_function_library", 26, "parser_parse_one_function_library_glue", 38},
    {"parse_one_function_library_into", 31, "parser_parse_one_function_library_into_glue", 43},
    {"parse_one_function_library_scan", 31, "parser_parse_one_function_library_scan_glue", 43},
    {"parse_one_top_level_let_into", 28, "parser_parse_one_top_level_let_into_glue", 40},
    {"parse_primary_into", 18, "parser_parse_primary_into_glue", 30},
    {"parse_relcompare_into", 21, "parser_parse_relcompare_into_glue", 33},
    {"parse_shift_into", 16, "parser_parse_shift_into_glue", 28},
    {"parse_struct_record_layout_into", 31, "parser_parse_struct_record_layout_into_glue", 43},
    {"parse_term_into", 15, "parser_parse_term_into_glue", 27},
    {"parse_ternary_into", 18, "parser_parse_ternary_into_glue", 30},
    {"parse_type_ref_for_arena_into", 29, "parser_parse_type_ref_for_arena_into_glue", 41},
    {"parse_unary_into", 16, "parser_parse_unary_into_glue", 28},
    {"parser_rewind_lex_for_following_stmt", 36, "parser_parser_rewind_lex_for_following_stmt_glue", 48},
    {"parser_vector_type_ref_from_ident_spelling", 42, "parser_parser_vector_type_ref_from_ident_spelling_glue", 54},
    {"skip_balanced_braces_buf", 24, "parser_skip_balanced_braces_buf_glue", 36},
    {"skip_balanced_braces", 20, "parser_skip_balanced_braces_glue", 32},
    {"skip_balanced_braces_into", 25, "parser_skip_balanced_braces_into_glue", 37},
    {"skip_balanced_parens_buf", 24, "parser_skip_balanced_parens_buf_glue", 36},
    {"skip_balanced_parens", 20, "parser_skip_balanced_parens_glue", 32},
    {"skip_balanced_parens_into", 25, "parser_skip_balanced_parens_into_glue", 37},
    {"skip_imports", 12, "parser_skip_imports_glue", 24},
    {"skip_one_enum_buf", 17, "parser_skip_one_enum_buf_glue", 29},
    {"skip_one_enum", 13, "parser_skip_one_enum_glue", 25},
    {"skip_one_enum_into", 18, "parser_skip_one_enum_into_glue", 30},
    {"skip_one_enum_into_buf", 22, "parser_skip_one_enum_into_buf_glue", 34},
    {"skip_one_enum_register_into_buf", 31, "parser_skip_one_enum_register_into_buf_glue", 43},
    {"skip_one_enum_register_into", 27, "parser_skip_one_enum_register_into_glue", 39},
    {"skip_one_extern_buf", 19, "parser_skip_one_extern_buf_glue", 31},
    {"skip_one_extern", 15, "parser_skip_one_extern_glue", 27},
    {"skip_one_extern_into_buf", 24, "parser_skip_one_extern_into_buf_glue", 36},
    {"skip_one_extern_into", 20, "parser_skip_one_extern_into_glue", 32},
    {"skip_one_function_full_buf", 26, "parser_skip_one_function_full_buf_glue", 38},
    {"skip_one_function_full", 22, "parser_skip_one_function_full_glue", 34},
    {"skip_one_function_full_into_buf", 31, "parser_skip_one_function_full_into_buf_glue", 43},
    {"skip_one_function_full_into", 27, "parser_skip_one_function_full_into_glue", 39},
    {"skip_one_if_core_buf", 20, "parser_skip_one_if_core_buf_glue", 32},
    {"skip_one_if_core", 16, "parser_skip_one_if_core_glue", 28},
    {"skip_one_if_core_into", 21, "parser_skip_one_if_core_into_glue", 33},
    {"skip_one_if_statement_buf", 25, "parser_skip_one_if_statement_buf_glue", 37},
    {"skip_one_if_statement", 21, "parser_skip_one_if_statement_glue", 33},
    {"skip_one_if_statement_into", 26, "parser_skip_one_if_statement_into_glue", 38},
    {"skip_one_impl_buf", 17, "parser_skip_one_impl_buf_glue", 29},
    {"skip_one_impl", 13, "parser_skip_one_impl_glue", 25},
    {"skip_one_impl_into_buf", 22, "parser_skip_one_impl_into_buf_glue", 34},
    {"skip_one_impl_into", 18, "parser_skip_one_impl_into_glue", 30},
    {"skip_one_struct_buf", 19, "parser_skip_one_struct_buf_glue", 31},
    {"skip_one_struct", 15, "parser_skip_one_struct_glue", 27},
    {"skip_one_struct_into_buf", 24, "parser_skip_one_struct_into_buf_glue", 36},
    {"skip_one_struct_into", 20, "parser_skip_one_struct_into_glue", 32},
    {"skip_one_trait_buf", 18, "parser_skip_one_trait_buf_glue", 30},
    {"skip_one_trait", 14, "parser_skip_one_trait_glue", 26},
    {"skip_one_trait_into_buf", 23, "parser_skip_one_trait_into_buf_glue", 35},
    {"skip_one_trait_into", 19, "parser_skip_one_trait_into_glue", 31},
    {"struct_field_name_from_tok", 26, "parser_struct_field_name_from_tok_glue", 38},
    {"parser_token_is_label_start", 27, "parser_token_is_label_start_glue", 32},
    {"parser_should_wrap_func_tail_in_return", 38, "parser_should_wrap_func_tail_in_return_glue", 43},
    {"pipeline_module_reset_parse_counters", 36, "pipeline_module_reset_parse_counters_c", 38},
    {"try_skip_allow_padding_struct_buf", 33, "parser_try_skip_allow_padding_struct_buf_glue", 45},
    {"try_skip_allow_padding_struct", 29, "parser_try_skip_allow_padding_struct_glue", 41},
};

int32_t asm_parser_func_is_thin_delegate(void *m, int32_t func_index) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
  nrows = (int32_t)(sizeof(k_wave120_parser_thin_delegate) / sizeof(k_wave120_parser_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)k_wave120_parser_thin_delegate[i].x_name,
                                           k_wave120_parser_thin_delegate[i].x_len))
      return 1;
  }
  return 0;
}
/* wave777 Class AB: was void(a,b) wrong arity — callers pass 7 args
 * (is_block, a, ref, caller_id, caller_mod, ctx, depth). Win leftover had
 * empty wpo_thin.o (0 bytes) so stub won; PREFER thin -c is HARD BAN / CG002
 * on Win. ABI-safe no-op until PE thin is green. PLATFORM: WINDOWS leftover-PE. */
void asm_wpo_collect_walk(int32_t is_block, void *a, int32_t ref, int32_t caller_id,
                          void *caller_mod, void *ctx, int32_t depth) {
  (void)is_block;
  (void)a;
  (void)ref;
  (void)caller_id;
  (void)caller_mod;
  (void)ctx;
  (void)depth;
}
/* int32_t pipe_modlet_bake_scalar_imm_to_data() { return -1; } — real body in windows_e extras; stubs merge last */
/* int32_t pipeline_asm_emit_assign_elf_c() { return -1; } — real body in windows_e extras; stubs merge last */
/* Real CALL/METHOD/STRUCT_LIT let-init (stub was return -2 → bare store_rax
 * dropped Option_ptr rdx half → tests/option -16). PLATFORM: WINDOWS leftover-PE. */
extern int32_t glue_call_return_byte_size_c(void *arena, int32_t call_expr_ref);
extern int32_t glue_type_size_simple(void *m, void *a, int32_t ty_ref, int32_t depth);
extern int32_t glue_type_named_layout_size_any_module_elf_c(void *arena, int32_t ty_ref);
extern int32_t glue_store_retval_pair_to_rbp_elf_c(void *m, void *arena, void *elf_ctx, int32_t ty_ref,
                                                    int32_t slot_off, int32_t ta, int32_t init_ref, void *ctx);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern void pipeline_asm_set_call_expected_ret_ty_c(int32_t type_ref);
extern void pipeline_asm_emit_set_call_sret_reg_shift_c(int32_t v);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf, int32_t k, int32_t ta);
extern int32_t try_inline_struct_lit_return_call_to_slot_elf(void *arena, void *elf_ctx, int32_t call_ref, void *ctx,
                                                              int32_t ta, int32_t stack_slot_off);
extern int32_t try_inline_const_struct_lit_return_call_to_slot_elf(void *arena, void *elf_ctx, int32_t call_ref,
                                                                    void *ctx, int32_t ta, int32_t stack_slot_off);
extern void *glue_emit_module_from_ctx(void *ctx);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf, int32_t off, int32_t ta);

int32_t glue_emit_struct_type_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx, int32_t ta,
                                             int32_t let_ty_ref, int32_t stack_slot_off) {
  int32_t ko;
  int32_t inl;
  int32_t emit_rc;
  int32_t call_ret_sz;
  int32_t let_sz;
  int32_t named_sz;
  int32_t best;
  int32_t dest_in_rbx;
  void *modp;
  if (!arena || !elf_ctx || !ctx || init_ref <= 0)
    return -2;
  dest_in_rbx = (stack_slot_off == -3) ? 1 : 0;
  ko = pipeline_expr_kind_ord_at(arena, init_ref);
  if (ko == 45) {
    /* STRUCT_LIT: leave to existing twin / fallthrough (pipeline_asm_emit_struct_let_init Class U real) */
    return -2;
  }
  if (ko == 48 || ko == 49) {
    if (!dest_in_rbx) {
      inl = try_inline_struct_lit_return_call_to_slot_elf(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
      if (inl == 1)
        return 0;
      inl = try_inline_const_struct_lit_return_call_to_slot_elf(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
      if (inl == 1)
        return 0;
    }
    pipeline_asm_set_call_expected_ret_ty_c(let_ty_ref > 0 ? let_ty_ref : 0);
    call_ret_sz = glue_call_return_byte_size_c(arena, init_ref);
    if (call_ret_sz <= 16 && let_ty_ref > 0) {
      modp = glue_emit_module_from_ctx(ctx);
      let_sz = glue_type_size_simple(modp, arena, let_ty_ref, 0);
      named_sz = glue_type_named_layout_size_any_module_elf_c(arena, let_ty_ref);
      best = let_sz;
      if (named_sz > best)
        best = named_sz;
      if (best > call_ret_sz)
        call_ret_sz = best;
    }
    if (call_ret_sz > 16 && ta == 0 && !dest_in_rbx) {
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0) {
        pipeline_asm_set_call_expected_ret_ty_c(0);
        return -1;
      }
      if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0) {
        pipeline_asm_set_call_expected_ret_ty_c(0);
        return -1;
      }
      pipeline_asm_emit_set_call_sret_reg_shift_c(1);
      emit_rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta);
      pipeline_asm_emit_set_call_sret_reg_shift_c(0);
      pipeline_asm_set_call_expected_ret_ty_c(0);
      return emit_rc != 0 ? -1 : 0;
    }
    emit_rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta);
    pipeline_asm_set_call_expected_ret_ty_c(0);
    if (emit_rc != 0)
      return -1;
    if (dest_in_rbx)
      return -2;
    modp = glue_emit_module_from_ctx(ctx);
    if (glue_store_retval_pair_to_rbp_elf_c(modp, arena, elf_ctx, let_ty_ref, stack_slot_off, ta, init_ref, ctx) != 0)
      return -1;
    return 0;
  }
  return -2;
}
/* wave773 Class X: was empty stub return -2. Twin of FROM_X glue_emit_vector_type_let_init
 * (ARRAY_LIT→mangled vector_let_init; VAR/binop/splat/binop2). select/shuffle/fma3 absent
 * on Win PE leftover — leave -2. PLATFORM: WINDOWS leftover-PE. */
extern int32_t asm_type_is_simd_vector_spelling(void *arena, int32_t type_ref);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32(
    void *arena, void *elf_ctx, int32_t init_ref, void *ctx, int32_t ta, int32_t stack_slot_off);
extern int32_t pipeline_asm_emit_vector_var_copy_elf_c(void *arena, void *elf_ctx, int32_t init_ref,
                                                       void *ctx, int32_t ta, int32_t stack_slot_off,
                                                       int32_t type_ref);
extern int32_t glue_is_vector_lane_scalar_binop_ko(int32_t ko);
extern int32_t pipeline_asm_emit_vector_binop_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref,
                                                             void *ctx, int32_t ta, int32_t stack_slot_off,
                                                             int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_select_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                             void *ctx, int32_t ta, int32_t stack_slot_off,
                                                             int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_shuffle_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                              void *ctx, int32_t ta, int32_t stack_slot_off,
                                                              int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_fma3_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                            void *ctx, int32_t ta, int32_t stack_slot_off,
                                                            int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_splat_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                             void *ctx, int32_t ta, int32_t stack_slot_off,
                                                             int32_t type_ref);
extern int32_t pipeline_asm_simd_try_inline_binop2_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                              void *ctx, int32_t ta, int32_t stack_slot_off,
                                                              int32_t type_ref);
int32_t glue_emit_vector_type_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx,
                                             int32_t ta, int32_t stack_slot_off, int32_t type_ref) {
  int32_t ko;
  int32_t inl;
  if (!arena || !elf_ctx || !ctx || init_ref <= 0 || !asm_type_is_simd_vector_spelling(arena, type_ref))
    return -2;
  ko = pipeline_expr_kind_ord_at(arena, init_ref);
  if (ko == 46)
    return pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32(
        arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
  if (ko == 3)
    return pipeline_asm_emit_vector_var_copy_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off,
                                                   type_ref);
  if (glue_is_vector_lane_scalar_binop_ko(ko))
    return pipeline_asm_emit_vector_binop_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                         stack_slot_off, type_ref);
  /* CALL=48 / METHOD_CALL=49 — Class Y: wire select/shuffle/fma3 */
  if (ko == 48 || ko == 49) {
    inl = pipeline_asm_simd_try_inline_splat_call_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                        stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
    inl = pipeline_asm_simd_try_inline_select_call_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                        stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
    inl = pipeline_asm_simd_try_inline_shuffle_call_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                         stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
    inl = pipeline_asm_simd_try_inline_fma3_call_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                       stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
    inl = pipeline_asm_simd_try_inline_binop2_call_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                         stack_slot_off, type_ref);
    if (inl == 1)
      return 0;
  }
  return -2;
}
/* Class U: pipeline_asm_emit_struct_let_init_elf_c defined after struct_lit_fields below. */
/* Prior stub returned -1 → Option STRUCT_LIT (`none_i32` etc) CG002 code_len=12.
 * G.7 twin of leftover_emit_struct_lit_into_parked_rbx + array_lit stack home.
 * PE stubs merge last (last-wins) — real body must live here. PLATFORM: WINDOWS leftover-PE. */
extern void *glue_emit_module_from_ctx(void *ctx);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(void *elf, int32_t off, int32_t sz, int32_t ta);
extern int32_t pipeline_expr_struct_lit_num_fields(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_struct_lit_init_ref(void *a, int32_t expr_ref, int32_t fi);
extern int32_t pipeline_expr_struct_lit_field_offset_at(void *a, void *m, int32_t expr_ref, int32_t fi);
extern int32_t pipeline_expr_struct_lit_value_bytes(void *a, void *m, int32_t expr_ref);
extern int32_t glue_struct_lit_field_store_sz(void *a, int32_t expr_ref, int32_t fi);
extern int32_t pipeline_asm_emit_expr_elf_rec(void *a, void *elf, int32_t er, void *ctx, int32_t ta);
extern int32_t backend_enc_push_rbx_arch(void *elf, int32_t ta);
extern int32_t backend_enc_pop_rbx_arch(void *elf, int32_t ta);
extern int32_t backend_enc_mov_rbx_to_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rax_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rdx_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rbx_arch(void *elf, int32_t off, int32_t ta);
extern int32_t pipe_load_i32_le(void *base, int32_t off);
extern void pipe_store_i32_le(void *base, int32_t off, int32_t v);
extern int32_t pipe_asm_ctx_off_next_offset(void);

static int32_t win_emit_struct_lit_fields_into_parked_rbx(void *arena, void *elf_ctx, int32_t lit_ref,
                                                          void *ctx, int32_t ta, int32_t base_off) {
  int32_t nf, fi, iref, foff, fsz, store_off, iko;
  void *mod;
  if (!arena || !elf_ctx || lit_ref <= 0)
    return -1;
  if (base_off < 0 || base_off > 4096)
    return -1;
  mod = glue_emit_module_from_ctx(ctx);
  if (!mod)
    mod = pipeline_asm_emit_module_ref_c();
  nf = pipeline_expr_struct_lit_num_fields(arena, lit_ref);
  if (nf < 0)
    nf = 0;
  if (nf > 64)
    return -1;
  for (fi = 0; fi < nf; fi++) {
    iref = pipeline_expr_struct_lit_init_ref(arena, lit_ref, fi);
    if (iref <= 0)
      return -1;
    foff = 0;
    if (mod)
      foff = pipeline_expr_struct_lit_field_offset_at(arena, mod, lit_ref, fi);
    if (foff < 0)
      foff = 0;
    store_off = foff + base_off;
    if (store_off > 4096)
      return -1;
    iko = pipeline_expr_kind_ord_at(arena, iref);
    if (iko == 45) {
      if (win_emit_struct_lit_fields_into_parked_rbx(arena, elf_ctx, iref, ctx, ta, store_off) != 0)
        return -1;
      continue;
    }
    fsz = glue_struct_lit_field_store_sz(arena, lit_ref, fi);
    if (fsz <= 0)
      continue;
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, iref, ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (fsz > 8)
      fsz = 8;
    if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, store_off, fsz, ta) != 0)
      return -1;
  }
  return 0;
}

int32_t pipeline_asm_emit_struct_lit_fields_elf_c(void *arena, void *elf_ctx, int32_t expr_ref,
                                                 void *ctx, int32_t ta, int32_t stack_slot_off) {
  int32_t dest_in_rbx;
  int32_t home;
  int32_t nbytes;
  int32_t reserve;
  void *mod;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 45)
    return -1;
  dest_in_rbx = (stack_slot_off == -3) ? 1 : 0;
  home = stack_slot_off;
  mod = glue_emit_module_from_ctx(ctx);
  if (!mod)
    mod = pipeline_asm_emit_module_ref_c();
  nbytes = 0;
  if (mod)
    nbytes = pipeline_expr_struct_lit_value_bytes(arena, mod, expr_ref);
  if (nbytes <= 0)
    nbytes = 8;
  if (nbytes > 4096)
    return -1;
  if (!dest_in_rbx) {
    if (home < 0) {
      reserve = (nbytes + 7) & -8;
      if (reserve < 8)
        reserve = 8;
      home = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
      if ((home % 8) != 0)
        home = ((home + 7) / 8) * 8;
      if (ta == 1) {
        pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + reserve);
      } else {
        home = home + reserve;
        pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home);
      }
    }
    if (home < 0)
      return -1;
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
  }
  if (backend_enc_push_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (win_emit_struct_lit_fields_into_parked_rbx(arena, elf_ctx, expr_ref, ctx, ta, 0) != 0) {
    (void)backend_enc_pop_rbx_arch(elf_ctx, ta);
    return -1;
  }
  if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (!dest_in_rbx) {
    /* value_bytes can under-report (Option_ptr: 8 while fields land at +8).
     * Raise nbytes from field ends so 16B returns load RAX+RDX. */
    {
      int32_t nf2, fi2, foff2, fsz2, end2;
      nf2 = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
      if (nf2 < 0)
        nf2 = 0;
      for (fi2 = 0; fi2 < nf2 && fi2 < 64; fi2++) {
        foff2 = 0;
        if (mod)
          foff2 = pipeline_expr_struct_lit_field_offset_at(arena, mod, expr_ref, fi2);
        if (foff2 < 0)
          foff2 = 0;
        fsz2 = glue_struct_lit_field_store_sz(arena, expr_ref, fi2);
        if (fsz2 <= 0)
          continue;
        if (fsz2 > 8)
          fsz2 = 8;
        end2 = foff2 + fsz2;
        if (end2 > nbytes)
          nbytes = end2;
      }
    }
    /* ≤16B rvalue/return: materialize VALUE into GP regs (not lea pointer).
     * ta != 1: ≤8B in RAX; 9–16B RAX at home and RDX at home-8 (end polarity).
     * ta == 1: home stays at the slot start. Low 8B load into x0 from home.
     * High 8B load into x1 from home+8. rbx is x1, so load_rbp_to_rbx emits
     * ldr x1, [x29, #(home+8)]. home-8 is the byte before this slot.
     * backend_enc_load_rbp_to_rdx_arch returns -1 when ta is not 0; do not
     * call it on ARM64 and do not turn that -1 into a successful return.
     * >16B keeps lea (sret).
     * PLATFORM: WINDOWS leftover-PE (ta != 1) / MACOS|ARM64 (ta == 1). */
    if (nbytes <= 8) {
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
        return -1;
    } else if (nbytes <= 16) {
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
        return -1;
      if (ta == 1) {
        if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, home + 8, ta) != 0)
          return -1;
      } else if (backend_enc_load_rbp_to_rdx_arch(elf_ctx, home - 8, ta) != 0) {
        return -1;
      }
    } else {
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
        return -1;
    }
  }
  return 0;
}

int32_t pipeline_asm_emit_struct_lit_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                          int32_t ta) {
  return pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, expr_ref, ctx, ta, -1);
}

/* wave770 Class U: STRUCT_LIT let-init was return -1; forward to fields body.
 * Twin of FROM_X thin wrapper. PLATFORM: WINDOWS leftover-PE. */
int32_t pipeline_asm_emit_struct_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref,
                                               void *ctx, int32_t ta, int32_t stack_slot_off) {
  if (!arena || !elf_ctx || !ctx || init_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 45)
    return -1;
  return pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
}

/* VAR assign: real leftover body (was return -1 → si/if-assign CG002).
 * FIELD/INDEX/DEREF still stub until their windows_e peers land; si uses VAR dest.
 * PLATFORM: WINDOWS leftover-PE. Full twin: seeds/win_assign_var_override.c */
extern int32_t glue_var_expr_stack_off_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t glue_var_decl_type_ref_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t type_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf_ctx, int32_t slot_off, int32_t ta);
extern int32_t backend_enc_store_eax_to_rbp_arch(void *elf_ctx, int32_t slot_off, int32_t ta);
extern int32_t backend_enc_store_rdx_to_rbp_arch(void *elf_ctx, int32_t slot_off, int32_t ta);
extern int32_t glue_slice_dual_gp_length_off_c(int32_t data_home, int32_t ta);
extern int32_t glue_store_retval_pair_to_rbp_elf_c(void *m, void *arena, void *elf_ctx, int32_t ty_ref,
                                                    int32_t slot_off, int32_t ta, int32_t init_ref, void *ctx);
extern void *glue_emit_module_from_ctx(void *ctx);

int32_t glue_emit_assign_var_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t left_ref,
                                  int32_t right_ref, void *ctx, int32_t ta) {
  int32_t off;
  int32_t ltr;
  int32_t ltk;
  int32_t ako;
  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return -1;
  off = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
  if (off < 0)
    return -1;
  ako = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ako != 28)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  ltr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
  ltk = (ltr > 0) ? pipeline_type_kind_ord_at(arena, ltr) : 0;
  if (ltk == 11) {
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off, ta) != 0)
      return -1;
    if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(off, ta), ta) != 0)
      return -1;
  } else if (ltr > 0 && ltk == 14) {
    if (backend_enc_store_eax_to_rbp_arch(elf_ctx, off, ta) != 0)
      return -1;
  } else if (glue_store_retval_pair_to_rbp_elf_c(glue_emit_module_from_ctx(ctx), arena, elf_ctx, ltr, off, ta,
                                                right_ref, ctx) != 0) {
    return -1;
  }
  return 0;
}
/* wave767 Class R: FIELD assign. Scalar path pushes rax, takes the lvalue
 * address into rbx, pops, and stores load_byte_sz bytes indirectly.
 * AAPCS64 (ta==1) named fields of 9..16 bytes are a dual-GP value: x0 is
 * the low half and x1 is the high half. push_rax keeps only x0, then
 * mov_rax_to_rbx writes the address into x1 and drops the high half.
 * That path saves x1 first, parks the address in x19 (mov_rax_to_rbx
 * already copies it there), restores both halves, and stores them through
 * x19. Size <= 8 and size > 16 stay on the scalar store. A field larger
 * than 16 bytes is an address, not a pair; do not send it through the
 * 16-byte store.
 * PLATFORM: MACOS|ARM64 for the pair. The one-GPR store stays for ta != 1
 * (WINDOWS leftover-PE and LINUX x86_64). */
extern int32_t pipeline_asm_emit_lvalue_eff_addr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref,
                                                       void *ctx, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_push_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_indirect_arch(void *elf_ctx, int32_t elem_sz, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(void *elf, int32_t off, int32_t sz, int32_t ta);
extern int32_t pipeline_expr_field_access_load_byte_sz(void *arena, void *mod, int32_t expr_ref);
extern int32_t glue_field_access_field_type_ref_c(void *arena, void *mod, int32_t fa_ref);
extern int32_t glue_type_named_layout_size_any_module_elf_c(void *arena, int32_t ty_ref);
extern void *pipeline_asm_emit_module_ref_c(void);

int32_t glue_emit_assign_field_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t left_ref,
                                    int32_t right_ref, void *ctx, int32_t ta) {
  int32_t sz;
  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 28)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  /* PLATFORM: MACOS|ARM64 — x1 still holds the high half. Save it before
   * the lvalue address overwrites x1. x19 keeps the address. */
  if (ta == 1) {
    void *mod = pipeline_asm_emit_module_ref_c();
    int32_t fty = glue_field_access_field_type_ref_c(arena, mod, left_ref);
    int32_t wide = glue_type_named_layout_size_any_module_elf_c(arena, fty);
    if (wide > 8 && wide <= 16) {
      if (backend_enc_push_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      return backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, 0, 16, ta);
    }
  }
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  sz = pipeline_expr_field_access_load_byte_sz(arena, pipeline_asm_emit_module_ref_c(), left_ref);
  if (sz <= 0)
    sz = 8;
  return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, sz, ta);
}
/* wave768 Class T: INDEX/DEREF assign real scalar (was return -1).
 * Twin of FIELD scalar: RHS→rax, push, lvalue→rbx, pop, store indirect.
 * INDEX esz via pipeline_asm_index_elem_byte_sz_c; DEREF via type width.
 * PLATFORM: WINDOWS leftover-PE. */
extern int32_t pipeline_asm_index_elem_byte_sz_c(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t glue_index_elem_byte_sz_from_type_ref_c(void *arena, int32_t tr);

int32_t glue_emit_assign_index_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t left_ref,
                                    int32_t right_ref, void *ctx, int32_t ta) {
  int32_t sz;
  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 28)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  sz = pipeline_asm_index_elem_byte_sz_c(arena, left_ref);
  if (sz <= 0)
    sz = 8;
  return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, sz, ta);
}

int32_t glue_emit_assign_deref_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t left_ref,
                                    int32_t right_ref, void *ctx, int32_t ta) {
  int32_t sz;
  int32_t tr;
  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 28)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  tr = pipeline_expr_resolved_type_ref(arena, left_ref);
  sz = (tr > 0) ? glue_index_elem_byte_sz_from_type_ref_c(arena, tr) : 0;
  if (sz <= 0)
    sz = 4;
  return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, sz, ta);
}
/* Cap residual glue_emit_index_eff_addr_scaled is #ifndef FROM_X; windows_e
 * emit_index calls these. Prior stubs returned -1 → option `bp[0]` CG002 after
 * ARRAY_LIT fix. Minimal Win body: eff_addr_base + lit add / scaled rbx.
 * try_* return -2 (not-handled) so Cap/windows_e fallthroughs keep working.
 * PLATFORM: WINDOWS leftover-PE. */
extern int32_t glue_emit_index_eff_addr_base_elf_c(void *arena, void *elf_ctx, int32_t ix_ref,
                                                   void *ctx, int32_t ta);
extern int32_t glue_emit_index_rax_plus_rbx_scaled_elf_c(void *elf_ctx, int32_t esz, int32_t ta);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_int_val_at(void *a, int32_t expr_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *a, void *elf, int32_t er, void *ctx, int32_t ta);
extern int32_t backend_enc_add_imm_to_rax_arch(void *elf, int32_t imm, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf, int32_t ta);
int32_t glue_try_index_var_or_field_base_to_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                     void *ctx, int32_t ta) {
  (void)arena; (void)elf_ctx; (void)base_ref; (void)ctx; (void)ta;
  return -2;
}
int32_t glue_try_index_var_or_field_base_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref,
                                                     void *ctx, int32_t ta) {
  (void)arena; (void)elf_ctx; (void)base_ref; (void)ctx; (void)ta;
  return -2;
}
int32_t glue_emit_index_eff_addr_scaled_elf_c(void *arena, void *elf_ctx, int32_t ix_ref,
                                             int32_t base_ref, int32_t idx_ref, void *ctx,
                                             int32_t ta, int32_t esz) {
  int32_t iko;
  int32_t lit;
  if (!arena || !elf_ctx || !ctx || ix_ref <= 0 || base_ref <= 0 || idx_ref <= 0)
    return -1;
  if (glue_emit_index_eff_addr_base_elf_c(arena, elf_ctx, ix_ref, ctx, ta) != 0)
    return -1;
  iko = pipeline_expr_kind_ord_at(arena, idx_ref);
  if (iko == 0) {
    lit = pipeline_expr_int_val_at(arena, idx_ref);
    if (lit != 0 && esz != 0) {
      if (backend_enc_add_imm_to_rax_arch(elf_ctx, lit * esz, ta) != 0)
        return -1;
    }
    return 0;
  }
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, idx_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}
/* wave771 Class V: was return -1. Seed twin of FROM_X glue_copy_large_struct
 * (memcpy via arg_reg 0/1/2 — Win64 enc maps rcx/rdx/r8). PLATFORM: WINDOWS leftover-PE. */
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(void *elf_ctx, int32_t lo, int32_t hi, int32_t ta);
extern int32_t backend_enc_call_arch(void *elf_ctx, uint8_t *sym, int32_t sym_len, int32_t ta);
extern int32_t backend_enc_mov_rbx_to_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t off, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t glue_arm64_mov_x19_to_x0_elf_c(void *elf_ctx);

int32_t glue_copy_large_struct_from_rax_ptr_elf_c(void *elf_ctx, int32_t slot_off, int32_t sz, int32_t ta) {
  uint8_t memcpy_sym[8];
  memcpy_sym[0] = 109;
  memcpy_sym[1] = 101;
  memcpy_sym[2] = 109;
  memcpy_sym[3] = 99;
  memcpy_sym[4] = 112;
  memcpy_sym[5] = 121;
  memcpy_sym[6] = 0;
  if (!elf_ctx || (ta != 0 && ta != 1) || sz < 8)
    return -1;
  if (sz <= 16 && slot_off != -3)
    return -1;
  if (slot_off == -3) {
    if (ta == 1) {
      if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
        return -1;
      if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
        return -1;
      if (glue_arm64_mov_x19_to_x0_elf_c(elf_ctx) != 0)
        return -1;
      return backend_enc_call_arch(elf_ctx, memcpy_sym, 6, ta);
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
      return -1;
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
      return -1;
    return backend_enc_call_arch(elf_ctx, memcpy_sym, 6, ta);
  }
  if (ta == 1) {
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
      return -1;
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot_off, ta) != 0)
      return -1;
    return backend_enc_call_arch(elf_ctx, memcpy_sym, 6, ta);
  }
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, memcpy_sym, 6, ta);
}
/* Win PE egg calls Cap-mangled name; Cap residual body is #ifndef FROM_X.
 * Prior stub returned -1 → fixed-array let init fail → option CG002 after unwrap_or
 * (`let buf: u8[4] = [1,2,3,4]`). Real scalar ARRAY_LIT → stack slot (G.7 twin of
 * pipeline_asm_emit_vector_let_init_elf_c Cap residual). PLATFORM: WINDOWS leftover-PE. */
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_num_elems_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_elem_ref(void *a, int32_t expr_ref, int32_t ai);
extern int32_t pipeline_asm_array_lit_elem_byte_sz_c(void *a, int32_t expr_ref);
extern int32_t glue_array_lit_emit_scalar_elem_to_rax_elf_c(void *a, void *elf, int32_t lit,
                                                            int32_t elem, void *ctx, int32_t ta,
                                                            int32_t esz);
extern int32_t glue_expr_emit_may_clobber_rbx_elf_c(void *a, int32_t expr_ref);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(void *elf, int32_t off, int32_t sz,
                                                        int32_t ta);
int32_t pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32(
    void *arena, void *elf_ctx, int32_t init_ref, void *ctx, int32_t ta, int32_t stack_slot_off) {
  int32_t n_arr;
  int32_t esz;
  int32_t store_sz;
  int32_t ai;
  int32_t elem_ref;
  int32_t may_clobber;
  if (!arena || !elf_ctx || !ctx || init_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 46)
    return -1;
  n_arr = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  if (n_arr <= 0 || n_arr > 1024)
    return -1;
  /* w1023: nested ARRAY_LIT → array_lit_flat (cold_L20500 twin). Was -1. */
  {
    int32_t has_nested = 0;
    int32_t flat_i = 0;
    for (ai = 0; ai < n_arr; ai++) {
      elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
      if (elem_ref > 0 && pipeline_expr_kind_ord_at(arena, elem_ref) == 46) {
        has_nested = 1;
        break;
      }
    }
    if (has_nested != 0) {
      extern int32_t pipeline_asm_array_lit_leaf_elem_byte_sz_c(void *a, int32_t expr_ref);
      extern int32_t pipeline_asm_emit_array_lit_flat_elf_c(void *a, void *elf, int32_t init,
                                                           void *ctx, int32_t ta, int32_t off,
                                                           int32_t leaf_esz, int32_t *flat_i);
      esz = pipeline_asm_array_lit_leaf_elem_byte_sz_c(arena, init_ref);
      if (esz <= 0)
        esz = 4;
      return pipeline_asm_emit_array_lit_flat_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                   stack_slot_off, esz, &flat_i);
    }
  }
  esz = pipeline_asm_array_lit_elem_byte_sz_c(arena, init_ref);
  if (esz <= 0)
    esz = 4;
  store_sz = esz;
  if (store_sz != 1 && store_sz != 2 && store_sz != 4 && store_sz != 8)
    store_sz = 4;
  for (ai = 0; ai < n_arr; ai++) {
    elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
    if (elem_ref == 0)
      continue;
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    may_clobber = glue_expr_emit_may_clobber_rbx_elf_c(arena, elem_ref);
    if (glue_array_lit_emit_scalar_elem_to_rax_elf_c(arena, elf_ctx, init_ref, elem_ref, ctx, ta,
                                                    esz) != 0)
      return -1;
    if (may_clobber != 0) {
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
    }
    if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, ai * esz, store_sz, ta) != 0)
      return -1;
  }
  return 0;
}
/* wave772 Class W: was return -1 (false error). Twin of FROM_X try_inline splat.
 * Returns 1 inlined / 0 no-match / -1 err. PLATFORM: WINDOWS leftover-PE. */
static int32_t win_glue_simd_callee_is_splat_c(const uint8_t *cname, int32_t clen) {
  if (!cname || clen <= 0)
    return 0;
  if (clen == 5 && memcmp(cname, "splat", 5) == 0)
    return 1;
  if (clen == 10 && memcmp(cname, "simd_splat", 10) == 0)
    return 1;
  if (clen == 11 && memcmp(cname, "vec8i_splat", 11) == 0)
    return 1;
  if (clen == 11 && memcmp(cname, "vec4f_splat", 11) == 0)
    return 1;
  return 0;
}
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_num_args_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_call_num_args_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_name_len(void *a, int32_t expr_ref);
extern void pipeline_expr_method_call_name_into(void *a, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_expr_call_callee_ref_at(void *a, int32_t expr_ref);
extern int32_t glue_call_callee_func_name_into_c(void *a, int32_t callee_ref, uint8_t *out, int32_t cap);
extern int32_t glue_vector_type_lanes_esz_c(void *a, int32_t type_ref, int32_t *out_lanes, int32_t *out_esz);
extern int32_t pipeline_expr_method_call_arg_ref(void *a, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_call_arg_ref(void *a, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_int_val_at(void *a, int32_t expr_ref);
extern int32_t glue_simd_emit_imm_fill_slot_c(void *elf, int32_t slot, int32_t lanes, int32_t esz, int32_t ta, int32_t imm);
extern int32_t glue_ieee_f64_bits_to_f32_bits(int32_t lo, int32_t hi);
extern int32_t pipeline_expr_float_bits_lo_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_float_bits_hi_at(void *a, int32_t expr_ref);
extern int32_t glue_emit_float_lit_to_rax_elf_c(void *a, void *elf, int32_t expr_ref, int32_t ta, int32_t a4, int32_t a5);
extern int32_t backend_enc_lea_rbp_to_rbx_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(void *elf, int32_t off, int32_t sz, int32_t ta);

int32_t pipeline_asm_simd_try_inline_splat_call_elf_c(void *arena, void *elf_ctx, int32_t call_ref,
                                                     void *ctx, int32_t ta, int32_t stack_slot_off,
                                                     int32_t type_ref) {
  int32_t callee_ref, clen, arg0, lanes, esz, ko, nargs, is_method, imm, store_sz, li;
  uint8_t cname[256];
  if (!arena || !elf_ctx || !ctx || call_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, call_ref);
  if (ko != 48 && ko != 49)
    return 0;
  is_method = (ko == 49) ? 1 : 0;
  nargs = is_method ? pipeline_expr_method_call_num_args_at(arena, call_ref)
                    : pipeline_expr_call_num_args_at(arena, call_ref);
  if (nargs != 1)
    return 0;
  if (is_method) {
    clen = pipeline_expr_method_call_name_len(arena, call_ref);
    if (clen <= 0 || clen >= 64)
      return 0;
    pipeline_expr_method_call_name_into(arena, call_ref, cname);
  } else {
    callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
    if (callee_ref <= 0)
      return 0;
    clen = glue_call_callee_func_name_into_c(arena, callee_ref, cname, 64);
    if (clen <= 0)
      return 0;
  }
  if (!win_glue_simd_callee_is_splat_c(cname, clen))
    return 0;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  arg0 = is_method ? pipeline_expr_method_call_arg_ref(arena, call_ref, 0)
                   : pipeline_expr_call_arg_ref(arena, call_ref, 0);
  if (arg0 <= 0)
    return -1;
  ko = pipeline_expr_kind_ord_at(arena, arg0);
  if (ko == 0 || ko == 2) {
    imm = pipeline_expr_int_val_at(arena, arg0);
    if (glue_simd_emit_imm_fill_slot_c(elf_ctx, stack_slot_off, lanes, esz, ta, imm) != 0)
      return -1;
    return 1;
  }
  if (ko == 1) {
    if (esz == 4) {
      imm = glue_ieee_f64_bits_to_f32_bits(pipeline_expr_float_bits_lo_at(arena, arg0),
                                          pipeline_expr_float_bits_hi_at(arena, arg0));
      if (glue_simd_emit_imm_fill_slot_c(elf_ctx, stack_slot_off, lanes, esz, ta, imm) != 0)
        return -1;
      return 1;
    }
    if (glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, arg0, ta, 0, 0) != 0)
      return -1;
    store_sz = esz;
    if (store_sz != 1 && store_sz != 2 && store_sz != 4 && store_sz != 8)
      store_sz = 4;
    if (backend_enc_lea_rbp_to_rbx_arch(elf_ctx, stack_slot_off, ta) != 0)
      return -1;
    for (li = 0; li < lanes; li++) {
      if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, li * store_sz, store_sz, ta) != 0)
        return -1;
    }
    return 1;
  }
  return 0;
}
/* Win PE: identity emit-order (was return -1 → mega loop 0× → CG002 empty).
 * Real asm_wpo.from_x may be clobbered by PE ld -r stub merge; these must work.
 * wave778 Class AC: prepare was empty no-op; count/at recomputed each call.
 * Fill bounded order[] in prepare (FROM_X twin pattern; identity = non-extern
 * order, no PGO sort). Empty stub 1→0. PLATFORM: WINDOWS. */
#ifndef ASM_WPO_MAX_FUNCS
#define ASM_WPO_MAX_FUNCS 4096
#endif
extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t fi);
static int32_t g_win_pgo_emit_order[ASM_WPO_MAX_FUNCS];
static int32_t g_win_pgo_emit_n;
static void *g_win_pgo_emit_mod;
void pipeline_asm_wpo_pgo_emit_order_prepare(void *m) {
  int32_t nf, fi, n = 0;
  g_win_pgo_emit_mod = m;
  g_win_pgo_emit_n = 0;
  if (!m) return;
  nf = pipeline_module_num_funcs(m);
  for (fi = 0; fi < nf; fi++) {
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0) continue;
    if (n < ASM_WPO_MAX_FUNCS) {
      g_win_pgo_emit_order[n] = fi;
      n++;
    }
  }
  g_win_pgo_emit_n = n;
}
int32_t pipeline_asm_wpo_pgo_emit_order_count(void *m) {
  if (!m) return 0;
  if (m != g_win_pgo_emit_mod)
    pipeline_asm_wpo_pgo_emit_order_prepare(m);
  return g_win_pgo_emit_n;
}
int32_t pipeline_asm_wpo_pgo_emit_order_at(void *m, int32_t order_index) {
  if (!m || order_index < 0) return -1;
  if (m != g_win_pgo_emit_mod)
    pipeline_asm_wpo_pgo_emit_order_prepare(m);
  if (order_index >= g_win_pgo_emit_n || order_index >= ASM_WPO_MAX_FUNCS)
    return -1;
  return g_win_pgo_emit_order[order_index];
}
/* add_sym/add_label/ensure_label/add_common_sym: NOT stubbed.
 * Stubs merge last and were clobbering elf_ctx.windows_e real bodies
 * → num_syms stayed 0 → COFF .o had .text but no main (WinMain ld fail). */

/* Class Y deps for select/shuffle/fma3 twins in this TU */
extern char *link_abi_getenv(const char *name);
extern int32_t glue_peel_comptime_array_lit_mask_c(void *arena, void *ctx, int32_t mask_ref);
extern int32_t glue_asm_local_var_stack_off_scoped(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t glue_shuffle_pshufd_imm8_from_mask_c(void *arena, int32_t mask_ref, int32_t lanes, int32_t *out_imm8);
extern uint32_t glue_simd_emit_cpu_features_c(void);
extern uint32_t xlang_target_cpu_detect_host(void);
extern int32_t simd_enc_try_pshufd_rbp(void *elf, int32_t src, int32_t dst, int32_t imm8, int32_t lanes, int32_t ta, uint32_t feats);
extern int32_t glue_emit_vector_shuffle_lane_scalar_elf_c(void *arena, void *elf_ctx, int32_t src_ref, int32_t mask_lit,
                                                          int32_t dst_off, int32_t type_ref, void *ctx, int32_t ta);
extern int32_t glue_simd_expr_splat_int_imm_c(void *arena, int32_t expr_ref, int32_t *out_imm);
extern int32_t glue_simd_select_arg_stack_off_c(void *arena, void *elf_ctx, void *ctx, int32_t ta, int32_t arg_ref,
                                                int32_t type_ref);
extern int32_t glue_vector_elem_is_f32_c(void *arena, int32_t type_ref);
extern int32_t simd_enc_try_hw_vector_select_rbp(void *elf, int32_t m, int32_t a, int32_t b, int32_t d, int32_t lanes,
                                                  int32_t is_f32, int32_t ta, uint32_t feats);
extern int32_t glue_emit_vector_select_lane_scalar_elf_c(void *arena, void *elf_ctx, int32_t mask_ref, int32_t a_ref,
                                                         int32_t b_ref, int32_t dst_off, int32_t type_ref, void *ctx,
                                                         int32_t ta);
extern int32_t glue_callee_is_vec4f_fma3_c(uint8_t *cname, int32_t clen);
extern int32_t simd_enc_try_hw_vector_fma_rbp(void *elf, int32_t a, int32_t b, int32_t c, int32_t d, int32_t lanes,
                                               int32_t esz, int32_t ta, uint32_t feats);

int32_t pipeline_asm_simd_try_inline_shuffle_call_elf_c(void *arena,
                                                       void *elf_ctx, int32_t call_ref,
                                                       void *ctx, int32_t ta,
                                                       int32_t stack_slot_off, int32_t type_ref) {
  int32_t callee_ref;
  int32_t clen;
  uint8_t cname[256];
  int32_t expect_lanes;
  int32_t arg0;
  int32_t arg1;
  int32_t mask_lit;
  int32_t lanes;
  int32_t esz;
  int32_t src_off;
  int32_t imm8;
  uint32_t feats;
  const char *hw_env;
  int32_t ko;
  int32_t nargs;
  int32_t is_method;

  if (!arena || !elf_ctx || !ctx || call_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, call_ref);
  /* CALL=48, METHOD_CALL=49 (import simd.shuffle is METHOD). */
  if (ko != 48 && ko != 49)
    return 0;
  is_method = (ko == 49) ? 1 : 0;
  if (is_method)
    nargs = pipeline_expr_method_call_num_args_at(arena, call_ref);
  else
    nargs = pipeline_expr_call_num_args_at(arena, call_ref);
  if (nargs != 2)
    return 0;
  if (is_method) {
    /* Method name lives on METHOD_CALL node (not FIELD callee). */
    clen = pipeline_expr_method_call_name_len(arena, call_ref);
    if (clen <= 0 || clen >= 64)
      return 0;
    pipeline_expr_method_call_name_into(arena, call_ref, cname);
  } else {
    callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
    if (callee_ref <= 0)
      return 0;
    clen = glue_call_callee_func_name_into_c(arena, callee_ref, cname, 64);
    if (clen <= 0)
      return 0;
  }
  expect_lanes = 0;
  if (clen == 13 && memcmp(cname, "vec4f_shuffle", 13) == 0)
    expect_lanes = 4;
  else if (clen == 13 && memcmp(cname, "vec8i_shuffle", 13) == 0)
    expect_lanes = 8;
  else if (clen == 12 && memcmp(cname, "simd_shuffle", 12) == 0)
    expect_lanes = 0;
  else if (clen == 7 && memcmp(cname, "shuffle", 7) == 0)
    /* import METHOD bare name: simd.shuffle → "shuffle". */
    expect_lanes = 0;
  else
    return 0;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  if (expect_lanes != 0 && lanes != expect_lanes)
    return 0;
  if (is_method) {
    arg0 = pipeline_expr_method_call_arg_ref(arena, call_ref, 0);
    arg1 = pipeline_expr_method_call_arg_ref(arena, call_ref, 1);
  } else {
    arg0 = pipeline_expr_call_arg_ref(arena, call_ref, 0);
    arg1 = pipeline_expr_call_arg_ref(arena, call_ref, 1);
  }
  if (arg0 <= 0 || arg1 <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, arg0) != 3)
    return 0;
  mask_lit = glue_peel_comptime_array_lit_mask_c(arena, ctx, arg1);
  if (mask_lit <= 0)
    return 0;
  src_off = glue_asm_local_var_stack_off_scoped(arena, ctx, arg0);
  if (src_off < 0)
    return 0;
  hw_env = link_abi_getenv("XLANG_SIMD_HW");
  if (!hw_env || hw_env[0] != '0') {
    if (glue_shuffle_pshufd_imm8_from_mask_c(arena, mask_lit, lanes, &imm8) == 0) {
      feats = glue_simd_emit_cpu_features_c();
      if (feats == 0)
        feats = xlang_target_cpu_detect_host();
      if (simd_enc_try_pshufd_rbp(elf_ctx, src_off, stack_slot_off, imm8, lanes, ta, feats) == 0)
        return 1;
    }
  }
  if (glue_emit_vector_shuffle_lane_scalar_elf_c(arena, elf_ctx, arg0, mask_lit, stack_slot_off, type_ref, ctx, ta) != 0)
    return 0;
  return 1;
}

int32_t pipeline_asm_simd_try_inline_select_call_elf_c(void *arena,
                                                      void *elf_ctx, int32_t call_ref,
                                                      void *ctx, int32_t ta,
                                                      int32_t stack_slot_off, int32_t type_ref) {
  int32_t callee_ref;
  int32_t clen;
  uint8_t cname[256];
  int32_t expect_lanes;
  int32_t arg_m;
  int32_t arg_a;
  int32_t arg_b;
  int32_t lanes;
  int32_t esz;
  int32_t off_m;
  int32_t off_a;
  int32_t off_b;
  int32_t is_f32;
  uint32_t feats;
  const char *hw_env;
  int32_t ko;
  int32_t nargs;
  int32_t is_method;

  if (!arena || !elf_ctx || !ctx || call_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, call_ref);
  if (ko != 48 && ko != 49)
    return 0;
  is_method = (ko == 49) ? 1 : 0;
  if (is_method)
    nargs = pipeline_expr_method_call_num_args_at(arena, call_ref);
  else
    nargs = pipeline_expr_call_num_args_at(arena, call_ref);
  if (nargs != 3)
    return 0;
  if (is_method) {
    clen = pipeline_expr_method_call_name_len(arena, call_ref);
    if (clen <= 0 || clen >= 64)
      return 0;
    pipeline_expr_method_call_name_into(arena, call_ref, cname);
  } else {
    callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
    if (callee_ref <= 0)
      return 0;
    clen = glue_call_callee_func_name_into_c(arena, callee_ref, cname, 64);
    if (clen <= 0)
      return 0;
  }
  expect_lanes = 0;
  if (clen == 12 && memcmp(cname, "vec4f_select", 12) == 0)
    expect_lanes = 4;
  else if (clen == 12 && memcmp(cname, "vec8i_select", 12) == 0)
    expect_lanes = 8;
  else if (clen == 11 && memcmp(cname, "simd_select", 11) == 0)
    expect_lanes = 0;
  else if (clen == 6 && memcmp(cname, "select", 6) == 0)
    expect_lanes = 0;
  else
    return 0;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  if (expect_lanes != 0 && lanes != expect_lanes)
    return 0;
  if (is_method) {
    arg_m = pipeline_expr_method_call_arg_ref(arena, call_ref, 0);
    arg_a = pipeline_expr_method_call_arg_ref(arena, call_ref, 1);
    arg_b = pipeline_expr_method_call_arg_ref(arena, call_ref, 2);
  } else {
    arg_m = pipeline_expr_call_arg_ref(arena, call_ref, 0);
    arg_a = pipeline_expr_call_arg_ref(arena, call_ref, 1);
    arg_b = pipeline_expr_call_arg_ref(arena, call_ref, 2);
  }
  if (arg_m <= 0 || arg_a <= 0 || arg_b <= 0)
    return -1;
  /* Comptime-uniform mask: select(splat(k), a, b) → a if k!=0 else b.
   * Product select_lane is mask!=0 ? a : b. Avoids two splat sret + select.
   * PLATFORM: SHARED — fold before any temp emit. */
  {
    int32_t mask_imm;
    int32_t pick;
    int32_t pko;
    if (glue_simd_expr_splat_int_imm_c(arena, arg_m, &mask_imm)) {
      pick = (mask_imm != 0) ? arg_a : arg_b;
      pko = pipeline_expr_kind_ord_at(arena, pick);
      if (pko == 3) {
        if (pipeline_asm_emit_vector_var_copy_elf_c(arena, elf_ctx, pick, ctx, ta, stack_slot_off,
                                                    type_ref) != 0)
          return -1;
        return 1;
      }
      if (pipeline_asm_simd_try_inline_splat_call_elf_c(arena, elf_ctx, pick, ctx, ta, stack_slot_off,
                                                        type_ref) == 1)
        return 1;
      return 0;
    }
  }
  off_m = glue_simd_select_arg_stack_off_c(arena, elf_ctx, ctx, ta, arg_m, type_ref);
  off_a = glue_simd_select_arg_stack_off_c(arena, elf_ctx, ctx, ta, arg_a, type_ref);
  off_b = glue_simd_select_arg_stack_off_c(arena, elf_ctx, ctx, ta, arg_b, type_ref);
  if (off_m < 0 || off_a < 0 || off_b < 0)
    return 0;
  is_f32 = glue_vector_elem_is_f32_c(arena, type_ref);
  hw_env = link_abi_getenv("XLANG_SIMD_HW");
  if (!hw_env || hw_env[0] != '0') {
    feats = glue_simd_emit_cpu_features_c();
    if (feats == 0)
      feats = xlang_target_cpu_detect_host();
    if (simd_enc_try_hw_vector_select_rbp(elf_ctx, off_m, off_a, off_b, stack_slot_off, lanes, is_f32, ta, feats) == 0)
      return 1;
  }
  /* Lane-scalar fallback still requires IDENT args (expr refs, not temps). */
  if (pipeline_expr_kind_ord_at(arena, arg_m) != 3 || pipeline_expr_kind_ord_at(arena, arg_a) != 3 ||
      pipeline_expr_kind_ord_at(arena, arg_b) != 3)
    return 0;
  if (glue_emit_vector_select_lane_scalar_elf_c(arena, elf_ctx, arg_m, arg_a, arg_b, stack_slot_off, type_ref, ctx,
                                                ta) != 0)
    return 0;
  return 1;
}

int32_t pipeline_asm_simd_try_inline_fma3_call_elf_c(void *arena,
                                                     void *elf_ctx, int32_t call_ref,
                                                     void *ctx, int32_t ta, int32_t stack_slot_off,
                                                     int32_t type_ref) {
  int32_t callee_ref;
  int32_t clen;
  uint8_t cname[256];
  int32_t arg0;
  int32_t arg1;
  int32_t arg2;
  int32_t lanes;
  int32_t esz;
  int32_t off_a;
  int32_t off_b;
  int32_t off_c;
  uint32_t feats;
  const char *hw_env;
  int32_t ko;
  int32_t is_method;

  if (!arena || !elf_ctx || !ctx || call_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, call_ref);
  /* CALL=48, METHOD_CALL=49 (import simd.fma is METHOD). */
  if (ko != 48 && ko != 49)
    return 0;
  is_method = (ko == 49);
  if (is_method) {
    if (pipeline_expr_method_call_num_args_at(arena, call_ref) != 3)
      return 0;
    clen = pipeline_expr_method_call_name_len(arena, call_ref);
    if (clen <= 0 || clen >= 64)
      return 0;
    pipeline_expr_method_call_name_into(arena, call_ref, cname);
  } else {
    if (pipeline_expr_call_num_args_at(arena, call_ref) != 3)
      return 0;
    callee_ref = pipeline_expr_call_callee_ref_at(arena, call_ref);
    if (callee_ref <= 0)
      return 0;
    clen = glue_call_callee_func_name_into_c(arena, callee_ref, cname, 64);
  }
  if (clen <= 0 || glue_callee_is_vec4f_fma3_c(cname, clen) == 0)
    return 0;
  if (glue_vector_type_lanes_esz_c(arena, type_ref, &lanes, &esz) != 0)
    return -1;
  if (lanes != 4 || esz != 4 || glue_vector_elem_is_f32_c(arena, type_ref) == 0)
    return 0;
  if (is_method) {
    arg0 = pipeline_expr_method_call_arg_ref(arena, call_ref, 0);
    arg1 = pipeline_expr_method_call_arg_ref(arena, call_ref, 1);
    arg2 = pipeline_expr_method_call_arg_ref(arena, call_ref, 2);
  } else {
    arg0 = pipeline_expr_call_arg_ref(arena, call_ref, 0);
    arg1 = pipeline_expr_call_arg_ref(arena, call_ref, 1);
    arg2 = pipeline_expr_call_arg_ref(arena, call_ref, 2);
  }
  if (arg0 <= 0 || arg1 <= 0 || arg2 <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, arg0) != 3 || pipeline_expr_kind_ord_at(arena, arg1) != 3 ||
      pipeline_expr_kind_ord_at(arena, arg2) != 3)
    return 0;
  off_a = glue_asm_local_var_stack_off_scoped(arena, ctx, arg0);
  off_b = glue_asm_local_var_stack_off_scoped(arena, ctx, arg1);
  off_c = glue_asm_local_var_stack_off_scoped(arena, ctx, arg2);
  if (off_a < 0 || off_b < 0 || off_c < 0)
    return 0;
  hw_env = link_abi_getenv("XLANG_SIMD_HW");
  if (hw_env && hw_env[0] == '0')
    return 0;
  feats = glue_simd_emit_cpu_features_c();
  if (feats == 0)
    feats = xlang_target_cpu_detect_host();
  if (simd_enc_try_hw_vector_fma_rbp(elf_ctx, off_a, off_b, off_c, stack_slot_off, lanes, esz, ta, feats) == 0)
    return 1;
  return 0;
}

/* Class AA: m8_tail wrong ABI stubs removed; real bodies below (also in overrides). */
extern int32_t asm_module_is_pipeline_selfhost(void *m);
extern int32_t asm_module_is_driver_compile_selfhost(void *m);
extern int32_t asm_module_is_typeck_selfhost(void *m);
extern int32_t asm_env_entry_emit_heavy(void);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t func_index);
extern int32_t pipeline_module_func_name_len_at(void *m, int32_t func_index);
extern void pipeline_asm_module_func_name_copy64(void *m, int32_t func_index, uint8_t *out);

typedef struct {
  const char *x_name;
  int32_t x_len;
  const char *c_name;
  int32_t c_len;
} AsmBackendThinDelegateRow;

static const AsmBackendThinDelegateRow k_asm_backend_thin_delegate[] = {
    {"fill_param_slots", 16, "pipeline_asm_fill_param_slots", 29},
    {"fill_local_slots", 16, "pipeline_asm_fill_local_slots", 29},
    {"compute_frame_size", 18, "pipeline_asm_compute_frame_size_c", 33},
    {"emit_block_body_elf", 19, "backend_emit_block_body_sync_elf", 32},
    {"emit_block_inits_elf", 20, "pipeline_asm_emit_block_inits_elf_c", 35},
    {"emit_if_then_block_body_elf", 27, "pipeline_asm_emit_if_then_block_body_elf_c", 42},
    {"emit_while_loop_elf", 18, "pipeline_asm_emit_while_loop_elf_c", 34},
    {"emit_for_loop_elf", 16, "pipeline_asm_emit_for_loop_elf_c", 32},
    {"emit_loop_body_content", 22, "pipeline_asm_emit_loop_body_content_c", 35},
    {"emit_loop_body_content_elf", 26, "pipeline_asm_emit_loop_body_content_elf_c", 39},
    {"emit_next_label", 15, "pipeline_asm_emit_next_label_c", 30},
    {"format_label_id", 15, "pipeline_asm_format_label_id_c", 30},
    {"emit_expr_elf_call", 18, "pipeline_asm_emit_call_elf_c", 28},
    {"emit_expr_elf_method_call", 25, "pipeline_asm_emit_method_call_elf_c", 35},
    {"asm_emit_call_args_elf", 22, "pipeline_asm_emit_call_args_elf_c", 33},
    {"emit_block_inits", 16, "pipeline_asm_emit_block_inits_c", 31},
    {"emit_block_body", 15, "pipeline_asm_emit_block_body_c", 30},
    {"emit_while_loop", 15, "pipeline_asm_emit_while_loop_c", 30},
    {"emit_for_loop", 13, "pipeline_asm_emit_for_loop_c", 28},
    {"emit_if_then_block_body_text", 28, "pipeline_asm_emit_if_then_block_body_text_c", 43},
    {"emit_expr", 9, "pipeline_asm_emit_expr_c", 24},
    {"emit_expr_call", 14, "pipeline_asm_emit_expr_call_c", 29},
    {"emit_expr_method_call", 21, "pipeline_asm_emit_expr_method_call_c", 36},
    {"emit_expr_elf", 13, "pipeline_asm_emit_expr_elf_c", 28},
    {"emit_index_eff_addr_text", 24, "pipeline_asm_emit_index_eff_addr_text_c", 39},
    {"emit_index_eff_addr_elf", 23, "pipeline_asm_emit_index_eff_addr_elf_c", 38},
    {"emit_lvalue_eff_addr_text", 25, "pipeline_asm_emit_lvalue_eff_addr_text_c", 40},
    {"emit_lvalue_eff_addr_elf", 24, "pipeline_asm_emit_lvalue_eff_addr_elf_c", 39},
    {"asm_emit_call_args_text", 23, "pipeline_asm_emit_call_args_text_c", 33},
    {"local_offset", 12, "pipeline_asm_local_offset_c", 27},
    {"asm_resolve_whole_import_qualified_symbol", 41, "pipeline_asm_resolve_whole_import_qualified_symbol_c", 52},
    {"emit_skip_heavy_stub_elf", 24, "pipeline_asm_emit_skip_heavy_stub_elf_c", 39},
    {"simd_try_inline_shuffle_call_elf", 32, "pipeline_asm_simd_try_inline_shuffle_call_elf_c", 47},
    {"simd_try_inline_select_call_elf", 31, "pipeline_asm_simd_try_inline_select_call_elf_c", 46},
    {"simd_try_inline_binop2_call_elf", 31, "pipeline_asm_simd_try_inline_binop2_call_elf_c", 46},
    {"simd_try_inline_fma3_call_elf", 29, "pipeline_asm_simd_try_inline_fma3_call_elf_c", 46},
    {"asm_codegen_ast", 15, "pipeline_backend_asm_codegen_ast_c", 34},
    {"asm_codegen_ast_to_elf", 22, "pipeline_backend_asm_codegen_ast_to_elf_c", 41},
};

/**
 * 查 backend 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_backend_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                  int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0)
    return 0;
  nrows = (int32_t)(sizeof(k_asm_backend_thin_delegate) / sizeof(k_asm_backend_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_backend_thin_delegate[i].x_name,
                                           k_asm_backend_thin_delegate[i].x_len)) {
      if (k_asm_backend_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_backend_thin_delegate[i].c_name, (size_t)k_asm_backend_thin_delegate[i].c_len);
      out[k_asm_backend_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_backend_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}

/** M8-tail：parse/typecheck entry 薄 bl→C（do_parse 仍 X emit 调 set_main thin→C）。 */
static const AsmBackendThinDelegateRow k_asm_pipeline_thin_delegate[] = {
    {"pipeline_parse_set_main_from_buf", 32, "pipeline_parse_set_main_from_buf_c", 34},
    {"pipeline_should_skip_x_typeck", 30, "pipeline_should_skip_x_typeck_c", 32},
    {"run_x_pipeline_typecheck_entry", 31, "run_x_pipeline_typecheck_entry_emit_c", 36},
};

/**
 * 查 pipeline 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_pipeline_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                   int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0 || !asm_module_is_pipeline_selfhost(m))
    return 0;
  nrows = (int32_t)(sizeof(k_asm_pipeline_thin_delegate) / sizeof(k_asm_pipeline_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_pipeline_thin_delegate[i].x_name,
                                           k_asm_pipeline_thin_delegate[i].x_len)) {
      if (k_asm_pipeline_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_pipeline_thin_delegate[i].c_name, (size_t)k_asm_pipeline_thin_delegate[i].c_len);
      out[k_asm_pipeline_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_pipeline_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}


/* ── driver / typeck M8-tail 薄委托表（补全五表域；历史自 ast_pool.c 抽出，live in runtime_pipeline_abi）── */
/* k_asm_driver_thin_delegate + k_asm_typeck_thin_delegate 及其 m8 查找符号。 */

/** M8-tail：driver compile 薄 bl 表已空；run_compiler_full_x* 堆 state + X post_parse 真 emit。 */
static const AsmBackendThinDelegateRow k_asm_driver_thin_delegate[] = {
};

/**
 * 查 driver/compile.x 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_driver_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                 int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0 || !asm_module_is_driver_compile_selfhost(m))
    return 0;
  nrows = (int32_t)(sizeof(k_asm_driver_thin_delegate) / sizeof(k_asm_driver_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_driver_thin_delegate[i].x_name,
                                           k_asm_driver_thin_delegate[i].x_len)) {
      if (k_asm_driver_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_driver_thin_delegate[i].c_name, (size_t)k_asm_driver_thin_delegate[i].c_len);
      out[k_asm_driver_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_driver_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}

/** typeck EMIT_HEAVY 薄委托：仅剩须 C 维持的入口（typeck 主体已 X emit）。 */
static const AsmBackendThinDelegateRow k_asm_typeck_thin_delegate[] = {
};

/**
 * typeck EMIT_HEAVY 第二遍：SKIP 桩路径 bl→C 委托或 typeck_x.o 同名实现（首遍 SKIP 仍 ret0）。
 * 实参已在 ABI 寄存器；Mach-O 由 backend_enc_call_arch 加 leading `_`。
 */
int32_t asm_typeck_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                 int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  int32_t nl;

  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0)
    return 0;
  if (!asm_module_is_typeck_selfhost(m) || asm_env_entry_emit_heavy() == 0)
    return 0;
  if (pipeline_asm_module_func_is_extern_at(m, func_index) != 0)
    return 0;
  nrows = (int32_t)(sizeof(k_asm_typeck_thin_delegate) / sizeof(k_asm_typeck_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_typeck_thin_delegate[i].x_name,
                                           k_asm_typeck_thin_delegate[i].x_len)) {
      if (k_asm_typeck_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_typeck_thin_delegate[i].c_name, (size_t)k_asm_typeck_thin_delegate[i].c_len);
      out[k_asm_typeck_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_typeck_thin_delegate[i].c_len;
      return 1;
    }
  }
  nl = pipeline_module_func_name_len_at(m, func_index);
  if (nl <= 0 || nl >= out_cap)
    return 0;
  pipeline_asm_module_func_name_copy64(m, func_index, out);
  out[nl] = 0;
  *out_len = nl;
  return 1;
}


/* Class AA parser m8_tail */
int32_t asm_parser_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                 int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0)
    return 0;
  nrows = (int32_t)(sizeof(k_wave120_parser_thin_delegate) / sizeof(k_wave120_parser_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)k_wave120_parser_thin_delegate[i].x_name,
                                           k_wave120_parser_thin_delegate[i].x_len)) {
      if (k_wave120_parser_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_wave120_parser_thin_delegate[i].c_name, (size_t)k_wave120_parser_thin_delegate[i].c_len);
      out[k_wave120_parser_thin_delegate[i].c_len] = 0;
      *out_len = k_wave120_parser_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}
