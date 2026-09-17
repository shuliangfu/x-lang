// Thin pure: wave319/343/344/346/348/379 M2 — typeck_check_expr Cap residual.
// Dispatch check_expr_*_c + match subject BSS + repr/extern gates; ~22 exports.
// G.7: bodies match seed WAVE286 (#define ordinals — no mutable storage).
// wave346: ordinal `let`→`const`. wave348: Darwin PREFER historic overlay.
// wave379 HARD BAN reinject: Ubuntu tip XT001 even -E; Darwin tip PREFER
//   reinject → ARM64_RELOC_BRANCH26. Stay prior overlay both ends.
// Cold WEAK check_expr_impl{,_mega} NOT defined here — typeck_x.o provides strong.
// PLATFORM: SHARED · BAN reinject both ends.

// ExprKind / TypeKind product ordinals — const (seed #define twin; no let storage).
const W286_EXPR_LIT: i32 = 0;
const W286_EXPR_FLOAT_LIT: i32 = 1;
const W286_EXPR_BOOL_LIT: i32 = 2;
const W286_EXPR_VAR: i32 = 3;
const W286_EXPR_ADD: i32 = 4;
const W286_EXPR_LOGOR: i32 = 21;
const W286_EXPR_NEG: i32 = 22;
const W286_EXPR_BITNOT: i32 = 23;
const W286_EXPR_LOGNOT: i32 = 24;
const W286_EXPR_IF: i32 = 25;
const W286_EXPR_BLOCK: i32 = 26;
const W286_EXPR_TERNARY: i32 = 27;
const W286_EXPR_BREAK: i32 = 39;
const W286_EXPR_CONTINUE: i32 = 40;
const W286_EXPR_RETURN: i32 = 41;
const W286_EXPR_PANIC: i32 = 42;
const W286_EXPR_MATCH: i32 = 43;
const W286_EXPR_FIELD_ACCESS: i32 = 44;
const W286_EXPR_STRUCT_LIT: i32 = 45;
const W286_EXPR_INDEX: i32 = 47;
const W286_EXPR_CALL: i32 = 48;
const W286_EXPR_METHOD_CALL: i32 = 49;
const W286_EXPR_ENUM_VARIANT: i32 = 50;
const W286_EXPR_ADDR_OF: i32 = 51;
const W286_EXPR_DEREF: i32 = 52;
const W286_EXPR_AS: i32 = 54;
const W286_EXPR_TRY_PROPAGATE: i32 = 58;
const W286_EXPR_C_TRY_PROPAGATE: i32 = 57;
const W286_EXPR_STRING_LIT: i32 = 59;
const W286_TYPE_PTR: i32 = 9;
const W286_TYPE_ARRAY: i32 = 10;
const W286_TYPE_SLICE: i32 = 11;

export extern function pipeline_expr_kind_ord_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_set_resolved_type_ref(a: *u8, expr_ref: i32, ty: i32): void;
export extern function pipeline_type_kind_ord_at(a: *u8, type_ref: i32): i32;
export extern function pipeline_arena_num_types(a: *u8): i32;
export extern function check_expr_impl_mega(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
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
export extern function typeck_check_expr_unary(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_addr_of(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_index(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_deref(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_var(module: *u8, arena: *u8, expr_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_return(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_match(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_try_propagate(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_call(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_field_access(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_binop(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_as(module: *u8, arena: *u8, expr_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_struct_lit(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_float_lit(arena: *u8, expr_ref: i32): i32;
export extern function typeck_check_expr_int_lit(arena: *u8, expr_ref: i32, return_type_ref: i32): i32;
export extern function typeck_check_expr_bool_lit(arena: *u8, expr_ref: i32): i32;
export extern function typeck_check_expr_break_continue(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_enum_variant(arena: *u8, expr_ref: i32): i32;
export extern function typeck_check_expr_if_ternary(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_check_expr_block(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern function typeck_ensure_u8_type_ref(arena: *u8): i32;
export extern function typeck_find_or_alloc_ptr_type_ref(arena: *u8, elem_ref: i32): i32;
export extern function typeck_match_subject_field_type(module: *u8, arena: *u8, name: *u8, name_len: i32): i32;
export extern function typeck_call_arg_repr_compatible_ok(module: *u8, arena: *u8, param_ref: i32, arg_ref: i32): i32;
export extern function typeck_check_extern_call_unsafe_boundary(module: *u8, arena: *u8, expr_ref: i32, ctx: *u8): i32;

// wave286: match subject BSS (field-bind VAR resolve + nested save/restore).
let g_w286_typeck_match_subject_ty: i32 = 0;
let g_w286_typeck_match_subject_mod: *u8 = 0 as *u8;

/**
 * Arena LE: num_exprs at offset 4 (LP64 ASTArena header).
 * @param a *u8 — ASTArena*
 * @return i32 — num_exprs or 0
 */
function w286_arena_num_exprs(a: *u8): i32 {
  if (a == (0 as *u8)) {
    return 0;
  }
  unsafe {
    return *((a + 4) as *i32);
  }
}

/**
 * Null-ref predicate for 1-based arena refs.
 * @param ref i32
 * @return i32 — 1 if null/0 else 0
 */
function w286_ref_is_null(ref: i32): i32 {
  if (ref == 0) {
    return 1;
  }
  return 0;
}

/**
 * Set match subject type for field-bind VAR resolve.
 * @param module *u8
 * @param ty i32
 * @return i32 — always 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_match_set_subject_c(module: *u8, ty: i32): i32 {
  g_w286_typeck_match_subject_mod = module;
  g_w286_typeck_match_subject_ty = ty;
  return 0;
}

/**
 * Clear match subject field-bind context.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_match_clear_subject_c(): void {
  g_w286_typeck_match_subject_mod = 0 as *u8;
  g_w286_typeck_match_subject_ty = 0;
}

/**
 * Read subject type_ref for nested match save/restore.
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_match_subject_ty_get_c(): i32 {
  return g_w286_typeck_match_subject_ty;
}

/**
 * Read subject module for nested match save/restore.
 * @return *u8
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_match_subject_mod_get_c(): *u8 {
  return g_w286_typeck_match_subject_mod;
}

/**
 * Match subject field-bind type lookup.
 * @param module *u8
 * @param arena *u8
 * @param name *u8
 * @param name_len i32
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_match_subject_field_type_c(module: *u8, arena: *u8, name: *u8, name_len: i32): i32 {
  unsafe {
    return typeck_match_subject_field_type(module, arena, name, name_len);
  }
}

/**
 * Product face EXPR_PANIC.
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_check_expr_panic_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    return typeck_check_expr_panic(module, arena, expr_ref, return_type_ref, ctx);
  }
}

/**
 * Product face EXPR_MATCH.
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_check_expr_match_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    return typeck_check_expr_match(module, arena, expr_ref, return_type_ref, ctx);
  }
}

/**
 * Product face EXPR_RETURN.
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_check_expr_return_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    return typeck_check_expr_return(module, arena, expr_ref, return_type_ref, ctx);
  }
}

/**
 * Product face NEG/BITNOT/LOGNOT.
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_check_expr_unary_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    return typeck_check_expr_unary(module, arena, expr_ref, return_type_ref, ctx);
  }
}

/**
 * Product face EXPR_ADDR_OF.
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_check_expr_addr_of_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    return typeck_check_expr_addr_of(module, arena, expr_ref, return_type_ref, ctx);
  }
}

/**
 * Product face EXPR_DEREF.
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_check_expr_deref_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    return typeck_check_expr_deref(module, arena, expr_ref, return_type_ref, ctx);
  }
}

/**
 * Product face EXPR_INDEX.
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_check_expr_index_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    return typeck_check_expr_index(module, arena, expr_ref, return_type_ref, ctx);
  }
}

/**
 * Product face EXPR_VAR.
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_check_expr_var_c(module: *u8, arena: *u8, expr_ref: i32, ctx: *u8): i32 {
  unsafe {
    return typeck_check_expr_var(module, arena, expr_ref, ctx);
  }
}

/**
 * Product face EXPR_TRY_PROPAGATE.
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_check_expr_try_propagate_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    return typeck_check_expr_try_propagate(module, arena, expr_ref, return_type_ref, ctx);
  }
}

/**
 * Product face EXPR_CALL.
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_check_expr_call_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    return typeck_check_expr_call(module, arena, expr_ref, return_type_ref, ctx);
  }
}

/**
 * Product face #[repr(compatible)] gate.
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_call_arg_repr_compatible_ok_c(module: *u8, arena: *u8, param_ref: i32, arg_ref: i32): i32 {
  unsafe {
    return typeck_call_arg_repr_compatible_ok(module, arena, param_ref, arg_ref);
  }
}

/**
 * Product face LANG-007 S0 extern-call unsafe boundary.
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_check_extern_call_unsafe_boundary_c(module: *u8, arena: *u8, expr_ref: i32, ctx: *u8): i32 {
  unsafe {
    return typeck_check_extern_call_unsafe_boundary(module, arena, expr_ref, ctx);
  }
}

/**
 * check_expr_impl_mega C delegate: ExprKind dispatch + escape gates.
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_check_expr_impl_mega_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  let kind: i32 = 0;
  let nexpr: i32 = 0;
  nexpr = w286_arena_num_exprs(arena);
  if (arena == (0 as *u8) || expr_ref <= 0 || expr_ref > nexpr) {
    return 0;
  }
  unsafe {
    kind = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  unsafe {
    if (pipeline_typeck_expr_is_any_assign_kind_c(kind) != 0) {
      let left_ref: i32 = pipeline_expr_binop_left_ref_at(arena, expr_ref);
      let right_ref: i32 = pipeline_expr_binop_right_ref_at(arena, expr_ref);
      let rc: i32 = 0;
      if (pipeline_typeck_check_struct_stack_escape_assign_c(module, arena, expr_ref, left_ref, right_ref, ctx) != 0) {
        return -1;
      }
      if (pipeline_typeck_check_scope_borrow_assign_c(module, arena, expr_ref, left_ref, right_ref, ctx) != 0) {
        return -1;
      }
      if (pipeline_typeck_check_allocator_region_assign_c(module, arena, expr_ref, left_ref, ctx) != 0) {
        return -1;
      }
      rc = pipeline_typeck_check_expr_assign_c(module, arena, expr_ref, return_type_ref, ctx);
      if (rc != 0) {
        return rc;
      }
      return 0;
    }
  }
  if (kind == W286_EXPR_RETURN) {
    let op_ref: i32 = 0;
    let rc: i32 = 0;
    unsafe {
      op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
      if (pipeline_typeck_check_scope_borrow_return_c(module, arena, expr_ref, op_ref, return_type_ref, ctx) != 0) {
        return -1;
      }
      if (pipeline_typeck_check_allocator_region_return_c(arena, expr_ref, return_type_ref) != 0) {
        return -1;
      }
      if (pipeline_typeck_check_return_slice_region_in_scope_c(arena, expr_ref, return_type_ref, ctx) != 0) {
        return -1;
      }
      if (pipeline_typeck_check_return_slice_region_c(arena, expr_ref, op_ref, return_type_ref) != 0) {
        return -1;
      }
      rc = pipeline_typeck_check_expr_return_c(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (rc != 0) {
      return rc;
    }
    return 0;
  }
  unsafe {
    if (kind == W286_EXPR_PANIC) {
      return typeck_check_expr_panic(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == W286_EXPR_MATCH) {
      return typeck_check_expr_match(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == W286_EXPR_FIELD_ACCESS) {
      return typeck_check_expr_field_access(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == W286_EXPR_INDEX) {
      return typeck_check_expr_index(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == W286_EXPR_CALL) {
      let rc: i32 = pipeline_typeck_check_expr_call_c(module, arena, expr_ref, return_type_ref, ctx);
      if (rc != 0) {
        return rc;
      }
      return pipeline_typeck_check_call_struct_stack_escape_c(module, arena, expr_ref, ctx);
    }
    if (kind == W286_EXPR_METHOD_CALL) {
      return pipeline_typeck_check_expr_method_call_c(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind >= W286_EXPR_ADD && kind <= W286_EXPR_LOGOR) {
      return typeck_check_expr_binop(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == W286_EXPR_NEG || kind == W286_EXPR_BITNOT || kind == W286_EXPR_LOGNOT) {
      return typeck_check_expr_unary(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == W286_EXPR_ADDR_OF) {
      return typeck_check_expr_addr_of(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == W286_EXPR_DEREF) {
      return typeck_check_expr_deref(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == W286_EXPR_VAR) {
      return typeck_check_expr_var(module, arena, expr_ref, ctx);
    }
    if (kind == W286_EXPR_AS) {
      return typeck_check_expr_as(module, arena, expr_ref, ctx);
    }
    if (kind == W286_EXPR_TRY_PROPAGATE || kind == W286_EXPR_C_TRY_PROPAGATE) {
      return typeck_check_expr_try_propagate(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == W286_EXPR_STRUCT_LIT) {
      return typeck_check_expr_struct_lit(module, arena, expr_ref, return_type_ref, ctx);
    }
  }
  return 0;
}

/**
 * check_expr_impl C delegate: simple kinds + mega fallback.
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_check_expr_impl_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  let kind: i32 = 0;
  let nexpr: i32 = 0;
  nexpr = w286_arena_num_exprs(arena);
  if (arena == (0 as *u8) || expr_ref <= 0 || expr_ref > nexpr) {
    return 0;
  }
  unsafe {
    kind = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (kind == W286_EXPR_FLOAT_LIT) {
      return typeck_check_expr_float_lit(arena, expr_ref);
    }
    if (kind == W286_EXPR_LIT) {
      return typeck_check_expr_int_lit(arena, expr_ref, return_type_ref);
    }
    if (kind == W286_EXPR_BOOL_LIT) {
      return typeck_check_expr_bool_lit(arena, expr_ref);
    }
    if (kind == W286_EXPR_STRING_LIT) {
      let u8r: i32 = 0;
      let slice_u8: i32 = 0;
      let exp_kind: i32 = 0;
      let ntypes: i32 = pipeline_arena_num_types(arena);
      if (w286_ref_is_null(return_type_ref) == 0 && return_type_ref > 0 && return_type_ref <= ntypes) {
        exp_kind = pipeline_type_kind_ord_at(arena, return_type_ref);
        if (exp_kind == W286_TYPE_PTR || exp_kind == W286_TYPE_ARRAY || exp_kind == W286_TYPE_SLICE) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref);
          return 0;
        }
      }
      u8r = typeck_ensure_u8_type_ref(arena);
      if (w286_ref_is_null(u8r) != 0) {
        return -1;
      }
      slice_u8 = typeck_find_or_alloc_ptr_type_ref(arena, u8r);
      if (w286_ref_is_null(slice_u8) == 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, slice_u8);
      }
      return 0;
    }
    if (kind == W286_EXPR_BREAK || kind == W286_EXPR_CONTINUE) {
      return typeck_check_expr_break_continue(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == W286_EXPR_ENUM_VARIANT) {
      return typeck_check_expr_enum_variant(arena, expr_ref);
    }
    if (kind == W286_EXPR_IF || kind == W286_EXPR_TERNARY) {
      return typeck_check_expr_if_ternary(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == W286_EXPR_BLOCK) {
      return typeck_check_expr_block(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == W286_EXPR_MATCH) {
      return typeck_check_expr_match(module, arena, expr_ref, return_type_ref, ctx);
    }
    return check_expr_impl_mega(module, arena, expr_ref, return_type_ref, ctx);
  }
}

/**
 * check_expr C delegate: bounds + try_propagate fast-path + impl_c.
 * @return i32
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_check_expr_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  let rc: i32 = 0;
  let kind: i32 = 0;
  let nexpr: i32 = 0;
  if (w286_ref_is_null(expr_ref) != 0) {
    return 0;
  }
  nexpr = w286_arena_num_exprs(arena);
  if (expr_ref <= 0 || arena == (0 as *u8) || expr_ref > nexpr) {
    return 0;
  }
  unsafe {
    kind = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (kind == W286_EXPR_TRY_PROPAGATE || kind == W286_EXPR_C_TRY_PROPAGATE) {
      return pipeline_typeck_check_expr_try_propagate_c(module, arena, expr_ref, return_type_ref, ctx);
    }
    rc = pipeline_typeck_check_expr_impl_c(module, arena, expr_ref, return_type_ref, ctx);
  }
  // Debug getenv path omitted (no-op); product L2 does not require XLANG_DEBUG_PIPE.
  return rc;
}
