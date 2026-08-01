/**
 * pipeline_asm_emit_with_arena.c — with_arena scope stack-arena emit domain
 * (BC 8.3.1 · wave1030).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding with_arena emit:
 * - GLUE_WA_SCOPE_STACK_MAX (16) + g_glue_wa_* globals (scope stack,
 *   temp_base/next, func_body_ref)
 * - glue_with_arena_scope_active_c (public; queried by seed
 *   backend_try_inline_dispatch default_alloc inliner)
 * - glue_with_arena_scope_top_off_c (public; returns top wa_off for
 *   default_alloc inline path)
 * - glue_wa_emit_begin_func_c (reset wa cursor at func emit entry; must
 *   run after fill_block_locals_tree)
 * - glue_wa_scope_alloc_off_c (allocate 24B Arena64 stack slot; 8-align;
 *   advances ly->next_offset past wa region)
 * - glue_wa_scope_push_c / glue_wa_scope_pop_c (scope stack push/pop)
 * - glue_emit_with_arena_init_elf (call heap_arena_init_c(a, cap))
 * - glue_emit_with_arena_deinit_elf (call heap_arena64_deinit_c(a))
 *
 * G.7: single product-mega with_arena emit face — do not open a second
 * stack-arena scope path outside this leaf.
 * Callers: pipeline_asm_emit_block_body.c (begin_func at L286; alloc/init/
 * push/deinit/pop at L679-690). Seed backend_try_inline_dispatch externs
 * call the two public scope-active/top-off accessors.
 *
 * Dependencies visible at #include site (L4738 in pipeline_glue.c):
 * - pipeline_asm_ctx_layout (glue L86; early)
 * - asm_sum_block_array_temp_bytes (glue L1658; early forward decl)
 * - pipeline_glue_AsmFuncCtxLayout (glue early typedef)
 * - backend_enc_*_arch (arch encoder; extern)
 * - pipeline_asm_emit_expr_elf_rec (forward decl in glue early block)
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c at the
 * former with_arena body site (before pipeline_asm_emit_block_body.c).
 *
 * PLATFORM: SHARED freestanding emit · LINUX+MACOS x86_64|arm64 via
 * backend_enc_*_arch ta parameter.
 */

/** MEM-C1: with_arena emit stack depth and current scope stack-arena offset
 * (for default_alloc inline). */
#define GLUE_WA_SCOPE_STACK_MAX 16
static int32_t g_glue_wa_scope_off_stack[GLUE_WA_SCOPE_STACK_MAX];
static int32_t g_glue_wa_scope_n;
static int32_t g_glue_wa_temp_base;
static int32_t g_glue_wa_temp_next;
static int32_t g_glue_wa_func_body_ref;

/** Whether currently inside a with_arena scope (backend_try_inline default_alloc). */
int32_t glue_with_arena_scope_active_c(void) {
  return g_glue_wa_scope_n > 0 ? 1 : 0;
}

/** Top with_arena temporary Arena64 rbp negative offset; 0 if no scope. */
int32_t glue_with_arena_scope_top_off_c(void) {
  return g_glue_wa_scope_n > 0 ? g_glue_wa_scope_off_stack[g_glue_wa_scope_n - 1] : 0;
}

/** Func body emit entry: reset wa temp cursor (must run after fill_block_locals_tree). */
static void glue_wa_emit_begin_func_c(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena, int32_t body_ref) {
  pipeline_glue_AsmFuncCtxLayout *ly;
  g_glue_wa_scope_n = 0;
  g_glue_wa_temp_next = 0;
  g_glue_wa_func_body_ref = body_ref;
  /**
   * Arena64 stack slot sits after all lets: next_offset is the previous
   * local slot_off (= lea base); must +24 before wa start to avoid
   * overlapping with Vec_u8 etc struct [fp-(off+sz),fp-off) ranges.
   */
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return;
  g_glue_wa_temp_base = ly->next_offset + asm_sum_block_array_temp_bytes(arena, body_ref) + 24;
}

/** Allocate stack Arena64 slot offset for this with_arena block (24B step, 8-align;
 * must run after all block-local lets). */
static int32_t glue_wa_scope_alloc_off_c(struct backend_AsmFuncCtx *ctx) {
  int32_t off = g_glue_wa_temp_base + g_glue_wa_temp_next;
  pipeline_glue_AsmFuncCtxLayout *ly;
  g_glue_wa_temp_next += 24;
  if (g_glue_wa_temp_next % 8 != 0)
    g_glue_wa_temp_next += 8 - (g_glue_wa_temp_next % 8);
  /** Consistent with compute_frame_size: cursor advances past wa region
   * to prevent subsequent fill from overlapping Arena64 slots. */
  if (ctx) {
    int32_t end = off + 24;
    if (end % 8 != 0)
      end += 8 - (end % 8);
    ly = pipeline_asm_ctx_layout(ctx);
    if (ly && end > ly->next_offset)
      ly->next_offset = end;
  }
  return off;
}

static void glue_wa_scope_push_c(int32_t wa_off) {
  if (g_glue_wa_scope_n >= GLUE_WA_SCOPE_STACK_MAX)
    return;
  g_glue_wa_scope_off_stack[g_glue_wa_scope_n++] = wa_off;
}

static void glue_wa_scope_pop_c(void) {
  if (g_glue_wa_scope_n > 0)
    g_glue_wa_scope_n--;
}

/** heap_arena_init_c(a, cap): a=rbp+wa_off, cap evaluated from cap_ref expr. */
static int32_t glue_emit_with_arena_init_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                             struct backend_AsmFuncCtx *ctx, int32_t wa_off, int32_t cap_ref,
                                             int32_t ta) {
  static const uint8_t init_sym[] = "heap_arena_init_c";
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, wa_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, cap_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, (uint8_t *)init_sym, (int32_t)(sizeof(init_sym) - 1), ta);
}

/** heap_arena64_deinit_c(a): release with_arena stack Arena64 chunks. */
static int32_t glue_emit_with_arena_deinit_elf(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t wa_off, int32_t ta) {
  static const uint8_t deinit_sym[] = "heap_arena64_deinit_c";
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, wa_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, (uint8_t *)deinit_sym, (int32_t)(sizeof(deinit_sym) - 1), ta);
}
