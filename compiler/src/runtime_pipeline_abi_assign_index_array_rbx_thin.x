// Thin pure: INDEX TYPE_ARRAY runtime dest-in-rbx (wave441).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, arr_ty: i32, depth: i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, arr_ty: i32, stack_off: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;

/**
 * Runtime/non-VAR INDEX TYPE_ARRAY assign via INDEX-lea dest-in-rbx.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_array_rbx_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32, ltr: i32): i32 {
  unsafe {
    let ltk: i32 = 0;
    let nbytes: i32 = 0;
    let rc: i32 = 0;
    let arr_st: i32 = 0;
    ltk = pipeline_type_kind_ord_at(arena, ltr);
    if (ltk != 10) {
      return 0 - 3;
    }
    nbytes = glue_fixed_array_total_bytes_c(arena, ltr, 0);
    if (nbytes < 8) {
      nbytes = esz;
    }
    if (nbytes <= 0) {
      return 0 - 3;
    }
    rc = glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, nbytes);
    if (rc != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    if (rc != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    arr_st = glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3);
    if (arr_st == 0) {
      glue_index_assign_addr_cache_clear();
      return 0;
    }
    if (arr_st == 0 - 1) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    return 0 - 3;
  }
}
