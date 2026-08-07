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

/* wave1156 G.7: extern fwd decls for diag fmt cluster migrated to this
 * file's EOF. Callsites at lines 265-336 precede the EOF definitions. */
int32_t pipeline_typeck_diag_fmt_type_into_c(struct ast_ASTArena *arena, int32_t ref, uint8_t *out, int32_t cap);
int32_t pipeline_typeck_diag_fmt_type_or_question_c(struct ast_ASTArena *arena, int32_t ref, uint8_t *out);

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
  /* wave224: active module cell is pure BSS (G.7; no residual static write). */
  pipeline_typeck_active_module_set_c(module);
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

/**
 * Unified import count reader: prefer sidecar accessor, fall back to thin
 * Module field.
 *
 * Why: import count can be stored either in the parser sidecar (full parse
 * pipeline) or in the Module struct thin field (bootstrap/seed path). A
 * single reader avoids scattering two-path checks across import_segment_at,
 * map_import_binding, and import_overload_match consumers. Matches
 * typeck.x::module_num_imports.
 *
 * Invariant: returns 0 for NULL module; otherwise parser sidecar count if
 * >0, else module->num_imports.
 *
 * Asm/Perf: O(1) — one accessor call + one field read. Cold path — called
 * per import lookup in typeck_import_segment_at_c (glue.c:11627),
 * pipeline_typeck_map_import_binding_named_to_caller_c (glue.c:11706),
 * and import_overload_match (glue.c:12111).
 *
 * PLATFORM: SHARED — import count is platform-independent.
 *
 * wave1066 G.7: migrated from glue.c:11682 (body 9 LOC). Static
 * (non-extern): same-TU visibility — assign.c #include at L11324 < old
 * fwd L11618 < def L11682 < all callsites (L11627/11706/12111). Old fwd
 * decl at L11618 deleted (def now visible from #include point).
 * Dependencies: parser_get_module_num_imports (extern);
 * module->num_imports (struct field).
 */
static int32_t pipeline_typeck_module_num_imports_c(struct ast_Module *module) {
  int32_t n_imp;

  if (!module)
    return 0;
  n_imp = parser_get_module_num_imports(module);
  if (n_imp > 0)
    return n_imp;
  return module->num_imports;
}

/* ============================================================
 * wave1156 G.7: typeck diag fmt cluster (5 fns)
 * (migrated from pipeline_glue.c L7420-7579).
 *
 * Why here: pipeline_typeck_diag_fmt_type_at_c / _into_c /
 * _or_question_c format type_ref as readable ASCII for mismatch
 * diagnostics. The primary consumer is pipeline_typeck_check_expr_assign_c
 * (this file, lines 265-336 — 8 callsites for fmt_type_into /
 * fmt_type_or_question in assign mismatch diag paths). The glue.c
 * callsite at L8142 (check_expr_return return-type mismatch diag)
 * is the only other consumer — extern fwd decl added in glue.c.
 *
 * Cluster (5 fns, ~145 LOC):
 *   - pipeline_typeck_diag_append_lit_c (14 LOC; pure buffer copy)
 *   - pipeline_typeck_diag_append_u32_dec_c (28 LOC; u32 decimal)
 *   - pipeline_typeck_diag_fmt_type_at_c (92 LOC; type_ref → ASCII)
 *   - pipeline_typeck_diag_fmt_type_into_c (2 LOC; wrapper)
 *   - pipeline_typeck_diag_fmt_type_or_question_c (7 LOC; wrapper)
 *
 * Dependencies (all extern/header-declared):
 *   - pipeline_type_kind_ord_at / pipeline_type_named_name_into /
 *     pipeline_type_elem_ref_at / pipeline_type_array_size_at /
 *     pipeline_type_region_label_len_at / pipeline_type_region_label_into
 *     (all extern, header-declared)
 *   - ast_ref_is_null / ast_TypeKind_* (global enum)
 *   - intra-cluster calls (append_lit / append_u32_dec / fmt_type_at /
 *     fmt_type_into — same cluster, direct call)
 *
 * Visibility:
 *   - assign.c callsites at lines 265-336 PRECEDE the EOF definitions →
 *     extern fwd decls added at top of assign.c (lines 33-38 below).
 *   - glue.c callsite at L8142 PRECEDES assign.c #include at L8265 →
 *     extern fwd decl added in glue.c before L8142.
 *
 * PLATFORM: SHARED — pure type-formatting; no platform ABI dep.
 * ============================================================ */

/**
 * Diagnostic buffer append literal (matches typeck.x::typeck_diag_append_lit).
 */
int32_t pipeline_typeck_diag_append_lit_c(uint8_t *out, int32_t pos, int32_t cap, uint8_t *lit, int32_t lit_len) {
  int32_t p;
  int32_t i;

  p = pos;
  i = 0;
  while (i < lit_len && p >= 0 && p < cap) {
    out[p] = lit[i];
    p = p + 1;
    i = i + 1;
  }
  return p;
}

/**
 * Diagnostic buffer append decimal u32 (matches typeck.x::typeck_diag_append_u32_dec).
 */
int32_t pipeline_typeck_diag_append_u32_dec_c(uint8_t *out, int32_t pos, int32_t cap, int32_t v) {
  int32_t p;
  int32_t cnt;
  int32_t tc;
  int32_t k;
  int32_t tm;
  int32_t d;
  uint8_t zd[1];

  p = pos;
  if (v < 0 || p < 0 || p >= cap)
    return p;
  if (v == 0) {
    zd[0] = (uint8_t)'0';
    return pipeline_typeck_diag_append_lit_c(out, p, cap, zd, 1);
  }
  cnt = 0;
  tc = v;
  while (tc > 0) {
    cnt = cnt + 1;
    tc = tc / 10;
  }
  k = cnt - 1;
  tm = v;
  while (tm > 0) {
    d = tm % 10;
    tm = tm / 10;
    if ((pos + k) < 0 || (pos + k) >= cap)
      return p;
    out[pos + k] = (uint8_t)(d + 48);
    k = k - 1;
  }
  return pos + cnt;
}

/**
 * typeck.x::typeck_diag_fmt_type_at C delegate: format type ref as readable ASCII (no NUL written).
 */
int32_t pipeline_typeck_diag_fmt_type_at_c(struct ast_ASTArena *arena, int32_t ref, uint8_t *out, int32_t cur,
                                           int32_t cap) {
  static const uint8_t qmk[1] = { 63 };
  static const uint8_t lit_i32[3] = { 105, 51, 50 };
  static const uint8_t lit_bool[4] = { 98, 111, 111, 108 };
  static const uint8_t lit_u8[2] = { 117, 56 };
  static const uint8_t lit_u32[3] = { 117, 51, 50 };
  static const uint8_t lit_u64[3] = { 117, 54, 52 };
  static const uint8_t lit_i64[3] = { 105, 54, 52 };
  static const uint8_t lit_usize[5] = { 117, 115, 105, 122, 101 };
  static const uint8_t lit_isize[5] = { 105, 115, 105, 122, 101 };
  static const uint8_t lit_f32[3] = { 102, 51, 50 };
  static const uint8_t lit_f64[3] = { 102, 54, 52 };
  static const uint8_t star[1] = { 42 };
  static const uint8_t lbk[1] = { 91 };
  static const uint8_t rbk[1] = { 93 };
  static const uint8_t slo[2] = { 91, 93 };
  int32_t kind;
  int32_t nlen;
  uint8_t nm[128];
  int32_t elem_ref;
  int32_t asz;
  int32_t nex;
  int32_t p0;
  int32_t p1;
  int32_t p2;

  if (cur < 0 || cap <= 0 || cur >= cap)
    return cur;
  if (ast_ref_is_null(ref) || ref <= 0 || !arena || ref > arena->num_types)
    return pipeline_typeck_diag_append_lit_c(out, cur, cap, (uint8_t *)qmk, 1);
  kind = pipeline_type_kind_ord_at(arena, ref);
  if (kind == (int32_t)ast_TypeKind_TYPE_NAMED) {
    nlen = pipeline_type_named_name_into(arena, ref, nm);
    if (nlen > 0)
      return pipeline_typeck_diag_append_lit_c(out, cur, cap, nm, nlen);
  }
  if (kind == (int32_t)ast_TypeKind_TYPE_I32)
    return pipeline_typeck_diag_append_lit_c(out, cur, cap, (uint8_t *)lit_i32, 3);
  if (kind == (int32_t)ast_TypeKind_TYPE_BOOL)
    return pipeline_typeck_diag_append_lit_c(out, cur, cap, (uint8_t *)lit_bool, 4);
  if (kind == (int32_t)ast_TypeKind_TYPE_U8)
    return pipeline_typeck_diag_append_lit_c(out, cur, cap, (uint8_t *)lit_u8, 2);
  if (kind == (int32_t)ast_TypeKind_TYPE_U32)
    return pipeline_typeck_diag_append_lit_c(out, cur, cap, (uint8_t *)lit_u32, 3);
  if (kind == (int32_t)ast_TypeKind_TYPE_U64)
    return pipeline_typeck_diag_append_lit_c(out, cur, cap, (uint8_t *)lit_u64, 3);
  if (kind == (int32_t)ast_TypeKind_TYPE_I64)
    return pipeline_typeck_diag_append_lit_c(out, cur, cap, (uint8_t *)lit_i64, 3);
  if (kind == (int32_t)ast_TypeKind_TYPE_USIZE)
    return pipeline_typeck_diag_append_lit_c(out, cur, cap, (uint8_t *)lit_usize, 5);
  if (kind == (int32_t)ast_TypeKind_TYPE_ISIZE)
    return pipeline_typeck_diag_append_lit_c(out, cur, cap, (uint8_t *)lit_isize, 5);
  if (kind == (int32_t)ast_TypeKind_TYPE_F32)
    return pipeline_typeck_diag_append_lit_c(out, cur, cap, (uint8_t *)lit_f32, 3);
  if (kind == (int32_t)ast_TypeKind_TYPE_F64)
    return pipeline_typeck_diag_append_lit_c(out, cur, cap, (uint8_t *)lit_f64, 3);
  if (kind == (int32_t)ast_TypeKind_TYPE_VOID)
    return pipeline_typeck_diag_append_lit_c(out, cur, cap, (uint8_t *)qmk, 1);
  if (kind == (int32_t)ast_TypeKind_TYPE_PTR) {
    elem_ref = pipeline_type_elem_ref_at(arena, ref);
    nex = pipeline_typeck_diag_append_lit_c(out, cur, cap, (uint8_t *)star, 1);
    return pipeline_typeck_diag_fmt_type_at_c(arena, elem_ref, out, nex, cap);
  }
  if (kind == (int32_t)ast_TypeKind_TYPE_SLICE) {
    static const uint8_t lt_ch[1] = { 60 };
    static const uint8_t gt_ch[1] = { 62 };
    int32_t rlen;
    uint8_t rbuf[128];
    elem_ref = pipeline_type_elem_ref_at(arena, ref);
    nex = pipeline_typeck_diag_append_lit_c(out, cur, cap, (uint8_t *)slo, 2);
    nex = pipeline_typeck_diag_fmt_type_at_c(arena, elem_ref, out, nex, cap);
    rlen = pipeline_type_region_label_len_at(arena, ref);
    if (rlen > 0 && pipeline_type_region_label_into(arena, ref, rbuf) == rlen) {
      p0 = pipeline_typeck_diag_append_lit_c(out, nex, cap, (uint8_t *)lt_ch, 1);
      p1 = pipeline_typeck_diag_append_lit_c(out, p0, cap, rbuf, rlen);
      return pipeline_typeck_diag_append_lit_c(out, p1, cap, (uint8_t *)gt_ch, 1);
    }
    return nex;
  }
  if (kind == (int32_t)ast_TypeKind_TYPE_ARRAY) {
    elem_ref = pipeline_type_elem_ref_at(arena, ref);
    asz = pipeline_type_array_size_at(arena, ref);
    if (!ast_ref_is_null(elem_ref) && asz > 0) {
      p0 = pipeline_typeck_diag_append_lit_c(out, cur, cap, (uint8_t *)lbk, 1);
      p1 = pipeline_typeck_diag_append_u32_dec_c(out, p0, cap, asz);
      p2 = pipeline_typeck_diag_append_lit_c(out, p1, cap, (uint8_t *)rbk, 1);
      return pipeline_typeck_diag_fmt_type_at_c(arena, elem_ref, out, p2, cap);
    }
  }
  return pipeline_typeck_diag_append_lit_c(out, cur, cap, (uint8_t *)qmk, 1);
}

/** typeck.x::typeck_diag_fmt_type_into C delegate. */
int32_t pipeline_typeck_diag_fmt_type_into_c(struct ast_ASTArena *arena, int32_t ref, uint8_t *out, int32_t cap) {
  return pipeline_typeck_diag_fmt_type_at_c(arena, ref, out, 0, cap);
}

/** typeck.x::typeck_diag_fmt_type_or_question C delegate. */
int32_t pipeline_typeck_diag_fmt_type_or_question_c(struct ast_ASTArena *arena, int32_t ref, uint8_t *out) {
  static const uint8_t qmk[1] = { 63 };

  if (ast_ref_is_null(ref) || ref <= 0 || !arena || ref > arena->num_types)
    return pipeline_typeck_diag_append_lit_c(out, 0, 96, (uint8_t *)qmk, 1);
  return pipeline_typeck_diag_fmt_type_into_c(arena, ref, out, 96);
}

