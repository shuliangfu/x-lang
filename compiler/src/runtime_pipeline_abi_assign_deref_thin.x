// Thin pure: DEREF arm dispatcher (wave441).
// G.7: body MUST match pipeline_asm_emit_assign_elf_c DEREF path (peer-flat).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_vector_type_lanes_esz_c(arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32): i32;
export extern function glue_emit_assign_deref_vec_var_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, rko_pre: i32, nbytes: i32): i32;
export extern function glue_emit_assign_deref_vec_call_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, rko_pre: i32, nbytes: i32, ltr: i32): i32;
export extern function glue_emit_assign_deref_slice_call_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, ltk: i32, rko_pre: i32, ltr: i32): i32;
export extern function glue_emit_assign_deref_array_call_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, ltk: i32, rko_pre: i32, ltr: i32): i32;
export extern function glue_emit_assign_deref_let_init_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, ltk: i32, ltr: i32): i32;
export extern function glue_emit_assign_deref_scalar_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * DEREF lvalue assign arm — flat peer dispatch.
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let ltr: i32 = 0;
    let ltk: i32 = 0;
    let base_ref: i32 = 0;
    let ltr_pre: i32 = 0;
    let ltk_pre: i32 = 0;
    let rc: i32 = 0;
    let rko_pre: i32 = 0;
    let arr_st: i32 = 0;
    let n_arr: i32 = 0;
    let esz: i32 = 0;
    let nbytes: i32 = 0;
    if (ta != 0) {
      if (ta != 1) {
        return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
      }
    }
    ltr = pipeline_expr_resolved_type_ref(arena, left_ref);
    ltk = 0;
    if (ltr > 0) {
      ltk = pipeline_type_kind_ord_at(arena, ltr);
    }
    if (ltk != 8) {
      base_ref = pipeline_expr_unary_operand_ref_at(arena, left_ref);
      if (base_ref > 0) {
        ltr_pre = pipeline_expr_resolved_type_ref(arena, base_ref);
        if (ltr_pre <= 0) {
          ltr_pre = glue_var_decl_type_ref_elf_c(arena, ctx, base_ref);
        }
        if (ltr_pre > 0) {
          ltk_pre = pipeline_type_kind_ord_at(arena, ltr_pre);
          if (ltk_pre == 9) {
            ltr = pipeline_type_elem_ref_at(arena, ltr_pre);
            if (ltr > 0) {
              ltk = pipeline_type_kind_ord_at(arena, ltr);
            }
          }
        }
      }
    }
    if (ltr <= 0) {
      return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (ltk != 8) {
      if (ltk != 11) {
        if (ltk != 13) {
          if (ltk != 10) {
            return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
          }
        }
      }
    }
    rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rko_pre = pipeline_expr_kind_ord_at(arena, right_ref);
    arr_st = glue_vector_type_lanes_esz_c(arena, ltr, &n_arr, &esz);
    if (arr_st == 0) {
      if (n_arr > 0) {
        if (esz > 0) {
          nbytes = n_arr * esz;
          rc = glue_emit_assign_deref_vec_var_elf_c(arena, elf_ctx, right_ref, ctx, ta, rko_pre, nbytes);
          if (rc != 0 - 3) {
            return rc;
          }
          rc = glue_emit_assign_deref_vec_call_elf_c(arena, elf_ctx, right_ref, ctx, ta, rko_pre, nbytes, ltr);
          if (rc != 0 - 3) {
            return rc;
          }
        }
      }
    }
    rc = glue_emit_assign_deref_slice_call_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltk, rko_pre, ltr);
    if (rc != 0 - 3) {
      return rc;
    }
    rc = glue_emit_assign_deref_array_call_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltk, rko_pre, ltr);
    if (rc != 0 - 3) {
      return rc;
    }
    rc = glue_emit_assign_deref_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltk, ltr);
    if (rc != 0 - 3) {
      return rc;
    }
    return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
  }
}
