// Thin pure: wave295 M2 — glue_statics Cap residual C→.x
// (was wave261 C thin). glue_asm_ctx_set_scope_block +
// glue_block_body_bind_module_dep_from_ctx. No BSS. No FROM_X gate.
// G.7: bodies match seeds/runtime_pipeline_abi.from_x.c wave261 cold twins.
// PRODUCT inject: -E+$CC via pipeline_abi_inject_glue_statics_thin
// (ALLOW_E_REPLACE; stamp). Prefer PREFER_ASM only when proven green.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.
//
// LP64 layout: module_ref@16 / dep_pipe@1384 (tail_join_label@1392 - 8).
// Pointer loads use pipe_load_ptr_slot (slot index = byte_off / 8).

export extern function asm_ctx_set_scope_block(ctx: *u8, block_ref: i32): void;
export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_asm_emit_ctx_scope_block_set(block_ref: i32): void;
export extern function pipeline_asm_emit_ctx_module_set(m: *u8): void;
export extern function pipeline_asm_emit_ctx_dep_pipe_set(ctx: *u8): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;

/* LP64 byte offsets → pipe_load_ptr_slot indices (×8). */
const W261_SLOT_MODULE_REF: i32 = 2;
const W261_SLOT_DEP_PIPE: i32 = 173;

/**
 * Set process-local emit scope block + per-ctx sidecar scope_block_ref.
 * PLATFORM: SHARED freestanding emit scope bookkeeping (wave295 .x thin).
 */
#[no_mangle]
export function glue_asm_ctx_set_scope_block(ctx: *u8, block_ref: i32): void {
  unsafe {
    pipeline_asm_emit_ctx_scope_block_set(block_ref);
    asm_ctx_set_scope_block(ctx, block_ref);
  }
}

/**
 * Bind process-local emit module + dep_pipe from AsmFuncCtx layout fields.
 * LP64: module_ref@16 / dep_pipe@1384.
 * PLATFORM: SHARED freestanding emit Cap bridge (wave295 .x thin).
 */
#[no_mangle]
export function glue_block_body_bind_module_dep_from_ctx(ctx: *u8): void {
  let ly: *u8 = 0 as *u8;
  let mod: *u8 = 0 as *u8;
  let dep: *u8 = 0 as *u8;
  if (ctx == (0 as *u8)) {
    return;
  }
  unsafe {
    ly = pipeline_asm_ctx_layout(ctx);
  }
  if (ly == (0 as *u8)) {
    return;
  }
  unsafe {
    mod = pipe_load_ptr_slot(ly, W261_SLOT_MODULE_REF);
  }
  if (mod != (0 as *u8)) {
    unsafe {
      pipeline_asm_emit_ctx_module_set(mod);
    }
  }
  unsafe {
    dep = pipe_load_ptr_slot(ly, W261_SLOT_DEP_PIPE);
  }
  if (dep != (0 as *u8)) {
    unsafe {
      pipeline_asm_emit_ctx_dep_pipe_set(dep);
    }
  }
}
