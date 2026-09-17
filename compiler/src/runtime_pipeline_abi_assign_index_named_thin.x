// Thin pure: INDEX TYPE_NAMED esz>8 peer (wave441).
// G.7: part of pipeline_asm_emit_assign_elf_c INDEX path.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_index_setup_elf_c(arena: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, out_esz: *i32, out_base: *i32, out_idx: *i32, out_rko: *i32, out_ako: *i32, out_bk: *i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;

/**
 * INDEX TYPE_NAMED dest via dest-in-rbx struct let-init (esz>8).
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_named_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let esz_s: i32[1] = [];
    let base_s: i32[1] = [];
    let idx_s: i32[1] = [];
    let rko_s: i32[1] = [];
    let ako_s: i32[1] = [];
    let bk_s: i32[1] = [];
    let ltr: i32 = 0;
    let ltr_pre: i32 = 0;
    let ltk_pre: i32 = 0;
    let ltk: i32 = 0;
    let rc: i32 = 0;
    let arr_st: i32 = 0;
    rc = glue_emit_assign_index_setup_elf_c(arena, expr_ref, left_ref, right_ref, &esz_s[0], &base_s[0], &idx_s[0], &rko_s[0], &ako_s[0], &bk_s[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    if (ta != 0) {
      if (ta != 1) {
        return 0 - 3;
      }
    }
    if (esz_s[0] <= 8) {
      return 0 - 3;
    }
    ltr = pipeline_expr_resolved_type_ref(arena, left_ref);
    if (ltr <= 0) {
      ltr_pre = pipeline_expr_resolved_type_ref(arena, base_s[0]);
      if (ltr_pre <= 0) {
        return 0 - 3;
      }
      ltk_pre = pipeline_type_kind_ord_at(arena, ltr_pre);
      if (ltk_pre != 10) {
        if (ltk_pre != 11) {
          if (ltk_pre != 9) {
            return 0 - 3;
          }
        }
      }
      ltr = pipeline_type_elem_ref_at(arena, ltr_pre);
    }
    if (ltr <= 0) {
      return 0 - 3;
    }
    ltk = pipeline_type_kind_ord_at(arena, ltr);
    if (ltk != 8) {
      return 0 - 3;
    }
    rc = glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_s[0], idx_s[0], ctx, ta, esz_s[0]);
    if (rc != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    if (rc != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    arr_st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3);
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
