/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X /* reopen remaining wave178 FROM_X after leftover-PE for_call_args unique */

/* XLANG_PABI_AL_NC_SEQ_THIN_BEGIN */
/*
 * wave219 cold twin: ARRAY_LIT / escape / deep-copy COMMON seq take (G.7 pure leave).
 * Working freestanding BSS twin of pure g_pipeline_asm_al_nc_seq (same clamp).
 * Hybrid product links pure; cold seed keeps local static under #ifndef FROM_X.
 * Mid-file array_lit/escape cold bodies call this face via extern.
 * PLATFORM: SHARED freestanding emit label uniqueness.
 */
static int32_t g_wave219_pipeline_asm_al_nc_seq = 0;

int32_t glue_pipeline_asm_al_nc_seq_take_c(void) {
  int32_t seq = g_wave219_pipeline_asm_al_nc_seq;
  if (seq < 0 || seq > 999999)
    seq = 0;
  g_wave219_pipeline_asm_al_nc_seq = seq + 1;
  return seq;
}

/* XLANG_PABI_AL_NC_SEQ_THIN_END */

/* XLANG_PABI_EMIT_CTX_BSS_THIN_BEGIN */
/*
 * wave220 cold twin: if/ternary arm emit depth get/set (G.7 pure leave).
 * Working freestanding BSS twin of pure g_if_expr_arm_emit_depth.
 * Hybrid product links pure; cold seed keeps local static under #ifndef FROM_X.
 * Mid-file if_arm cold bodies call these faces via extern.
 * PLATFORM: SHARED freestanding emit arm nest depth.
 */
static int32_t g_wave220_if_expr_arm_emit_depth = 0;

int32_t glue_if_expr_arm_emit_depth_get(void) {
  return g_wave220_if_expr_arm_emit_depth;
}

void glue_if_expr_arm_emit_depth_set(int32_t v) {
  g_wave220_if_expr_arm_emit_depth = v;
}

/*
 * wave221 cold twins: emit_ctx accessor-only BSS + host_is_arm64 (G.7 pure leave).
 * Working freestanding BSS twins of pure g_pipeline_asm_emit_* cells.
 * Hybrid product links pure; cold seed keeps local static under #ifndef FROM_X.
 * Mid-file context leave cold bodies call these faces via extern.
 * host_is_arm64 matches residual #if __aarch64__/__arm64__ (compile-time host).
 * PLATFORM: SHARED freestanding emit context · MACOS|ARM64 / LINUX aarch64 → 1.
 */
static int32_t g_wave221_emit_func_index = -1;
static void *g_wave221_emit_arena = 0;
static int32_t g_wave221_emit_call_param_ty = 0;
static int32_t g_wave221_emit_call_arg_depth = 0;
static void *g_wave221_emit_elf_ctx = 0;
static int32_t g_wave221_emit_scope_block = 0;

int32_t pipeline_asm_emit_ctx_func_index_get(void) {
  return g_wave221_emit_func_index;
}
void pipeline_asm_emit_ctx_func_index_set(int32_t fi) {
  g_wave221_emit_func_index = fi;
}
void *pipeline_asm_emit_ctx_arena_get(void) {
  return g_wave221_emit_arena;
}
void pipeline_asm_emit_ctx_arena_set(void *arena) {
  g_wave221_emit_arena = arena;
}
int32_t pipeline_asm_emit_ctx_call_param_ty_get(void) {
  return g_wave221_emit_call_param_ty;
}
void pipeline_asm_emit_ctx_call_param_ty_set(int32_t type_ref) {
  g_wave221_emit_call_param_ty = type_ref;
}
int32_t pipeline_asm_emit_ctx_call_arg_depth_get(void) {
  return g_wave221_emit_call_arg_depth;
}
void pipeline_asm_emit_ctx_call_arg_depth_set(int32_t d) {
  g_wave221_emit_call_arg_depth = d;
}
void *pipeline_asm_emit_ctx_elf_ctx_get(void) {
  return g_wave221_emit_elf_ctx;
}
void pipeline_asm_emit_ctx_elf_ctx_set(void *elf_ctx) {
  g_wave221_emit_elf_ctx = elf_ctx;
}
int32_t pipeline_asm_emit_ctx_scope_block_get(void) {
  return g_wave221_emit_scope_block;
}
void pipeline_asm_emit_ctx_scope_block_set(int32_t block_ref) {
  g_wave221_emit_scope_block = block_ref;
}
int32_t pipeline_asm_host_is_arm64_c(void) {
#if defined(__aarch64__) || defined(__arm64__)
  return 1;
#else
  return 0;
#endif
}
/* XLANG_PABI_EMIT_CTX_BSS_THIN_END */

/* XLANG_PABI_EMIT_CTX_MODULE_DEP_THIN_BEGIN */
/*
 * wave222 cold twins: emit_ctx module + dep_pipe BSS (G.7 pure leave).
 * Working freestanding BSS twins of pure g_pipeline_asm_emit_module / dep_pipe.
 * Hybrid product links pure; cold seed keeps local static under #ifndef FROM_X.
 * Mid-file context leave cold bodies call these faces via extern.
 * PLATFORM: SHARED freestanding emit module / dep pool cells.
 */
static void *g_wave222_emit_module = 0;
static void *g_wave222_emit_dep_pipe = 0;

void *pipeline_asm_emit_ctx_module_get(void) {
  return g_wave222_emit_module;
}
void pipeline_asm_emit_ctx_module_set(void *m) {
  g_wave222_emit_module = m;
}
void *pipeline_asm_emit_ctx_dep_pipe_get(void) {
  return g_wave222_emit_dep_pipe;
}
void pipeline_asm_emit_ctx_dep_pipe_set(void *ctx) {
  g_wave222_emit_dep_pipe = ctx;
}
/* XLANG_PABI_EMIT_CTX_MODULE_DEP_THIN_END */

#endif /* close wave178 FROM_X for leftover-PE sret BSS cluster */
