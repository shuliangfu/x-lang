// Thin pure: wave350 Cap A module fixed-array INDEX rvalue.
// G.7: for VAR+lit bases, cold modlet_load FIRST (≡ emit_expr_elf_fast VAR),
// then scale + element load. Historic mega VAR gate used product
// modlet_find (empty vs cold prepare) → bare g[0] CG002. After inject,
// re-inject asm_expr_thin so emit_expr_elf_rec binds to this face (not
// *_pabi_superseded). PLATFORM: SHARED freestanding · LINUX · MACOS|ARM64.

export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;
export extern function glue_index_assign_addr_cache_hit(arena: *u8, ctx: *u8, base_ref: i32, idx_ref: i32, esz: i32): i32;
export extern function glue_index_load_from_cached_assign_addr_elf_c(elf_ctx: *u8, esz: i32, ta: i32): i32;
export extern function pipeline_asm_cmp_expr_lit_i32_at(arena: *u8, expr_ref: i32, out_imm: *i32): i32;
export extern function pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_index_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_modlet_load_to_rax_elf_c(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out64: *u8): void;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;

/**
 * Load INDEX element from address already in rax.
 * @return i32 - 0 ok; -1 fail
 * PLATFORM: SHARED.
 */
function w350_index_load_from_addr_rax(elf_ctx: *u8, arena: *u8, expr_ref: i32, esz: i32, ta: i32): i32 {
  let res_ty: i32 = 0;
  let rtk: i32 = 0;
  unsafe {
    res_ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
  }
  if (res_ty > 0) {
    unsafe {
      rtk = pipeline_type_kind_ord_at(arena, res_ty);
    }
    if (rtk == 10) {
      return 0;
    }
    if (rtk == 11) {
      unsafe {
        return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
      }
    }
  }
  if (esz > 8 && esz <= 16) {
    unsafe {
      return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
    }
  }
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8) {
    return 0;
  }
  if (esz == 1) {
    unsafe {
      return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
    }
  }
  if (esz == 4) {
    unsafe {
      return backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
    }
  }
  unsafe {
    return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
  }
}

/**
 * Emit EXPR_INDEX rvalue. Module fixed-array: cold modlet LEA + lit scale.
 * @return i32 - 0 ok; -1 fail
 * PLATFORM: SHARED Cap A wave350.
 */
#[no_mangle]
export function pipeline_asm_emit_index_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  let base_ref: i32 = 0;
  let idx_ref: i32 = 0;
  let esz: i32 = 0;
  let rc: i32 = 0;
  let hit: i32 = 0;
  let base_kind: i32 = 0;
  let vlen: i32 = 0;
  let lit_imm: i32 = 0;
  let lit_slot: i32[1] = [];
  let is_lit: i32 = 0;
  let byte_off: i32 = 0;
  let vname: u8[256] = [];
  unsafe {
    base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
    idx_ref = pipeline_expr_index_index_ref(arena, expr_ref);
  }
  if (base_ref <= 0 || idx_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    esz = pipeline_asm_index_elem_byte_sz_c(arena, expr_ref);
    hit = glue_index_assign_addr_cache_hit(arena, ctx, base_ref, idx_ref, esz);
  }
  if (hit != 0) {
    unsafe {
      return glue_index_load_from_cached_assign_addr_elf_c(elf_ctx, esz, ta);
    }
  }
  unsafe {
    glue_index_assign_addr_cache_clear();
    base_kind = pipeline_expr_kind_ord_at(arena, base_ref);
  }
  if (base_kind == 3) {
    unsafe {
      is_lit = pipeline_asm_cmp_expr_lit_i32_at(arena, idx_ref, &lit_slot[0]);
      vlen = pipeline_expr_var_name_len(arena, base_ref);
    }
    if (is_lit != 0 && vlen > 0 && vlen <= 255) {
      unsafe {
        pipeline_expr_var_name_into(arena, base_ref, &vname[0]);
        rc = pipeline_asm_modlet_load_to_rax_elf_c(elf_ctx, &vname[0], vlen, ta);
      }
      if (rc == 0) {
        lit_imm = lit_slot[0];
        byte_off = lit_imm * esz;
        if (byte_off != 0) {
          unsafe {
            if (backend_enc_add_imm_to_rax_arch(elf_ctx, byte_off, ta) != 0) {
              return 0 - 1;
            }
          }
        }
        return w350_index_load_from_addr_rax(elf_ctx, arena, expr_ref, esz, ta);
      }
    }
  }
  unsafe {
    rc = glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, expr_ref, base_ref, idx_ref, ctx, ta, esz);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return w350_index_load_from_addr_rax(elf_ctx, arena, expr_ref, esz, ta);
}
