/*
 * Thin pure: wave220–221 emit arm-depth + emit_ctx BSS + host_is_arm64.
 * G.7: bodies match mega runtime_pipeline_abi.x wave220/221 leave.
 *
 * Why C (not .x pure-asm):
 *   1) file-level `let x: i32 = -1` emits no BSS under pure-asm (probe);
 *   2) non-zero scalar lets that do emit become Lxml COMMON (loader zeros),
 *      while mega -E uses named .data cells — dual-home SEGV on f32.
 * C thin defines the same named globals mega -E uses (global linkage) and
 * first-wins the get/set/host faces. Mega's local static cells + weak
 * getters become orphans; live callers go through these strong faces.
 *
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED freestanding · MACOS|ARM64 / LINUX aarch64 host_is_arm64=1.
 */

#include <stdint.h>

/* wave220 */
int32_t g_if_expr_arm_emit_depth = 0;

/* wave221 emit-context cells (canonical names). */
int32_t g_pipeline_asm_emit_func_index = -1;
void *g_pipeline_asm_emit_arena = 0;
int32_t g_pipeline_asm_emit_call_param_ty_ref = 0;
int32_t g_glue_emit_call_arg_depth = 0;
void *g_pipeline_asm_emit_elf_ctx = 0;
int32_t g_pipeline_asm_emit_scope_block = 0;

#if defined(__aarch64__) || defined(__arm64__)
int32_t g_pipeline_asm_host_is_arm64_lit = 1;
#else
int32_t g_pipeline_asm_host_is_arm64_lit = 0;
#endif

/** wave220: get if/ternary arm emit depth. PLATFORM: SHARED. */
int32_t glue_if_expr_arm_emit_depth_get(void) {
  return g_if_expr_arm_emit_depth;
}

/** wave220: set if/ternary arm emit depth. PLATFORM: SHARED. */
void glue_if_expr_arm_emit_depth_set(int32_t v) {
  g_if_expr_arm_emit_depth = v;
}

/** wave221: get emit function index. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_ctx_func_index_get(void) {
  return g_pipeline_asm_emit_func_index;
}

/** wave221: set emit function index. PLATFORM: SHARED. */
void pipeline_asm_emit_ctx_func_index_set(int32_t fi) {
  g_pipeline_asm_emit_func_index = fi;
}

/** wave221: get emit arena. PLATFORM: SHARED. */
void *pipeline_asm_emit_ctx_arena_get(void) {
  return g_pipeline_asm_emit_arena;
}

/** wave221: set emit arena. PLATFORM: SHARED. */
void pipeline_asm_emit_ctx_arena_set(void *arena) {
  g_pipeline_asm_emit_arena = arena;
}

/** wave221: get call param type_ref. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_ctx_call_param_ty_get(void) {
  return g_pipeline_asm_emit_call_param_ty_ref;
}

/** wave221: set call param type_ref. PLATFORM: SHARED. */
void pipeline_asm_emit_ctx_call_param_ty_set(int32_t type_ref) {
  g_pipeline_asm_emit_call_param_ty_ref = type_ref;
}

/** wave221: get call arg depth. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_ctx_call_arg_depth_get(void) {
  return g_glue_emit_call_arg_depth;
}

/** wave221: set call arg depth. PLATFORM: SHARED. */
void pipeline_asm_emit_ctx_call_arg_depth_set(int32_t d) {
  g_glue_emit_call_arg_depth = d;
}

/** wave221: get elf ctx. PLATFORM: SHARED. */
void *pipeline_asm_emit_ctx_elf_ctx_get(void) {
  return g_pipeline_asm_emit_elf_ctx;
}

/** wave221: set elf ctx. PLATFORM: SHARED. */
void pipeline_asm_emit_ctx_elf_ctx_set(void *elf_ctx) {
  g_pipeline_asm_emit_elf_ctx = elf_ctx;
}

/** wave221: get scope block. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_ctx_scope_block_get(void) {
  return g_pipeline_asm_emit_scope_block;
}

/** wave221: set scope block. PLATFORM: SHARED. */
void pipeline_asm_emit_ctx_scope_block_set(int32_t block_ref) {
  g_pipeline_asm_emit_scope_block = block_ref;
}

/** wave221: host ISA polarity. PLATFORM: SHARED · MACOS|ARM64 / LINUX aarch64. */
int32_t pipeline_asm_host_is_arm64_c(void) {
  return g_pipeline_asm_host_is_arm64_lit;
}
