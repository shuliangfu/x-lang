// Thin pure: wave316/341/380 M2 — emit_ctx_sret Cap residual (was wave223 C thin).
// sret_active / sret_home_off(-1) / sret_ret_sz scalar BSS + get/set; 6 exports.
// G.7: bodies match runtime_pipeline_abi.x wave223 leave.
// PRODUCT inject (pipeline_abi_inject_emit_ctx_sret_thin, stamp w380):
//   Prior: LINUX PREFER / DARWIN -E overlays kept.
//   HARD BAN reinject both ends (Darwin BRANCH26; Ubuntu tip SEGV).
// PLATFORM: SHARED · BAN reinject both ends (keep prior overlays).

let g_pipeline_asm_func_sret_active: i32 = 0;
// wave223: sret home stack offset; -1 = unset (must survive -E init).
let g_pipeline_asm_sret_home_off: i32 = -1;
let g_pipeline_asm_func_sret_ret_sz: i32 = 0;

/**
 * Get sret-active flag for current asm emit function.
 * @return i32 — 0 = inactive; non-zero = SysV rdi / AAPCS64 x8 sret polarity
 * wave223 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_sret_active_get(): i32 {
  return g_pipeline_asm_func_sret_active;
}

/**
 * Set sret-active flag for current asm emit function.
 * @param v i32 — 0 clears; non-zero arms sret polarity
 * @return void
 * wave223 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_sret_active_set(v: i32): void {
  g_pipeline_asm_func_sret_active = v;
}

/**
 * Get sret home stack offset (bytes from rbp/fp).
 * @return i32 — home offset, or -1 when unset
 * wave223 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_sret_home_off_get(): i32 {
  return g_pipeline_asm_sret_home_off;
}

/**
 * Set sret home stack offset (bytes from rbp/fp).
 * @param off i32 — home offset; pass -1 to clear
 * @return void
 * wave223 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_sret_home_off_set(off: i32): void {
  g_pipeline_asm_sret_home_off = off;
}

/**
 * Get sret return byte width for current asm emit function.
 * @return i32 — return size in bytes (0 when inactive / scalar)
 * wave223 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_sret_ret_sz_get(): i32 {
  return g_pipeline_asm_func_sret_ret_sz;
}

/**
 * Set sret return byte width for current asm emit function.
 * @param sz i32 — return size in bytes; 0 clears
 * @return void
 * wave223 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_sret_ret_sz_set(sz: i32): void {
  g_pipeline_asm_func_sret_ret_sz = sz;
}
