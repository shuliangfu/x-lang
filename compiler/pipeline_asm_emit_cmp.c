/**
 * pipeline_asm_emit_cmp.c — asm ELF relational CMP emit face (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding EQ/NE/LT/LE/GT/GE ELF
 * emit (EXPR_* cmp kinds 10..15):
 * - pipeline_asm_emit_cmp_elf (public entry; CTFE fold, call-vs-0 test,
 *   enum TypeKind/ExprKind RHS tag, VAR/lit fast paths, lit-left null/ptr,
 *   general push/pop via glue_try_binop_cmp_rbx_rax_elf_c)
 * - pipeline_asm_cmp_enum_rhs_tag_c (TypeKind/ExprKind field-access RHS tag)
 * - glue_type_kind_is_64bit_int / glue_emit_rex_w_if_64bit (cmpq vs cmpl)
 * - glue_emit_cmp_finish_rbx_rax_elf_c (f64 ucomisd / f32 ucomiss / int setcc)
 *
 * G.7: single product-mega CMP ELF face — do not open a second setcc finish
 * or second 64-bit width table. TypeKind name→tag table
 * (pipeline_asm_typekind_variant_tag) stays in glue (shared with field_access).
 * Operand load placement helper glue_try_binop_cmp_rbx_rax_elf_c lives in
 * pipeline_asm_emit_binop.c (wave1018 G.7 fold; same TU before this include).
 * (shared with binop operand stack discipline).
 *
 * Callers: pipeline_asm_emit_expr_elf_rec cmp arms (kind 10..15).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c at the former
 * cmp body site (after pipeline_asm_typekind_variant_tag; before block-if
 * ast_pipeline forward decls / block_inits).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/* Forward decls / callees defined elsewhere in the same TU:
 * - pipeline_asm_emit_expr_elf_rec (static; declared earlier)
 * - pipeline_asm_typekind_variant_tag (static; defined just above this include)
 * - glue_try_binop_cmp_rbx_rax_elf_c / glue_binop_operand_is_scalar_f32/f64_elf_c
 * - glue_var_expr_stack_off_elf_c / glue_binop_var_slot_cache_invalidate_rbx
 * - pipeline_asm_cmp_cc_for_expr_kind_ord / pipeline_asm_call_return_type_kind_ord_c
 * - pipeline_asm_expr_lit_i32_at_c / backend_enc_*_arch / pipeline_expr_*
 */

/** 右操作数为 TypeKind/ExprKind 枚举 FIELD_ACCESS 时返回 tag，否则 -1（不查 module 字段，避免 typeck_x_ast 中 module.x 误触）。 */
static int32_t pipeline_asm_cmp_enum_rhs_tag_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  struct ast_Expr *ex;
  uint8_t base_buf[32];
  uint8_t field_buf[128];
  int32_t blen;
  int32_t flen;
  int32_t tag;
  if (!arena || expr_ref <= 0 || pipeline_expr_kind_ord_at(arena, expr_ref) != 44)
    return -1;
  ex = glue_arena_expr_at_ref(arena, expr_ref);
  if (!ex || ex->field_access_base_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, ex->field_access_base_ref) != 3)
    return -1;
  blen = pipeline_expr_var_name_len(arena, ex->field_access_base_ref);
  if (blen != 8)
    return -1;
  pipeline_expr_var_name_into(arena, ex->field_access_base_ref, base_buf);
  flen = pipeline_expr_field_access_name_len(arena, expr_ref);
  if (flen <= 0 || flen > 127)
    return -1;
  pipeline_expr_field_access_name_into(arena, expr_ref, field_buf);
  if (memcmp(base_buf, "TypeKind", 8) == 0)
    return pipeline_asm_typekind_variant_tag(field_buf, flen);
  if (memcmp(base_buf, "ExprKind", 8) != 0)
    return -1;
  tag = pipeline_expr_enum_namespace_field_tag(arena, expr_ref);
  return tag;
}

/**
 * 判断 TypeKind 是否需 64-bit cmpq（整数/指针）。
 * TYPE_U64=4, TYPE_I64=5, TYPE_USIZE=6, TYPE_ISIZE=7, TYPE_PTR=9.
 * f64 is NOT here: signed cmpq of IEEE bits reverses order among negatives;
 * scalar f64 compares use ucomisd (glue_emit_cmp_finish_rbx_rax_elf_c).
 */
static int32_t glue_type_kind_is_64bit_int(int32_t kind) {
  return kind == 4 || kind == 5 || kind == 6 || kind == 7 || kind == 9;
}

/**
 * 【Why】x86_64 的 enc_cmp_rbx_rax 硬编码 32-bit cmpl（39 C3），i64/u64/usize/isize/ptr
 *        比较时高 32 位被截断，导致 mmap 返回地址等 64-bit 值的 <= 比较误判为负。
 *        修复：64-bit 比较前发射 REX.W 前缀（0x48），使 cmpl 升级为 cmpq。
 * 【Invariant】仅在 ta==0（x86_64）且 is_64bit 时发射 1 字节 0x48；其他架构 no-op。
 *              REX.W 必须紧贴 cmp 指令前，中间不得插入其他字节。
 * 【Asm/Perf】48 39 C3 = cmpq %rax, %rbx（64-bit 比较，置标志位供后续 setcc 用）。
 */
static int32_t glue_emit_rex_w_if_64bit(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t is_64bit, int32_t ta) {
  if (is_64bit && ta == 0) {
    uint8_t rex_w[1] = { 0x48 };
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, rex_w, 1);
  }
  return 0;
}

/**
 * Finish a cmp with left in rbx, right in rax.
 * PLATFORM: LINUX+MACOS x86_64 / MACOS|ARM64 —
 *   scalar f64 → ucomisd/fcmp d + CF/ZF (NZCV) setcc
 *   scalar f32 → ucomiss/fcmp s + same setcc (wave621; prior fell through to integer cmp)
 *   integers   → cmp/cmpq + SF setcc
 * G.7 single finish authority for all three; do not open a second cmp finish path.
 */
static int32_t glue_emit_cmp_finish_rbx_rax_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t left_ref,
                                                    int32_t right_ref, int32_t is_cmp_64bit, int32_t cc, int32_t ta) {
  if ((ta == 0 || ta == 1) && left_ref > 0 && right_ref > 0 &&
      glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref)) {
    if (backend_enc_ucomisd_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    return backend_enc_fp_cmp_setcc_movzbl_arch(elf_ctx, cc, ta);
  }
  /* wave621 Cap residual pure: freestanding f32 ==/ordered used integer cmp of 64-bit
   * stack loads (high-half garbage → equal false; signed order wrong for negatives).
   * Authority: backend_enc_ucomiss_rbx_rax_arch + fp setcc (G.7 expand finish, not a fork). */
  if ((ta == 0 || ta == 1) && left_ref > 0 && right_ref > 0 &&
      glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref)) {
    if (backend_enc_ucomiss_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    return backend_enc_fp_cmp_setcc_movzbl_arch(elf_ctx, cc, ta);
  }
  if (glue_emit_rex_w_if_64bit(elf_ctx, is_cmp_64bit, ta) != 0)
    return -1;
  if (backend_enc_cmp_rbx_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_cmp_setcc_movzbl_arch(elf_ctx, cc, ta);
}

int32_t pipeline_asm_emit_cmp_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                  int32_t cmp_expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t right_ref;
  int32_t left_ref;
  int32_t lit_imm;
  int32_t cc;
  int32_t enum_tag;
  int32_t cmp_ko;
  int32_t is_cmp_64bit;
  int32_t lt_ref;
  int32_t lt_kind;
  struct ast_Expr *e;
  if (!arena || cmp_expr_ref <= 0)
    return -1;
  e = glue_arena_expr_at_ref(arena, cmp_expr_ref);
  if (e && e->const_folded_valid != 0)
    return backend_enc_mov_imm32_to_w0_arch(elf_ctx, e->const_folded_val, ta);
  cmp_ko = pipeline_expr_kind_ord_at(arena, cmp_expr_ref);
  left_ref = pipeline_expr_binop_left_ref_at(arena, cmp_expr_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, cmp_expr_ref);
  /* 获取左操作数类型判断是否 64-bit 比较（i64/u64/usize/isize/ptr），
   * 64-bit 时 x86_64 需 REX.W 前缀将 cmpl 升级为 cmpq，避免高 32 位截断。 */
  is_cmp_64bit = 0;
  if (left_ref > 0) {
    struct ast_Expr *le = pipeline_arena_expr_ptr(arena, left_ref);
    if (le) {
      lt_ref = le->resolved_type_ref;
      if (lt_ref > 0) {
        lt_kind = pipeline_type_kind_ord_at(arena, lt_ref);
        is_cmp_64bit = glue_type_kind_is_64bit_int(lt_kind);
      }
    }
    /** CALL 返回 i64/ptr 时 resolved 可能仍空：用 callee 返回 kind 触发 cmpq（非 f64）。 */
    if (is_cmp_64bit == 0 && pipeline_expr_kind_ord_at(arena, left_ref) == 48) {
      int32_t rk = pipeline_asm_call_return_type_kind_ord_c(arena, left_ref);
      if (rk == 5 || rk == 4 || rk == 6 || rk == 7 || rk == 9)
        is_cmp_64bit = 1;
    }
  }
  /**
   * wave669 Cap residual: lit-left `0==p` / `null==p` — left LIT may still be i32-shaped
   * before peer coerce stamp is visible here; take 64-bit cmp from right when right is
   * ptr/i64/… so REX.W is not lost on the lit-left fast path.
   * G.7: same glue_type_kind_is_64bit_int authority; no second width table.
   */
  if (is_cmp_64bit == 0 && right_ref > 0) {
    struct ast_Expr *re = pipeline_arena_expr_ptr(arena, right_ref);
    if (re) {
      int32_t rt_ref = re->resolved_type_ref;
      if (rt_ref > 0) {
        int32_t rt_kind = pipeline_type_kind_ord_at(arena, rt_ref);
        is_cmp_64bit = glue_type_kind_is_64bit_int(rt_kind);
      }
    }
    if (is_cmp_64bit == 0 && pipeline_expr_kind_ord_at(arena, right_ref) == 48) {
      int32_t rk = pipeline_asm_call_return_type_kind_ord_c(arena, right_ref);
      if (rk == 5 || rk == 4 || rk == 6 || rk == 7 || rk == 9)
        is_cmp_64bit = 1;
    }
  }
  /**
   * CALL 与字面量 0 比较（while/if 内 pipeline_loop_* / sync_one 等）：
   * 勿 mov rax→rbx + imm 0 cmp（CALL 后 tear/patch 易失败）；test eax + setcc 归一化 bool。
   */
  if (left_ref > 0 && right_ref > 0 && pipeline_expr_kind_ord_at(arena, left_ref) == 48) {
    int32_t lit_ok = pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm);
    if (link_abi_getenv("XLANG_ASM_DEBUG") && cmp_ko == 15)
      fprintf(stderr, "xlang: cmp_call0 left=%d lit_ok=%d lit=%d cmp_ko=%d\n", (int)left_ref, (int)lit_ok, (int)lit_imm,
              (int)cmp_ko);
  }
  if (left_ref > 0 && right_ref > 0 && pipeline_expr_kind_ord_at(arena, left_ref) == 48 &&
      pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm) && lit_imm == 0 &&
      (cmp_ko == 14 || cmp_ko == 15)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    cc = pipeline_asm_cmp_cc_for_expr_kind_ord(cmp_ko);
    if (cc < 0)
      return -1;
    if (glue_emit_rex_w_if_64bit(elf_ctx, is_cmp_64bit, ta) != 0)
      return -1;
    if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_cmp_setcc_movzbl_arch(elf_ctx, cc, ta) != 0)
      return -1;
    return 0;
  }
  /** TypeKind.TYPE_I32 等枚举右操作数：左+立即数 cmp，避免 push/rec 右子树。 */
  if (right_ref > 0 && (enum_tag = pipeline_asm_cmp_enum_rhs_tag_c(arena, right_ref)) >= 0) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, cmp_expr_ref), ctx,
                                       ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, enum_tag, ta) != 0)
      return -1;
    cc = pipeline_asm_cmp_cc_for_expr_kind_ord(pipeline_expr_kind_ord_at(arena, cmp_expr_ref));
    if (cc < 0)
      return -1;
    return glue_emit_cmp_finish_rbx_rax_elf_c(arena, ctx, elf_ctx, left_ref, right_ref, is_cmp_64bit, cc, ta);
  }
  /** while 头 VAR vs 字面量：rbp 直 load+cmp，勿 rec emit left 再 mov rax→rbx（tear 易失败）。
   * Skip when left is scalar f32/f64 (float must finish via ucomiss/ucomisd; int imm path is wrong). */
  if (left_ref > 0 && right_ref > 0 && pipeline_expr_kind_ord_at(arena, left_ref) == GLUE_EXPR_KIND_VAR &&
      !glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      !glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    int32_t var_off = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
    if (var_off >= 0) {
      cc = pipeline_asm_cmp_cc_for_expr_kind_ord(cmp_ko);
      if (cc < 0)
        return -1;
      if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, var_off, ta) != 0)
        return -1;
      if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, lit_imm, ta) != 0)
        return -1;
      return glue_emit_cmp_finish_rbx_rax_elf_c(arena, ctx, elf_ctx, left_ref, right_ref, is_cmp_64bit, cc, ta);
    }
  }
  if (right_ref != 0 && !glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      !glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, pipeline_expr_binop_left_ref_at(arena, cmp_expr_ref), ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    cc = pipeline_asm_cmp_cc_for_expr_kind_ord(pipeline_expr_kind_ord_at(arena, cmp_expr_ref));
    if (cc < 0)
      return -1;
    return glue_emit_cmp_finish_rbx_rax_elf_c(arena, ctx, elf_ctx, left_ref, right_ref, is_cmp_64bit, cc, ta);
  }
  /**
   * wave669 Cap residual pure: freestanding lit-left ptr/int cmp (`null==p`, `0==p`).
   * Mirror the right-lit fast path: left imm → rbx, right value → rax (enc_cmp order).
   * Skip when right is also lit (handled above) or either side is scalar float.
   * G.7: single emit_cmp authority expanded; seed path is this C file (standalone glue).
   * PLATFORM: SHARED freestanding; LINUX x86_64 false-green exposed; host-C hid.
   */
  if (left_ref > 0 && right_ref > 0 &&
      !glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref) &&
      !glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref) &&
      !glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      !glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm)) {
    int32_t var_off = -1;
    if (pipeline_expr_kind_ord_at(arena, right_ref) == GLUE_EXPR_KIND_VAR)
      var_off = glue_var_expr_stack_off_elf_c(arena, ctx, right_ref);
    cc = pipeline_asm_cmp_cc_for_expr_kind_ord(cmp_ko);
    if (cc < 0)
      return -1;
    if (var_off >= 0) {
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, var_off, ta) != 0)
        return -1;
    } else {
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
        return -1;
    }
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    return glue_emit_cmp_finish_rbx_rax_elf_c(arena, ctx, elf_ctx, left_ref, right_ref, is_cmp_64bit, cc, ta);
  }
  {
    int32_t left_ref2;
    int32_t vr;
    left_ref2 = pipeline_expr_binop_left_ref_at(arena, cmp_expr_ref);
    vr = glue_try_binop_cmp_rbx_rax_elf_c(arena, elf_ctx, left_ref2, right_ref, ctx, ta);
    if (vr == -1)
      return -1;
    if (vr == -2) {
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref2, ctx, ta) != 0)
        return -1;
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
        return -1;
    }
  }
  cc = pipeline_asm_cmp_cc_for_expr_kind_ord(pipeline_expr_kind_ord_at(arena, cmp_expr_ref));
  if (cc < 0)
    return -1;
  return glue_emit_cmp_finish_rbx_rax_elf_c(arena, ctx, elf_ctx, left_ref, right_ref, is_cmp_64bit, cc, ta);
}
