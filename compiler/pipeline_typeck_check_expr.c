/**
 * pipeline_typeck_check_expr.c — typeck check_expr Cap residual thin
 * (BC 8.3.1 wave228 pure leave + wave1188 domain extract).
 *
 * wave228 G.7 pure leave: dual bodies for panic/unary/addr_of/index/deref/var
 * retired from host-cc residual where typeck.x already owns live authority.
 * Cap residual keeps:
 *   1. Thin product faces → typeck_x.o for panic/unary/addr_of/index/deref/var
 *   2. Live residual bodies: match_c (g_typeck_match_subject_* BSS + enum/guard),
 *      return_c (ret coerce cluster), try_propagate_c, call_c
 *   3. Dispatch: impl_mega_c (region escape gates for assign/return),
 *      impl_c (simple kinds + mega), check_expr_c entry
 *   4. XLANG_WEAK check_expr_impl{,_mega} cold faces
 *
 * Dual-export ban: do NOT re-open second panic/unary/addr_of/index/deref/var
 * bodies here; typeck.x is single authority. match/return/call/try remain
 * residual until their typeck twins absorb BSS/coerce parity.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after
 * call helpers + method_call.c, before check_block.c.
 *
 * PLATFORM: SHARED — freestanding typeck faces via typeck_x.o link.
 */

/* Live typeck.x twins for wave228 thin faces. */
extern int32_t typeck_check_expr_panic(struct ast_Module *module, struct ast_ASTArena *arena,
                                       int32_t expr_ref, int32_t return_type_ref,
                                       struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_unary(struct ast_Module *module, struct ast_ASTArena *arena,
                                       int32_t expr_ref, int32_t return_type_ref,
                                       struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_addr_of(struct ast_Module *module, struct ast_ASTArena *arena,
                                         int32_t expr_ref, int32_t return_type_ref,
                                         struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_index(struct ast_Module *module, struct ast_ASTArena *arena,
                                       int32_t expr_ref, int32_t return_type_ref,
                                       struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_deref(struct ast_Module *module, struct ast_ASTArena *arena,
                                       int32_t expr_ref, int32_t return_type_ref,
                                       struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_var(struct ast_Module *module, struct ast_ASTArena *arena,
                                     int32_t expr_ref, struct ast_PipelineDepCtx *ctx);

/**
 * typeck.x::check_expr_impl_mega 的 C 委托：按 ExprKind 分派至 typeck_check_expr_* 子 helper；
 * strict+pipeline 链不链整颗 typeck.o 时子 helper 来自 typeck_x_no_layout。
 *
 * Why: full ExprKind dispatch table — assign/return arms run escape diagnostics
 *      before type matching (MEM-C1/WPO negative gate precedence); remaining
 *      kinds delegate to typeck_check_expr_* sub-helpers (extern or glue C).
 * Invariant: arena non-null; expr_ref in [1, arena->num_exprs]; kind resolved
 *            before dispatch; no re-entry from sub-helpers into mega_c.
 * Asm/Perf: N/A (typeck pass; no codegen).
 * Contract: returns 0 on success; -1 on typeck fail; 0 for unhandled kinds
 *           (fall-through). module/arena/ctx non-null; expr_ref > 0.
 * PLATFORM: SHARED — product path (seed typeck_check_expr_impl_mega → this glue).
 */
int32_t pipeline_typeck_check_expr_impl_mega_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t expr_ref, int32_t return_type_ref,
                                                    struct ast_PipelineDepCtx *ctx) {
  int32_t kind;

  if (!arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return 0;
  kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (pipeline_typeck_expr_is_any_assign_kind_c(kind)) {
    int32_t left_ref;
    int32_t right_ref;
    int32_t rc;
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    /** MEM-C1/WPO：逃逸诊断优先于 assign 类型匹配，负例 gate 须在 mismatch 前报 allocator/scope 逃逸。 */
    if (pipeline_typeck_check_struct_stack_escape_assign_c(module, arena, expr_ref, left_ref, right_ref, ctx) != 0)
      return -1;
    if (pipeline_typeck_check_scope_borrow_assign_c(module, arena, expr_ref, left_ref, right_ref, ctx) != 0)
      return -1;
    if (pipeline_typeck_check_allocator_region_assign_c(module, arena, expr_ref, left_ref, ctx) != 0)
      return -1;
    rc = pipeline_typeck_check_expr_assign_c(module, arena, expr_ref, return_type_ref, ctx);
    if (rc != 0)
      return rc;
    return 0;
  }
  if (kind == (int32_t)ast_ExprKind_EXPR_RETURN) {
    int32_t op_ref;
    int32_t rc;
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    /** MEM-C1/M-3：return 逃逸诊断优先于 return 类型匹配。 */
    if (pipeline_typeck_check_scope_borrow_return_c(module, arena, expr_ref, op_ref, return_type_ref, ctx) != 0)
      return -1;
    if (pipeline_typeck_check_allocator_region_return_c(arena, expr_ref, return_type_ref) != 0)
      return -1;
    if (pipeline_typeck_check_return_slice_region_in_scope_c(arena, expr_ref, return_type_ref, ctx) != 0)
      return -1;
    if (pipeline_typeck_check_return_slice_region_c(arena, expr_ref, op_ref, return_type_ref) != 0)
      return -1;
    rc = pipeline_typeck_check_expr_return_c(module, arena, expr_ref, return_type_ref, ctx);
    if (rc != 0)
      return rc;
    return 0;
  }
  if (kind == (int32_t)ast_ExprKind_EXPR_PANIC)
    return typeck_check_expr_panic(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_MATCH)
    return pipeline_typeck_check_expr_match_c(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS)
    return typeck_check_expr_field_access(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_INDEX)
    return typeck_check_expr_index(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_CALL) {
    int32_t rc = pipeline_typeck_check_expr_call_c(module, arena, expr_ref, return_type_ref, ctx);
    if (rc != 0)
      return rc;
    return pipeline_typeck_check_call_struct_stack_escape_c(module, arena, expr_ref, ctx);
  }
  if (kind == (int32_t)ast_ExprKind_EXPR_METHOD_CALL)
    return pipeline_typeck_check_expr_method_call_c(module, arena, expr_ref, return_type_ref, ctx);
  if (kind >= (int32_t)ast_ExprKind_EXPR_ADD && kind <= (int32_t)ast_ExprKind_EXPR_LOGOR)
    return typeck_check_expr_binop(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_NEG || kind == (int32_t)ast_ExprKind_EXPR_BITNOT ||
      kind == (int32_t)ast_ExprKind_EXPR_LOGNOT)
    return typeck_check_expr_unary(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_ADDR_OF)
    return typeck_check_expr_addr_of(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_DEREF)
    return typeck_check_expr_deref(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_VAR)
    return typeck_check_expr_var(module, arena, expr_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_AS)
    return typeck_check_expr_as(module, arena, expr_ref, ctx);
  if (kind == GLUE_EXPR_KIND_TRY_PROPAGATE || kind == GLUE_EXPR_KIND_C_TRY_PROPAGATE)
    return typeck_check_expr_try_propagate(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_STRUCT_LIT)
    return typeck_check_expr_struct_lit(module, arena, expr_ref, return_type_ref, ctx);
  return 0;
}

extern int32_t typeck_check_expr_impl_mega(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                         int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);

/** glue-only 链无 typeck.o 时回退 mega_c；自举 typeck_x.o 提供 typeck_check_expr_impl_mega 覆盖。 */
XLANG_WEAK int32_t check_expr_impl_mega(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t expr_ref, int32_t return_type_ref,
                                                   struct ast_PipelineDepCtx *ctx) {
  return typeck_check_expr_impl_mega(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * typeck.x::check_expr_impl 的 C 委托：简单 kind→typeck_check_expr_*；mega→check_expr_impl_mega。
 * EMIT_HEAVY 第二遍 check_expr_impl 仍 bl 本符号（勿 X 真 emit if+递归 check_expr）。
 *
 * Why: simple kinds (LIT/BOOL/FLOAT/STRING/BREAK/CONTINUE/ENUM_VARIANT/IF/
 *      TERNARY/BLOCK/MATCH) handled in C; remaining kinds fall through to
 *      check_expr_impl_mega (full dispatch). STRING_LIT only adopts expected
 *      PTR/ARRAY/SLICE type; otherwise defaults to *u8.
 * Invariant: arena non-null; expr_ref in [1, arena->num_exprs]; kind resolved
 *            before dispatch; mega fallback for unhandled kinds.
 * Asm/Perf: N/A (typeck pass; no codegen).
 * Contract: returns 0 on success; -1 on fail; delegates to mega for complex kinds.
 * PLATFORM: SHARED — product path (seed typeck_check_expr_impl → this glue).
 */
int32_t pipeline_typeck_check_expr_impl_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                          int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  int32_t kind;

  if (!arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return 0;
  kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (kind == (int32_t)ast_ExprKind_EXPR_FLOAT_LIT)
    return typeck_check_expr_float_lit(arena, expr_ref);
  if (kind == (int32_t)ast_ExprKind_EXPR_LIT)
    return typeck_check_expr_int_lit(arena, expr_ref, return_type_ref);
  if (kind == (int32_t)ast_ExprKind_EXPR_BOOL_LIT)
    return typeck_check_expr_bool_lit(arena, expr_ref);
  /** STRING_LIT(kind 59)：仅当期望为 PTR/ARRAY/SLICE 时沿用（*u8 / u8[]）；勿吞 void 等函数返回类型。 */
  if (kind == GLUE_EXPR_STRING_LIT_ORD) {
    int32_t u8r;
    int32_t slice_u8;
    int32_t exp_kind;
    extern int32_t typeck_ensure_u8_type_ref(struct ast_ASTArena *arena);
    extern int32_t typeck_find_or_alloc_slice_type_ref(struct ast_ASTArena *w, int32_t elem_ref);
    if (!ast_ref_is_null(return_type_ref) && return_type_ref > 0 && return_type_ref <= arena->num_types) {
      exp_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
      if (exp_kind == (int32_t)ast_TypeKind_TYPE_PTR || exp_kind == (int32_t)ast_TypeKind_TYPE_ARRAY
          || exp_kind == (int32_t)ast_TypeKind_TYPE_SLICE) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref);
        return 0;
      }
    }
    u8r = typeck_ensure_u8_type_ref(arena);
    if (ast_ref_is_null(u8r))
      return -1;
    /* Default *u8 — see typeck_check_expr_string_lit comment in typeck_gen.c */
    {
      extern int32_t typeck_find_or_alloc_ptr_type_ref(struct ast_ASTArena *w, int32_t elem_ref);
      slice_u8 = typeck_find_or_alloc_ptr_type_ref(arena, u8r);
    }
    if (!ast_ref_is_null(slice_u8))
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, slice_u8);
    return 0;
  }
  if (kind == (int32_t)ast_ExprKind_EXPR_BREAK || kind == (int32_t)ast_ExprKind_EXPR_CONTINUE)
    return typeck_check_expr_break_continue(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_ENUM_VARIANT)
    return typeck_check_expr_enum_variant(arena, expr_ref);
  if (kind == (int32_t)ast_ExprKind_EXPR_IF || kind == (int32_t)ast_ExprKind_EXPR_TERNARY)
    return typeck_check_expr_if_ternary(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_BLOCK)
    return typeck_check_expr_block(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_MATCH)
    return pipeline_typeck_check_expr_match_c(module, arena, expr_ref, return_type_ref, ctx);
  return check_expr_impl_mega(module, arena, expr_ref, return_type_ref, ctx);
}

/** glue-only 链无 typeck.o 时回退 impl_c；自举 typeck.o 在 EMIT_HEAVY 下 bl→impl_c 覆盖。 */
XLANG_WEAK int32_t check_expr_impl(struct ast_Module *module, struct ast_ASTArena *arena,
                                              int32_t expr_ref, int32_t return_type_ref,
                                              struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_check_expr_impl_c(module, arena, expr_ref, return_type_ref, ctx);
}

/** typeck.x::check_expr 的 C 委托：边界检查后委托 pipeline_typeck_check_expr_impl_c（简单 kind C 处理 + mega 回退）。
 *
 * Why: top-level expr typeck entry — null/bounds guard, then try_propagate
 *      fast-path (ERR-01 Result `?`), then impl_c (simple + mega fallback).
 *      XLANG_DEBUG_PIPE logs fail context for diagnosis.
 * Invariant: arena non-null; expr_ref in [1, arena->num_exprs] or null (returns 0).
 * Asm/Perf: N/A (typeck pass; no codegen).
 * Contract: returns 0 on success (including null expr); -1 on typeck fail.
 * PLATFORM: SHARED — product path (seed typeck_check_expr → this glue).
 */
int32_t pipeline_typeck_check_expr_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                     int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  int32_t rc;
  int32_t kind;

  if (ast_ref_is_null(expr_ref))
    return 0;
  if (expr_ref <= 0 || !arena || expr_ref > arena->num_exprs)
    return 0;
  kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (kind == GLUE_EXPR_KIND_TRY_PROPAGATE || kind == GLUE_EXPR_KIND_C_TRY_PROPAGATE)
    return pipeline_typeck_check_expr_try_propagate_c(module, arena, expr_ref, return_type_ref, ctx);
  rc = pipeline_typeck_check_expr_impl_c(module, arena, expr_ref, return_type_ref, ctx);
  if (rc != 0 && link_abi_getenv("XLANG_DEBUG_PIPE"))
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] check_expr fail func=%d expr=%d kind=%d block=%d\n",
            ctx ? (int)ctx->current_func_index : -1, (int)expr_ref, (int)kind,
            ctx ? (int)ctx->current_block_ref : -1);
  return rc;
}

/* ===========================================================================
 * wave1189 G.7: typeck check_expr sub-class cluster (8 fns + 3 match helpers
 * + 2 match statics) migrated from pipeline_glue.c. Colocated with wave1188
 * entry/dispatch domain. All extern (non-static): cross-TU calls (typeck_x.o /
 * typeck.o / seeds). Statics g_typeck_match_subject_{ty,mod} moved with match
 * helpers (sole users). g_typeck_unsafe_depth remains in pipeline_glue.c
 * (shared with pipeline_typeck_check_block.c via same-TU #include).
 *
 * Forward decls visible at #include point (glue.c L6782) via earlier decls:
 * - pipeline_typeck_check_expr_c (fwd decl at glue.c L4737)
 * - pipeline_typeck_coerce_init_* (fwd decls at glue.c L4911-L4925)
 * - pipeline_typeck_bootstrap_expr_fixup_c (static fwd decl at glue.c L4928)
 * - pipeline_typeck_diag_fmt_type_or_question_c (fwd decl at glue.c L4934)
 * - pipeline_typeck_type_refs_equal_c / expr_type_ref_c (fwd decls L4594/L4599)
 * - pipeline_typeck_return_operand_matches_c (fwd decl at glue.c L4717)
 * - pipeline_typeck_ret_coerce_integral_* (fwd decls at glue.c L4718-L4720)
 * - pipeline_typeck_float_widen_ok_c (static fwd decl at glue.c L4661)
 * - pipeline_typeck_integer_widen_ok_refs_c (static fwd decl at glue.c L4688)
 * - find_or_alloc_ptr_type_ref (extern at glue.c L5076)
 * - pipeline_typeck_ptr_for_addr_of_operand_c (fwd decl at glue.c L5107)
 * - pipeline_dep_ctx_typeck_unsafe_depth_at (fwd decl at glue.c L5141)
 * - typeck_reject_bare_import_const (typeck_x.o authority; 8.3.3 host-cc leave)
 * - driver_diagnostic_* / driver_typeck_diag_scratch_* (extern L4722-L4734)
 * - typeck_top_level_let_name_equal / typeck_name_equal (extern L5360-L5362)
 * - typeck_find_or_alloc_named_type_ref (extern at glue.c L5363)
 * - pipeline_module_top_level_let_type_ref (extern at glue.c L5364)
 * PLATFORM: SHARED.
 * ========================================================================== */

/* --- match subject helpers (wave703: field-bind VAR resolve) --- */

/* wave703: match arm field binds from subject type (struct pattern as wildcard). */
static int32_t g_typeck_match_subject_ty = 0;
static struct ast_Module *g_typeck_match_subject_mod = 0;

/** wave703: set match subject type for field-bind VAR resolve (strict_minimal twin). */
int32_t pipeline_typeck_match_set_subject_c(struct ast_Module *module, int32_t ty) {
  g_typeck_match_subject_mod = module;
  g_typeck_match_subject_ty = ty;
  return 0;
}

/** wave703: clear match subject field-bind context. */
void pipeline_typeck_match_clear_subject_c(void) {
  g_typeck_match_subject_mod = 0;
  g_typeck_match_subject_ty = 0;
}

int32_t pipeline_typeck_match_subject_field_type_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   uint8_t *name, int32_t name_len) {
  int32_t ty;
  int32_t k;
  int32_t nsl;
  int32_t fi;
  int32_t nf;
  int32_t fl;
  int32_t j;
  uint8_t tnm[128];
  uint8_t fnm[128];
  int32_t tnl;
  if (!module || !arena || !name || name_len <= 0)
    return 0;
  ty = g_typeck_match_subject_ty;
  if (ty <= 0 || g_typeck_match_subject_mod != module)
    return 0;
  if (pipeline_type_kind_ord_at(arena, ty) != (int32_t)ast_TypeKind_TYPE_NAMED)
    return 0;
  tnl = pipeline_type_named_name_into(arena, ty, tnm);
  if (tnl <= 0)
    return 0;
  nsl = module->num_struct_layouts;
  for (k = 0; k < nsl; k++) {
    fl = pipeline_module_struct_layout_name_len(module, k);
    if (fl != tnl)
      continue;
    {
      int32_t match = 1;
      int32_t bi;
      for (bi = 0; bi < fl && match; bi++) {
        if (pipeline_module_struct_layout_name_byte_at(module, k, bi) != tnm[bi])
          match = 0;
      }
      if (!match)
        continue;
    }
    nf = pipeline_module_struct_layout_num_fields(module, k);
    for (fi = 0; fi < nf; fi++) {
      int32_t fnl = pipeline_module_struct_layout_field_name_len(module, k, fi);
      if (fnl != name_len)
        continue;
      memset(fnm, 0, sizeof(fnm));
      pipeline_module_struct_layout_field_name_into(module, k, fi, fnm);
      {
        int32_t match = 1;
        for (j = 0; j < fnl && match; j++) {
          if (fnm[j] != name[j])
            match = 0;
        }
        if (match)
          return pipeline_module_struct_layout_field_type_ref(module, k, fi);
      }
    }
  }
  return 0;
}

/* --- check_expr_panic (wave228 thin → typeck.x) --- */

/**
 * Product-mega C face for EXPR_PANIC.
 * Thin → typeck_check_expr_panic.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_panic_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                           int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return typeck_check_expr_panic(module, arena, expr_ref, return_type_ref, ctx);
}

/* --- check_expr_match --- */

/**
 * typeck.x::typeck_check_expr_match 的 C 委托：检查 matched 与各 arm result；迭代遍历 arm 避免 X 递归 SIGSEGV。
 */
int32_t pipeline_typeck_check_expr_match_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                           int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  int32_t matched_ref;
  int32_t num_arms;
  int32_t arm_i;
  int32_t is_enum;
  int32_t var_ix;
  int32_t arm_res;
  int32_t line;
  int32_t col;
  int32_t matched_ty;
  int32_t saved_subj_ty;
  struct ast_Module *saved_subj_mod;
  int32_t guard_ref;

  (void)module;
  if (!arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return 0;
  matched_ref = pipeline_expr_match_matched_ref_at(arena, expr_ref);
  num_arms = pipeline_expr_match_num_arms_at(arena, expr_ref);
  line = pipeline_expr_line_at(arena, expr_ref);
  col = pipeline_expr_col_at(arena, expr_ref);
  if (pipeline_typeck_check_expr_c(module, arena, matched_ref, return_type_ref, ctx) != 0)
    return -1;
  matched_ty = pipeline_expr_resolved_type_ref(arena, matched_ref);
  saved_subj_ty = g_typeck_match_subject_ty;
  saved_subj_mod = g_typeck_match_subject_mod;
  g_typeck_match_subject_ty = matched_ty;
  g_typeck_match_subject_mod = module;
  arm_i = 0;
  while (arm_i < num_arms) {
    is_enum = pipeline_expr_match_arm_is_enum_variant(arena, expr_ref, arm_i);
    if (is_enum != 0) {
      var_ix = pipeline_expr_match_arm_variant_index(arena, expr_ref, arm_i);
      if (var_ix < 0) {
        g_typeck_match_subject_ty = saved_subj_ty;
        g_typeck_match_subject_mod = saved_subj_mod;
        driver_diagnostic_typeck_enum_no_variant(line, col);
        return -1;
      }
    }
    /* wave700: typecheck optional guard under subject field binds. */
    guard_ref = pipeline_expr_match_arm_guard_ref(arena, expr_ref, arm_i);
    if (guard_ref > 0 && pipeline_typeck_check_expr_c(module, arena, guard_ref, 0, ctx) != 0) {
      g_typeck_match_subject_ty = saved_subj_ty;
      g_typeck_match_subject_mod = saved_subj_mod;
      return -1;
    }
    arm_res = pipeline_expr_match_arm_result_ref(arena, expr_ref, arm_i);
    if (pipeline_typeck_check_expr_c(module, arena, arm_res, return_type_ref, ctx) != 0) {
      g_typeck_match_subject_ty = saved_subj_ty;
      g_typeck_match_subject_mod = saved_subj_mod;
      return -1;
    }
    arm_i = arm_i + 1;
  }
  g_typeck_match_subject_ty = saved_subj_ty;
  g_typeck_match_subject_mod = saved_subj_mod;
  if (!ast_ref_is_null(return_type_ref))
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref);
  return 0;
}

/* --- check_expr_return --- */

/**
 * typeck.x::typeck_check_expr_return 的 C 委托：裸 return / return expr 与函数签名匹配。
 */
int32_t pipeline_typeck_check_expr_return_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                             int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  int32_t op_ref;
  int32_t line;
  int32_t col;
  int32_t rt_kind;
  int32_t op_kind;
  int32_t int_val;
  int32_t as_tgt;
  int32_t got;
  uint8_t *eb_ret;
  uint8_t *gb_ret;
  int32_t el_ret;
  int32_t gl_ret;

  (void)module;
  if (!arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return 0;
  op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  line = pipeline_expr_line_at(arena, expr_ref);
  col = pipeline_expr_col_at(arena, expr_ref);
  if (ast_ref_is_null(op_ref)) {
    if (!ast_ref_is_null(return_type_ref)) {
      rt_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
      if (rt_kind != (int32_t)ast_TypeKind_TYPE_VOID) {
        driver_diagnostic_typeck_ret_fail(1, expr_ref, return_type_ref, 0);
        return -1;
      }
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref);
    }
    return 0;
  }
  if (!ast_ref_is_null(return_type_ref)) {
    rt_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
    if (rt_kind == (int32_t)ast_TypeKind_TYPE_VOID) {
      got = pipeline_typeck_expr_type_ref_c(arena, op_ref);
      driver_diagnostic_typeck_ret_fail(2, op_ref, return_type_ref, got);
      return -1;
    }
  }
  /* 【Why 根源】return 0 在 *T 语境须先收窄为 null 指针，再 check_expr；
   * 否则 int lit 默认 i32，check_expr 阶段即报 expected *u8 found i32
   * （contextual_typing_p1 / typeck_ret_coerce_null_lit 应对齐 let 初值路径）。 */
  if (!ast_ref_is_null(op_ref) && !ast_ref_is_null(return_type_ref)) {
    op_kind = pipeline_expr_kind_ord_at(arena, op_ref);
    if (op_kind == (int32_t)ast_ExprKind_EXPR_LIT) {
      rt_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
      int_val = pipeline_expr_int_val_at(arena, op_ref);
      if (int_val == 0 && rt_kind == (int32_t)ast_TypeKind_TYPE_PTR)
        pipeline_expr_set_resolved_type_ref(arena, op_ref, return_type_ref);
    }
  }
  if (pipeline_typeck_check_expr_c(module, arena, op_ref, return_type_ref, ctx) != 0) {
    driver_diagnostic_typeck_ret_fail(1, op_ref, return_type_ref, 0);
    return -1;
  }
  pipeline_typeck_bootstrap_expr_fixup_c(module, arena, op_ref);
  if (!ast_ref_is_null(op_ref) && !ast_ref_is_null(return_type_ref)) {
    op_kind = pipeline_expr_kind_ord_at(arena, op_ref);
    rt_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
    /*
     * wave318: return bare int lit → f32/f64 (G.7 reuse lit coerce; let/assign parity).
     * wave319: return EXPR_NEG / int binop → f32/f64 (G.7 reuse int_binop; let/assign parity).
     * PLATFORM: SHARED — twin with typeck.x typeck_check_expr_return.
     */
    (void)pipeline_typeck_coerce_init_lit_to_decl_c(arena, op_ref, return_type_ref, rt_kind, op_kind);
    /* wave316: return float lit / `-float` → f32/f64 (G.7 reuse float_lit coerce). */
    (void)pipeline_typeck_coerce_init_float_lit_to_decl_c(arena, op_ref, return_type_ref, rt_kind, op_kind);
    (void)pipeline_typeck_coerce_init_int_binop_to_decl_c(arena, op_ref, return_type_ref, rt_kind, op_kind);
    if (op_kind == (int32_t)ast_ExprKind_EXPR_LIT) {
      if (rt_kind == (int32_t)ast_TypeKind_TYPE_I64) {
        pipeline_expr_set_resolved_type_ref(arena, op_ref, return_type_ref);
      } else {
        int_val = pipeline_expr_int_val_at(arena, op_ref);
        if (int_val == 0 && rt_kind == (int32_t)ast_TypeKind_TYPE_PTR)
          pipeline_expr_set_resolved_type_ref(arena, op_ref, return_type_ref);
        else if (int_val >= 0) {
          if (rt_kind == (int32_t)ast_TypeKind_TYPE_USIZE || rt_kind == (int32_t)ast_TypeKind_TYPE_U32 ||
              rt_kind == (int32_t)ast_TypeKind_TYPE_U64)
            pipeline_expr_set_resolved_type_ref(arena, op_ref, return_type_ref);
        }
      }
    }
  }
  if (!ast_ref_is_null(op_ref) && !ast_ref_is_null(return_type_ref)) {
    /*
     * wave333 Cap residual pure: return ARRAY_LIT → TYPE_SLICE / TYPE_ARRAY / VECTOR.
     * Root: return path only stamped TYPE_ARRAY / TYPE_VECTOR, so
     * `function f(): i32[] { return [1,2,3] }` reported expected []i32 found ?.
     * G.7: reuse pipeline_typeck_coerce_init_array_vector_lit_to_decl_c (let-init
     * wave328 / assign wave331 / call-arg wave332). PLATFORM: SHARED.
     */
    op_kind = pipeline_expr_kind_ord_at(arena, op_ref);
    rt_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
    (void)pipeline_typeck_coerce_init_array_vector_lit_to_decl_c(arena, op_ref, return_type_ref,
                                                                rt_kind, op_kind);
    /** return 语境：匿名 `{ a: 1, b: 2 }` 按函数返回 struct 类型回填名与 resolved_type。 */
    if (op_kind == (int32_t)ast_ExprKind_EXPR_STRUCT_LIT &&
        rt_kind == (int32_t)ast_TypeKind_TYPE_NAMED) {
      (void)pipeline_typeck_coerce_init_struct_lit_to_decl_c(module, arena, op_ref, return_type_ref);
    }
  }
  if (!ast_ref_is_null(op_ref) && !ast_ref_is_null(return_type_ref)) {
    op_kind = pipeline_expr_kind_ord_at(arena, op_ref);
    if (op_kind == (int32_t)ast_ExprKind_EXPR_AS) {
      as_tgt = pipeline_expr_as_target_type_ref_at(arena, op_ref);
      if (!ast_ref_is_null(as_tgt) && pipeline_typeck_type_refs_equal_c(arena, as_tgt, return_type_ref))
        pipeline_expr_set_resolved_type_ref(arena, op_ref, as_tgt);
    }
  }
  if (!ast_ref_is_null(return_type_ref) && !ast_ref_is_null(op_ref)) {
    int32_t ek_ret;
    int32_t gk_ret;
    pipeline_typeck_ret_coerce_integral_to_expect_i32_c(arena, op_ref, return_type_ref);
    pipeline_typeck_ret_coerce_integral_widen_c(arena, op_ref, return_type_ref);
    got = pipeline_typeck_expr_type_ref_c(arena, op_ref);
    if (!pipeline_typeck_return_operand_matches_c(arena, op_ref, return_type_ref)) {
      /** 整型隐式拓宽：match 失败但 i32→i64 等仍合法时写回 resolved 并通过（ret_ternary_i32）。 */
      if (got > 0 && return_type_ref > 0) {
        ek_ret = pipeline_type_kind_ord_at(arena, return_type_ref);
        gk_ret = pipeline_type_kind_ord_at(arena, got);
        if (pipeline_typeck_integer_widen_ok_refs_c(arena, return_type_ref, got) ||
            pipeline_typeck_float_widen_ok_c(ek_ret, gk_ret)) {
          pipeline_expr_set_resolved_type_ref(arena, op_ref, return_type_ref);
          return 0;
        }
      }
      eb_ret = driver_typeck_diag_scratch_expect();
      gb_ret = driver_typeck_diag_scratch_found();
      el_ret = pipeline_typeck_diag_fmt_type_or_question_c(arena, return_type_ref, eb_ret);
      gl_ret = pipeline_typeck_diag_fmt_type_or_question_c(arena, got, gb_ret);
      driver_diagnostic_typeck_return_mismatch(line, col, eb_ret, el_ret, gb_ret, gl_ret);
      driver_diagnostic_typeck_ret_fail(2, op_ref, return_type_ref, got);
      return -1;
    }
  }
  return 0;
}

/* --- check_expr_unary / addr_of / deref / index (wave228 thin → typeck.x) --- */

/**
 * Product-mega C face for NEG/BITNOT/LOGNOT.
 * Thin → typeck_check_expr_unary.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_unary_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                           int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return typeck_check_expr_unary(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * Product-mega C face for EXPR_ADDR_OF.
 * Thin → typeck_check_expr_addr_of (includes stack_local ptr label).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_addr_of_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                             int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return typeck_check_expr_addr_of(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * Product-mega C face for EXPR_DEREF (LANG-007 unsafe gate).
 * Thin → typeck_check_expr_deref.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_deref_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                           int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return typeck_check_expr_deref(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * Product-mega C face for EXPR_INDEX.
 * Thin → typeck_check_expr_index.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_index_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                           int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return typeck_check_expr_index(module, arena, expr_ref, return_type_ref, ctx);
}

/* --- check_expr_var (wave228 thin → typeck.x) --- */

/**
 * Product-mega C face for EXPR_VAR (symtab / param / import / match subject hop).
 * Thin → typeck_check_expr_var.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_var_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       struct ast_PipelineDepCtx *ctx) {
  return typeck_check_expr_var(module, arena, expr_ref, ctx);
}

/* ===========================================================================
 * wave1190 G.7: typeck check_expr try_propagate + call entry cluster (2 fns
 * + 1 wrapper) migrated from pipeline_glue.c. Colocated with wave1188
 * entry/dispatch domain + wave1189 sub-class cluster.
 *
 * try_propagate_c was in glue.c before method_call.c #include (needed static
 * fwd decl of debug_try_propagate_report_glue_c). Now after method_call.c
 * #include (check_expr.c #include at glue.c L6246 > method_call.c #include at
 * L6038) — debug_try_propagate_report_glue_c definition in method_call.c EOF
 * (wave1147) is visible; static fwd decl removed from glue.c.
 *
 * call_c was in glue.c after method_call.c #include (needed static helpers
 * glue_generic_call_fixup_resolved_type_c / pipeline_typeck_check_call_generic
 * type_args_c in method_call.c EOF). Now in check_expr.c EOF — both static
 * helpers visible (method_call.c #include before check_expr.c #include).
 * pipeline_typeck_check_extern_call_unsafe_boundary_c (extern, defined at
 * glue.c L6075) visible via fwd decl at glue.c L4760+.
 *
 * Forward decls visible at #include point (glue.c L6246) via earlier decls:
 * - pipeline_typeck_check_expr_c (defined above in this file)
 * - pipeline_typeck_expr_type_ref_c (fwd decl at glue.c L4599)
 * - pipeline_typeck_type_refs_equal_c (fwd decl at glue.c L4594)
 * - pipeline_module_num_funcs / pipeline_module_func_return_type_at (extern)
 * - pipeline_type_kind_ord_at / pipeline_type_named_name_into (extern)
 * - pipeline_type_ensure_by_kind_ord (extern)
 * - pipeline_expr_unary_operand_ref_at / pipeline_expr_line/col_at (extern)
 * - pipeline_expr_set_resolved_type_ref / pipeline_expr_resolved_type_ref (extern)
 * - pipeline_expr_call_num_args_at / pipeline_expr_call_callee_ref_at (extern)
 * - driver_diagnostic_typeck_try_propagate_bad_enclosing (extern)
 * - pipeline_typeck_check_extern_call_unsafe_boundary_c (fwd decl at glue.c L6075)
 * - pipeline_typeck_check_call_generic_type_args_c (static in method_call.c EOF)
 * - glue_generic_call_fixup_resolved_type_c (static in method_call.c EOF)
 * - pipeline_typeck_resolve_call_callee_return_type_c (extern in method_call.c EOF)
 * - pipeline_typeck_check_call_slice_region_c (extern)
 * - typeck_check_expr_call_arg / call_resolve (extern)
 * - typeck_check_call_arity / call_arg_types (extern)
 * - typeck_overload_expected_ret_slot (extern)
 * - debug_try_propagate_report_glue_c (static in method_call.c EOF, wave1147)
 * PLATFORM: SHARED.
 * ========================================================================== */

/**
 * ERR-01: Result `?` propagation — operand must be Result_*, enclosing function
 * return type must match; expression type is Ok payload (Result_i32→i32).
 *
 * Why: contextual `?` operator desugars to early-return on Err; typeck must
 *      verify operand is Result_<T> named type and enclosing function returns
 *      same Result type. Payload type extracted from name suffix (i32/u8).
 * Invariant: arena non-null; expr_ref in [1, arena->num_exprs]; operand
 *            type-checked before payload extraction.
 * Asm/Perf: N/A (typeck pass; no codegen).
 * Contract: returns 0 on success (expr resolved to payload type); -1 on
 *           typeck fail (bad enclosing / non-Result operand).
 * PLATFORM: SHARED — product path (seed typeck_check_expr_try_propagate → this glue).
 */
int32_t pipeline_typeck_check_expr_try_propagate_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t expr_ref, int32_t return_type_ref,
                                                   struct ast_PipelineDepCtx *ctx) {
  int32_t op_ref;
  int32_t op_ty;
  int32_t enclosing_return_type_ref;
  int32_t func_ix;
  int32_t func_ret;
  int32_t line;
  int32_t col;
  int32_t payload_ty;
  uint8_t rname[128];
  int32_t rlen;
  int32_t si;

  (void)module;
  (void)ctx;
  if (!arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return 0;
  op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  line = pipeline_expr_line_at(arena, expr_ref);
  col = pipeline_expr_col_at(arena, expr_ref);
  if (pipeline_typeck_check_expr_c(module, arena, op_ref, return_type_ref, ctx) != 0)
    return -1;
  op_ty = pipeline_typeck_expr_type_ref_c(arena, op_ref);
  enclosing_return_type_ref = return_type_ref;
  func_ret = 0;
  func_ix = ctx ? ctx->current_func_index : -1;
  if (module && ctx && func_ix >= 0 && func_ix < pipeline_module_num_funcs(module)) {
    func_ret = pipeline_module_func_return_type_at(module, func_ix);
    if (!ast_ref_is_null(func_ret))
      enclosing_return_type_ref = func_ret;
  }
  debug_try_propagate_report_glue_c(expr_ref, func_ix, return_type_ref, func_ret, enclosing_return_type_ref, op_ty);
  if (ast_ref_is_null(op_ty) || pipeline_type_kind_ord_at(arena, op_ty) != (int32_t)ast_TypeKind_TYPE_NAMED) {
    driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
    return -1;
  }
  rlen = pipeline_type_named_name_into(arena, op_ty, rname);
  if (rlen < 7 || rname[0] != 'R' || rname[1] != 'e' || rname[2] != 's' || rname[3] != 'u' || rname[4] != 'l' ||
      rname[5] != 't' || rname[6] != '_') {
    driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
    return -1;
  }
  if (ast_ref_is_null(enclosing_return_type_ref) ||
      !pipeline_typeck_type_refs_equal_c(arena, enclosing_return_type_ref, op_ty)) {
    driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
    return -1;
  }
  payload_ty = 0;
  if (rlen == 10 && rname[7] == 'i' && rname[8] == '3' && rname[9] == '2')
    payload_ty = pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_I32);
  else if (rlen == 9 && rname[7] == 'u' && rname[8] == '8')
    payload_ty = pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_U8);
  else {
    /** Result_<T> generic family: parse scalar from suffix T (current gate: i32/u8 only). */
    for (si = 7; si + 1 < rlen && si + 1 < 64; si++) {
      if (rname[si] == 'i' && rname[si + 1] == '3' && rname[si + 2] == '2') {
        payload_ty = pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_I32);
        break;
      }
      if (rname[si] == 'u' && rname[si + 1] == '8') {
        payload_ty = pipeline_type_ensure_by_kind_ord(arena, (int32_t)ast_TypeKind_TYPE_U8);
        break;
      }
    }
  }
  if (payload_ty != 0)
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, payload_ty);
  else if (!ast_ref_is_null(op_ty))
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, op_ty);
  return 0;
}

int32_t typeck_check_expr_try_propagate(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                        int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_check_expr_try_propagate_c(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * EXPR_CALL: delegate to typeck_x.o seed sub-steps + glue resolve, then
 * generic return-type monomorphization fixup (bootstrap parser may not store
 * call type_args). LANG-007 v2: S0 extern calls must be inside unsafe { }.
 *
 * Why: full call typeck pipeline — unsafe boundary check → arg typeck →
 *      resolve → arity check → arg type check → generic type-args gate →
 *      slice region check → return-type resolve + generic fixup.
 *      Expected return stored for zero-arg overload pick (let v: Vec_u8 = vec.new()).
 * Invariant: arena non-null; expr_ref in [1, arena->num_exprs]; expected_ret
 *            slot cleared on all exit paths (no leak across calls).
 * Asm/Perf: N/A (typeck pass; no codegen).
 * Contract: returns 0 on success; -1 on typeck fail (unsafe/arity/type/generic).
 * PLATFORM: SHARED — product path (seed typeck_check_expr_call → this glue).
 */
int32_t pipeline_typeck_check_expr_call_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                          int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  int32_t rc;
  int32_t callee_ref;
  int32_t ret_ty;
  int32_t expect_store;
  extern int32_t *typeck_overload_expected_ret_slot(void);
  if (pipeline_typeck_check_extern_call_unsafe_boundary_c(module, arena, expr_ref, ctx) != 0)
    return -1;
  /*
   * PLATFORM: SHARED — install expected return for zero-arg overload pick
   * (let v: Vec_u8 = vec.new()). Also held through generic infer + fixup
   * (wave453 bare ret-only type-param inference). Cleared on all exit paths.
   * Authority consumers: typeck_find_func_return_type_in_module_by_name_overload
   * / module_overload / try_infer / glue_generic_call_fixup.
   */
  expect_store = 0;
  if (!ast_ref_is_null(return_type_ref) && return_type_ref > 0)
    expect_store = return_type_ref;
  *typeck_overload_expected_ret_slot() = expect_store;
  /** Do not recurse via glue typeck_check_expr_call; call seed sub-steps + glue resolve directly. */
  rc = typeck_check_expr_call_arg(module, arena, expr_ref, return_type_ref, ctx, 0,
                                  pipeline_expr_call_num_args_at(arena, expr_ref));
  if (rc != 0) {
    *typeck_overload_expected_ret_slot() = 0;
    return rc;
  }
  rc = typeck_check_expr_call_resolve(module, arena, expr_ref, ctx);
  if (rc != 0) {
    *typeck_overload_expected_ret_slot() = 0;
    return rc;
  }
  /*
   * wave660 Cap residual: hard-fail free-function call arity at typeck.
   * Root: overload first_idx fallback ignored nparams vs num_args → typeck OK,
   * host-cc BLD001 (too few/many arguments). G.7: typeck_check_call_arity.
   * PLATFORM: SHARED — product path (seed typeck_check_expr_call → this glue).
   */
  {
    extern int32_t typeck_check_call_arity(struct ast_Module *module, struct ast_ASTArena *arena,
                                           int32_t expr_ref, struct ast_PipelineDepCtx *ctx);
    if (typeck_check_call_arity(module, arena, expr_ref, ctx) != 0) {
      *typeck_overload_expected_ret_slot() = 0;
      return -1;
    }
  }
  /*
   * wave661 Cap residual: hard-fail free-function call arg types at typeck.
   * Root: resolve+arity OK but arg vs param never scored → host-cc BLD001 or
   * silent C conversion false-green. G.7: typeck_check_call_arg_types (reuses
   * typeck_overload_arg_param_score; soft-skip unknown arg/param types).
   * PLATFORM: SHARED — product path (seed typeck_check_expr_call → this glue).
   */
  {
    extern int32_t typeck_check_call_arg_types(struct ast_Module *module, struct ast_ASTArena *arena,
                                              int32_t expr_ref, struct ast_PipelineDepCtx *ctx);
    if (typeck_check_call_arg_types(module, arena, expr_ref, ctx) != 0) {
      *typeck_overload_expected_ret_slot() = 0;
      return -1;
    }
  }
  /* Keep expected_ret through generic gate + fixup (wave453); clear after. */
  if (pipeline_typeck_check_call_generic_type_args_c(module, arena, expr_ref, ctx, expect_store) != 0) {
    *typeck_overload_expected_ret_slot() = 0;
    return -1;
  }
  if (pipeline_typeck_check_call_slice_region_c(module, arena, expr_ref, ctx) != 0) {
    *typeck_overload_expected_ret_slot() = 0;
    return -1;
  }
  if (ast_ref_is_null(pipeline_expr_resolved_type_ref(arena, expr_ref))) {
    callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    ret_ty = pipeline_typeck_resolve_call_callee_return_type_c(module, arena, callee_ref, expr_ref, ctx);
    if (ret_ty != 0)
      (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, ret_ty));
  }
  (void)glue_generic_call_fixup_resolved_type_c(module, arena, expr_ref, ctx, expect_store);
  *typeck_overload_expected_ret_slot() = 0;
  return 0;
}

/* wave1198 G.7: pipeline_typeck_call_arg_repr_compatible_ok_c +
 * pipeline_typeck_check_extern_call_unsafe_boundary_c (2 fns) migrated
 * from pipeline_glue.c to this file's EOF (same-TU #include at L5444,
 * after struct_lit.c L1438 + vector_simd.c L1509 + ast_pool.c L3985 +
 * method_call.c L5307 — all same-TU static deps visible).
 *
 * Why colocate: both functions are typeck call-checking sub-domain of
 * check_expr — repr(compatible) ptr coerce gate + extern call unsafe
 * boundary gate. They belong with the check_expr dispatch entry.
 *
 * Members (2 fns):
 *  - pipeline_typeck_call_arg_repr_compatible_ok_c (MOD-02: *StructA vs
 *    *StructB coercion under #[repr(compatible)] + same field shape)
 *  - pipeline_typeck_check_extern_call_unsafe_boundary_c (LANG-007 S0:
 *    extern calls must be inside unsafe { })
 *
 * Fwd decls:
 *  - pipeline_typeck_call_arg_repr_compatible_ok_c: extern fwd decl added
 *    in pipeline_typeck_method_call.c L435 (before L2734 callsite in
 *    typeck_check_call_ptr_struct_compat_c < this file's #include at L5444)
 *  - pipeline_typeck_check_extern_call_unsafe_boundary_c: fwd decl at
 *    glue.c L5068 (before L5090 callsite in check_call_slice_region_c,
 *    which stays in glue.c — dual-authority seed file)
 *
 * Static deps visible at this #include point:
 *  - typeck_type_is_named_struct_c (struct_lit.c L2051, #include at L1438)
 *  - typeck_struct_layouts_same_shape_c (struct_lit.c, #include at L1438)
 *  - typeck_layout_index_for_named_type_c (struct_lit.c L1505, #include at L1438)
 *  - glue_module_func_index_by_name_c (runtime_pipeline_abi pure wave148)
 *
 * PLATFORM: SHARED — pure typeck check + diagnostic; no platform ABI dep. */

/**
 * wave703 / MOD-02: 1 if *StructA vs *StructB (or &StructB) may coerce under
 * #[repr(compatible)] + same field shape. 0 if not applicable or not ok.
 * G.7 single authority for positive coerce; typeck_check_call_arg_types and
 * overload score gate through this (not a second layout walker).
 *
 * Why: SysV ABI allows pointer-to-struct coercion when both structs have
 *      identical field shapes AND both are annotated #[repr(compatible)].
 *      Without this gate, typeck would reject valid cross-struct calls.
 * Contract: param_ref<=0 or arg_ref<=0 → 0; non-PTR param → 0;
 *           non-NAMED-struct arg → 0; same type → 1; same shape + repr → 1.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_call_arg_repr_compatible_ok_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                      int32_t param_ref, int32_t arg_ref) {
  int32_t param_elem;
  int32_t arg_elem;
  int32_t arg_ty;
  int32_t arg_kind;
  int32_t la;
  int32_t lb;
  if (!module || !arena || param_ref <= 0 || arg_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, param_ref) != (int32_t)ast_TypeKind_TYPE_PTR)
    return 0;
  param_elem = pipeline_type_elem_ref_at(arena, param_ref);
  if (param_elem <= 0 || !typeck_type_is_named_struct_c(module, arena, param_elem))
    return 0;
  arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
  arg_kind = pipeline_expr_kind_ord_at(arena, arg_ref);
  if (arg_ty <= 0 && arg_kind == (int32_t)ast_ExprKind_EXPR_ADDR_OF) {
    int32_t op = pipeline_expr_unary_operand_ref_at(arena, arg_ref);
    if (op > 0)
      arg_ty = pipeline_expr_resolved_type_ref(arena, op);
  }
  if (arg_ty <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, arg_ty) == (int32_t)ast_TypeKind_TYPE_NAMED) {
    arg_elem = arg_ty;
  } else if (pipeline_type_kind_ord_at(arena, arg_ty) == (int32_t)ast_TypeKind_TYPE_PTR) {
    arg_elem = pipeline_type_elem_ref_at(arena, arg_ty);
  } else {
    return 0;
  }
  if (arg_elem <= 0 || !typeck_type_is_named_struct_c(module, arena, arg_elem))
    return 0;
  param_elem = pipeline_typeck_resolve_type_alias_ref_c(arena, param_elem);
  arg_elem = pipeline_typeck_resolve_type_alias_ref_c(arena, arg_elem);
  if (param_elem == arg_elem)
    return 1;
  la = typeck_layout_index_for_named_type_c(module, arena, param_elem);
  lb = typeck_layout_index_for_named_type_c(module, arena, arg_elem);
  if (la < 0 || lb < 0)
    return 0;
  if (la == lb)
    return 1;
  if (typeck_struct_layouts_same_shape_c(module, arena, la, lb) &&
      pipeline_module_struct_layout_repr_compatible_at(module, la) &&
      pipeline_module_struct_layout_repr_compatible_at(module, lb))
    return 1;
  return 0;
}

/**
 * LANG-007 v2: S0 — extern calls must be inside unsafe { }.
 *
 * Why: extern functions may call back into C code that violates X's
 *      memory safety invariants; typeck gates all extern calls behind
 *      unsafe { } blocks (depth>0). The allow_legacy escape hatch is
 *      used by -E seed regen / typeck_x.o legacy mode.
 * Contract: NULL module/arena or expr_ref<=0 → 0 (no-op);
 *           allow_legacy!=0 → 0 (skip); unsafe depth>0 → 0 (allowed);
 *           callee is extern function → emit diagnostic, return -1.
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_extern_call_unsafe_boundary_c(struct ast_Module *module,
                                                            struct ast_ASTArena *arena, int32_t expr_ref,
                                                            struct ast_PipelineDepCtx *ctx) {
  int32_t callee_ref;
  int32_t callee_kind;
  int32_t name_len;
  uint8_t name[128];
  int32_t fi;
  int32_t line;
  int32_t col;
  /* -E seed regen / allow_legacy: typeck_x.o provides getter; default weak 0 keeps S0 enforced. */
  extern int typeck_get_allow_legacy_extern_calls(void);

  if (typeck_get_allow_legacy_extern_calls() != 0)
    return 0;
  if (pipeline_dep_ctx_typeck_unsafe_depth_at(ctx) > 0)
    return 0;
  if (!module || !arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return 0;
  callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
  if (callee_ref <= 0 || callee_ref > arena->num_exprs)
    return 0;
  callee_kind = pipeline_expr_kind_ord_at(arena, callee_ref);
  if (callee_kind != (int32_t)ast_ExprKind_EXPR_VAR)
    return 0;
  name_len = pipeline_expr_var_name_len(arena, callee_ref);
  if (name_len <= 0 || name_len > 127)
    return 0;
  pipeline_expr_var_name_into(arena, callee_ref, name);
  fi = glue_module_func_index_by_name_c(module, name, name_len);
  if (fi < 0 || pipeline_module_func_is_extern_at(module, fi) == 0)
    return 0;
  line = pipeline_expr_line_at(arena, expr_ref);
  col = pipeline_expr_col_at(arena, expr_ref);
  driver_diagnostic_typeck_extern_call_outside_unsafe(line, col);
  return -1;
}

/* wave1282 / wave228 G.7: non-standalone cold wrappers for call/method_call
 * only (residual still owns live bodies). wave228: deref dual export removed —
 * typeck.x owns typeck_check_expr_deref; residual face thins to typeck (thinning
 * + dual export would recurse). Omitted when STANDALONE_TU or OMIT_X_DUP_EXPORTS
 * (product/strict: typeck_x.o sole typeck_* export). PLATFORM: SHARED.
 */
#if !defined(XLANG_PIPELINE_GLUE_STANDALONE_TU) && !defined(XLANG_PIPELINE_GLUE_OMIT_X_DUP_EXPORTS)
int32_t typeck_check_expr_call(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                               int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_check_expr_call_c(module, arena, expr_ref, return_type_ref, ctx);
}

int32_t typeck_check_expr_method_call(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                      int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_check_expr_method_call_c(module, arena, expr_ref, return_type_ref, ctx);
}
#endif
