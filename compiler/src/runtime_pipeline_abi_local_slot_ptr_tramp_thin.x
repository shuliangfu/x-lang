// Thin ELF face: glue_enc_local_slot_ptr_or_addr_elf_c.
// 256/10.2 Cap tip: m8 hollow stub (ret 0, no encode) first-won → field SEGV;
// text-face tramp (wrong out=elf_ctx) returned 1 → CG002. This face mirrors
// restored leftover ELF: needs_ptr_load → LDR, else LEA into rax/x0.
// PLATFORM: SHARED freestanding Cap leave. No new host-cc .c.

export extern function glue_local_var_slot_needs_ptr_load_elf_c(
  arena: *u8, var_ref: i32, var_off: i32, ctx: *u8
): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;

#[no_mangle]
export function glue_enc_local_slot_ptr_or_addr_elf_c(
  arena: *u8, elf_ctx: *u8, var_ref: i32, var_off: i32, ctx: *u8, ta: i32
): i32 {
  unsafe {
    if (elf_ctx == (0 as *u8)) {
      return 0 - 1;
    }
    if (glue_local_var_slot_needs_ptr_load_elf_c(arena, var_ref, var_off, ctx) != 0) {
      return backend_enc_load_rbp_to_rax_arch(elf_ctx, var_off, ta);
    }
    return backend_enc_lea_rbp_to_rax_arch(elf_ctx, var_off, ta);
  }
}
