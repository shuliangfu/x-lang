// Thin pure: arr_struct_lit one CALL elem store (wave440).
// G.7: part of glue_struct_lit_store_fixed_array_field_elf_c authority.
// PRODUCT: LINUX PREFER peer chain for arr_struct_lit.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;

/**
 * One element: load from spill+ai*esz into field dest.
 * @return i32 — 0 ok; -1 error
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_struct_lit_call_one_elem_elf_c(elf_ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, esz: i32, spill_off: i32, ai: i32, sret_home: i32): i32 {
  unsafe {
    let rc: i32 = 0;
    let store_off: i32 = 0;
    rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, spill_off, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    if (ai * esz != 0) {
      rc = backend_enc_add_imm_to_rax_arch(elf_ctx, ai * esz, ta);
      if (rc != 0) {
        return 0 - 1;
      }
    }
    if (esz == 1) {
      rc = backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
      if (rc != 0) {
        return 0 - 1;
      }
    } else {
      if (esz == 8) {
        rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
        if (rc != 0) {
          return 0 - 1;
        }
      } else {
        rc = backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
        if (rc != 0) {
          return 0 - 1;
        }
      }
    }
    rc = backend_enc_push_rax_arch(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
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
      store_off = ai * esz;
    } else {
      rc = backend_enc_load_rbp_to_rbx_arch(elf_ctx, sret_home, ta);
      if (rc != 0) {
        return 0 - 1;
      }
      store_off = foff + ai * esz;
    }
    rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, store_off, esz, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
}
