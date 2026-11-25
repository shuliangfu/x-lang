// knife256/10.2 Cap tip linked body of typeck_check_expr_float_lit.
// Source authority is the already-resolved keep in typeck.x.
// Cap tip -c of that mega emits a hollow mov w0,#0; ret, so this thin
// is what the link runs. The demoted body always stamps f64 after
// writing the f64 bits. An assign pre-stamp of a bare FLOAT_LIT onto
// a TYPE_VECTOR of f32 must survive, the same way an INT_LIT stamp
// survives typeck_check_expr_int_lit. The bits are still written
// before the keep, so the emitter can read lo@684 / hi@688.
// An unresolved lit still calls the demoted body, which stamps f64.
// PLATFORM: SHARED — type rule is the same on macOS, Ubuntu, and Windows.
// The demote/retarget step that makes this symbol win is Mach-O only.

export extern "C" function typeck_check_expr_float_lit__demoted(
  arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_typeck_set_float_bits_from_val(
  arena: *u8, expr_ref: i32): void;
export extern "C" function pipeline_expr_resolved_type_ref(
  arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_arena_num_types(arena: *u8): i32;

/**
 * Keep an already-resolved FLOAT_LIT, else call the demoted body.
 * @param arena *u8 — AST arena; null defers to the demoted body
 * @param expr_ref i32 — FLOAT_LIT expr; <= 0 defers to the demoted body
 * @return i32 — 0 when the type is already in range, else the demoted result
 * The demoted body copies f64 bits from expr+24 into lo@684 / hi@688
 * and then stamps TYPE_F64. A bare lit starts unresolved, so that
 * stamp still happens and let-coerce can restamp f32 or a vector
 * afterwards. An assign that already stamped a TYPE_VECTOR of f32
 * must not be overwritten. The bits are written on the keep path too:
 * returning before the demoted body would otherwise leave lo/hi at 0
 * and the lane fill would store zeros. A resolved type outside
 * 1..num_types is not a keep.
 * Two compares, not a chained && : the bootstrap image clobbers the
 * register a chained compare reuses.
 * PLATFORM: SHARED — same type rule on every host.
 */
#[no_mangle]
export function typeck_check_expr_float_lit(arena: *u8, expr_ref: i32): i32 {
  unsafe {
    let already: i32 = 0;
    let ntypes: i32 = 0;
    if (arena == 0 as *u8) {
      return typeck_check_expr_float_lit__demoted(arena, expr_ref);
    }
    if (expr_ref <= 0) {
      return typeck_check_expr_float_lit__demoted(arena, expr_ref);
    }
    pipeline_expr_typeck_set_float_bits_from_val(arena, expr_ref);
    already = pipeline_expr_resolved_type_ref(arena, expr_ref);
    ntypes = pipeline_arena_num_types(arena);
    if (already > 0) {
      if (already <= ntypes) {
        return 0;
      }
    }
    return typeck_check_expr_float_lit__demoted(arena, expr_ref);
  }
}
