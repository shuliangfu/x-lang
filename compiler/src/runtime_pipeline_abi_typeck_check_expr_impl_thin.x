// Thin pure: wave531 Soft Cap peer — typeck_check_expr impl_c + check_expr_c.
// G.7: bodies match Cap faces (peer-flat from typeck_check_expr_thin).
// wave531: Soft Cap tip CG002 split + pipe-cell tipU; PRODUCT HARD BAN (stamp w531).
// PLATFORM: SHARED Soft Cap tip heal / LINUX gold / MACOS co-path.

const W286_EXPR_LIT: i32 = 0;
const W286_EXPR_FLOAT_LIT: i32 = 1;
const W286_EXPR_BOOL_LIT: i32 = 2;
const W286_EXPR_IF: i32 = 25;
const W286_EXPR_BLOCK: i32 = 26;
const W286_EXPR_TERNARY: i32 = 27;
const W286_EXPR_BREAK: i32 = 39;
const W286_EXPR_CONTINUE: i32 = 40;
const W286_EXPR_MATCH: i32 = 43;
const W286_EXPR_ENUM_VARIANT: i32 = 50;
const W286_EXPR_TRY_PROPAGATE: i32 = 58;
const W286_EXPR_C_TRY_PROPAGATE: i32 = 57;
const W286_EXPR_STRING_LIT: i32 = 59;
const W286_TYPE_PTR: i32 = 9;
const W286_TYPE_ARRAY: i32 = 10;
const W286_TYPE_SLICE: i32 = 11;
const W286_ARENA_NUM_EXPRS: i32 = 4;

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_expr_kind_ord_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_set_resolved_type_ref(a: *u8, expr_ref: i32, ty: i32): void;
export extern function pipeline_type_kind_ord_at(a: *u8, type_ref: i32): i32;
export extern function pipeline_arena_num_types(a: *u8): i32;
export extern function check_expr_impl_mega(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_float_lit(arena: *u8, expr_ref: i32): i32;
export extern function typeck_check_expr_int_lit(arena: *u8, expr_ref: i32, return_type_ref: i32): i32;
export extern function typeck_check_expr_bool_lit(arena: *u8, expr_ref: i32): i32;
export extern function typeck_check_expr_break_continue(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_enum_variant(arena: *u8, expr_ref: i32): i32;
export extern function typeck_check_expr_if_ternary(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_block(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_match(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_try_propagate(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_ensure_u8_type_ref(arena: *u8): i32;
export extern function typeck_find_or_alloc_ptr_type_ref(arena: *u8, elem_ref: i32): i32;

function w286_ref_is_null(ref: i32): i32 {
  if (ref == 0) { return 1; }
  return 0;
}

/**
 * check_expr_impl C delegate: simple kinds + mega fallback.
 * wave531: pipe-cell mid-call; ban nested lets.
 * PLATFORM: SHARED Soft Cap tip heal (wave531).
 */
#[no_mangle]
export function pipeline_typeck_check_expr_impl_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  let kind: i32 = 0;
  let nexpr: i32 = 0;
  let u8r: i32 = 0;
  let slice_u8: i32 = 0;
  let exp_kind: i32 = 0;
  let ntypes: i32 = 0;
  let icell: u8[4] = [];
  if (arena == (0 as *u8) || expr_ref <= 0) { return 0; }
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipe_load_i32_le(arena, W286_ARENA_NUM_EXPRS));
    nexpr = pipe_load_i32_le(&icell[0], 0);
  }
  if (expr_ref > nexpr) { return 0; }
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_expr_kind_ord_at(arena, expr_ref));
    kind = pipe_load_i32_le(&icell[0], 0);
  }
  if (kind == W286_EXPR_FLOAT_LIT) {
    unsafe { return typeck_check_expr_float_lit(arena, expr_ref); }
  }
  if (kind == W286_EXPR_LIT) {
    unsafe { return typeck_check_expr_int_lit(arena, expr_ref, return_type_ref); }
  }
  if (kind == W286_EXPR_BOOL_LIT) {
    unsafe { return typeck_check_expr_bool_lit(arena, expr_ref); }
  }
  if (kind == W286_EXPR_STRING_LIT) {
    unsafe {
      pipe_store_i32_le(&icell[0], 0, pipeline_arena_num_types(arena));
      ntypes = pipe_load_i32_le(&icell[0], 0);
    }
    if (w286_ref_is_null(return_type_ref) == 0 && return_type_ref > 0 && return_type_ref <= ntypes) {
      unsafe {
        pipe_store_i32_le(&icell[0], 0, pipeline_type_kind_ord_at(arena, return_type_ref));
        exp_kind = pipe_load_i32_le(&icell[0], 0);
      }
      if (exp_kind == W286_TYPE_PTR || exp_kind == W286_TYPE_ARRAY || exp_kind == W286_TYPE_SLICE) {
        unsafe { pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref); }
        return 0;
      }
    }
    unsafe {
      pipe_store_i32_le(&icell[0], 0, typeck_ensure_u8_type_ref(arena));
      u8r = pipe_load_i32_le(&icell[0], 0);
    }
    if (w286_ref_is_null(u8r) != 0) { return -1; }
    unsafe {
      pipe_store_i32_le(&icell[0], 0, typeck_find_or_alloc_ptr_type_ref(arena, u8r));
      slice_u8 = pipe_load_i32_le(&icell[0], 0);
    }
    if (w286_ref_is_null(slice_u8) == 0) {
      unsafe { pipeline_expr_set_resolved_type_ref(arena, expr_ref, slice_u8); }
    }
    return 0;
  }
  if (kind == W286_EXPR_BREAK || kind == W286_EXPR_CONTINUE) {
    unsafe { return typeck_check_expr_break_continue(module, arena, expr_ref, return_type_ref, ctx); }
  }
  if (kind == W286_EXPR_ENUM_VARIANT) {
    unsafe { return typeck_check_expr_enum_variant(arena, expr_ref); }
  }
  if (kind == W286_EXPR_IF || kind == W286_EXPR_TERNARY) {
    unsafe { return typeck_check_expr_if_ternary(module, arena, expr_ref, return_type_ref, ctx); }
  }
  if (kind == W286_EXPR_BLOCK) {
    unsafe { return typeck_check_expr_block(module, arena, expr_ref, return_type_ref, ctx); }
  }
  if (kind == W286_EXPR_MATCH) {
    unsafe { return typeck_check_expr_match(module, arena, expr_ref, return_type_ref, ctx); }
  }
  unsafe { return check_expr_impl_mega(module, arena, expr_ref, return_type_ref, ctx); }
}

/**
 * check_expr C delegate: bounds + try_propagate fast-path + impl_c.
 * PLATFORM: SHARED Soft Cap tip heal (wave531).
 */
#[no_mangle]
export function pipeline_typeck_check_expr_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  let rc: i32 = 0;
  let kind: i32 = 0;
  let nexpr: i32 = 0;
  let icell: u8[4] = [];
  if (w286_ref_is_null(expr_ref) != 0) { return 0; }
  if (arena == (0 as *u8) || expr_ref <= 0) { return 0; }
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipe_load_i32_le(arena, W286_ARENA_NUM_EXPRS));
    nexpr = pipe_load_i32_le(&icell[0], 0);
  }
  if (expr_ref > nexpr) { return 0; }
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_expr_kind_ord_at(arena, expr_ref));
    kind = pipe_load_i32_le(&icell[0], 0);
  }
  if (kind == W286_EXPR_TRY_PROPAGATE || kind == W286_EXPR_C_TRY_PROPAGATE) {
    unsafe { return typeck_check_expr_try_propagate(module, arena, expr_ref, return_type_ref, ctx); }
  }
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_typeck_check_expr_impl_c(module, arena, expr_ref, return_type_ref, ctx));
    rc = pipe_load_i32_le(&icell[0], 0);
  }
  return rc;
}
