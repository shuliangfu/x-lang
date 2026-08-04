
/* ============================================================================
 * pipeline_asm_thin_delegate.c — backend asm M8-tail thin delegate tables
 *
 * wave1258 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   AsmBackendThinDelegateRow + k_asm_backend_thin_delegate
 *   + asm_backend_m8_tail_thin_delegate_c_name
 *   + k_asm_pipeline_thin_delegate
 *   + asm_pipeline_m8_tail_thin_delegate_c_name
 *   + k_asm_parser_thin_delegate
 *
 * M8-tail thin delegate: X function name → C glue/partial delegate symbol
 * lookup tables for backend.x / pipeline.x / parser.x self-host units.
 * First-pass SKIP stub path emits bl (not ret0) to expand __text.
 * k_asm_parser_thin_delegate queried by asm_parser_m8_tail_thin_delegate_c_name
 * (defined later in ast_pool.c parser_emit_heavy domain).
 * Included from ast_pool.c (replaces former inline body). Not a separate .o.
 *
 * PLATFORM: SHARED.
 * ============================================================================ */

/**
 * M8-tail：backend.x 薄包装 X 名 → C glue/partial 委托符号。
 * 首遍 SKIP 桩路径 emit bl（非 ret0），扩 build_asm/backend.o __text。
 */
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
int32_t asm_backend_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
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
int32_t asm_pipeline_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
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

/** M8-tail：parser.x 薄包装 X 名 → parser_asm_thin_c.c *_glue 或 pipeline_glue *_c（EMIT_HEAVY bl 扩 __text）。
 * slot_fallback / safe_helper 真 emit：collect_imports_buf / parse_one_function_library_buf 等。 */
static const AsmBackendThinDelegateRow k_asm_parser_thin_delegate[] = {
    {"collect_imports_buf", 19, "parser_collect_imports_buf_glue", 31},
    {"advance_past_cond_rparen_into", 29, "parser_advance_past_cond_rparen_into_glue", 41},
    {"advance_past_stmt_semicolon_into", 32, "parser_advance_past_stmt_semicolon_into_glue", 44},
    {"alloc_pointee_type_ref_from_tok", 31, "parser_alloc_pointee_type_ref_from_tok_glue", 43},
    {"append_block_lets_from_res", 26, "parser_append_block_lets_from_res_glue", 38},
    {"body_skip_let_const_then_if_buf", 31, "parser_body_skip_let_const_then_if_buf_glue", 43},
    {"body_skip_let_const_then_if", 27, "parser_body_skip_let_const_then_if_glue", 39},
    {"body_skip_let_const_then_if_into", 32, "parser_body_skip_let_const_then_if_into_glue", 44},
    {"collect_imports", 15, "parser_collect_imports_glue", 27},
    {"copy_lex_from_import_into", 25, "parser_lex_copy_from_import_into_glue", 38},
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

/* ── driver / typeck M8-tail 薄委托表（补全五表域；自 ast_pool.c 抽出）── */
/* k_asm_driver_thin_delegate + k_asm_typeck_thin_delegate 及其 m8 查找符号。 */

/** M8-tail：driver compile 薄 bl 表已空；run_compiler_full_x* 堆 state + X post_parse 真 emit。 */
static const AsmBackendThinDelegateRow k_asm_driver_thin_delegate[] = {
};

/**
 * 查 driver/compile.x 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_driver_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
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
int32_t asm_typeck_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
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
