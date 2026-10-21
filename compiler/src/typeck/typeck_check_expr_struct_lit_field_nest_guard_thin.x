// note743y.6.6: tip-peel nest guard for struct-lit field walk.
// Imported Split_u8 + nested anon `{ left: { data, length }, right: … }`
// SEGVs in typeck_check_expr_struct_lit↔field (cycle / bogus init_ref).
// First-wins over seed/egg field walker. PLATFORM: SHARED · LINUX tip cold.

export extern "C" function pipeline_expr_struct_lit_init_ref(
  arena: *u8, expr_ref: i32, field_i: i32): i32;
export extern "C" function typeck_check_expr(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern "C" function pipeline_dep_ctx_typeck_unsafe_depth_at(ctx: *u8): i32;
export extern "C" function pipeline_typeck_unsafe_depth_push_c(ctx: *u8): i32;
export extern "C" function pipeline_typeck_unsafe_depth_pop_c(ctx: *u8, saved: i32): void;

/**
 * Walk STRUCT_LIT fields with cycle / nest guards (note743y.6.6).
 * @return i32 — 0 ok, -1 typeck fail
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_check_expr_struct_lit_field(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8,
  field_i: i32, num_fields: i32): i32 {
  unsafe {
    let init_sl: i32 = 0;
    let saved: i32 = 0;
    let depth: i32 = 0;
    let rc: i32 = 0;
    if (field_i >= num_fields) {
      return 0;
    }
    if (num_fields < 0 || num_fields > 256) {
      return 0 - 1;
    }
    if (arena == (0 as *u8) || expr_ref <= 0) {
      return 0 - 1;
    }
    if (ctx != (0 as *u8)) {
      depth = pipeline_dep_ctx_typeck_unsafe_depth_at(ctx);
      if (depth > 64) {
        return 0 - 1;
      }
    }
    init_sl = pipeline_expr_struct_lit_init_ref(arena, expr_ref, field_i);
    if (init_sl <= 0 || init_sl == expr_ref) {
      return typeck_check_expr_struct_lit_field(
        module, arena, expr_ref, return_type_ref, ctx, field_i + 1, num_fields);
    }
    /* expected=0: do not pass outer return type into field CALL. */
    if (ctx != (0 as *u8)) {
      saved = pipeline_typeck_unsafe_depth_push_c(ctx);
    }
    rc = typeck_check_expr(module, arena, init_sl, 0, ctx);
    if (ctx != (0 as *u8)) {
      pipeline_typeck_unsafe_depth_pop_c(ctx, saved);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return typeck_check_expr_struct_lit_field(
      module, arena, expr_ref, return_type_ref, ctx, field_i + 1, num_fields);
  }
}
