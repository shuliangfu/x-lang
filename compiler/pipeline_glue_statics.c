/**
 * pipeline_glue_statics.c — Emit / typeck active-context static globals shell
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
 * G.7: single same-TU definition of each static; no second implementation.
 * PLATFORM: SHARED — host-cc residual shell (sret fields carry per-arch notes).
 */

/** Module currently being emitted by asm_codegen_ast_to_elf
 * (set by pipeline_asm_emit_set_module, defined later in the TU). */
static struct ast_Module *g_pipeline_asm_emit_module;
/** WPO-S3 / LANG-006 call-site CTFE: set by pipeline_typeck_set_active_ctx_c before check. */
static struct ast_Module *g_typeck_active_module;
/** Current asm emit function index; used for param *T slot load/lea decisions
 * (driver compile.x state etc.). */
static int32_t g_pipeline_asm_emit_func_index = -1;
/** Current emit AST arena (param homing param-kind queries). */
static struct ast_ASTArena *g_pipeline_asm_emit_arena;
/** Callee param type_ref对照 during CALL arg emit (f32 must be a 32-bit scalar). */
static int32_t g_pipeline_asm_emit_call_param_ty_ref;
/** CALL arg emit nesting depth (>0 lets FIELD_ACCESS distinguish by-ref struct field). */
static int32_t g_glue_emit_call_arg_depth;
/**
 * Large-struct (>16B) return home: stack slot holding the caller's dest pointer.
 * PLATFORM: LINUX+MACOS x86_64 SysV — hidden dest arrives in rdi, saved here.
 * PLATFORM: MACOS|ARM64 AAPCS64 — Indirect Result Location arrives in x8, saved here.
 * (-1 = current function is not an sret return target.)
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
/** Current emit block scope (synced with asm_ctx scope_block_ref); FIELD_ACCESS
 * uses it to look up let types. */
static int32_t g_pipeline_asm_emit_scope_block = 0;
/** Current asm emit dep pool; used for import struct layout field offsets
 * (WPO-S3 cross_ret etc.). */
static struct ast_PipelineDepCtx *g_pipeline_asm_emit_dep_pipe;
/** elf_ctx currently being written by asm_codegen_ast_to_elf (PGO-Lite emit seg switch). */
static struct platform_elf_ElfCodegenCtx *g_pipeline_asm_emit_elf_ctx;

/* ========================================================================== *
 * wave141 Cap residual storage for pure emit-context leave
 * (pipeline_asm_emit_context.c pure-owned leave).
 *
 * Pure public faces live in runtime_pipeline_abi; residual C in this same TU
 * still reads/writes the statics above directly. Pure Cap residual these
 * get/set faces so product hybrid shares one storage (G.7 single authority
 * for public API; Cap residual owns process-local cells until statics leave).
 * PLATFORM: SHARED — host-cc residual shell.
 * ========================================================================== */

void *pipeline_asm_emit_ctx_module_get(void) {
  return (void *)g_pipeline_asm_emit_module;
}
void pipeline_asm_emit_ctx_module_set(void *m) {
  g_pipeline_asm_emit_module = (struct ast_Module *)m;
}
int32_t pipeline_asm_emit_ctx_func_index_get(void) {
  return g_pipeline_asm_emit_func_index;
}
void pipeline_asm_emit_ctx_func_index_set(int32_t fi) {
  g_pipeline_asm_emit_func_index = fi;
}
void *pipeline_asm_emit_ctx_arena_get(void) {
  return (void *)g_pipeline_asm_emit_arena;
}
void pipeline_asm_emit_ctx_arena_set(void *arena) {
  g_pipeline_asm_emit_arena = (struct ast_ASTArena *)arena;
}
int32_t pipeline_asm_emit_ctx_call_param_ty_get(void) {
  return g_pipeline_asm_emit_call_param_ty_ref;
}
void pipeline_asm_emit_ctx_call_param_ty_set(int32_t type_ref) {
  g_pipeline_asm_emit_call_param_ty_ref = type_ref;
}
int32_t pipeline_asm_emit_ctx_call_arg_depth_get(void) {
  return g_glue_emit_call_arg_depth;
}
void pipeline_asm_emit_ctx_call_arg_depth_set(int32_t d) {
  g_glue_emit_call_arg_depth = d;
}
void *pipeline_asm_emit_ctx_dep_pipe_get(void) {
  return (void *)g_pipeline_asm_emit_dep_pipe;
}
void pipeline_asm_emit_ctx_dep_pipe_set(void *ctx) {
  g_pipeline_asm_emit_dep_pipe = (struct ast_PipelineDepCtx *)ctx;
}
void *pipeline_asm_emit_ctx_elf_ctx_get(void) {
  return (void *)g_pipeline_asm_emit_elf_ctx;
}
void pipeline_asm_emit_ctx_elf_ctx_set(void *elf_ctx) {
  g_pipeline_asm_emit_elf_ctx = (struct platform_elf_ElfCodegenCtx *)elf_ctx;
}
int32_t pipeline_asm_emit_ctx_sret_active_get(void) {
  return g_pipeline_asm_func_sret_active;
}
int32_t pipeline_asm_emit_ctx_sret_home_off_get(void) {
  return g_pipeline_asm_sret_home_off;
}
/**
 * Host compile-time ISA polarity for frame/param home layout.
 * Matches residual #if __aarch64__/__arm64__ (product freestanding ISA == host).
 * PLATFORM: SHARED — 1 on MACOS|ARM64 / LINUX aarch64; 0 on x86_64.
 */
int32_t pipeline_asm_host_is_arm64_c(void) {
#if defined(__aarch64__) || defined(__arm64__)
  return 1;
#else
  return 0;
#endif
}
