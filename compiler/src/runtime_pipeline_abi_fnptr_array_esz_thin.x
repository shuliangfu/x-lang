// Thin pure override: TYPE_FN array-lit elem stride + fixed-array temp bytes.
// 10.3.1 slice13: TYPE_FN=18 must size as Cap opaque fn-ptr (8B), same as PTR=9.
// Prior miss → force_esz=0 / elem_byte_sz=4 → `mov %eax` truncates LEA;
// INDEX 8B load + Cap blr → SEGV.
// Vector let-init (`pipeline_asm_emit_vector_let_init_elf_c`) sizes via
// pipeline_asm_array_lit_elem_byte_sz_c — that leaf must also know TYPE_FN.
// G.7: bodies MUST match the same exports in runtime_pipeline_abi.x.
// ensure injects via weaken + first-wins ld -r (seed rest holds strong defs;
// avoids Darwin mega -E).
// PLATFORM: SHARED freestanding sizing · LINUX gold · MACOS underscore.

export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_type_size_simple(mod: *u8, arena: *u8, type_ref: i32, depth: i32): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, type_ref: i32, depth: i32): i32;
export extern function pipeline_arena_num_types(arena: *u8): i32;
export extern function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_asm_array_lit_elem_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, ai: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;

/**
 * Infer ARRAY_LIT element byte width from stamped elem type (force_esz=0 path).
 * @param arena *u8 - ASTArena*
 * @param expr_ref i32 - ARRAY_LIT expr
 * @return i32 - elem bytes; default 4
 * 10.3.1 slice13: TYPE_FN=18 → 8. G.7 thin twin of mega .x.
 * PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function pipeline_asm_array_lit_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32 {
  let elem_ty: i32 = 0;
  let kind_ord: i32 = 0;
  let nested: i32 = 0;
  let first_ref: i32 = 0;
  let ssz: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let n_inner: i32 = 0;
  let iesz: i32 = 0;
  let fko: i32 = 0;
  elem_ty = pipeline_asm_array_lit_elem_type_ref(arena, expr_ref);
  if (elem_ty > 0) {
    unsafe {
      kind_ord = pipeline_type_kind_ord_at(arena, elem_ty);
    }
    if (kind_ord == 10) {
      unsafe {
        nested = glue_fixed_array_total_bytes_c(arena, elem_ty, 0);
      }
      if (nested > 0) {
        return nested;
      }
    }
    if (kind_ord == 2 || kind_ord == 1) {
      return 1;
    }
    if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14) {
      return 4;
    }
    /* TYPE_FN=18 Cap opaque with PTR=9. */
    if (kind_ord == 15 || kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7
        || kind_ord == 9 || kind_ord == 18) {
      return 8;
    }
    if (kind_ord == 11) {
      return 16;
    }
    if (kind_ord == 8) {
      unsafe {
        mod = pipeline_asm_emit_module_ref_c();
      }
      if (mod != (0 as *u8)) {
        unsafe {
          ssz = glue_type_size_simple(mod, arena, elem_ty, 0);
        }
        if (ssz > 0) {
          return ssz;
        }
      }
    }
  }
  unsafe {
    first_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, 0);
  }
  if (first_ref > 0) {
    unsafe {
      fko = pipeline_expr_kind_ord_at(arena, first_ref);
    }
    if (fko == 46) {
      unsafe {
        n_inner = pipeline_expr_array_lit_num_elems_at(arena, first_ref);
      }
      iesz = pipeline_asm_array_lit_elem_byte_sz_c(arena, first_ref);
      if (n_inner > 0 && iesz > 0) {
        return n_inner * iesz;
      }
    }
  }
  return 4;
}

/**
 * Force ARRAY_LIT element store/INDEX stride from dest elem type kind.
 * @param arena *u8 - ASTArena*
 * @param et i32 - element type_ref
 * @return i32 - force_esz (0 = lit-infer)
 * 10.3.1 slice13: TYPE_FN=18 → 8 (Cap ABI). G.7 thin twin of mega .x.
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
 */
#[no_mangle]
export function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32 {
  let ek: i32 = 0;
  let ssz: i32 = 0;
  let mod: *u8 = 0 as *u8;
  if (arena == (0 as *u8) || et <= 0) {
    return 0;
  }
  unsafe {
    ek = pipeline_type_kind_ord_at(arena, et);
  }
  if (ek == 2 || ek == 1) {
    return 1;
  }
  if (ek == 0 || ek == 3 || ek == 13 || ek == 14) {
    return 4;
  }
  /* TYPE_FN=18 shares Cap opaque fn-ptr ABI with TYPE_PTR=9. */
  if (ek == 4 || ek == 5 || ek == 6 || ek == 7 || ek == 15 || ek == 9 || ek == 18) {
    return 8;
  }
  if (ek == 8) {
    unsafe {
      mod = pipeline_asm_emit_module_ref_c();
    }
    if (mod != (0 as *u8)) {
      unsafe {
        ssz = glue_type_size_simple(mod, arena, et, 0);
      }
      if (ssz > 0) {
        return ssz;
      }
    }
  }
  /* TYPE_ARRAY=10: row stride = sizeof([N]T). */
  if (ek == 10) {
    unsafe {
      ssz = glue_fixed_array_total_bytes_c(arena, et, 0);
    }
    if (ssz > 0) {
      return ssz;
    }
  }
  if (ek == 11) {
    return 16;
  }
  return 0;
}

/**
 * Fixed-length array T[N] stack temp byte width.
 * @param arena *u8 - ASTArena*
 * @param type_ref i32 - TYPE_ARRAY type_ref
 * @return i32 - bytes; 0 if non-array / invalid
 * 10.3.1 slice13: elem TYPE_FN/PTR → esz 8. G.7 thin twin of mega .x.
 * PLATFORM: SHARED — pure type sizing; arch-agnostic.
 */
#[no_mangle]
export function glue_fixed_array_temp_bytes(arena: *u8, type_ref: i32): i32 {
  let elem_ref: i32 = 0;
  let esz: i32 = 4;
  let bytes: i32 = 0;
  let arr_sz: i32 = 0;
  let nt: i32 = 0;
  let tk: i32 = 0;
  let etk: i32 = 0;
  let mod: *u8 = 0 as *u8;
  if (arena == (0 as *u8) || type_ref <= 0) {
    return 0;
  }
  unsafe {
    nt = pipeline_arena_num_types(arena);
  }
  if (type_ref > nt) {
    return 0;
  }
  unsafe {
    arr_sz = pipeline_type_array_size_at(arena, type_ref);
  }
  if (arr_sz <= 0) {
    return 0;
  }
  unsafe {
    tk = pipeline_type_kind_ord_at(arena, type_ref);
  }
  if (tk == 10) {
    unsafe {
      mod = pipeline_asm_emit_module_ref_c();
      bytes = glue_type_size_simple(mod, arena, type_ref, 0);
    }
    if (bytes > 0) {
      return bytes;
    }
  }
  unsafe {
    elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
  }
  esz = 4;
  if (elem_ref > 0 && elem_ref <= nt) {
    unsafe {
      etk = pipeline_type_kind_ord_at(arena, elem_ref);
    }
    if (etk == 2) {
      esz = 1;
    } else {
      if (etk == 11) {
        esz = 16;
      } else {
        if (etk == 8) {
          unsafe {
            mod = pipeline_asm_emit_module_ref_c();
          }
          if (mod != (0 as *u8)) {
            esz = glue_type_size_simple(mod, arena, elem_ref, 0);
          }
          if (esz <= 0) {
            esz = 8;
          }
        } else {
          if (etk == 4 || etk == 5 || etk == 6 || etk == 7 || etk == 9 || etk == 14
              || etk == 15 || etk == 18) {
            esz = 8;
          } else {
            esz = 4;
          }
        }
      }
    }
  }
  bytes = arr_sz * esz;
  if (bytes > 0) {
    return bytes;
  }
  return 0;
}
