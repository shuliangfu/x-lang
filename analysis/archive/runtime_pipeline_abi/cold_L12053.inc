/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
#define WAVE131_ASYNC_LIVE_MAX 64
#define WAVE131_ASYNC_LIVE_VAR_SZ 268
#define WAVE131_ASYNC_LAYOUT_SZ 17168
#define WAVE131_ASYNC_STATE_SZ 17316
#define WAVE131_ASYNC_OFF_LAYOUT 16
#define WAVE131_ASYNC_OFF_RESUME 17184
#define WAVE131_ASYNC_OFF_RESUME_LEN 17312
#define WAVE131_TAIL_JOIN_LBL 1392
#define WAVE131_TAIL_JOIN_LEN 1520

typedef struct Wave131AsyncAsmPoolLiveVar {
  char name[256];
  int32_t name_len;
  int32_t size_bytes;
  int32_t frame_data_off;
} Wave131AsyncAsmPoolLiveVar;

typedef struct Wave131AsyncAsmPoolLayout {
  uint32_t fn_id;
  int32_t num_awaits;
  int32_t num_live;
  Wave131AsyncAsmPoolLiveVar live[WAVE131_ASYNC_LIVE_MAX];
  int32_t await_stmt_idx;
} Wave131AsyncAsmPoolLayout;

typedef struct Wave131GlueAsyncCpsEmitState {
  int32_t active;
  int32_t ta;
  uint32_t fn_id;
  int32_t next_phase;
  Wave131AsyncAsmPoolLayout layout;
  uint8_t resume_label[128];
  int32_t resume_label_len;
} Wave131GlueAsyncCpsEmitState;

static Wave131GlueAsyncCpsEmitState g_glue_async_cps_emit;

extern int32_t async_asm_pool_build_layout(void *arena, void *mod, int32_t func_index, void *out);
extern int32_t asm_ctx_local_find_offset(void *ctx, uint8_t *name, int32_t name_len);
extern void *pipeline_asm_ctx_layout(void *ctx);
extern int32_t pipeline_asm_emit_next_label_c(void *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t glue_enc_jz_after_bool_in_eax(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(void *elf_ctx, int32_t lo, int32_t hi, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_call_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_32_from_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_cmp_rbx_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_jeq_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_jmp_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_label_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_global, int32_t ta);

static int32_t glue_async_cps_mov_imm32_to_rax(void *elf_ctx, int32_t imm, int32_t ta) {
  return backend_enc_mov_imm64_to_rax_arch(elf_ctx, imm, 0, ta);
}

static int32_t glue_async_cps_emit_frame_phase_ptr(void *elf_ctx, uint32_t fn_id, int32_t ta) {
  static const uint8_t nm[] = "xlang_async_asm_frame_phase_by_id";
  if (glue_async_cps_mov_imm32_to_rax(elf_ctx, (int32_t)fn_id, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, (uint8_t *)nm, (int32_t)(sizeof(nm) - 1), ta);
}

static int32_t glue_async_cps_call_frame_memop(void *elf_ctx, uint8_t *cname, int32_t cname_len, uint32_t fn_id,
                                               int32_t data_off, int32_t stack_off, int32_t nbytes, int32_t ta) {
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

static int32_t glue_async_cps_save_live(void *elf_ctx, void *ctx, int32_t ta) {
  int32_t i;
  static const uint8_t store_nm[] = "xlang_async_asm_frame_store_from_ptr";
  for (i = 0; i < g_glue_async_cps_emit.layout.num_live; i++) {
    const Wave131AsyncAsmPoolLiveVar *lv = &g_glue_async_cps_emit.layout.live[i];
    int32_t stack_off = asm_ctx_local_find_offset(ctx, (uint8_t *)lv->name, lv->name_len);
    if (stack_off < 0)
      return -1;
    if (glue_async_cps_call_frame_memop(elf_ctx, (uint8_t *)store_nm, (int32_t)(sizeof(store_nm) - 1),
                                        g_glue_async_cps_emit.fn_id, lv->frame_data_off, stack_off, lv->size_bytes,
                                        ta) != 0)
      return -1;
  }
  return 0;
}

static int32_t glue_async_cps_restore_live(void *elf_ctx, void *ctx, int32_t ta) {
  int32_t i;
  static const uint8_t load_nm[] = "xlang_async_asm_frame_load_to_ptr";
  for (i = 0; i < g_glue_async_cps_emit.layout.num_live; i++) {
    const Wave131AsyncAsmPoolLiveVar *lv = &g_glue_async_cps_emit.layout.live[i];
    int32_t stack_off = asm_ctx_local_find_offset(ctx, (uint8_t *)lv->name, lv->name_len);
    if (stack_off < 0)
      return -1;
    if (glue_async_cps_call_frame_memop(elf_ctx, (uint8_t *)load_nm, (int32_t)(sizeof(load_nm) - 1),
                                        g_glue_async_cps_emit.fn_id, lv->frame_data_off, stack_off, lv->size_bytes,
                                        ta) != 0)
      return -1;
  }
  return 0;
}

int32_t glue_async_cps_emit_after_await(void *arena, void *elf_ctx, void *ctx, int32_t ta) {
  uint8_t *ly;
  static const uint8_t suspend_nm[] = "xlang_async_cps_suspend";
  int32_t next_ph;
  int32_t tj_len;
  (void)arena;
  if (!g_glue_async_cps_emit.active)
    return 0;
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
  if (glue_enc_jz_after_bool_in_eax(elf_ctx, g_glue_async_cps_emit.resume_label, g_glue_async_cps_emit.resume_label_len,
                                    ta) != 0)
    return -1;
  ly = (uint8_t *)pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  {
    int32_t *p = (int32_t *)(ly + WAVE131_TAIL_JOIN_LEN);
    tj_len = *p;
  }
  if (tj_len <= 0)
    return -1;
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, (int32_t)0x41535700, ta) != 0)
    return -1;
  if (backend_enc_jmp_arch(elf_ctx, ly + WAVE131_TAIL_JOIN_LBL, tj_len, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, g_glue_async_cps_emit.resume_label, g_glue_async_cps_emit.resume_label_len, 0,
                             ta) != 0)
    return -1;
  return glue_async_cps_restore_live(elf_ctx, ctx, ta);
}

int32_t glue_async_cps_emit_phase_reset(void *elf_ctx, int32_t ta) {
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

int32_t pipeline_asm_emit_async_cps_entry_elf_c(void *arena, void *elf_ctx, void *ctx, void *mod, int32_t func_index,
                                                int32_t ta) {
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

void pipeline_asm_emit_async_cps_end_func_elf_c(void) {
  memset(&g_glue_async_cps_emit, 0, sizeof(g_glue_async_cps_emit));
}
