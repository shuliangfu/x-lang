/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
#define WAVE130_WPO_MONO_MAX_THUNKS 64
#define WAVE130_WPO_MONO_SYM_MAX 128
#define WAVE130_WPO_MONO_MAX_ARGS 8
#define WAVE130_WPO_MONO_THUNK_SZ 136
#define WAVE130_WPO_MONO_BAG_SZ 8708
#define WAVE130_WPO_MONO_N_OFF 8704

typedef struct Wave130GlueWpoMonoThunk {
  char sym[WAVE130_WPO_MONO_SYM_MAX];
  int32_t result_imm;
  unsigned char valid;
} Wave130GlueWpoMonoThunk;

typedef struct Wave130GlueWpoMonoThunks {
  Wave130GlueWpoMonoThunk thunks[WAVE130_WPO_MONO_MAX_THUNKS];
  int n;
} Wave130GlueWpoMonoThunks;

static Wave130GlueWpoMonoThunks g_glue_wpo_mono_pending;

extern int codegen_wpo_mono_sym_format(const char *base, int nargs, const int *args, char *out, int cap);
extern char *link_abi_getenv(const char *name);
extern int32_t backend_enc_label_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_global, int32_t ta);
extern int32_t backend_enc_prologue_arch(void *elf_ctx, int32_t frame_sz, int32_t ta);
extern int32_t backend_enc_epilogue_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(void *elf_ctx, int32_t lo, int32_t hi, int32_t ta);
extern int32_t pipeline_dep_ctx_target_arch(void *ctx);

static int glue_wpo_mono_has_sym(const Wave130GlueWpoMonoThunks *bag, const char *sym) {
  int i;
  if (!bag || !sym)
    return 0;
  for (i = 0; i < bag->n; i++)
    if (bag->thunks[i].valid && strcmp(bag->thunks[i].sym, sym) == 0)
      return 1;
  return 0;
}

void glue_wpo_mono_reset_pending(void) {
  memset(&g_glue_wpo_mono_pending, 0, sizeof(g_glue_wpo_mono_pending));
}

void glue_wpo_mono_register_thunk_n(const char *base, int32_t nargs, const int32_t *args, int32_t folded) {
  char sym[WAVE130_WPO_MONO_SYM_MAX];
  int sym_len;
  Wave130GlueWpoMonoThunk *slot;
  if (!base || !link_abi_getenv("XLANG_WPO_MONO"))
    return;
  if (nargs < 0)
    nargs = 0;
  if (nargs > WAVE130_WPO_MONO_MAX_ARGS)
    nargs = WAVE130_WPO_MONO_MAX_ARGS;
  sym_len = codegen_wpo_mono_sym_format(base, (int)nargs, (const int *)args, sym, (int)sizeof(sym));
  if (sym_len <= 0 || glue_wpo_mono_has_sym(&g_glue_wpo_mono_pending, sym))
    return;
  if (g_glue_wpo_mono_pending.n >= WAVE130_WPO_MONO_MAX_THUNKS)
    return;
  slot = &g_glue_wpo_mono_pending.thunks[g_glue_wpo_mono_pending.n];
  memset(slot, 0, sizeof(*slot));
  memcpy(slot->sym, sym, (size_t)sym_len + 1);
  slot->result_imm = folded;
  slot->valid = 1;
  g_glue_wpo_mono_pending.n++;
}

void glue_wpo_mono_register_thunk(const char *base, int32_t av0, int32_t av1, int32_t folded) {
  int32_t args[2];
  args[0] = av0;
  args[1] = av1;
  glue_wpo_mono_register_thunk_n(base, 2, args, folded);
}

int32_t pipeline_asm_emit_wpo_mono_thunks_elf_c(struct ast_Module *entry, struct ast_ASTArena *arena,
                                                 void *elf_ctx, void *pipeline_ctx) {
  const Wave130GlueWpoMonoThunks *thunks;
  int ta;
  int ti;
  (void)entry;
  (void)arena;
  if (!elf_ctx || !pipeline_ctx)
    return -1;
  if (!link_abi_getenv("XLANG_WPO_MONO"))
    return 0;
  thunks = &g_glue_wpo_mono_pending;
  ta = (int)pipeline_dep_ctx_target_arch(pipeline_ctx);
  for (ti = 0; ti < thunks->n; ti++) {
    const Wave130GlueWpoMonoThunk *th = &thunks->thunks[ti];
    int32_t hi;
    uint8_t sym[WAVE130_WPO_MONO_SYM_MAX];
    int32_t sym_len;
    if (!th->valid)
      continue;
    sym_len = (int32_t)strlen(th->sym);
    if (sym_len <= 0 || sym_len >= WAVE130_WPO_MONO_SYM_MAX)
      return -1;
    memcpy(sym, th->sym, (size_t)sym_len);
    if (backend_enc_label_arch(elf_ctx, sym, sym_len, 1, ta) != 0)
      return -1;
    if (backend_enc_prologue_arch(elf_ctx, 0, ta) != 0)
      return -1;
    hi = (th->result_imm < 0) ? -1 : 0;
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, th->result_imm, hi, ta) != 0)
      return -1;
    if (backend_enc_epilogue_arch(elf_ctx, ta) != 0)
      return -1;
  }
  return 0;
}
