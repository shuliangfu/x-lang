// Thin pure: wave351/378/387/516 Cap A — mega emit_index twin with gate removed.
// No modlet shortcut (w350 over-eager VAR+lit modlet broke Ubuntu option).
// G.7 ≡ mega pipeline_asm_emit_index_elf_c post-w350.
// wave378: BAN Ubuntu PREFER (option=240); Darwin PREFER stays.
// wave387: HARD BAN reinject both ends (stamp .pabi_w387_emit_index.stamp);
//   stay prior Darwin PREFER / Ubuntu -E until option=240 root.
// wave516: tipU 6/13→15/15 — mid `base=/idx=/esz=/hit=/rc=/res_ty=/rtk=call()`
//   drop U; pipe-cell heal; stamp → w516; tip PRODUCT reinject still HARD BAN.
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
/** wave516: pipe-cell helpers (keep tip U across mid-call assign). */
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Emit EXPR_INDEX rvalue — mega twin, no VAR/modlet early gate.
 * wave516: ban mid `x=call()`; dedicated pipe-cells inside one unsafe.
 * @return i32 - 0 ok; -1 fail
 * PLATFORM: SHARED Cap A wave351/516.
 */
#[no_mangle]
export function pipeline_asm_emit_index_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  let bcell: u8[4] = [];
  let icell: u8[4] = [];
  let ecell: u8[4] = [];
  let hcell: u8[4] = [];
  let rccell: u8[4] = [];
  let rtycell: u8[4] = [];
  let rtkcell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&bcell[0], 0, pipeline_expr_index_base_ref(arena, expr_ref));
    pipe_store_i32_le(&icell[0], 0, pipeline_expr_index_index_ref(arena, expr_ref));
    if (pipe_load_i32_le(&bcell[0], 0) <= 0 || pipe_load_i32_le(&icell[0], 0) <= 0) {
      return 0 - 1;
    }
    pipe_store_i32_le(&ecell[0], 0, pipeline_asm_index_elem_byte_sz_c(arena, expr_ref));
    pipe_store_i32_le(&hcell[0], 0, glue_index_assign_addr_cache_hit(
      arena, ctx,
      pipe_load_i32_le(&bcell[0], 0),
      pipe_load_i32_le(&icell[0], 0),
      pipe_load_i32_le(&ecell[0], 0)
    ));
    if (pipe_load_i32_le(&hcell[0], 0) != 0) {
      return glue_index_load_from_cached_assign_addr_elf_c(
        elf_ctx, pipe_load_i32_le(&ecell[0], 0), ta
      );
    }
    glue_index_assign_addr_cache_clear();
    pipe_store_i32_le(&rccell[0], 0, glue_emit_index_eff_addr_scaled_elf_c(
      arena, elf_ctx, expr_ref,
      pipe_load_i32_le(&bcell[0], 0),
      pipe_load_i32_le(&icell[0], 0),
      ctx, ta,
      pipe_load_i32_le(&ecell[0], 0)
    ));
    if (pipe_load_i32_le(&rccell[0], 0) != 0) {
      return 0 - 1;
    }
    pipe_store_i32_le(&rtycell[0], 0, pipeline_expr_resolved_type_ref(arena, expr_ref));
    if (pipe_load_i32_le(&rtycell[0], 0) > 0) {
      pipe_store_i32_le(&rtkcell[0], 0, pipeline_type_kind_ord_at(
        arena, pipe_load_i32_le(&rtycell[0], 0)
      ));
      if (pipe_load_i32_le(&rtkcell[0], 0) == 10) {
        return 0;
      }
      if (pipe_load_i32_le(&rtkcell[0], 0) == 11) {
        return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
      }
    }
    if (pipe_load_i32_le(&ecell[0], 0) > 8 && pipe_load_i32_le(&ecell[0], 0) <= 16) {
      return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
    }
    if (pipe_load_i32_le(&ecell[0], 0) != 1
      && pipe_load_i32_le(&ecell[0], 0) != 2
      && pipe_load_i32_le(&ecell[0], 0) != 4
      && pipe_load_i32_le(&ecell[0], 0) != 8) {
      return 0;
    }
    if (pipe_load_i32_le(&ecell[0], 0) == 1) {
      return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
    }
    if (pipe_load_i32_le(&ecell[0], 0) == 4) {
      return backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
    }
    return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
  }
}
