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
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_vector_elem_is_f32_c(arena: *u8, type_ref: i32): i32;
export extern function vector_let_init_array_lit_a64_vlet_f32_fill_lane(arena: *u8, type_ref: i32): i32;

/**
 * True when a vector-lane binop's left operand has f32 lanes.
 * @param arena *u8 — expression arena. Null returns 0.
 * @param ctx *u8 — asm ctx. Used only when the expr has no resolved type.
 *   Null skips the VAR decl fallback.
 * @param left_ref i32 — left expr. Not positive returns 0.
 * @return i32 — 1 when the lane op must be f32, 0 when it stays integer.
 * Vec4f, f32x4, and a TYPE_VECTOR of f32 come from the classifier.
 * f32x8 comes from the fill helper. An integer spelling returns 0.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_lane_binop_lhs_is_f32_c(arena: *u8, ctx: *u8, left_ref: i32): i32 {
  let tr: i32 = 0;
  let ko: i32 = 0;
  let is_f32: i32 = 0;
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
  return is_f32;
}
