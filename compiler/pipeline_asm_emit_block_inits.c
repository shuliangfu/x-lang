/**
 * pipeline_asm_emit_block_inits.c — asm ELF block const/let init emit domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding block-level const/let
 * ELF init emit:
 * - pipeline_asm_emit_block_inits_elf_c (const + let loops; TYPE_VECTOR /
 *   TYPE_SLICE / fixed-array / struct let inits; empty-array dual-GP)
 * - lazy local registration for stmt_order==0 paths
 * - f32→f64 promote on scalar let store
 *
 * G.7: single product-mega block_inits ELF path — do not open a second
 * block const/let init emitter in seed partial or a parallel glue copy.
 * Callers (func body emit / mega_body) call this entry (same TU).
 *
 * wave1024 G.7 fold: TYPE_SLICE dual-GP helpers + slice_from_array let-init
 * moved here from glue residual (same TU; no new DEPS):
 * - glue_slice_dual_gp_length_off_c (arch-aware length half offset)
 * - glue_slice_dual_gp_bump_past_home_c (advance next_offset past fat home)
 * - glue_emit_slice_from_array_let_init_elf_c (ARRAY_LIT / VAR / FIELD → slice)
 * Shared with call_args leaf (slice_let_reent_deep_copy) via early glue forward
 * (length_off forward at glue ~2017; bump_past_home implicit/forward).
 * Remaining nested helpers (struct/fixed_array/vector let_init) still in glue.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c before
 * block_body / block_if_stmt includes (definition order: inits before body).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/* ========================================================================
 * wave1024 G.7 fold: TYPE_SLICE dual-GP helpers + slice_from_array let-init
 * (from pipeline_glue residual before this #include). Same-TU static.
 * Callers: this leaf (block_inits_elf_c); glue func-body let init (8193);
 * call_args leaf (length_off / bump_past_home via forward).
 * PLATFORM: SHARED freestanding · MACOS|ARM64 vs LINUX|x86_64 polarity.
 * ======================================================================== */

/* wave1118-1123 G.7: extern fwd decl — pipeline_expr_set_resolved_type_ref
 * is defined at glue.c:4076 (after this file's #include at L3689). The
 * getter pipeline_expr_resolved_type_ref has its own fwd decl at glue.c:1654
 * but the setter does not. Required by glue_fill_var_types_from_params_for_func. */
extern void pipeline_expr_set_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t type_ref);

/**
 * wave394 Cap residual pure: TYPE_SLICE dual-GP length half product offset.
 *
 * Memory layout authority = C fat {data at lower address, length at data+8} so
 * lea(data_home) is a valid slice* for call-arg / param paths.
 *
 * - x86_64 product offset uses [rbp-off]: smaller offset → higher address →
 *   length half is data_home-8 (historical dual-GP high half).
 * - arm64 product offset uses [x29+off]: larger offset → higher address →
 *   length half is data_home+8. Prior home-8 overwrote fixed-array elems that
 *   grow +i*esz from their slot (mac multi INDEX sum 34 vs 100; s[2]=4 length)
 *   and fat*+8 length load saw empty (len_of(s)=0). Ubuntu x86 hid both.
 *
 * G.7: single helper for every TYPE_SLICE dual-GP length store/load (let-init,
 * assign, FIELD_ACCESS, INDEX bounds, call-arg materialize, escape return).
 * PLATFORM: SHARED freestanding · MACOS|ARM64 vs LINUX|x86_64 frame polarity.
 *
 * @param data_home product slot offset of the data pointer half
 * @param ta        0=x86_64, 1=arm64, 2=riscv (riscv treated as x86 polarity)
 * @return product offset of the length half
 */
static int32_t glue_slice_dual_gp_length_off_c(int32_t data_home, int32_t ta) {
  if (ta == 1)
    return data_home + 8;
  return data_home - 8;
}

/**
 * Advance next_offset past both dual-GP halves of a TYPE_SLICE home.
 * x86: highest product offset used is data_home; arm64 also uses data_home+8.
 */
static void glue_slice_dual_gp_bump_past_home_c(struct backend_AsmFuncCtx *ctx, int32_t data_home,
                                               int32_t ta) {
  pipeline_glue_AsmFuncCtxLayout *ly;
  int32_t past;
  if (!ctx)
    return;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return;
  past = (ta == 1) ? (data_home + 16) : (data_home + 8);
  if (ly->next_offset < past)
    ly->next_offset = past;
  glue_align_next_offset(ctx);
}

/**
 * let s: T[] = arr / let s: T[] = [..]：asm 栈槽写入 { .data = ptr, .length = N }.
 * - VAR path: arr is a prior fixed TYPE_ARRAY local (codegen_try_emit_slice_init_from_array_var).
 * - ARRAY_LIT path (wave329/wave330/wave339): dual-GP fat {data, length=num_elems}.
 *   Host-C already uses durable static compound
 *   `({ static E __xlang_al[]=…; slice{.data=__xlang_al,.length=N} })` so `return a` is safe.
 *   Freestanding used stack emit_array_lit only → `return a` dual-GP dangles after clobber
 *   (Ubuntu trash probe: expect 60, got 84). wave339: prefer durable text-embed (G.7 reuse
 *   glue_asm_emit_array_lit_durable_ptr_rax_elf_c). wave341: non-const also durable via
 *   SHN_COMMON BSS + runtime stores (ctx required). wave330: empty `[]` still writes
 *   {data, length=0}; do not rely on prologue zeroing.
 *
 * PLATFORM: SHARED freestanding dual-GP. Length half offset is arch-aware
 * (glue_slice_dual_gp_length_off_c — wave394); memory order always C fat.
 *
 * @return 1 已写入；0 不适用；-1 失败。
 */
static int32_t glue_emit_slice_from_array_let_init_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         int32_t block_ref, int32_t let_idx, int32_t init_ref,
                                                         int32_t let_type_ref, struct backend_AsmFuncCtx *ctx,
                                                         int32_t ta, int32_t slice_slot_off) {
  int32_t arr_sz = 0;
  int32_t li;
  int32_t vlen;
  int32_t arr_off;
  int32_t init_ko;
  uint8_t vname[128];

  if (!arena || !elf_ctx || !ctx || block_ref <= 0 || let_type_ref <= 0 || init_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, let_type_ref) != GLUE_TYPE_KIND_SLICE)
    return 0;
  init_ko = pipeline_expr_kind_ord_at(arena, init_ref);
  /*
   * wave329 Cap residual pure: TYPE_SLICE + EXPR_ARRAY_LIT (`let a: i32[] = [1,2,3]`).
   * wave330: empty `[]` (n_arr==0) dual-GP length=0.
   * wave339: prefer durable text-embed payload (match host static / kill return-VAR dangle).
   * G.7: single authority for ARRAY_LIT→slice dual-GP; callers must route empty TYPE_SLICE here.
   */
  if (init_ko == 46) {
    int32_t n_arr;
    int32_t durable = 0;
    int32_t force_esz = 0;
    int32_t et;
    pipeline_glue_AsmFuncCtxLayout *ly;
    n_arr = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
    if (n_arr < 0 || n_arr > GLUE_ARRAY_LIT_MAX_ELEMS)
      return -1;
    /* wave625: G.7 force_esz authority (scalar + TYPE_NAMED layout size). */
    et = pipeline_type_elem_ref_at(arena, let_type_ref);
    force_esz = glue_array_lit_force_esz_from_elem_type_c(arena, et);
    /*
     * Prefer durable (wave335/wave341 helper): const text-embed or non-const COMMON BSS.
     * wave408: arm64 durable COMMON+ADRP (ta==1) same authority.
     * Fallback: stack emit_array_lit only if durable pack fails (cap/ta/etc).
     * PLATFORM: SHARED freestanding · LINUX|x86_64 · MACOS|ARM64.
     */
    if ((ta == 0 || ta == 1) &&
        glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, init_ref, force_esz, ta, ctx) == 0) {
      durable = 1;
    } else if (pipeline_asm_emit_array_lit_force_esz_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                             force_esz) != 0) {
      /* wave631: stack fallback must keep force_esz (S24[] lit esz>8 rejects durable). */
      return -1;
    }
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, slice_slot_off, ta) != 0)
      return -1;
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_arr, 0, ta) != 0)
      return -1;
    /* wave394: arch-aware length half (C fat memory order). */
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(slice_slot_off, ta),
                                         ta) != 0)
      return -1;
    /*
     * wave331: empty ARRAY_LIT does not bump next_offset (0 temp bytes), and lea(temp)
     * may equal the dual-GP home. Advance past home so a later `a = [..]` assign does
     * not write payload into the fat slot (Ubuntu: empty→lit index garbage).
     * Non-empty stack path: also bump payload size (direct emit_array_lit skips slow-path bump).
     * Durable path: no stack payload — skip array_lit bump (payload lives in text).
     * wave394: arm64 length@home+8 must also be past next_offset.
     * PLATFORM: SHARED freestanding stack temp discipline.
     */
    if (durable == 0 && n_arr > 0)
      pipeline_asm_bump_next_offset_for_array_lit(arena, init_ref, ctx);
    glue_slice_dual_gp_bump_past_home_c(ctx, slice_slot_off, ta);
    return 1;
  }
  /*
   * VAR path: prior fixed TYPE_ARRAY local.
   * wave348 FIELD path: `let s: T[] = b.a` — lea base+field_off → data, length=N.
   * G.7: same dual-GP store authority; reuse INDEX field base lea (TYPE_ARRAY no load).
   * PLATFORM: SHARED freestanding · LINUX+MACOS x86_64 SysV.
   */
  if (init_ko == GLUE_EXPR_KIND_VAR) {
    vlen = pipeline_expr_var_name_len(arena, init_ref);
    if (vlen <= 0 || vlen > 127)
      return 0;
    pipeline_expr_var_name_into(arena, init_ref, vname);
    for (li = 0; li < let_idx; li++) {
      int32_t nlen = pipeline_block_let_name_len(arena, block_ref, li);
      if (nlen == vlen && nlen > 0) {
        int32_t match = 1;
        int32_t ci;
        uint8_t nb[128];
        pipeline_block_let_name_copy64(arena, block_ref, li, nb);
        for (ci = 0; ci < nlen; ci++) {
          if (nb[ci] != vname[ci]) {
            match = 0;
            break;
          }
        }
        if (match) {
          int32_t tr = pipeline_block_let_type_ref(arena, block_ref, li);
          if (pipeline_type_kind_ord_at(arena, tr) == (int32_t)ast_TypeKind_TYPE_ARRAY)
            arr_sz = pipeline_type_array_size_at(arena, tr);
          if (arr_sz > 0)
            break;
        }
      }
    }
    if (arr_sz <= 0) {
      int32_t init_tr = pipeline_expr_resolved_type_ref(arena, init_ref);
      if (init_tr > 0 && pipeline_type_kind_ord_at(arena, init_tr) == 10)
        arr_sz = pipeline_type_array_size_at(arena, init_tr);
    }
    if (arr_sz <= 0)
      return 0;
    arr_off = glue_var_expr_stack_off_elf_c(arena, ctx, init_ref);
    if (arr_off < 0)
      return -1;
    if (glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, init_ref, arr_off, ctx, ta) != 0)
      return -1;
  } else if (init_ko == 44) {
    /* EXPR_FIELD_ACCESS: fixed TYPE_ARRAY field of VAR base. */
    int32_t init_tr;
    int32_t ftr;
    int32_t lea_rc;
    if (pipeline_expr_field_access_is_enum_variant(arena, init_ref) != 0)
      return 0;
    init_tr = pipeline_expr_resolved_type_ref(arena, init_ref);
    if (init_tr > 0 && pipeline_type_kind_ord_at(arena, init_tr) == (int32_t)ast_TypeKind_TYPE_ARRAY)
      arr_sz = pipeline_type_array_size_at(arena, init_tr);
    if (arr_sz <= 0) {
      ftr = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, init_ref);
      if (ftr > 0 && pipeline_type_kind_ord_at(arena, ftr) == (int32_t)ast_TypeKind_TYPE_ARRAY)
        arr_sz = pipeline_type_array_size_at(arena, ftr);
    }
    if (arr_sz <= 0)
      return 0;
    /* lea &b.a into rax (TYPE_ARRAY field: no ptr load). */
    lea_rc = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, init_ref, ctx, ta);
    if (lea_rc != 0)
      return lea_rc < 0 ? -1 : 0;
  } else {
    return 0;
  }
  if (backend_enc_store_rax_to_rbp_arch(elf_ctx, slice_slot_off, ta) != 0)
    return -1;
  if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, arr_sz, 0, ta) != 0)
    return -1;
  /* wave394: arch-aware length half (C fat memory order; arm64 home+8). */
  if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(slice_slot_off, ta),
                                       ta) != 0)
    return -1;
  glue_slice_dual_gp_bump_past_home_c(ctx, slice_slot_off, ta);
  return 1;
}

/**
 * ELF 路径：块的 const/let 初始化（C 实现）；TYPE_VECTOR+ARRAY_LIT 直写栈槽，避免 8B 指针 + 重叠 temp。
 */
int32_t pipeline_asm_emit_block_inits_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t ta,
                                            int32_t slot_base) {
  int32_t nconst;
  int32_t nlet;
  int32_t idx;
  int32_t i;
  pipeline_glue_AsmFuncCtxLayout *ly;
  if (!arena || !elf_ctx || !ctx || block_ref <= 0)
    return -1;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  nconst = ast_ast_block_num_consts(arena, block_ref);
  nlet = ast_ast_block_num_lets(arena, block_ref);
  idx = 0;
  for (i = 0; i < nconst && (slot_base + idx) < ly->num_locals; i++) {
    int32_t init_ref = ast_pipeline_block_const_init_ref(arena, block_ref, i);
    if (init_ref != 0 && !glue_init_is_empty_array_lit(arena, init_ref)) {
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot_base + idx), ta) != 0)
        return -1;
    }
    idx++;
  }
  for (i = 0; i < nlet && (slot_base + idx) < ly->num_locals; i++) {
    int32_t init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, i);
    int32_t slot = slot_base + idx;
    int32_t type_ref;
    uint8_t lnb[128];
    int32_t llen;
    if (init_ref == 0) {
      idx++;
      continue;
    }
    /**
     * wave330: empty `[]` for TYPE_SLICE must write dual-GP {data,length=0} (G.7 authority
     * glue_emit_slice_from_array_let_init_elf_c). Fixed/pointer empties may still skip.
     * PLATFORM: SHARED freestanding emit.
     */
    if (glue_init_is_empty_array_lit(arena, init_ref)) {
      llen = pipeline_block_let_name_len(arena, block_ref, i);
      if (llen > 0) {
        pipeline_block_let_name_copy64(arena, block_ref, i, lnb);
        if (glue_lazy_append_block_let_local(arena, ctx, block_ref, i, lnb, llen) != 0)
          return -1;
      }
      type_ref = pipeline_block_let_type_ref(arena, block_ref, i);
      {
        int32_t slice_st =
            glue_emit_slice_from_array_let_init_elf_c(arena, elf_ctx, block_ref, i, init_ref, type_ref, ctx, ta,
                                                      backend_asm_ctx_slot_offset(ctx, slot));
        if (slice_st < 0)
          return -1;
      }
      idx++;
      continue;
    }
    /** stmt_order==0 路径：fill_local_slots 可能因 block_ref 碰撞跳过，懒登记真实栈偏移。 */
    llen = pipeline_block_let_name_len(arena, block_ref, i);
    if (llen > 0) {
      pipeline_block_let_name_copy64(arena, block_ref, i, lnb);
      if (glue_lazy_append_block_let_local(arena, ctx, block_ref, i, lnb, llen) != 0)
        return -1;
    }
    type_ref = pipeline_block_let_type_ref(arena, block_ref, i);
    if (glue_block_let_is_simd_vector_type(arena, block_ref, i)) {
      int32_t vst = glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                         backend_asm_ctx_slot_offset(ctx, slot), type_ref);
      if (vst == 0) {
        /* 向量 ARRAY_LIT / VAR 拷贝 / 逐 lane binop 已直写 let 槽 */
      } else if (vst == -1) {
        return -1;
      } else if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0) {
        return -1;
      } else if (backend_enc_store_rax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot), ta) != 0) {
        return -1;
      }
    } else if (glue_block_let_is_fixed_array_type(arena, block_ref, i)) {
      /**
       * wave354: T[N] = [..] / VAR / FIELD / CALL — element-wise into let slot.
       * G.7: glue_emit_fixed_array_type_let_init_elf_c (reuses STRUCT_LIT field store).
       * Prior: only ARRAY_LIT; FIELD fell through to 8B pointer store (Ubuntu fs wrong sum).
       */
      int32_t arr_st =
          glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, type_ref,
                                                    backend_asm_ctx_slot_offset(ctx, slot));
      if (arr_st == 0) {
        /* fixed array payload written */
      } else if (arr_st == -1) {
        return -1;
      } else {
        /* -2 unsupported fixed-array init — do not store pointer into array slot. */
        if (link_abi_getenv("XLANG_ASM_DEBUG"))
          fprintf(stderr, "xlang: fixed array let init unhandled block=%d i=%d init_ko=%d\n",
                  (int)block_ref, (int)i, (int)pipeline_expr_kind_ord_at(arena, init_ref));
        return -1;
      }
    } else {
      int32_t slice_st = glue_emit_slice_from_array_let_init_elf_c(arena, elf_ctx, block_ref, i, init_ref,
                                                                   type_ref, ctx, ta,
                                                                   backend_asm_ctx_slot_offset(ctx, slot));
      if (slice_st == 1) {
        /* slice from array var 已写入 { data, length } */
      } else if (slice_st < 0) {
        return -1;
      } else {
      int32_t st =
          glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, type_ref,
                                               backend_asm_ctx_slot_offset(ctx, slot));
      if (st == 0) {
        /* struct 字面量或 mk(...) 内联已写入 let 槽 */
      } else if (st == -1) {
        return -1;
      } else if (pipeline_expr_kind_ord_at(arena, init_ref) == 46) {
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot), ta) != 0)
        return -1;
      pipeline_asm_bump_next_offset_after_let_init(arena, block_ref, i, init_ref, ctx);
      } else {
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0)
        return -1;
      /* wave314: f32 init → f64 let: use scalar-f32 classifier (decl/resolved/index). */
      {
        int32_t dty = type_ref > 0 ? type_ref : pipeline_block_let_type_ref(arena, block_ref, i);
        if (glue_type_ref_is_scalar_f64_c(arena, dty) &&
            glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, init_ref)) {
          if (backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx, ta) != 0)
            return -1;
        } else {
          int32_t src_ty = glue_float_promote_src_ty_ref_c(arena, init_ref);
          if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, dty, src_ty, ta) != 0)
            return -1;
        }
      }
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot), ta) != 0)
        return -1;
      }
      }
    }
    idx++;
  }
  return 0;
}

/**
 * Check whether a block-internal let name matches an EXPR_VAR (length + bytes).
 *
 * Why: glue_fill_var_types_from_lets_in_block and glue_fill_array_lit_types_in_
 * block iterate block lets and match them against EXPR_VAR refs to propagate
 * resolved_type from let init to var usage. This helper centralizes the
 * name comparison so callers don't repeat kind_ord + name_len + memcmp.
 *
 * Invariant: returns 0 for NULL arena/let_nm, invalid expr_ref, let_nlen <= 0,
 * or non-VAR (kind_ord != 3); returns 1 iff var name length and bytes match
 * let_nm exactly.
 *
 * Asm/Perf: O(n) — one name read + one byte loop. Cold path — called per
 * let × per expr in glue_fill_var_types_from_lets_in_block (glue.c:8985) and
 * glue_fill_array_lit_types_in_block (glue.c:9015).
 *
 * PLATFORM: SHARED — name comparison is platform-independent.
 *
 * wave1084 G.7: migrated from glue.c:8914 (body 19 LOC). Static (non-extern):
 * same-TU — block_inits.c #include at L3830 < def EOF < all callsites
 * (glue.c:8985/9015). Dependencies: pipeline_expr_kind_ord_at /
 * pipeline_expr_var_name_len / pipeline_expr_var_name_into (all extern).
 */
static int glue_let_name_matches_var(struct ast_ASTArena *arena, int32_t expr_ref, const uint8_t *let_nm,
                                   int32_t let_nlen) {
  uint8_t vn[128];
  int32_t vlen;
  int32_t j;
  if (!arena || !let_nm || let_nlen <= 0 || expr_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 3)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, expr_ref);
  if (vlen != let_nlen)
    return 0;
  pipeline_expr_var_name_into(arena, expr_ref, vn);
  for (j = 0; j < let_nlen; j++) {
    if (vn[j] != let_nm[j])
      return 0;
  }
  return 1;
}

/* ─────────────────────────────────────────────────────────────────────────── */
/* wave1118-1123 G.7: skipped-typeck array-lit/var type backfill domain (5 fns)
 * migrated from pipeline_glue.c L6729-6851. These form a tight interdependent
 * cluster: glue_fill_array_lit_types_in_block orchestrates over the other
 * four, and glue_fill_var_types_from_params_for_func / _from_lets_in_block
 * both consume glue_expr_in_scope_block_c + glue_let_name_matches_var
 * (defined above in this file). Co-located with the block-init domain.
 * Static (non-extern): same-TU visibility via #include order — block_inits.c
 * #include at glue.c L3689 < all callsites (L8981+ public skipped-typeck
 * path). Zero fwd decls required. PLATFORM: SHARED. */

/**
 * Backfill a let/const declaration type T[N] into the ARRAY_LIT init's
 * resolved_type_ref (mirrors typeck_coerce_init_expr_to_decl).
 *
 * Why: when the asm emitter skips .x typeck (skip-heavy C-only modules),
 * ARRAY_LIT inits have resolved_type_ref=0; the asm array_lit path needs
 * the element count from the declared array type to size the memcpy.
 *
 * Contract: no-op if arena/decl_ty_ref/init_ref invalid, decl_ty_ref is
 * not TYPE_ARRAY (kind ord 10), or init_ref is not EXPR_ARRAY_LIT (kind 46).
 *
 * PLATFORM: SHARED — pure type_ref stamp, no arch dependency.
 */
static void glue_fill_array_lit_from_decl(struct ast_ASTArena *arena, int32_t decl_ty_ref, int32_t init_ref) {
  struct ast_Expr *init_ex;
  if (!arena || decl_ty_ref <= 0 || decl_ty_ref > arena->num_types || init_ref <= 0 ||
      init_ref > arena->num_exprs)
    return;
  if (pipeline_type_kind_ord_at(arena, decl_ty_ref) != GLUE_TYPE_KIND_ARRAY)
    return;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 46)
    return;
  init_ex = pipeline_arena_expr_ptr(arena, init_ref);
  if (!init_ex)
    return;
  init_ex->resolved_type_ref = decl_ty_ref;
}

/**
 * Return 1 if expr_ref lives in scope_block_ref or any of its child blocks.
 * Prevents cross-function / cross-sibling-block name collisions from
 * polluting resolved_type_ref during the skip-typeck backfill.
 *
 * Why: the asm skip-typeck path scans all exprs for name matches; without
 * this scope gate, `v` in func A would inherit the type of `v` in func B.
 *
 * Contract: returns 0 for invalid arena/refs. Depth-limited to 128 to
 * prevent infinite loops on cyclic block graphs (should not happen).
 *
 * PLATFORM: SHARED — pure block-tree walk, no arch dependency.
 */
static int32_t glue_expr_in_scope_block_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t scope_block_ref) {
  int32_t cur;
  int32_t depth;
  if (!arena || expr_ref <= 0 || scope_block_ref <= 0 || scope_block_ref > arena->num_blocks)
    return 0;
  cur = pipeline_expr_block_ref_at(arena, expr_ref);
  if (cur == scope_block_ref)
    return 1;
  depth = 0;
  while (cur > 0 && cur <= arena->num_blocks && depth < 128) {
    struct ast_Block *b = pipeline_arena_block_ptr(arena, cur);
    if (!b)
      break;
    cur = b->parent_block_ref;
    if (cur == scope_block_ref)
      return 1;
    depth++;
  }
  return 0;
}

/**
 * Backfill resolved_type_ref for EXPR_VAR nodes that match a function
 * parameter name (skip .x typeck path; SoA `arr[i].field` needs T[N]).
 * Only writes when resolved_type_ref is still 0, so multiple functions
 * with same-named params (e.g. `v`) do not overwrite each other.
 *
 * Why: the asm emitter dereferences INDEX/METHOD_CALL base VARs whose
 * resolved_type_ref was never set by the skipped typeck pass.
 *
 * Contract: no-op if m/arena/func_index invalid or func has no body.
 * Iterates all exprs (O(E×P)) — cold path, only called when typeck
 * is skipped.
 *
 * PLATFORM: SHARED — pure type_ref propagation, no arch dependency.
 */
static void glue_fill_var_types_from_params_for_func(struct ast_Module *m, struct ast_ASTArena *arena,
                                                     int32_t func_index) {
  int32_t np;
  int32_t pi;
  int32_t ei;
  int32_t body_ref;
  uint8_t nm[128];
  int32_t nlen;
  int32_t tref;
  if (!m || !arena || func_index < 0 || func_index >= (int32_t)m->num_funcs)
    return;
  body_ref = pipeline_module_func_body_ref_at(m, func_index);
  if (body_ref <= 0)
    return;
  np = pipeline_module_func_num_params_at(m, func_index);
  for (pi = 0; pi < np; pi++) {
    nlen = pipeline_module_func_param_name_len_at(m, func_index, pi);
    if (nlen <= 0 || nlen > 127)
      continue;
    pipeline_module_func_param_name_copy32(m, func_index, pi, nm);
    tref = pipeline_module_func_param_type_ref_at(m, func_index, pi);
    if (tref <= 0)
      continue;
    for (ei = 1; ei <= arena->num_exprs; ei++) {
      if (glue_expr_in_scope_block_c(arena, ei, body_ref) &&
          glue_let_name_matches_var(arena, ei, nm, nlen) &&
          pipeline_expr_resolved_type_ref(arena, ei) <= 0)
        pipeline_expr_set_resolved_type_ref(arena, ei, tref);
    }
  }
}

/**
 * Backfill resolved_type_ref for EXPR_VAR nodes that match a block-internal
 * let name (skip .x typeck path; arr[i] INDEX needs base type).
 *
 * Why: without typeck, the asm emitter cannot size the element store for
 * `let buf: u8[N] = [..]; buf[0] = 1;` — the VAR `buf` has no
 * resolved_type_ref until this backfill stamps it from the let decl.
 *
 * Contract: no-op if arena/block_ref invalid. Overwrites resolved_type_ref
 * unconditionally (unlike the params variant) because let scope is
 * block-local — there is no cross-function collision risk.
 *
 * PLATFORM: SHARED — pure type_ref propagation, no arch dependency.
 */
static void glue_fill_var_types_from_lets_in_block(struct ast_ASTArena *arena, int32_t block_ref) {
  int32_t nlet;
  int32_t li;
  int32_t ei;
  if (!arena || block_ref <= 0 || block_ref > arena->num_blocks)
    return;
  nlet = ast_ast_block_num_lets(arena, block_ref);
  for (li = 0; li < nlet; li++) {
    int32_t tref = pipeline_block_let_type_ref(arena, block_ref, li);
    uint8_t nm[128];
    int32_t nlen;
    if (tref <= 0)
      continue;
    nlen = pipeline_block_let_name_len(arena, block_ref, li);
    if (nlen <= 0 || nlen > 127)
      continue;
    pipeline_block_let_name_copy64(arena, block_ref, li, nm);
    for (ei = 1; ei <= arena->num_exprs; ei++) {
      struct ast_Expr *ex = pipeline_arena_expr_ptr(arena, ei);
      if (!ex)
        continue;
      if (glue_expr_in_scope_block_c(arena, ei, block_ref) &&
          glue_let_name_matches_var(arena, ei, nm, nlen)) {
        ex->resolved_type_ref = tref;
      }
    }
  }
}

/**
 * Walk block-internal lets and backfill ARRAY_LIT init types for the
 * skip-typeck asm path (e.g. `let buf: u8[12] = [0;12]` in hello.x).
 *
 * Why: orchestrates the let→VAR type propagation (via
 * glue_fill_var_types_from_lets_in_block) and then stamps ARRAY_LIT
 * resolved_type_ref from the declared let type (via
 * glue_fill_array_lit_from_decl). Called by the public skipped-typeck
 * entry point pipeline_fill_array_lit_types_for_skipped_typeck.
 *
 * Contract: no-op if arena/block_ref invalid.
 *
 * PLATFORM: SHARED — pure orchestration, no arch dependency.
 */
static void glue_fill_array_lit_types_in_block(struct ast_ASTArena *arena, int32_t block_ref) {
  int32_t nlet;
  int32_t i;
  if (!arena || block_ref <= 0 || block_ref > arena->num_blocks)
    return;
  glue_fill_var_types_from_lets_in_block(arena, block_ref);
  nlet = ast_ast_block_num_lets(arena, block_ref);
  for (i = 0; i < nlet; i++) {
    glue_fill_array_lit_from_decl(arena, pipeline_block_let_type_ref(arena, block_ref, i),
                                ast_pipeline_block_let_init_ref(arena, block_ref, i));
  }
}

/* ============================================================
 * wave1149 G.7: block locals tree fill + init reserve bytes pair
 * (migrated from pipeline_glue.c L1583-1604 + L1679-1690).
 *
 * Why here: pipeline_asm_fill_block_locals_tree walks a block_ref
 * subtree and registers all const/let into the AsmFuncCtx sidecar
 * (via asm_ctx_fill_locals_block_tree). It is the entry-point for
 * block-level local slot allocation — colocated with the block
 * const/let init emit domain already in this file.
 *
 * glue_asm_init_expr_reserve_stack_bytes is the companion helper
 * that computes extra temp bytes for ARRAY_LIT/STRUCT_LIT let
 * initializers (used by pipeline_asm_let_init_stack_reserve_bytes
 * in glue.c). Colocating both keeps block-local allocation logic
 * in one file.
 *
 * Dependencies (visible via earlier decls in the TU):
 *   - pipeline_asm_ctx_layout (static, defined at glue.c L86,
 *     before this file's #include at L3617)
 *   - pipeline_glue_AsmFuncCtxLayout (struct, defined at glue.c L84)
 *   - asm_ctx_fill_locals_block_tree (extern, declared at glue.c L1557)
 *   - asm_array_lit_reserve_stack_bytes / asm_struct_lit_reserve_stack_bytes
 *     (extern, declared at glue.c L1676-1677)
 *   - pipeline_asm_emit_set_module (extern, defined at glue.c L4247,
 *     AFTER this file's #include at L3617 — extern fwd decl below)
 *
 * Globals: pipeline_asm_fill_block_locals_tree previously wrote to
 *   glue.c-local static g_pipeline_asm_emit_module; replaced with
 *   the public setter pipeline_asm_emit_set_module (G.7 single
 *   authority for the active emit module global).
 *
 * Callers (all AFTER this file's #include at L3617):
 *   - pipeline_asm_emit_block_body.c:297 (via #include at L3632)
 *   - pipeline_asm_emit_block_if_stmt.c:73,90 (via #include at L3635)
 *   - glue.c L5230 (pipeline_asm_emit_block_body_sync_elf caller)
 *   - glue.c L2113 calls glue_asm_init_expr_reserve_stack_bytes
 *     (BEFORE this file's #include at L3617 — static fwd decl added
 *     at glue.c before L2106)
 *
 * PLATFORM: SHARED — pure block-local slot allocation; no platform ABI dep.
 * ============================================================ */

/* extern fwd decl: pipeline_asm_emit_set_module is defined at glue.c L4247
 * (AFTER this file's #include at L3617). Sole use is the side-effect write
 * in pipeline_asm_fill_block_locals_tree (replacing direct global write). */
extern void pipeline_asm_emit_set_module(struct ast_Module *m);

/**
 * Register all const/let within a block_ref subtree into AsmFuncCtx sidecar.
 * Side effect: sets the active emit module from ctx prefix (offset 16) via
 * the public setter pipeline_asm_emit_set_module (G.7 single authority for
 * g_pipeline_asm_emit_module; was a direct static-global write before wave1149).
 */
static void pipeline_asm_fill_block_locals_tree(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena,
                                                int32_t block_ref) {
  struct ast_Module *mod_ref;
  pipeline_glue_AsmFuncCtxLayout *ly;
  int32_t off;
  int32_t nl;
  if (!ctx || !arena || block_ref <= 0)
    return;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return;
  /* module_ref at AsmFuncCtx prefix offset 16; feeds asm_local_slot_bytes
   * struct layout queries via the active emit module global. */
  mod_ref = *(struct ast_Module **)((uint8_t *)ctx + 16);
  if (mod_ref)
    pipeline_asm_emit_set_module(mod_ref);
  off = ly->next_offset;
  nl = ly->num_locals;
  asm_ctx_fill_locals_block_tree((uint8_t *)ctx, arena, block_ref, &off, &nl);
  ly->next_offset = off;
  ly->num_locals = nl;
}

/**
 * Extra temp stack bytes reserved for ARRAY_LIT/STRUCT_LIT let/const
 * initializers (beyond the pointer slot). Returns 0 for non-aggregate inits.
 */
static int32_t glue_asm_init_expr_reserve_stack_bytes(struct ast_ASTArena *arena, int32_t init_ref) {
  int32_t n;
  if (init_ref <= 0)
    return 0;
  n = asm_array_lit_reserve_stack_bytes(arena, init_ref);
  if (n > 0)
    return n;
  return asm_struct_lit_reserve_stack_bytes(arena, init_ref);
}

/* ========================================================================== *
 * wave1204 G.7: pipeline_asm_let_init_stack_reserve_bytes migrated from
 * pipeline_glue.c L1498-1506. Colocated with glue_asm_init_expr_reserve_
 * stack_bytes (L723 above) — its sole static callee returning non-zero
 * fallback. Two other static callees (glue_vector_let_init_uses_direct_slot
 * in vector_simd.c L2218 + glue_fixed_array_let_init_uses_direct_slot in
 * vector_let.c L2063) are visible here via same-TU #include order:
 *   vector_let.c   #include at glue.c L2063  (before this file at L2404)
 *   vector_simd.c  #include at glue.c L2218  (before this file at L2404)
 * Root: original glue.c L1498 definition preceded those #includes —
 * glue_fixed_array_let_init_uses_direct_slot had NO fwd decl, relying on
 * C implicit declaration. Migrating here fixes that latent issue.
 *
 * Members (1 fn):
 *  - pipeline_asm_let_init_stack_reserve_bytes (extern; 3 static callees)
 *
 * Callers (4 sites, all via same-TU #include after L2404 OR via extern):
 *  - pipeline_asm_emit_context.c L724/739 (#include at L2564, after L2404)
 *  - ast_pool.c L8497/8511 (#include at L3186, after L2404; extern decl L8080)
 *  - ast_pool_top_level.c L323 (via extern decl at L285)
 *  - pipeline_asm_emit_modlet.c L530 (#include at L1543, BEFORE L2404 —
 *    needs extern fwd decl added at modlet.c L331)
 *
 * Cleaned up in glue.c:
 *  - static fwd decl for glue_asm_init_expr_reserve_stack_bytes (L1081)
 *  - static fwd decl for glue_vector_let_init_uses_direct_slot (L1467)
 * Both had pipeline_asm_let_init_stack_reserve_bytes as sole caller.
 *
 * PLATFORM: SHARED — pure stack byte arithmetic, no arch dependency.
 * ========================================================================== */

/**
 * Extra stack bytes reserved for a let/const initializer beyond its type slot.
 *
 * Why: VECTOR and fixed TYPE_ARRAY let-inits that emit via ARRAY_LIT direct
 *      slot writes need 0 extra bytes (pointer slot suffices). All other
 *      aggregate initializers (STRUCT_LIT, nested ARRAY_LIT) need temp space
 *      for the init expression — delegated to glue_asm_init_expr_reserve_
 *      stack_bytes above (which checks asm_array_lit_reserve_stack_bytes
 *      then asm_struct_lit_reserve_stack_bytes).
 * Contract: NULL arena -> 0; type_ref<=0 or init_ref<=0 -> 0 (via callee).
 * Invariant: returns 0 for direct-slot inits (VECTOR/fixed-array);
 *            returns glue_asm_init_expr_reserve_stack_bytes result otherwise.
 * Asm/Perf: O(1) — 2 boolean checks + 1 tail call. Cold path (fill_local_slots).
 * PLATFORM: SHARED.
 */
int32_t pipeline_asm_let_init_stack_reserve_bytes(struct ast_ASTArena *arena, int32_t type_ref, int32_t init_ref) {
  if (!arena)
    return 0;
  if (glue_vector_let_init_uses_direct_slot(arena, type_ref, init_ref))
    return 0;
  if (glue_fixed_array_let_init_uses_direct_slot(arena, type_ref, init_ref))
    return 0;
  return glue_asm_init_expr_reserve_stack_bytes(arena, init_ref);
}
