// Thin prefix for the egg asm_skip_heavy_module_func_body.
// w1624: the linked egg returns from the null check straight into
// asm_module_is_compiler_selfhost. runtime_pipeline_abi.x checks
// asm_env_force_full_bodies before that, but the egg predates the
// check and does not define the symbol. Twelve R_X86_64_PLT32 sites
// inside the egg call asm_skip_heavy_module_func_body. g05 copies the
// egg, keeps those bytes under asm_skip_heavy_module_func_body_egg,
// and makes the original name undefined so this file is the one body.
// FORCE unset calls the egg body, so the default product path is the
// egg dispatcher. This file does not copy that dispatcher.
// Do not rebuild the pabi egg. PLATFORM: LINUX.

export extern "C" function link_abi_getenv(name: *u8): *u8;
export extern "C" function asm_diag_env_truthy(e: *u8): i32;
export extern "C" function asm_skip_heavy_module_func_body_egg(m: *u8, arena: *u8, func_index: i32): i32;

/**
 * Report whether XLANG_ASM_FORCE_FULL_BODIES asks for every body.
 * @return i32 — 1 when the env is truthy, else 0
 * Truthiness is asm_diag_env_truthy (null, empty, or a leading '0'
 * is off). That helper is a weak egg symbol, not a second copy here.
 * PLATFORM: LINUX — sole linked body; the egg does not define this name.
 */
#[no_mangle]
export function asm_env_force_full_bodies(): i32 {
  unsafe {
    return asm_diag_env_truthy(link_abi_getenv("XLANG_ASM_FORCE_FULL_BODIES"));
  }
}

/**
 * Skip a heavy self-host body, unless FORCE asks for a real emit.
 * @param m *u8 — Module*; null is forwarded to the egg body
 * @param arena *u8 — ASTArena*; may be null
 * @param func_index i32 — function index
 * @return i32 — 1 when the body stays a stub, 0 when it must be emitted
 * FORCE set returns 0 before the egg dispatcher runs. FORCE unset
 * calls asm_skip_heavy_module_func_body_egg, the original bytes.
 * PLATFORM: LINUX — linked ahead of the derived egg. Darwin and Windows
 * do not build this file.
 */
#[no_mangle]
export function asm_skip_heavy_module_func_body(m: *u8, arena: *u8, func_index: i32): i32 {
  unsafe {
    if (asm_env_force_full_bodies() != 0) {
      return 0;
    }
    return asm_skip_heavy_module_func_body_egg(m, arena, func_index);
  }
}
