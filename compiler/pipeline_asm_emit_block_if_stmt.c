/**
 * pipeline_asm_emit_block_if_stmt.c — asm ELF block-level if-stmt emit domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding block-level if ELF emit:
 * - pipeline_asm_emit_block_if_stmt_elf (then-first + jz / else / done labels)
 * - parent scope restore for consecutive ifs; then/else body_sync + live-end
 *   merge + CFG merge cache / if-phi invalidate
 *
 * G.7: single product-mega block_if_stmt ELF path — do not open a second
 * then-first if emitter in seed partial or a parallel glue copy. Callers
 * (block_body_sync stmt_order if arm) call this entry (same TU). Nested
 * body_sync remains in pipeline_asm_emit_block_body.c.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after
 * pipeline_asm_emit_block_body.c and before expr field accessors.
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/**
 * 块级 if ELF 发射（then-first + jz）：避免 backend.x 经 xlang-c -E 后 jnz/else/then 顺序错乱，
 * 导致 cond 为真时跳进错误分支（escape/unescape 等 while 内 if 返回 -1）。
 */
int32_t pipeline_asm_emit_block_if_stmt_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t cur_block, int32_t if_idx, struct backend_AsmFuncCtx *ctx,
                                            int32_t ta, int32_t stmt_i) {
  int32_t cond_if;
  int32_t then_ref;
  int32_t else_ref;
  uint8_t else_lbl[128];
  uint8_t done_lbl[128];
  int32_t else_len;
  int32_t done_len;
  (void)stmt_i;
  if (!arena || !elf_ctx || !ctx || cur_block <= 0)
    return -1;
  /** 连续 if：进入每条 if 前恢复父块 scope（上一条 if 的 then 可能未还原）。 */
  glue_asm_ctx_set_scope_block((uint8_t *)ctx, cur_block);
  cond_if = ast_pipeline_block_if_cond_ref(arena, cur_block, if_idx);
  then_ref = ast_pipeline_block_if_then_body_ref(arena, cur_block, if_idx);
  else_ref = ast_pipeline_block_if_else_body_ref(arena, cur_block, if_idx);
  if (link_abi_getenv("XLANG_ASM_DEBUG") && g_pipeline_asm_emit_module && g_pipeline_asm_emit_func_index >= 0 &&
      pipeline_module_func_name_equal_at(g_pipeline_asm_emit_module, g_pipeline_asm_emit_func_index,
                                         (uint8_t *)"vec_u8_push", 11)) {
    int32_t ck = pipeline_expr_kind_ord_at(arena, cond_if);
    int32_t lr = pipeline_expr_binop_left_ref_at(arena, cond_if);
    int32_t rr = pipeline_expr_binop_right_ref_at(arena, cond_if);
    fprintf(stderr, "xlang: vec_u8_push block_if cond=%d kind=%d left=%d lk=%d right=%d rk=%d\n", (int)cond_if, (int)ck,
            (int)lr, lr > 0 ? (int)pipeline_expr_kind_ord_at(arena, lr) : -1, (int)rr,
            rr > 0 ? (int)pipeline_expr_kind_ord_at(arena, rr) : -1);
  }
  if (cond_if == 0 || then_ref == 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, cond_if, ctx, ta) != 0) {
    if (link_abi_getenv("XLANG_ASM_DEBUG"))
      fprintf(stderr, "xlang: if cond emit fail block=%d if_idx=%d cond_ref=%d\n", (int)cur_block, (int)if_idx,
              (int)cond_if);
    return -1;
  }
  else_len = pipeline_asm_emit_next_label_c(ctx, else_lbl, 64);
  done_len = pipeline_asm_emit_next_label_c(ctx, done_lbl, 64);
  if (else_len <= 0 || done_len <= 0)
    return -1;
  if (else_ref != 0) {
    if (glue_enc_jz_after_bool_in_eax(elf_ctx, else_lbl, else_len, ta) != 0)
      return -1;
  } else {
    if (glue_enc_jz_after_bool_in_eax(elf_ctx, done_lbl, done_len, ta) != 0)
      return -1;
  }
  backend_ensure_block_local_slots(ctx, arena, then_ref);
  pipeline_asm_fill_block_locals_tree(ctx, arena, then_ref);
  glue_asm_ctx_set_scope_block((uint8_t *)ctx, then_ref);
  {
    GlueBlockLiveFwd then_live_end;
    GlueBlockLiveFwd else_live_end;
    if (pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, then_ref, ctx, ta) != 0)
      return -1;
    glue_block_fill_live_end_for_merge(arena, ctx, then_ref, &then_live_end);
    /** then 已 return 时 done 落在 if 后语句上，不能再 jmp done（否则引号/无引号双路径）。 */
    if (!glue_block_stmt_order_has_return(arena, then_ref)) {
      if (backend_enc_jmp_arch(elf_ctx, done_lbl, done_len, ta) != 0)
        return -1;
    }
    if (else_ref != 0) {
      if (backend_enc_label_arch(elf_ctx, else_lbl, else_len, 0, ta) != 0)
        return -1;
      backend_ensure_block_local_slots(ctx, arena, else_ref);
      pipeline_asm_fill_block_locals_tree(ctx, arena, else_ref);
      glue_asm_ctx_set_scope_block((uint8_t *)ctx, else_ref);
      if (pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, else_ref, ctx, ta) != 0)
        return -1;
      glue_block_fill_live_end_for_merge(arena, ctx, else_ref, &else_live_end);
    } else
      glue_live_fwd_copy(&else_live_end, &glue_live_snap_before_if);
    if (backend_enc_label_arch(elf_ctx, done_lbl, done_len, 0, ta) != 0)
      return -1;
    glue_asm_cache_invalidate_at_cfg_merge_selective(arena, ctx, then_ref, else_ref);
    glue_asm_if_phi_invalidate_both_branch_defs(arena, ctx, then_ref, else_ref);
    glue_asm_if_merge_live_union_from_ends(arena, ctx, &then_live_end, &else_live_end);
  }
  /** 连续 if（with_arena 内 push 链）：then 体 emit 后 scope 仍停在 then 子块，须恢复 cur_block 否则后续 if 不落码。 */
  glue_asm_ctx_set_scope_block((uint8_t *)ctx, cur_block);
  return 0;
}
