/**
 * pipeline_asm_emit_index_eff_addr.c — asm ELF INDEX effective-address
 * scaled domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding INDEX address emission
 * that face emitters and the try_index forest depend on:
 * - glue_emit_index_rax_plus_rbx_scaled_elf_c (base@rax + index@rbx * esz)
 * - glue_emit_index_var_base_to_rax_elf_c / glue_emit_index_add_index_to_base_rax_elf_c
 * - glue_try_index_base_rax_index_rbx_elf_c + slow finish push path
 * - glue_emit_slice_length_to_rbx_elf_c + glue_emit_index_bounds_guard_elf_c
 * - glue_try_index_rvalue_slice_once_elf_c (CALL/METHOD TYPE_SLICE once)
 * - glue_emit_index_eff_addr_scaled_elf_c (full scaled INDEX address entry)
 * - glue_arch_emit_local_slot_ptr_or_addr_text_c (text twin of local slot ptr/addr)
 * - glue_emit_index_eff_addr_base_{elf,text}_c + public pipeline_asm_emit_index_eff_addr_{elf,text}_c
 *
 * G.7: single product-mega INDEX scaled-eff-addr face — do not open a second
 * bounds-guard or rax+rbx*esz path, and do not re-open base/public INDEX
 * eff-addr twins outside this leaf. try_index forest + lvalue_eff_addr_{elf,text}
 * stay in pipeline_asm_emit_index_helpers.c (text folded wave1013; calls
 * local_slot_text + index_eff_addr_text here via same-TU forward decls);
 * face emitters stay in pipeline_asm_emit_index.c / assign.
 *
 * Callers: pipeline_asm_emit_index.c; assign INDEX lhs; index_helpers try_index;
 * spill index_assign residual (via forward decl); lvalue text INDEX arm;
 * backend/M8-tail thin wrappers.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c in place of
 * the former residual body (after binop load helpers / spill; before lit_i32 +
 * expr_rec).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 *   · LINUX+MACOS x86_64 SysV — imul/lea scale + bounds jl/jge
 *   · MACOS|ARM64 AAPCS64 — mul/add + bounds twin
 */

/* Forward decls / callees defined elsewhere in the same TU:
 * - glue_try_index_var_or_field_base_to_rax_elf_c / try_index_* forest
 *   (pipeline_asm_emit_index_helpers.c)
 * - glue_try_index_var_{mul,plus,minus}_* _eff_addr_rax_elf_c (index_helpers)
 * - pipeline_asm_emit_expr_elf_rec / pipeline_asm_expr_lit_i32_at_c (expr_rec leaf; after this include)
 * - pipeline_asm_emit_expr_c / backend_arch_emit_* text twins (text public path)
 * - glue_index_deref_ptr_field_slot_rax_elf_c / glue_enc_local_slot_ptr_or_addr_elf_c
 * - glue_field_access_effective_offset_c / glue_var_expr_type_ref_with_decl_fallback_c
 * - pipeline_asm_emit_panic_int_div_zero_elf_c (panic face)
 * - glue_binop_preserve/restore_rax_* (binop residual helpers)
 * - glue_var_expr_stack_off_elf_c / backend_enc_* / asm_ctx_local_*
 * - g_pipeline_asm_emit_module
 */

/**
 * INDEX scale 加：base 在 rax、index 在 rbx → rax += rbx*esz。
 * esz 非 1/4/8（如 12B struct）时 imul+add，勿误用 lea scale8。
 */
static int32_t glue_emit_index_rax_plus_rbx_scaled_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t esz,
                                                          int32_t ta) {
  if (esz == 1)
    return backend_enc_rax_plus_rbx_scale1_arch(elf_ctx, ta);
  if (esz == 4)
    return backend_enc_rax_plus_rbx_scale4_arch(elf_ctx, ta);
  if (esz == 8)
    return backend_enc_rax_plus_rbx_scale8_arch(elf_ctx, ta);
  if (backend_enc_mul_imm_to_rbx_arch(elf_ctx, esz, ta) != 0)
    return -1;
  return backend_enc_add_rax_rbx_arch(elf_ctx, ta);
}

/** 局部 VAR / VAR-base FIELD 数组基底 → rax（lea 或 load ptr）。 */
static int32_t glue_emit_index_var_base_to_rax_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                       int32_t base_ref, struct backend_AsmFuncCtx *ctx,
                                                       int32_t ta) {
  return glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
}

/**
 * 7.3：INDEX — base 已在 rax，index 装入 rbx 并 scale 加；0=OK，-1=错。
 */
static int32_t glue_emit_index_add_index_to_base_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t idx_ref, struct backend_AsmFuncCtx *ctx,
                                                            int32_t ta, int32_t esz) {
  int32_t ioff;
  if (!arena || !elf_ctx || !ctx)
    return -1;
  ioff = glue_var_expr_stack_off_elf_c(arena, ctx, idx_ref);
  if (ioff >= 0) {
    if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, ioff, ta) != 0)
      return -1;
  } else {
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, idx_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
  }
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * 7.3：INDEX 有效地址 — base→rax、index→rbx 后 scale 加；0=OK，-1=错，-2=需 push slow。
 */
static int32_t glue_try_index_base_rax_index_rbx_elf_c(struct ast_ASTArena *arena,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                        int32_t base_ref, int32_t idx_ref,
                                                        struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t ioff;
  int32_t br;
  if (!arena || !elf_ctx || !ctx)
    return -2;
  ioff = glue_var_expr_stack_off_elf_c(arena, ctx, idx_ref);
  if (ioff >= 0) {
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br == 0)
      return backend_enc_load_rbp_to_rbx_arch(elf_ctx, ioff, ta) != 0 ? -1 : 0;
    if (br == -1)
      return -1;
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, base_ref, ctx, ta) != 0)
      return -1;
    return backend_enc_load_rbp_to_rbx_arch(elf_ctx, ioff, ta) != 0 ? -1 : 0;
  }
  br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
  if (br == 0) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, idx_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
    return 0;
  }
  if (br == -1)
    return -1;
  return -2;
}

/** slow：base/index 各 emit 后 push 保 base（历史栈序）。 */
static int32_t glue_finish_index_base_rax_index_rbx_slow_elf_c(struct ast_ASTArena *arena,
                                                                  struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                  int32_t base_ref, int32_t idx_ref,
                                                                  struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t base_ko;
  base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
  if (base_ko == 3) {
    int32_t off;
    uint8_t vname[128];
    int32_t vlen;
    vlen = pipeline_expr_var_name_len(arena, base_ref);
    if (vlen <= 0 || vlen > 127)
      return -1;
    pipeline_expr_var_name_into(arena, base_ref, vname);
    off = asm_ctx_local_find_offset((uint8_t *)ctx, vname, vlen);
    if (off < 0)
      return -1;
    if (glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, base_ref, off, ctx, ta) != 0)
      return -1;
  } else if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, base_ref, ctx, ta) != 0) {
    return -1;
  }
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, idx_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return 0;
}

/**
 * Slice base length → rbx ({data,length} home, *slice param, or dual-GP call rvalue).
 *
 * PLATFORM: SHARED fat layout; LINUX/MACOS SysV / AAPCS64:
 * - Local dual-GP home: data @ off, length @ glue_slice_dual_gp_length_off_c(off,ta)
 *   (wave394: arm64 +8 / x86 -8; C fat memory order)
 * - slice* param: load fat*, then length at +8
 * - CALL/METHOD_CALL returning TYPE_SLICE: freestanding dual-GP data@rax length@rdx
 *   (wave333/335 return emit). Do NOT treat rax as fat* (+8 deref) — that was wave336
 *   soft residual take()[1] panic (bounds length garbage).
 *
 * Bounds guard holds index in rax; any emit of base that clobbers rax must push/pop.
 * G.7: single authority for slice length for INDEX bounds (no parallel path).
 */
static int32_t glue_emit_slice_length_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                    struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t base_ref) {
  int32_t base_ko;
  uint8_t vname[128];
  int32_t vlen;
  int32_t off;
  int32_t bty;

  base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
  if (base_ko == 3) {
    vlen = pipeline_expr_var_name_len(arena, base_ref);
    if (vlen <= 0 || vlen > 127)
      return -1;
    pipeline_expr_var_name_into(arena, base_ref, vname);
    off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
    if (off < 0)
      off = asm_ctx_local_find_offset((uint8_t *)ctx, vname, vlen);
    if (off < 0)
      return -1;
    if (glue_local_var_slot_needs_ptr_load_elf_c(arena, base_ref, off, ctx) != 0) {
      /*
       * wave332d: preserve rax (INDEX has index in rax when loading length to rbx).
       * Prior path load_rbp→rax clobbered the index → upper-bound cmp used length vs
       * length-1 → always panic (Ubuntu freestanding a[0] after slice* param fix).
       * G.7: push/pop around the pointer chase; dual-GP path already loads straight to rbx.
       * PLATFORM: SHARED freestanding · LINUX gold.
       */
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta) != 0)
        return -1;
      if (backend_enc_add_imm_to_rax_arch(elf_ctx, 8, ta) != 0)
        return -1;
      if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
      return 0;
    }
    /* wave394: arch-aware dual-GP length half (matches slice_from_array_let_init). */
    return backend_enc_load_rbp_to_rbx_arch(elf_ctx, glue_slice_dual_gp_length_off_c(off, ta), ta);
  }

  /*
   * wave336 Cap residual pure: non-VAR slice base (esp. CALL take()[1]).
   * Index is live in rax (bounds guard). Emit base may clobber rax/rdx.
   * TYPE_SLICE CALL/METHOD_CALL return is dual-GP (needs_rax_deref=0): length@rdx.
   * Else historical fat* in rax: length at [rax+8].
   * PLATFORM: SHARED freestanding · LINUX gold (host-C uses C codegen INDEX).
   */
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, base_ref, ctx, ta) != 0)
    return -1;
  bty = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (bty > 0 && pipeline_type_kind_ord_at(arena, bty) == (int32_t)ast_TypeKind_TYPE_SLICE &&
      (base_ko == 48 || base_ko == 49) &&
      (base_ko != 48 || glue_call_struct16_ret_needs_rax_deref_c(arena, base_ref) == 0)) {
    /* SysV arg_reg 2 = rdx — length half after dual-GP return. */
    if (backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, 2, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  if (backend_enc_add_imm_to_rax_arch(elf_ctx, 8, ta) != 0)
    return -1;
  if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return 0;
}

/**
 * UB 收窄：定长数组 / 切片下标越界时发射 xlang_panic_(1,0)（与 C codegen 一致）。
 * ix_ref：INDEX expr ref（读 proven_in_bounds / base_is_slice）；<=0 时仍按 base 类型检查。
 */
static int32_t glue_emit_index_bounds_guard_elf_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t ix_ref,
                                                   int32_t base_ref, int32_t idx_ref) {
  struct ast_Expr *ix;
  int32_t base_ty;
  int32_t bt_kind;
  int32_t is_slice;
  int32_t lit_idx;
  int32_t array_sz;
  uint8_t ok_lo[128];
  uint8_t ok_hi[128];
  int32_t ok_lo_len;
  int32_t ok_hi_len;

  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return 0;

  if (ix_ref > 0) {
    ix = pipeline_arena_expr_ptr(arena, ix_ref);
    if (ix && ix->index_proven_in_bounds != 0)
      return 0;
    is_slice = (ix && ix->index_base_is_slice != 0) ? 1 : 0;
  } else {
    is_slice = 0;
  }

  base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (base_ty <= 0)
    return 0;
  bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
  if (is_slice == 0 && bt_kind == (int32_t)ast_TypeKind_TYPE_SLICE)
    is_slice = 1;
  if (is_slice == 0 && bt_kind != (int32_t)ast_TypeKind_TYPE_ARRAY)
    return 0;

  if (pipeline_asm_expr_lit_i32_at_c(arena, idx_ref, &lit_idx)) {
    if (lit_idx < 0)
      return pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta);
    if (is_slice == 0) {
      array_sz = pipeline_type_array_size_at(arena, base_ty);
      if (array_sz > 0 && lit_idx >= array_sz)
        return pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta);
      return 0;
    }
  }

  ok_lo_len = pipeline_asm_emit_next_label_c(ctx, ok_lo, 64);
  ok_hi_len = pipeline_asm_emit_next_label_c(ctx, ok_hi, 64);
  if (ok_lo_len <= 0 || ok_hi_len <= 0)
    return -1;

  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, idx_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, 0, ta) != 0)
    return -1;
  if (backend_enc_cmp_rax_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jge_arch(elf_ctx, ok_lo, ok_lo_len, ta) != 0)
    return -1;
  if (pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, ok_lo, ok_lo_len, 0, ta) != 0)
    return -1;

  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, idx_ref, ctx, ta) != 0)
    return -1;
  if (is_slice != 0) {
    if (glue_emit_slice_length_to_rbx_elf_c(arena, elf_ctx, ctx, ta, base_ref) != 0)
      return -1;
    if (backend_enc_add_imm_to_rbx_arch(elf_ctx, -1, ta) != 0)
      return -1;
  } else {
    array_sz = pipeline_type_array_size_at(arena, base_ty);
    if (array_sz <= 0)
      return 0;
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, array_sz - 1, ta) != 0)
      return -1;
  }
  if (backend_enc_cmp_rbx_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jge_arch(elf_ctx, ok_hi, ok_hi_len, ta) != 0)
    return -1;
  if (pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, ok_hi, ok_hi_len, 0, ta) != 0)
    return -1;
  return 0;
}

/**
 * wave337 Cap residual pure: call-as-INDEX base evaluated once.
 *
 * Root: glue_emit_index_bounds_guard → glue_emit_slice_length_to_rbx emits CALL base
 * for length@rdx, then lit/scaled path emits base again for data@rax → take()[1]
 * double-eval (side effects / cost). Local VAR slice homes already single-eval.
 *
 * G.7 authority: materialize TYPE_SLICE CALL/METHOD_CALL dual-GP (data@rax length@rdx)
 * or fat* return into one dual-GP temp {data@home, length@home-8}, then bounds+addr
 * only load the temp — no second emit of base. Complements wave336 length@rdx.
 *
 * @return 0 handled (eff addr in rax), -2 not applicable, -1 error
 * PLATFORM: SHARED freestanding · LINUX gold (host-C uses C codegen INDEX).
 */
static int32_t glue_try_index_rvalue_slice_once_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ix_ref,
                                                       int32_t base_ref, int32_t idx_ref,
                                                       struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t esz) {
  int32_t base_ko;
  int32_t bty;
  int32_t dual_gp;
  int32_t home;
  int32_t base_off;
  pipeline_glue_AsmFuncCtxLayout *ly;
  struct ast_Expr *ix;
  int32_t proven;
  int32_t lit_idx;
  int32_t ok_lo_len;
  int32_t ok_hi_len;
  uint8_t ok_lo[128];
  uint8_t ok_hi[128];

  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
  /*
   * CALL=48 METHOD_CALL=49 — rvalues that re-emit full base for length+data.
   * wave692: INDEX=47 base with TYPE_SLICE result (nested `rows[i][j]`) also
   * materializes dual-GP once — outer INDEX loads fat→data@rax length@rdx
   * (emit_index TYPE_SLICE arm); re-emitting for length path would double-eval
   * and the non-CALL length path assumes fat* not dual-GP.
   */
  if (base_ko != 48 && base_ko != 49 && base_ko != 47)
    return -2;
  bty = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (bty <= 0 || pipeline_type_kind_ord_at(arena, bty) != (int32_t)ast_TypeKind_TYPE_SLICE)
    return -2;
  /*
   * dual-GP: freestanding TYPE_SLICE return (wave333/335); CALL only when
   * needs_rax_deref==0. METHOD_CALL TYPE_SLICE treated as dual-GP (wave336).
   * wave692: INDEX of nested outer yields dual-GP (emit_index TYPE_SLICE load).
   * Else fat* in rax (length at [rax+8], data at [rax]).
   */
  dual_gp = 0;
  if (base_ko == 49 || base_ko == 47)
    dual_gp = 1;
  else if (base_ko == 48 && glue_call_struct16_ret_needs_rax_deref_c(arena, base_ref) == 0)
    dual_gp = 1;

  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  base_off = ly->next_offset;
  if ((base_off % 8) != 0)
    base_off = (base_off + 7) / 8 * 8;
  /* data@home + arch-aware length half — same dual-GP home as let/call-arg slice. */
  home = base_off + 16;
  ly->next_offset = (ta == 1) ? (home + 16) : (home + 8);
  glue_align_next_offset(ctx);

  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, base_ref, ctx, ta) != 0)
    return -1;
  if (dual_gp != 0) {
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
      return -1;
    if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta) != 0)
      return -1;
  } else {
    /* fat*: rax → struct { data, length }; spill both halves into dual-GP home. */
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, 8, ta) != 0)
      return -1;
    if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
      return -1;
  }

  /* Bounds from materialized length only (no second base emit). */
  proven = 0;
  if (ix_ref > 0) {
    ix = pipeline_arena_expr_ptr(arena, ix_ref);
    if (ix && ix->index_proven_in_bounds != 0)
      proven = 1;
  }
  if (proven == 0) {
    if (pipeline_asm_expr_lit_i32_at_c(arena, idx_ref, &lit_idx)) {
      if (lit_idx < 0)
        return pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta);
    }
    ok_lo_len = pipeline_asm_emit_next_label_c(ctx, ok_lo, 64);
    ok_hi_len = pipeline_asm_emit_next_label_c(ctx, ok_hi, 64);
    if (ok_lo_len <= 0 || ok_hi_len <= 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, idx_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, 0, ta) != 0)
      return -1;
    if (backend_enc_cmp_rax_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_jge_arch(elf_ctx, ok_lo, ok_lo_len, ta) != 0)
      return -1;
    if (pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_label_arch(elf_ctx, ok_lo, ok_lo_len, 0, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, idx_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta) != 0)
      return -1;
    if (backend_enc_add_imm_to_rbx_arch(elf_ctx, -1, ta) != 0)
      return -1;
    if (backend_enc_cmp_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_jge_arch(elf_ctx, ok_hi, ok_hi_len, ta) != 0)
      return -1;
    if (pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_label_arch(elf_ctx, ok_hi, ok_hi_len, 0, ta) != 0)
      return -1;
  }

  /* Effective address: data@home + index * esz → rax. */
  if (pipeline_asm_expr_lit_i32_at_c(arena, idx_ref, &lit_idx)) {
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
      return -1;
    if (lit_idx != 0 && esz != 0) {
      int32_t off = lit_idx * esz;
      if (off != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, off, ta) != 0)
        return -1;
    }
    return 0;
  }
  /* Non-lit: after bounds, index is in rax; move to rbx then load data. */
  if (proven != 0) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, idx_ref, ctx, ta) != 0)
      return -1;
  }
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 有效地址完整发射：try 7.3 快速路径，否则 slow push。
 */
/* wave140 pure leave Cap residual: was static; pure index/addr_of links here. PLATFORM: SHARED. */
int32_t glue_emit_index_eff_addr_scaled_elf_c(struct ast_ASTArena *arena,
                                              struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ix_ref,
                                              int32_t base_ref, int32_t idx_ref, struct backend_AsmFuncCtx *ctx,
                                              int32_t ta, int32_t esz) {
  int32_t vr;
  int32_t lit_imm;
  int32_t once_rc;

  /* wave337: CALL/METHOD TYPE_SLICE base — materialize once before bounds+load. */
  once_rc = glue_try_index_rvalue_slice_once_elf_c(arena, elf_ctx, ix_ref, base_ref, idx_ref, ctx, ta, esz);
  if (once_rc == 0)
    return 0;
  if (once_rc == -1)
    return -1;

  if (glue_emit_index_bounds_guard_elf_c(arena, elf_ctx, ctx, ta, ix_ref, base_ref, idx_ref) != 0)
    return -1;
  /** 字面量下标：base→rax 后 add imm*esz，免 rbx 缩放（7.3 活跃性）。 */
  if (pipeline_asm_expr_lit_i32_at_c(arena, idx_ref, &lit_imm)) {
    {
      int32_t br;
      br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
      if (br == -2) {
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, base_ref, ctx, ta) != 0)
          return -1;
      } else if (br != 0) {
        return -1;
      }
    }
    if (lit_imm != 0 || esz != 0) {
      int32_t off;
      off = lit_imm * esz;
      if (off != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, off, ta) != 0)
        return -1;
    }
    return 0;
  }
  {
    int32_t mr;
    mr = glue_try_index_var_mul_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (mr == 0)
      return 0;
    if (mr == -1)
      return -1;
  }
  {
    int32_t pr;
    pr = glue_try_index_var_plus_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (pr == 0)
      return 0;
    if (pr == -1)
      return -1;
  }
  {
    int32_t mr2;
    mr2 = glue_try_index_var_minus_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (mr2 == 0)
      return 0;
    if (mr2 == -1)
      return -1;
  }
  {
    int32_t pvr;
    pvr = glue_try_index_var_plus_var_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (pvr == 0)
      return 0;
    if (pvr == -1)
      return -1;
  }
  {
    int32_t mvr;
    mvr = glue_try_index_var_minus_var_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (mvr == 0)
      return 0;
    if (mvr == -1)
      return -1;
  }
  {
    int32_t mvr2;
    mvr2 = glue_try_index_var_mul_var_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (mvr2 == 0)
      return 0;
    if (mvr2 == -1)
      return -1;
  }
  {
    int32_t pvv;
    pvv = glue_try_index_var_plus_var_plus_var_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (pvv == 0)
      return 0;
    if (pvv == -1)
      return -1;
  }
  {
    int32_t mvp;
    mvp = glue_try_index_var_minus_var_plus_var_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (mvp == 0)
      return 0;
    if (mvp == -1)
      return -1;
  }
  {
    int32_t mvm;
    mvm = glue_try_index_var_minus_var_minus_var_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (mvm == 0)
      return 0;
    if (mvm == -1)
      return -1;
  }
  {
    int32_t ma3;
    ma3 = glue_try_index_var_minus_add3_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (ma3 == 0)
      return 0;
    if (ma3 == -1)
      return -1;
  }
  {
    int32_t pvm;
    pvm = glue_try_index_var_plus_var_mul_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (pvm == 0)
      return 0;
    if (pvm == -1)
      return -1;
  }
  {
    int32_t mvl;
    mvl = glue_try_index_var_minus_var_mul_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (mvl == 0)
      return 0;
    if (mvl == -1)
      return -1;
  }
  {
    int32_t a3m;
    a3m = glue_try_index_var_add3_mul_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (a3m == 0)
      return 0;
    if (a3m == -1)
      return -1;
  }
  {
    int32_t sa3m;
    sa3m = glue_try_index_var_subadd3_mul_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (sa3m == 0)
      return 0;
    if (sa3m == -1)
      return -1;
  }
  {
    int32_t ss3m;
    ss3m = glue_try_index_var_subsub3_mul_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (ss3m == 0)
      return 0;
    if (ss3m == -1)
      return -1;
  }
  {
    int32_t ma3m;
    ma3m = glue_try_index_var_minus_add3_mul_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (ma3m == 0)
      return 0;
    if (ma3m == -1)
      return -1;
  }
  vr = glue_try_index_base_rax_index_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta);
  if (vr == -1)
    return -1;
  if (vr == -2) {
    if (glue_finish_index_base_rax_index_rbx_slow_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta) != 0)
      return -1;
  }
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * text 路径：局部 VAR 槽地址（*T/T[N] load 指针，其余 lea 栈槽）。
 */
static int32_t glue_arch_emit_local_slot_ptr_or_addr_text_c(struct ast_ASTArena *arena,
                                                            struct codegen_CodegenOutBuf *out, int32_t var_expr_ref,
                                                            int32_t stack_off, struct backend_AsmFuncCtx *ctx,
                                                            int32_t ta) {
  if (asm_local_var_slot_holds_indirect_ptr(arena, var_expr_ref, g_pipeline_asm_emit_module, (uint8_t *)ctx) != 0)
    return backend_arch_emit_load_rbp_to_rax(out, stack_off, ta);
  return backend_arch_emit_lea_rbp_to_rax(out, stack_off, ta);
}

/**
 * INDEX 左值 base 有效地址入 rax/x0（ELF）；与 backend.x 原 emit_index_eff_addr_elf 语义一致。
 */
static int32_t glue_emit_index_eff_addr_base_elf_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ix_ref,
                                                   struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t base_ref;
  int32_t base_ko;
  int32_t tr;
  base_ref = pipeline_expr_index_base_ref(arena, ix_ref);
  if (base_ref <= 0)
    return -1;
  base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
  if (base_ko == 44 && pipeline_expr_field_access_is_enum_variant(arena, base_ref) == 0) {
    int32_t fb_ref;
    int32_t field_off;
    fb_ref = pipeline_expr_field_access_base_ref(arena, base_ref);
    field_off = glue_field_access_effective_offset_c(arena, g_pipeline_asm_emit_module, base_ref);
    if (fb_ref > 0 && pipeline_expr_kind_ord_at(arena, fb_ref) == 3) {
      uint8_t vname[128];
      int32_t vlen;
      int32_t off;
      vlen = pipeline_expr_var_name_len(arena, fb_ref);
      if (vlen <= 0 || vlen > 127)
        return -1;
      pipeline_expr_var_name_into(arena, fb_ref, vname);
      off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
      if (off < 0)
        return -1;
      if (glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, fb_ref, off, ctx, ta) != 0)
        return -1;
    } else {
      if (fb_ref <= 0)
        return -1;
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, fb_ref, ctx, ta) != 0)
        return -1;
    }
    if (field_off != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, field_off, ta) != 0)
      return -1;
    if (glue_index_deref_ptr_field_slot_rax_elf_c(arena, elf_ctx, base_ref, ta) != 0)
      return -1;
  } else if (base_ko == 3) {
    uint8_t vname[128];
    int32_t vlen;
    int32_t off;
    vlen = pipeline_expr_var_name_len(arena, base_ref);
    if (vlen <= 0 || vlen > 127)
      return -1;
    pipeline_expr_var_name_into(arena, base_ref, vname);
    off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
    if (off < 0)
      return -1;
    if (glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, base_ref, off, ctx, ta) != 0)
      return -1;
  } else if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, base_ref, ctx, ta) != 0) {
    return -1;
  }
  tr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
  if (tr <= 0)
    tr = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == GLUE_TYPE_KIND_SLICE) {
    if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
      return -1;
  } else if (base_ko == 44) {
    if (glue_index_deref_ptr_field_slot_rax_elf_c(arena, elf_ctx, base_ref, ta) != 0)
      return -1;
  }
  return 0;
}

/**
 * INDEX 左值 base 有效地址入 rax/x0（text）；与 ELF 路径对称。
 */
static int32_t glue_emit_index_eff_addr_base_text_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                    int32_t ix_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t base_ref;
  int32_t base_ko;
  int32_t tr;
  base_ref = pipeline_expr_index_base_ref(arena, ix_ref);
  if (base_ref <= 0)
    return -1;
  base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
  if (base_ko == 44 && pipeline_expr_field_access_is_enum_variant(arena, base_ref) == 0) {
    int32_t fb_ref;
    int32_t field_off;
    fb_ref = pipeline_expr_field_access_base_ref(arena, base_ref);
    field_off = glue_field_access_effective_offset_c(arena, g_pipeline_asm_emit_module, base_ref);
    if (fb_ref > 0 && pipeline_expr_kind_ord_at(arena, fb_ref) == 3) {
      uint8_t vname[128];
      int32_t vlen;
      int32_t off;
      vlen = pipeline_expr_var_name_len(arena, fb_ref);
      if (vlen <= 0 || vlen > 127)
        return -1;
      pipeline_expr_var_name_into(arena, fb_ref, vname);
      off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
      if (off < 0)
        return -1;
      if (glue_arch_emit_local_slot_ptr_or_addr_text_c(arena, out, fb_ref, off, ctx, ta) != 0)
        return -1;
    } else {
      if (fb_ref <= 0)
        return -1;
      if (pipeline_asm_emit_expr_c(arena, out, fb_ref, ctx, ta) != 0)
        return -1;
    }
    if (field_off != 0 && backend_arch_emit_add_imm_to_rax(out, field_off, ta) != 0)
      return -1;
  } else if (base_ko == 3) {
    uint8_t vname[128];
    int32_t vlen;
    int32_t off;
    vlen = pipeline_expr_var_name_len(arena, base_ref);
    if (vlen <= 0 || vlen > 127)
      return -1;
    pipeline_expr_var_name_into(arena, base_ref, vname);
    off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
    if (off < 0)
      return -1;
    if (glue_arch_emit_local_slot_ptr_or_addr_text_c(arena, out, base_ref, off, ctx, ta) != 0)
      return -1;
  } else if (pipeline_asm_emit_expr_c(arena, out, base_ref, ctx, ta) != 0) {
    return -1;
  }
  tr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
  if (tr <= 0)
    tr = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == GLUE_TYPE_KIND_SLICE) {
    if (backend_arch_emit_load_64_from_rax(out, ta) != 0)
      return -1;
  }
  return 0;
}

/**
 * INDEX 左值有效地址 ELF（ix_ref 替代 Expr 按值；M8-tail 薄包装 bl 目标）。
 */
int32_t pipeline_asm_emit_index_eff_addr_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                               int32_t ix_ref, struct backend_AsmFuncCtx *ctx, int32_t ta,
                                               int32_t elem_sz) {
  int32_t idx_ref;
  if (!arena || !elf_ctx || !ctx || ix_ref <= 0)
    return -1;
  idx_ref = pipeline_expr_index_index_ref(arena, ix_ref);
  if (pipeline_expr_index_base_ref(arena, ix_ref) <= 0 || idx_ref <= 0)
    return -1;
  if (glue_emit_index_eff_addr_base_elf_c(arena, elf_ctx, ix_ref, ctx, ta) != 0)
    return -1;
  return glue_emit_index_add_index_to_base_rax_elf_c(arena, elf_ctx, idx_ref, ctx, ta, elem_sz);
}

/**
 * INDEX 左值有效地址 text（ix_ref 替代 Expr 按值；M8-tail 薄包装 bl 目标）。
 */
int32_t pipeline_asm_emit_index_eff_addr_text_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                int32_t ix_ref, struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                int32_t elem_sz) {
  int32_t idx_ref;
  if (!arena || !out || !ctx || ix_ref <= 0)
    return -1;
  idx_ref = pipeline_expr_index_index_ref(arena, ix_ref);
  if (pipeline_expr_index_base_ref(arena, ix_ref) <= 0 || idx_ref <= 0)
    return -1;
  if (glue_emit_index_eff_addr_base_text_c(arena, out, ix_ref, ctx, ta) != 0)
    return -1;
  if (backend_arch_emit_push_rax(out, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_c(arena, out, idx_ref, ctx, ta) != 0)
    return -1;
  if (backend_arch_emit_mov_rax_to_rbx(out, ta) != 0)
    return -1;
  if (backend_arch_emit_pop_rax(out, ta) != 0)
    return -1;
  if (elem_sz == 1)
    return backend_arch_emit_rax_plus_rbx_scale1(out, ta);
  if (elem_sz == 8)
    return backend_arch_emit_rax_plus_rbx_scale8(out, ta);
  return backend_arch_emit_rax_plus_rbx_scale4(out, ta);
}

