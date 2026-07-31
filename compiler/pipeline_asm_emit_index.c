/**
 * pipeline_asm_emit_index.c — asm ELF EXPR_INDEX / ADDR_OF / DEREF emit domain
 * (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding index-cluster ELF emit:
 * - pipeline_asm_index_elem_byte_sz_c (INDEX stride / load width: ptr pointee,
 *   multi-dim TYPE_ARRAY total_bytes, TYPE_PTR=8, TYPE_SLICE=16, VECTOR lane,
 *   Struct layout — Cap residual pure waves 357/637/692)
 * - pipeline_asm_emit_index_elf_c (eff_addr + load / leave-addr for ARRAY /
 *   SLICE dual-GP — Cap residual pure waves 357/692)
 * - pipeline_asm_emit_addr_of_elf_c (VAR lea slot, INDEX eff_addr, FIELD /
 *   DEREF lvalue_eff_addr — Cap residual pure waves 640/641)
 * - pipeline_asm_emit_deref_elf_c (load [ptr]; TYPE_ARRAY leave; TYPE_PTR=8 —
 *   Cap residual pure waves 323/636/640)
 *
 * G.7: single product-mega INDEX / ADDR_OF / DEREF ELF face — do not open a
 * second cluster emitter. Nested helpers: try_index_* forest + lvalue_eff_addr
 * live in pipeline_asm_emit_index_helpers.c (same TU; included earlier);
 * glue_emit_index_eff_addr_scaled + index assign-addr cache remain in
 * pipeline_glue.c (same TU).
 *
 * Callers: expr_elf_rec / mega, assign INDEX lhs (elem_byte_sz),
 * lvalue_eff_addr INDEX/DEREF arms, public pipeline_asm_index_elem_byte_sz.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c immediately
 * after pipeline_asm_emit_array_lit.c (before call/match faces).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/* Forward decls for helpers defined later in pipeline_glue.c (same TU).
 * Most index-cluster callees are defined earlier (eff_addr scaled, cache,
 * field_type_ref, fixed_array_total_bytes, from_type_ref). */
static int32_t glue_type_size_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref,
                                     int32_t depth);

/**
 * INDEX 元素字节宽：*u8/u8→1，i32/u32/f32→4，Struct[N]→layout 宽，默认 8。
 * glue_type_size_simple defined later in pipeline_glue.c (forward above).
 */

static int32_t pipeline_asm_index_elem_byte_sz_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  int32_t base_ref;
  int32_t tr;
  int32_t kind_ord;
  int32_t pointee;
  int32_t esz_base;
  /**
   * v.ptr[v.len] 等：INDEX resolved_type 偶发为 i32/usize（8B）而基址为 *u8；
   * 优先按指针基址 pointee 步长，避免 lea (ptr,len,8) 写穿 bump 区（with_arena_vec SIGSEGV）。
   */
  base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
  if (base_ref > 0) {
    /** Vec_u8.ptr[i]：layout 字段 type 偶发误为 *f64；按形参 *Vec_u8 名后缀强制步长 1。 */
    if (pipeline_expr_kind_ord_at(arena, base_ref) == 44) {
      struct ast_Expr *fa = pipeline_arena_expr_ptr(arena, base_ref);
      if (fa && fa->field_access_field_len == 3 && fa->field_access_field_name[0] == (uint8_t)'p' &&
          fa->field_access_field_name[1] == (uint8_t)'t' && fa->field_access_field_name[2] == (uint8_t)'r') {
        int32_t vref = fa->field_access_base_ref;
        if (vref > 0 && g_pipeline_asm_emit_module &&
            pipeline_expr_kind_ord_at(arena, vref) == GLUE_EXPR_KIND_VAR) {
          uint8_t vn[128];
          int32_t vl = pipeline_expr_var_name_len(arena, vref);
          int32_t pty = 0;
          if (vl > 0 && vl <= 63 && g_pipeline_asm_emit_func_index >= 0) {
            pipeline_expr_var_name_into(arena, vref, vn);
            pty = pipeline_module_func_param_type_ref_for_name(g_pipeline_asm_emit_module,
                                                               g_pipeline_asm_emit_func_index, vn, vl);
          }
          if (pty > 0 && pipeline_type_kind_ord_at(arena, pty) == GLUE_TYPE_KIND_PTR) {
            int32_t st = pipeline_type_elem_ref_at(arena, pty);
            uint8_t sn[128];
            int32_t sl = st > 0 ? pipeline_type_named_name_into(arena, st, sn) : 0;
            if (sl >= 6 && sn[sl - 1] == (uint8_t)'8' && sn[sl - 2] == (uint8_t)'u' &&
                sn[sl - 3] == (uint8_t)'_' && sn[sl - 4] == (uint8_t)'c' && sn[sl - 5] == (uint8_t)'e' &&
                sn[sl - 6] == (uint8_t)'V')
              return 1;
          }
        }
      }
    }
    if (pipeline_expr_kind_ord_at(arena, base_ref) == 44) {
      tr = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, base_ref);
    } else {
      tr = pipeline_expr_resolved_type_ref(arena, base_ref);
    }
    if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == GLUE_TYPE_KIND_PTR) {
      pointee = pipeline_type_elem_ref_at(arena, tr);
      if (pointee > 0) {
        esz_base = glue_index_elem_byte_sz_from_type_ref_c(arena, pointee);
        if (esz_base > 0 && esz_base < 8)
          return esz_base;
      }
    } else if (tr > 0) {
      /** v.ptr 等 FIELD_ACCESS 有时直接 resolved 为 u8 而非 *u8。 */
      esz_base = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
      if (esz_base > 0 && esz_base < 8)
        return esz_base;
    }
  }
  /** typeck 已在 INDEX 表达式写入元素类型（v.col_x[i]→f32）；优先于基址推断，避免 tr=0 误落 1。 */
  tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (tr > 0) {
    int32_t esz_res;
    /*
     * wave357 Cap residual pure: multi-dim outer INDEX resolves to TYPE_ARRAY
     * (`a[i]` of `[N][M]T` → `[M]T`). Stride is sizeof(that subarray), NOT the
     * peeled scalar width (peel would give 4 for [3]i32 → wrong add $4).
     * PLATFORM: SHARED freestanding address scale · LINUX gold.
     */
    if (pipeline_type_kind_ord_at(arena, tr) == 10) {
      int32_t asz = glue_fixed_array_total_bytes_c(arena, tr, 0);
      if (asz > 0)
        return asz;
    }
    /*
     * wave637 Cap residual pure: INDEX result TYPE_PTR means the *element* is a
     * pointer (`*i32[2]` → a[i] has type *i32). Stride/load width = 8.
     * glue_index_elem_byte_sz_from_type_ref peels *T→sizeof(T) for pointer-base
     * p[i] only — must not peel when tr is the INDEX element type itself.
     * Root: freestanding `*a[0]+*a[1]` used esz=4 → ldr w of pointer half → SEGV;
     * pure-asm CTFE folded 42; host-C hid. G.7: same authority as ARRAY_LIT PTR=8.
     * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
     */
    if (pipeline_type_kind_ord_at(arena, tr) == GLUE_TYPE_KIND_PTR)
      return 8;
    /*
     * wave692 Cap residual pure: INDEX result TYPE_SLICE means the *element* is a
     * fat slice (`[][]i32` → rows[i] has type []i32). Stride/load width = 16.
     * glue_index_elem_byte_sz_from_type_ref peels []T→sizeof(T) for slice-base
     * s[i] only — must not peel when tr is the INDEX element type itself.
     * Root: Ubuntu pure-asm nested INDEX used esz=4 → mov eax half-pointer SEGV;
     * host-C braces green; mac arm64 CTFE often hid. G.7 twin of TYPE_PTR=8 /
     * TYPE_ARRAY total_bytes. PLATFORM: SHARED freestanding · LINUX gold.
     */
    if (pipeline_type_kind_ord_at(arena, tr) == GLUE_TYPE_KIND_SLICE)
      return 16;
    esz_res = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
    /** v.ptr[v.len]：INDEX resolved_type 误落 i64/usize(8) 时仍按 *u8 基址步长 1。 */
    if (esz_res >= 8) {
      int32_t base_ref2;
      int32_t tr_base;
      int32_t pointee2;
      int32_t esz_pt;
      base_ref2 = pipeline_expr_index_base_ref(arena, expr_ref);
      if (base_ref2 > 0) {
        if (pipeline_expr_kind_ord_at(arena, base_ref2) == 44)
          tr_base = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, base_ref2);
        else
          tr_base = pipeline_expr_resolved_type_ref(arena, base_ref2);
        if (tr_base > 0 && pipeline_type_kind_ord_at(arena, tr_base) == GLUE_TYPE_KIND_PTR) {
          pointee2 = pipeline_type_elem_ref_at(arena, tr_base);
          if (pointee2 > 0) {
            esz_pt = glue_index_elem_byte_sz_from_type_ref_c(arena, pointee2);
            if (esz_pt > 0 && esz_pt < esz_res)
              return esz_pt;
          }
        }
      }
    }
    return esz_res;
  }
  base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
  if (base_ref <= 0)
    return 4;
  /** FIELD_ACCESS 基址（v.col_x 等）：按字段类型 *f32→4；未知时与 asm_index_elem_byte_sz 一致默认 4。 */
  if (pipeline_expr_kind_ord_at(arena, base_ref) == 44) {
    tr = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, base_ref);
    if (tr > 0)
      return glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
    return 4;
  }
  /** G.7: same VAR type recovery as INDEX slice load / .length offset (decl fallback). */
  tr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
  if (tr <= 0)
    tr = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (tr <= 0)
    return 4;
  kind_ord = pipeline_type_kind_ord_at(arena, tr);
  if (kind_ord == 9) {
    pointee = pipeline_type_elem_ref_at(arena, tr);
    if (pointee > 0) {
      kind_ord = pipeline_type_kind_ord_at(arena, pointee);
      if (kind_ord == 2 || kind_ord == 1)
        return 1;
      if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14)
        return 4;
    }
    return 4;
  }
  if (kind_ord == 10 || kind_ord == 11) {
    pointee = pipeline_type_elem_ref_at(arena, tr);
    if (pointee > 0) {
      kind_ord = pipeline_type_kind_ord_at(arena, pointee);
      if (kind_ord == 2 || kind_ord == 1)
        return 1;
      if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14)
        return 4;
      /* wave637: array/slice of pointers — element width 8 (see resolved-type path). */
      if (kind_ord == GLUE_TYPE_KIND_PTR)
        return 8;
      /* wave357: multi-dim outer INDEX stride = sizeof(inner TYPE_ARRAY). */
      if (kind_ord == 10) {
        int32_t asz = glue_fixed_array_total_bytes_c(arena, pointee, 0);
        if (asz > 0)
          return asz;
      }
      /* wave692: array/slice of TYPE_SLICE — fat element width 16. */
      if (kind_ord == GLUE_TYPE_KIND_SLICE)
        return 16;
      /** Struct[N] AoS：步长为 layout 槽宽（勿误落默认 8 → 错位/栈破坏）。 */
      if (kind_ord == 8 && g_pipeline_asm_emit_module) {
        int32_t esz = glue_type_size_simple(g_pipeline_asm_emit_module, arena, pointee, 0);
        if (esz > 0)
          return esz;
      }
    }
  }
  if (kind_ord == 8 && g_pipeline_asm_emit_module) {
    int32_t esz = glue_type_size_simple(g_pipeline_asm_emit_module, arena, tr, 0);
    if (esz > 0)
      return esz;
  }
  /** TYPE_VECTOR ord==13：v[i] 步长为 lane 元素宽（Vec4f→4），勿误落默认 8 导致错位。 */
  if (kind_ord == 13) {
    pointee = pipeline_type_elem_ref_at(arena, tr);
    if (pointee > 0)
      return glue_index_elem_byte_sz_from_type_ref_c(arena, pointee);
    return 4;
  }
  return 8;
}

/**
 * EXPR_INDEX：base+index 有效地址后 load（name_equal 的 a[i] 等；勿 ast_arena_expr_get）。
 *
 * wave357 Cap residual pure: when INDEX resolves to TYPE_ARRAY (multi-dim subrow
 * `a[i]` of `[N][M]T`), leave the element effective address in rax — do not load a
 * pointer/scalar. Nested `a[i][j]` then INDEX-loads the scalar from that address.
 * Root: prior always loaded esz (often 8) → garbage pointer → Ubuntu SIGSEGV.
 * PLATFORM: SHARED freestanding · LINUX gold.
 */
int32_t pipeline_asm_emit_index_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                             int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t base_ref;
  int32_t idx_ref;
  int32_t esz;
  int32_t res_ty;
  base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
  idx_ref = pipeline_expr_index_index_ref(arena, expr_ref);
  if (base_ref <= 0 || idx_ref <= 0)
    return -1;
  esz = pipeline_asm_index_elem_byte_sz_c(arena, expr_ref);
  if (pipeline_expr_kind_ord_at(arena, base_ref) == 3) {
    int32_t off;
    uint8_t vname[128];
    int32_t vlen;
    vlen = pipeline_expr_var_name_len(arena, base_ref);
    if (vlen <= 0 || vlen > 127)
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    pipeline_expr_var_name_into(arena, base_ref, vname);
    off = asm_ctx_local_find_offset((uint8_t *)ctx, vname, vlen);
    if (off < 0)
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  }
  if (glue_index_assign_addr_cache_hit(arena, ctx, base_ref, idx_ref, esz))
    return glue_index_load_from_cached_assign_addr_elf_c(elf_ctx, esz, ta);
  glue_index_assign_addr_cache_clear();
  if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, expr_ref, base_ref, idx_ref, ctx, ta, esz) != 0)
    return -1;
  /* Subarray address: multi-dim outer INDEX yields TYPE_ARRAY — no load. */
  res_ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (res_ty > 0 && pipeline_type_kind_ord_at(arena, res_ty) == 10)
    return 0;
  /*
   * wave692 Cap residual pure: INDEX result TYPE_SLICE (nested `rows[i]` of `[][]T`).
   * eff_addr left fat element home in the outer payload (stride 16). Load dual-GP
   * rvalue data@rax length@rdx so nested INDEX / let-alias matches VAR TYPE_SLICE.
   * Prior: esz=4 loaded eax half-pointer → Ubuntu SEGV; leave-addr alone left fat*
   * while length path for non-CALL assumed dual-GP or fat inconsistently.
   * G.7: complete same emit_index authority (TYPE_ARRAY leave / PTR load 8 twin).
   * Memory fat order: data@+0, length@+8 (C layout; both arches).
   * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
   */
  if (res_ty > 0 && pipeline_type_kind_ord_at(arena, res_ty) == GLUE_TYPE_KIND_SLICE) {
    /* rax = &fat; length first → arg_reg 2 (rdx/x1), then data@rax. */
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, 8, ta) != 0)
      return -1;
    if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
  }
  /* Large non-scalar esz (nested row) without TYPE_ARRAY stamp: keep address. */
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8)
    return 0;
  if (esz == 1)
    return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
  if (esz == 4)
    return backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
  return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
}

/**
 * EXPR_ADDR_OF：局部/形参 VAR 的 lea（&buf[0]、&buf 等）；勿 ast_arena_expr_get 慢路径。
 */
int32_t pipeline_asm_emit_addr_of_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t op;
  int32_t ok;
  uint8_t vname[128];
  int32_t vlen;
  int32_t off;
  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op <= 0)
    return -1;
  ok = pipeline_expr_kind_ord_at(arena, op);
  if (ok == 3) {
    vlen = pipeline_expr_var_name_len(arena, op);
    if (vlen <= 0 || vlen > 127)
      return -1;
    pipeline_expr_var_name_into(arena, op, vname);
    off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
    if (off < 0)
      off = asm_ctx_local_find_offset((uint8_t *)ctx, vname, vlen);
    if (off < 0)
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    /*
     * wave640 Cap residual pure: language-level `&var` is always the address of
     * the local/param *slot* (lea rbp+off). Prior path reused
     * glue_enc_local_slot_ptr_or_addr which *loads* *T / T[] param slots — correct
     * for INDEX/field base (`p[i]`, `p.f`) but wrong for ADDR_OF: `&p` became
     * equal to `p` when p:*T, so `let pp:**T = &p` stored the pointee pointer;
     * freestanding `**pp` / `(*(*pp)).v` then SEGV (host-C real &; pure-asm CTFE
     * folded 42). G.7: fix ADDR_OF authority only — do not change needs_ptr_load
     * (INDEX/field still load). PLATFORM: SHARED freestanding · LINUX gold.
     */
    return backend_enc_lea_rbp_to_rax_arch(elf_ctx, off, ta);
  }
  /** &ptr[i] / &arr[0]：INDEX 有效地址（7.3 字面量下标 add_imm / VAR+VAR 快速路径）。 */
  if (ok == 47) {
    int32_t base_ref = pipeline_expr_index_base_ref(arena, op);
    int32_t idx_ref = pipeline_expr_index_index_ref(arena, op);
    int32_t esz;
    if (base_ref <= 0 || idx_ref <= 0)
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    esz = pipeline_asm_index_elem_byte_sz_c(arena, op);
    return glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, op, base_ref, idx_ref, ctx, ta, esz);
  }
  /** &v.field / &ptr.field：直接复用 lvalue 有效地址路径。 */
  if (ok == 44)
    return pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, op, ctx, ta);
  /*
   * wave641 Cap residual pure: language-level `&(*p)` / `&(*(*pp))` — ADDR_OF of
   * EXPR_DEREF (ko=52). Prior path handled only VAR(3)/INDEX(47)/FIELD(44) →
   * UNHANDLED → freestanding CG002 (host-C emits `&(*(p))` → cancels to `p`;
   * pure-asm CTFE often folds). Semantics: address of the pointee *is* the
   * pointer value of the DEREF operand — same as wave324 lvalue_eff_addr for
   * DEREF assign lhs (`*p = …`). G.7: complete same ADDR_OF authority; reuse
   * lvalue_eff_addr (no second cancel path). PLATFORM: SHARED freestanding ·
   * LINUX gold · MACOS|ARM64 co-path.
   */
  if (ok == 52)
    return pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, op, ctx, ta);
  /* #region debug-point A:context-cg002-addr-of-fallback */
  if (link_abi_getenv("XLANG_ASM_DEBUG")) {
    fprintf(stderr, "xlang: addr_of elf fallback expr_ref=%d op_ref=%d op_kind=%d\n",
            (int)expr_ref, (int)op, (int)ok);
  }
  /* #endregion debug-point A:context-cg002-addr-of-fallback */
  return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
}

/**
 * wave323 Cap residual pure: EXPR_DEREF rvalue (ko==52).
 *
 * Root cause: rec had ADDR_OF (51) but no DEREF arm → fell through to
 * backend_emit_expr_elf_slow (weak/no-op or peel without load). Freestanding
 * then used the pointer bits as the value:
 *   return *p + 2  → lea p; add $2,%rax  (no mov (%rax),%eax) → exit garbage
 *   function load(p:*i32){ return *p } → ret with rdi pointer bits
 *
 * Authority (G.7): single ELF path next to ADDR_OF / INDEX load-after-addr.
 * Reuse backend_enc_load_{zext8,i32_indirect,64}_from_rax (no new encoder).
 * Width from DEREF resolved type via glue_index_elem_byte_sz_from_type_ref_c.
 * PLATFORM: SHARED emit / LINUX freestanding gold (mac host-gcc C hid via *(p)).
 */
int32_t pipeline_asm_emit_deref_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                      int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t op;
  int32_t tr;
  int32_t esz;
  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op <= 0)
    return -1;
  /* Pointer value into rax (VAR slot load, call result, nested deref, …). */
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, op, ctx, ta) != 0)
    return -1;
  tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  /*
   * wave636 Cap residual pure: DEREF of `*[N]T` / pointer-to-fixed-array yields
   * TYPE_ARRAY. Array "rvalue" is the base address (same bits as the pointer) for
   * subsequent INDEX `(*p)[i]`. Loading the first element (old path: esz=elem_sz)
   * then treating that scalar as a pointer → freestanding SEGV (mac/Ubuntu 138/139).
   * C twin: `T (*p)[N]; (*p)[i]` — *p does not load T, it designates the array.
   * G.7: single authority in this deref ELF path; host-C emit_type PTR→ARRAY separate.
   * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
   */
  if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == (int32_t)ast_TypeKind_TYPE_ARRAY)
    return 0;
  /*
   * wave640 Cap residual pure: DEREF result TYPE_PTR means load a *pointer value*
   * (8 bytes), not sizeof(pointee). glue_index_elem_byte_sz_from_type_ref peels
   * *T→sizeof(T) for pointer-base INDEX stride only — using it here for *pp
   * (pp:**T → result *T) yields esz=4 → half-pointer load → freestanding SEGV on
   * **pp / (*(*pp)).v / let q = *pp (host-C / pure-asm CTFE hid).
   * Twin of wave637 INDEX result TYPE_PTR → 8. G.7: complete same deref authority;
   * do not open a second nested-deref path.
   * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
   */
  if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == GLUE_TYPE_KIND_PTR)
    return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
  esz = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
  if (esz == 1)
    return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
  if (esz == 4)
    return backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
  return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
}
