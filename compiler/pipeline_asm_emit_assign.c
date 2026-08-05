/**
 * pipeline_asm_emit_assign.c — asm ELF EXPR_ASSIGN emit domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding assign ELF emit:
 * - glue_assign_lhs_f32_type_ref_elf_c (lhs f32 slot detect for float-lit RHS)
 * - glue_emit_assign_rhs_elf_c (RHS emit; f32 imm32 vs rec)
 * - glue_emit_assign_rhs_to_rax_elf_c (plain + compound assign value into rax;
 *   wave1016 G.7 fold from glue residual)
 * - pipeline_asm_emit_assign_elf_c (FIELD / INDEX / VAR / DEREF assign paths;
 *   slice dual-GP, fixed-array whole assign, STRUCT_LIT index in-place,
 *   esz>8 bulk copy — Cap residual pure waves 324–630)
 *
 * G.7: single product-mega assign ELF path — do not open a second assign
 * emitter in seed partial or a parallel glue copy. Callers (expr_elf_rec /
 * mega) call pipeline_asm_emit_assign_elf_c (same TU). Nested helpers still
 * outside this leaf: index try_*, lvalue_eff_addr, array_lit, struct_lit,
 * modlet store; binop rax/rbx helpers live in pipeline_asm_emit_binop.c
 * (forward-declared below; bodies after this include in the same TU).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after spill
 * (before array_lit / index / addr_of).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/* Forward decls for helpers defined later in the same TU (glue / binop leaf). */
/* wave124 pure-owned leave: live in runtime_pipeline_abi pure. */
extern int32_t glue_var_decl_type_ref_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                            int32_t var_expr_ref);
/* Compound-assign value path: nested load + add/sub/mul/div/shift helpers
 * (bodies in pipeline_asm_emit_binop.c including try_binop left_rax wave1018;
 * after this #include). Div-zero face: wave127 pure (pipeline_asm_emit_divisor_zero_check_rbx_elf_c extern). */
static int32_t glue_try_binop_left_rax_right_rbx_elf_c(struct ast_ASTArena *arena,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                        int32_t left_ref, int32_t right_ref,
                                                        struct backend_AsmFuncCtx *ctx, int32_t ta);
static int32_t glue_emit_binop_add_rax_rbx_elf_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   struct backend_AsmFuncCtx *ctx, int32_t left_ref,
                                                   int32_t right_ref, int32_t ta);
static int32_t glue_emit_binop_sub_rax_minus_rbx_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         struct backend_AsmFuncCtx *ctx, int32_t left_ref,
                                                         int32_t right_ref, int32_t ta);
static int32_t glue_emit_binop_mul_rax_rbx_elf_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   struct backend_AsmFuncCtx *ctx, int32_t left_ref,
                                                   int32_t right_ref, int32_t ta);
/* wave133 Cap residual: non-static (defs binop.c; pure unary leave links). */
int32_t glue_binop_operand_is_scalar_f32_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                               int32_t expr_ref);
int32_t glue_binop_operand_is_scalar_f64_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                               int32_t expr_ref);
static int32_t glue_binop_operand_is_unsigned_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                     int32_t left_ref, int32_t right_ref);
static int32_t glue_binop_operand_is_64bit_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                  int32_t left_ref, int32_t right_ref);
void pipeline_asm_bump_next_offset_for_array_lit(struct ast_ASTArena *arena, int32_t expr_ref,
                                                 struct backend_AsmFuncCtx *ctx);
int32_t pipeline_asm_emit_array_lit_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                          int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);

/**
 * assign 左值是否为 f32 槽：VAR / FIELD_ACCESS / INDEX resolved 类型。
 * 供 RHS 浮点字面量发 32-bit 位型（勿 f64 movabs 低 32 位截断为 0）。
 */
static int32_t glue_assign_lhs_f32_type_ref_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                   int32_t left_ref) {
  int32_t lko;
  int32_t tr;
  if (!arena || left_ref <= 0)
    return 0;
  lko = pipeline_expr_kind_ord_at(arena, left_ref);
  if (lko == 3) {
    tr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
    if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == GLUE_TYPE_KIND_F32_ORD)
      return tr;
  }
  if (lko == 44) {
    tr = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, left_ref);
    if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == GLUE_TYPE_KIND_F32_ORD)
      return tr;
  }
  if (lko == 47) {
    tr = pipeline_expr_resolved_type_ref(arena, left_ref);
    if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == GLUE_TYPE_KIND_F32_ORD)
      return tr;
  }
  return 0;
}

/**
 * assign RHS emit: lhs f32 + float lit uses imm32 (not CALL f64 widen).
 */
static int32_t glue_emit_assign_rhs_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                           int32_t left_ref, int32_t right_ref, struct backend_AsmFuncCtx *ctx,
                                           int32_t ta) {
  int32_t lhs_f32;
  if (!arena || right_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, right_ref) == 1) {
    lhs_f32 = glue_assign_lhs_f32_type_ref_elf_c(arena, ctx, left_ref);
    if (lhs_f32 > 0)
      return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, right_ref, ta, lhs_f32, 0);
  }
  return pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta);
}

/**
 * Plain / compound assign: materialize the value to write into lhs in rax.
 * Plain (ako==28) → RHS only; a+=10 etc → lhs op rhs via nested binop helpers.
 * Avoids EXPR_*_ASSIGN falling through backend_emit_expr_elf_slow and mutual
 * recursion SIGSEGV with expr_elf_rec.
 * wave1016 G.7: folded from pipeline_glue residual (same semantics).
 * PLATFORM: SHARED freestanding · f32/f64 compound reuse binop residual.
 */
static int32_t glue_emit_assign_rhs_to_rax_elf_c(struct ast_ASTArena *arena,
                                                  struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                  int32_t assign_expr_ref, int32_t left_ref, int32_t right_ref,
                                                  struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t ako;
  int32_t vr;
  if (!arena || !elf_ctx || !ctx || assign_expr_ref <= 0 || left_ref <= 0 || right_ref <= 0)
    return -1;
  ako = pipeline_expr_kind_ord_at(arena, assign_expr_ref);
  if (ako == 28)
    return glue_emit_assign_rhs_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
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
    if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0)
      return -1;
  }
  switch (ako) {
  case 29:
    return glue_emit_binop_add_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
  case 30:
    /* PLATFORM: SHARED — f64/f32 -= → subsd/subss (same residual as EXPR_SUB; not int sub). */
    return glue_emit_binop_sub_rax_minus_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
  case 31:
    return glue_emit_binop_mul_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta);
  case 32:
    /* PLATFORM: SHARED — f64 /= → divsd; f32 /= → divss (same residual as EXPR_DIV; not idiv). */
    if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, left_ref) &&
        glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref))
      return backend_enc_divsd_rax_rbx_arch(elf_ctx, ta);
    if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref) &&
        glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, right_ref))
      return backend_enc_divss_rax_rbx_arch(elf_ctx, ta);
    if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0)
      return -1;
    return backend_enc_idiv_rbx_arch(elf_ctx, ta);
  case 33:
    if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0)
      return -1;
    return backend_enc_rem_mod_arch(elf_ctx, ta);
  case 34:
    return backend_enc_and_rbx_rax_arch(elf_ctx, ta);
  case 35:
    return backend_enc_or_rbx_rax_arch(elf_ctx, ta);
  case 36:
    return backend_enc_xor_rbx_rax_arch(elf_ctx, ta);
  case 37: {
    int32_t is_64bit;
    glue_binop_var_slot_cache_clear();
    if (backend_enc_mov_rbx_to_ecx_arch(elf_ctx, ta) != 0)
      return -1;
    /* left only: compound assign shift width follows lhs type. */
    is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, 0);
    return is_64bit ? backend_enc_shl_cl_rax_arch(elf_ctx, ta) : backend_enc_shl_cl_eax_arch(elf_ctx, ta);
  }
  case 38: {
    /*
     * wave648 Cap residual pure: signed >>= must be SAR not logical SHR.
     * Same root as binop >> — host-C uses arithmetic shift; freestanding
     * always emitted SHR so `-16 >>= 2` stayed 0x3ffffffc (fs if-eq 0).
     * G.7: reuse unsigned + 64-bit helpers; u32/u64 keep SHR.
     * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
     */
    int32_t is_64bit;
    int32_t is_unsigned;
    glue_binop_var_slot_cache_clear();
    if (backend_enc_mov_rbx_to_ecx_arch(elf_ctx, ta) != 0)
      return -1;
    is_64bit = glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, 0);
    is_unsigned = glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, 0);
    if (is_unsigned)
      return is_64bit ? backend_enc_shr_cl_rax_arch(elf_ctx, ta) : backend_enc_shr_cl_eax_arch(elf_ctx, ta);
    return is_64bit ? backend_enc_sar_cl_rax_arch(elf_ctx, ta) : backend_enc_sar_cl_eax_arch(elf_ctx, ta);
  }
  default:
    return -1;
  }
}

/**
 * EXPR_ASSIGN ELF emit (p.a = ... etc; M8 must not use backend emit_lvalue_eff_addr_elf stub).
 */
int32_t pipeline_asm_emit_assign_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                       int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t lko;
  int32_t load_sz;
  int32_t esz;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -1;
  left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -1;
  lko = pipeline_expr_kind_ord_at(arena, left_ref);
  if (lko != 47)
    glue_index_assign_addr_cache_clear();
  if (lko == 44 && pipeline_expr_field_access_is_enum_variant(arena, left_ref) == 0) {
    int32_t base_ref = pipeline_expr_field_access_base_ref(arena, left_ref);
    int32_t field_off;
    /** 局部 VAR 基址字段：lea 基址 + str w0/[x1,#foff]（勿用 64 位 stur 以免覆盖相邻 i32 字段）。 */
    if (base_ref > 0 && pipeline_expr_kind_ord_at(arena, base_ref) == 3) {
      uint8_t vname[128];
      int32_t vlen;
      int32_t var_off;
      vlen = pipeline_expr_var_name_len(arena, base_ref);
      if (vlen <= 0 || vlen > 127)
        return -1;
      pipeline_expr_var_name_into(arena, base_ref, vname);
      var_off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
      if (var_off < 0)
        var_off = asm_ctx_local_find_offset((uint8_t *)ctx, vname, vlen);
      if (var_off < 0)
        return -1;
      field_off = glue_field_access_effective_offset_c(arena, g_pipeline_asm_emit_module, left_ref);
      load_sz = pipeline_expr_field_access_load_byte_sz(arena, g_pipeline_asm_emit_module, left_ref);
      if (load_sz <= 0)
        load_sz = 4;
      /** arm64 rbx=x1：须先 emit 右值→rax，再 lea/load 基址→x1，避免 AND 等写 w1 覆盖基址。 */
      if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0)
        return -1;
      if (glue_enc_local_slot_ptr_or_addr_rbx_elf_c(arena, elf_ctx, base_ref, var_off, ctx, ta) != 0)
        return -1;
      return backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, field_off, load_sz, ta);
    }
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    load_sz = pipeline_expr_field_access_load_byte_sz(arena, g_pipeline_asm_emit_module, left_ref);
    return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, load_sz, ta);
  }
  if (lko == 47) {
    int32_t base_ref;
    int32_t idx_ref;
    int32_t rko_idx;
    esz = pipeline_asm_index_elem_byte_sz_c(arena, left_ref);
    base_ref = pipeline_expr_index_base_ref(arena, left_ref);
    idx_ref = pipeline_expr_index_index_ref(arena, left_ref);
    if (base_ref <= 0 || idx_ref <= 0)
      return -1;
    /*
     * wave627/628/629 Cap residual pure: INDEX assign of STRUCT_LIT
     * (`a[i] = Pt{…}` / S24{…} on TYPE_ARRAY or TYPE_SLICE).
     *
     * Root (wave627 INT_LIT TYPE_ARRAY): generic path emit_expr STRUCT_LIT
     * (slot_off=-1) materializes at ly->next_offset without advancing high-end
     * top; after fixed TYPE_ARRAY alloc, next_offset aliases a[0]. Field stores
     * for a[1]=Pt{0,32} overwrite a[0], then finish_store bulk-copies 8B to a[1]
     * → Ubuntu pure-asm a[0].x+a[1].y=32 (host-C temps green). >8B also
     * store_rax width ≤8 → s24 lit asg run=3 before in-place.
     *
     * Root (wave628 var-index TYPE_ARRAY): same generic path leaves pointer in
     * rax and finish_store only writes 8B of that pointer into the element
     * (s24_var field a = stack addr bits; sum garbage). Assign-side scale
     * helper also falls back to ×8 for esz∉{1,4} so a[j] with esz=24 lands
     * mid-element.
     *
     * Root (wave629 TYPE_SLICE): wave628 gated only TYPE_ARRAY. Slice fat home
     * is dual-GP {data,length} — never a payload base. Generic path still
     * leaves temp pointer + finish_store ≤8 → pure-asm S24[] sum garbage
     * (host-C green; fixed TYPE_ARRAY already green via wave628).
     *
     * G.7: same in-place authority as wave626 vector_let STRUCT_LIT —
     * ① TYPE_ARRAY+INT_LIT: arch-aware rbp elem_home field writes (wave627)
     * ② TYPE_ARRAY non-lit OR TYPE_SLICE (any index): glue_emit_index_eff_addr
     *    scaled (loads .data for slice; general imul esz) → rbx, then fields
     *    with GLUE_STRUCT_LIT_DEST_IN_RBX (no rvalue / no bulk≤8)
     * PLATFORM: SHARED freestanding · LINUX|x86 high-end · MACOS|ARM64 low-end.
     */
    rko_idx = pipeline_expr_kind_ord_at(arena, right_ref);
    if (pipeline_expr_kind_ord_at(arena, expr_ref) == (int32_t)ast_ExprKind_EXPR_ASSIGN &&
        rko_idx == 45 && esz > 0 && pipeline_expr_kind_ord_at(arena, base_ref) == 3) {
      int32_t lit_imm;
      int32_t base_off;
      int32_t elem_home;
      int32_t base_tr;
      int32_t base_tk;
      base_tr = glue_var_decl_type_ref_elf_c(arena, ctx, base_ref);
      base_tk = (base_tr > 0) ? pipeline_type_kind_ord_at(arena, base_tr) : 0;
      if (base_tk == GLUE_TYPE_KIND_ARRAY) {
        /* wave627: compile-time index → rbp-relative field home. */
        if (pipeline_asm_expr_lit_i32_at_c(arena, idx_ref, &lit_imm)) {
          base_off = glue_var_expr_stack_off_elf_c(arena, ctx, base_ref);
          if (base_off >= 0) {
            elem_home = (ta == 1) ? (base_off + lit_imm * esz) : (base_off - lit_imm * esz);
            if (elem_home >= 0 &&
                pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, right_ref, ctx, ta,
                                                           elem_home) == 0) {
              glue_index_assign_addr_cache_clear();
              return 0;
            }
          }
        } else {
          /*
           * wave628: runtime index — eff_addr (handles general esz via imul, not
           * assign-side ×8 fallback) then field-write through rbx. Once entered,
           * hard-fail (no generic fall-through: rax/rbx already clobbered).
           */
          if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta,
                                                      esz) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
          if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
          if (pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, right_ref, ctx, ta,
                                                         GLUE_STRUCT_LIT_DEST_IN_RBX) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
          glue_index_assign_addr_cache_clear();
          return 0;
        }
      } else if (base_tk == GLUE_TYPE_KIND_SLICE) {
        /*
         * wave629: TYPE_SLICE INDEX STRUCT_LIT — always eff_addr + DEST_IN_RBX.
         * Fat home is {data@0,length@8}; INT_LIT must NOT use fat rbp as elem
         * base (that would smash length / miss durable data). Scaled path loads
         * .data then imul esz (same as wave628 non-lit TYPE_ARRAY). Once entered
         * hard-fail (rax/rbx already clobbered). Covers local dual-GP let and
         * formal slice* (glue_emit_index_eff_addr_base loads via needs_ptr_load).
         */
        if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta,
                                                    esz) != 0) {
          glue_index_assign_addr_cache_clear();
          return -1;
        }
        if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
          glue_index_assign_addr_cache_clear();
          return -1;
        }
        if (pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, right_ref, ctx, ta,
                                                       GLUE_STRUCT_LIT_DEST_IN_RBX) != 0) {
          glue_index_assign_addr_cache_clear();
          return -1;
        }
        glue_index_assign_addr_cache_clear();
        return 0;
      }
    }
    /*
     * wave630 Cap residual pure: non-STRUCT_LIT INDEX assign with esz>8
     * (`a[i]=t` / `a[j]=a[i]` / `a[i]=mk()` / S12 esz=12).
     *
     * Root (Ubuntu pure-asm; host-C green; arm64 low-end often masks):
     *  1) assign-side try_* ends in rbx_plus_index_scratch_scaled which only
     *     scales {1,4,8} — esz=12/24 falls to ×8 → mid-element dest
     *  2) finish_store store_rax_to_rbx_indirect width ≤8; rhs VAR of large
     *     struct loads first qword only → s24_asg run=14 (=1+10+3)
     * G.7: ① src address (lvalue lea / CALL materialize into temp via
     *   glue_emit_struct_type_let_init) ② dest via glue_emit_index_eff_addr_scaled
     *   (general imul esz; TYPE_SLICE .data) ③ chunked bulk copy (no ≤8 store).
     * Once entered hard-fail (rax/rbx already used). STRUCT_LIT still above.
     * PLATFORM: SHARED freestanding · LINUX|x86 high-end · MACOS|ARM64 low-end.
     */
    if (esz > 8) {
      int32_t rko_bulk;
      int32_t src_spill;
      int32_t dst_spill;
      int32_t temp_home;
      int32_t nbytes;
      int32_t rc_bulk;
      pipeline_glue_AsmFuncCtxLayout *ly_bulk;
      rko_bulk = pipeline_expr_kind_ord_at(arena, right_ref);
      if (rko_bulk == 3 || rko_bulk == 44 || rko_bulk == 47 || rko_bulk == 48 || rko_bulk == 49) {
        ly_bulk = pipeline_asm_ctx_layout(ctx);
        if (!ly_bulk) {
          glue_index_assign_addr_cache_clear();
          return -1;
        }
        /* Two pointer spills (src, dst); 16B each for dual-GP slot alignment. */
        if (ly_bulk->next_offset + 32 < ly_bulk->next_offset) {
          glue_index_assign_addr_cache_clear();
          return -1;
        }
        ly_bulk->next_offset += 16;
        src_spill = ly_bulk->next_offset;
        ly_bulk->next_offset += 16;
        dst_spill = ly_bulk->next_offset;
        temp_home = -1;
        if (rko_bulk == 3 || rko_bulk == 44 || rko_bulk == 47) {
          if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
        } else {
          /* CALL/METHOD: materialize return into temp then copy (sret / dual-GP). */
          nbytes = (esz + 7) & ~7;
          if (ly_bulk->next_offset + nbytes < ly_bulk->next_offset) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
          ly_bulk->next_offset += nbytes;
          temp_home = ly_bulk->next_offset;
          rc_bulk = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0, temp_home);
          if (rc_bulk != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
          if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_home, ta) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta) != 0) {
            glue_index_assign_addr_cache_clear();
            return -1;
          }
        }
        if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta,
                                                    esz) != 0) {
          glue_index_assign_addr_cache_clear();
          return -1;
        }
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta) != 0) {
          glue_index_assign_addr_cache_clear();
          return -1;
        }
        if (glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, esz, ta) != 0) {
          glue_index_assign_addr_cache_clear();
          return -1;
        }
        glue_index_assign_addr_cache_clear();
        return 0;
      }
    }
    /** arm64 rbx=x1：先 emit 右值→rax，再 INDEX 址→rbx（字面量/变量下标直路径免 x2）。 */
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0) {
      glue_index_assign_addr_cache_clear();
      return -1;
    }
    /** 右值已在 rax；INDEX 址计算会占用 rax，先 push 栈上保留（finish_store pop 后写 [rbx]）。 */
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) {
      glue_index_assign_addr_cache_clear();
      return -1;
    }
    /** rhs INDEX/FIELD/binop 等可能改写 x1：须失效上一笔 INDEX assign 留下的 rbx 有效址。 */
    if (glue_expr_emit_may_clobber_rbx_elf_c(arena, right_ref))
      glue_index_assign_addr_cache_clear();
    if (glue_index_assign_addr_cache_hit(arena, ctx, base_ref, idx_ref, esz))
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    /*
     * wave630: assign-side try_* use rbx_plus_index_scratch_scaled which only
     * scales {1,4,8}. esz∉{1,4,8} (e.g. 12,24) must skip try_* → fall through
     * to glue_emit_index_eff_addr_scaled (general imul). lit path multiplies
     * esz correctly but still only for ≤8 store widths in finish_store.
     */
    if (esz == 1 || esz == 4 || esz == 8) {
      if (glue_try_index_var_lit_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_plus_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_plus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_minus_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_minus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_mul_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_plus_var_plus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_minus_var_plus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_minus_var_minus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_minus_add3_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_plus_var_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_minus_var_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_add3_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_subadd3_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_subsub3_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
      if (glue_try_index_var_minus_add3_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0)
        return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    glue_index_assign_addr_cache_clear();
    if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
  }
  if (lko == 3) {
    uint8_t vname[128];
    int32_t vlen;
    int32_t off;
    int32_t is_modlet;
    int32_t ltr_pre;
    int32_t ltk_pre;
    int32_t rko_pre;
    vlen = pipeline_expr_var_name_len(arena, left_ref);
    if (vlen <= 0 || vlen > 127)
      return -1;
    pipeline_expr_var_name_into(arena, left_ref, vname);
    glue_index_scratch_spill_invalidate_var(arena, elf_ctx, ctx, left_ref, ta);
    is_modlet = pipeline_asm_modlet_name_is_shared(vname, vlen);
    off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
    if (off < 0)
      off = asm_ctx_local_find_offset((uint8_t *)ctx, vname, vlen);
    if (off < 0 && is_modlet == 0)
      return -1;
    /** 写 a 前失效 a 的槽命中，避免 rhs 仍用旧缓存。 */
    if (off >= 0)
      glue_binop_var_slot_cache_invalidate_slot(off);
    /*
     * wave331: TYPE_SLICE + ARRAY_LIT assign — reserve temp past dual-GP home before
     * emit so payload never overwrites data@off / length@off-8 (empty→lit path).
     * G.7: same dual store as glue_emit_slice_from_array_let_init_elf_c.
     * PLATFORM: SHARED freestanding · LINUX gold.
     */
    ltr_pre = (off >= 0) ? glue_var_decl_type_ref_elf_c(arena, ctx, left_ref) : 0;
    ltk_pre = (ltr_pre > 0) ? pipeline_type_kind_ord_at(arena, ltr_pre) : 0;
    rko_pre = pipeline_expr_kind_ord_at(arena, right_ref);
    if (is_modlet == 0 && off >= 0 && ltk_pre == GLUE_TYPE_KIND_SLICE &&
        rko_pre == (int32_t)ast_ExprKind_EXPR_ARRAY_LIT &&
        pipeline_expr_kind_ord_at(arena, expr_ref) == (int32_t)ast_ExprKind_EXPR_ASSIGN) {
      int32_t n_arr;
      pipeline_glue_AsmFuncCtxLayout *ly = pipeline_asm_ctx_layout(ctx);
      n_arr = pipeline_expr_array_lit_num_elems_at(arena, right_ref);
      if (n_arr < 0 || n_arr > GLUE_ARRAY_LIT_MAX_ELEMS)
        return -1;
      glue_slice_dual_gp_bump_past_home_c(ctx, off, ta);
      if (pipeline_asm_emit_array_lit_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off, ta) != 0)
        return -1;
      if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_arr, 0, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(off, ta), ta) != 0)
        return -1;
      if (n_arr > 0)
        pipeline_asm_bump_next_offset_for_array_lit(arena, right_ref, ctx);
      glue_binop_var_slot_cache_kill_def_at_slot(off);
      return 0;
    }
    /*
     * wave334 Cap residual pure: TYPE_ARRAY whole-array assign (`a = [4,5,6]` / `a = b`).
     * wave354: also `a = b.f` (FIELD) / `a = fill(n)` (CALL) — same element-wise authority.
     *
     * Root: generic path emit_array_lit → rax=temp-ptr then store_rax_to_rbp(off)
     * overwrites the first 8 bytes of the fixed array with that pointer (Ubuntu run
     * garbage / mac host-C rejects `int[N] = …` as not assignable).
     *
     * Authority (G.7): glue_struct_lit_store_fixed_array_field_elf_c / fixed_array_type_let
     * (ARRAY_LIT / VAR / FIELD / CALL → element-wise into LHS slot; no pointer store).
     * PLATFORM: SHARED freestanding emit · LINUX gold · MACOS host-C uses memcpy.
     */
    if (is_modlet == 0 && off >= 0 && ltk_pre == GLUE_TYPE_KIND_ARRAY &&
        pipeline_expr_kind_ord_at(arena, expr_ref) == (int32_t)ast_ExprKind_EXPR_ASSIGN) {
      int32_t arr_st =
          glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr_pre, off);
      if (arr_st == 0) {
        glue_binop_var_slot_cache_kill_def_at_slot(off);
        return 0;
      }
      if (arr_st == -1)
        return -1;
      /* -2: fall through to generic assign (unsupported RHS for fixed array). */
    }
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0)
      return -1;
    /* Module shared mutable let: store to text cell (true cross-fn). Prefer over stack. */
    if (is_modlet != 0) {
      if (pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx, vname, vlen, ta) != 0)
        return -1;
      if (off >= 0)
        glue_binop_var_slot_cache_kill_def_at_slot(off);
      return 0;
    }
    {
      int32_t ltr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
      int32_t rty = glue_float_promote_src_ty_ref_c(arena, right_ref);
      int32_t ltk;
      /* wave314: f32 RHS → f64 LHS promote before store. */
      if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, ltr, rty, ta) != 0)
        return -1;
      ltk = (ltr > 0) ? pipeline_type_kind_ord_at(arena, ltr) : 0;
      /*
       * wave331 Cap residual pure: TYPE_SLICE VAR assign dual-GP home (non-ARRAY_LIT).
       * Root: VAR assign only store_rax_to_rbp → length half stale.
       * Ubuntu freestanding `a=b` kept old length.
       * wave394: length half arch-aware (glue_slice_dual_gp_length_off_c).
       * Authority (G.7): dual-load leaves rax+rdx; store both halves.
       * PLATFORM: SHARED layout · LINUX freestanding gold · MACOS host-C uses compound.
       */
      if (ltk == GLUE_TYPE_KIND_SLICE) {
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off, ta) != 0)
          return -1;
        if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(off, ta), ta) !=
            0)
          return -1;
      } else if (ltr > 0 && ltk == GLUE_TYPE_KIND_F32_ORD) {
        if (backend_enc_store_eax_to_rbp_arch(elf_ctx, off, ta) != 0)
          return -1;
      } else if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off, ta) != 0) {
        return -1;
      }
    }
    glue_binop_var_slot_cache_kill_def_at_slot(off);
    return 0;
  }
  /**
   * wave324 Cap residual pure: *p = rhs / *p += … (EXPR_DEREF lhs, ko==52).
   *
   * Root: assign handled VAR(3)/FIELD(44)/INDEX(47) only → DEREF lhs returned -1
   * → freestanding CG002 (code_len tiny, no main). mac host-gcc C *(p)= hid it.
   *
   * Authority (G.7): same dual-slot store as FIELD (rhs→rax, push, addr→rbx, pop,
   * store [rbx]). Addr via lvalue_eff_addr (operand pointer, no load). Width from
   * DEREF resolved type — same helper as wave323 load path.
   * PLATFORM: SHARED emit / LINUX freestanding gold.
   */
  if (lko == 52) {
    int32_t store_sz;
    int32_t tr;
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    tr = pipeline_expr_resolved_type_ref(arena, left_ref);
    store_sz = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
    if (store_sz <= 0)
      store_sz = 4;
    return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, store_sz, ta);
  }
  return -1;
}

/**
 * Extract the pair base VAR ref from a field-assign expression.
 *
 * Why: fold/affine pattern detection (glue_match_struct_pair_n2_body_pattern)
 * needs the base VAR of `p.a = ...` (FIELD_ASSIGN left = FIELD_ACCESS, base =
 * VAR). This helper centralizes the EXPR_FIELD_ASSIGN(28) → left(44) → base
 * traversal so callers don't repeat kind_ord checks.
 *
 * Invariant: returns 0 for non-field-assign or NULL arena; otherwise the
 * base VAR expr_ref from pipeline_expr_field_access_base_ref.
 *
 * Asm/Perf: O(1) — 3 accessor calls. Cold path — called per body stmt in
 * pattern match (glue.c:6664).
 *
 * PLATFORM: SHARED — pattern detection is platform-independent.
 *
 * wave1068 G.7: migrated from glue.c:6499 (body 8 LOC). Static
 * (non-extern): same-TU — asm_emit_assign.c #include L2294 < def L6499 <
 * callsite L6664. Deps: pipeline_expr_kind_ord_at /
 * pipeline_expr_binop_left_ref_at / pipeline_expr_field_access_base_ref
 * (all extern).
 */
static int32_t glue_field_assign_pair_base_ref_c(struct ast_ASTArena *arena, int32_t er) {
  int32_t left_ref;
  if (!arena || er <= 0 || pipeline_expr_kind_ord_at(arena, er) != 28)
    return 0;
  left_ref = pipeline_expr_binop_left_ref_at(arena, er);
  if (pipeline_expr_kind_ord_at(arena, left_ref) != 44)
    return 0;
  return pipeline_expr_field_access_base_ref(arena, left_ref);
}

/**
 * Get the si-th expr stmt ref in a block (handles stmt_order + pure
 * expr_stmts sub-block).
 *
 * Why: fold/affine pattern match iterates body expr stmts; some blocks use
 * stmt_order (mixed let/expr) and others use pure expr_stmts. This helper
 * normalizes the two paths so callers see a uniform indexed sequence.
 *
 * Invariant: returns 0 for NULL arena / invalid body / non-expr stmt at
 * si; otherwise writes the expr_ref to *out_er and returns 1.
 *
 * Asm/Perf: O(1) — 2-3 accessor calls. Cold path — called per body stmt
 * in pattern match (glue.c:6657).
 *
 * PLATFORM: SHARED — block traversal is platform-independent.
 *
 * wave1069 G.7: migrated from glue.c:6604 (body 15 LOC). Static
 * (non-extern): same-TU — asm_emit_assign.c #include L2294 < def L6604 <
 * callsite L6657. Deps: ast_ast_block_stmt_order_kind /
 * ast_ast_block_stmt_order_idx / ast_pipeline_block_expr_stmt_ref
 * (all extern).
 */
static int32_t glue_body_expr_stmt_at_c(struct ast_ASTArena *arena, int32_t body_ref, int32_t si, int32_t nso,
                                        int32_t *out_er) {
  int32_t er;
  if (!arena || body_ref <= 0 || !out_er)
    return 0;
  if (nso > 0) {
    if (ast_ast_block_stmt_order_kind(arena, body_ref, si) != 2)
      return 0;
    er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, ast_ast_block_stmt_order_idx(arena, body_ref, si));
  } else {
    er = ast_pipeline_block_expr_stmt_ref(arena, body_ref, si);
  }
  if (er <= 0)
    return 0;
  *out_er = er;
  return 1;
}
