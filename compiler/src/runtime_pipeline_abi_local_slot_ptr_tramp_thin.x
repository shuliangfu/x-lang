// Thin trampoline: glue_enc_local_slot_ptr_or_addr_elf_c → arch text face.
// 256/10.2 Cap tip: m8 hollow stub (mov w0,#0; ret) first-won and left rax
// stale → field load SEGV. Prefer this over m8. No new host-cc .c.
// PLATFORM: SHARED freestanding Cap leave.

export extern function glue_arch_emit_local_slot_ptr_or_addr_text_c(
  arena: *u8, out: *u8, var_expr_ref: i32, stack_off: i32, ctx: *u8, ta: i32
): i32;

#[no_mangle]
export function glue_enc_local_slot_ptr_or_addr_elf_c(
  arena: *u8, elf_ctx: *u8, var_ref: i32, var_off: i32, ctx: *u8, ta: i32
): i32 {
  unsafe {
    return glue_arch_emit_local_slot_ptr_or_addr_text_c(arena, elf_ctx, var_ref, var_off, ctx, ta);
  }
}
