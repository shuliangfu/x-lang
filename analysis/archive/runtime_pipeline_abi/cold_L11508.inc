/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
extern int32_t asm_ctx_local_find_offset(uint8_t *ctx, uint8_t *name, int32_t name_len);
extern int32_t asm_ctx_block_slot_get(uint8_t *ctx, int32_t block_ref);
extern int32_t pipeline_block_let_type_ref(void *arena, int32_t block_ref, int32_t let_idx);
extern int32_t asm_local_slot_reg_offset(void *arena, int32_t type_ref, int32_t off, int32_t *inout_off);
extern int32_t asm_ctx_local_append(uint8_t *ctx, uint8_t *name, int32_t name_len, int32_t offset);
extern int32_t asm_ctx_local_count(uint8_t *ctx);

int32_t glue_lazy_append_block_let_local(void *arena, void *ctx, int32_t block_ref, int32_t let_idx, uint8_t *name,
                                         int32_t name_len) {
  int32_t tref;
  int32_t off;
  int32_t slot_off;
  int32_t *ly_next;
  int32_t *ly_num;
  if (!arena || !ctx || !name || name_len <= 0 || block_ref <= 0 || let_idx < 0)
    return -1;
  /* LP64: next_offset@4, num_locals@8 on AsmFuncCtx layout overlay */
  ly_next = (int32_t *)((uint8_t *)ctx + 4);
  ly_num = (int32_t *)((uint8_t *)ctx + 8);
  if (asm_ctx_local_find_offset((uint8_t *)ctx, name, name_len) >= 0)
    return 0;
  if (asm_ctx_block_slot_get((uint8_t *)ctx, block_ref) >= 0)
    return 0;
  tref = pipeline_block_let_type_ref(arena, block_ref, let_idx);
  off = *ly_next;
  slot_off = asm_local_slot_reg_offset(arena, tref, off, &off);
  *ly_next = off;
  if (asm_ctx_local_append((uint8_t *)ctx, name, name_len, slot_off) < 0)
    return -1;
  *ly_num = asm_ctx_local_count((uint8_t *)ctx);
  return 0;
}
