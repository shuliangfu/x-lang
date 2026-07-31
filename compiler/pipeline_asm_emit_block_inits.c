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
 * Callers (func body emit / mega_body) call this entry (same TU). Nested
 * helpers (glue_emit_*_let_init_elf_c) remain in pipeline_glue.c.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c before
 * block_body / block_if_stmt includes (definition order: inits before body).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

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
