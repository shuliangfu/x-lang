// knife256/10.2 Cap tip linked body of typeck_check_expr_unary.
// Source authority is the NEG exemption in typeck.x. Cap tip -c of that
// mega emits a hollow mov w0,#0; ret, so this thin is what the link runs.
// Unary minus of TYPE_VECTOR (kind 13) is accepted here. Every other
// unary, including ~ and ! on a vector, is the demoted live body.
// PLATFORM: SHARED — type rule is the same on macOS, Ubuntu, and Windows.
// The demote/retarget step that makes this symbol win is Mach-O only.

export extern "C" function typeck_check_expr_unary__demoted(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern "C" function typeck_check_expr(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_arena_num_types(arena: *u8): i32;
export extern "C" function pipeline_expr_set_resolved_type_ref(arena: *u8, expr_ref: i32, ty: i32): void;

/**
 * Accept unary minus of a TYPE_VECTOR, otherwise call the demoted body.
 * @param module *u8 — caller module; null defers to the demoted body
 * @param arena *u8 — AST arena; null defers to the demoted body
 * @param expr_ref i32 — unary expr; <= 0 defers to the demoted body
 * @param return_type_ref i32 — enclosing return type, passed through
 * @param ctx *u8 — dep context, passed through; may be null
 * @return i32 — 0 when the unary typechecks, -1 on failure
 * Kind 13 is still an aggregate for comparison, bitwise not, and logical
 * not. Those expr kinds never enter the accept path. The operand is
 * typechecked once on the accept path and not again: the demoted body
 * still rejects kind 13 and would emit T001. A non-vector unary minus
 * falls through to that body, which typechecks the operand itself.
 * Two compares, not a chained && : the bootstrap image clobbers the
 * register a chained compare reuses.
 * PLATFORM: SHARED — same type rule on every host.
 */
#[no_mangle]
export function typeck_check_expr_unary(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    let ord_neg: i32 = 22;
    let ord_vector: i32 = 13;
    let expr_kind: i32 = 0;
    let op_ref: i32 = 0;
    let op_tr: i32 = 0;
    let ntypes: i32 = 0;
    let accept: i32 = 0;
    let rc: i32 = 0;
    if (module == 0 as *u8 || arena == 0 as *u8 || expr_ref <= 0) {
      return typeck_check_expr_unary__demoted(
        module, arena, expr_ref, return_type_ref, ctx);
    }
    expr_kind = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (expr_kind != ord_neg) {
      return typeck_check_expr_unary__demoted(
        module, arena, expr_ref, return_type_ref, ctx);
    }
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    rc = typeck_check_expr(module, arena, op_ref, return_type_ref, ctx);
    if (rc != 0) {
      return 0 - 1;
    }
    op_tr = pipeline_expr_resolved_type_ref(arena, op_ref);
    ntypes = pipeline_arena_num_types(arena);
    /*
     * Stamp the operand type only for a real TYPE_VECTOR slot.
     * Out-of-range refs stay on the demoted body.
     */
    if (op_tr > 0) {
      if (op_tr <= ntypes) {
        if (pipeline_type_kind_ord_at(arena, op_tr) == ord_vector) {
          accept = 1;
        }
      }
    }
    if (accept == 1) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, op_tr);
      return 0;
    }
    return typeck_check_expr_unary__demoted(
      module, arena, expr_ref, return_type_ref, ctx);
  }
}
