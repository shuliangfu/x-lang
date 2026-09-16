// Thin pure: wave293 M2 — pipeline_typeck_orch Cap residual C→.x
// (was wave285 C thin). Product rename shims only: typeck_x_ast*_c.
// Layout glue (zero_padding / size / align from_layout) stays seed ALWAYS
// residual — .x out-param &i32 face red on Option ptr (opt return -16/240);
// leave those three faces to seed until out-param ABI green.
// G.7: shim bodies match seeds/runtime_pipeline_abi.from_x.c
// WAVE285_TYPECK_ORCH_ALWAYS. No BSS. No FROM_X gate.
// ensure injects via pipeline_abi_inject_thin_leaf (PREFER_ASM + stamp).
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.
//
// Note: inventory wave293 bare_link_alias host wrappers are already
// seed-only (absent). This leaf reuses the wave slot for host-cc→0.

export extern function typeck_x_ast_check_one_func(module: *u8, arena: *u8, ctx: *u8, func_idx: i32): i32;
export extern function typeck_x_ast_impl(module: *u8, arena: *u8, ctx: *u8): i32;
export extern function typeck_x_ast_library(module: *u8, arena: *u8, ctx: *u8): i32;
export extern function typeck_x_ast(module: *u8, arena: *u8, ctx: *u8): i32;

/**
 * Product-mega C face for per-function body typeck.
 * Thin → typeck_x_ast_check_one_func (wave684+ generic body check).
 * PLATFORM: SHARED — Cap residual rename shim (wave293 .x thin).
 */
#[no_mangle]
export function pipeline_typeck_x_ast_check_one_func_c(module: *u8, arena: *u8, ctx: *u8, func_idx: i32): i32 {
  unsafe {
    return typeck_x_ast_check_one_func(module, arena, ctx, func_idx);
  }
}

/**
 * Product-mega C face for whole-module typeck (main preconditions + loop).
 * Thin → typeck_x_ast_impl.
 * PLATFORM: SHARED — Cap residual rename shim (wave293 .x thin).
 */
#[no_mangle]
export function pipeline_typeck_x_ast_impl_c(module: *u8, arena: *u8, ctx: *u8): i32 {
  unsafe {
    return typeck_x_ast_impl(module, arena, ctx);
  }
}

/**
 * Product-mega C face for library-module typeck (no main).
 * Thin → typeck_x_ast_library.
 * PLATFORM: SHARED — Cap residual rename shim (wave293 .x thin).
 */
#[no_mangle]
export function pipeline_typeck_x_ast_library_c(module: *u8, arena: *u8, ctx: *u8): i32 {
  unsafe {
    return typeck_x_ast_library(module, arena, ctx);
  }
}

/**
 * Product-mega C face for whole-module typeck entry.
 * Thin → typeck_x_ast.
 * PLATFORM: SHARED — Cap residual rename shim (wave293 .x thin).
 */
#[no_mangle]
export function pipeline_typeck_x_ast_c(module: *u8, arena: *u8, ctx: *u8): i32 {
  unsafe {
    return typeck_x_ast(module, arena, ctx);
  }
}
