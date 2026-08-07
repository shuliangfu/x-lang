/**
 * pipeline_typeck_region_assign.c — typeck region/escape assign-site domain (BC 8.3.1).
 *
 * wave235 G.7 pure leave: M-3 slice region assign + return operand path dual
 * bodies retired → typeck.x (typeck_check_slice_region_assign /
 * typeck_check_return_slice_region + private escape/conflict helpers).
 *
 * wave236 G.7 pure leave: WPO-S3 stack-escape assign + MEM-A3 scope-borrow
 * assign/return → typeck.x (typeck_check_struct_stack_escape_assign /
 * typeck_check_scope_borrow_assign / typeck_check_scope_borrow_return +
 * private helpers). Cap residual keeps thin *_c faces for scan/mega.
 *
 * wave237 G.7 pure leave: MEM-C1 allocator region assign/return → typeck.x
 * (typeck_check_allocator_region_assign / typeck_check_allocator_region_return).
 *
 * wave239 G.7 pure leave: M-3 call_slice_region + MOD-02 *Struct compat →
 * typeck.x (typeck_check_call_slice_region + private typeck_check_call_ptr_struct_compat).
 * Cap residual keeps thin pipeline_typeck_check_call_slice_region_c only.
 *
 * wave240 G.7 pure leave: MEM-C1 with_arena nest BSS + push/pop/reset →
 * typeck.x (pipeline_typeck_with_arena_scope_*). Cap residual only
 * calls pure faces from scan tree + check_block_one_region.
 *
 * wave241 G.7 pure leave: M-3 region-label scope BSS + push/pop/len/reset →
 * typeck.x (pipeline_dep_ctx_scope_region_* + pipeline_typeck_region_scope_reset_c).
 * Cap residual only calls pure faces; no second BSS cell.
 *
 * wave242 G.7 pure leave: WPO-S3 post-scan tree (scan_expr / scan_block /
 * pipeline_typeck_scan_module_struct_stack_escape_c) → typeck.x.
 * Cap residual deletes static scan bodies (dual-export ban); pure calls pure
 * pipeline_typeck_check_call_struct_stack_escape_c (wave244; dual-export ban).
 *
 * wave243 G.7 pure leave: M-5 read_ptr slice + M-3 stamp_let → typeck.x
 * (pipeline_typeck_is_read_ptr_slice_callee_c /
 *  pipeline_typeck_read_ptr_slice_return_ref_c /
 *  pipeline_type_stamp_block_let_region_c). Cap residual deletes second bodies.
 *
 * wave244 G.7 pure leave: M-3 check_block_one_region + WPO-S3
 * call_struct_stack_escape → typeck.x (pipeline_typeck_check_block_one_region_c /
 * pipeline_typeck_check_call_struct_stack_escape_c). Cap residual deletes second
 * bodies; pure var_is_block_local gains residual-fidelity block-tree walk.
 *
 * Still residual (not pure-leaved this wave):
 * - stack_local ptr stamp helpers + ptr_for_addr_of
 * - block tree store-scan helpers (param field; DCE candidate)
 *
 * G.7 dual-export ban: do NOT re-open second bodies for pure-leaved faces;
 * typeck.x is single authority for those checks.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c.
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/* Live M-3 / WPO-S3 / MEM-A3 authority in typeck_x.o (typeck.x exports). */
extern int32_t typeck_check_slice_region_assign(struct ast_ASTArena *arena, int32_t site_expr_ref,
                                                int32_t expect_ref, int32_t src_ref);
extern int32_t typeck_check_return_slice_region(struct ast_ASTArena *arena, int32_t ret_site_ref,
                                                int32_t op_ref, int32_t func_return_ref);
extern int32_t typeck_check_struct_stack_escape_assign(struct ast_Module *module, struct ast_ASTArena *arena,
                                                       int32_t site_expr_ref, int32_t left_ref, int32_t right_ref,
                                                       struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_scope_borrow_assign(struct ast_Module *module, struct ast_ASTArena *arena,
                                                int32_t site_expr_ref, int32_t left_ref, int32_t right_ref,
                                                struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_scope_borrow_return(struct ast_Module *module, struct ast_ASTArena *arena,
                                                int32_t site_expr_ref, int32_t op_ref, int32_t return_type_ref,
                                                struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_allocator_region_assign(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t site_expr_ref, int32_t left_ref,
                                                    struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_allocator_region_return(struct ast_ASTArena *arena, int32_t site_expr_ref,
                                                    int32_t return_type_ref);
extern int32_t typeck_check_call_slice_region(struct ast_Module *module, struct ast_ASTArena *arena,
                                              int32_t call_expr_ref, struct ast_PipelineDepCtx *ctx);

/* wave1125-1129 G.7: forward decl — definition at EOF (callsites at L122/238/279
 * precede the EOF definition). */
/* wave156 pure-owned: assign-like kind face lives in runtime_pipeline_abi pure. */
int32_t glue_expr_kind_is_assign_like_ord(int32_t ko);

static int32_t typeck_expr_is_addr_of_block_local_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                   struct ast_PipelineDepCtx *ctx, int32_t expr_ref);

/* wave1133-1135 G.7: forward decl — definition at EOF (callsite at L141 in
 * pipeline_typeck_check_struct_stack_escape_assign_c precedes the EOF
 * definition). */
static int32_t typeck_lval_is_param_ptr_field_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t func_ix,
                                                int32_t left_ref, int32_t dst_pi);

/**
 * M-3：.x typeck 统一 slice 域 assign/let/实参检查.
 * wave235 pure leave: thin → typeck_check_slice_region_assign.
 * site_expr_ref 用于 line/col；返回 0 可接受，-1 已打印 typeck error。
 * PLATFORM: SHARED — Cap residual face only.
 */
static void pipeline_typeck_expr_diag_line_col_c(struct ast_ASTArena *a, int32_t expr_ref, int32_t *line,
                                                 int32_t *col);

int32_t pipeline_typeck_check_slice_region_assign_c(struct ast_ASTArena *arena, int32_t site_expr_ref,
                                                    int32_t expect_ref, int32_t src_ref) {
  return typeck_check_slice_region_assign(arena, site_expr_ref, expect_ref, src_ref);
}

/**
 * WPO-S3：assign 路径 — 禁止将局部 struct 指针写入形参 *T 的字段（外层槽逃逸）。
 * wave236 pure leave: thin → typeck_check_struct_stack_escape_assign.
 * PLATFORM: SHARED — Cap residual face only.
 */
int32_t pipeline_typeck_check_struct_stack_escape_assign_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                           int32_t site_expr_ref, int32_t left_ref, int32_t right_ref,
                                                           struct ast_PipelineDepCtx *ctx) {
  return typeck_check_struct_stack_escape_assign(module, arena, site_expr_ref, left_ref, right_ref, ctx);
}

/** MEM-A3：typeck 诊断 line/col（assign 等 site expr line=0 时回退子树）。 */
static void pipeline_typeck_expr_diag_line_col_c(struct ast_ASTArena *a, int32_t expr_ref, int32_t *line,
                                                 int32_t *col) {
  int32_t k;
  if (!a || expr_ref <= 0 || !line || !col) {
    if (line)
      *line = 0;
    if (col)
      *col = 0;
    return;
  }
  *line = pipeline_expr_line_at(a, expr_ref);
  *col = pipeline_expr_col_at(a, expr_ref);
  if (*line > 0)
    return;
  k = pipeline_expr_kind_ord_at(a, expr_ref);
  if (glue_expr_kind_is_assign_like_ord(k)) {
    pipeline_typeck_expr_diag_line_col_c(a, pipeline_expr_binop_left_ref_at(a, expr_ref), line, col);
    if (*line > 0)
      return;
    pipeline_typeck_expr_diag_line_col_c(a, pipeline_expr_binop_right_ref_at(a, expr_ref), line, col);
    return;
  }
  if (k == (int32_t)ast_ExprKind_EXPR_ADDR_OF || k == (int32_t)ast_ExprKind_EXPR_RETURN ||
      k == (int32_t)ast_ExprKind_EXPR_NEG || k == (int32_t)ast_ExprKind_EXPR_LOGNOT)
    pipeline_typeck_expr_diag_line_col_c(a, pipeline_expr_unary_operand_ref_at(a, expr_ref), line, col);
}

/**
 * MEM-A3：assign — 禁止内层块局部地址写入外层块变量（scope borrow 逃逸）。
 * wave236 pure leave: thin → typeck_check_scope_borrow_assign.
 * PLATFORM: SHARED — Cap residual face only.
 */
int32_t pipeline_typeck_check_scope_borrow_assign_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  int32_t site_expr_ref, int32_t left_ref, int32_t right_ref,
                                                  struct ast_PipelineDepCtx *ctx) {
  return typeck_check_scope_borrow_assign(module, arena, site_expr_ref, left_ref, right_ref, ctx);
}

/**
 * MEM-A3：return — 禁止返回块内局部变量地址（指针逃出函数/块生命周期）。
 * wave236 pure leave: thin → typeck_check_scope_borrow_return.
 * PLATFORM: SHARED — Cap residual face only.
 */
int32_t pipeline_typeck_check_scope_borrow_return_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t site_expr_ref, int32_t op_ref, int32_t return_type_ref,
                                                    struct ast_PipelineDepCtx *ctx) {
  return typeck_check_scope_borrow_return(module, arena, site_expr_ref, op_ref, return_type_ref, ctx);
}

/*
 * wave240 G.7 pure leave: with_arena nest BSS + push/pop/reset live in
 * typeck.x / typeck_gen (pipeline_typeck_with_arena_scope_* → typeck_x.o).
 * Cap residual only calls pure faces — dual-export ban (no second BSS cell).
 * PLATFORM: SHARED — freestanding typeck_x provides the symbols.
 */
extern int32_t pipeline_typeck_with_arena_scope_n_at(void);
extern int32_t pipeline_typeck_with_arena_current_body_ref_c(void);
extern void pipeline_typeck_with_arena_scope_push_c(int32_t body_ref);
extern void pipeline_typeck_with_arena_scope_pop_c(void);
extern void pipeline_typeck_with_arena_scope_reset_c(void);

/*
 * wave241 G.7 pure leave: region-label scope BSS + push/pop/len/reset live in
 * typeck.x / typeck_gen (pipeline_dep_ctx_scope_region_* → typeck_x.o).
 * Cap residual only calls pure faces — dual-export ban (no second BSS cell).
 */
extern int32_t pipeline_dep_ctx_scope_region_push_c(struct ast_PipelineDepCtx *ctx, uint8_t *label,
                                                    int32_t label_len);
extern void pipeline_dep_ctx_scope_region_pop_c(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_scope_region_len_at(struct ast_PipelineDepCtx *ctx);
extern void pipeline_typeck_region_scope_reset_c(void);

/** M-3 AL-06：return slice 域检查（定义见下）。 */
int32_t pipeline_typeck_check_return_slice_region_c(struct ast_ASTArena *arena, int32_t ret_site_ref,
                                                    int32_t op_ref, int32_t func_return_ref);

/**
 * MEM-C1 AL-04：with_arena 内 assign — 禁止 arena 域值写入块外变量（allocator region 逃逸）。
 * wave237 pure leave: thin → typeck_check_allocator_region_assign.
 * PLATFORM: SHARED — Cap residual face only.
 */
int32_t pipeline_typeck_check_allocator_region_assign_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                      int32_t site_expr_ref, int32_t left_ref,
                                                      struct ast_PipelineDepCtx *ctx) {
  return typeck_check_allocator_region_assign(module, arena, site_expr_ref, left_ref, ctx);
}

/**
 * MEM-C1 AL-04：with_arena 内 return Allocator — 禁止 allocator 域逃出 with_arena 块。
 * wave237 pure leave: thin → typeck_check_allocator_region_return.
 * PLATFORM: SHARED — Cap residual face only.
 */
int32_t pipeline_typeck_check_allocator_region_return_c(struct ast_ASTArena *arena, int32_t site_expr_ref,
                                                        int32_t return_type_ref) {
  return typeck_check_allocator_region_return(arena, site_expr_ref, return_type_ref);
}

/**
 * M-3 AL-06：region 内 return 未标注域 slice — 禁止 slice 域逃出 region
 *（scan + typeck.x 共用；不依赖 operand 已 stamp，只要在 scope 内 return 未标注 T[]）。
 */
int32_t pipeline_typeck_check_return_slice_region_in_scope_c(struct ast_ASTArena *arena, int32_t site_expr_ref,
                                                            int32_t return_type_ref,
                                                            struct ast_PipelineDepCtx *ctx) {
  int32_t line;
  int32_t col;
  int32_t rlen;
  if (!arena || !ctx || site_expr_ref <= 0 || return_type_ref <= 0)
    return 0;
  if (pipeline_dep_ctx_scope_region_len_at(ctx) <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, return_type_ref) != (int32_t)ast_TypeKind_TYPE_SLICE)
    return 0;
  if (pipeline_type_region_label_len_at(arena, return_type_ref) > 0)
    return 0;
  pipeline_typeck_expr_diag_line_col_c(arena, site_expr_ref, &line, &col);
  rlen = pipeline_dep_ctx_scope_region_len_at(ctx);
  lsp_diag_report_typeck((int)line, (int)col,
                         "slice region escape: cannot return <%.*s> slice as unbound T[]", (int)rlen,
                         (const char *)ctx->typeck_scope_region_label);
  return -1;
}

/**
 * M-3：.x typeck return 路径 slice 域逃逸 / 不一致；ret_site_ref 用于 line/col。
 * wave235 pure leave: thin → typeck_check_return_slice_region.
 * PLATFORM: SHARED — Cap residual face only.
 */
int32_t pipeline_typeck_check_return_slice_region_c(struct ast_ASTArena *arena, int32_t ret_site_ref,
                                                    int32_t op_ref, int32_t func_return_ref) {
  return typeck_check_return_slice_region(arena, ret_site_ref, op_ref, func_return_ref);
}

/* ─────────────────────────────────────────────────────────────────────────── */
/* wave1125-1129 G.7: WPO-S3 stack-escape analysis helpers (5 fns + 1 const)
 * migrated from pipeline_glue.c L9947-10081. These form the stack-escape
 * local-var detection cluster — natural co-located with the WPO-S3 struct
 * stack-escape assign domain already in region_assign.c. Static (non-extern):
 * same-TU visibility via #include order — region_assign.c #include at
 * glue.c L10231. Glue.c L10223/10227 callsites (inside
 * pipeline_typeck_ptr_for_addr_of_operand_c) precede the #include, so 2
 * static fwd decls are kept in glue.c. The region_assign.c L122/238/279
 * callsites precede these EOF definitions, so a static fwd decl is added
 * at the top of this file. PLATFORM: SHARED. */

/* Forward decl at top of file (L34) covers L122/238/279 callsites. */

/** WPO-S3: *T stack-local region label (shares Type slot with slice
 * region_label; TYPE_PTR only). Migrated from glue.c (wave1125-1129). */
static const uint8_t TYPECK_STACK_LOCAL_PTR_LBL[] = "stack_local";

/**
 * WPO-S3: find or allocate a *elem_ref with the stack_local region label.
 *
 * Why: when &local_struct is taken, the resulting pointer type must carry
 * the stack_local label so that downstream escape analysis can distinguish
 * it from heap/param pointers. The label is stamped into the Type's
 * region_label field (shared with slice region labels).
 *
 * Contract: returns 0 on failure (invalid arena/elem_ref or alloc fails).
 * Returns an existing matching type_ref if found, or a newly allocated one.
 *
 * PLATFORM: SHARED — pure type_ref allocation, no arch dependency.
 */
static int32_t typeck_find_or_alloc_ptr_stack_local_c(struct ast_ASTArena *a, int32_t elem_ref) {
  int32_t k;
  struct ast_Type *t;
  static const int32_t lbl_len = 11;
  if (!a || elem_ref <= 0)
    return 0;
  for (k = 1; k <= a->num_types; k++) {
    t = pipeline_arena_type_ptr(a, k);
    if (t && t->kind == ast_TypeKind_TYPE_PTR && t->elem_type_ref == elem_ref && t->name_len == 0 &&
        t->region_label_len == lbl_len &&
        memcmp(t->region_label, TYPECK_STACK_LOCAL_PTR_LBL, (size_t)lbl_len) == 0)
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  memset(t, 0, sizeof(*t));
  t->kind = ast_TypeKind_TYPE_PTR;
  t->elem_type_ref = elem_ref;
  memcpy(t->region_label, TYPECK_STACK_LOCAL_PTR_LBL, (size_t)lbl_len);
  t->region_label_len = lbl_len;
  return k;
}

/**
 * WPO-S3: return 1 if ty_ref is a TYPE_PTR with the stack_local region
 * label (marks a pointer to a block-local struct).
 *
 * Why: escape analysis checks this label to detect when a stack-local
 * pointer escapes via call args or return values.
 *
 * Contract: returns 0 for invalid refs, non-PTR types, or PTR types
 * without the stack_local label.
 *
 * PLATFORM: SHARED — pure label check, no arch dependency.
 */
static int32_t typeck_ptr_has_stack_local_label_c(struct ast_ASTArena *a, int32_t ty_ref) {
  struct ast_Type *t;
  static const int32_t lbl_len = 11;
  if (!a || ty_ref <= 0 || ty_ref > a->num_types)
    return 0;
  t = pipeline_arena_type_ptr(a, ty_ref);
  if (!t || t->kind != ast_TypeKind_TYPE_PTR)
    return 0;
  return (t->region_label_len == lbl_len &&
          memcmp(t->region_label, TYPECK_STACK_LOCAL_PTR_LBL, (size_t)lbl_len) == 0)
             ? 1
             : 0;
}

/**
 * WPO-S3: return 1 if a let/const named `vname` exists anywhere in the
 * block subtree (including while/for/if-then/if-else/region bodies).
 *
 * Why: escape analysis needs to know whether a VAR is a block-local
 * let/const (vs a function parameter). This walker searches the entire
 * block tree because the current_block_ref in ctx may not be pushed
 * during post-scan paths.
 *
 * Contract: returns 0 for invalid arena/block_ref/vname. Self-recursive
 * on if-then/else and loop/region bodies. Depth is bounded by the
 * block tree structure (no cycles expected).
 *
 * PLATFORM: SHARED — pure block-tree walk, no arch dependency.
 */
static int32_t typeck_block_tree_has_var_c(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname,
                                           int32_t vlen) {
  int32_t nso;
  int32_t i;
  if (!a || block_ref <= 0 || !vname || vlen <= 0)
    return 0;
  if (pipeline_block_resolve_var_type_ref(a, block_ref, vname, vlen) > 0)
    return 1;
  nso = ast_ast_block_num_stmt_order(a, block_ref);
  for (i = 0; i < nso; i++) {
    uint8_t sk = ast_ast_block_stmt_order_kind(a, block_ref, i);
    int32_t idx = ast_ast_block_stmt_order_idx(a, block_ref, i);
    int32_t br = 0;
    if (sk == 3 && idx >= 0 && idx < ast_ast_block_num_loops(a, block_ref))
      br = ast_ast_block_while_body_ref(a, block_ref, idx);
    else if (sk == 4 && idx >= 0 && idx < ast_ast_block_num_for_loops(a, block_ref))
      br = ast_ast_block_for_body_ref(a, block_ref, idx);
    else if (sk == 5 && idx >= 0 && idx < ast_ast_block_num_if_stmts(a, block_ref)) {
      int32_t tr = ast_ast_block_if_then_body_ref(a, block_ref, idx);
      int32_t er = ast_ast_block_if_else_body_ref(a, block_ref, idx);
      if (tr > 0 && typeck_block_tree_has_var_c(a, tr, vname, vlen))
        return 1;
      if (er > 0 && typeck_block_tree_has_var_c(a, er, vname, vlen))
        return 1;
      continue;
    } else if (sk == 6 && idx >= 0 && idx < ast_ast_block_num_regions(a, block_ref))
      br = ast_ast_block_region_body_ref(a, block_ref, idx);
    if (br > 0 && typeck_block_tree_has_var_c(a, br, vname, vlen))
      return 1;
  }
  return 0;
}

/**
 * WPO-S3: return 1 if expr_ref is a VAR that is a block-local let/const
 * (not a function parameter).
 *
 * Why: escape analysis needs to distinguish local lets from params.
 * Checks the current block first (fast path), then falls back to a
 * full function-body block-tree walk for post-scan paths where ctx
 * may not have current_block_ref pushed.
 *
 * Contract: returns 0 for invalid refs, non-VAR exprs, or VARs that
 * match a function parameter name.
 *
 * PLATFORM: SHARED — pure block-tree walk, no arch dependency.
 */
static int32_t typeck_var_is_block_local_c(struct ast_Module *m, struct ast_ASTArena *a,
                                           struct ast_PipelineDepCtx *ctx, int32_t expr_ref) {
  int32_t vlen;
  uint8_t vbuf[128];
  int32_t func_ix;
  int32_t body_ref;
  if (!m || !a || !ctx || expr_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(a, expr_ref) != GLUE_EXPR_KIND_VAR)
    return 0;
  vlen = pipeline_expr_var_name_len(a, expr_ref);
  if (vlen <= 0 || vlen > 127)
    return 0;
  pipeline_expr_var_name_into(a, expr_ref, vbuf);
  func_ix = ctx->current_func_index;
  if (func_ix >= 0 && pipeline_module_func_param_type_ref_for_name(m, func_ix, vbuf, vlen) > 0)
    return 0;
  if (ctx->current_block_ref > 0 &&
      pipeline_block_resolve_var_type_ref(a, ctx->current_block_ref, vbuf, vlen) > 0)
    return 1;
  /* post-scan paths may not have ctx block pushed: fall back to
   * function-body root block and its children for let lookup. */
  if (func_ix >= 0) {
    body_ref = pipeline_module_func_body_ref_at(m, func_ix);
    if (body_ref > 0 && typeck_block_tree_has_var_c(a, body_ref, vbuf, vlen))
      return 1;
  }
  return 0;
}

/**
 * WPO-S3: return 1 if expr_ref is an address-of a block-local variable
 * (i.e. &local_let) or already carries a stack_local pointer label.
 *
 * Why: call escape detection checks this to flag when a stack-local
 * pointer is passed as a call arg or returned. The check covers both
 * direct &local and pointers already stamped with stack_local label
 * (e.g. from a prior &local propagation).
 *
 * Contract: returns 0 for invalid refs or non-address-of exprs whose
 * resolved type is not a stack_local PTR. Returns 1 if the operand of
 * an ADDR_OF is a block-local VAR.
 *
 * PLATFORM: SHARED — pure analysis, no arch dependency.
 */
static int32_t typeck_expr_is_addr_of_block_local_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                   struct ast_PipelineDepCtx *ctx, int32_t expr_ref) {
  int32_t op_ref;
  if (!m || !a || !ctx || expr_ref <= 0)
    return 0;
  if (typeck_ptr_has_stack_local_label_c(a, pipeline_expr_resolved_type_ref(a, expr_ref)))
    return 1;
  if (pipeline_expr_kind_ord_at(a, expr_ref) != (int32_t)ast_ExprKind_EXPR_ADDR_OF)
    return 0;
  op_ref = pipeline_expr_unary_operand_ref_at(a, expr_ref);
  return op_ref > 0 && typeck_var_is_block_local_c(m, a, ctx, op_ref) ? 1 : 0;
}

/* ============================================================
 * wave1133-1135 G.7: lval param ptr field cluster (migrated from
 * glue.c L9912-10042).
 *
 * Why here: this cluster answers "does an lvalue denote a field of a
 * *T function param (or chain slot.x.ptr rooted at a *T param)" — the
 * same WPO-S3 stack-escape assign-site question that
 * pipeline_typeck_check_struct_stack_escape_assign_c (L121 above) asks.
 * Colocating with the existing stack-escape helpers (wave1125-1129)
 * keeps the whole WPO-S3 assign / call escape analysis path in one
 * domain file.
 *
 * Cluster members:
 *   wave1133 — typeck_lval_is_param_ptr_field_c (base case: is left a
 *              FIELD_ACCESS whose base is the dst_pi *T param, or a
 *              chain slot.x.ptr rooted at any *T param matching dst_pi?)
 *   wave1134 — typeck_block_expr_stmts_store_scan_c (scan block
 *              expr_stmts for `param[dst].field = param[src]`)
 *            + typeck_block_final_expr_store_scan_c (scan final_expr)
 *            + typeck_block_stores_param_into_param_field_c (recursive
 *              block scan walking stmt_order / nested while/for/region)
 *   wave1135 — typeck_func_stores_param_into_param_field_c (func-level
 *              entry: body_ref scan combining expr_stmts + final +
 *              recursive block walk).
 *
 * Invariant: definitions placed at EOF AFTER all callsites in this file.
 * Forward decl at file top (L34 area) keeps L141 callsite visible.
 * Same-TU visibility: any subsequent caller in pipeline_glue.c sees
 * these via the #include of this leaf at glue.c L10059.
 *
 * Note: as of wave1135 migration, typeck_func_stores_param_into_param_field_c
 * has no in-tree caller (the call_struct_stack_escape path at glue.c
 * L10066+ does its own arg-pair scan instead). Kept cohesive with the
 * cluster for future WPO-S3 call-site reuse; candidate for DCE if no
 * caller appears.
 *
 * PLATFORM: SHARED — pure typeck analysis; no platform ABI dependency.
 * ============================================================ */

/* wave1133-1135 G.7: forward decl — recursive helper body below. */
static int32_t typeck_block_stores_param_into_param_field_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                            int32_t block_ref, int32_t func_ix, int32_t dst_pi,
                                                            int32_t src_pi);

/**
 * WPO-S3: left is a FIELD_ACCESS writing into a field of the dst_pi
 * formal param (which must be *T). Also handles field chains like
 * slot.x.ptr where the chain root is any *T param matching dst_pi.
 *
 * Contract:
 *   - m / a non-NULL; left_ref > 0; func_ix >= 0; dst_pi >= 0.
 *   - Returns 1 if left is FIELD_ACCESS whose base is the dst_pi *T
 *     param (or chain root matches dst_pi); 0 otherwise.
 *
 * PLATFORM: SHARED — pure AST walk; no platform ABI dependency.
 */
static int32_t typeck_lval_is_param_ptr_field_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t func_ix,
                                                int32_t left_ref, int32_t dst_pi) {
  int32_t base_ref;
  int32_t param_ty;
  int32_t np;
  int32_t pi;
  if (!m || !a || left_ref <= 0 || func_ix < 0 || dst_pi < 0)
    return 0;
  if (pipeline_expr_kind_ord_at(a, left_ref) != (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS)
    return 0;
  base_ref = pipeline_expr_field_access_base_ref(a, left_ref);
  if (glue_expr_is_func_param_at_c(a, m, func_ix, base_ref, dst_pi)) {
    param_ty = pipeline_module_func_param_type_ref_at(m, func_ix, dst_pi);
    return param_ty > 0 && pipeline_type_kind_ord_at(a, param_ty) == (int32_t)ast_TypeKind_TYPE_PTR ? 1 : 0;
  }
  /* Field chain: slot.x.ptr etc. — walk base to find a *T param root. */
  np = pipeline_module_func_num_params_at(m, func_ix);
  for (pi = 0; pi < np; pi++) {
    if (glue_expr_is_func_param_at_c(a, m, func_ix, base_ref, pi)) {
      param_ty = pipeline_module_func_param_type_ref_at(m, func_ix, pi);
      if (param_ty > 0 && pipeline_type_kind_ord_at(a, param_ty) == (int32_t)ast_TypeKind_TYPE_PTR)
        return pi == dst_pi ? 1 : 0;
    }
  }
  return 0;
}

/**
 * WPO-S3: scan block expr_stmts for an assign-like statement of the form
 * `param[dst].field = param[src]`. Returns 1 if found; 0 otherwise.
 *
 * Contract: m / a non-NULL; block_ref > 0; func_ix >= 0.
 * PLATFORM: SHARED — pure AST walk.
 */
static int32_t typeck_block_expr_stmts_store_scan_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                    int32_t block_ref, int32_t func_ix, int32_t dst_pi,
                                                    int32_t src_pi) {
  int32_t nes;
  int32_t ei;
  if (!m || !a || block_ref <= 0 || func_ix < 0)
    return 0;
  nes = ast_ast_block_num_expr_stmts(a, block_ref);
  for (ei = 0; ei < nes; ei++) {
    int32_t er = ast_ast_block_expr_stmt_ref(a, block_ref, ei);
    int32_t left_ref;
    int32_t right_ref;
    if (er <= 0 || !glue_expr_kind_is_assign_like_ord(pipeline_expr_kind_ord_at(a, er)))
      continue;
    left_ref = pipeline_expr_binop_left_ref_at(a, er);
    right_ref = pipeline_expr_binop_right_ref_at(a, er);
    if (typeck_lval_is_param_ptr_field_c(m, a, func_ix, left_ref, dst_pi) &&
        glue_expr_is_func_param_at_c(a, m, func_ix, right_ref, src_pi))
      return 1;
  }
  return 0;
}

/**
 * WPO-S3: scan block final_expr for an assign-like expr
 * `param[dst].field = param[src]`. Returns 1 if found; 0 otherwise.
 *
 * Contract: m / a non-NULL; block_ref > 0; func_ix >= 0.
 * PLATFORM: SHARED — pure AST walk.
 */
static int32_t typeck_block_final_expr_store_scan_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                    int32_t block_ref, int32_t func_ix, int32_t dst_pi,
                                                    int32_t src_pi) {
  int32_t fin;
  int32_t left_ref;
  int32_t right_ref;
  if (!m || !a || block_ref <= 0 || func_ix < 0)
    return 0;
  fin = pipeline_asm_block_final_expr_ref_at(a, block_ref);
  if (fin <= 0 || !glue_expr_kind_is_assign_like_ord(pipeline_expr_kind_ord_at(a, fin)))
    return 0;
  left_ref = pipeline_expr_binop_left_ref_at(a, fin);
  right_ref = pipeline_expr_binop_right_ref_at(a, fin);
  return typeck_lval_is_param_ptr_field_c(m, a, func_ix, left_ref, dst_pi) &&
                 glue_expr_is_func_param_at_c(a, m, func_ix, right_ref, src_pi)
             ? 1
             : 0;
}

/**
 * WPO-S3: recursive block walk — does this block (or any nested
 * while/for/region body) contain `param[dst].field = param[src]`?
 * Combines stmt_order walk with nested-body recursion.
 *
 * Contract: m / a non-NULL; block_ref > 0; func_ix >= 0.
 * Recursion depth bounded by AST block tree depth (no explicit cap;
 * AST construction guarantees acyclic).
 *
 * PLATFORM: SHARED — pure AST walk.
 */
static int32_t typeck_block_stores_param_into_param_field_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                            int32_t block_ref, int32_t func_ix, int32_t dst_pi,
                                                            int32_t src_pi) {
  int32_t nso;
  int32_t i;
  if (!m || !a || block_ref <= 0 || func_ix < 0)
    return 0;
  if (typeck_block_expr_stmts_store_scan_c(m, a, block_ref, func_ix, dst_pi, src_pi))
    return 1;
  nso = ast_ast_block_num_stmt_order(a, block_ref);
  for (i = 0; i < nso; i++) {
    uint8_t item_kind = ast_ast_block_stmt_order_kind(a, block_ref, i);
    int32_t idx = ast_ast_block_stmt_order_idx(a, block_ref, i);
    if (item_kind == 2 && idx >= 0 && idx < ast_ast_block_num_expr_stmts(a, block_ref)) {
      int32_t er = ast_ast_block_expr_stmt_ref(a, block_ref, idx);
      int32_t left_ref;
      int32_t right_ref;
      if (er <= 0 || !glue_expr_kind_is_assign_like_ord(pipeline_expr_kind_ord_at(a, er)))
        continue;
      left_ref = pipeline_expr_binop_left_ref_at(a, er);
      right_ref = pipeline_expr_binop_right_ref_at(a, er);
      if (typeck_lval_is_param_ptr_field_c(m, a, func_ix, left_ref, dst_pi) &&
          glue_expr_is_func_param_at_c(a, m, func_ix, right_ref, src_pi))
        return 1;
    } else if (item_kind == 3 && idx >= 0 && idx < ast_ast_block_num_loops(a, block_ref)) {
      int32_t body_ref = ast_ast_block_while_body_ref(a, block_ref, idx);
      if (body_ref > 0 &&
          typeck_block_stores_param_into_param_field_c(m, a, body_ref, func_ix, dst_pi, src_pi))
        return 1;
    } else if (item_kind == 4 && idx >= 0 && idx < ast_ast_block_num_for_loops(a, block_ref)) {
      int32_t body_ref = ast_ast_block_for_body_ref(a, block_ref, idx);
      if (body_ref > 0 &&
          typeck_block_stores_param_into_param_field_c(m, a, body_ref, func_ix, dst_pi, src_pi))
        return 1;
    } else if (item_kind == 5 && idx >= 0 && idx < ast_ast_block_num_regions(a, block_ref)) {
      int32_t body_ref = ast_ast_block_region_body_ref(a, block_ref, idx);
      if (body_ref > 0 &&
          typeck_block_stores_param_into_param_field_c(m, a, body_ref, func_ix, dst_pi, src_pi))
        return 1;
    }
  }
  return 0;
}

/**
 * WPO-S3: does callee `func_ix` store its src_pi param into a field of
 * the *T object pointed to by its dst_pi param? Combines expr_stmts +
 * final_expr + recursive block walk over the function body.
 *
 * Contract: m / a non-NULL; func_ix >= 0.
 * Returns 1 if such a store exists; 0 otherwise.
 *
 * Note: as of wave1135, this helper has no in-tree caller (the call-site
 * escape path at glue.c L10066+ does its own arg-pair scan). Retained
 * for future WPO-S3 call-site reuse; DCE candidate if unused long-term.
 *
 * PLATFORM: SHARED — pure AST analysis.
 */
static int32_t typeck_func_stores_param_into_param_field_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                           int32_t func_ix, int32_t dst_pi, int32_t src_pi) {
  int32_t body_ref;
  if (!m || !a || func_ix < 0)
    return 0;
  body_ref = pipeline_module_func_body_ref_at(m, func_ix);
  if (body_ref <= 0)
    return 0;
  if (typeck_block_expr_stmts_store_scan_c(m, a, body_ref, func_ix, dst_pi, src_pi))
    return 1;
  if (typeck_block_final_expr_store_scan_c(m, a, body_ref, func_ix, dst_pi, src_pi))
    return 1;
  return typeck_block_stores_param_into_param_field_c(m, a, body_ref, func_ix, dst_pi, src_pi);
}

/*
 * wave242 G.7 pure leave: scan_expr / scan_block / scan_module → typeck_x.o.
 * Dual-export ban: no second scan bodies here. Pure faces call pure
 * pipeline_typeck_check_call_struct_stack_escape_c (wave244) + pure
 * check_* assign/return faces.
 * wave243 G.7 pure leave: read_ptr + stamp_let → typeck_x.o (no second bodies).
 * wave244 G.7 pure leave: one_region + call_struct → typeck_x.o (no second bodies).
 * Residual keeps stack_local helpers + ptr_for_addr.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU (U faces from typeck_x).
 */

/* wave243 pure leave: read_ptr + stamp_let live in typeck_x.o (dual-export ban). */
extern int32_t pipeline_typeck_is_read_ptr_slice_callee_c(uint8_t *name, int32_t name_len);
extern int32_t pipeline_typeck_read_ptr_slice_return_ref_c(struct ast_ASTArena *arena);
extern int32_t pipeline_type_stamp_block_let_region_c(struct ast_ASTArena *arena, int32_t block_ref,
                                                     int32_t let_idx, struct ast_PipelineDepCtx *ctx);

/* wave244 pure leave: one_region + call_struct live in typeck_x.o (dual-export ban).
 * check_expr residual may still call call_struct by name — U from typeck_x. */
extern int32_t pipeline_typeck_check_call_struct_stack_escape_c(struct ast_Module *module,
                                                                struct ast_ASTArena *arena,
                                                                int32_t call_expr_ref,
                                                                struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_check_block_one_region_c(struct ast_Module *module,
                                                        struct ast_ASTArena *arena, int32_t block_ref,
                                                        int32_t region_idx, int32_t return_type_ref,
                                                        struct ast_PipelineDepCtx *ctx);

/**
 * M-3 CALL slice region Cap residual thin face.
 * wave239 pure leave: body → typeck_check_call_slice_region (typeck_x.o).
 * Dual-export ban: no second call_slice / ptr_struct_compat body here.
 * PLATFORM: SHARED — Cap residual face only.
 */
int32_t pipeline_typeck_check_call_slice_region_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  int32_t call_expr_ref, struct ast_PipelineDepCtx *ctx) {
  return typeck_check_call_slice_region(module, arena, call_expr_ref, ctx);
}

/* wave1282 G.7: pipeline_typeck_ptr_for_addr_of_operand_c migrated from
 * pipeline_glue.c (was immediately before this file's #include). Colocated
 * with WPO-S3 stack-escape helpers at EOF (typeck_var_is_block_local_c /
 * typeck_find_or_alloc_ptr_stack_local_c) — sole callees of this public
 * face. typeck_type_is_named_struct_c is static in struct_lit.c (included
 * earlier in the same TU).
 *
 * Callers: check_expr.c addr_of path (after this #include) + typeck_gen seed
 * via extern. PLATFORM: SHARED — Cap residual &local struct → stack_local *T.
 */

/**
 * WPO-S3: when operand is a block-local VAR of named struct type, return a
 * stack_local *T type_ref; otherwise 0 (caller falls back to ordinary *T).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_ptr_for_addr_of_operand_c(struct ast_ASTArena *arena, int32_t op_ref, int32_t elem_ty,
                                                  struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  if (!arena || !module || !ctx || op_ref <= 0 || elem_ty <= 0)
    return 0;
  if (!typeck_var_is_block_local_c(module, arena, ctx, op_ref))
    return 0;
  if (!typeck_type_is_named_struct_c(module, arena, elem_ty))
    return 0;
  return typeck_find_or_alloc_ptr_stack_local_c(arena, elem_ty);
}
