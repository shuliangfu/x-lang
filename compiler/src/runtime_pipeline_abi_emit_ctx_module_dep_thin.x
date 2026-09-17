// Thin pure: wave315 M2 — emit_ctx_module_dep Cap residual C→.x (was wave222 C thin).
// Emit module + dep_pipe pointer BSS + get/set; 4 exports.
// G.7: bodies match runtime_pipeline_abi.x wave222 leave.
// PRODUCT inject: -E+$CC via pipeline_abi_inject_emit_ctx_module_dep_thin
// (ALLOW_E_REPLACE + stamp). Named pointer BSS OK under -E+$CC.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

let g_pipeline_asm_emit_module: *u8 = 0 as *u8;
// wave222: current emit PipelineDepCtx* (import layout / WPO dep pool).
let g_pipeline_asm_emit_dep_pipe: *u8 = 0 as *u8;

/**
 * Get current asm emit module pointer.
 * @return *u8 — ast_Module* as *u8, or null
 * wave222 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_module_get(): *u8 {
  return g_pipeline_asm_emit_module;
}

/**
 * Set current asm emit module pointer.
 * @param m *u8 — ast_Module* as *u8; may be null
 * @return void
 * wave222 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_module_set(m: *u8): void {
  g_pipeline_asm_emit_module = m;
}

/**
 * Get current asm emit dep pipe pointer.
 * @return *u8 — ast_PipelineDepCtx* as *u8, or null
 * wave222 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_dep_pipe_get(): *u8 {
  return g_pipeline_asm_emit_dep_pipe;
}

/**
 * Set current asm emit dep pipe pointer.
 * @param ctx *u8 — ast_PipelineDepCtx* as *u8; may be null
 * @return void
 * wave222 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_dep_pipe_set(ctx: *u8): void {
  g_pipeline_asm_emit_dep_pipe = ctx;
}

