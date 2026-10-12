// Thin pure: wave295 M2 — glue_statics Cap residual C→.x
// (was wave261 C thin). glue_asm_ctx_set_scope_block +
// glue_block_body_bind_module_dep_from_ctx. No BSS. No FROM_X gate.
// G.7: bodies match seeds/runtime_pipeline_abi.from_x.c wave261 cold twins.
// PRODUCT inject: wave332 PREFER_ASM via pipeline_abi_inject_glue_statics_thin
// (ALLOW_E_REPLACE + stamp). No BSS; standalone -c green (was -E+$CC interim).
// wave477: tip no-local HARD BAN (tip U=6/6; reinject → L2 CG002 4/5); keep w332.
// wave506: tipU re-heal — ban mid `ly=call()` / `mod=call()` (tip drop → 4/6);
//   re-call layout/slot in conditions only. tipU 6/6; tip PRODUCT PREFER still BAN.
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
 * wave506: no-local — re-call layout/slot (ban `ly=call()` / `mod=call()` tip drop).
 * PLATFORM: SHARED freestanding emit Cap bridge (wave295 .x thin).
 */
#[no_mangle]
export function glue_block_body_bind_module_dep_from_ctx(ctx: *u8): void {
  if (ctx == (0 as *u8)) {
    return;
  }
  unsafe {
    if (pipeline_asm_ctx_layout(ctx) == (0 as *u8)) {
      return;
    }
    if (pipe_load_ptr_slot(pipeline_asm_ctx_layout(ctx), W261_SLOT_MODULE_REF) != (0 as *u8)) {
      pipeline_asm_emit_ctx_module_set(pipe_load_ptr_slot(pipeline_asm_ctx_layout(ctx), W261_SLOT_MODULE_REF));
    }
    if (pipe_load_ptr_slot(pipeline_asm_ctx_layout(ctx), W261_SLOT_DEP_PIPE) != (0 as *u8)) {
      pipeline_asm_emit_ctx_dep_pipe_set(pipe_load_ptr_slot(pipeline_asm_ctx_layout(ctx), W261_SLOT_DEP_PIPE));
    }
  }
}
