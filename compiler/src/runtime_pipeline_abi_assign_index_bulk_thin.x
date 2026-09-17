// Thin pure: INDEX esz>8 bulk copy peer (wave441).
// G.7: part of pipeline_asm_emit_assign_elf_c INDEX path.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_index_setup_elf_c(arena: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, out_esz: *i32, out_base: *i32, out_idx: *i32, out_rko: *i32, out_ako: *i32, out_bk: *i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function asg_thin_load_i32_le(base: *u8, off: i32): i32;
export extern function asg_thin_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function asg_thin_ctx_off_next_offset(): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx: *u8, src_spill: i32, dst_spill: i32, nbytes: i32, ta: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;

/**
 * INDEX esz>8 bulk spill copy for VAR/FIELD/INDEX/CALL/METHOD rhs.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_bulk_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let esz_s: i32[1] = [];
    let base_s: i32[1] = [];
    let idx_s: i32[1] = [];
    let rko_s: i32[1] = [];
    let ako_s: i32[1] = [];
    let bk_s: i32[1] = [];
    let rko_bulk: i32 = 0;
    let next_off: i32 = 0;
    let src_spill: i32 = 0;
    let dst_spill: i32 = 0;
    let temp_home: i32 = 0;
    let nbytes: i32 = 0;
    let rc: i32 = 0;
    let is_lval: i32 = 0;
    rc = glue_emit_assign_index_setup_elf_c(arena, expr_ref, left_ref, right_ref, &esz_s[0], &base_s[0], &idx_s[0], &rko_s[0], &ako_s[0], &bk_s[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    if (esz_s[0] <= 8) {
      return 0 - 3;
    }
    rko_bulk = pipeline_expr_kind_ord_at(arena, right_ref);
    is_lval = 0;
    if (rko_bulk == 3) {
      is_lval = 1;
    }
    if (rko_bulk == 44) {
      is_lval = 1;
    }
    if (rko_bulk == 47) {
      is_lval = 1;
    }
    if (rko_bulk == 48) {
      is_lval = 2;
    }
    if (rko_bulk == 49) {
      is_lval = 2;
    }
    if (is_lval == 0) {
      return 0 - 3;
    }
    next_off = asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset());
    if (next_off + 32 < next_off) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    next_off = next_off + 16;
    src_spill = next_off;
    next_off = next_off + 16;
    dst_spill = next_off;
    asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), next_off);
    temp_home = 0 - 1;
    if (is_lval == 1) {
      rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
      if (rc != 0) {
        glue_index_assign_addr_cache_clear();
        return 0 - 1;
      }
      rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
      if (rc != 0) {
        glue_index_assign_addr_cache_clear();
        return 0 - 1;
      }
    } else {
      nbytes = (esz_s[0] + 7) & (0 - 8);
      next_off = asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset());
      if (next_off + nbytes < next_off) {
        glue_index_assign_addr_cache_clear();
        return 0 - 1;
      }
      next_off = next_off + nbytes;
      temp_home = next_off;
      asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), next_off);
      rc = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0, temp_home);
      if (rc != 0) {
        glue_index_assign_addr_cache_clear();
        return 0 - 1;
      }
      rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_home, ta);
      if (rc != 0) {
        glue_index_assign_addr_cache_clear();
        return 0 - 1;
      }
      rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
      if (rc != 0) {
        glue_index_assign_addr_cache_clear();
        return 0 - 1;
      }
    }
    rc = glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_s[0], idx_s[0], ctx, ta, esz_s[0]);
    if (rc != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta);
    if (rc != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    rc = glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, esz_s[0], ta);
    if (rc != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    glue_index_assign_addr_cache_clear();
    return 0;
  }
}
