/* ============================================================================
 * wave317 typeck M4 layer-1 Cap residual (BSS slots + CTFE).
 * Authority: pin typeck_gen L13097-14390 (pre-wave317). allow_legacy lives in
 * patch_typeck_gen_lang007 / product header — not duplicated here.
 * Append-only companion for tip typeck.x -E re-pin; G.7 residual TU.
 * PLATFORM: SHARED freestanding typeck Cap residual.
 * ========================================================================== */


/* ============================================================================
 * 8.3.1/8.3.2 host-cc leave: typeck scratch / call-resolve / overload /
 * layout-metrics slots — historical body in pipeline_typeck_slots.c (same-TU
 * #include into pipeline_x). Live BSS accessors only; dead binop_arith_infer /
 * try_packed C twins dropped (typeck.x owns widen/layout business).
 * PLATFORM: SHARED — lives in typeck_x.o (not pipeline_x host-cc mega-TU).
 * ============================================================================ */

/** typeck.x: named-type scratch (avoid local u8[64] under self-typecheck). */
uint8_t *typeck_named_scratch64(void) {
  static uint8_t s[128];
  return s;
}

/** typeck.x: multi-slot 128B scratch (wave577 Cap: 64->128). */
static uint8_t g_typeck_scratch64[16][128];

uint8_t *typeck_scratch64_slot(int32_t slot) {
  if (slot < 0 || slot >= 16)
    return g_typeck_scratch64[0];
  return g_typeck_scratch64[slot];
}

/** typeck.x: CALL resolve func/dep index BSS (no stack &cfi under selfhost). */
static int32_t g_typeck_call_resolve_func_idx;
static int32_t g_typeck_call_resolve_dep_idx;
/**
 * PLATFORM: SHARED — expected return type for overload pick (let/assign/return).
 * Zero-arg overloads score by this when args do not disambiguate. 0 = no hint.
 */
static int32_t g_typeck_overload_expected_ret;

int32_t *typeck_call_resolve_func_idx_slot(void) {
  return &g_typeck_call_resolve_func_idx;
}

int32_t *typeck_call_resolve_dep_idx_slot(void) {
  return &g_typeck_call_resolve_dep_idx;
}

int32_t *typeck_overload_expected_ret_slot(void) {
  return &g_typeck_overload_expected_ret;
}

int32_t typeck_call_resolve_dep_idx_peek(void) {
  return g_typeck_call_resolve_dep_idx;
}

int32_t typeck_call_resolve_func_idx_peek(void) {
  return g_typeck_call_resolve_func_idx;
}

int32_t typeck_overload_expected_ret_peek(void) {
  return g_typeck_overload_expected_ret;
}

/** typeck.x: struct_layout_metrics out_sz/out_al BSS (no stack &z/&al). */
static int32_t g_typeck_layout_metrics_sz;
static int32_t g_typeck_layout_metrics_al;

int32_t *typeck_layout_metrics_sz_slot(void) {
  return &g_typeck_layout_metrics_sz;
}

int32_t *typeck_layout_metrics_al_slot(void) {
  return &g_typeck_layout_metrics_al;
}

/** Recursive metrics: 8 depth groups avoid align/size single-slot tearing. */
static int32_t g_typeck_layout_metrics_depth_scratch[8][2];

int32_t *typeck_layout_metrics_sz_slot_depth(int32_t depth) {
  int32_t s = depth;
  if (s < 0)
    s = 0;
  return &g_typeck_layout_metrics_depth_scratch[s % 8][0];
}

int32_t *typeck_layout_metrics_al_slot_depth(int32_t depth) {
  int32_t s = depth;
  if (s < 0)
    s = 0;
  return &g_typeck_layout_metrics_depth_scratch[s % 8][1];
}

/* ==========================================================================
 * wave238 hand-sync: typeck CTFE pure leave (LANG-006 producer).
 * Authority = typeck_x.o (this file). Cap residual pipeline_typeck_ctfe.c thins
 * here. PLATFORM: SHARED freestanding typeck.
 * ========================================================================== */
extern struct ast_Expr *glue_arena_expr_at_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
extern int32_t pipeline_block_const_name_len(struct ast_ASTArena *a, int32_t br, int32_t ci);
extern void pipeline_block_const_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t ci, uint8_t *dst);
extern int32_t pipeline_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
extern int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_elem_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_struct_lit_init_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t j);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *a, int32_t type_ref);
extern int32_t pipeline_expr_if_cond_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_if_then_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_if_else_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_match_matched_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_match_num_arms_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_match_arm_is_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_variant_index(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_result_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_enum_variant_tag_at(struct ast_ASTArena *a, int32_t expr_ref);
extern void pipeline_expr_try_mark_enum_field_access(struct ast_Module *m, struct ast_ASTArena *a, int32_t expr_ref);
extern struct ast_Module *pipeline_typeck_active_module_c(void);
extern int32_t pipeline_expr_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t expr_ref);
extern void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_expr_const_folded_valid_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_const_folded_val_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_int_val_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t glue_fold_func_returns_param01_scalar_binop_c(struct ast_ASTArena *a, struct ast_Module *mod, int32_t fi, int32_t *out_ko);
extern int32_t glue_try_eval_pure_param0_scalar_func_c(struct ast_ASTArena *a, struct ast_Module *mod, int32_t fi, int32_t arg, int32_t *out);
extern int32_t glue_fold_func_returns_param0_index_const_c(struct ast_ASTArena *a, struct ast_Module *mod, int32_t fi, int32_t *out_lane);
extern int32_t glue_fold_func_returns_param01_vector_binop_ctfe_c(struct ast_ASTArena *a, struct ast_Module *mod, int32_t fi, int32_t *out_ko);
extern int32_t glue_try_array_lit_lane_const_i32_c(struct ast_ASTArena *a, int32_t arr_ref, int32_t lane, int32_t *out);
/* lsp_diag_report_typeck already declared above (uint8_t *msg). */
extern int32_t ast_ast_block_num_consts(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_num_loops(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_num_for_loops(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_num_regions(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t i);

static int typeck_is_const_expr_ref_impl(struct ast_ASTArena *a, int32_t expr_ref, const char *const_names[], int n_const_names) {
  struct ast_Expr *e;
  int i, j, ne;
  enum ast_ExprKind kd;

  e = glue_arena_expr_at_ref(a, expr_ref);
  if (!e)
    return 0;
  kd = e->kind;
  if (kd == ast_ExprKind_EXPR_LIT || kd == ast_ExprKind_EXPR_FLOAT_LIT || kd == ast_ExprKind_EXPR_BOOL_LIT)
    return 1;
  if (kd == ast_ExprKind_EXPR_VAR) {
    for (i = 0; i < n_const_names; i++) {
      if (!const_names[i])
        continue;
      if (e->var_name_len > 0 && strcmp(const_names[i], e->var_name) == 0)
        return 1;
    }
    return 0;
  }
  if (kd >= ast_ExprKind_EXPR_ADD && kd <= ast_ExprKind_EXPR_LOGOR)
    return typeck_is_const_expr_ref_impl(a, e->binop_left_ref, const_names, n_const_names) &&
           typeck_is_const_expr_ref_impl(a, e->binop_right_ref, const_names, n_const_names);
  if (kd == ast_ExprKind_EXPR_NEG || kd == ast_ExprKind_EXPR_BITNOT || kd == ast_ExprKind_EXPR_LOGNOT)
    return typeck_is_const_expr_ref_impl(a, e->unary_operand_ref, const_names, n_const_names);
  if (kd == ast_ExprKind_EXPR_ARRAY_LIT) {
    ne = e->array_lit_num_elems;
    for (i = 0; i < ne; i++) {
      if (!typeck_is_const_expr_ref_impl(a, pipeline_expr_array_lit_elem_ref(a, expr_ref, i), const_names, n_const_names))
        return 0;
    }
    return 1;
  }
  /**
   * C5-struct-lit: a struct literal is a const expression iff every field
   * initializer is a const expression. The struct value itself cannot fit
   * in the i32 const_folded_val field, so callers that demand a scalar
   * result (e.g. `const N: i32 = <struct lit>`) still fail at typeck; this
   * branch only enables nested folding of inner field inits such as
   * `S { x: A+1, y: B*2 }` where A,B are prior block consts. Mirrors the
   * ARRAY_LIT recursion above. PLATFORM: SHARED.
   */
  if (kd == ast_ExprKind_EXPR_STRUCT_LIT) {
    ne = e->struct_lit_num_fields;
    for (i = 0; i < ne; i++) {
      int32_t init_ref = pipeline_expr_struct_lit_init_ref(a, expr_ref, i);
      if (init_ref <= 0)
        return 0;
      if (!typeck_is_const_expr_ref_impl(a, init_ref, const_names, n_const_names))
        return 0;
    }
    return 1;
  }
  /**
   * C5-enum-variant: a TypeName.Variant FIELD_ACCESS is a const expression
   * iff the marker confirms it resolves to an enum variant tag.
   *
   * Why: This whitelist (pipeline_typeck_block_const_init_is_const_c) runs at
   *      seed typeck_gen L6839, BEFORE the typeck-time marker
   *      pipeline_typeck_try_mark_enum_field_access fires inside
   *      typeck_check_expr at L6850. So at whitelist time a fresh
   *      FIELD_ACCESS still has field_access_is_enum_variant=0, and the
   *      whitelist cannot tell Color.Red (enum variant — const-eligible)
   *      from obj.field (runtime struct access — NOT const-eligible).
   *
   *      We resolve the chicken-and-egg by pre-marking here using the
   *      global g_typeck_active_module, which is set at module typeck
   *      entry (ast_pool.c L6428 / pipeline_glue.c L22027) before any
   *      block-level typeck runs. The marker is idempotent — early-
   *      returns if already marked — so re-marking at L6850 is a no-op.
   *
   * Invariant: For non-enum FIELD_ACCESS (obj.field / array[x].field at
   *            runtime) pipeline_expr_try_mark_enum_field_access leaves
   *            field_access_is_enum_variant=0 (tag lookup returns -1), so
   *            this branch correctly rejects them — they are NOT const.
   *            Only TypeName.Variant shapes pass.
   *
   * Asm/Perf: Enables `const X: Color = Color.Red;` to typecheck, paving
   *           the way for the fold handler in glue_typeck_fold_expr_ref to
   *           stamp X.const_folded_val=tag. Downstream `match X { ... }`
   *           then folds to a single mov w0,#imm (no runtime enum load).
   *
   * PLATFORM: SHARED — g_typeck_active_module is populated identically on
   *           macOS arm64 and Ubuntu x86_64 at module typeck entry.
   */
  if (kd == ast_ExprKind_EXPR_FIELD_ACCESS) {
    pipeline_expr_try_mark_enum_field_access(pipeline_typeck_active_module_c(), a, expr_ref);
    if (pipeline_expr_field_access_is_enum_variant(a, expr_ref) != 0)
      return 1;
    return 0;
  }
  /**
   * C5-ternary-if: a ternary `cond ? then : else` or if-expression
   * `if cond { then } else { else }` is a const expression iff cond, then,
   * and else are all const expressions. EXPR_IF and EXPR_TERNARY share the
   * same field layout (if_cond_ref / if_then_ref / if_else_ref, see
   * ast_pool.c::asm_wpo_collect_edges_from_expr L14836-14844), so one
   * branch covers both kinds.
   *
   * Why: Lets `const Y: i32 = (X == 2) ? 100 : 200;` and
   *      `const Y: i32 = if (X == 2) { 100 } else { 200 };` pass the
   *      const-init whitelist (pipeline_typeck_block_const_init_is_const_c
   *      at seed typeck_gen L6839). The fold handler in
   *      glue_typeck_fold_expr_ref then picks the live branch and stamps
   *      the result. Mirrors EXPR_MATCH treatment (subject + arms recursion
   *      but no top-level whitelist case; here we whitelist because both
   *      branches are statically reachable from a const POV — only one is
   *      selected at CTFE, but both must be const-eligible to type-check
   *      `const Y = cond ? a : b;` regardless of which branch fires).
   *
   * Invariant: Recurses into all three children (cond, then, else). If any
   *            child is non-const (e.g. runtime VAR or function call) the
   *            whole expression is non-const. This is stricter than the
   *            fold handler, which only needs the *selected* branch to
   *            fold — the whitelist must accept both because the typeck
   *            pass runs before CTFE picks a branch.
   *
   * Asm/Perf: Enables `const Y = cond ? a : b;` to typecheck, paving the
   *           way for the fold handler to emit `mov w0, #const` (4 bytes)
   *           instead of runtime cmp/branch + 2× value materialization
   *           (~24 bytes). Also unlocks parent binop folds.
   *
   * PLATFORM: SHARED — EXPR_IF / EXPR_TERNARY field layout is identical on
   *           macOS arm64 and Ubuntu x86_64 (ast_pool.c L14836).
   */
  if (kd == ast_ExprKind_EXPR_TERNARY || kd == ast_ExprKind_EXPR_IF) {
    int32_t cond_ref = pipeline_expr_if_cond_ref_at(a, expr_ref);
    int32_t then_ref = pipeline_expr_if_then_ref_at(a, expr_ref);
    int32_t else_ref = pipeline_expr_if_else_ref_at(a, expr_ref);
    if (cond_ref <= 0 || then_ref <= 0 || else_ref <= 0)
      return 0;
    return typeck_is_const_expr_ref_impl(a, cond_ref, const_names, n_const_names) &&
           typeck_is_const_expr_ref_impl(a, then_ref, const_names, n_const_names) &&
           typeck_is_const_expr_ref_impl(a, else_ref, const_names, n_const_names);
  }
  /**
   * C5-block: a single-stmt block `({ expr })` is a const expression iff the
   * block has no side-effecting statements (no const/let decls, no loops, no
   * if-statements, no regions) and exactly one expression statement whose
   * expr is const. This is required for EXPR_IF support because the
   * if-expression parser wraps each branch as EXPR_BLOCK
   * (parser_asm_if_expr_slice.inc::parser_asm_wrap_block_ref_as_expr_c);
   * recursing into then_ref/else_ref reaches EXPR_BLOCK children.
   *
   * Why: Lets `const Y: i32 = if (X==2) { 100 } else { 200 };` pass the
   *      const-init whitelist by treating the wrapped `{ 100 }` block as the
   *      inner literal's value. Multi-stmt / side-effecting blocks stay
   *      non-const (correctly: those have runtime ordering concerns that
   *      CTFE cannot model at this stage).
   *
   * Invariant: Strict side-effect scan (num_consts/lets/loops/for_loops/
   *            if_stmts/regions all zero, num_expr_stmts == 1). The fold
   *            handler mirrors this check and stamps e->const_folded_val
   *            from ast_ast_block_final_expr_ref's folded value.
   *
   * Asm/Perf: Unlocks EXPR_IF CTFE end-to-end. Combined with EXPR_TERNARY +
   *           EXPR_IF handlers, enables `const Y = cond ? a : b;` and
   *           `const Y = if (c) { a } else { b };` to emit `mov w0, #const`
   *           (4 bytes / 1 instr) instead of runtime cmp/branch + materialize.
   *
   * PLATFORM: SHARED — EXPR_BLOCK layout and Block accessors are identical
   *           on macOS arm64 and Ubuntu x86_64. Mirrored in seed
   *           pipeline_glue_strict_minimal.from_x.c (Darwin filtered pipeline
   *           localizes this strong version, so seed weak version is what
   *           Darwin calls).
   */
  if (kd == ast_ExprKind_EXPR_BLOCK) {
    int32_t block_ref = pipeline_expr_block_ref_at(a, expr_ref);
    int32_t final_expr_ref;
    int32_t n_es;
    if (block_ref <= 0)
      return 0;
    if (ast_ast_block_num_consts(a, block_ref) > 0)
      return 0;
    if (ast_ast_block_num_lets(a, block_ref) > 0)
      return 0;
    if (ast_ast_block_num_loops(a, block_ref) > 0)
      return 0;
    if (ast_ast_block_num_for_loops(a, block_ref) > 0)
      return 0;
    if (ast_ast_block_num_if_stmts(a, block_ref) > 0)
      return 0;
    if (ast_ast_block_num_regions(a, block_ref) > 0)
      return 0;
    /* Parser normalizes `{ expr }` (final_expr_ref set, num_expr_stmts=0)
     * into `expr_stmts[0] = expr; final_expr_ref = 0`. So accept either
     * form: prefer final_expr_ref when set, else fall back to the single
     * expr_stmt. Reject multi-stmt blocks (num_expr_stmts > 1). */
    n_es = ast_ast_block_num_expr_stmts(a, block_ref);
    final_expr_ref = ast_ast_block_final_expr_ref(a, block_ref);
    if (final_expr_ref <= 0) {
      if (n_es != 1)
        return 0;
      final_expr_ref = ast_pipeline_block_expr_stmt_ref(a, block_ref, 0);
    } else if (n_es != 0) {
      return 0;
    }
    if (final_expr_ref <= 0)
      return 0;
    return typeck_is_const_expr_ref_impl(a, final_expr_ref, const_names, n_const_names);
  }
  return 0;
}

/** PLATFORM: SHARED — expr is legal as a C static initializer (compile-time const, no free vars).
 * Authority: glue_is_const_expr_ref with empty const-name set (pure lit trees + ops; VAR fails).
 * Used by codegen want_decl_init for mutable top-level lets: lit sentinels (e.g. -1) stay at
 * decl-site for library .o without main; VAR-dependent inits (e.g. a+2) stay init_globals-only. */
int32_t typeck_expr_is_c_static_const_init(struct ast_ASTArena *arena, int32_t expr_ref) {
  if (!arena || expr_ref <= 0)
    return 0;
  return typeck_is_const_expr_ref_impl(arena, expr_ref, NULL, 0) ? 1 : 0;
}

/** block 内第 const_idx 条 const 的 init 是否为常量表达式；是返回 1，否返回 0。 */
int32_t typeck_block_const_init_is_const(struct ast_ASTArena *arena, int32_t block_ref, int32_t const_idx) {
  const char *names[64];
  char name_bufs[64][128];
  int n = 0;
  int i;
  int32_t init_ref;

  if (!arena || const_idx < 0)
    return 0;
  for (i = 0; i < const_idx && n < 64; i++) {
    int32_t nlen = pipeline_block_const_name_len(arena, block_ref, i);
    if (nlen <= 0 || nlen >= 64)
      continue;
    pipeline_block_const_name_copy64(arena, block_ref, i, (uint8_t *)name_bufs[n]);
    name_bufs[n][nlen] = '\0';
    names[n] = name_bufs[n];
    n++;
  }
  init_ref = pipeline_block_const_init_ref(arena, block_ref, const_idx);
  if (init_ref <= 0)
    return 1;
  return typeck_is_const_expr_ref_impl(arena, init_ref, names, n) ? 1 : 0;
}

/** const 初值非常量表达式时报错（与 typeck.c TYPECK_ERR_AT 措辞一致）。 */
void typeck_const_init_not_constant(int32_t line, int32_t col) {
  static uint8_t msg[] = "const init must be constant expression";
  lsp_diag_report_typeck(line, col, msg);
}

/**
 * PLATFORM: SHARED — typeck CTFE producer (LANG-006 / residual IR authority).
 *
 * Writes `const_folded_valid` / `const_folded_val` on arena exprs. Emit only
 * *consumes* these fields (mov imm); do not grow emit-side optim folds.
 *
 * Restores the producer lost when mega typeck.c was removed (G-02a): product
 * typeck.x only validated `is_const_expr` and never folded. Pure lit trees and
 * block-const chains (const A=3; const B=A+2) are folded bottom-up.
 *
 * names/values: prior const bindings in scope (may be NULL/0 for pure lits).
 *
 * PLATFORM: SHARED — product Expr.const_folded_val is still an i32 field in
 * ast.x / seed layouts (ast.h documents i64 intent). Truncating wide i64 lits
 * (e.g. 9223372036854775807 -> -1) then folding `0 - lit - 1` -> 0 is the
 * fmt_i64_min / P0-4 silent wrong-code class. Rule:
 *   - Only set const_folded_valid when the value fits in int32_t.
 *   - Otherwise leave valid=0 so C emit uses full int_val on LIT / full binop tree.
 */
static int typeck_ctfe_fits_i32(int64_t v) {
  return v >= (int64_t)INT32_MIN && v <= (int64_t)INT32_MAX;
}

static void typeck_fold_expr_ref_impl(struct ast_ASTArena *a, int32_t expr_ref,
                                     const char *const_names[], const int64_t *const_values,
                                     int n_const_names) {
  struct ast_Expr *e;
  enum ast_ExprKind kd;
  int32_t left_ref;
  int32_t right_ref;
  int32_t op_ref;
  int i;
  int64_t l;
  int64_t r;
  int64_t o;
  int64_t out;

  e = glue_arena_expr_at_ref(a, expr_ref);
  if (!e)
    return;
  e->const_folded_valid = 0;
  kd = e->kind;

  if (kd == ast_ExprKind_EXPR_LIT || kd == ast_ExprKind_EXPR_BOOL_LIT) {
    /* P0-4: do not CTFE-truncate wide i64 literals into the i32 fold field. */
    if (typeck_ctfe_fits_i32(e->int_val)) {
      e->const_folded_val = (int32_t)e->int_val;
      e->const_folded_valid = 1;
    }
    return;
  }
  /*
   * wave287 Cap residual: do NOT CTFE-fold EXPR_FLOAT_LIT into const_folded_val.
   * Root cause: const_folded_val is i32; folding (int32_t)float_val truncated fractions
   * (1.5->1) and emit consumed fold via format_int -> soft residual wrong C (`double a = 1`
   * instead of 1.5; (1.5*2.0) as i32 -> 2). Product C emit uses pipeline_codegen_emit_float_lit_c
   * on float_val when const_folded_valid=0. PLATFORM: SHARED — single authority here.
   */
  if (kd == ast_ExprKind_EXPR_FLOAT_LIT) {
    e->const_folded_valid = 0;
    return;
  }
  if (kd == ast_ExprKind_EXPR_VAR) {
    if (!const_names || !const_values || n_const_names <= 0 || e->var_name_len <= 0)
      return;
    for (i = 0; i < n_const_names; i++) {
      if (!const_names[i])
        continue;
      if (strcmp(const_names[i], (const char *)e->var_name) == 0) {
        if (typeck_ctfe_fits_i32(const_values[i])) {
          e->const_folded_val = (int32_t)const_values[i];
          e->const_folded_valid = 1;
        }
        return;
      }
    }
    return;
  }

  if (kd >= ast_ExprKind_EXPR_ADD && kd <= ast_ExprKind_EXPR_LOGOR) {
    left_ref = e->binop_left_ref;
    right_ref = e->binop_right_ref;
    typeck_fold_expr_ref_impl(a, left_ref, const_names, const_values, n_const_names);
    typeck_fold_expr_ref_impl(a, right_ref, const_names, const_values, n_const_names);
    {
      struct ast_Expr *el = glue_arena_expr_at_ref(a, left_ref);
      struct ast_Expr *er = glue_arena_expr_at_ref(a, right_ref);
      if (!el || !er || !el->const_folded_valid || !er->const_folded_valid)
        return;
      l = (int64_t)el->const_folded_val;
      r = (int64_t)er->const_folded_val;
    }
    switch (kd) {
    case ast_ExprKind_EXPR_ADD:
      out = l + r;
      break;
    case ast_ExprKind_EXPR_SUB:
      out = l - r;
      break;
    case ast_ExprKind_EXPR_MUL:
      out = l * r;
      break;
    case ast_ExprKind_EXPR_DIV:
      if (r == 0)
        return;
      out = l / r;
      break;
    case ast_ExprKind_EXPR_MOD:
      if (r == 0)
        return;
      out = l % r;
      break;
    case ast_ExprKind_EXPR_SHL:
      out = (int64_t)((uint64_t)l << ((uint64_t)r & 63u));
      break;
    case ast_ExprKind_EXPR_SHR:
      out = (int64_t)((uint64_t)l >> ((uint64_t)r & 63u));
      break;
    case ast_ExprKind_EXPR_BITAND:
      out = l & r;
      break;
    case ast_ExprKind_EXPR_BITOR:
      out = l | r;
      break;
    case ast_ExprKind_EXPR_BITXOR:
      out = l ^ r;
      break;
    case ast_ExprKind_EXPR_EQ:
      out = (l == r) ? 1 : 0;
      break;
    case ast_ExprKind_EXPR_NE:
      out = (l != r) ? 1 : 0;
      break;
    case ast_ExprKind_EXPR_LT:
      out = (l < r) ? 1 : 0;
      break;
    case ast_ExprKind_EXPR_LE:
      out = (l <= r) ? 1 : 0;
      break;
    case ast_ExprKind_EXPR_GT:
      out = (l > r) ? 1 : 0;
      break;
    case ast_ExprKind_EXPR_GE:
      out = (l >= r) ? 1 : 0;
      break;
    case ast_ExprKind_EXPR_LOGAND:
      out = (l && r) ? 1 : 0;
      break;
    case ast_ExprKind_EXPR_LOGOR:
      out = (l || r) ? 1 : 0;
      break;
    default:
      return;
    }
    if (!typeck_ctfe_fits_i32(out))
      return;
    e->const_folded_val = (int32_t)out;
    e->const_folded_valid = 1;
    return;
  }

  if (kd == ast_ExprKind_EXPR_NEG || kd == ast_ExprKind_EXPR_BITNOT || kd == ast_ExprKind_EXPR_LOGNOT) {
    op_ref = e->unary_operand_ref;
    typeck_fold_expr_ref_impl(a, op_ref, const_names, const_values, n_const_names);
    {
      struct ast_Expr *eo = glue_arena_expr_at_ref(a, op_ref);
      if (!eo || !eo->const_folded_valid)
        return;
      o = (int64_t)eo->const_folded_val;
    }
    if (kd == ast_ExprKind_EXPR_NEG)
      out = -o;
    else if (kd == ast_ExprKind_EXPR_BITNOT)
      out = ~o;
    else
      out = !o ? 1 : 0;
    if (!typeck_ctfe_fits_i32(out))
      return;
    e->const_folded_val = (int32_t)out;
    e->const_folded_valid = 1;
    return;
  }

  if (kd == ast_ExprKind_EXPR_ARRAY_LIT) {
    int ne = e->array_lit_num_elems;
    int32_t tr;
    int32_t tk;
    for (i = 0; i < ne; i++)
      typeck_fold_expr_ref_impl(a, pipeline_expr_array_lit_elem_ref(a, expr_ref, i), const_names,
                                const_values, n_const_names);
    /**
     * C5-array-len: only when the lit was coerced to a scalar int type
     * (`const N: i32 = [1,2,3,4]`). Real array materialization keeps
     * const_folded_valid=0 so emit does not mov imm.
     */
    tr = e->resolved_type_ref;
    if (tr > 0) {
      tk = pipeline_type_kind_ord_at(a, tr);
      /* TYPE_I32..TYPE_ISIZE = 0..7 in product enum. */
      if (tk >= 0 && tk <= 7) {
        e->const_folded_val = (int32_t)ne;
        e->const_folded_valid = 1;
      }
    }
    return;
  }

  /**
   * PLATFORM: SHARED — C5-struct-lit field CTFE (扩全).
   * Why: Struct literals frequently carry field initializers that are pure
   *      const expressions (`S { x: A+1, y: A*3 }` where A is a prior const).
   *      Without recursion the inner binop trees stay unfolded, forcing emit
   *      to emit runtime `mov;add;mov;mul;mov` sequences instead of immediates.
   * Invariant: The struct value itself cannot fit in the i32 const_folded_val
   *            field, so this branch NEVER stamps e->const_folded_valid=1 on
   *            the STRUCT_LIT node. It only descends into each field init so
   *            that the inner Expr trees (binop/unary/lit/var/nested-call)
   *            get folded in place; emit then reads those inner stamps. This
   *            mirrors ARRAY_LIT's element recursion but skips the scalar
   *            coercion stamp (struct cannot be coerced to scalar int).
   * Asm/Perf: For `S { x: A+1, y: A*3 }` with A=2 folded prior, emit drops
   *           `mov edi,2; add edi,1; mov [..x],edi; mov edi,2; imul edi,3;`
   *           in favor of `mov DWORD[..x],3; mov DWORD[..y],6;` (constant
   *           materialization only), shrinking the hot path and removing
   *           two ALU dependencies.
   */
  if (kd == ast_ExprKind_EXPR_STRUCT_LIT) {
    int nf = e->struct_lit_num_fields;
    for (i = 0; i < nf; i++) {
      int32_t init_ref = pipeline_expr_struct_lit_init_ref(a, expr_ref, i);
      if (init_ref > 0)
        typeck_fold_expr_ref_impl(a, init_ref, const_names, const_values, n_const_names);
    }
    return;
  }

  if (kd == ast_ExprKind_EXPR_AS) {
    /*
     * PLATFORM: SHARED — CTFE producer for EXPR_AS (wave460 Cap residual pure).
     * Always fold the operand so nested trees still CTFE. Stamp this AS node
     * only when the *target* is a scalar that host-C/asm can materialize as a
     * bare i32 immediate.
     *
     * Root (soft leave-off after wave459 compound-literal host-C emit):
     *   `let m: MultiField = 7 as MultiField` -> typeck set const_folded_valid=1
     *   from the lit operand -> emit_expr consumed fold as format_int -> host C
     *   `struct MultiField m = 7` -> BLD001. Variable operand skipped the fold
     *   stamp and correctly took wave459 `((TYPE){ (op) })`.
     *
     * Mirror STRUCT_LIT: aggregate values cannot fit in i32 const_folded_val;
     * never stamp valid=1 for TYPE_NAMED user structs / array / slice / vector /
     * linear so codegen EXPR_AS (compound literal / cast) remains authority.
     * G.7: single authority = this producer; emit only *consumes* the flags.
     */
    typeck_fold_expr_ref_impl(a, e->as_operand_ref, const_names, const_values, n_const_names);
    {
      struct ast_Expr *eo = glue_arena_expr_at_ref(a, e->as_operand_ref);
      int32_t tgt;
      int32_t tk;
      if (!eo || !eo->const_folded_valid)
        return;
      tgt = e->as_target_type_ref;
      if (tgt <= 0)
        tgt = e->resolved_type_ref;
      if (tgt > 0) {
        /* Kind check only (no alias peel): TYPE_NAMED covers user structs and
         * named aliases; skipping stamp for aliases is safe — emit still does
         * C cast/compound via EXPR_AS. Avoid calling resolve here (defined later
         * in this TU; fold stays self-contained). */
        tk = pipeline_type_kind_ord_at(a, tgt);
        if (tk == (int32_t)ast_TypeKind_TYPE_NAMED
            || tk == (int32_t)ast_TypeKind_TYPE_ARRAY
            || tk == (int32_t)ast_TypeKind_TYPE_SLICE
            || tk == (int32_t)ast_TypeKind_TYPE_LINEAR
            || tk == (int32_t)ast_TypeKind_TYPE_VECTOR)
          return; /* keep const_folded_valid=0; emit via EXPR_AS host-C path */
      }
      e->const_folded_val = eo->const_folded_val; /* int32 product field */
      e->const_folded_valid = 1;
    }
    return;
  }

  /**
   * PLATFORM: SHARED — C5-enum-variant CTFE (TypeName.Variant folds to tag).
   *
   * Why: Enum variants are statically assigned a discriminator tag at parse
   *      time via pipeline_module_enum_variant_tag_for_names (ast_pool.c
   *      L4204). The same source feeds both:
   *        - MatchArmEntry.variant_index (pipeline_expr_append_match_arm,
   *          ast_pool.c L5200) — drives arm comparison in EXPR_MATCH fold.
   *        - Expr.enum_variant_tag (set by pipeline_expr_try_mark_enum_field_access,
   *          ast_pool.c L4312) — drives emit's `mov w0,#tag` fast path.
   *      Folding Color.Red into const_folded_val=tag enables two key wins:
   *        (1) `const X: Color = Color.Red;` stamps X with the tag so
   *            downstream `match X { Color.Red => ... }` folds to a single
   *            immediate via the EXPR_MATCH handler (L14131-14137).
   *        (2) Standalone `return Color.Red;` emits `mov w0,#tag` directly
   *            instead of going through runtime enum-load glue.
   *
   * Invariant: const_folded_val holds the enum_variant_tag (i32 >= 0). The
   *            marker is idempotent — re-running on an already-marked expr
   *            early-returns without rewriting the tag. For non-enum
   *            FIELD_ACCESS (obj.field) the marker leaves
   *            field_access_is_enum_variant=0, so this branch correctly
   *            skips stamping (const_folded_valid stays 0, set at L13664).
   *            The marker needs the active module — g_typeck_active_module
   *            is set at module typeck entry (ast_pool.c L6428 / glue L22027)
   *            and remains live throughout block-level typeck.
   *
   * Asm/Perf: Replaces runtime tag-load sequence (`adrp xN, .enum_table;
   *           ldr w0, [xN, #off]`) with `mov w0, #imm` (4 bytes vs ~12).
   *           Eliminates a memory load and a relocation in the .text section.
   *           For match-on-const-enum the entire jump table collapses to one
   *           immediate materialization.
   */
  if (kd == ast_ExprKind_EXPR_FIELD_ACCESS) {
    int32_t tag;
    /* Pre-mark in case the whitelist path was bypassed (e.g. fold invoked
     * from pipeline_typeck_fold_expr_c on a standalone FIELD_ACCESS expr
     * without prior whitelist pre-mark). No-op if already marked. */
    pipeline_expr_try_mark_enum_field_access(pipeline_typeck_active_module_c(), a, expr_ref);
    if (pipeline_expr_field_access_is_enum_variant(a, expr_ref) == 0)
      return; /* Non-enum FIELD_ACCESS: runtime struct access, not const. */
    tag = pipeline_expr_enum_variant_tag_at(a, expr_ref);
    if (tag < 0)
      return; /* Defensive: marker set is_enum_variant=1 but tag readback failed. */
    e->const_folded_val = tag;
    e->const_folded_valid = 1;
    return;
  }

  /**
   * PLATFORM: SHARED — WPO-S2 / LANG-006 call-site CTFE (pre-emit authority).
   * (1) Pure local `f(c0,c1)` when f body is `return p0 binop p1`.
   * (2) Pure 1-param scalar: `id(c)` / `g(c)` where body is p0 / p0 op lit /
   *     lit op p0 / unary(p0). Enables nested `f(g(3),4)` via arg fold first.
   * (3) Pure `laneK(vec_binop([const…],[const…]))` when outer is `return p0[K]`
   *     and inner is vector `return p0 binop p1` with array-lit const lanes.
   * Emit only *consumes* const_folded_* (mov imm / C int); try_inline_* remain
   * safety nets. XLANG_WPO_MONO / NO_FOLD skip stamp so call sites stay live.
   */
  if (kd == ast_ExprKind_EXPR_CALL) {
    int32_t nargs;
    int32_t ai;
    int32_t callee_ref;
    int32_t clen;
    int32_t fi;
    int32_t binop_ko;
    int32_t arg0;
    int32_t arg1;
    int32_t av0;
    int32_t av1;
    int32_t folded;
    uint8_t cname[128];
    struct ast_Module *mod;
    struct ast_Expr *ea0;
    struct ast_Expr *ea1;

    nargs = pipeline_expr_call_num_args_at(a, expr_ref);
    for (ai = 0; ai < nargs; ai++) {
      int32_t ar = pipeline_expr_call_arg_ref(a, expr_ref, ai);
      if (ar > 0)
        typeck_fold_expr_ref_impl(a, ar, const_names, const_values, n_const_names);
    }
    /**
     * WPO-S2 harness: XLANG_WPO_MONO needs a live CALL for mono thunks;
     * XLANG_WPO_NO_FOLD needs a real call. Skip stamping CALL const_folded so
     * parent binops do not erase the site (scale(c0,c1)-K would become 0).
     */
    {
      const char *wpo_mono = link_abi_getenv("XLANG_WPO_MONO");
      const char *wpo_nofold = link_abi_getenv("XLANG_WPO_NO_FOLD");
      if ((wpo_mono && wpo_mono[0]) || (wpo_nofold && wpo_nofold[0]))
        return;
    }
    mod = pipeline_typeck_active_module_c();
    if (!mod)
      return;
    callee_ref = pipeline_expr_call_callee_ref_at(a, expr_ref);
    if (callee_ref <= 0 || pipeline_expr_kind_ord_at(a, callee_ref) != 3)
      return;
    clen = pipeline_expr_var_name_len(a, callee_ref);
    if (clen <= 0 || clen > 127)
      return;
    pipeline_expr_var_name_into(a, callee_ref, cname);
    /* PLATFORM: SHARED — prefer typeck call_resolved_func_index for overloads.
     * Name-only lookup returns the first same-name func (e.g. pick(i32) before
     * pick(i64)) and wrongly CTFE-folds the i64 call site -> types/overload exit 2. */
    fi = pipeline_expr_call_resolved_func_index_at(a, expr_ref);
    if (fi < 0)
      fi = glue_module_func_index_by_name_c(mod, cname, clen);
    if (fi < 0)
      return;

    /* (1) scalar f(c0,c1) -> const */
    if (nargs == 2) {
      if (glue_fold_func_returns_param01_scalar_binop_c(a, mod, fi, &binop_ko) == 0)
        return;
      arg0 = pipeline_expr_call_arg_ref(a, expr_ref, 0);
      arg1 = pipeline_expr_call_arg_ref(a, expr_ref, 1);
      if (arg0 <= 0 || arg1 <= 0)
        return;
      ea0 = glue_arena_expr_at_ref(a, arg0);
      ea1 = glue_arena_expr_at_ref(a, arg1);
      if (!ea0 || !ea1)
        return;
      if (ea0->const_folded_valid)
        av0 = ea0->const_folded_val;
      else if (ea0->kind == ast_ExprKind_EXPR_LIT || ea0->kind == ast_ExprKind_EXPR_BOOL_LIT)
        av0 = (int32_t)ea0->int_val;
      else
        return;
      if (ea1->const_folded_valid)
        av1 = ea1->const_folded_val;
      else if (ea1->kind == ast_ExprKind_EXPR_LIT || ea1->kind == ast_ExprKind_EXPR_BOOL_LIT)
        av1 = (int32_t)ea1->int_val;
      else
        return;
      /* Same domain as glue_const_scalar_binop_eval_i32 (ko 4..8). */
      switch (binop_ko) {
      case 4:
        folded = (int32_t)((int64_t)av0 + (int64_t)av1);
        break;
      case 5:
        folded = (int32_t)((int64_t)av0 - (int64_t)av1);
        break;
      case 6:
        folded = (int32_t)((int64_t)av0 * (int64_t)av1);
        break;
      case 7:
        if (av1 == 0)
          return;
        folded = (int32_t)((int64_t)av0 / (int64_t)av1);
        break;
      case 8:
        if (av1 == 0)
          return;
        folded = (int32_t)((int64_t)av0 % (int64_t)av1);
        break;
      default:
        return;
      }
      e->const_folded_val = folded;
      e->const_folded_valid = 1;
      return;
    }

    /* (2)/(3) 1-arg: pure scalar unary, else laneK(vec_binop(...)) */
    if (nargs == 1) {
      int32_t lane;
      int32_t inner_call_ref;
      int32_t inner_callee_ref;
      int32_t ilen;
      int32_t inner_fi;
      uint8_t iname[128];

      arg0 = pipeline_expr_call_arg_ref(a, expr_ref, 0);
      if (arg0 <= 0)
        return;
      /* (2) pure 1-param scalar (nested g(3) leaf). Prefer before vector lane. */
      {
        int32_t arg_const_ok = 0;
        if (pipeline_expr_const_folded_valid_at(a, arg0) != 0) {
          av0 = pipeline_expr_const_folded_val_at(a, arg0);
          arg_const_ok = 1;
        } else {
          int32_t ako = pipeline_expr_kind_ord_at(a, arg0);
          if (ako == 0 || ako == 2) {
            av0 = (int32_t)pipeline_expr_int_val_at(a, arg0);
            arg_const_ok = 1;
          }
        }
        if (arg_const_ok != 0 &&
            glue_try_eval_pure_param0_scalar_func_c(a, mod, fi, av0, &folded) != 0) {
          e->const_folded_val = folded;
          e->const_folded_valid = 1;
          return;
        }
      }

      /* (3) laneK(vec_binop([const…],[const…])) -> scalar const */
      if (glue_fold_func_returns_param0_index_const_c(a, mod, fi, &lane) == 0)
        return;
      inner_call_ref = arg0;
      if (pipeline_expr_kind_ord_at(a, inner_call_ref) != (int32_t)ast_ExprKind_EXPR_CALL)
        return;
      if (pipeline_expr_call_num_args_at(a, inner_call_ref) != 2)
        return;
      /* Nested CALL already folded above; still ok if not stamped (vector return). */
      inner_callee_ref = pipeline_expr_call_callee_ref_at(a, inner_call_ref);
      if (inner_callee_ref <= 0 || pipeline_expr_kind_ord_at(a, inner_callee_ref) != 3)
        return;
      ilen = pipeline_expr_var_name_len(a, inner_callee_ref);
      if (ilen <= 0 || ilen > 127)
        return;
      pipeline_expr_var_name_into(a, inner_callee_ref, iname);
      /* PLATFORM: SHARED — same overload rule as outer CALL fold above. */
      inner_fi = pipeline_expr_call_resolved_func_index_at(a, inner_call_ref);
      if (inner_fi < 0)
        inner_fi = glue_module_func_index_by_name_c(mod, iname, ilen);
      if (inner_fi < 0)
        return;
      if (glue_fold_func_returns_param01_vector_binop_ctfe_c(a, mod, inner_fi, &binop_ko) == 0)
        return;
      arg0 = pipeline_expr_call_arg_ref(a, inner_call_ref, 0);
      arg1 = pipeline_expr_call_arg_ref(a, inner_call_ref, 1);
      if (arg0 <= 0 || arg1 <= 0)
        return;
      if (glue_try_array_lit_lane_const_i32_c(a, arg0, lane, &av0) == 0)
        return;
      if (glue_try_array_lit_lane_const_i32_c(a, arg1, lane, &av1) == 0)
        return;
      if (binop_ko == 51)
        binop_ko = 4;
      switch (binop_ko) {
      case 4:
        folded = (int32_t)((int64_t)av0 + (int64_t)av1);
        break;
      case 5:
        folded = (int32_t)((int64_t)av0 - (int64_t)av1);
        break;
      case 6:
        folded = (int32_t)((int64_t)av0 * (int64_t)av1);
        break;
      case 7:
        if (av1 == 0)
          return;
        folded = (int32_t)((int64_t)av0 / (int64_t)av1);
        break;
      case 8:
        if (av1 == 0)
          return;
        folded = (int32_t)((int64_t)av0 % (int64_t)av1);
        break;
      default:
        return;
      }
      e->const_folded_val = folded;
      e->const_folded_valid = 1;
      return;
    }
  }

  /**
   * PLATFORM: SHARED — EXPR_MATCH CTFE (C5).
   * Why: Pure-const match expressions (`match const_X { lit => const; ...; _ => const }`)
   *      are common in state machines / config tables; folding them at typeck time lets
   *      emit emit a single mov imm32 instead of a runtime cmp/branch dispatch.
   * Invariant: Only stamps const_folded_valid=1 when (1) subject folds to a constant and
   *            (2) the first matching arm (literal or wildcard) result also folds to a
   *            constant. Enum-variant arms compare variant_index; guarded arms
   *            (would need guard eval) are left unfolded (const_folded_valid stays 0).
   * Asm/Perf: Replaces `mov rbx,subj; cmp;jmp;armN;mov w0,result;done` (~30 bytes)
   *           with `mov w0, #const` (4 bytes); also enables parent binop folds.
   */
  if (kd == ast_ExprKind_EXPR_MATCH) {
    int32_t matched_ref;
    int32_t num_arms;
    int32_t wild_idx;
    int32_t i;
    int32_t cmp_val;
    int32_t arm_result_ref;
    int32_t matched_val;
    struct ast_Expr *em;
    struct ast_Expr *er;

    matched_ref = pipeline_expr_match_matched_ref_at(a, expr_ref);
    if (matched_ref <= 0)
      return;
    typeck_fold_expr_ref_impl(a, matched_ref, const_names, const_values, n_const_names);
    em = glue_arena_expr_at_ref(a, matched_ref);
    if (!em || !em->const_folded_valid)
      return;
    matched_val = em->const_folded_val;

    num_arms = pipeline_expr_match_num_arms_at(a, expr_ref);
    if (num_arms <= 0 || num_arms > 32)
      return;

    /* First-match wins (mirrors ELF emit semantics). Wildcard only fires as fallback. */
    wild_idx = -1;
    for (i = 0; i < num_arms; i++) {
      if (pipeline_expr_match_arm_is_wildcard(a, expr_ref, i) != 0) {
        if (wild_idx < 0)
          wild_idx = i;
        continue;
      }
      if (pipeline_expr_match_arm_is_enum_variant(a, expr_ref, i) != 0)
        cmp_val = pipeline_expr_match_arm_variant_index(a, expr_ref, i);
      else
        cmp_val = pipeline_expr_match_arm_lit_val(a, expr_ref, i);
      if (cmp_val != matched_val)
        continue;
      arm_result_ref = pipeline_expr_match_arm_result_ref(a, expr_ref, i);
      if (arm_result_ref <= 0)
        return;
      typeck_fold_expr_ref_impl(a, arm_result_ref, const_names, const_values, n_const_names);
      er = glue_arena_expr_at_ref(a, arm_result_ref);
      if (er && er->const_folded_valid) {
        e->const_folded_val = er->const_folded_val;
        e->const_folded_valid = 1;
      }
      return;
    }

    /* Wildcard arm fallback (only if no lit/variant arm matched). */
    if (wild_idx >= 0) {
      arm_result_ref = pipeline_expr_match_arm_result_ref(a, expr_ref, wild_idx);
      if (arm_result_ref > 0) {
        typeck_fold_expr_ref_impl(a, arm_result_ref, const_names, const_values, n_const_names);
        er = glue_arena_expr_at_ref(a, arm_result_ref);
        if (er && er->const_folded_valid) {
          e->const_folded_val = er->const_folded_val;
          e->const_folded_valid = 1;
        }
      }
    }
    return;
  }
  /**
   * C5-ternary-if: fold `cond ? then : else` and `if cond { then } else { else }`
   * to the selected branch's constant when cond folds. EXPR_IF and EXPR_TERNARY
   * share the if_cond_ref / if_then_ref / if_else_ref field layout (see
   * ast_pool.c::asm_wpo_collect_edges_from_expr L14836-14844), so one branch
   * covers both kinds.
   *
   * Why: Pure-const ternaries/if-exprs (`const Y = (X==2) ? 100 : 200;` or
   *      `let Y = if (X==2) { 100 } else { 200 };` with X a prior const) are
   *      common in config / lookup tables. Folding them at typeck time lets
   *      emit emit `mov w0, #const` (4 bytes) instead of runtime cmp/branch +
   *      2× value materialization (~24 bytes). Mirrors EXPR_MATCH handler
   *      (subject fold -> branch select -> result fold -> stamp), generalized
   *      to the 2-branch case.
   *
   * Invariant: Only stamps const_folded_valid=1 when (1) cond folds to a
   *            constant and (2) the selected branch (then if cond != 0,
   *            else if cond == 0) also folds to a constant. If cond does
   *            not fold (runtime value) both branches are still recursed
   *            into so nested pure subtrees can fold, but the ternary/if
   *            node itself stays valid=0 (runtime cmp/branch emit path).
   *            Asm-emit branch (cond==0/!=0) is unchanged.
   *
   * Asm/Perf: Replaces `cmp; b.eq else; mov w0, then; b done; else: mov w0,
   *           else; done:` (~24 bytes / 5 instrs) with `mov w0, #const`
   *           (4 bytes / 1 instr). Also unlocks parent binop folds.
   *
   * PLATFORM: SHARED — EXPR_IF / EXPR_TERNARY field layout and accessors
   *           (pipeline_expr_if_cond_ref_at / _then_ref_at / _else_ref_at)
   *           are identical on macOS arm64 and Ubuntu x86_64.
   */
  if (kd == ast_ExprKind_EXPR_TERNARY || kd == ast_ExprKind_EXPR_IF) {
    int32_t cond_ref = pipeline_expr_if_cond_ref_at(a, expr_ref);
    int32_t then_ref = pipeline_expr_if_then_ref_at(a, expr_ref);
    int32_t else_ref = pipeline_expr_if_else_ref_at(a, expr_ref);
    int32_t sel_ref;
    struct ast_Expr *ec;
    struct ast_Expr *es;

    if (cond_ref <= 0)
      return;
    typeck_fold_expr_ref_impl(a, cond_ref, const_names, const_values, n_const_names);
    ec = glue_arena_expr_at_ref(a, cond_ref);
    if (!ec || !ec->const_folded_valid) {
      /* Cond did not fold (runtime). Still recurse into both branches so
       * nested pure subtrees (e.g. `cond ? A+1 : B*2` where A,B are const)
       * can fold their inner binops, even though the ternary itself stays
       * runtime. Mirror the ARRAY_LIT/STRUCT_LIT treatment. */
      if (then_ref > 0)
        typeck_fold_expr_ref_impl(a, then_ref, const_names, const_values, n_const_names);
      if (else_ref > 0)
        typeck_fold_expr_ref_impl(a, else_ref, const_names, const_values, n_const_names);
      return;
    }
    /* Cond folded: pick the live branch. XLANG ternary/if treats any non-zero
     * int as true (mirrors C semantics; bool is i32 0/1 in the IR). */
    sel_ref = (ec->const_folded_val != 0) ? then_ref : else_ref;
    if (sel_ref <= 0)
      return;
    typeck_fold_expr_ref_impl(a, sel_ref, const_names, const_values, n_const_names);
    es = glue_arena_expr_at_ref(a, sel_ref);
    if (es && es->const_folded_valid) {
      e->const_folded_val = es->const_folded_val;
      e->const_folded_valid = 1;
    }
    return;
  }
  /**
   * C5-block: fold a single-stmt EXPR_BLOCK `({ expr })` by folding the
   * block's final expr_stmt and stamping the EXPR_BLOCK node with its
   * folded value. Mirrors the whitelist side-effect scan: only blocks with
   * no const/let/loop/if-stmt/region decls and exactly one expr_stmt are
   * eligible. This is the second half of EXPR_IF support — the if-expr
   * parser wraps each branch as EXPR_BLOCK, so when EXPR_IF picks a branch
   * it recurses into an EXPR_BLOCK child, which must fold through to the
   * inner literal.
   *
   * Why: Without this, `const Y = if (X==2) { 100 } else { 200 };` would
   *      pass the whitelist (EXPR_BLOCK accepted) but the EXPR_IF fold
   *      would recurse into the EXPR_BLOCK branch and find const_folded_valid=0
   *      (no handler stamped it), so the EXPR_IF wouldn't propagate the
   *      value upward. This handler closes the loop.
   *
   * Invariant: Same strict side-effect scan as whitelist. If the block has
   *            any side-effecting stmts, return without stamping (the
   *            EXPR_BLOCK stays runtime). The final expr is folded
   *            unconditionally so nested pure subtrees still get CTFE.
   *
   * Asm/Perf: Stamps const_folded_val on the EXPR_BLOCK so the parent
   *           EXPR_IF handler can propagate it to the const decl. Final
   *           emit then produces `mov w0, #const` (4 bytes / 1 instr).
   *
   * PLATFORM: SHARED — Mirrors whitelist case in glue_is_const_expr_ref
   *           above. ast_ast_block_final_expr_ref returns Block.final_expr_ref
   *           directly (verified at pipeline_glue.c L23405-23411).
   */
  if (kd == ast_ExprKind_EXPR_BLOCK) {
    int32_t block_ref = pipeline_expr_block_ref_at(a, expr_ref);
    int32_t final_expr_ref;
    int32_t n_es;
    struct ast_Expr *ef;
    if (block_ref <= 0)
      return;
    if (ast_ast_block_num_consts(a, block_ref) > 0)
      return;
    if (ast_ast_block_num_lets(a, block_ref) > 0)
      return;
    if (ast_ast_block_num_loops(a, block_ref) > 0)
      return;
    if (ast_ast_block_num_for_loops(a, block_ref) > 0)
      return;
    if (ast_ast_block_num_if_stmts(a, block_ref) > 0)
      return;
    if (ast_ast_block_num_regions(a, block_ref) > 0)
      return;
    /* Parser normalizes `{ expr }` (final_expr_ref set, num_expr_stmts=0)
     * into `expr_stmts[0] = expr; final_expr_ref = 0`. Accept either form. */
    n_es = ast_ast_block_num_expr_stmts(a, block_ref);
    final_expr_ref = ast_ast_block_final_expr_ref(a, block_ref);
    if (final_expr_ref <= 0) {
      if (n_es != 1)
        return;
      final_expr_ref = ast_pipeline_block_expr_stmt_ref(a, block_ref, 0);
    } else if (n_es != 0) {
      return;
    }
    if (final_expr_ref <= 0)
      return;
    typeck_fold_expr_ref_impl(a, final_expr_ref, const_names, const_values, n_const_names);
    ef = glue_arena_expr_at_ref(a, final_expr_ref);
    if (ef && ef->const_folded_valid) {
      e->const_folded_val = ef->const_folded_val;
      e->const_folded_valid = 1;
    }
    return;
  }
}

/** Pure-lit / already-folded tree CTFE after typeck (no block const env). */
void typeck_fold_expr(struct ast_ASTArena *arena, int32_t expr_ref) {
  if (!arena || expr_ref <= 0)
    return;
  if (!typeck_is_const_expr_ref_impl(arena, expr_ref, NULL, 0)) {
    /* Still recurse so nested pure subtrees can fold. */
    struct ast_Expr *e = glue_arena_expr_at_ref(arena, expr_ref);
    if (!e)
      return;
    if (e->kind >= ast_ExprKind_EXPR_ADD && e->kind <= ast_ExprKind_EXPR_LOGOR) {
      typeck_fold_expr_ref_impl(arena, e->binop_left_ref, NULL, NULL, 0);
      typeck_fold_expr_ref_impl(arena, e->binop_right_ref, NULL, NULL, 0);
      typeck_fold_expr_ref_impl(arena, expr_ref, NULL, NULL, 0);
    } else if (e->kind == ast_ExprKind_EXPR_NEG || e->kind == ast_ExprKind_EXPR_BITNOT ||
               e->kind == ast_ExprKind_EXPR_LOGNOT) {
      typeck_fold_expr_ref_impl(arena, e->unary_operand_ref, NULL, NULL, 0);
      typeck_fold_expr_ref_impl(arena, expr_ref, NULL, NULL, 0);
    } else if (e->kind == ast_ExprKind_EXPR_LIT || e->kind == ast_ExprKind_EXPR_BOOL_LIT ||
               e->kind == ast_ExprKind_EXPR_FLOAT_LIT) {
      typeck_fold_expr_ref_impl(arena, expr_ref, NULL, NULL, 0);
    } else if (e->kind == ast_ExprKind_EXPR_CALL) {
      /* Call itself is not a pure const-expr tree; still try WPO call-site CTFE. */
      typeck_fold_expr_ref_impl(arena, expr_ref, NULL, NULL, 0);
    } else if (e->kind == ast_ExprKind_EXPR_MATCH) {
      /* PLATFORM: SHARED — Match is not a pure const-expr (subject may be runtime).
       * Still attempt CTFE: if the subject folds to a constant (e.g. `match 2 { ... }`
       * or `match const_X { ... }` outside a block-const env), the handler inside
       * glue_typeck_fold_expr_ref picks the matching arm and stamps the result. */
      typeck_fold_expr_ref_impl(arena, expr_ref, NULL, NULL, 0);
    } else if (e->kind == ast_ExprKind_EXPR_STRUCT_LIT) {
      /* PLATFORM: SHARED — Struct lit is not a pure const-expr (struct cannot
       * fit in i32 const_folded_val). Still recurse into each field init so
       * inner binop/unary/lit trees fold; struct node itself stays valid=0.
       * Mirrors EXPR_ARRAY_LIT treatment in pipeline_typeck_fold_expr_c. */
      typeck_fold_expr_ref_impl(arena, expr_ref, NULL, NULL, 0);
    } else if (e->kind == ast_ExprKind_EXPR_TERNARY || e->kind == ast_ExprKind_EXPR_IF) {
      /* PLATFORM: SHARED — Ternary `cond ? a : b` and if-expression
       * `if cond { a } else { b }` are not pure const-expr trees (cond may
       * be runtime). Still attempt CTFE: if cond folds to a constant
       * (e.g. `let Y = (X==2) ? 100 : 200;` with X a prior const outside a
       * block-const env), the handler inside glue_typeck_fold_expr_ref
       * picks the live branch and stamps the result. Mirrors EXPR_MATCH
       * treatment above. */
      typeck_fold_expr_ref_impl(arena, expr_ref, NULL, NULL, 0);
    } else if (e->kind == ast_ExprKind_EXPR_BLOCK) {
      /* PLATFORM: SHARED — Block expression `({ stmt; expr })` is not a pure
       * const-expr tree when stmt has side effects. Still attempt CTFE on
       * the final expr so single-stmt blocks (e.g. if-expression branches
       * `{ 100 }` produced by parser_asm_wrap_block_ref_as_expr_c) fold
       * when the final expr folds. Mirrors EXPR_MATCH / EXPR_TERNARY /
       * EXPR_IF treatment: attempt fold with NULL const env; the handler
       * inside glue_typeck_fold_expr_ref will skip if side-effect scan
       * fails. */
      typeck_fold_expr_ref_impl(arena, expr_ref, NULL, NULL, 0);
    }
    return;
  }
  typeck_fold_expr_ref_impl(arena, expr_ref, NULL, NULL, 0);
}

/**
 * Build prior-const name/value env for block consts [0, const_idx), then fold
 * the const_idx init (or fold expr_ref when const_idx < 0 using all consts).
 */
static void typeck_block_const_env_build_impl(struct ast_ASTArena *arena, int32_t block_ref, int max_const,
                                             const char *names[64], char name_bufs[64][128],
                                             int64_t values[64], int *out_n) {
  int n = 0;
  int i;
  *out_n = 0;
  if (!arena || max_const <= 0)
    return;
  for (i = 0; i < max_const && n < 64; i++) {
    int32_t nlen = pipeline_block_const_name_len(arena, block_ref, i);
    int32_t init_ref = pipeline_block_const_init_ref(arena, block_ref, i);
    if (nlen <= 0 || nlen >= 64)
      continue;
    pipeline_block_const_name_copy64(arena, block_ref, i, (uint8_t *)name_bufs[n]);
    name_bufs[n][nlen] = '\0';
    names[n] = name_bufs[n];
    values[n] = 0;
    if (init_ref > 0) {
      typeck_fold_expr_ref_impl(arena, init_ref, names, values, n);
      {
        struct ast_Expr *ie = glue_arena_expr_at_ref(arena, init_ref);
        if (ie && ie->const_folded_valid)
          values[n] = (int64_t)ie->const_folded_val;
      }
    }
    n++;
  }
  *out_n = n;
}

/** Fold block const init at const_idx with prior consts in scope. */
void typeck_fold_block_const_init(struct ast_ASTArena *arena, int32_t block_ref,
                                            int32_t const_idx) {
  const char *names[64];
  char name_bufs[64][128];
  int64_t values[64];
  int n = 0;
  int32_t init_ref;
  int32_t type_ref;
  struct ast_Expr *ie;

  if (!arena || const_idx < 0)
    return;
  typeck_block_const_env_build_impl(arena, block_ref, const_idx, names, name_bufs, values, &n);
  init_ref = pipeline_block_const_init_ref(arena, block_ref, const_idx);
  if (init_ref <= 0)
    return;
  typeck_fold_expr_ref_impl(arena, init_ref, names, values, n);
  ie = glue_arena_expr_at_ref(arena, init_ref);
  if (!ie || ie->const_folded_valid)
    return;
  /**
   * C5-array-len: `const N: i32 = [1,2,3,4]` — array lit init with scalar const
   * type folds to element count (LANG-006). Stamp resolved_type to const type
   * so emit/codegen can treat the init as a scalar imm.
   */
  type_ref = pipeline_block_const_type_ref(arena, block_ref, const_idx);
  if (type_ref > 0 && ie->kind == ast_ExprKind_EXPR_ARRAY_LIT) {
    int32_t tk = pipeline_type_kind_ord_at(arena, type_ref);
    if (tk >= 0 && tk <= 7) {
      ie->resolved_type_ref = type_ref;
      ie->const_folded_val = (int32_t)ie->array_lit_num_elems;
      ie->const_folded_valid = 1;
    }
  }
}

/** Fold expr with all block consts as env (let init / return of const names). */
void typeck_fold_expr_in_block(struct ast_ASTArena *arena, int32_t block_ref,
                                         int32_t expr_ref) {
  const char *names[64];
  char name_bufs[64][128];
  int64_t values[64];
  int n = 0;
  int nconst;

  if (!arena || expr_ref <= 0 || block_ref <= 0)
    return;
  nconst = ast_ast_block_num_consts(arena, block_ref);
  typeck_block_const_env_build_impl(arena, block_ref, nconst, names, name_bufs, values, &n);
  typeck_fold_expr_ref_impl(arena, expr_ref, names, values, n);
}


