// Thin pure: wave531 Soft Cap peer — typeck_check_expr impl_mega Cap face.
// G.7: body matches pipeline_typeck_check_expr_impl_mega_c (peer-flat from
//   typeck_check_expr_thin; Ubuntu tip CG002 when co-TU with faces/helpers).
// wave531: inline pipe-cell mid-call tipU; PRODUCT inject HARD BAN (stamp w531).
// PLATFORM: SHARED Soft Cap tip heal / LINUX gold / MACOS co-path.

const W286_EXPR_PANIC: i32 = 42;
const W286_EXPR_MATCH: i32 = 43;
const W286_EXPR_FIELD_ACCESS: i32 = 44;
const W286_EXPR_INDEX: i32 = 47;
const W286_EXPR_CALL: i32 = 48;
const W286_EXPR_METHOD_CALL: i32 = 49;
const W286_EXPR_ADD: i32 = 4;
const W286_EXPR_LOGOR: i32 = 21;
const W286_EXPR_NEG: i32 = 22;
const W286_EXPR_BITNOT: i32 = 23;
const W286_EXPR_LOGNOT: i32 = 24;
const W286_EXPR_ADDR_OF: i32 = 51;
const W286_EXPR_DEREF: i32 = 52;
const W286_EXPR_VAR: i32 = 3;
const W286_EXPR_AS: i32 = 54;
const W286_EXPR_TRY_PROPAGATE: i32 = 58;
const W286_EXPR_C_TRY_PROPAGATE: i32 = 57;
const W286_EXPR_STRUCT_LIT: i32 = 45;
const W286_EXPR_RETURN: i32 = 41;
const W286_ARENA_NUM_EXPRS: i32 = 4;

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_expr_kind_ord_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_typeck_expr_is_any_assign_kind_c(kind: i32): i32;
export extern function pipeline_typeck_check_struct_stack_escape_assign_c(module: *u8, arena: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8): i32;
export extern function pipeline_typeck_check_scope_borrow_assign_c(module: *u8, arena: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8): i32;
export extern function pipeline_typeck_check_allocator_region_assign_c(module: *u8, arena: *u8, expr_ref: i32, left_ref: i32, ctx: *u8): i32;
export extern function pipeline_typeck_check_expr_assign_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function pipeline_typeck_check_scope_borrow_return_c(module: *u8, arena: *u8, expr_ref: i32, op_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function pipeline_typeck_check_allocator_region_return_c(arena: *u8, expr_ref: i32, return_type_ref: i32): i32;
export extern function pipeline_typeck_check_return_slice_region_in_scope_c(arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function pipeline_typeck_check_return_slice_region_c(arena: *u8, expr_ref: i32, op_ref: i32, return_type_ref: i32): i32;
export extern function pipeline_typeck_check_call_struct_stack_escape_c(module: *u8, arena: *u8, expr_ref: i32, ctx: *u8): i32;
export extern function pipeline_typeck_check_expr_method_call_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_panic(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_match(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_field_access(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_index(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_call(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_binop(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_unary(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_addr_of(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_deref(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_var(module: *u8, arena: *u8, expr_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_as(module: *u8, arena: *u8, expr_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_try_propagate(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_struct_lit(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_return(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;

#[no_mangle]
export function pipeline_typeck_check_expr_impl_mega_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  let kind: i32 = 0;
  let nexpr: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let op_ref: i32 = 0;
  let rc: i32 = 0;
  let is_assign: i32 = 0;
  let icell: u8[4] = [];
  if (arena == (0 as *u8)) { return 0; }
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipe_load_i32_le(arena, W286_ARENA_NUM_EXPRS));
    nexpr = pipe_load_i32_le(&icell[0], 0);
  }
  if (expr_ref <= 0 || expr_ref > nexpr) { return 0; }
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_expr_kind_ord_at(arena, expr_ref));
    kind = pipe_load_i32_le(&icell[0], 0);
  }
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_typeck_expr_is_any_assign_kind_c(kind));
    is_assign = pipe_load_i32_le(&icell[0], 0);
  }
  if (is_assign != 0) {
    unsafe {
      pipe_store_i32_le(&icell[0], 0, pipeline_expr_binop_left_ref_at(arena, expr_ref));
      left_ref = pipe_load_i32_le(&icell[0], 0);
      pipe_store_i32_le(&icell[0], 0, pipeline_expr_binop_right_ref_at(arena, expr_ref));
      right_ref = pipe_load_i32_le(&icell[0], 0);
      pipe_store_i32_le(&icell[0], 0, pipeline_typeck_check_struct_stack_escape_assign_c(module, arena, expr_ref, left_ref, right_ref, ctx));
      rc = pipe_load_i32_le(&icell[0], 0);
    }
    if (rc != 0) { return -1; }
    unsafe {
      pipe_store_i32_le(&icell[0], 0, pipeline_typeck_check_scope_borrow_assign_c(module, arena, expr_ref, left_ref, right_ref, ctx));
      rc = pipe_load_i32_le(&icell[0], 0);
    }
    if (rc != 0) { return -1; }
    unsafe {
      pipe_store_i32_le(&icell[0], 0, pipeline_typeck_check_allocator_region_assign_c(module, arena, expr_ref, left_ref, ctx));
      rc = pipe_load_i32_le(&icell[0], 0);
    }
    if (rc != 0) { return -1; }
    unsafe {
      pipe_store_i32_le(&icell[0], 0, pipeline_typeck_check_expr_assign_c(module, arena, expr_ref, return_type_ref, ctx));
      rc = pipe_load_i32_le(&icell[0], 0);
    }
    if (rc != 0) { return rc; }
    return 0;
  }
  if (kind == W286_EXPR_RETURN) {
    unsafe {
      pipe_store_i32_le(&icell[0], 0, pipeline_expr_unary_operand_ref_at(arena, expr_ref));
      op_ref = pipe_load_i32_le(&icell[0], 0);
      pipe_store_i32_le(&icell[0], 0, pipeline_typeck_check_scope_borrow_return_c(module, arena, expr_ref, op_ref, return_type_ref, ctx));
      rc = pipe_load_i32_le(&icell[0], 0);
    }
    if (rc != 0) { return -1; }
    unsafe {
      pipe_store_i32_le(&icell[0], 0, pipeline_typeck_check_allocator_region_return_c(arena, expr_ref, return_type_ref));
      rc = pipe_load_i32_le(&icell[0], 0);
    }
    if (rc != 0) { return -1; }
    unsafe {
      pipe_store_i32_le(&icell[0], 0, pipeline_typeck_check_return_slice_region_in_scope_c(arena, expr_ref, return_type_ref, ctx));
      rc = pipe_load_i32_le(&icell[0], 0);
    }
    if (rc != 0) { return -1; }
    unsafe {
      pipe_store_i32_le(&icell[0], 0, pipeline_typeck_check_return_slice_region_c(arena, expr_ref, op_ref, return_type_ref));
      rc = pipe_load_i32_le(&icell[0], 0);
    }
    if (rc != 0) { return -1; }
    unsafe {
      pipe_store_i32_le(&icell[0], 0, typeck_check_expr_return(module, arena, expr_ref, return_type_ref, ctx));
      rc = pipe_load_i32_le(&icell[0], 0);
    }
    if (rc != 0) { return rc; }
    return 0;
  }
  if (kind == W286_EXPR_PANIC) { unsafe { return typeck_check_expr_panic(module, arena, expr_ref, return_type_ref, ctx); } }
  if (kind == W286_EXPR_MATCH) { unsafe { return typeck_check_expr_match(module, arena, expr_ref, return_type_ref, ctx); } }
  if (kind == W286_EXPR_FIELD_ACCESS) { unsafe { return typeck_check_expr_field_access(module, arena, expr_ref, return_type_ref, ctx); } }
  if (kind == W286_EXPR_INDEX) { unsafe { return typeck_check_expr_index(module, arena, expr_ref, return_type_ref, ctx); } }
  if (kind == W286_EXPR_CALL) {
    unsafe {
      pipe_store_i32_le(&icell[0], 0, typeck_check_expr_call(module, arena, expr_ref, return_type_ref, ctx));
      rc = pipe_load_i32_le(&icell[0], 0);
    }
    if (rc != 0) { return rc; }
    unsafe { return pipeline_typeck_check_call_struct_stack_escape_c(module, arena, expr_ref, ctx); }
  }
  if (kind == W286_EXPR_METHOD_CALL) { unsafe { return pipeline_typeck_check_expr_method_call_c(module, arena, expr_ref, return_type_ref, ctx); } }
  if (kind >= W286_EXPR_ADD && kind <= W286_EXPR_LOGOR) { unsafe { return typeck_check_expr_binop(module, arena, expr_ref, return_type_ref, ctx); } }
  if (kind == W286_EXPR_NEG || kind == W286_EXPR_BITNOT || kind == W286_EXPR_LOGNOT) { unsafe { return typeck_check_expr_unary(module, arena, expr_ref, return_type_ref, ctx); } }
  if (kind == W286_EXPR_ADDR_OF) { unsafe { return typeck_check_expr_addr_of(module, arena, expr_ref, return_type_ref, ctx); } }
  if (kind == W286_EXPR_DEREF) { unsafe { return typeck_check_expr_deref(module, arena, expr_ref, return_type_ref, ctx); } }
  if (kind == W286_EXPR_VAR) { unsafe { return typeck_check_expr_var(module, arena, expr_ref, ctx); } }
  if (kind == W286_EXPR_AS) { unsafe { return typeck_check_expr_as(module, arena, expr_ref, ctx); } }
  if (kind == W286_EXPR_TRY_PROPAGATE || kind == W286_EXPR_C_TRY_PROPAGATE) { unsafe { return typeck_check_expr_try_propagate(module, arena, expr_ref, return_type_ref, ctx); } }
  if (kind == W286_EXPR_STRUCT_LIT) { unsafe { return typeck_check_expr_struct_lit(module, arena, expr_ref, return_type_ref, ctx); } }
  return 0;
}
