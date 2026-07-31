/**
 * pipeline_asm_emit_unary.c — asm ELF unary expr emit domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding unary ELF emit:
 * - EXPR_NEG (int / f32 / f64 / i64 width / post-mask / i32 sxt)
 * - EXPR_LOGNOT (test + setz 0/1)
 * - EXPR_BITNOT (32/64-bit not + i32 sxt)
 * - glue_enc_sxt_i32_result_to_rax_elf_c (wave646 i32 GP canonicalize)
 * - glue_enc_jz_after_bool_in_eax (bool-in-eax → jz; used by if/while/async)
 *
 * G.7: single product-mega unary ELF emit path — do not open a second NEG /
 * BITNOT / LOGNOT emitter in seed partial or a parallel glue copy. rec / thin
 * wrappers (pipeline_asm_emit_*_elf_c) stay in pipeline_glue.c and call these
 * static impls (same TU).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after float
 * classifier forward decls and before await/as/try/logand emit helpers.
 * Callers of glue_enc_jz (if/while/async) remain later in the same TU.
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/**
 * EXPR_NEG: emit unary operand, then negate.
 *
 * PLATFORM: LINUX+MACOS x86_64 — scalar f32/f64 flip the IEEE sign bit (btc).
 * Integer path: 32-bit enc_neg_eax by default; 64-bit integer types / large INT
 * lits use REX.W `neg %rax` (x86) / `neg x0,x0` (arm64). A 32-bit `neg %eax`
 * zero-extends RAX and destroys high bits — freestanding
 * `let a: i64 = -9223372036854775807` loaded max via mov_imm64 then `neg %eax`
 * → 1 (wave306 SE residual). f32 is checked before f64 so FLOAT_LIT with
 * resolved f32 does not take the f64 default.
 * PLATFORM: SHARED type classification; x86_64 (ta==0) btc / REX.W neg; arm64
 * (ta==1) 64-bit neg via bit31 of the ALU opcode.
 */
/* wave646: i32 GP canonicalize after 32-bit unary (defined with BITNOT). */
static int32_t glue_enc_sxt_i32_result_to_rax_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
static int32_t pipeline_asm_emit_neg_elf_impl(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t op;
  int32_t use_i64_neg = 0;
  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op == 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
    return -1;
  /* f32 first: btc eax, 31 — flip IEEE f32 sign in low 32 bits. */
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, op)) {
    /* x86: btc eax,31. arm64 wave616: eor sign bit in w0. */
    if (ta == 1) {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x52b00001u) != 0) /* movz w1,#0x8000,lsl#16 */
        return -1;
      return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x4a010000u); /* eor w0,w0,w1 */
    }
    static const uint8_t btc_eax_31[4] = {0x0f, 0xba, 0xf8, 0x1f};
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)btc_eax_31, 4);
  }
  /* f64 / float lit default: btc rax, 63 — flip IEEE f64 sign without touching magnitude. */
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, op)) {
    if (ta == 1) {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0xd2f00001u) != 0) /* movz x1,#0x8000,lsl#48 */
        return -1;
      return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0xca010000u); /* eor x0,x0,x1 */
    }
    static const uint8_t btc_rax_63[5] = {0x48, 0x0f, 0xba, 0xf8, 0x3f};
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)btc_rax_63, 5);
  }
  /*
   * wave306 Cap residual pure: 64-bit integer unary minus.
   * Prefer resolved type on NEG / operand / var decl; also large INT lit
   * (outside i32) already in RAX via mov_imm64 — must negate full width.
   */
  {
    int32_t tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
    int32_t kind_ord = -1;
    if (tr <= 0)
      tr = pipeline_expr_resolved_type_ref(arena, op);
    if (tr <= 0 && ctx)
      tr = glue_var_decl_type_ref_elf_c(arena, ctx, op);
    if (tr > 0)
      kind_ord = pipeline_type_kind_ord_at(arena, tr);
    /* TYPE_U64=4, TYPE_I64=5, TYPE_USIZE=6, TYPE_ISIZE=7, TYPE_PTR=9 */
    if (kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7 || kind_ord == 9)
      use_i64_neg = 1;
    if (!use_i64_neg && pipeline_expr_kind_ord_at(arena, op) == 0) {
      int64_t v64 = pipeline_expr_int64_val_at(arena, op);
      if (v64 < (int64_t)INT32_MIN || v64 > (int64_t)INT32_MAX)
        use_i64_neg = 1;
    }
  }
  if (use_i64_neg) {
    if (ta == 0) {
      /* REX.W neg %rax — 48 F7 D8 */
      static const uint8_t neg_rax[3] = {0x48, 0xf7, 0xd8};
      return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)neg_rax, 3);
    }
    if (ta == 1) {
      /* neg x0, x0 — sf=1 form of sub x0, xzr, x0 (0xcb0003e0) */
      static const uint8_t neg_x0[4] = {0xe0, 0x03, 0x00, 0xcb};
      return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)neg_x0, 4);
    }
  }
  if (backend_enc_neg_eax_arch(elf_ctx, ta) != 0)
    return -1;
  /*
   * wave310: after 32-bit neg, rax/eax is 0xffffffff for -1. Freestanding
   * compares u8/u16 against 0xff/0xffff — mask to declared width (cfold path
   * already masks; live NEG from assign `a=-1` does not).
   * wave646: i32 needs sxtw/cdqe — 32-bit neg zero-extends high half while
   * freestanding cmp is 64-bit and negative i32 lits are full-width sign-ext
   * → `-x == -5` false (host-C / pure CTFE green). u32 keeps zero-ext.
   * PLATFORM: SHARED emit / x86_64 and-imm+cdqe; arm64 and-imm32+sxtw.
   */
  {
    int32_t tr_n = pipeline_expr_resolved_type_ref(arena, expr_ref);
    int32_t k_n = (tr_n > 0) ? pipeline_type_kind_ord_at(arena, tr_n) : -1;
    if (k_n == (int32_t)ast_TypeKind_TYPE_I32) {
      return glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta);
    } else if (k_n == (int32_t)ast_TypeKind_TYPE_U8) {
      if (ta == 0) {
        /* and $0xff,%eax — must be imm32 (25 ff 00 00 00). Opcode 83 e0 ff
         * sign-extends imm8 0xff → and $0xffffffff (no-op). */
        static const uint8_t and_eax_ff[5] = {0x25, 0xff, 0x00, 0x00, 0x00};
        return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)and_eax_ff, 5);
      }
    } else if (k_n == (int32_t)ast_TypeKind_TYPE_NAMED) {
      uint8_t nm[128];
      int32_t nlen = pipeline_type_named_name_into(arena, tr_n, nm);
      if (nlen == 3 && nm[0] == (uint8_t)'u' && nm[1] == (uint8_t)'1' && nm[2] == (uint8_t)'6') {
        if (ta == 0) {
          static const uint8_t and_eax_ffff[5] = {0x25, 0xff, 0xff, 0x00, 0x00}; /* and $0xffff,%eax */
          return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)and_eax_ffff, 5);
        }
      }
    }
  }
  return 0;
}

/**
 * bool 表达式结果已在 eax/x0 后，为零则跳转到 label。
 * x86_64 的 je/jz 只读 EFLAGS；mov 到 eax 不会置 ZF，须先发 test %eax,%eax。
 * arm64 cbz / riscv beqz 直接读寄存器，无需 test。
 */
static int32_t glue_enc_jz_after_bool_in_eax(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label,
                                             int32_t label_len, int32_t ta) {
  if (ta == 0) {
    if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
      return -1;
  }
  return backend_enc_jz_arch(elf_ctx, label, label_len, ta);
}

/** EXPR_LOGNOT：emit 操作数后 test eax; setz 归一化为 0/1。 */
static int32_t pipeline_asm_emit_lognot_elf_impl(struct ast_ASTArena *arena,
                                                 struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                 struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t op;
  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op == 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
    return -1;
  if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_setz_movzbl_eax_arch(elf_ctx, ta);
}

/**
 * Sign-extend i32 result in eax/w0 to full GP (rax/x0).
 *
 * wave646 Cap residual: freestanding binop cmp uses 64-bit registers and
 * negative i32 literals are materialised as full-width sign-ext values, but
 * 32-bit `neg`/`not` leave the high half zero → `~x == -1` / `-x == -5` false
 * (host-C green; pure-asm often CTFE-folds). u32 must NOT call this (keeps
 * zero-ext so `~0u == 4294967295` still matches 32-bit lit materialisation).
 *
 * PLATFORM: SHARED contract; x86_64 cdqe; arm64 sxtw x0,w0; other ta no-op.
 */
static int32_t glue_enc_sxt_i32_result_to_rax_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (!elf_ctx)
    return -1;
  if (ta == 0) {
    /* cdqe — 48 98 */
    static const uint8_t cdqe[2] = {0x48, 0x98};
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)cdqe, 2);
  }
  if (ta == 1) {
    /* sxtw x0, w0 — 0x93407c00 little-endian */
    static const uint8_t sxtw[4] = {0x00, 0x7c, 0x40, 0x93};
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)sxtw, 4);
  }
  return 0;
}

/**
 * EXPR_BITNOT: emit unary operand into eax/w0, then bitwise complement.
 *
 * wave290 Cap residual root fix:
 *   pipeline_asm_emit_expr_elf_rec dispatched NEG (ko==22) and LOGNOT (ko==24)
 *   but dropped BITNOT (ko==23) into backend_emit_expr_elf_slow, which did not
 *   write eax for `~x`. Ubuntu freestanding -o then returned garbage (e.g. 232
 *   for `return (~3)`); -E C path already emitted `~(3)`. CTFE fold of pure
 *   lit BITNOT still works via const_folded_valid (mac path); this impl covers
 *   non-folded / runtime operands and closes the ELF dispatch hole.
 *
 * wave646 Cap residual:
 *   (1) i64/u64/usize/isize/ptr: full-width not (mirror wave306 NEG) — prior
 *       always 32-bit notl/mvn → `~i64(0) == -1` freestanding false.
 *   (2) i32: after 32-bit not, sxtw/cdqe so cmp vs full-width -1 matches.
 *   u32 stays 32-bit zero-ext (G.7: do not sxt unsigned).
 *
 * Authority: single ELF emit path here; encoders backend_enc_not_eax_arch +
 * inline REX.W/sf=1 not for 64-bit + glue_enc_sxt_i32_result_to_rax_elf_c.
 * PLATFORM: SHARED dispatch; arch encoding via ta.
 */
static int32_t pipeline_asm_emit_bitnot_elf_impl(struct ast_ASTArena *arena,
                                                 struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                 struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t op;
  int32_t use_i64_not = 0;
  int32_t tr;
  int32_t kind_ord = -1;
  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op == 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
    return -1;
  /* Type width: prefer BITNOT result, else operand, else var decl (≡ NEG). */
  tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (tr <= 0)
    tr = pipeline_expr_resolved_type_ref(arena, op);
  if (tr <= 0 && ctx)
    tr = glue_var_decl_type_ref_elf_c(arena, ctx, op);
  if (tr > 0)
    kind_ord = pipeline_type_kind_ord_at(arena, tr);
  /* TYPE_U64=4, TYPE_I64=5, TYPE_USIZE=6, TYPE_ISIZE=7, TYPE_PTR=9 */
  if (kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7 || kind_ord == 9)
    use_i64_not = 1;
  if (use_i64_not) {
    if (ta == 0) {
      /* REX.W not %rax — 48 F7 D0 */
      static const uint8_t not_rax[3] = {0x48, 0xf7, 0xd0};
      return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)not_rax, 3);
    }
    if (ta == 1) {
      /* mvn x0, x0 — sf=1 orn x0, xzr, x0 (0xaa2003e0) */
      static const uint8_t mvn_x0[4] = {0xe0, 0x03, 0x20, 0xaa};
      return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)mvn_x0, 4);
    }
  }
  if (backend_enc_not_eax_arch(elf_ctx, ta) != 0)
    return -1;
  /* i32: canonicalize to full GP for 64-bit freestanding cmp (wave646). */
  if (kind_ord == (int32_t)ast_TypeKind_TYPE_I32)
    return glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta);
  return 0;
}
