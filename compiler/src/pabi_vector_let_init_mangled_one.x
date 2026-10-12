// Mangled Cap residual face of pipeline_asm_emit_vector_let_init_elf_c.
// Windows leftover store and glue_emit_vector_type_let_init call this
// name. The body stays in pabi_vector_let_init_nested_one.x. Same-.o
// dual T smashes i32, so this link winner is its own object. Do not
// gcc seeds/vector_let_init_nested_override.c on Windows, Linux, or
// Darwin. Darwin rebuilds this object.
// PLATFORM: SHARED body. Linux, Darwin, and Windows relinks consume this object.

export extern function pipeline_asm_emit_vector_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32;

/**
 * Mangled name. Forwards to the short-name body.
 * @param arena *u8 — AST arena; null returns -1 from the body
 * @param elf_ctx *u8 — object writer; null returns -1 from the body
 * @param init_ref i32 — ARRAY_LIT expr ref
 * @param ctx *u8 — AsmFuncCtx; null returns -1 from the body
 * @param ta i32 — 0 x86, 1 arm64
 * @param stack_slot_off i32 — destination slot of element 0
 * @return i32 — the short-name result, 0 stored or -1 failure
 * No second copy of the element loop lives here.
 * PLATFORM: SHARED — one strong T. Linux, Darwin, and Windows link this ahead of the egg.
 */
#[no_mangle]
export function pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32 {
  unsafe {
    return pipeline_asm_emit_vector_let_init_elf_c(
      arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
  }
}
