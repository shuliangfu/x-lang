// Thin pure: wave351/378/387 Cap A — mega emit_index twin with gate removed.
// No modlet shortcut (w350 over-eager VAR+lit modlet broke Ubuntu option).
// G.7 ≡ mega pipeline_asm_emit_index_elf_c post-w350.
// wave378: BAN Ubuntu PREFER (option=240); Darwin PREFER stays.
// wave387: HARD BAN reinject both ends (stamp .pabi_w387_emit_index.stamp);
//   stay prior Darwin PREFER / Ubuntu -E until option=240 root.
// PLATFORM: SHARED.

export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;
export extern function glue_index_assign_addr_cache_hit(arena: *u8, ctx: *u8, base_ref: i32, idx_ref: i32, esz: i32): i32;
export extern function glue_index_load_from_cached_assign_addr_elf_c(elf_ctx: *u8, esz: i32, ta: i32): i32;
export extern function pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_index_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;

/**
 * Emit EXPR_INDEX rvalue — mega twin, no VAR/modlet early gate.
 * @return i32 - 0 ok; -1 fail
 * PLATFORM: SHARED Cap A wave351.
 */
#[no_mangle]
export function pipeline_asm_emit_index_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  let base_ref: i32 = 0;
  let idx_ref: i32 = 0;
  let esz: i32 = 0;
  let res_ty: i32 = 0;
  let rc: i32 = 0;
  let hit: i32 = 0;
  let rtk: i32 = 0;
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
    rc = glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, expr_ref, base_ref, idx_ref, ctx, ta, esz);
  }
  if (rc != 0) {
    return 0 - 1;
  }
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
