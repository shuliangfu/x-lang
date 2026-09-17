// Thin pure: arr_struct_lit zero-fill arm (wave440).
// G.7: part of glue_struct_lit_store_fixed_array_field_elf_c authority.
// PRODUCT: LINUX PREFER peer chain for arr_struct_lit.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function pipeline_expr_int64_val_at(arena: *u8, expr_ref: i32): i64;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;

/**
 * Zero-fill fixed-array field (INT 0 or empty ARRAY_LIT).
 * @param empty_array_zero i32 — non-0 skips INT0 check
 * @return i32 — 0 handled; -1 error; -2 unsupported non-zero lit
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_struct_lit_zero_field_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32, empty_array_zero: i32): i32 {
  unsafe {
    let lit_v: i64 = 0;
    let ai: i32 = 0;
    let sret_home: i32 = 0;
    let rc: i32 = 0;
    if (empty_array_zero == 0) {
      lit_v = pipeline_expr_int64_val_at(arena, init_ref);
      if (lit_v != (0 as i64)) {
        return 0 - 2;
      }
    }
    if (n_arr > 1024) {
      return 0;
    }
    if (sret_direct == 0) {
      rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, field_mag, ta);
      if (rc != 0) {
        return 0 - 1;
      }
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
      if (rc != 0) {
        return 0 - 1;
      }
      rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, 0, 0, ta);
      if (rc != 0) {
        return 0 - 1;
      }
      ai = 0;
      while (ai < n_arr) {
        rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, ai * esz, esz, ta);
        if (rc != 0) {
          return 0 - 1;
        }
        ai = ai + 1;
      }
      return 0;
    }
    sret_home = pipeline_asm_emit_ctx_sret_home_off_get();
    rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, 0, 0, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    ai = 0;
    while (ai < n_arr) {
      rc = backend_enc_push_rax_arch(elf_ctx, ta);
      if (rc != 0) {
        return 0 - 1;
      }
      rc = backend_enc_load_rbp_to_rbx_arch(elf_ctx, sret_home, ta);
      if (rc != 0) {
        return 0 - 1;
      }
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
      if (rc != 0) {
        return 0 - 1;
      }
      rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff + ai * esz, esz, ta);
      if (rc != 0) {
        return 0 - 1;
      }
      ai = ai + 1;
    }
    return 0;
  }
}
