/* ============================================================================
 * pipeline_asm_parser_emit_heavy.c — backend asm parser EMIT_HEAVY domain
 *
 * wave1260 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   ASM_EMIT_HEAVY_PARSER_SLOT_MAX + asm_parser_emit_heavy_{dbg_real,
 *   bisect_max_index, slot_max} + asm_parser_mega_bisect_skip_stub
 *   + asm_parser_bootstrap_mega_emit_allowed + asm_skip_heavy_parser_mega_entry
 *   + asm_parser_emit_heavy_{force_stub, safe_helper, x_body_keep,
 *   slot_fallback_ok} + asm_parser_func_is_thin_delegate
 *   + asm_parser_m8_tail_thin_delegate_c_name (uses k_asm_parser_thin_delegate
 *     from pipeline_asm_thin_delegate.c)
 *   + asm_parser_emit_heavy_resolve_call_to_glue
 *   + asm_parser_emit_heavy_callee_is_same_module_local
 *
 * Parser EMIT_HEAVY 2nd-pass: slot fallback cap, bisect/debug knobs, mega-entry
 * skip, force-stub, safe-helper classifier, thin-delegate resolution, and
 * same-module-local callee detection. Depends on k_asm_parser_thin_delegate
 * (thin_delegate include) + asm_module_is_parser_emit_heavy (selfhost include)
 * + pipeline_module_func_name_* accessors, all defined/included earlier in the
 * host TU. Included from ast_pool.c (replaces former inline body). Not a .o.
 *
 * PLATFORM: SHARED.
 * ============================================================================ */

/** parser EMIT_HEAVY 第二遍：槽位 fallback 上限（>16 无增量；2026-06-14 提至 16）。 */
#define ASM_EMIT_HEAVY_PARSER_SLOT_MAX 16

/** XLANG_ASM_DEBUG=1 时打印 parser EMIT_HEAVY 真 emit 决策（定位 seed_mega SIGSEGV）。 */
static void asm_parser_emit_heavy_dbg_real(struct ast_Module *m, int32_t fi, const char *why) {
  uint8_t fn[128];
  int32_t fl;
  if (!link_abi_getenv("XLANG_ASM_DEBUG") || !m || fi < 0 || !why)
    return;
  fl = pipeline_module_func_name_len_at(m, fi);
  pipeline_module_func_name_copy64(m, fi, fn);
  fprintf(stderr, "xlang: parser REAL_EMIT fi=%d fn=%.*s why=%s\n", fi, (int)(fl > 127 ? 127 : fl), fn, why);
  fflush(stderr);
}

/** 调试/二分：XLANG_PARSER_EMIT_HEAVY_BISECT_N=N 上限 func_index；STUB_ONLY=1 仅 delegate 桩。 */
static int32_t asm_parser_emit_heavy_bisect_max_index(void) {
  const char *stub = link_abi_getenv("XLANG_PARSER_EMIT_HEAVY_STUB_ONLY");
  char *end = NULL;
  long v;
  const char *e;
  if (stub != NULL && stub[0] != '\0' && stub[0] != '0')
    return 0;
  e = link_abi_getenv("XLANG_PARSER_EMIT_HEAVY_BISECT_N");
  if (!e || e[0] == '\0')
    return 2147483647;
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return 2147483647;
  if (v > 2147483647L)
    return 2147483647;
  return (int32_t)v;
}

/** XLANG_PARSER_EMIT_HEAVY_SLOT_MAX=N 覆盖槽位 fallback 上限（默认 8）。 */
static int32_t asm_parser_emit_heavy_slot_max(void) {
  const char *e = link_abi_getenv("XLANG_PARSER_EMIT_HEAVY_SLOT_MAX");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return ASM_EMIT_HEAVY_PARSER_SLOT_MAX;
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return ASM_EMIT_HEAVY_PARSER_SLOT_MAX;
  if (v > 512)
    return 512;
  return (int32_t)v;
}

/**
 * XLANG_ASM_PARSER_MEGA_BISECT=<name>：单项 mega 跳过 ret0 桩以 X 真 emit（bisect 门禁用）。
 */
static int32_t asm_parser_mega_bisect_skip_stub(struct ast_Module *m, int32_t func_index, const char *name,
                                                int32_t len) {
  const char *b;
  size_t blen;
  if (!m || func_index < 0 || !name || len <= 0)
    return 0;
  b = link_abi_getenv("XLANG_ASM_PARSER_MEGA_BISECT");
  if (!b || b[0] == '\0')
    return 0;
  blen = strlen(b);
  if ((int32_t)blen != len)
    return 0;
  if (memcmp(b, name, (size_t)len) != 0)
    return 0;
  return pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)name, len);
}

/**
 * PARSE_BOOTSTRAP_EMIT 时 mega 入口是否允许 X 真 emit；MINIMAL 仅 parse_into_init / set_main_index。
 */
static int32_t asm_parser_bootstrap_mega_emit_allowed(struct ast_Module *m, int32_t func_index, const char *name,
                                                      int32_t len) {
  static const asm_boot_parse_sym_t k_min[] = {
      {"parse_into_init", 15},
      {"parse_into_set_main_index", 25},
  };
  static const asm_boot_parse_sym_t k_full[] = {
      {"parse_into_buf", 14},
      {"parse_into", 10},
      {"parse_into_init", 15},
      {"parse_into_set_main_index", 25},
      {"collect_imports_buf", 19},
  };
  const asm_boot_parse_sym_t *k;
  int32_t kn;
  int32_t i;
  if (!m || func_index < 0 || link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT") == NULL)
    return 0;
  if (!pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)name, len))
    return 0;
  if (link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT_MINIMAL") != NULL) {
    k = k_min;
    kn = (int32_t)(sizeof(k_min) / sizeof(k_min[0]));
  } else {
    k = k_full;
    kn = (int32_t)(sizeof(k_full) / sizeof(k_full[0]));
  }
  for (i = 0; i < kn; i++) {
    if (k[i].len == len && memcmp(k[i].name, name, (size_t)len) == 0)
      return 1;
  }
  return 0;
}

/**
 * parser.x EMIT_HEAVY 第二遍：巨型 parse_into/expr 入口 ret0 桩（strict 链由 parser.o / C alias 提供）。
 * XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1：experimental 重链用 ./xlang 编 parser 真 parse_into*（仅 bootstrap .o，非 gate EMIT_HEAVY）。
 */
static int32_t asm_skip_heavy_parser_mega_entry(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_MEGA_EQ(n, l)                                                                                           \
  do {                                                                                                                 \
    if (asm_parser_mega_bisect_skip_stub(m, func_index, (n), (l)))                                                     \
      break;                                                                                                           \
    if (asm_parser_bootstrap_mega_emit_allowed(m, func_index, (n), (l)))                                               \
      break;                                                                                                           \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(n), (l)))                                        \
      return 1;                                                                                                        \
  } while (0)
#define PARSER_MEGA_PFX(pfx, plen)                                                                                     \
  do {                                                                                                                 \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(plen)))                                \
      return 1;                                                                                                        \
  } while (0)
  PARSER_MEGA_EQ("parse_into_buf", 14);
  PARSER_MEGA_EQ("parse_into", 10);
  PARSER_MEGA_EQ("parse", 5);
  PARSER_MEGA_EQ("parse_one_function_impl", 23);
  PARSER_MEGA_EQ("parse_expr_into", 15);
  PARSER_MEGA_EQ("parse_block_into", 16);
  PARSER_MEGA_EQ("parse_body_lets_into", 20);
  /** parse_at_simd_builtin / finish_struct_lit / leading_int_as glue 已迁 tier4c safe。 */
  /** parse_if_* / parse_match_* glue 薄包装已迁 tier4 safe；勿 mega ret0 桩。 */
  /** 表达式 precedence 链（parse_primary/addsub/…_into）走 thin delegate 或 X 真 emit；勿 PFX mega ret0 桩。 */
#undef PARSER_MEGA_EQ
#undef PARSER_MEGA_PFX
  return 0;
}

/**
 * parser EMIT_HEAVY 第二遍：须 ret0 桩（X 真 emit Segfault / code_len 爆炸）；勿 safe_helper 白名单。
 */
static int32_t asm_parser_emit_heavy_force_stub(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_STUB_EQ(n, l)                                                                                           \
  do {                                                                                                                 \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(n), (l)))                                        \
      return 1;                                                                                                        \
  } while (0)
#define PARSER_STUB_PFX(pfx, plen)                                                                                     \
  do {                                                                                                                 \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(plen)))                                \
      return 1;                                                                                                        \
  } while (0)
  PARSER_STUB_PFX("copy_onefunc_", 13);
  PARSER_STUB_PFX("onefunc_", 8);
  PARSER_STUB_PFX("set_onefunc_", 12);
  PARSER_STUB_EQ("wrap_block_ref_as_expr", 22);
  PARSER_STUB_EQ("parser_alloc_true_bool_lit", 26);
  PARSER_STUB_EQ("parser_alloc_float_lit", 22);
  PARSER_STUB_EQ("parser_expr_wrap_in_return", 26);
  PARSER_STUB_EQ("try_skip_allow_padding_struct", 29);
  PARSER_STUB_EQ("try_skip_allow_padding_struct_buf", 33);
  /** parse_peek_function_name_buf 已迁 tier4 safe（单行 bl→glue X emit OK）。 */
  /** parser_token_is_label_start：勿入 safe_helper（单独即 elf_ec=-1）；仅 thin_delegate→glue。 */
#undef PARSER_STUB_EQ
#undef PARSER_STUB_PFX
  return 0;
}

/**
 * parser EMIT_HEAVY 第二遍：按名判定可安全 X 真 emit 的小 helper（扩 __text；名长须与 module 表一致）。
 */
static int32_t asm_parser_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_SAFE_EQ(n, l)                                                                                           \
  do {                                                                                                                 \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(n), (l)))                                        \
      return 1;                                                                                                        \
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
  /** LexerResult/CollectImportsResult 字段读：slice 路径须 glue bl（X 真 emit 内调 lexer_next_into → elf_ec=-1）。 */
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
  /** tier4 selective X emit：单行 bl→glue（alloc/wrap_in_return X 真 emit → elf_ec=-1）。 */
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
  /** *_into_buf：parser_slice_from_buf + bl *_into（13al；勿 lexer_next_buf X 深循环）。 */
  PARSER_SAFE_EQ("skip_one_enum_into_buf", 22);
  PARSER_SAFE_EQ("skip_one_struct_into_buf", 24);
  PARSER_SAFE_EQ("skip_one_trait_into_buf", 23);
  PARSER_SAFE_EQ("skip_one_impl_into_buf", 22);
  PARSER_SAFE_EQ("skip_one_extern_into_buf", 24);
  PARSER_SAFE_EQ("skip_one_function_full_into_buf", 31);
  PARSER_SAFE_EQ("skip_one_enum_register_into_buf", 31);
  PARSER_SAFE_EQ("parse_one_extern_and_add_into_buf", 33);
  /** *_buf：parser_slice_from_buf + bl slice 路径（13bc；深循环仍在 C glue）。 */
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
  /** slice 兼容包装 / glue 单行桩（扩 __text 有限；勿 lexer_next_into X 体）。 */
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
  /** tier3a（21 项）：slice 非 _buf；+1180B __text。 */
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
  /** tier3b（69 项）：跳过 parser_token_is_label_start（elf_ec=-1）；+936B __text。 */
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
  /** tier4b：mega→safe glue 薄包装（if/match slice 路径）。 */
  PARSER_SAFE_EQ("parse_if_stmt_into", 18);
  PARSER_SAFE_EQ("parse_if_expr_into", 18);
  PARSER_SAFE_EQ("parse_match_into", 16);
  PARSER_SAFE_EQ("parse_match_subject_into", 24);
  /** tier4c：mega→safe glue 薄包装（simd / struct_lit / leading_int_as）。 */
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

/** delegate 表内仍有 X 体：强制真 emit（须先于 thin_delegate）；当前全禁（experimental emit SIGSEGV）。 */
static int32_t asm_parser_emit_heavy_x_body_keep(struct ast_Module *m, int32_t func_index) {
  (void)m;
  (void)func_index;
  return 0;
#if 0
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_KEEP_EQ(n, l)                                                                                           \
  do {                                                                                                                 \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(n), (l)))                                        \
      return 1;                                                                                                        \
  } while (0)
  PARSER_KEEP_EQ("struct_layout_first_name_match_idx", 34);
  PARSER_KEEP_EQ("struct_layout_name_exists_arr", 29);
  PARSER_KEEP_EQ("struct_layout_placeholder_idx", 29);
#undef PARSER_KEEP_EQ
  return 0;
#endif
}

/** 槽位 fallback：小体 X 真 emit（>ASM_EMIT_HEAVY_PARSER_SLOT_MAX 仍桩化）。 */
static int32_t asm_parser_emit_heavy_slot_fallback_ok(struct ast_ASTArena *arena, int32_t body_ref, int32_t slots) {
  (void)arena;
  if (body_ref <= 0)
    return 0;
  return slots <= ASM_EMIT_HEAVY_PARSER_SLOT_MAX;
}

/** 查 func 是否在 k_asm_parser_thin_delegate 表（EMIT_HEAVY bl→C glue）。 */
static int32_t asm_parser_func_is_thin_delegate(struct ast_Module *m, int32_t func_index) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
  nrows = (int32_t)(sizeof(k_asm_parser_thin_delegate) / sizeof(k_asm_parser_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_parser_thin_delegate[i].x_name,
                                           k_asm_parser_thin_delegate[i].x_len))
      return 1;
  }
  return 0;
}

/**
 * 查 parser 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_parser_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                 int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0)
    return 0;
  /** 表内均为 parser.x 符号；勿绑 asm_module_is_parser_selfhost（marker 偶发缺失时 delegate 仍须 bl）。 */
  nrows = (int32_t)(sizeof(k_asm_parser_thin_delegate) / sizeof(k_asm_parser_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_parser_thin_delegate[i].x_name,
                                           k_asm_parser_thin_delegate[i].x_len)) {
      if (k_asm_parser_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_parser_thin_delegate[i].c_name, (size_t)k_asm_parser_thin_delegate[i].c_len);
      out[k_asm_parser_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_parser_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}

/**
 * parser EMIT_HEAVY：同模块 X 真 emit 调 skip/delegate 目标时重定向 bl glue（避免 U x 名）。
 * 成功写 out/out_len 并返回 1。
 */
int32_t asm_parser_emit_heavy_resolve_call_to_glue(struct ast_Module *m, uint8_t *name, int32_t name_len,
                                                    uint8_t *out, int32_t out_cap, int32_t *out_len) {
  int32_t fi;
  if (!m || !name || name_len <= 0 || !out || !out_len || out_cap <= 0)
    return 0;
  *out_len = 0;
  if (!asm_module_is_parser_emit_heavy(m))
    return 0;
  for (fi = 0; fi < m->num_funcs; fi++) {
    if (pipeline_module_func_name_equal_at(m, fi, name, name_len) == 0)
      continue;
    if (asm_parser_m8_tail_thin_delegate_c_name(m, fi, out, out_cap, out_len) != 0)
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_module_reset_parse_counters", 36)) {
      const char *c = "pipeline_module_reset_parse_counters_c";
      int32_t n = 38;
      if (n >= out_cap)
        return 0;
      memcpy(out, c, (size_t)n);
      out[n] = 0;
      *out_len = n;
      return 1;
    }
    return 0;
  }
  return 0;
}

/**
 * parser EMIT_HEAVY：callee 为本模块已定义（非 extern）func 时返回 1。
 * X 真 emit 调 stub/同模块 helper 应 enc_call→patch，勿 elf_add_reloc 产生 unexpected U。
 */
int32_t asm_parser_emit_heavy_callee_is_same_module_local(struct ast_Module *m, uint8_t *name, int32_t name_len) {
  int32_t fi;
  if (!m || !name || name_len <= 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
  for (fi = 0; fi < m->num_funcs; fi++) {
    if (pipeline_module_func_name_equal_at(m, fi, name, name_len) == 0)
      continue;
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0)
      return 0;
    return 1;
  }
  return 0;
}
