// 记211: tip pure overlay — non-hoist top-level let registration.
// Probe isolation: no-op body. If Linux early-return still dies, the dead
// slot is NOT from this face. PRODUCT: _g05_pure_overlay first-wins Cap.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS co-path.

/**
 * No-op: do not shadow module consts/lets with unseeded frame slots.
 * Hoist-target still gets inits via hoist; other funcs use const_lit/modlet.
 * PLATFORM: SHARED freestanding · tip pure overlay.
 */
#[no_mangle]
export function pipeline_asm_register_module_top_level_lets_c(ctx: *u8, m: *u8, a: *u8, func_index: i32): void {
  return;
}
