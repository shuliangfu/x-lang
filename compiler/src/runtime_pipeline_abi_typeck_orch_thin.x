// Thin pure: wave318 M2 — pipeline_typeck_orch Cap residual full C→.x
// (wave293: rename shims; wave318: layout glue was C thin).
// Faces: typeck_x_ast*_c rename shims + zero_padding / size / align from_layout.
// G.7: bodies match seeds/runtime_pipeline_abi.from_x.c WAVE285_TYPECK_ORCH_ALWAYS.
// PRODUCT inject: wave331 PREFER_ASM via pipeline_abi_inject_typeck_orch_thin
// (ALLOW_E_REPLACE + stamp). No BSS. Out-param *i32 reloc OK under pure-asm
// (historical Option-ptr red closed; -E+$CC was interim).
// No FROM_X gate.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function typeck_x_ast_check_one_func(module: *u8, arena: *u8, ctx: *u8, func_idx: i32): i32;
export extern function typeck_x_ast_impl(module: *u8, arena: *u8, ctx: *u8): i32;
export extern function typeck_x_ast_library(module: *u8, arena: *u8, ctx: *u8): i32;
export extern function typeck_x_ast(module: *u8, arena: *u8, ctx: *u8): i32;
export extern function typeck_typeck_struct_layout_metrics(
  module: *u8, arena: *u8, li: i32, depth: i32, want_align: i32,
  out_size: *i32, out_align: *i32): i32;
export extern function pipeline_module_num_struct_layouts_at(m: *u8): i32;

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

/**
 * Validate all struct layouts have zero padding waste.
 * @param module *u8 — ast_Module* as *u8
 * @param arena *u8 — ast_ASTArena* as *u8
 * @return i32 — 0 OK; -1 null or metrics fail
 * wave318 pure: G.7 authority (was Cap residual C thin layout glue).
 * PLATFORM: SHARED freestanding typeck.
 */
#[no_mangle]
export function typeck_validate_struct_layouts_zero_padding_glue(module: *u8, arena: *u8): i32 {
  let li: i32 = 0;
  let nsl: i32 = 0;
  if (module == (0 as *u8) || arena == (0 as *u8)) {
    return -1;
  }
  unsafe {
    nsl = pipeline_module_num_struct_layouts_at(module);
  }
  while (li < nsl) {
    let dz: i32 = 0;
    let da: i32 = 1;
    let rc: i32 = 0;
    unsafe {
      rc = typeck_typeck_struct_layout_metrics(module, arena, li, 0, 1, &dz, &da);
    }
    if (rc != 0) {
      return -1;
    }
    li = li + 1;
  }
  return 0;
}

/**
 * Compute TYPE_NAMED size from struct_layout when layout exists.
 * @param module *u8 — ast_Module* as *u8
 * @param arena *u8 — ast_ASTArena* as *u8
 * @param li i32 — struct_layout index
 * @param depth i32 — recursion depth into nested layouts
 * @return i32 — size in bytes; 0 on bad index / metrics fail
 * wave318 pure: G.7 authority (was Cap residual C thin layout glue).
 * PLATFORM: SHARED freestanding typeck.
 */
#[no_mangle]
export function typeck_x_type_size_from_layout_glue(module: *u8, arena: *u8, li: i32, depth: i32): i32 {
  let z2: i32 = 0;
  let al2: i32 = 1;
  if (li < 0) {
    return 0;
  }
  unsafe {
    if (typeck_typeck_struct_layout_metrics(module, arena, li, depth, 0, &z2, &al2) != 0) {
      return 0;
    }
  }
  return z2;
}

/**
 * Compute TYPE_NAMED align from struct_layout when layout exists.
 * @param module *u8 — ast_Module* as *u8
 * @param arena *u8 — ast_ASTArena* as *u8
 * @param li i32 — struct_layout index
 * @param depth i32 — recursion depth into nested layouts
 * @return i32 — align in bytes (>=1); 1 on bad index / metrics fail
 * wave318 pure: G.7 authority (was Cap residual C thin layout glue).
 * PLATFORM: SHARED freestanding typeck.
 */
#[no_mangle]
export function typeck_x_type_align_from_layout_glue(module: *u8, arena: *u8, li: i32, depth: i32): i32 {
  let z2: i32 = 0;
  let al2: i32 = 1;
  if (li < 0) {
    return 1;
  }
  unsafe {
    if (typeck_typeck_struct_layout_metrics(module, arena, li, depth, 0, &z2, &al2) != 0) {
      return 1;
    }
  }
  if (al2 > 0) {
    return al2;
  }
  return 1;
}
