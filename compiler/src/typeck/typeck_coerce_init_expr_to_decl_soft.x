// knife256/10.2 Cap tip linked body of typeck_coerce_init_expr_to_decl.
// Source authority is the i32 TYPE_VECTOR splat in typeck.x. Cap tip -c
// of that mega emits a hollow mov w0,#0; ret, so this thin is what the
// link runs. An INT_LIT, or unary minus / bitwise not of an INT_LIT,
// into a TYPE_VECTOR of i32 is stamped with the declared type. Every
// other init calls the demoted body.
// PLATFORM: SHARED — type rule is the same on macOS, Ubuntu, and Windows.
// The demote/retarget step that makes this symbol win is Mach-O only.

export extern "C" function typeck_coerce_init_expr_to_decl__demoted(
  module: *u8, arena: *u8, init_ref: i32, decl_ty_ref: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_arena_num_types(arena: *u8): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_is_null_keyword_c(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_set_resolved_type_ref(arena: *u8, expr_ref: i32, ty: i32): void;

/**
 * Stamp an i32 scalar splat onto a TYPE_VECTOR, else call demoted.
 * @param module *u8 — caller module; passed through, may be null
 * @param arena *u8 — AST arena; null defers to the demoted body
 * @param init_ref i32 — initializer expr; <= 0 defers
 * @param decl_ty_ref i32 — declared type; <= 0 defers
 * @return i32 — 1 when the vector splat is stamped, demoted result otherwise
 * Vec8i is kind 13 of i32. Named i32x8 is kind 8 and already passes the
 * soft equality, so `let v: i32x8 = ~1` typechecks. Kind 13 does not, so
 * `let v: Vec8i = ~1` was "expected ?, found i32". The vector let-init
 * already splats INT_LIT and unary -/~ of INT_LIT. A variable, a binop,
 * keyword null, and a float vector stay on the demoted body.
 * Two compares, not a chained && : the bootstrap image clobbers the
 * register a chained compare reuses. An out-of-range expr ref is not
 * counted here: pipeline_expr_kind_ord_at already returns -1, which is
 * not INT_LIT, so the splat stays off and the demoted body rejects it.
 * PLATFORM: SHARED — same type rule on every host.
 */
#[no_mangle]
export function typeck_coerce_init_expr_to_decl(
  module: *u8, arena: *u8, init_ref: i32, decl_ty_ref: i32): i32 {
  unsafe {
    let ord_lit: i32 = 0;
    let ord_neg: i32 = 22;
    let ord_bitnot: i32 = 23;
    let ord_vector: i32 = 13;
    let ord_i32: i32 = 0;
    let decl_kind: i32 = 0;
    let init_kind: i32 = 0;
    let splat_ok: i32 = 0;
    let elem_ref: i32 = 0;
    let elem_k: i32 = 0;
    let op_ref: i32 = 0;
    let op_k: i32 = 0;
    let ntypes: i32 = 0;
    if (arena == 0 as *u8 || init_ref <= 0 || decl_ty_ref <= 0) {
      return typeck_coerce_init_expr_to_decl__demoted(
        module, arena, init_ref, decl_ty_ref);
    }
    ntypes = pipeline_arena_num_types(arena);
    if (decl_ty_ref > ntypes) {
      return typeck_coerce_init_expr_to_decl__demoted(
        module, arena, init_ref, decl_ty_ref);
    }
    decl_kind = pipeline_type_kind_ord_at(arena, decl_ty_ref);
    init_kind = pipeline_expr_kind_ord_at(arena, init_ref);
    /*
     * Only a real TYPE_VECTOR of i32. Out-of-range element refs stay
     * on the demoted body. PLATFORM: SHARED.
     */
    if (decl_kind == ord_vector) {
      elem_ref = pipeline_type_elem_ref_at(arena, decl_ty_ref);
      if (elem_ref > 0) {
        if (elem_ref <= ntypes) {
          elem_k = pipeline_type_kind_ord_at(arena, elem_ref);
          if (elem_k == ord_i32) {
            if (init_kind == ord_lit) {
              if (pipeline_expr_is_null_keyword_c(arena, init_ref) == 0) {
                splat_ok = 1;
              }
            }
            if (init_kind == ord_neg) {
              op_ref = pipeline_expr_unary_operand_ref_at(arena, init_ref);
            }
            if (init_kind == ord_bitnot) {
              op_ref = pipeline_expr_unary_operand_ref_at(arena, init_ref);
            }
            if (op_ref > 0) {
              op_k = pipeline_expr_kind_ord_at(arena, op_ref);
              if (op_k == ord_lit) {
                if (pipeline_expr_is_null_keyword_c(arena, op_ref) == 0) {
                  splat_ok = 1;
                }
              }
            }
          }
        }
      }
    }
    if (splat_ok == 1) {
      pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
      return 1;
    }
    return typeck_coerce_init_expr_to_decl__demoted(
      module, arena, init_ref, decl_ty_ref);
  }
}
