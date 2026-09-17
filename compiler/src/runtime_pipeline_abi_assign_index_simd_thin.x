// Thin pure: INDEX SIMD dest peer (wave441).
// G.7: part of pipeline_asm_emit_assign_elf_c INDEX path.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_index_setup_elf_c(arena: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, out_esz: *i32, out_base: *i32, out_idx: *i32, out_rko: *i32, out_ako: *i32, out_bk: *i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern function glue_vector_type_lanes_esz_c(arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32): i32;
export extern function pipeline_asm_cmp_expr_lit_i32_at(arena: *u8, expr_ref: i32, out: *i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_emit_vector_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_off: i32, type_ref: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;

/**
 * INDEX SIMD/vector dest via lit VAR frame elem_home.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_simd_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
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
    let arr_st: i32 = 0;
    let n_arr: i32 = 0;
    let store_sz: i32 = 0;
    let nbytes: i32 = 0;
    let cmp_lit: i32 = 0;
    let lit_slot: i32[1] = [];
    let lit_imm: i32 = 0;
    let base_off: i32 = 0;
    let elem_home: i32 = 0;
    let rc: i32 = 0;
    rc = glue_emit_assign_index_setup_elf_c(arena, expr_ref, left_ref, right_ref, &esz_s[0], &base_s[0], &idx_s[0], &rko_s[0], &ako_s[0], &bk_s[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    if (ta != 0) {
      if (ta != 1) {
        return 0 - 3;
      }
    }
    if (bk_s[0] != 3) {
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
    arr_st = glue_vector_type_lanes_esz_c(arena, ltr, &n_arr, &store_sz);
    if (arr_st != 0) {
      return 0 - 3;
    }
    if (n_arr <= 0) {
      return 0 - 3;
    }
    if (store_sz <= 0) {
      return 0 - 3;
    }
    nbytes = n_arr * store_sz;
    cmp_lit = pipeline_asm_cmp_expr_lit_i32_at(arena, idx_s[0], &lit_slot[0]);
    if (cmp_lit == 0) {
      return 0 - 3;
    }
    lit_imm = lit_slot[0];
    base_off = glue_var_expr_stack_off_elf_c(arena, ctx, base_s[0]);
    if (base_off < 0) {
      return 0 - 3;
    }
    if (nbytes <= 0) {
      return 0 - 3;
    }
    if (ta == 1) {
      elem_home = base_off + lit_imm * nbytes;
    } else {
      elem_home = base_off - lit_imm * nbytes;
    }
    if (elem_home < 0) {
      return 0 - 3;
    }
    arr_st = glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, elem_home, ltr);
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
