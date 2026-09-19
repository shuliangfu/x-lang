// Thin pure: wave601 M2 — emit_ctx func_index get/set peer-flat.
// Smash leftover PREFER of the w342/w380 bss_thin family
// (`sub $0x858`, no endbr64) makes pipeline_asm_emit_ctx_func_index_get
// return -1, so while-body final_expr (if-in-while) takes
// glue_emit_block_final_expr_elf tail_join fallback and jmp .Lf0_0.
// Full emit_ctx_bss_thin PREFER stays HARD BAN (w380 L2 SEGV; w601
// -E of the 15-export TU broke option ptr load). This peer is only
// the func_index cell. G.7: bodies match mega wave221 leave / bss_thin.
// PRODUCT: LINUX -E replace leftover T; HARD BAN PREFER; MACOS overlay.
// PLATFORM: SHARED · LINUX gold · MACOS.

// wave221: current emit function index (-1 = none).
let g_pipeline_asm_emit_func_index: i32 = -1;

/**
 * Get current asm emit function index.
 * @return i32 — function index in emit module, or -1 if none
 * wave221 pure: G.7 authority (was Cap residual glue_statics).
 * wave601: LINUX product path is host-cc -E of this getter (PREFER smash BAN).
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
 * wave601: LINUX product path is host-cc -E of this setter (PREFER smash BAN).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_func_index_set(fi: i32): void {
  g_pipeline_asm_emit_func_index = fi;
}
