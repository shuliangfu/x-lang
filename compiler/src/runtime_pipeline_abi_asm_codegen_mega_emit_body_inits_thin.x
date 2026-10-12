// Thin pure: mega emit_one block-inits + return-expr peer (wave499).
// G.7: part of w393_mega_emit_one (peer-flat; nso==0 path).
// tipU: isolated leaf keeps consts/lets/block_inits/get_return/emit_expr.
// PRODUCT: LINUX+MACOS PREFER with emit_one head. PLATFORM: SHARED.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_asm_emit_next_label_c(ctx: *u8, buf: *u8, buf_size: i32): i32;
export extern function ast_ast_block_num_consts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function pipeline_asm_emit_block_inits_elf_c(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32, slot_base: i32): i32;
export extern function backend_enc_label_arch(elf_ctx: *u8, name: *u8, name_len: i32, is_global: i32, ta: i32): i32;
export extern function pipeline_asm_get_return_expr_ref_at(a: *u8, m: *u8, func_index: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * Load i32 from pipe cell (unique name — avoid multi-leaf T clash).
 * @param base *u8 — cell base
 * @return i32
 * PLATFORM: SHARED — wave499 tipU helper.
 */
function w499i_c32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

const W328_CTX_NUM_LOCALS: i32 = 8;
const W328_CTX_TAIL_JOIN_LABEL: i32 = 1392;
const W328_CTX_TAIL_JOIN_LABEL_LEN: i32 = 1520;

/**
 * Block const/let inits + join label + return-expr emit (nso==0 path).
 * @return 0 ok, -1 on emit failure
 * PLATFORM: SHARED — wave499 mega emit_one peer.
 */
#[no_mangle]
export function w499_mega_emit_body_inits(
    m: *u8, a: *u8, elf_ctx: *u8, bctx: *u8, ta: i32, i: i32, body_ref: i32): i32 {
  unsafe {
    let cell: u8[8];
    let neg1: i32 = 0 - 1;
    let lbl_len: i32 = 0;
    let nc: i32 = 0;
    let nl: i32 = 0;
    let slot_base: i32 = 0;
    let result_ref: i32 = 0;
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_next_label_c(bctx, bctx + (W328_CTX_TAIL_JOIN_LABEL as usize), 64));
    lbl_len = w499i_c32(&cell[0]);
    pipe_store_i32_le(bctx, W328_CTX_TAIL_JOIN_LABEL_LEN, lbl_len);
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_consts(a, body_ref));
    nc = w499i_c32(&cell[0]);
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_lets(a, body_ref));
    nl = w499i_c32(&cell[0]);
    slot_base = pipe_load_i32_le(bctx, W328_CTX_NUM_LOCALS) - nc - nl;
    if (slot_base < 0) { return neg1; }
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_block_inits_elf_c(a, elf_ctx, body_ref, bctx, ta, slot_base));
    if (w499i_c32(&cell[0]) != 0) { return neg1; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_label_arch(elf_ctx, bctx + (W328_CTX_TAIL_JOIN_LABEL as usize),
                               pipe_load_i32_le(bctx, W328_CTX_TAIL_JOIN_LABEL_LEN), 0, ta));
    if (w499i_c32(&cell[0]) != 0) { return neg1; }
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_get_return_expr_ref_at(a, m, i));
    result_ref = w499i_c32(&cell[0]);
    if (result_ref != 0) {
      pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_expr_elf_c(a, elf_ctx, result_ref, bctx, ta));
      if (w499i_c32(&cell[0]) != 0) { return neg1; }
    }
    return 0;
  }
}
