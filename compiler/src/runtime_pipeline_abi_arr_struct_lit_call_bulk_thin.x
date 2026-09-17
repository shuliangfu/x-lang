// Thin pure: arr_struct_lit CALL bulk copy esz>8 (wave440/442).
// G.7: part of glue_struct_lit_store_fixed_array_field_elf_c authority.
// PRODUCT: MACOS pure-asm / LINUX -E (w442; pure-asm residual).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx: *u8, src_spill: i32, dst_spill: i32, esz: i32, ta: i32): i32;
export extern function pipe_asm_ctx_off_next_offset(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;

/**
 * CALL/INDEX/DEREF path when esz>8: emit to spill then bulk memcpy.
 * Pre: iko in {47,48,49,52} and esz>8.
 * @return i32 — 0 ok; -1 error
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_struct_lit_call_bulk_elf_c(arena: *u8, elf_ctx: *u8, src: i32, ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32): i32 {
  unsafe {
    let ly: *u8 = 0 as *u8;
    let spill_off: i32 = 0;
    let next_off: i32 = 0;
    let src_spill: i32 = 0;
    let dst_spill: i32 = 0;
    let total: i32 = 0;
    let sret_home: i32 = 0;
    let rc: i32 = 0;
    ly = pipeline_asm_ctx_layout(ctx);
    if (ly == (0 as *u8)) {
      return 0 - 1;
    }
    rc = pipe_asm_ctx_off_next_offset();
    next_off = pipe_load_i32_le(ly, rc);
    if (next_off + 16 < next_off) {
      return 0 - 1;
    }
    next_off = next_off + 16;
    rc = pipe_asm_ctx_off_next_offset();
    pipe_store_i32_le(ly, rc, next_off);
    spill_off = next_off;
    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, src, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, spill_off, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    if (esz > 4096) {
      return 0 - 1;
    }
    total = n_arr * esz;
    if (total <= 0 || total > 4096) {
      return 0 - 1;
    }
    rc = pipe_asm_ctx_off_next_offset();
    next_off = pipe_load_i32_le(ly, rc);
    if (next_off + 32 < next_off) {
      return 0 - 1;
    }
    next_off = next_off + 16;
    src_spill = next_off;
    next_off = next_off + 16;
    dst_spill = next_off;
    rc = pipe_asm_ctx_off_next_offset();
    pipe_store_i32_le(ly, rc, next_off);
    rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, spill_off, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    if (sret_direct == 0) {
      rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, field_mag, ta);
      if (rc != 0) {
        return 0 - 1;
      }
    } else {
      sret_home = pipeline_asm_emit_ctx_sret_home_off_get();
      rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, sret_home, ta);
      if (rc != 0) {
        return 0 - 1;
      }
      if (foff != 0) {
        rc = backend_enc_add_imm_to_rax_arch(elf_ctx, foff, ta);
        if (rc != 0) {
          return 0 - 1;
        }
      }
    }
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, total, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
}
