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
export extern function lane_f32_neg_depth(arena: *u8, expr_ref: i32, budget: i32): i32;
export extern function lane_f32_neg_core(arena: *u8, expr_ref: i32, n: i32): i32;

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
 * a lane scalar binop (kinds 4..13 or 51), or any chain of EXPR_NEG
 * whose core is a FLOAT_LIT, a VAR, a FIELD, or add/sub/mul/div also
 * returns 1. The chain is one recursive peel. Kind 23 and kinds 8..13
 * under a NEG do not. A chain that does not end within 128 peels does
 * not either. i32 leaves the gate at 0.
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
  // A nested lane binop does not either. The gate is set for an f32
  // dest on add, sub, mul, div, and compare. i32x8 leaves it at 0.
  // A chain of EXPR_NEG is the same f32 lane at every depth up to 8:
  // -(-(-h.v)) / 2.0 was integer div of f64 bits, and the lane was
  // not -2.0. The peel recurses, so another depth is not another arm.
  // Kind 23 and kinds 8..13 stay out. The operand peeler accepts the
  // same shapes.
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
    // One recursive peel, same budget as the operand emitter.
    // Core kind 22 means the chain did not end within 128 peels.
    // PLATFORM: SHARED.
    if (ko == 22) {
      unsafe {
        op = lane_f32_neg_depth(arena, left_ref, 128);
      }
      if (op > 0) {
        unsafe {
          op = lane_f32_neg_core(arena, left_ref, op);
        }
        if (op > 0) {
          unsafe {
            ko = pipeline_expr_kind_ord_at(arena, op);
          }
          if (ko == 1) {
            return 1;
          }
          if (ko == 3) {
            return 1;
          }
          if (ko == 44) {
            return 1;
          }
          // Not kinds 8..13. Kind 23 does not enter. PLATFORM: SHARED.
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
  return is_f32;
}
