/* ============================================================================
 * pipeline_asm_emit_heavy_safe_helper.c — backend asm EMIT_HEAVY safe-helper classifiers
 *
 * wave1259 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   asm_typeck_emit_heavy_safe_helper
 *   + asm_pipeline_emit_heavy_safe_helper
 *   + asm_driver_compile_emit_heavy_safe_helper
 *   + asm_skip_heavy_backend_m8_helper_keep
 *   + asm_skip_heavy_backend_helper_keep
 *
 * EMIT_HEAVY 2nd-pass per-module classifiers: by function name, decide which
 * small helpers are safe to really emit (expand __text past 8KiB) vs stub.
 * Depends on static pipeline_module_func_name_has_prefix_at + extern
 * pipeline_module_func_name_equal_at + asm_module_is_{backend,typeck,pipeline,
 * driver_compile}_selfhost (selfhost domain), all defined/included earlier in
 * the host TU. Included from ast_pool.c (replaces former inline body). Not a
 * separate .o.
 *
 * PLATFORM: SHARED.
 * ============================================================================ */

/** typeck EMIT_HEAVY 第二遍：按名判定可安全真 emit 的小 helper（扩 __text 过 8KiB）。 */
static int32_t asm_typeck_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0)
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_kind_ordinal", 17))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"name_equal", 10))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "ensure_", 7))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "find_or_alloc_", 14))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_field_offset_from_layout", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_field_type_ref_from_layout", 30))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_name", 18))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_field_name", 24))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_import_path_slice", 24))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_import_binding_name", 26))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_import_select_name", 25))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_top_level_let_name", 25))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_find_layout_idx", 22))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_x_named_builtin_", 24))
    return 1;
  /** §11.1 align/size：layout 命中走 C glue，X 真 emit 递归/array 分支（勿 metrics depth slot）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_align", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_size", 19))
    return 1;
  /** §11.1 metrics：scratch 预绑定 + typeck_i32_ptr_store 写 out；槽位≤96 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_struct_layout_metrics", 28))
    return 1;
  /** import 合并 / struct_lit 登记：scratch 预绑定 + glue 读 num_struct_layouts。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_merge_dep_struct_layouts_into_entry", 42))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_wpo_unify_soa_layouts", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_ensure_primitive_by_kind_ord", 35))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_find_or_alloc_compound_type_ref", 38))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ensure_struct_layout_from_struct_lit", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_dep_return_type_in_caller_arena", 35))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"dep_return_type_to_caller_arena", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_field_offset_from_layout_deps", 33))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_field_type_ref_from_layout_deps", 35))
    return 1;
  /** FIELD_ACCESS 内联池字段 / Expr 标量回落：小 helper X 真 emit（layout_deps/name_fallback 已真 emit）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_inline_u8_64_array_field_type_ref", 40))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_expr_inline_array_field_type_ref", 39))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"expr_field_access_fallback_scalar_type_ref", 42))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_field_access_lexer_wrapper_fallback", 42))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"entry_module_find_struct_layout_index", 37))
    return 1;
  /** ord>45 小 helper：import 路径分段 / diag 追加 / 隐式 return 判定 / parent 链 patch。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_import_path_segment_count", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_import_segment_at", 24))
    return 1;
  /** ord>58：diag 缓冲追加（小循环体；fmt_* 仍 mega 桩）。 */
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_diag_append_", 19))
    return 1;
  /** diag fmt 族：glue 读类型池 + 局部序数；勿 ast_arena_type_get 按值 Type。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_fmt_type_at", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_fmt_type_into", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_fmt_type_or_question", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_resolve_scan_dep_with_apply", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_return_type", 31))
    return 1;
  /** 隐式尾返回判定：tail ref 扫描 + ast_expr_disallows_implicit_tail（patch 4096 后 X 真 emit）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"func_body_tail_expr_ref_for_implicit_rule", 41))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"func_body_has_implicit_return_tail", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_binop", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_binop_cmp", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_method_call", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_method_call_arg", 33))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_as", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_struct_lit", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_struct_lit_field", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_field_access", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_const", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_let", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_while", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_for", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_if", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_final", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_binop_arith", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"find_func_return_type_in_module", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"find_func_return_type_in_module_by_name", 39))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_whole_import_qualified_call_return_type", 47))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_binding_import_return_type", 39))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_select_import_return_type", 38))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_local_module", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_try_whole_import", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_try_binding_import", 38))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_scan_dep", 28))
    return 1;
  /** S2 X 真 emit：expr/type 小 helper（glue 指针读池；勿 Type 按值 ast_arena_type_get）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"expr_type_ref", 13))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_ref_is_bool", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_ref_is_bool_impl", 21))
    return 1;
  /** type_refs_equal 薄包装可 X emit；拆分 named/same_kind/impl 逐步 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal_impl", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_return_operand_matches", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_integer_widen_ok", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"expr_var_name_equal_func", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_ret_coerce_integral_to_expect_i32", 40))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_ret_coerce_integral_widen", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_expr_to_decl", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal_named", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal_same_kind", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_lit_to_decl", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_enum_field_to_decl", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_float_lit_to_decl", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_named_call_to_decl", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_array_vector_lit_to_decl", 43))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_vector_binop_to_decl", 39))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_slice_from_array", 35))
    return 1;
  /** validate 薄循环：metrics/align/size 仍 mega/thin stub（独立 X emit SIGSEGV）；本函数 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_validate_struct_layouts_zero_padding", 43))
    return 1;
  /** typeck_x_ast 薄入口见 mega_entry；check_block 薄 guard 仍 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block", 11))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block_as_loop_body", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_loop_depth_push", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_loop_depth_pop", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_patch_all_body_parent_links", 34))
    return 1;
  /** check_expr/check_block 薄 guard→check_*_impl；impl/mega 走 asm_skip_heavy_typeck_mega_entry 桩。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr", 10))
    return 1;
  /** check_expr mega 分派子 helper（assign/index/unary/addr/deref/var/return/panic）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_expr_is_any_assign_kind", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_assign", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_index", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_unary", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_addr_of", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_deref", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_var", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_return", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_panic", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_break_continue", 32))
    return 1;
  /** check_block_impl 编排子 helper（stmt_order/impl 主体 mega 桩）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_consts", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_lets", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_whiles", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_fors", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_ifs", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_expr_stmts", 36))
    return 1;
  /** check_expr_impl 小 kind 子 helper（impl/mega 主体 mega 桩）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_int_lit", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_bool_lit", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_float_lit", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_enum_variant", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_block", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_if_ternary", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_match", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_match_arm", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_call", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_call_arg", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_call_resolve", 30))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_", 14))
    return 0;
  return 0;
}

/**
 * pipeline EMIT_HEAVY 第二遍：编排 helper X 真 emit；parse/typecheck 关键路径 thin→C（strict smoke）。
 * S3：resolve/read 经 weak→强符号 dispatch（build_asm 覆盖 impl_c）。
 */
static int32_t asm_pipeline_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_pipeline_selfhost(m))
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_one_function_ok", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_should_skip_x_typeck", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_loaded_buf_cap", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_parse_entry_if_needed", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_typecheck_entry", 31))
    return 1;
  /** parse set_main + typeck 分派：if(CALL) 模式 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_parse_set_main_from_buf", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_typeck_parsed_module", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_typeck_entry_module", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_fill_dep_import_path", 36))
    return 1;
  /** import 路径含 '.' 探测：纯 while，无 let=CALL。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_import_has_dot", 27))
    return 1;
  /** 单 import resolve+read：X 栈 path + if(CALL!=0) return。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_load_import_resolve_read", 33))
    return 1;
  /** 单 import 全链 resolve/read/preprocess/parse；X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_load_import_from_disk", 30))
    return 1;
  /** 单 import 槽 bind 或 load_from_disk；X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_load_one_import_slot", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_prepare_dep_codegen_path", 33))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_finish_dep_codegen_diag", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_parse_entry_do_parse", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_codegen_one_dep", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_codegen_entry", 29))
    return 1;
  /** sync 入口：null 检查 + 有界 while(CALL!=0) + if(sync_one) X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_sync_dep_slots_from_driver", 35))
    return 1;
  /** dep 批量 codegen：有界 while + run_x_pipeline_codegen_one_dep X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_codegen_deps", 28))
    return 1;
  /** load/sync deps：import 有界 while + sync/typeck merge X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_load_and_sync_direct_import_deps", 41))
    return 1;
  /** resolve 编排：lib_root while + try_* CALL（try_* 仍 thin→C）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_x", 15))
    return 1;
  /** resolve try_*：sidecar off + if(CALL) 模式 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_try_one_lib_root", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_try_entry_dir", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_try_flat_import_under_lib", 38))
    return 1;
  /** 完整流水线编排：run_x_pipeline_impl X 真 emit（if(CALL)+last_rc_get 模式）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_impl", 19))
    return 1;
  /** load/typecheck phase 编排 + last_rc sidecar。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_load_deps_after_parse", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_typecheck_after_load", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"lsp_diag_typeck_after_load", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"lsp_diag_parse_typeck_buf", 25))
    return 1;
  return 0;
}

/**
 * driver/compile.x EMIT_HEAVY 第二遍：argv 分 helper + dispatch X 真 emit；post_parse / run_compiler_full_x 仍桩。
 */
static int32_t asm_driver_compile_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_driver_compile_selfhost(m))
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"compile_dispatch_asm_backend", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"compile_dispatch_emit_c_path", 28))
    return 1;
  /** driver_compile_gen.o 导出带 driver_ 前缀；module 表多为裸名，二者均匹配。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_dispatch_asm_backend", 35))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_dispatch_emit_c_path", 35))
    return 1;
  /** run_compiler_full_x* 大栈/复杂分派：EMIT_HEAVY 堆 state + post_parse/dispatch X 真 emit（thin 表已空）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_state_key", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_ensure_default_lib", 29))
    return 1;
  /** parse_argv 分 helper：init/step/loop/finalize/入口 X 真 emit（单函数双 512 栈数组 SIGSEGV）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_init", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_step", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_loop", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_finalize", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_scan_c", 31))
    return 0;
  /** run_compiler_full_x / post_parse：堆 state + dispatch X 真 emit（勿 thin→impl_c）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_compiler_full_x", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_compiler_full_x_post_parse", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_run_compiler_full_x", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_run_compiler_full_x_post_parse", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"path_ends_x", 12))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"target_has_arm", 14))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "eq_", 3))
    return 1;
  return 0;
}

/**
 * backend EMIT_HEAVY 第二遍：按符号名保留小 helper 真 emit（覆盖 #87+ 索引桩；219 func 模块中 arch_emit/enc 常在 #87 之后）。
 * M8-tail：fold_/asm_import_ 等前缀体 + 薄包装 C 委托函数按名放行。
 */
static int32_t asm_skip_heavy_backend_m8_helper_keep(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
#define ASMB_M8_HLP_PREFIX(pfx, plen)                                                                                  \
  do {                                                                                                                 \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(plen)))                                \
      return 1;                                                                                                        \
  } while (0)
  ASMB_M8_HLP_PREFIX("asm_import_", 11);
  ASMB_M8_HLP_PREFIX("asm_build_import_", 17);
  ASMB_M8_HLP_PREFIX("asm_c_prefix_", 13);
  ASMB_M8_HLP_PREFIX("fold_", 5);
  ASMB_M8_HLP_PREFIX("asm_module_named_", 17);
  ASMB_M8_HLP_PREFIX("asm_expr_binop_", 15);
  ASMB_M8_HLP_PREFIX("asm_field_access_", 17);
#undef ASMB_M8_HLP_PREFIX
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ctx_push_loop_labels", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ctx_pop_loop_labels", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_hoist_top_level_lets_for_codegen", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ctx_reset", 9))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"compute_frame_size", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf", 13))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"local_offset", 12))
    return 1;
  /** M8-tail：形参/局部槽与 ELF/text 块体薄包装（单行 C 委托），扩 backend.o __text。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"fill_param_slots", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"fill_local_slots", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_body_elf", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_inits_elf", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_if_then_block_body_elf", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_while_loop_elf", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_for_loop_elf", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_loop_body_content", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_loop_body_content_elf", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_next_label", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"format_label_id", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf_call", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf_method_call", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_emit_call_args_elf", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_inits", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_body", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_while_loop", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_for_loop", 13))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_if_then_block_body_text", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr", 9))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_call", 14))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_method_call", 21))
    return 1;
  return 0;
}

/** 旧名别名：arch_emit_/enc_ 前缀 helper。 */
static int32_t asm_skip_heavy_backend_helper_keep(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
#define ASMB_KEEP_PREFIX(pfx)                                                                                            \
  do {                                                                                                                 \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(sizeof(pfx) - 1)))                     \
      return 1;                                                                                                        \
  } while (0)
  ASMB_KEEP_PREFIX("arch_emit_");
  ASMB_KEEP_PREFIX("enc_");
#undef ASMB_KEEP_PREFIX
  return 0;
}

/* ── EMIT_HEAVY 第二遍 backend/typeck mega + m8-tail skip 入口分类器（补全 skip_heavy 全集；自 ast_pool.c 抽出）── */

/**
 * M8-tail：backend 薄包装 helper 按名真 emit，须先于 #87+ 索引桩（emit_block_body_elf #179 等）。
 * 不含 fold_/asm_import_ 等前缀体，避免 Abort 带内误放行大函数。
 */
static int32_t asm_skip_heavy_backend_m8_tail_thin_keep(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"fill_param_slots", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"fill_local_slots", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"compute_frame_size", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_body_elf", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_inits_elf", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_if_then_block_body_elf", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_while_loop_elf", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_for_loop_elf", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_loop_body_content", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_loop_body_content_elf", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_next_label", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"format_label_id", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf_call", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf_method_call", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_emit_call_args_elf", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_inits", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_body", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_while_loop", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_for_loop", 13))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_if_then_block_body_text", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr", 9))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_call", 14))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_method_call", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_index_eff_addr_text", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_index_eff_addr_elf", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_lvalue_eff_addr_text", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_lvalue_eff_addr_elf", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_emit_call_args_text", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"local_offset", 12))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_resolve_whole_import_qualified_symbol", 41))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_skip_heavy_stub_elf", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"simd_try_inline_shuffle_call_elf", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"simd_try_inline_select_call_elf", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"simd_try_inline_binop2_call_elf", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"simd_try_inline_fma3_call_elf", 29))
    return 1;
  return 0;
}

/**
 * typeck EMIT_HEAVY 第二遍：layout/diag 小 helper 真 emit（ExprKind=51 已修；槽位过大仍走 mega/默认桩）。
 */
static int32_t asm_skip_heavy_typeck_helper_keep(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_typeck_selfhost(m))
    return 0;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_", 14))
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_align", 20) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_size", 19))
    return 0;
  return 0;
}

/**
 * backend 第二遍 EMIT_HEAVY：按符号名桩化 mega codegen/emit 入口（expr 树递归、块体、入口 asm_codegen_ast）。
 * 小 helper（arch_emit_*、try_fold_*、fill_param_slots 等）仍真 emit，扩 backend.o __text 且避免宿主栈 Abort。
 */
static int32_t asm_skip_heavy_backend_mega_entry(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
#define ASMB_MEGA(name, nlen)                                                                                          \
  do {                                                                                                                 \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(name), (nlen)))                                  \
      return 1;                                                                                                        \
  } while (0)
  ASMB_MEGA("asm_codegen_ast", 15);
  ASMB_MEGA("asm_codegen_ast_to_elf", 22);
  ASMB_MEGA("asm_codegen_ast_seed_mega", 25);
  ASMB_MEGA("asm_codegen_ast_to_elf_seed_mega", 32);
  /** emit_expr / emit_block_* / loop / if-then / fill_* / call / local_offset：thin_keep 真 emit（C/partial 委托）。 */
  /** extern/C sidecar glue：.x 体含 ExprKind 54 等 asm 未支持形态，须桩化。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_ctx_key", 11))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "asm_ctx_local_", 14))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "asm_ctx_block_", 14))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "asm_ctx_loop_", 13))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "asm_ctx_ensure_", 15))
    return 1;
  return 0;
}

/** typeck 第二遍 emit：桩化巨型 typecheck/diag/implicit-return 入口；layout/helper 须真 emit 过 8KiB。 */
static int32_t asm_skip_heavy_typeck_mega_entry(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0)
    return 0;
  if (/** typeck_skip_heavy_selfhost 等 mega 入口仍桩化。 */
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_skip_heavy_selfhost_func_body", 36))
    return 1;
  /**
   * check_* mega：宿主编译器真 emit 会 SIGSEGV；EMIT_HEAVY 第二遍 ret0 桩。
   * 子 helper 经 asm_typeck_emit_heavy_safe_helper 分片 X 真 emit。
   */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr_impl_mega", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr_impl", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block_impl", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_stmt_order_one", 33))
    return 1;
  /** 遍历全模块函数：槽位高；EMIT_HEAVY 第二遍 ret0 桩（子 helper check_one_func 仍 X）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_impl", 17))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_library", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_check_all_funcs_loop", 33))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_check_one_func", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast", 12))
    return 1;
  /** type_kind_ordinal 在瘦 typeck #0 须真 emit；勿在此 mega 桩。 */
  return 0;
}
