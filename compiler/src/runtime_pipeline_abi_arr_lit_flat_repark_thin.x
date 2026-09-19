// Thin pure: arr_lit_flat repark leaf (wave438).
// wave568 Soft Cap: Ubuntu tip `-backend asm -c` UND=0. Every encoder
//   was `rc = call()` then `if (rc != 0)`, which that tip drops.
//   w568_query always stores each encoder once and declares no
//   locals. The export returns 0; the real repark stays on the
//   w438 overlay. Do not store through *i32 (flat_i).
// stamp w568 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the repark-rbx encoders. Offsets 0..12 step 4: push rax,
 * lea rbp→rax at stack_slot_off, mov rax→rbx, pop rax. No locals.
 * Each encoder runs once, not under if.
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param ta i32 — target arch
 * @param stack_slot_off i32 — array base frame magnitude (lea offset)
 * @param cell *u8 — at least 16 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w568_query(elf_ctx: *u8, ta: i32, stack_slot_off: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, backend_enc_push_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 4, backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta));
    pipe_store_i32_le(cell, 8, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 12, backend_enc_pop_rax_arch(elf_ctx, ta));
    return 0;
  }
}

/**
 * wave438/568: after a scalar elem emit, repark the array base into
 * rbx when the elem may clobber rbx. Queries always run. Tip returns
 * 0 and must not write *flat_i (Ubuntu x86_64 `-backend asm -c`
 * SEGV 139 on store through a *i32). The real repark stays on the
 * w438 product overlay.
 * @param arena *u8 — unused on this tip; ABI match
 * @param elf_ctx *u8 — ELF emit context
 * @param init_ref i32 — unused on this tip; ABI match
 * @param ctx *u8 — unused on this tip; ABI match
 * @param ta i32 — target arch
 * @param stack_slot_off i32 — array base frame magnitude
 * @param leaf_esz i32 — unused on this tip; ABI match
 * @param flat_i *i32 — overlay may update; tip does not store through it
 * @return i32 — 0 on this tip; overlay returns 0 or -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_array_lit_flat_repark_rbx_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32): i32 {
  unsafe {
    let cell: u8[16] = [];
    w568_query(elf_ctx, ta, stack_slot_off, &cell[0]);
    return 0;
  }
}
