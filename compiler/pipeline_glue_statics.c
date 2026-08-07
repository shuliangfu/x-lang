/**
 * pipeline_glue_statics.c — Emit / typeck active-context residual storage shell
 * (BC 8.3 shell thin).
 *
 * wave1290 BC 8.3 G.7 same-TU fold from pipeline_glue.c: the process-local
 * static globals that hold the currently-emitted module / function / arena /
 * ELF ctx / sret home / call-arg state, shared by every domain #included below
 * via one same-TU definition. wave1284 left these in glue; this file is that
 * single definition site (early_fwd holds only declarations).
 *
 * Must be #included once, before every emit/typeck domain that reads or writes
 * any of these — site: pipeline_glue.c right after pipeline_glue_early_fwd.c,
 * before pipeline_parser_result.c and all emit/typeck domains.
 *
 * Not a separate .o — host-cc via pipeline_x.o.
 *
 * wave221 pure-owned leave: accessor-only cells + host_is_arm64 moved to
 * runtime_pipeline_abi pure BSS/get/set (func_index / arena / call_param_ty /
 * call_arg_depth / elf_ctx / scope_block + host_is_arm64).
 * wave222 pure-owned leave: module / dep_pipe BSS+get/set → runtime_pipeline_abi
 * pure (bind_module_dep_from_ctx uses pure setters; no residual static cells).
 * This shell keeps residual-owned cells residual C still direct-writes:
 *   sret_active / sret_home_off / sret_ret_sz / typeck_active_module
 * plus Cap residual glue_asm_ctx_set_scope_block / bind_module_dep_from_ctx
 * (scope → pure set; module/dep → pure set).
 *
 * G.7: single authority per cell — pure owns pure-leaved faces; residual owns
 * direct-write cells. No dual BSS for pure-leaved faces.
 * PLATFORM: SHARED — host-cc residual shell (sret fields carry per-arch notes).
 */

/** Module currently being emitted by asm_codegen_ast_to_elf
 * (set by pipeline_asm_emit_set_module → pure ctx_module_set). */
/* wave153: Cap residual set_scope needs asm_ctx face (same mega TU). */
extern void asm_ctx_set_scope_block(uint8_t *ctx, int32_t block_ref);
/* wave221 pure-owned: process-local scope_block cell (live = runtime_pipeline_abi). */
extern void pipeline_asm_emit_ctx_scope_block_set(int32_t block_ref);
/* wave222 pure-owned: process-local module / dep_pipe cells. */
extern void *pipeline_asm_emit_ctx_module_get(void);
extern void pipeline_asm_emit_ctx_module_set(void *m);
extern void *pipeline_asm_emit_ctx_dep_pipe_get(void);
extern void pipeline_asm_emit_ctx_dep_pipe_set(void *ctx);

/** WPO-S3 / LANG-006 call-site CTFE: set by pipeline_typeck_set_active_ctx_c before check. */
static struct ast_Module *g_typeck_active_module;
/**
 * Large-struct (>16B) return home: stack slot holding the caller's dest pointer.
 * PLATFORM: LINUX+MACOS x86_64 SysV — hidden dest arrives in rdi, saved here.
 * PLATFORM: MACOS|ARM64 AAPCS64 — Indirect Result Location arrives in x8, saved here.
 * (-1 = current function is not an sret return target.)
 * wave222: still residual — mega_body writes these statics directly.
 */
static int32_t g_pipeline_asm_sret_home_off = -1;
/**
 * 1 = current emit function writes large struct return via hidden dest (sret).
 * PLATFORM: LINUX+MACOS x86_64 SysV (rdi) · MACOS|ARM64 AAPCS64 (x8).
 */
static int32_t g_pipeline_asm_func_sret_active = 0;
/** Current emit function sret return byte width (valid when >16). */
static int32_t g_pipeline_asm_func_sret_ret_sz = 0;
/* wave132 pure-owned leave: g_pipeline_asm_call_sret_reg_shift live =
 * runtime_pipeline_abi pure BSS (g_call_sret_reg_shift) via
 * pipeline_asm_emit_{set_,}call_sret_reg_shift_c. Do not re-open a second
 * sret shift flag (G.7 dual authority). PLATFORM: SHARED. */
/* wave221 pure-owned leave: func_index / arena / call_param_ty / call_arg_depth /
 * elf_ctx / scope_block statics + get/set deleted; live = runtime_pipeline_abi
 * pure BSS. Do not re-open second cells (G.7 dual authority). PLATFORM: SHARED. */
/* wave222 pure-owned leave: module / dep_pipe statics + get/set deleted; live =
 * runtime_pipeline_abi pure BSS. Do not re-open second cells. PLATFORM: SHARED. */

/* ========================================================================== *
 * wave141 Cap residual storage faces still residual-owned (direct-write cells).
 * wave221/222: pure-leaved faces are extern-only below.
 * PLATFORM: SHARED — host-cc residual shell.
 * ========================================================================== */

int32_t pipeline_asm_emit_ctx_sret_active_get(void) {
  return g_pipeline_asm_func_sret_active;
}
int32_t pipeline_asm_emit_ctx_sret_home_off_get(void) {
  return g_pipeline_asm_sret_home_off;
}
/**
 * wave144 Cap residual: pure return leave reads sret return byte width.
 * PLATFORM: SHARED — process-local emit cell; pure Cap residual getter.
 */
int32_t pipeline_asm_emit_ctx_sret_ret_sz_get(void) {
  return g_pipeline_asm_func_sret_ret_sz;
}

/* wave221 pure-owned leave: func_index/arena/call_param_ty/call_arg_depth/
 * elf_ctx/scope_block get/set + host_is_arm64 live = runtime_pipeline_abi pure.
 * wave222 pure-owned leave: module/dep_pipe get/set live = pure (extern above).
 * Residual keeps extern-only declarations for same-TU residual callers that
 * still name the symbols (hybrid links pure .o for the bodies).
 * PLATFORM: SHARED freestanding emit. */
extern int32_t pipeline_asm_emit_ctx_func_index_get(void);
extern void pipeline_asm_emit_ctx_func_index_set(int32_t fi);
extern void *pipeline_asm_emit_ctx_arena_get(void);
extern void pipeline_asm_emit_ctx_arena_set(void *arena);
extern int32_t pipeline_asm_emit_ctx_call_param_ty_get(void);
extern void pipeline_asm_emit_ctx_call_param_ty_set(int32_t type_ref);
extern int32_t pipeline_asm_emit_ctx_call_arg_depth_get(void);
extern void pipeline_asm_emit_ctx_call_arg_depth_set(int32_t d);
extern void *pipeline_asm_emit_ctx_elf_ctx_get(void);
extern void pipeline_asm_emit_ctx_elf_ctx_set(void *elf_ctx);
extern int32_t pipeline_asm_emit_ctx_scope_block_get(void);
extern int32_t pipeline_asm_host_is_arm64_c(void);

/**
 * wave153 Cap residual: set TU-wide emit scope block + per-ctx scope_block_ref.
 * wave221: process-local cell is pure BSS via pipeline_asm_emit_ctx_scope_block_set;
 * residual only bridges to asm_ctx layout face (G.7 single cell authority).
 * PLATFORM: SHARED pure scope bookkeeping + residual ctx layout sync.
 */
void glue_asm_ctx_set_scope_block(uint8_t *ctx, int32_t block_ref) {
  pipeline_asm_emit_ctx_scope_block_set(block_ref);
  asm_ctx_set_scope_block(ctx, block_ref);
}

/**
 * wave153 Cap residual: bind emit module + dep_pipe from AsmFuncCtx layout.
 * wave222: process-local cells are pure BSS via module/dep_pipe_set (G.7 single
 * cell authority; no residual static write).
 * Used by pure backend_emit_block_body_sync_elf / glue_emit_block_final_expr_elf
 * (pure cannot load layout pointers without Cap residual helpers).
 * PLATFORM: SHARED freestanding emit.
 */
void glue_block_body_bind_module_dep_from_ctx(uint8_t *ctx) {
  pipeline_glue_AsmFuncCtxLayout *ly;
  if (!ctx)
    return;
  ly = pipeline_asm_ctx_layout((struct backend_AsmFuncCtx *)ctx);
  if (!ly)
    return;
  if (ly->module_ref)
    pipeline_asm_emit_ctx_module_set((void *)ly->module_ref);
  if (ly->dep_pipe)
    pipeline_asm_emit_ctx_dep_pipe_set((void *)ly->dep_pipe);
}
