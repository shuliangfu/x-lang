/**
 * pipeline_typeck_coerce_init.c — typeck coerce-init domain slice (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega let/const/return/arg init coercion:
 * lit / float lit / enum field / named call / array|vector lit / vector binop /
 * int binop / struct lit / slice-from-array, plus thin dispatcher
 * pipeline_typeck_coerce_init_expr_to_decl_c.
 *
 * G.7: single product-mega coerce-init path — typeck.x twin must stay aligned;
 * assign / return / call arg sites must call these producers, not reimplement.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after
 * check_block_one_region and before check_expr_impl forward decls.
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/* typeck.x ensure path (also declared earlier in glue for fill_cl). */
extern int32_t typeck_ensure_struct_layout_from_struct_lit(struct ast_Module *module, struct ast_ASTArena *arena,
                                                           int32_t expr_ref);

/* wave1158 G.7: extern fwd decls for type_refs_equal / type_ref_is_bool /
 * expr_type_ref public wrappers migrated to this file's EOF (colocated with
 * wave1080-1083 static implementations). Callsites at L277 / L816 precede the
 * EOF definitions; these decls make them visible within the same TU. */
int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena *arena, int32_t a, int32_t b);
int32_t pipeline_typeck_type_refs_equal_same_kind_c(struct ast_ASTArena *arena, int32_t a, int32_t b,
                                                     int32_t kind_ord);

/** 比较两段字节序列是否逐字节相等（typeck name_equal 的 C 辅助）。 */
static int32_t pipeline_typeck_bytes_equal_c(uint8_t *a, int32_t a_len, uint8_t *b, int32_t b_len) {
  int32_t i;

  if (a_len != b_len || a_len <= 0)
    return 0;
  i = 0;
  while (i < a_len) {
    if (a[i] != b[i])
      return 0;
    i = i + 1;
  }
  return 1;
}

/**
 * typeck.x::typeck_coerce_init_lit_to_decl C delegate (integer literal branch).
 * PLATFORM: SHARED — wave307 Cap residual pure: use full i64 EXPR_LIT bits.
 * Prior i32 truncation + `int_val >= 0` rejected u64max (stored as -1) and
 * i64max (low32 all-ones → -1 as i32) for u64/usize targets.
 */
int32_t pipeline_typeck_coerce_init_lit_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref, int32_t decl_ty_ref,
                                                  int32_t decl_kind, int32_t init_kind) {
  struct ast_Expr *init_ex;
  int64_t int_val;

  if (!arena || init_ref <= 0 || init_ref > arena->num_exprs || decl_ty_ref <= 0)
    return 0;
  if (init_kind != (int32_t)ast_ExprKind_EXPR_LIT)
    return 0;
  init_ex = pipeline_arena_expr_ptr(arena, init_ref);
  if (!init_ex)
    return 0;
  int_val = pipeline_expr_int64_val_at(arena, init_ref);
  if (decl_kind == (int32_t)ast_TypeKind_TYPE_PTR && int_val == 0) {
    init_ex->resolved_type_ref = decl_ty_ref;
    return 1;
  }
  if (decl_kind == (int32_t)ast_TypeKind_TYPE_ARRAY && int_val == 0) {
    init_ex->resolved_type_ref = decl_ty_ref;
    return 1;
  }
  if (decl_kind == (int32_t)ast_TypeKind_TYPE_U8 && int_val >= 0 && int_val <= 255) {
    init_ex->resolved_type_ref = decl_ty_ref;
    return 1;
  }
  if (decl_kind == (int32_t)ast_TypeKind_TYPE_I64) {
    init_ex->resolved_type_ref = decl_ty_ref;
    return 1;
  }
  if (decl_kind == (int32_t)ast_TypeKind_TYPE_ISIZE) {
    init_ex->resolved_type_ref = decl_ty_ref;
    return 1;
  }
  /* u32: accept full lit bit pattern (emit uses low 32). */
  if (decl_kind == (int32_t)ast_TypeKind_TYPE_U32) {
    init_ex->resolved_type_ref = decl_ty_ref;
    return 1;
  }
  /*
   * wave307: u64/usize accept any bare EXPR_LIT bit pattern.
   * Digits in 2^63..2^64-1 wrap to negative i64 two's-complement but remain
   * valid unsigned values (u64max → -1 bits). Unary `-N` is EXPR_NEG.
   */
  if (decl_kind == (int32_t)ast_TypeKind_TYPE_USIZE || decl_kind == (int32_t)ast_TypeKind_TYPE_U64) {
    init_ex->resolved_type_ref = decl_ty_ref;
    return 1;
  }
  if (decl_kind == (int32_t)ast_TypeKind_TYPE_F32 || decl_kind == (int32_t)ast_TypeKind_TYPE_F64) {
    init_ex->resolved_type_ref = decl_ty_ref;
    return 1;
  }
  if (int_val == 0 &&
      (decl_kind == (int32_t)ast_TypeKind_TYPE_NAMED || decl_kind == (int32_t)ast_TypeKind_TYPE_VECTOR)) {
    init_ex->resolved_type_ref = decl_ty_ref;
    return 1;
  }
  return 0;
}

/**
 * typeck.x::typeck_coerce_init_float_lit_to_decl C twin (G.7).
 * wave316: bare FLOAT_LIT + EXPR_NEG of FLOAT_LIT → f32/f64 (assign/return/let).
 * PLATFORM: SHARED — product mega typeck uses this path for coerce_init_expr.
 */
int32_t pipeline_typeck_coerce_init_float_lit_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                        int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind) {
  struct ast_Expr *init_ex;
  int32_t op_ref;

  if (!arena || init_ref <= 0 || init_ref > arena->num_exprs)
    return 0;
  if (decl_kind != (int32_t)ast_TypeKind_TYPE_F32 && decl_kind != (int32_t)ast_TypeKind_TYPE_F64)
    return 0;
  if (init_kind == (int32_t)ast_ExprKind_EXPR_FLOAT_LIT) {
    init_ex = pipeline_arena_expr_ptr(arena, init_ref);
    if (!init_ex)
      return 0;
    init_ex->resolved_type_ref = decl_ty_ref;
    return 1;
  }
  /* wave316: unary `-6.0` is EXPR_NEG of FLOAT_LIT — stamp operand + NEG. */
  if (init_kind == (int32_t)ast_ExprKind_EXPR_NEG) {
    op_ref = pipeline_expr_unary_operand_ref_at(arena, init_ref);
    if (ast_ref_is_null(op_ref) || op_ref <= 0 || op_ref > arena->num_exprs)
      return 0;
    if (pipeline_expr_kind_ord_at(arena, op_ref) != (int32_t)ast_ExprKind_EXPR_FLOAT_LIT)
      return 0;
    init_ex = pipeline_arena_expr_ptr(arena, op_ref);
    if (init_ex)
      init_ex->resolved_type_ref = decl_ty_ref;
    init_ex = pipeline_arena_expr_ptr(arena, init_ref);
    if (!init_ex)
      return 0;
    init_ex->resolved_type_ref = decl_ty_ref;
    return 1;
  }
  return 0;
}

/** typeck.x::typeck_coerce_init_enum_field_to_decl 的 C 委托（枚举 variant 字段访问）。 */
int32_t pipeline_typeck_coerce_init_enum_field_to_decl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         int32_t init_ref, int32_t decl_ty_ref, int32_t decl_kind,
                                                         int32_t init_kind) {
  struct ast_Expr *init_ex;
  int32_t base_ix;
  uint8_t decl_nm[128];
  int32_t decl_nlen;
  uint8_t field_nm[128];
  int32_t field_nlen;

  if (!arena || init_ref <= 0 || init_ref > arena->num_exprs)
    return 0;
  if (decl_kind != (int32_t)ast_TypeKind_TYPE_NAMED || init_kind != (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS)
    return 0;
  init_ex = pipeline_arena_expr_ptr(arena, init_ref);
  if (!init_ex)
    return 0;
  base_ix = pipeline_expr_field_access_base_ref(arena, init_ref);
  if (!ast_ref_is_null(base_ix) && base_ix > 0 && base_ix <= arena->num_exprs) {
    decl_nlen = pipeline_type_named_name_into(arena, decl_ty_ref, decl_nm);
    if (pipeline_expr_kind_ord_at(arena, base_ix) == 3) {
      uint8_t vnm[128];
      int32_t vnlen;

      vnlen = pipeline_expr_var_name_len(arena, base_ix);
      pipeline_expr_var_name_into(arena, base_ix, vnm);
      if (pipeline_typeck_bytes_equal_c(decl_nm, decl_nlen, vnm, vnlen)) {
        field_nlen = pipeline_expr_field_access_name_len(arena, init_ref);
        pipeline_expr_field_access_name_into(arena, init_ref, field_nm);
        if (module) {
          int32_t ev_tag =
              pipeline_module_enum_variant_tag_for_names(module, decl_nm, decl_nlen, field_nm, field_nlen);
          if (ev_tag >= 0) {
            init_ex->field_access_is_enum_variant = 1;
            init_ex->enum_variant_tag = ev_tag;
            init_ex->resolved_type_ref = decl_ty_ref;
            return 1;
          }
        }
      }
    }
  }
  if (pipeline_expr_field_access_is_enum_variant(arena, init_ref) != 0) {
    init_ex->resolved_type_ref = decl_ty_ref;
    return 1;
  }
  return 0;
}

/** typeck.x::typeck_coerce_init_named_call_to_decl 的 C 委托。 */
int32_t pipeline_typeck_coerce_init_named_call_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                         int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind) {
  struct ast_Expr *init_ex;

  if (!arena || init_ref <= 0 || init_ref > arena->num_exprs)
    return 0;
  if (decl_kind != (int32_t)ast_TypeKind_TYPE_NAMED || init_kind != (int32_t)ast_ExprKind_EXPR_CALL ||
      !ast_ref_is_null(pipeline_expr_resolved_type_ref(arena, init_ref)))
    return 0;
  init_ex = pipeline_arena_expr_ptr(arena, init_ref);
  if (!init_ex)
    return 0;
  init_ex->resolved_type_ref = decl_ty_ref;
  return 1;
}

/**
 * typeck.x::typeck_coerce_init_array_vector_lit_to_decl C mirror.
 * wave328 Cap residual: TYPE_SLICE + EXPR_ARRAY_LIT (`let a: i32[] = [1,2,3]`) stamps
 * resolved_type_ref so host emit_expr takes the slice compound path
 * `(struct xlang_slice_*){ .data = (T[]){…}, .length = N }` instead of bare
 * `(uint8_t[]){…}` fallback. Fixed TYPE_ARRAY and TYPE_VECTOR unchanged.
 * PLATFORM: SHARED — keep in sync with typeck.x (G.7 dual authority).
 */
int32_t pipeline_typeck_coerce_init_array_vector_lit_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                               int32_t decl_ty_ref, int32_t decl_kind,
                                                               int32_t init_kind) {
  struct ast_Expr *init_ex;
  int32_t nel_v;
  int32_t decl_asz;

  if (!arena || init_ref <= 0 || init_ref > arena->num_exprs)
    return 0;
  init_ex = pipeline_arena_expr_ptr(arena, init_ref);
  if (!init_ex)
    return 0;
  /* TYPE_ARRAY T[N] or TYPE_SLICE T[] ← ARRAY_LIT */
  if ((decl_kind == (int32_t)ast_TypeKind_TYPE_ARRAY ||
       decl_kind == (int32_t)ast_TypeKind_TYPE_SLICE) &&
      init_kind == (int32_t)ast_ExprKind_EXPR_ARRAY_LIT) {
    init_ex->resolved_type_ref = decl_ty_ref;
    return 1;
  }
  if (decl_kind == (int32_t)ast_TypeKind_TYPE_VECTOR && init_kind == (int32_t)ast_ExprKind_EXPR_ARRAY_LIT) {
    nel_v = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
    decl_asz = pipeline_type_array_size_at(arena, decl_ty_ref);
    if (nel_v == decl_asz) {
      init_ex->resolved_type_ref = decl_ty_ref;
      return 1;
    }
  }
  return 0;
}

/** typeck.x::typeck_coerce_init_vector_binop_to_decl 的 C 委托。 */
int32_t pipeline_typeck_coerce_init_vector_binop_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                           int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind) {
  struct ast_Expr *init_ex;
  int32_t lref_c;
  int32_t rref_c;
  int32_t lt_c;
  int32_t rt_c;

  if (!arena || init_ref <= 0 || init_ref > arena->num_exprs)
    return 0;
  if (decl_kind != (int32_t)ast_TypeKind_TYPE_VECTOR)
    return 0;
  if (init_kind != (int32_t)ast_ExprKind_EXPR_ADD && init_kind != (int32_t)ast_ExprKind_EXPR_SUB &&
      init_kind != (int32_t)ast_ExprKind_EXPR_MUL && init_kind != (int32_t)ast_ExprKind_EXPR_DIV)
    return 0;
  init_ex = pipeline_arena_expr_ptr(arena, init_ref);
  if (!init_ex)
    return 0;
  lref_c = pipeline_expr_binop_left_ref_at(arena, init_ref);
  rref_c = pipeline_expr_binop_right_ref_at(arena, init_ref);
  if (!ast_ref_is_null(lref_c) && !ast_ref_is_null(rref_c)) {
    lt_c = pipeline_typeck_expr_type_ref_c(arena, lref_c);
    rt_c = pipeline_typeck_expr_type_ref_c(arena, rref_c);
    if (!ast_ref_is_null(lt_c) && !ast_ref_is_null(rt_c) &&
        pipeline_type_kind_ord_at(arena, lt_c) == (int32_t)ast_TypeKind_TYPE_VECTOR &&
        pipeline_type_kind_ord_at(arena, rt_c) == (int32_t)ast_TypeKind_TYPE_VECTOR &&
        pipeline_type_array_size_at(arena, lt_c) == pipeline_type_array_size_at(arena, rt_c) &&
        pipeline_type_array_size_at(arena, lt_c) == pipeline_type_array_size_at(arena, decl_ty_ref) &&
        pipeline_typeck_type_refs_equal_c(arena, pipeline_type_elem_ref_at(arena, lt_c),
                                          pipeline_type_elem_ref_at(arena, rt_c))) {
      init_ex->resolved_type_ref = decl_ty_ref;
      return 1;
    }
  }
  return 0;
}

/**
 * typeck.x::typeck_coerce_init_int_binop_to_decl 的 C 委托：
 * let 标量整型声明 + 算术二元初值时提升到声明类型（INT64_MIN 等 i64 表达式）。
 * wave319 Cap residual: also TYPE_F32/TYPE_F64 for EXPR_NEG / int binop
 * (`let a:f32 = -6` / `1-7` / assign / return). Bare int lit already via lit
 * coerce (wave318); float lit NEG via float_lit (wave316). CTFE folds the
 * tree to i32 then freestanding IEEE path (wave318) materializes bits.
 * PLATFORM: SHARED — typeck.x thin-wraps this C authority; assign reuses same call (wave310).
 */
int32_t pipeline_typeck_coerce_init_int_binop_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                        int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind) {
  struct ast_Expr *init_ex;

  if (!arena || init_ref <= 0 || init_ref > arena->num_exprs)
    return 0;
  /* 【Why 根源】i8/i16 无独立 TypeKind（存为 TYPE_NAMED name="i8"/"i16"），binop/NEG 初值（如 -1 解析为
   * EXPR_NEG(lit(1))）需按 name 放行 signed 窄整型，否则 let y:i16=-1 报 type mismatch。
   * wave309 Cap residual: TYPE_ISIZE + EXPR_NEG/binop (let a:isize=-1 / 1-2).
   * wave310 Cap residual: TYPE_U8 + NAMED u16 bit-pattern wrap for EXPR_NEG/binop
   * (`let a:u8=-1` / `1-2` / assign; product already accepts u32/u64/usize=-1).
   * wave319 Cap residual: TYPE_F32/TYPE_F64 + EXPR_NEG/int binop (`let a:f32=-6`).
   * Prior invariant rejected unsigned narrow NEG; lit path still range-gates bare EXPR_LIT.
   * 【Asm/Perf】与 i32 路径对齐，不做编译期范围检查（i32 路径同样不做）。
   * PLATFORM: SHARED — typeck.x thin-wraps this C authority; assign reuses same call (wave310). */
  if (decl_kind != (int32_t)ast_TypeKind_TYPE_I32 && decl_kind != (int32_t)ast_TypeKind_TYPE_I64 &&
      decl_kind != (int32_t)ast_TypeKind_TYPE_U8 && decl_kind != (int32_t)ast_TypeKind_TYPE_U32 &&
      decl_kind != (int32_t)ast_TypeKind_TYPE_U64 && decl_kind != (int32_t)ast_TypeKind_TYPE_USIZE &&
      decl_kind != (int32_t)ast_TypeKind_TYPE_ISIZE &&
      decl_kind != (int32_t)ast_TypeKind_TYPE_F32 && decl_kind != (int32_t)ast_TypeKind_TYPE_F64 &&
      decl_kind != (int32_t)ast_TypeKind_TYPE_NAMED)
    return 0;
  /* TYPE_NAMED: i8/i16 (signed narrow) + u16 (unsigned narrow; TYPE_U8 is builtin kind=2). */
  if (decl_kind == (int32_t)ast_TypeKind_TYPE_NAMED) {
    uint8_t nm[128] = { 0 };
    int32_t nlen = pipeline_type_named_name_into(arena, decl_ty_ref, nm);
    if (!((nlen == 2 && nm[0] == 105 && nm[1] == 56) ||                 /* "i8" */
          (nlen == 3 && nm[0] == 105 && nm[1] == 49 && nm[2] == 54) ||   /* "i16" */
          (nlen == 3 && nm[0] == 117 && nm[1] == 49 && nm[2] == 54)))    /* "u16" */
      return 0;
  }
  if (init_kind != (int32_t)ast_ExprKind_EXPR_ADD && init_kind != (int32_t)ast_ExprKind_EXPR_SUB &&
      init_kind != (int32_t)ast_ExprKind_EXPR_MUL && init_kind != (int32_t)ast_ExprKind_EXPR_DIV &&
      init_kind != (int32_t)ast_ExprKind_EXPR_NEG)
    return 0;
  init_ex = pipeline_arena_expr_ptr(arena, init_ref);
  if (!init_ex)
    return 0;
  /*
   * wave319: for f32/f64, stamp EXPR_NEG's bare int lit operand too (G.7 parity with
   * float_lit NEG of FLOAT_LIT). Freestanding emit_neg then loads IEEE bits and btc
   * the sign; return/assign paths may not CTFE-fold the tree (let does fold_in_block).
   * Without operand stamp: mov $6; neg %eax → 0xfffffffa bits, not IEEE -6.0f.
   * PLATFORM: SHARED / LINUX+MACOS freestanding.
   */
  if ((decl_kind == (int32_t)ast_TypeKind_TYPE_F32 || decl_kind == (int32_t)ast_TypeKind_TYPE_F64) &&
      init_kind == (int32_t)ast_ExprKind_EXPR_NEG) {
    int32_t op_ref = pipeline_expr_unary_operand_ref_at(arena, init_ref);
    if (!ast_ref_is_null(op_ref) && op_ref > 0 && op_ref <= arena->num_exprs &&
        pipeline_expr_kind_ord_at(arena, op_ref) == (int32_t)ast_ExprKind_EXPR_LIT) {
      struct ast_Expr *op_ex = pipeline_arena_expr_ptr(arena, op_ref);
      if (op_ex)
        op_ex->resolved_type_ref = decl_ty_ref;
    }
  }
  init_ex->resolved_type_ref = decl_ty_ref;
  return 1;
}

/**
 * let 初值：匿名 struct 字面量 `{ fd, ... }` 从声明类型 `PollFd` 回填 struct 名与 resolved_type。
 * 须在 typeck_ensure_struct_layout_from_struct_lit 之前写入 struct_lit_struct_name。
 */
int32_t pipeline_typeck_coerce_init_struct_lit_to_decl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         int32_t init_ref, int32_t decl_ty_ref) {
  struct ast_Expr *init_ex;
  int32_t decl_kind;
  int32_t init_kind;
  int32_t name_len;
  uint8_t decl_nm[128];
  int32_t decl_nlen;
  int32_t ti;

  if (!arena || init_ref <= 0 || init_ref > arena->num_exprs || decl_ty_ref <= 0 || decl_ty_ref > arena->num_types)
    return 0;
  decl_kind = pipeline_type_kind_ord_at(arena, decl_ty_ref);
  init_kind = pipeline_expr_kind_ord_at(arena, init_ref);
  if (decl_kind != (int32_t)ast_TypeKind_TYPE_NAMED || init_kind != (int32_t)ast_ExprKind_EXPR_STRUCT_LIT)
    return 0;
  init_ex = pipeline_arena_expr_ptr(arena, init_ref);
  if (!init_ex)
    return 0;
  name_len = init_ex->struct_lit_struct_name_len;
  if (name_len > 0)
    return 0;
  decl_nlen = pipeline_type_named_name_into(arena, decl_ty_ref, decl_nm);
  if (decl_nlen <= 0 || decl_nlen > 127)
    return 0;
  init_ex->struct_lit_struct_name_len = decl_nlen;
  ti = 0;
  while (ti < 64) {
    init_ex->struct_lit_struct_name[ti] = (ti < decl_nlen) ? decl_nm[ti] : (uint8_t)0;
    ti = ti + 1;
  }
  if (module && typeck_ensure_struct_layout_from_struct_lit(module, arena, init_ref) != 0)
    return 0;
  init_ex->resolved_type_ref = decl_ty_ref;
  return 1;
}

/** typeck.x::typeck_coerce_init_slice_from_array 的 C 委托。 */
int32_t pipeline_typeck_coerce_init_slice_from_array_c(struct ast_ASTArena *arena, int32_t init_ref, int32_t decl_ty_ref,
                                                       int32_t decl_kind) {
  struct ast_Expr *init_ex;
  int32_t decl_elem;
  int32_t init_res;
  int32_t init_res_kind;
  int32_t init_elem;

  if (!arena || init_ref <= 0 || init_ref > arena->num_exprs)
    return 0;
  if (decl_kind != (int32_t)ast_TypeKind_TYPE_SLICE)
    return 0;
  init_ex = pipeline_arena_expr_ptr(arena, init_ref);
  if (!init_ex)
    return 0;
  decl_elem = pipeline_type_elem_ref_at(arena, decl_ty_ref);
  init_res = pipeline_expr_resolved_type_ref(arena, init_ref);
  if (!ast_ref_is_null(decl_elem) && !ast_ref_is_null(init_res)) {
    init_res_kind = pipeline_type_kind_ord_at(arena, init_res);
    init_elem = pipeline_type_elem_ref_at(arena, init_res);
    if (init_res_kind == (int32_t)ast_TypeKind_TYPE_ARRAY && !ast_ref_is_null(init_elem) &&
        pipeline_typeck_type_refs_equal_c(arena, init_elem, decl_elem)) {
      init_ex->resolved_type_ref = decl_ty_ref;
      return 1;
    }
  }
  return 0;
}

/**
 * typeck.x::typeck_coerce_init_expr_to_decl 的 C 委托（薄分发，对齐 X 子 helper 调用序）：
 * let/const 初值类型与声明对齐；用指针写 Expr 池，避免 ast_arena_expr_get 按值拷贝。
 */
int32_t pipeline_typeck_coerce_init_expr_to_decl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t init_ref, int32_t decl_ty_ref) {
  int32_t decl_kind;
  int32_t init_kind;

  if (ast_ref_is_null(init_ref) || ast_ref_is_null(decl_ty_ref))
    return 0;
  if (!arena || init_ref <= 0 || init_ref > arena->num_exprs || decl_ty_ref <= 0 || decl_ty_ref > arena->num_types)
    return 0;
  decl_kind = pipeline_type_kind_ord_at(arena, decl_ty_ref);
  init_kind = pipeline_expr_kind_ord_at(arena, init_ref);
  if (pipeline_typeck_coerce_init_lit_to_decl_c(arena, init_ref, decl_ty_ref, decl_kind, init_kind) != 0)
    return 1;
  if (pipeline_typeck_coerce_init_float_lit_to_decl_c(arena, init_ref, decl_ty_ref, decl_kind, init_kind) != 0)
    return 1;
  if (pipeline_typeck_coerce_init_enum_field_to_decl_c(module, arena, init_ref, decl_ty_ref, decl_kind, init_kind) != 0)
    return 1;
  if (pipeline_typeck_coerce_init_named_call_to_decl_c(arena, init_ref, decl_ty_ref, decl_kind, init_kind) != 0)
    return 1;
  if (pipeline_typeck_coerce_init_array_vector_lit_to_decl_c(arena, init_ref, decl_ty_ref, decl_kind, init_kind) != 0)
    return 1;
  if (pipeline_typeck_coerce_init_vector_binop_to_decl_c(arena, init_ref, decl_ty_ref, decl_kind, init_kind) != 0)
    return 1;
  if (pipeline_typeck_coerce_init_int_binop_to_decl_c(arena, init_ref, decl_ty_ref, decl_kind, init_kind) != 0)
    return 1;
  if (pipeline_typeck_coerce_init_slice_from_array_c(arena, init_ref, decl_ty_ref, decl_kind) != 0)
    return 1;
  if (pipeline_typeck_coerce_init_struct_lit_to_decl_c(module, arena, init_ref, decl_ty_ref) != 0)
    return 1;
  return 0;
}

/**
 * Classify an ExprKind ordinal as any assignment kind (plain or compound).
 *
 * Why: check_block block-final-expr inference must distinguish assign-family
 * expressions from value expressions to route left/right coercion and lval
 * store. A single predicate avoids scattering kind_ord range checks across
 * the check_block path. Matches typeck.x check_block assign-kind gate.
 *
 * Invariant: returns 1 for EXPR_ASSIGN and EXPR_ADD_ASSIGN..EXPR_SHR_ASSIGN
 * inclusive, 0 otherwise (including invalid kind_ord).
 *
 * Asm/Perf: O(1) — two comparisons. Cold path — called per block-final
 * expr in pipeline_typeck_check_block_one_region_c (glue.c:15308).
 *
 * PLATFORM: SHARED — kind_ord classification is platform-independent.
 *
 * wave1065 G.7: migrated from glue.c:14135 (body 6 LOC). Static
 * (non-extern): same-TU visibility — coerce_init.c #include at L14126 <
 * def L14135 < sole callsite glue.c:15308. Dependencies: ast_ExprKind_*
 * enum (global); no other deps.
 */
static int32_t pipeline_typeck_expr_is_any_assign_kind_c(int32_t kind_ord) {
  if (kind_ord == (int32_t)ast_ExprKind_EXPR_ASSIGN)
    return 1;
  if (kind_ord >= (int32_t)ast_ExprKind_EXPR_ADD_ASSIGN && kind_ord <= (int32_t)ast_ExprKind_EXPR_SHR_ASSIGN)
    return 1;
  return 0;
}

/**
 * f32→f64 IEEE float widen gate (typeck-side).
 *
 * Why: implicit float widen (f32 → f64) is allowed in assign/arg/return
 * coercion; the reverse (f64 → f32) requires an explicit `as` cast. This
 * predicate centralizes the gate so coerce_init, check_expr_return, and
 * call_arg_types share one authority. Matches typeck.x::typeck_float_widen_ok.
 *
 * Invariant: returns 1 iff (dest==src and kind is F32 or F64) or
 * (src==F32 and dest==F64); 0 otherwise. TypeKind: TYPE_F32=14, TYPE_F64=15.
 *
 * Asm/Perf: O(1) — two comparisons. Cold path — called in coerce_init float
 * path, check_expr_return (glue.c:10650), return-type unify (glue.c:11132),
 * and call_arg_types (glue.c:13272).
 *
 * PLATFORM: SHARED — float widen classification is platform-independent.
 *
 * wave1076 G.7: migrated from glue.c:10544 (body 10 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:10435 (before all callsites) < coerce_init.c
 * #include at L14126 < def EOF. Dependencies: ast_TypeKind_TYPE_F32 /
 * ast_TypeKind_TYPE_F64 (global enum).
 */
static int32_t pipeline_typeck_float_widen_ok_c(int32_t dest_kind, int32_t src_kind) {
  if (dest_kind == src_kind) {
    if (dest_kind == (int32_t)ast_TypeKind_TYPE_F32 || dest_kind == (int32_t)ast_TypeKind_TYPE_F64)
      return 1;
    return 0;
  }
  if (src_kind == (int32_t)ast_TypeKind_TYPE_F32 && dest_kind == (int32_t)ast_TypeKind_TYPE_F64)
    return 1;
  return 0;
}

/**
 * First-class integer implicit widen gate (smaller → wider).
 *
 * Why: implicit integer widen (e.g. u8 → u32, i32 → i64) is allowed in
 * assign/arg/return coercion; narrowing requires explicit `as`. This
 * predicate centralizes the first-class TypeKind widen matrix so
 * integer_widen_ok_refs and coerce_init share one authority. Matches
 * typeck.x::typeck_integer_widen_ok (wave309–312). NAMED i8/i16/u16 go
 * through pipeline_typeck_integer_widen_ok_refs_c (family-id path).
 *
 * Invariant: returns 1 iff dest_kind can implicitly hold src_kind without
 * value loss (same-kind for int family, or wider dest). LP64 pointer-width
 * ↔ fixed 64-bit is same-bits (allowed). Returns 0 for narrowing or
 * non-integer kinds.
 *
 * Asm/Perf: O(1) — comparisons. Cold path — called in
 * pipeline_typeck_integer_widen_ok_refs_c (glue.c:10523, via fwd decl).
 *
 * PLATFORM: SHARED — integer widen classification is platform-independent.
 *
 * wave1077 G.7: migrated from glue.c:10441 (body 36 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:10441 (before sole callsite in refs_c) <
 * coerce_init.c #include at L14126 < def EOF. Dependencies: ast_TypeKind_*
 * (global enum).
 */
static int32_t pipeline_typeck_integer_widen_ok_c(int32_t dest_kind, int32_t src_kind) {
  /* G.7 mirror typeck.x::typeck_integer_widen_ok (wave309–312).
   * PLATFORM: SHARED — first-class integer family; wave313 NAMED via refs path. */
  if (dest_kind == src_kind) {
    if (dest_kind == (int32_t)ast_TypeKind_TYPE_I32 || dest_kind == (int32_t)ast_TypeKind_TYPE_I64 ||
        dest_kind == (int32_t)ast_TypeKind_TYPE_U8 || dest_kind == (int32_t)ast_TypeKind_TYPE_U32 ||
        dest_kind == (int32_t)ast_TypeKind_TYPE_U64 || dest_kind == (int32_t)ast_TypeKind_TYPE_USIZE ||
        dest_kind == (int32_t)ast_TypeKind_TYPE_ISIZE)
      return 1;
    return 0;
  }
  if (src_kind == (int32_t)ast_TypeKind_TYPE_U8)
    /* wave312: +i64 +isize (prior: u32/u64/usize/i32). */
    return dest_kind == (int32_t)ast_TypeKind_TYPE_U32 || dest_kind == (int32_t)ast_TypeKind_TYPE_U64 ||
           dest_kind == (int32_t)ast_TypeKind_TYPE_USIZE || dest_kind == (int32_t)ast_TypeKind_TYPE_I32 ||
           dest_kind == (int32_t)ast_TypeKind_TYPE_I64 || dest_kind == (int32_t)ast_TypeKind_TYPE_ISIZE;
  if (src_kind == (int32_t)ast_TypeKind_TYPE_I32)
    /* wave311: i32→u64 (true widen; was hole vs usize) + i32→u8 (low-byte narrow).
     * i32→isize：与 typeck.x / i32→usize 对称（指针宽度有符号整型）。 */
    return dest_kind == (int32_t)ast_TypeKind_TYPE_I64 || dest_kind == (int32_t)ast_TypeKind_TYPE_U32 ||
           dest_kind == (int32_t)ast_TypeKind_TYPE_U64 || dest_kind == (int32_t)ast_TypeKind_TYPE_USIZE ||
           dest_kind == (int32_t)ast_TypeKind_TYPE_ISIZE || dest_kind == (int32_t)ast_TypeKind_TYPE_U8;
  if (src_kind == (int32_t)ast_TypeKind_TYPE_U32)
    /* wave312: u32→u64 (prior) + u32→i64/usize/isize. */
    return dest_kind == (int32_t)ast_TypeKind_TYPE_U64 || dest_kind == (int32_t)ast_TypeKind_TYPE_I64 ||
           dest_kind == (int32_t)ast_TypeKind_TYPE_USIZE || dest_kind == (int32_t)ast_TypeKind_TYPE_ISIZE;
  /* wave312: LP64 pointer-width ↔ fixed 64-bit (same bits; ILP32 true widen). */
  if (src_kind == (int32_t)ast_TypeKind_TYPE_USIZE && dest_kind == (int32_t)ast_TypeKind_TYPE_U64)
    return 1;
  if (src_kind == (int32_t)ast_TypeKind_TYPE_U64 && dest_kind == (int32_t)ast_TypeKind_TYPE_USIZE)
    return 1;
  if (src_kind == (int32_t)ast_TypeKind_TYPE_ISIZE && dest_kind == (int32_t)ast_TypeKind_TYPE_I64)
    return 1;
  if (src_kind == (int32_t)ast_TypeKind_TYPE_I64 && dest_kind == (int32_t)ast_TypeKind_TYPE_ISIZE)
    return 1;
  return 0;
}

/**
 * Family id for first-class ints + NAMED i8/i16/u16.
 *
 * Why: integer_widen_ok_refs needs a uniform family id to route NAMED types
 * (i8/i16/u16) through the same widen matrix as first-class TypeKinds.
 * First-class ints return their TypeKind ordinal (0/2–7); NAMED i8/i16/u16
 * return 10/11/12 respectively. Matches typeck.x::typeck_int_family_id.
 *
 * Invariant: returns TypeKind ordinal (0/2–7) for first-class ints; 10 for
 * NAMED "i8", 11 for "i16", 12 for "u16"; -1 for NULL/invalid/non-int.
 *
 * Asm/Perf: O(1) — one kind read + one name comparison. Cold path — called
 * in pipeline_typeck_integer_widen_ok_refs_c (glue.c:10485/10486, via fwd decl).
 *
 * PLATFORM: SHARED — int family classification is platform-independent.
 *
 * wave1078 G.7: migrated from glue.c:10453 (body 19 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:10454 (before callsites in refs_c) <
 * coerce_init.c #include at L14126 < def EOF. Dependencies:
 * typeck_scratch64_slot (extern, glue.c:10447) /
 * pipeline_type_named_name_into (extern) / ast_ref_is_null (global).
 */
static int32_t pipeline_typeck_int_family_id_c(struct ast_ASTArena *arena, int32_t type_ref) {
  int32_t k;
  int32_t nlen;
  uint8_t *buf;
  if (ast_ref_is_null(type_ref) || type_ref <= 0 || !arena)
    return -1;
  k = pipeline_type_kind_ord_at(arena, type_ref);
  if (k == 0 || k == 2 || k == 3 || k == 4 || k == 5 || k == 6 || k == 7)
    return k;
  if (k != 8)
    return -1;
  buf = typeck_scratch64_slot(15);
  nlen = pipeline_type_named_name_into(arena, type_ref, buf);
  if (nlen == 2 && buf[0] == 105 && buf[1] == 56) /* i8 */
    return 10;
  if (nlen == 3 && buf[0] == 105 && buf[1] == 49 && buf[2] == 54) /* i16 */
    return 11;
  if (nlen == 3 && buf[0] == 117 && buf[1] == 49 && buf[2] == 54) /* u16 */
    return 12;
  return -1;
}

/**
 * Refs-based integer widen (first-class + NAMED i8/i16/u16).
 *
 * Why: typeck assign/arg/return coercion compares two type_refs for implicit
 * integer widen. First-class TypeKinds route through integer_widen_ok_c;
 * NAMED i8/i16/u16 use family-id-based widen matrix. This helper unifies
 * both paths so callers see one predicate. Matches
 * typeck.x::typeck_integer_widen_ok_refs.
 *
 * Invariant: returns 0 for NULL arena or null refs; 1 iff dest can implicitly
 * hold src (same family id, or first-class widen, or NAMED→first-class /
 * NAMED→NAMED per matrix). Returns 0 for narrowing or non-int types.
 *
 * Asm/Perf: O(1) — two family-id lookups + comparisons. Cold path — called
 * in typeck_check_expr (glue.c:10590/10646), return-type unify (glue.c:11074),
 * and call_arg_types (glue.c:13212).
 *
 * PLATFORM: SHARED — int widen classification is platform-independent.
 *
 * wave1079 G.7: migrated from glue.c:10460 (body 33 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:10462 (before all callsites) <
 * coerce_init.c #include at L14126 < def EOF. Dependencies:
 * pipeline_typeck_int_family_id_c (same file, def above) /
 * pipeline_typeck_integer_widen_ok_c (same file, def above) /
 * ast_ref_is_null (global).
 */
static int32_t pipeline_typeck_integer_widen_ok_refs_c(struct ast_ASTArena *arena, int32_t dest_ref,
                                                       int32_t src_ref) {
  int32_t dest_f;
  int32_t src_f;
  if (ast_ref_is_null(dest_ref) || ast_ref_is_null(src_ref) || !arena)
    return 0;
  dest_f = pipeline_typeck_int_family_id_c(arena, dest_ref);
  src_f = pipeline_typeck_int_family_id_c(arena, src_ref);
  if (dest_f < 0 || src_f < 0)
    return 0;
  if (dest_f == src_f)
    return 1;
  if (dest_f <= 7 && src_f <= 7) {
    if (pipeline_typeck_integer_widen_ok_c(dest_f, src_f))
      return 1;
  }
  if (src_f == 10) /* i8 */
    return dest_f == 11 || dest_f == 12 || dest_f == 2 || dest_f == 0 || dest_f == 3 || dest_f == 4 ||
           dest_f == 5 || dest_f == 6 || dest_f == 7;
  if (src_f == 11) /* i16 */
    return dest_f == 12 || dest_f == 2 || dest_f == 0 || dest_f == 3 || dest_f == 4 || dest_f == 5 ||
           dest_f == 6 || dest_f == 7;
  if (src_f == 12) /* u16 */
    return dest_f == 2 || dest_f == 0 || dest_f == 3 || dest_f == 4 || dest_f == 5 || dest_f == 6 ||
           dest_f == 7;
  if (dest_f == 10) /* → i8 */
    return src_f == 2 || src_f == 0 || src_f == 11 || src_f == 12;
  if (dest_f == 11) /* → i16 */
    return src_f == 2 || src_f == 0 || src_f == 12 || src_f == 3;
  if (dest_f == 12) /* → u16 */
    return src_f == 2 || src_f == 0 || src_f == 11 || src_f == 3;
  return 0;
}

/**
 * NAMED type unqualified-name offset: find the last '.' and return offset+1.
 *
 * Why: type_refs_equal_named compares two NAMED type names. When full-name
 * match fails, it falls back to unqualified suffix match (last segment after
 * '.'). This helper centralizes the offset calculation so the caller does not
 * repeat the reverse scan. Matches typeck.x::type_refs_equal_named helper.
 *
 * Invariant: returns 0 if no '.' found (whole name is unqualified); otherwise
 * the byte offset of the first char after the last '.'.
 *
 * Asm/Perf: O(len) — one reverse scan. Cold path — called twice in
 * typeck_glue_type_refs_equal_named (glue.c:10117/10118, via fwd decl).
 *
 * PLATFORM: SHARED — string scan is platform-independent.
 *
 * wave1080 G.7: migrated from glue.c:10083 (body 7 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:10087 (before callsites in
 * typeck_glue_type_refs_equal_named) < coerce_init.c #include at L14126 < def EOF.
 * Dependencies: none (pure buf scan).
 */
static int32_t typeck_named_unqual_offset_c(const uint8_t *buf, int32_t len) {
  int32_t i;
  for (i = len - 1; i > 0; i--) {
    if (buf[i] == '.')
      return i + 1;
  }
  return 0;
}

/**
 * NAMED type_refs_equal: full-name match then unqualified suffix match.
 *
 * Why: typeck assign/arg/return coercion compares two NAMED type_refs. A
 * qualified name `mod.Foo` and unqualified `Foo` should compare equal when
 * they are the same type. This helper first tries full-name equality, then
 * falls back to comparing only the unqualified suffix (last segment after
 * '.'). Matches typeck.x::type_refs_equal_named.
 *
 * Invariant: returns 0 for NULL arena or invalid refs; 1 iff full names
 * match exactly OR unqualified suffixes match (same length + byte-equal).
 *
 * Asm/Perf: O(na+nb) — two name reads + two scans + one compare. Cold path —
 * called in pipeline_typeck_type_refs_equal_named_c (glue.c:10101, thin
 * delegate) and pipeline_typeck_type_refs_equal_same_kind_c (glue.c:10112).
 *
 * PLATFORM: SHARED — NAMED type comparison is platform-independent.
 *
 * wave1081 G.7: migrated from glue.c:10092 (body 37 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:10095 (before callsites L10101/10112) <
 * coerce_init.c #include at L14126 < def EOF. Dependencies:
 * typeck_named_unqual_offset_c (same file, def above) /
 * typeck_scratch64_slot (extern, glue.c:10447) /
 * pipeline_type_named_name_into (extern).
 */
static int32_t typeck_glue_type_refs_equal_named(struct ast_ASTArena *arena, int32_t a, int32_t b) {
  int32_t na;
  int32_t nb;
  int32_t i;
  int32_t oa;
  int32_t ob;
  int32_t ua;
  int32_t ub;
  uint8_t *buf_a;
  uint8_t *buf_b;

  buf_a = typeck_scratch64_slot(0);
  buf_b = typeck_scratch64_slot(1);
  na = pipeline_type_named_name_into(arena, a, buf_a);
  nb = pipeline_type_named_name_into(arena, b, buf_b);
  if (na <= 0 || nb <= 0)
    return 0;
  if (na == nb) {
    for (i = 0; i < na; i++) {
      if (buf_a[i] != buf_b[i])
        break;
    }
    if (i == na)
      return 1;
  }
  oa = typeck_named_unqual_offset_c(buf_a, na);
  ob = typeck_named_unqual_offset_c(buf_b, nb);
  ua = na - oa;
  ub = nb - ob;
  if (ua != ub || ua <= 0)
    return 0;
  for (i = 0; i < ua; i++) {
    if (buf_a[oa + i] != buf_b[ob + i])
      return 0;
  }
  return 1;
}

/**
 * type_refs_equal internal impl: read kind then delegate to same_kind.
 *
 * Why: pipeline_typeck_type_refs_equal_c (the public entry) calls this impl
 * for the non-null, a!=b case. Reads both type kinds; if they differ, types
 * are not equal; if same, delegates to same_kind_c for compound comparison.
 * Matches typeck.x::type_refs_equal_impl.
 *
 * Invariant: returns 0 for NULL arena or invalid refs; 0 if kinds differ;
 * otherwise delegates to pipeline_typeck_type_refs_equal_same_kind_c.
 *
 * Asm/Perf: O(1) — two kind reads + one delegate. Cold path — called in
 * pipeline_typeck_type_refs_equal_c (glue.c:10199) and resolve_alias path
 * (glue.c:10204).
 *
 * PLATFORM: SHARED — type comparison is platform-independent.
 *
 * wave1082 G.7: migrated from glue.c:10127 (body 12 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:10132 (before callsites L10199/10204) <
 * coerce_init.c #include at L14126 < def EOF. Dependencies:
 * pipeline_typeck_type_refs_equal_same_kind_c (extern, glue.c:10108) /
 * pipeline_type_kind_ord_at (extern).
 */
static int32_t typeck_glue_type_refs_equal_impl(struct ast_ASTArena *arena, int32_t a, int32_t b) {
  int32_t ka;
  int32_t kb;

  if (!arena || a <= 0 || b <= 0)
    return 0;
  ka = pipeline_type_kind_ord_at(arena, a);
  kb = pipeline_type_kind_ord_at(arena, b);
  if (ka != kb)
    return 0;
  return pipeline_typeck_type_refs_equal_same_kind_c(arena, a, b, ka);
}

/**
 * Type alias chain resolver: NAMED → target ref, depth-limited recursion.
 *
 * Why: typeck type_refs_equal must resolve type aliases before comparing.
 * A NAMED type `Foo` may alias to another type `Bar` or a compound. This
 * resolver walks the module's alias table, matching by name, and recurses
 * into the target ref (depth-limited to 32 to prevent infinite loops).
 * Matches typeck.x::resolve_type_alias_ref_impl.
 *
 * Invariant: returns type_ref unchanged for NULL arena, null ref, depth > 32,
 * no module, no aliases, or non-NAMED kind. For NAMED types matching an alias,
 * returns the resolved target ref (recursively). Returns type_ref if target
 * is invalid (<=0).
 *
 * Asm/Perf: O(n_aliases × name_len) per level, depth ≤ 32. Cold path — called
 * in pipeline_typeck_resolve_type_alias_ref_c (glue.c:10145, via fwd decl).
 *
 * PLATFORM: SHARED — alias resolution is platform-independent.
 *
 * wave1083 G.7: migrated from glue.c:10148 (body 36 LOC). Static (non-extern):
 * same-TU — static fwd decl at glue.c:10141 (before callsite in
 * resolve_type_alias_ref_c) < coerce_init.c #include at L14126 < def EOF.
 * Recursive self-call is within this def (same file). Dependencies:
 * ast_ref_is_null (global) / pipeline_module_num_type_aliases_at (extern,
 * glue.c:10135) / pipeline_type_kind_ord_at (extern) /
 * pipeline_type_named_name_into (extern) /
 * pipeline_module_type_alias_name_len (extern, glue.c:10136) /
 * pipeline_module_type_alias_name_byte_at (extern, glue.c:10137) /
 * pipeline_module_type_alias_target_ref (extern, glue.c:10138).
 */
static int32_t pipeline_typeck_resolve_type_alias_ref_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                             int32_t type_ref, int32_t depth) {
  int32_t kind;
  uint8_t nm[128];
  int32_t nlen;
  int32_t i;
  int32_t alen;
  int32_t j;
  int32_t tgt;

  if (!arena || ast_ref_is_null(type_ref) || depth > 32)
    return type_ref;
  if (!module || pipeline_module_num_type_aliases_at(module) <= 0)
    return type_ref;
  kind = pipeline_type_kind_ord_at(arena, type_ref);
  if (kind != (int32_t)ast_TypeKind_TYPE_NAMED)
    return type_ref;
  nlen = pipeline_type_named_name_into(arena, type_ref, nm);
  if (nlen <= 0)
    return type_ref;
  for (i = 0; i < pipeline_module_num_type_aliases_at(module); i++) {
    alen = pipeline_module_type_alias_name_len(module, i);
    if (alen != nlen)
      continue;
    for (j = 0; j < nlen; j++) {
      if (pipeline_module_type_alias_name_byte_at(module, i, j) != nm[j])
        break;
    }
    if (j < nlen)
      continue;
    tgt = pipeline_module_type_alias_target_ref(module, i);
    if (tgt <= 0)
      return type_ref;
    return pipeline_typeck_resolve_type_alias_ref_impl_c(module, arena, tgt, depth + 1);
  }
  return type_ref;
}

/* ============================================================
 * wave1158 G.7: typeck type_refs_equal / type_ref_is_bool /
 * expr_type_ref public wrappers (9 extern fns) migrated from
 * glue.c L7319-7423.
 *
 * Why here: these extern wrappers delegate to the static
 * implementations migrated by wave1080-1083 (named, impl,
 * resolve_alias_ref_impl) which already live in this file's
 * body above. Colocating public wrappers with their static
 * implementations is G.7 single-authority — the typeck type
 * comparison / bool check / expr-type-ref query path has one
 * home (coerce_init.c), not split between glue.c and
 * coerce_init.c.
 *
 * Extern (non-static): cross-TU link visibility; same-TU
 * visibility via #include L9626 + fwd decls at glue.c L7299
 * (for callsites before #include) and coerce_init.c L23
 * (for callsites L277/L816 before EOF definitions).
 *
 * Dependencies: typeck_glue_type_refs_equal_named (static,
 * same file L745) / typeck_glue_type_refs_equal_impl (static,
 * same file L806) / pipeline_typeck_resolve_type_alias_ref_impl_c
 * (static, same file L849) / g_typeck_active_module (static
 * global, glue.c L135, visible via #include) /
 * pipeline_type_elem_ref_at (extern, glue.c) /
 * pipeline_type_array_size_at (extern, glue.c) /
 * pipeline_type_kind_ord_at (extern, glue.c) /
 * pipeline_expr_resolved_type_ref (extern, glue.c) /
 * ast_ref_is_null (global).
 *
 * PLATFORM: SHARED — type comparison / bool check / expr-type
 * query is platform-independent.
 */

/**
 * NAMED type_refs_equal public wrapper: null/invalid gate then
 * delegate to typeck_glue_type_refs_equal_named (static, same file).
 * Matches typeck.x::type_refs_equal_named.
 */
int32_t pipeline_typeck_type_refs_equal_named_c(struct ast_ASTArena *arena, int32_t a, int32_t b) {
  if (!arena || a <= 0 || b <= 0)
    return 0;
  return typeck_glue_type_refs_equal_named(arena, a, b);
}

/**
 * resolve_type_alias_ref public wrapper: delegate to the static
 * impl with the active module (g_typeck_active_module) and depth 0.
 * Matches typeck.x::resolve_type_alias_ref.
 */
int32_t pipeline_typeck_resolve_type_alias_ref_c(struct ast_ASTArena *arena, int32_t type_ref) {
  return pipeline_typeck_resolve_type_alias_ref_impl_c(g_typeck_active_module, arena, type_ref, 0);
}

/**
 * type_refs_equal_impl thin delegate: caller guarantees non-null
 * refs and a!=b. Delegates to typeck_glue_type_refs_equal_impl
 * (static, same file).
 */
int32_t pipeline_typeck_type_refs_equal_impl_c(struct ast_ASTArena *arena, int32_t a, int32_t b) {
  return typeck_glue_type_refs_equal_impl(arena, a, b);
}

/**
 * type_refs_equal public entry: resolve aliases on both sides,
 * then if still different delegate to typeck_glue_type_refs_equal_impl
 * (static, same file). Matches typeck.x::type_refs_equal.
 */
int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena *arena, int32_t a, int32_t b) {
  if (ast_ref_is_null(a) || ast_ref_is_null(b))
    return a == b;
  a = pipeline_typeck_resolve_type_alias_ref_c(arena, a);
  b = pipeline_typeck_resolve_type_alias_ref_c(arena, b);
  if (a == b)
    return 1;
  return typeck_glue_type_refs_equal_impl(arena, a, b);
}

/**
 * Compound type comparison when kind is already known equal.
 * NAMED → name compare; PTR/SLICE/LINEAR → elem recursive;
 * ARRAY/VECTOR → size check + elem recursive; else equal.
 * Matches typeck.x::type_refs_equal_same_kind.
 */
int32_t pipeline_typeck_type_refs_equal_same_kind_c(struct ast_ASTArena *arena, int32_t a, int32_t b,
                                                    int32_t kind_ord) {
  if (!arena || a <= 0 || b <= 0)
    return 0;
  if (kind_ord == (int32_t)ast_TypeKind_TYPE_NAMED)
    return typeck_glue_type_refs_equal_named(arena, a, b);
  if (kind_ord == (int32_t)ast_TypeKind_TYPE_PTR || kind_ord == (int32_t)ast_TypeKind_TYPE_SLICE ||
      kind_ord == (int32_t)ast_TypeKind_TYPE_LINEAR)
    return pipeline_typeck_type_refs_equal_c(arena, pipeline_type_elem_ref_at(arena, a),
                                             pipeline_type_elem_ref_at(arena, b));
  if (kind_ord == (int32_t)ast_TypeKind_TYPE_ARRAY || kind_ord == (int32_t)ast_TypeKind_TYPE_VECTOR) {
    if (pipeline_type_array_size_at(arena, a) != pipeline_type_array_size_at(arena, b))
      return 0;
    return pipeline_typeck_type_refs_equal_c(arena, pipeline_type_elem_ref_at(arena, a),
                                             pipeline_type_elem_ref_at(arena, b));
  }
  return 1;
}

/**
 * type_ref_is_bool internal: check TypeKind == TYPE_BOOL.
 * Matches typeck.x::type_ref_is_bool_impl.
 */
int32_t pipeline_typeck_type_ref_is_bool_impl_c(struct ast_ASTArena *arena, int32_t type_ref) {
  return pipeline_type_kind_ord_at(arena, type_ref) == (int32_t)ast_TypeKind_TYPE_BOOL;
}

/**
 * type_ref_is_bool public entry: null/bounds gate then delegate
 * to type_ref_is_bool_impl_c (same file). Matches typeck.x::type_ref_is_bool.
 */
int32_t pipeline_typeck_type_ref_is_bool_c(struct ast_ASTArena *arena, int32_t type_ref) {
  if (ast_ref_is_null(type_ref) || type_ref <= 0 || !arena || type_ref > arena->num_types)
    return 0;
  return pipeline_typeck_type_ref_is_bool_impl_c(arena, type_ref);
}

/**
 * expr_type_ref internal: read expr.resolved_type_ref via glue pointer
 * read (avoids Expr by-value tearing). Matches typeck.x::expr_type_ref_impl.
 */
int32_t pipeline_typeck_expr_type_ref_impl_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  return pipeline_expr_resolved_type_ref(arena, expr_ref);
}

/**
 * expr_type_ref public entry: null/bounds gate then delegate to
 * expr_type_ref_impl_c (same file). Matches typeck.x::expr_type_ref.
 */
int32_t pipeline_typeck_expr_type_ref_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  if (ast_ref_is_null(expr_ref))
    return 0;
  if (!arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return 0;
  return pipeline_typeck_expr_type_ref_impl_c(arena, expr_ref);
}

