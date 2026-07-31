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

