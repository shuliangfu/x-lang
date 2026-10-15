// Live body of glue_lane_binop_lhs_is_f32_c.
// The copy in runtime_pipeline_abi.x is an extern. pabi_weak still has
// the old strong definition and is weakened at link. That copy calls
// only glue_vector_elem_is_f32_c. The linked classifier returns 0 for
// f32x8, so a lane subtract emitted integer sub. 3.0 - 1.0 was not 2.0.
// Hardware f32 sub still returns -1 and this scalar check runs, which
// is the path f32x4 already uses. The fill helper is the f32x8 check
// a let already uses. The classifier itself stays 0 for f32x8 so a
// struct-literal field still enters the integer-vector gate.
// PLATFORM: SHARED.

export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_vector_elem_is_f32_c(arena: *u8, type_ref: i32): i32;
export extern function vector_let_init_array_lit_a64_vlet_f32_fill_lane(arena: *u8, type_ref: i32): i32;
export extern function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32;

// 1 while an f32-lane add, sub, mul, or div is being emitted.
// The operand materializer reads this and narrows a FLOAT_LIT to f32
// bits. i32x8 leaves it at 0, so 4.0 / 2.0 there stays on the old path.
// PLATFORM: SHARED.
let g_lane_f32_lit_dest: i32 = 0;

/**
 * Read the f32-literal lane gate.
 * @return i32 — 1 when the current lane binop's dest element is f32
 *   and the opcode is add, sub, mul, or div; 0 otherwise.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_lane_f32_lit_dest_get(): i32 {
  return g_lane_f32_lit_dest;
}

/**
 * Set the f32-literal lane gate.
 * @param v i32 — 1 to narrow FLOAT_LIT lane operands, 0 to leave them.
 * @return i32 — the previous gate, so the caller can restore it.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_lane_f32_lit_dest_set(v: i32): i32 {
  let prev: i32 = 0;
  prev = g_lane_f32_lit_dest;
  g_lane_f32_lit_dest = v;
  return prev;
}

/**
 * True when a vector-lane binop's left operand has f32 lanes.
 * @param arena *u8 — expression arena. Null returns 0.
 * @param ctx *u8 — asm ctx. Used only when the expr has no resolved type.
 *   Null skips the VAR decl fallback.
 * @param left_ref i32 — left expr. Not positive returns 0.
 * @return i32 — 1 when the lane op must be f32, 0 when it stays integer.
 * Vec4f, f32x4, and a TYPE_VECTOR of f32 come from the classifier.
 * f32x8 comes from the fill helper. An integer spelling returns 0.
 * When the f32 literal gate is set and those checks stay 0, a FLOAT_LIT,
 * one or two EXPR_NEG of a FLOAT_LIT, one or two EXPR_NEG of
 * add/sub/mul/div (kinds 4..7), one or two EXPR_NEG of a VAR (kind 3),
 * one or two EXPR_NEG of a FIELD (kind 44), or a lane scalar binop
 * (kinds 4..13 or 51) also returns 1. Kind 23, kinds 8..13 under a
 * NEG, and a third EXPR_NEG do not. i32 leaves the gate at 0.
 * The operand peeler accepts the same shapes.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_lane_binop_lhs_is_f32_c(arena: *u8, ctx: *u8, left_ref: i32): i32 {
  let tr: i32 = 0;
  let ko: i32 = 0;
  let is_f32: i32 = 0;
  let op: i32 = 0;
  if (arena == (0 as *u8) || left_ref <= 0) {
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
  unsafe {
    is_f32 = glue_vector_elem_is_f32_c(arena, tr);
  }
  // Classifier returns 0 for f32x8. Integer sub of those bits is not
  // 3.0 - 1.0. The fill helper returns 1 for that spelling only when
  // the classifier did not. f32x4 and Vec4f already returned 1.
  // PLATFORM: SHARED.
  if (is_f32 == 0) {
    unsafe {
      is_f32 = vector_let_init_array_lit_a64_vlet_f32_fill_lane(arena, tr);
    }
  }
  // A FLOAT_LIT has no vector type, so both checks above stay 0.
  // A nested lane binop does not either: `(4.0 / 2.0) / 2.0` then
  // did integer div of the inner f32 bits, and the lane was not 1.0.
  // The gate is set for an f32 dest on add, sub, mul, div, and compare.
  // i32x8 leaves it at 0. Kind 23 does not enter. Two EXPR_NEG over a
  // FLOAT_LIT is still that literal. One EXPR_NEG over add, sub, mul,
  // or div is still an f32 lane: -(4.0 / 2.0) / 2.0 was integer div
  // and the lane was not -1.0. One EXPR_NEG of a VAR is the same:
  // -a / 2.0 was not -2.0. One EXPR_NEG of a FIELD is the same:
  // -h.v / 2.0 was not -2.0. Two EXPR_NEG of a VAR is still f32:
  // -(-a) / 2.0 was not 2.0. Two EXPR_NEG of a FIELD is the same:
  // -(-h.v) / 2.0 was not 2.0. Two EXPR_NEG of add, sub, mul, or
  // div is the same: -(-(4.0 / 2.0)) / 2.0 was not 1.0. Kinds 8..13
  // under a NEG stay out. The operand peeler accepts
  // the same shapes.
  // PLATFORM: SHARED.
  if (is_f32 == 0 && g_lane_f32_lit_dest != 0) {
    unsafe {
      ko = pipeline_expr_kind_ord_at(arena, left_ref);
    }
    unsafe {
      op = glue_is_vector_lane_scalar_binop_ko(ko);
    }
    if (op != 0) {
      return 1;
    }
    if (ko == 1) {
      return 1;
    }
    if (ko == 22) {
      unsafe {
        op = pipeline_expr_unary_operand_ref_at(arena, left_ref);
      }
      if (op > 0) {
        unsafe {
          ko = pipeline_expr_kind_ord_at(arena, op);
        }
        if (ko == 1) {
          return 1;
        }
        // One NEG of add, sub, mul, or div. Not kinds 8..13.
        // A second NEG is kind 22 and is peeled below. PLATFORM: SHARED.
        if (ko == 4) {
          return 1;
        }
        if (ko == 5) {
          return 1;
        }
        if (ko == 6) {
          return 1;
        }
        if (ko == 7) {
          return 1;
        }
        // One NEG of a VAR. A second NEG is kind 22 and is peeled
        // below. PLATFORM: SHARED.
        if (ko == 3) {
          return 1;
        }
        // One NEG of a FIELD. A second NEG is kind 22 and is peeled
        // below. PLATFORM: SHARED.
        if (ko == 44) {
          return 1;
        }
        // Second EXPR_NEG of a FLOAT_LIT, a VAR, a FIELD, or add,
        // sub, mul, div. Kinds 8..13 stay out. A third NEG stays out.
        // Kind 23 does not enter. PLATFORM: SHARED.
        if (ko == 22) {
          unsafe {
            op = pipeline_expr_unary_operand_ref_at(arena, op);
          }
          if (op > 0) {
            unsafe {
              ko = pipeline_expr_kind_ord_at(arena, op);
            }
            if (ko == 1) {
              return 1;
            }
            // Two NEG of a VAR. The emitter loads that lane and
            // does not xor. PLATFORM: SHARED.
            if (ko == 3) {
              return 1;
            }
            // Two NEG of a FIELD. The emitter loads that lane and
            // does not xor. A binop is not kind 44. PLATFORM: SHARED.
            if (ko == 44) {
              return 1;
            }
            // Two NEG of add, sub, mul, or div. Not kinds 8..13.
            // The emitter runs that lane op and does not xor.
            // PLATFORM: SHARED.
            if (ko == 4) {
              return 1;
            }
            if (ko == 5) {
              return 1;
            }
            if (ko == 6) {
              return 1;
            }
            if (ko == 7) {
              return 1;
            }
          }
        }
      }
    }
  }
  return is_f32;
}
