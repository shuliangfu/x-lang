// Thin pure: DEREF array_call leaf (wave441 peer).
// G.7: match mega / assign_deref dispatcher peer arm.
// wave449: LINUX PREFER tip pure-asm (product si green).
// wave535 Soft Cap: tipU heal — pipe-cell mid `mod/nbytes/spill/rc=call()`
//   (ptr via pipe_store_ptr_slot; i32 via pipe_store + if pipe_load);
//   stamp w535 HARD BAN tip PRODUCT reinject (keep prior PREFER; stamp-only).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, arr_ty: i32, depth: i32): i32;
export extern function asg_thin_align_next_offset(ctx: *u8): void;
export extern function asg_thin_load_i32_le(base: *u8, off: i32): i32;
export extern function asg_thin_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function asg_thin_ctx_off_next_offset(): i32;
export extern function glue_arm64_mov_x19_to_x0_elf_c(elf_ctx: *u8): i32;
export extern function backend_enc_mov_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx: *u8, dest_off: i32, nbytes: i32, ta: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;

/**
 * DEREF TYPE_ARRAY CALL: park dest, spill payload ptr, memcpy dest-in-rbx.
 * Soft Cap tipU: extern call as arg to pipe_store; branch on pipe_load.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_array_call_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, ltk: i32, rko_pre: i32, ltr: i32): i32 {
  let pcell: u8[8] = [];
  let ncell: u8[4] = [];
  let dcell: u8[4] = [];
  let scell: u8[4] = [];
  let rcell: u8[4] = [];
  if (ltk != 10) {
    return 0 - 3;
  }
  if (rko_pre != 48) {
    if (rko_pre != 49) {
      return 0 - 3;
    }
  }
  unsafe {
    pipe_store_ptr_slot(&pcell[0], 0, glue_emit_module_from_ctx(ctx));
    pipe_store_i32_le(&ncell[0], 0, glue_type_size_simple(pipe_load_ptr_slot(&pcell[0], 0), arena, ltr, 0));
    if (pipe_load_i32_le(&ncell[0], 0) < 8) {
      pipe_store_i32_le(&ncell[0], 0, glue_fixed_array_total_bytes_c(arena, ltr, 0));
    }
    if (pipe_load_i32_le(&ncell[0], 0) < 8) {
      return 0 - 3;
    }
    asg_thin_align_next_offset(ctx);
    pipe_store_i32_le(&dcell[0], 0, asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset()));
    if (ta == 1) {
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), pipe_load_i32_le(&dcell[0], 0) + 8);
    } else {
      pipe_store_i32_le(&dcell[0], 0, pipe_load_i32_le(&dcell[0], 0) + 8);
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), pipe_load_i32_le(&dcell[0], 0));
    }
    if (ta == 1) {
      pipe_store_i32_le(&rcell[0], 0, glue_arm64_mov_x19_to_x0_elf_c(elf_ctx));
    } else {
      pipe_store_i32_le(&rcell[0], 0, backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta));
    }
    if (pipe_load_i32_le(&rcell[0], 0) != 0) {
      return 0 - 1;
    }
    pipe_store_i32_le(&rcell[0], 0, backend_enc_store_rax_to_rbp_arch(elf_ctx, pipe_load_i32_le(&dcell[0], 0), ta));
    if (pipe_load_i32_le(&rcell[0], 0) != 0) {
      return 0 - 1;
    }
    pipe_store_i32_le(&rcell[0], 0, pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta));
    if (pipe_load_i32_le(&rcell[0], 0) != 0) {
      return 0 - 1;
    }
    asg_thin_align_next_offset(ctx);
    pipe_store_i32_le(&scell[0], 0, asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset()));
    if (ta == 1) {
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), pipe_load_i32_le(&scell[0], 0) + 8);
    } else {
      pipe_store_i32_le(&scell[0], 0, pipe_load_i32_le(&scell[0], 0) + 8);
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), pipe_load_i32_le(&scell[0], 0));
    }
    pipe_store_i32_le(&rcell[0], 0, backend_enc_store_rax_to_rbp_arch(elf_ctx, pipe_load_i32_le(&scell[0], 0), ta));
    if (pipe_load_i32_le(&rcell[0], 0) != 0) {
      return 0 - 1;
    }
    pipe_store_i32_le(&rcell[0], 0, backend_enc_load_rbp_to_rax_arch(elf_ctx, pipe_load_i32_le(&dcell[0], 0), ta));
    if (pipe_load_i32_le(&rcell[0], 0) != 0) {
      return 0 - 1;
    }
    pipe_store_i32_le(&rcell[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
    if (pipe_load_i32_le(&rcell[0], 0) != 0) {
      return 0 - 1;
    }
    pipe_store_i32_le(&rcell[0], 0, backend_enc_load_rbp_to_rax_arch(elf_ctx, pipe_load_i32_le(&scell[0], 0), ta));
    if (pipe_load_i32_le(&rcell[0], 0) != 0) {
      return 0 - 1;
    }
    pipe_store_i32_le(&rcell[0], 0, glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, pipe_load_i32_le(&ncell[0], 0), ta));
    if (pipe_load_i32_le(&rcell[0], 0) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}
