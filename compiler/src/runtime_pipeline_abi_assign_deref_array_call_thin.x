// Thin pure: DEREF TYPE_ARRAY CALL park+copy (wave441).
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

/**
 * DEREF TYPE_ARRAY CALL: park dest, spill payload ptr, memcpy dest-in-rbx.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_array_call_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, ltk: i32, rko_pre: i32, ltr: i32): i32 {
  unsafe {
    let mod: *u8 = 0 as *u8;
    let nbytes: i32 = 0;
    let dst_spill: i32 = 0;
    let src_spill: i32 = 0;
    let rc: i32 = 0;
    if (ltk != 10) {
      return 0 - 3;
    }
    if (rko_pre != 48) {
      if (rko_pre != 49) {
        return 0 - 3;
      }
    }
    mod = glue_emit_module_from_ctx(ctx);
    nbytes = glue_type_size_simple(mod, arena, ltr, 0);
    if (nbytes < 8) {
      nbytes = glue_fixed_array_total_bytes_c(arena, ltr, 0);
    }
    if (nbytes < 8) {
      return 0 - 3;
    }
    asg_thin_align_next_offset(ctx);
    dst_spill = asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset());
    if (ta == 1) {
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), dst_spill + 8);
    } else {
      dst_spill = dst_spill + 8;
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), dst_spill);
    }
    if (ta == 1) {
      rc = glue_arm64_mov_x19_to_x0_elf_c(elf_ctx);
    } else {
      rc = backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    asg_thin_align_next_offset(ctx);
    src_spill = asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset());
    if (ta == 1) {
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), src_spill + 8);
    } else {
      src_spill = src_spill + 8;
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), src_spill);
    }
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, dst_spill, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, src_spill, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, nbytes, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
}
