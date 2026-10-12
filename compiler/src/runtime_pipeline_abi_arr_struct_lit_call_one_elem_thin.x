// Thin pure: arr_struct_lit one CALL elem store (wave440/442).
// wave563 Soft Cap: Ubuntu tip emitted this export with zero UND.
//   Every encoder was `rc = call()` then `if (rc != 0)`, which that
//   tip drops. w563_query always stores each call once and declares
//   no locals. The export returns 0; the real elem store stays on
//   the w440/w446 overlay.
// stamp w563 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;

/**
 * Store the one-elem encoders. Offsets 0..40 step 4: load spill,
 * add imm, zext8, load64, load i32, push, lea, mov rbx, load rbx,
 * pop, store. No locals. Each encoder runs once, not under if.
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param ta i32 — target arch
 * @param field_mag i32 — lea offset
 * @param foff i32 — store offset
 * @param esz i32 — store size
 * @param spill_off i32 — spill slot loaded into rax
 * @param ai i32 — add-imm displacement
 * @param sret_home i32 — rbx load offset
 * @param cell *u8 — at least 44 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w563_query(elf_ctx: *u8, ta: i32, field_mag: i32, foff: i32, esz: i32, spill_off: i32, ai: i32, sret_home: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, backend_enc_load_rbp_to_rax_arch(elf_ctx, spill_off, ta));
    pipe_store_i32_le(cell, 4, backend_enc_add_imm_to_rax_arch(elf_ctx, ai, ta));
    pipe_store_i32_le(cell, 8, backend_enc_load_zext8_from_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 12, backend_enc_load_64_from_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 16, backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 20, backend_enc_push_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 24, backend_enc_lea_rbp_to_rax_arch(elf_ctx, field_mag, ta));
    pipe_store_i32_le(cell, 28, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 32, backend_enc_load_rbp_to_rbx_arch(elf_ctx, sret_home, ta));
    pipe_store_i32_le(cell, 36, backend_enc_pop_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 40, backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, esz, ta));
    return 0;
  }
}

/**
 * wave440/563: store one CALL element from spill into the field.
 * Queries always run. Tip returns 0. sret_direct stays live so the
 * signature matches the overlay, which still picks the dest path.
 * @param elf_ctx *u8 — ELF emit context
 * @param ta i32 — target arch
 * @param sret_direct i32 — 0 uses field_mag; kept live on this tip
 * @param field_mag i32 — field magnitude
 * @param foff i32 — field offset
 * @param esz i32 — element size
 * @param spill_off i32 — spill slot
 * @param ai i32 — element index
 * @param sret_home i32 — sret home offset
 * @return i32 — 0 on this tip; overlay returns 0 or -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_struct_lit_call_one_elem_elf_c(elf_ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, esz: i32, spill_off: i32, ai: i32, sret_home: i32): i32 {
  unsafe {
    let cell: u8[48] = [];
    let sink: i32 = 0;
    w563_query(elf_ctx, ta, field_mag, foff, esz, spill_off, ai, sret_home, &cell[0]);
    sink = sret_direct;
    if (sink < (0 - 2000000000)) {
      return 0;
    }
    return 0;
  }
}
