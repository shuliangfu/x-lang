// Link body of glue_copy_large_struct_from_rax_ptr_elf_c.
// After 9.1 seed hollow, Darwin tip cold only UNDEFs this face. The
// archive_leaf leftover also defines it, but that same object first-wins
// stale struct_lit emit faces and yields CG002. This thin is the seed
// body (seeds/win_copy_large_struct_override.c): memcpy via arg_reg,
// slot_off -3 keeps dest in rbx/x19, other slots lea rbp. Rebuild every
// Darwin relink with no PREFER; link ahead of archive_leaf / pabi_weak.
// Pipe cells hold every extern result — the product drops a direct
// "name = extern(...)" store. No integer / or %.
// PLATFORM: MACOS|DARWIN tip cold (knife 254 / 9.2 copy_large).
// Windows keeps the egg windows_link_stubs body. Linux leftover overlay
// already owns this face.

export extern function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern function backend_enc_call_arch(elf_ctx: *u8, sym: *u8, sym_len: i32, ta: i32): i32;
export extern function backend_enc_mov_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_arm64_mov_x19_to_x0_elf_c(elf_ctx: *u8): i32;
export extern function pipe_load_i32_le(p: *u8, off: i32): i32;
export extern function pipe_store_i32_le(p: *u8, off: i32, v: i32): void;

function w254_copy_large_cell_i32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

/**
 * Emit memcpy of sz bytes from the address in rax into a stack home or
 * the address parked in rbx/x19. slot_off -3 means dest is already in
 * rbx (x86) or x19 (arm64). Other slot_off values lea rbp+slot_off as
 * dest. sz must be at least 8. When slot_off is not -3, sz must also be
 * greater than 16.
 * @param elf_ctx *u8 — emit context. Null returns -1.
 * @param slot_off i32 — rbp home, or -3 for dest-in-rbx/x19.
 * @param sz i32 — byte count. Below 8 returns -1.
 * @param ta i32 — 0 is x86_64, 1 is arm64. Other values return -1.
 * @return i32 — 0 on success, -1 on encode failure or bad args.
 * PLATFORM: MACOS|DARWIN tip cold. Matches the leftover seed body.
 */
#[no_mangle]
export function glue_copy_large_struct_from_rax_ptr_elf_c(
  elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32
): i32 {
  let memcpy_sym: u8[8];
  let cell: u8[8];
  unsafe {
    memcpy_sym[0] = 109;
    memcpy_sym[1] = 101;
    memcpy_sym[2] = 109;
    memcpy_sym[3] = 99;
    memcpy_sym[4] = 112;
    memcpy_sym[5] = 121;
    memcpy_sym[6] = 0;
    if (elf_ctx == 0 as *u8) { return 0 - 1; }
    if (ta != 0) {
      if (ta != 1) { return 0 - 1; }
    }
    if (sz < 8) { return 0 - 1; }
    if (slot_off != 0 - 3) {
      if (sz <= 16) { return 0 - 1; }
    }
    if (slot_off == 0 - 3) {
      if (ta == 1) {
        pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta));
        if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
        pipe_store_i32_le(&cell[0], 0, backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta));
        if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
        pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta));
        if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
        pipe_store_i32_le(&cell[0], 0, glue_arm64_mov_x19_to_x0_elf_c(elf_ctx));
        if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
        pipe_store_i32_le(&cell[0], 0, backend_enc_call_arch(elf_ctx, &memcpy_sym[0], 6, ta));
        return w254_copy_large_cell_i32(&cell[0]);
      }
      pipe_store_i32_le(&cell[0], 0, backend_enc_push_rax_arch(elf_ctx, ta));
      if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta));
      if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta));
      if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rax_arch(elf_ctx, ta));
      if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta));
      if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      pipe_store_i32_le(&cell[0], 0, backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta));
      if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta));
      if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      pipe_store_i32_le(&cell[0], 0, backend_enc_call_arch(elf_ctx, &memcpy_sym[0], 6, ta));
      return w254_copy_large_cell_i32(&cell[0]);
    }
    if (ta == 1) {
      pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
      if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      pipe_store_i32_le(&cell[0], 0, backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta));
      if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta));
      if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      pipe_store_i32_le(&cell[0], 0, backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot_off, ta));
      if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      pipe_store_i32_le(&cell[0], 0, backend_enc_call_arch(elf_ctx, &memcpy_sym[0], 6, ta));
      return w254_copy_large_cell_i32(&cell[0]);
    }
    pipe_store_i32_le(&cell[0], 0, backend_enc_push_rax_arch(elf_ctx, ta));
    if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot_off, ta));
    if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta));
    if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rax_arch(elf_ctx, ta));
    if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta));
    if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta));
    if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta));
    if (w254_copy_large_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_call_arch(elf_ctx, &memcpy_sym[0], 6, ta));
    return w254_copy_large_cell_i32(&cell[0]);
  }
}
