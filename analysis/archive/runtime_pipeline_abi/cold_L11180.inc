/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
/* wave122 cold: with_arena scope BSS (fixed cap 16). */
static int32_t wave122_wa_scope_off_stack[16];
static int32_t wave122_wa_scope_n;
static int32_t wave122_wa_temp_base;
static int32_t wave122_wa_temp_next;
static int32_t wave122_wa_func_body_ref;

/* Cap residual faces used by pure leave (also available on host-cc product). */
extern int32_t asm_sum_block_array_temp_bytes(void *arena, int32_t block_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_call_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t ta);

int32_t glue_with_arena_scope_active_c(void) {
  return wave122_wa_scope_n > 0 ? 1 : 0;
}

int32_t glue_with_arena_scope_top_off_c(void) {
  return wave122_wa_scope_n > 0 ? wave122_wa_scope_off_stack[wave122_wa_scope_n - 1] : 0;
}

void glue_wa_emit_begin_func_c(void *ctx, void *arena, int32_t body_ref) {
  int32_t next_off;
  int32_t arr_temp;
  wave122_wa_scope_n = 0;
  wave122_wa_temp_next = 0;
  wave122_wa_func_body_ref = body_ref;
  if (!ctx)
    return;
  /* AsmFuncCtx.next_offset @4 (LP64). */
  next_off = (int32_t)((uint8_t *)ctx)[4]
           | ((int32_t)((uint8_t *)ctx)[5] << 8)
           | ((int32_t)((uint8_t *)ctx)[6] << 16)
           | ((int32_t)((uint8_t *)ctx)[7] << 24);
  arr_temp = arena ? asm_sum_block_array_temp_bytes(arena, body_ref) : 0;
  wave122_wa_temp_base = next_off + arr_temp + 24;
}

int32_t glue_wa_scope_alloc_off_c(void *ctx) {
  /* dest extra-arm dest-in-rbx dest_spill vs reserved wa window.
   * Same body as runtime_pipeline_abi.x (G.7 twin).
   * PLATFORM: SHARED dest extra-arm with_arena · LINUX gold. */
  int32_t off = wave122_wa_temp_base + wave122_wa_temp_next;
  int32_t end;
  int32_t cur = 0;
  uint8_t *b;
  if (ctx) {
    b = (uint8_t *)ctx;
    cur = (int32_t)b[4] | ((int32_t)b[5] << 8) | ((int32_t)b[6] << 16) | ((int32_t)b[7] << 24);
    /* x86 high-end dest_spill store is at rbp-cur; wa lea is 24B at
     * rbp-off. off==cur overlaps dest (Ubuntu memcpy dest=NULL).
     * PLATFORM: SHARED dest extra-arm dest_spill vs reserved wa. */
    if (off < (cur + 24))
      off = cur + 24;
  }
  wave122_wa_temp_next = off + 24 - wave122_wa_temp_base;
  if (wave122_wa_temp_next < 24)
    wave122_wa_temp_next = 24;
  if (wave122_wa_temp_next % 8 != 0)
    wave122_wa_temp_next += 8 - (wave122_wa_temp_next % 8);
  if (ctx) {
    end = off + 24;
    if (end % 8 != 0)
      end += 8 - (end % 8);
    b = (uint8_t *)ctx;
    if (end > cur) {
      b[4] = (uint8_t)(end & 255);
      b[5] = (uint8_t)((end >> 8) & 255);
      b[6] = (uint8_t)((end >> 16) & 255);
      b[7] = (uint8_t)((end >> 24) & 255);
    }
  }
  return off;
}

void glue_wa_scope_push_c(int32_t wa_off) {
  if (wave122_wa_scope_n >= 16)
    return;
  wave122_wa_scope_off_stack[wave122_wa_scope_n++] = wa_off;
}

void glue_wa_scope_pop_c(void) {
  if (wave122_wa_scope_n > 0)
    wave122_wa_scope_n--;
}

int32_t glue_emit_with_arena_init_elf(void *arena, void *elf_ctx, void *ctx, int32_t wa_off, int32_t cap_ref,
                                     int32_t ta) {
  static const uint8_t init_sym[] = "heap_arena_init_c";
  /* PLATFORM: SHARED — arm64 rax==x0: emit cap → arg1 before lea → arg0
   * (historical residual lea-first clobbers arena on MACOS|ARM64). */
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, cap_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, wa_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, (uint8_t *)init_sym, (int32_t)(sizeof(init_sym) - 1), ta);
}

int32_t glue_emit_with_arena_deinit_elf(void *elf_ctx, int32_t wa_off, int32_t ta) {
  static const uint8_t deinit_sym[] = "heap_arena64_deinit_c";
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, wa_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, (uint8_t *)deinit_sym, (int32_t)(sizeof(deinit_sym) - 1), ta);
}
