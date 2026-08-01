/**
 * pipeline_asm_emit_as.c — asm ELF EXPR_AS / await / try / float-lit domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding cast and related emit:
 * - GLUE_EXPR_KIND_ORD54 / X_AWAIT / TRY_PROPAGATE / STRING_LIT kind macros
 * - glue_expr_is_await_at_c / glue_expr_is_x_as_cast_at_c (ord-54 collision)
 * - pipeline_asm_emit_await_sync_elf_impl (WPO-S3 sync await stub)
 * - pipeline_asm_emit_try_propagate_elf_impl (ERR-01 Result `?`)
 * - glue_array_lit_emit_scalar_elem_to_rax_elf_c + glue_emit_float_lit_to_rax_elf_c
 * - pipeline_asm_emit_as_elf_impl (int/float cast family; routes await via stub)
 *
 * G.7: single product-mega EXPR_AS ELF emit path — do not open a second cast
 * emitter in seed partial or a parallel glue copy. Thin public wrapper
 * pipeline_asm_emit_as_elf_c lives at end of this leaf (wave1014 fold) and
 * calls the static impl (same TU).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after the
 * unary emit slice and before async CPS; logand·logor live in
 * pipeline_asm_emit_logand.c (same TU, later include).
 * Callers of glue_emit_float_lit (array_lit pack / let) remain later in the
 * same TU.
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/** C ASTExprKind 与 X ast_ExprKind 在序 54 碰撞：C AWAIT=54，X EXPR_AS=54；X EXPR_AWAIT=55。 */
#define GLUE_EXPR_KIND_ORD54 54
#define GLUE_EXPR_KIND_X_AWAIT 55
/** X pool：ERR-01 Result `?` 传播（C ast.h AST_EXPR_TRY_PROPAGATE=57，X EXPR_SPAWN=57 后插入=58）。 */
#define GLUE_EXPR_KIND_TRY_PROPAGATE 58
#define GLUE_EXPR_KIND_C_TRY_PROPAGATE 57
/** X/parser_asm/backend 权威：STRING_LIT 序数 59（与 GLUE_EXPR_STRING_LIT_ORD / PARSER_ASM_EXPR_STRING_LIT 一致）。 */
#define GLUE_EXPR_STRING_LIT_ORD 59

/* wave1034 G.7: forward decl — glue_arena_expr_at_ref is defined later in the
 * TU (glue.c:2796, after field_access.c #include at glue.c:2496). as.c is
 * #included at glue.c:2062, before the definition; without this static
 * forward decl the call below would get an implicit non-static declaration
 * and conflict with the later static definition. */
static struct ast_Expr *glue_arena_expr_at_ref(struct ast_ASTArena *a, int32_t expr_ref);

/**
 * Low 32 bits of a float64 literal's IEEE-754 bit representation.
 *
 * Why: at emit time the bits are recomputed from float_val to avoid
 * relying on X parser having persisted float_bits_* (which may be
 * stale or zero). Non-float expressions fall back to the stored
 * float_bits_lo field.
 *
 * Contract: returns 0 for invalid expr_ref or NULL expr; otherwise
 * returns the low 32 bits of typeck_float64_bits(double).
 *
 * PLATFORM: SHARED — typeck_float64_bits_lo is an external asm symbol
 * (typeck_f64_bits_x86_64_mingw.s / typeck_f64_bits_arm64.s).
 */
int32_t pipeline_expr_float_bits_lo_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return 0;
  if (ex->kind == ast_ExprKind_EXPR_FLOAT_LIT)
    return typeck_float64_bits_lo(ex->float_val);
  return ex->float_bits_lo;
}

/**
 * High 32 bits of a float64 literal's IEEE-754 bit representation.
 *
 * Why: same rationale as pipeline_expr_float_bits_lo_at — recompute
 * from float_val at emit time rather than trusting persisted bits.
 *
 * Contract: returns 0 for invalid expr_ref or NULL expr; otherwise
 * returns the high 32 bits of typeck_float64_bits(double).
 *
 * PLATFORM: SHARED — typeck_float64_bits_hi is an external asm symbol.
 */
int32_t pipeline_expr_float_bits_hi_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return 0;
  if (ex->kind == ast_ExprKind_EXPR_FLOAT_LIT)
    return typeck_float64_bits_hi(ex->float_val);
  return ex->float_bits_hi;
}

/**
 * pool/C parser 上的 await 表达式。
 * X pool：kind==EXPR_AWAIT(55) 且 unary 操作数有效。
 * C partial：kind==54 且非 as cast（unary 有效、as_* 字段为空）。
 */
static int32_t glue_expr_is_await_at_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  int32_t ko, uop;
  if (!arena || expr_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == GLUE_EXPR_KIND_X_AWAIT) {
    uop = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    return uop > 0 ? 1 : 0;
  }
  if (ko != GLUE_EXPR_KIND_ORD54)
    return 0;
  if (pipeline_expr_as_target_type_ref_at(arena, expr_ref) > 0 ||
      pipeline_expr_as_operand_ref_at(arena, expr_ref) > 0)
    return 0;
  uop = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  return uop > 0 ? 1 : 0;
}

/** kind 序 54 且为 X pool EXPR_AS（as_operand 有效；非 C await）。 */
static int32_t glue_expr_is_x_as_cast_at_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  int32_t ko;
  if (!arena || expr_ref <= 0)
    return 0;
  if (glue_expr_is_await_at_c(arena, expr_ref))
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko != (int32_t)ast_ExprKind_EXPR_AS && ko != GLUE_EXPR_KIND_ORD54)
    return 0;
  return pipeline_expr_as_operand_ref_at(arena, expr_ref) > 0 ? 1 : 0;
}

/** WPO-S3 / A3：await sync stub — 无 CPS suspend，等价 eval 操作数（struct 跨 await 烟测 exit 10）。 */
static int32_t pipeline_asm_emit_await_sync_elf_impl(struct ast_ASTArena *arena,
                                                     struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                     struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t op;
  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op <= 0)
    return -1;
  return pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta);
}

/**
 * ERR-01：Result `?` — 求值 operand（Result 双寄存器返回），err!=0 则清理并 jmp tail_join 早退，否则 Ok 载荷留在 eax/w0。
 */
static int32_t pipeline_asm_emit_try_propagate_elf_impl(struct ast_ASTArena *arena,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                        struct backend_AsmFuncCtx *ctx, int32_t ta) {
  pipeline_glue_AsmFuncCtxLayout *ly;
  int32_t op;
  uint8_t ok_lbl[128];
  int32_t ok_len;

  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op <= 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
    return -1;
  ok_len = pipeline_asm_emit_next_label_c(ctx, ok_lbl, (int32_t)sizeof(ok_lbl));
  if (ok_len <= 0)
    return -1;
  /** 第二槽 err：x86 edx；arm64/riscv 经 test_rbx（w1/a1）。 */
  if (ta == 0) {
    extern int32_t arch_x86_64_enc_enc_test_edx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx);
    if (arch_x86_64_enc_enc_test_edx_edx(elf_ctx) != 0)
      return -1;
  } else if (backend_enc_test_rbx_rbx_arch(elf_ctx, ta) != 0) {
    return -1;
  }
  if (backend_enc_jz_arch(elf_ctx, ok_lbl, ok_len, ta) != 0)
    return -1;
  if (glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta) != 0)
    return -1;
  if (glue_async_cps_emit_phase_reset(elf_ctx, ta) != 0)
    return -1;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly || ly->tail_join_label_len <= 0)
    return -1;
  if (backend_enc_jmp_arch(elf_ctx, ly->tail_join_label, ly->tail_join_label_len, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, ok_lbl, ok_len, 0, ta) != 0)
    return -1;
  return 0;
}

/** EXPR_FLOAT_LIT → rax/x0：resolved f32 发 32-bit IEEE754 位型（勿 f64 movabs 低 32 位截断为 0）。 */
/** call_abi_widen_f64：CALL 实参经整型寄存器 8B 槽传递时须发 f64 位型（callee cvtsd2ss）；let/field 用 imm32。 */
static int32_t glue_emit_float_lit_to_rax_elf_c(struct ast_ASTArena *arena,
                                                 struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                 int32_t ta, int32_t force_ty_ref, int32_t call_abi_widen_f64);

/**
 * wave647 Cap residual pure: emit one ARRAY_LIT scalar element to rax for esz-wide pack.
 *
 * Root: bare FLOAT_LIT defaults to f64 IEEE bits in rax; packing force_esz=4 (formal
 * []f32 / TYPE_F32) stores only the low 32 of f64 1.0 (=0x00000000) → freestanding
 * `take([1.0, 2.0])` as []f32 reads 0 while host-C braced compound is green; let
 * `let a: []f32 = [1.0, 2.0]; take(a)` often green via stamped elems / CTFE.
 * Ubuntu x86 gold exposes; mac arm64 CTFE may fold `return 42` and hide.
 *
 * G.7: single authority — pass force_ty from ARRAY_LIT peel (TYPE_SLICE/ARRAY elem)
 * into glue_emit_float_lit (wave300); when peel missing but force_esz==4, pack f32
 * bits (same IEEE convert as force_ty F32). force_esz==8 keeps f64 default.
 * PLATFORM: SHARED freestanding · LINUX gold + MACOS|ARM64 co-path.
 *
 * @param arena AST arena
 * @param elf_ctx product ELF/Mach-O codegen ctx
 * @param array_lit_ref parent EXPR_ARRAY_LIT (for elem type peel)
 * @param elem_ref element expression
 * @param ctx asm func ctx (required for non-lit elems)
 * @param ta 0=x86_64, 1=arm64
 * @param force_esz formal/let element byte size (0 → infer only via peel)
 * @return 0 success, -1 emit error
 */
static int32_t glue_array_lit_emit_scalar_elem_to_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t array_lit_ref, int32_t elem_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t force_esz) {
  int32_t eko;
  int32_t ety;
  int32_t ek;
  if (!arena || !elf_ctx || elem_ref <= 0)
    return -1;
  eko = pipeline_expr_kind_ord_at(arena, elem_ref);
  /* EXPR_FLOAT_LIT = 1 */
  if (eko == 1) {
    ety = pipeline_asm_array_lit_elem_type_ref(arena, array_lit_ref);
    ek = ety > 0 ? pipeline_type_kind_ord_at(arena, ety) : -1;
    if (ek == 14 || ek == 15)
      return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, elem_ref, ta, ety, 0);
    /*
     * Formal force_esz=4 without peel (call-arg stamp race / unstamped lit):
     * still pack f32 bits — never store f64 low-half zeros into f32 slots.
     */
    if (force_esz == 4) {
      int32_t lo = pipeline_expr_float_bits_lo_at(arena, elem_ref);
      int32_t hi = pipeline_expr_float_bits_hi_at(arena, elem_ref);
      double dv;
      float fv;
      uint32_t fb;
      memcpy(&dv, (int32_t[]){lo, hi}, sizeof(dv));
      fv = (float)dv;
      memcpy(&fb, &fv, sizeof(fb));
      return backend_enc_mov_imm32_to_w0_arch(elf_ctx, (int32_t)fb, ta);
    }
    /* force_esz==8 or 0: default f64 bits via glue_emit_float_lit. */
    return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, elem_ref, ta, 0, 0);
  }
  if (!ctx)
    return -1;
  return pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, elem_ref, ctx, ta);
}

static int32_t glue_emit_float_lit_to_rax_elf_c(struct ast_ASTArena *arena,
                                                 struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                 int32_t ta, int32_t force_ty_ref, int32_t call_abi_widen_f64) {
  int32_t lo;
  int32_t hi;
  int32_t tr;
  double dv;
  float fv;
  uint32_t fb;
  uint64_t u64;
  lo = pipeline_expr_float_bits_lo_at(arena, expr_ref);
  hi = pipeline_expr_float_bits_hi_at(arena, expr_ref);
  tr = force_ty_ref > 0 ? force_ty_ref : pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == 14) {
    memcpy(&dv, (int32_t[]){lo, hi}, sizeof(dv));
    fv = (float)dv;
    if (call_abi_widen_f64 != 0) {
      dv = (double)fv;
      memcpy(&u64, &dv, sizeof(u64));
      lo = (int32_t)(u64 & 0xffffffffu);
      hi = (int32_t)(u64 >> 32);
      return backend_enc_mov_imm64_to_rax_arch(elf_ctx, lo, hi, ta);
    }
    memcpy(&fb, &fv, sizeof(fb));
    return backend_enc_mov_imm32_to_w0_arch(elf_ctx, (int32_t)fb, ta);
  }
  return backend_enc_mov_imm64_to_rax_arch(elf_ctx, lo, hi, ta);
}

/**
 * EXPR_AS ELF emit (integer cast reuses operand path; float lit special-cased).
 *
 * f32 target + FLOAT_LIT: must emit 32-bit IEEE bits (not f64 movabs low-32).
 * wave300 Cap residual pure: pass force_ty_ref=tgt (TYPE_F32). Prior force_ty=0
 * used the lit's own resolved type (usually f64 for bare `7.0`), so mov_imm64
 * left full f64 bits in rax; freestanding mulss then consumed only the low 32
 * → `b * 7.0 as f32` run=0 while `let c:f32=7.0` (force_ty on let) stayed green.
 * G.7: complete glue_emit_float_lit authority next to let/assign force_ty sites
 * (no new encoder). PLATFORM: SHARED cast semantics / LINUX+MACOS x86_64 emit.
 */
static int32_t pipeline_asm_emit_as_elf_impl(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                             int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t op;
  int32_t tgt;
  if (glue_expr_is_await_at_c(arena, expr_ref))
    return pipeline_asm_emit_await_sync_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  op = pipeline_expr_as_operand_ref_at(arena, expr_ref);
  if (op == 0)
    return -1;
  tgt = pipeline_expr_as_target_type_ref_at(arena, expr_ref);
  if (tgt > 0 && pipeline_type_kind_ord_at(arena, tgt) == 14 &&
      pipeline_expr_kind_ord_at(arena, op) == 1)
    return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, op, ta, tgt, 0);
  /**
   * f32 / f64 → integer truncate (wave291 i32; wave303 u32 + 64-bit REX.W).
   * PLATFORM: SHARED cast semantics / LINUX+MACOS x86_64 emit.
   * Root (wave291): f64→i32 re-emitted IEEE bits; eax low 32 is 0 for many finite doubles.
   * Root (wave303): f32→u32/i64/u64 (and f64 same) only had i32 eax path; other targets
   * re-emitted bits → freestanding run=0 (mac host-gcc hid). G.7: complete EXPR_AS
   * float→int authority next to existing cvttss2si/cvttsd2si eax forms.
   * Kinds: 0=i32, 3=u32 (eax form); 4=u64, 5=i64, 6=usize, 7=isize (REX.W rax form).
   * Note: ISA is signed convert; values outside signed destination range leave-off.
   */
  if (tgt > 0) {
    int32_t tgt_kind = pipeline_type_kind_ord_at(arena, tgt);
    int32_t src_tr = pipeline_expr_resolved_type_ref(arena, op);
    int32_t src_kind = src_tr > 0 ? pipeline_type_kind_ord_at(arena, src_tr) : -1;
    int32_t op_ko = pipeline_expr_kind_ord_at(arena, op);
    int32_t src_is_f32 = (src_kind == 14);
    int32_t src_is_f64 = (src_kind == 15 || (src_kind <= 0 && op_ko == 1) ||
                         glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, op));
    if (src_is_f32 || src_is_f64) {
      /* 32-bit integer targets: cvtt*2si → eax. */
      if (tgt_kind == 0 || tgt_kind == 3) {
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
          return -1;
        if (src_is_f32)
          return backend_enc_cvttss2si_eax_from_f32_bits_arch(elf_ctx, ta);
        return backend_enc_cvttsd2si_eax_from_f64_bits_arch(elf_ctx, ta);
      }
      /* 64-bit integer targets: REX.W cvtt*2si → rax (wave303). */
      if (tgt_kind == 4 || tgt_kind == 5 || tgt_kind == 6 || tgt_kind == 7) {
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
          return -1;
        if (src_is_f32)
          return backend_enc_cvttss2si_rax_from_f32_bits_arch(elf_ctx, ta);
        return backend_enc_cvttsd2si_rax_from_f64_bits_arch(elf_ctx, ta);
      }
    }
  }
  /**
   * 32-bit-class integer → f32：cvtsi2ss (wave302 Cap residual pure).
   * PLATFORM: SHARED cast semantics / LINUX+MACOS x86_64 emit.
   * Root: TYPE_F32 path only matched kind 0/3/13; TypeKind 13 is VECTOR not named int,
   * TYPE_U8=2 was missing (u8→f64 already had kind 2), TYPE_NAMED=8 (i8/i16/u16) never
   * matched → re-emitted integer bits then outer `as i32` did cvttss2si on denormals →
   * freestanding `(u8 as f32)` / `(i16 as f32)*f32` run=0 while i32→f32 and u8→f64 green.
   * G.7: complete i32-family → f32 next to wave292/295 f64 path (no new encoder).
   * Kinds: 0=i32, 2=u8, 3=u32, 8=NAMED (i8/i16/u16 spelling).
   */
  if (tgt > 0 && pipeline_type_kind_ord_at(arena, tgt) == 14) {
    int32_t src_tr = pipeline_expr_resolved_type_ref(arena, op);
    if (src_tr > 0) {
      int32_t src_kind = pipeline_type_kind_ord_at(arena, src_tr);
      /* Signed/narrow → f32 (eax cvtsi2ss). kind 3=u32 handled below (unsigned). */
      if (src_kind == 0 || src_kind == 2 || src_kind == 8) {
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
          return -1;
        return backend_enc_cvtsi2ss_eax_from_i32_arch(elf_ctx, ta);
      }
      /**
       * u32 → f32：zext eax→rax + REX.W cvtsi2ss (wave304 Cap residual pure).
       * PLATFORM: SHARED cast / LINUX+MACOS x86_64.
       * Root: 32-bit cvtsi2ss treats eax as signed i32 → u32>2^31-1 → negative f32 (run=0).
       * G.7: complete unsigned class next to u64 unsigned seq; mov eax,eax zero-extends.
       */
      if (src_kind == 3) {
        static const uint8_t mov_eax_eax[2] = {0x89, 0xc0};
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
          return -1;
        if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)mov_eax_eax, 2) != 0)
          return -1;
        return backend_enc_cvtsi2ss_eax_from_i64_arch(elf_ctx, ta);
      }
      /**
       * u64/usize → f32：unsigned convert sequence (wave304 Cap residual pure).
       * PLATFORM: SHARED cast semantics / LINUX+MACOS x86_64 emit.
       * Root: REX.W cvtsi2ss is signed; values >2^63-1 → negative f32 (freestanding run=0).
       * G.7: new backend_enc_cvtsi2ss_eax_from_u64_arch (gcc/clang algorithm) next to
       * signed i64 form (wave299). i64/isize keep signed path.
       */
      if (src_kind == 4 || src_kind == 6) {
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
          return -1;
        return backend_enc_cvtsi2ss_eax_from_u64_arch(elf_ctx, ta);
      }
      /* i64/isize → f32：signed REX.W cvtsi2ss (wave299). */
      if (src_kind == 5 || src_kind == 7) {
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
          return -1;
        return backend_enc_cvtsi2ss_eax_from_i64_arch(elf_ctx, ta);
      }
      /**
       * f64 → f32：cvtsd2ss (wave293 Cap residual pure).
       * PLATFORM: SHARED cast semantics / LINUX+MACOS x86_64 emit.
       * Root: prior EXPR_AS f32 target re-emitted f64 bits then low-32 movd + cvttss2si
       * → freestanding `(x:f64 as f32) as i32` run=0 (mac host-gcc hid). G.7: complete
       * EXPR_AS authority next to existing backend_enc_cvtsd2ss (ABI/var path).
       * Detect: TYPE_F32 target + f64 source (kind 15 / FLOAT_LIT / scalar-f64).
       */
      if (src_kind == 15 || glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, op)) {
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
          return -1;
        return backend_enc_cvtsd2ss_eax_from_f64_bits_arch(elf_ctx, ta);
      }
    }
  }
  /**
   * integer → f64：cvtsi2sd (wave292 i32; wave295 REX.W signed; wave304 unsigned u64/u32).
   * PLATFORM: SHARED cast semantics / LINUX+MACOS x86_64 emit.
   * Root (wave292): EXPR_AS f64 re-emitted integer bits → freestanding denormal mulsd → run=0.
   * Root (wave295): TYPE_U64 kind=4 was missing; 64-bit kinds need REX.W cvtsi2sd.
   * Root (wave304): signed cvtsi2sd makes u64>2^63-1 and u32>2^31-1 negative → run=0.
   * G.7: complete EXPR_AS → f64 authority (signed vs unsigned split by TypeKind).
   */
  if (tgt > 0 && pipeline_type_kind_ord_at(arena, tgt) == 15) {
    int32_t src_tr = pipeline_expr_resolved_type_ref(arena, op);
    if (src_tr > 0) {
      int32_t src_kind = pipeline_type_kind_ord_at(arena, src_tr);
      /* 4=u64, 6=usize — unsigned convert sequence (wave304). */
      if (src_kind == 4 || src_kind == 6) {
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
          return -1;
        return backend_enc_cvtsi2sd_rax_from_u64_arch(elf_ctx, ta);
      }
      /* 5=i64, 7=isize — signed REX.W cvtsi2sd (wave295). */
      if (src_kind == 5 || src_kind == 7) {
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
          return -1;
        return backend_enc_cvtsi2sd_rax_from_i64_arch(elf_ctx, ta);
      }
      /**
       * u32 → f64：zext + REX.W signed convert (wave304).
       * 32-bit cvtsi2sd treats eax as signed → u32>2^31-1 negative (run=0).
       */
      if (src_kind == 3) {
        static const uint8_t mov_eax_eax[2] = {0x89, 0xc0};
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
          return -1;
        if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)mov_eax_eax, 2) != 0)
          return -1;
        return backend_enc_cvtsi2sd_rax_from_i64_arch(elf_ctx, ta);
      }
      /*
       * 32-bit-class signed/narrow → f64 (eax form). wave302: TYPE_NAMED=8 for i8/i16/u16.
       * Keep 0/2 + 8 (u32 split out above).
       */
      if (src_kind == 0 || src_kind == 2 || src_kind == 8) {
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
          return -1;
        return backend_enc_cvtsi2sd_rax_from_i32_arch(elf_ctx, ta);
      }
      /**
       * f32 → f64：cvtss2sd (wave293 Cap residual pure).
       * PLATFORM: SHARED cast semantics / LINUX+MACOS x86_64 emit.
       * Root: prior path re-emitted f32 bits then cvttsd2si / mulsd treated those bits
       * as IEEE f64 → freestanding `(x:f32 as f64)` run=0. G.7: new encoder next to
       * cvtsd2ss / cvtsi2sd family.
       */
      if (src_kind == 14) {
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
          return -1;
        return backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx, ta);
      }
    }
  }
  return pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta);
}

/**
 * EXPR_AS ELF face (X emit_expr_elf single-line delegate).
 * wave1014 G.7: folded from pipeline_glue residual next to static impl.
 * PLATFORM: SHARED — product residual C; same TU as as_elf_impl.
 */
int32_t pipeline_asm_emit_as_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                   int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return pipeline_asm_emit_as_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
}
