// Thin pure: DEREF vec_call leaf (wave441 peer).
// G.7: match mega / assign_deref dispatcher peer arm.
// wave449: LINUX PREFER tip pure-asm (product si green).
// wave536 Soft Cap: tipU heal — pipe-cell mid `spill/rc/arr_st=call()`;
//   stamp w536 HARD BAN tip PRODUCT reinject (keep prior PREFER; stamp-only).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function asg_thin_align_next_offset(ctx: *u8): void;
export extern function asg_thin_load_i32_le(base: *u8, off: i32): i32;
export extern function asg_thin_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function asg_thin_ctx_off_next_offset(): i32;
export extern function backend_enc_mov_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function glue_emit_vector_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_off: i32, type_ref: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx: *u8, dest_off: i32, nbytes: i32, ta: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;
export extern function glue_x86_store_rdx_to_rbx8_elf_c(elf_ctx: *u8): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * Finish vec_call after vector let-init.
 * Soft Cap: unique lea/copy stay behind `if (st==0)` on a parameter
 * (Ubuntu tip drops them behind `if (pipe_load==0)`).
 * @param st i32 — arr_st from glue_emit_vector_type_let_init (0 ok, -1 err, else dual-GP)
 * @return i32 — 0 ok; -1 err
 * PLATFORM: SHARED Soft Cap (wave536).
 */
function w536_finish_vec_call(elf_ctx: *u8, st: i32, src_spill: i32, temp_home: i32, nbytes: i32, ta: i32, arena: *u8, right_ref: i32, ctx: *u8): i32 {
  if (st == (0 - 1)) { return 0 - 1; }
  if (st == 0) {
    unsafe {
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, src_spill, ta) != 0) { return 0 - 1; }
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) { return 0 - 1; }
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_home, ta) != 0) { return 0 - 1; }
      if (glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, nbytes, ta) != 0) { return 0 - 1; }
    }
    return 0;
  }
  /* st==-2: restore dest and emit CALL dual-GP store. */
  unsafe {
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, src_spill, ta) != 0) { return 0 - 1; }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) { return 0 - 1; }
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0) { return 0 - 1; }
    if (ta == 1) {
      if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, 0, 16, ta) != 0) { return 0 - 1; }
    } else {
      if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, 0, 8, ta) != 0) { return 0 - 1; }
      if (glue_x86_store_rdx_to_rbx8_elf_c(elf_ctx) != 0) { return 0 - 1; }
    }
  }
  return 0;
}

/**
 * DEREF SIMD dest from CALL/METHOD: park dest, vector let-init or dual-GP store.
 * Soft Cap tipU: extern call as arg to pipe_store; branch on pipe_load.
 * Preconditions: dest already in rbx.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_vec_call_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, rko_pre: i32, nbytes: i32, ltr: i32): i32 {
  let scell: u8[4] = [];
  let tcell: u8[4] = [];
  let rcell: u8[4] = [];
  let acell: u8[4] = [];
  if (nbytes < 8) {
    return 0 - 3;
  }
  if (rko_pre != 48) {
    if (rko_pre != 49) {
      return 0 - 3;
    }
  }
  unsafe {
    asg_thin_align_next_offset(ctx);
    pipe_store_i32_le(&scell[0], 0, asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset()));
    if (ta == 1) {
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), pipe_load_i32_le(&scell[0], 0) + 8);
    } else {
      pipe_store_i32_le(&scell[0], 0, pipe_load_i32_le(&scell[0], 0) + 8);
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), pipe_load_i32_le(&scell[0], 0));
    }
    pipe_store_i32_le(&rcell[0], 0, backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta));
    if (pipe_load_i32_le(&rcell[0], 0) != 0) { return 0 - 1; }
    pipe_store_i32_le(&rcell[0], 0, backend_enc_store_rax_to_rbp_arch(elf_ctx, pipe_load_i32_le(&scell[0], 0), ta));
    if (pipe_load_i32_le(&rcell[0], 0) != 0) { return 0 - 1; }
    asg_thin_align_next_offset(ctx);
    pipe_store_i32_le(&tcell[0], 0, asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset()));
    if (ta == 1) {
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), pipe_load_i32_le(&tcell[0], 0) + nbytes);
    } else {
      pipe_store_i32_le(&tcell[0], 0, pipe_load_i32_le(&tcell[0], 0) + nbytes);
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), pipe_load_i32_le(&tcell[0], 0));
    }
    pipe_store_i32_le(&acell[0], 0, glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, pipe_load_i32_le(&tcell[0], 0), ltr));
  }
  unsafe {
    return w536_finish_vec_call(elf_ctx, pipe_load_i32_le(&acell[0], 0), pipe_load_i32_le(&scell[0], 0), pipe_load_i32_le(&tcell[0], 0), nbytes, ta, arena, right_ref, ctx);
  }
}
