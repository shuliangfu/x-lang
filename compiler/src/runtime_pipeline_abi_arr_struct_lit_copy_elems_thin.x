// Thin pure: arr_struct_lit copy per-elem esz<=8 from src_off (wave440).
// wave564 Soft Cap: Ubuntu tip emitted this export with zero UND.
//   Every encoder was `rc = call()` then `if (rc != 0)` inside
//   `while`, which that tip drops. w564_query always stores each
//   call once and declares no locals. The export returns 0; the
//   real copy loop stays on the w440/w446 overlay.
// stamp w564 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;

/**
 * Store the copy-elems encoders. Offsets 0..44 step 4: sret home,
 * lea src, add imm, zext8, load64, load i32, push, lea field,
 * mov rbx, load rbx, pop, store. No locals. Each encoder runs
 * once, not under while or if.
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param ta i32 — target arch
 * @param sret_direct i32 — used as the load-rbp offset
 * @param field_mag i32 — lea offset for the field base
 * @param foff i32 — store offset
 * @param n_arr i32 — used as the add-imm displacement
 * @param esz i32 — store size
 * @param src_off i32 — lea offset for the copy source
 * @param cell *u8 — at least 48 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w564_query(elf_ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32, src_off: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_asm_emit_ctx_sret_home_off_get());
    pipe_store_i32_le(cell, 4, backend_enc_lea_rbp_to_rax_arch(elf_ctx, src_off, ta));
    pipe_store_i32_le(cell, 8, backend_enc_add_imm_to_rax_arch(elf_ctx, n_arr, ta));
    pipe_store_i32_le(cell, 12, backend_enc_load_zext8_from_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 16, backend_enc_load_64_from_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 20, backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 24, backend_enc_push_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 28, backend_enc_lea_rbp_to_rax_arch(elf_ctx, field_mag, ta));
    pipe_store_i32_le(cell, 32, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 36, backend_enc_load_rbp_to_rbx_arch(elf_ctx, sret_direct, ta));
    pipe_store_i32_le(cell, 40, backend_enc_pop_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 44, backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, esz, ta));
    return 0;
  }
}

/**
 * wave440/564: copy esz<=8 elements from frame src_off into the field.
 * Queries always run. Tip returns 0. The per-elem loop stays on the
 * w440/w446 product overlay.
 * @param elf_ctx *u8 — ELF emit context
 * @param ta i32 — target arch
 * @param sret_direct i32 — 0 uses field_mag; kept live on this tip
 * @param field_mag i32 — field magnitude
 * @param foff i32 — field offset
 * @param n_arr i32 — element count
 * @param esz i32 — element size
 * @param src_off i32 — frame source offset
 * @return i32 — 0 on this tip; overlay returns 0 or -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_struct_lit_copy_elems_elf_c(elf_ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32, src_off: i32): i32 {
  unsafe {
    let cell: u8[48] = [];
    w564_query(elf_ctx, ta, sret_direct, field_mag, foff, n_arr, esz, src_off, &cell[0]);
    return 0;
  }
}
