// Thin pure override: module-let scalar COMMON/.data gate with f32 inits.
// w1511 (终局待办 10.40): pabi's pipe_modlet_scalar_init_common_imm only
// accepted BOOL, integer constants and a null pointer. A module
// `let g: f32 = 1.5` then got no modlet cell: the hoist put it into main's
// frame and every other function summed its own stack slot for it, so a
// store in one function was never seen by another (main re-read its own
// slot). Floats travel in rax as IEEE bits in this backend, so an f32
// FLOAT_LIT (or NEG over one) registers the 32-bit pattern as the cell
// imm; prepare bakes a non-zero pattern into .data and load/store go
// through the same 8-byte cell as an integer let. The hoist gate calls
// this same symbol, so hoist skip and prepare register stay in agreement.
// src/runtime_pipeline_abi.x and modlet_thin.x may not be rebuilt (mega
// ban), so this file redefines the exported symbol; merge it back into
// pabi.x under 10.26.
// PLATFORM: SHARED freestanding · ELF .data · Mach-O __DATA · PE .data.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_float_bits_lo_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_float_bits_hi_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function glue_ieee_f64_bits_to_f32_bits(lo: i32, hi: i32): i32;
export extern function pipe_modlet_array_lit_elem_const_val(arena: *u8, eref: i32, out_v: *i32, out_hi: *i32): i32;

/**
 * f32 bit pattern of a FLOAT_LIT or NEG over a FLOAT_LIT.
 * @param arena *u8 - ASTArena
 * @param eref i32 - init expr
 * @param out_bits *i32 - IEEE single pattern
 * @return i32 - 1 when written; 0 when not a float literal form
 * PLATFORM: SHARED - little-endian host float.
 */
function w1511_mf_f32_bits(arena: *u8, eref: i32, out_bits: *i32): i32 {
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

/**
 * True when a mutable scalar module-let init is prepare-COMMON-owned.
 * Same contract as pabi (BOOL, folded integer constant, null TYPE_PTR)
 * plus w1511: TYPE_F32 (14) FLOAT_LIT / NEG over FLOAT_LIT as its IEEE
 * single pattern.
 * @param arena *u8 - ASTArena
 * @param init_ref i32 - top-level let init expr
 * @param tk i32 - type kind ord (9 = TYPE_PTR, 14 = TYPE_F32)
 * @param is_const i32 - 1 = const let (prepare skips; hoist keeps)
 * @param out_imm *i32 - folded init bits
 * @return i32 - 1 register 8-byte cell; 0 keep other arms / hoist
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 · WINDOWS.
 */
export function pipe_modlet_scalar_init_common_imm(
  arena: *u8, init_ref: i32, tk: i32, is_const: i32, out_imm: *i32
): i32 {
  let ik: i32 = 0;
  let fold_buf: i32[1] = [];
  let op: i32 = 0;
  let oek: i32 = 0;
  let v: i32 = 0;
  if (is_const != 0 || arena == (0 as *u8) || init_ref <= 0 || out_imm == (0 as *i32)) {
    return 0;
  }
  fold_buf[0] = 0;
  unsafe {
    ik = pipeline_expr_kind_ord_at(arena, init_ref);
  }
  if (tk == 14) {
    let fb: i32 = 0;
    unsafe {
      fb = w1511_mf_f32_bits(arena, init_ref, &fold_buf[0]);
    }
    if (fb == 1) {
      unsafe {
        out_imm[0] = fold_buf[0];
      }
      return 1;
    }
    return 0;
  }
  if (ik == 2) {
    unsafe {
      v = pipeline_expr_int_val_at(arena, init_ref);
      out_imm[0] = v;
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
