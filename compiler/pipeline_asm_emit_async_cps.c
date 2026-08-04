/**
 * pipeline_asm_emit_async_cps.c — asm ELF async/await CPS emit domain
 * (BC 8.3.1 · wave1028).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding async CPS emit:
 * - GlueAsyncCpsEmitState (per-function emit state: active, fn_id, phase,
 *   resume label, live-var layout)
 * - g_glue_async_cps_emit (singleton state; memset per func entry/end)
 * - glue_async_cps_mov_imm32_to_rax (imm32 → rax/x0; wraps backend_enc)
 * - glue_async_cps_emit_frame_phase_ptr (call xlang_async_asm_frame_phase_by_id)
 * - glue_async_cps_call_frame_memop (call frame store/load helper, 4 args)
 * - glue_async_cps_save_live (save all live vars to frame data area)
 * - glue_async_cps_restore_live (restore all live vars from frame data area)
 * - glue_async_cps_emit_after_await (await boundary: save → suspend →
 *   resume label or return SUSPENDED; uses glue_enc_jz_after_bool_in_eax)
 * - glue_async_cps_emit_phase_reset (return前 reset coroutine phase;
 *   preserve rax via push/pop)
 * - pipeline_asm_emit_async_cps_entry_elf_c (prologue后 phase dispatch:
 *   phase==1 → jump to resume label; else continue from phase 0)
 * - pipeline_asm_emit_async_cps_end_func_elf_c (func emit end: clear CPS state)
 *
 * G.7: single product-mega async CPS ELF face — do not open a second async
 * CPS emit path outside this leaf.
 * Callers: as.c (glue_async_cps_emit_phase_reset before return);
 * return.c (glue_async_cps_emit_phase_reset); block_body.c
 * (glue_async_cps_emit_after_await at await boundary); glue residual
 * (pipeline_asm_emit_async_cps_entry_elf_c / end_func from func emit entry).
 *
 * Dependencies visible at #include site (L2103 in pipeline_glue.c, after
 * unary.c which provides glue_enc_jz_after_bool_in_eax):
 * - async_asm_pool.h (AsyncAsmPoolLayout / AsyncAsmPoolLiveVar)
 * - backend_enc_* (arch encoder surface; extern)
 * - pipeline_asm_ctx_layout / pipeline_glue_AsmFuncCtxLayout (glue early)
 * - asm_ctx_local_find_offset (glue early)
 * - pipeline_asm_emit_next_label_c (ctx helper)
 * - pipeline_module_func_is_async_at (extern below)
 * - glue_enc_jz_after_bool_in_eax (defined in pipeline_asm_emit_unary.c,
 *   #included earlier at L2097)
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c at the
 * former async CPS body site (after pipeline_asm_emit_as.c; before
 * pipeline_asm_emit_logand.c).
 *
 * PLATFORM: SHARED freestanding emit · LINUX+MACOS x86_64 SysV ·
 * MACOS|ARM64 AAPCS64 (arch dispatch via backend_enc_*_arch ta parameter).
 */

/** WPO-S3 asm CPS emit context (valid during single function emit). */
typedef struct {
  int32_t active;
  int32_t ta;
  uint32_t fn_id;
  int32_t next_phase;
  AsyncAsmPoolLayout layout;
  uint8_t resume_label[128];
  int32_t resume_label_len;
} GlueAsyncCpsEmitState;

static GlueAsyncCpsEmitState g_glue_async_cps_emit;

extern int32_t pipeline_module_func_is_async_at(struct ast_Module *m, int32_t fi);

/** Load imm32 into rax/x0 (fn_id etc.). */
static int32_t glue_async_cps_mov_imm32_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm,
                                               int32_t ta) {
  return backend_enc_mov_imm64_to_rax_arch(elf_ctx, imm, 0, ta);
}

/** Call xlang_async_asm_frame_phase_by_id(fn_id); result phase pointer in rax. */
static int32_t glue_async_cps_emit_frame_phase_ptr(struct platform_elf_ElfCodegenCtx *elf_ctx, uint32_t fn_id,
                                                   int32_t ta) {
  static const uint8_t nm[] = "xlang_async_asm_frame_phase_by_id";
  if (glue_async_cps_mov_imm32_to_rax(elf_ctx, (int32_t)fn_id, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, (uint8_t *)nm, (int32_t)(sizeof(nm) - 1), ta);
}

/** Call frame store/load helper: arg0=fn_id, arg1=data_off, arg2=ptr, arg3=nbytes. */
static int32_t glue_async_cps_call_frame_memop(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *cname,
                                               int32_t cname_len, uint32_t fn_id, int32_t data_off, int32_t stack_off,
                                               int32_t nbytes, int32_t ta) {
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
    return -1;
  if (glue_async_cps_mov_imm32_to_rax(elf_ctx, nbytes, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 3, ta) != 0)
    return -1;
  if (glue_async_cps_mov_imm32_to_rax(elf_ctx, data_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (glue_async_cps_mov_imm32_to_rax(elf_ctx, (int32_t)fn_id, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, cname, cname_len, ta);
}

/** Save all live vars in layout to frame data area. */
static int32_t glue_async_cps_save_live(struct platform_elf_ElfCodegenCtx *elf_ctx, struct backend_AsmFuncCtx *ctx,
                                        int32_t ta) {
  int32_t i;
  static const uint8_t store_nm[] = "xlang_async_asm_frame_store_from_ptr";
  for (i = 0; i < g_glue_async_cps_emit.layout.num_live; i++) {
    const AsyncAsmPoolLiveVar *lv = &g_glue_async_cps_emit.layout.live[i];
    int32_t stack_off = asm_ctx_local_find_offset((uint8_t *)ctx, (uint8_t *)lv->name, lv->name_len);
    if (stack_off < 0)
      return -1;
    if (glue_async_cps_call_frame_memop(elf_ctx, (uint8_t *)store_nm, (int32_t)(sizeof(store_nm) - 1),
                                        g_glue_async_cps_emit.fn_id, lv->frame_data_off, stack_off, lv->size_bytes,
                                        ta) != 0)
      return -1;
  }
  return 0;
}

/** Restore all live vars from frame data area to stack slots. */
static int32_t glue_async_cps_restore_live(struct platform_elf_ElfCodegenCtx *elf_ctx, struct backend_AsmFuncCtx *ctx,
                                           int32_t ta) {
  int32_t i;
  static const uint8_t load_nm[] = "xlang_async_asm_frame_load_to_ptr";
  for (i = 0; i < g_glue_async_cps_emit.layout.num_live; i++) {
    const AsyncAsmPoolLiveVar *lv = &g_glue_async_cps_emit.layout.live[i];
    int32_t stack_off = asm_ctx_local_find_offset((uint8_t *)ctx, (uint8_t *)lv->name, lv->name_len);
    if (stack_off < 0)
      return -1;
    if (glue_async_cps_call_frame_memop(elf_ctx, (uint8_t *)load_nm, (int32_t)(sizeof(load_nm) - 1),
                                        g_glue_async_cps_emit.fn_id, lv->frame_data_off, stack_off, lv->size_bytes,
                                        ta) != 0)
      return -1;
  }
  return 0;
}

/** Await boundary: save live → suspend → emit resume label or return SUSPENDED. */
static int32_t glue_async_cps_emit_after_await(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                               struct backend_AsmFuncCtx *ctx, int32_t ta) {
  pipeline_glue_AsmFuncCtxLayout *ly;
  static const uint8_t suspend_nm[] = "xlang_async_cps_suspend";
  int32_t next_ph;
  if (!g_glue_async_cps_emit.active)
    return 0;
  (void)arena;
  next_ph = g_glue_async_cps_emit.next_phase++;
  if (glue_async_cps_save_live(elf_ctx, ctx, ta) != 0)
    return -1;
  if (glue_async_cps_emit_frame_phase_ptr(elf_ctx, g_glue_async_cps_emit.fn_id, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  if (glue_async_cps_mov_imm32_to_rax(elf_ctx, next_ph, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_call_arch(elf_ctx, (uint8_t *)suspend_nm, (int32_t)(sizeof(suspend_nm) - 1), ta) != 0)
    return -1;
  /** suspend returns 0 → resume; x86 must test eax, arm64 cbz reads w0 directly
   * (glue_enc_jz_after_bool_in_eax). */
  if (glue_enc_jz_after_bool_in_eax(elf_ctx, g_glue_async_cps_emit.resume_label, g_glue_async_cps_emit.resume_label_len,
                                    ta) != 0)
    return -1;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly || ly->tail_join_label_len <= 0)
    return -1;
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, (int32_t)0x41535700, ta) != 0)
    return -1;
  if (backend_enc_jmp_arch(elf_ctx, ly->tail_join_label, ly->tail_join_label_len, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, g_glue_async_cps_emit.resume_label, g_glue_async_cps_emit.resume_label_len, 0,
                             ta) != 0)
    return -1;
  return glue_async_cps_restore_live(elf_ctx, ctx, ta);
}

/** Reset coroutine phase before return (must preserve rax return value; reset_by_id clobbers). */
static int32_t glue_async_cps_emit_phase_reset(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t reset_nm[] = "xlang_async_asm_frame_reset_by_id";
  if (!g_glue_async_cps_emit.active)
    return 0;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (glue_async_cps_mov_imm32_to_rax(elf_ctx, (int32_t)g_glue_async_cps_emit.fn_id, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  if (backend_enc_call_arch(elf_ctx, (uint8_t *)reset_nm, (int32_t)(sizeof(reset_nm) - 1), ta) != 0)
    return -1;
  return backend_enc_pop_rax_arch(elf_ctx, ta);
}

/**
 * After prologue/param_home: async+await function emit phase dispatch (x86_64 / arm64 / riscv64).
 * phase==1 → jump to resume label and restore live; otherwise continue from phase 0.
 * When no await is present, async_asm_pool_build_layout returns non-0 and this function is no-op.
 */
int32_t pipeline_asm_emit_async_cps_entry_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                struct backend_AsmFuncCtx *ctx, struct ast_Module *mod,
                                                int32_t func_index, int32_t ta) {
  int32_t lr;
  memset(&g_glue_async_cps_emit, 0, sizeof(g_glue_async_cps_emit));
  if (!arena || !elf_ctx || !ctx || !mod || func_index < 0)
    return 0;
  if (ta < 0 || ta > 2)
    return 0;
  lr = async_asm_pool_build_layout(arena, mod, func_index, &g_glue_async_cps_emit.layout);
  if (lr != 0)
    return 0;
  g_glue_async_cps_emit.active = 1;
  g_glue_async_cps_emit.ta = ta;
  g_glue_async_cps_emit.fn_id = g_glue_async_cps_emit.layout.fn_id;
  g_glue_async_cps_emit.next_phase = 1;
  g_glue_async_cps_emit.resume_label_len =
      pipeline_asm_emit_next_label_c(ctx, g_glue_async_cps_emit.resume_label, 64);
  if (g_glue_async_cps_emit.resume_label_len <= 0)
    return -1;
  if (glue_async_cps_emit_frame_phase_ptr(elf_ctx, g_glue_async_cps_emit.fn_id, ta) != 0)
    return -1;
  if (backend_enc_load_32_from_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (glue_async_cps_mov_imm32_to_rax(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_cmp_rbx_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jeq_arch(elf_ctx, g_glue_async_cps_emit.resume_label, g_glue_async_cps_emit.resume_label_len, ta) !=
      0)
    return -1;
  return 0;
}

/** Function emit end: clear CPS context. */
void pipeline_asm_emit_async_cps_end_func_elf_c(void) {
  memset(&g_glue_async_cps_emit, 0, sizeof(g_glue_async_cps_emit));
}
