/**
 * pipeline_typeck_check_expr.c — typeck check_expr Cap residual thin
 * (BC 8.3.1 wave234 pure leave + wave232–228 + wave1188).
 *
 * wave234 G.7 pure leave: field_type / call_arg_repr / extern_unsafe dual
 * bodies → typeck twins (match subject BSS stays residual — pure mega
 * pipeline_abi -E SEGV deferred). Residual faces thin only.
 * wave232: call_c → typeck_check_expr_call.
 * wave231: match_c + try_propagate_c → typeck twins.
 * wave229: return_c → typeck_check_expr_return.
 * wave228: panic/unary/addr_of/index/deref/var thin → typeck twins.
 * Cap residual keeps:
 *   1. Thin product faces → typeck_x.o for panic/unary/addr/index/deref/var/
 *      return/match/try/call + field_type + repr_compatible + extern_unsafe
 *   2. Live residual: match subject BSS set/clear/get
 *   3. Dispatch: impl_mega_c (region escape gates for assign/return before
 *      type match; CALL still stack-escape after thin call face), impl_c
 *   4. XLANG_WEAK check_expr_impl{,_mega} cold faces
 *   5. method_call dual-export cold wrapper only when !OMIT_X_DUP_EXPORTS
 *
 * Dual-export ban: do NOT re-open second panic/unary/addr/index/deref/var/
 * return/match/try/call/field_type/repr/extern bodies here; typeck.x is
 * single authority for those. method_call remains residual (typeck twin
 * still wraps method_call_c).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after
 * call helpers + method_call.c, before check_block.c.
 *
 * PLATFORM: SHARED — freestanding typeck faces via typeck_x.o link.
 */

/* Live typeck.x twins for wave228/wave229 thin faces. */
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
extern int32_t typeck_check_expr_return(struct ast_Module *module, struct ast_ASTArena *arena,
                                        int32_t expr_ref, int32_t return_type_ref,
                                        struct ast_PipelineDepCtx *ctx);
/* wave231: live match + try_propagate authority in typeck_x.o. */
extern int32_t typeck_check_expr_match(struct ast_Module *module, struct ast_ASTArena *arena,
                                       int32_t expr_ref, int32_t return_type_ref,
                                       struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_try_propagate(struct ast_Module *module, struct ast_ASTArena *arena,
                                               int32_t expr_ref, int32_t return_type_ref,
                                               struct ast_PipelineDepCtx *ctx);
/* wave232: live CALL authority in typeck_x.o (generic fixup parity). */
extern int32_t typeck_check_expr_call(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                      int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);

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
    return typeck_check_expr_match(module, arena, expr_ref, return_type_ref, ctx);
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
    return typeck_check_expr_match(module, arena, expr_ref, return_type_ref, ctx);
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
 * wave1189+wave234 G.7: check_expr sub-class cluster. wave234: match subject
 * BSS pure leave (runtime_pipeline_abi); field_type/repr/extern thin → typeck.
 * g_typeck_unsafe_depth remains in pipeline_glue.c (shared with check_block).
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

/* --- match subject helpers (wave703 BSS + wave234 field_type pure leave) ---
 * set/clear/get remain residual BSS (pure pipeline_abi -E SEGV on mega .x this
 * wave — domain leave deferred). field_type thin → typeck. Dual-export ban. */

/* wave703: match arm field binds from subject type (struct pattern as wildcard). */
static int32_t g_typeck_match_subject_ty = 0;
static struct ast_Module *g_typeck_match_subject_mod = 0;

/** wave703: set match subject type for field-bind VAR resolve. */
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

/**
 * wave231: read subject type_ref for nested match save/restore (typeck.x match).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_match_subject_ty_get_c(void) {
  return g_typeck_match_subject_ty;
}

/**
 * wave231: read subject module for nested match save/restore (typeck.x match).
 * PLATFORM: SHARED.
 */
struct ast_Module *pipeline_typeck_match_subject_mod_get_c(void) {
  return g_typeck_match_subject_mod;
}

extern int32_t typeck_match_subject_field_type(struct ast_Module *module, struct ast_ASTArena *arena,
                                               uint8_t *name, int32_t name_len);

/**
 * Product-mega C face: match subject field-bind type lookup.
 * Thin → typeck_match_subject_field_type (wave234 pure leave).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_match_subject_field_type_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   uint8_t *name, int32_t name_len) {
  return typeck_match_subject_field_type(module, arena, name, name_len);
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

/* --- check_expr_match (wave231 thin → typeck.x) --- */

/**
 * Product-mega C face for EXPR_MATCH.
 * Thin → typeck_check_expr_match (subject BSS + iterative arms + guard).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_match_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                           int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return typeck_check_expr_match(module, arena, expr_ref, return_type_ref, ctx);
}

/* --- check_expr_return (wave229 thin → typeck.x) --- */

/**
 * Product-mega C face for EXPR_RETURN.
 * Thin → typeck_check_expr_return (wave318–333 coerce + null keyword +
 * array_vector + ret_coerce + slice region + breadcrumbs).
 * Mega arm still runs escape/region gates *before* this face (MEM-C1/WPO);
 * typeck return re-checks slice region (idempotent).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_return_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                             int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return typeck_check_expr_return(module, arena, expr_ref, return_type_ref, ctx);
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
 * - pipeline_typeck_check_call_generic_type_args_c (exported method_call.c; typeck call)
 * - glue_generic_call_fixup_resolved_type_c (exported method_call.c; typeck call)
 * - pipeline_typeck_resolve_call_callee_return_type_c (extern in method_call.c EOF)
 * - pipeline_typeck_check_call_slice_region_c (extern)
 * - typeck_check_expr_call_arg / call_resolve (extern)
 * - typeck_check_call_arity / call_arg_types (extern)
 * - typeck_overload_expected_ret_slot (extern)
 * - debug_try_propagate_report_glue_c (static in method_call.c EOF, wave1147)
 * PLATFORM: SHARED.
 * ========================================================================== */

/**
 * Product-mega C face for EXPR_TRY_PROPAGATE (ERR-01 Result `?`).
 * Thin → typeck_check_expr_try_propagate (wave231 pure leave).
 * Do NOT dual-export typeck_check_expr_try_propagate here (would cycle).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_try_propagate_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t expr_ref, int32_t return_type_ref,
                                                   struct ast_PipelineDepCtx *ctx) {
  return typeck_check_expr_try_propagate(module, arena, expr_ref, return_type_ref, ctx);
}

/**
 * Product-mega C face for EXPR_CALL.
 * Thin → typeck_check_expr_call (wave232 pure leave: generic type-args +
 * mono fixup parity). Do NOT dual-export typeck_check_expr_call here (cycle).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_expr_call_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                          int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return typeck_check_expr_call(module, arena, expr_ref, return_type_ref, ctx);
}

/* wave234 G.7 pure leave: call_arg_repr + extern_call_unsafe dual bodies
 * retired → typeck_call_arg_repr_compatible_ok /
 * typeck_check_extern_call_unsafe_boundary. Residual faces thin only.
 * PLATFORM: SHARED — freestanding typeck faces via typeck_x.o link. */

extern int32_t typeck_call_arg_repr_compatible_ok(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t param_ref, int32_t arg_ref);
extern int32_t typeck_check_extern_call_unsafe_boundary(struct ast_Module *module,
                                                        struct ast_ASTArena *arena, int32_t expr_ref,
                                                        struct ast_PipelineDepCtx *ctx);

/**
 * Product-mega C face: #[repr(compatible)] *StructA → *StructB gate.
 * Thin → typeck_call_arg_repr_compatible_ok (wave234 pure leave).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_call_arg_repr_compatible_ok_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                      int32_t param_ref, int32_t arg_ref) {
  return typeck_call_arg_repr_compatible_ok(module, arena, param_ref, arg_ref);
}

/**
 * Product-mega C face: LANG-007 S0 extern call must be inside unsafe { }.
 * Thin → typeck_check_extern_call_unsafe_boundary (wave234 pure leave).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_check_extern_call_unsafe_boundary_c(struct ast_Module *module,
                                                            struct ast_ASTArena *arena, int32_t expr_ref,
                                                            struct ast_PipelineDepCtx *ctx) {
  return typeck_check_extern_call_unsafe_boundary(module, arena, expr_ref, ctx);
}

/* wave232 / wave1282 G.7: call dual export removed — typeck.x owns
 * typeck_check_expr_call; residual face thins to typeck (thinning + dual
 * export would recurse). method_call residual still owns live body; cold
 * wrapper only when not OMIT_X_DUP_EXPORTS. PLATFORM: SHARED.
 */
#if !defined(XLANG_PIPELINE_GLUE_STANDALONE_TU) && !defined(XLANG_PIPELINE_GLUE_OMIT_X_DUP_EXPORTS)
int32_t typeck_check_expr_method_call(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                      int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_check_expr_method_call_c(module, arena, expr_ref, return_type_ref, ctx);
}
#endif
