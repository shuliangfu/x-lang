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

/*
 * wave1160 G.7: static fwd decl for glue_arena_expr_at_ref (defined in
 * pipeline_glue.c L2501, after this file's #include at L2210). The 10
 * expr accessor wrappers migrated to this file's EOF use it for
 * bounds-checked Expr pointer retrieval. Safe within same TU (C11
 * allows static fwd decl within same translation unit).
 */
static struct ast_Expr *glue_arena_expr_at_ref(struct ast_ASTArena *a, int32_t expr_ref);

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
  /* wave133 pure leave: public faces (was static *_impl in unary.c). */
  else if (ko == 22)
    out_rc = pipeline_asm_emit_neg_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 23)
    out_rc = pipeline_asm_emit_bitnot_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 24)
    out_rc = pipeline_asm_emit_lognot_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
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
 * Freestanding match field-bind: bare VAR name under active match subject →
 * load matched_subject.field into rax (stack home + layout offset).
 *
 * Why: host-C rewrites `x` to `(matched).x` (codegen wave707). Pure-asm MATCH
 * arms keep bare VARs with no local slot; without this hop Ubuntu pure-asm
 * CG002s on `Point { x, y } => x + y`.
 *
 * G.7: consumes pipeline_codegen_match_* subject set by
 * pipeline_asm_emit_match_elf_c; reuses glue_field_layout_offset_for_var_base_field
 * + glue_enc_local_slot_ptr_or_addr (same authority as VAR-base FIELD_ACCESS).
 *
 * @return 0 success, -1 not applicable or emit fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS co-path
 */
static int32_t glue_try_emit_match_subject_field_var_elf_c(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                          uint8_t *vname, int32_t vlen) {
  int32_t mref;
  int32_t foff;
  int32_t base_off;
  int32_t load_sz;
  if (!arena || !elf_ctx || !ctx || !vname || vlen <= 0 || !g_pipeline_asm_emit_module)
    return -1;
  if (pipeline_codegen_match_name_is_subject_field_c(g_pipeline_asm_emit_module, arena, vname, vlen) == 0)
    return -1;
  mref = pipeline_codegen_match_matched_ref_c();
  if (mref <= 0 || pipeline_expr_kind_ord_at(arena, mref) != 3)
    return -1;
  foff = glue_field_layout_offset_for_var_base_field(arena, g_pipeline_asm_emit_module, mref, vname, vlen);
  if (foff < 0)
    return -1;
  base_off = glue_call_arg_resolve_var_stack_off_elf_c(arena, ctx, mref);
  if (base_off < 0)
    base_off = glue_var_expr_stack_off_elf_c(arena, ctx, mref);
  if (base_off < 0)
    return -1;
  if (glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, mref, base_off, ctx, ta) != 0)
    return -1;
  if (foff != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, foff, ta) != 0)
    return -1;
  /* Scalar field load size: prefer layout field type width; default i32. */
  load_sz = 4;
  {
    int32_t subj_ty = pipeline_codegen_match_subject_ty_c();
    if (subj_ty > 0 && pipeline_type_kind_ord_at(arena, subj_ty) == (int32_t)ast_TypeKind_TYPE_NAMED) {
      uint8_t tnm[128];
      int32_t tnl = pipeline_type_named_name_into(arena, subj_ty, tnm);
      int32_t k;
      if (tnl > 0) {
        k = glue_struct_layout_index_by_type_name_c(g_pipeline_asm_emit_module, tnm, tnl);
        if (k >= 0) {
          int32_t nf = pipeline_module_struct_layout_num_fields(g_pipeline_asm_emit_module, k);
          int32_t fi;
          for (fi = 0; fi < nf; fi++) {
            int32_t fnl = pipeline_module_struct_layout_field_name_len(g_pipeline_asm_emit_module, k, fi);
            if (fnl != vlen)
              continue;
            {
              uint8_t fnm[128];
              int32_t j;
              int32_t match = 1;
              pipeline_module_struct_layout_field_name_into(g_pipeline_asm_emit_module, k, fi, fnm);
              for (j = 0; j < fnl && match; j++) {
                if (fnm[j] != vname[j])
                  match = 0;
              }
              if (match) {
                int32_t ftr = pipeline_module_struct_layout_field_type_ref(g_pipeline_asm_emit_module, k, fi);
                if (ftr > 0) {
                  int32_t sz = glue_type_size_simple(g_pipeline_asm_emit_module, arena, ftr, 0);
                  if (sz == 1 || sz == 4 || sz == 8)
                    load_sz = sz;
                }
                break;
              }
            }
          }
        }
      }
    }
  }
  if (load_sz == 1)
    return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
  if (load_sz == 8)
    return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
  return backend_enc_load_32_from_rax_arch(elf_ctx, ta);
}

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
      /*
       * Freestanding match field-bind: bare `x`/`y` under MATCH subject →
       * load subject.field (G.7 twin of host-C wave707). Local slots win
       * above; only unbound names hop here.
       */
      if (glue_try_emit_match_subject_field_var_elf_c(arena, elf_ctx, ctx, ta, vname, vlen) == 0)
        return 0;
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

/* ============================================================
 * wave1160 G.7: expr accessor public wrappers (10 fns) +
 * ast_pipeline_* forwarding wrappers (9 fns) migrated from
 * pipeline_glue.c L3564-3625 / L10412-10449. Colocated with expr
 * ELF recursion dispatcher — these are the field readers consumed
 * by emit_expr_elf_rec / emit_expr_elf_fast above. Fwd decls at
 * glue.c L1532-1578 (before #include L2210).
 */

/**
 * Read EXPR_AS operand expr ref. Returns 0 for invalid ref.
 * Used by emit_expr_elf_rec EXPR_AS arm to load the cast source.
 */
int32_t pipeline_expr_as_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->as_operand_ref : 0;
}

/**
 * Read EXPR_AS target type pool ref. Returns 0 for invalid ref.
 * Used by typeck return path and emit EXPR_AS arm to determine
 * the cast target type.
 */
int32_t pipeline_expr_as_target_type_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->as_target_type_ref : 0;
}

/**
 * Read EXPR_ENUM_VARIANT / FIELD_ACCESS enum variant tag.
 * Returns 0 for invalid ref. Used by emit_expr_elf_rec to emit
 * the variant ordinal as immediate.
 */
int32_t pipeline_expr_enum_variant_tag_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->enum_variant_tag : 0;
}

/**
 * Read EXPR_IF/EXPR_TERNARY condition expr ref.
 * Returns 0 for invalid ref.
 */
int32_t pipeline_expr_if_cond_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->if_cond_ref : 0;
}

/**
 * Read EXPR_IF/EXPR_TERNARY then-branch expr ref.
 * Returns 0 for invalid ref.
 */
int32_t pipeline_expr_if_then_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->if_then_ref : 0;
}

/**
 * Read EXPR_IF/EXPR_TERNARY else-branch expr ref.
 * Returns 0 for invalid ref.
 */
int32_t pipeline_expr_if_else_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->if_else_ref : 0;
}

/**
 * Read EXPR_BLOCK inner block ref. Returns 0 for invalid ref.
 * Used by emit_expr_elf_rec EXPR_BLOCK arm and typeck tail-expr scan.
 */
int32_t pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->block_ref : 0;
}

/**
 * Read EXPR_MATCH matched-value expr ref. Returns 0 for invalid ref.
 * Used by emit_expr_elf_rec EXPR_MATCH arm and typeck check_expr_match.
 */
int32_t pipeline_expr_match_matched_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->match_matched_ref : 0;
}

/**
 * Read CTFE const-folded valid flag. Returns 0 for invalid ref.
 * Used by emit_expr_elf_fast to short-circuit folded constants.
 */
int32_t pipeline_expr_const_folded_valid_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? (int32_t)ex->const_folded_valid : 0;
}

/**
 * Read CTFE const-folded integer value. Returns 0 for invalid ref.
 * Used by emit_expr_elf_fast to emit folded constant as immediate.
 */
int32_t pipeline_expr_const_folded_val_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->const_folded_val : 0;
}

/*
 * ast_pipeline_* forwarding wrappers: codegen may prepend ast_ prefix
 * when importing the ast module; each delegates to the pipeline_expr_*
 * bare symbol defined above.
 */

int32_t ast_pipeline_expr_as_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_as_operand_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_enum_variant_tag_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_enum_variant_tag_at(a, expr_ref);
}

int32_t ast_pipeline_expr_if_cond_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_if_cond_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_if_then_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_if_then_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_if_else_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_if_else_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_block_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_match_matched_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_match_matched_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_const_folded_valid_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_const_folded_valid_at(a, expr_ref);
}

int32_t ast_pipeline_expr_const_folded_val_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_const_folded_val_at(a, expr_ref);
}

/* ============================================================
 * wave1161 G.7: index/field_access/line/col accessor public wrappers
 * (10 fns) + ast_pipeline_* forwarding wrappers (3 fns) migrated from
 * pipeline_glue.c L3816-3950 / L10382-10392. Colocated with expr ELF
 * recursion dispatcher — these field readers/writers are consumed by
 * emit_expr_elf_rec / emit_expr_elf_fast and typeck index/field checks.
 * Fwd decls at glue.c L1554-1565 (before #include L2210).
 */

/**
 * Read EXPR_INDEX base expr ref. Returns 0 for invalid ref.
 * Used by emit_expr_elf_rec EXPR_INDEX arm to load the indexed value.
 */
int32_t pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->index_base_ref : 0;
}

/**
 * Read EXPR_INDEX index expr ref. Returns 0 for invalid ref.
 * Used by emit_expr_elf_rec EXPR_INDEX arm to load the index operand.
 */
int32_t pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->index_index_ref : 0;
}

/**
 * Read resolved_type_ref from arena-pooled Expr. Returns 0 for invalid
 * ref. Used throughout typeck and asm emit to determine the inferred
 * type of an expression.
 */
int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->resolved_type_ref : 0;
}

/**
 * Write resolved_type_ref on arena-pooled Expr. Called by typeck.x
 * EMIT_HEAVY emit path to stamp the inferred type without Expr
 * by-value get/set (which tears the struct on the asm backend).
 * Includes optional XLANG_TRACE_EXPR_SET debug tracing.
 */
void pipeline_expr_set_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t type_ref) {
  struct ast_Expr *ex;
  const char *trace_expr;
  int32_t trace_ref;
  int32_t old_ref;

  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return;
  old_ref = ex->resolved_type_ref;
  ex->resolved_type_ref = type_ref;
  trace_expr = link_abi_getenv("XLANG_TRACE_EXPR_SET");
  if (!trace_expr || !*trace_expr)
    return;
  trace_ref = atoi(trace_expr);
  if (trace_ref != expr_ref)
    return;
  fprintf(stderr, "note: expr set debug: expr=%d kind=%d block=%d old_ty=%d new_ty=%d\n", (int)expr_ref,
          (int)ex->kind, (int)ex->block_ref, (int)old_ref, (int)type_ref);
}

/**
 * Write index_base_is_slice flag on EXPR_INDEX. Called by typeck
 * index bounds check to mark slice-typed bases for asm emit.
 * Avoids ast_arena_expr_set (EMIT_HEAVY asm struct tear).
 */
void pipeline_expr_set_index_base_is_slice(struct ast_ASTArena *a, int32_t expr_ref, int32_t v) {
  struct ast_Expr *ex;

  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return;
  ex->index_base_is_slice = v;
}

/**
 * Write index_proven_in_bounds flag on EXPR_INDEX. Called by typeck
 * after static bounds proof to skip runtime bounds check in asm emit.
 */
void pipeline_expr_set_index_proven_in_bounds(struct ast_ASTArena *a, int32_t expr_ref, int32_t v) {
  struct ast_Expr *ex;

  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return;
  ex->index_proven_in_bounds = v;
}

/**
 * Read source line number from Expr. Returns 0 for invalid ref.
 * Used by break/continue diagnostics and typeck error reporting.
 */
int32_t pipeline_expr_line_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->line : 0;
}

/**
 * Read source column number from Expr. Returns 0 for invalid ref.
 * Used by break/continue diagnostics and typeck error reporting.
 */
int32_t pipeline_expr_col_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->col : 0;
}

/**
 * Read FIELD_ACCESS byte offset. Returns 0 for invalid ref.
 * Used by asm emit to compute the field address (base + offset).
 */
int32_t pipeline_expr_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->field_access_offset : 0;
}

/**
 * Write FIELD_ACCESS byte offset. Called by typeck field layout
 * resolver. Avoids ast_arena_expr_set (EMIT_HEAVY asm struct tear).
 */
void pipeline_expr_set_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref, int32_t offset) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (ex)
    ex->field_access_offset = offset;
}

/**
 * Read FIELD_ACCESS SoA column stride (DOD-S1). Returns 0 for AoS
 * static offset. Used by asm emit for SoA struct field access.
 */
int32_t pipeline_expr_field_access_soa_stride(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->field_access_soa_stride : 0;
}

/* ast_pipeline_* forwarding wrappers for index/field_access accessors. */

int32_t ast_pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_index_base_ref(a, expr_ref);
}

int32_t ast_pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_index_index_ref(a, expr_ref);
}

int32_t ast_pipeline_expr_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_field_access_offset(a, expr_ref);
}

/* ============================================================
 * wave1162 G.7: lit/var/field_access/unary/binop accessor public
 * wrappers (13 fns) migrated from pipeline_glue.c L3244-3422.
 * Colocated with expr ELF recursion dispatcher — these are the
 * field readers consumed by emit_expr_elf_rec / emit_expr_elf_fast
 * and typeck expr check paths. Fwd decls at glue.c L1530-1571.
 */

/**
 * Read EXPR_LIT/EXPR_BOOL_LIT int_val as i32. Returns 0 for invalid
 * ref. Backend asm must not use ast_arena_expr_get (large module
 * stack overflow risk).
 */
int32_t pipeline_expr_int_val_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? (int32_t)ex->int_val : 0;
}

/**
 * Read EXPR_LIT full i64 value (avoids int32 truncation for
 * INT64_MIN and large constants like P0-4).
 */
int64_t pipeline_expr_int64_val_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->int_val : 0;
}

/**
 * Read EXPR_NEG/EXPR_BITNOT/EXPR_LOGNOT unary operand ref.
 * Returns 0 for invalid ref. typeck check_block_impl block-tail
 * `return;` detection uses this glue (not ast_arena_expr_get
 * which fails on bootstrap asm FIELD_ACCESS).
 */
int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->unary_operand_ref : 0;
}

/**
 * Copy FIELD_ACCESS field name into out64 (u8[128], max 127 bytes
 * + zero-fill). wave577 Cap: output buffer is u8[128].
 */
void pipeline_expr_field_access_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64) {
  struct ast_Expr *ex;
  int32_t nlen;
  if (!out64)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 128);
    return;
  }
  nlen = ex->field_access_field_len;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 127)
    nlen = 127;
  memset(out64, 0, 128);
  if (nlen > 0)
    memcpy(out64, ex->field_access_field_name, (size_t)nlen);
}

/**
 * Read FIELD_ACCESS field name length. Returns 0 for non-FIELD_ACCESS
 * or invalid ref.
 */
int32_t pipeline_expr_field_access_name_len(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_FIELD_ACCESS)
    return 0;
  return ex->field_access_field_len;
}

/**
 * Read FIELD_ACCESS base_ref. Returns 0 for non-FIELD_ACCESS or
 * invalid ref.
 */
int32_t pipeline_expr_field_access_base_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_FIELD_ACCESS)
    return 0;
  return ex->field_access_base_ref;
}

/**
 * Copy EXPR_VAR variable name into out64 (u8[128], max 127 bytes
 * + zero-fill).
 */
void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64) {
  struct ast_Expr *ex;
  int32_t nlen;
  if (!out64)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 128);
    return;
  }
  nlen = ex->var_name_len;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 127)
    nlen = 127;
  memset(out64, 0, 128);
  if (nlen > 0)
    memcpy(out64, ex->var_name, (size_t)nlen);
}

/**
 * Read STRING_LIT (kind 59) byte length. Returns 0 for non-string-lit
 * or invalid ref.
 */
int32_t pipeline_expr_var_name_len_for_string_lit_c(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || (int32_t)ex->kind != 59)
    return 0;
  return ex->var_name_len;
}

/**
 * Read EXPR_VAR name length. Returns 0 for non-VAR or invalid ref.
 */
int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_VAR)
    return 0;
  return ex->var_name_len;
}

/**
 * wave670 Cap residual: keyword `null` is EXPR_LIT int_val=0 tagged
 * var_name="null"/len=4. G.7 single null face.
 * PLATFORM: SHARED.
 */
int32_t pipeline_expr_is_null_keyword_c(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || (int32_t)ex->kind != 0 /* EXPR_LIT */)
    return 0;
  if (ex->int_val != 0 || ex->var_name_len != 4)
    return 0;
  if (ex->var_name[0] == (uint8_t)'n' && ex->var_name[1] == (uint8_t)'u' &&
      ex->var_name[2] == (uint8_t)'l' && ex->var_name[3] == (uint8_t)'l')
    return 1;
  return 0;
}

/**
 * Tag EXPR_LIT 0 as keyword null on the live arena expr.
 * Use after parser_asm primary set — avoids parser_asm_ast_expr ↔
 * ast_Expr memcpy layout drift (mac vs gcc) losing var_name tag.
 * PLATFORM: SHARED.
 */
void pipeline_expr_tag_null_keyword_c(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  int32_t zi;
  if (!ex)
    return;
  ex->kind = ast_ExprKind_EXPR_LIT;
  ex->int_val = 0;
  ex->var_name[0] = (uint8_t)'n';
  ex->var_name[1] = (uint8_t)'u';
  ex->var_name[2] = (uint8_t)'l';
  ex->var_name[3] = (uint8_t)'l';
  ex->var_name_len = 4;
  for (zi = 4; zi < 128; zi++)
    ex->var_name[zi] = 0;
}

/** Read expr.binop_left_ref. Returns 0 for invalid ref. */
int32_t pipeline_expr_binop_left_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->binop_left_ref : 0;
}

/** Read expr.binop_right_ref. Returns 0 for invalid ref. */
int32_t pipeline_expr_binop_right_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->binop_right_ref : 0;
}

/* wave1183 G.7: Forward declarations for pipeline_expr_* functions defined
 * in ast_pool_expr_sidecar.c (included later via ast_pool.c #include L4607).
 * Needed because the ast_pipeline_expr_* forwarders below call these before
 * their definitions appear in the same TU. */
int32_t pipeline_expr_append_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref);
void pipeline_expr_on_call_created(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_prepare_call_arg_slot(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_append_method_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref);
int32_t pipeline_expr_append_match_arm(struct ast_ASTArena *a, int32_t expr_ref, int32_t result_ref,
                                       int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant,
                                       int32_t variant_index);
void pipeline_expr_match_arm_set_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v);
void pipeline_expr_match_arm_set_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v);
void pipeline_expr_match_arm_set_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i,
                                              int32_t is_var, int32_t variant_index);
int32_t pipeline_expr_append_struct_lit_field(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *name_bytes,
                                              int32_t name_len, int32_t init_ref);
int32_t pipeline_expr_append_array_lit_elem(struct ast_ASTArena *a, int32_t expr_ref, int32_t elem_ref);
int32_t pipeline_module_import_append_select_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);

/* wave1183 G.7: ast_pipeline_expr_* + codegen_pipeline_expr_* +
 * backend_pipeline_expr_* forwarder cluster (40 fns) migrated from
 * pipeline_glue.c to this file's EOF.
 *
 * Why colocate: ast.x / codegen.x / backend.x resolve extern pipeline_expr_*
 * symbols with module prefixes at codegen time (ast_pipeline_expr_*,
 * codegen_pipeline_expr_*, backend_pipeline_expr_*), but the authoritative
 * implementations live in ast_pool_expr_sidecar.c / pipeline_asm_emit_expr_rec.c
 * with unprefixed C names (pipeline_expr_*). These 40 thin forwarders exist
 * solely to satisfy the linker name-mangling gap; colocating them here
 * keeps pipeline_glue.c focused on real glue logic.
 *
 * Sub-clusters:
 *  - codegen_pipeline_module_func_param_type_ref_at (1 fn: codegen_ prefix)
 *  - ast_pipeline_expr_call_* (6 fns: append_arg/on_created/prepare_slot/
 *    arg_ref/num_args/callee_ref -- call expr sidecar accessors)
 *  - ast_pipeline_expr_method_call_* (5 fns: append_arg/arg_ref/num_args/
 *    name_len/name_into -- method call sidecar accessors)
 *  - ast_pipeline_expr_match_* (10 fns: append_arm/num_arms/result_ref/
 *    is_wildcard/lit_val/is_enum_variant/variant_index/set_wildcard/
 *    set_lit_val/set_enum_variant -- match arm sidecar accessors)
 *  - ast_pipeline_expr_struct_lit/array_lit/float/if/block/match/const_folded
 *    (12 fns: append_field/append_elem/elem_ref/num_elems/bits_lo/hi/
 *    cond_ref/then_ref/else_ref/block_ref/matched_ref/const_folded_valid/val)
 *  - ast_pipeline_expr_index/field_access (6 fns: base_ref/index_ref/
 *    is_enum_variant/offset/layout_offset/load_byte_sz)
 *  - ast_pipeline_module_import_append_select_name (1 fn: import select name)
 *  - codegen_pipeline_expr_* + backend_pipeline_expr_* (5 fns: kind_ord/
 *    struct_lit_num_fields/init_ref -- codegen_ and backend_ prefix twins)
 *
 * Contract: every function here is a pure pass-through -- no state mutation,
 *   no branch, single tail call to the underlying pipeline_expr_* impl.
 *
 * PLATFORM: SHARED -- forwarders are platform-agnostic.
 */
int32_t codegen_pipeline_module_func_param_type_ref_at(struct ast_Module *m, int32_t func_index,
                                                       int32_t param_index) {
  return pipeline_module_func_param_type_ref_at(m, func_index, param_index);
}

/** Expr sidecar pool symbol forwarders called via import prefix by ast.x / typeck / codegen / backend / parser. */
int32_t ast_pipeline_expr_append_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref) {
  return pipeline_expr_append_call_arg(a, expr_ref, arg_ref);
}
void ast_pipeline_expr_on_call_created(struct ast_ASTArena *a, int32_t expr_ref) {
  pipeline_expr_on_call_created(a, expr_ref);
}
int32_t ast_pipeline_expr_prepare_call_arg_slot(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_prepare_call_arg_slot(a, expr_ref);
}
int32_t ast_pipeline_expr_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  return pipeline_expr_call_arg_ref(a, expr_ref, idx);
}
int32_t ast_pipeline_expr_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_call_num_args_at(a, expr_ref);
}
int32_t ast_pipeline_expr_append_method_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref) {
  return pipeline_expr_append_method_call_arg(a, expr_ref, arg_ref);
}
int32_t ast_pipeline_expr_method_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  return pipeline_expr_method_call_arg_ref(a, expr_ref, idx);
}
int32_t ast_pipeline_expr_append_match_arm(struct ast_ASTArena *a, int32_t expr_ref, int32_t result_ref,
                                           int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant,
                                           int32_t variant_index) {
  return pipeline_expr_append_match_arm(a, expr_ref, result_ref, is_wildcard, lit_val, is_enum_variant,
                                        variant_index);
}
int32_t ast_pipeline_expr_match_num_arms_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_match_num_arms_at(a, expr_ref);
}
int32_t ast_pipeline_expr_match_arm_result_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_result_ref(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_is_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_is_wildcard(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_lit_val(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_is_enum_variant(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_variant_index(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_variant_index(a, expr_ref, i);
}
void ast_pipeline_expr_match_arm_set_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v) {
  pipeline_expr_match_arm_set_wildcard(a, expr_ref, i, v);
}
void ast_pipeline_expr_match_arm_set_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v) {
  pipeline_expr_match_arm_set_lit_val(a, expr_ref, i, v);
}
void ast_pipeline_expr_match_arm_set_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i,
                                                  int32_t is_var, int32_t variant_index) {
  pipeline_expr_match_arm_set_enum_variant(a, expr_ref, i, is_var, variant_index);
}
int32_t ast_pipeline_expr_append_struct_lit_field(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *name_bytes,
                                                  int32_t name_len, int32_t init_ref) {
  return pipeline_expr_append_struct_lit_field(a, expr_ref, name_bytes, name_len, init_ref);
}
int32_t ast_pipeline_expr_append_array_lit_elem(struct ast_ASTArena *a, int32_t expr_ref, int32_t elem_ref) {
  return pipeline_expr_append_array_lit_elem(a, expr_ref, elem_ref);
}
int32_t ast_pipeline_expr_array_lit_elem_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  return pipeline_expr_array_lit_elem_ref(a, expr_ref, idx);
}
int32_t ast_pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_array_lit_num_elems_at(a, expr_ref);
}
int32_t ast_pipeline_expr_float_bits_lo_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_float_bits_lo_at(a, expr_ref);
}
int32_t ast_pipeline_expr_float_bits_hi_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_float_bits_hi_at(a, expr_ref);
}
int32_t ast_pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_call_callee_ref_at(a, expr_ref);
}
int32_t ast_pipeline_expr_as_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_enum_variant_tag_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_method_call_base_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_method_call_base_ref_at(a, expr_ref);
}
int32_t ast_pipeline_expr_method_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_method_call_num_args_at(a, expr_ref);
}
int32_t ast_pipeline_expr_method_call_name_len(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_method_call_name_len(a, expr_ref);
}
void ast_pipeline_expr_method_call_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64) {
  pipeline_expr_method_call_name_into(a, expr_ref, out64);
}
int32_t ast_pipeline_expr_if_cond_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_if_then_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_if_else_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_match_matched_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_const_folded_valid_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_const_folded_val_at(struct ast_ASTArena *a, int32_t expr_ref);
/* wave1160 G.7: 9 ast_pipeline_expr_* wrappers above (as/if/block/match/
 * const_folded/enum_variant) migrated to pipeline_asm_emit_expr_rec.c EOF
 * as fwd decls. wave1159: 4 method_call wrappers remain as function bodies
 * (their pipeline_expr_* twins are in method_call.c via #include L9703). */
/* wave1161 G.7: index/field_access_offset wrappers migrated to
 * pipeline_asm_emit_expr_rec.c EOF as fwd decls below. */
int32_t ast_pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_field_access_is_enum_variant(a, expr_ref);
}
int32_t ast_pipeline_expr_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_field_access_layout_offset(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref) {
  return pipeline_expr_field_access_layout_offset(a, m, expr_ref);
}

int32_t ast_pipeline_expr_field_access_load_byte_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref) {
  return pipeline_expr_field_access_load_byte_sz(a, m, expr_ref);
}
int32_t ast_pipeline_module_import_append_select_name(struct ast_Module *m, int32_t idx, uint8_t *bytes,
                                                      int32_t len) {
  return pipeline_module_import_append_select_name(m, idx, bytes, len);
}

/** backend import codegen uses codegen_ prefix for struct_lit glue. */
int32_t codegen_pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_kind_ord_at(a, expr_ref);
}
int32_t codegen_pipeline_expr_struct_lit_num_fields(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_struct_lit_num_fields(a, expr_ref);
}
int32_t codegen_pipeline_expr_struct_lit_init_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t j) {
  return pipeline_expr_struct_lit_init_ref(a, expr_ref, j);
}
int32_t backend_pipeline_expr_struct_lit_num_fields(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_struct_lit_num_fields(a, expr_ref);
}
int32_t backend_pipeline_expr_struct_lit_init_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t j) {
  return pipeline_expr_struct_lit_init_ref(a, expr_ref, j);
}

/* wave1187 G.7: codegen_/backend_ struct_lit field offset/store_sz forwarders
 * migrated from pipeline_glue.c L7239-L7255. Pure forwarders to
 * pipeline_expr_struct_lit_field_offset_at / _field_store_sz. */
int32_t codegen_pipeline_expr_struct_lit_field_offset_at(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref,
                                                         int32_t field_ix) {
  return pipeline_expr_struct_lit_field_offset_at(a, m, expr_ref, field_ix);
}
int32_t codegen_pipeline_expr_struct_lit_field_store_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref,
                                                        int32_t field_ix) {
  return pipeline_expr_struct_lit_field_store_sz(a, m, expr_ref, field_ix);
}
int32_t backend_pipeline_expr_struct_lit_field_offset_at(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref,
                                                         int32_t field_ix) {
  return pipeline_expr_struct_lit_field_offset_at(a, m, expr_ref, field_ix);
}
int32_t backend_pipeline_expr_struct_lit_field_store_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref,
                                                        int32_t field_ix) {
  return pipeline_expr_struct_lit_field_store_sz(a, m, expr_ref, field_ix);
}
