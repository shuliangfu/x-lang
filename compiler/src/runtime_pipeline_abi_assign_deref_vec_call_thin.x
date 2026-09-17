// Thin pure: DEREF vec_call leaf (wave441 peer).
// G.7: match mega / assign_deref dispatcher peer arm.
// wave449: LINUX PREFER tip pure-asm (product si green).
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

/**
 * DEREF SIMD dest from CALL/METHOD: park dest, vector let-init or dual-GP store.
 * Preconditions: dest already in rbx.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_vec_call_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, rko_pre: i32, nbytes: i32, ltr: i32): i32 {
  unsafe {
    let src_spill: i32 = 0;
    let temp_home: i32 = 0;
    let rc: i32 = 0;
    let arr_st: i32 = 0;
    if (nbytes < 8) {
      return 0 - 3;
    }
    if (rko_pre != 48) {
      if (rko_pre != 49) {
        return 0 - 3;
      }
    }
    asg_thin_align_next_offset(ctx);
    src_spill = asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset());
    if (ta == 1) {
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), src_spill + 8);
    } else {
      src_spill = src_spill + 8;
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), src_spill);
    }
    rc = backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    asg_thin_align_next_offset(ctx);
    temp_home = asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset());
    if (ta == 1) {
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), temp_home + nbytes);
    } else {
      temp_home = temp_home + nbytes;
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), temp_home);
    }
    arr_st = glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, temp_home, ltr);
    if (arr_st == 0 - 1) {
      return 0 - 1;
    }
    if (arr_st == 0) {
      rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, src_spill, ta);
      if (rc != 0) {
        return 0 - 1;
      }
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
      if (rc != 0) {
        return 0 - 1;
      }
      rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_home, ta);
      if (rc != 0) {
        return 0 - 1;
      }
      rc = glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, nbytes, ta);
      if (rc != 0) {
        return 0 - 1;
      }
      return 0;
    }
    // -2: restore dest and emit CALL dual-GP store
    rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, src_spill, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    if (ta == 1) {
      rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, 0, 16, ta);
    } else {
      rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, 0, 8, ta);
      if (rc == 0) {
        rc = glue_x86_store_rdx_to_rbx8_elf_c(elf_ctx);
      }
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
}
