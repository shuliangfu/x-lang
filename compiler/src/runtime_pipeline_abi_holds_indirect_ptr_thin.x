// Local-slot holds-indirect-ptr using widen_type_kind_ord so a
// type_ref outside the cached num_types word still sees TYPE_PTR
// and the emitter loads the pointer, not the slot address.
// Does not replace pipeline_type_kind_ord_at (typeck keeps that face).
// PLATFORM: SHARED.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function asm_ctx_scope_block_ref_at(asm_ctx: *u8): i32;
export extern function pipeline_block_resolve_var_type_ref(arena: *u8, br: i32, vname: *u8, vlen: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_var_is_emit_func_param_ptr_c(arena: *u8, mod: *u8, asm_ctx: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena: *u8, mod: *u8, expr_ref: i32): i32;
export extern function glue_type_ref_is_named_struct_layout(arena: *u8, mod: *u8, ty_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function arena_sidecar_get(key: *u8, create: i32): *u8;
export extern function grow_vec_at(v: *u8, index: i32): *u8;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * Return 1 when the local slot holds a pointer value that INDEX
 * must load, rather than the address of an on-stack array.
 * Kind 9 (TYPE_PTR) is read through pipeline_widen_type_kind_ord.
 * PLATFORM: SHARED.
 */

/**
 * Type.kind with sidecar-on-miss, same path as 83d6a7b85 widen_type_kind_ord.
 * pipeline_type_kind_ord_at is tried first; sidecar only when it returns < 0.
 * PLATFORM: SHARED.
 */
function widen_type_kind_ord(arena: *u8, type_ref: i32): i32 {
  let kind: i32 = 0 - 1;
  let sc: *u8 = 0 as *u8;
  let n: i32 = 0;
  let slot: *u8 = 0 as *u8;
  if (arena == (0 as *u8) || type_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    kind = pipeline_type_kind_ord_at(arena, type_ref);
  }
  if (kind >= 0) {
    return kind;
  }
  unsafe {
    sc = arena_sidecar_get(arena, 0);
  }
  if (sc == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    n = pipe_load_i32_le(sc + (16 as usize), 12);
  }
  if (type_ref > n) {
    return 0 - 1;
  }
  unsafe {
    slot = grow_vec_at(sc + (16 as usize), type_ref - 1);
  }
  if (slot == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    kind = pipe_load_i32_le(slot, 0);
  }
  return kind;
}

#[no_mangle]
export function asm_local_var_slot_holds_indirect_ptr(arena: *u8, expr_ref: i32, mod: *u8, asm_ctx: *u8): i32 {
  let has_block_decl: i32 = 0;
  let decl_ty: i32 = 0;
  let ko: i32 = 0;
  let vlen: i32 = 0;
  let scope_br: i32 = 0;
  let kind: i32 = 0;
  let tr: i32 = 0;
  let kind2: i32 = 0;
  let vname: u8[256] = [];
  if (arena == (0 as *u8)) {
    return 0;
  }
  if (expr_ref <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (asm_ctx != (0 as *u8)) {
    if (ko == 3) {
      unsafe {
        vlen = pipeline_expr_var_name_len(arena, expr_ref);
      }
      if (vlen > 0) {
        if (vlen <= 63) {
          unsafe {
            pipeline_expr_var_name_into(arena, expr_ref, &vname[0]);
            scope_br = asm_ctx_scope_block_ref_at(asm_ctx);
          }
          if (scope_br > 0) {
            unsafe {
              decl_ty = pipeline_block_resolve_var_type_ref(arena, scope_br, &vname[0], vlen);
            }
            if (decl_ty > 0) {
              has_block_decl = 1;
            }
          }
        }
      }
    }
  }
  if (has_block_decl != 0) {
    unsafe {
      kind = widen_type_kind_ord(arena, decl_ty);
    }
    if (kind == 9) {
      return 1;
    }
    let named1: i32 = 0;
    unsafe {
      named1 = glue_type_ref_is_named_struct_layout(arena, mod, decl_ty);
    }
    if (named1 != 0) {
      return 0;
    }
    return 0;
  }
  unsafe {
    tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  }
  if (tr <= 0) {
    unsafe {
      if (pipeline_asm_var_is_emit_func_param_ptr_c(arena, mod, asm_ctx, expr_ref) != 0) {
        return 1;
      }
    }
    if (mod != (0 as *u8)) {
      unsafe {
        if (pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, expr_ref) != 0) {
          return 1;
        }
      }
    }
    return 0;
  }
  unsafe {
    kind2 = widen_type_kind_ord(arena, tr);
  }
  if (kind2 == 9) {
    return 1;
  }
  let named2: i32 = 0;
  unsafe {
    named2 = glue_type_ref_is_named_struct_layout(arena, mod, tr);
  }
  if (named2 != 0) {
    if (mod != (0 as *u8)) {
      unsafe {
        if (pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, expr_ref) != 0) {
          return 1;
        }
      }
    }
    return 0;
  }
  if (kind2 == 8) {
    return 0;
  }
  unsafe {
    if (pipeline_asm_var_is_emit_func_param_ptr_c(arena, mod, asm_ctx, expr_ref) != 0) {
      return 1;
    }
  }
  return 0;
}
