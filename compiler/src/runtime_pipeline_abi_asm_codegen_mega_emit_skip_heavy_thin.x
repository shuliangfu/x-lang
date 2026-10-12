// Thin pure: mega emit_one skip-heavy stub peer (wave499).
// G.7: part of w393_mega_emit_one (peer-flat; skip_heavy!=0 path).
// tipU: isolated leaf keeps prologue(0) + skip_heavy_or_thin_stub.
// PRODUCT: LINUX+MACOS PREFER with emit_one head. PLATFORM: SHARED.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function backend_enc_prologue_arch(elf_ctx: *u8, frame_sz: i32, ta: i32): i32;
export extern function pipeline_asm_emit_skip_heavy_or_thin_stub_elf_c(elf_ctx: *u8, ta: i32, mod: *u8, func_index: i32): i32;

/**
 * Load i32 from pipe cell (unique name — avoid multi-leaf T clash).
 * @param base *u8 — cell base
 * @return i32
 * PLATFORM: SHARED — wave499 tipU helper.
 */
function w499k_c32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

/**
 * Empty prologue + skip-heavy / thin stub epilogue path.
 * @return 0 ok, -1 on emit failure
 * PLATFORM: SHARED — wave499 mega emit_one peer.
 */
#[no_mangle]
export function w499_mega_emit_skip_heavy(
    elf_ctx: *u8, ta: i32, m: *u8, i: i32): i32 {
  unsafe {
    let cell: u8[8];
    let neg1: i32 = 0 - 1;
    pipe_store_i32_le(&cell[0], 0, backend_enc_prologue_arch(elf_ctx, 0, ta));
    if (w499k_c32(&cell[0]) != 0) { return neg1; }
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_skip_heavy_or_thin_stub_elf_c(elf_ctx, ta, m, i));
    if (w499k_c32(&cell[0]) != 0) { return neg1; }
    return 0;
  }
}
