// Live body of glue_emit_vector_lane_scalar_binop_elf_c.
// The copy in runtime_pipeline_abi.x is an extern. pabi_weak still has
// the old strong definition and is weakened at link. That copy shifts
// every lane with the logical encoder. A signed i32 lane of -4 then
// stays a large positive. This file is the one body. Kind 10 calls the
// existing arithmetic encoder only for a signed i32 lane. u32x8 and a
// failed lookup stay on the logical encoder. Do not add a second body.
// PLATFORM: SHARED.

export extern function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32;
export extern function glue_lane_binop_lhs_is_f32_c(arena: *u8, ctx: *u8, left_ref: i32): i32;
export extern function glue_try_vector_lane_binop_operands_elf_c(
  arena: *u8, elf_ctx: *u8, binop_ko: i32, left_ref: i32, right_ref: i32,
  lane: i32, esz: i32, ctx: *u8, ta: i32
): i32;
export extern function glue_apply_vector_lane_f32_binop_elf_c(elf_ctx: *u8, binop_ko: i32, ta: i32): i32;
export extern function glue_apply_vector_lane_scalar_binop_elf_c(elf_ctx: *u8, binop_ko: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_vector_operand_lane_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32
): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_add_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_sub_rbx_rax_then_mov_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_imul_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rbx_to_ecx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx: *u8, ctx: *u8, ta: i32): i32;
export extern function backend_enc_idiv_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_rem_mod_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_shl_cl_eax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_shr_cl_eax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_sar_cl_eax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_and_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_or_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_xor_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_binop_operand_is_unsigned_elf_c(arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ty_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, ty_ref: i32, out: *u8): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;

/**
 * 1 when a lane right shift of this left operand is arithmetic.
 * @param arena *u8 — expression arena. Null returns 0 (logical).
 * @param ctx *u8 — asm ctx. Used only when a VAR has no resolved type.
 *   Null skips that fallback.
 * @param left_ref i32 — left expr. Not positive returns 0.
 * @param right_ref i32 — right expr. Forwarded to the scalar unsigned helper.
 * @return i32 — 1 arithmetic, 0 logical.
 * The scalar helper returns 1 for u8, u32, u64, and usize. Those stay
 * logical. A named SIMD type is not one of those kinds, so u32x8 would
 * look signed if this stopped there. Exact names i32x4, i32x8, and
 * i32x16 are arithmetic. Vec8i is the same. A kind-13 vector whose
 * element is i32 is arithmetic. Anything else, including a failed
 * lookup, stays logical. PLATFORM: SHARED.
 */
function lane_shr_is_arith(arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32): i32 {
  let un: i32 = 0;
  let tr: i32 = 0;
  let tk: i32 = 0;
  let ko: i32 = 0;
  let nlen: i32 = 0;
  let er: i32 = 0;
  let etk: i32 = 0;
  let name: u8[256] = [];
  if (arena == (0 as *u8)) {
    return 0;
  }
  if (left_ref <= 0) {
    return 0;
  }
  unsafe {
    un = glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, right_ref);
  }
  if (un != 0) {
    return 0;
  }
  unsafe {
    tr = pipeline_expr_resolved_type_ref(arena, left_ref);
  }
  if (tr <= 0) {
    if (ctx != (0 as *u8)) {
      unsafe {
        ko = pipeline_expr_kind_ord_at(arena, left_ref);
      }
      if (ko == 3) {
        unsafe {
          tr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
        }
      }
    }
  }
  if (tr <= 0) {
    return 0;
  }
  unsafe {
    tk = pipeline_type_kind_ord_at(arena, tr);
  }
  if (tk == 13) {
    unsafe {
      er = pipeline_type_elem_ref_at(arena, tr);
    }
    if (er <= 0) {
      return 0;
    }
    unsafe {
      etk = pipeline_type_kind_ord_at(arena, er);
    }
    if (etk == 0) {
      return 1;
    }
    return 0;
  }
  if (tk != 8) {
    return 0;
  }
  unsafe {
    nlen = pipeline_type_named_name_into(arena, tr, &name[0]);
  }
  if (nlen == 5) {
    if (name[0] == 105) {
      if (name[1] == 51) {
        if (name[2] == 50) {
          if (name[3] == 120) {
            if (name[4] == 52) {
              return 1;
            }
            if (name[4] == 56) {
              return 1;
            }
          }
        }
      }
    }
    if (name[0] == 86) {
      if (name[1] == 101) {
        if (name[2] == 99) {
          if (name[3] == 56) {
            if (name[4] == 105) {
              return 1;
            }
          }
        }
      }
    }
  }
  if (nlen == 6) {
    if (name[0] == 105) {
      if (name[1] == 51) {
        if (name[2] == 50) {
          if (name[3] == 120) {
            if (name[4] == 49) {
              if (name[5] == 54) {
                return 1;
              }
            }
          }
        }
      }
    }
  }
  return 0;
}

/**
 * Emit one vector lane scalar binop; result in rax.
 * @param arena *u8 — expression arena. A null arena fails in the operand try.
 * @param elf_ctx *u8 — emit buffer. A null buffer fails in the operand try.
 * @param binop_ko i32 — lane scalar kind. Outside 4..13 and 51 returns -1.
 * @param left_ref i32 — left expr.
 * @param right_ref i32 — right expr.
 * @param lane i32 — lane index.
 * @param esz i32 — lane size in bytes.
 * @param ctx *u8 — asm ctx.
 * @param ta i32 — 1 arm64, else x86. Forwarded to the encoders.
 * @return i32 — 0 when rax holds the lane, -1 when an encode fails.
 * Kind 10 is a right shift. Signed i32 lanes use the existing arithmetic
 * encoder. Unsigned lanes, and a type this helper does not know, keep
 * the logical encoder. The fast path does not call apply for kind 10:
 * apply has no type and always shifts logically. Add, sub, mul, div,
 * mod, and the bitwise ops are unchanged. PLATFORM: SHARED.
 */

#[no_mangle]
export function glue_emit_vector_lane_scalar_binop_elf_c(arena: *u8, elf_ctx: *u8, binop_ko: i32, left_ref: i32, right_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32): i32 {
  let vr: i32 = 0;
  let rc: i32 = 0;
  let is_shr: i32 = 0;
  let is_f32: i32 = 0;
  let arith: i32 = 0;
  let shift_ko: i32 = 0;
  unsafe {
    rc = glue_is_vector_lane_scalar_binop_ko(binop_ko);
  }
  if (rc == 0) {
    return 0 - 1;
  }
  unsafe {
    is_f32 = glue_lane_binop_lhs_is_f32_c(arena, ctx, left_ref);
  }
  unsafe {
    vr = glue_try_vector_lane_binop_operands_elf_c(arena, elf_ctx, binop_ko, left_ref, right_ref, lane, esz, ctx, ta);
  }
  if (vr == 0) {
    // G.7: Vec4f/f32x4 lanes are IEEE f32 bits; integer ADD/IDIV of those
    // bits is not f32 arith (mac a+b was run=1; a/b is run=1). Reuse
    // scalar addss/subss/mulss/divss. IEEE Inf/NaN on /0 — do not trip
    // the integer divisor-zero check (0.0f has integer bits 0).
    if (is_f32 != 0) {
      if (binop_ko == 4) {
        unsafe {
          return glue_apply_vector_lane_f32_binop_elf_c(elf_ctx, binop_ko, ta);
        }
      }
      if (binop_ko == 5) {
        unsafe {
          return glue_apply_vector_lane_f32_binop_elf_c(elf_ctx, binop_ko, ta);
        }
      }
      if (binop_ko == 6) {
        unsafe {
          return glue_apply_vector_lane_f32_binop_elf_c(elf_ctx, binop_ko, ta);
        }
      }
      if (binop_ko == 7) {
        unsafe {
          return glue_apply_vector_lane_f32_binop_elf_c(elf_ctx, binop_ko, ta);
        }
      }
    }
    // Kind 10 count is already in rbx. apply would shift it logically.
    // Decide from the left type, then use the same ecx move. PLATFORM: SHARED.
    if (binop_ko == 10) {
      arith = lane_shr_is_arith(arena, ctx, left_ref, right_ref);
      unsafe {
        rc = backend_enc_mov_rbx_to_ecx_arch(elf_ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      if (arith != 0) {
        unsafe {
          return backend_enc_sar_cl_eax_arch(elf_ctx, ta);
        }
      }
      unsafe {
        return backend_enc_shr_cl_eax_arch(elf_ctx, ta);
      }
    }
    unsafe {
      return glue_apply_vector_lane_scalar_binop_elf_c(elf_ctx, binop_ko, ctx, ta);
    }
  }
  if (vr == 0 - 1) {
    return 0 - 1;
  }
  unsafe {
    rc = glue_emit_vector_operand_lane_elf_c(arena, elf_ctx, left_ref, lane, esz, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_push_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = glue_emit_vector_operand_lane_elf_c(arena, elf_ctx, right_ref, lane, esz, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  if (binop_ko == 4) {
    unsafe {
      rc = backend_enc_pop_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    if (is_f32 != 0) {
      unsafe {
        return glue_apply_vector_lane_f32_binop_elf_c(elf_ctx, 4, ta);
      }
    }
    unsafe {
      return backend_enc_add_rax_rbx_arch(elf_ctx, ta);
    }
  }
  if (binop_ko == 5) {
    unsafe {
      rc = backend_enc_pop_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    if (is_f32 != 0) {
      unsafe {
        return glue_apply_vector_lane_f32_binop_elf_c(elf_ctx, 5, ta);
      }
    }
    unsafe {
      return backend_enc_sub_rbx_rax_then_mov_arch(elf_ctx, ta);
    }
  }
  if (binop_ko == 6) {
    unsafe {
      rc = backend_enc_pop_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    if (is_f32 != 0) {
      unsafe {
        return glue_apply_vector_lane_f32_binop_elf_c(elf_ctx, 6, ta);
      }
    }
    unsafe {
      return backend_enc_imul_rbx_rax_arch(elf_ctx, ta);
    }
  }
  if (binop_ko == 7) {
    unsafe {
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    // PLATFORM: SHARED — f32 /0 is IEEE Inf/NaN; skip integer #DE guard.
    if (is_f32 == 0) {
      unsafe {
        rc = pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
    }
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    if (is_f32 != 0) {
      unsafe {
        return glue_apply_vector_lane_f32_binop_elf_c(elf_ctx, 7, ta);
      }
    }
    unsafe {
      return backend_enc_idiv_rbx_arch(elf_ctx, ta);
    }
  }
  if (binop_ko == 8) {
    unsafe {
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      return backend_enc_rem_mod_arch(elf_ctx, ta);
    }
  }
  is_shr = 0;
  shift_ko = 0;
  if (binop_ko == 9) {
    shift_ko = 1;
  }
  if (binop_ko == 10) {
    shift_ko = 1;
    is_shr = 1;
  }
  if (shift_ko != 0) {
    unsafe {
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_mov_rbx_to_ecx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    if (is_shr != 0) {
      arith = lane_shr_is_arith(arena, ctx, left_ref, right_ref);
      if (arith != 0) {
        unsafe {
          return backend_enc_sar_cl_eax_arch(elf_ctx, ta);
        }
      }
      unsafe {
        return backend_enc_shr_cl_eax_arch(elf_ctx, ta);
      }
    }
    unsafe {
      return backend_enc_shl_cl_eax_arch(elf_ctx, ta);
    }
  }
  if (binop_ko == 11) {
    unsafe {
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      return backend_enc_and_rbx_rax_arch(elf_ctx, ta);
    }
  }
  if (binop_ko == 12) {
    unsafe {
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      return backend_enc_or_rbx_rax_arch(elf_ctx, ta);
    }
  }
  if (binop_ko == 13) {
    unsafe {
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      return backend_enc_xor_rbx_rax_arch(elf_ctx, ta);
    }
  }
  return 0 - 1;
}
