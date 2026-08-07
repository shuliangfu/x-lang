/**
 * pipeline_typeck_region_assign.c — typeck region/escape assign-site domain (BC 8.3.1).
 *
 * wave235 G.7 pure leave: M-3 slice region assign + return operand path dual
 * bodies retired → typeck.x (typeck_check_slice_region_assign /
 * typeck_check_return_slice_region + private escape/conflict helpers).
 * Cap residual keeps thin *_c faces for call_slice_region / mega / seed paths.
 *
 * Still residual (not pure-leaved this wave):
 * - M-3 AL-06 return slice in region-scope (scope label BSS)
 * - WPO-S3 struct stack-escape assign + helpers
 * - MEM-A3 scope-borrow assign/return + diag line/col + lval/ancestor helpers
 * - MEM-C1 with_arena scope stack + allocator region assign/return
 * - call_slice_region mega (resolve + array_lit coerce + stack-escape)
 *
 * G.7 dual-export ban: do NOT re-open second slice_region_assign /
 * return_slice_region body here; typeck.x is single authority.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c.
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/* Live M-3 slice region authority in typeck_x.o (typeck.x exports). */
extern int32_t typeck_check_slice_region_assign(struct ast_ASTArena *arena, int32_t site_expr_ref,
                                                int32_t expect_ref, int32_t src_ref);
extern int32_t typeck_check_return_slice_region(struct ast_ASTArena *arena, int32_t ret_site_ref,
                                                int32_t op_ref, int32_t func_return_ref);

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
 * PLATFORM: SHARED — Cap-T001: inside unsafe { } (typeck_unsafe_depth>0) skip; not LANG-007 off.
 */
int32_t pipeline_typeck_check_struct_stack_escape_assign_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                           int32_t site_expr_ref, int32_t left_ref, int32_t right_ref,
                                                           struct ast_PipelineDepCtx *ctx) {
  int32_t func_ix;
  int32_t np;
  int32_t pi;
  int32_t line;
  int32_t col;
  if (!module || !arena || !ctx || left_ref <= 0 || right_ref <= 0)
    return 0;
  /* Cap-T001 / mega selfhost: whole-body unsafe opts into stack-ptr patterns. */
  if (pipeline_dep_ctx_typeck_unsafe_depth_at(ctx) > 0)
    return 0;
  if (!typeck_expr_is_addr_of_block_local_c(module, arena, ctx, right_ref))
    return 0;
  func_ix = ctx->current_func_index;
  if (func_ix < 0)
    return 0;
  np = pipeline_module_func_num_params_at(module, func_ix);
  for (pi = 0; pi < np; pi++) {
    if (typeck_lval_is_param_ptr_field_c(module, arena, func_ix, left_ref, pi)) {
      line = 0;
      col = 0;
      if (site_expr_ref > 0 && site_expr_ref <= arena->num_exprs) {
        line = pipeline_expr_line_at(arena, site_expr_ref);
        col = pipeline_expr_col_at(arena, site_expr_ref);
      }
      lsp_diag_report_typeck((int)line, (int)col,
                             "struct stack escape: cannot store address of local struct in outer lifetime");
      return -1;
    }
  }
  return 0;
}

/** MEM-A3：block ancestor 是否为 block descendant 的严格外层父链祖先。 */
static int32_t typeck_block_is_strict_ancestor_c(struct ast_ASTArena *a, int32_t ancestor, int32_t descendant) {
  struct ast_Block *b;
  int32_t cur;
  int32_t depth;
  if (!a || ancestor <= 0 || descendant <= 0 || ancestor == descendant)
    return 0;
  cur = descendant;
  depth = 0;
  while (cur > 0 && cur <= a->num_blocks && depth < 128) {
    b = pipeline_arena_block_ptr(a, cur);
    if (!b)
      break;
    if (b->parent_block_ref == ancestor)
      return 1;
    cur = b->parent_block_ref;
    depth++;
  }
  return 0;
}

/** MEM-A3：自 lvalue expr 沿 field/index 链取根 VAR 名。 */
static int32_t typeck_expr_lval_root_var_c(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out, int32_t *out_len) {
  int32_t cur;
  int32_t k;
  if (!a || expr_ref <= 0 || !out || !out_len)
    return 0;
  cur = expr_ref;
  for (;;) {
    k = pipeline_expr_kind_ord_at(a, cur);
    if (k == GLUE_EXPR_KIND_VAR) {
      *out_len = pipeline_expr_var_name_len(a, cur);
      if (*out_len <= 0 || *out_len > 127)
        return 0;
      pipeline_expr_var_name_into(a, cur, out);
      return 1;
    }
    if (k == (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS)
      cur = pipeline_expr_field_access_base_ref(a, cur);
    else if (k == (int32_t)ast_ExprKind_EXPR_INDEX)
      cur = pipeline_expr_index_base_ref(a, cur);
    else
      return 0;
    if (cur <= 0)
      return 0;
  }
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
 */
int32_t pipeline_typeck_check_scope_borrow_assign_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  int32_t site_expr_ref, int32_t left_ref, int32_t right_ref,
                                                  struct ast_PipelineDepCtx *ctx) {
  uint8_t lname[128];
  uint8_t rname[128];
  int32_t llen;
  int32_t rlen;
  int32_t op_ref;
  int32_t site_block;
  int32_t lblock;
  int32_t rblock;
  int32_t line;
  int32_t col;
  if (!module || !arena || !ctx || left_ref <= 0 || right_ref <= 0)
    return 0;
  if (!typeck_expr_is_addr_of_block_local_c(module, arena, ctx, right_ref))
    return 0;
  if (!typeck_expr_lval_root_var_c(arena, left_ref, lname, &llen))
    return 0;
  if (pipeline_expr_kind_ord_at(arena, right_ref) != (int32_t)ast_ExprKind_EXPR_ADDR_OF)
    return 0;
  op_ref = pipeline_expr_unary_operand_ref_at(arena, right_ref);
  if (op_ref <= 0 || pipeline_expr_kind_ord_at(arena, op_ref) != GLUE_EXPR_KIND_VAR)
    return 0;
  rlen = pipeline_expr_var_name_len(arena, op_ref);
  if (rlen <= 0 || rlen > 127)
    return 0;
  pipeline_expr_var_name_into(arena, op_ref, rname);
  site_block = ctx->current_block_ref;
  if (site_block <= 0 && ctx->current_func_index >= 0)
    site_block = pipeline_module_func_body_ref_at(module, ctx->current_func_index);
  if (site_block <= 0)
    return 0;
  lblock = pipeline_block_find_var_decl_block_ref(arena, site_block, lname, llen);
  rblock = pipeline_block_find_var_decl_block_ref(arena, site_block, rname, rlen);
  if (lblock <= 0 || rblock <= 0 || lblock == rblock)
    return 0;
  if (!typeck_block_is_strict_ancestor_c(arena, lblock, rblock))
    return 0;
  pipeline_typeck_expr_diag_line_col_c(arena, site_expr_ref, &line, &col);
  lsp_diag_report_typeck((int)line, (int)col, "scope borrow escape");
  return -1;
}

/**
 * MEM-A3：return — 禁止返回块内局部变量地址（指针逃出函数/块生命周期）。
 */
int32_t pipeline_typeck_check_scope_borrow_return_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t site_expr_ref, int32_t op_ref, int32_t return_type_ref,
                                                    struct ast_PipelineDepCtx *ctx) {
  int32_t line;
  int32_t col;
  if (!module || !arena || !ctx || site_expr_ref <= 0 || op_ref <= 0)
    return 0;
  if (return_type_ref <= 0 || pipeline_type_kind_ord_at(arena, return_type_ref) != (int32_t)ast_TypeKind_TYPE_PTR)
    return 0;
  if (!typeck_expr_is_addr_of_block_local_c(module, arena, ctx, op_ref))
    return 0;
  pipeline_typeck_expr_diag_line_col_c(arena, site_expr_ref, &line, &col);
  lsp_diag_report_typeck((int)line, (int)col, "scope borrow escape");
  return -1;
}

/** MEM-C1：with_arena 嵌套栈深度（post-typeck scan 用；每模块 scan 前清零）。 */
#define TYPECK_WITH_ARENA_SCOPE_MAX 8
static int32_t g_typeck_with_arena_body_stack[TYPECK_WITH_ARENA_SCOPE_MAX];
static int32_t g_typeck_with_arena_scope_n;

/** MEM-C1：当前 with_arena 栈顶 body 块 ref；无则 0。 */
static int32_t typeck_with_arena_current_body_ref_c(void) {
  return g_typeck_with_arena_scope_n > 0 ? g_typeck_with_arena_body_stack[g_typeck_with_arena_scope_n - 1] : 0;
}

/** MEM-C1：进入 with_arena 块体 scan 前 push body ref。 */
static void typeck_with_arena_scope_push_c(int32_t body_ref) {
  if (body_ref <= 0 || g_typeck_with_arena_scope_n >= TYPECK_WITH_ARENA_SCOPE_MAX)
    return;
  g_typeck_with_arena_body_stack[g_typeck_with_arena_scope_n++] = body_ref;
}

/** MEM-C1：离开 with_arena 块体 scan 后 pop。 */
static void typeck_with_arena_scope_pop_c(void) {
  if (g_typeck_with_arena_scope_n > 0)
    g_typeck_with_arena_scope_n--;
}

/** M-3：region 域栈读/写（定义见下；前置声明供 AL-06 scan/typeck 使用）。 */
int32_t pipeline_dep_ctx_scope_region_push_c(struct ast_PipelineDepCtx *ctx, uint8_t *label, int32_t label_len);
void pipeline_dep_ctx_scope_region_pop_c(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_scope_region_len_at(struct ast_PipelineDepCtx *ctx);

/** M-3 AL-06：return slice 域检查（定义见下）。 */
int32_t pipeline_typeck_check_return_slice_region_c(struct ast_ASTArena *arena, int32_t ret_site_ref,
                                                    int32_t op_ref, int32_t func_return_ref);

/** MEM-C1：return 类型是否为命名 struct Allocator。 */
static int32_t typeck_type_is_allocator_struct_c(struct ast_ASTArena *arena, int32_t ty_ref) {
  uint8_t nm[128];
  int32_t nlen;
  if (!arena || ty_ref <= 0 || pipeline_type_kind_ord_at(arena, ty_ref) != (int32_t)ast_TypeKind_TYPE_NAMED)
    return 0;
  nlen = pipeline_type_named_name_into(arena, ty_ref, nm);
  return (nlen == 9 && memcmp(nm, "Allocator", 9) == 0) ? 1 : 0;
}

/**
 * MEM-C1 AL-04：with_arena 内 assign — 禁止 arena 域值写入块外变量（allocator region 逃逸）。
 */
int32_t pipeline_typeck_check_allocator_region_assign_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                      int32_t site_expr_ref, int32_t left_ref,
                                                      struct ast_PipelineDepCtx *ctx) {
  uint8_t lname[128];
  int32_t llen;
  int32_t wa_body;
  int32_t site_block;
  int32_t lblock;
  int32_t line;
  int32_t col;
  if (!module || !arena || !ctx || left_ref <= 0 || g_typeck_with_arena_scope_n <= 0)
    return 0;
  if (!typeck_expr_lval_root_var_c(arena, left_ref, lname, &llen))
    return 0;
  wa_body = typeck_with_arena_current_body_ref_c();
  if (wa_body <= 0)
    return 0;
  site_block = ctx->current_block_ref;
  if (site_block <= 0)
    site_block = wa_body;
  lblock = pipeline_block_find_var_decl_block_ref(arena, site_block, lname, llen);
  if (lblock <= 0)
    return 0;
  if (lblock == wa_body || typeck_block_is_strict_ancestor_c(arena, wa_body, lblock))
    return 0;
  if (!typeck_block_is_strict_ancestor_c(arena, lblock, wa_body))
    return 0;
  pipeline_typeck_expr_diag_line_col_c(arena, site_expr_ref, &line, &col);
  lsp_diag_report_typeck((int)line, (int)col, "allocator region escape");
  return -1;
}

/**
 * MEM-C1 AL-04：with_arena 内 return Allocator — 禁止 allocator 域逃出 with_arena 块。
 */
int32_t pipeline_typeck_check_allocator_region_return_c(struct ast_ASTArena *arena, int32_t site_expr_ref,
                                                        int32_t return_type_ref) {
  int32_t line;
  int32_t col;
  if (!arena || site_expr_ref <= 0 || g_typeck_with_arena_scope_n <= 0)
    return 0;
  if (!typeck_type_is_allocator_struct_c(arena, return_type_ref))
    return 0;
  pipeline_typeck_expr_diag_line_col_c(arena, site_expr_ref, &line, &col);
  lsp_diag_report_typeck((int)line, (int)col, "allocator region escape");
  return -1;
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

/* ============================================================
 * wave1136-1137 G.7: stack-escape scan pair (migrated from
 * glue.c L10011-10074 + L10114-10212).
 *
 * Why here: typeck_scan_expr_stack_escape_c and
 * typeck_scan_block_stack_escape_c are the recursive post-typeck
 * walkers that drive ALL assign/return/call stack-escape checks
 * defined in this file (check_struct_stack_escape_assign_c L121,
 * check_scope_borrow_assign_c L241, check_scope_borrow_return_c L288,
 * check_allocator_region_assign_c L349, check_allocator_region_return_c
 * L384, check_return_slice_region_in_scope_c L401,
 * check_return_slice_region_c L426) plus the call-site escape check
 * (pipeline_typeck_check_call_struct_stack_escape_c, extern in glue.c).
 * Colocating the scanners with the checks they invoke keeps the entire
 * WPO-S3 / M-3 escape analysis path in one domain file.
 *
 * Invariant: definitions placed at EOF AFTER all called check_* helpers
 * above. scan_expr is defined first (no self-recursion); scan_block is
 * recursive and gets a static fwd decl immediately below so it can call
 * itself. pipeline_typeck_scan_module_struct_stack_escape_c (the public
 * entry, glue.c L10215) stays in glue.c because it touches globals
 * g_typeck_with_arena_scope_n / g_typeck_region_scope_n directly; it
 * sees scan_block via the #include of this leaf at glue.c L9934.
 *
 * Dependencies visible via earlier fwd decls in glue.c (all before
 * #include at L9934):
 *   - pipeline_typeck_check_call_struct_stack_escape_c (static fwd at L9886)
 *   - pipeline_dep_ctx_scope_region_push_c / _pop_c (extern fwd at L328-329
 *     of this file; definitions at glue.c L10083/10101)
 *   - pipeline_typeck_unsafe_depth_push_c / _pop_c (fwd at glue.c L8703-8704)
 *   - typeck_with_arena_scope_push_c / _pop_c (defined at L315/322 this file)
 *
 * PLATFORM: SHARED — pure typeck analysis; no platform ABI dependency.
 * ============================================================ */

/* wave1137 G.7: forward decl — scan_block is recursive (calls itself
 * for nested while/for/if/region bodies). */
static int32_t typeck_scan_block_stack_escape_c(struct ast_Module *m, struct ast_ASTArena *a,
                                              struct ast_PipelineDepCtx *ctx, int32_t func_ix,
                                              int32_t block_ref);

/**
 * WPO-S3: single-expr assign/call/return stack-escape scan
 * (post-typeck; typeck.o WPO may strip inline hooks).
 *
 * Dispatches by expr kind:
 *   - assign-like: struct stack-escape + scope-borrow + allocator-region
 *   - RETURN: scope-borrow-return + allocator-region-return +
 *     return-slice-region-in-scope + return-slice-region
 *   - CALL: call-struct-stack-escape
 *
 * Saves/restores ctx->current_func_index around the check so diag
 * helpers see the correct function context.
 *
 * Contract: m / a / ctx non-NULL; expr_ref > 0; func_ix >= 0.
 * @return 0 OK; -1 escape detected (diag already printed).
 *
 * PLATFORM: SHARED — pure typeck dispatch; no platform ABI dependency.
 */
static int32_t typeck_scan_expr_stack_escape_c(struct ast_Module *m, struct ast_ASTArena *a,
                                             struct ast_PipelineDepCtx *ctx, int32_t func_ix,
                                             int32_t expr_ref) {
  int32_t k;
  int32_t saved_ix;
  int32_t saved_br;
  if (!m || !a || !ctx || expr_ref <= 0 || func_ix < 0)
    return 0;
  saved_ix = ctx->current_func_index;
  saved_br = ctx->current_block_ref;
  ctx->current_func_index = func_ix;
  k = pipeline_expr_kind_ord_at(a, expr_ref);
  if (glue_expr_kind_is_assign_like_ord(k)) {
    int32_t l = pipeline_expr_binop_left_ref_at(a, expr_ref);
    int32_t r = pipeline_expr_binop_right_ref_at(a, expr_ref);
    if (pipeline_typeck_check_struct_stack_escape_assign_c(m, a, expr_ref, l, r, ctx) != 0) {
      ctx->current_func_index = saved_ix;
      ctx->current_block_ref = saved_br;
      return -1;
    }
    if (pipeline_typeck_check_scope_borrow_assign_c(m, a, expr_ref, l, r, ctx) != 0) {
      ctx->current_func_index = saved_ix;
      ctx->current_block_ref = saved_br;
      return -1;
    }
    if (pipeline_typeck_check_allocator_region_assign_c(m, a, expr_ref, l, ctx) != 0) {
      ctx->current_func_index = saved_ix;
      ctx->current_block_ref = saved_br;
      return -1;
    }
  } else if (k == (int32_t)ast_ExprKind_EXPR_RETURN) {
    int32_t op = pipeline_expr_unary_operand_ref_at(a, expr_ref);
    int32_t func_ret = pipeline_module_func_return_type_at(m, func_ix);
    if (pipeline_typeck_check_scope_borrow_return_c(m, a, expr_ref, op, func_ret, ctx) != 0) {
      ctx->current_func_index = saved_ix;
      ctx->current_block_ref = saved_br;
      return -1;
    }
    if (pipeline_typeck_check_allocator_region_return_c(a, expr_ref, func_ret) != 0) {
      ctx->current_func_index = saved_ix;
      ctx->current_block_ref = saved_br;
      return -1;
    }
    if (pipeline_typeck_check_return_slice_region_in_scope_c(a, expr_ref, func_ret, ctx) != 0) {
      ctx->current_func_index = saved_ix;
      ctx->current_block_ref = saved_br;
      return -1;
    }
    if (pipeline_typeck_check_return_slice_region_c(a, expr_ref, op, func_ret) != 0) {
      ctx->current_func_index = saved_ix;
      ctx->current_block_ref = saved_br;
      return -1;
    }
  } else if (k == (int32_t)ast_ExprKind_EXPR_CALL) {
    if (pipeline_typeck_check_call_struct_stack_escape_c(m, a, expr_ref, ctx) != 0) {
      ctx->current_func_index = saved_ix;
      ctx->current_block_ref = saved_br;
      return -1;
    }
  }
  ctx->current_func_index = saved_ix;
  ctx->current_block_ref = saved_br;
  return 0;
}

/**
 * WPO-S3: recursive block scan — walk expr_stmts + final_expr +
 * stmt_order (expr_stmt / while / for / if-then-else / region) and
 * dispatch each expr through typeck_scan_expr_stack_escape_c.
 *
 * Region handling mirrors check_block_one_region:
 *   - with_arena cap region: push with_arena scope, recurse, pop
 *   - labeled region: push scope_region label, recurse, pop
 *   - unsafe region: push unsafe_depth, recurse, pop (Cap-T001)
 *
 * Contract: m / a / ctx non-NULL; block_ref > 0; func_ix >= 0.
 * Saves/restores ctx->current_block_ref around the scan.
 * Recursion depth bounded by AST block tree depth.
 *
 * @return 0 OK; -1 escape detected (diag already printed).
 *
 * PLATFORM: SHARED — pure typeck walk; no platform ABI dependency.
 */
static int32_t typeck_scan_block_stack_escape_c(struct ast_Module *m, struct ast_ASTArena *a,
                                              struct ast_PipelineDepCtx *ctx, int32_t func_ix,
                                              int32_t block_ref) {
  int32_t nes;
  int32_t ei;
  int32_t fin;
  int32_t nso;
  int32_t i;
  int32_t saved_br;
  if (!m || !a || !ctx || block_ref <= 0 || func_ix < 0)
    return 0;
  saved_br = ctx->current_block_ref;
  ctx->current_block_ref = block_ref;
  nes = ast_ast_block_num_expr_stmts(a, block_ref);
  for (ei = 0; ei < nes; ei++) {
    int32_t er = ast_ast_block_expr_stmt_ref(a, block_ref, ei);
    if (er > 0 && typeck_scan_expr_stack_escape_c(m, a, ctx, func_ix, er) != 0) {
      ctx->current_block_ref = saved_br;
      return -1;
    }
  }
  fin = pipeline_asm_block_final_expr_ref_at(a, block_ref);
  if (fin > 0 && typeck_scan_expr_stack_escape_c(m, a, ctx, func_ix, fin) != 0) {
    ctx->current_block_ref = saved_br;
    return -1;
  }
  nso = ast_ast_block_num_stmt_order(a, block_ref);
  for (i = 0; i < nso; i++) {
    uint8_t k = ast_ast_block_stmt_order_kind(a, block_ref, i);
    int32_t idx = ast_ast_block_stmt_order_idx(a, block_ref, i);
    if (k == 2 && idx >= 0 && idx < ast_ast_block_num_expr_stmts(a, block_ref)) {
      int32_t er = ast_ast_block_expr_stmt_ref(a, block_ref, idx);
      if (er > 0 && typeck_scan_expr_stack_escape_c(m, a, ctx, func_ix, er) != 0) {
        ctx->current_block_ref = saved_br;
        return -1;
      }
    } else if (k == 3 && idx >= 0 && idx < ast_ast_block_num_loops(a, block_ref)) {
      int32_t br = ast_ast_block_while_body_ref(a, block_ref, idx);
      if (br > 0 && typeck_scan_block_stack_escape_c(m, a, ctx, func_ix, br) != 0)
        return -1;
    } else if (k == 4 && idx >= 0 && idx < ast_ast_block_num_for_loops(a, block_ref)) {
      int32_t br = ast_ast_block_for_body_ref(a, block_ref, idx);
      if (br > 0 && typeck_scan_block_stack_escape_c(m, a, ctx, func_ix, br) != 0)
        return -1;
    } else if (k == 5 && idx >= 0 && idx < ast_ast_block_num_if_stmts(a, block_ref)) {
      int32_t tr = ast_ast_block_if_then_body_ref(a, block_ref, idx);
      int32_t er = ast_ast_block_if_else_body_ref(a, block_ref, idx);
      if (tr > 0 && typeck_scan_block_stack_escape_c(m, a, ctx, func_ix, tr) != 0)
        return -1;
      if (er > 0 && typeck_scan_block_stack_escape_c(m, a, ctx, func_ix, er) != 0)
        return -1;
    } else if (k == 6 && idx >= 0 && idx < ast_ast_block_num_regions(a, block_ref)) {
      int32_t wa_cap = pipeline_block_region_with_arena_cap_ref(a, block_ref, idx);
      int32_t br = ast_ast_block_region_body_ref(a, block_ref, idx);
      /* Cap-T001: post-scan must honor unsafe regions like check_block_one_region. */
      int32_t is_unsafe = pipeline_block_region_is_unsafe(a, block_ref, idx);
      int32_t saved_ud = 0;
      if (is_unsafe != 0)
        saved_ud = pipeline_typeck_unsafe_depth_push_c(ctx);
      if (wa_cap > 0) {
        typeck_with_arena_scope_push_c(br);
        if (br > 0 && typeck_scan_block_stack_escape_c(m, a, ctx, func_ix, br) != 0) {
          typeck_with_arena_scope_pop_c();
          if (is_unsafe != 0)
            pipeline_typeck_unsafe_depth_pop_c(ctx, saved_ud);
          ctx->current_block_ref = saved_br;
          return -1;
        }
        typeck_with_arena_scope_pop_c();
      } else {
        uint8_t lbl[128];
        int32_t llen = pipeline_block_region_label_len(a, block_ref, idx);
        if (llen > 0) {
          pipeline_block_region_label_copy64(a, block_ref, idx, lbl);
          if (pipeline_dep_ctx_scope_region_push_c(ctx, lbl, llen) != 0) {
            if (is_unsafe != 0)
              pipeline_typeck_unsafe_depth_pop_c(ctx, saved_ud);
            ctx->current_block_ref = saved_br;
            return -1;
          }
        }
        if (br > 0 && typeck_scan_block_stack_escape_c(m, a, ctx, func_ix, br) != 0) {
          if (llen > 0)
            pipeline_dep_ctx_scope_region_pop_c(ctx);
          if (is_unsafe != 0)
            pipeline_typeck_unsafe_depth_pop_c(ctx, saved_ud);
          ctx->current_block_ref = saved_br;
          return -1;
        }
        if (llen > 0)
          pipeline_dep_ctx_scope_region_pop_c(ctx);
      }
      if (is_unsafe != 0)
        pipeline_typeck_unsafe_depth_pop_c(ctx, saved_ud);
    }
  }
  ctx->current_block_ref = saved_br;
  return 0;
}

/*
 * wave1167 G.7: region scope + scan_module + read_ptr + stamp_let cluster
 * (7 fns + 3 statics + 1 macro) migrated from pipeline_glue.c (was L8497-8645).
 * Colocated with region_assign domain — all region scope push/pop/len/stamp
 * and module-level stack-escape scan belong here with typeck_scan_block_stack_escape_c.
 *
 * Statics (g_typeck_region_saved_len / saved_label / scope_n) now live here
 * alongside g_typeck_with_arena_scope_n (L307). Both are reset by
 * pipeline_typeck_scan_module_struct_stack_escape_c before per-func scan.
 *
 * Forward decls at L327-329 retained for early callsites in this file
 * (check_return_slice_region_c at L409/416, scan_block at L1112/1121/1128)
 * which precede these EOF definitions.
 *
 * Extern fwd decl for pipeline_block_set_let_type_ref (defined in
 * ast_pool_block.c, visible via ast_pool.c #include at glue.c L5281 < this
 * file's #include at L8417).
 *
 * Deps (all extern, visible at region_assign.c #include L8417):
 * - link_abi_getenv (global)
 * - pipeline_module_num_funcs / pipeline_module_func_is_extern_at /
 *   pipeline_module_func_num_generic_params_at /
 *   pipeline_module_func_body_ref_at (module_func domain)
 * - typeck_scan_block_stack_escape_c (same file, L920+)
 * - pipeline_type_ensure_by_kind_ord (glue.c L3334)
 * - pipeline_type_find_or_alloc_slice (ast_pool_type.c)
 * - pipeline_type_kind_ord_at / pipeline_type_elem_ref_at /
 *   pipeline_type_region_label_len_at (type accessor domain)
 * - pipeline_block_let_type_ref / pipeline_block_set_let_type_ref
 *   (ast_pool_block.c)
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU.
 */

/** M-3: typeck region domain nesting stack (max 8 levels; push/pop in C glue). */
#define TYPECK_REGION_SCOPE_MAX 8
static int32_t g_typeck_region_saved_len[TYPECK_REGION_SCOPE_MAX];
static uint8_t g_typeck_region_saved_label[TYPECK_REGION_SCOPE_MAX][128];
static int32_t g_typeck_region_scope_n;

/**
 * Save current ctx region label and set new domain label; -1 on failure.
 * Why: region blocks (unsafe/io_read_ptr/etc.) push a domain label so that
 *      inner let T[] declarations inherit the region tag for escape checks.
 * Contract: null ctx / null label / label_len outside [1,127] → -1.
 *           Stack overflow (>= TYPECK_REGION_SCOPE_MAX) → -1.
 * PLATFORM: SHARED — region scope management for post-typeck escape scan.
 */
int32_t pipeline_dep_ctx_scope_region_push_c(struct ast_PipelineDepCtx *ctx, uint8_t *label, int32_t label_len) {
  int32_t slot;
  if (!ctx || !label || label_len <= 0 || label_len > 127)
    return -1;
  if (g_typeck_region_scope_n >= TYPECK_REGION_SCOPE_MAX)
    return -1;
  slot = g_typeck_region_scope_n;
  g_typeck_region_saved_len[slot] = ctx->typeck_scope_region_len;
  if (ctx->typeck_scope_region_len > 0 && ctx->typeck_scope_region_len <= 63)
    memcpy(g_typeck_region_saved_label[slot], ctx->typeck_scope_region_label, 128);
  memset(ctx->typeck_scope_region_label, 0, sizeof(ctx->typeck_scope_region_label));
  memcpy(ctx->typeck_scope_region_label, label, (size_t)label_len);
  ctx->typeck_scope_region_len = label_len;
  g_typeck_region_scope_n++;
  return 0;
}

/**
 * Restore the region domain label saved by the matching push.
 * Why: pop region scope after scanning a region block body so outer
 *      lets are not tagged with the inner region label.
 * Contract: null ctx / empty stack → no-op.
 * PLATFORM: SHARED — region scope management for post-typeck escape scan.
 */
void pipeline_dep_ctx_scope_region_pop_c(struct ast_PipelineDepCtx *ctx) {
  int32_t slot;
  if (!ctx || g_typeck_region_scope_n <= 0)
    return;
  g_typeck_region_scope_n--;
  slot = g_typeck_region_scope_n;
  ctx->typeck_scope_region_len = g_typeck_region_saved_len[slot];
  memset(ctx->typeck_scope_region_label, 0, sizeof(ctx->typeck_scope_region_label));
  if (g_typeck_region_saved_len[slot] > 0 && g_typeck_region_saved_len[slot] <= 127)
    memcpy(ctx->typeck_scope_region_label, g_typeck_region_saved_label[slot], 128);
}

/**
 * Module-level post-typeck scan for struct stack-pointer escape.
 * Why: iterate all non-extern, non-generic funcs and delegate to
 *      typeck_scan_block_stack_escape_c (same file) for each body.
 *      Resets both with_arena and region scope stacks before scanning.
 * Contract: null module/arena/ctx → 0 (no-op).
 *           XLANG_SKIP_STACK_ESCAPE env → 0 (skip).
 * PLATFORM: SHARED — WPO-S3 struct escape gate; called from glue.c
 *           pipeline_typeck_after_parse_ok_c and lsp_diag paths.
 */
int32_t pipeline_typeck_scan_module_struct_stack_escape_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                          struct ast_PipelineDepCtx *ctx) {
  int32_t i;
  int32_t nf;
  int32_t body;
  int32_t num_generic_params;
  if (!module || !arena || !ctx)
    return 0;
  if (link_abi_getenv("XLANG_SKIP_STACK_ESCAPE") != NULL)
    return 0;
  g_typeck_with_arena_scope_n = 0;
  g_typeck_region_scope_n = 0;
  ctx->typeck_scope_region_len = 0;
  memset(ctx->typeck_scope_region_label, 0, sizeof(ctx->typeck_scope_region_label));
  nf = pipeline_module_num_funcs(module);
  for (i = 0; i < nf; i++) {
    if (pipeline_module_func_is_extern_at(module, i) != 0)
      continue;
    num_generic_params = pipeline_module_func_num_generic_params_at(module, i);
    if (num_generic_params > 0)
      continue;
    body = pipeline_module_func_body_ref_at(module, i);
    if (body <= 0)
      continue;
    if (typeck_scan_block_stack_escape_c(module, arena, ctx, i, body) != 0)
      return -1;
  }
  return 0;
}

/**
 * Check if callee name is a read_ptr slice producer (auto-binds io_read_ptr region).
 * Why: read_ptr_slice / xlang_io_read_ptr_slice / driver_read_ptr_slice /
 *      io_read_ptr_slice all return u8[]<io_read_ptr> tagged slices; the typeck
 *      auto-binds the io_read_ptr region label for escape-safe return paths.
 * Contract: null name / name_len <= 0 → 0.
 * PLATFORM: SHARED — M-5 read_ptr slice region binding.
 */
int32_t pipeline_typeck_is_read_ptr_slice_callee_c(uint8_t *name, int32_t name_len) {
  static const uint8_t n0[] = "read_ptr_slice";
  static const uint8_t n1[] = "xlang_io_read_ptr_slice";
  static const uint8_t n2[] = "driver_read_ptr_slice";
  static const uint8_t n3[] = "io_read_ptr_slice";
  if (!name || name_len <= 0)
    return 0;
  if (name_len == 14 && memcmp(name, n0, 14) == 0)
    return 1;
  if (name_len == 19 && memcmp(name, n1, 19) == 0)
    return 1;
  if (name_len == 18 && memcmp(name, n2, 18) == 0)
    return 1;
  if (name_len == 16 && memcmp(name, n3, 16) == 0)
    return 1;
  return 0;
}

/**
 * Allocate or find the u8[]<io_read_ptr> type pool ref (read_ptr TLS buf domain).
 * Why: read_ptr slice return type must carry the io_read_ptr region label so
 *      the escape checker permits the return path within the region block.
 * Contract: null arena → 0.
 * PLATFORM: SHARED — M-5 read_ptr slice region binding.
 */
int32_t pipeline_typeck_read_ptr_slice_return_ref_c(struct ast_ASTArena *arena) {
  static const uint8_t lbl[] = "io_read_ptr";
  int32_t u8_ref;
  if (!arena)
    return 0;
  u8_ref = pipeline_type_ensure_by_kind_ord(arena, 2);
  if (u8_ref <= 0)
    return 0;
  return pipeline_type_find_or_alloc_slice(arena, u8_ref, (uint8_t *)lbl, 11);
}

/**
 * Read current ctx region domain label length; 0 means not inside a region block.
 * Contract: null ctx → 0.
 * PLATFORM: SHARED — M-3 region scope reader for let region stamping.
 */
int32_t pipeline_dep_ctx_scope_region_len_at(struct ast_PipelineDepCtx *ctx) {
  if (!ctx)
    return 0;
  return ctx->typeck_scope_region_len > 0 ? ctx->typeck_scope_region_len : 0;
}

/* extern: defined in ast_pool_block.c (visible via ast_pool.c #include at glue.c L5281). */
int32_t pipeline_block_set_let_type_ref(struct ast_ASTArena *arena, int32_t block_ref, int32_t let_idx,
                                        int32_t type_ref);

/**
 * Stamp a block-let's T[] type with the current ctx region label.
 * Why: region-block inner `let v = arr` where arr: T[] must inherit the
 *      region tag (T[]<label>) so the escape checker can verify the let
 *      does not outlive the region. In-place mutation of the shared type
 *      node is forbidden (would corrupt function return types sharing the
 *      same T[] ref); must find_or_alloc a new T[]<label> and write it back.
 * Contract: null arena/ctx / invalid block_ref/let_idx → 0.
 *           Non-TYPE_SLICE type / already-tagged → 0 (no-op).
 *           find_or_alloc failure → -1.
 * PLATFORM: SHARED — M-3 region tag propagation to let declarations.
 */
int32_t pipeline_type_stamp_block_let_region_c(struct ast_ASTArena *arena, int32_t block_ref, int32_t let_idx,
                                             struct ast_PipelineDepCtx *ctx) {
  int32_t ty_ref;
  int32_t rlen;
  int32_t elem;
  int32_t stamped;
  if (!arena || !ctx || block_ref <= 0 || let_idx < 0)
    return 0;
  rlen = pipeline_dep_ctx_scope_region_len_at(ctx);
  if (rlen <= 0)
    return 0;
  ty_ref = pipeline_block_let_type_ref(arena, block_ref, let_idx);
  if (ty_ref <= 0 || pipeline_type_kind_ord_at(arena, ty_ref) != (int32_t)ast_TypeKind_TYPE_SLICE)
    return 0;
  if (pipeline_type_region_label_len_at(arena, ty_ref) > 0)
    return 0;
  elem = pipeline_type_elem_ref_at(arena, ty_ref);
  if (elem <= 0)
    return 0;
  stamped = pipeline_type_find_or_alloc_slice(arena, elem, ctx->typeck_scope_region_label, rlen);
  if (stamped <= 0)
    return -1;
  if (stamped == ty_ref)
    return 0;
  return pipeline_block_set_let_type_ref(arena, block_ref, let_idx, stamped);
}

/* ========================================================================== *
 * wave1214 G.7: pipeline_typeck_check_call_struct_stack_escape_c migrated
 * from pipeline_glue.c L3685-3752. Colocated with region/escape assign-site
 * domain (this file; #include at glue.c L3678).
 *
 * Members (1 fn):
 *  - pipeline_typeck_check_call_struct_stack_escape_c (WPO-S3 CALL stack escape)
 *
 * Deps (all visible at #include point L3678):
 *  - pipeline_typeck_resolve_call_func_index_c (static fwd decl, glue.c L3628)
 *  - typeck_expr_is_addr_of_block_local_c (static, this file — defined earlier)
 *  - typeck_type_is_named_struct_c (static, struct_lit.c; #include L1435 < L3678)
 *  - pipeline_dep_ctx_typeck_unsafe_depth_at / pipeline_expr_call_num_args_at /
 *    pipeline_module_func_num_params_at / pipeline_expr_call_arg_ref /
 *    pipeline_expr_resolved_type_ref / pipeline_type_kind_ord_at /
 *    pipeline_type_elem_ref_at / pipeline_module_func_param_type_ref_at /
 *    pipeline_expr_line_at / pipeline_expr_col_at / link_abi_getenv /
 *    lsp_diag_report_typeck (all extern)
 *
 * Callers: no TU-internal callsites in glue.c. Sole callers are
 * pipeline_typeck_region_assign.c L1009 (this file) + pipeline_typeck_check_expr.c
 * L129 (#include at glue.c L4265, after L3678 — visible).
 *
 * PLATFORM: SHARED — Cap-T001: inside unsafe { } skip (depth>0); safe code
 * still hard-fails T001.
 * ========================================================================== */

/**
 * WPO-S3: CALL path — reject when a local struct pointer is passed alongside
 * another *Struct formal parameter (callee may write into the outer slot).
 *
 * Why: if a function f(&local_struct, outer_struct_ptr) is called and the
 *      callee assigns through outer_struct_ptr, it may overwrite local_struct
 *      whose lifetime is bounded to the caller's frame — a stack escape.
 *      This check prevents that by scanning all arg pairs: if one arg is
 *      &local_named_struct and another arg's formal is *NamedStruct (from a
 *      longer-lived source), reject with a diagnostic.
 * Contract: NULL module/arena/ctx or call_expr_ref<=0 -> 0 (no error).
 *           unsafe_depth>0 -> 0 (Cap-T001: unsafe block opt-out).
 *           XLANG_SKIP_STACK_ESCAPE env set -> 0 (diagnostic bypass).
 *           Returns -1 on escape detected, 0 otherwise.
 * Invariant: both args being &block_local is safe (same frame lifetime);
 *            only outer-origin *Struct triggers rejection.
 * Asm/Perf: O(num_args^2) — pairwise scan; cold path (typeck, not emit).
 * PLATFORM: SHARED.
 */
static int32_t pipeline_typeck_check_call_struct_stack_escape_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         int32_t call_expr_ref, struct ast_PipelineDepCtx *ctx) {
  int32_t func_ix;
  int32_t num_args;
  int32_t np;
  int32_t src_i;
  int32_t dst_j;
  int32_t line;
  int32_t col;
  if (!module || !arena || !ctx || call_expr_ref <= 0)
    return 0;
  /* Cap-T001: mega parser/typeck/codegen whole-body unsafe may pass &local with *Struct outer. */
  if (pipeline_dep_ctx_typeck_unsafe_depth_at(ctx) > 0)
    return 0;
  func_ix = pipeline_typeck_resolve_call_func_index_c(module, arena, call_expr_ref);
  if (func_ix < 0)
    return 0;
  num_args = pipeline_expr_call_num_args_at(arena, call_expr_ref);
  np = pipeline_module_func_num_params_at(module, func_ix);
  if (num_args != np || num_args < 2)
    return 0;
  if (link_abi_getenv("XLANG_SKIP_STACK_ESCAPE") != NULL)
    return 0;
  for (src_i = 0; src_i < num_args; src_i++) {
    int32_t arg_ref = pipeline_expr_call_arg_ref(arena, call_expr_ref, src_i);
    int32_t arg_ty;
    int32_t arg_elem;
    if (!typeck_expr_is_addr_of_block_local_c(module, arena, ctx, arg_ref))
      continue;
    /** 仅当 &local 的类型是 *Struct 时才触发（&local_i32 不逃逸）。 */
    arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
    if (arg_ty <= 0)
      continue;
    if (pipeline_type_kind_ord_at(arena, arg_ty) != (int32_t)ast_TypeKind_TYPE_PTR)
      continue;
    arg_elem = pipeline_type_elem_ref_at(arena, arg_ty);
    if (arg_elem <= 0 || !typeck_type_is_named_struct_c(module, arena, arg_elem))
      continue;
    for (dst_j = 0; dst_j < num_args; dst_j++) {
      int32_t param_ref;
      int32_t elem_ref;
      int32_t other_arg;
      if (dst_j == src_i)
        continue;
      param_ref = pipeline_module_func_param_type_ref_at(module, func_ix, dst_j);
      if (param_ref <= 0 ||
          pipeline_type_kind_ord_at(arena, param_ref) != (int32_t)ast_TypeKind_TYPE_PTR)
        continue;
      elem_ref = pipeline_type_elem_ref_at(arena, param_ref);
      if (elem_ref <= 0 || !typeck_type_is_named_struct_c(module, arena, elem_ref))
        continue;
      /**
       * 另一实参若也是「本函数块局部」的取址，则两指针同帧栈寿命，不是 outer。
       * 误报例：emit/main 中 pipeline(..., &out, &ctx) 两个本地 struct。
       * 仅当另一 *Struct 来自更长寿命（参数/堆/外层）时才拒。
       */
      other_arg = pipeline_expr_call_arg_ref(arena, call_expr_ref, dst_j);
      if (typeck_expr_is_addr_of_block_local_c(module, arena, ctx, other_arg))
        continue;
      line = pipeline_expr_line_at(arena, call_expr_ref);
      col = pipeline_expr_col_at(arena, call_expr_ref);
      lsp_diag_report_typeck((int)line, (int)col,
                             "struct stack escape: cannot pass address of local struct with outer struct pointer");
      return -1;
    }
  }
  return 0;
}

/* wave1233 G.7: pipeline_typeck_check_call_slice_region_c migrated from
 * pipeline_glue.c to this file's EOF (colocated with
 * pipeline_typeck_check_slice_region_assign_c — M-3 slice region domain).
 * Static same-TU: typeck_check_call_ptr_struct_compat_c fwd decl below
 * (def in method_call.c #include at glue.c L3986 > region_assign.c #include
 * at L3576). Extern same-TU: check_extern_call_unsafe_boundary_c fwd decl
 * below (def in check_expr.c #include at glue.c L4089). Sole extern caller:
 * typeck.x typeck_check_expr_call + typeck_gen seed. PLATFORM: SHARED. */
static int32_t typeck_check_call_ptr_struct_compat_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                     int32_t call_expr_ref, int32_t param_ref, int32_t arg_ref);

/** LANG-007：S0 extern 边界（定义见 check_expr.c #include at glue.c L4089；call_slice_region 挂此检查）。 */
int32_t pipeline_typeck_check_extern_call_unsafe_boundary_c(struct ast_Module *module,
                                                            struct ast_ASTArena *arena, int32_t expr_ref,
                                                            struct ast_PipelineDepCtx *ctx);

/**
 * M-3：.x typeck CALL 实参 slice 域检查；解析 callee 后逐实参对照形参域标签。
 * wave1233 G.7: migrated from pipeline_glue.c to here (colocated with
 * pipeline_typeck_check_slice_region_assign_c — M-3 slice region domain).
 */
int32_t pipeline_typeck_check_call_slice_region_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  int32_t call_expr_ref, struct ast_PipelineDepCtx *ctx) {
  int32_t func_ix;
  int32_t dep_ix;
  int32_t num_args;
  int32_t np;
  int32_t i;
  int32_t arg_ref;
  int32_t param_ref;
  int32_t arg_ty;
  struct ast_Module *callee_mod;
  if (!module || !arena || call_expr_ref <= 0)
    return 0;
  /**
   * LANG-007 belt：旧 typeck_gen 的 typeck_check_expr_call 内联路径不经
   * pipeline_typeck_check_expr_call_c，但仍调用本函数做 slice region；在此再挂 S0 extern 边界。
   * （新路径已在 pipeline_typeck_check_expr_call_c 内检查；重复检查幂等。）
   */
  if (pipeline_typeck_check_extern_call_unsafe_boundary_c(module, arena, call_expr_ref, ctx) != 0)
    return -1;
  func_ix = pipeline_expr_call_resolved_func_index_at(arena, call_expr_ref);
  dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, call_expr_ref);
  if (func_ix < 0)
    func_ix = pipeline_typeck_resolve_call_func_index_c(module, arena, call_expr_ref);
  if (func_ix < 0)
    return 0;
  callee_mod = module;
  if (dep_ix >= 0 && ctx) {
    struct ast_Module *dm = pipeline_dep_ctx_module_at(ctx, dep_ix);
    if (dm)
      callee_mod = dm;
  }
  num_args = pipeline_expr_call_num_args_at(arena, call_expr_ref);
  np = pipeline_module_func_num_params_at(callee_mod, func_ix);
  if (num_args != np)
    return 0;
  for (i = 0; i < num_args; i++) {
    int32_t arg_kind;
    int32_t param_kind;
    arg_ref = pipeline_expr_call_arg_ref(arena, call_expr_ref, i);
    param_ref = pipeline_module_func_param_type_ref_at(callee_mod, func_ix, i);
    /*
     * wave332 Cap residual pure: call-arg ARRAY_LIT → TYPE_SLICE / TYPE_ARRAY param.
     * Root: args are check_expr'd *before* resolve, so no param type is available then;
     * bare `[1,2,3]` never stamps → host emit falls to `(uint8_t[]){…}` while the formal
     * is `struct xlang_slice_* *` (run garbage / Ubuntu freestanding wrong).
     * Authority (G.7): reuse pipeline_typeck_coerce_init_array_vector_lit_to_decl_c
     * (let-init wave328 / assign wave331). After stamp, host emit_call_arg_slice_abi
     * emits `&(struct xlang_slice_T){ .data=(E[]){…}, .length=N }`.
     * PLATFORM: SHARED typeck — runs on product path (check_call_slice_region is the
     * post-resolve single authority for both typeck.x and glue call).
     */
    if (arg_ref > 0 && param_ref > 0) {
      arg_kind = pipeline_expr_kind_ord_at(arena, arg_ref);
      param_kind = pipeline_type_kind_ord_at(arena, param_ref);
      (void)pipeline_typeck_coerce_init_array_vector_lit_to_decl_c(arena, arg_ref, param_ref,
                                                                   param_kind, arg_kind);
    }
    arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
    if (pipeline_typeck_check_slice_region_assign_c(arena, arg_ref, param_ref, arg_ty) != 0)
      return -1;
    if (typeck_check_call_ptr_struct_compat_c(module, arena, call_expr_ref, param_ref, arg_ref) != 0)
      return -1;
  }
  /**
   * WPO-S3：&local struct 与 *Struct 形参同传 → 拒（外层槽逃逸）。
   * PLATFORM: SHARED — Cap-T001: skip when already inside unsafe { } (same gate as call_struct_stack_escape).
   * G.7 note: body mirrors pipeline_typeck_check_call_struct_stack_escape_c for dep-resolved callee_mod.
   */
  if (ctx && num_args >= 2 && link_abi_getenv("XLANG_SKIP_STACK_ESCAPE") == NULL &&
      pipeline_dep_ctx_typeck_unsafe_depth_at(ctx) <= 0) {
    int32_t src_i;
    int32_t dst_j;
    for (src_i = 0; src_i < num_args; src_i++) {
      int32_t stack_arg = pipeline_expr_call_arg_ref(arena, call_expr_ref, src_i);
      int32_t stack_arg_ty;
      int32_t stack_arg_elem;
      if (!typeck_expr_is_addr_of_block_local_c(module, arena, ctx, stack_arg))
        continue;
      /** 仅当 &local 的类型是 *Struct 时才触发（&local_i32 不逃逸）。 */
      stack_arg_ty = pipeline_expr_resolved_type_ref(arena, stack_arg);
      if (stack_arg_ty <= 0)
        continue;
      if (pipeline_type_kind_ord_at(arena, stack_arg_ty) != (int32_t)ast_TypeKind_TYPE_PTR)
        continue;
      stack_arg_elem = pipeline_type_elem_ref_at(arena, stack_arg_ty);
      if (stack_arg_elem <= 0 || !typeck_type_is_named_struct_c(module, arena, stack_arg_elem))
        continue;
      for (dst_j = 0; dst_j < num_args; dst_j++) {
        int32_t param_ref2;
        int32_t elem_ref;
        int32_t line;
        int32_t col;
        int32_t other_arg;
        if (dst_j == src_i)
          continue;
        param_ref2 = pipeline_module_func_param_type_ref_at(callee_mod, func_ix, dst_j);
        if (param_ref2 <= 0 ||
            pipeline_type_kind_ord_at(arena, param_ref2) != (int32_t)ast_TypeKind_TYPE_PTR)
          continue;
        elem_ref = pipeline_type_elem_ref_at(arena, param_ref2);
        if (elem_ref <= 0 || !typeck_type_is_named_struct_c(module, arena, elem_ref))
          continue;
        /* 同帧 &local 兄弟实参：非 outer（与 pipeline_typeck_check_call_struct_stack_escape_c 一致） */
        other_arg = pipeline_expr_call_arg_ref(arena, call_expr_ref, dst_j);
        if (typeck_expr_is_addr_of_block_local_c(module, arena, ctx, other_arg))
          continue;
        line = pipeline_expr_line_at(arena, call_expr_ref);
        col = pipeline_expr_col_at(arena, call_expr_ref);
        lsp_diag_report_typeck((int)line, (int)col,
                               "struct stack escape: cannot pass address of local struct with outer struct pointer");
        return -1;
      }
    }
  }
  return 0;
}

/* wave1234 G.7: pipeline_typeck_check_block_one_region_c migrated from
 * pipeline_glue.c to this file's EOF (colocated with with_arena scope +
 * region scope push/pop — M-3 / MEM-C1 region dispatch domain).
 * Dependencies visible via earlier fwd decls in glue.c (before #include at
 * L3576):
 *   - pipeline_block_region_body_ref / _is_unsafe / _with_arena_cap_ref /
 *     _label_len / _label_copy64 (ast_pool_block.c via ast_pool.c #include L2839)
 *   - pipeline_typeck_unsafe_depth_push_c / _pop_c (fwd at glue.c L3238-3239;
 *     definitions in pipeline_typeck_check_block.c #include L3959)
 *   - typeck_with_arena_scope_push_c / _pop_c (defined at L315/322 this file)
 *   - pipeline_dep_ctx_scope_region_push_c / _pop_c (defined in this file)
 *   - typeck_check_block (extern decl inside function body)
 * Sole extern caller: typeck_gen.c L9100 + typeck.x seed. PLATFORM: SHARED. */

/**
 * M-3 / MEM-C1：typeck 单条 region 或 with_arena 块。
 * with_arena 无域标签，旧实现 label_len<=0 直接 return 0 会跳过体块 typeck，导致 AL-04 assign 逃逸漏报。
 */
int32_t pipeline_typeck_check_block_one_region_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                 int32_t block_ref, int32_t region_idx, int32_t return_type_ref,
                                                 struct ast_PipelineDepCtx *ctx) {
  uint8_t label[128];
  int32_t label_len;
  int32_t body_ref;
  int32_t wa_cap;
  int32_t rc;
  extern int32_t typeck_check_block(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                    int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
  if (!module || !arena || !ctx || block_ref <= 0 || region_idx < 0)
    return 0;
  body_ref = pipeline_block_region_body_ref(arena, block_ref, region_idx);
  if (body_ref <= 0)
    return 0;
  if (pipeline_block_region_is_unsafe(arena, block_ref, region_idx)) {
    int32_t saved_ud;
    saved_ud = pipeline_typeck_unsafe_depth_push_c(ctx);
    rc = typeck_check_block(module, arena, body_ref, return_type_ref, ctx);
    pipeline_typeck_unsafe_depth_pop_c(ctx, saved_ud);
    return rc;
  }
  wa_cap = pipeline_block_region_with_arena_cap_ref(arena, block_ref, region_idx);
  if (wa_cap > 0) {
    /** MEM-C1：push with_arena 栈，使 check_expr_impl_mega / post-scan 能报 allocator region escape。 */
    typeck_with_arena_scope_push_c(body_ref);
    rc = typeck_check_block(module, arena, body_ref, return_type_ref, ctx);
    typeck_with_arena_scope_pop_c();
    return rc;
  }
  label_len = pipeline_block_region_label_len(arena, block_ref, region_idx);
  if (label_len <= 0)
    return 0;
  pipeline_block_region_label_copy64(arena, block_ref, region_idx, label);
  if (pipeline_dep_ctx_scope_region_push_c(ctx, label, label_len) != 0)
    return -1;
  rc = typeck_check_block(module, arena, body_ref, return_type_ref, ctx);
  pipeline_dep_ctx_scope_region_pop_c(ctx);
  return rc;
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
