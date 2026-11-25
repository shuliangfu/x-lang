// Local-slot holds-indirect-ptr using widen_type_kind_ord so a
// type_ref outside the cached num_types word still sees TYPE_PTR
// and the emitter loads the pointer, not the slot address.
// Does not replace pipeline_type_kind_ord_at (typeck keeps that face).
// wave s40: no-local mid `x=call()` (T001 check_block); TYPE_NAMED=8
// returns before typool glue_type_ref_is_named_struct_layout (hangs in
// pipeline_module_struct_layout_name_byte_at / pipe_load_ptr_slot).
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
export extern function pipe_store_i32_le(p: *u8, off: i32, v: i32): void;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, p: *u8): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;

/**
 * Return 1 when the local slot holds a pointer value that INDEX
 * must load, rather than the address of an on-stack array.
 * Kind 9 (TYPE_PTR) is read through pipeline_widen_type_kind_ord.
 * PLATFORM: SHARED.
 */

/**
 * Type.kind with sidecar-on-miss, same path as 83d6a7b85 widen_type_kind_ord.
 * pipeline_type_kind_ord_at is tried first; sidecar only when it returns < 0.
 * wave s40: pipe cells, no mid `x=call()` (T001).
 * PLATFORM: SHARED.
 */
function widen_type_kind_ord(arena: *u8, type_ref: i32): i32 {
  let cell_k: u8[8];
  let cell_p: u8[8];
  if (arena == (0 as *u8) || type_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell_k[0], 0, pipeline_type_kind_ord_at(arena, type_ref));
    if (pipe_load_i32_le(&cell_k[0], 0) >= 0) {
      return pipe_load_i32_le(&cell_k[0], 0);
    }
    pipe_store_ptr_slot(&cell_p[0], 0, arena_sidecar_get(arena, 0));
    if (pipe_load_ptr_slot(&cell_p[0], 0) == (0 as *u8)) {
      return 0 - 1;
    }
    pipe_store_i32_le(&cell_k[0], 0, pipe_load_i32_le(pipe_load_ptr_slot(&cell_p[0], 0) + (16 as usize), 12));
    if (type_ref > pipe_load_i32_le(&cell_k[0], 0)) {
      return 0 - 1;
    }
    pipe_store_ptr_slot(&cell_p[0], 0, grow_vec_at(pipe_load_ptr_slot(&cell_p[0], 0) + (16 as usize), type_ref - 1));
    if (pipe_load_ptr_slot(&cell_p[0], 0) == (0 as *u8)) {
      return 0 - 1;
    }
    return pipe_load_i32_le(pipe_load_ptr_slot(&cell_p[0], 0), 0);
  }
}

#[no_mangle]
export function asm_local_var_slot_holds_indirect_ptr(arena: *u8, expr_ref: i32, mod: *u8, asm_ctx: *u8): i32 {
  /* var_name_into memset(out,0,256); skip typool u8[256]=[] emit smash */
  let vname: u8[256];
  let cell: u8[8];
  let cell2: u8[8];
  if (arena == (0 as *u8)) {
    return 0;
  }
  if (expr_ref <= 0) {
    return 0;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(arena, expr_ref));
    if (asm_ctx != (0 as *u8)) {
      if (pipe_load_i32_le(&cell[0], 0) == 3) {
        pipe_store_i32_le(&cell[0], 4, pipeline_expr_var_name_len(arena, expr_ref));
        if (pipe_load_i32_le(&cell[0], 4) > 0) {
          if (pipe_load_i32_le(&cell[0], 4) <= 63) {
            pipeline_expr_var_name_into(arena, expr_ref, &vname[0]);
            pipe_store_i32_le(&cell2[0], 0, asm_ctx_scope_block_ref_at(asm_ctx));
            if (pipe_load_i32_le(&cell2[0], 0) > 0) {
              pipe_store_i32_le(&cell2[0], 4, pipeline_block_resolve_var_type_ref(arena, pipe_load_i32_le(&cell2[0], 0), &vname[0], pipe_load_i32_le(&cell[0], 4)));
              if (pipe_load_i32_le(&cell2[0], 4) > 0) {
                pipe_store_i32_le(&cell[0], 0, widen_type_kind_ord(arena, pipe_load_i32_le(&cell2[0], 4)));
                if (pipe_load_i32_le(&cell[0], 0) == 9) {
                  return 1;
                }
                /* TYPE_NAMED=8 and every other kind in this block-decl
                 * branch already returned 0. Skip typool layout walk. */
                return 0;
              }
            }
          }
        }
      }
    }
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_resolved_type_ref(arena, expr_ref));
    if (pipe_load_i32_le(&cell[0], 0) <= 0) {
      if (pipeline_asm_var_is_emit_func_param_ptr_c(arena, mod, asm_ctx, expr_ref) != 0) {
        return 1;
      }
      if (mod != (0 as *u8)) {
        if (pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, expr_ref) != 0) {
          return 1;
        }
      }
      return 0;
    }
    pipe_store_i32_le(&cell[0], 4, widen_type_kind_ord(arena, pipe_load_i32_le(&cell[0], 0)));
    if (pipe_load_i32_le(&cell[0], 4) == 9) {
      return 1;
    }
    /* TYPE_NAMED=8: same as the named-layout hit path after the
     * indirect-struct check — skip typool layout name walk (hangs). */
    if (pipe_load_i32_le(&cell[0], 4) == 8) {
      if (mod != (0 as *u8)) {
        if (pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, expr_ref) != 0) {
          return 1;
        }
      }
      return 0;
    }
    pipe_store_i32_le(&cell2[0], 0, glue_type_ref_is_named_struct_layout(arena, mod, pipe_load_i32_le(&cell[0], 0)));
    if (pipe_load_i32_le(&cell2[0], 0) != 0) {
      if (mod != (0 as *u8)) {
        if (pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, expr_ref) != 0) {
          return 1;
        }
      }
      return 0;
    }
    if (pipeline_asm_var_is_emit_func_param_ptr_c(arena, mod, asm_ctx, expr_ref) != 0) {
      return 1;
    }
  }
  return 0;
}
