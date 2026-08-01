/**
 * pipeline_asm_emit_next_offset.c — asm_func_ctx next_offset management domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via #include).
 * Authority for temp-area offset advancement after let-init / array-lit emission:
 * - glue_align_next_offset: 8-byte alignment bump of ctx->next_offset
 * - pipeline_asm_bump_next_offset_for_array_lit: post ARRAY_LIT emit offset advance
 * - pipeline_asm_bump_next_offset_after_let_init: post let-init offset advance
 *
 * Why: continuous `let a:u8[N]=[]; let b:[M]u8=[...]` declarations used to share
 * ctx.next_offset (csv main buf/line overlap caused escape writes corrupting
 * buf[1]); this family advances and aligns the temp cursor after each let init.
 *
 * Same-TU #include contract:
 * - MUST be #included AFTER pipeline_asm_emit_array_lit.c (provides static
 *   glue_array_temp_bytes_for_let_init + glue_fixed_array_temp_bytes via its own
 *   same-TU #include at glue.c L2260 < this file's #include point).
 * - MUST be #included BEFORE pipeline_asm_emit_block_inits.c /
 *   pipeline_asm_emit_block_body.c (consumers of bump_next_offset_*).
 * - Earlier consumers (return.c / assign.c / call_args.c) reach the public
 *   bump_* via the forward decl retained at glue.c L1840 (set before their
 *   respective #include points).
 *
 * Dependencies (all extern / same-TU visible at #include point):
 * - pipeline_asm_ctx_layout (accessor — extern decl earlier in glue.c)
 * - pipeline_glue_AsmFuncCtxLayout (typedef — extern decl earlier in glue.c)
 * - glue_array_temp_bytes_for_let_init (static, defined in
 *   pipeline_asm_emit_array_lit.c, visible via same-TU #include at L2260)
 * - pipeline_expr_resolved_type_ref / pipeline_expr_kind_ord_at /
 *   pipeline_block_let_type_ref (public pool accessors)
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/** Align ctx->next_offset up to an 8-byte boundary. */
static void glue_align_next_offset(struct backend_AsmFuncCtx *ctx) {
  pipeline_glue_AsmFuncCtxLayout *ly;
  int32_t m;
  if (!ctx)
    return;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return;
  m = ly->next_offset % 8;
  if (m != 0)
    ly->next_offset += (8 - m);
}

/**
 * Bump temp area after EXPR_ARRAY_LIT emit (called at emit_expr_elf_slow tail,
 * compile-time ctx). Avoids shared next_offset between successive array lits.
 */
void pipeline_asm_bump_next_offset_for_array_lit(struct ast_ASTArena *arena, int32_t expr_ref,
                                                 struct backend_AsmFuncCtx *ctx) {
  int32_t bytes;
  pipeline_glue_AsmFuncCtxLayout *ly;
  if (!ctx || expr_ref <= 0)
    return;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return;
  bytes = glue_array_temp_bytes_for_let_init(arena, pipeline_expr_resolved_type_ref(arena, expr_ref), expr_ref);
  if (bytes <= 0)
    return;
  ly->next_offset += bytes;
  glue_align_next_offset(ctx);
}

/**
 * Bump temp area after let-init emission. EXPR_ARRAY_LIT already bumped at
 * emit_expr_elf_slow tail; STRUCT_LIT let writes stack slot directly — both
 * skip the temp area and return early.
 */
void pipeline_asm_bump_next_offset_after_let_init(struct ast_ASTArena *arena, int32_t block_ref, int32_t let_idx,
                                                  int32_t init_ref, struct backend_AsmFuncCtx *ctx) {
  int32_t tref;
  int32_t bytes;
  pipeline_glue_AsmFuncCtxLayout *ly;
  if (!ctx)
    return;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return;
  /* EXPR_ARRAY_LIT (iko==46) already bumped in emit_expr_elf_slow;
   * STRUCT_LIT (iko==45) writes stack slot directly — skip temp area. */
  if (init_ref > 0) {
    int32_t iko = pipeline_expr_kind_ord_at(arena, init_ref);
    if (iko == 46 || iko == 45)
      return;
  }
  tref = pipeline_block_let_type_ref(arena, block_ref, let_idx);
  bytes = glue_array_temp_bytes_for_let_init(arena, tref, init_ref);
  if (bytes <= 0)
    return;
  ly->next_offset += bytes;
  glue_align_next_offset(ctx);
}
