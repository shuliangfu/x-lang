/* pipeline_typeck_slots.c — typeck scratch/推理/布局 slot 状态域（自 ast_pool.c 抽出）
 *
 * typeck_named_scratch64 / typeck_scratch64_slot：命名类型 64B scratch（多槽防覆盖）。
 * typeck_call_resolve_*_slot/_peek / typeck_overload_expected_ret：call resolve / overload 槽。
 * typeck_integer_widen_ok_* / typeck_binop_arith_infer_type_c：整型 widening + binop 算术推断。
 * typeck_struct_layout_metrics_try_packed_c / typeck_layout_metrics_*_slot[_depth]：struct 布局度量。
 * 同 TU #include；公共符号 + static 槽。 */

/** typeck.x：命名类型对齐/大小时复用的 64 字节 scratch（避免局部 u8[64] 在自 typecheck 时 check_block 失败）。 */
uint8_t *typeck_named_scratch64(void) {
  static uint8_t s[128];
  return s;
}

/** typeck.x：多槽 128 字节 scratch (wave577 Cap: AST name slots 64→128)；嵌套 layout/struct_lit 路径须用不同 slot 避免覆盖。 */
static uint8_t g_typeck_scratch64[16][128];

uint8_t *typeck_scratch64_slot(int32_t slot) {
  if (slot < 0 || slot >= 16)
    return g_typeck_scratch64[0];
  return g_typeck_scratch64[slot];
}

/** typeck.x：CALL resolve 写 func 下标用；勿用栈上 &cfi（自举 pipeline 下可撕裂致 segfault）。 */
static int32_t g_typeck_call_resolve_func_idx;
static int32_t g_typeck_call_resolve_dep_idx;
/**
 * PLATFORM: SHARED — expected return type for overload pick (let/assign/return context).
 * Zero-arg overloads (vec.new → Vec_i32 vs Vec_u8) score by this when args do not disambiguate.
 * Set by typeck_check_expr_call / method_call; cleared after resolve. 0 = no hint.
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

/** 读 CALL resolve dep scratch（X emit 勿 typeck_i32_ptr_read(slot()) 嵌套）。 */
int32_t typeck_call_resolve_dep_idx_peek(void) {
  return g_typeck_call_resolve_dep_idx;
}

/** 读 CALL resolve func scratch（X emit 勿 typeck_i32_ptr_read(slot()) 嵌套）。 */
int32_t typeck_call_resolve_func_idx_peek(void) {
  return g_typeck_call_resolve_func_idx;
}

/** Read expected-return hint for overload scoring (X emit: avoid nested slot read). */
int32_t typeck_overload_expected_ret_peek(void) {
  return g_typeck_overload_expected_ret;
}

/** 前向声明：binop arith infer C glue 读/写类型池。 */
extern int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern void pipeline_expr_set_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t type_ref);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *a, int32_t type_ref);
extern int32_t pipeline_type_array_size_at(struct ast_ASTArena *a, int32_t type_ref);
extern int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *a, int32_t type_ref);
extern int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena *arena, int32_t a, int32_t b);
extern int32_t pipeline_type_ensure_by_kind_ord(struct ast_ASTArena *a, int32_t kind_ord);

/* first-class only; binop twin prefers refs path below for NAMED (wave313). */
static int32_t typeck_integer_widen_ok_ord_c(int32_t dest_kind, int32_t src_kind) {
  if (dest_kind == src_kind)
    return dest_kind == 0 || dest_kind == 2 || dest_kind == 3 || dest_kind == 4 || dest_kind == 5 ||
           dest_kind == 6 || dest_kind == 7;
  if (src_kind == 2)
    return dest_kind == 0 || dest_kind == 3 || dest_kind == 4 || dest_kind == 5 || dest_kind == 6 ||
           dest_kind == 7;
  if (src_kind == 0)
    return dest_kind == 3 || dest_kind == 4 || dest_kind == 5 || dest_kind == 6 || dest_kind == 7 ||
           dest_kind == 2;
  if (src_kind == 3)
    return dest_kind == 4 || dest_kind == 5 || dest_kind == 6 || dest_kind == 7;
  if ((src_kind == 6 && dest_kind == 4) || (src_kind == 4 && dest_kind == 6) ||
      (src_kind == 7 && dest_kind == 5) || (src_kind == 5 && dest_kind == 7))
    return 1;
  return 0;
}

extern int32_t pipeline_type_named_name_into(struct ast_ASTArena *a, int32_t type_ref, uint8_t *out);

/** wave313: G.7 ≡ typeck_integer_widen_ok_refs for binop twin (NAMED i8/i16/u16). */
static int32_t typeck_integer_widen_ok_refs_c(struct ast_ASTArena *arena, int32_t dest_ref, int32_t src_ref) {
  int32_t dk;
  int32_t sk;
  int32_t df;
  int32_t sf;
  uint8_t *buf;
  int32_t nlen;
  if (!arena || dest_ref <= 0 || src_ref <= 0)
    return 0;
  dk = pipeline_type_kind_ord_at(arena, dest_ref);
  sk = pipeline_type_kind_ord_at(arena, src_ref);
  df = -1;
  sf = -1;
  if (dk == 0 || dk == 2 || dk == 3 || dk == 4 || dk == 5 || dk == 6 || dk == 7)
    df = dk;
  else if (dk == 8) {
    buf = typeck_scratch64_slot(15);
    nlen = pipeline_type_named_name_into(arena, dest_ref, buf);
    if (nlen == 2 && buf[0] == 105 && buf[1] == 56)
      df = 10;
    else if (nlen == 3 && buf[0] == 105 && buf[1] == 49 && buf[2] == 54)
      df = 11;
    else if (nlen == 3 && buf[0] == 117 && buf[1] == 49 && buf[2] == 54)
      df = 12;
  }
  if (sk == 0 || sk == 2 || sk == 3 || sk == 4 || sk == 5 || sk == 6 || sk == 7)
    sf = sk;
  else if (sk == 8) {
    buf = typeck_scratch64_slot(15);
    nlen = pipeline_type_named_name_into(arena, src_ref, buf);
    if (nlen == 2 && buf[0] == 105 && buf[1] == 56)
      sf = 10;
    else if (nlen == 3 && buf[0] == 105 && buf[1] == 49 && buf[2] == 54)
      sf = 11;
    else if (nlen == 3 && buf[0] == 117 && buf[1] == 49 && buf[2] == 54)
      sf = 12;
  }
  if (df < 0 || sf < 0)
    return 0;
  if (df == sf)
    return 1;
  if (df <= 7 && sf <= 7)
    return typeck_integer_widen_ok_ord_c(df, sf);
  if (sf == 10)
    return df == 11 || df == 12 || df == 2 || df == 0 || df == 3 || df == 4 || df == 5 || df == 6 || df == 7;
  if (sf == 11)
    return df == 12 || df == 2 || df == 0 || df == 3 || df == 4 || df == 5 || df == 6 || df == 7;
  if (sf == 12)
    return df == 2 || df == 0 || df == 3 || df == 4 || df == 5 || df == 6 || df == 7;
  if (df == 10)
    return sf == 2 || sf == 0 || sf == 11 || sf == 12;
  if (df == 11)
    return sf == 2 || sf == 0 || sf == 12 || sf == 3;
  if (df == 12)
    return sf == 2 || sf == 0 || sf == 11 || sf == 3;
  return 0;
}

/**
 * 算术/位 binop 结果类型推导（typeck.x 同逻辑；X 单函 emit 触顶 reloc 8192，暂经 C glue）。
 * 假定 bop_l/bop_r 已 check；写 expr_ref.resolved_type_ref。
 */
void typeck_binop_arith_infer_type_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t bop_l,
                                     int32_t bop_r, int32_t expr_kind) {
  int32_t lk_expr;
  int32_t rk_expr;
  int32_t lt_ar;
  int32_t rt_ar;
  int32_t lko;
  int32_t rko;
  int32_t out_ar = 0;
  int32_t allow_i32_fallback = 0;
  if (!arena || expr_ref <= 0 || bop_l <= 0 || bop_r <= 0)
    return;
  lt_ar = pipeline_expr_resolved_type_ref(arena, bop_l);
  rt_ar = pipeline_expr_resolved_type_ref(arena, bop_r);
  if (lt_ar <= 0 || rt_ar <= 0 || lt_ar > arena->num_types || rt_ar > arena->num_types)
    return;
  lk_expr = pipeline_expr_kind_ord_at(arena, bop_l);
  rk_expr = pipeline_expr_kind_ord_at(arena, bop_r);
  lko = pipeline_type_kind_ord_at(arena, lt_ar);
  rko = pipeline_type_kind_ord_at(arena, rt_ar);
  /** ptr ± i32/usize/isize → ptr（与 typeck.x binop_arith 一致）。 */
  if (expr_kind >= 4 && expr_kind <= 5) {
    if (lko == 9 && (rko == 0 || rko == 6 || rko == 7))
      out_ar = lt_ar;
    else if (expr_kind == 4 && rko == 9 && (lko == 0 || lko == 6 || lko == 7))
      out_ar = rt_ar;
  }
  /* wave285 Cap residual: G.7 ≡ typeck.x — illegal pointer arithmetic must not
   * fall through type_refs_equal (host BLD001 soft residual). This helper only
   * sets resolved type; callers that hard-fail use typeck_check_expr_binop_arith.
   * Allowed: ptr+int/int+ptr (ADD), ptr-int (SUB→ptr), ptr-ptr (SUB→isize=7). */
  if (lko == 9 || rko == 9) {
    if (expr_kind == 4) {
      if (out_ar != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, out_ar);
        return;
      }
      return; /* leave unresolved; product path hard-fails in typeck_check_expr_binop_arith */
    }
    if (expr_kind == 5) {
      if (lko == 9 && rko == 9) {
        out_ar = pipeline_type_ensure_by_kind_ord(arena, 7); /* isize */
        if (out_ar != 0)
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, out_ar);
        return;
      }
      if (out_ar != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, out_ar);
        return;
      }
      return;
    }
    return; /* mul/div/… with ptr: leave unresolved */
  }
  /* wave286 Cap residual: G.7 ≡ typeck.x — illegal float bitop/mod/shift must not
   * promote to f32/f64 (host BLD001 soft residual). Leave unresolved; product path
   * hard-fails in typeck_check_expr_binop_arith.
   * expr_kind: MOD=8 SHL=9 SHR=10 BITAND=11 BITOR=12 BITXOR=13; f32=14 f64=15. */
  if ((lko == 14 || lko == 15 || rko == 14 || rko == 15)
      && (expr_kind == 8 || expr_kind == 9 || expr_kind == 10 || expr_kind == 11
          || expr_kind == 12 || expr_kind == 13)) {
    return;
  }
  /* wave658 Cap residual: G.7 ≡ typeck.x — ARRAY/SLICE/LINEAR must not fall through
   * type_refs_equal (host BLD001). VECTOR (13) same-size still allowed below.
   * Named struct hard-fail needs module layouts — product typeck_check_expr_binop_arith. */
  if (lko == 10 || lko == 11 || lko == 12 || rko == 10 || rko == 11 || rko == 12)
    return;
  if (lko == 13 && rko == 13 && pipeline_type_array_size_at(arena, lt_ar) == pipeline_type_array_size_at(arena, rt_ar) &&
      pipeline_typeck_type_refs_equal_c(arena, pipeline_type_elem_ref_at(arena, lt_ar),
                                        pipeline_type_elem_ref_at(arena, rt_ar)) != 0) {
    out_ar = lt_ar;
  } else if (out_ar == 0 && (lko == 5 || rko == 5)) {
    out_ar = pipeline_type_ensure_by_kind_ord(arena, 5);
  } else if (out_ar == 0 && lko == 14
             && (rk_expr == 1 /* EXPR_FLOAT_LIT */ || rk_expr == 22 /* EXPR_NEG */)) {
    /* wave317 soft-infer twin: f32 + bare FLOAT_LIT / -float stays f32 before f64 widen.
     * G.7 ≡ typeck.x typeck_coerce_init_float_lit_to_decl (inline stamp; ast_pool is
     * #include'd before glue coerce body). EXPR_FLOAT_LIT=1, EXPR_NEG=22. */
    if (rk_expr == 1) {
      pipeline_expr_set_resolved_type_ref(arena, bop_r, lt_ar);
      out_ar = lt_ar;
    } else {
      int32_t op_r = pipeline_expr_unary_operand_ref_at(arena, bop_r);
      if (op_r > 0 && pipeline_expr_kind_ord_at(arena, op_r) == 1) {
        pipeline_expr_set_resolved_type_ref(arena, op_r, lt_ar);
        pipeline_expr_set_resolved_type_ref(arena, bop_r, lt_ar);
        out_ar = lt_ar;
      }
    }
  } else if (out_ar == 0 && rko == 14
             && (lk_expr == 1 || lk_expr == 22)) {
    if (lk_expr == 1) {
      pipeline_expr_set_resolved_type_ref(arena, bop_l, rt_ar);
      out_ar = rt_ar;
    } else {
      int32_t op_l = pipeline_expr_unary_operand_ref_at(arena, bop_l);
      if (op_l > 0 && pipeline_expr_kind_ord_at(arena, op_l) == 1) {
        pipeline_expr_set_resolved_type_ref(arena, op_l, rt_ar);
        pipeline_expr_set_resolved_type_ref(arena, bop_l, rt_ar);
        out_ar = rt_ar;
      }
    }
  } else if (out_ar == 0 && (lko == 15 || rko == 15)) {
    /* wave296: f64 before f32 (usual arithmetic conversion); G.7 ≡ typeck.x / typeck_gen. */
    out_ar = pipeline_type_ensure_by_kind_ord(arena, 15);
  } else if (out_ar == 0 && (lko == 14 || rko == 14)) {
    out_ar = pipeline_type_ensure_by_kind_ord(arena, 14);
  } else if (out_ar == 0 && pipeline_typeck_type_refs_equal_c(arena, lt_ar, rt_ar) != 0) {
    out_ar = lt_ar;
  } else if (out_ar == 0 && typeck_integer_widen_ok_refs_c(arena, lt_ar, rt_ar)) {
    out_ar = lt_ar;
  } else if (out_ar == 0 && typeck_integer_widen_ok_refs_c(arena, rt_ar, lt_ar)) {
    out_ar = rt_ar;
  } else if (out_ar == 0 && lk_expr == 0 && rk_expr != 0) {
    out_ar = rt_ar;
  } else if (out_ar == 0 && rk_expr == 0 && lk_expr != 0) {
    out_ar = lt_ar;
  } else if (out_ar == 0 && lt_ar != 0) {
    out_ar = lt_ar;
  } else if (out_ar == 0 && rt_ar != 0) {
    out_ar = rt_ar;
  }
  if (expr_kind >= 4 && expr_kind <= 13)
    allow_i32_fallback = 1;
  if (out_ar == 0 && lko != 13 && rko != 13 && allow_i32_fallback)
    out_ar = pipeline_type_ensure_by_kind_ord(arena, 0);
  if (allow_i32_fallback && lko != 9 && rko != 9 &&
      (pipeline_type_kind_ord_at(arena, lt_ar) == 1 || pipeline_type_kind_ord_at(arena, rt_ar) == 1))
    out_ar = pipeline_type_ensure_by_kind_ord(arena, 0);
  if (out_ar != 0)
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, out_ar);
}

/**
 * packed struct 布局快路径：无隐式 padding；与 typeck.x typeck_struct_layout_metrics 一致。
 * 返回值：1=已写入 out_sz/out_al，0=非 packed 须走常规对齐路径，-1=字段尺寸错误。
 */
int32_t typeck_struct_layout_metrics_try_packed_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                int32_t li, int32_t depth, int32_t check_pad, int32_t *out_sz,
                                                int32_t *out_al) {
  int32_t nf;
  int32_t j;
  int32_t ftr;
  int32_t fsize;
  int32_t current;
  uint8_t layout_nm[128];
  uint8_t field_nm[128];
  int32_t layout_nlen;
  int32_t flen;
  extern int32_t typeck_x_type_size(struct ast_Module *module, struct ast_ASTArena *arena, int32_t ty_ref,
                                     int32_t depth);
  extern void driver_diagnostic_typeck_struct_field_bad_size(uint8_t *sname, int32_t sname_len, uint8_t *fname,
                                                             int32_t fname_len);
  (void)check_pad;
  if (!module || !arena || !out_sz || !out_al || li < 0)
    return 0;
  if (pipeline_module_struct_layout_packed_at(module, li) == 0)
    return 0;
  nf = pipeline_module_struct_layout_num_fields(module, li);
  current = 0;
  j = 0;
  while (j < nf) {
    ftr = pipeline_module_struct_layout_field_type_ref(module, li, j);
    pipeline_module_struct_layout_field_name_into(module, li, j, field_nm);
    flen = pipeline_module_struct_layout_field_name_len(module, li, j);
    fsize = typeck_x_type_size(module, arena, ftr, depth);
    if (fsize <= 0) {
      pipeline_module_struct_layout_name_into(module, li, layout_nm);
      layout_nlen = pipeline_module_struct_layout_name_len(module, li);
      driver_diagnostic_typeck_struct_field_bad_size(layout_nm, layout_nlen, field_nm, flen);
      return -1;
    }
    current = current + fsize;
    j = j + 1;
  }
  *out_sz = current;
  *out_al = 1;
  return 1;
}

/** typeck.x：struct_layout_metrics 写 out_sz/out_al；勿用栈上 &z/&al。 */
static int32_t g_typeck_layout_metrics_sz;
static int32_t g_typeck_layout_metrics_al;

int32_t *typeck_layout_metrics_sz_slot(void) {
  return &g_typeck_layout_metrics_sz;
}

int32_t *typeck_layout_metrics_al_slot(void) {
  return &g_typeck_layout_metrics_al;
}

/** 递归 metrics 用 depth 分槽（8 组），避免 align/size 共用单槽 tearing。 */
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
