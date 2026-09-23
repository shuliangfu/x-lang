/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
extern int32_t glue_array_temp_bytes_for_let_init(void *arena, int32_t let_type_ref, int32_t init_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_block_let_type_ref(void *arena, int32_t block_ref, int32_t let_idx);

void glue_align_next_offset(void *ctx) {
  int32_t *ly_next;
  int32_t off;
  int32_t m;
  if (!ctx)
    return;
  ly_next = (int32_t *)((uint8_t *)ctx + 4);
  off = *ly_next;
  m = off % 8;
  if (m != 0)
    *ly_next = off + (8 - m);
}

void pipeline_asm_bump_next_offset_for_array_lit(void *arena, int32_t expr_ref, void *ctx) {
  int32_t bytes;
  int32_t *ly_next;
  if (!ctx || expr_ref <= 0)
    return;
  ly_next = (int32_t *)((uint8_t *)ctx + 4);
  bytes = glue_array_temp_bytes_for_let_init(arena, pipeline_expr_resolved_type_ref(arena, expr_ref), expr_ref);
  if (bytes <= 0)
    return;
  *ly_next = *ly_next + bytes;
  glue_align_next_offset(ctx);
}

void pipeline_asm_bump_next_offset_after_let_init(void *arena, int32_t block_ref, int32_t let_idx, int32_t init_ref,
                                                   void *ctx) {
  int32_t tref;
  int32_t bytes;
  int32_t *ly_next;
  if (!ctx)
    return;
  ly_next = (int32_t *)((uint8_t *)ctx + 4);
  /* EXPR_ARRAY_LIT (46) already bumped; STRUCT_LIT (45) writes stack slot. */
  if (init_ref > 0) {
    int32_t iko = pipeline_expr_kind_ord_at(arena, init_ref);
    if (iko == 46 || iko == 45)
      return;
  }
  tref = pipeline_block_let_type_ref(arena, block_ref, let_idx);
  bytes = glue_array_temp_bytes_for_let_init(arena, tref, init_ref);
  if (bytes <= 0)
    return;
  *ly_next = *ly_next + bytes;
  glue_align_next_offset(ctx);
}
