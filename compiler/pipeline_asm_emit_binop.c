/**
 * pipeline_asm_emit_binop.c — asm ELF EXPR_BINOP arithmetic/bitwise/shift face
 * (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding BINOP ELF emit:
 * - pipeline_asm_emit_binop_add_elf_c (ADD + mixed f32/f64 + ptr arith scale)
 * - pipeline_asm_emit_binop_sub_elf_c
 * - pipeline_asm_emit_binop_mul_elf_c
 * - pipeline_asm_emit_binop_div_elf_c (signed/unsigned + div-zero panic face)
 * - pipeline_asm_emit_binop_mod_elf_c
 * - pipeline_asm_emit_binop_and_elf_c (logical && short-circuit is separate
 *   pipeline_asm_emit_logand.c)
 * - pipeline_asm_emit_binop_bitwise_elf_c (OR / XOR)
 * - pipeline_asm_emit_binop_shift_elf_c (<< / >> SAR vs SHR by signedness)
 * - glue_binop_operand_is_unsigned_elf_c / glue_binop_operand_is_64bit_elf_c
 * - nested rax/rbx op helpers colocated with add/sub/mul placement
 *   (glue_emit_binop_sub_* / mul / glue_try_emit_mixed_f32_f64_arith)
 * - glue_binop_operand_is_scalar_f32/f64 + type_ref scalar + ptr arith scale
 *   + glue_emit_binop_add_rax_rbx (wave1015 fold from glue residual)
 * - glue_try_binop_load_operand / commutative / left_rax / cmp placement
 *   + as_needs / may_clobber / preserve-restore (wave1018 fold)
 *
 * G.7: single product-mega BINOP ELF face — do not open a second int/float
 * arith path. CALL/METHOD_CALL remain seed backend_call_dispatch (not this
 * slice). EXPR_PANIC / div-zero helpers: wave127 pure (runtime_pipeline_abi)
 * (included just before this file in the same TU).
 *
 * Callers: pipeline_asm_emit_expr_elf_fast BINOP arms; compound-assign
 * glue_emit_assign_rhs_to_rax (in emit_assign leaf) uses nested rax/rbx helpers
 * (forwards in assign leaf; bodies here).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c at the former
 * binop body site (after panic include; before
 * field_access include).
 * wave1015 G.7 有则补全: residual scalar/ptr/add helpers at top of this leaf.
 * wave1018 G.7 有则补全: try_binop load/placement residual also in this leaf.
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/* ========================================================================
 * wave1015 G.7 fold: binop residual helpers (from pipeline_glue residual
 * after call_args include). Same-TU static; unary/as/assign use early
 * forward decls in pipeline_glue.c.
 * ======================================================================== */

/* ========================================================================
 * wave1018 G.7 fold: try_binop residual (as_needs + load_operand + clobber
 * predicates + preserve/restore + commutative placement + left_rax + cmp).
 * From pipeline_glue residual before index_eff_addr include. Same-TU static.
 * Callers: binop faces (this leaf); assign compound path (forward in assign);
 * cmp leaf (after this include); array_lit/vector_let via may_clobber forward.
 * f32 VAR slot load lives in call_args leaf (wave1019; shared with emit_expr
 * VAR arm). Spill CAP/cache in pipeline_asm_emit_spill.c / index_helpers.
 * ======================================================================== */

/**
 * Whether EXPR_AS must run pipeline_asm_emit_as_elf_impl in binop load (not peel).
 * True for float-target AS (wave301) and float-source → integer AS (wave620).
 * PLATFORM: SHARED freestanding dual-slot cast authority.
 */
static int32_t glue_binop_as_needs_full_emit_elf_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  int32_t op_ref;
  int32_t tgt;
  int32_t tgt_k;
  int32_t src_tr;
  int32_t src_k;
  int32_t op_ko;
  if (!arena || expr_ref <= 0 || !glue_expr_is_x_as_cast_at_c(arena, expr_ref))
    return 0;
  op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
  if (op_ref <= 0)
    return 0;
  tgt = pipeline_expr_as_target_type_ref_at(arena, expr_ref);
  if (tgt <= 0)
    return 0;
  tgt_k = pipeline_type_kind_ord_at(arena, tgt);
  if (tgt_k == GLUE_TYPE_KIND_F32_ORD || tgt_k == GLUE_TYPE_KIND_F64_ORD)
    return 1;
  src_tr = pipeline_expr_resolved_type_ref(arena, op_ref);
  src_k = src_tr > 0 ? pipeline_type_kind_ord_at(arena, src_tr) : -1;
  op_ko = pipeline_expr_kind_ord_at(arena, op_ref);
  /* kind 1 = EXPR_FLOAT_LIT — often unresolved or f64 default. */
  if (src_k == GLUE_TYPE_KIND_F32_ORD || src_k == GLUE_TYPE_KIND_F64_ORD ||
      (src_k <= 0 && op_ko == 1))
    return 1;
  return 0;
}

/**
 * 7.3：标量 binop 操作数装入 rax（to_rbx=0）或 rbx/x1（to_rbx=1）；VAR / VAR-base FIELD / INDEX。
 * 0=成功，-1=错，-2=需 rec slow。
 */
static int32_t glue_try_binop_load_operand_elf_c(struct ast_ASTArena *arena,
                                                 struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                 struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t to_rbx) {
  int32_t ko;
  int32_t off;
  int32_t vr;
  int32_t base_ref;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -2;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == GLUE_EXPR_KIND_VAR) {
    off = glue_var_expr_stack_off_elf_c(arena, ctx, expr_ref);
    if (off < 0)
      return -2;
    if (glue_block_live_fwd_active)
      glue_asm73_linear_scan_evict_cache_if_pressure_live(&glue_block_live_fwd, glue_block_emit_stmt_i, ta, elf_ctx);
    if (to_rbx != 0) {
      if (glue_binop_var_slot_cache.valid_rbx && glue_binop_var_slot_cache.ctx_key == (size_t)ctx &&
          glue_binop_var_slot_cache.rbx_off == off)
        return 0;
      vr = glue_binop_try_reload_spill_off_elf_c(elf_ctx, ctx, off, ta, 1);
      if (vr < 0)
        return -1;
      if (vr != 0)
        return 0;
      {
        int32_t vtr = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
        if (vtr > 0 && pipeline_type_kind_ord_at(arena, vtr) == GLUE_TYPE_KIND_F32_ORD) {
          if (glue_load_f32_var_slot_to_rbx_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta) != 0)
            return -1;
        } else if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, off, ta) != 0) {
          return -1;
        }
      }
      if (glue_asm73_var_prefers_stack_spill(off) != 0) {
        if (glue_binop_stack_spill_push_elf_c(elf_ctx, ta, off, 1) != 0)
          return -1;
        glue_binop_var_slot_cache.ctx_key = (size_t)ctx;
        return 0;
      }
      glue_binop_var_slot_cache.ctx_key = (size_t)ctx;
      glue_binop_var_slot_cache.valid_rbx = 1;
      glue_binop_var_slot_cache.rbx_off = off;
      return 0;
    }
    if (glue_binop_var_slot_cache.valid_rax && glue_binop_var_slot_cache.ctx_key == (size_t)ctx &&
        glue_binop_var_slot_cache.rax_off == off)
      return 0;
    vr = glue_binop_try_reload_spill_off_elf_c(elf_ctx, ctx, off, ta, 0);
    if (vr < 0)
      return -1;
    if (vr != 0)
      return 0;
    {
      int32_t vtr = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
      if (vtr > 0 && pipeline_type_kind_ord_at(arena, vtr) == GLUE_TYPE_KIND_F32_ORD) {
        if (glue_load_f32_var_slot_to_rax_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta) != 0)
          return -1;
      } else if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta) != 0) {
        return -1;
      }
    }
    if (glue_asm73_var_prefers_stack_spill(off) != 0) {
      if (glue_binop_stack_spill_push_elf_c(elf_ctx, ta, off, 0) != 0)
        return -1;
      glue_binop_var_slot_cache.ctx_key = (size_t)ctx;
      return 0;
    }
    glue_binop_var_slot_cache.ctx_key = (size_t)ctx;
    glue_binop_var_slot_cache.valid_rax = 1;
    glue_binop_var_slot_cache.rax_off = off;
    return 0;
  }
  if (ko == 44) {
    if (pipeline_expr_field_access_is_enum_variant(arena, expr_ref) != 0)
      return -2;
    base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
    /** DOD-S1：SoA `arr[i].field` 作 binop 右值须 field_access fast（含 stride/load_sz），勿 -2 落 INDEX imul AoS。 */
    if (base_ref > 0 && pipeline_expr_kind_ord_at(arena, base_ref) == 47) {
      glue_binop_var_slot_cache_clear();
      vr = pipeline_asm_emit_expr_elf_fast(arena, elf_ctx, expr_ref, ctx, ta);
      if (vr == PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED)
        return -2;
      if (vr != 0)
        return -1;
      if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      return 0;
    }
    if (base_ref <= 0 || pipeline_expr_kind_ord_at(arena, base_ref) != GLUE_EXPR_KIND_VAR)
      return -2;
    glue_binop_var_slot_cache_clear();
    /** TokenKind/ExprKind 枚举须在 field_access fast 回落，勿仅 var_field_access（binop RHS 比较）。 */
    vr = pipeline_asm_emit_field_access_elf_fast_c(arena, elf_ctx, expr_ref, ctx, ta);
    if (vr == PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED)
      return -2;
    if (vr != 0)
      return -1;
    if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  if (ko == 47) {
    glue_binop_var_slot_cache_clear();
    vr = pipeline_asm_emit_index_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    if (vr != 0)
      return -2;
    if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  /** wave323: *p as binop operand — emit load [ptr], not pointer bits. */
  if (ko == 52) {
    glue_binop_var_slot_cache_clear();
    vr = pipeline_asm_emit_deref_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    if (vr != 0)
      return -1;
    if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  /** u8[i] as i32 等：剥 EXPR_AS 再 load 标量操作数；C await(54) 剥 unary 操作数。 */
  if (glue_expr_is_await_at_c(arena, expr_ref)) {
    int32_t await_op;
    await_op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    if (await_op <= 0)
      return -2;
    return glue_try_binop_load_operand_elf_c(arena, elf_ctx, await_op, ctx, ta, to_rbx);
  }
  if (glue_expr_is_x_as_cast_at_c(arena, expr_ref)) {
    int32_t op_ref;
    op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
    if (op_ref <= 0)
      return -2;
    /*
     * wave301 Cap residual pure: peel only integer-result AS (e.g. u8[i] as i32).
     * Float-target AS must not peel — dual-slot would load raw integer/source bits
     * and skip cvtsi2ss / cvtsi2sd / cvtsd2ss / cvtss2sd from pipeline_asm_emit_as_elf.
     * Soft residual after wave299/300: `(u64 as f32) * f32_var` run=0 while bare
     * `(u64 as f32) as i32` stayed green. G.7: complete loader authority next to
     * emit_as (reuse pipeline_asm_emit_as_elf_impl; no new encoder / no second cast path).
     * PLATFORM: SHARED cast semantics / LINUX+MACOS x86_64 freestanding exposes; mac host-gcc hid.
     *
     * wave620 Cap residual pure: float→int AS must not peel either.
     * Top-level `return z as i32` hits pipeline_asm_emit_as_elf_impl (cvttss2si green),
     * but dual-slot binop `(x as i32)+(y as i32)` / `(a[0] as i32)+(a[1] as i32)` peeled
     * AS → integer ADD of IEEE bits (mac/Ubuntu pure-asm run=0 via 8-bit $?; host-C hid).
     * G.7: glue_binop_as_needs_full_emit_elf_c + same full-AS authority — no second path.
     * PLATFORM: SHARED freestanding dual-slot; LINUX x86_64 + MACOS|ARM64 both expose.
     */
    if (glue_binop_as_needs_full_emit_elf_c(arena, expr_ref) != 0) {
      glue_binop_var_slot_cache_clear();
      if (pipeline_asm_emit_as_elf_impl(arena, elf_ctx, expr_ref, ctx, ta) != 0)
        return -1;
      if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      return 0;
    }
    return glue_try_binop_load_operand_elf_c(arena, elf_ctx, op_ref, ctx, ta, to_rbx);
  }
  return -2;
}

/**
 * 装入操作数时是否会用 x1/rbx 做 INDEX 下标缩放或 bounds（会 clobber 已就位的 rbx 操作数）。
 *
 * wave329 Cap residual pure: TYPE_SLICE INDEX always runs
 * glue_emit_index_bounds_guard_elf_c which uses rbx (imm0 lower + length-1 upper)
 * even for literal indices. The old "lit idx → no rbx" shortcut only holds for
 * fixed TYPE_ARRAY on VAR/FIELD base (CTFE size; bounds guard early-returns without
 * rbx). Without this, dual-slot `a[i]+a[j]` on slices keeps right in rbx then left
 * INDEX overwrites it (Ubuntu freestanding sum 10+20+12 → 24; host-C hid).
 *
 * wave612 Cap residual pure: freestanding dual ARRAY_LIT INDEX binop
 * (`[10,32][0]+[10,32][1]`). `pipeline_asm_emit_array_lit_elf_c` always parks the
 * payload base in rbx (`mov rax→rbx` / x1) while storing elems (wave340 dual-slot).
 * INDEX of that base re-leas into rbx then loads the elem — so even TYPE_ARRAY +
 * lit index clobbers a live binop operand in rbx (mac fs run=114; Ubuntu run=218;
 * let-split `a+b` green; host-C green). The "lit idx → no rbx" shortcut must not
 * apply when base materializes through ARRAY_LIT (or other non-VAR bases that park
 * temps in rbx: STRUCT_LIT/CALL/METHOD). G.7: complete this classifier only —
 * preserve/restore path already exists (glue_binop_preserve_rbx_for_index_elf_c).
 *
 * wave625 Cap residual pure: peel FIELD_ACCESS (ko=44) before INDEX classify.
 * Root: `a[0].x + a[1].y` on `[]Pt` — both operands are FIELD of INDEX; classifier
 * only handled bare INDEX (ko=47) → save_rbx=0 → left slice bounds guard
 * `mov w1,#0` / `ldr x1,length` clobbered rhs parked in x1 → sum=10+2=12
 * (storage esz already 8 via force_esz NAMED; p1y alone=32; let-split x+y=42).
 * G.7: same peel as await/as; do not invent a second preserve path.
 * PLATFORM: SHARED freestanding dual-slot; LINUX x86_64 + MACOS|ARM64 both expose.
 */
static int32_t glue_binop_operand_index_addr_clobbers_rbx_elf_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  int32_t ko;
  int32_t op_ref;
  if (!arena || expr_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (glue_expr_is_await_at_c(arena, expr_ref)) {
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    return op_ref > 0 ? glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref) : 0;
  }
  if (glue_expr_is_x_as_cast_at_c(arena, expr_ref)) {
    op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
    return op_ref > 0 ? glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref) : 0;
  }
  /* wave625: FIELD of INDEX still runs INDEX bounds/addr in rbx (a[i].x dual-slot). */
  if (ko == 44) {
    op_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
    return op_ref > 0 ? glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref) : 0;
  }
  if (ko == 47) {
    int32_t idx_ref;
    int32_t lit_dummy;
    struct ast_Expr *ix;
    int32_t base_ref;
    int32_t base_ty;
    int32_t base_ko;
    ix = pipeline_arena_expr_ptr(arena, expr_ref);
    if (ix && ix->index_base_is_slice != 0)
      return 1;
    base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
    if (base_ref > 0) {
      base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
      if (base_ty > 0 && pipeline_type_kind_ord_at(arena, base_ty) == GLUE_TYPE_KIND_SLICE)
        return 1;
      /*
       * Materializing bases park payload/home in rbx while writing temps.
       * ARRAY_LIT (46): emit_array_lit mov rax→rbx for store loop.
       * STRUCT_LIT (45) / CALL (48) / METHOD (49): call_base / struct temp same.
       * Nested INDEX (47) / FIELD (44) of those: recurse via base walk below.
       * Only VAR / pure FIELD-of-VAR can take base+imm*esz without touching rbx.
       */
      base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
      if (base_ko == 46 || base_ko == 45 || base_ko == 48 || base_ko == 49)
        return 1;
      if (base_ko == 47)
        return 1;
      if (base_ko == 44) {
        int32_t fa_base = pipeline_expr_field_access_base_ref(arena, base_ref);
        if (fa_base > 0) {
          int32_t fa_ko = pipeline_expr_kind_ord_at(arena, fa_base);
          /* FIELD of materializing root (Wrap{}.xs[i] dual-slot) also parks rbx. */
          if (fa_ko == 46 || fa_ko == 45 || fa_ko == 48 || fa_ko == 49 || fa_ko == 47)
            return 1;
        }
      }
    }
    idx_ref = pipeline_expr_index_index_ref(arena, expr_ref);
    /* Fixed TYPE_ARRAY + lit index on VAR/FIELD base: base+imm*esz, bounds CTFE — no rbx. */
    if (idx_ref > 0 && pipeline_asm_expr_lit_i32_at_c(arena, idx_ref, &lit_dummy))
      return 0;
    return 1;
  }
  return 0;
}

/**
 * 装入 rbx 时是否会经 rax 中转（FIELD/INDEX）；VAR 直 ldr 到 rbx 不 clobber 已在 rax 的左值。
 * 7.3 活跃性原型：嵌套 binop slow 路径仅在此为 1 时暂存 rax/x2。
 */
static int32_t glue_binop_operand_load_to_rbx_clobbers_rax_elf_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  int32_t ko;
  int32_t op_ref;
  if (!arena || expr_ref <= 0)
    return 1;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == GLUE_EXPR_KIND_VAR)
    return 0;
  /** 立即数直 mov 到 rbx，不经 rax。 */
  if (ko == 0 || ko == 2)
    return 0;
  if (ko == 44 || ko == 47)
    return 1;
  if (glue_expr_is_await_at_c(arena, expr_ref)) {
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    return op_ref > 0 ? glue_binop_operand_load_to_rbx_clobbers_rax_elf_c(arena, op_ref) : 1;
  }
  if (glue_expr_is_x_as_cast_at_c(arena, expr_ref)) {
    /*
     * wave620: full-AS (float↔int) always materializes via rax then mov→rbx when
     * to_rbx=1 — peels as VAR would claim "no clobber" and destroy a live left in rax.
     */
    if (glue_binop_as_needs_full_emit_elf_c(arena, expr_ref) != 0)
      return 1;
    op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
    return op_ref > 0 ? glue_binop_operand_load_to_rbx_clobbers_rax_elf_c(arena, op_ref) : 1;
  }
  return 1;
}

/**
 * rec emit 表达式时是否会 clobber 已在 rbx 的左比较操作数（binop/FIELD/INDEX 等）。
 * VAR/字面量直 mov 到 rax 不动 rbx；7.3 cmp 左 rbx + 右 slow emit 前按需 x2 暂存。
 */
int32_t glue_expr_emit_may_clobber_rbx_elf_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  int32_t ko;
  int32_t op_ref;
  if (!arena || expr_ref <= 0)
    return 1;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == GLUE_EXPR_KIND_VAR || ko == 0 || ko == 2)
    return 0;
  if (ko == 44 || ko == 47)
    return 1;
  if (glue_expr_is_await_at_c(arena, expr_ref)) {
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    return op_ref > 0 ? glue_expr_emit_may_clobber_rbx_elf_c(arena, op_ref) : 1;
  }
  if (glue_expr_is_x_as_cast_at_c(arena, expr_ref)) {
    /* Full-AS may walk INDEX/FIELD operands that park temps in rbx. */
    if (glue_binop_as_needs_full_emit_elf_c(arena, expr_ref) != 0) {
      op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
      return op_ref > 0 ? glue_expr_emit_may_clobber_rbx_elf_c(arena, op_ref) : 1;
    }
    op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
    return op_ref > 0 ? glue_expr_emit_may_clobber_rbx_elf_c(arena, op_ref) : 1;
  }
  return 1;
}

/**
 * INDEX 装入另一操作数前暂存已就位的 rbx（arm64→x2，其余→push_rbx）。
 * 实现在 glue 内，避免 seed 链 backend_enc_dispatch.o 未重编时缺符号。
 */
static int32_t glue_binop_preserve_rbx_for_index_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_rbx_to_x2(elf_ctx);
  return backend_enc_push_rbx_arch(elf_ctx, ta);
}

/**
 * INDEX 装入完成后恢复 rbx（arm64←x2，其余 pop_rbx）。
 */
static int32_t glue_binop_restore_rbx_after_index_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_x2_to_rbx(elf_ctx);
  return backend_enc_pop_rbx_arch(elf_ctx, ta);
}

/**
 * Left operand is live in rax; park it while loading the right into rbx when that
 * load/emit would clobber rax (FIELD/INDEX via rax, CALL/METHOD, nested binop).
 *
 * wave403 Cap residual pure — two arm64 false starts, one root:
 *   1) volatile x9: right CALL body reuses x9 for multi-INDEX partials
 *      (`s[0]+s[1]+s[2]`) → outer `take(a)+take(a)` restored clobbered left
 *      (fs run=9 expect 12; host-C / Linux x86 push path green).
 *   2) SP push (str x0,[sp,#-16]!): arm64 callee prolog `str x0,[x29,#0x10]`
 *      for the first param home sits at the pre-call SP slot and overwrites the
 *      parked left (mid_s0 run=33; disasm correct-looking push/pop still red).
 * G.7 single authority:
 *   - LINUX|x86_64: keep push/pop (call-safe under SysV; not the arm64 leaf).
 *   - MACOS|ARM64: frame-local spill via ctx next_offset + nest stack of homes
 *     (x29-relative; survives CALL; nest-safe for chained binops). Do not invent
 *     a second preserve register; x9 stays free for other scratch.
 * PLATFORM: SHARED freestanding binop preserve · MACOS|ARM64 frame · LINUX|x86 push.
 */
static int32_t glue_binop_preserve_rax_for_rbx_load_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t ta, struct backend_AsmFuncCtx *ctx) {
  if (ta != 1)
    return backend_enc_push_rax_arch(elf_ctx, ta);
  {
    pipeline_glue_AsmFuncCtxLayout *ly;
    int32_t base_off;
    int32_t home;
    if (!elf_ctx || !ctx)
      return -1;
    if (glue_binop_rax_frame_spill_n >= GLUE_BINOP_RAX_FRAME_SPILL_CAP)
      return -1;
    ly = pipeline_asm_ctx_layout(ctx);
    if (!ly)
      return -1;
    /* PLATFORM: MACOS|ARM64 low-end home (wave402): home=off, next=off+8. */
    base_off = ly->next_offset;
    if ((base_off % 8) != 0)
      base_off = (base_off + 7) / 8 * 8;
    home = base_off;
    ly->next_offset = base_off + 8;
    glue_align_next_offset(ctx);
    glue_binop_rax_frame_spill_off[glue_binop_rax_frame_spill_n++] = home;
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
      return -1;
    return 0;
  }
}

/**
 * Pair restore for glue_binop_preserve_rax_for_rbx_load_elf_c.
 * x86: pop rax. arm64: load from nested frame home (wave403).
 * PLATFORM: SHARED freestanding · matches preserve.
 */
static int32_t glue_binop_restore_rax_after_rbx_load_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                               int32_t ta) {
  if (ta != 1)
    return backend_enc_pop_rax_arch(elf_ctx, ta);
  {
    int32_t home;
    if (!elf_ctx || glue_binop_rax_frame_spill_n <= 0)
      return -1;
    home = glue_binop_rax_frame_spill_off[--glue_binop_rax_frame_spill_n];
    return backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta);
  }
}

/**
 * 7.3：纯 VAR+VAR 交换律 binop，按槽缓存选择装载顺序（含 rbx 已含左操作数时 swap）。
 * 0=就绪，-1=错，-2=不适用。
 */
static int32_t glue_try_binop_commutative_var_var_slot_cached_elf_c(struct ast_ASTArena *arena,
                                                                       struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                       int32_t left_ref, int32_t right_ref,
                                                                       struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t loff;
  int32_t roff;
  int32_t rax_hit_l;
  int32_t rax_hit_r;
  int32_t rbx_hit_l;
  int32_t rbx_hit_r;
  if (!arena || !elf_ctx || !ctx)
    return -2;
  if (pipeline_expr_kind_ord_at(arena, left_ref) != GLUE_EXPR_KIND_VAR ||
      pipeline_expr_kind_ord_at(arena, right_ref) != GLUE_EXPR_KIND_VAR)
    return -2;
  loff = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
  roff = glue_var_expr_stack_off_elf_c(arena, ctx, right_ref);
  if (loff < 0 || roff < 0)
    return -2;
  if (glue_binop_var_slot_cache.ctx_key != (size_t)ctx)
    return -2;
  rax_hit_l = glue_binop_var_slot_cache.valid_rax && glue_binop_var_slot_cache.rax_off == loff;
  rax_hit_r = glue_binop_var_slot_cache.valid_rax && glue_binop_var_slot_cache.rax_off == roff;
  rbx_hit_l = glue_binop_var_slot_cache.valid_rbx && glue_binop_var_slot_cache.rbx_off == loff;
  rbx_hit_r = glue_binop_var_slot_cache.valid_rbx && glue_binop_var_slot_cache.rbx_off == roff;
  /** 目标：rax=left(loff)，rbx=right(roff)。 */
  if (rax_hit_l && rbx_hit_r)
    return 0;
  if (rax_hit_l) {
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1) != 0)
      return -1;
    return 0;
  }
  if (rbx_hit_r) {
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, left_ref, ctx, ta, 0) != 0)
      return -1;
    return 0;
  }
  /** 左操作数已在 rbx（如上一笔 a+b 后 b+a 的 b）。 */
  if (rbx_hit_l) {
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, left_ref, ctx, ta, 1) != 0)
      return -1;
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0) != 0)
      return -1;
    if (glue_enc_swap_rax_rbx_arm64_elf_c(elf_ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache.valid_rax = 1;
    glue_binop_var_slot_cache.rax_off = loff;
    glue_binop_var_slot_cache.valid_rbx = 1;
    glue_binop_var_slot_cache.rbx_off = roff;
    return 0;
  }
  if (rax_hit_r) {
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0) != 0)
      return -1;
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, left_ref, ctx, ta, 1) != 0)
      return -1;
    if (glue_enc_swap_rax_rbx_arm64_elf_c(elf_ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache.valid_rax = 1;
    glue_binop_var_slot_cache.rax_off = loff;
    glue_binop_var_slot_cache.valid_rbx = 1;
    glue_binop_var_slot_cache.rbx_off = roff;
    return 0;
  }
  return -2;
}

/**
 * 7.3：交换律 binop 尝试 VAR/FIELD/INDEX 快速路径，将左/右装入 rax/rbx；0=就绪，-1=错，-2=需 push/pop slow。
 */
static int32_t glue_try_binop_commutative_rax_rbx_elf_c(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          int32_t left_ref, int32_t right_ref,
                                                          struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t r;
  int32_t cr;
  if (!arena || !elf_ctx || !ctx)
    return -2;
  cr = glue_try_binop_commutative_var_var_slot_cached_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (cr == 0)
    return 0;
  if (cr == -1)
    return -1;
  /** FIELD/INDEX 内部经 rax：须先 rbx 后 rax，避免第二次 load 覆盖第一次。 */
  r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1);
  if (r == 0) {
    int32_t save_rbx;
    save_rbx = glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, left_ref);
    if (save_rbx != 0 && glue_binop_preserve_rbx_for_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, left_ref, ctx, ta, 0);
    if (save_rbx != 0 && glue_binop_restore_rbx_after_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    if (r != -2)
      return r;
  } else if (r == -1) {
    return -1;
  }
  r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, left_ref, ctx, ta, 1);
  if (r == 0) {
    int32_t save_rbx;
    save_rbx = glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, right_ref);
    if (save_rbx != 0 && glue_binop_preserve_rbx_for_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0);
    if (save_rbx != 0 && glue_binop_restore_rbx_after_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    if (r != -2)
      return r;
  } else if (r == -1) {
    return -1;
  }
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  {
    int32_t save_rax;
    save_rax = glue_binop_operand_load_to_rbx_clobbers_rax_elf_c(arena, right_ref);
    if (save_rax != 0 && glue_binop_preserve_rax_for_rbx_load_elf_c(elf_ctx, ta, ctx) != 0)
      return -1;
    r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1);
    if (r == -1) {
      if (save_rax != 0)
        (void)glue_binop_restore_rax_after_rbx_load_elf_c(elf_ctx, ta);
      return -1;
    }
    if (r == -2) {
      if (save_rax == 0 && glue_binop_preserve_rax_for_rbx_load_elf_c(elf_ctx, ta, ctx) != 0)
        return -1;
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      save_rax = 1;
    }
    if (save_rax != 0 && glue_binop_restore_rax_after_rbx_load_elf_c(elf_ctx, ta) != 0)
      return -1;
  }
  return 0;
}

/** 7.3：交换律 binop slow — 左入栈、右到 rax、pop 到 rbx（与 add/and 栈序一致）。 */
static int32_t glue_finish_binop_commutative_slow_rax_rbx_elf_c(struct ast_ASTArena *arena,
                                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                   int32_t left_ref, int32_t right_ref,
                                                                   struct backend_AsmFuncCtx *ctx, int32_t ta) {
  glue_binop_var_slot_cache_clear();
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  return 0;
}

/**
 * 7.3：非交换 binop — 左 value 在 rax、右 count/divisor 在 rbx（SHIFT/DIV/MOD 共用）；0=就绪，-1=错，-2=需 slow。
 */
int32_t glue_try_binop_left_rax_right_rbx_elf_c(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          int32_t left_ref, int32_t right_ref,
                                                          struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t r;
  if (!arena || !elf_ctx || !ctx)
    return -2;
  /** 非交换：左 rax 右 rbx；FIELD/INDEX 时先装 rbx 再装 rax。 */
  r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1);
  if (r == 0) {
    int32_t save_rbx;
    save_rbx = glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, left_ref);
    if (save_rbx != 0 && glue_binop_preserve_rbx_for_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, left_ref, ctx, ta, 0);
    if (save_rbx != 0 && glue_binop_restore_rbx_after_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    if (r != -2)
      return r;
    {
      int32_t save_rbx_emit;
      /** 右已在 rbx；左 slow emit 可能 clobber rbx（与 cmp 右 slow emit 对称）。 */
      save_rbx_emit = glue_expr_emit_may_clobber_rbx_elf_c(arena, left_ref);
      if (save_rbx_emit != 0 && glue_binop_preserve_rbx_for_index_elf_c(elf_ctx, ta) != 0)
        return -1;
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
        return -1;
      if (save_rbx_emit != 0 && glue_binop_restore_rbx_after_index_elf_c(elf_ctx, ta) != 0)
        return -1;
    }
    return 0;
  } else if (r == -1) {
    return -1;
  }
  r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, left_ref, ctx, ta, 0);
  if (r == 0) {
    int32_t save_rbx;
    save_rbx = glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, right_ref);
    if (save_rbx != 0 && glue_binop_preserve_rbx_for_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1);
    if (save_rbx != 0 && glue_binop_restore_rbx_after_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    if (r != -2)
      return r;
    /** 左已在 rax；右 slow emit 须 x2 暂存 rax 再 mov 到 rbx。 */
    if (glue_binop_preserve_rax_for_rbx_load_elf_c(elf_ctx, ta, ctx) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (glue_binop_restore_rax_after_rbx_load_elf_c(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  if (r == -1)
    return -1;
  r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1);
  if (r == 0) {
    int32_t save_rbx_emit;
    save_rbx_emit = glue_expr_emit_may_clobber_rbx_elf_c(arena, left_ref);
    if (save_rbx_emit != 0 && glue_binop_preserve_rbx_for_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (save_rbx_emit != 0 && glue_binop_restore_rbx_after_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  if (r == -1)
    return -1;
  return -2;
}

/**
 * 7.3：比较 binop — 左 rbx、右 rax（enc_cmp_rbx_rax）；0=就绪，-1=错，-2=需 slow。
 *
 * wave669 Cap residual pure: freestanding lit-left `0==p` / `null==p` false green.
 * Root: when left cannot fast-load to rbx, this path loads right VAR → rax (caches
 * valid_rax), then emit left imm clobbers rax without invalidating the VAR slot
 * cache; reload right hits cache and skips the second load → cmp 0,0 → equal.
 * Fix: invalidate rax before emit-left, invalidate rbx after mov left into rbx,
 * then reload right. G.7: same try path authority (no second cmp loader).
 * PLATFORM: SHARED freestanding dual-slot; LINUX x86_64 exposes (host-C hid).
 */
/* wave137 Cap residual for cmp pure leave: non-static face. */
int32_t glue_try_binop_cmp_rbx_rax_elf_c(struct ast_ASTArena *arena,
                                                  struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                  int32_t left_ref, int32_t right_ref,
                                                  struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t r;
  if (!arena || !elf_ctx || !ctx)
    return -2;
  r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, left_ref, ctx, ta, 1);
  if (r == 0) {
    int32_t save_rbx;
    save_rbx = glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, right_ref);
    if (save_rbx != 0 && glue_binop_preserve_rbx_for_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0);
    if (save_rbx != 0 && glue_binop_restore_rbx_after_index_elf_c(elf_ctx, ta) != 0)
      return -1;
    if (r != -2)
      return r;
    {
      int32_t save_rbx_emit;
      save_rbx_emit = glue_expr_emit_may_clobber_rbx_elf_c(arena, right_ref);
      if (save_rbx_emit != 0 && glue_binop_preserve_rbx_for_index_elf_c(elf_ctx, ta) != 0)
        return -1;
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
        return -1;
      if (save_rbx_emit != 0 && glue_binop_restore_rbx_after_index_elf_c(elf_ctx, ta) != 0)
        return -1;
    }
    return 0;
  }
  if (r == -1)
    return -1;
  r = glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0);
  if (r == 0) {
    /* emit left writes rax — drop stale "right VAR still in rax" cache hit. */
    glue_binop_var_slot_cache_invalidate_rax();
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    /* rbx now holds left (often a lit), not a cached right VAR slot. */
    glue_binop_var_slot_cache_invalidate_rbx();
    return glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0);
  }
  if (r == -1)
    return -1;
  return -2;
}


/** 类型 ref 是否为标量 f32。 */
static int32_t glue_type_ref_is_scalar_f32_c(struct ast_ASTArena *arena, int32_t type_ref) {
  if (!arena || type_ref <= 0)
    return 0;
  return pipeline_type_kind_ord_at(arena, type_ref) == GLUE_TYPE_KIND_F32_ORD ? 1 : 0;
}

/** 类型 ref 是否为标量 f64。 */
static int32_t glue_type_ref_is_scalar_f64_c(struct ast_ASTArena *arena, int32_t type_ref) {
  if (!arena || type_ref <= 0)
    return 0;
  return pipeline_type_kind_ord_at(arena, type_ref) == GLUE_TYPE_KIND_F64_ORD ? 1 : 0;
}

/** 表达式 resolved_type 是否为标量 f32。 */
static int32_t glue_expr_resolved_is_scalar_f32_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  return glue_type_ref_is_scalar_f32_c(arena, pipeline_expr_resolved_type_ref(arena, expr_ref));
}

/** 表达式 resolved_type 是否为标量 f64。 */
static int32_t glue_expr_resolved_is_scalar_f64_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  return glue_type_ref_is_scalar_f64_c(arena, pipeline_expr_resolved_type_ref(arena, expr_ref));
}

/**
 * binop/assign：判定操作数是否为标量 f32（resolved / 局部声明 / SoA INDEX *f32）。
 * heap Vec3f sum_x 等路径 INDEX 常无 resolved_type，须回落字段 *f32 与 VAR let/形参类型。
 */
/* wave133 pure leave Cap residual: was static; pure unary neg links here. */
int32_t glue_binop_operand_is_scalar_f32_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                int32_t expr_ref) {
  int32_t ko;
  int32_t tr;
  int32_t base_ref;
  if (!arena || expr_ref <= 0)
    return 0;
  if (glue_expr_resolved_is_scalar_f32_c(arena, expr_ref))
    return 1;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == GLUE_EXPR_KIND_VAR && ctx) {
    tr = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
    return glue_type_ref_is_scalar_f32_c(arena, tr);
  }
  /** AoS arr[i].x：FIELD_ACCESS 回落字段类型（SoA 外堆/栈 f32 列扫描须 addss）。 */
  if (ko == 44) {
    tr = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, expr_ref);
    if (glue_type_ref_is_scalar_f32_c(arena, tr))
      return 1;
    tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
    return glue_type_ref_is_scalar_f32_c(arena, tr);
  }
  if (ko == 47) {
    tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
    if (glue_type_ref_is_scalar_f32_c(arena, tr))
      return 1;
    if (pipeline_asm_index_elem_byte_sz_c(arena, expr_ref) != 4)
      return 0;
    base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
    if (base_ref > 0 && pipeline_expr_kind_ord_at(arena, base_ref) == 44) {
      tr = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, base_ref);
      if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == GLUE_TYPE_KIND_PTR) {
        tr = pipeline_type_elem_ref_at(arena, tr);
        return glue_type_ref_is_scalar_f32_c(arena, tr);
      }
    }
  }
  if (ko == 1)
    return glue_type_ref_is_scalar_f32_c(arena, pipeline_expr_resolved_type_ref(arena, expr_ref));
  /* CALL/METHOD_CALL: same return-kind fallback as f64 (G.7 single authority). */
  if (ko == 48 || ko == 49) {
    int32_t rk = pipeline_asm_call_return_type_kind_ord_c(arena, expr_ref);
    return rk == GLUE_TYPE_KIND_F32_ORD ? 1 : 0;
  }
  /** f32 加法链：(t.x+t.y)+t.z 左子为 ADD 时 skip typeck 无 resolved_type，须递归判定。 */
  if (ko == 4) {
    int32_t lr = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    int32_t rr = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    if (lr > 0 && rr > 0 &&
        glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, lr) &&
        glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, rr))
      return 1;
  }
  return 0;
}

/**
 * binop：标量 f64 操作数（resolved / 局部声明 / 浮点字面量 / 加减链 / call ret）。
 * PLATFORM: SHARED type / LINUX+MACOS x86_64 uses addsd/subsd/ucomisd.
 *
 * CALL(48) and METHOD_CALL(49) must share one return-kind fallback:
 * product `import("std.math"); math.pi()` is METHOD_CALL, and resolved_type is
 * often empty on that path. Historical code only re-checked resolved for CALL,
 * so cmp finish fell through to 32-bit cmpl of IEEE low halves (math_asm run=1
 * on `math.pi() <= 3.0`). G.7: complete authority via call_return_type_kind_ord
 * (already resolves kind 49 targets).
 */
/* wave133 pure leave Cap residual: was static; pure unary neg links here. */
int32_t glue_binop_operand_is_scalar_f64_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                int32_t expr_ref) {
  int32_t ko;
  int32_t tr;
  int32_t rk;
  if (!arena || expr_ref <= 0)
    return 0;
  if (glue_expr_resolved_is_scalar_f64_c(arena, expr_ref))
    return 1;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == GLUE_EXPR_KIND_VAR && ctx) {
    tr = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
    return glue_type_ref_is_scalar_f64_c(arena, tr);
  }
  /** FLOAT_LIT default / unresolved → treat as f64 (typeck ensures_f64). */
  if (ko == 1)
    return 1;
  /* CALL (48) / METHOD_CALL (49): callee return kind when expr resolved is empty. */
  if (ko == 48 || ko == 49) {
    rk = pipeline_asm_call_return_type_kind_ord_c(arena, expr_ref);
    return rk == GLUE_TYPE_KIND_F64_ORD ? 1 : 0;
  }
  if (ko == 4 || ko == 5 || ko == 6 || ko == 7) {
    int32_t lr = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    int32_t rr = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    if (lr > 0 && rr > 0 && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, lr) &&
        glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, rr))
      return 1;
  }
  return 0;
}

/** wave296/wave297 mixed f32/f64 arith; defined below (forward for add path). */
static int32_t glue_try_emit_mixed_f32_f64_arith_elf_c(struct ast_ASTArena *arena,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                        struct backend_AsmFuncCtx *ctx, int32_t left_ref,
                                                        int32_t right_ref, int32_t ta, int32_t op_kind);
/** wave298: f32/f64 SUB helper (forward for assign -= path above body). */
int32_t glue_emit_binop_sub_rax_minus_rbx_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         struct backend_AsmFuncCtx *ctx, int32_t left_ref,
                                                         int32_t right_ref, int32_t ta);

/**
 * wave642 Cap residual pure: freestanding C-like pointer arithmetic scale.
 * typeck allows ptr±int / int+ptr / ptr-ptr (wave285); host-C scales by sizeof(*p).
 * Prior freestanding ADD/SUB used raw GP add → `p+1` advanced 1 byte (i32 expect 4;
 * pure-asm CTFE often folds false-green; host-C green). Reuse INDEX PTR peel
 * (`glue_index_elem_byte_sz_from_type_ref_c`) for pointee width — G.7 single face.
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
 */
static int32_t glue_expr_type_is_ptr_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  int32_t tr;
  if (!arena || expr_ref <= 0)
    return 0;
  tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (tr <= 0)
    return 0;
  return pipeline_type_kind_ord_at(arena, tr) == GLUE_TYPE_KIND_PTR ? 1 : 0;
}

/** Pointee byte width for pointer-typed expr (0 if not ptr / unknown). */
static int32_t glue_ptr_expr_pointee_byte_sz_c(struct ast_ASTArena *arena, int32_t ptr_expr_ref) {
  int32_t tr;
  int32_t esz;
  if (!arena || ptr_expr_ref <= 0)
    return 0;
  tr = pipeline_expr_resolved_type_ref(arena, ptr_expr_ref);
  if (tr <= 0 || pipeline_type_kind_ord_at(arena, tr) != GLUE_TYPE_KIND_PTR)
    return 0;
  esz = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
  return esz > 0 ? esz : 0;
}

/**
 * Scale offset in rbx by pointee size when left@rax is *T and right is integer
 * (assign `p += n` / `p -= n` left-rax right-rbx convention).
 * @return 0 ok; -1 emit fail
 */
static int32_t glue_ptr_arith_scale_rbx_offset_if_left_ptr_c(struct ast_ASTArena *arena,
                                                              struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                              int32_t left_ref, int32_t right_ref,
                                                              int32_t ta) {
  int32_t esz;
  if (!glue_expr_type_is_ptr_c(arena, left_ref))
    return 0;
  if (glue_expr_type_is_ptr_c(arena, right_ref))
    return 0;
  esz = glue_ptr_expr_pointee_byte_sz_c(arena, left_ref);
  if (esz <= 1)
    return 0;
  return backend_enc_mul_imm_to_rbx_arch(elf_ctx, esz, ta);
}

/**
 * Emit ptr ± int / int + ptr with C scale: ptr@rax, (offset*esz)@rbx, then add or sub.
 * @param is_sub 0=add, 1=sub (ptr - int only; int-ptr rejected by typeck)
 * @return 0 handled; -2 not pointer arith (caller falls through); -1 emit fail
 */
static int32_t glue_try_emit_ptr_arith_scaled_elf_c(struct ast_ASTArena *arena,
                                                     struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                     struct backend_AsmFuncCtx *ctx, int32_t left_ref,
                                                     int32_t right_ref, int32_t ta, int32_t is_sub) {
  int32_t lp;
  int32_t rp;
  int32_t ptr_ref;
  int32_t off_ref;
  int32_t esz;
  int32_t lit_imm;
  int32_t scaled;
  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return -2;
  lp = glue_expr_type_is_ptr_c(arena, left_ref);
  rp = glue_expr_type_is_ptr_c(arena, right_ref);
  if (is_sub) {
    /* ptr - ptr → element count (byte diff / esz). */
    if (lp && rp) {
      esz = glue_ptr_expr_pointee_byte_sz_c(arena, left_ref);
      if (esz <= 0)
        return -1;
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_sub_rax_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (esz != 1) {
        glue_binop_var_slot_cache_invalidate_rbx();
        if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, esz, ta) != 0)
          return -1;
        if (backend_enc_idiv_rbx_arch(elf_ctx, ta) != 0)
          return -1;
      }
      glue_binop_var_slot_cache_invalidate_rax();
      glue_binop_var_slot_cache_invalidate_rbx();
      return 0;
    }
    /* ptr - int only (int - ptr rejected at typeck). */
    if (!(lp && !rp))
      return -2;
    ptr_ref = left_ref;
    off_ref = right_ref;
  } else {
    /* ADD: exactly one pointer (ptr+int or int+ptr). */
    if (lp == rp)
      return -2;
    ptr_ref = lp ? left_ref : right_ref;
    off_ref = lp ? right_ref : left_ref;
  }
  esz = glue_ptr_expr_pointee_byte_sz_c(arena, ptr_ref);
  if (esz <= 0)
    return -1;
  /* ptr → rax */
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, ptr_ref, ctx, ta) != 0)
    return -1;
  glue_binop_var_slot_cache_invalidate_rax();
  /* offset → rbx, pre-scale when literal (avoid imul on 1*esz). */
  if (pipeline_asm_expr_lit_i32_at_c(arena, off_ref, &lit_imm)) {
    scaled = lit_imm;
    if (esz != 1) {
      /* Small probes; overflow → still best-effort int32 product. */
      scaled = lit_imm * esz;
    }
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, scaled, ta) != 0)
      return -1;
  } else {
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, off_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (esz > 1 && backend_enc_mul_imm_to_rbx_arch(elf_ctx, esz, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
  }
  if (is_sub) {
    if (backend_enc_sub_rax_rbx_arch(elf_ctx, ta) != 0)
      return -1;
  } else {
    if (backend_enc_add_rax_rbx_arch(elf_ctx, ta) != 0)
      return -1;
  }
  glue_binop_var_slot_cache_invalidate_rax();
  return 0;
}

/** f32 ADD → addss; f64 ADD → addsd; else integer add。 */
int32_t glue_emit_binop_add_rax_rbx_elf_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   struct backend_AsmFuncCtx *ctx, int32_t left_ref,
                                                   int32_t right_ref, int32_t ta) {
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref))
    return backend_enc_addsd_rax_rbx_arch(elf_ctx, ta);
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref))
    return backend_enc_addss_rax_rbx_arch(elf_ctx, ta);
  /* wave642: assign `p += n` — left@rax right@rbx; scale integer offset. */
  if (glue_ptr_arith_scale_rbx_offset_if_left_ptr_c(arena, elf_ctx, left_ref, right_ref, ta) != 0)
    return -1;
  return backend_enc_add_rax_rbx_arch(elf_ctx, ta);
}


/* Forward decls / callees defined elsewhere in the same TU:
 * - pipeline_asm_emit_expr_elf_rec (static; declared earlier)
 * - pipeline_asm_emit_panic_int_div_zero_elf_c /
 *   pipeline_asm_emit_divisor_zero_check_rbx_elf_c (wave127 pure; extern)
 * - glue_try_binop_left_rax_right_rbx_elf_c / glue_emit_binop_add_rax_rbx_elf_c
 *   (still in glue; defined before this include)
 * - glue_binop_var_slot_cache_* / glue_var_decl_type_ref_elf_c
 * - backend_enc_*_arch / pipeline_expr_* / pipeline_type_*
 * - glue_ptr_arith_scale_rbx_offset_if_left_ptr_c
 * - glue_binop_operand_is_scalar_f32/f64_elf_c
 */

static int32_t pipeline_asm_emit_binop_add_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   int32_t left_ref, int32_t right_ref, struct backend_AsmFuncCtx *ctx,
                                                   int32_t ta) {
  int32_t lit_imm;
  int32_t vr;
  int32_t inl;
  int32_t mixed_rc;
  int32_t ptr_rc;
  /**
   * wave297: mixed f32+f64 before commutative/left-assoc (placement not fixed there).
   * Promote f32 side (cvtss2sd) then addsd; typeck result is f64 (f64-before-f32).
   */
  mixed_rc = glue_try_emit_mixed_f32_f64_arith_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta, 4);
  if (mixed_rc == 0)
    return 0;
  if (mixed_rc == -1)
    return -1;
  /**
   * wave642: ptr+int / int+ptr with C pointee scale before integer lit/var paths
   * (those paths raw-add byte offsets).
   */
  ptr_rc = glue_try_emit_ptr_arith_scaled_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta, 0);
  if (ptr_rc == 0)
    return 0;
  if (ptr_rc == -1)
    return -1;
  /** WPO-S3：p.a + p.b 同 VAR 字段求和（cross_ret 等 import struct）。 */
  inl = try_inline_var_field_sum_binop_elf(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (inl != 0)
    return inl < 0 ? -1 : 0;
  if (pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm)) {
    /** 先 emit 右子树再装左字面量到 w1，避免嵌套 MUL 等把 w1 覆盖（如 1+2*3）。 */
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (glue_emit_binop_add_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (glue_emit_binop_add_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  /**
   * 7.3 / wave338: left-assoc dual-slot when right is VAR and left may clobber rbx.
   * Emit left fully (result@rax) then load right@rbx — never leave a stale
   * binop slot-cache hit on rbx after nested mul/sub/… mov_imm→rbx.
   *
   * Prior gate was only left ADD/SUB (same-op chains). Missed cross-op
   * `(n*100)+v`: commutative loaded v→rbx, nested mul did `mov $100,%ebx`
   * without invalidate, cache still claimed rbx=v → Ubuntu freestanding
   * `add %rbx,%rax` used 100 → run=200 (expect 120). Host-C / arm64 hid.
   *
   * Authority (G.7): single left-first path for any left that
   * glue_expr_emit_may_clobber_rbx_elf_c (nested binop/call/index/…); pure
   * VAR+VAR still uses commutative cache path below.
   * PLATFORM: SHARED freestanding emit; LINUX x86_64 exposes; MACOS arm64 may hide.
   */
  if (pipeline_expr_kind_ord_at(arena, right_ref) == GLUE_EXPR_KIND_VAR &&
      glue_expr_emit_may_clobber_rbx_elf_c(arena, left_ref) != 0) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    glue_binop_var_slot_cache_invalidate_rbx();
    glue_asm73_left_assoc_spill_rbx_before_var_load_elf_c(arena, ctx, right_ref, ta, elf_ctx);
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1) != 0)
      return -1;
    if (glue_emit_binop_add_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  vr = glue_try_binop_commutative_rax_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (vr == 0) {
    if (glue_emit_binop_add_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  if (vr == -1)
    return -1;
  if (glue_finish_binop_commutative_slow_rax_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta) != 0)
    return -1;
  if (glue_emit_binop_add_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
    return -1;
  glue_binop_var_slot_cache_invalidate_rax();
  return 0;
}

/**
 * f64 SUB → subsd; f32 SUB → subss; else integer sub.
 * PLATFORM: SHARED arith / LINUX+MACOS x86_64 emit.
 * wave298 Cap residual pure: freestanding f32 `-` used integer sub on IEEE bits → run=0
 * (mac host-gcc hid). G.7: complete next to addss/mulss + subsd family.
 */
static int32_t glue_emit_binop_sub_rbx_minus_rax_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         struct backend_AsmFuncCtx *ctx, int32_t left_ref,
                                                         int32_t right_ref, int32_t ta) {
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref))
    return backend_enc_subsd_rbx_rax_arch(elf_ctx, ta);
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref))
    return backend_enc_subss_rbx_rax_arch(elf_ctx, ta);
  return backend_enc_sub_rbx_rax_then_mov_arch(elf_ctx, ta);
}

int32_t glue_emit_binop_sub_rax_minus_rbx_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         struct backend_AsmFuncCtx *ctx, int32_t left_ref,
                                                         int32_t right_ref, int32_t ta) {
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref))
    return backend_enc_subsd_rax_rbx_arch(elf_ctx, ta);
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref))
    return backend_enc_subss_rax_rbx_arch(elf_ctx, ta);
  /* wave642: assign `p -= n` — left@rax right@rbx; scale integer offset. */
  if (glue_ptr_arith_scale_rbx_offset_if_left_ptr_c(arena, elf_ctx, left_ref, right_ref, ta) != 0)
    return -1;
  return backend_enc_sub_rax_rbx_arch(elf_ctx, ta);
}

/**
 * f64 MUL → mulsd; f32 MUL → mulss; mixed f32*f64 → promote f32 then mulsd; else imul.
 * PLATFORM: SHARED cast/arith semantics / LINUX+MACOS x86_64 emit.
 * wave294 Cap residual pure: freestanding f32 `*` used imul on IEEE bits → run=0
 * (mac host-gcc hid). G.7: complete next to addss path + mulsd family.
 * wave296 Cap residual pure: mixed f32*f64 fell to imul (operands different IEEE
 * widths). Authority: reuse backend_enc_cvtss2sd_rax_from_f32_bits_arch + mulsd;
 * placement of left/right in rax/rbx is not fixed after commutative loads — mixed
 * is handled only via pipeline_asm_emit_binop_mul_elf_c fixed placement path.
 * This helper still accepts mixed when caller has already promoted both to f64 bits
 * in rax/rbx (then both-f64 branch); or pure same-class sides.
 */
int32_t glue_emit_binop_mul_rax_rbx_elf_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   struct backend_AsmFuncCtx *ctx, int32_t left_ref,
                                                   int32_t right_ref, int32_t ta) {
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref))
    return backend_enc_mulsd_rax_rbx_arch(elf_ctx, ta);
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref))
    return backend_enc_mulss_rax_rbx_arch(elf_ctx, ta);
  return backend_enc_imul_rbx_rax_arch(elf_ctx, ta);
}

/**
 * wave296/wave297: freestanding mixed f32/f64 ADD SUB MUL DIV with fixed register placement.
 * Typeck usual arithmetic conversion is f64-before-f32 (result kind f64); emit must
 * promote the f32 side (cvtss2sd, wave293) then use f64 scalar ops - never integer
 * add/sub/imul/idiv on mixed IEEE widths (Ubuntu freestanding run=0; mac host-gcc hides).
 *
 * Placement (matches pure f64 conventions for non-commutative ops):
 *   ADD/MUL (commutative): left=rbx, right=rax then addsd/mulsd rax,rbx
 *   SUB: left=rbx, right=rax then subsd_rbx_rax (left minus right)
 *   DIV: left=rax, right=rbx then divsd_rax_rbx (left / right; IEEE Inf/NaN on /0)
 *
 * @param op_kind EXPR kind_ord: 4=ADD, 5=SUB, 6=MUL, 7=DIV
 * @return 0 ok; -1 emit fail; -2 not mixed (caller falls through to pure paths)
 * PLATFORM: LINUX+MACOS x86_64 emit / SHARED type semantics.
 * G.7: single authority for mixed f32/f64 arith (complete mul leaf; no parallel helpers).
 */
static int32_t glue_try_emit_mixed_f32_f64_arith_elf_c(struct ast_ASTArena *arena,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                        struct backend_AsmFuncCtx *ctx, int32_t left_ref,
                                                        int32_t right_ref, int32_t ta, int32_t op_kind) {
  int32_t lf32;
  int32_t rf32;
  int32_t lf64;
  int32_t rf64;
  int32_t mixed;
  if (ta != 0 || !arena || !elf_ctx || !ctx)
    return -2;
  if (op_kind != 4 && op_kind != 5 && op_kind != 6 && op_kind != 7)
    return -2;
  lf32 = glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref);
  rf32 = glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref);
  lf64 = glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref);
  rf64 = glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref);
  /* Pure same-class: not mixed (caller uses addss/addsd/mulss/mulsd/…). */
  if (lf32 && rf32)
    return -2;
  if (lf64 && rf64 && !lf32 && !rf32)
    return -2;
  mixed = ((lf32 && rf64) || (lf64 && rf32)) ? 1 : 0;
  if (!mixed)
    return -2;

  if (op_kind == 7) {
    /* DIV: left=rax, right=rbx (matches pure f64 divsd path). */
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    /* Promote f32 side(s) to f64 IEEE bits in place. */
    if (lf32) {
      if (backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx, ta) != 0)
        return -1;
    }
    if (rf32) {
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
    }
    if (backend_enc_divsd_rax_rbx_arch(elf_ctx, ta) != 0)
      return -1;
  } else {
    /* ADD/SUB/MUL: left=rbx, right=rax (wave296 mul placement). */
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    /* Promote f32 side to f64 IEEE bits (cvtss2sd authority = wave293 encoder). */
    if (lf32) {
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
    }
    if (rf32) {
      if (backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx, ta) != 0)
        return -1;
    }
    if (op_kind == 4) {
      if (backend_enc_addsd_rax_rbx_arch(elf_ctx, ta) != 0)
        return -1;
    } else if (op_kind == 5) {
      if (backend_enc_subsd_rbx_rax_arch(elf_ctx, ta) != 0)
        return -1;
    } else {
      /* op_kind == 6 MUL */
      if (backend_enc_mulsd_rax_rbx_arch(elf_ctx, ta) != 0)
        return -1;
    }
  }
  glue_binop_var_slot_cache_invalidate_rax();
  return 0;
}

static int32_t pipeline_asm_emit_binop_sub_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   int32_t left_ref, int32_t right_ref, struct backend_AsmFuncCtx *ctx,
                                                   int32_t ta) {
  int32_t lit_imm;
  int32_t mixed_rc;
  int32_t ptr_rc;
  /**
   * wave297: mixed f32-f64 / f64-f32 before lit/var paths (placement not fixed there).
   * Promote f32 side then subsd_rbx_rax (left − right); typeck result f64.
   */
  mixed_rc = glue_try_emit_mixed_f32_f64_arith_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta, 5);
  if (mixed_rc == 0)
    return 0;
  if (mixed_rc == -1)
    return -1;
  /**
   * wave642: ptr-int (scale) / ptr-ptr (byte diff / esz) before integer lit/var paths.
   */
  ptr_rc = glue_try_emit_ptr_arith_scaled_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta, 1);
  if (ptr_rc == 0)
    return 0;
  if (ptr_rc == -1)
    return -1;
  /** 左字面量：先 emit 右子树，再 rbx=左立即数，结果 rbx-rax（如 42-i）。 */
  if (pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    /* wave338: imm→rbx clobbers dual-slot cache. */
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    return glue_emit_binop_sub_rbx_minus_rax_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
  }
  /** 右字面量：rax=左子树，rbx=立即数，结果 rax-rbx（如 i-1）。 */
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    /* wave338: imm→rbx clobbers dual-slot cache. */
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    return glue_emit_binop_sub_rax_minus_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
  }
  {
    int32_t loff;
    int32_t roff;
    loff = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
    roff = glue_var_expr_stack_off_elf_c(arena, ctx, right_ref);
    if (loff >= 0 && roff >= 0) {
      if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, loff, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, roff, ta) != 0)
        return -1;
      return glue_emit_binop_sub_rbx_minus_rax_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
    }
    if (loff >= 0) {
      /** 左 VAR、右复合：先 emit 右子树到 rax，再 rax=i、rbx=右，sub rax-rbx（如 i-(j+k)）。 */
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
        return -1;
      glue_binop_var_slot_cache_invalidate_rax();
      glue_binop_var_slot_cache_invalidate_rbx();
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, loff, ta) != 0)
        return -1;
      return glue_emit_binop_sub_rax_minus_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
    }
    if (roff >= 0) {
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, roff, ta) != 0)
        return -1;
      return glue_emit_binop_sub_rbx_minus_rax_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
    }
  }
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  return glue_emit_binop_sub_rbx_minus_rax_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
}

static int32_t pipeline_asm_emit_binop_mul_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   int32_t left_ref, int32_t right_ref, struct backend_AsmFuncCtx *ctx,
                                                   int32_t ta) {
  int32_t lit_imm;
  int32_t vr;
  int32_t mixed_rc;
  /**
   * wave296/wave297: mixed f32*f64 before commutative/left-assoc (placement not fixed there).
   * Promote f32 side (cvtss2sd) then mulsd; typeck result is f64 (f64-before-f32).
   * Authority: glue_try_emit_mixed_f32_f64_arith_elf_c (G.7 complete arith leaf).
   */
  mixed_rc = glue_try_emit_mixed_f32_f64_arith_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta, 6);
  if (mixed_rc == 0)
    return 0;
  if (mixed_rc == -1)
    return -1;
  /**
   * Integer lit fast path only when neither side is scalar f32/f64
   * (else mulss/mulsd need full IEEE bits in GPRs).
   */
  if (pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm) &&
      !(glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) ||
        glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref) ||
        glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) ||
        glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref))) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    /* wave338: imm→rbx clobbers dual-slot; drop stale VAR cache (G.7 with add lit path). */
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (glue_emit_binop_mul_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm) &&
      !(glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) ||
        glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref) ||
        glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) ||
        glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref))) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    /* wave338: imm→rbx clobbers dual-slot; drop stale VAR cache (G.7 with add lit path). */
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (glue_emit_binop_mul_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  /**
   * 7.3 / wave338: left-assoc mul when right is VAR and left may clobber rbx.
   * Same cross-op rule as add (e.g. (a+b)*c); same-op ((…)*VAR) included.
   */
  if (pipeline_expr_kind_ord_at(arena, right_ref) == GLUE_EXPR_KIND_VAR &&
      glue_expr_emit_may_clobber_rbx_elf_c(arena, left_ref) != 0) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    glue_binop_var_slot_cache_invalidate_rbx();
    glue_asm73_left_assoc_spill_rbx_before_var_load_elf_c(arena, ctx, right_ref, ta, elf_ctx);
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1) != 0)
      return -1;
    if (glue_emit_binop_mul_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  vr = glue_try_binop_commutative_rax_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (vr == 0) {
    if (glue_emit_binop_mul_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  if (vr == -1)
    return -1;
  if (glue_finish_binop_commutative_slow_rax_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta) != 0)
    return -1;
  if (glue_emit_binop_mul_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta) != 0)
    return -1;
  glue_binop_var_slot_cache_invalidate_rax();
  return 0;
}

/**
 * 判定 binop 左操作数是否无符号类型（u8/u32/u64/usize）。
 * 【Why】除法/取模指令须按符号性选择：u32 用 divl（无符号），i32 用 idivl（有符号）。
 *        若用 idivl 处理 u32，0xFFFFFFFF 会被当作 -1，导致 /2 得 0 而非 0x7FFFFFFF。
 * 优先取 left_ref 的 resolved_type_ref；若为空（字面量场景），回退到 right_ref。
 */
int32_t glue_binop_operand_is_unsigned_elf_c(struct ast_ASTArena *arena,
                                                     struct backend_AsmFuncCtx *ctx,
                                                     int32_t left_ref, int32_t right_ref) {
  int32_t tr = 0;
  int32_t kind_ord;
  if (!arena)
    return 0;
  if (left_ref > 0) {
    tr = pipeline_expr_resolved_type_ref(arena, left_ref);
    if (tr <= 0 && ctx)
      tr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
  }
  if (tr <= 0 && right_ref > 0) {
    tr = pipeline_expr_resolved_type_ref(arena, right_ref);
    if (tr <= 0 && ctx)
      tr = glue_var_decl_type_ref_elf_c(arena, ctx, right_ref);
  }
  if (tr <= 0)
    return 0;
  kind_ord = pipeline_type_kind_ord_at(arena, tr);
  /* TYPE_U8=2, TYPE_U32=3, TYPE_U64=4, TYPE_USIZE=6 */
  if (kind_ord == 2 || kind_ord == 3 || kind_ord == 4 || kind_ord == 6)
    return 1;
  return 0;
}

/**
 * 判定 binop 操作数是否 64-bit（u64/i64/usize/isize/ptr）。
 * 【Why】移位/除法须按宽度选择指令：64-bit 用 shlq/divq（REX.W 前缀），32-bit 用 shll/divl。
 *        若用 32-bit 指令处理 i64，移位量被 & 31 截断（1<<40 变成 1<<8）。
 */
int32_t glue_binop_operand_is_64bit_elf_c(struct ast_ASTArena *arena,
                                                  struct backend_AsmFuncCtx *ctx,
                                                  int32_t left_ref, int32_t right_ref) {
  int32_t tr = 0;
  int32_t kind_ord;
  if (!arena)
    return 0;
  if (left_ref > 0) {
    tr = pipeline_expr_resolved_type_ref(arena, left_ref);
    if (tr <= 0 && ctx)
      tr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
  }
  if (tr <= 0 && right_ref > 0) {
    tr = pipeline_expr_resolved_type_ref(arena, right_ref);
    if (tr <= 0 && ctx)
      tr = glue_var_decl_type_ref_elf_c(arena, ctx, right_ref);
  }
  if (tr <= 0)
    return 0;
  kind_ord = pipeline_type_kind_ord_at(arena, tr);
  /* TYPE_U64=4, TYPE_I64=5, TYPE_USIZE=6, TYPE_ISIZE=7, TYPE_PTR=9 */
  if (kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7 || kind_ord == 9)
    return 1;
  return 0;
}

static int32_t pipeline_asm_emit_binop_div_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   int32_t left_ref, int32_t right_ref, struct backend_AsmFuncCtx *ctx,
                                                   int32_t ta) {
  int32_t lit_imm;
  int32_t vr;
  int32_t is_unsigned;
  int32_t mixed_rc;
  /**
   * wave297: mixed f32/f64 before pure-f64/f32 or integer idiv.
   * Promote f32 then divsd; no integer div-zero panic (IEEE Inf/NaN).
   */
  mixed_rc = glue_try_emit_mixed_f32_f64_arith_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta, 7);
  if (mixed_rc == 0)
    return 0;
  if (mixed_rc == -1)
    return -1;
  /** PLATFORM: SHARED — f64 / must use IEEE divsd, not idiv of bit patterns (same residual as mulsd).
   * Skip integer lit imm32 path (truncates float bits) and integer div-zero panic (IEEE → Inf/NaN). */
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref)) {
    vr = glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
    if (vr == -1)
      return -1;
    if (vr == 0)
      return backend_enc_divsd_rax_rbx_arch(elf_ctx, ta);
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    return backend_enc_divsd_rax_rbx_arch(elf_ctx, ta);
  }
  /**
   * wave298 Cap residual pure: pure f32 `/` → divss (not idiv of IEEE bits).
   * Placement left=rax right=rbx matches pure f64 divsd path. IEEE Inf/NaN on /0.
   * G.7: complete f32 scalar arith next to mulss/addss/subss.
   */
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
      glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref)) {
    vr = glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
    if (vr == -1)
      return -1;
    if (vr == 0)
      return backend_enc_divss_rax_rbx_arch(elf_ctx, ta);
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    return backend_enc_divss_rax_rbx_arch(elf_ctx, ta);
  }
  is_unsigned = glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, right_ref);
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (lit_imm == 0)
      return pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta);
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    return is_unsigned ? backend_enc_div_rbx_arch(elf_ctx, ta) : backend_enc_idiv_rbx_arch(elf_ctx, ta);
  }
  vr = glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (vr == -1)
    return -1;
  if (vr == 0) {
    if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0)
      return -1;
    return is_unsigned ? backend_enc_div_rbx_arch(elf_ctx, ta) : backend_enc_idiv_rbx_arch(elf_ctx, ta);
  }
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return is_unsigned ? backend_enc_div_rbx_arch(elf_ctx, ta) : backend_enc_idiv_rbx_arch(elf_ctx, ta);
}

/** 按位与二元运算 ELF 发射（i & 1 等；与 add 同栈序 pop_rbx）。 */
static int32_t pipeline_asm_emit_binop_and_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                 int32_t left_ref, int32_t right_ref, struct backend_AsmFuncCtx *ctx,
                                                 int32_t ta) {
  int32_t lit_imm;
  int32_t vr;
  if (pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (backend_enc_and_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (backend_enc_and_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  /** 7.3 / wave338: left-assoc & when right is VAR and left may clobber rbx. */
  if (pipeline_expr_kind_ord_at(arena, right_ref) == GLUE_EXPR_KIND_VAR &&
      glue_expr_emit_may_clobber_rbx_elf_c(arena, left_ref) != 0) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    glue_binop_var_slot_cache_invalidate_rbx();
    glue_asm73_left_assoc_spill_rbx_before_var_load_elf_c(arena, ctx, right_ref, ta, elf_ctx);
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1) != 0)
      return -1;
    if (backend_enc_and_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  vr = glue_try_binop_commutative_rax_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (vr == 0) {
    if (backend_enc_and_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  if (vr == -1)
    return -1;
  if (glue_finish_binop_commutative_slow_rax_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_and_rbx_rax_arch(elf_ctx, ta) != 0)
    return -1;
  glue_binop_var_slot_cache_invalidate_rax();
  return 0;
}

/** 按位或/异或 ELF 发射（VAR 快速路径 rax/rbx；slow 与历史栈序一致）。 */
static int32_t pipeline_asm_emit_binop_bitwise_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t left_ref,
                                                       int32_t right_ref, struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                       int32_t is_xor) {
  int32_t lit_imm;
  int32_t vr;
  if (pipeline_asm_expr_lit_i32_at_c(arena, left_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (is_xor) {
      if (backend_enc_xor_rbx_rax_arch(elf_ctx, ta) != 0)
        return -1;
    } else if (backend_enc_or_rbx_rax_arch(elf_ctx, ta) != 0) {
      return -1;
    }
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    if (is_xor) {
      if (backend_enc_xor_rbx_rax_arch(elf_ctx, ta) != 0)
        return -1;
    } else if (backend_enc_or_rbx_rax_arch(elf_ctx, ta) != 0) {
      return -1;
    }
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  /** 7.3 / wave338: left-assoc |/^ when right is VAR and left may clobber rbx. */
  if (pipeline_expr_kind_ord_at(arena, right_ref) == GLUE_EXPR_KIND_VAR &&
      glue_expr_emit_may_clobber_rbx_elf_c(arena, left_ref) != 0) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rax();
    glue_binop_var_slot_cache_invalidate_rbx();
    glue_asm73_left_assoc_spill_rbx_before_var_load_elf_c(arena, ctx, right_ref, ta, elf_ctx);
    if (glue_try_binop_load_operand_elf_c(arena, elf_ctx, right_ref, ctx, ta, 1) != 0)
      return -1;
    if (is_xor) {
      if (backend_enc_xor_rbx_rax_arch(elf_ctx, ta) != 0)
        return -1;
    } else if (backend_enc_or_rbx_rax_arch(elf_ctx, ta) != 0) {
      return -1;
    }
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  vr = glue_try_binop_commutative_rax_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (vr == 0) {
    if (is_xor) {
      if (backend_enc_xor_rbx_rax_arch(elf_ctx, ta) != 0)
        return -1;
    } else if (backend_enc_or_rbx_rax_arch(elf_ctx, ta) != 0) {
      return -1;
    }
    glue_binop_var_slot_cache_invalidate_rax();
    return 0;
  }
  if (vr == -1)
    return -1;
  glue_binop_var_slot_cache_clear();
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (is_xor) {
    if (backend_enc_xor_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
  } else if (backend_enc_or_rbx_rax_arch(elf_ctx, ta) != 0) {
    return -1;
  }
  glue_binop_var_slot_cache_clear();
  return 0;
}

/**
 * Freestanding shift binop ELF: value@rax/w0, count@rbx/w1, then count→cl/w2.
 *
 * op: 0=shl, 1=right shift (signed → SAR / asr; unsigned → SHR / lsr).
 *
 * wave648 Cap residual pure: EXPR_SHR always emitted logical SHR even for
 * signed i32/i64 → freestanding `-16 >> 2` became 0x3ffffffc (host-C SAR
 * green; cmp to -4 fs=0; pure may CTFE-fold). Encoders already had
 * backend_enc_sar_cl_{eax,rax}_arch (wave306 arm64 64-bit asr).
 *
 * G.7: single authority — reuse glue_binop_operand_is_unsigned_elf_c
 * (same as div/rem) + is_64bit; do not open a second shift path.
 * PLATFORM: SHARED freestanding · LINUX x86 sar · MACOS|ARM64 asr co-path.
 */
static int32_t pipeline_asm_emit_binop_shift_elf_c(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t left_ref,
                                                    int32_t right_ref, struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                    int32_t op) {
  int32_t lit_imm;
  int32_t vr;
  int32_t is_64bit;
  int32_t is_unsigned;
  /* i64/u64/usize/isize/ptr need 64-bit shift forms (REX.W / sf=1). */
  is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, right_ref);
  /* Left operand width decides arithmetic vs logical right shift. */
  is_unsigned = glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, right_ref);
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
  } else {
    vr = glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
    if (vr == -1)
      return -1;
    if (vr == -2) {
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
    }
  }
  glue_binop_var_slot_cache_clear();
  if (backend_enc_mov_rbx_to_ecx_arch(elf_ctx, ta) != 0)
    return -1;
  if (op == 0)
    return is_64bit ? backend_enc_shl_cl_rax_arch(elf_ctx, ta) : backend_enc_shl_cl_eax_arch(elf_ctx, ta);
  /* op==1 right shift: signed arithmetic, unsigned logical. */
  if (is_unsigned)
    return is_64bit ? backend_enc_shr_cl_rax_arch(elf_ctx, ta) : backend_enc_shr_cl_eax_arch(elf_ctx, ta);
  return is_64bit ? backend_enc_sar_cl_rax_arch(elf_ctx, ta) : backend_enc_sar_cl_eax_arch(elf_ctx, ta);
}

static int32_t pipeline_asm_emit_binop_mod_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   int32_t left_ref, int32_t right_ref, struct backend_AsmFuncCtx *ctx,
                                                   int32_t ta) {
  int32_t lit_imm;
  int32_t vr;
  int32_t is_unsigned;
  is_unsigned = glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, right_ref);
  if (pipeline_asm_expr_lit_i32_at_c(arena, right_ref, &lit_imm)) {
    if (lit_imm == 0)
      return pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta);
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    glue_binop_var_slot_cache_invalidate_rbx();
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, lit_imm, ta) != 0)
      return -1;
    return is_unsigned ? backend_enc_rem_mod_unsigned_arch(elf_ctx, ta) : backend_enc_rem_mod_arch(elf_ctx, ta);
  }
  vr = glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  if (vr == -1)
    return -1;
  if (vr == 0) {
    if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0)
      return -1;
    return is_unsigned ? backend_enc_rem_mod_unsigned_arch(elf_ctx, ta) : backend_enc_rem_mod_arch(elf_ctx, ta);
  }
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return is_unsigned ? backend_enc_rem_mod_unsigned_arch(elf_ctx, ta) : backend_enc_rem_mod_arch(elf_ctx, ta);
}
