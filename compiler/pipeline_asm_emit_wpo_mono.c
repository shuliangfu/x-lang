/**
 * pipeline_asm_emit_wpo_mono.c — WPO-S2 monomorphization thunk domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via #include).
 * Authority for whole-program-optimization (WPO) constant-folding monomorphization:
 * when a call site has all-constant arguments and the callee fold result is known at
 * compile time, a monomorphic thunk (mov imm64; ret) is emitted instead of a real call.
 *
 * Collection model: try_call inline dispatch (backend_try_inline_dispatch) collects
 * matched constant calls into g_glue_wpo_mono_pending during ELF codegen. After all
 * regular function bodies are emitted, pipeline_asm_emit_wpo_mono_thunks_elf_c appends
 * the thunk bodies (label + prologue + mov imm64 + epilogue) to the .text section.
 *
 * Domain members (5 functions + 3 macros + 2 typedefs + 1 global):
 * - glue_wpo_mono_has_sym (static): dedup check for the pending thunk bag
 * - glue_wpo_mono_reset_pending (public): clear bag at start of each ELF module codegen
 * - glue_wpo_mono_register_thunk_n (public): register a mono thunk (any nargs)
 * - glue_wpo_mono_register_thunk (public): scalar 2-arg convenience wrapper
 * - pipeline_asm_emit_wpo_mono_thunks_elf_c (public): emit all pending thunk bodies
 *
 * G.7: single WPO mono thunk path — backend_try_inline_dispatch.x and ast_pool.c
 * call the same public register/emit symbols; no second mono path.
 *
 * Gate: all paths are no-ops when XLANG_WPO_MONO env is unset (production default).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c.
 *
 * PLATFORM: SHARED — emits x86_64 and arm64 thunk bodies via backend_enc_*_arch
 * dispatch (ta=0 x86_64, ta=1 arm64). Thunk body: label + empty prologue +
 * mov imm64 to rax/x0 + epilogue (ret).
 */

/* ------------------------------------------------------------------------- */
/* Extern dependency: codegen WPO mono symbol formatter.                      */
/* ------------------------------------------------------------------------- */

/** codegen.c — format mono thunk symbol name from base + type-arg list. */
extern int codegen_wpo_mono_sym_format(const char *base, int nargs, const int *args, char *out, int cap);

/* ------------------------------------------------------------------------- */
/* Mono thunk slot: max 64 pending thunks per ELF module codegen.             */
/* ------------------------------------------------------------------------- */

#define GLUE_WPO_MONO_MAX_THUNKS 64
#define GLUE_WPO_MONO_SYM_MAX 128
#define GLUE_WPO_MONO_MAX_ARGS 8

/**
 * Single monomorphization thunk entry.
 *
 * sym:       null-terminated symbol name (e.g. "__mono_scale_i32_3_2")
 * result_imm: compile-time folded result (returned via mov imm64; ret)
 * valid:     1 if slot is occupied, 0 if free
 */
typedef struct GlueWpoMonoThunk {
  char sym[GLUE_WPO_MONO_SYM_MAX];
  int32_t result_imm;
  unsigned char valid;
} GlueWpoMonoThunk;

/**
 * Pending thunk bag for the current ELF codegen pass.
 *
 * Why: Collected during try_call inline dispatch (backend_try_inline_dispatch.x)
 * when a call has all-constant args and a known fold result. Emitted as thunk
 * bodies at the end of pipeline_backend_asm_codegen_ast_to_elf_c.
 *
 * Invariant: n tracks the number of valid entries [0, GLUE_WPO_MONO_MAX_THUNKS].
 * Reset to zero by glue_wpo_mono_reset_pending at the start of each ELF module.
 *
 * PLATFORM: SHARED — bag layout is platform-independent; thunk emit is arch-dispatched.
 */
typedef struct GlueWpoMonoThunks {
  GlueWpoMonoThunk thunks[GLUE_WPO_MONO_MAX_THUNKS];
  int n;
} GlueWpoMonoThunks;

/** Current ELF codegen pending all-constant call→mono registry (emit end writes thunk bodies). */
static GlueWpoMonoThunks g_glue_wpo_mono_pending;

/**
 * Check whether a monomorphization symbol is already in the pending bag.
 *
 * Why: Dedup — if try_call matches the same constant call multiple times (e.g. in a
 * loop), we only emit one thunk body. Without dedup, duplicate labels would cause
 * linker multiple-definition errors.
 *
 * Invariant: Returns 1 if a valid entry with matching sym exists; 0 otherwise
 * (including null bag/sym or empty bag).
 *
 * Asm/Perf: O(N_thunks) linear scan with strcmp. Cold path (codegen, not runtime).
 * N_thunks is typically small (< 10).
 *
 * PLATFORM: SHARED — string comparison is platform-independent.
 */
static int glue_wpo_mono_has_sym(const GlueWpoMonoThunks *bag, const char *sym) {
  int i;
  if (!bag || !sym)
    return 0;
  for (i = 0; i < bag->n; i++)
    if (bag->thunks[i].valid && strcmp(bag->thunks[i].sym, sym) == 0)
      return 1;
  return 0;
}

/**
 * Clear the mono thunk pending bag at the start of a new ELF module codegen.
 *
 * Why: Each ELF module has its own set of mono thunks. Stale entries from a prior
 * module would cause spurious thunk bodies or symbol collisions in the new module.
 *
 * Invariant: After reset, g_glue_wpo_mono_pending.n == 0 and all slots are zeroed
 * (valid=0, sym empty, result_imm=0).
 *
 * Asm/Perf: O(1) memset of the entire bag struct. Called once per ELF module.
 *
 * PLATFORM: SHARED — memset is platform-independent.
 */
void glue_wpo_mono_reset_pending(void) {
  memset(&g_glue_wpo_mono_pending, 0, sizeof(g_glue_wpo_mono_pending));
}

/**
 * Register a monomorphization thunk when a try_call matches all-constant args.
 *
 * Why: backend_try_inline_dispatch.x calls this when a call site has all-constant
 * arguments and the callee's fold result is known. The thunk symbol is formed from
 * the base name + type-arg list via codegen_wpo_mono_sym_format. At emit end,
 * pipeline_asm_emit_wpo_mono_thunks_elf_c writes the thunk body (mov imm64; ret).
 *
 * Invariant: No-op when base is null or XLANG_WPO_MONO env is unset. Dedup via
 * glue_wpo_mono_has_sym. nargs clamped to [0, GLUE_WPO_MONO_MAX_ARGS]. Silently
 * drops when bag is full (GLUE_WPO_MONO_MAX_THUNKS reached).
 *
 * Asm/Perf: O(N_thunks) for dedup scan + O(1) for slot fill. Cold path (codegen).
 *
 * PLATFORM: SHARED — symbol formatting and bag management are platform-independent.
 */
void glue_wpo_mono_register_thunk_n(const char *base, int32_t nargs, const int32_t *args, int32_t folded) {
  char sym[GLUE_WPO_MONO_SYM_MAX];
  int sym_len;
  GlueWpoMonoThunk *slot;
  if (!base || !link_abi_getenv("XLANG_WPO_MONO"))
    return;
  if (nargs < 0)
    nargs = 0;
  if (nargs > GLUE_WPO_MONO_MAX_ARGS)
    nargs = GLUE_WPO_MONO_MAX_ARGS;
  sym_len = codegen_wpo_mono_sym_format(base, (int)nargs, args, sym, (int)sizeof(sym));
  if (sym_len <= 0 || glue_wpo_mono_has_sym(&g_glue_wpo_mono_pending, sym))
    return;
  if (g_glue_wpo_mono_pending.n >= GLUE_WPO_MONO_MAX_THUNKS)
    return;
  slot = &g_glue_wpo_mono_pending.thunks[g_glue_wpo_mono_pending.n];
  memset(slot, 0, sizeof(*slot));
  memcpy(slot->sym, sym, (size_t)sym_len + 1);
  slot->result_imm = folded;
  slot->valid = 1;
  g_glue_wpo_mono_pending.n++;
}

/**
 * Register a scalar 2-argument monomorphization thunk (convenience wrapper).
 *
 * Why: Common case for binary scalar operations (e.g. scale(a, b) with both
 * arguments being compile-time constants). Delegates to glue_wpo_mono_register_
 * thunk_n with nargs=2.
 *
 * Invariant: Same contract as glue_wpo_mono_register_thunk_n.
 *
 * PLATFORM: SHARED — delegates to platform-independent register_thunk_n.
 */
void glue_wpo_mono_register_thunk(const char *base, int32_t av0, int32_t av1, int32_t folded) {
  int32_t args[2];
  args[0] = av0;
  args[1] = av1;
  glue_wpo_mono_register_thunk_n(base, 2, args, folded);
}

/**
 * Emit all pending monomorphization thunk bodies after regular function emit.
 *
 * Why: WPO-S2 monomorphize — after all regular function bodies are emitted to the
 * .text section, this function appends mono thunk bodies. Each thunk is:
 *   label <sym>          (backend_enc_label_arch, is_global=1)
 *   prologue (frame=0)   (backend_enc_prologue_arch, no stack frame)
 *   mov rax/x0, imm64    (backend_enc_mov_imm64_to_rax_arch, hi = sign-extend)
 *   epilogue (ret)       (backend_enc_epilogue_arch)
 *
 * Invariant: Returns 0 on success (including no-op when XLANG_WPO_MONO is unset).
 * Returns -1 on null elf_ctx/pipeline_ctx, invalid sym length, or backend_enc
 * failure. Sign-extension: hi = -1 when result_imm < 0 (negative i64), else 0.
 *
 * Asm/Perf: O(N_thunks) — each thunk is ~20-30 bytes. Cold path (codegen emit end).
 *
 * PLATFORM: SHARED — emits x86_64 (ta=0) or arm64 (ta=1) via backend_enc_*_arch
 * dispatch. x86_64: mov rax, imm64 (10B) + ret (1B). arm64: 2×movz + ret.
 */
int32_t pipeline_asm_emit_wpo_mono_thunks_elf_c(struct ast_Module *entry, struct ast_ASTArena *arena,
                                                 struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                 struct ast_PipelineDepCtx *pipeline_ctx) {
  const GlueWpoMonoThunks *thunks;
  int ta;
  int ti;
  (void)entry;
  (void)arena;
  if (!elf_ctx || !pipeline_ctx)
    return -1;
  if (!link_abi_getenv("XLANG_WPO_MONO"))
    return 0;
  thunks = &g_glue_wpo_mono_pending;
  ta = pipeline_ctx->target_arch;
  for (ti = 0; ti < thunks->n; ti++) {
    const GlueWpoMonoThunk *th = &thunks->thunks[ti];
    int32_t hi;
    uint8_t sym[GLUE_WPO_MONO_SYM_MAX];
    int32_t sym_len;
    if (!th->valid)
      continue;
    sym_len = (int32_t)strlen(th->sym);
    if (sym_len <= 0 || sym_len >= GLUE_WPO_MONO_SYM_MAX)
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
