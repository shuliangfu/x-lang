// Darwin leftover store branches to this stubdead name. It is the
// same body as pipeline_asm_emit_vector_let_init_elf_c. The body stays
// in pabi_vector_let_init_nested_one.x. Same-.o dual T smashes i32, so
// this link winner is its own object. Windows and Linux still link it
// so a leftover undef does not fall through to a Cap residual -1.
// PLATFORM: MACOS|DARWIN call site. WINDOWS and LINUX link the strong T.

export extern function pipeline_asm_emit_vector_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32;

/**
 * stubdead name. Forwards to the short-name body.
 * @param arena *u8 — AST arena; null returns -1 from the body
 * @param elf_ctx *u8 — object writer; null returns -1 from the body
 * @param init_ref i32 — ARRAY_LIT expr ref
 * @param ctx *u8 — AsmFuncCtx; null returns -1 from the body
 * @param ta i32 — 0 x86, 1 arm64
 * @param stack_slot_off i32 — destination slot of element 0
 * @return i32 — the short-name result, 0 stored or -1 failure
 * No second copy of the element loop lives here.
 * PLATFORM: MACOS|DARWIN — leftover bl target. Linux and Windows link the T too.
 */
#[no_mangle]
export function pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32_pabi_stubdead(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32 {
  unsafe {
    return pipeline_asm_emit_vector_let_init_elf_c(
      arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
  }
}
