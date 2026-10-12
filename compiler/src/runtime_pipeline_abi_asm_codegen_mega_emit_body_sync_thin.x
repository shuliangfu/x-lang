// Thin pure: mega emit_one block-body sync peer (wave499).
// G.7: part of w393_mega_emit_one (peer-flat; nso>0 path).
// tipU: isolated leaf keeps emit_next_label + backend_emit_block_body_sync.
// PRODUCT: LINUX+MACOS PREFER with emit_one head. PLATFORM: SHARED.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_debug_trace_named_func_bodies(phase: *u8, module: *u8, arena: *u8): void;
export extern function pipeline_asm_emit_next_label_c(ctx: *u8, buf: *u8, buf_size: i32): i32;
export extern function backend_emit_block_body_sync_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_label_arch(elf_ctx: *u8, name: *u8, name_len: i32, is_global: i32, ta: i32): i32;

/**
 * Load i32 from pipe cell (unique name — avoid multi-leaf T clash).
 * @param base *u8 — cell base
 * @return i32
 * PLATFORM: SHARED — wave499 tipU helper.
 */
function w499s_c32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

const W328_CTX_TAIL_JOIN_LABEL: i32 = 1392;
const W328_CTX_TAIL_JOIN_LABEL_LEN: i32 = 1520;

/**
 * Emit next-label + sync block body + join label (nso>0 path).
 * @return 0 ok, -1 on emit failure
 * PLATFORM: SHARED — wave499 mega emit_one peer.
 */
#[no_mangle]
export function w499_mega_emit_body_sync(
    m: *u8, a: *u8, elf_ctx: *u8, bctx: *u8, ta: i32, body_ref: i32): i32 {
  unsafe {
    let cell: u8[8];
    let neg1: i32 = 0 - 1;
    let lbl_len: i32 = 0;
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_next_label_c(bctx, bctx + (W328_CTX_TAIL_JOIN_LABEL as usize), 64));
    lbl_len = w499s_c32(&cell[0]);
    pipe_store_i32_le(bctx, W328_CTX_TAIL_JOIN_LABEL_LEN, lbl_len);
    pipeline_debug_trace_named_func_bodies("mega_pre_emit_block_body" as *u8, m, a);
    pipe_store_i32_le(&cell[0], 0, backend_emit_block_body_sync_elf(a, elf_ctx, body_ref, bctx, ta));
    if (w499s_c32(&cell[0]) != 0) { return neg1; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_label_arch(elf_ctx, bctx + (W328_CTX_TAIL_JOIN_LABEL as usize),
                               pipe_load_i32_le(bctx, W328_CTX_TAIL_JOIN_LABEL_LEN), 0, ta));
    if (w499s_c32(&cell[0]) != 0) { return neg1; }
    return 0;
  }
}
