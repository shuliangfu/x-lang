/**
 * pipeline_typeck_check_expr.c — typeck check_expr entry/dispatch domain
 * (BC 8.3.1 wave1188).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega expr typeck dispatch entry:
 * - pipeline_typeck_check_expr_impl_mega_c (full ExprKind → typeck_check_expr_*)
 * - XLANG_WEAK check_expr_impl_mega (glue-only fallback; typeck_x.o overrides)
 * - pipeline_typeck_check_expr_impl_c (simple kind C path + mega fallback)
 * - XLANG_WEAK check_expr_impl (glue-only fallback; typeck.o EMIT_HEAVY overrides)
 * - pipeline_typeck_check_expr_c (boundary check → try_propagate / impl_c)
 *
 * G.7: single product-mega check_expr dispatch face — do not open a second
 * kind-dispatch table or parallel entry. Sub-class helpers (panic/match/
 * return/unary/addr_of/deref/index/var) remain in pipeline_glue.c (interleaved
 * with assign/soa/field_access domain slices); call_c remains in pipeline_glue.c
 * (before method_call.c #include); try_propagate_c remains in pipeline_glue.c
 * (before method_call.c #include for debug_try_propagate_report_glue_c).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c at the
 * original impl_mega_c definition site (after call_c + #if wrapper, before
 * check_block.c #include).
 *
 * Forward decls (visible at #include point via earlier pipeline_glue.c decls):
 * - pipeline_typeck_check_expr_c (fwd decl at glue.c L4737 / L6438)
 * - pipeline_typeck_check_expr_match_c (defined at glue.c L4845)
 * - pipeline_typeck_check_expr_call_c (defined at glue.c L6669)
 * - pipeline_typeck_check_expr_return_c (defined at glue.c L4936)
 * - pipeline_typeck_check_expr_deref_c (defined at glue.c L5155)
 * - pipeline_typeck_check_expr_var_c (defined at glue.c L5369)
 * - pipeline_typeck_check_expr_assign_c (defined in pipeline_typeck_assign.c)
 * - pipeline_typeck_check_expr_method_call_c (defined in pipeline_typeck_method_call.c)
 * - pipeline_typeck_check_expr_try_propagate_c (defined at glue.c L6468)
 * - pipeline_typeck_check_struct_stack_escape_assign_c (extern)
 * - pipeline_typeck_check_scope_borrow_assign_c (extern)
 * - pipeline_typeck_check_allocator_region_assign_c (extern)
 * - pipeline_typeck_check_scope_borrow_return_c (extern)
 * - pipeline_typeck_check_allocator_region_return_c (extern)
 * - pipeline_typeck_check_return_slice_region_in_scope_c (extern)
 * - pipeline_typeck_check_return_slice_region_c (extern)
 * - pipeline_typeck_check_call_struct_stack_escape_c (extern)
 * - pipeline_typeck_check_call_slice_region_c (extern)
 * - pipeline_typeck_expr_is_any_assign_kind_c (defined in coerce_init.c)
 * - pipeline_expr_kind_ord_at / pipeline_expr_binop_left/right_ref_at (extern)
 * - pipeline_expr_unary_operand_ref_at / pipeline_expr_set_resolved_type_ref (extern)
 * - pipeline_type_kind_ord_at / pipeline_type_ensure_by_kind_ord (extern)
 * - typeck_check_expr_panic / field_access / index / binop / unary /
 *   addr_of / as / try_propagate / struct_lit / float_lit / int_lit /
 *   bool_lit / break_continue / enum_variant / if_ternary / block (extern)
 * - typeck_check_expr_impl_mega (extern, typeck_x.o strong override)
 * - link_abi_getenv (extern)
 * - ast_ExprKind_* / ast_TypeKind_* / GLUE_EXPR_KIND_* / GLUE_EXPR_STRING_LIT_ORD
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 *   · LINUX+MACOS x86_64 SysV — kind dispatch only (encoding in callees)
 *   · MACOS|ARM64 AAPCS64 — same dispatch twin
 */

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
    return pipeline_typeck_check_expr_deref_c(module, arena, expr_ref, return_type_ref, ctx);
  if (kind == (int32_t)ast_ExprKind_EXPR_VAR)
    return pipeline_typeck_check_expr_var_c(module, arena, expr_ref, ctx);
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
