/**
 * pipeline_asm_emit_expr_rec.c — asm ELF expr recursion dispatcher domain
 * (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding expr ELF dispatch:
 * - pipeline_asm_expr_lit_i32_at_c (INT/BOOL lit kind 0/2 → imm)
 * - pipeline_asm_emit_expr_elf_rec (fast → kind dispatch → slow)
 * - pipeline_asm_emit_expr_elf_c (public thin: rec only; no re-entry from rec)
 * - pipeline_asm_emit_expr_elf_fast (LIT/const_fold/VAR/binop arms; -99 miss)
 *
 * G.7: single product-mega expr ELF recursion face — do not open a second
 * kind-dispatch table or parallel slow-path router. Face emitters stay in
 * their domain leaves (index/match/panic/struct_lit/array_lit/assign/…);
 * return/unary/as/logand impls stay in their leaves; backend_emit_expr_elf_slow
 * remains the ultimate residual fallback.
 *
 * wave1020: G.7 fold emit_expr_elf_c + emit_expr_elf_fast residual into this
 * leaf (was glue after field_access include). Include point is after
 * field_access / call_args / binop so fast callees are defined.
 *
 * Callers: public mega body / param home / block residual via emit_expr_elf_c
 * or rec; binop load path may call fast; XLANG_DEBUG_REGEX_EMIT depth log.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after
 * pipeline_asm_emit_field_access.c (wave1020 include site).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 *   · LINUX+MACOS x86_64 SysV — kind dispatch only (encoding in callees)
 *   · MACOS|ARM64 AAPCS64 — same dispatch twin
 */

/* Forward decls / callees defined elsewhere in the same TU:
 * - PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED
 * - pipeline_asm_emit_{if,if_arm,match,panic,struct_lit,array_lit,index,...}_elf_c
 * - pipeline_asm_emit_{return,break,continue,neg,bitnot,lognot,...}_elf_impl
 * - pipeline_asm_emit_binop_{add,sub,mul,div,mod,and,shift,bitwise}_elf_c
 * - pipeline_asm_emit_field_access_elf_fast_c / glue_load_f32_var_slot_to_rax
 * - glue_load_var_as_value_to_rax_rdx_elf_c / glue_emit_float_lit_to_rax_elf_c
 * - glue_var_decl_type_ref_elf_c / pipeline_asm_modlet_load_to_rax_elf_c
 * - glue_expr_is_await_at_c / glue_expr_is_x_as_cast_at_c / assign-like
 * - glue_asm_emit_string_lit_ptr_rax_elf_c (string lit face)
 * - backend_emit_expr_elf_slow / backend_enc_mov_imm{32,64}_*_arch
 * - pipeline_expr_kind_ord_at / pipeline_expr_int_val_at /
 *   pipeline_expr_enum_namespace_field_tag
 * - link_abi_getenv
 */

/** 字面量判定：kind 序 0/2。 */
static int32_t pipeline_asm_expr_lit_i32_at_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t *out_imm) {
  int32_t ko;
  if (expr_ref == 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 0 || ko == 2) {
    *out_imm = pipeline_expr_int_val_at(arena, expr_ref);
    return 1;
  }
  return 0;
}

/** 快速路径未命中时走 backend_emit_expr_elf（slow）。 */
static int32_t pipeline_asm_emit_expr_elf_rec(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t dbg_on;
  int32_t dbg_depth_now;
  int32_t dbg_log_now;
  int32_t r;
  int32_t ko;
  int32_t out_rc;
  /* #region debug-point A:regex-asm-expr-recursion */
  static int32_t dbg_depth = 0;
  static int32_t dbg_max_depth = 0;
  static int32_t dbg_prev_expr_ref = -1;
  static int32_t dbg_prev_ko = -1;
  static int32_t dbg_same_expr_streak = 0;
  /* #endregion debug-point A:regex-asm-expr-recursion */
  dbg_on = link_abi_getenv("XLANG_DEBUG_REGEX_EMIT") != NULL ? 1 : 0;
  dbg_depth_now = 0;
  dbg_log_now = 0;
  ko = expr_ref > 0 ? pipeline_expr_kind_ord_at(arena, expr_ref) : -1;
  /* #region debug-point A:regex-asm-expr-recursion */
  if (dbg_on) {
    dbg_depth = dbg_depth + 1;
    dbg_depth_now = dbg_depth;
    if (expr_ref == dbg_prev_expr_ref && ko == dbg_prev_ko)
      dbg_same_expr_streak = dbg_same_expr_streak + 1;
    else
      dbg_same_expr_streak = 1;
    dbg_prev_expr_ref = expr_ref;
    dbg_prev_ko = ko;
    if (dbg_depth_now <= 24 || dbg_depth_now > dbg_max_depth ||
        dbg_same_expr_streak == 2 || dbg_same_expr_streak == 4 || dbg_same_expr_streak == 8 ||
        dbg_same_expr_streak == 16 || dbg_same_expr_streak == 32 || dbg_same_expr_streak == 64) {
      dbg_log_now = 1;
      if (dbg_depth_now > dbg_max_depth)
        dbg_max_depth = dbg_depth_now;
    }
    if (dbg_log_now) {
      fprintf(stderr,
              "xlang: [XLANG_DEBUG_REGEX_EMIT] rec depth=%d expr_ref=%d ko=%d streak=%d ctx=%p ta=%d\n",
              (int)dbg_depth_now, (int)expr_ref, (int)ko, (int)dbg_same_expr_streak, (void *)ctx, (int)ta);
    }
  }
  /* #endregion debug-point A:regex-asm-expr-recursion */
  r = pipeline_asm_emit_expr_elf_fast(arena, elf_ctx, expr_ref, ctx, ta);
  if (r != PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED) {
    out_rc = r;
    goto debug_done;
  }
  if (ko == 25 || ko == 27)
    out_rc = pipeline_asm_emit_expr_if_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  /** EXPR_BLOCK 需走块体同步发射；若落 slow 会把同一 expr_ref 再喂回 rec，形成自递归。 */
  else if (ko == 26)
    out_rc = pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 43)
    out_rc = pipeline_asm_emit_match_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 42)
    out_rc = pipeline_asm_emit_panic_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 45)
    out_rc = pipeline_asm_emit_struct_lit_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 46)
    out_rc = pipeline_asm_emit_array_lit_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 47)
    out_rc = pipeline_asm_emit_index_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 51)
    out_rc = pipeline_asm_emit_addr_of_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  /** wave323: EXPR_DEREF — load [ptr]; must not fall through to slow no-op. */
  else if (ko == 52)
    out_rc = pipeline_asm_emit_deref_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 48)
    out_rc = pipeline_asm_emit_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 49)
    out_rc = pipeline_asm_emit_method_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  /** STRING_LIT（kind 59）：内嵌 .text rodata，指针在 rax（fmt.println 实参等）。 */
  else if (ko == 59) {
    extern int32_t glue_asm_emit_string_lit_ptr_rax_elf_c(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          int32_t str_expr_ref, int32_t ta);
    out_rc = glue_asm_emit_string_lit_ptr_rax_elf_c(arena, elf_ctx, expr_ref, ta);
  } else if (ko >= 14 && ko <= 19)
    out_rc = pipeline_asm_emit_cmp_elf(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 41)
    out_rc = pipeline_asm_emit_return_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 39)
    out_rc = pipeline_asm_emit_break_elf_impl(arena, elf_ctx, ctx, ta);
  else if (ko == 40)
    out_rc = pipeline_asm_emit_continue_elf_impl(arena, elf_ctx, ctx, ta);
  else if (ko == 22)
    out_rc = pipeline_asm_emit_neg_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 23)
    out_rc = pipeline_asm_emit_bitnot_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 24)
    out_rc = pipeline_asm_emit_lognot_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  else if (glue_expr_is_await_at_c(arena, expr_ref))
    out_rc = pipeline_asm_emit_await_sync_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  else if (glue_expr_is_x_as_cast_at_c(arena, expr_ref))
    out_rc = pipeline_asm_emit_as_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == GLUE_EXPR_KIND_TRY_PROPAGATE || ko == GLUE_EXPR_KIND_C_TRY_PROPAGATE)
    out_rc = pipeline_asm_emit_try_propagate_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  else if (glue_expr_kind_is_assign_like_ord(ko))
    out_rc = pipeline_asm_emit_assign_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 20)
    out_rc = pipeline_asm_emit_logand_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 21)
    out_rc = pipeline_asm_emit_logor_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  /** FIELD_ACCESS 已在 fast 尝试过（含链式 v.al.kind）；勿落 slow（与 rec 互递归 SIGSEGV）。 */
  else if (ko == 44) {
    int32_t ns_tag = pipeline_expr_enum_namespace_field_tag(arena, expr_ref);
    if (ns_tag >= 0)
      out_rc = backend_enc_mov_imm32_to_w0_arch(elf_ctx, ns_tag, ta);
    else
      out_rc = -1;
  } else
    out_rc = backend_emit_expr_elf_slow(arena, elf_ctx, expr_ref, ctx, ta);
debug_done:
  /* #region debug-point A:regex-asm-expr-recursion */
  if (dbg_on && dbg_log_now && out_rc == PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED) {
    fprintf(stderr,
            "xlang: [XLANG_DEBUG_REGEX_EMIT] unhandled depth=%d expr_ref=%d ko=%d\n",
            (int)dbg_depth_now, (int)expr_ref, (int)ko);
  }
  if (dbg_on && dbg_depth > 0)
    dbg_depth = dbg_depth - 1;
  /* #endregion debug-point A:regex-asm-expr-recursion */
  return out_rc;
}


/* wave1020 G.7: public emit_expr_elf_c + emit_expr_elf_fast folded from
 * pipeline_glue residual (after field_access include site). */

/**
 * emit_expr_elf 统一 C 入口（fast + rec）；供日后 X 薄包装，勿在 rec 内再回调本符号。
 */
int32_t pipeline_asm_emit_expr_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                     int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, expr_ref, ctx, ta);
}

/**
 * emit_expr_elf 快速路径：LIT/const_fold/RETURN/算术二元；未命中返回 -99 由 .x 尾 return 结束函数。
 */
int32_t pipeline_asm_emit_expr_elf_fast(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                        int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  struct ast_Expr *e;
  int32_t ko;
  if (expr_ref == 0)
    return -1;
  if (!arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  e = pipeline_arena_expr_ptr(arena, expr_ref);
  if (!e)
    return -1;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  /**
   * 形参/局部 VAR 勿走 CTFE 快速路径（池字段未初始化或与 C 布局错位时会误折叠为 0）。
   * CALL with pre-emit fold: default mov imm (authority = typeck CTFE).
   * XLANG_WPO_MONO / XLANG_WPO_NO_FOLD still need the call dispatch (mono thunk or real call).
   * PLATFORM: SHARED — env gates for WPO-S2 harness only.
   */
  if (e->const_folded_valid != 0 && ko != (int32_t)ast_ExprKind_EXPR_VAR) {
    int32_t cfold_imm = e->const_folded_val;
    int32_t cfold_use_imm32 = 1;
    if (ko == (int32_t)ast_ExprKind_EXPR_CALL) {
      const char *wpo_mono = link_abi_getenv("XLANG_WPO_MONO");
      const char *wpo_nofold = link_abi_getenv("XLANG_WPO_NO_FOLD");
      if ((wpo_mono && wpo_mono[0]) || (wpo_nofold && wpo_nofold[0]))
        cfold_use_imm32 = 0; /* fall through to CALL emit / mono path */
    }
    if (cfold_use_imm32) {
      /*
       * wave306: const_folded_val is i32. Non-negative → mov_imm32 (zero-extend OK).
       * Negative → mov_imm64 with sign-extended hi so i64 slots keep 0xff.. high bits
       * (same residual as bare EXPR_LIT -1 via mov_imm32).
       * wave310: unsigned narrow target (TYPE_U8 / TYPE_U32 / NAMED u16) must
       * materialize the bit-pattern width (0xff / 0xffff / 0xffffffff) via
       * mov_imm32 — full sign-extended -1 makes freestanding `a:u8=-1; a==255`
       * load 0xffffffff and fail the 0xff compare (host-gcc truncates on store).
       * PLATFORM: SHARED emit width / LINUX+MACOS freestanding.
       */
      {
        int32_t cfold_tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
        int32_t cfold_k = (cfold_tr > 0) ? pipeline_type_kind_ord_at(arena, cfold_tr) : -1;
        if (cfold_k == (int32_t)ast_TypeKind_TYPE_U8)
          return backend_enc_mov_imm32_to_w0_arch(elf_ctx, (int32_t)((uint32_t)cfold_imm & 0xffu), ta);
        if (cfold_k == (int32_t)ast_TypeKind_TYPE_U32)
          return backend_enc_mov_imm32_to_w0_arch(elf_ctx, cfold_imm, ta); /* low 32 bits; zext high */
        if (cfold_k == (int32_t)ast_TypeKind_TYPE_NAMED) {
          uint8_t nm[128];
          int32_t nlen = pipeline_type_named_name_into(arena, cfold_tr, nm);
          if (nlen == 3 && nm[0] == (uint8_t)'u' && nm[1] == (uint8_t)'1' && nm[2] == (uint8_t)'6')
            return backend_enc_mov_imm32_to_w0_arch(elf_ctx, (int32_t)((uint32_t)cfold_imm & 0xffffu), ta);
        }
        /*
         * wave318: CTFE folds int lit before EXPR_LIT IEEE path. Stamped f32/f64
         * (`let a: f32 = 6`) still held const_folded_val=6 as integer → mov $6
         * into f32 slot (Ubuntu freestanding run=0). Convert folded i32 to IEEE.
         * PLATFORM: SHARED / LINUX+MACOS freestanding.
         */
        if (cfold_k == GLUE_TYPE_KIND_F32_ORD) {
          float fv = (float)cfold_imm;
          uint32_t fb = 0;
          memcpy(&fb, &fv, sizeof(fb));
          return backend_enc_mov_imm32_to_w0_arch(elf_ctx, (int32_t)fb, ta);
        }
        if (cfold_k == GLUE_TYPE_KIND_F64_ORD) {
          double dv = (double)cfold_imm;
          uint64_t u = 0;
          memcpy(&u, &dv, sizeof(u));
          return backend_enc_mov_imm64_to_rax_arch(elf_ctx, (int32_t)(u & 0xffffffffu),
                                                   (int32_t)(u >> 32), ta);
        }
      }
      if (cfold_imm >= 0)
        return backend_enc_mov_imm32_to_w0_arch(elf_ctx, cfold_imm, ta);
      {
        int64_t v64 = (int64_t)cfold_imm; /* sign-extend i32 → i64 */
        uint64_t u = (uint64_t)v64;
        int32_t lo = (int32_t)(u & 0xffffffffu);
        int32_t hi = (int32_t)(u >> 32);
        return backend_enc_mov_imm64_to_rax_arch(elf_ctx, lo, hi, ta);
      }
    }
  }
  /**
   * wave305 Cap residual pure: EXPR_LIT / BOOL_LIT may hold full i64 (lexer +
   * parser_alloc_int_lit). Prior always mov_imm32 → freestanding truncated
   * values outside signed int32 (same soft residual as i32 sidecar).
   * wave306: negative values that fit i32 still must use mov_imm64 — mov_imm32
   * writes eax and zero-extends RAX, so `let a: i64 = -1` became 0xffffffff
   * not 0xffffffffffffffff (high bits 0; `a >> 32` freestanding run=0).
   * Non-negative values in 0..INT32_MAX keep mov_imm32. Outside that range or
   * any negative → mov_imm64 lo/hi (existing encoder; arm64 seed must emit all
   * four halfwords — see arch_arm64_enc_enc_mov_imm64_to_rax).
   * BOOL_LIT stays 0/1 so still takes the imm32 path.
   * wave318 Cap residual pure: typeck may stamp bare EXPR_LIT as f32/f64
   * (`let a: f32 = 6` / `return 6` after lit coerce). Emitting integer 6 in
   * eax then movd→xmm0 is a denormal float (~0 after cvttss2si) → Ubuntu
   * freestanding run=0 (mac host-gcc C converts). Convert int payload to IEEE
   * bits; G.7 next to glue_emit_float_lit (FLOAT_LIT path remains kind==1).
   * PLATFORM: SHARED cast path / LINUX+MACOS x86_64+arm64 emit.
   */
  if (ko == 0 || ko == 2) {
    int64_t v64 = pipeline_expr_int64_val_at(arena, expr_ref);
    if (ko == 0) {
      int32_t rty = pipeline_expr_resolved_type_ref(arena, expr_ref);
      if (rty > 0) {
        int32_t rk = pipeline_type_kind_ord_at(arena, rty);
        if (rk == GLUE_TYPE_KIND_F32_ORD) {
          float fv = (float)v64;
          uint32_t fb = 0;
          memcpy(&fb, &fv, sizeof(fb));
          return backend_enc_mov_imm32_to_w0_arch(elf_ctx, (int32_t)fb, ta);
        }
        if (rk == GLUE_TYPE_KIND_F64_ORD) {
          double dv = (double)v64;
          uint64_t u = 0;
          memcpy(&u, &dv, sizeof(u));
          return backend_enc_mov_imm64_to_rax_arch(elf_ctx, (int32_t)(u & 0xffffffffu),
                                                   (int32_t)(u >> 32), ta);
        }
      }
    }
    if (ko == 2 || (v64 >= 0 && v64 <= (int64_t)INT32_MAX))
      return backend_enc_mov_imm32_to_w0_arch(elf_ctx, (int32_t)v64, ta);
    {
      uint64_t u = (uint64_t)v64;
      int32_t lo = (int32_t)(u & 0xffffffffu);
      int32_t hi = (int32_t)(u >> 32);
      return backend_enc_mov_imm64_to_rax_arch(elf_ctx, lo, hi, ta);
    }
  }
  if (ko == 1)
    return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, expr_ref, ta, 0, 0);
  if (ko == 50)
    return backend_enc_mov_imm32_to_w0_arch(elf_ctx, pipeline_expr_enum_variant_tag_at(arena, expr_ref), ta);
  if (ko == 44)
    return pipeline_asm_emit_field_access_elf_fast_c(arena, elf_ctx, expr_ref, ctx, ta);
  /** EXPR_VAR：走 C 读名 + sidecar 偏移，勿 ast_arena_expr_get + local_offset slow。 */
  if (ko == 3) {
    uint8_t vname[128];
    int32_t vlen = pipeline_expr_var_name_len(arena, expr_ref);
    int32_t off;
    if (vlen <= 0)
      return -1;
    pipeline_expr_var_name_into(arena, expr_ref, vname);
    /**
     * Prefer module shared modlet over hoist/local stack so set_g/get_g see one cell
     * (true cross-fn share; not const-fold).
     */
    if (pipeline_asm_modlet_load_to_rax_elf_c(elf_ctx, vname, vlen, ta) == 0)
      return 0;
    off = glue_call_arg_resolve_var_stack_off_elf_c(arena, ctx, expr_ref);
    if (off < 0) {
      int32_t mod_imm;
      /** 库模块多函数：顶层 const 仅 hoist 进首个函数体，其它函数 VAR 回落模块 const 字面量。 */
      if (g_pipeline_asm_emit_module &&
          asm_module_top_level_const_lit_i32(g_pipeline_asm_emit_module, arena, vname, vlen, &mod_imm) != 0)
        return backend_enc_mov_imm32_to_w0_arch(elf_ctx, mod_imm, ta);
      return -1;
    }
    {
      int32_t vtr = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
      if (vtr > 0 && pipeline_type_kind_ord_at(arena, vtr) == GLUE_TYPE_KIND_F32_ORD)
        return glue_load_f32_var_slot_to_rax_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta);
    }
    return glue_load_var_as_value_to_rax_rdx_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta);
  }
  /* EXPR_RETURN 走 slow（emit 操作数 + jmp tail_join）；fast 仅剥壳会漏 jmp 导致 SIGSEGV。 */
  if (ko == (int32_t)ast_ExprKind_EXPR_RETURN)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  if (ko == 4)
    return pipeline_asm_emit_binop_add_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                              pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
  if (ko == 5)
    return pipeline_asm_emit_binop_sub_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                              pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
  if (ko == 6)
    return pipeline_asm_emit_binop_mul_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                              pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
  if (ko == 7)
    return pipeline_asm_emit_binop_div_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                              pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
  if (ko == 8)
    return pipeline_asm_emit_binop_mod_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                              pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
  if (ko == 11)
    return pipeline_asm_emit_binop_and_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                              pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta);
  if (ko == 9)
    return pipeline_asm_emit_binop_shift_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                               pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta, 0);
  if (ko == 10)
    return pipeline_asm_emit_binop_shift_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                               pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta, 1);
  if (ko == 12)
    return pipeline_asm_emit_binop_bitwise_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                                 pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta, 0);
  if (ko == 13)
    return pipeline_asm_emit_binop_bitwise_elf_c(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, expr_ref),
                                                 pipeline_expr_binop_right_ref_at(arena, expr_ref), ctx, ta, 1);
  return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
}
