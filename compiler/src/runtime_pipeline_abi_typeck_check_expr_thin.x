// Thin pure: wave319/343/344/346/348/379/530/531 M2 — typeck_check_expr Cap residual.
// Dispatch check_expr_*_c + match subject BSS + repr/extern gates; ~22 exports.
// G.7: bodies match seed WAVE286 (#define ordinals — no mutable storage).
// wave346: ordinal `let`→`const`. wave348: Darwin PREFER historic overlay.
// wave379 HARD BAN reinject: Ubuntu tip XT001 even -E; Darwin tip PREFER
//   reinject → ARM64_RELOC_BRANCH26. Stay prior overlay both ends.
// wave531 Soft Cap peer-flat: faces-only (mega/impl/check → peer thins);
//   tipU Soft Cap; stamp w531 HARD BAN tip PRODUCT reinject.
// wave530 Soft Cap: tip XT001 heal — w286 pipe_load unsafe + flatten mega/impl_c
//   (ban nested lets in unsafe; ban raw `*((a+4) as *i32)`); tipU Soft Cap;
//   stamp w530 HARD BAN tip PRODUCT reinject (keep prior overlay).
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
export extern function typeck_match_subject_field_type(module: *u8, arena: *u8, name: *u8, name_len: i32): i32;
export extern function typeck_call_arg_repr_compatible_ok(module: *u8, arena: *u8, param_ref: i32, arg_ref: i32): i32;
export extern function typeck_check_extern_call_unsafe_boundary(module: *u8, arena: *u8, expr_ref: i32, ctx: *u8): i32;

// wave286: match subject BSS (field-bind VAR resolve + nested save/restore).
let g_w286_typeck_match_subject_ty: i32 = 0;
let g_w286_typeck_match_subject_mod: *u8 = 0 as *u8;

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

