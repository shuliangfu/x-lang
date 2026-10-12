/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
extern int32_t ast_pipeline_block_if_cond_ref(void *arena, int32_t block_ref, int32_t if_idx);
extern int32_t ast_pipeline_block_if_then_body_ref(void *arena, int32_t block_ref, int32_t if_idx);
extern int32_t ast_pipeline_block_if_else_body_ref(void *arena, int32_t block_ref, int32_t if_idx);
extern void glue_asm_ctx_set_scope_block(void *ctx, int32_t block_ref);
extern int32_t glue_enc_jz_after_bool_in_eax(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern void backend_ensure_block_local_slots(void *ctx, void *arena, int32_t block_ref);
extern void pipeline_asm_fill_block_locals_tree(void *ctx, void *arena, int32_t block_ref);
extern int32_t pipeline_asm_emit_block_body_sync_elf(void *arena, void *elf_ctx, int32_t block_ref, void *ctx, int32_t ta);
extern void glue_block_fill_live_end_for_merge(void *arena, void *ctx, int32_t block_ref, void *out_live);
extern int glue_block_stmt_order_has_return(void *arena, int32_t block_ref);
extern void glue_live_fwd_copy_from_snap_before_if(void *dst_live);
extern void glue_asm_cache_invalidate_at_cfg_merge_selective(void *arena, void *ctx, int32_t branch_a, int32_t branch_b);
extern void glue_asm_if_phi_invalidate_both_branch_defs(void *arena, void *ctx, int32_t then_ref, int32_t else_ref);
extern void glue_asm_if_merge_live_union_from_ends(void *arena, void *ctx, void *then_live, void *else_live);
extern void pipeline_asm_fill_local_slots(void *ctx, void *arena, int32_t block_ref);
extern int32_t backend_emit_block_body_sync_elf(void *arena, void *elf_ctx, int32_t block_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_next_label_c(void *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t backend_enc_jmp_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_label_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_global, int32_t ta);
extern void *pipeline_asm_ctx_layout(void *ctx);

/* LP64 AsmFuncCtx: next_offset@4, num_locals@8 — match pure pipe_asm_ctx_off_*. */
static int32_t seed_pipe_load_i32_le(void *base, int32_t off) {
  const uint8_t *p = (const uint8_t *)base + off;
  return (int32_t)((uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24));
}
static void seed_pipe_store_i32_le(void *base, int32_t off, int32_t v) {
  uint8_t *p = (uint8_t *)base + off;
  p[0] = (uint8_t)(v & 0xff);
  p[1] = (uint8_t)((v >> 8) & 0xff);
  p[2] = (uint8_t)((v >> 16) & 0xff);
  p[3] = (uint8_t)((v >> 24) & 0xff);
}

int32_t pipeline_asm_emit_block_if_stmt_elf(void *arena, void *elf_ctx, int32_t cur_block, int32_t if_idx, void *ctx,
                                            int32_t ta, int32_t stmt_i) {
  int32_t cond_if;
  int32_t then_ref;
  int32_t else_ref;
  uint8_t else_lbl[256];
  uint8_t done_lbl[256];
  int32_t else_len;
  int32_t done_len;
  uint8_t then_live[136];
  uint8_t else_live[136];
  (void)stmt_i;
  if (!arena || !elf_ctx || !ctx || cur_block <= 0)
    return -1;
  glue_asm_ctx_set_scope_block(ctx, cur_block);
  cond_if = ast_pipeline_block_if_cond_ref(arena, cur_block, if_idx);
  then_ref = ast_pipeline_block_if_then_body_ref(arena, cur_block, if_idx);
  else_ref = ast_pipeline_block_if_else_body_ref(arena, cur_block, if_idx);
  if (cond_if == 0 || then_ref == 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, cond_if, ctx, ta) != 0)
    return -1;
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
  glue_asm_ctx_set_scope_block(ctx, then_ref);
  if (pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, then_ref, ctx, ta) != 0)
    return -1;
  glue_block_fill_live_end_for_merge(arena, ctx, then_ref, then_live);
  if (!glue_block_stmt_order_has_return(arena, then_ref)) {
    if (backend_enc_jmp_arch(elf_ctx, done_lbl, done_len, ta) != 0)
      return -1;
  }
  if (else_ref != 0) {
    if (backend_enc_label_arch(elf_ctx, else_lbl, else_len, 0, ta) != 0)
      return -1;
    backend_ensure_block_local_slots(ctx, arena, else_ref);
    pipeline_asm_fill_block_locals_tree(ctx, arena, else_ref);
    glue_asm_ctx_set_scope_block(ctx, else_ref);
    if (pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, else_ref, ctx, ta) != 0)
      return -1;
    glue_block_fill_live_end_for_merge(arena, ctx, else_ref, else_live);
  } else {
    glue_live_fwd_copy_from_snap_before_if(else_live);
  }
  if (backend_enc_label_arch(elf_ctx, done_lbl, done_len, 0, ta) != 0)
    return -1;
  glue_asm_cache_invalidate_at_cfg_merge_selective(arena, ctx, then_ref, else_ref);
  glue_asm_if_phi_invalidate_both_branch_defs(arena, ctx, then_ref, else_ref);
  glue_asm_if_merge_live_union_from_ends(arena, ctx, then_live, else_live);
  glue_asm_ctx_set_scope_block(ctx, cur_block);
  return 0;
}

int32_t pipeline_asm_emit_if_then_block_body_elf_c(void *arena, void *elf_ctx, int32_t then_block_ref, void *ctx,
                                                   int32_t ta) {
  int32_t sv_locs;
  int32_t sv_next;
  int32_t r;
  void *ly;
  if (!ctx || !arena || then_block_ref <= 0)
    return -1;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  sv_locs = seed_pipe_load_i32_le(ly, 8);
  sv_next = seed_pipe_load_i32_le(ly, 4);
  pipeline_asm_fill_local_slots(ctx, arena, then_block_ref);
  r = backend_emit_block_body_sync_elf(arena, elf_ctx, then_block_ref, ctx, ta);
  seed_pipe_store_i32_le(ly, 8, sv_locs);
  seed_pipe_store_i32_le(ly, 4, sv_next);
  return r;
}
