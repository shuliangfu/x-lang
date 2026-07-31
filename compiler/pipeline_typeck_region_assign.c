/**
 * pipeline_typeck_region_assign.c — typeck region/escape assign-site domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega region / lifetime escape gates used
 * before assign/return type matching:
 * - M-3 slice region: conflict / escape helpers + check_slice_region_assign
 * - M-3 return slice region (operand stamp path)
 * - WPO-S3 struct stack-escape assign
 * - MEM-A3 scope-borrow assign/return + diag line/col + lval/ancestor helpers
 * - MEM-C1 with_arena scope stack + allocator region assign/return
 * - M-3 AL-06 return slice region in region-scope
 *
 * G.7: single product-mega region-assign gate path — typeck.x twins must stay
 * aligned; do not open a second escape checker in emit or a parallel glue copy.
 * Call-path stack escape (check_call_struct_stack_escape) and post-typeck
 * module scan remain in pipeline_glue.c (same TU; static with_arena state shared).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after
 * stack_local / addr_of_block_local helpers and before call_struct_stack_escape.
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/** M-3：slice 域冲突（expect/src 均带 label 且不同）返回 1。 */
static int32_t pipeline_typeck_slice_region_conflict_c(struct ast_ASTArena *arena, int32_t expect_ref,
                                                       int32_t src_ref) {
  int32_t ek;
  int32_t sk;
  uint8_t eb[128];
  uint8_t sb[128];
  if (!arena || expect_ref <= 0 || src_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, expect_ref) != (int32_t)ast_TypeKind_TYPE_SLICE ||
      pipeline_type_kind_ord_at(arena, src_ref) != (int32_t)ast_TypeKind_TYPE_SLICE)
    return 0;
  ek = pipeline_type_region_label_len_at(arena, expect_ref);
  sk = pipeline_type_region_label_len_at(arena, src_ref);
  if (ek <= 0 || sk <= 0)
    return 0;
  if (pipeline_type_region_label_into(arena, expect_ref, eb) != ek ||
      pipeline_type_region_label_into(arena, src_ref, sb) != sk)
    return 0;
  return (ek != sk || memcmp(eb, sb, (size_t)ek) != 0) ? 1 : 0;
}

/** M-3：域绑定 slice 逃逸到未标注域（src 有 label、expect 无）返回 1。 */
static int32_t pipeline_typeck_slice_region_escape_c(struct ast_ASTArena *arena, int32_t expect_ref,
                                                     int32_t src_ref) {
  if (!arena || expect_ref <= 0 || src_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, expect_ref) != (int32_t)ast_TypeKind_TYPE_SLICE ||
      pipeline_type_kind_ord_at(arena, src_ref) != (int32_t)ast_TypeKind_TYPE_SLICE)
    return 0;
  return (pipeline_type_region_label_len_at(arena, src_ref) > 0 &&
          pipeline_type_region_label_len_at(arena, expect_ref) <= 0)
             ? 1
             : 0;
}

/**
 * M-3：.x typeck 统一 slice 域 assign/let/实参检查；与 typeck.c typeck_check_slice_region_assign 措辞一致。
 * site_expr_ref 用于 line/col；返回 0 可接受，-1 已打印 typeck error。
 */
static void pipeline_typeck_expr_diag_line_col_c(struct ast_ASTArena *a, int32_t expr_ref, int32_t *line,
                                                 int32_t *col);

int32_t pipeline_typeck_check_slice_region_assign_c(struct ast_ASTArena *arena, int32_t site_expr_ref,
                                                    int32_t expect_ref, int32_t src_ref) {
  int32_t line;
  int32_t col;
  uint8_t sb[128];
  int32_t slen;
  uint8_t eb[128];
  int32_t elen;
  if (!arena || expect_ref <= 0 || src_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, expect_ref) != (int32_t)ast_TypeKind_TYPE_SLICE ||
      pipeline_type_kind_ord_at(arena, src_ref) != (int32_t)ast_TypeKind_TYPE_SLICE)
    return 0;
  line = 0;
  col = 0;
  pipeline_typeck_expr_diag_line_col_c(arena, site_expr_ref, &line, &col);
  if (pipeline_typeck_slice_region_escape_c(arena, expect_ref, src_ref)) {
    slen = pipeline_type_region_label_into(arena, src_ref, sb);
    sb[slen > 0 && slen < 64 ? slen : 0] = '\0';
    lsp_diag_report_typeck((int)line, (int)col,
                           "slice region escape: cannot assign <%.*s> slice to unbound T[]", (int)(slen > 0 ? slen : 0),
                           (const char *)sb);
    return -1;
  }
  if (pipeline_typeck_slice_region_conflict_c(arena, expect_ref, src_ref)) {
    elen = pipeline_type_region_label_into(arena, expect_ref, eb);
    slen = pipeline_type_region_label_into(arena, src_ref, sb);
    eb[elen > 0 && elen < 64 ? elen : 0] = '\0';
    sb[slen > 0 && slen < 64 ? slen : 0] = '\0';
    lsp_diag_report_typeck((int)line, (int)col, "slice region mismatch: expected <%.*s>, found <%.*s>",
                           (int)(elen > 0 ? elen : 0), (const char *)eb, (int)(slen > 0 ? slen : 0),
                           (const char *)sb);
    return -1;
  }
  return 0;
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
 */
int32_t pipeline_typeck_check_return_slice_region_c(struct ast_ASTArena *arena, int32_t ret_site_ref,
                                                    int32_t op_ref, int32_t func_return_ref) {
  int32_t got_ref;
  int32_t line;
  int32_t col;
  uint8_t sb[128];
  int32_t slen;
  uint8_t eb[128];
  int32_t elen;
  if (!arena || op_ref <= 0 || func_return_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, func_return_ref) != (int32_t)ast_TypeKind_TYPE_SLICE)
    return 0;
  got_ref = pipeline_expr_resolved_type_ref(arena, op_ref);
  if (got_ref <= 0 || pipeline_type_kind_ord_at(arena, got_ref) != (int32_t)ast_TypeKind_TYPE_SLICE)
    return 0;
  line = 0;
  col = 0;
  if (ret_site_ref > 0 && ret_site_ref <= arena->num_exprs) {
    line = pipeline_expr_line_at(arena, ret_site_ref);
    col = pipeline_expr_col_at(arena, ret_site_ref);
  }
  if (pipeline_typeck_slice_region_escape_c(arena, func_return_ref, got_ref)) {
    slen = pipeline_type_region_label_into(arena, got_ref, sb);
    sb[slen > 0 && slen < 64 ? slen : 0] = '\0';
    lsp_diag_report_typeck((int)line, (int)col,
                           "slice region escape: cannot return <%.*s> slice as unbound T[]",
                           (int)(slen > 0 ? slen : 0), (const char *)sb);
    return -1;
  }
  if (pipeline_typeck_slice_region_conflict_c(arena, func_return_ref, got_ref)) {
    elen = pipeline_type_region_label_into(arena, func_return_ref, eb);
    slen = pipeline_type_region_label_into(arena, got_ref, sb);
    eb[elen > 0 && elen < 64 ? elen : 0] = '\0';
    sb[slen > 0 && slen < 64 ? slen : 0] = '\0';
    lsp_diag_report_typeck((int)line, (int)col, "slice region mismatch in return: expected <%.*s>, found <%.*s>",
                           (int)(elen > 0 ? elen : 0), (const char *)eb, (int)(slen > 0 ? slen : 0),
                           (const char *)sb);
    return -1;
  }
  return 0;
}
