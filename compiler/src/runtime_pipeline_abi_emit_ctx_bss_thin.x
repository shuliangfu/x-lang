// Thin pure: wave317/342/380 M2 — emit_ctx_bss Cap residual (was wave220–221 C thin).
// Arm-depth + emit_ctx scalar/pointer BSS + host_is_arm64; 15 exports.
// G.7: bodies match runtime_pipeline_abi.x wave220/221 leave.
// PRODUCT inject (pipeline_abi_inject_emit_ctx_bss_thin, stamp w380):
//   Prior: LINUX PREFER / DARWIN -E overlays kept.
//   HARD BAN reinject both ends (Darwin BRANCH26; Ubuntu tip SEGV).
// PLATFORM: SHARED · BAN reinject both ends (keep prior overlays).

// wave220: nest depth while emitting if/ternary branch arms (0 = not in arm).
let g_if_expr_arm_emit_depth: i32 = 0;

// wave221: current emit function index (-1 = none).
let g_pipeline_asm_emit_func_index: i32 = -1;
// wave221: current emit AST arena pointer.
let g_pipeline_asm_emit_arena: *u8 = 0 as *u8;
// wave221: callee param type_ref during CALL arg emit (0 = unset).
let g_pipeline_asm_emit_call_param_ty_ref: i32 = 0;
// wave221: CALL arg emit nesting depth.
let g_glue_emit_call_arg_depth: i32 = 0;
// wave221: current ELF codegen ctx pointer.
let g_pipeline_asm_emit_elf_ctx: *u8 = 0 as *u8;
// wave221: current emit block scope ref.
let g_pipeline_asm_emit_scope_block: i32 = 0;

// wave221: host ISA polarity lit — 1 on aarch64 product .o, else 0.
// Matches residual #if defined(__aarch64__) || defined(__arm64__).
#[cfg(target_arch = "aarch64")]
let g_pipeline_asm_host_is_arm64_lit: i32 = 1;
#[cfg(not(target_arch = "aarch64"))]
let g_pipeline_asm_host_is_arm64_lit: i32 = 0;

/**
 * Get current if/ternary arm emit depth.
 * @return i32 — current arm emit depth (>=0 in well-formed emit)
 * wave220 pure: G.7 authority (was Cap residual emit_fwd static + get).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_if_expr_arm_emit_depth_get(): i32 {
  return g_if_expr_arm_emit_depth;
}

/**
 * Set current if/ternary arm emit depth.
 * @param v i32 — new arm emit depth
 * @return void
 * wave220 pure: G.7 authority (was Cap residual emit_fwd static + set).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_if_expr_arm_emit_depth_set(v: i32): void {
  g_if_expr_arm_emit_depth = v;
}

/**
 * Get current asm emit function index.
 * @return i32 — function index in emit module, or -1 if none
 * wave221 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_func_index_get(): i32 {
  return g_pipeline_asm_emit_func_index;
}

/**
 * Set current asm emit function index.
 * @param fi i32 — function index, or -1 to clear
 * @return void
 * wave221 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_func_index_set(fi: i32): void {
  g_pipeline_asm_emit_func_index = fi;
}

/**
 * Get current emit AST arena pointer.
 * @return *u8 — ast_ASTArena* as *u8, or null
 * wave221 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_arena_get(): *u8 {
  return g_pipeline_asm_emit_arena;
}

/**
 * Set current emit AST arena pointer.
 * @param arena *u8 — ast_ASTArena* as *u8; may be null
 * @return void
 * wave221 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_arena_set(arena: *u8): void {
  g_pipeline_asm_emit_arena = arena;
}

/**
 * Get callee param type_ref during CALL arg emit.
 * @return i32 — type_ref, or 0 if unset
 * wave221 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_call_param_ty_get(): i32 {
  return g_pipeline_asm_emit_call_param_ty_ref;
}

/**
 * Set callee param type_ref during CALL arg emit.
 * @param type_ref i32 — param type_ref (0 clears)
 * @return void
 * wave221 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_call_param_ty_set(type_ref: i32): void {
  g_pipeline_asm_emit_call_param_ty_ref = type_ref;
}

/**
 * Get CALL arg emit nesting depth.
 * @return i32 — depth (>=0); >0 means inside CALL-arg packing
 * wave221 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_call_arg_depth_get(): i32 {
  return g_glue_emit_call_arg_depth;
}

/**
 * Set CALL arg emit nesting depth.
 * @param d i32 — new depth (callers push/pop by 1)
 * @return void
 * wave221 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_call_arg_depth_set(d: i32): void {
  g_glue_emit_call_arg_depth = d;
}

/**
 * Get current ELF codegen ctx pointer.
 * @return *u8 — platform_elf_ElfCodegenCtx* as *u8, or null
 * wave221 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_elf_ctx_get(): *u8 {
  return g_pipeline_asm_emit_elf_ctx;
}

/**
 * Set current ELF codegen ctx pointer.
 * @param elf_ctx *u8 — ElfCodegenCtx* as *u8; may be null
 * @return void
 * wave221 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_elf_ctx_set(elf_ctx: *u8): void {
  g_pipeline_asm_emit_elf_ctx = elf_ctx;
}

/**
 * Get current emit block scope ref.
 * @return i32 — block_ref (0 = unset / module scope)
 * wave221 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_scope_block_get(): i32 {
  return g_pipeline_asm_emit_scope_block;
}

/**
 * Set current emit block scope ref (process-local cell only).
 * @param block_ref i32 — block scope ref
 * @return void
 * wave221 pure: G.7 authority (was Cap residual static write in set_scope_block).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_scope_block_set(block_ref: i32): void {
  g_pipeline_asm_emit_scope_block = block_ref;
}

/**
 * Host compile-time ISA polarity for frame/param home layout.
 * @return i32 — 1 arm64 / 0 x86_64 (or other)
 * wave221 pure: G.7 authority (was Cap residual glue_statics host-cc #if).
 * PLATFORM: SHARED — cfg(target_arch); MACOS|ARM64 + LINUX aarch64 → 1.
 */
#[no_mangle]
export function pipeline_asm_host_is_arm64_c(): i32 {
  return g_pipeline_asm_host_is_arm64_lit;
}
