// 10.53: module-level f64 let → modlet COMMON/data (lo+hi). Replaces
// stale modlet_float_imm.o (f32-only) so Cap tip first-wins this face.
// Callers pass out_imm as i32[2]: [0]=lo [1]=hi.
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, eref: i32): i32;
export extern "C" function pipeline_expr_int_val_at(arena: *u8, eref: i32): i32;
export extern "C" function pipeline_expr_as_operand_ref_at(arena: *u8, eref: i32): i32;
export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, eref: i32): i32;
export extern "C" function pipeline_expr_float_bits_lo_at(arena: *u8, eref: i32): i32;
export extern "C" function pipeline_expr_float_bits_hi_at(arena: *u8, eref: i32): i32;
export extern "C" function glue_ieee_f64_bits_to_f32_bits(lo: i32, hi: i32): i32;
export extern function pipe_modlet_array_lit_elem_const_val(
  arena: *u8, eref: i32, out_lo: *i32, out_hi: *i32
): i32;
export extern function pipe_modlet_fold_f64_elem_bits(
  arena: *u8, eref: i32, out_lo: *i32, out_hi: *i32
): i32;

function w1511_mf_f32_bits_thin(arena: *u8, eref: i32, out_bits: *i32): i32 {
  let ek: i32 = 0;
  let op: i32 = 0;
  let lo: i32 = 0;
  let hi: i32 = 0;
  let neg: i32 = 0;
  let bits: i32 = 0;
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, eref);
  }
  op = eref;
  if (ek == 22) {
    unsafe {
      op = pipeline_expr_unary_operand_ref_at(arena, eref);
    }
    if (op <= 0) {
      return 0;
    }
    unsafe {
      ek = pipeline_expr_kind_ord_at(arena, op);
    }
    neg = 1;
  }
  if (ek != 1) {
    return 0;
  }
  unsafe {
    lo = pipeline_expr_float_bits_lo_at(arena, op);
    hi = pipeline_expr_float_bits_hi_at(arena, op);
  }
  if (neg != 0) {
    hi = hi ^ (0 - 2147483647 - 1);
  }
  unsafe {
    bits = glue_ieee_f64_bits_to_f32_bits(lo, hi);
    out_bits[0] = bits;
  }
  return 1;
}

#[no_mangle]
export function pipe_modlet_scalar_init_common_imm(
  arena: *u8, init_ref: i32, tk: i32, is_const: i32, out_imm: *i32
): i32 {
  let ik: i32 = 0;
  let fold_buf: i32[2] = [];
  let op: i32 = 0;
  let oek: i32 = 0;
  let v: i32 = 0;
  if (is_const != 0 || arena == (0 as *u8) || init_ref <= 0 || out_imm == (0 as *i32)) {
    return 0;
  }
  fold_buf[0] = 0;
  fold_buf[1] = 0;
  unsafe {
    ik = pipeline_expr_kind_ord_at(arena, init_ref);
  }
  if (tk == 14) {
    let fb: i32 = 0;
    fb = w1511_mf_f32_bits_thin(arena, init_ref, &fold_buf[0]);
    if (fb == 1) {
      unsafe {
        out_imm[0] = fold_buf[0];
        out_imm[1] = 0;
      }
      return 1;
    }
    return 0;
  }
  if (tk == 15) {
    let flo: i32 = 0;
    let fhi: i32 = 0;
    let fb64: i32 = 0;
    unsafe {
      fb64 = pipe_modlet_fold_f64_elem_bits(arena, init_ref, &flo, &fhi);
    }
    if (fb64 == 0) {
      return 0;
    }
    unsafe {
      out_imm[0] = flo;
      out_imm[1] = fhi;
    }
    return 1;
  }
  if (ik == 2) {
    unsafe {
      v = pipeline_expr_int_val_at(arena, init_ref);
      out_imm[0] = v;
      out_imm[1] = 0;
    }
    return 1;
  }
  let cv: i32 = 0;
  unsafe {
    cv = pipe_modlet_array_lit_elem_const_val(arena, init_ref, &fold_buf[0], (0 as *i32));
  }
  if (cv == 1) {
    unsafe {
      out_imm[0] = fold_buf[0];
      out_imm[1] = 0;
    }
    return 1;
  }
  if (tk == 9) {
    if (ik == 0) {
      unsafe {
        v = pipeline_expr_int_val_at(arena, init_ref);
      }
      if (v == 0) {
        unsafe {
          out_imm[0] = 0;
          out_imm[1] = 0;
        }
        return 1;
      }
    } else {
      if (ik == 54) {
        unsafe {
          op = pipeline_expr_as_operand_ref_at(arena, init_ref);
        }
        if (op > 0) {
          unsafe {
            oek = pipeline_expr_kind_ord_at(arena, op);
          }
          if (oek == 0) {
            unsafe {
              v = pipeline_expr_int_val_at(arena, op);
            }
            if (v == 0) {
              unsafe {
                out_imm[0] = 0;
                out_imm[1] = 0;
              }
              return 1;
            }
          }
        }
      }
    }
  }
  return 0;
}
