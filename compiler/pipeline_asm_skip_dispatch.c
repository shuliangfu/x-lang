/* pipeline_asm_skip_dispatch.c — asm 桩化/skip dispatch 域（自 ast_pool.c 抽出）
 *
 * asm_empty_text_stub_label：空 __text 桩的确定性标签名生成（FNV-1a hash → _xlang_asm_stu_<dec>）。
 * asm_skip_heavy_module_func_body：EMIT_HEAVY 第二遍 / build_xlang_asm 的中央 skip dispatch——
 *   按模块自举类型（backend/typeck/pipeline/parser/driver）＋ env（BUILD_SKIP_TYPECK／
 *   ENTRY_EMIT_HEAVY）＋ 函数名/索引/槽位阈值，决定是否 ret0 桩化该 func body。
 * 依赖（均先于此 include 定义）：selfhost 9 谓词／skip_heavy 分类器（safe_helper）／
 *   parser_emit_heavy 分类器／asm_count_block_stack_slots（block_tree）／asm_env_*（Block B）／
 *   ASM_HEAVY_BODY_SLOT_THRESHOLD 宏／g_asm_skip_pipeline_ctx 静态／pipeline_dep_ctx_* 访问器。
 * 公共符号；TU 内调用方（codegen_mega_body／emit_call_args／glue）均在此 include 之后或经
 *   pipeline_glue.c 前向声明。
 */

/**
 * out 至少 24 字节；*out_len 为 NUL 终止名长（不含 NUL）。
 */
void asm_empty_text_stub_label(struct ast_Module *m, uint8_t *out, int32_t out_cap, int32_t *out_len) {
  uint32_t h = 2166136261u;
  int32_t i, k, nl, pos, d, nd;
  uint32_t v;
  uint8_t digits[16];
  static const uint8_t prefix[] = "_xlang_asm_stu_";
  if (!out || out_cap < 24 || !out_len) {
    if (out_len)
      *out_len = 0;
    return;
  }
  if (m && m->num_funcs > 0) {
    for (i = 0; i < m->num_funcs; i++) {
      nl = pipeline_module_func_name_len_at(m, i);
      for (k = 0; k < nl; k++)
        h = (uint32_t)((h ^ (uint8_t)pipeline_module_func_name_byte_at(m, i, k)) * 16777619u);
    }
  } else {
    h ^= (uint32_t)(m ? m->num_imports : 0);
    h *= 16777619u;
  }
  memcpy(out, prefix, sizeof(prefix) - 1);
  pos = (int32_t)(sizeof(prefix) - 1);
  nd = 0;
  v = h;
  if (v == 0)
    digits[nd++] = (uint8_t)'0';
  else {
    while (v > 0 && nd < 16) {
      digits[nd++] = (uint8_t)('0' + (v % 10));
      v /= 10;
    }
  }
  for (d = nd - 1; d >= 0; d--)
    out[pos++] = digits[d];
  out[pos] = 0;
  *out_len = pos;
}

int32_t asm_skip_heavy_module_func_body(struct ast_Module *m, struct ast_ASTArena *arena, int32_t func_index) {
  int32_t body_ref;
  int32_t slots;
  int32_t slot_threshold;
  if (!m || func_index < 0)
    return 0;
  /**
   * 用户程序（非 parser/typeck/backend/pipeline/driver 自举模块）：须完整 emit 真机码。
   * 须先于 XLANG_ASM_BUILD_SKIP_TYPECK 桩分支；否则 return42 等单文件 -o 被 ret0 桩化或 WPO 跳过。
   */
  if (!asm_module_is_compiler_selfhost(m))
    return 0;
  /**
   * ast.x 首遍 SKIP：除 whitelist 外一律 ret0 桩（含 extern 占位；真符号由 ast_pool/pipeline_x 提供）。
   */
  if (asm_module_is_ast_selfhost(m) && asm_env_build_skip_typeck() != 0 && asm_env_entry_emit_heavy() == 0) {
    if (asm_skip_typeck_entry_whitelist(m, func_index) != 0)
      return 0;
    return 1;
  }
  /**
   * 用户 import+exe（asm_entry_module_only、非大入口）：须完整 emit 入口模块，禁止 ret0 桩。
   * build_xlang_asm（XLANG_ASM_BUILD_SKIP_TYPECK）同为 ENTRY_MODULE_ONLY，须走下方白名单/桩路径，勿全量 emit。
   */
  if (g_asm_skip_pipeline_ctx != NULL &&
      pipeline_dep_ctx_asm_entry_module_only(g_asm_skip_pipeline_ctx) != 0 &&
      pipeline_dep_ctx_use_asm_backend(g_asm_skip_pipeline_ctx) != 0 &&
      driver_typeck_skip_large_entry() == 0 &&
      asm_env_build_skip_typeck() == 0 &&
      asm_env_entry_emit_heavy() == 0) {
    return 0;
  }
  /**
   * build_xlang_asm：XLANG_ASM_BUILD_SKIP_TYPECK 默认桩 emit（非 extern/非白名单 ret 0）。
   * XLANG_ASM_ENTRY_EMIT_HEAVY=1 时仅跳过 pipeline typecheck，emit 仍走槽位阈值真机码。
   */
  if (asm_env_build_skip_typeck() != 0 && asm_env_entry_emit_heavy() == 0) {
    if (pipeline_asm_module_func_is_extern_at(m, func_index) != 0)
      return 0;
    if (asm_skip_typeck_entry_whitelist(m, func_index) != 0)
      return 0;
    return 1;
  }
  /* 小模块（lexer 等 ~21 func）：首遍 SKIP 桩前 10 项；EMIT_HEAVY 第二遍改走 driver/pipeline 按名白名单。 */
  if (asm_env_build_skip_typeck() != 0 && asm_env_entry_emit_heavy() == 0 && m->num_funcs > 0 &&
      m->num_funcs <= 32 && func_index < 10)
    return 1;
  /** 首遍 SKIP 桩：mega check_* 勿真 emit；EMIT_HEAVY 第二遍改走下方按名/索引桩。 */
  if (asm_env_entry_emit_heavy() == 0 &&
      (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr", 10) ||
       pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr_impl", 15) ||
       pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block", 11) ||
       pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block_impl", 16)))
    return 1;
  /**
   * ENTRY_EMIT_HEAVY 第二遍：放宽槽位阈值；桩化 mega typecheck/diag 入口（按符号名）。
   * typeck 大入口：#90–117 Abort 区间（索引+按名桩）；#118+ 真 emit。
   * backend 大入口：#87–189 索引桩 + emit_expr/asm_codegen_ast 等按名 mega 桩；其余 helper 真 emit。
   * 非 typeck/backend 大模块且 func≥160：func#72+ 仍粗筛桩化。
   */
  if (asm_env_entry_emit_heavy() != 0) {
    int32_t typeck_ndef = asm_module_is_typeck_selfhost(m) ? asm_module_num_defined_funcs(m) : 0;
    int32_t typeck_ord = asm_module_defined_func_ordinal(m, func_index);
    /**
     * parser.x EMIT_HEAVY 第二遍：须先于 typeck ndef 启发式（parser ndef≈130 与 typeck 重叠）。
     */
    if (asm_module_is_parser_emit_heavy(m)) {
      if (asm_skip_heavy_parser_mega_entry(m, func_index) != 0)
        return 1;
      /** STUB_ONLY / BISECT_N=0：仅 thin delegate 桩。 */
      if (asm_parser_emit_heavy_bisect_max_index() == 0)
        return 1;
      /**
       * safe_helper 须先于 force_stub：onefunc_result_pool_ptr 等被 onefunc_ 前缀误桩，
       * 白名单内小 helper 仍须 X 真 emit 扩 __text。
       */
      if (asm_parser_emit_heavy_safe_helper(m, func_index) != 0) {
        asm_parser_emit_heavy_dbg_real(m, func_index, "safe_helper");
        return 0;
      }
      if (asm_parser_emit_heavy_force_stub(m, func_index) != 0)
        return 1;
      /** thin delegate：薄包装 bl→C glue。 */
      if (asm_parser_func_is_thin_delegate(m, func_index) != 0)
        return 1;
      if (func_index >= asm_parser_emit_heavy_bisect_max_index())
        return 1;
      body_ref = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref <= 0)
        return 1;
      slots = asm_count_block_stack_slots(arena, body_ref);
      if (slots > asm_parser_emit_heavy_slot_max())
        return 1;
      asm_parser_emit_heavy_dbg_real(m, func_index, "slot_fallback");
      /** 槽位 fallback：≤SLOT_MAX 小函数 X 真 emit（ExprKind 序已对齐 primary_slice）。 */
      return 0;
    }
    /**
     * typeck.x 合并 glue 后 ~160–180 已定义 func：#0–89 glue 桩；#90–117 按名小 helper；
     * #118–159 check_* 桩；#160+ typeck_x_ast mega 桩（序号均按非 extern ordinal）。
     */
    if (asm_module_is_typeck_selfhost(m) && typeck_ndef >= 160 && typeck_ndef <= 180) {
      if (typeck_ord < 0)
        return 1;
      if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
        return 1;
      /** safe_helper 须先于 ord #118–159 粗筛，否则 expr_type_ref 等无法 X 真 emit。 */
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      if (typeck_ord >= 118 && typeck_ord <= ASM_EMIT_HEAVY_TYPECK_INDEX_HI)
        return 1;
      /** 按名放行 layout/小 helper（须在 ordinal<90 粗筛之前，type_kind_ordinal 在 #0）。 */
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_kind_ordinal", 17))
        return 0;
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      if (typeck_ord < 90)
        return 1;
      return 1;
    }
    /** 瘦 typeck：safe_helper 白名单 + 槽位过关 X 真 emit；上限随 block helper 扩容（2026-06 ndef≈130）。 */
    if (typeck_ndef >= 75 && typeck_ndef <= 200 && !asm_module_is_backend_selfhost(m) &&
        !asm_module_is_parser_emit_heavy(m)) {
      int32_t body_ref_thin;
      int32_t slots_thin;
      if (typeck_ord < 0)
        return 1;
      if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
        return 1;
      /** merge_dep 须先于 safe_helper 粗筛（双循环槽位高；按名强制 X 真 emit）。 */
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_merge_dep_struct_layouts_into_entry", 42))
        return 0;
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_wpo_unify_soa_layouts", 28))
        return 0;
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) == 0)
        return 1;
      body_ref_thin = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref_thin <= 0)
        return 1;
      slots_thin = asm_count_block_stack_slots(arena, body_ref_thin);
      if (slots_thin > ASM_EMIT_HEAVY_TYPECK_LAYOUT_SLOT_MAX)
        return 1;
      return 0;
    }
    /**
     * pipeline.x：编排经 asm_pipeline_emit_heavy_safe_helper 真 emit；C mega 仅 ast_pool/pipeline_glue 回退。
     * safe_helper 小函数 X 真 emit（S3 起步）。
     */
    if (asm_module_is_pipeline_selfhost(m)) {
      if (asm_pipeline_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    /**
     * main.x：仅 entry 真 emit；其余 helper 走 SKIP 桩 + WPO 从 entry 建 reach。
     */
    if (asm_module_is_main_driver_selfhost(m)) {
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"entry", 5))
        return 0;
      return 1;
    }
    /**
     * driver/compile.x：parse_argv 分 helper + dispatch X 真 emit；run_compiler_full_x* 薄 bl→runtime impl_c。
     */
    if (asm_module_is_driver_compile_selfhost(m)) {
      if (asm_driver_compile_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    /**
     * M8-tail：backend 薄包装 EMIT_HEAVY 仍 skip 桩 + bl→C（与 SKIP 首遍一致；勿真 emit 单行 X）。
     */
    if (asm_module_is_backend_selfhost(m) && asm_skip_heavy_backend_m8_tail_thin_keep(m, func_index) != 0)
      return 1;
    /**
     * 白名单须先于 mega/索引桩：layout/arch helper 按名保留真 emit（小槽位体）。
     * 合并 glue 后 num_funcs>150（~285 func）时勿 #0–86 真 emit，否则宿主编 backend.x SIGSEGV。
     */
    if (asm_module_is_backend_selfhost(m) && m->num_funcs <= 150 &&
        (asm_skip_heavy_backend_helper_keep(m, func_index) != 0 ||
         asm_skip_heavy_backend_m8_helper_keep(m, func_index) != 0)) {
      body_ref = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref <= 0 ||
          asm_count_block_stack_slots(arena, body_ref) <= ASM_EMIT_HEAVY_BACKEND_HELPER_SLOT_MAX)
        return 0;
    }
    if (asm_module_is_typeck_selfhost(m) && asm_skip_heavy_typeck_helper_keep(m, func_index) != 0) {
      /** layout/metrics 小 helper 先于 Abort 索引带真 emit（合并 glue 后 #90 即为 type_kind_ordinal）。 */
      if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_", 14))
        return 1;
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_align", 20) ||
          pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_size", 19))
        return 1;
      if (func_index >= ASM_EMIT_HEAVY_TYPECK_INDEX_LO && func_index <= ASM_EMIT_HEAVY_TYPECK_INDEX_HI)
        return 1;
      body_ref = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref <= 0)
        return 0;
      if (asm_count_block_stack_slots(arena, body_ref) <= ASM_EMIT_HEAVY_TYPECK_LAYOUT_SLOT_MAX)
        return 0;
    }
    if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
      return 1;
    if (asm_skip_heavy_backend_mega_entry(m, func_index) != 0)
      return 1;
    /** typeck.x：ordinal #90–159 Abort 区间 ret0 桩（safe_helper 已 X 真 emit 的除外）。 */
    if (asm_module_is_typeck_selfhost(m) && typeck_ndef >= 90 && typeck_ord >= 0 &&
        typeck_ord >= ASM_EMIT_HEAVY_TYPECK_INDEX_LO && typeck_ord <= ASM_EMIT_HEAVY_TYPECK_INDEX_HI) {
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    /** backend.x ~100 func：勿要求 num_funcs>=175，否则 #87+ 全走真 emit → 宿主栈 Abort。 */
    if (asm_module_is_backend_selfhost(m) && m->num_funcs >= 80) {
      int32_t be_hi = asm_emit_heavy_abort_hi();
      if (be_hi >= m->num_funcs)
        be_hi = m->num_funcs - 1;
      if (func_index >= asm_emit_heavy_abort_lo() && func_index <= be_hi)
        return 1;
    } else if (driver_typeck_skip_large_entry() != 0 && m->num_funcs >= 175) {
      if (func_index >= asm_emit_heavy_abort_lo() && func_index <= asm_emit_heavy_abort_hi())
        return 1;
    } else if (m->num_funcs >= 160 && func_index >= 72 && !asm_module_is_backend_selfhost(m) &&
               !asm_module_is_typeck_selfhost(m) && !asm_module_is_parser_emit_heavy(m)) {
      return 1;
    }
    body_ref = pipeline_module_func_body_ref_at(m, func_index);
    slot_threshold = ASM_EMIT_HEAVY_SLOT_THRESHOLD;
    /** backend #0–86 小 helper：放宽槽位；#87+ 索引/mega 桩后再收紧槽位阈值。 */
    if (asm_module_is_backend_selfhost(m) && func_index < ASM_EMIT_HEAVY_BACKEND_INDEX_LO) {
      slot_threshold = ASM_EMIT_HEAVY_SLOT_THRESHOLD;
    } else if ((asm_module_is_backend_selfhost(m) && m->num_funcs >= 80) ||
               (driver_typeck_skip_large_entry() != 0 && m->num_funcs >= 175))
      slot_threshold = ASM_EMIT_HEAVY_LARGE_BACKEND_SLOT_THRESHOLD;
    if (arena && body_ref > 0) {
      slots = asm_count_block_stack_slots(arena, body_ref);
      if (slots > slot_threshold)
        return 1;
    }
    /** backend/typeck 第二遍：backend 默认 ret0 桩；typeck 槽位过关则真 emit。 */
    if (asm_module_is_backend_selfhost(m))
      return 1;
    if (asm_module_is_typeck_selfhost(m)) {
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 0;
    }
    return 0;
  }
  /** 默认大模块：func_index>=72 粗筛（非 EMIT_HEAVY 第二遍；仅 compiler 自举）。 */
  if (m->num_funcs >= 160 && func_index >= 72)
    return 1;
  body_ref = pipeline_module_func_body_ref_at(m, func_index);
  if (arena && body_ref > 0) {
    slots = asm_count_block_stack_slots(arena, body_ref);
    if (slots > ASM_HEAVY_BODY_SLOT_THRESHOLD)
      return 1;
  }
  return 0;
}
