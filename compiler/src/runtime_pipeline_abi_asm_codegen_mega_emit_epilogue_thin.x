// Thin pure: mega emit_one float/void-main/epilogue peer (wave499).
// G.7: part of w393_mega_emit_one (peer-flat).
// tipU: same-file micro-peers for mov xmm/imm (gated ifs starve tip mid).
// PRODUCT: LINUX+MACOS PREFER with emit_one head. PLATFORM: SHARED.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_module_func_return_type_at(m: *u8, fi: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function pipeline_module_main_func_index(m: *u8): i32;
export extern function backend_enc_mov_imm32_to_w0_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function backend_enc_epilogue_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_async_cps_end_func_elf_c(): void;

/**
 * Load i32 from pipe cell (unique name — avoid multi-leaf T clash).
 * @param base *u8 — cell base
 * @return i32
 * PLATFORM: SHARED — wave499 tipU helper.
 */
function w499e_c32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

const W328_GLUE_TYPE_KIND_F32_ORD: i32 = 14;
const W328_GLUE_TYPE_KIND_F64_ORD: i32 = 15;
const W328_TYPE_KIND_VOID_ORD: i32 = 16;

/**
 * Place f32 return in xmm0 (x86_64 SysV).
 * @return 0 ok, nonzero on emit failure
 * PLATFORM: SHARED — wave499 micro-peer under epilogue.
 */
#[no_mangle]
export function w499_mega_emit_f32_ret(elf_ctx: *u8, ta: i32): i32 {
  unsafe {
    let cell: u8[8];
    pipe_store_i32_le(&cell[0], 0, backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx, 0, ta));
    return w499e_c32(&cell[0]);
  }
}

/**
 * Place f64 return in xmm0 (x86_64 SysV).
 * @return 0 ok, nonzero on emit failure
 * PLATFORM: SHARED — wave499 micro-peer under epilogue.
 */
#[no_mangle]
export function w499_mega_emit_f64_ret(elf_ctx: *u8, ta: i32): i32 {
  unsafe {
    let cell: u8[8];
    pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx, 0, ta));
    return w499e_c32(&cell[0]);
  }
}

/**
 * Zig-like void main: process entry must exit 0 on fall-off.
 * @return 0 ok, nonzero on emit failure
 * PLATFORM: SHARED — wave499 micro-peer under epilogue.
 */
#[no_mangle]
export function w499_mega_emit_void_main(elf_ctx: *u8, ta: i32): i32 {
  unsafe {
    let cell: u8[8];
    pipe_store_i32_le(&cell[0], 0, backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta));
    return w499e_c32(&cell[0]);
  }
}

/**
 * Scalar float return + void main → 0 + epilogue + cps end.
 * @return 0 ok, -1 on emit failure
 * PLATFORM: SHARED — wave499 mega emit_one peer.
 *   LINUX+MACOS x86_64 SysV float return; Zig-like void main exit 0.
 */
#[no_mangle]
export function w499_mega_emit_epilogue(
    m: *u8, a: *u8, elf_ctx: *u8, ta: i32, i: i32): i32 {
  unsafe {
    let cell: u8[8];
    let neg1: i32 = 0 - 1;
    let rty: i32 = 0;
    let rkind: i32 = 0;
    let main_fi: i32 = 0;
    pipe_store_i32_le(&cell[0], 0, pipeline_module_func_return_type_at(m, i));
    rty = w499e_c32(&cell[0]);
    /* Always call type_kind (tip drops if(rty>0) gated mid-call). */
    pipe_store_i32_le(&cell[0], 0, pipeline_type_kind_ord_at(a, rty));
    rkind = w499e_c32(&cell[0]);
    if (rty <= 0) { rkind = neg1; }
    if (ta == 0 && rkind == W328_GLUE_TYPE_KIND_F32_ORD) {
      pipe_store_i32_le(&cell[0], 0, w499_mega_emit_f32_ret(elf_ctx, ta));
      if (w499e_c32(&cell[0]) != 0) { return neg1; }
    }
    if (ta == 0 && rkind == W328_GLUE_TYPE_KIND_F64_ORD) {
      pipe_store_i32_le(&cell[0], 0, w499_mega_emit_f64_ret(elf_ctx, ta));
      if (w499e_c32(&cell[0]) != 0) { return neg1; }
    }
    pipe_store_i32_le(&cell[0], 0, pipeline_module_main_func_index(m));
    main_fi = w499e_c32(&cell[0]);
    if (rkind == W328_TYPE_KIND_VOID_ORD && i == main_fi) {
      pipe_store_i32_le(&cell[0], 0, w499_mega_emit_void_main(elf_ctx, ta));
      if (w499e_c32(&cell[0]) != 0) { return neg1; }
    }
    pipe_store_i32_le(&cell[0], 0, backend_enc_epilogue_arch(elf_ctx, ta));
    if (w499e_c32(&cell[0]) != 0) { return neg1; }
    pipeline_asm_emit_async_cps_end_func_elf_c();
    return 0;
  }
}
