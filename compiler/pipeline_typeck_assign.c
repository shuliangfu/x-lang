/**
 * pipeline_typeck_assign.c — typeck assign domain slice (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega EXPR_ASSIGN / compound assign:
 * LHS/RHS check, const immutability gate, lit/binop coerce, mismatch diags,
 * slice-region post-check.
 *
 * G.7: single product-mega assign path — typeck.x twin must stay aligned;
 * do not open a second assign checker in emit or a parallel glue copy.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after
 * check_expr_deref and before pipeline_typeck_soa.c.
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/* Bodies later in pipeline_glue.c (coerce family / region assign). */
int32_t pipeline_typeck_coerce_init_lit_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref, int32_t decl_ty_ref,
                                                  int32_t decl_kind, int32_t init_kind);
int32_t pipeline_typeck_coerce_init_int_binop_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                        int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind);
int32_t pipeline_typeck_coerce_init_float_lit_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                        int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind);
int32_t pipeline_typeck_coerce_init_array_vector_lit_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                               int32_t decl_ty_ref, int32_t decl_kind,
                                                               int32_t init_kind);
int32_t pipeline_typeck_check_slice_region_assign_c(struct ast_ASTArena *arena, int32_t site_expr_ref,
                                                    int32_t expect_ref, int32_t src_ref);
int32_t pipeline_typeck_check_struct_stack_escape_assign_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                           int32_t site_expr_ref, int32_t left_ref, int32_t right_ref,
                                                           struct ast_PipelineDepCtx *ctx);

static int32_t pipeline_typeck_lit_fits_named_i16_u16_c(struct ast_ASTArena *arena, int32_t ty_ref, int32_t int_val) {
  uint8_t nm[128];
  int32_t nlen;

  if (!arena || ty_ref <= 0 || pipeline_type_kind_ord_at(arena, ty_ref) != (int32_t)ast_TypeKind_TYPE_NAMED)
    return 0;
  nlen = pipeline_type_named_name_into(arena, ty_ref, nm);
  if (nlen == 3 && nm[0] == (uint8_t)'i' && nm[1] == (uint8_t)'1' && nm[2] == (uint8_t)'6')
    return int_val >= -32768 && int_val <= 32767;
  if (nlen == 3 && nm[0] == (uint8_t)'u' && nm[1] == (uint8_t)'1' && nm[2] == (uint8_t)'6')
    return int_val >= 0 && int_val <= 65535;
  return 0;
}

/**
 * typeck.x::typeck_check_expr_assign 的 C 委托：EXPR_ASSIGN / 复合赋值左右子式 check、字面量收窄与 mismatch 诊断。
 */
int32_t pipeline_typeck_check_slice_region_assign_c(struct ast_ASTArena *arena, int32_t site_expr_ref,
                                                    int32_t expect_ref, int32_t src_ref);

int32_t pipeline_typeck_check_struct_stack_escape_assign_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                           int32_t site_expr_ref, int32_t left_ref, int32_t right_ref,
                                                           struct ast_PipelineDepCtx *ctx);

int32_t pipeline_typeck_check_expr_assign_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  int32_t expr_kind;
  int32_t left_ref;
  int32_t right_ref;
  int32_t line;
  int32_t col;
  int32_t lt;
  int32_t rt;
  int32_t rt_after;
  int32_t compound_flag;
  int32_t lt_kind;
  int32_t rhs_kind;
  int32_t lhs_kind;
  int32_t int_val;
  int32_t ev;
  int32_t then_r;
  int32_t else_r;
  uint8_t *eb_ptr;
  uint8_t *gb_ptr;
  int32_t el;
  int32_t gl;
  /* wave643: 1 when compound *T +=/-= integer offset accepted (G.7 ≡ typeck.x twin). */
  int32_t ptr_compound_offset_ok = 0;

  if (!arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return 0;
  g_typeck_active_module = module;
  expr_kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  line = pipeline_expr_line_at(arena, expr_ref);
  col = pipeline_expr_col_at(arena, expr_ref);
  compound_flag = 1;
  if (expr_kind == (int32_t)ast_ExprKind_EXPR_ASSIGN)
    compound_flag = 0;
  /*
   * wave472 L4: product mega path uses this C assign (not typeck.x alone).
   * Do not pass function return ambient into assign LHS — wave465 field ambient
   * then rewrote enum field stores (out.method = m → expected ?/S found Method).
   * PLATFORM: SHARED — keep typeck.x twin at expected 0.
   */
  if (pipeline_typeck_check_expr_c(module, arena, left_ref, 0, ctx) != 0)
    return -1;
  /*
   * wave678 Cap residual: const binding is immutable (docs/06). Prior assign
   * path never checked const vs let → `const x: i32 = 1; x = 2` typeck-green
   * (host-C may even rewrite a non-const local). G.7: single gate on product
   * mega assign — VAR LHS only; block parent chain (inner-first) then top-level
   * const. let remains reassignable; mut is spelling-only (wave385).
   * Twin: typeck.x + seed typeck_gen same commit. PLATFORM: SHARED.
   */
  {
    int32_t lhs_kind_c = pipeline_expr_kind_ord_at(arena, left_ref);
    if (lhs_kind_c == (int32_t)ast_ExprKind_EXPR_VAR) {
      uint8_t vbuf_c[128];
      int32_t vnlen_c = pipeline_expr_var_name_len(arena, left_ref);
      int32_t bind_kind = -1;
      extern int32_t pipeline_block_name_binding_kind(struct ast_ASTArena *a, int32_t block_ref,
                                                     uint8_t *vname, int32_t vlen);
      extern int32_t pipeline_module_top_level_name_is_const(struct ast_Module *m, uint8_t *vname,
                                                            int32_t vlen);
      extern void driver_diagnostic_typeck_assign_to_const(int32_t line, int32_t col);
      if (vnlen_c > 0 && vnlen_c < 128) {
        memset(vbuf_c, 0, sizeof(vbuf_c));
        pipeline_expr_var_name_into(arena, left_ref, &vbuf_c[0]);
        if (ctx && ctx->current_block_ref > 0)
          bind_kind = pipeline_block_name_binding_kind(arena, ctx->current_block_ref, &vbuf_c[0], vnlen_c);
        if (bind_kind < 0 && module)
          bind_kind = pipeline_module_top_level_name_is_const(module, &vbuf_c[0], vnlen_c) != 0 ? 1 : -1;
        if (bind_kind == 1) {
          driver_diagnostic_typeck_assign_to_const(line, col);
          return -1;
        }
      }
    }
  }
  lt = pipeline_typeck_expr_type_ref_c(arena, left_ref);
  {
    int32_t rhs_ctx = return_type_ref;
    if (!ast_ref_is_null(lt))
      rhs_ctx = lt;
    /*
     * wave643 Cap residual: product mega path is this C assign (not typeck.x alone).
     * Compound p += n / p -= n is C-like pointer arithmetic (≡ p = p ± n): RHS is an
     * integer offset, not *T. Prior rhs_ctx=lt + type_refs_equal → expected *i32 found
     * i32 while p = p + 1 greened (wave285). G.7: complete same assign authority; emit
     * already scales (wave642). Twin: typeck.x + seed typeck_gen same semantics.
     * PLATFORM: SHARED.
     */
    if (compound_flag != 0 && !ast_ref_is_null(lt) &&
        (expr_kind == (int32_t)ast_ExprKind_EXPR_ADD_ASSIGN ||
         expr_kind == (int32_t)ast_ExprKind_EXPR_SUB_ASSIGN)) {
      lt_kind = pipeline_type_kind_ord_at(arena, lt);
      if (lt_kind == (int32_t)ast_TypeKind_TYPE_PTR)
        rhs_ctx = 0;
    }
    if (pipeline_typeck_check_expr_c(module, arena, right_ref, rhs_ctx, ctx) != 0)
      return -1;
  }
  if (ast_ref_is_null(left_ref) || ast_ref_is_null(right_ref))
    return 0;
  if (ast_ref_is_null(lt))
    lt = pipeline_typeck_expr_type_ref_c(arena, left_ref);
  rt_after = pipeline_typeck_expr_type_ref_c(arena, right_ref);
  if (!ast_ref_is_null(lt) && lt > 0) {
    rhs_kind = pipeline_expr_kind_ord_at(arena, right_ref);
    lt_kind = pipeline_type_kind_ord_at(arena, lt);
    /*
     * wave308: assign RHS bare EXPR_LIT — G.7 reuse coerce_init_lit (full i64).
     * wave310: assign RHS EXPR_NEG / int binop — G.7 reuse coerce_init_int_binop
     * (product mega path calls this C assign, not typeck.x typeck_check_expr_assign;
     * typeck.x mirror alone left Ubuntu assign `u8=-1` / `u64 a=-1` found i32).
     * wave316: assign/compound RHS FLOAT_LIT / `-float` — G.7 reuse coerce_init_float_lit
     * (closes `a:f32=6.0` / `a+=2.0` / `a=-6.0`; product path must update this C).
     * wave331: assign RHS ARRAY_LIT → TYPE_ARRAY / TYPE_SLICE — G.7 reuse
     * coerce_init_array_vector_lit (let-init wave328 already stamps TYPE_SLICE;
     * product assign lacked it → `a = []` / `a = [1,2]` found `?`).
     * Named i16/u16 still use lit_fits helper when lit coerce misses TYPE_NAMED.
     * PLATFORM: SHARED — typeck lit/binop/float/array-lit assign coerce.
     */
    if (rhs_kind == (int32_t)ast_ExprKind_EXPR_ARRAY_LIT &&
        (lt_kind == (int32_t)ast_TypeKind_TYPE_ARRAY ||
         lt_kind == (int32_t)ast_TypeKind_TYPE_SLICE)) {
      if (pipeline_typeck_coerce_init_array_vector_lit_to_decl_c(arena, right_ref, lt, lt_kind,
                                                                rhs_kind) != 0)
        rt_after = lt;
    } else if (rhs_kind == (int32_t)ast_ExprKind_EXPR_LIT) {
      if (pipeline_typeck_coerce_init_lit_to_decl_c(arena, right_ref, lt, lt_kind, rhs_kind) == 0 &&
          expr_kind == (int32_t)ast_ExprKind_EXPR_ASSIGN) {
        int_val = pipeline_expr_int_val_at(arena, right_ref);
        if (pipeline_typeck_lit_fits_named_i16_u16_c(arena, lt, int_val))
          pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
      }
      (void)rt_after;
    } else if (!pipeline_typeck_type_refs_equal_c(arena, lt, rt_after)) {
      (void)pipeline_typeck_coerce_init_float_lit_to_decl_c(arena, right_ref, lt, lt_kind, rhs_kind);
      (void)pipeline_typeck_coerce_init_int_binop_to_decl_c(arena, right_ref, lt, lt_kind, rhs_kind);
    }
  }
  rt = pipeline_typeck_expr_type_ref_c(arena, right_ref);
  if (!ast_ref_is_null(lt) && !ast_ref_is_null(rt) &&
      !pipeline_typeck_type_refs_equal_c(arena, lt, rt)) {
    rhs_kind = pipeline_expr_kind_ord_at(arena, right_ref);
    if (rhs_kind == (int32_t)ast_ExprKind_EXPR_TERNARY) {
      lt_kind = pipeline_type_kind_ord_at(arena, lt);
      if (lt_kind == (int32_t)ast_TypeKind_TYPE_U8) {
        then_r = pipeline_expr_if_then_ref_at(arena, right_ref);
        else_r = pipeline_expr_if_else_ref_at(arena, right_ref);
        if (pipeline_expr_kind_ord_at(arena, then_r) == (int32_t)ast_ExprKind_EXPR_LIT &&
            pipeline_expr_kind_ord_at(arena, else_r) == (int32_t)ast_ExprKind_EXPR_LIT) {
          int_val = pipeline_expr_int_val_at(arena, then_r);
          ev = pipeline_expr_int_val_at(arena, else_r);
          if (int_val >= 0 && int_val <= 255 && ev >= 0 && ev <= 255) {
            pipeline_expr_set_resolved_type_ref(arena, then_r, lt);
            pipeline_expr_set_resolved_type_ref(arena, else_r, lt);
            pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
            rt = lt;
          }
        }
      }
    }
  }
  if (!ast_ref_is_null(lt) && ast_ref_is_null(rt)) {
    rhs_kind = pipeline_expr_kind_ord_at(arena, right_ref);
    if (rhs_kind == (int32_t)ast_ExprKind_EXPR_CALL) {
      pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
      rt = lt;
    }
    /** STRING_LIT(kind 59)：与 typeck.x 对齐。seed/impl 可能未给字面量定型，
     *  回填 lhs 类型，避免 `m: *u8; m = ""` 误报 expected *u8, found ?。
     *  codegen 依 kind=59 生成 (uint8_t[]){...}，不依赖 resolved 切片类型。 */
    if (rhs_kind == GLUE_EXPR_STRING_LIT_ORD) {
      pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
      rt = lt;
    }
  }
  if (ast_ref_is_null(lt) && !ast_ref_is_null(rt)) {
    lhs_kind = pipeline_expr_kind_ord_at(arena, left_ref);
    if (lhs_kind == (int32_t)ast_ExprKind_EXPR_VAR || lhs_kind == (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS ||
        lhs_kind == (int32_t)ast_ExprKind_EXPR_INDEX) {
      pipeline_expr_set_resolved_type_ref(arena, left_ref, rt);
      lt = rt;
    }
  }
  /*
   * wave643: *T +=/-= integer offset — accept without lt==rt and without stamping
   * RHS to *T (emit scales). Reject *T += *U / float / etc. G.7 ≡ wave285 ptr±int
   * + typeck.x twin. PLATFORM: SHARED product mega path.
   */
  if (compound_flag != 0 && !ast_ref_is_null(lt) && !ast_ref_is_null(rt) &&
      (expr_kind == (int32_t)ast_ExprKind_EXPR_ADD_ASSIGN ||
       expr_kind == (int32_t)ast_ExprKind_EXPR_SUB_ASSIGN)) {
    lt_kind = pipeline_type_kind_ord_at(arena, lt);
    if (lt_kind == (int32_t)ast_TypeKind_TYPE_PTR) {
      int32_t rt_kind_pca = pipeline_type_kind_ord_at(arena, rt);
      if (rt_kind_pca == (int32_t)ast_TypeKind_TYPE_I32 ||
          rt_kind_pca == (int32_t)ast_TypeKind_TYPE_USIZE ||
          rt_kind_pca == (int32_t)ast_TypeKind_TYPE_ISIZE ||
          rt_kind_pca == (int32_t)ast_TypeKind_TYPE_U8 ||
          rt_kind_pca == (int32_t)ast_TypeKind_TYPE_U32 ||
          rt_kind_pca == (int32_t)ast_TypeKind_TYPE_U64 ||
          rt_kind_pca == (int32_t)ast_TypeKind_TYPE_I64) {
        ptr_compound_offset_ok = 1;
      } else {
        eb_ptr = driver_typeck_diag_scratch_expect();
        gb_ptr = driver_typeck_diag_scratch_found();
        el = pipeline_typeck_diag_fmt_type_into_c(arena, lt, eb_ptr, 96);
        gl = pipeline_typeck_diag_fmt_type_into_c(arena, rt, gb_ptr, 96);
        driver_diagnostic_typeck_assign_mismatch(compound_flag, line, col, eb_ptr, el, gb_ptr, gl);
        return -1;
      }
    }
  }
  if (!ast_ref_is_null(lt) && !ast_ref_is_null(rt)) {
    if (!pipeline_typeck_type_refs_equal_c(arena, lt, rt) && ptr_compound_offset_ok == 0) {
      /* 整型隐式拓宽：i32→isize/i64/usize… + NAMED i8/i16/u16（typeck_integer_widen_ok_refs）
       * wave314: + f32→f64 float widen (typeck_float_widen_ok). */
      if (expr_kind == (int32_t)ast_ExprKind_EXPR_ASSIGN) {
        int32_t rt_kind_w;
        lt_kind = pipeline_type_kind_ord_at(arena, lt);
        rt_kind_w = pipeline_type_kind_ord_at(arena, rt);
        if (pipeline_typeck_integer_widen_ok_refs_c(arena, lt, rt)) {
          pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
          rt = lt;
        } else if (pipeline_typeck_float_widen_ok_c(lt_kind, rt_kind_w)) {
          /* wave314: accept f32→f64 without stamp — freestanding emit cvtss2sd. */
        } else {
          /* wave310: prefer G.7 int_binop coerce (covers U8/U16/NEG); keep
           * prior hard set as fallback for ADD/SUB/MUL/DIV on wide ints. */
          rhs_kind = pipeline_expr_kind_ord_at(arena, right_ref);
          if (pipeline_typeck_coerce_init_int_binop_to_decl_c(arena, right_ref, lt, lt_kind, rhs_kind) != 0) {
            rt = lt;
          } else if ((lt_kind == (int32_t)ast_TypeKind_TYPE_I32 || lt_kind == (int32_t)ast_TypeKind_TYPE_I64 ||
               lt_kind == (int32_t)ast_TypeKind_TYPE_U64 || lt_kind == (int32_t)ast_TypeKind_TYPE_USIZE ||
               lt_kind == (int32_t)ast_TypeKind_TYPE_ISIZE) &&
              (rhs_kind == (int32_t)ast_ExprKind_EXPR_ADD || rhs_kind == (int32_t)ast_ExprKind_EXPR_SUB ||
               rhs_kind == (int32_t)ast_ExprKind_EXPR_MUL || rhs_kind == (int32_t)ast_ExprKind_EXPR_DIV)) {
            pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
            rt = lt;
          }
        }
      }
      if (!pipeline_typeck_type_refs_equal_c(arena, lt, rt)) {
        int32_t lk = pipeline_type_kind_ord_at(arena, lt);
        int32_t rk = pipeline_type_kind_ord_at(arena, rt);
        /* wave314: f32→f64 is not a typeck mismatch. */
        if (!pipeline_typeck_float_widen_ok_c(lk, rk)) {
          eb_ptr = driver_typeck_diag_scratch_expect();
          gb_ptr = driver_typeck_diag_scratch_found();
          el = pipeline_typeck_diag_fmt_type_into_c(arena, lt, eb_ptr, 96);
          gl = pipeline_typeck_diag_fmt_type_into_c(arena, rt, gb_ptr, 96);
          driver_diagnostic_typeck_assign_mismatch(compound_flag, line, col, eb_ptr, el, gb_ptr, gl);
          return -1;
        }
      }
    }
  }
  if (!ast_ref_is_null(lt) && ast_ref_is_null(rt)) {
    rhs_kind = pipeline_expr_kind_ord_at(arena, right_ref);
    if (rhs_kind == (int32_t)ast_ExprKind_EXPR_SUB || rhs_kind == (int32_t)ast_ExprKind_EXPR_ADD) {
      lt_kind = pipeline_type_kind_ord_at(arena, lt);
      if (lt_kind == (int32_t)ast_TypeKind_TYPE_USIZE) {
        pipeline_expr_set_resolved_type_ref(arena, right_ref, lt);
        rt = lt;
      }
    }
  }
  eb_ptr = driver_typeck_diag_scratch_expect();
  gb_ptr = driver_typeck_diag_scratch_found();
  if (ast_ref_is_null(lt) && !ast_ref_is_null(rt)) {
    el = pipeline_typeck_diag_fmt_type_or_question_c(arena, lt, eb_ptr);
    gl = pipeline_typeck_diag_fmt_type_or_question_c(arena, rt, gb_ptr);
    driver_diagnostic_typeck_assign_mismatch(compound_flag, line, col, eb_ptr, el, gb_ptr, gl);
    return -1;
  }
  if (!ast_ref_is_null(lt) && ast_ref_is_null(rt)) {
    el = pipeline_typeck_diag_fmt_type_or_question_c(arena, lt, eb_ptr);
    gl = pipeline_typeck_diag_fmt_type_or_question_c(arena, rt, gb_ptr);
    driver_diagnostic_typeck_assign_mismatch(compound_flag, line, col, eb_ptr, el, gb_ptr, gl);
    return -1;
  }
  /** M-3：类型相等后再查 slice 域（i32[]<ra> vs i32[] elem 相同但域不同 / 逃逸）。 */
  if (!ast_ref_is_null(lt) && !ast_ref_is_null(rt) &&
      pipeline_typeck_type_refs_equal_c(arena, lt, rt)) {
    if (pipeline_typeck_check_slice_region_assign_c(arena, expr_ref, lt, rt) != 0)
      return -1;
  }
  return 0;
}

